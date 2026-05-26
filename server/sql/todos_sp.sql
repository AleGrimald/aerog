-- ========================================
-- DROP PROCEDURES (GLOBAL)
-- ========================================
DROP PROCEDURE IF EXISTS sp_admin_aeropuertos_listar;
DROP PROCEDURE IF EXISTS sp_admin_vuelos_listar;
DROP PROCEDURE IF EXISTS sp_admin_vuelos_crear;
DROP PROCEDURE IF EXISTS sp_admin_vuelos_actualizar;
DROP PROCEDURE IF EXISTS sp_admin_vuelos_count_reservas;
DROP PROCEDURE IF EXISTS sp_admin_vuelos_eliminar;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_listar;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_buscar_por_email;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_crear;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_buscar_por_id;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_email_duplicado;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_actualizar_con_password;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_actualizar_sin_password;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_obtener_estado;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_desactivar;
DROP PROCEDURE IF EXISTS sp_admin_reservas_listar;
DROP PROCEDURE IF EXISTS sp_admin_estadisticas_recaudacion;
DROP PROCEDURE IF EXISTS sp_admin_estadisticas_total_reservas;
DROP PROCEDURE IF EXISTS sp_admin_estadisticas_total_cancelaciones;
DROP PROCEDURE IF EXISTS sp_admin_estadisticas_destinos_top;
DROP PROCEDURE IF EXISTS sp_login_usuario;
DROP PROCEDURE IF EXISTS sp_auth_buscar_usuario_por_email;
DROP PROCEDURE IF EXISTS sp_auth_registrar_usuario;
DROP PROCEDURE IF EXISTS sp_auth_activar_usuario;
DROP PROCEDURE IF EXISTS sp_auth_actualizar_perfil;
DROP PROCEDURE IF EXISTS sp_common_obtener_usuarios;
DROP PROCEDURE IF EXISTS sp_flights_airport_suggestions;
DROP PROCEDURE IF EXISTS sp_flights_buscar_vuelos;
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

-- ========================================
-- FILE: admin_stored_procedures.sql
-- ========================================

-- Querys migradas de routes/admin.py


DELIMITER $$

CREATE PROCEDURE sp_admin_aeropuertos_listar()
BEGIN
    SELECT aeropuerto_id, nombre, ciudad, provincia, codigo_IATA
    FROM aeropuertos
    ORDER BY provincia, nombre;
END$$

CREATE PROCEDURE sp_admin_vuelos_listar()
BEGIN
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
    ORDER BY v.fecha_salida DESC;
END$$

CREATE PROCEDURE sp_admin_vuelos_crear(
    IN p_codigo_vuelo VARCHAR(50),
    IN p_aeropuerto_origen INT,
    IN p_aeropuerto_destino INT,
    IN p_fecha_salida DATETIME,
    IN p_fecha_llegada DATETIME,
    IN p_capacidad_total INT,
    IN p_asientos_disponibles INT,
    IN p_precio_base DECIMAL(12,2)
)
BEGIN
    INSERT INTO vuelos (
        codigo_vuelo, aeropuerto_origen, aeropuerto_destino, fecha_salida,
        fecha_llegada, capacidad_total, asientos_disponibles, precio_base
    )
    VALUES (
        p_codigo_vuelo, p_aeropuerto_origen, p_aeropuerto_destino, p_fecha_salida,
        p_fecha_llegada, p_capacidad_total, p_asientos_disponibles, p_precio_base
    );

    SELECT LAST_INSERT_ID() AS vuelo_id;
END$$

