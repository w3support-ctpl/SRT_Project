-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c001_organization`;
CREATE TABLE `c001_organization` (
  `Org_Id` varchar(10) NOT NULL,
  `Org_Name` varchar(45) DEFAULT NULL,
  `Org_Address` varchar(200) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Kg_To_Ltr_Farmer` decimal(8,2) DEFAULT NULL,
  `Kg_To_Ltr_Agent` decimal(8,2) DEFAULT NULL,
  `Kg_To_Ltr_Dairy` decimal(8,2) DEFAULT NULL,
  `TruckCollection_FirstQty` int DEFAULT '0',
  `TankerCollection_FirstQty` int DEFAULT '0',
  `Destination_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c001_organization` VALUES('C001','SRT Dairy','Sangamner',1,0,0.97,0.97,0.97,1,1,'DEV');
INSERT INTO `c001_organization` VALUES('C002','Amol Dairy ','Andheri',1,0,0.97,0.97,0.97,1,1,'DEV');
INSERT INTO `c001_organization` VALUES('C003','SRT Dairy','Sangamner',1,0,0.97,0.97,0.97,1,1,'UAT');
INSERT INTO `c001_organization` VALUES('C005','S R Thorat Dairy','Sangamner',1,1,0.97,0.97,0.97,1,1,'PRD');

-- Dump completed on 2026-05-12 17:14:38
