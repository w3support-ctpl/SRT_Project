-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t101_mcc_material_inward`;
CREATE TABLE `t101_mcc_material_inward` (
  `Org_Id` varchar(10) NOT NULL,
  `Inward_Id` varchar(45) NOT NULL,
  `MCC_Id` varchar(45) DEFAULT NULL,
  `Supplier_Id` varchar(45) DEFAULT NULL,
  `Inward_Date` date DEFAULT NULL,
  `Total_Amount` decimal(30,2) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Inward_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t101_mcc_material_inward` VALUES('C005','T101251000001','M005242000120','M102251000005','07/22/2025',1550.00,1,0,'07/23/2025 15:12:58',NULL,'MU05241000021','',NULL,NULL);
INSERT INTO `t101_mcc_material_inward` VALUES('C005','T101251000002','M005241000018','M102251000007','07/10/2025',1480.00,1,0,'07/23/2025 19:41:13',NULL,'MU05241000018','',NULL,NULL);
INSERT INTO `t101_mcc_material_inward` VALUES('C005','T101251000003','M005241000080','M102251000003','07/25/2025',1210.00,1,0,'07/25/2025 14:15:36',NULL,'MU05241000080','',NULL,NULL);

-- Dump completed on 2026-05-12 17:16:20
