-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t106_mcc_material_issue`;
CREATE TABLE `t106_mcc_material_issue` (
  `Org_Id` varchar(10) NOT NULL,
  `Issue_Id` varchar(45) NOT NULL,
  `MCC_Id` varchar(45) DEFAULT NULL,
  `Farmer_Id` varchar(45) DEFAULT NULL,
  `Issue_Date` date DEFAULT NULL,
  `Material` longtext,
  `Quantity` decimal(30,3) DEFAULT NULL,
  `Rate` decimal(30,3) DEFAULT NULL,
  `Amount` decimal(30,2) DEFAULT NULL,
  `Amount_Interest` decimal(10,2) DEFAULT NULL,
  `Amount_Deducted` decimal(10,2) DEFAULT NULL,
  `Balance` decimal(10,2) DEFAULT NULL,
  `No_Of_Installments` int DEFAULT NULL,
  `Is_Paid` int DEFAULT '0',
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Issue_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t106_mcc_material_issue` VALUES('C005','T106251000001','M005241000063','MU04251000086','07/12/2025','M101251000002',1.000,1700.000,1700.00,0.00,NULL,1700.00,0,1,1,0,'07/12/2025 09:27:08',NULL,'MU05241000063','',NULL,NULL);
INSERT INTO `t106_mcc_material_issue` VALUES('C005','T106251000002','M005241000078','MU04251000091','07/18/2025','M101251000005',1.000,1600.000,1600.00,0.00,NULL,1600.00,0,1,1,0,'07/18/2025 15:20:05',NULL,'MU05241000078','',NULL,NULL);
INSERT INTO `t106_mcc_material_issue` VALUES('C005','T106251000003','M005242000120','MU04251000107','07/23/2025','M101251000013',1.000,1600.000,1600.00,0.00,NULL,1600.00,1,0,1,0,'07/23/2025 15:14:16',NULL,'MU05241000021','',NULL,NULL);
INSERT INTO `t106_mcc_material_issue` VALUES('C005','T106251000004','M005231000008','MU04251000177','12/10/2025','M101251000020',30.000,1350.000,40500.00,0.00,NULL,40500.00,10,0,1,0,'12/10/2025 10:32:10',NULL,'MU05241000008','',NULL,NULL);

-- Dump completed on 2026-05-12 17:16:21
