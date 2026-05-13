-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t009_milkcollectiondairy_mccloss`;
CREATE TABLE `t009_milkcollectiondairy_mccloss` (
  `Org_Id` varchar(10) NOT NULL,
  `Entry_Id` varchar(20) NOT NULL,
  `MilkCollectionDairy_Id` varchar(20) NOT NULL,
  `TripDocument_Id` varchar(20) NOT NULL,
  `MCCCollectionShift_Id` varchar(20) NOT NULL,
  `MCC_Id` varchar(20) NOT NULL,
  `CellNo` varchar(2) NOT NULL,
  `Weight` decimal(20,3) DEFAULT NULL,
  `Liters` decimal(20,3) DEFAULT NULL,
  `Loss` decimal(20,3) DEFAULT NULL,
  `Adjusted_Liters` decimal(20,3) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`,`MilkCollectionDairy_Id`,`TripDocument_Id`,`CellNo`,`MCCCollectionShift_Id`,`MCC_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:16:10
