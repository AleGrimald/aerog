"""Blueprint de autenticación y perfil de usuario"""
import time
from datetime import datetime
from flask import Blueprint, request, jsonify, redirect
from mysql.connector import Error
from itsdangerous import BadSignature, SignatureExpired

from .utils import (
    get_db_connection,
    hash_password,
    verify_password,
    _get_verification_serializer,
    send_verification_email,
    FRONTEND_BASE_URL,
    VERIFICATION_TOKEN_MAX_AGE,
)

auth_bp = Blueprint('auth', __name__)


def _registrar_log(usuario_id: int, resultado: str, razon_fallo: str = None,
                   ip: str = None, navegador: str = None, tiempo_ms: int = None) -> None:
    """Inserta un registro en historial_logs. Nunca lanza excepción para no romper el flujo."""
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            'INSERT INTO historial_logs '
            '(fk_usuario, resultado_login, razon_fallo, ip_origen_fallo, navegador_usuario, tiempo_respuesta_server) '
            'VALUES (%s, %s, %s, %s, %s, %s)',
            (usuario_id, resultado, razon_fallo, ip, navegador, tiempo_ms)
        )
        conn.commit()
        cur.close()
        conn.close()
    except Exception:
        pass  # Los logs nunca deben interrumpir el flujo principal


def _drain_call_results(cursor) -> None:
    """Consume todos los result sets pendientes tras un CALL para evitar 'Commands out of sync'."""
    try:
        while cursor.nextset():
            pass
    except Exception:
        pass


@auth_bp.route('/register', methods=['POST'])
def registrar_usuario():
    """Registra un nuevo usuario en la base de datos"""
    try:
        data = request.get_json() or {}
        
        # Validar campos requeridos
        campos_requeridos = ['nombre', 'apellido', 'email', 'telefono', 'direccion', 'dni', 'fecha_nacimiento', 'password']
        if not all(field in data for field in campos_requeridos):
            return jsonify({'error': 'Campos faltantes'}), 400

        dni = str(data.get('dni', '')).strip()
        if not dni.isdigit() or len(dni) < 7 or len(dni) > 9:
            return jsonify({'error': 'El DNI debe contener solo dígitos (7-9).'}), 400
        
        email_normalizado = str(data.get('email', '')).strip().lower()

        # Validar que el email no exista
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('CALL sp_auth_buscar_usuario_por_email(%s)', (email_normalizado,))
        usuario_existente = cursor.fetchone()
        _drain_call_results(cursor)
        if usuario_existente:
            cursor.close()
            connection.close()
            if int(usuario_existente.get('activo') or 0) == 0:
                return jsonify({'error': 'El email ya está registrado pero sin verificar. Revisa tu correo.'}), 409
            return jsonify({'error': 'El email ya está registrado'}), 409

        cursor.execute('SELECT usuario_id FROM Usuarios WHERE dni = %s LIMIT 1', (dni,))
        dni_existente = cursor.fetchone()
        if dni_existente:
            cursor.close()
            connection.close()
            return jsonify({'error': 'El DNI ya está registrado'}), 409
        
        # Hash de la contraseña
        contraseña_hash = hash_password(data['password'])
        
        # Insertar usuario
        fecha_nacimiento = data.get('fecha_nacimiento', None)
        fecha_registro = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        cursor.execute(
            'CALL sp_auth_registrar_usuario(%s, %s, %s, %s, %s, %s, %s, %s, %s)',
            (data['nombre'], data['apellido'], email_normalizado, contraseña_hash, data['telefono'], data['direccion'], dni, fecha_nacimiento, fecha_registro)
        )

        row_id = cursor.fetchone() or {}
        _drain_call_results(cursor)
        connection.commit()
        nuevo_usuario_id = row_id.get('usuario_id')

        token = _get_verification_serializer().dumps({'email': email_normalizado})
        email_enviado = send_verification_email(email_normalizado, data.get('nombre', ''), token)
        
        cursor.close()
        connection.close()
        
        return jsonify({
            'mensaje': 'Usuario registrado. Verifica tu email para activar la cuenta.' if email_enviado else 'Usuario registrado, pero no se pudo enviar el correo de verificación.',
            'usuario_id': nuevo_usuario_id,
            'email_verificacion_enviado': email_enviado,
        }), 201
        
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        import traceback; traceback.print_exc()
        return jsonify({'error': str(exc)}), 500


@auth_bp.route('/verificar-email', methods=['GET'])
def verificar_email():
    """Confirma email y activa al usuario (alta lógica)."""
    token = request.args.get('token', '').strip()
    status = 'error'

    if not token:
        return redirect(f'{FRONTEND_BASE_URL}/?email_verification=token_faltante')

    try:
        payload = _get_verification_serializer().loads(token, max_age=VERIFICATION_TOKEN_MAX_AGE)
        email = str(payload.get('email', '')).strip().lower()
        if not email:
            return redirect(f'{FRONTEND_BASE_URL}/?email_verification=token_invalido')

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('CALL sp_auth_buscar_usuario_por_email(%s)', (email,))
        usuario = cursor.fetchone()
        _drain_call_results(cursor)
        if not usuario:
            cursor.close()
            connection.close()
            return redirect(f'{FRONTEND_BASE_URL}/?email_verification=usuario_no_encontrado')

        if int(usuario.get('activo') or 0) == 1:
            cursor.close()
            connection.close()
            return redirect(f'{FRONTEND_BASE_URL}/?email_verification=ya_verificado')

        cursor.execute('CALL sp_auth_activar_usuario(%s)', (usuario['usuario_id'],))
        _drain_call_results(cursor)
        connection.commit()
        cursor.close()
        connection.close()
        status = 'ok'
    except SignatureExpired:
        status = 'token_expirado'
    except BadSignature:
        status = 'token_invalido'
    except Exception:
        status = 'error'

    return redirect(f'{FRONTEND_BASE_URL}/?email_verification={status}')


