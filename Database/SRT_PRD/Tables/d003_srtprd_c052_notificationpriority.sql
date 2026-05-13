-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c052_notificationpriority`;
CREATE TABLE `c052_notificationpriority` (
  `Org_Id` varchar(10) NOT NULL,
  `NotificationPriority_Id` varchar(255) NOT NULL,
  `NotificationPriority_Name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`NotificationPriority_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c052_notificationpriority` VALUES('C005','1','Very High');
INSERT INTO `c052_notificationpriority` VALUES('C005','2','High');
INSERT INTO `c052_notificationpriority` VALUES('C005','3','Medium');
INSERT INTO `c052_notificationpriority` VALUES('C005','4','Low');

-- Dump completed on 2026-05-12 17:14:40
