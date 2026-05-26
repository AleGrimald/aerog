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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cancelaciones_reservas`
--

LOCK TABLES `cancelaciones_reservas` WRITE;
/*!40000 ALTER TABLE `cancelaciones_reservas` DISABLE KEYS */;
INSERT INTO `cancelaciones_reservas` VALUES (1,3,1,1,'2026-05-15 13:02:11'),(2,1,1,1,'2026-05-15 13:02:13'),(3,33,21,21,'2026-05-18 14:28:23'),(4,34,21,21,'2026-05-18 14:34:51'),(5,35,21,21,'2026-05-18 14:37:40'),(6,36,21,21,'2026-05-18 14:42:44'),(7,37,21,21,'2026-05-18 15:24:10'),(8,38,21,21,'2026-05-19 11:55:54'),(9,39,1,21,'2026-05-19 11:56:17'),(10,42,21,24,'2026-05-20 11:55:33'),(11,41,21,21,'2026-05-20 12:53:39'),(12,40,1,21,'2026-05-20 12:54:03'),(13,46,1,21,'2026-05-21 13:11:48'),(14,47,1,21,'2026-05-21 13:11:51'),(15,48,1,21,'2026-05-21 13:24:24'),(16,50,1,21,'2026-05-21 13:24:26'),(17,49,1,21,'2026-05-21 13:24:28'),(18,55,1,21,'2026-05-21 13:44:15'),(19,54,1,21,'2026-05-21 14:59:06'),(20,53,1,21,'2026-05-21 14:59:07'),(21,52,1,21,'2026-05-21 14:59:11'),(22,51,1,21,'2026-05-21 14:59:13'),(23,57,1,21,'2026-05-21 14:59:15'),(24,56,1,21,'2026-05-21 14:59:17'),(25,58,1,21,'2026-05-21 14:59:19');
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
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pagos`
--

LOCK TABLES `pagos` WRITE;
/*!40000 ALTER TABLE `pagos` DISABLE KEYS */;
INSERT INTO `pagos` VALUES (26,43,1.25,'2026-05-20 11:57:02','Credito','Confirmado',0.25,11,6),(27,44,33750.00,'2026-05-20 11:57:52','Credito','Confirmado',0.25,11,6),(28,45,63906.50,'2026-05-20 12:00:13','Credito','Confirmado',0.55,11,12),(42,59,54250.00,'2026-05-21 15:00:52','Credito','Confirmado',0.55,9,12),(43,60,42000.00,'2026-05-21 15:17:46','Debito','Confirmado',0.00,8,1),(44,61,46200.00,'2026-05-21 15:23:00','Credito','Confirmado',0.10,12,3),(45,62,43750.00,'2026-05-21 15:28:15','Credito','Confirmado',0.25,12,6),(46,63,1.25,'2026-05-21 15:39:47','Credito','Confirmado',0.25,12,6);
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
-- Table structure for table `reserva_asientos`
--

