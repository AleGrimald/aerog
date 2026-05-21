-- Esquema para persistir selección de asientos por reserva

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
