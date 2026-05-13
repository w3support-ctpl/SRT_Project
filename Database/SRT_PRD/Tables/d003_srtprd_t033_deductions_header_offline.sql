-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t033_deductions_header_offline`;
CREATE TABLE `t033_deductions_header_offline` (
  `Org_Id` varchar(20) NOT NULL,
  `Deductions_Id` varchar(45) NOT NULL,
  `Entry_Date` datetime DEFAULT NULL,
  `Farmer_Id` varchar(45) DEFAULT NULL,
  `MCC_Id` varchar(45) DEFAULT NULL,
  `Total_Amount` decimal(10,2) DEFAULT NULL,
  `Amount_Interest` decimal(10,2) DEFAULT NULL,
  `Amount_Deducted` decimal(10,2) DEFAULT NULL,
  `Balance` decimal(10,2) DEFAULT NULL,
  `Is_Closed` int DEFAULT NULL,
  `No_Of_Installments` int DEFAULT NULL,
  `ApprovedBy_On` datetime DEFAULT CURRENT_TIMESTAMP,
  `CreatedBy_Id` varchar(45) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(45) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Deductions_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t033_deductions_header_offline` VALUES('C005','T033251000004','07/23/2025 15:17:46','MU04251000107','M005242000120',50000.00,0.00,0.00,50000.00,0,1,'07/23/2025 15:17:46','MU05241000021','',NULL,NULL);

-- Dump completed on 2026-05-12 17:16:16
