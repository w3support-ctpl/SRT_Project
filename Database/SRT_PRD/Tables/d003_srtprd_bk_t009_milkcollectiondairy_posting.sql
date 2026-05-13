-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `bk_t009_milkcollectiondairy_posting`;
CREATE TABLE `bk_t009_milkcollectiondairy_posting` (
  `Org_Id` varchar(10) NOT NULL,
  `MilkCollectionPosting_Id` varchar(20) NOT NULL,
  `CollectionShift_Id` varchar(20) DEFAULT NULL,
  `MCC_Id` varchar(20) DEFAULT NULL,
  `Created_On` date DEFAULT NULL,
  `Batch_Id` varchar(45) DEFAULT NULL,
  `MilkType_Id` varchar(20) DEFAULT NULL,
  `MilkStatus_Id` varchar(20) DEFAULT NULL,
  `Weight` decimal(20,3) DEFAULT NULL,
  `Liters` decimal(20,3) DEFAULT NULL,
  `Year` varchar(45) DEFAULT NULL,
  `SAP_Document_Id` varchar(45) DEFAULT NULL,
  `Fat` decimal(20,2) DEFAULT NULL,
  `FatCost` decimal(20,2) DEFAULT NULL,
  `FatKG` decimal(20,3) DEFAULT NULL,
  `SNF` decimal(20,2) DEFAULT NULL,
  `SNFCost` decimal(20,2) DEFAULT NULL,
  `SNFKG` decimal(20,3) DEFAULT NULL,
  `MilkCost` decimal(20,2) DEFAULT NULL,
  `AgentCost` decimal(20,2) DEFAULT NULL,
  `TransporterCost` decimal(20,2) DEFAULT NULL,
  `Rate` decimal(20,2) DEFAULT NULL,
  `Original_MilkPrice` decimal(20,2) DEFAULT NULL,
  `Total_GainLoss` decimal(20,2) DEFAULT NULL,
  `MilkPrice` decimal(20,2) DEFAULT NULL,
  `TotalLandedCost` decimal(20,2) DEFAULT NULL,
  `Original_FatRate` decimal(20,2) DEFAULT NULL,
  `Original_FatValue` decimal(20,2) DEFAULT NULL,
  `Original_SNFRate` decimal(20,2) DEFAULT NULL,
  `Original_SNFValue` decimal(20,2) DEFAULT NULL,
  `FatRate` decimal(20,2) DEFAULT NULL,
  `FatValue` decimal(20,2) DEFAULT NULL,
  `SNFRate` decimal(20,2) DEFAULT NULL,
  `SNFValue` decimal(20,2) DEFAULT NULL,
  `FEQ` decimal(20,2) DEFAULT NULL,
  `Is_Posted` int DEFAULT '0',
  PRIMARY KEY (`Org_Id`,`MilkCollectionPosting_Id`),
  KEY `MCC_Id` (`MCC_Id`),
  KEY `CollectionShift_Id` (`CollectionShift_Id`),
  KEY `Created_On` (`Created_On`),
  KEY `MilkCollectionPosting_Id` (`MilkCollectionPosting_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:14:38
