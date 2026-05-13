-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c015_collectionshift`;
CREATE TABLE `c015_collectionshift` (
  `CollectionShift_Id` varchar(10) NOT NULL,
  `CollectionShift_Name` varchar(45) DEFAULT NULL,
  `ShiftStart_Time` time DEFAULT NULL,
  `ShiftEnd_Time` time DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`CollectionShift_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c015_collectionshift` VALUES('C015001','Morning','06:30:00','17:30:00',1,0);
INSERT INTO `c015_collectionshift` VALUES('C015002','Evening','18:30:00','22:30:00',1,0);
INSERT INTO `c015_collectionshift` VALUES('C015003','All Day','00:01:00','23:59:00',1,0);

-- Dump completed on 2026-05-12 17:14:38
