-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m012_service`;
CREATE TABLE `m012_service` (
  `Org_Id` varchar(10) NOT NULL,
  `Service_Id` varchar(20) NOT NULL,
  `Service_Name` varchar(45) DEFAULT NULL,
  `ServiceType_Id` varchar(45) DEFAULT NULL,
  `Service_Description` longtext,
  `Condition_1` longtext,
  `Condition_2` longtext,
  `Condition_3` longtext,
  `Condition_4` longtext,
  `Condition_5` longtext,
  `Material_Id` varchar(20) DEFAULT NULL,
  `From_Date` datetime DEFAULT NULL,
  `To_Date` datetime DEFAULT NULL,
  `Is_For_Farmer` int DEFAULT NULL,
  `Is_For_Agent` int DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Service_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:15:48
