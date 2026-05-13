-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m018_mccopening_stock`;
CREATE TABLE `m018_mccopening_stock` (
  `Org_Id` varchar(20) NOT NULL,
  `OpeningStock_Id` varchar(45) NOT NULL,
  `MCC_Id` varchar(45) DEFAULT NULL,
  `Material_Id` varchar(45) DEFAULT NULL,
  `Stock` varchar(20) DEFAULT NULL,
  `Stock_Unit` varchar(45) DEFAULT NULL,
  `OpeingStock_Date` datetime DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`OpeningStock_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:49
