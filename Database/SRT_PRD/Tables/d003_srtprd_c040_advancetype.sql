-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c040_advancetype`;
CREATE TABLE `c040_advancetype` (
  `AdvanceType_Id` varchar(10) NOT NULL,
  `AdvanceType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`AdvanceType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c040_advancetype` VALUES('C040001','Emergency',1,0);
INSERT INTO `c040_advancetype` VALUES('C040002','Other',1,0);

-- Dump completed on 2026-05-12 17:14:39
