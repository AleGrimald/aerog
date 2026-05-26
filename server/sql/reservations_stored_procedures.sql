-- Querys originales y SPs de routes/reservations.py

DROP PROCEDURE IF EXISTS sp_reservations_descontar_asientos;
DROP PROCEDURE IF EXISTS sp_reservations_crear_reserva;
DROP PROCEDURE IF EXISTS sp_reservations_mis_reservas;
DROP PROCEDURE IF EXISTS sp_reservations_obtener_reserva;
DROP PROCEDURE IF EXISTS sp_reservations_insert_cancelacion;
DROP PROCEDURE IF EXISTS sp_reservations_delete_pago;
DROP PROCEDURE IF EXISTS sp_reservations_delete_reserva;
DROP PROCEDURE IF EXISTS sp_reservations_sumar_asientos;
DROP PROCEDURE IF EXISTS sp_reservations_sumar_asiento;
DROP PROCEDURE IF EXISTS sp_reservations_insert_usuario_secundario;
DROP PROCEDURE IF EXISTS sp_reservations_link_usuario_secundario_reserva;
DROP PROCEDURE IF EXISTS sp_reservations_count_secundarios;
DROP PROCEDURE IF EXISTS sp_reservations_delete_secundarios_by_reserva;
DROP PROCEDURE IF EXISTS sp_reservations_get_secundarios_by_reserva;
DROP PROCEDURE IF EXISTS sp_reservations_insert_asiento;
DROP PROCEDURE IF EXISTS sp_reservations_get_asientos_by_vuelo;
DROP PROCEDURE IF EXISTS sp_reservations_delete_asientos_by_reserva;
DROP PROCEDURE IF EXISTS sp_reservations_get_asientos_by_reserva;

DELIMITER $$

-- Original:
-- UPDATE vuelos SET asientos_disponibles = asientos_disponibles - ?
-- WHERE vuelo_id = ? AND asientos_disponibles >= ?;
CREATE PROCEDURE sp_reservations_descontar_asientos(
    IN p_vuelo_id INT,
    IN p_asientos INT
)
BEGIN
    UPDATE vuelos
    SET asientos_disponibles = asientos_disponibles - p_asientos
    WHERE vuelo_id = p_vuelo_id
      AND asientos_disponibles >= p_asientos;

    SELECT ROW_COUNT() AS affected_rows;
END$$
-- Usuarios
-- Original:
-- INSERT INTO usuario_reservas_vuelo (usuario_id, vuelo_id, fecha_reserva, estado)
-- VALUES (?, ?, ?, ?);
CREATE PROCEDURE sp_reservations_crear_reserva(
    IN p_usuario_id INT,
    IN p_vuelo_id INT,
    IN p_fecha_reserva DATETIME,
    IN p_estado VARCHAR(50)
)
BEGIN
    INSERT INTO usuario_reservas_vuelo (usuario_id, vuelo_id, fecha_reserva, estado)
    VALUES (p_usuario_id, p_vuelo_id, p_fecha_reserva, p_estado);

    SELECT LAST_INSERT_ID() AS reserva_id;
END$$

-- Original consulta completa de mis reservas (joins con vuelos/aeropuertos/usuarios/pagos/tarjetas).
CREATE PROCEDURE sp_reservations_mis_reservas(IN p_usuario_id INT)
BEGIN
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
        ao.nombre AS origen_nombre,
        ao.provincia AS provincia_origen,
        ad.nombre AS destino_nombre,
        ad.provincia AS provincia_destino,
        u.nombre,
        u.apellido,
        u.email,
        p.monto AS pago_monto,
        p.fecha_pago AS pago_fecha,
        p.metodo_pago AS pago_metodo,
        p.estado_pago AS pago_estado,
        p.interes_aplicado AS pago_interes,
        p.cantidad_cuotas AS pago_cuotas,
        CASE
            WHEN tu.ultimos4 REGEXP '^[0-9]{4}$' THEN tu.ultimos4
            ELSE NULL
        END AS pago_tarjeta_ultimos4,
        (
            1 + (
                SELECT COUNT(*)
                FROM usuario_secundario_reserva_vuelo usrv
                WHERE usrv.reserva_id = urv.reserva_id
            )
        ) AS cantidad_pasajeros
    FROM usuario_reservas_vuelo urv
    JOIN vuelos vd ON urv.vuelo_id = vd.vuelo_id
    JOIN aeropuertos ao ON vd.aeropuerto_origen = ao.aeropuerto_id
    JOIN aeropuertos ad ON vd.aeropuerto_destino = ad.aeropuerto_id
    JOIN usuarios u ON urv.usuario_id = u.usuario_id
    LEFT JOIN pagos p ON urv.reserva_id = p.reserva_id
    LEFT JOIN tarjetas_usuario tu ON p.tarjeta_id = tu.tarjeta_id
    WHERE urv.usuario_id = p_usuario_id
    ORDER BY urv.fecha_reserva DESC;
END$$

-- Original:
-- SELECT vuelo_id, usuario_id FROM usuario_reservas_vuelo WHERE reserva_id = ?;
CREATE PROCEDURE sp_reservations_obtener_reserva(IN p_reserva_id INT)
BEGIN
    SELECT vuelo_id, usuario_id
    FROM usuario_reservas_vuelo
    WHERE reserva_id = p_reserva_id
    LIMIT 1;
