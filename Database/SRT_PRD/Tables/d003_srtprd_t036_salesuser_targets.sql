-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t036_salesuser_targets`;
CREATE TABLE `t036_salesuser_targets` (
  `Org_Id` varchar(20) NOT NULL,
  `Entry_Id` varchar(45) NOT NULL,
  `SalesUser_Id` varchar(45) DEFAULT NULL,
  `Month_Year` date DEFAULT NULL,
  `FinancialYear_Id` varchar(45) DEFAULT NULL,
  `Dealer_Id` varchar(45) DEFAULT NULL,
  `ProductGroup_Id` varchar(45) DEFAULT NULL,
  `Product_Id` varchar(45) DEFAULT NULL,
  `ProductUOM` varchar(45) DEFAULT NULL,
  `Quantity` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t036_salesuser_targets` VALUES('C005','T036241000001','MU12241000003','07/01/2024',NULL,'MU08241000285',NULL,'M023231000532',NULL,'100',1,0,'07/19/2024 13:01:42','MU03231000001','Abasaheb Thorat','07/19/2024 13:02:09','MU03231000001','Abasaheb Thorat');
INSERT INTO `t036_salesuser_targets` VALUES('C005','T036241000002','MU12241000003','07/01/2024',NULL,'MU08241000285',NULL,'M023231000534',NULL,'120',1,0,'07/19/2024 15:41:06','MU03231000001','Abasaheb Thorat',NULL,NULL,NULL);
INSERT INTO `t036_salesuser_targets` VALUES('C005','T036241000003','MU12241000013','10/01/2024',NULL,'MU08241000113','M023231000631','M01724M000052','BOX','5',1,0,'09/30/2024 11:53:11','MU03231000001','Abasaheb Thorat',NULL,NULL,NULL);
INSERT INTO `t036_salesuser_targets` VALUES('C005','T036241000004','MU12241000013','10/01/2024',NULL,'MU08241000113','M023231000631','M01724M000050','BOX','10',1,0,'09/30/2024 11:53:41','MU03231000001','Abasaheb Thorat',NULL,NULL,NULL);

-- Dump completed on 2026-05-12 17:16:17
