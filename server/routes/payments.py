"""Blueprint de pagos y gestión de tarjetas"""
from datetime import datetime
from flask import Blueprint, request, jsonify
from mysql.connector import Error
from mercadopago_utils import crear_preferencia_pago_qr, obtener_estado_pago_por_reserva

from .utils import (
    get_db_connection,
    detectar_metadata_tarjeta,
    hash_password,
)

cards_bp = Blueprint('cards', __name__)


def _sp_missing(exc: Error) -> bool:
    msg = str(exc).lower()
    return 'procedure' in msg and 'does not exist' in msg


def _drain_call_results(cursor) -> None:
    """Consume result sets pendientes de CALL para evitar 'commands out of sync'."""
    try:
        while cursor.nextset():
            pass
    except Exception:
        pass


def _ensure_tarjetas_schema(connection):
    """Ajusta esquema de tarjetas para no almacenar CVV y soportar hash + ultimos4."""
    schema_cursor = connection.cursor(dictionary=True)
    schema_cursor.execute('SHOW COLUMNS FROM tarjetas_usuario')
    columns = schema_cursor.fetchall()
    schema_cursor.close()

    col_map = {str(col.get('Field')): str(col.get('Type') or '').lower() for col in columns}

    alter_cursor = connection.cursor()
    changed = False

    numero_type = col_map.get('numero', '')
    if 'varchar(16)' in numero_type or 'char(16)' in numero_type:
        alter_cursor.execute('ALTER TABLE tarjetas_usuario MODIFY COLUMN numero VARCHAR(255) NOT NULL')
        changed = True

    vencimiento_type = col_map.get('vencimiento', '')
    if 'varchar(5)' in vencimiento_type or 'char(5)' in vencimiento_type:
        alter_cursor.execute('ALTER TABLE tarjetas_usuario MODIFY COLUMN vencimiento VARCHAR(10) NOT NULL')
        changed = True

    if 'ultimos4' not in col_map:
        alter_cursor.execute('ALTER TABLE tarjetas_usuario ADD COLUMN ultimos4 VARCHAR(4) NULL AFTER numero')
        changed = True

    if 'cvv' in col_map:
        alter_cursor.execute('ALTER TABLE tarjetas_usuario DROP COLUMN cvv')
        changed = True

    if changed:
        connection.commit()

    # Backfill de ultimos4 y hash para numeros históricos en texto plano.
    backfill_cursor = connection.cursor()
    backfill_cursor.execute(
        """
        UPDATE tarjetas_usuario
        SET ultimos4 = RIGHT(numero, 4)
        WHERE (ultimos4 IS NULL OR ultimos4 = '')
          AND numero REGEXP '^[0-9]{13,19}$'
        """
    )
    backfill_cursor.execute(
        """
        SELECT tarjeta_id, numero
        FROM tarjetas_usuario
        WHERE numero REGEXP '^[0-9]{13,19}$'
        """
    )
    plain_rows = backfill_cursor.fetchall()
    for tarjeta_id, numero_plano in plain_rows:
        backfill_cursor.execute(
            'UPDATE tarjetas_usuario SET numero = %s WHERE tarjeta_id = %s',
            (hash_password(str(numero_plano)), tarjeta_id)
        )
    connection.commit()
    backfill_cursor.close()
    alter_cursor.close()


@cards_bp.route('/agregar-tarjeta', methods=['POST'])
def agregar_tarjeta():
    """Guarda una tarjeta de crédito/débito para el usuario"""
    try:
        data = request.get_json() or {}
        usuario_id = data.get('usuario_id')
        numero = data.get('numero')
        titular = data.get('titular')
        vencimiento = data.get('vencimiento')

        if not usuario_id or not numero or not titular or not vencimiento:
            return jsonify({'error': 'Todos los campos de la tarjeta son requeridos'}), 400

        numero_limpio = ''.join(ch for ch in str(numero) if ch.isdigit())
        if len(numero_limpio) < 13 or len(numero_limpio) > 19:
            return jsonify({'error': 'Número de tarjeta inválido'}), 400

        metadata = detectar_metadata_tarjeta(numero_limpio)

        connection = get_db_connection()
        _ensure_tarjetas_schema(connection)
        cursor = connection.cursor(dictionary=True, buffered=True)

        numero_hash = hash_password(numero_limpio)
        ultimos4 = numero_limpio[-4:]
        
        cursor.execute(
            'CALL sp_cards_agregar_tarjeta(%s, %s, %s, %s, %s, %s, %s, %s)',
            (usuario_id, numero_hash, ultimos4, titular, vencimiento, metadata['tipo_tarjeta'], metadata['fabricante'], metadata['entidad_bancaria'])
        )
        tarjeta_id = (cursor.fetchone() or {}).get('tarjeta_id')
        _drain_call_results(cursor)
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
        if _sp_missing(exc):
            return jsonify({'error': 'Faltan stored procedures de tarjetas/pagos en la base de datos. Ejecuta server/sql/payments_stored_procedures.sql'}), 500
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        import traceback; traceback.print_exc()
        return jsonify({'error': str(exc)}), 500


