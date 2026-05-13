-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m024_dealer_route`;
CREATE TABLE `m024_dealer_route` (
  `Org_Id` varchar(30) NOT NULL,
  `FleetX_RouteId` varchar(45) NOT NULL,
  `Route_Name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`FleetX_RouteId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:49
