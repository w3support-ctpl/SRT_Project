-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c019_uom`;
CREATE TABLE `c019_uom` (
  `UOM_Id` varchar(10) NOT NULL,
  `UOM_Name` varchar(45) DEFAULT NULL,
  `UOM_Type` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Conversion` decimal(30,6) DEFAULT NULL,
  PRIMARY KEY (`UOM_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c019_uom` VALUES('C019001','Litre','Ltr',1,0,1.000000);
INSERT INTO `c019_uom` VALUES('C019002','Kilolitre','Kl',1,0,1000.000000);
INSERT INTO `c019_uom` VALUES('C019003','Milliliter','Ml',1,0,0.001000);
INSERT INTO `c019_uom` VALUES('C019004','Kilogram','Kg',1,0,1.000000);
INSERT INTO `c019_uom` VALUES('C019005','Gram','G',1,0,0.001000);
INSERT INTO `c019_uom` VALUES('C019006','Milligram','Mg',1,0,0.000001);
INSERT INTO `c019_uom` VALUES('C019007','Tonne','T',1,0,1000.000000);
INSERT INTO `c019_uom` VALUES('C019008','Each','EA',1,0,1.000000);
INSERT INTO `c019_uom` VALUES('C019009','Dozen','Dz',1,0,12.000000);

-- Dump completed on 2026-05-12 17:14:38
