-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c016_milkstatus`;
CREATE TABLE `c016_milkstatus` (
  `MilkStatus_Id` varchar(10) NOT NULL,
  `MilkStatus_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`MilkStatus_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c016_milkstatus` VALUES('C016001','Good',1,0);
INSERT INTO `c016_milkstatus` VALUES('C016002','Sour',1,0);
INSERT INTO `c016_milkstatus` VALUES('C016003','Adulterated',1,0);

-- Dump completed on 2026-05-12 17:14:38
