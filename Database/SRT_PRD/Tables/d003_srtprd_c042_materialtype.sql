-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c042_materialtype`;
CREATE TABLE `c042_materialtype` (
  `MaterialType_Id` varchar(20) NOT NULL,
  `MaterialType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`MaterialType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c042_materialtype` VALUES('C042231000001','Aluminum Can With Lid',1,0);
INSERT INTO `c042_materialtype` VALUES('C042231000002','Aluminum Can Without  Lid',1,0);
INSERT INTO `c042_materialtype` VALUES('C042231000003','Plastic Can With Lid',1,0);
INSERT INTO `c042_materialtype` VALUES('C042231000004','Plastic Lid Without  Lid',1,0);
INSERT INTO `c042_materialtype` VALUES('C042231000005','Crate',1,0);

-- Dump completed on 2026-05-12 17:14:40
