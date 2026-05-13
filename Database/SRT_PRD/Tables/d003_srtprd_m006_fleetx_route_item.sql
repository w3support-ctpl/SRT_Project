-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m006_fleetx_route_item`;
CREATE TABLE `m006_fleetx_route_item` (
  `Org_Id` varchar(10) NOT NULL,
  `Entry_Id` varchar(45) NOT NULL,
  `Route_Id` varchar(20) DEFAULT NULL,
  `Type` varchar(45) DEFAULT NULL,
  `User_Id` varchar(45) DEFAULT NULL,
  `Is_Notify` int DEFAULT '0',
  `Title` longtext,
  `Body` longtext,
  `Created_On` datetime DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:48
