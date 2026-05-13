-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t003_service`;
CREATE TABLE `t003_service` (
  `Org_Id` varchar(10) NOT NULL,
  `Request_Id` varchar(20) NOT NULL,
  `Service_Id` varchar(20) DEFAULT NULL,
  `MCC_Id` varchar(45) DEFAULT NULL,
  `ServiceType_Id` varchar(20) DEFAULT NULL,
  `Request_For` varchar(45) DEFAULT NULL,
  `Request_For_User_Id` varchar(20) DEFAULT NULL,
  `Request_By` varchar(45) DEFAULT NULL,
  `Request_By_User_Id` varchar(20) DEFAULT NULL,
  `Request_Date` datetime DEFAULT NULL,
  `Request_Amount` decimal(8,2) DEFAULT NULL,
  `Request_Remark` text,
  `Is_Approved` int DEFAULT '0',
  `Approval_Remarks` longtext,
  `Approved_On` datetime DEFAULT NULL,
  `Approved_Id` varchar(20) DEFAULT NULL COMMENT 'If account is created by Farmer then Farmer Id will come here else Id of User who has created account will come here',
  `Approved_Name` varchar(45) DEFAULT NULL,
  `Approved_Amount` decimal(8,3) DEFAULT NULL,
  `VeterinaryService_Date` datetime DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Request_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:51
