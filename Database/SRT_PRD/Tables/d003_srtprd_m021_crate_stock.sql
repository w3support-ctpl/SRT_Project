-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m021_crate_stock`;
CREATE TABLE `m021_crate_stock` (
  `Org_Id` varchar(45) NOT NULL,
  `Dealer_Id` varchar(45) NOT NULL,
  `Material_Code` varchar(45) NOT NULL,
  `Quantity` varchar(45) DEFAULT NULL,
  `Date` datetime DEFAULT NULL,
  PRIMARY KEY (`Dealer_Id`,`Material_Code`,`Org_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:49
