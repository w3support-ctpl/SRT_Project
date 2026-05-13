-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t032_dispatchstock_item`;
CREATE TABLE `t032_dispatchstock_item` (
  `Org_Id` varchar(20) NOT NULL,
  `Dispatchstock_Id` varchar(45) NOT NULL,
  `Material_Id` varchar(45) NOT NULL,
  `Stock_Type` varchar(100) DEFAULT NULL,
  `Dispatched_Quantity` int DEFAULT '0',
  `Accepted_Quantity` int DEFAULT '0',
  PRIMARY KEY (`Org_Id`,`Dispatchstock_Id`,`Material_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t032_dispatchstock_item` VALUES('C005','T032241000001','M010241000020','Material',40,0);
INSERT INTO `t032_dispatchstock_item` VALUES('C005','T032251000001','M010241000020','Material',18,0);
INSERT INTO `t032_dispatchstock_item` VALUES('C005','T032251000002','M010241000020','Material',4,0);
INSERT INTO `t032_dispatchstock_item` VALUES('C005','T032251000003','M010241000020','Material',4,0);

-- Dump completed on 2026-05-12 17:16:16
