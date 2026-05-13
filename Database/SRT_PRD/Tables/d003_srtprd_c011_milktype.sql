-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c011_milktype`;
CREATE TABLE `c011_milktype` (
  `MilkType_Id` varchar(20) NOT NULL,
  `MilkType_Name` varchar(45) DEFAULT NULL,
  `FAT` decimal(8,2) DEFAULT NULL,
  `SNF` decimal(8,2) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`MilkType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c011_milktype` VALUES('C011001','Cow',3.50,8.50,1,0);
INSERT INTO `c011_milktype` VALUES('C011002','Buffalo',6.00,9.00,1,0);
INSERT INTO `c011_milktype` VALUES('C011003','Skim Milk',0.00,8.50,1,0);
INSERT INTO `c011_milktype` VALUES('C011004','PHCM',3.50,8.50,1,0);

-- Dump completed on 2026-05-12 17:14:38
