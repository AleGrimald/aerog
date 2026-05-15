from datetime import datetime, timedelta
import os
import bcrypt
import json
from urllib import request as urlrequest
from urllib.error import URLError, HTTPError

from dotenv import load_dotenv
import mysql.connector
from flask import Flask, jsonify, request
from flask_cors import CORS
from mysql.connector import Error

# Importar función de MercadoPago
from mercadopago_utils import crear_preferencia_pago_qr


load_dotenv()

# Detectar entorno
ENV = os.environ.get('ENV', 'development').lower()

if ENV == 'development':
    MY_SQL_HOST = os.environ.get('MYSQL_ADDON_HOST', 'blm5x9oepuyj2mg73vdk-mysql.services.clever-cloud.com')
    MY_SQL_USER = os.environ.get('MYSQL_ADDON_USER', 'urmow4dfpnsddjqz')
    MY_SQL_PASS = os.environ.get('MYSQL_ADDON_PASSWORD', '5xet9ohmSY9r4KYf5HYR')
    MY_SQL_PORT = int(os.environ.get('MYSQL_ADDON_PORT', 3306))
    MY_SQL_DB = os.environ.get('MYSQL_ADDON_DB', 'blm5x9oepuyj2mg73vdk')
else:
    MY_SQL_HOST = os.environ.get('MY_SQL_HOST', 'localhost')
    MY_SQL_USER = os.environ.get('MY_SQL_USER', 'root')
    MY_SQL_PASS = os.environ.get('MY_SQL_PASS', '78531015aA@')
    MY_SQL_PORT = int(os.environ.get('MY_SQL_PORT', 3306))
    MY_SQL_DB = os.environ.get('MY_SQL_DB', 'pasajes')

PORT = int(os.environ.get('PORT', 5000))

app = Flask(__name__)
CORS(app, resources={
    r"/*": {
        "origins": [
            "http://localhost:3000",
            "http://127.0.0.1:3000",
            "http://192.168.40.226:3000",
            "https://aerog-cliente.vercel.app",
            "https://aerog.vercel.app",
        ],
        "methods": ["GET", "POST", "OPTIONS", "DELETE", "PUT"],
        "allow_headers": ["Content-Type"],
    }
})

def hash_password(password):
    """Genera un hash bcrypt para la contraseña"""
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode(), hashed.encode())

def get_db_connection():
    return mysql.connector.connect(
        host=MY_SQL_HOST,
        user=MY_SQL_USER,
        password=MY_SQL_PASS,
        port=MY_SQL_PORT,
        database=MY_SQL_DB,
    )