CREATE PROCEDURE sp_admin_vuelos_actualizar(
    IN p_vuelo_id INT,
    IN p_codigo_vuelo VARCHAR(50),
    IN p_aeropuerto_origen INT,
    IN p_aeropuerto_destino INT,
    IN p_fecha_salida DATETIME,
    IN p_fecha_llegada DATETIME,
    IN p_capacidad_total INT,
    IN p_asientos_disponibles INT,
    IN p_precio_base DECIMAL(12,2)
)
BEGIN
    UPDATE vuelos
    SET codigo_vuelo = p_codigo_vuelo,
        aeropuerto_origen = p_aeropuerto_origen,
        aeropuerto_destino = p_aeropuerto_destino,
        fecha_salida = p_fecha_salida,
        fecha_llegada = p_fecha_llegada,
        capacidad_total = p_capacidad_total,
        asientos_disponibles = p_asientos_disponibles,
        precio_base = p_precio_base
    WHERE vuelo_id = p_vuelo_id;

    SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_admin_vuelos_count_reservas(IN p_vuelo_id INT)
BEGIN
    SELECT COUNT(*) AS total
    FROM usuario_reservas_vuelo
    WHERE vuelo_id = p_vuelo_id;
END$$

CREATE PROCEDURE sp_admin_vuelos_eliminar(IN p_vuelo_id INT)
BEGIN
    DELETE FROM vuelos
    WHERE vuelo_id = p_vuelo_id;

    SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE PROCEDURE sp_admin_usuarios_listar()
BEGIN
    SELECT usuario_id, nombre, apellido, email, telefono, direccion, dni, fecha_nacimiento, fecha_registro, activo
    FROM usuarios
    ORDER BY fecha_registro DESC;
END$$

CREATE PROCEDURE sp_admin_usuarios_buscar_por_email(IN p_email VARCHAR(255))
BEGIN
    SELECT usuario_id
    FROM usuarios
    WHERE email = p_email
    LIMIT 1;
END$$

CREATE PROCEDURE sp_admin_usuarios_crear(
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_contrasena_hash TEXT,
    IN p_telefono VARCHAR(50),
    IN p_direccion VARCHAR(255),
    IN p_dni VARCHAR(9),
    IN p_fecha_nacimiento DATE,
    IN p_fecha_registro DATETIME
)
BEGIN
    INSERT INTO usuarios (nombre, apellido, email, contraseÃ±a_hash, telefono, direccion, dni, fecha_nacimiento, fecha_registro, activo)
    VALUES (p_nombre, p_apellido, p_email, p_contrasena_hash, p_telefono, p_direccion, p_dni, p_fecha_nacimiento, p_fecha_registro, 1);

    SELECT LAST_INSERT_ID() AS usuario_id;
END$$

CREATE PROCEDURE sp_admin_usuarios_buscar_por_id(IN p_usuario_id INT)
BEGIN
    SELECT usuario_id
    FROM usuarios
    WHERE usuario_id = p_usuario_id
    LIMIT 1;
END$$

CREATE PROCEDURE sp_admin_usuarios_email_duplicado(
    IN p_email VARCHAR(255),
    IN p_usuario_id INT
)
BEGIN
    SELECT usuario_id
    FROM usuarios
    WHERE email = p_email
      AND usuario_id <> p_usuario_id
    LIMIT 1;
END$$

CREATE PROCEDURE sp_admin_usuarios_actualizar_con_password(
    IN p_usuario_id INT,
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_telefono VARCHAR(50),
    IN p_direccion VARCHAR(255),
    IN p_dni VARCHAR(9),
    IN p_fecha_nacimiento DATE,
    IN p_contrasena_hash TEXT
)
BEGIN
    UPDATE usuarios
    SET nombre = p_nombre,
        apellido = p_apellido,
        email = p_email,
        telefono = p_telefono,
        direccion = p_direccion,
        dni = p_dni,
        fecha_nacimiento = p_fecha_nacimiento,
        contraseÃ±a_hash = p_contrasena_hash
    WHERE usuario_id = p_usuario_id;
END$$

CREATE PROCEDURE sp_admin_usuarios_actualizar_sin_password(
    IN p_usuario_id INT,
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_telefono VARCHAR(50),
    IN p_direccion VARCHAR(255),
    IN p_dni VARCHAR(9),
    IN p_fecha_nacimiento DATE
)
BEGIN
    UPDATE usuarios
    SET nombre = p_nombre,
        apellido = p_apellido,
        email = p_email,
        telefono = p_telefono,
        direccion = p_direccion,
        dni = p_dni,
        fecha_nacimiento = p_fecha_nacimiento
    WHERE usuario_id = p_usuario_id;
