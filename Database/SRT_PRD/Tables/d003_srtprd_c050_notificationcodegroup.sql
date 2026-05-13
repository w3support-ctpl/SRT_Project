-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c050_notificationcodegroup`;
CREATE TABLE `c050_notificationcodegroup` (
  `Org_Id` varchar(10) NOT NULL,
  `NotificationCodeGroup_Id` varchar(255) NOT NULL,
  `NotificationCodeGroup_Name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`NotificationCodeGroup_Id`,`Org_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c050_notificationcodegroup` VALUES('C005','QM-COD','Problem Details');

-- Dump completed on 2026-05-12 17:14:40
