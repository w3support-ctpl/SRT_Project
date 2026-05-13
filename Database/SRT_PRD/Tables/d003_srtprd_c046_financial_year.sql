-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c046_financial_year`;
CREATE TABLE `c046_financial_year` (
  `Year_Id` varchar(20) NOT NULL,
  `Year_Name` varchar(45) NOT NULL,
  `StartDate` datetime DEFAULT NULL,
  `EndDate` datetime DEFAULT NULL,
  PRIMARY KEY (`Year_Id`,`Year_Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c046_financial_year` VALUES('C046001','2023-2024','04/01/2023 00:00:00','03/31/2024 00:00:00');
INSERT INTO `c046_financial_year` VALUES('C046002','2024-2025','04/01/2024 00:00:00','03/31/2025 00:00:00');

-- Dump completed on 2026-05-12 17:14:40
