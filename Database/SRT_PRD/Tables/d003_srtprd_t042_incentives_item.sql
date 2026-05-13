-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t042_incentives_item`;
CREATE TABLE `t042_incentives_item` (
  `Org_Id` varchar(20) NOT NULL,
  `Entry_Id` varchar(20) NOT NULL,
  `Incentives_Id` varchar(45) NOT NULL,
  `Incentive_Date` datetime NOT NULL,
  `Incentive_Amount` decimal(10,2) DEFAULT NULL,
  `Is_Paid` int DEFAULT NULL,
  `Invoice_Id` varchar(20) DEFAULT NULL,
  `Is_InvoiceCreated` int DEFAULT '0',
  `InvoiceCreated_On` datetime DEFAULT NULL,
  `Is_Check` int DEFAULT '0',
  `MusterCycle_StartDate` date DEFAULT NULL,
  `MusterCycle_EndDate` date DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`,`Incentives_Id`,`Incentive_Date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t042_incentives_item` VALUES('C005','T042A241000001','T042241000001','02/15/2024 00:00:00',10.00,1,'T029241000001',1,'03/29/2024 12:18:46',1,NULL,NULL);

-- Dump completed on 2026-05-12 17:16:20
