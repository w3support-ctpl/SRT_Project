-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `f003_farmerperformance`;
CREATE TABLE `f003_farmerperformance` (
  `Org_Id` varchar(20) DEFAULT NULL,
  `Farmer_Id` varchar(45) DEFAULT NULL,
  `Performance_Month` varchar(45) DEFAULT NULL,
  `Quality_Score` varchar(20) DEFAULT NULL,
  `Quantity_Score` varchar(20) DEFAULT NULL,
  `Quantity` varchar(45) DEFAULT NULL,
  `Quality` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:14:41
