-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t040_salesinquiry_header`;
CREATE TABLE `t040_salesinquiry_header` (
  `Org_Id` varchar(10) NOT NULL,
  `SalesInquiry` varchar(20) NOT NULL,
  `Dealer_Id` varchar(20) DEFAULT NULL,
  `Retailer_Id` varchar(20) DEFAULT NULL,
  `SalesUser_Id` varchar(20) DEFAULT NULL,
  `SalesNoteText` varchar(45) DEFAULT NULL,
  `CustomerReference` varchar(45) DEFAULT NULL,
  `InquiryStatus_Id` int DEFAULT '0',
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL COMMENT 'If account is created by Farmer then Farmer Id will come here else Id of User who has created account will come here',
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  `SalesInquiryType` varchar(45) DEFAULT NULL,
  `SalesOrganization` varchar(45) DEFAULT NULL,
  `DistributionChannel` varchar(45) DEFAULT NULL,
  `OrganizationDivision` varchar(45) DEFAULT NULL,
  `CustomerPaymentTerms` varchar(45) DEFAULT NULL,
  `IncotermsClassification` varchar(45) DEFAULT NULL,
  `PurchaseOrderByCustomer` varchar(45) DEFAULT NULL,
  `DestinationText` varchar(45) DEFAULT NULL,
  `SoldToParty` varchar(45) DEFAULT NULL,
  `ShipToParty` varchar(45) DEFAULT NULL,
  `BillToParty` varchar(45) DEFAULT NULL,
  `Transporter` varchar(45) DEFAULT NULL,
  `Payer` varchar(45) DEFAULT NULL,
  `SalesPerson` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`SalesInquiry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040241000002','MU08241000152',NULL,NULL,NULL,NULL,0,1,0,'04/01/2024 17:34:26','MU03241000002','Gargi Thorat',NULL,NULL,NULL,'',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12241000003');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040241000003','MU08241000001',NULL,NULL,NULL,NULL,0,1,0,'04/03/2024 14:42:03','MU03231000001','Abasaheb Thorat',NULL,NULL,NULL,'',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12241000025');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040241000004','MU08241000370',NULL,NULL,NULL,NULL,0,1,0,'07/04/2024 17:17:53','MU03241000002','Gargi Thorat','07/04/2024 17:20:29','MU03241000002','Gargi Thorat','',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12241000012');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040241000005','MU08241000001',NULL,NULL,NULL,NULL,0,0,0,'07/18/2024 16:33:08','MU12241000030',NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12241000030');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040241000006','MU08241000001',NULL,NULL,NULL,NULL,0,0,0,'07/19/2024 15:55:05','MU12241000003',NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12241000003');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040241000008','MU08241000001',NULL,NULL,NULL,NULL,0,0,0,'10/15/2024 13:50:07','MU12241000011',NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12241000011');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040241000009','MU08241000038',NULL,NULL,NULL,NULL,0,0,0,'12/03/2024 16:19:37','MU12241000011',NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12241000011');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040251000001','MU08241000197','MU09221000126','MU12241000001',NULL,NULL,0,0,0,'08/20/2025 11:24:28','MU12241000001',NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12241000001');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040261000001',NULL,'','MU12251000005',NULL,NULL,0,0,0,'03/12/2026 16:08:14','MU08241000438',NULL,'03/12/2026 16:21:00','MU03241000028','Sachin Atre','',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12251000005');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040261000002',NULL,'','MU12251000005','Rate  1 box 1900',NULL,0,1,0,'03/12/2026 16:22:50','MU08241000438',NULL,'03/12/2026 16:25:41','MU03241000028','Sachin Atre','',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12251000005');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040261000003',NULL,'','MU12251000005',NULL,NULL,0,1,0,'03/13/2026 14:41:26','MU08241000438',NULL,'03/23/2026 15:44:40','MU03241000028','Sachin Atre','',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12251000005');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040261000009','MU08241000203','MU09221000173','MU12241000027',NULL,NULL,0,0,0,'03/24/2026 10:08:22','MU12241000027',NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12241000027');
INSERT INTO `t040_salesinquiry_header` VALUES('C005','T040261000010','MU08241000203','MU09221000173','MU12241000027',NULL,NULL,0,0,0,'03/24/2026 10:11:02','MU03241000028','Sachin Atre','03/24/2026 10:11:51','MU03241000028','Sachin Atre','',NULL,NULL,NULL,'','','',NULL,'','','','','','MU12241000027');

-- Dump completed on 2026-05-12 17:16:20
