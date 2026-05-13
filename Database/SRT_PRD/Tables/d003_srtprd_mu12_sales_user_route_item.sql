-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `mu12_sales_user_route_item`;
CREATE TABLE `mu12_sales_user_route_item` (
  `Org_Id` varchar(20) NOT NULL,
  `SalesUser_Id` varchar(45) NOT NULL,
  `Route_Id` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `mu12_sales_user_route_item` VALUES('C005','MU12241000001','MU19261000001');
INSERT INTO `mu12_sales_user_route_item` VALUES('C005','MU12241000027','MU19261000002');

-- Dump completed on 2026-05-12 17:15:51
