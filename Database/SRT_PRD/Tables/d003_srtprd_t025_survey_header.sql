-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t025_survey_header`;
CREATE TABLE `t025_survey_header` (
  `Org_Id` varchar(10) NOT NULL,
  `Survey_Id` varchar(20) NOT NULL,
  `Chemist_Id` varchar(20) DEFAULT NULL,
  `Applicable_Date` datetime DEFAULT NULL,
  `Assign` int DEFAULT '0',
  `Conducted` int DEFAULT '0',
  `Is_Started` int DEFAULT NULL,
  `Is_Active` int DEFAULT NULL,
  `Is_Deleted` int DEFAULT NULL,
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Survey_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:16:14
