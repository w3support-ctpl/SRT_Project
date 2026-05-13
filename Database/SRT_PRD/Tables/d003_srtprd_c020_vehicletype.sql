-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c020_vehicletype`;
CREATE TABLE `c020_vehicletype` (
  `VehicleType_Id` varchar(10) NOT NULL,
  `VehicleType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`VehicleType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c020_vehicletype` VALUES('C020001','Truck',1,0);
INSERT INTO `c020_vehicletype` VALUES('C020002','Tanker',1,0);

-- Dump completed on 2026-05-12 17:14:39
