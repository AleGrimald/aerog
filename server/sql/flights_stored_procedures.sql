-- Querys originales y SPs de routes/flights.py

DROP PROCEDURE IF EXISTS sp_flights_airport_suggestions;
DROP PROCEDURE IF EXISTS sp_flights_buscar_vuelos;

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
