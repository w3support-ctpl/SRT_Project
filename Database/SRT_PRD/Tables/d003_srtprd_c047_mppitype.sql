-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c047_mppitype`;
CREATE TABLE `c047_mppitype` (
  `MPPIType_Id` varchar(10) NOT NULL,
  `MPPIType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`MPPIType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c047_mppitype` VALUES('C047001','MPPI',1,0);
INSERT INTO `c047_mppitype` VALUES('C047002','Transport Charges',0,1);
INSERT INTO `c047_mppitype` VALUES('C047003','Gain - Loss',0,1);
INSERT INTO `c047_mppitype` VALUES('C047004','Anamat',0,1);
INSERT INTO `c047_mppitype` VALUES('C047005','Freight',0,1);
INSERT INTO `c047_mppitype` VALUES('C047006','Protein',1,0);
INSERT INTO `c047_mppitype` VALUES('C047007','Ash',1,0);
INSERT INTO `c047_mppitype` VALUES('C047008','Sodium',1,0);
INSERT INTO `c047_mppitype` VALUES('C047009','Incentive',1,0);

-- Dump completed on 2026-05-12 17:14:40
