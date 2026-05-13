-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `f010_milkcollectionmcc_final_sour_mcc`;
CREATE TABLE `f010_milkcollectionmcc_final_sour_mcc` (
  `Org_Id` varchar(10) NOT NULL,
  `Entry_Id` varchar(20) NOT NULL,
  `MilkCollectionDairy_Id` varchar(20) DEFAULT NULL,
  `MCC_Id` varchar(20) DEFAULT NULL,
  `CollectionShift_Id` varchar(20) DEFAULT NULL,
  `MilkType_Id` varchar(20) DEFAULT NULL,
  `Collection_Date` datetime DEFAULT NULL,
  `Agent_Quantity_Kg` decimal(20,3) DEFAULT NULL,
  `Agent_Quantity_Ltr` decimal(20,3) DEFAULT NULL,
  `Agent_Fat` decimal(8,2) DEFAULT NULL,
  `Agent_SNF` decimal(8,2) DEFAULT NULL,
  `Agent_Fat_Kg` decimal(10,2) DEFAULT NULL,
  `Agent_SNF_Kg` decimal(10,2) DEFAULT NULL,
  `Dairy_Quantity_Kg` decimal(20,3) DEFAULT NULL,
  `Dairy_Quantity_Ltr` decimal(20,3) DEFAULT NULL,
  `Dairy_Fat` decimal(8,2) DEFAULT NULL,
  `Dairy_SNF` decimal(8,2) DEFAULT NULL,
  `Dairy_Protein` decimal(8,2) DEFAULT NULL,
  `Dairy_Ash` decimal(8,2) DEFAULT NULL,
  `Dairy_Sodium` decimal(8,2) DEFAULT NULL,
  `Dairy_Fat_Kg` decimal(10,2) DEFAULT NULL,
  `Dairy_SNF_Kg` decimal(10,2) DEFAULT NULL,
  `FatKG_GainLoss` decimal(20,3) DEFAULT NULL,
  `SNFKG_GainLoss` decimal(20,3) DEFAULT NULL,
  `FatKG_Rate` decimal(20,3) DEFAULT NULL,
  `SNFKG_Rate` decimal(20,3) DEFAULT NULL,
  `Total_GainLoss` decimal(20,3) DEFAULT NULL,
  `MilkCollectionPosting_Id` varchar(20) DEFAULT NULL,
  `AgentCost` decimal(20,2) DEFAULT NULL,
  `TransporterCost` decimal(20,2) DEFAULT NULL,
  `MilkPrice` decimal(20,2) DEFAULT NULL,
  `MilkRate` decimal(8,2) DEFAULT NULL,
  `Plant_Code` varchar(45) DEFAULT NULL,
  `Is_VoucherLocked` int DEFAULT '0',
  `Locked_By` varchar(45) DEFAULT NULL,
  `Locked_On` datetime DEFAULT NULL,
  `Dairy_Sour_Ltr` decimal(20,3) DEFAULT '0.000',
  `OutsideInvoice_Id` varchar(20) DEFAULT NULL,
  `Is_OutsideCheck` int DEFAULT '0',
  `OutsideInvoiceCreated_On` datetime DEFAULT NULL,
  `Is_OutsideInvoiceCreated` int DEFAULT '0',
  PRIMARY KEY (`Org_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:14:45
