-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m011_incentivescheme`;
CREATE TABLE `m011_incentivescheme` (
  `Org_Id` varchar(10) NOT NULL,
  `IncentiveScheme_Id` varchar(20) NOT NULL,
  `Scheme_Name` varchar(45) DEFAULT NULL,
  `IncentiveType_Id` varchar(45) DEFAULT NULL,
  `IncentiveFrequency_Id` varchar(45) DEFAULT NULL,
  `Criteria` int DEFAULT NULL,
  `Scheme_Description` varchar(255) DEFAULT NULL,
  `Is_For_Farmer` int DEFAULT NULL,
  `Is_For_Agent` int DEFAULT NULL,
  `From_Date` datetime DEFAULT NULL,
  `To_Date` datetime DEFAULT NULL,
  `Photo` varchar(255) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Is_Completed` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`IncentiveScheme_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `m011_incentivescheme` VALUES('C005','M011241000001','INC','C025002','C026004',2000,'0.50P Above 2000Ltr',1,1,'05/21/2024 00:00:00','05/30/2024 00:00:00','',1,0,0,'05/21/2024 12:05:58','06/05/2024 11:11:43','MU03241000002','Gargi Thorat','MU03231000001','Abasaheb Thorat');

-- Dump completed on 2026-05-12 17:15:48
