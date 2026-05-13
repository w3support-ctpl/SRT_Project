-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t101_mcc_material_inward_item`;
CREATE TABLE `t101_mcc_material_inward_item` (
  `Org_Id` varchar(10) NOT NULL,
  `Entry_Id` varchar(45) NOT NULL,
  `Inward_Id` varchar(45) DEFAULT NULL,
  `Material_Id` varchar(45) DEFAULT NULL,
  `Purchase_Amount` decimal(30,2) DEFAULT NULL,
  `Selling_Amount` decimal(30,2) DEFAULT NULL,
  `Purchase_Unit` varchar(45) DEFAULT NULL,
  `Quantity` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t101_mcc_material_inward_item` VALUES('C005','T101A251000001','T101251000001','M101251000013',1550.00,1600.00,'EA','50');
INSERT INTO `t101_mcc_material_inward_item` VALUES('C005','T101A251000002','T101251000002','M101251000016',1480.00,1500.00,'EA','10');
INSERT INTO `t101_mcc_material_inward_item` VALUES('C005','T101A251000003','T101251000003','M101251000018',1210.00,1220.00,'EA','10');

-- Dump completed on 2026-05-12 17:16:20