END$$

-- Original:
-- INSERT INTO cancelaciones_reservas (reserva_id, vuelo_id, usuario_id)
-- VALUES (?, ?, ?);
CREATE PROCEDURE sp_reservations_insert_cancelacion(
    IN p_reserva_id INT,
    IN p_vuelo_id INT,
    IN p_usuario_id INT
)
BEGIN
    INSERT INTO cancelaciones_reservas (reserva_id, vuelo_id, usuario_id)
    VALUES (p_reserva_id, p_vuelo_id, p_usuario_id);
END$$

-- Original:
-- DELETE FROM pagos WHERE reserva_id = ?;
CREATE PROCEDURE sp_reservations_delete_pago(IN p_reserva_id INT)
BEGIN
    DELETE FROM pagos
    WHERE reserva_id = p_reserva_id;
END$$

-- Original:
-- DELETE FROM usuario_reservas_vuelo WHERE reserva_id = ?;
CREATE PROCEDURE sp_reservations_delete_reserva(IN p_reserva_id INT)
BEGIN
    DELETE FROM usuario_reservas_vuelo
    WHERE reserva_id = p_reserva_id;

    SELECT ROW_COUNT() AS affected_rows;
END$$

-- Original:
-- UPDATE vuelos SET asientos_disponibles = asientos_disponibles + ? WHERE vuelo_id = ?;
CREATE PROCEDURE sp_reservations_sumar_asientos(
    IN p_vuelo_id INT,
    IN p_asientos INT
)
BEGIN
    UPDATE vuelos
    SET asientos_disponibles = asientos_disponibles + p_asientos
    WHERE vuelo_id = p_vuelo_id
      AND p_asientos >= 1;
END$$

-- Compatibilidad hacia atrás: suma 1 asiento.
CREATE PROCEDURE sp_reservations_sumar_asiento(IN p_vuelo_id INT)
BEGIN
    CALL sp_reservations_sumar_asientos(p_vuelo_id, 1);
END$$

CREATE PROCEDURE sp_reservations_insert_usuario_secundario(
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_direccion VARCHAR(255),
    IN p_telefono VARCHAR(30),
    IN p_dni VARCHAR(20),
    IN p_edad INT,
    IN p_email VARCHAR(150)
)
BEGIN
    INSERT INTO usuario_secundario (nombre, apellido, direccion, telefono, dni, edad, email)
    VALUES (p_nombre, p_apellido, p_direccion, p_telefono, p_dni, p_edad, p_email);

    SELECT LAST_INSERT_ID() AS usuario_secundario_id;
END$$

CREATE PROCEDURE sp_reservations_link_usuario_secundario_reserva(
    IN p_reserva_id INT,
    IN p_usuario_secundario_id INT
)
BEGIN
    INSERT INTO usuario_secundario_reserva_vuelo (reserva_id, usuario_secundario_id)
    VALUES (p_reserva_id, p_usuario_secundario_id);
END$$

CREATE PROCEDURE sp_reservations_count_secundarios(IN p_reserva_id INT)
BEGIN
    SELECT COUNT(*) AS cantidad_secundarios
    FROM usuario_secundario_reserva_vuelo
    WHERE reserva_id = p_reserva_id;
END$$

CREATE PROCEDURE sp_reservations_delete_secundarios_by_reserva(IN p_reserva_id INT)
BEGIN
    DELETE FROM usuario_secundario_reserva_vuelo
    WHERE reserva_id = p_reserva_id;
END$$

CREATE PROCEDURE sp_reservations_get_secundarios_by_reserva(IN p_reserva_id INT)
BEGIN
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
    WHERE usrv.reserva_id = p_reserva_id
    ORDER BY us.apellido, us.nombre;
END$$

CREATE PROCEDURE sp_reservations_insert_asiento(
    IN p_reserva_id INT,
    IN p_vuelo_id INT,
    IN p_asiento_codigo VARCHAR(8),
    IN p_numero_pasajero INT
)
BEGIN
    INSERT INTO reserva_asientos (reserva_id, vuelo_id, asiento_codigo, numero_pasajero)
    VALUES (p_reserva_id, p_vuelo_id, UPPER(TRIM(p_asiento_codigo)), p_numero_pasajero);
END$$

CREATE PROCEDURE sp_reservations_get_asientos_by_vuelo(IN p_vuelo_id INT)
BEGIN
    SELECT asiento_codigo
    FROM reserva_asientos
    WHERE vuelo_id = p_vuelo_id
    ORDER BY asiento_codigo;
END$$

CREATE PROCEDURE sp_reservations_delete_asientos_by_reserva(IN p_reserva_id INT)
BEGIN
    DELETE FROM reserva_asientos
    WHERE reserva_id = p_reserva_id;
END$$

CREATE PROCEDURE sp_reservations_get_asientos_by_reserva(IN p_reserva_id INT)
BEGIN
    SELECT asiento_codigo, numero_pasajero
    FROM reserva_asientos
    WHERE reserva_id = p_reserva_id
    ORDER BY numero_pasajero ASC, asiento_codigo ASC;
END$$

DELIMITER ;