END$$

CREATE PROCEDURE sp_admin_usuarios_obtener_estado(IN p_usuario_id INT)
BEGIN
    SELECT usuario_id, activo
    FROM usuarios
    WHERE usuario_id = p_usuario_id
    LIMIT 1;
END$$

CREATE PROCEDURE sp_admin_usuarios_desactivar(IN p_usuario_id INT)
BEGIN
    UPDATE usuarios
    SET activo = 0
    WHERE usuario_id = p_usuario_id;
END$$

CREATE PROCEDURE sp_admin_reservas_listar()
BEGIN
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
    JOIN usuarios u ON urv.usuario_id = u.usuario_id
    JOIN vuelos v ON urv.vuelo_id = v.vuelo_id
    JOIN aeropuertos ao ON v.aeropuerto_origen = ao.aeropuerto_id
    JOIN aeropuertos ad ON v.aeropuerto_destino = ad.aeropuerto_id
    LEFT JOIN pagos p ON urv.reserva_id = p.reserva_id
    ORDER BY urv.fecha_reserva DESC;
END$$

CREATE PROCEDURE sp_admin_estadisticas_recaudacion()
BEGIN
    SELECT DATE_FORMAT(fecha_pago, '%Y-%m') AS mes, ROUND(SUM(monto), 2) AS total
    FROM pagos
    WHERE estado_pago = 'Confirmado'
    GROUP BY DATE_FORMAT(fecha_pago, '%Y-%m')
    ORDER BY mes DESC
    LIMIT 12;
END$$

CREATE PROCEDURE sp_admin_estadisticas_total_reservas()
BEGIN
    SELECT COUNT(*) AS total
    FROM usuario_reservas_vuelo;
END$$

CREATE PROCEDURE sp_admin_estadisticas_total_cancelaciones()
BEGIN
    SELECT COUNT(*) AS total
    FROM cancelaciones_reservas;
END$$

CREATE PROCEDURE sp_admin_estadisticas_destinos_top()
BEGIN
    SELECT ad.nombre AS destino, ad.provincia AS provincia, COUNT(*) AS cantidad
    FROM usuario_reservas_vuelo urv
    JOIN vuelos v ON urv.vuelo_id = v.vuelo_id
    JOIN aeropuertos ad ON v.aeropuerto_destino = ad.aeropuerto_id
    GROUP BY ad.aeropuerto_id, ad.nombre, ad.provincia
    ORDER BY cantidad DESC
    LIMIT 5;
END$$

DELIMITER ;

-- ========================================
-- FILE: auth_stored_procedures.sql
-- ========================================

-- Querys originales y procedimientos almacenados para routes/auth.py

-- Original login (ya migrada):
-- SELECT usuario_id, nombre, apellido, email, telefono, direccion, dni, fecha_nacimiento, fecha_registro, contraseÃ±a_hash, activo
-- FROM usuarios
-- WHERE email = ? OR LOWER(nombre) = ?
-- LIMIT 1;


DELIMITER $$

CREATE PROCEDURE sp_login_usuario(IN p_identificador VARCHAR(255))
BEGIN
    SELECT
        usuario_id,
        nombre,
        apellido,
        email,
        telefono,
        direccion,
        dni,
        fecha_nacimiento,
        fecha_registro,
        contraseÃ±a_hash,
        activo
    FROM usuarios
    WHERE email = p_identificador
       OR LOWER(nombre) = p_identificador
    LIMIT 1;
END$$

-- Original:
-- SELECT usuario_id, activo FROM usuarios WHERE email = ? LIMIT 1;
CREATE PROCEDURE sp_auth_buscar_usuario_por_email(IN p_email VARCHAR(255))
BEGIN
    SELECT usuario_id, activo
    FROM usuarios
    WHERE email = p_email
    LIMIT 1;
END$$

