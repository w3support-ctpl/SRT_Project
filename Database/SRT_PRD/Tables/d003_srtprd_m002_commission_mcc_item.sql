-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m002_commission_mcc_item`;
CREATE TABLE `m002_commission_mcc_item` (
  `Org_Id` varchar(10) NOT NULL,
  `MPPI_Id` varchar(20) NOT NULL,
  `Version_No` int NOT NULL,
  `MCC_Id` varchar(20) NOT NULL,
  PRIMARY KEY (`Org_Id`,`MPPI_Id`,`Version_No`,`MCC_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:47
