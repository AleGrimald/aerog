-- Querys funcionales migradas de routes/payments.py
-- Nota: _ensure_tarjetas_schema mantiene SQL directo por tratarse de DDL/migración de esquema.

DROP PROCEDURE IF EXISTS sp_cards_agregar_tarjeta;
DROP PROCEDURE IF EXISTS sp_cards_obtener_tarjetas_usuario;
DROP PROCEDURE IF EXISTS sp_cards_eliminar_tarjeta;
DROP PROCEDURE IF EXISTS sp_payments_obtener_reserva_qr;
DROP PROCEDURE IF EXISTS sp_payments_obtener_pago_qr_existente;
DROP PROCEDURE IF EXISTS sp_payments_actualizar_pago_qr;
DROP PROCEDURE IF EXISTS sp_payments_insertar_pago;
DROP PROCEDURE IF EXISTS sp_payments_obtener_estado_reserva;
DROP PROCEDURE IF EXISTS sp_payments_confirmar_pago_qr;
DROP PROCEDURE IF EXISTS sp_payments_actualizar_estado_pago_qr;
DROP PROCEDURE IF EXISTS sp_payments_confirmar_reserva;
DROP PROCEDURE IF EXISTS sp_payments_obtener_tarjeta;
DROP PROCEDURE IF EXISTS sp_payments_obtener_reserva_para_pago;

DELIMITER $$

-- Original: INSERT INTO tarjetas_usuario (...)
CREATE PROCEDURE sp_cards_agregar_tarjeta(
    IN p_usuario_id INT,
    IN p_numero_hash VARCHAR(255),
    IN p_ultimos4 VARCHAR(4),
    IN p_titular VARCHAR(255),
    IN p_vencimiento VARCHAR(10),
    IN p_tipo_tarjeta VARCHAR(50),
    IN p_fabricante VARCHAR(100),
    IN p_entidad_bancaria VARCHAR(100)
)
BEGIN
    INSERT INTO tarjetas_usuario (usuario_id, numero, ultimos4, titular, vencimiento, tipo_tarjeta, fabricante, entidad_bancaria)
    VALUES (p_usuario_id, p_numero_hash, p_ultimos4, p_titular, p_vencimiento, p_tipo_tarjeta, p_fabricante, p_entidad_bancaria);

    SELECT LAST_INSERT_ID() AS tarjeta_id;
END$$

-- Original: SELECT ... FROM tarjetas_usuario WHERE usuario_id = ? ORDER BY ...
CREATE PROCEDURE sp_cards_obtener_tarjetas_usuario(IN p_usuario_id INT)
BEGIN
    SELECT tarjeta_id, titular, ultimos4, tipo_tarjeta, fabricante, entidad_bancaria
    FROM tarjetas_usuario
    WHERE usuario_id = p_usuario_id
    ORDER BY fecha_agregada DESC, tarjeta_id DESC;
END$$

-- Original: DELETE FROM tarjetas_usuario WHERE tarjeta_id = ?
CREATE PROCEDURE sp_cards_eliminar_tarjeta(IN p_tarjeta_id INT)
BEGIN
    DELETE FROM tarjetas_usuario
    WHERE tarjeta_id = p_tarjeta_id;

    SELECT ROW_COUNT() AS affected_rows;
END$$

-- Original QR: SELECT urv.reserva_id, urv.estado, vd.precio_base, u.email ...
CREATE PROCEDURE sp_payments_obtener_reserva_qr(IN p_reserva_id INT)
BEGIN
    SELECT urv.reserva_id, urv.estado, vd.precio_base, u.email
    FROM usuario_reservas_vuelo urv
    JOIN vuelos vd ON urv.vuelo_id = vd.vuelo_id
    JOIN Usuarios u ON urv.usuario_id = u.usuario_id
    WHERE urv.reserva_id = p_reserva_id
    LIMIT 1;
END$$

-- Original: SELECT pago_id, estado_pago FROM pagos WHERE reserva_id = ? AND metodo_pago='MercadoPago QR' ...
CREATE PROCEDURE sp_payments_obtener_pago_qr_existente(IN p_reserva_id INT)
BEGIN
    SELECT pago_id, estado_pago
    FROM pagos
    WHERE reserva_id = p_reserva_id AND metodo_pago = 'MercadoPago QR'
    ORDER BY pago_id DESC
    LIMIT 1;
END$$

