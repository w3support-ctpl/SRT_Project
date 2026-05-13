-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m026_dealerroute_fleetx`;
CREATE TABLE `m026_dealerroute_fleetx` (
  `Org_Id` varchar(20) NOT NULL,
  `Route_Id` varchar(45) NOT NULL,
  `Route_Name` varchar(100) DEFAULT NULL,
  `FleetX_RouteId` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(45) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(45) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Route_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:49