DROP TABLE IF EXISTS `reserva_asientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reserva_asientos` (
  `reserva_asiento_id` int NOT NULL AUTO_INCREMENT,
  `reserva_id` int NOT NULL,
  `vuelo_id` int NOT NULL,
  `asiento_codigo` varchar(8) NOT NULL,
  `numero_pasajero` int NOT NULL,
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reserva_asiento_id`),
  UNIQUE KEY `uk_reserva_asiento_unico_vuelo` (`vuelo_id`,`asiento_codigo`),
  UNIQUE KEY `uk_reserva_asiento_unico_reserva_pasajero` (`reserva_id`,`numero_pasajero`),
  KEY `idx_reserva_asientos_reserva_id` (`reserva_id`),
  KEY `idx_reserva_asientos_vuelo_id` (`vuelo_id`),
  CONSTRAINT `fk_reserva_asientos_reserva` FOREIGN KEY (`reserva_id`) REFERENCES `usuario_reservas_vuelo` (`reserva_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reserva_asientos_vuelo` FOREIGN KEY (`vuelo_id`) REFERENCES `vuelos` (`vuelo_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reserva_asientos`
--

LOCK TABLES `reserva_asientos` WRITE;
/*!40000 ALTER TABLE `reserva_asientos` DISABLE KEYS */;
INSERT INTO `reserva_asientos` VALUES (3,59,1,'C1',1,'2026-05-21 15:00:49'),(4,59,1,'D1',2,'2026-05-21 15:00:49'),(5,60,15,'D2',1,'2026-05-21 15:17:43'),(6,61,15,'C2',1,'2026-05-21 15:21:59'),(7,62,1,'D3',1,'2026-05-21 15:28:14'),(8,63,21,'D2',1,'2026-05-21 15:39:47'),(9,63,21,'C3',2,'2026-05-21 15:39:47');
/*!40000 ALTER TABLE `reserva_asientos` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tarjetas_usuario`
--

LOCK TABLES `tarjetas_usuario` WRITE;
/*!40000 ALTER TABLE `tarjetas_usuario` DISABLE KEYS */;
INSERT INTO `tarjetas_usuario` VALUES (8,21,'$2b$12$CGgNT8y3hhHiAeAY8xXm4.jo/ASZW2rVydz.lBxDXedVXAnCCp73G','1111','Grimaldi Oscar Alejandro','06/27','2026-05-18 14:20:51','Debito','Visa','Conotoxia Sp. Z O.O'),(9,21,'$2b$12$.koffLvJvUyQQ9rQmvVGguO0x2F51V8arxiT5CWovupYYQABlavW6','0001','Grimaldi O Alejandro','05/28','2026-05-18 14:24:32','Credito','No identificado','Naranja X'),(11,24,'$2b$12$BIKH31J7PpvHDhdnNydZWediYr.Ii591XmSpz8Y8Prqptx2.pYE2m','4444','Grimaldi Oscar Alejandro','06/27','2026-05-20 11:52:02','Credito','Visa','No identificado'),(12,25,'$2b$12$6E6Mb1EyfuUZOScHPfm1b.lqn1R85wbBUDvpQ6odO2oDozpCbuZfG','6666','M Arroyo','06/27','2026-05-21 15:22:40','Credito','Visa','No identificado');
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
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_reservas_vuelo`
--

LOCK TABLES `usuario_reservas_vuelo` WRITE;
/*!40000 ALTER TABLE `usuario_reservas_vuelo` DISABLE KEYS */;
INSERT INTO `usuario_reservas_vuelo` VALUES (43,24,21,'2026-05-20 11:56:59','confirmada',NULL),(44,24,18,'2026-05-20 11:57:35','confirmada',NULL),(45,24,19,'2026-05-20 12:00:11','confirmada',NULL),(59,21,1,'2026-05-21 15:00:49','confirmada',NULL),(60,21,15,'2026-05-21 15:17:43','confirmada',NULL),(61,25,15,'2026-05-21 15:21:59','confirmada',NULL),(62,25,1,'2026-05-21 15:28:14','confirmada',NULL),(63,25,21,'2026-05-21 15:39:47','confirmada',NULL);
/*!40000 ALTER TABLE `usuario_reservas_vuelo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_secundario`
--

DROP TABLE IF EXISTS `usuario_secundario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_secundario` (
  `usuario_secundario_id` int NOT NULL AUTO_INCREMENT,
  `apellido` varchar(100) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `direccion` varchar(255) NOT NULL,
  `telefono` varchar(30) NOT NULL,
  `dni` varchar(20) NOT NULL,
  `edad` int NOT NULL,
  `email` varchar(150) NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`usuario_secundario_id`),
  UNIQUE KEY `uk_usuario_secundario_dni` (`dni`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_secundario`
--

LOCK TABLES `usuario_secundario` WRITE;
/*!40000 ALTER TABLE `usuario_secundario` DISABLE KEYS */;
INSERT INTO `usuario_secundario` VALUES (1,'Grimaldi','Oscar Reinaldo','Av Nada 1111','3816666600','35478878',35,'grimaldialejandro5@gmail.com','2026-05-21 10:02:29'),(2,'Grimaldi','Oscar Reinaldo','Av Nada 1111','3816666602','35000252',36,'grim.o@gmail.com','2026-05-21 10:12:56'),(3,'Grimaldi','Oscar Reinaldo','Av Nada 1111','3816660000','35000200',36,'grimaldidro5@gmail.com','2026-05-21 10:30:23'),(4,'Grim','Oscar','Av Nada 1111','3816666657','23233433',23,'grimaldialejandro5@gmail.com','2026-05-21 10:37:34'),(5,'Grim','Oscar','Av Nada 1111','3816666657','12222333',23,'grimaldialejandro5@gmail.com','2026-05-21 10:37:34'),(6,'Grim','Oscar','Av Nada 1111','3816666657','44555666',43,'grimaldialejandro5@gmail.com','2026-05-21 10:37:34'),(7,'Grim','Oscar','Av Nada 1111','3816666657','34111222',43,'grimaldialejandro5@gmail.com','2026-05-21 10:37:34'),(8,'Grim','Oscar','Av Nada 1111','3816666657','11111111',11,'grimaldialejandro5@gmail.com','2026-05-21 10:37:34'),(9,'Grimaldi','Oscar Reinaldo','Av Nada 1111','3816660107','12000252',72,'grimldiadro5@gmail.com','2026-05-21 12:00:49'),(10,'Grimaldi','Oscar Alejandro','B Lomas de Tafi - Yerbal 300','3816699521','12356565',72,'ale@g.com','2026-05-21 12:39:47');
/*!40000 ALTER TABLE `usuario_secundario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_secundario_reserva_vuelo`
--

DROP TABLE IF EXISTS `usuario_secundario_reserva_vuelo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_secundario_reserva_vuelo` (
  `id_usuario_secundario_reserva` int NOT NULL AUTO_INCREMENT,
  `reserva_id` int NOT NULL,
  `usuario_secundario_id` int NOT NULL,
  `fecha_vinculacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario_secundario_reserva`),
  UNIQUE KEY `uk_usrv_reserva_secundario` (`reserva_id`,`usuario_secundario_id`),
  KEY `fk_usrv_usuario_secundario` (`usuario_secundario_id`),
  CONSTRAINT `fk_usrv_reserva` FOREIGN KEY (`reserva_id`) REFERENCES `usuario_reservas_vuelo` (`reserva_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_usrv_usuario_secundario` FOREIGN KEY (`usuario_secundario_id`) REFERENCES `usuario_secundario` (`usuario_secundario_id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_secundario_reserva_vuelo`
--

LOCK TABLES `usuario_secundario_reserva_vuelo` WRITE;
/*!40000 ALTER TABLE `usuario_secundario_reserva_vuelo` DISABLE KEYS */;
INSERT INTO `usuario_secundario_reserva_vuelo` VALUES (9,59,9,'2026-05-21 12:00:49'),(10,63,10,'2026-05-21 12:39:47');
/*!40000 ALTER TABLE `usuario_secundario_reserva_vuelo` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'admin','admin','admin@gmail.com','$2b$12$mEvsW6GT33.Y7z/iT.vF/u9nZUjx5a351dy34iSuymcclUI5gu3MO','0000000000','nada','1991-11-06','2000-01-01 14:20:55',1),(21,'Oscar Alejandro','Grimaldi','ale@g.com','$2b$12$8SVk5wVVONuO/LVz6AAdzOLo.bKZt0IMBwKSQkwAubCC9VJaYQrqm','3816699521','B Lomas de Tafi - Yerbal 300','1991-11-06','2026-05-18 13:09:46',1),(24,'Oscar Alejandro','Grimaldi','grimaldialejandro5@gmail.com','$2b$12$6sjaqdY.c64iLVo8cXaPduZ187vPb8V04/kruw2Tjw8NZk7ukH3OC','3816666657','Av Nada 1111','1990-07-06','2026-05-20 11:50:42',1),(25,'Maria','Arroyo','mar@a.com','$2b$12$8SVk5wVVONuO/LVz6AAdzOLo.bKZt0IMBwKSQkwAubCC9VJaYQrqm','34568956','B Lomas de Tafi - Yerbal 300','1991-11-06','2026-05-18 13:09:46',1);
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
INSERT INTO `vuelos` VALUES (1,'AR1234',3,1,'2026-06-01 09:00:00','2026-07-10 14:00:00',48,35000.00,8),(2,'AR5678',1,4,'2026-06-02 00:00:00','2026-06-02 00:00:00',48,28000.00,15),(3,'AR9012',4,2,'2026-06-03 00:00:00','2026-06-03 00:00:00',48,25000.00,20),(5,'AR1236',1,2,'2026-06-01 00:00:00','2026-06-01 00:00:00',48,35000.00,3),(10,'AR5688',3,1,'2026-06-05 10:00:00','2026-07-08 15:00:00',48,42000.00,5),(11,'AR9812',5,3,'2026-06-10 11:00:00','2026-07-09 16:00:00',48,31000.00,2),(12,'AR3486',3,7,'2026-06-10 12:00:00','2026-07-07 17:00:00',48,46000.00,18),(13,'AR7880',4,2,'2026-06-20 13:00:00','2026-07-05 08:00:00',48,38000.00,12),(15,'AR5008',3,5,'2026-06-05 00:00:00','2026-07-08 00:00:00',48,42000.00,17),(17,'AR5018',3,14,'2026-06-15 00:00:00','2026-08-08 00:00:00',48,38200.00,12),(18,'AR5028',3,13,'2026-06-15 00:00:00','2026-08-08 00:00:00',48,27000.00,11),(19,'AR5038',3,13,'2026-06-15 00:00:00','2026-08-08 00:00:00',48,41230.00,7),(20,'AR508',3,14,'2026-06-01 09:00:00','2026-07-01 12:00:00',48,42000.00,14),(21,'AR101',3,13,'2026-05-28 11:26:00','2026-05-23 11:26:00',48,1.00,21);
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

-- Dump completed on 2026-05-22 11:45:22
