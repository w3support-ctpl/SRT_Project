-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c030_nomineerelation`;
CREATE TABLE `c030_nomineerelation` (
  `NomineeRelation_Id` varchar(10) NOT NULL,
  `NomineeRelation_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT NULL,
  `Is_Deleted` int DEFAULT NULL,
  PRIMARY KEY (`NomineeRelation_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c030_nomineerelation` VALUES('C030001','Spouse',1,0);
INSERT INTO `c030_nomineerelation` VALUES('C030002','Child',1,0);
INSERT INTO `c030_nomineerelation` VALUES('C030003','Brother',1,0);
INSERT INTO `c030_nomineerelation` VALUES('C030004','Sister',1,0);
INSERT INTO `c030_nomineerelation` VALUES('C030005','Parent',1,0);
INSERT INTO `c030_nomineerelation` VALUES('C030006','Other',1,0);

-- Dump completed on 2026-05-12 17:14:39
