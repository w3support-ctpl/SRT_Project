-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c022_mustertype`;
CREATE TABLE `c022_mustertype` (
  `MusterType_Id` varchar(10) NOT NULL,
  `MusterType_Name` varchar(45) DEFAULT NULL,
  `MusterType` int DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`MusterType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c022_mustertype` VALUES('C022001','1 Day',1,1,0);
INSERT INTO `c022_mustertype` VALUES('C022002','5 Days',5,1,0);
INSERT INTO `c022_mustertype` VALUES('C022003','7 Days',7,1,0);
INSERT INTO `c022_mustertype` VALUES('C022004','10 Days',10,1,0);
INSERT INTO `c022_mustertype` VALUES('C022005','15 Days',15,1,0);
INSERT INTO `c022_mustertype` VALUES('C022006','1 Month',30,1,0);

-- Dump completed on 2026-05-12 17:14:39
