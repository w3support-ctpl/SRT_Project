-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t044_rebate`;
CREATE TABLE `t044_rebate` (
  `Org_Id` varchar(10) NOT NULL,
  `Entry_Id` varchar(20) NOT NULL,
  `MCC_Id` varchar(20) DEFAULT NULL,
  `Entry_Date` date DEFAULT NULL,
  `Quantity_Ltr` decimal(20,3) DEFAULT NULL,
  `RebateRate` decimal(8,2) DEFAULT NULL,
  `RebateMilkPrice` decimal(20,2) DEFAULT NULL,
  `Is_Posted` int DEFAULT '0',
  `SAP_Document_Id` varchar(45) DEFAULT NULL,
  `SAP_Document_Year` varchar(45) DEFAULT NULL,
  `Created_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `Posted_On` datetime DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t044_rebate` VALUES('C005','T044241000003','M005241000045','02/01/2024',8049.000,1.25,10061.00,2,'0100013458','2023','05/17/2024 12:30:20','MU03241000002',NULL);

-- Dump completed on 2026-05-12 17:16:20
