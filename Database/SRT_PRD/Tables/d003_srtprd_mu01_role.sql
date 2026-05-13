-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `mu01_role`;
CREATE TABLE `mu01_role` (
  `Org_Id` varchar(10) NOT NULL,
  `Role_Id` varchar(20) NOT NULL,
  `Role_Name` varchar(45) DEFAULT NULL,
  `Is_SystemRole` int DEFAULT '0',
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Role_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `mu01_role` VALUES('C005','MU001','SuperAdmin',1,1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `mu01_role` VALUES('C005','MU01241000001','Finance Admin',0,1,0,'02/01/2024 12:08:05','03/11/2026 14:45:17','MU03231000001','Abasaheb Thorat','MU03241000002','Gargi Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01241000002','Gate Security',0,1,0,'02/06/2024 10:22:25','02/06/2024 10:22:46','MU03231000001','Abasaheb Thorat','MU03231000001','Abasaheb Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01241000003','RMRD Supervisor',0,1,0,'02/06/2024 10:27:44','03/02/2024 15:57:17','MU03231000001','Abasaheb Thorat','MU03241000002','Gargi Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01241000004','Quality Supervisor',0,1,0,'02/06/2024 10:34:01','02/06/2024 10:34:32','MU03231000001','Abasaheb Thorat','MU03231000001','Abasaheb Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01241000005','MP Admin',0,1,0,'02/06/2024 10:46:32','03/25/2026 11:54:25','MU03231000001','Abasaheb Thorat','MU03241000002','Gargi Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01241000006','Finance User',0,1,0,'02/06/2024 10:53:02','03/29/2024 14:03:22','MU03231000001','Abasaheb Thorat','MU03241000002','Gargi Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01241000007','Crate Inward Approver',0,1,0,'02/10/2024 15:27:01','12/10/2024 10:25:46','MU03231000001','Abasaheb Thorat','MU03241000002','Gargi Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01241000008','Production',0,1,0,'02/12/2024 13:58:50','02/12/2024 19:05:41','MU03231000001','Abasaheb Thorat','MU03231000001','Abasaheb Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01242000009','MP Master Admin',0,1,0,'02/23/2024 10:31:48','12/12/2025 14:28:18','MU03241000002','Gargi Thorat','MU03241000028','Sachin Atre');
INSERT INTO `mu01_role` VALUES('C005','MU01242000010','Crate Inward Data Entry',0,1,0,'03/12/2024 19:22:57','07/31/2024 11:00:53','MU03241000002','Gargi Thorat','MU03241000002','Gargi Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01242000011','Sales Order Creator',0,1,0,'03/30/2024 12:06:24','03/11/2026 14:48:10','MU03241000002','Gargi Thorat','MU03241000002','Gargi Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01242000012','Quality Admin',0,1,0,'04/30/2024 10:03:45','04/30/2024 10:05:23','MU03241000002','Gargi Thorat','MU03241000002','Gargi Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01242000013','Trading Sale',0,1,0,'05/15/2024 16:24:36','12/12/2024 10:06:58','MU03241000002','Gargi Thorat','MU03241000042','Ramchandra Arjun Mandlik');
INSERT INTO `mu01_role` VALUES('C005','MU01242000014','Sales Admin',0,1,0,'10/17/2024 11:30:50','05/04/2026 18:04:49','MU03241000002','Gargi Thorat','MU03241000002','Gargi Thorat');
INSERT INTO `mu01_role` VALUES('C005','MU01242000015','TRANSPORT TRIP DISPLAY',0,1,0,'10/24/2024 10:06:31','10/24/2024 10:07:31','MU03241000002','Gargi Thorat','MU03241000002','Gargi Thorat');

-- Dump completed on 2026-05-12 17:15:50
