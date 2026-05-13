-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `l005_fleetx_routevehicle`;
CREATE TABLE `l005_fleetx_routevehicle` (
  `Entry_Id` varchar(45) NOT NULL,
  `FleetX_RouteId` varchar(45) DEFAULT NULL,
  `Latitude` varchar(45) DEFAULT NULL,
  `Longitude` varchar(45) DEFAULT NULL,
  `Update_On` text,
  `Created_On` datetime DEFAULT NULL,
  PRIMARY KEY (`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:45
