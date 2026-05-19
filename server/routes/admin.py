"""Blueprint de administración"""
from datetime import datetime
from flask import Blueprint, request, jsonify
from mysql.connector import Error

from .utils import (
    get_db_connection,
    hash_password,
)

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')


def _drain_call_results(cursor) -> None:
    """Consume result sets pendientes de CALL para evitar out of sync."""
    try:
        while cursor.nextset():
            pass
    except Exception:
        pass


@admin_bp.route('/aeropuertos', methods=['GET'])
def admin_aeropuertos():
    """Obtiene lista de aeropuertos"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute('CALL sp_admin_aeropuertos_listar()')
        rows = cursor.fetchall()
        _drain_call_results(cursor)
        cursor.close()
        connection.close()
        return jsonify({'aeropuertos': rows}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500


@admin_bp.route('/vuelos', methods=['GET'])
def admin_vuelos_listar():
    """Lista todos los vuelos"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.execute('CALL sp_admin_vuelos_listar()')
        rows = cursor.fetchall()
        _drain_call_results(cursor)

        for row in rows:
            if row.get('fecha_salida') is not None and hasattr(row['fecha_salida'], 'strftime'):
                row['fecha_salida'] = row['fecha_salida'].strftime('%Y-%m-%d %H:%M:%S')
            if row.get('fecha_llegada') is not None and hasattr(row['fecha_llegada'], 'strftime'):
                row['fecha_llegada'] = row['fecha_llegada'].strftime('%Y-%m-%d %H:%M:%S')

        cursor.close()
        connection.close()
        return jsonify({'vuelos': rows}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500


@admin_bp.route('/vuelos', methods=['POST'])
def admin_vuelos_crear():
    """Crea un nuevo vuelo"""
    try:
        data = request.get_json() or {}
        campos = ['codigo_vuelo', 'aeropuerto_origen', 'aeropuerto_destino', 'fecha_salida', 'fecha_llegada', 'capacidad_total', 'precio_base']
        faltantes = [c for c in campos if data.get(c) in (None, '')]
        if faltantes:
            return jsonify({'error': f'Campos faltantes: {", ".join(faltantes)}'}), 400

        codigo_vuelo = str(data.get('codigo_vuelo')).strip().upper()
        aeropuerto_origen = int(data.get('aeropuerto_origen'))
        aeropuerto_destino = int(data.get('aeropuerto_destino'))
        capacidad_total = int(data.get('capacidad_total'))
        precio_base = float(data.get('precio_base'))
        asientos_disponibles = data.get('asientos_disponibles')
        asientos_disponibles = int(asientos_disponibles) if asientos_disponibles not in (None, '') else capacidad_total
        fecha_salida = str(data.get('fecha_salida')).strip().replace('T', ' ')
        fecha_llegada = str(data.get('fecha_llegada')).strip().replace('T', ' ')

        if aeropuerto_origen == aeropuerto_destino:
            return jsonify({'error': 'Origen y destino no pueden ser iguales'}), 400
        if capacidad_total < 1:
            return jsonify({'error': 'La capacidad total debe ser mayor a 0'}), 400
        if asientos_disponibles < 0 or asientos_disponibles > capacidad_total:
            return jsonify({'error': 'Los asientos disponibles deben estar entre 0 y la capacidad total'}), 400
        if precio_base <= 0:
            return jsonify({'error': 'El precio base debe ser mayor a 0'}), 400

        try:
            dt_salida = datetime.strptime(fecha_salida, '%Y-%m-%d %H:%M:%S')
            dt_llegada = datetime.strptime(fecha_llegada, '%Y-%m-%d %H:%M:%S')
        except ValueError:
            return jsonify({'error': 'Formato de fechas inválido. Usa YYYY-MM-DD HH:MM:SS'}), 400

        if dt_llegada <= dt_salida:
            return jsonify({'error': 'La llegada debe ser posterior a la salida'}), 400

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute(
            'CALL sp_admin_vuelos_crear(%s, %s, %s, %s, %s, %s, %s, %s)',
            (
                codigo_vuelo,
                aeropuerto_origen,
                aeropuerto_destino,
                dt_salida.strftime('%Y-%m-%d %H:%M:%S'),
                dt_llegada.strftime('%Y-%m-%d %H:%M:%S'),
                capacidad_total,
                asientos_disponibles,
                precio_base,
            )
        )
        nuevo_id = (cursor.fetchone() or {}).get('vuelo_id')
        _drain_call_results(cursor)
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Vuelo creado', 'vuelo_id': nuevo_id}), 201
    except (TypeError, ValueError):
        return jsonify({'error': 'Datos numéricos inválidos en el formulario'}), 400
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500


@admin_bp.route('/vuelos/<int:vuelo_id>', methods=['PUT'])
def admin_vuelos_actualizar(vuelo_id):
    """Actualiza un vuelo existente"""
    try:
        data = request.get_json() or {}
        campos = ['codigo_vuelo', 'aeropuerto_origen', 'aeropuerto_destino', 'fecha_salida', 'fecha_llegada', 'capacidad_total', 'precio_base']
        faltantes = [c for c in campos if data.get(c) in (None, '')]
        if faltantes:
            return jsonify({'error': f'Campos faltantes: {", ".join(faltantes)}'}), 400

        codigo_vuelo = str(data.get('codigo_vuelo')).strip().upper()
        aeropuerto_origen = int(data.get('aeropuerto_origen'))
        aeropuerto_destino = int(data.get('aeropuerto_destino'))
        capacidad_total = int(data.get('capacidad_total'))
        precio_base = float(data.get('precio_base'))
        asientos_disponibles = data.get('asientos_disponibles')
        asientos_disponibles = int(asientos_disponibles) if asientos_disponibles not in (None, '') else capacidad_total
        fecha_salida = str(data.get('fecha_salida')).strip().replace('T', ' ')
        fecha_llegada = str(data.get('fecha_llegada')).strip().replace('T', ' ')

        if aeropuerto_origen == aeropuerto_destino:
            return jsonify({'error': 'Origen y destino no pueden ser iguales'}), 400
        if capacidad_total < 1:
            return jsonify({'error': 'La capacidad total debe ser mayor a 0'}), 400
        if asientos_disponibles < 0 or asientos_disponibles > capacidad_total:
            return jsonify({'error': 'Los asientos disponibles deben estar entre 0 y la capacidad total'}), 400
        if precio_base <= 0:
            return jsonify({'error': 'El precio base debe ser mayor a 0'}), 400

        try:
            dt_salida = datetime.strptime(fecha_salida, '%Y-%m-%d %H:%M:%S')
            dt_llegada = datetime.strptime(fecha_llegada, '%Y-%m-%d %H:%M:%S')
        except ValueError:
            return jsonify({'error': 'Formato de fechas inválido. Usa YYYY-MM-DD HH:MM:SS'}), 400

        if dt_llegada <= dt_salida:
            return jsonify({'error': 'La llegada debe ser posterior a la salida'}), 400

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute(
            'CALL sp_admin_vuelos_actualizar(%s, %s, %s, %s, %s, %s, %s, %s, %s)',
            (
                vuelo_id,
                codigo_vuelo,
                aeropuerto_origen,
                aeropuerto_destino,
                dt_salida.strftime('%Y-%m-%d %H:%M:%S'),
                dt_llegada.strftime('%Y-%m-%d %H:%M:%S'),
                capacidad_total,
                asientos_disponibles,
                precio_base,
            )
        )
        result = cursor.fetchone() or {}
        _drain_call_results(cursor)
        if int(result.get('affected_rows') or 0) == 0:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Vuelo no encontrado'}), 404

        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Vuelo actualizado'}), 200
    except (TypeError, ValueError):
        return jsonify({'error': 'Datos numéricos inválidos en el formulario'}), 400
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500


@admin_bp.route('/vuelos/<int:vuelo_id>', methods=['DELETE'])
def admin_vuelos_eliminar(vuelo_id):
    """Elimina un vuelo (solo sin reservas)"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('CALL sp_admin_vuelos_count_reservas(%s)', (vuelo_id,))
        reservas_count = (cursor.fetchone() or {}).get('total', 0)
        _drain_call_results(cursor)
        if reservas_count > 0:
            cursor.close()
            connection.close()
            return jsonify({'error': 'No se puede eliminar: el vuelo tiene reservas asociadas'}), 409

        cursor.execute('CALL sp_admin_vuelos_eliminar(%s)', (vuelo_id,))
        result = cursor.fetchone() or {}
        _drain_call_results(cursor)
        if int(result.get('affected_rows') or 0) == 0:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Vuelo no encontrado'}), 404

        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Vuelo eliminado'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500


@admin_bp.route('/usuarios', methods=['GET'])
def admin_usuarios_listar():
    """Lista todos los usuarios"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute('CALL sp_admin_usuarios_listar()')
        rows = cursor.fetchall()
        _drain_call_results(cursor)
        for row in rows:
            for key in ('fecha_nacimiento', 'fecha_registro'):
                if row.get(key) is not None and hasattr(row[key], 'strftime'):
                    row[key] = row[key].strftime('%Y-%m-%d %H:%M:%S')

        cursor.close()
        connection.close()
        return jsonify({'usuarios': rows}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500


@admin_bp.route('/usuarios', methods=['POST'])
def admin_usuarios_crear():
    """Crea un nuevo usuario (admin)"""
    try:
        data = request.get_json() or {}
        campos = ['nombre', 'apellido', 'email', 'telefono', 'direccion', 'fecha_nacimiento', 'password']
        faltantes = [c for c in campos if str(data.get(c, '')).strip() == '']
        if faltantes:
            return jsonify({'error': f'Campos faltantes: {", ".join(faltantes)}'}), 400

        nombre = str(data.get('nombre')).strip()
        apellido = str(data.get('apellido')).strip()
        email = str(data.get('email')).strip().lower()
        telefono = str(data.get('telefono')).strip()
        direccion = str(data.get('direccion')).strip()
        fecha_nacimiento = str(data.get('fecha_nacimiento')).strip()
        password = str(data.get('password')).strip()

        if len(password) < 6:
            return jsonify({'error': 'La contraseña debe tener al menos 6 caracteres'}), 400

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('CALL sp_admin_usuarios_buscar_por_email(%s)', (email,))
        email_exists = cursor.fetchone()
        _drain_call_results(cursor)
        if email_exists:
            cursor.close()
            connection.close()
            return jsonify({'error': 'El email ya está registrado'}), 409

        contraseña_hash = hash_password(password)
        fecha_registro = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        cursor.execute(
            'CALL sp_admin_usuarios_crear(%s, %s, %s, %s, %s, %s, %s, %s)',
            (nombre, apellido, email, contraseña_hash, telefono, direccion, fecha_nacimiento, fecha_registro)
        )
        nuevo_id = (cursor.fetchone() or {}).get('usuario_id')
        _drain_call_results(cursor)
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Usuario creado', 'usuario_id': nuevo_id}), 201
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500


@admin_bp.route('/usuarios/<int:usuario_id>', methods=['PUT'])
def admin_usuarios_actualizar(usuario_id):
    """Actualiza un usuario existente"""
    try:
        data = request.get_json() or {}
        campos = ['nombre', 'apellido', 'email', 'telefono', 'direccion', 'fecha_nacimiento']
        faltantes = [c for c in campos if str(data.get(c, '')).strip() == '']
        if faltantes:
            return jsonify({'error': f'Campos faltantes: {", ".join(faltantes)}'}), 400

        nombre = str(data.get('nombre')).strip()
        apellido = str(data.get('apellido')).strip()
        email = str(data.get('email')).strip().lower()
        telefono = str(data.get('telefono')).strip()
        direccion = str(data.get('direccion')).strip()
        fecha_nacimiento = str(data.get('fecha_nacimiento')).strip()
        password = str(data.get('password') or '').strip()

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('CALL sp_admin_usuarios_buscar_por_id(%s)', (usuario_id,))
        usuario_row = cursor.fetchone()
        _drain_call_results(cursor)
        if not usuario_row:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Usuario no encontrado'}), 404

        cursor.execute('CALL sp_admin_usuarios_email_duplicado(%s, %s)', (email, usuario_id))
        email_duplicado = cursor.fetchone()
        _drain_call_results(cursor)
        if email_duplicado:
            cursor.close()
            connection.close()
            return jsonify({'error': 'El email ya está en uso por otro usuario'}), 409

        if password:
            if len(password) < 6:
                cursor.close()
                connection.close()
                return jsonify({'error': 'La contraseña debe tener al menos 6 caracteres'}), 400
            contraseña_hash = hash_password(password)
            cursor.execute(
                'CALL sp_admin_usuarios_actualizar_con_password(%s, %s, %s, %s, %s, %s, %s, %s)',
                (usuario_id, nombre, apellido, email, telefono, direccion, fecha_nacimiento, contraseña_hash)
            )
            _drain_call_results(cursor)
        else:
            cursor.execute(
                'CALL sp_admin_usuarios_actualizar_sin_password(%s, %s, %s, %s, %s, %s, %s)',
                (usuario_id, nombre, apellido, email, telefono, direccion, fecha_nacimiento)
            )
            _drain_call_results(cursor)

        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Usuario actualizado'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500


@admin_bp.route('/usuarios/<int:usuario_id>', methods=['DELETE'])
def admin_usuarios_eliminar(usuario_id):
    """Desactiva un usuario (soft delete)"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('CALL sp_admin_usuarios_obtener_estado(%s)', (usuario_id,))
        usuario = cursor.fetchone()
        _drain_call_results(cursor)
        if not usuario:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Usuario no encontrado'}), 404

        if int(usuario.get('activo') or 0) == 0:
            cursor.close()
            connection.close()
            return jsonify({'mensaje': 'Usuario ya estaba desactivado'}), 200

        cursor.execute('CALL sp_admin_usuarios_desactivar(%s)', (usuario_id,))
        _drain_call_results(cursor)
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Usuario desactivado (eliminación lógica)'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500


@admin_bp.route('/reservas', methods=['GET'])
def admin_reservas_listar():
    """Lista todas las reservas"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute('CALL sp_admin_reservas_listar()')
        rows = cursor.fetchall()
        _drain_call_results(cursor)
        for row in rows:
            if row.get('fecha_reserva') is not None and hasattr(row['fecha_reserva'], 'strftime'):
                row['fecha_reserva'] = row['fecha_reserva'].strftime('%Y-%m-%d %H:%M:%S')

        cursor.close()
        connection.close()
        return jsonify({'reservas': rows}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500


@admin_bp.route('/estadisticas', methods=['GET'])
def admin_estadisticas():
    """Obtiene estadísticas generales"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.execute('CALL sp_admin_estadisticas_recaudacion()')
        recaudacion_rows = cursor.fetchall()
        _drain_call_results(cursor)
        recaudacion_rows.reverse()

        cursor.execute('CALL sp_admin_estadisticas_total_reservas()')
        reservados = cursor.fetchone().get('total', 0)
        _drain_call_results(cursor)

        cursor.execute('CALL sp_admin_estadisticas_total_cancelaciones()')
        cancelados = cursor.fetchone().get('total', 0)
        _drain_call_results(cursor)

        cursor.execute('CALL sp_admin_estadisticas_destinos_top()')
        destinos_rows = cursor.fetchall()
        _drain_call_results(cursor)

        cursor.close()
        connection.close()

        return jsonify({
            'recaudacion_mensual': recaudacion_rows,
            'vuelos_reservados': reservados,
            'vuelos_cancelados': cancelados,
            'destinos_mas_pedidos': destinos_rows,
        }), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500
