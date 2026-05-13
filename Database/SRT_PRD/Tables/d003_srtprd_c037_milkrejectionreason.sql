-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c037_milkrejectionreason`;
CREATE TABLE `c037_milkrejectionreason` (
  `MilkRejectionReason_Id` varchar(20) NOT NULL,
  `MilkRejectionReason_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`MilkRejectionReason_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c037_milkrejectionreason` VALUES('C037001','Sour',1,0);
INSERT INTO `c037_milkrejectionreason` VALUES('C037002','Adulterated',1,0);
INSERT INTO `c037_milkrejectionreason` VALUES('C037003','Ash',1,0);
INSERT INTO `c037_milkrejectionreason` VALUES('C037004','Antibiotic +',1,0);
INSERT INTO `c037_milkrejectionreason` VALUES('C037005','Fat',1,0);
INSERT INTO `c037_milkrejectionreason` VALUES('C037006','Snf',1,0);
INSERT INTO `c037_milkrejectionreason` VALUES('C037007','Aflatoxin +',1,0);
INSERT INTO `c037_milkrejectionreason` VALUES('C037008','RM',1,0);
INSERT INTO `c037_milkrejectionreason` VALUES('C037009','BR',1,0);
INSERT INTO `c037_milkrejectionreason` VALUES('C037010','MBRT',1,0);
INSERT INTO `c037_milkrejectionreason` VALUES('C037011','Heat Stability Test for Freshness',1,0);

-- Dump completed on 2026-05-12 17:14:39
