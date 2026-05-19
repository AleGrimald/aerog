-- Query original common.py:
-- SELECT * FROM Usuarios;

DROP PROCEDURE IF EXISTS sp_common_obtener_usuarios;

DELIMITER $$
CREATE PROCEDURE sp_common_obtener_usuarios()
BEGIN
    SELECT *
    FROM Usuarios;
END$$
DELIMITER ;
