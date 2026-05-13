-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t040_salesinquiry_item`;
CREATE TABLE `t040_salesinquiry_item` (
  `Org_Id` varchar(10) NOT NULL,
  `Material` varchar(20) NOT NULL,
  `SalesInquiry` varchar(20) NOT NULL,
  `Rate` varchar(20) DEFAULT NULL,
  `RequestedQuantity` varchar(45) DEFAULT NULL,
  `LrDetailsText` longtext,
  `ProductionInstructionsText` longtext,
  `UOM` varchar(45) DEFAULT NULL,
  `Price` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Material`,`SalesInquiry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000001','T040241000005','0.00','1','','','CRT','0');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000001','T040241000006','0.00','2','','','CRT','0');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000002','T040241000006','0.00','1','','','CRT','0');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000037','T040241000008','300.00','19','','','BAG','5700');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000037','T040241000009','300.00','3','','','BAG','900');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000059','T040241000003',NULL,'2','','','BOX',NULL);
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000130','T040251000001','1.00','1','','','KG','1.00');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000136','T040261000009','228.57','1','210 per kg ya rate madhe pahije
','','KG','228.57');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000144','T040241000002','20.00','200','','','BOX','4000');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000145','T040261000001','410.00','1','i required for rate','','KG','410.00');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000145','T040261000003','390.00','1','Testing','','KG','390.00');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000148','T040261000002','1800.00','1','Testing for app','','BOX','1800.00');
INSERT INTO `t040_salesinquiry_item` VALUES('C005','M01724M000154','T040241000004','20.00','500','','','KG','10000');

-- Dump completed on 2026-05-12 17:16:20
