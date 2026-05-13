-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c028_drivertype`;
CREATE TABLE `c028_drivertype` (
  `DriverType_Id` varchar(10) NOT NULL,
  `DriverType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`DriverType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c028_drivertype` VALUES('C028001','Own driver',1,0);
INSERT INTO `c028_drivertype` VALUES('C028002','Driver of contract vehicle',1,0);

-- Dump completed on 2026-05-12 17:14:39
