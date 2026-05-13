-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `mu10_user_otp`;
CREATE TABLE `mu10_user_otp` (
  `OTP_Request_Id` varchar(20) NOT NULL,
  `Org_Id` varchar(10) DEFAULT NULL,
  `Mobile_No` varchar(12) DEFAULT NULL,
  `OTP` varchar(10) DEFAULT NULL,
  `Generated_On` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`OTP_Request_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `mu10_user_otp` VALUES('MU10261000356','C005','9082654707','2433','05/11/2026 14:56:28');
INSERT INTO `mu10_user_otp` VALUES('MU10261000357','C005','9923560128','7865','05/11/2026 15:00:32');

-- Dump completed on 2026-05-12 17:15:50
