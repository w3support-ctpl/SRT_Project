-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c031_routefrequency`;
CREATE TABLE `c031_routefrequency` (
  `RouteFrequency_Id` varchar(10) NOT NULL,
  `RouteFrequency_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`RouteFrequency_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c031_routefrequency` VALUES('C031000','All Day',1,0);
INSERT INTO `c031_routefrequency` VALUES('C031001','Monday',1,0);
INSERT INTO `c031_routefrequency` VALUES('C031002','Tuesday',1,0);
INSERT INTO `c031_routefrequency` VALUES('C031003','Wednesday',1,0);
INSERT INTO `c031_routefrequency` VALUES('C031004','Thursday',1,0);
INSERT INTO `c031_routefrequency` VALUES('C031005','Friday',1,0);
INSERT INTO `c031_routefrequency` VALUES('C031006','Saturday',1,0);
INSERT INTO `c031_routefrequency` VALUES('C031007','Sunday',1,0);

-- Dump completed on 2026-05-12 17:14:39
