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
