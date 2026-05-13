-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t033_deductions_item_offline`;
CREATE TABLE `t033_deductions_item_offline` (
  `Org_Id` varchar(20) NOT NULL,
  `Entry_Id` varchar(20) NOT NULL,
  `Deductions_Id` varchar(45) NOT NULL,
  `Deduction_Date` datetime NOT NULL,
  `Deduction_Amount` decimal(10,2) DEFAULT NULL,
  `Is_Deducted` int DEFAULT NULL,
  `Invoice_Id` varchar(20) DEFAULT NULL,
  `Is_InvoiceCreated` int DEFAULT '0',
  `InvoiceCreated_On` datetime DEFAULT NULL,
  `Is_Check` int DEFAULT '0',
  `MusterCycle_StartDate` date DEFAULT NULL,
  `MusterCycle_EndDate` date DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`,`Deductions_Id`,`Deduction_Date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t033_deductions_item_offline` VALUES('C005','T033A251009773','T033251000004','07/23/2025 00:00:00',50000.00,0,NULL,0,NULL,0,'07/21/2025','07/31/2025');

-- Dump completed on 2026-05-12 17:16:16
