-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t036_salesusers_targets_header`;
CREATE TABLE `t036_salesusers_targets_header` (
  `Org_Id` varchar(20) NOT NULL,
  `Target_Id` varchar(45) NOT NULL,
  `SalesUser_Id` varchar(45) DEFAULT NULL,
  `Month_Year` date DEFAULT NULL,
  `FinancialYear_Id` varchar(45) DEFAULT NULL,
  `Dealer_Id` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Target_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t036_salesusers_targets_header` VALUES('C005','T036261000001','MU12241000001','03/01/2026',NULL,'MU08241000197',1,0,'03/16/2026 11:38:29','MU03241000028','Sachin Atre',NULL,NULL,NULL);

-- Dump completed on 2026-05-12 17:16:17
