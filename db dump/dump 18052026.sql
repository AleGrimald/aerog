-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: pasajes
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aeropuertos`
--

DROP TABLE IF EXISTS `aeropuertos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aeropuertos` (
  `aeropuerto_id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `ciudad` varchar(100) NOT NULL,
  `pais` varchar(100) NOT NULL,
  `codigo_IATA` char(3) NOT NULL,
  `provincia` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`aeropuerto_id`),
  UNIQUE KEY `codigo_IATA` (`codigo_IATA`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aeropuertos`
--

LOCK TABLES `aeropuertos` WRITE;
/*!40000 ALTER TABLE `aeropuertos` DISABLE KEYS */;
INSERT INTO `aeropuertos` VALUES (1,'Aeropuerto Internacional Ezeiza','Buenos Aires','Argentina','EZE','Buenos Aires'),(2,'Aeropuerto Jorge Newbery','Buenos Aires','Argentina','AEP','Buenos Aires'),(3,'Aeropuerto Internacional de Tucumán','San Miguel de Tucumán','Argentina','TUC','Tucuman'),(4,'Aeropuerto Internacional de Córdoba','Córdoba','Argentina','COR','Cordoba'),(5,'Aeropuerto Internacional de Mendoza','Mendoza','Argentina','MDZ','Mendoza'),(6,'Aeropuerto Internacional de Rosario','Rosario','Argentina','ROS','Santa Fe'),(7,'Aeropuerto Internacional de Salta','Salta','Argentina','SLA','Salta'),(8,'Aeropuerto Internacional de Bariloche','San Carlos de Bariloche','Argentina','BRC','Rio Negro'),(9,'Aeropuerto Internacional de Neuquén','Neuquén','Argentina','NQN','Neuquen'),(10,'Aeropuerto Internacional de Iguazú','Puerto Iguazú','Argentina','IGR','Misiones'),(11,'Aeropuerto Internacional de Comodoro Rivadavia','Comodoro Rivadavia','Argentina','CRD','Santa Cruz'),(12,'Aeropuerto Internacional de Río Gallegos','Río Gallegos','Argentina','RGL','Santa Cruz'),(13,'Aeropuerto Internacional de Ushuaia','Ushuaia','Argentina','USH','Tierra del Fuego'),(14,'Aeropuerto Internacional de Jujuy','San Salvador de Jujuy','Argentina','JUJ','Jujuy');
/*!40000 ALTER TABLE `aeropuertos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cancelaciones_reservas`
--

DROP TABLE IF EXISTS `cancelaciones_reservas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cancelaciones_reservas` (
  `cancelacion_id` int NOT NULL AUTO_INCREMENT,
  `reserva_id` int NOT NULL,
  `vuelo_id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `fecha_cancelacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`cancelacion_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cancelaciones_reservas`
--

LOCK TABLES `cancelaciones_reservas` WRITE;
/*!40000 ALTER TABLE `cancelaciones_reservas` DISABLE KEYS */;
INSERT INTO `cancelaciones_reservas` VALUES (1,3,1,1,'2026-05-15 13:02:11'),(2,1,1,1,'2026-05-15 13:02:13'),(3,33,21,21,'2026-05-18 14:28:23'),(4,34,21,21,'2026-05-18 14:34:51'),(5,35,21,21,'2026-05-18 14:37:40'),(6,36,21,21,'2026-05-18 14:42:44'),(7,37,21,21,'2026-05-18 15:24:10');
/*!40000 ALTER TABLE `cancelaciones_reservas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pagos`
--

DROP TABLE IF EXISTS `pagos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pagos` (
  `pago_id` int NOT NULL AUTO_INCREMENT,
  `reserva_id` int NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha_pago` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `metodo_pago` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `estado_pago` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `interes_aplicado` decimal(4,2) NOT NULL,
  `tarjeta_id` int DEFAULT NULL,
  `cantidad_cuotas` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`pago_id`),
  KEY `reserva_id` (`reserva_id`),
  CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`reserva_id`) REFERENCES `usuario_reservas_vuelo` (`reserva_id`),
  CONSTRAINT `pagos_chk_1` CHECK ((`monto` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pagos`
--

LOCK TABLES `pagos` WRITE;
/*!40000 ALTER TABLE `pagos` DISABLE KEYS */;
INSERT INTO `pagos` VALUES (20,38,1.55,'2026-05-18 15:24:03','Credito','Confirmado',0.55,9,12);
/*!40000 ALTER TABLE `pagos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pasajes`
--

DROP TABLE IF EXISTS `pasajes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pasajes` (
  `pasaje_id` int NOT NULL AUTO_INCREMENT,
  `reserva_id` int NOT NULL,
  `asiento` varchar(5) NOT NULL,
  `precio_final` decimal(10,2) NOT NULL,
  PRIMARY KEY (`pasaje_id`),
  KEY `reserva_id` (`reserva_id`),
  CONSTRAINT `pasajes_ibfk_1` FOREIGN KEY (`reserva_id`) REFERENCES `usuario_reservas_vuelo` (`reserva_id`),
  CONSTRAINT `pasajes_chk_1` CHECK ((`precio_final` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pasajes`
--

LOCK TABLES `pasajes` WRITE;
/*!40000 ALTER TABLE `pasajes` DISABLE KEYS */;
INSERT INTO `pasajes` VALUES (1,1,'12A',35000.00),(2,1,'12B',35000.00),(3,2,'5C',28000.00);
/*!40000 ALTER TABLE `pasajes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tarjetas_usuario`
--

DROP TABLE IF EXISTS `tarjetas_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tarjetas_usuario` (
  `tarjeta_id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `numero` varchar(255) NOT NULL,
  `ultimos4` varchar(4) DEFAULT NULL,
  `titular` varchar(100) NOT NULL,
  `vencimiento` varchar(10) NOT NULL,
  `fecha_agregada` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_tarjeta` varchar(45) DEFAULT NULL,
  `fabricante` varchar(45) DEFAULT NULL,
  `entidad_bancaria` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`tarjeta_id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `tarjetas_usuario_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tarjetas_usuario`
--

LOCK TABLES `tarjetas_usuario` WRITE;
/*!40000 ALTER TABLE `tarjetas_usuario` DISABLE KEYS */;
INSERT INTO `tarjetas_usuario` VALUES (8,21,'$2b$12$CGgNT8y3hhHiAeAY8xXm4.jo/ASZW2rVydz.lBxDXedVXAnCCp73G','1111','Grimaldi Oscar Alejandro','06/27','2026-05-18 14:20:51','Debito','Visa','Conotoxia Sp. Z O.O'),(9,21,'$2b$12$.koffLvJvUyQQ9rQmvVGguO0x2F51V8arxiT5CWovupYYQABlavW6','0001','Grimaldi O Alejandro','05/28','2026-05-18 14:24:32','Credito','No identificado','Naranja X');
/*!40000 ALTER TABLE `tarjetas_usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_reservas_vuelo`
--

DROP TABLE IF EXISTS `usuario_reservas_vuelo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_reservas_vuelo` (
  `reserva_id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `vuelo_id` int NOT NULL,
  `fecha_reserva` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `numero_asiento` int DEFAULT NULL,
  PRIMARY KEY (`reserva_id`),
  KEY `usuario_id` (`usuario_id`),
  KEY `vuelo_id` (`vuelo_id`),
  CONSTRAINT `usuario_reservas_vuelo_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`),
  CONSTRAINT `usuario_reservas_vuelo_ibfk_2` FOREIGN KEY (`vuelo_id`) REFERENCES `vuelos` (`vuelo_id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_reservas_vuelo`
--

LOCK TABLES `usuario_reservas_vuelo` WRITE;
/*!40000 ALTER TABLE `usuario_reservas_vuelo` DISABLE KEYS */;
INSERT INTO `usuario_reservas_vuelo` VALUES (38,21,21,'2026-05-18 15:24:00','confirmada',NULL);
/*!40000 ALTER TABLE `usuario_reservas_vuelo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `usuario_id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `contraseña_hash` varchar(255) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `fecha_registro` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `activo` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`usuario_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'admin','admin','admin@gmail.com','$2b$12$mEvsW6GT33.Y7z/iT.vF/u9nZUjx5a351dy34iSuymcclUI5gu3MO','0000000000','nada','1991-11-06','2000-01-01 14:20:55',1),(21,'Oscar Alejandro','Grimaldi','ale@g.com','$2b$12$8SVk5wVVONuO/LVz6AAdzOLo.bKZt0IMBwKSQkwAubCC9VJaYQrqm','3816699521','B Lomas de Tafi - Yerbal 300','1991-11-06','2026-05-18 13:09:46',1);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vuelos`
--

DROP TABLE IF EXISTS `vuelos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vuelos` (
  `vuelo_id` int NOT NULL AUTO_INCREMENT,
  `codigo_vuelo` varchar(10) NOT NULL,
  `aeropuerto_origen` int NOT NULL,
  `aeropuerto_destino` int NOT NULL,
  `fecha_salida` datetime NOT NULL,
  `fecha_llegada` datetime NOT NULL,
  `capacidad_total` int NOT NULL,
  `precio_base` decimal(10,2) NOT NULL,
  `asientos_disponibles` int NOT NULL,
  PRIMARY KEY (`vuelo_id`),
  UNIQUE KEY `codigo_vuelo` (`codigo_vuelo`),
  KEY `aeropuerto_origen` (`aeropuerto_origen`),
  KEY `aeropuerto_destino` (`aeropuerto_destino`),
  CONSTRAINT `vuelos_ibfk_1` FOREIGN KEY (`aeropuerto_origen`) REFERENCES `aeropuertos` (`aeropuerto_id`),
  CONSTRAINT `vuelos_ibfk_2` FOREIGN KEY (`aeropuerto_destino`) REFERENCES `aeropuertos` (`aeropuerto_id`),
  CONSTRAINT `vuelos_chk_1` CHECK ((`capacidad_total` > 0)),
  CONSTRAINT `vuelos_chk_2` CHECK ((`precio_base` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vuelos`
--

LOCK TABLES `vuelos` WRITE;
/*!40000 ALTER TABLE `vuelos` DISABLE KEYS */;
INSERT INTO `vuelos` VALUES (1,'AR1234',3,1,'2026-06-01 09:00:00','2026-07-10 14:00:00',180,35000.00,20),(2,'AR5678',1,4,'2026-06-02 00:00:00','2026-06-02 00:00:00',150,28000.00,5),(3,'AR9012',4,2,'2026-06-03 00:00:00','2026-06-03 00:00:00',200,25000.00,53),(5,'AR1236',1,2,'2026-06-01 00:00:00','2026-06-01 00:00:00',180,35000.00,31),(10,'AR5688',3,1,'2026-06-05 10:00:00','2026-07-08 15:00:00',200,42000.00,0),(11,'AR9812',5,3,'2026-06-10 11:00:00','2026-07-09 16:00:00',150,31000.00,2),(12,'AR3486',3,7,'2026-06-10 12:00:00','2026-07-07 17:00:00',220,46000.00,186),(13,'AR7880',3,1,'2026-06-20 13:00:00','2026-07-05 08:00:00',170,38000.00,125),(15,'AR5008',3,5,'2026-06-05 00:00:00','2026-07-08 00:00:00',200,42000.00,196),(17,'AR5018',3,14,'2026-06-15 00:00:00','2026-08-08 00:00:00',200,38200.00,125),(18,'AR5028',3,13,'2026-06-15 00:00:00','2026-08-08 00:00:00',200,27000.00,200),(19,'AR5038',3,13,'2026-06-15 00:00:00','2026-08-08 00:00:00',200,41230.00,135),(20,'AR508',3,14,'2026-06-01 09:00:00','2026-07-01 12:00:00',200,42000.00,141),(21,'AR0101',3,13,'2026-05-18 11:26:00','2026-05-23 11:26:00',55,1.00,54);
/*!40000 ALTER TABLE `vuelos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'pasajes'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_aeropuertos_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_aeropuertos_listar`()
BEGIN
    SELECT aeropuerto_id, nombre, ciudad, provincia, codigo_IATA
    FROM aeropuertos
    ORDER BY provincia, nombre;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_estadisticas_destinos_top` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_estadisticas_destinos_top`()
BEGIN
    SELECT ad.nombre AS destino, ad.provincia AS provincia, COUNT(*) AS cantidad
    FROM usuario_reservas_vuelo urv
    JOIN vuelos v ON urv.vuelo_id = v.vuelo_id
    JOIN aeropuertos ad ON v.aeropuerto_destino = ad.aeropuerto_id
    GROUP BY ad.aeropuerto_id, ad.nombre, ad.provincia
    ORDER BY cantidad DESC
    LIMIT 5;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_estadisticas_recaudacion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_estadisticas_recaudacion`()
BEGIN
    SELECT DATE_FORMAT(fecha_pago, '%Y-%m') AS mes, ROUND(SUM(monto), 2) AS total
    FROM pagos
    WHERE estado_pago = 'Confirmado'
    GROUP BY DATE_FORMAT(fecha_pago, '%Y-%m')
    ORDER BY mes DESC
    LIMIT 12;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_estadisticas_total_cancelaciones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_estadisticas_total_cancelaciones`()
BEGIN
    SELECT COUNT(*) AS total
    FROM cancelaciones_reservas;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_estadisticas_total_reservas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_estadisticas_total_reservas`()
BEGIN
    SELECT COUNT(*) AS total
    FROM usuario_reservas_vuelo;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_reservas_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_reservas_listar`()
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
    JOIN Usuarios u ON urv.usuario_id = u.usuario_id
    JOIN vuelos v ON urv.vuelo_id = v.vuelo_id
    JOIN aeropuertos ao ON v.aeropuerto_origen = ao.aeropuerto_id
    JOIN aeropuertos ad ON v.aeropuerto_destino = ad.aeropuerto_id
    LEFT JOIN pagos p ON urv.reserva_id = p.reserva_id
    ORDER BY urv.fecha_reserva DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_usuarios_actualizar_con_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_usuarios_actualizar_con_password`(
    IN p_usuario_id INT,
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_telefono VARCHAR(50),
    IN p_direccion VARCHAR(255),
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
        fecha_nacimiento = p_fecha_nacimiento,
        contraseña_hash = p_contrasena_hash
    WHERE usuario_id = p_usuario_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_usuarios_actualizar_sin_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_usuarios_actualizar_sin_password`(
    IN p_usuario_id INT,
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_telefono VARCHAR(50),
    IN p_direccion VARCHAR(255),
    IN p_fecha_nacimiento DATE
)
BEGIN
    UPDATE Usuarios
    SET nombre = p_nombre,
        apellido = p_apellido,
        email = p_email,
        telefono = p_telefono,
        direccion = p_direccion,
        fecha_nacimiento = p_fecha_nacimiento
    WHERE usuario_id = p_usuario_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_usuarios_buscar_por_email` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_usuarios_buscar_por_email`(IN p_email VARCHAR(255))
BEGIN
    SELECT usuario_id
    FROM Usuarios
    WHERE email = p_email
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_usuarios_buscar_por_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_usuarios_buscar_por_id`(IN p_usuario_id INT)
BEGIN
    SELECT usuario_id
    FROM Usuarios
    WHERE usuario_id = p_usuario_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_usuarios_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_usuarios_crear`(
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_contrasena_hash TEXT,
    IN p_telefono VARCHAR(50),
    IN p_direccion VARCHAR(255),
    IN p_fecha_nacimiento DATE,
    IN p_fecha_registro DATETIME
)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, email, contraseña_hash, telefono, direccion, fecha_nacimiento, fecha_registro, activo)
    VALUES (p_nombre, p_apellido, p_email, p_contrasena_hash, p_telefono, p_direccion, p_fecha_nacimiento, p_fecha_registro, 1);

    SELECT LAST_INSERT_ID() AS usuario_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_usuarios_desactivar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_usuarios_desactivar`(IN p_usuario_id INT)
BEGIN
    UPDATE Usuarios
    SET activo = 0
    WHERE usuario_id = p_usuario_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_usuarios_email_duplicado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_usuarios_email_duplicado`(
    IN p_email VARCHAR(255),
    IN p_usuario_id INT
)
BEGIN
    SELECT usuario_id
    FROM Usuarios
    WHERE email = p_email
      AND usuario_id <> p_usuario_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_usuarios_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_usuarios_listar`()
BEGIN
    SELECT usuario_id, nombre, apellido, email, telefono, direccion, fecha_nacimiento, fecha_registro, activo
    FROM Usuarios
    ORDER BY fecha_registro DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_usuarios_obtener_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_usuarios_obtener_estado`(IN p_usuario_id INT)
BEGIN
    SELECT usuario_id, activo
    FROM Usuarios
    WHERE usuario_id = p_usuario_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_vuelos_actualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_vuelos_actualizar`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_vuelos_count_reservas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_vuelos_count_reservas`(IN p_vuelo_id INT)
BEGIN
    SELECT COUNT(*) AS total
    FROM usuario_reservas_vuelo
    WHERE vuelo_id = p_vuelo_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_vuelos_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_vuelos_crear`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_vuelos_eliminar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_vuelos_eliminar`(IN p_vuelo_id INT)
BEGIN
    DELETE FROM vuelos
    WHERE vuelo_id = p_vuelo_id;

    SELECT ROW_COUNT() AS affected_rows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_vuelos_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_vuelos_listar`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_auth_activar_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_auth_activar_usuario`(IN p_usuario_id INT)
BEGIN
    UPDATE Usuarios
    SET activo = 1
    WHERE usuario_id = p_usuario_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_auth_actualizar_perfil` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_auth_actualizar_perfil`(
    IN p_usuario_id INT,
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_telefono VARCHAR(50),
    IN p_direccion VARCHAR(255)
)
BEGIN
    UPDATE Usuarios
    SET nombre = p_nombre,
        apellido = p_apellido,
        email = p_email,
        telefono = p_telefono,
        direccion = p_direccion
    WHERE usuario_id = p_usuario_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_auth_buscar_usuario_por_email` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_auth_buscar_usuario_por_email`(IN p_email VARCHAR(255))
BEGIN
    SELECT usuario_id, activo
    FROM Usuarios
    WHERE email = p_email
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_auth_registrar_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_auth_registrar_usuario`(
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_contrasena_hash TEXT,
    IN p_telefono VARCHAR(50),
    IN p_direccion VARCHAR(255),
    IN p_fecha_nacimiento DATE,
    IN p_fecha_registro DATETIME
)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, email, contraseña_hash, telefono, direccion, fecha_nacimiento, fecha_registro, activo)
    VALUES (p_nombre, p_apellido, p_email, p_contrasena_hash, p_telefono, p_direccion, p_fecha_nacimiento, p_fecha_registro, 0);

    SELECT LAST_INSERT_ID() AS usuario_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cards_agregar_tarjeta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cards_agregar_tarjeta`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cards_eliminar_tarjeta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cards_eliminar_tarjeta`(IN p_tarjeta_id INT)
BEGIN
    DELETE FROM tarjetas_usuario
    WHERE tarjeta_id = p_tarjeta_id;

    SELECT ROW_COUNT() AS affected_rows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cards_obtener_tarjetas_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cards_obtener_tarjetas_usuario`(IN p_usuario_id INT)
BEGIN
    SELECT tarjeta_id, titular, ultimos4, tipo_tarjeta, fabricante, entidad_bancaria
    FROM tarjetas_usuario
    WHERE usuario_id = p_usuario_id
    ORDER BY fecha_agregada DESC, tarjeta_id DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_common_obtener_usuarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_common_obtener_usuarios`()
BEGIN
    SELECT *
    FROM Usuarios;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_flights_airport_suggestions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_flights_airport_suggestions`(IN p_query VARCHAR(255))
BEGIN
    SELECT aeropuerto_id, nombre, ciudad, provincia, codigo_IATA
    FROM aeropuertos
    WHERE nombre LIKE CONCAT('%', p_query, '%')
       OR ciudad LIKE CONCAT('%', p_query, '%')
       OR provincia LIKE CONCAT('%', p_query, '%')
       OR codigo_IATA LIKE CONCAT('%', p_query, '%')
    LIMIT 10;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_flights_buscar_vuelos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_flights_buscar_vuelos`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_login_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_usuario`(IN p_identificador VARCHAR(255))
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_payments_actualizar_estado_pago_qr` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_payments_actualizar_estado_pago_qr`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_payments_actualizar_pago_qr` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_payments_actualizar_pago_qr`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_payments_confirmar_pago_qr` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_payments_confirmar_pago_qr`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_payments_confirmar_reserva` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_payments_confirmar_reserva`(IN p_reserva_id INT)
BEGIN
    UPDATE usuario_reservas_vuelo
    SET estado = 'confirmada'
    WHERE reserva_id = p_reserva_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_payments_insertar_pago` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_payments_insertar_pago`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_payments_obtener_estado_reserva` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_payments_obtener_estado_reserva`(IN p_reserva_id INT)
BEGIN
    SELECT reserva_id, estado
    FROM usuario_reservas_vuelo
    WHERE reserva_id = p_reserva_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_payments_obtener_pago_qr_existente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_payments_obtener_pago_qr_existente`(IN p_reserva_id INT)
BEGIN
    SELECT pago_id, estado_pago
    FROM pagos
    WHERE reserva_id = p_reserva_id AND metodo_pago = 'MercadoPago QR'
    ORDER BY pago_id DESC
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_payments_obtener_reserva_para_pago` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_payments_obtener_reserva_para_pago`(IN p_reserva_id INT)
BEGIN
    SELECT urv.vuelo_id, vd.precio_base
    FROM usuario_reservas_vuelo urv
    JOIN vuelos vd ON urv.vuelo_id = vd.vuelo_id
    WHERE urv.reserva_id = p_reserva_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_payments_obtener_reserva_qr` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_payments_obtener_reserva_qr`(IN p_reserva_id INT)
BEGIN
    SELECT urv.reserva_id, urv.estado, vd.precio_base, u.email
    FROM usuario_reservas_vuelo urv
    JOIN vuelos vd ON urv.vuelo_id = vd.vuelo_id
    JOIN Usuarios u ON urv.usuario_id = u.usuario_id
    WHERE urv.reserva_id = p_reserva_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_payments_obtener_tarjeta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_payments_obtener_tarjeta`(IN p_tarjeta_id INT)
BEGIN
    SELECT tarjeta_id
    FROM tarjetas_usuario
    WHERE tarjeta_id = p_tarjeta_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reservations_crear_reserva` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reservations_crear_reserva`(
    IN p_usuario_id INT,
    IN p_vuelo_id INT,
    IN p_fecha_reserva DATETIME,
    IN p_estado VARCHAR(50)
)
BEGIN
    INSERT INTO usuario_reservas_vuelo (usuario_id, vuelo_id, fecha_reserva, estado)
    VALUES (p_usuario_id, p_vuelo_id, p_fecha_reserva, p_estado);

    SELECT LAST_INSERT_ID() AS reserva_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reservations_delete_pago` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reservations_delete_pago`(IN p_reserva_id INT)
BEGIN
    DELETE FROM pagos
    WHERE reserva_id = p_reserva_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reservations_delete_reserva` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reservations_delete_reserva`(IN p_reserva_id INT)
BEGIN
    DELETE FROM usuario_reservas_vuelo
    WHERE reserva_id = p_reserva_id;

    SELECT ROW_COUNT() AS affected_rows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reservations_descontar_asientos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reservations_descontar_asientos`(
    IN p_vuelo_id INT,
    IN p_asientos INT
)
BEGIN
    UPDATE vuelos
    SET asientos_disponibles = asientos_disponibles - p_asientos
    WHERE vuelo_id = p_vuelo_id
      AND asientos_disponibles >= p_asientos;

    SELECT ROW_COUNT() AS affected_rows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reservations_insert_cancelacion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reservations_insert_cancelacion`(
    IN p_reserva_id INT,
    IN p_vuelo_id INT,
    IN p_usuario_id INT
)
BEGIN
    INSERT INTO cancelaciones_reservas (reserva_id, vuelo_id, usuario_id)
    VALUES (p_reserva_id, p_vuelo_id, p_usuario_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reservations_mis_reservas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reservations_mis_reservas`(IN p_usuario_id INT)
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
        RIGHT(tu.numero, 4) AS pago_tarjeta_ultimos4
    FROM usuario_reservas_vuelo urv
    JOIN vuelos vd ON urv.vuelo_id = vd.vuelo_id
    JOIN aeropuertos ao ON vd.aeropuerto_origen = ao.aeropuerto_id
    JOIN aeropuertos ad ON vd.aeropuerto_destino = ad.aeropuerto_id
    JOIN Usuarios u ON urv.usuario_id = u.usuario_id
    LEFT JOIN pagos p ON urv.reserva_id = p.reserva_id
    LEFT JOIN tarjetas_usuario tu ON p.tarjeta_id = tu.tarjeta_id
    WHERE urv.usuario_id = p_usuario_id
    ORDER BY urv.fecha_reserva DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reservations_obtener_reserva` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reservations_obtener_reserva`(IN p_reserva_id INT)
BEGIN
    SELECT vuelo_id, usuario_id
    FROM usuario_reservas_vuelo
    WHERE reserva_id = p_reserva_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reservations_sumar_asiento` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reservations_sumar_asiento`(IN p_vuelo_id INT)
BEGIN
    UPDATE vuelos
    SET asientos_disponibles = asientos_disponibles + 1
    WHERE vuelo_id = p_vuelo_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-18 12:51:40
