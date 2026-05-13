-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c038_requesttype`;
CREATE TABLE `c038_requesttype` (
  `RequestType_Id` varchar(10) NOT NULL,
  `RequestType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`RequestType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c038_requesttype` VALUES('C038001','Manual Weight',1,0);
INSERT INTO `c038_requesttype` VALUES('C038002','Manual Quality',1,0);
INSERT INTO `c038_requesttype` VALUES('C038003','Extra Time',1,0);

-- Dump completed on 2026-05-12 17:14:39
