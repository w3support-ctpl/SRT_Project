-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m019_salesuserroute_item_dealer`;
CREATE TABLE `m019_salesuserroute_item_dealer` (
  `Org_Id` varchar(20) NOT NULL,
  `SalesUser_Id` varchar(45) NOT NULL,
  `Dealer_Id` varchar(20) NOT NULL,
  PRIMARY KEY (`Org_Id`,`SalesUser_Id`,`Dealer_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `m019_salesuserroute_item_dealer` VALUES('C005','MU12241000003','MU08241000521');
INSERT INTO `m019_salesuserroute_item_dealer` VALUES('C005','MU12241000011','MU08241000120');

-- Dump completed on 2026-05-12 17:15:49
