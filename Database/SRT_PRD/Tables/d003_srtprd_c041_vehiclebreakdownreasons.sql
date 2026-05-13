-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c041_vehiclebreakdownreasons`;
CREATE TABLE `c041_vehiclebreakdownreasons` (
  `BreakDown_Id` varchar(10) NOT NULL,
  `BreakDown_Reason` varchar(20) DEFAULT NULL,
  `Is_Active` int DEFAULT NULL,
  `Is_Deleted` int DEFAULT NULL,
  PRIMARY KEY (`BreakDown_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c041_vehiclebreakdownreasons` VALUES('C041001','Tire puncture',1,0);

-- Dump completed on 2026-05-12 17:14:39
