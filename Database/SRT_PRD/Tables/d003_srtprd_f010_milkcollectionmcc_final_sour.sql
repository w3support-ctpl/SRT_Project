-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `f010_milkcollectionmcc_final_sour`;
CREATE TABLE `f010_milkcollectionmcc_final_sour` (
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
INSERT INTO `f010_milkcollectionmcc_final_sour` VALUES('C005','F010A251000001','T009251024322','M005241000072',NULL,'C011001','08/08/2025 00:00:00',1316.495,1277.000,3.60,8.40,47.39,110.59,1316.500,1277.000,3.60,8.10,2.70,0.00,0.00,47.39,106.64,0.000,-3.950,405.429,221.294,0.000,'',NULL,NULL,40480.90,31.70,'1100',0,NULL,NULL,0.000,NULL,0,NULL,0);
INSERT INTO `f010_milkcollectionmcc_final_sour` VALUES('C005','F010A251000002','T009251025751','M005231000069',NULL,'C011001','08/21/2025 00:00:00',1515.464,1470.000,3.90,8.40,59.10,127.30,1515.500,1470.000,3.50,7.90,2.60,0.00,0.00,53.04,119.72,-6.060,-7.580,422.571,226.000,0.000,'',NULL,NULL,43953.00,29.90,'1100',0,NULL,NULL,0.000,NULL,0,NULL,0);
INSERT INTO `f010_milkcollectionmcc_final_sour` VALUES('C005','F010A251000003','T009251025751','M005241000072',NULL,'C011001','08/21/2025 00:00:00',1294.845,1256.000,3.90,8.40,50.50,108.77,1294.800,1256.000,3.70,8.20,2.80,0.00,0.00,47.91,106.17,-2.590,-2.600,422.571,226.000,0.000,'',NULL,NULL,40820.00,32.50,'1100',0,NULL,NULL,0.000,NULL,0,NULL,0);
INSERT INTO `f010_milkcollectionmcc_final_sour` VALUES('C005','F010A251000004','T009251025751','M005241000066',NULL,'C011001','08/21/2025 00:00:00',1083.505,1051.000,3.90,8.50,42.26,92.10,1083.500,1051.000,3.60,8.10,2.80,0.00,0.00,39.01,87.76,-3.250,-4.340,422.571,226.000,0.000,'',NULL,NULL,33316.70,31.70,'1100',0,NULL,NULL,0.000,NULL,0,NULL,0);

-- Dump completed on 2026-05-12 17:14:45
