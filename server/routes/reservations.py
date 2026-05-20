"""Blueprint de reservas de vuelos"""
from datetime import datetime
from flask import Blueprint, request, jsonify
from mysql.connector import Error

from .utils import get_db_connection

reservations_bp = Blueprint('reservations', __name__)


def _sp_missing(exc: Error) -> bool:
    """Detecta error de SP inexistente para permitir fallback temporal."""
    msg = str(exc).lower()
    return 'procedure' in msg and 'does not exist' in msg

def _drain_call_results(cursor) -> None:
    """Consume result sets pendientes de CALL para evitar 'commands out of sync'."""
    try:
        while cursor.nextset():
            pass
    except Exception:
        pass


@reservations_bp.route('/confirmar-reserva', methods=['POST'])
def confirmar_reserva():
    """Crea reservas en usuario_reservas_vuelo para el pasajero principal y adicionales"""
    try:
        data = request.get_json() or {}
        print('CONFIRMAR RESERVA payload:', data)

        # Validar campos requeridos
        vuelo_id = data.get('vuelo_id')
        usuario_principal_id = data.get('usuario_principal_id')
        if vuelo_id is None:
            return jsonify({'error': 'Campo requerido faltante: vuelo_id'}), 400
        if usuario_principal_id is None:
            return jsonify({'error': 'Campo requerido faltante: usuario_principal_id'}), 400

        try:
            vuelo_id = int(vuelo_id)
            usuario_principal_id = int(usuario_principal_id)
        except (TypeError, ValueError):
            return jsonify({'error': 'vuelo_id y usuario_principal_id deben ser numéricos'}), 400

        pasajeros_adicionales = data.get('pasajeros_adicionales', [])
        if not isinstance(pasajeros_adicionales, list):
            return jsonify({'error': 'pasajeros_adicionales debe ser una lista de IDs'}), 400
        try:
            pasajeros_adicionales = [int(uid) for uid in pasajeros_adicionales]
        except (TypeError, ValueError):
            return jsonify({'error': 'pasajeros_adicionales contiene IDs inválidos'}), 400

        estado_reserva = data.get('estado', 'confirmada')  # 'confirmada' o 'pendiente'

        # Lista de todos los usuario_ids a reservar (principal + adicionales)
        todos_usuarios = [usuario_principal_id] + pasajeros_adicionales

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        asientos_solicitados = len(todos_usuarios)
        usar_fallback_sql = False

        try:
            cursor.execute('CALL sp_reservations_descontar_asientos(%s, %s)', (vuelo_id, asientos_solicitados))
            descuento = cursor.fetchone() or {}
            _drain_call_results(cursor)
            if int(descuento.get('affected_rows') or 0) == 0:
                cursor.close()
                connection.close()
                return jsonify({'error': 'No hay asientos disponibles suficientes para esta reserva'}), 409
        except Error as exc:
            if _sp_missing(exc):
                usar_fallback_sql = True
            else:
                raise

        if usar_fallback_sql:
            cursor.execute(
                '''
                UPDATE vuelos
                SET asientos_disponibles = asientos_disponibles - %s
                WHERE vuelo_id = %s AND asientos_disponibles >= %s
                ''',
                (asientos_solicitados, vuelo_id, asientos_solicitados)
            )
            if cursor.rowcount == 0:
                cursor.close()
                connection.close()
                return jsonify({'error': 'No hay asientos disponibles suficientes para esta reserva'}), 409

        fecha_reserva = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        # Insertar una fila en usuario_reservas_vuelo por cada pasajero
        reserva_ids = []
        for usuario_id in todos_usuarios:
            if usar_fallback_sql:
                cursor.execute(
                    '''
                    INSERT INTO usuario_reservas_vuelo (usuario_id, vuelo_id, fecha_reserva, estado)
                    VALUES (%s, %s, %s, %s)
                    ''',
                    (usuario_id, vuelo_id, fecha_reserva, estado_reserva)
                )
                reserva_ids.append(cursor.lastrowid)
            else:
                cursor.execute(
                    'CALL sp_reservations_crear_reserva(%s, %s, %s, %s)',
                    (usuario_id, vuelo_id, fecha_reserva, estado_reserva)
                )
                reserva_row = cursor.fetchone() or {}
                _drain_call_results(cursor)
                reserva_ids.append(reserva_row.get('reserva_id'))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({
            'mensaje': f"Reservas creadas con estado '{estado_reserva}'",
            'reserva_ids': reserva_ids,
            'cantidad_pasajeros': len(todos_usuarios),
            'estado': estado_reserva,
        }), 201

    except Error as exc:
        if _sp_missing(exc):
            return jsonify({'error': 'Faltan stored procedures de reservas en la base de datos. Ejecuta server/sql/reservations_stored_procedures.sql'}), 500
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500


@reservations_bp.route('/mis-reservas/<int:usuario_id>', methods=['GET'])
def mis_reservas(usuario_id):
    """Obtiene todas las reservas de un usuario con detalles del vuelo"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)
        
        cursor.execute('CALL sp_reservations_mis_reservas(%s)', (usuario_id,))
        reservas = cursor.fetchall()
        _drain_call_results(cursor)

        # Puede haber filas duplicadas por reserva si existen múltiples pagos asociados.
        # Nos quedamos con la fila más reciente por reserva_id.
        reservas_unicas = {}
        for r in reservas:
            reserva_id = r.get('reserva_id')
            if reserva_id is None:
                continue

            existente = reservas_unicas.get(reserva_id)
            if not existente:
                reservas_unicas[reserva_id] = r
                continue

            fecha_nueva = r.get('pago_fecha') or r.get('fecha_reserva')
            fecha_existente = existente.get('pago_fecha') or existente.get('fecha_reserva')
            if fecha_nueva and (not fecha_existente or fecha_nueva >= fecha_existente):
                reservas_unicas[reserva_id] = r

        reservas = list(reservas_unicas.values())
        
        cursor.close()
        connection.close()
        
        # Convertir datetime a string para serialización JSON
        for r in reservas:
            for key in ('fecha_reserva', 'fecha_salida', 'fecha_llegada'):
                if r.get(key) is not None and hasattr(r[key], 'strftime'):
                    r[key] = r[key].strftime('%Y-%m-%d %H:%M:%S')
        
        return jsonify(reservas), 200
        
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500


@reservations_bp.route('/cancelar-reserva/<int:reserva_id>', methods=['DELETE'])
def cancelar_reserva(reserva_id):
    """Elimina una reserva y su pago asociado"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('CALL sp_reservations_obtener_reserva(%s)', (reserva_id,))
        reserva = cursor.fetchone()
        _drain_call_results(cursor)
        if not reserva:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Reserva no encontrada'}), 404

        vuelo_id = reserva.get('vuelo_id')
        usuario_id = reserva.get('usuario_id')

        cursor.execute('CALL sp_reservations_insert_cancelacion(%s, %s, %s)', (reserva_id, vuelo_id, usuario_id))
        _drain_call_results(cursor)
        
        # Primero eliminar el pago asociado (si existe)
        cursor.execute('CALL sp_reservations_delete_pago(%s)', (reserva_id,))
        _drain_call_results(cursor)
        
        # Luego eliminar la reserva
        cursor.execute('CALL sp_reservations_delete_reserva(%s)', (reserva_id,))
        delete_result = cursor.fetchone() or {}
        _drain_call_results(cursor)

        if int(delete_result.get('affected_rows') or 0) > 0:
            cursor.execute('CALL sp_reservations_sumar_asiento(%s)', (vuelo_id,))
            _drain_call_results(cursor)
        
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Reserva cancelada correctamente'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500
