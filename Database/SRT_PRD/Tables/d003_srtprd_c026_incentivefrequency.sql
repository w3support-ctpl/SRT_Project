-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c026_incentivefrequency`;
CREATE TABLE `c026_incentivefrequency` (
  `IncentiveFrequency_Id` varchar(10) NOT NULL,
  `IncentiveFrequency_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`IncentiveFrequency_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c026_incentivefrequency` VALUES('C026001','Weekly',1,0);
INSERT INTO `c026_incentivefrequency` VALUES('C026002','Monthly',1,0);
INSERT INTO `c026_incentivefrequency` VALUES('C026003','Yearly',1,0);
INSERT INTO `c026_incentivefrequency` VALUES('C026004','Muster wise',1,0);

-- Dump completed on 2026-05-12 17:14:39
