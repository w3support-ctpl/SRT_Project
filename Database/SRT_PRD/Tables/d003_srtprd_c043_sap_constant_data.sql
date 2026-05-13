-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c043_sap_constant_data`;
CREATE TABLE `c043_sap_constant_data` (
  `Org_Id` varchar(10) NOT NULL,
  `Entry_Id` int NOT NULL,
  `API_Name` varchar(50) DEFAULT NULL,
  `Constant_Name` varchar(255) DEFAULT NULL,
  `Constant_Value` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c043_sap_constant_data` VALUES('C005',1,'FarmerBP','BusinessPartnerRole1','FLVN00');
INSERT INTO `c043_sap_constant_data` VALUES('C005',2,'FarmerBP','BusinessPartnerRole2','FLVN01');
INSERT INTO `c043_sap_constant_data` VALUES('C005',3,'FarmerBP','CompanyCode','1000');
INSERT INTO `c043_sap_constant_data` VALUES('C005',4,'FarmerBP','ReconciliationAccount','10501110');
INSERT INTO `c043_sap_constant_data` VALUES('C005',5,'MCCBP','BusinessPartnerRole1','FLVN00');
INSERT INTO `c043_sap_constant_data` VALUES('C005',6,'MCCBP','BusinessPartnerRole2','FLVN01');
INSERT INTO `c043_sap_constant_data` VALUES('C005',7,'MCCBP','CompanyCode','1000');
INSERT INTO `c043_sap_constant_data` VALUES('C005',8,'MCCBP','ReconciliationAccount11','10501020');
INSERT INTO `c043_sap_constant_data` VALUES('C005',9,'MCCBP','ReconciliationAccount12','10501010');
INSERT INTO `c043_sap_constant_data` VALUES('C005',10,'MCCBP','ReconciliationAccount21','10501040');
INSERT INTO `c043_sap_constant_data` VALUES('C005',11,'MCCBP','ReconciliationAccount22','10501030');
INSERT INTO `c043_sap_constant_data` VALUES('C005',12,'MCCBP','ReconciliationAccount3','10501050');
INSERT INTO `c043_sap_constant_data` VALUES('C005',13,'TransporterBP','BusinessPartnerRole1','FLVN00');
INSERT INTO `c043_sap_constant_data` VALUES('C005',14,'TransporterBP','BusinessPartnerRole2','FLVN01');
INSERT INTO `c043_sap_constant_data` VALUES('C005',15,'TransporterBP','CompanyCode','1000');
INSERT INTO `c043_sap_constant_data` VALUES('C005',16,'TransporterBP','ReconciliationAccount','10501080');
INSERT INTO `c043_sap_constant_data` VALUES('C005',17,'MaterialDocumentHeader','Plant','1100');
INSERT INTO `c043_sap_constant_data` VALUES('C005',18,'MaterialDocumentHeader','StorageLocation','RMT1');
INSERT INTO `c043_sap_constant_data` VALUES('C005',19,'MaterialDocumentHeader','GoodsMovementType','Z61');
INSERT INTO `c043_sap_constant_data` VALUES('C005',20,'MaterialDocumentHeader','GoodsMovementCode','05');
INSERT INTO `c043_sap_constant_data` VALUES('C005',21,'BATCH','CharcInternalID_TOTQTY','821');
INSERT INTO `c043_sap_constant_data` VALUES('C005',22,'BATCH','CharcInternalID_FAT','815');
INSERT INTO `c043_sap_constant_data` VALUES('C005',23,'BATCH','CharcInternalID_SNF','816');
INSERT INTO `c043_sap_constant_data` VALUES('C005',24,'BATCH','CharcInternalID_TOTFAT','819');
INSERT INTO `c043_sap_constant_data` VALUES('C005',25,'BATCH','CharcInternalID_TOTSNF','820');
INSERT INTO `c043_sap_constant_data` VALUES('C005',26,'BATCH','CharcInternalID_FATCOST','818');
INSERT INTO `c043_sap_constant_data` VALUES('C005',27,'BATCH','CharcInternalID_SNFCOST','817');
INSERT INTO `c043_sap_constant_data` VALUES('C005',28,'FarmerVoucher','AccountingDocumentType','ZM');
INSERT INTO `c043_sap_constant_data` VALUES('C005',29,'FarmerVoucher','CompanyCode','1000');
INSERT INTO `c043_sap_constant_data` VALUES('C005',30,'FarmerVoucher','GLAccount_Gross','0010501230');
INSERT INTO `c043_sap_constant_data` VALUES('C005',31,'FarmerVoucher','GLAccount_Freight','0030103080');
INSERT INTO `c043_sap_constant_data` VALUES('C005',32,'FarmerVoucher','Debtor','530025');
INSERT INTO `c043_sap_constant_data` VALUES('C005',33,'FarmerVoucher','Creditor','530025');
INSERT INTO `c043_sap_constant_data` VALUES('C005',34,'FarmerVoucher','AltvRecnclnAccts_Anamat','10501200');
INSERT INTO `c043_sap_constant_data` VALUES('C005',35,'FarmerVoucher','AltvRecnclnAccts_Loan','20407020');
INSERT INTO `c043_sap_constant_data` VALUES('C005',36,'FarmerVoucher','AltvRecnclnAccts_Advance','20407010');
INSERT INTO `c043_sap_constant_data` VALUES('C005',37,'MaterialDocumentHeader','Material1','CGM');
INSERT INTO `c043_sap_constant_data` VALUES('C005',38,'MaterialDocumentHeader','Material2','BGM');
INSERT INTO `c043_sap_constant_data` VALUES('C005',39,'MCCVoucher','AccountingDocumentType','ZM');
INSERT INTO `c043_sap_constant_data` VALUES('C005',40,'MCCVoucher','CompanyCode','1000');
INSERT INTO `c043_sap_constant_data` VALUES('C005',41,'MCCVoucher','GLAccount_Gross','0010501230');
INSERT INTO `c043_sap_constant_data` VALUES('C005',42,'MCCVoucher','GLAccount_Loss','0040401380');
INSERT INTO `c043_sap_constant_data` VALUES('C005',43,'TransporterVoucher','AccountingDocumentType','ZT');
INSERT INTO `c043_sap_constant_data` VALUES('C005',44,'TransporterVoucher','CompanyCode','1000');
INSERT INTO `c043_sap_constant_data` VALUES('C005',45,'TransporterVoucher','GLAccount1','0010501230');
INSERT INTO `c043_sap_constant_data` VALUES('C005',46,'TransporterVoucher','GLAccount2','0010501230');
INSERT INTO `c043_sap_constant_data` VALUES('C005',47,'TransporterVoucher','GLAccount3','0040102273');
INSERT INTO `c043_sap_constant_data` VALUES('C005',48,'TransporterVoucher','GLAccount4','0040102272');
INSERT INTO `c043_sap_constant_data` VALUES('C005',49,'MaterialDocumentHeader','Material3','RCGM');
INSERT INTO `c043_sap_constant_data` VALUES('C005',50,'MaterialDocumentHeader','Material4','RBGM');
INSERT INTO `c043_sap_constant_data` VALUES('C005',51,'MCCVoucher','AccountingDocumentTypeGL','ZL');
INSERT INTO `c043_sap_constant_data` VALUES('C005',52,'MCCVoucher','AccountingDocumentTypeMPPI','ZM');
INSERT INTO `c043_sap_constant_data` VALUES('C005',200,'MaterialDocumentHeaderCrate','StorageLocation','CACR');
INSERT INTO `c043_sap_constant_data` VALUES('C005',201,'MaterialDocumentHeaderCrate','GoodsMovementType','Z01');
INSERT INTO `c043_sap_constant_data` VALUES('C005',202,'MaterialDocumentHeaderCrate','EntryUnit','EA');
INSERT INTO `c043_sap_constant_data` VALUES('C005',204,'MCCVoucher','AltvRecnclnAccts_Advance','20407010');
INSERT INTO `c043_sap_constant_data` VALUES('C005',206,'MCCVoucher','AltvRecnclnAccts_Anamat','10501200');
INSERT INTO `c043_sap_constant_data` VALUES('C005',207,'MCCVoucher','GLAccount_Freight','0030103080');
INSERT INTO `c043_sap_constant_data` VALUES('C005',208,'TransporterVoucher','GLAccount5','0010501230');
INSERT INTO `c043_sap_constant_data` VALUES('C005',209,'RebateVoucher','CompanyCode','1000');
INSERT INTO `c043_sap_constant_data` VALUES('C005',230,'RebateVoucher','GLAccount_Rebate','40102261');
INSERT INTO `c043_sap_constant_data` VALUES('C005',231,'MCCVoucher','GLAccount_Protein','');
INSERT INTO `c043_sap_constant_data` VALUES('C005',232,'MCCVoucher','GLAccount_Ash','');
INSERT INTO `c043_sap_constant_data` VALUES('C005',233,'MCCVoucher','GLAccount_Sodium','');
INSERT INTO `c043_sap_constant_data` VALUES('C005',234,'MCCVoucher','GLAccount_Incentives','');
INSERT INTO `c043_sap_constant_data` VALUES('C005',235,'MaterialDocumentHeader','Material5','600018');
INSERT INTO `c043_sap_constant_data` VALUES('C005',236,'BATCH','CharcInternalID_SPGRYCOST','827');

-- Dump completed on 2026-05-12 17:14:40
