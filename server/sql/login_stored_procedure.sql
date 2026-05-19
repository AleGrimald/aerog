-- Consulta actual de login (original):
-- SELECT usuario_id, nombre, apellido, email, telefono, direccion, fecha_nacimiento, fecha_registro, contraseña_hash, activo
-- FROM Usuarios
-- WHERE email = ? OR LOWER(nombre) = ?
-- LIMIT 1;

-- Procedimiento almacenado para reemplazar la consulta de login.
-- Ejecutar este script en MySQL.

DROP PROCEDURE IF EXISTS sp_login_usuario;

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
        fecha_nacimiento,
        fecha_registro,
        contraseña_hash,
        activo
    FROM Usuarios
    WHERE email = p_identificador
       OR LOWER(nombre) = p_identificador
    LIMIT 1;
END$$
DELIMITER ;
