-- Querys originales y procedimientos almacenados para routes/auth.py

-- Original login (ya migrada):
-- SELECT usuario_id, nombre, apellido, email, telefono, direccion, dni, fecha_nacimiento, fecha_registro, contraseña_hash, activo
-- FROM Usuarios
-- WHERE email = ? OR LOWER(nombre) = ?
-- LIMIT 1;

DROP PROCEDURE IF EXISTS sp_login_usuario;
DROP PROCEDURE IF EXISTS sp_auth_buscar_usuario_por_email;
DROP PROCEDURE IF EXISTS sp_auth_registrar_usuario;
DROP PROCEDURE IF EXISTS sp_auth_activar_usuario;
DROP PROCEDURE IF EXISTS sp_auth_actualizar_perfil;

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
        contraseña_hash,
        activo
    FROM Usuarios
    WHERE email = p_identificador
       OR LOWER(nombre) = p_identificador
    LIMIT 1;
END$$

-- Original:
-- SELECT usuario_id, activo FROM Usuarios WHERE email = ? LIMIT 1;
CREATE PROCEDURE sp_auth_buscar_usuario_por_email(IN p_email VARCHAR(255))
BEGIN
    SELECT usuario_id, activo
    FROM Usuarios
    WHERE email = p_email
    LIMIT 1;
END$$

-- Original:
-- INSERT INTO Usuarios (nombre, apellido, email, contraseña_hash, telefono, direccion, dni, fecha_nacimiento, fecha_registro, activo)
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
    INSERT INTO Usuarios (nombre, apellido, email, contraseña_hash, telefono, direccion, dni, fecha_nacimiento, fecha_registro, activo)
    VALUES (p_nombre, p_apellido, p_email, p_contrasena_hash, p_telefono, p_direccion, p_dni, p_fecha_nacimiento, p_fecha_registro, 0);

    SELECT LAST_INSERT_ID() AS usuario_id;
END$$

-- Original:
-- UPDATE Usuarios SET activo = 1 WHERE usuario_id = ?;
CREATE PROCEDURE sp_auth_activar_usuario(IN p_usuario_id INT)
BEGIN
    UPDATE Usuarios
    SET activo = 1
    WHERE usuario_id = p_usuario_id;
END$$

-- Original:
-- UPDATE Usuarios
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
    UPDATE Usuarios
    SET nombre = p_nombre,
        apellido = p_apellido,
        email = p_email,
        telefono = p_telefono,
        direccion = p_direccion,
        dni = p_dni
    WHERE usuario_id = p_usuario_id;
END$$

DELIMITER ;
