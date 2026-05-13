-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `ml02_state`;
CREATE TABLE `ml02_state` (
  `Org_Id` varchar(10) NOT NULL,
  `State_Id` varchar(20) NOT NULL,
  `State_Name` varchar(45) DEFAULT NULL,
  `State_Code` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`State_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `ml02_state` VALUES('C005','ML02231000001','Maharashtra','MH',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `ml02_state` VALUES('C005','ML02231000002','Gujrat','GJ',1,0,NULL,NULL,NULL,NULL,NULL,NULL);

-- Dump completed on 2026-05-12 17:15:49
