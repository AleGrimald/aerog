-- Querys migradas de routes/admin.py

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
    FROM Usuarios
    ORDER BY fecha_registro DESC;
END$$

CREATE PROCEDURE sp_admin_usuarios_buscar_por_email(IN p_email VARCHAR(255))
BEGIN
    SELECT usuario_id
    FROM Usuarios
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
    INSERT INTO Usuarios (nombre, apellido, email, contraseña_hash, telefono, direccion, dni, fecha_nacimiento, fecha_registro, activo)
    VALUES (p_nombre, p_apellido, p_email, p_contrasena_hash, p_telefono, p_direccion, p_dni, p_fecha_nacimiento, p_fecha_registro, 1);

    SELECT LAST_INSERT_ID() AS usuario_id;
END$$

CREATE PROCEDURE sp_admin_usuarios_buscar_por_id(IN p_usuario_id INT)
BEGIN
    SELECT usuario_id
    FROM Usuarios
    WHERE usuario_id = p_usuario_id
    LIMIT 1;
END$$

CREATE PROCEDURE sp_admin_usuarios_email_duplicado(
    IN p_email VARCHAR(255),
    IN p_usuario_id INT
)
BEGIN
    SELECT usuario_id
    FROM Usuarios
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
    UPDATE Usuarios
    SET nombre = p_nombre,
        apellido = p_apellido,
        email = p_email,
        telefono = p_telefono,
        direccion = p_direccion,
        dni = p_dni,
        fecha_nacimiento = p_fecha_nacimiento,
        contraseña_hash = p_contrasena_hash
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
    UPDATE Usuarios
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
    FROM Usuarios
    WHERE usuario_id = p_usuario_id
    LIMIT 1;
END$$

CREATE PROCEDURE sp_admin_usuarios_desactivar(IN p_usuario_id INT)
BEGIN
    UPDATE Usuarios
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
