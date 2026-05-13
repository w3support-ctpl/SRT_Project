-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c033_paymenttype`;
CREATE TABLE `c033_paymenttype` (
  `PaymentType_Id` varchar(10) NOT NULL,
  `PaymentType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`PaymentType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c033_paymenttype` VALUES('C033001','SRT Dairy',1,0);
INSERT INTO `c033_paymenttype` VALUES('C033002','Third Party',1,0);

-- Dump completed on 2026-05-12 17:14:39
