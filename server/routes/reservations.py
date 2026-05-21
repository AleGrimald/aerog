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
    """Crea reserva para titular y vincula pasajeros secundarios."""
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

        pasajeros_secundarios = data.get('pasajeros_secundarios', [])
        if not isinstance(pasajeros_secundarios, list):
            return jsonify({'error': 'pasajeros_secundarios debe ser una lista'}), 400

        secundarios_normalizados = []
        solo_letras = set('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZáéíóúÁÉÍÓÚñÑüÜ ')
        for idx, pasajero in enumerate(pasajeros_secundarios):
            if not isinstance(pasajero, dict):
                return jsonify({'error': f'Pasajero secundario #{idx + 1} inválido'}), 400

            nombre = str(pasajero.get('nombre') or '').strip()
            apellido = str(pasajero.get('apellido') or '').strip()
            direccion = str(pasajero.get('direccion') or '').strip()
            telefono = str(pasajero.get('telefono') or '').strip()
            dni = str(pasajero.get('dni') or '').strip()
            email = str(pasajero.get('email') or '').strip()
            edad_raw = pasajero.get('edad')

            if len(nombre) < 2 or any(ch not in solo_letras for ch in nombre):
                return jsonify({'error': f'Nombre inválido en pasajero secundario #{idx + 1}'}), 400
            if len(apellido) < 2 or any(ch not in solo_letras for ch in apellido):
                return jsonify({'error': f'Apellido inválido en pasajero secundario #{idx + 1}'}), 400
            if len(direccion) < 5:
                return jsonify({'error': f'Dirección inválida en pasajero secundario #{idx + 1}'}), 400
            if not telefono.isdigit() or len(telefono) < 7 or len(telefono) > 15:
                return jsonify({'error': f'Teléfono inválido en pasajero secundario #{idx + 1}'}), 400
            if not dni.isdigit() or len(dni) < 7 or len(dni) > 10:
                return jsonify({'error': f'DNI inválido en pasajero secundario #{idx + 1}'}), 400
            if '@' not in email or '.' not in email:
                return jsonify({'error': f'Email inválido en pasajero secundario #{idx + 1}'}), 400
            try:
                edad = int(edad_raw)
            except (TypeError, ValueError):
                return jsonify({'error': f'Edad inválida en pasajero secundario #{idx + 1}'}), 400
            if edad < 0 or edad > 120:
                return jsonify({'error': f'Edad fuera de rango en pasajero secundario #{idx + 1}'}), 400

            secundarios_normalizados.append({
                'nombre': nombre,
                'apellido': apellido,
                'direccion': direccion,
                'telefono': telefono,
                'dni': dni,
                'edad': edad,
                'email': email,
            })

        estado_input = str(data.get('estado', 'pendiente')).strip().lower()
        if estado_input == 'pendiente':
            estado_reserva = 'pendiente'
        elif estado_input in ('pagada', 'confirmada'):
            # Internamente manejamos reservas pagadas como confirmadas.
            estado_reserva = 'confirmada'
        else:
            return jsonify({'error': "estado inválido. Usa 'pendiente' o 'pagada'"}), 400

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        asientos_solicitados = 1 + len(secundarios_normalizados)
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

        # Crear reserva del pasajero principal.
        if usar_fallback_sql:
            cursor.execute(
                '''
                INSERT INTO usuario_reservas_vuelo (usuario_id, vuelo_id, fecha_reserva, estado)
                VALUES (%s, %s, %s, %s)
                ''',
                (usuario_principal_id, vuelo_id, fecha_reserva, estado_reserva)
            )
            reserva_principal_id = cursor.lastrowid
        else:
            cursor.execute(
                'CALL sp_reservations_crear_reserva(%s, %s, %s, %s)',
                (usuario_principal_id, vuelo_id, fecha_reserva, estado_reserva)
            )
            reserva_row = cursor.fetchone() or {}
            _drain_call_results(cursor)
            reserva_principal_id = reserva_row.get('reserva_id')

        # Persistir pasajeros secundarios y vincularlos a la reserva principal.
        secundarios_ids = []
        for pasajero in secundarios_normalizados:
            if usar_fallback_sql:
                cursor.execute(
                    '''
                    INSERT INTO usuario_secundario (nombre, apellido, direccion, telefono, dni, edad, email)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    ''',
                    (
                        pasajero['nombre'], pasajero['apellido'], pasajero['direccion'], pasajero['telefono'],
                        pasajero['dni'], pasajero['edad'], pasajero['email']
                    )
                )
                usuario_secundario_id = cursor.lastrowid
                cursor.execute(
                    '''
                    INSERT INTO usuario_secundario_reserva_vuelo (reserva_id, usuario_secundario_id)
                    VALUES (%s, %s)
                    ''',
                    (reserva_principal_id, usuario_secundario_id)
                )
            else:
                cursor.execute(
                    'CALL sp_reservations_insert_usuario_secundario(%s, %s, %s, %s, %s, %s, %s)',
                    (
                        pasajero['nombre'], pasajero['apellido'], pasajero['direccion'], pasajero['telefono'],
                        pasajero['dni'], pasajero['edad'], pasajero['email']
                    )
                )
                secundario_row = cursor.fetchone() or {}
                _drain_call_results(cursor)
                usuario_secundario_id = secundario_row.get('usuario_secundario_id')

                cursor.execute(
                    'CALL sp_reservations_link_usuario_secundario_reserva(%s, %s)',
                    (reserva_principal_id, usuario_secundario_id)
                )
                _drain_call_results(cursor)

            secundarios_ids.append(usuario_secundario_id)

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({
            'mensaje': f"Reservas creadas con estado '{estado_reserva}'",
            'reserva_ids': [reserva_principal_id],
            'cantidad_pasajeros': asientos_solicitados,
            'usuarios_secundarios_ids': secundarios_ids,
            'estado': estado_reserva,
        }), 201

    except Error as exc:
        if _sp_missing(exc):
            return jsonify({'error': 'Faltan objetos de reservas en la base de datos. Ejecuta server/sql/secondary_passengers_schema.sql y server/sql/reservations_stored_procedures.sql'}), 500
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


