-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m025_app_version`;
CREATE TABLE `m025_app_version` (
  `Entry_Id` varchar(20) NOT NULL,
  `App_Name` varchar(100) DEFAULT NULL,
  `Version` varchar(45) DEFAULT NULL,
  `Applicable_From` datetime DEFAULT NULL,
  PRIMARY KEY (`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `m025_app_version` VALUES('M025231007563','SankalanPoint','9','03/27/2024 10:27:03');
INSERT INTO `m025_app_version` VALUES('M025231007564','Dairylicious','9','03/27/2024 10:27:03');
INSERT INTO `m025_app_version` VALUES('M025231007565','RouteWise','6','03/27/2024 10:27:03');
INSERT INTO `m025_app_version` VALUES('M025231007566','QACheck','5','03/27/2024 10:27:03');

-- Dump completed on 2026-05-12 17:15:49
