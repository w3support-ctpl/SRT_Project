-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c032_vehiclemake`;
CREATE TABLE `c032_vehiclemake` (
  `VehicleMake_Id` varchar(10) NOT NULL,
  `VehicleMake_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`VehicleMake_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c032_vehiclemake` VALUES('C032001','Ape',1,0);
INSERT INTO `c032_vehiclemake` VALUES('C032002','Pickup',1,0);
INSERT INTO `c032_vehiclemake` VALUES('C032003','407',1,0);
INSERT INTO `c032_vehiclemake` VALUES('C032004','709',1,0);
INSERT INTO `c032_vehiclemake` VALUES('C032005','909',1,0);
INSERT INTO `c032_vehiclemake` VALUES('C032006','Truck',1,0);
INSERT INTO `c032_vehiclemake` VALUES('C032007','Tanker',1,0);

-- Dump completed on 2026-05-12 17:14:39
