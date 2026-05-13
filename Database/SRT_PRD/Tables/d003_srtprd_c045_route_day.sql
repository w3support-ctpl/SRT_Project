-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c045_route_day`;
CREATE TABLE `c045_route_day` (
  `RouteDay_Id` varchar(20) NOT NULL,
  `RouteDay_Name` varchar(45) NOT NULL,
  PRIMARY KEY (`RouteDay_Id`,`RouteDay_Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c045_route_day` VALUES('C045001','Monday');
INSERT INTO `c045_route_day` VALUES('C045002','Tuesday');
INSERT INTO `c045_route_day` VALUES('C045003','Wednesday');
INSERT INTO `c045_route_day` VALUES('C045004','Thursday');
INSERT INTO `c045_route_day` VALUES('C045005','Friday');
INSERT INTO `c045_route_day` VALUES('C045006','Saturday');
INSERT INTO `c045_route_day` VALUES('C045007','Sunday');

-- Dump completed on 2026-05-12 17:14:40
