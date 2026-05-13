-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c029_freightratetype`;
CREATE TABLE `c029_freightratetype` (
  `FreightRateType_Id` varchar(10) NOT NULL,
  `FreightRateType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`FreightRateType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c029_freightratetype` VALUES('C029001','Fixed Per Route',1,0);
INSERT INTO `c029_freightratetype` VALUES('C029002','Per KM',1,0);
INSERT INTO `c029_freightratetype` VALUES('C029003','Per Ltr',1,0);

-- Dump completed on 2026-05-12 17:14:39
