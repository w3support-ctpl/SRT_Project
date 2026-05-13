-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c034_complainttype`;
CREATE TABLE `c034_complainttype` (
  `ComplaintType_Id` varchar(20) NOT NULL,
  `ComplaintType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`ComplaintType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c034_complainttype` VALUES('C034001','Cattle Feed',1,0);
INSERT INTO `c034_complainttype` VALUES('C034002','SRT Product',1,0);
INSERT INTO `c034_complainttype` VALUES('C034003','Expired Product',1,0);
INSERT INTO `c034_complainttype` VALUES('C034261000001','Other',1,0);
INSERT INTO `c034_complainttype` VALUES('C034261000002','APP Related',1,0);

-- Dump completed on 2026-05-12 17:14:39
