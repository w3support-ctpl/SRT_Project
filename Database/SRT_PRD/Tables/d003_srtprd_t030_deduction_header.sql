-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t030_deduction_header`;
CREATE TABLE `t030_deduction_header` (
  `Org_Id` varchar(10) NOT NULL,
  `Ddeduction_Id` varchar(20) NOT NULL,
  `Order_Id` varchar(20) NOT NULL,
  `Service_Id` varchar(20) DEFAULT NULL,
  `Ddeduction_For_User_Type` varchar(45) DEFAULT NULL,
  `Ddeduction_For_User_Id` varchar(20) DEFAULT NULL,
  `Total_Ddeduction_Amount` decimal(8,2) DEFAULT NULL,
  `Installation_Count` int DEFAULT '0',
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Ddeduction_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:16:15