-- Original:
-- INSERT INTO usuarios (nombre, apellido, email, contraseÃ±a_hash, telefono, direccion, dni, fecha_nacimiento, fecha_registro, activo)
-- VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0);
CREATE PROCEDURE sp_auth_registrar_usuario(
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_contrasena_hash TEXT,
    IN p_telefono VARCHAR(50),
    IN p_direccion VARCHAR(255),
    IN p_dni VARCHAR(9),
    IN p_fecha_nacimiento DATE,
    IN p_fecha_registro DATETIME
)
BEGIN
    INSERT INTO usuarios (nombre, apellido, email, contraseÃ±a_hash, telefono, direccion, dni, fecha_nacimiento, fecha_registro, activo)
    VALUES (p_nombre, p_apellido, p_email, p_contrasena_hash, p_telefono, p_direccion, p_dni, p_fecha_nacimiento, p_fecha_registro, 0);

    SELECT LAST_INSERT_ID() AS usuario_id;
END$$

-- Original:
-- UPDATE usuarios SET activo = 1 WHERE usuario_id = ?;
CREATE PROCEDURE sp_auth_activar_usuario(IN p_usuario_id INT)
BEGIN
    UPDATE usuarios
    SET activo = 1
    WHERE usuario_id = p_usuario_id;
END$$

-- Original:
-- UPDATE usuarios
-- SET nombre = ?, apellido = ?, email = ?, telefono = ?, direccion = ?, dni = ?
-- WHERE usuario_id = ?;
CREATE PROCEDURE sp_auth_actualizar_perfil(
    IN p_usuario_id INT,
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_telefono VARCHAR(50),
    IN p_direccion VARCHAR(255),
    IN p_dni VARCHAR(9)
)
BEGIN
    UPDATE usuarios
    SET nombre = p_nombre,
        apellido = p_apellido,
        email = p_email,
        telefono = p_telefono,
        direccion = p_direccion,
        dni = p_dni
    WHERE usuario_id = p_usuario_id;
END$$

DELIMITER ;

-- ========================================
-- FILE: common_stored_procedures.sql
-- ========================================

-- Query original common.py:
-- SELECT * FROM usuarios;


DELIMITER $$
CREATE PROCEDURE sp_common_obtener_usuarios()
BEGIN
    SELECT *
    FROM usuarios;
END$$
DELIMITER ;

-- ========================================
-- FILE: flights_stored_procedures.sql
-- ========================================

-- Querys originales y SPs de routes/flights.py


DELIMITER $$

-- Original:
-- SELECT aeropuerto_id, nombre, ciudad, provincia, codigo_IATA
-- FROM aeropuertos
-- WHERE nombre LIKE ? OR ciudad LIKE ? OR provincia LIKE ? OR codigo_IATA LIKE ?
-- LIMIT 10;

CREATE PROCEDURE sp_flights_airport_suggestions(IN p_query VARCHAR(255))
BEGIN
    SELECT aeropuerto_id, nombre, ciudad, provincia, codigo_IATA
    FROM aeropuertos
    WHERE nombre LIKE CONCAT('%', p_query, '%')
       OR ciudad LIKE CONCAT('%', p_query, '%')
       OR provincia LIKE CONCAT('%', p_query, '%')
       OR codigo_IATA LIKE CONCAT('%', p_query, '%')
    LIMIT 10;
END$$

-- Original:
-- SELECT ... FROM vuelos ... WHERE DATE(v.fecha_salida) >= ? AND DATE(v.fecha_llegada) <= ?
--   AND v.aeropuerto_origen = ? AND v.aeropuerto_destino = ? AND v.asientos_disponibles >= ?
-- ORDER BY v.fecha_salida;
CREATE PROCEDURE sp_flights_buscar_vuelos(
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_origen_id INT,
    IN p_destino_id INT,
    IN p_pasajeros INT
)
BEGIN
    SELECT
        v.vuelo_id,
        v.codigo_vuelo,
        a_origen.nombre AS origen_nombre,
        a_destino.nombre AS destino_nombre,
        v.fecha_salida,
        v.fecha_llegada,
        v.capacidad_total,
        v.asientos_disponibles,
        v.precio_base
    FROM vuelos v
    JOIN aeropuertos a_origen ON v.aeropuerto_origen = a_origen.aeropuerto_id
    JOIN aeropuertos a_destino ON v.aeropuerto_destino = a_destino.aeropuerto_id
    WHERE DATE(v.fecha_salida) >= p_start_date
      AND DATE(v.fecha_llegada) <= p_end_date
      AND v.aeropuerto_origen = p_origen_id
      AND v.aeropuerto_destino = p_destino_id
      AND v.asientos_disponibles >= p_pasajeros
    ORDER BY v.fecha_salida;
