-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `f008_salesusertarget`;
CREATE TABLE `f008_salesusertarget` (
  `Org_Id` varchar(30) DEFAULT NULL,
  `SalesUser_Id` varchar(45) DEFAULT NULL,
  `Dealer_Id` varchar(45) DEFAULT NULL,
  `Product_Id` varchar(45) DEFAULT NULL,
  `Quantity` varchar(45) DEFAULT NULL,
  `Amount` varchar(45) DEFAULT NULL,
  `Date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:14:42
