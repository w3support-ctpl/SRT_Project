-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c036_expensetype`;
CREATE TABLE `c036_expensetype` (
  `ExpenseType_Id` varchar(20) NOT NULL,
  `ExpenseType_Name` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`ExpenseType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c036_expensetype` VALUES('C036001','Repairing',1,0);
INSERT INTO `c036_expensetype` VALUES('C036002','Other',1,0);

-- Dump completed on 2026-05-12 17:14:39
