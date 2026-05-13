-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m013_salesarea`;
CREATE TABLE `m013_salesarea` (
  `Org_Id` varchar(10) NOT NULL,
  `SalesArea_Id` varchar(20) NOT NULL,
  `SalesArea_Name` varchar(45) DEFAULT NULL,
  `SalesArea_Code` varchar(45) DEFAULT NULL,
  `SalesOffice_Code` varchar(20) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`SalesArea_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `m013_salesarea` VALUES('C005','M013001','Sangamner Sales Group','SS1','1000',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m013_salesarea` VALUES('C005','M013002','Pune Sales Group','PS1','1100',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m013_salesarea` VALUES('C005','M013003','Mumbai Sales Group','MS1','1200',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m013_salesarea` VALUES('C005','M013004','Nashik Sales Group','NS1','1100',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m013_salesarea` VALUES('C005','M013005','Marathwada Sales Grp','MS2','1100',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m013_salesarea` VALUES('C005','M013006','Vidarbha Sales Group','VS1','1100',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m013_salesarea` VALUES('C005','M013007','Sangamner Rtl Sl Group','SS2','1000',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m013_salesarea` VALUES('C005','M013008','Others Sales Group','OS1','1000',1,0,NULL,NULL,NULL,NULL,NULL,NULL);

-- Dump completed on 2026-05-12 17:15:48