@auth_bp.route('/login', methods=['POST'])
def login():
    """Autentica un usuario"""
    inicio = time.time()

    # Datos del cliente para el log
    ip = request.headers.get('X-Forwarded-For', request.remote_addr or '').split(',')[0].strip()
    navegador = request.headers.get('User-Agent', '')[:255]

    try:
        data = request.get_json() or {}

        # Validar campos requeridos
        if 'email' not in data or 'password' not in data:
            return jsonify({'error': 'Email/usuario y contraseña requeridos'}), 400

        identificador = str(data.get('email', '')).strip()
        identificador_lower = identificador.lower()
        if not identificador:
            return jsonify({'error': 'Email/usuario requerido'}), 400

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)
        cursor.execute('CALL sp_login_usuario(%s)', (identificador_lower,))
        usuario = cursor.fetchone()
        _drain_call_results(cursor)
        cursor.close()
        connection.close()

        tiempo_ms = int((time.time() - inicio) * 1000)

        if not usuario:
            _registrar_log(0, 'FAILURE', 'Usuario no encontrado', ip, navegador, tiempo_ms)
            return jsonify({'error': 'Email o contraseña incorrectos'}), 401

        usuario_id = int(usuario.get('usuario_id') or 0)

        if int(usuario.get('activo') or 0) == 0:
            _registrar_log(usuario_id, 'FAILURE', 'Cuenta no verificada o desactivada', ip, navegador, tiempo_ms)
            return jsonify({'error': 'Debes verificar tu email para iniciar sesión o tu cuenta fue desactivada'}), 403

        if not verify_password(data['password'], usuario['contraseña_hash']):
            _registrar_log(usuario_id, 'FAILURE', 'Contraseña incorrecta', ip, navegador, tiempo_ms)
            return jsonify({'error': 'Email o contraseña incorrectos'}), 401

        # Login exitoso
        tiempo_ms = int((time.time() - inicio) * 1000)
        _registrar_log(usuario_id, 'SUCCESS', None, ip, navegador, tiempo_ms)

        # Eliminar el hash de la respuesta
        usuario.pop('contraseña_hash', None)

        # Determinar si es admin
        email_usuario = str(usuario.get('email') or '').strip().lower()
        usuario['es_admin'] = email_usuario == 'admin@gmail.com'

        return jsonify({
            'mensaje': 'Login exitoso',
            'usuario': usuario
        }), 200

    except Error as exc:
        tiempo_ms = int((time.time() - inicio) * 1000)
        _registrar_log(0, 'FAILURE', f'DB Error: {str(exc)[:200]}', ip, navegador, tiempo_ms)
        return jsonify({'error': str(exc)}), 500
    except Exception:
        tiempo_ms = int((time.time() - inicio) * 1000)
        _registrar_log(0, 'FAILURE', 'Error interno del servidor', ip, navegador, tiempo_ms)
        return jsonify({'error': 'Error en el servidor'}), 500


@auth_bp.route('/actualizar-perfil', methods=['PUT'])
def actualizar_perfil():
    """Actualiza los datos personales del usuario"""
    try:
        data = request.get_json()
        usuario_id = data.get('usuario_id')
        nombre = data.get('nombre')
        apellido = data.get('apellido')
        email = data.get('email')
        telefono = data.get('telefono')
        direccion = data.get('direccion')
        dni = str(data.get('dni') or '').strip()

        if not usuario_id:
            return jsonify({'error': 'ID de usuario no proporcionado'}), 400

        if not dni.isdigit() or len(dni) < 7 or len(dni) > 9:
            return jsonify({'error': 'El DNI debe contener solo dígitos (7-9).'}), 400

        connection = get_db_connection()
        cursor = connection.cursor()

        cursor.execute('SELECT usuario_id FROM Usuarios WHERE dni = %s AND usuario_id <> %s LIMIT 1', (dni, usuario_id))
        dni_existente = cursor.fetchone()
        if dni_existente:
            cursor.close()
            connection.close()
            return jsonify({'error': 'El DNI ya está en uso por otro usuario'}), 409
        
        cursor.execute(
            'CALL sp_auth_actualizar_perfil(%s, %s, %s, %s, %s, %s, %s)',
            (usuario_id, nombre, apellido, email, telefono, direccion, dni)
        )
        _drain_call_results(cursor)
        connection.commit()
        cursor.close()
        connection.close()
        
        return jsonify({'mensaje': 'Perfil actualizado correctamente'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500
