-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `mu02_role_report`;
CREATE TABLE `mu02_role_report` (
  `Org_Id` varchar(10) NOT NULL,
  `Role_Id` varchar(20) NOT NULL,
  `ReportType_Id` varchar(10) NOT NULL,
  `Flag` int DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Role_Id`,`ReportType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `mu02_role_report` VALUES('C005','MU001','C048010',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU001','C048022',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU001','C048023',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU001','C048024',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU001','C048025',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU01241000001','C048010',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU01241000001','C048022',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU01241000001','C048023',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU01241000001','C048024',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU01241000001','C048025',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU01241000007','C048010',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU01241000007','C048022',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU01241000007','C048023',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU01241000007','C048024',1);
INSERT INTO `mu02_role_report` VALUES('C005','MU01241000007','C048025',1);

-- Dump completed on 2026-05-12 17:15:50
