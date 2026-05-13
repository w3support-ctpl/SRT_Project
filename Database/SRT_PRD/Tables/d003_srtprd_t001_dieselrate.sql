-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t001_dieselrate`;
CREATE TABLE `t001_dieselrate` (
  `Org_Id` varchar(10) NOT NULL,
  `DieselRate_Id` varchar(45) NOT NULL,
  `DieselRate` decimal(8,2) DEFAULT NULL,
  `DieselRate_Date` datetime DEFAULT NULL,
  `Is_Active` int DEFAULT NULL,
  `Is_Deleted` int DEFAULT NULL,
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`DieselRate_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t001_dieselrate` VALUES('C005','T001241000001',93.50,'02/03/2024 00:00:00',1,0,'02/03/2024 11:49:28',NULL,'MU03231000001','Abasaheb Thorat',NULL,NULL);
INSERT INTO `t001_dieselrate` VALUES('C005','T001241000002',91.50,'03/15/2024 00:00:00',1,0,'03/15/2024 11:07:39',NULL,'MU03241000002','Gargi Thorat',NULL,NULL);
INSERT INTO `t001_dieselrate` VALUES('C005','T001251000001',91.00,'01/21/2025 00:00:00',1,0,'01/20/2025 17:44:51',NULL,'MU03241000028','Sachin Atre',NULL,NULL);
INSERT INTO `t001_dieselrate` VALUES('C005','T001251000002',91.45,'02/25/2025 00:00:00',1,0,'02/25/2025 12:07:49',NULL,'MU03241000028','Sachin Atre',NULL,NULL);

-- Dump completed on 2026-05-12 17:15:51
