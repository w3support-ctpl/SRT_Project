-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t025_survey_item`;
CREATE TABLE `t025_survey_item` (
  `Org_Id` varchar(10) NOT NULL,
  `Survey_Id` varchar(20) NOT NULL,
  `MCC_Id` varchar(20) NOT NULL,
  `Is_Started` int DEFAULT '0',
  `Started_On` datetime DEFAULT NULL,
  `Is_Completed` int DEFAULT '0',
  `Completed_On` datetime DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Survey_Id`,`MCC_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dump completed on 2026-05-12 17:16:15
