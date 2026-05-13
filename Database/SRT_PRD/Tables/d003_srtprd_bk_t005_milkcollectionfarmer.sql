-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `bk_t005_milkcollectionfarmer`;
CREATE TABLE `bk_t005_milkcollectionfarmer` (
  `Org_Id` varchar(10) NOT NULL,
  `FarmerCollection_Id` varchar(20) NOT NULL,
  `MCC_Id` varchar(20) DEFAULT NULL,
  `MCCCollectionShift_Id` varchar(20) DEFAULT NULL,
  `Farmer_Id` varchar(20) DEFAULT NULL,
  `MilkType_Id` varchar(20) DEFAULT NULL,
  `MilkStatus_Id` varchar(20) DEFAULT NULL,
  `Quantity_Ltr` decimal(8,3) DEFAULT NULL,
  `Quantity_Kg` decimal(8,3) DEFAULT NULL,
  `Fat` decimal(8,2) DEFAULT NULL,
  `SNF` decimal(8,2) DEFAULT NULL,
  `Protein` varchar(45) DEFAULT NULL,
  `QuantityAuto_Flag` int DEFAULT '0',
  `QualityAuto_Flag` int DEFAULT '0',
  `ApplicableRate` decimal(8,2) DEFAULT NULL,
  `Amount` decimal(8,2) DEFAULT NULL,
  `EntryTime` time DEFAULT NULL,
  `Is_Corrected` int DEFAULT NULL,
  `Correction_Request_Id` varchar(45) DEFAULT NULL,
  `MusterCycle_StartDate` date DEFAULT NULL,
  `MusterCycle_EndDate` date DEFAULT NULL,
  `Invoice_Id` varchar(20) DEFAULT NULL,
  `Is_InvoiceCreated` int DEFAULT '0',
  `InvoiceCreated_On` datetime DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  `Is_Check` int DEFAULT '0',
  `Anamat_Charge` decimal(8,2) DEFAULT NULL,
  `Freight_Charge` decimal(8,2) DEFAULT NULL,
  `Is_FromApp` int DEFAULT '0',
  `Is_Missing` int DEFAULT '0',
  PRIMARY KEY (`Org_Id`,`FarmerCollection_Id`),
  KEY `MCC_Id` (`MCC_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:14:38
