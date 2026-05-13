-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c023_mccworktype`;
CREATE TABLE `c023_mccworktype` (
  `MCCWorkType_Id` varchar(10) NOT NULL,
  `MCCWorkType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`MCCWorkType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c023_mccworktype` VALUES('C023001','Offline Center',1,0);
INSERT INTO `c023_mccworktype` VALUES('C023002','Online Center',1,0);

-- Dump completed on 2026-05-12 17:14:39
