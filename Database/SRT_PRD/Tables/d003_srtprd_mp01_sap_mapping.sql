-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `mp01_sap_mapping`;
CREATE TABLE `mp01_sap_mapping` (
  `Org_Id` varchar(10) NOT NULL,
  `APP_Code` varchar(20) NOT NULL,
  `SAP_Code` varchar(45) DEFAULT NULL,
  `Description` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`APP_Code`,`Org_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:50
