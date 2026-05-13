-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c044_sales_user_role`;
CREATE TABLE `c044_sales_user_role` (
  `SalesUserRole_Id` varchar(20) NOT NULL,
  `SalesUserRole_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`SalesUserRole_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c044_sales_user_role` VALUES('C044001','Sales Person');
INSERT INTO `c044_sales_user_role` VALUES('C044002','ASM');

-- Dump completed on 2026-05-12 17:14:40
