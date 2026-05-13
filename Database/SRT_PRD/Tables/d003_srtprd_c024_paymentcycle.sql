-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c024_paymentcycle`;
CREATE TABLE `c024_paymentcycle` (
  `PaymentCycle_Id` varchar(10) NOT NULL,
  `PaymentCycle_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`PaymentCycle_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c024_paymentcycle` VALUES('C024001','1 Day',1,0);
INSERT INTO `c024_paymentcycle` VALUES('C024002','5 Day',1,0);
INSERT INTO `c024_paymentcycle` VALUES('C024003','10 Day',1,0);
INSERT INTO `c024_paymentcycle` VALUES('C024004','15 Day',1,0);
INSERT INTO `c024_paymentcycle` VALUES('C024005','1 Month',1,0);

-- Dump completed on 2026-05-12 17:14:39
