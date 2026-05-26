-- Todos los Stored Procedures relacionados con la tabla usuarios
-- Tabla: usuarios (en minúscula)

-- ========================================
-- PROCEDIMIENTOS DE AUTENTICACIÓN
-- ========================================

DROP PROCEDURE IF EXISTS sp_login_usuario;
DROP PROCEDURE IF EXISTS sp_auth_buscar_usuario_por_email;
DROP PROCEDURE IF EXISTS sp_auth_registrar_usuario;
DROP PROCEDURE IF EXISTS sp_auth_activar_usuario;
DROP PROCEDURE IF EXISTS sp_auth_actualizar_perfil;

DELIMITER $$

-- Login de usuario
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
    FROM usuarios
    WHERE email = p_identificador
       OR LOWER(nombre) = p_identificador
    LIMIT 1;
END$$

-- Buscar usuario por email (verificar si existe)
CREATE PROCEDURE sp_auth_buscar_usuario_por_email(IN p_email VARCHAR(255))
BEGIN
    SELECT usuario_id, activo
    FROM usuarios
    WHERE email = p_email
    LIMIT 1;
END$$

-- Registrar nuevo usuario
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
    INSERT INTO usuarios (nombre, apellido, email, contraseña_hash, telefono, direccion, dni, fecha_nacimiento, fecha_registro, activo)
    VALUES (p_nombre, p_apellido, p_email, p_contrasena_hash, p_telefono, p_direccion, p_dni, p_fecha_nacimiento, p_fecha_registro, 0);

    SELECT LAST_INSERT_ID() AS usuario_id;
END$$

-- Activar usuario (al verificar email)
CREATE PROCEDURE sp_auth_activar_usuario(IN p_usuario_id INT)
BEGIN
    UPDATE usuarios
    SET activo = 1
    WHERE usuario_id = p_usuario_id;
END$$

-- Actualizar perfil del usuario
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

-- ========================================
-- PROCEDIMIENTOS DE ADMINISTRACIÓN
-- ========================================

DROP PROCEDURE IF EXISTS sp_admin_usuarios_listar;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_buscar_por_email;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_crear;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_buscar_por_id;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_email_duplicado;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_dni_duplicado;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_actualizar_con_password;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_actualizar_sin_password;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_obtener_estado;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_desactivar;
DROP PROCEDURE IF EXISTS sp_admin_usuarios_activar;

-- Listar todos los usuarios
CREATE PROCEDURE sp_admin_usuarios_listar()
BEGIN
    SELECT usuario_id, nombre, apellido, email, telefono, direccion, dni, fecha_nacimiento, fecha_registro, activo
    FROM usuarios
    ORDER BY fecha_registro DESC;
END$$

-- Buscar usuario por email
CREATE PROCEDURE sp_admin_usuarios_buscar_por_email(IN p_email VARCHAR(255))
BEGIN
    SELECT usuario_id
    FROM usuarios
    WHERE email = p_email
    LIMIT 1;
END$$

-- Crear nuevo usuario (por admin)
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
    INSERT INTO usuarios (nombre, apellido, email, contraseña_hash, telefono, direccion, dni, fecha_nacimiento, fecha_registro, activo)
    VALUES (p_nombre, p_apellido, p_email, p_contrasena_hash, p_telefono, p_direccion, p_dni, p_fecha_nacimiento, p_fecha_registro, 1);

    SELECT LAST_INSERT_ID() AS usuario_id;
END$$

-- Buscar usuario por ID
CREATE PROCEDURE sp_admin_usuarios_buscar_por_id(IN p_usuario_id INT)
BEGIN
    SELECT usuario_id
    FROM usuarios
    WHERE usuario_id = p_usuario_id
    LIMIT 1;
END$$

-- Verificar email duplicado (excluyendo el usuario actual)
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

-- Verificar DNI duplicado (excluyendo el usuario actual)
CREATE PROCEDURE sp_admin_usuarios_dni_duplicado(
    IN p_dni VARCHAR(9),
    IN p_usuario_id INT
)
BEGIN
    SELECT usuario_id
    FROM usuarios
    WHERE dni = p_dni
      AND usuario_id <> p_usuario_id
    LIMIT 1;
END$$

-- Actualizar usuario con cambio de contraseña
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
        contraseña_hash = p_contrasena_hash
    WHERE usuario_id = p_usuario_id;
END$$

-- Actualizar usuario sin cambio de contraseña
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

-- Obtener estado del usuario
CREATE PROCEDURE sp_admin_usuarios_obtener_estado(IN p_usuario_id INT)
BEGIN
    SELECT usuario_id, activo
    FROM usuarios
    WHERE usuario_id = p_usuario_id
    LIMIT 1;
END$$

-- Desactivar usuario (soft delete)
CREATE PROCEDURE sp_admin_usuarios_desactivar(IN p_usuario_id INT)
BEGIN
    UPDATE usuarios
    SET activo = 0
    WHERE usuario_id = p_usuario_id;
END$$

-- Activar usuario (reactivar)
CREATE PROCEDURE sp_admin_usuarios_activar(IN p_usuario_id INT)
BEGIN
    UPDATE usuarios
    SET activo = 1
    WHERE usuario_id = p_usuario_id;
END$$

DELIMITER ;