-- Original: UPDATE pagos ... WHERE pago_id = ?
CREATE PROCEDURE sp_payments_actualizar_pago_qr(
    IN p_pago_id INT,
    IN p_monto DECIMAL(12,2),
    IN p_fecha_pago DATETIME,
    IN p_estado_pago VARCHAR(50),
    IN p_interes DECIMAL(12,4),
    IN p_tarjeta_id INT,
    IN p_cuotas INT
)
BEGIN
    UPDATE pagos
    SET monto = p_monto,
        fecha_pago = p_fecha_pago,
        estado_pago = p_estado_pago,
        interes_aplicado = p_interes,
        tarjeta_id = p_tarjeta_id,
        cantidad_cuotas = p_cuotas
    WHERE pago_id = p_pago_id;
END$$

-- Original: INSERT INTO pagos (...)
CREATE PROCEDURE sp_payments_insertar_pago(
    IN p_reserva_id INT,
    IN p_monto DECIMAL(12,2),
    IN p_fecha_pago DATETIME,
    IN p_metodo_pago VARCHAR(100),
    IN p_estado_pago VARCHAR(50),
    IN p_interes DECIMAL(12,4),
    IN p_tarjeta_id INT,
    IN p_cuotas INT
)
BEGIN
    INSERT INTO pagos (reserva_id, monto, fecha_pago, metodo_pago, estado_pago, interes_aplicado, tarjeta_id, cantidad_cuotas)
    VALUES (p_reserva_id, p_monto, p_fecha_pago, p_metodo_pago, p_estado_pago, p_interes, p_tarjeta_id, p_cuotas);
END$$

-- Original: SELECT reserva_id, estado FROM usuario_reservas_vuelo WHERE reserva_id = ? LIMIT 1
CREATE PROCEDURE sp_payments_obtener_estado_reserva(IN p_reserva_id INT)
BEGIN
    SELECT reserva_id, estado
    FROM usuario_reservas_vuelo
    WHERE reserva_id = p_reserva_id
    LIMIT 1;
END$$

-- Original: UPDATE pagos SET estado_pago='Confirmado', fecha_pago=? WHERE reserva_id=? AND metodo_pago='MercadoPago QR' ORDER BY pago_id DESC LIMIT 1
CREATE PROCEDURE sp_payments_confirmar_pago_qr(
    IN p_reserva_id INT,
    IN p_fecha_pago DATETIME
)
BEGIN
    UPDATE pagos p
    JOIN (
        SELECT pago_id
        FROM pagos
        WHERE reserva_id = p_reserva_id AND metodo_pago = 'MercadoPago QR'
        ORDER BY pago_id DESC
        LIMIT 1
    ) x ON p.pago_id = x.pago_id
    SET p.estado_pago = 'Confirmado',
        p.fecha_pago = p_fecha_pago;
END$$

-- Original: UPDATE pagos SET estado_pago=?, fecha_pago=? WHERE reserva_id=? AND metodo_pago='MercadoPago QR' ORDER BY pago_id DESC LIMIT 1
CREATE PROCEDURE sp_payments_actualizar_estado_pago_qr(
    IN p_reserva_id INT,
    IN p_estado_pago VARCHAR(50),
    IN p_fecha_pago DATETIME
)
BEGIN
    UPDATE pagos p
    JOIN (
        SELECT pago_id
        FROM pagos
        WHERE reserva_id = p_reserva_id AND metodo_pago = 'MercadoPago QR'
        ORDER BY pago_id DESC
        LIMIT 1
    ) x ON p.pago_id = x.pago_id
    SET p.estado_pago = p_estado_pago,
        p.fecha_pago = p_fecha_pago;
END$$

-- Original: UPDATE usuario_reservas_vuelo SET estado='confirmada' WHERE reserva_id=?
CREATE PROCEDURE sp_payments_confirmar_reserva(IN p_reserva_id INT)
BEGIN
    UPDATE usuario_reservas_vuelo
    SET estado = 'confirmada'
    WHERE reserva_id = p_reserva_id;
END$$

-- Original: SELECT tarjeta_id FROM tarjetas_usuario WHERE tarjeta_id = ?
CREATE PROCEDURE sp_payments_obtener_tarjeta(IN p_tarjeta_id INT)
BEGIN
    SELECT tarjeta_id
    FROM tarjetas_usuario
    WHERE tarjeta_id = p_tarjeta_id
    LIMIT 1;
END$$

-- Original: SELECT urv.vuelo_id, vd.precio_base FROM usuario_reservas_vuelo urv JOIN vuelos vd ... WHERE urv.reserva_id = ?
CREATE PROCEDURE sp_payments_obtener_reserva_para_pago(IN p_reserva_id INT)
BEGIN
    SELECT urv.vuelo_id, vd.precio_base
    FROM usuario_reservas_vuelo urv
    JOIN vuelos vd ON urv.vuelo_id = vd.vuelo_id
    WHERE urv.reserva_id = p_reserva_id
    LIMIT 1;
END$$

DELIMITER ;
