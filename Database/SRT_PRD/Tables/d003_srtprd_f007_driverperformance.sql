-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `f007_driverperformance`;
CREATE TABLE `f007_driverperformance` (
  `Org_Id` varchar(20) DEFAULT NULL,
  `Trip_Id` varchar(45) DEFAULT NULL,
  `Driver_Id` varchar(45) DEFAULT NULL,
  `Route_Time` varchar(45) DEFAULT NULL,
  `Route_Fuel` varchar(45) DEFAULT NULL,
  `BreakDown` int DEFAULT NULL,
  `Trip_Date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:14:42
