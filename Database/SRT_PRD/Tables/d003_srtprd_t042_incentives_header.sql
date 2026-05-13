-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t042_incentives_header`;
CREATE TABLE `t042_incentives_header` (
  `Org_Id` varchar(20) NOT NULL,
  `Incentives_Id` varchar(45) NOT NULL,
  `Advance_Id` varchar(45) DEFAULT NULL,
  `Entry_Date` datetime DEFAULT NULL,
  `Request_User_Type` varchar(45) DEFAULT NULL,
  `Request_User_Id` varchar(45) DEFAULT NULL,
  `MCC_Id` varchar(45) DEFAULT NULL,
  `Request_Type` varchar(45) DEFAULT NULL,
  `Total_Amount` decimal(10,2) DEFAULT NULL,
  `Amount_Paid` decimal(10,2) DEFAULT NULL,
  `Balance` decimal(10,2) DEFAULT NULL,
  `Is_Closed` int DEFAULT NULL,
  `No_Of_Installments` int DEFAULT NULL,
  `Remarks` text,
  `CreatedBy_Id` varchar(45) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(45) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Incentives_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t042_incentives_header` VALUES('C005','T042241000001',NULL,'02/15/2024 00:00:00','Transporter','MU04443',NULL,'M020232000001',10.00,10.00,0.00,1,1,NULL,'MU03241000002','Gargi Thorat',NULL,NULL);

-- Dump completed on 2026-05-12 17:16:20
