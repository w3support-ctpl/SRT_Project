-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c025_incentivetype`;
CREATE TABLE `c025_incentivetype` (
  `IncentiveType_Id` varchar(10) NOT NULL,
  `IncentiveType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`IncentiveType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c025_incentivetype` VALUES('C025001','Quality',1,0);
INSERT INTO `c025_incentivetype` VALUES('C025002','Quantity',1,0);

-- Dump completed on 2026-05-12 17:14:39