def ensure_tarjetas_table(cursor):
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS tarjetas_usuario (
            tarjeta_id INT AUTO_INCREMENT PRIMARY KEY,
            usuario_id INT NOT NULL,
            numero VARCHAR(16) NOT NULL,
            titular VARCHAR(100) NOT NULL,
            vencimiento VARCHAR(5) NOT NULL,
            cvv VARCHAR(4) NOT NULL,
            tipo_tarjeta NVARCHAR(20) NULL,
            fabricante NVARCHAR(30) NULL,
            entidad_bancaria NVARCHAR(100) NULL,
            fecha_agregada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE
        )
    ''')

def ensure_tarjetas_columns(cursor):
    """Asegura columnas de metadatos BIN/IIN en tarjetas_usuario."""
    cursor.execute(
        '''
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = %s AND TABLE_NAME = 'tarjetas_usuario'
        ''',
        (MY_SQL_DB,)
    )
    columnas = set()
    for row in cursor.fetchall():
        if isinstance(row, dict):
            columnas.add(row.get('COLUMN_NAME'))
        else:
            columnas.add(row[0])

    if 'tipo_tarjeta' not in columnas:
        cursor.execute('ALTER TABLE tarjetas_usuario ADD COLUMN tipo_tarjeta NVARCHAR(20) NULL')
    if 'fabricante' not in columnas:
        cursor.execute('ALTER TABLE tarjetas_usuario ADD COLUMN fabricante NVARCHAR(30) NULL')
    if 'entidad_bancaria' not in columnas:
        cursor.execute('ALTER TABLE tarjetas_usuario ADD COLUMN entidad_bancaria NVARCHAR(100) NULL')

def detectar_fabricante_por_iin(numero: str) -> str:
    if not numero:
        return 'No identificado'
    if numero.startswith('4'):
        return 'Visa'
    dos = int(numero[:2]) if len(numero) >= 2 and numero[:2].isdigit() else -1
    cuatro = int(numero[:4]) if len(numero) >= 4 and numero[:4].isdigit() else -1
    if 51 <= dos <= 55 or 2221 <= cuatro <= 2720:
        return 'Mastercard'
    if numero.startswith('34') or numero.startswith('37'):
        return 'American Express'
    return 'No identificado'

def detectar_entidad_local(bin6: str) -> str:
    """Fallback local basado en BINs frecuentes de AR."""
    if not bin6:
        return 'No identificado'

    prefijos_3 = {
        '450': 'Banco Santander',
        '451': 'BBVA Frances',
        '454': 'Banco Macro',
        '589': 'Naranja X',
        '540': 'Banco Galicia',
        '528': 'Banco Nacion',
        '522': 'Banco Provincia',
    }
    prefijos_4 = {
        '4509': 'Naranja X',
        '4557': 'Banco Macro',
        '4507': 'Banco Santander',
    }

    if bin6[:4] in prefijos_4:
        return prefijos_4[bin6[:4]]
    if bin6[:3] in prefijos_3:
        return prefijos_3[bin6[:3]]
    return 'No identificado'

def detectar_metadata_tarjeta(numero: str) -> dict:
    """Detecta tipo/fabricante/entidad con BIN/IIN (API externa + fallback local)."""
    numero_limpio = ''.join(ch for ch in str(numero) if ch.isdigit())
    bin6 = numero_limpio[:6]

    fabricante = detectar_fabricante_por_iin(numero_limpio)
    tipo_tarjeta = 'No identificado'
    entidad_bancaria = detectar_entidad_local(bin6)

    if len(bin6) == 6:
        try:
            req = urlrequest.Request(
                f'https://lookup.binlist.net/{bin6}',
                headers={'Accept-Version': '3'}
            )
            with urlrequest.urlopen(req, timeout=2.5) as resp:
                data = json.loads(resp.read().decode('utf-8'))
                scheme = (data.get('scheme') or '').strip()
                tipo = (data.get('type') or '').strip()
                bank_name = ((data.get('bank') or {}).get('name') or '').strip()

                if scheme:
                    fabricante = scheme.title()
                if tipo == 'debit':
                    tipo_tarjeta = 'Debito'
                elif tipo == 'credit':
                    tipo_tarjeta = 'Credito'
                if bank_name:
                    entidad_bancaria = bank_name
        except (URLError, HTTPError, TimeoutError, ValueError, json.JSONDecodeError):
            pass

    if tipo_tarjeta == 'No identificado':
        tipo_tarjeta = 'Debito' if numero_limpio.startswith('4') and bin6.startswith(('4023', '4098')) else 'Credito'

    if fabricante == 'Amex':
        fabricante = 'American Express'

    return {
        'tipo_tarjeta': tipo_tarjeta,
        'fabricante': fabricante,
        'entidad_bancaria': entidad_bancaria,
    }

def ensure_pagos_columns(cursor):
    """Asegura columnas necesarias para detalle de pago en la tabla pagos."""
    cursor.execute(
        '''
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = %s AND TABLE_NAME = 'pagos'
        ''',
        (MY_SQL_DB,)
    )
    columnas = {row[0] for row in cursor.fetchall()}

    if 'tarjeta_id' not in columnas:
        cursor.execute('ALTER TABLE pagos ADD COLUMN tarjeta_id INT NULL')
    if 'cantidad_cuotas' not in columnas:
        cursor.execute('ALTER TABLE pagos ADD COLUMN cantidad_cuotas INT NOT NULL DEFAULT 1')

def ensure_vuelos_asientos_column(cursor):
    """Asegura la columna asientos_disponibles en vuelos."""
    cursor.execute(
        '''
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = %s AND TABLE_NAME = 'vuelos'
        ''',
        (MY_SQL_DB,)
    )
    columnas = {row[0] for row in cursor.fetchall()}

    if 'asientos_disponibles' not in columnas:
        cursor.execute(
            '''
            ALTER TABLE vuelos
            ADD COLUMN asientos_disponibles INT NOT NULL DEFAULT 0
            '''
        )
        cursor.execute(
            '''
            UPDATE vuelos
            SET asientos_disponibles = capacidad_total
            WHERE asientos_disponibles = 0
            '''
        )

def ensure_cancelaciones_table(cursor):
    """Asegura tabla para auditar cancelaciones de reservas."""
    cursor.execute(
        '''
        CREATE TABLE IF NOT EXISTS cancelaciones_reservas (
            cancelacion_id INT AUTO_INCREMENT PRIMARY KEY,
            reserva_id INT NOT NULL,
            vuelo_id INT NOT NULL,
            usuario_id INT NOT NULL,
            fecha_cancelacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        '''
    )

@app.route('/', methods=['GET'])
def index():
    return jsonify({'message': 'Servidor activo. Usa /usuario para consultar datos.'})

@app.route('/mercadopago/qr', methods=['POST'])
def mercadopago_qr():
    """Crea una preferencia de pago QR en MercadoPago y retorna la URL del QR"""
    try:
        data = request.get_json()
        monto = data.get('monto')
        descripcion = data.get('descripcion', 'Reserva de vuelo')
        reserva_id = data.get('reserva_id')
        usuario_email = data.get('usuario_email')
        if not monto or not reserva_id or not usuario_email:
            return jsonify({'error': 'Faltan datos para crear el QR'}), 400
        url_qr = crear_preferencia_pago_qr(monto, descripcion, reserva_id, usuario_email)
        return jsonify({'qr_url': url_qr}), 200
    except Exception as exc:
        return jsonify({'error': str(exc)}), 500

@app.route('/usuario', methods=['GET'])
def obtener_usuario():
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)
        cursor.execute('SELECT * FROM Usuarios')
        usuarios = cursor.fetchall()
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection is not None and connection.is_connected():
            connection.close()

    return jsonify(usuarios)

@app.route('/airport-suggestions', methods=['GET'])
def airport_suggestions():
    query = request.args.get('q', '').strip()
    if not query or len(query) < 2:
        return jsonify([])

    sql = '''
        SELECT aeropuerto_id, nombre, ciudad, provincia, codigo_IATA
        FROM aeropuertos
        WHERE nombre LIKE %s OR ciudad LIKE %s OR provincia LIKE %s OR codigo_IATA LIKE %s
        LIMIT 10
    '''
    value = f"%{query}%"

    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute(sql, (value, value, value, value))
        suggestions = cursor.fetchall()
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection is not None and connection.is_connected():
            connection.close()

    normalized = []
    for row in suggestions:
        aeropuerto_id = row.get('aeropuerto_id')
        nombre = row.get('nombre') or ''
        ciudad = row.get('ciudad') or ''
        provincia = row.get('provincia') or ''
        codigo = row.get('codigo_IATA') or ''
        label = nombre
        if ciudad:
            label = f"{ciudad} - {label}"
        if codigo:
            label += f" ({codigo})"
        if provincia:
            label += f", {provincia}"
        normalized.append({
            'id': aeropuerto_id,
            'label': label,
            'nombre': nombre,
            'ciudad': ciudad,
            'provincia': provincia,
            'codigo_IATA': codigo,
        })

    return jsonify(normalized)

@app.route('/buscar-vuelos', methods=['POST'])
def buscar_vuelos():
    try:
        data = request.get_json() or {}
        origen_id = data.get('origenId')
        destino_id = data.get('destinoId')
        trip_type = (data.get('tripType') or 'one-way').strip()
        fecha_salida = (data.get('fechaSalida') or '').strip()
        fecha_regreso = (data.get('fechaRegreso') or '').strip()
        pasajeros = data.get('pasajeros', 1)

        if origen_id is None or destino_id is None or not fecha_salida or not fecha_regreso:
            return jsonify({'error': 'Origen, destino y rango de fechas son requeridos'}), 400

        try:
            origen_id = int(origen_id)
            destino_id = int(destino_id)
            pasajeros = int(pasajeros)
        except (TypeError, ValueError):
            return jsonify({'error': 'Origen, destino y pasajeros deben ser numéricos'}), 400

        if pasajeros < 1 or pasajeros > 10:
            return jsonify({'error': 'La cantidad de pasajeros debe estar entre 1 y 10'}), 400

        print('BUSCAR VUELOS payload:', data)

        try:
            selected_salida = datetime.strptime(fecha_salida, '%Y-%m-%d').date()
        except ValueError:
            return jsonify({'error': 'Fecha de salida inválida'}), 400

        if trip_type == 'round-trip':
            try:
                selected_regreso = datetime.strptime(fecha_regreso, '%Y-%m-%d').date()
            except ValueError:
                return jsonify({'error': 'Fecha de regreso inválida'}), 400

            if selected_regreso < selected_salida:
                return jsonify({'error': 'La fecha de regreso debe ser mayor o igual a la fecha de salida'}), 400
        else:
            selected_regreso = selected_salida

        today = datetime.now().date()
        if selected_salida < today:
            return jsonify({'error': 'La fecha de salida debe ser hoy o posterior'}), 400

        if trip_type == 'one-way':
            start_date = selected_salida - timedelta(days=5)
            end_date = selected_salida + timedelta(days=5)
            if start_date < today:
                start_date = today
        else:
            start_date = selected_salida
            end_date = selected_regreso

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            schema_cursor = connection.cursor()
            ensure_vuelos_asientos_column(schema_cursor)
            schema_cursor.close()

            sql_search = '''
                SELECT v.vuelo_id, v.codigo_vuelo, a_origen.nombre AS origen_nombre, a_destino.nombre AS destino_nombre,
                                             v.fecha_salida, v.fecha_llegada, v.capacidad_total, v.asientos_disponibles, v.precio_base
                FROM vuelos v
                JOIN aeropuertos a_origen ON v.aeropuerto_origen = a_origen.aeropuerto_id
                JOIN aeropuertos a_destino ON v.aeropuerto_destino = a_destino.aeropuerto_id
                WHERE DATE(v.fecha_salida) >= %s
                  AND DATE(v.fecha_llegada) <= %s
                  AND v.aeropuerto_origen = %s
                  AND v.aeropuerto_destino = %s
                                    AND v.asientos_disponibles >= %s
                ORDER BY v.fecha_salida
            '''
            params_search = (str(start_date), str(end_date), origen_id, destino_id, pasajeros)
            
            cursor.execute(sql_search, params_search)
            results = cursor.fetchall()
            
            print('SQL SEARCH:', sql_search)
            print('PARAMS SEARCH:', params_search)
            print(f'RESULTADOS BRUTOS: {len(results)} registros')
            for idx, vuelo in enumerate(results):
                print(f'  [{idx}] {vuelo.get("codigo_vuelo")} - Salida: {vuelo.get("fecha_salida")} - Llegada: {vuelo.get("fecha_llegada")}')
            
            # Formatear fechas a strings legibles para el frontend
            for vuelo in results:
                if vuelo.get('fecha_salida'):
                    vuelo['fecha_salida'] = vuelo['fecha_salida'].strftime('%Y-%m-%d %H:%M:%S')
                if vuelo.get('fecha_llegada'):
                    vuelo['fecha_llegada'] = vuelo['fecha_llegada'].strftime('%Y-%m-%d %H:%M:%S')
        finally:
            if cursor is not None:
                cursor.close()
            if connection is not None and connection.is_connected():
                connection.close()

        return jsonify({'results': results})

    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/register', methods=['POST'])
def registrar_usuario():
    """Registra un nuevo usuario en la base de datos"""
    try:
        data = request.get_json()
        
        # Validar campos requeridos
        campos_requeridos = ['nombre', 'apellido', 'email', 'telefono', 'direccion', 'fecha_nacimiento', 'password']
        if not all(field in data for field in campos_requeridos):
            return jsonify({'error': 'Campos faltantes'}), 400
        
        # Validar que el email no exista
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)
        cursor.execute('SELECT usuario_id FROM Usuarios WHERE email = %s', (data['email'],))
        if cursor.fetchone():
            cursor.close()
            connection.close()
            return jsonify({'error': 'El email ya está registrado'}), 400
        
        # Hash de la contraseña
        contraseña_hash = hash_password(data['password'])
        
        # Insertar usuario
        fecha_nacimiento = data.get('fecha_nacimiento', None)
        fecha_registro = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        cursor.execute('''
            INSERT INTO Usuarios (nombre, apellido, email, contraseña_hash, telefono, direccion, fecha_nacimiento, fecha_registro)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ''', (data['nombre'], data['apellido'], data['email'], contraseña_hash, data['telefono'], data['direccion'], fecha_nacimiento, fecha_registro))
        
        connection.commit()
        nuevo_usuario_id = cursor.lastrowid
        
        cursor.close()
        connection.close()
        
        return jsonify({
            'mensaje': 'Usuario registrado exitosamente',
            'usuario_id': nuevo_usuario_id
        }), 201
        
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/login', methods=['POST'])
def login():
    """Autentica un usuario"""
    try:
        data = request.get_json()
        
        # Validar campos requeridos
        if 'email' not in data or 'password' not in data:
            return jsonify({'error': 'Email/usuario y contraseña requeridos'}), 400

        identificador = str(data.get('email', '')).strip()
        if not identificador:
            return jsonify({'error': 'Email/usuario requerido'}), 400
        
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)
        cursor.execute(
            '''
            SELECT usuario_id, nombre, apellido, email, telefono, direccion, fecha_nacimiento, fecha_registro, contraseña_hash
            FROM Usuarios
            WHERE email = %s OR LOWER(nombre) = %s
            LIMIT 1
            ''',
            (identificador, identificador.lower())
        )
        usuario = cursor.fetchone()
        
        if not usuario or not verify_password(data['password'], usuario['contraseña_hash']):
            cursor.close()
            connection.close()
            return jsonify({'error': 'Email o contraseña incorrectos'}), 401
        
        # Eliminar el hash de la respuesta
        usuario.pop('contraseña_hash', None)
        usuario['es_admin'] = (
            str(usuario.get('email') or '').strip().lower() == 'admin@gmail.com'
            or identificador.lower() == 'admin@gmail.com'
        )
        cursor.close()
        connection.close()
        
        if not usuario:
            return jsonify({'error': 'Email o contraseña incorrectos'}), 401
        
        return jsonify({
            'mensaje': 'Login exitoso',
            'usuario': usuario
        }), 200
        
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/confirmar-reserva', methods=['POST'])
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
        cursor = connection.cursor()

        schema_cursor = connection.cursor()
        ensure_vuelos_asientos_column(schema_cursor)
        schema_cursor.close()

        asientos_solicitados = len(todos_usuarios)
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
            cursor.execute('''
                INSERT INTO usuario_reservas_vuelo (usuario_id, vuelo_id, fecha_reserva, estado)
                VALUES (%s, %s, %s, %s)
            ''', (usuario_id, vuelo_id, fecha_reserva, estado_reserva))
            reserva_ids.append(cursor.lastrowid)

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
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/mis-reservas/<int:usuario_id>', methods=['GET'])
def mis_reservas(usuario_id):
    """Obtiene todas las reservas de un usuario con detalles del vuelo"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)
        schema_cursor = connection.cursor()
        ensure_pagos_columns(schema_cursor)
        schema_cursor.close()
        
        # Consulta que trae reservas con datos del vuelo y pago (si existe)
        query = '''
            SELECT 
                urv.reserva_id,
                urv.usuario_id,
                urv.vuelo_id,
                urv.fecha_reserva,
                urv.estado,
                vd.codigo_vuelo,
                vd.fecha_salida,
                vd.fecha_llegada,
                vd.precio_base,
                ao.nombre as origen_nombre,
                ao.provincia as provincia_origen,
                ad.nombre as destino_nombre,
                ad.provincia as provincia_destino,
                u.nombre,
                u.apellido,
                u.email,
                p.monto as pago_monto,
                p.fecha_pago as pago_fecha,
                p.metodo_pago as pago_metodo,
                p.estado_pago as pago_estado,
                p.interes_aplicado as pago_interes,
                p.cantidad_cuotas as pago_cuotas,
                RIGHT(tu.numero, 4) as pago_tarjeta_ultimos4
            FROM usuario_reservas_vuelo urv
            JOIN vuelos vd ON urv.vuelo_id = vd.vuelo_id
            JOIN aeropuertos ao ON vd.aeropuerto_origen = ao.aeropuerto_id
            JOIN aeropuertos ad ON vd.aeropuerto_destino = ad.aeropuerto_id
            JOIN Usuarios u ON urv.usuario_id = u.usuario_id
            LEFT JOIN pagos p ON urv.reserva_id = p.reserva_id
            LEFT JOIN tarjetas_usuario tu ON p.tarjeta_id = tu.tarjeta_id
            WHERE urv.usuario_id = %s
            ORDER BY urv.fecha_reserva DESC
        '''
        cursor.execute(query, (usuario_id,))
        reservas = cursor.fetchall()
        
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

@app.route('/cancelar-reserva/<int:reserva_id>', methods=['DELETE'])
def cancelar_reserva(reserva_id):
    """Elimina una reserva y su pago asociado"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        schema_cursor = connection.cursor()
        ensure_vuelos_asientos_column(schema_cursor)
        ensure_cancelaciones_table(schema_cursor)
        schema_cursor.close()

        cursor.execute('SELECT vuelo_id, usuario_id FROM usuario_reservas_vuelo WHERE reserva_id = %s', (reserva_id,))
        reserva = cursor.fetchone()
        if not reserva:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Reserva no encontrada'}), 404

        vuelo_id = reserva[0]
        usuario_id = reserva[1]

        cursor.execute(
            '''
            INSERT INTO cancelaciones_reservas (reserva_id, vuelo_id, usuario_id)
            VALUES (%s, %s, %s)
            ''',
            (reserva_id, vuelo_id, usuario_id)
        )
        
        # Primero eliminar el pago asociado (si existe)
        cursor.execute('DELETE FROM pagos WHERE reserva_id = %s', (reserva_id,))
        
        # Luego eliminar la reserva
        cursor.execute('DELETE FROM usuario_reservas_vuelo WHERE reserva_id = %s', (reserva_id,))

        if cursor.rowcount > 0:
            cursor.execute(
                '''
                UPDATE vuelos
                SET asientos_disponibles = asientos_disponibles + 1
                WHERE vuelo_id = %s
                ''',
                (vuelo_id,)
            )
        
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Reserva cancelada correctamente'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/actualizar-perfil', methods=['PUT'])
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

        if not usuario_id:
            return jsonify({'error': 'ID de usuario no proporcionado'}), 400

        connection = get_db_connection()
        cursor = connection.cursor()
        
        cursor.execute('''
            UPDATE Usuarios 
            SET nombre = %s, apellido = %s, email = %s, telefono = %s, direccion = %s
            WHERE usuario_id = %s
        ''', (nombre, apellido, email, telefono, direccion, usuario_id))
        
        connection.commit()
        cursor.close()
        connection.close()
        
        return jsonify({'mensaje': 'Perfil actualizado correctamente'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/agregar-tarjeta', methods=['POST'])
def agregar_tarjeta():
    """Guarda una tarjeta de crédito/débito para el usuario"""
    try:
        data = request.get_json()
        usuario_id = data.get('usuario_id')
        numero = data.get('numero')
        titular = data.get('titular')
        vencimiento = data.get('vencimiento')
        cvv = data.get('cvv')

        if not usuario_id or not numero or not titular or not vencimiento or not cvv:
            return jsonify({'error': 'Todos los campos de la tarjeta son requeridos'}), 400

        numero_limpio = ''.join(ch for ch in str(numero) if ch.isdigit())
        if len(numero_limpio) < 13 or len(numero_limpio) > 19:
            return jsonify({'error': 'Número de tarjeta inválido'}), 400

        metadata = detectar_metadata_tarjeta(numero_limpio)

        connection = get_db_connection()
        cursor = connection.cursor()
        ensure_tarjetas_table(cursor)
        ensure_tarjetas_columns(cursor)
        
        cursor.execute('''
            INSERT INTO tarjetas_usuario (usuario_id, numero, titular, vencimiento, cvv, tipo_tarjeta, fabricante, entidad_bancaria)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ''', (usuario_id, numero_limpio, titular, vencimiento, cvv, metadata['tipo_tarjeta'], metadata['fabricante'], metadata['entidad_bancaria']))
        tarjeta_id = cursor.lastrowid

        numero_str = str(numero_limpio)
        ultimos4 = numero_str[-4:] if len(numero_str) >= 4 else numero_str
        marca = metadata['fabricante']
        
        connection.commit()
        cursor.close()
        connection.close()
        
        return jsonify({
            'mensaje': 'Tarjeta guardada correctamente',
            'tarjeta': {
                'tarjeta_id': tarjeta_id,
                'titular': titular,
                'ultimos4': ultimos4,
                'marca': marca,
                'tipo_tarjeta': metadata['tipo_tarjeta'],
                'fabricante': metadata['fabricante'],
                'entidad_bancaria': metadata['entidad_bancaria'],
            }
        }), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/tarjeta-usuario/<int:usuario_id>', methods=['GET'])
def obtener_tarjeta_usuario(usuario_id):
    """Obtiene todas las tarjetas guardadas de un usuario"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        ensure_tarjetas_table(cursor)
        ensure_tarjetas_columns(cursor)

        cursor.execute('''
            SELECT tarjeta_id, titular, numero, tipo_tarjeta, fabricante, entidad_bancaria
            FROM tarjetas_usuario
            WHERE usuario_id = %s
            ORDER BY fecha_agregada DESC, tarjeta_id DESC
        ''', (usuario_id,))
        tarjetas = cursor.fetchall()

        cursor.close()
        connection.close()

        tarjetas_resumen = []
        for tarjeta in tarjetas:
            numero = str(tarjeta.get('numero') or '')
            ultimos4 = numero[-4:] if len(numero) >= 4 else numero
            metadata = detectar_metadata_tarjeta(numero)
            fabricante = tarjeta.get('fabricante') or metadata['fabricante']
            tipo_tarjeta = tarjeta.get('tipo_tarjeta') or metadata['tipo_tarjeta']
            entidad_bancaria = tarjeta.get('entidad_bancaria') or metadata['entidad_bancaria']

            tarjetas_resumen.append({
                'tarjeta_id': tarjeta['tarjeta_id'],
                'titular': tarjeta.get('titular') or 'Titular',
                'ultimos4': ultimos4,
                'marca': fabricante,
                'tipo_tarjeta': tipo_tarjeta,
                'fabricante': fabricante,
                'entidad_bancaria': entidad_bancaria,
            })

        return jsonify({'tarjetas': tarjetas_resumen}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/eliminar-tarjeta/<int:tarjeta_id>', methods=['DELETE'])
def eliminar_tarjeta(tarjeta_id):
    """Elimina una tarjeta guardada"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor()
        ensure_tarjetas_table(cursor)

        cursor.execute('DELETE FROM tarjetas_usuario WHERE tarjeta_id = %s', (tarjeta_id,))
        connection.commit()

        if cursor.rowcount == 0:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Tarjeta no encontrada'}), 404

        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Tarjeta eliminada correctamente'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500

# Endpoint para registrar pago de una reserva pendiente
@app.route('/pagar-reserva', methods=['POST'])
def pagar_reserva():
    """Registra el pago de una reserva pendiente y la confirma"""
    try:
        data = request.get_json()
        reserva_id = data.get('reserva_id')
        tarjeta_id = data.get('tarjeta_id')
        tipo_pago = data.get('tipo')  # 'debito' o 'credito'
        cuotas = int(data.get('cuotas', 1))
        if not reserva_id or not tarjeta_id or not tipo_pago:
            return jsonify({'error': 'Faltan datos para procesar el pago'}), 400

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)
        schema_cursor = connection.cursor()
        ensure_pagos_columns(schema_cursor)
        schema_cursor.close()

        # Obtener datos de la tarjeta para validar y recuperar ultimos 4
        cursor.execute('''
            SELECT tarjeta_id
            FROM tarjetas_usuario
            WHERE tarjeta_id = %s
        ''', (tarjeta_id,))
        tarjeta = cursor.fetchone()
        if not tarjeta:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Tarjeta no encontrada'}), 404

        # Obtener datos de la reserva y vuelo
        cursor.execute('''
            SELECT urv.vuelo_id, vd.precio_base
            FROM usuario_reservas_vuelo urv
            JOIN vuelos vd ON urv.vuelo_id = vd.vuelo_id
            WHERE urv.reserva_id = %s
        ''', (reserva_id,))
        reserva = cursor.fetchone()
        if not reserva:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Reserva no encontrada'}), 404

        precio_base = float(reserva['precio_base'])
        interes = 0.0
        if tipo_pago == 'credito' and cuotas > 1:
            interes = 0.05 * (cuotas - 1)  # 5% por cada cuota extra
        monto_final = round(precio_base * (1 + interes), 2)

        # Capitalizar metodo_pago: 'debito' -> 'Debito', 'credito' -> 'Credito'
        metodo_pago = 'Debito' if tipo_pago.lower() == 'debito' else 'Credito'
        
        # Registrar el pago
        fecha_pago = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        cursor.execute('''
            INSERT INTO pagos (reserva_id, monto, fecha_pago, metodo_pago, estado_pago, interes_aplicado, tarjeta_id, cantidad_cuotas)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ''', (reserva_id, monto_final, fecha_pago, metodo_pago, 'Confirmado', interes, tarjeta_id, cuotas))

        # Actualizar estado de la reserva a confirmada
        cursor.execute('''
            UPDATE usuario_reservas_vuelo SET estado = 'confirmada' WHERE reserva_id = %s
        ''', (reserva_id,))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({'mensaje': 'Pago registrado y reserva confirmada', 'monto_final': monto_final, 'interes': interes}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/admin/aeropuertos', methods=['GET'])
def admin_aeropuertos():
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute(
            '''
            SELECT aeropuerto_id, nombre, ciudad, provincia, codigo_IATA
            FROM aeropuertos
            ORDER BY provincia, nombre
            '''
        )
        rows = cursor.fetchall()
        cursor.close()
        connection.close()
        return jsonify({'aeropuertos': rows}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/admin/vuelos', methods=['GET'])
def admin_vuelos_listar():
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        schema_cursor = connection.cursor()
        ensure_vuelos_asientos_column(schema_cursor)
        schema_cursor.close()

        cursor.execute(
            '''
            SELECT
                v.vuelo_id,
                v.codigo_vuelo,
                v.aeropuerto_origen,
                v.aeropuerto_destino,
                ao.nombre AS origen_nombre,
                ad.nombre AS destino_nombre,
                v.fecha_salida,
                v.fecha_llegada,
                v.capacidad_total,
                v.asientos_disponibles,
                v.precio_base
            FROM vuelos v
            JOIN aeropuertos ao ON v.aeropuerto_origen = ao.aeropuerto_id
            JOIN aeropuertos ad ON v.aeropuerto_destino = ad.aeropuerto_id
            ORDER BY v.fecha_salida DESC
            '''
        )
        rows = cursor.fetchall()

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

@app.route('/admin/vuelos', methods=['POST'])
def admin_vuelos_crear():
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
        cursor = connection.cursor()
        schema_cursor = connection.cursor()
        ensure_vuelos_asientos_column(schema_cursor)
        schema_cursor.close()

        cursor.execute(
            '''
            INSERT INTO vuelos (
                codigo_vuelo, aeropuerto_origen, aeropuerto_destino, fecha_salida,
                fecha_llegada, capacidad_total, asientos_disponibles, precio_base
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ''',
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
        nuevo_id = cursor.lastrowid
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

@app.route('/admin/vuelos/<int:vuelo_id>', methods=['PUT'])
def admin_vuelos_actualizar(vuelo_id):
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
        cursor = connection.cursor()
        schema_cursor = connection.cursor()
        ensure_vuelos_asientos_column(schema_cursor)
        schema_cursor.close()

        cursor.execute(
            '''
            UPDATE vuelos
            SET codigo_vuelo = %s,
                aeropuerto_origen = %s,
                aeropuerto_destino = %s,
                fecha_salida = %s,
                fecha_llegada = %s,
                capacidad_total = %s,
                asientos_disponibles = %s,
                precio_base = %s
            WHERE vuelo_id = %s
            ''',
            (
                codigo_vuelo,
                aeropuerto_origen,
                aeropuerto_destino,
                dt_salida.strftime('%Y-%m-%d %H:%M:%S'),
                dt_llegada.strftime('%Y-%m-%d %H:%M:%S'),
                capacidad_total,
                asientos_disponibles,
                precio_base,
                vuelo_id,
            )
        )
        if cursor.rowcount == 0:
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

@app.route('/admin/vuelos/<int:vuelo_id>', methods=['DELETE'])
def admin_vuelos_eliminar(vuelo_id):
    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        cursor.execute('SELECT COUNT(*) FROM usuario_reservas_vuelo WHERE vuelo_id = %s', (vuelo_id,))
        reservas_count = cursor.fetchone()[0]
        if reservas_count > 0:
            cursor.close()
            connection.close()
            return jsonify({'error': 'No se puede eliminar: el vuelo tiene reservas asociadas'}), 409

        cursor.execute('DELETE FROM vuelos WHERE vuelo_id = %s', (vuelo_id,))
        if cursor.rowcount == 0:
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

@app.route('/admin/usuarios', methods=['GET'])
def admin_usuarios_listar():
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute(
            '''
            SELECT usuario_id, nombre, apellido, email, telefono, direccion, fecha_nacimiento, fecha_registro
            FROM Usuarios
            ORDER BY fecha_registro DESC
            '''
        )
        rows = cursor.fetchall()
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

@app.route('/admin/usuarios', methods=['POST'])
def admin_usuarios_crear():
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

        cursor.execute('SELECT usuario_id FROM Usuarios WHERE email = %s', (email,))
        if cursor.fetchone():
            cursor.close()
            connection.close()
            return jsonify({'error': 'El email ya está registrado'}), 409

        contraseña_hash = hash_password(password)
        fecha_registro = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        cursor.execute(
            '''
            INSERT INTO Usuarios (nombre, apellido, email, contraseña_hash, telefono, direccion, fecha_nacimiento, fecha_registro)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ''',
            (nombre, apellido, email, contraseña_hash, telefono, direccion, fecha_nacimiento, fecha_registro)
        )
        nuevo_id = cursor.lastrowid
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Usuario creado', 'usuario_id': nuevo_id}), 201
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/admin/usuarios/<int:usuario_id>', methods=['PUT'])
def admin_usuarios_actualizar(usuario_id):
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

        cursor.execute('SELECT usuario_id FROM Usuarios WHERE usuario_id = %s', (usuario_id,))
        if not cursor.fetchone():
            cursor.close()
            connection.close()
            return jsonify({'error': 'Usuario no encontrado'}), 404

        cursor.execute('SELECT usuario_id FROM Usuarios WHERE email = %s AND usuario_id <> %s', (email, usuario_id))
        if cursor.fetchone():
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
                '''
                UPDATE Usuarios
                SET nombre = %s, apellido = %s, email = %s, telefono = %s, direccion = %s,
                    fecha_nacimiento = %s, contraseña_hash = %s
                WHERE usuario_id = %s
                ''',
                (nombre, apellido, email, telefono, direccion, fecha_nacimiento, contraseña_hash, usuario_id)
            )
        else:
            cursor.execute(
                '''
                UPDATE Usuarios
                SET nombre = %s, apellido = %s, email = %s, telefono = %s, direccion = %s,
                    fecha_nacimiento = %s
                WHERE usuario_id = %s
                ''',
                (nombre, apellido, email, telefono, direccion, fecha_nacimiento, usuario_id)
            )

        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Usuario actualizado'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/admin/usuarios/<int:usuario_id>', methods=['DELETE'])
def admin_usuarios_eliminar(usuario_id):
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('SELECT usuario_id FROM Usuarios WHERE usuario_id = %s', (usuario_id,))
        if not cursor.fetchone():
            cursor.close()
            connection.close()
            return jsonify({'error': 'Usuario no encontrado'}), 404

        cursor.execute('SELECT COUNT(*) AS total FROM usuario_reservas_vuelo WHERE usuario_id = %s', (usuario_id,))
        total_reservas = cursor.fetchone().get('total', 0)
        if total_reservas > 0:
            cursor.close()
            connection.close()
            return jsonify({'error': 'No se puede eliminar: el usuario tiene reservas asociadas'}), 409

        cursor.execute('DELETE FROM Usuarios WHERE usuario_id = %s', (usuario_id,))
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'mensaje': 'Usuario eliminado'}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500

@app.route('/admin/reservas', methods=['GET'])
def admin_reservas_listar():
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute(
            '''
            SELECT
                urv.reserva_id,
                urv.usuario_id,
                CONCAT(u.nombre, ' ', u.apellido) AS pasajero,
                u.email,
                urv.vuelo_id,
                v.codigo_vuelo,
                ao.nombre AS origen,
                ad.nombre AS destino,
                urv.fecha_reserva,
                urv.estado,
                p.monto AS pago_monto,
                p.metodo_pago AS pago_metodo,
                p.estado_pago AS pago_estado
            FROM usuario_reservas_vuelo urv
            JOIN Usuarios u ON urv.usuario_id = u.usuario_id
            JOIN vuelos v ON urv.vuelo_id = v.vuelo_id
            JOIN aeropuertos ao ON v.aeropuerto_origen = ao.aeropuerto_id
            JOIN aeropuertos ad ON v.aeropuerto_destino = ad.aeropuerto_id
            LEFT JOIN pagos p ON urv.reserva_id = p.reserva_id
            ORDER BY urv.fecha_reserva DESC
            '''
        )
        rows = cursor.fetchall()
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

@app.route('/admin/estadisticas', methods=['GET'])
def admin_estadisticas():
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        schema_cursor = connection.cursor()
        ensure_cancelaciones_table(schema_cursor)
        schema_cursor.close()

        cursor.execute(
            '''
            SELECT DATE_FORMAT(fecha_pago, '%%Y-%%m') AS mes, ROUND(SUM(monto), 2) AS total
            FROM pagos
            WHERE estado_pago = 'Confirmado'
            GROUP BY DATE_FORMAT(fecha_pago, '%%Y-%%m')
            ORDER BY mes DESC
            LIMIT 12
            '''
        )
        recaudacion_rows = cursor.fetchall()
        recaudacion_rows.reverse()

        cursor.execute('SELECT COUNT(*) AS total FROM usuario_reservas_vuelo')
        reservados = cursor.fetchone().get('total', 0)

        cursor.execute('SELECT COUNT(*) AS total FROM cancelaciones_reservas')
        cancelados = cursor.fetchone().get('total', 0)

        cursor.execute(
            '''
            SELECT ad.nombre AS destino, ad.provincia AS provincia, COUNT(*) AS cantidad
            FROM usuario_reservas_vuelo urv
            JOIN vuelos v ON urv.vuelo_id = v.vuelo_id
            JOIN aeropuertos ad ON v.aeropuerto_destino = ad.aeropuerto_id
            GROUP BY ad.aeropuerto_id, ad.nombre, ad.provincia
            ORDER BY cantidad DESC
            LIMIT 5
            '''
        )
        destinos_rows = cursor.fetchall()

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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT, debug=True)