@reservations_bp.route('/reserva-secundarios/<int:reserva_id>', methods=['GET'])
def reserva_secundarios(reserva_id):
    """Obtiene pasajeros secundarios vinculados a una reserva."""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        usar_fallback_sql = False
        try:
            cursor.execute('CALL sp_reservations_get_secundarios_by_reserva(%s)', (reserva_id,))
            secundarios = cursor.fetchall()
            _drain_call_results(cursor)
        except Error as exc:
            if _sp_missing(exc):
                usar_fallback_sql = True
            else:
                raise

        if usar_fallback_sql:
            cursor.execute(
                '''
                SELECT
                    us.usuario_secundario_id,
                    us.apellido,
                    us.nombre,
                    us.direccion,
                    us.telefono,
                    us.dni,
                    us.edad,
                    us.email
                FROM usuario_secundario_reserva_vuelo usrv
                JOIN usuario_secundario us
                  ON us.usuario_secundario_id = usrv.usuario_secundario_id
                WHERE usrv.reserva_id = %s
                ORDER BY us.apellido, us.nombre
                ''',
                (reserva_id,)
            )
            secundarios = cursor.fetchall()

        cursor.close()
        connection.close()
        return jsonify({'secundarios': secundarios}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
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

        cantidad_pasajeros = 1
        usar_fallback_count = False
        try:
            cursor.execute('CALL sp_reservations_count_secundarios(%s)', (reserva_id,))
            count_row = cursor.fetchone() or {}
            _drain_call_results(cursor)
            cantidad_pasajeros += int(count_row.get('cantidad_secundarios') or 0)
        except Error as exc:
            if _sp_missing(exc):
                usar_fallback_count = True
            else:
                raise

        if usar_fallback_count:
            cursor.execute(
                '''
                SELECT COUNT(*) AS cantidad_secundarios
                FROM usuario_secundario_reserva_vuelo
                WHERE reserva_id = %s
                ''',
                (reserva_id,)
            )
            count_row = cursor.fetchone() or {}
            cantidad_pasajeros += int(count_row.get('cantidad_secundarios') or 0)

        cursor.execute('CALL sp_reservations_insert_cancelacion(%s, %s, %s)', (reserva_id, vuelo_id, usuario_id))
        _drain_call_results(cursor)
        
        # Primero eliminar el pago asociado (si existe)
        cursor.execute('CALL sp_reservations_delete_pago(%s)', (reserva_id,))
        _drain_call_results(cursor)

        usar_fallback_cleanup = False
        try:
            cursor.execute('CALL sp_reservations_delete_secundarios_by_reserva(%s)', (reserva_id,))
            _drain_call_results(cursor)
        except Error as exc:
            if _sp_missing(exc):
                usar_fallback_cleanup = True
            else:
                raise

        if usar_fallback_cleanup:
            cursor.execute(
                'DELETE FROM usuario_secundario_reserva_vuelo WHERE reserva_id = %s',
                (reserva_id,)
            )
        
        # Luego eliminar la reserva
        cursor.execute('CALL sp_reservations_delete_reserva(%s)', (reserva_id,))
        delete_result = cursor.fetchone() or {}
        _drain_call_results(cursor)

        if int(delete_result.get('affected_rows') or 0) > 0:
            usar_fallback_sql = False
            try:
                cursor.execute('CALL sp_reservations_sumar_asientos(%s, %s)', (vuelo_id, cantidad_pasajeros))
                _drain_call_results(cursor)
            except Error as exc:
                if _sp_missing(exc):
                    usar_fallback_sql = True
                else:
                    raise

            if usar_fallback_sql:
                cursor.execute(
                    '''
                    UPDATE vuelos
                    SET asientos_disponibles = asientos_disponibles + %s
                    WHERE vuelo_id = %s
                    ''',
                    (cantidad_pasajeros, vuelo_id)
                )
        
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Reserva cancelada correctamente'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500
