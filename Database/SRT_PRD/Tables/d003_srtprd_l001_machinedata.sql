-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `l001_machinedata`;
CREATE TABLE `l001_machinedata` (
  `Org_Id` varchar(10) NOT NULL,
  `Machine1` longtext,
  `Machine2` longtext,
  `Machine3` longtext,
  PRIMARY KEY (`Org_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `l001_machinedata` VALUES('C005','4255','0000.2','16:52:50 12-05-2026,64, 0.00, 0.00, 0.00,,,,,,,MEASUREMENT_TIMED_OUT
');

-- Dump completed on 2026-05-12 17:14:48
