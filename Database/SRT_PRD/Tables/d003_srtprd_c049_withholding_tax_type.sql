-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c049_withholding_tax_type`;
CREATE TABLE `c049_withholding_tax_type` (
  `WithholdingTaxType_Id` varchar(45) NOT NULL,
  `WithholdingTaxType` varchar(45) DEFAULT NULL,
  `WithholdingTaxType_Name` varchar(255) DEFAULT NULL,
  `WithholdingTaxType_Code` varchar(45) DEFAULT NULL,
  `Recipient` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`WithholdingTaxType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c049_withholding_tax_type` VALUES('C048001','','NaN','','',1,0);
INSERT INTO `c049_withholding_tax_type` VALUES('C048002','1H','194H- Brokerage and commission(INV)','H1','OT',1,0);
INSERT INTO `c049_withholding_tax_type` VALUES('C048003','4Q','194Q- Pur of Goods (Invoice)','4Q','OT',1,0);

-- Dump completed on 2026-05-12 17:14:40