END$$

DELIMITER ;

-- ========================================
-- FILE: payments_stored_procedures.sql
-- ========================================

-- Querys funcionales migradas de routes/payments.py
-- Nota: _ensure_tarjetas_schema mantiene SQL directo por tratarse de DDL/migraciÃ³n de esquema.


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
    JOIN usuarios u ON urv.usuario_id = u.usuario_id
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

-- ========================================
-- FILE: reservations_stored_procedures.sql
-- ========================================

-- Querys originales y SPs de routes/reservations.py


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
-- usuarios
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

-- Compatibilidad hacia atrÃ¡s: suma 1 asiento.
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

-- ========================================
-- FILE: reservation_seats_schema.sql
-- ========================================

-- Esquema para persistir selecciÃ³n de asientos por reserva

CREATE TABLE IF NOT EXISTS reserva_asientos (
    reserva_asiento_id INT AUTO_INCREMENT PRIMARY KEY,
    reserva_id INT NOT NULL,
    vuelo_id INT NOT NULL,
    asiento_codigo VARCHAR(8) NOT NULL,
    numero_pasajero INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reserva_asientos_reserva
        FOREIGN KEY (reserva_id) REFERENCES usuario_reservas_vuelo(reserva_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_reserva_asientos_vuelo
        FOREIGN KEY (vuelo_id) REFERENCES vuelos(vuelo_id)
        ON DELETE CASCADE,
    CONSTRAINT uk_reserva_asiento_unico_vuelo UNIQUE (vuelo_id, asiento_codigo),
    CONSTRAINT uk_reserva_asiento_unico_reserva_pasajero UNIQUE (reserva_id, numero_pasajero),
    INDEX idx_reserva_asientos_reserva_id (reserva_id),
    INDEX idx_reserva_asientos_vuelo_id (vuelo_id)
);

-- ========================================
-- FILE: secondary_passengers_schema.sql
-- ========================================

-- Esquema para pasajeros secundarios de una reserva de vuelo
-- Ejecutar en la misma BD donde existe usuario_reservas_vuelo.

CREATE TABLE IF NOT EXISTS usuario_secundario (
    usuario_secundario_id INT AUTO_INCREMENT PRIMARY KEY,
    apellido VARCHAR(100) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    telefono VARCHAR(30) NOT NULL,
    dni VARCHAR(20) NOT NULL,
    edad INT NOT NULL,
    email VARCHAR(150) NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_usuario_secundario_dni (dni)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS usuario_secundario_reserva_vuelo (
    id_usuario_secundario_reserva INT AUTO_INCREMENT PRIMARY KEY,
    reserva_id INT NOT NULL,
    usuario_secundario_id INT NOT NULL,
    fecha_vinculacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usrv_reserva
        FOREIGN KEY (reserva_id)
        REFERENCES usuario_reservas_vuelo (reserva_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_usrv_usuario_secundario
        FOREIGN KEY (usuario_secundario_id)
        REFERENCES usuario_secundario (usuario_secundario_id)
        ON DELETE RESTRICT,
    UNIQUE KEY uk_usrv_reserva_secundario (reserva_id, usuario_secundario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Si en tu base la tabla principal se llama usuario_reserva_vuelo (singular),
-- reemplaza usuario_reservas_vuelo por ese nombre en la FK fk_usrv_reserva.


