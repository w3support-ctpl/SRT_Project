-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c014_mcctype`;
CREATE TABLE `c014_mcctype` (
  `MCCType_Id` varchar(10) NOT NULL,
  `MCCType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`MCCType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c014_mcctype` VALUES('C014001','Can Center',1,0);
INSERT INTO `c014_mcctype` VALUES('C014002','BMC ( Chiller )',1,0);
INSERT INTO `c014_mcctype` VALUES('C014003','Bulk Supplier',1,0);

-- Dump completed on 2026-05-12 17:14:38
