-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c012_milkrateentrytype`;
CREATE TABLE `c012_milkrateentrytype` (
  `MilkRateEntryType_Id` varchar(20) NOT NULL,
  `MilkRateEntryType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`MilkRateEntryType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c012_milkrateentrytype` VALUES('C012001','Base Rate',1,0);
INSERT INTO `c012_milkrateentrytype` VALUES('C012002','Fat Deduction',1,0);
INSERT INTO `c012_milkrateentrytype` VALUES('C012003','SNF Deduction',1,0);
INSERT INTO `c012_milkrateentrytype` VALUES('C012004','High Fat',1,0);
INSERT INTO `c012_milkrateentrytype` VALUES('C012005','High SNF',1,0);

-- Dump completed on 2026-05-12 17:14:38
