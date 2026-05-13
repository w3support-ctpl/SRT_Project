-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m102_mcc_supplier`;
CREATE TABLE `m102_mcc_supplier` (
  `Org_Id` varchar(10) NOT NULL,
  `MCC_Id` varchar(45) NOT NULL,
  `Supplier_Id` varchar(45) NOT NULL,
  `Supplier_Name` longtext,
  `Address_Text` longtext,
  `Mobile_No` varchar(45) DEFAULT NULL,
  `ContactPerson_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Supplier_Id`,`MCC_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `m102_mcc_supplier` VALUES('C005','M005241000063','M102251000001','Samantha tredars','AT_sanagamner','8830784890','Shravan khatal',1,0,'07/12/2025 09:24:20',NULL,'MU05241000063','Profile Name',NULL,NULL);
INSERT INTO `m102_mcc_supplier` VALUES('C005','M005241000078','M102251000002','Khatal Patil','sangamner','8888639068','Mahesh khatal',1,0,'07/18/2025 15:16:34',NULL,'MU05241000078','Profile Name',NULL,NULL);
INSERT INTO `m102_mcc_supplier` VALUES('C005','M005241000080','M102251000003','रायभान गुंजाळ ','खांडगाव ','9860140917','+91 97647 74220',1,0,'07/18/2025 15:19:50','07/25/2025 12:27:16','MU05241000080','Profile Name','MU05241000080','Profile Name');
INSERT INTO `m102_mcc_supplier` VALUES('C005','M005241000080','M102251000004','प्रमोद कोटकर ','संगमनेर ','9881555494','+91 98815 55494',1,0,'07/18/2025 15:23:48',NULL,'MU05241000080','Profile Name',NULL,NULL);
INSERT INTO `m102_mcc_supplier` VALUES('C005','M005242000120','M102251000005','Darikar treders ','kopargaon','8888639998','xxxc',1,0,'07/23/2025 15:12:08',NULL,'MU05241000021','Profile Name',NULL,NULL);
INSERT INTO `m102_mcc_supplier` VALUES('C005','M005241000018','M102251000006','khata ramadas','sangamner ','8888883846','khatal',1,0,'07/23/2025 19:37:29',NULL,'MU05241000018','Profile Name',NULL,NULL);
INSERT INTO `m102_mcc_supplier` VALUES('C005','M005241000018','M102251000007','pankesh bomble','Hivaragoan Ambre ','7387213447','pankesh ',1,0,'07/23/2025 19:39:02',NULL,'MU05241000018','Profile Name',NULL,NULL);
INSERT INTO `m102_mcc_supplier` VALUES('C005','M005231000008','M102251000008','SRT','sangamner','9860100936','SRT',1,0,'12/10/2025 10:29:48',NULL,'MU05241000008','Profile Name',NULL,NULL);

-- Dump completed on 2026-05-12 17:15:49
