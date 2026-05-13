-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t011_dispatch_header`;
CREATE TABLE `t011_dispatch_header` (
  `Org_Id` varchar(10) NOT NULL,
  `Dispatch_Id` varchar(20) NOT NULL,
  `MCC_Id` varchar(20) DEFAULT NULL,
  `Vehicle_Id` varchar(20) DEFAULT NULL,
  `Dispatch_Date` datetime DEFAULT NULL,
  `Vehicle_No` varchar(45) DEFAULT NULL,
  `Driver_Id` varchar(20) DEFAULT NULL,
  `Driver_Name` varchar(45) DEFAULT NULL,
  `Mobile_No` varchar(20) DEFAULT NULL,
  `Type` varchar(20) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Dispatch_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:16:12
