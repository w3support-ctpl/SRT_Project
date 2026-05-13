-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m020_incentives_head`;
CREATE TABLE `m020_incentives_head` (
  `Org_Id` varchar(20) NOT NULL,
  `IncentiveHead_Id` varchar(45) NOT NULL,
  `IncentiveHead_Name` varchar(45) DEFAULT NULL,
  `User_Type` varchar(45) DEFAULT NULL,
  `Incentive_Type` varchar(45) DEFAULT NULL,
  `GL_Code` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`IncentiveHead_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `m020_incentives_head` VALUES('C005','M020232000001','Cattle Feed','Transporter','','0040102281',1,0,NULL,NULL,NULL,NULL,NULL,NULL);

-- Dump completed on 2026-05-12 17:15:49