@cards_bp.route('/tarjeta-usuario/<int:usuario_id>', methods=['GET'])
def obtener_tarjeta_usuario(usuario_id):
    """Obtiene todas las tarjetas guardadas de un usuario"""
    try:
        connection = get_db_connection()
        _ensure_tarjetas_schema(connection)
        cursor = connection.cursor(dictionary=True)

        cursor.execute('CALL sp_cards_obtener_tarjetas_usuario(%s)', (usuario_id,))
        tarjetas = cursor.fetchall()
        _drain_call_results(cursor)

        cursor.close()
        connection.close()

        tarjetas_resumen = []
        for tarjeta in tarjetas:
            ultimos4 = str(tarjeta.get('ultimos4') or '****')
            fabricante = tarjeta.get('fabricante') or 'Desconocida'
            tipo_tarjeta = tarjeta.get('tipo_tarjeta') or 'Desconocido'
            entidad_bancaria = tarjeta.get('entidad_bancaria') or 'No identificado'

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
        if _sp_missing(exc):
            return jsonify({'error': 'Faltan stored procedures de pagos en la base de datos. Ejecuta server/sql/payments_stored_procedures.sql'}), 500
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500


@cards_bp.route('/eliminar-tarjeta/<int:tarjeta_id>', methods=['DELETE'])
def eliminar_tarjeta(tarjeta_id):
    """Elimina una tarjeta guardada"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('CALL sp_cards_eliminar_tarjeta(%s)', (tarjeta_id,))
        result = cursor.fetchone() or {}
        _drain_call_results(cursor)
        connection.commit()

        if int(result.get('affected_rows') or 0) == 0:
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


payments_bp = Blueprint('payments', __name__)


@payments_bp.route('/crear-pago-qr', methods=['POST'])
def crear_pago_qr():
    """Crea una preferencia de Mercado Pago QR para una reserva pendiente."""
    try:
        data = request.get_json() or {}
        reserva_id = data.get('reserva_id')
        usuario_email = (data.get('usuario_email') or '').strip()

        if not reserva_id:
            return jsonify({'error': 'Falta reserva_id'}), 400

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('CALL sp_payments_obtener_reserva_qr(%s)', (reserva_id,))
        reserva = cursor.fetchone()
        _drain_call_results(cursor)
        if not reserva:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Reserva no encontrada'}), 404

        if (reserva.get('estado') or '').lower() == 'confirmada':
            cursor.close()
            connection.close()
            return jsonify({'error': 'La reserva ya se encuentra confirmada'}), 409

        monto = float(reserva.get('precio_base') or 0)
        email_payer = usuario_email or (reserva.get('email') or '').strip()
        if not email_payer:
            cursor.close()
            connection.close()
            return jsonify({'error': 'No se pudo obtener el email del pagador'}), 400

        descripcion = f"Pago reserva Aero G #{reserva_id}"
        preferencia = crear_preferencia_pago_qr(
            monto=monto,
            descripcion=descripcion,
            reserva_id=reserva_id,
            usuario_email=email_payer,
        )

        cursor.execute('CALL sp_payments_obtener_pago_qr_existente(%s)', (reserva_id,))
        pago_existente = cursor.fetchone()
        _drain_call_results(cursor)

        if pago_existente:
            cursor.execute(
                'CALL sp_payments_actualizar_pago_qr(%s, %s, %s, %s, %s, %s, %s)',
                (
                    pago_existente['pago_id'],
                    monto,
                    datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                    'Pendiente',
                    0,
                    None,
                    1,
                )
            )
            _drain_call_results(cursor)
        else:
            cursor.execute(
                'CALL sp_payments_insertar_pago(%s, %s, %s, %s, %s, %s, %s, %s)',
                (reserva_id, monto, datetime.now().strftime('%Y-%m-%d %H:%M:%S'), 'MercadoPago QR', 'Pendiente', 0, None, 1)
            )
            _drain_call_results(cursor)

        connection.commit()
        cursor.close()
        connection.close()

        checkout_url = preferencia.get('init_point') or preferencia.get('sandbox_init_point')
        if not checkout_url:
            return jsonify({'error': 'Mercado Pago no devolvió URL de checkout'}), 502

        return jsonify({
            'mensaje': 'Preferencia QR creada',
            'checkout_url': checkout_url,
            'preference_id': preferencia.get('preference_id'),
            'estado': 'pendiente',
        }), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': str(exc)}), 500


@payments_bp.route('/verificar-pago-qr', methods=['POST'])
def verificar_pago_qr():
    """Verifica en Mercado Pago el estado del pago QR y confirma la reserva si corresponde."""
    try:
        data = request.get_json() or {}
        reserva_id = data.get('reserva_id')
        if not reserva_id:
            return jsonify({'error': 'Falta reserva_id'}), 400

        estado_mp = obtener_estado_pago_por_reserva(reserva_id)
        status = (estado_mp.get('status') or '').lower()

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        cursor.execute('CALL sp_payments_obtener_estado_reserva(%s)', (reserva_id,))
        reserva = cursor.fetchone()
        _drain_call_results(cursor)
        if not reserva:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Reserva no encontrada'}), 404

        if status == 'approved':
            cursor.execute('CALL sp_payments_confirmar_pago_qr(%s, %s)', (reserva_id, datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
            _drain_call_results(cursor)
            cursor.execute('CALL sp_payments_confirmar_reserva(%s)', (reserva_id,))
            _drain_call_results(cursor)
            connection.commit()
            cursor.close()
            connection.close()
            return jsonify({
                'estado': 'confirmado',
                'payment_id': estado_mp.get('payment_id'),
                'mensaje': 'Pago aprobado y reserva confirmada',
            }), 200

        if status in ('rejected', 'cancelled', 'refunded', 'charged_back'):
            cursor.execute(
                'CALL sp_payments_actualizar_estado_pago_qr(%s, %s, %s)',
                (reserva_id, status.capitalize(), datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            )
            _drain_call_results(cursor)
            connection.commit()
            cursor.close()
            connection.close()
            return jsonify({
                'estado': status,
                'payment_id': estado_mp.get('payment_id'),
                'mensaje': 'El pago no fue aprobado',
            }), 200

        cursor.close()
        connection.close()
        return jsonify({
            'estado': 'pendiente',
            'payment_id': estado_mp.get('payment_id'),
            'status_detail': estado_mp.get('status_detail'),
            'mensaje': 'El pago todavía no fue aprobado',
        }), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': str(exc)}), 500


@payments_bp.route('/pagar-reserva', methods=['POST'])
def pagar_reserva():
    """Registra el pago de una reserva pendiente y la confirma"""
    try:
        data = request.get_json()
        reserva_id = data.get('reserva_id')
        tarjeta_id = data.get('tarjeta_id')
        tipo_pago = data.get('tipo')  # 'debito' o 'credito'
        cvv = str(data.get('cvv', '')).strip()
        cuotas = int(data.get('cuotas', 1))
        if not reserva_id or not tarjeta_id or not tipo_pago:
            return jsonify({'error': 'Faltan datos para procesar el pago'}), 400
        if not cvv or not cvv.isdigit() or len(cvv) not in (3, 4):
            return jsonify({'error': 'CVV inválido'}), 400

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)

        # Obtener datos de la tarjeta para validar y recuperar ultimos 4
        cursor.execute('CALL sp_payments_obtener_tarjeta(%s)', (tarjeta_id,))
        tarjeta = cursor.fetchone()
        _drain_call_results(cursor)
        if not tarjeta:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Tarjeta no encontrada'}), 404

        # Obtener datos de la reserva y vuelo
        cursor.execute('CALL sp_payments_obtener_reserva_para_pago(%s)', (reserva_id,))
        reserva = cursor.fetchone()
        _drain_call_results(cursor)
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
        cursor.execute(
            'CALL sp_payments_insertar_pago(%s, %s, %s, %s, %s, %s, %s, %s)',
            (reserva_id, monto_final, fecha_pago, metodo_pago, 'Confirmado', interes, tarjeta_id, cuotas)
        )
        _drain_call_results(cursor)

        # Actualizar estado de la reserva a confirmada
        cursor.execute('CALL sp_payments_confirmar_reserva(%s)', (reserva_id,))
        _drain_call_results(cursor)

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({'mensaje': 'Pago registrado y reserva confirmada', 'monto_final': monto_final, 'interes': interes}), 200
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception as exc:
        return jsonify({'error': 'Error en el servidor'}), 500
