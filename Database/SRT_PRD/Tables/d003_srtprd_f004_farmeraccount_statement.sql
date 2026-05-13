-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `f004_farmeraccount_statement`;
CREATE TABLE `f004_farmeraccount_statement` (
  `Org_Id` varchar(20) DEFAULT NULL,
  `Farmer_Id` varchar(45) DEFAULT NULL,
  `Statement_Date` datetime DEFAULT NULL,
  `Collection_Shift` varchar(45) DEFAULT NULL,
  `FAT` varchar(45) DEFAULT NULL,
  `SNF` varchar(45) DEFAULT NULL,
  `Quantity` varchar(45) DEFAULT NULL,
  `Opening_Balance` varchar(20) DEFAULT NULL,
  `Credit` varchar(20) DEFAULT NULL,
  `Debit` varchar(20) DEFAULT NULL,
  `Current_Balance` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:14:41
