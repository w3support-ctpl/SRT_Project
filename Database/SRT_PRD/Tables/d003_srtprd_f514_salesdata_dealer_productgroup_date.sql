-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `f514_salesdata_dealer_productgroup_date`;
CREATE TABLE `f514_salesdata_dealer_productgroup_date` (
  `Org_Id` varchar(10) NOT NULL,
  `Date` date DEFAULT NULL,
  `ProductGroup` longtext,
  `Dealer_Id` longtext,
  `Quantity` decimal(30,3) DEFAULT NULL,
  `Amount` decimal(30,3) DEFAULT NULL,
  `BaseUnit` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:14:48
