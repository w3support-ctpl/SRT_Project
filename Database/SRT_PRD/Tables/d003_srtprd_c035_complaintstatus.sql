-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c035_complaintstatus`;
CREATE TABLE `c035_complaintstatus` (
  `ComplaintStatus_Id` varchar(20) NOT NULL,
  `ComplaintStatus_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`ComplaintStatus_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c035_complaintstatus` VALUES('C035001','New',1,0);
INSERT INTO `c035_complaintstatus` VALUES('C035002','Open',1,0);
INSERT INTO `c035_complaintstatus` VALUES('C035003','Resolved',1,0);
INSERT INTO `c035_complaintstatus` VALUES('C035004','Closed',1,0);
INSERT INTO `c035_complaintstatus` VALUES('C035005','Auto Closed',1,0);

-- Dump completed on 2026-05-12 17:14:39
