-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t107_mcc_farmer_deduction`;
CREATE TABLE `t107_mcc_farmer_deduction` (
  `Org_Id` varchar(10) NOT NULL,
  `Deduction_Id` varchar(45) NOT NULL,
  `MCC_Id` varchar(45) DEFAULT NULL,
  `Farmer_Id` varchar(45) DEFAULT NULL,
  `Deduction_Date` date DEFAULT NULL,
  `Deduction_Type` longtext,
  `Amount` decimal(30,2) DEFAULT NULL,
  `Is_Check` int DEFAULT '0',
  `Description` longtext,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  `Invoice_Id` varchar(20) DEFAULT NULL,
  `Is_InvoiceCreated` int DEFAULT '0',
  `InvoiceCreated_On` datetime DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Deduction_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t107_mcc_farmer_deduction` VALUES('C005','T107251000001','M005242000120','MU04251000120','08/11/2025','Products Sales',100.00,1,'nndb',1,0,'08/11/2025 12:44:31',NULL,'MU05241000021','',NULL,NULL,NULL,0,NULL);

-- Dump completed on 2026-05-12 17:16:21
