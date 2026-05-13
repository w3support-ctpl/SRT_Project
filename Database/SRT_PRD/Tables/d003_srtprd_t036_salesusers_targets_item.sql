-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t036_salesusers_targets_item`;
CREATE TABLE `t036_salesusers_targets_item` (
  `Org_Id` varchar(20) NOT NULL,
  `Entry_Id` varchar(45) NOT NULL,
  `Target_Id` varchar(45) DEFAULT NULL,
  `ProductGroup_Id` varchar(45) DEFAULT NULL,
  `Product_Id` varchar(45) DEFAULT NULL,
  `ProductUOM` varchar(45) DEFAULT NULL,
  `Quantity` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t036_salesusers_targets_item` VALUES('C005','T036A261000001','T036261000001','M023231000539','M01724M000131','KG','500');

-- Dump completed on 2026-05-12 17:16:17
