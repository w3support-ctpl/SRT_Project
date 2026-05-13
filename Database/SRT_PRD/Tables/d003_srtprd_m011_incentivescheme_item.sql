-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m011_incentivescheme_item`;
CREATE TABLE `m011_incentivescheme_item` (
  `Org_Id` varchar(10) NOT NULL,
  `Entry_Id` varchar(20) NOT NULL,
  `IncentiveScheme_Id` varchar(20) DEFAULT NULL,
  `MCC_Id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:48
