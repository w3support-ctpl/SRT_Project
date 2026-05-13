-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t108_mcc_farmer_payment`;
CREATE TABLE `t108_mcc_farmer_payment` (
  `Org_Id` varchar(10) NOT NULL,
  `Voucher_Id` varchar(20) NOT NULL,
  `Farmer_Id` varchar(20) DEFAULT NULL,
  `MCC_Id` varchar(20) DEFAULT NULL,
  `Invoice_Date` date DEFAULT NULL,
  `Invoice_No` varchar(20) DEFAULT NULL,
  `MusterCycle_StartDate` date DEFAULT NULL,
  `MusterCycle_EndDate` date DEFAULT NULL,
  `Invoice_Amount` decimal(30,2) DEFAULT NULL,
  `Description` longtext,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  `Is_Posted` int DEFAULT '1',
  PRIMARY KEY (`Org_Id`,`Voucher_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t108_mcc_farmer_payment` VALUES('C005','T108251000001','MU04251000091','M005241000078','07/10/2025','P25261000001','07/01/2025','07/10/2025',0.00,'',1,0,'07/18/2025 15:39:35',NULL,'MU05241000078','',NULL,NULL,2);

-- Dump completed on 2026-05-12 17:16:21
