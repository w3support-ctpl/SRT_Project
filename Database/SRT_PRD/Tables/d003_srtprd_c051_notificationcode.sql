-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c051_notificationcode`;
CREATE TABLE `c051_notificationcode` (
  `Org_Id` varchar(10) NOT NULL,
  `NotificationCode_Id` varchar(255) NOT NULL,
  `NotificationCode_Name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`NotificationCode_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c051_notificationcode` VALUES('C005','001','Logistical Issue');
INSERT INTO `c051_notificationcode` VALUES('C005','002','Printing and Packaging issue');
INSERT INTO `c051_notificationcode` VALUES('C005','003','Cold chain issue');
INSERT INTO `c051_notificationcode` VALUES('C005','004','Leakage and Product damage');
INSERT INTO `c051_notificationcode` VALUES('C005','005','Odor and taste issue');
INSERT INTO `c051_notificationcode` VALUES('C005','006','Physical Appearance');
INSERT INTO `c051_notificationcode` VALUES('C005','007','Nearby expiry');
INSERT INTO `c051_notificationcode` VALUES('C005','008','Volume / Weighment issue');
INSERT INTO `c051_notificationcode` VALUES('C005','009','Storage Issue');
INSERT INTO `c051_notificationcode` VALUES('C005','010','Suggestion for Improvement');
INSERT INTO `c051_notificationcode` VALUES('C005','011','Other');

-- Dump completed on 2026-05-12 17:14:40
