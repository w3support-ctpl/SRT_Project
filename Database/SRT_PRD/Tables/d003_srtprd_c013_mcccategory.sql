-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c013_mcccategory`;
CREATE TABLE `c013_mcccategory` (
  `MCCCategory_Id` varchar(10) NOT NULL,
  `MCCCategory_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`MCCCategory_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c013_mcccategory` VALUES('C013001','Society',1,0);
INSERT INTO `c013_mcccategory` VALUES('C013002','Own',1,0);

-- Dump completed on 2026-05-12 17:14:38
