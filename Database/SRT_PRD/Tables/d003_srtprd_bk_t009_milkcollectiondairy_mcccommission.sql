-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `bk_t009_milkcollectiondairy_mcccommission`;
CREATE TABLE `bk_t009_milkcollectiondairy_mcccommission` (
  `Org_Id` varchar(10) NOT NULL,
  `MilkCollectionMCCCommission_Id` varchar(20) NOT NULL,
  `MilkCollectionDairy_Id` varchar(20) NOT NULL,
  `MCC_Id` varchar(20) NOT NULL,
  `MPPIType_Id` varchar(20) NOT NULL,
  `CollectionShift_Id` varchar(20) DEFAULT NULL,
  `MilkType_Id` varchar(20) DEFAULT NULL,
  `MilkStatus_Id` varchar(20) DEFAULT NULL,
  `Weight` decimal(20,3) DEFAULT NULL,
  `Liters` decimal(20,3) DEFAULT NULL,
  `Fat` decimal(8,2) DEFAULT NULL,
  `SNF` decimal(8,2) DEFAULT NULL,
  `BaseRate` decimal(20,2) DEFAULT NULL,
  `ServiceCharge` decimal(20,2) DEFAULT NULL,
  `Amount` decimal(20,2) DEFAULT NULL,
  `MusterType_Id` varchar(20) DEFAULT NULL,
  `MusterCycle_StartDate` date DEFAULT NULL,
  `MusterCycle_EndDate` date DEFAULT NULL,
  `Is_Check` int DEFAULT '0',
  `Invoice_Id` varchar(20) DEFAULT NULL,
  `Is_InvoiceCreated` int DEFAULT '0',
  `InvoiceCreated_On` datetime DEFAULT NULL,
  `MCC_Commision` decimal(20,2) DEFAULT NULL,
  `Is_Sour_Check` int DEFAULT '0',
  PRIMARY KEY (`Org_Id`,`MilkCollectionMCCCommission_Id`,`MilkCollectionDairy_Id`,`MCC_Id`,`MPPIType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:14:38
