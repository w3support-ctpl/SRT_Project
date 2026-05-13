-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t031_deduction_item`;
CREATE TABLE `t031_deduction_item` (
  `Org_Id` varchar(10) NOT NULL,
  `Entry_Id` varchar(20) NOT NULL,
  `Ddeduction_Id` varchar(20) DEFAULT NULL,
  `Installation_No` varchar(45) DEFAULT NULL,
  `Installation_Amount` decimal(8,2) DEFAULT NULL,
  `Installation_Date` datetime DEFAULT NULL,
  `Voucher_Id` varchar(20) DEFAULT NULL,
  `Is_SAPPosted` int DEFAULT '0',
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:16:15
