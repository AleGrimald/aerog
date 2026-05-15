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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cancelaciones_reservas`
--

LOCK TABLES `cancelaciones_reservas` WRITE;
/*!40000 ALTER TABLE `cancelaciones_reservas` DISABLE KEYS */;
INSERT INTO `cancelaciones_reservas` VALUES (1,3,1,1,'2026-05-15 13:02:11'),(2,1,1,1,'2026-05-15 13:02:13');
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pagos`
--

LOCK TABLES `pagos` WRITE;
/*!40000 ALTER TABLE `pagos` DISABLE KEYS */;
INSERT INTO `pagos` VALUES (13,31,35000.00,'2026-05-15 12:33:11','Debito','Confirmado',0.00,7,1);
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
  `numero` varchar(16) NOT NULL,
  `titular` varchar(100) NOT NULL,
  `vencimiento` varchar(5) NOT NULL,
  `cvv` varchar(4) NOT NULL,
  `fecha_agregada` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_tarjeta` varchar(45) DEFAULT NULL,
  `fabricante` varchar(45) DEFAULT NULL,
  `entidad_bancaria` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`tarjeta_id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `tarjetas_usuario_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tarjetas_usuario`
--

LOCK TABLES `tarjetas_usuario` WRITE;
/*!40000 ALTER TABLE `tarjetas_usuario` DISABLE KEYS */;
INSERT INTO `tarjetas_usuario` VALUES (6,4,'4547991234567890','Oscar Alejandro Grimaldi','12/27','223','2026-05-14 11:42:20','Credito','Visa','Canadian Imperial Bank Of Commerce'),(7,4,'4541111111111111','Oscar Alejandro Grimaldi','20/28','111','2026-05-14 12:06:52','Debito','Visa','Macro');
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
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_reservas_vuelo`
--

LOCK TABLES `usuario_reservas_vuelo` WRITE;
/*!40000 ALTER TABLE `usuario_reservas_vuelo` DISABLE KEYS */;
INSERT INTO `usuario_reservas_vuelo` VALUES (2,2,2,'2026-05-11 14:21:38','pendiente',5),(4,2,2,'2026-05-11 14:21:47','pendiente',110),(9,7,11,'2026-05-13 13:34:31','confirmada',33),(31,4,1,'2026-05-15 12:32:51','confirmada',NULL);
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
  PRIMARY KEY (`usuario_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'admin','admin','admin@gmail.com','$2b$12$mEvsW6GT33.Y7z/iT.vF/u9nZUjx5a351dy34iSuymcclUI5gu3MO','0000000000','nada','1991-11-06','2000-01-01 14:20:55'),(2,'María','Gómez','maria.gomez@example.com','hash456','3814000002','Calle San Martín 456','1985-09-20','2026-05-11 14:20:55'),(3,'Carlos','López','carlos.lopez@example.com','hash789','3814000003','Belgrano 789','1992-03-15','2026-05-11 14:20:55'),(4,'Oscar Alejandro','Grimaldi','ale@g.com','$2b$12$mEvsW6GT33.Y7z/iT.vF/u9nZUjx5a351dy34iSuymcclUI5gu3MO','3816699521','B° Lomas de Tafi Sec 8 Lt 6 M6 C5','2026-05-02','2026-05-12 11:49:42'),(5,'Cynthia','Ortizq','cyn@o.com','$2b$12$tMV0NsI/6TuRPe3oMrgmHODzDCSip4WHGloISbx0CoZFMLei9Zdvu','3816655985','Av Belgrano 3423','1989-08-21','2026-05-13 11:32:30'),(6,'qweqwe','qweqweqweqwe','qwe@qwe.com','$2b$12$N3rmJ0OUrK7vk3qn2W4.5OdZngyD7oAaeMXAzeQZYKlMRcPHimIdG','13413413','av sarmiento 3423','1980-12-12','2026-05-13 11:37:44'),(7,'Cynthia','Ortiz','cyn2@o.com','$2b$12$Gzf3eF8C795dTF3zt1.WGeBqoRtZLQJPtj2.BsBdyalGQ1f0Zdz.y','798654321','av sarmiento 3423','1990-08-21','2026-05-13 11:47:40'),(8,'gfhjfhfg','fghfghfghfgh','fhjfhje@g.com','$2b$12$UYG03JTMT/mlC7qLWM8qiOEsegMJh9GnRy97TZ.181rGf61zmPLAe','3815689952','av sarmiento 3423','1990-07-06','2026-05-13 11:51:34');
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vuelos`
--

LOCK TABLES `vuelos` WRITE;
/*!40000 ALTER TABLE `vuelos` DISABLE KEYS */;
INSERT INTO `vuelos` VALUES (1,'AR1234',3,1,'2026-06-01 09:00:00','2026-07-10 14:00:00',180,35000.00,21),(2,'AR5678',1,4,'2026-06-02 00:00:00','2026-06-02 00:00:00',150,28000.00,5),(3,'AR9012',4,2,'2026-06-03 00:00:00','2026-06-03 00:00:00',200,25000.00,53),(5,'AR1236',1,2,'2026-06-01 00:00:00','2026-06-01 00:00:00',180,35000.00,31),(10,'AR5688',3,1,'2026-06-05 10:00:00','2026-07-08 15:00:00',200,42000.00,0),(11,'AR9812',5,3,'2026-06-10 11:00:00','2026-07-09 16:00:00',150,31000.00,2),(12,'AR3486',3,7,'2026-06-10 12:00:00','2026-07-07 17:00:00',220,46000.00,186),(13,'AR7880',3,1,'2026-06-20 13:00:00','2026-07-05 08:00:00',170,38000.00,125),(15,'AR5008',3,5,'2026-06-05 00:00:00','2026-07-08 00:00:00',200,420000.00,196),(17,'AR5018',3,14,'2026-06-15 00:00:00','2026-08-08 00:00:00',200,420000.00,125),(18,'AR5028',3,13,'2026-06-15 00:00:00','2026-08-08 00:00:00',200,420000.00,200),(19,'AR5038',3,13,'2026-06-15 00:00:00','2026-08-08 00:00:00',200,420000.00,135),(20,'AR508',3,14,'2026-06-01 09:00:00','2026-07-01 12:00:00',200,420000.00,141);
/*!40000 ALTER TABLE `vuelos` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-15 11:30:31
