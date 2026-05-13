-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t039_dispatch_crate_time`;
CREATE TABLE `t039_dispatch_crate_time` (
  `Org_Id` varchar(20) NOT NULL,
  `Dispatch_Id` varchar(45) NOT NULL,
  `Dealer_Code` varchar(45) DEFAULT NULL,
  `Dealer_Name` varchar(200) DEFAULT NULL,
  `Dispatch_Date` varchar(45) DEFAULT NULL,
  `Quantity` varchar(20) DEFAULT NULL,
  `Material_Code` varchar(45) DEFAULT NULL,
  `Invoice_Number` varchar(45) DEFAULT NULL,
  `Created_On` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Dispatch_Id`),
  KEY `Dealer_Code` (`Dealer_Code`),
  KEY `Material_Code` (`Material_Code`),
  KEY `idx_duplicate_check` (`Invoice_Number`,`Dealer_Code`,`Material_Code`,`Dispatch_Date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:16:20
