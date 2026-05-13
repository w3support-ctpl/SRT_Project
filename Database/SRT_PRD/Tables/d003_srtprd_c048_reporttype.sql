-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c048_reporttype`;
CREATE TABLE `c048_reporttype` (
  `ReportType_Id` varchar(10) NOT NULL,
  `ReportType_Name` varchar(200) DEFAULT NULL,
  `ReportGroup` varchar(10) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`ReportType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c048_reporttype` VALUES('C048001','Detail Report (Date | MCC | Shift | Milk Type)','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048002','Summary Report (Date | MCC Type | Shift | Milk Type)','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048003','Farmer Report (Date | Farmer | MCC | Shift | Milk Type)','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048004','Procurement Invoice','MI',1,0);
INSERT INTO `c048_reporttype` VALUES('C048005','MPPI Invoice','MI',1,0);
INSERT INTO `c048_reporttype` VALUES('C048006','Dairy Anamat Register','MI',1,0);
INSERT INTO `c048_reporttype` VALUES('C048007','Transporter Invoice','MI',0,1);
INSERT INTO `c048_reporttype` VALUES('C048008','Milk Payment Vs Dairy Collection (MCC)','MI',1,0);
INSERT INTO `c048_reporttype` VALUES('C048009','Inward Freight Report (Date | Transporter | Vehicle | Trip)','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048010','Dealer Crate Register','CR',1,0);
INSERT INTO `c048_reporttype` VALUES('C048011','RMRD Sour Milk Report (Date | MCC | Shift)','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048012','MCC Report (MCC | Milk Type)','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048013','ZRTDRS','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048014','Collection Trend Analysis Report','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048015','Day Wise Sample Report','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048016','Rate Chart Display Report','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048017','Collection Vehicle Duration Report','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048018','Diesel Issue Report','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048019','GRN vs Actual Payment ( Date )','MI',1,0);
INSERT INTO `c048_reporttype` VALUES('C048020','MCC''s Skipped Report','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048021','MPPI Invoice ( SAP )','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048022','Crate Ledger Daily','CR',1,0);
INSERT INTO `c048_reporttype` VALUES('C048023','Crate Ledger Weekly','CR',1,0);
INSERT INTO `c048_reporttype` VALUES('C048024','Crate Ledger Monthly','CR',1,0);
INSERT INTO `c048_reporttype` VALUES('C048025','Crate Ledger Yearly','CR',1,0);
INSERT INTO `c048_reporttype` VALUES('C048026','Farmer Report Without Dispatch (Date | Farmer | MCC | Shift | Milk Type)','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048027','GRN vs Actual Payment ( Muster Cycle )','MI',1,0);
INSERT INTO `c048_reporttype` VALUES('C048028','Rate Chart Display Report II','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048029','Sour Milk Report','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048030','Issue Can','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048031','Rate Chart Display Report III','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048032','Rate Chart Display Report IV','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048033','Advance Report','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048034','Order History Report','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048035','MPPI Rate Chart Display Report','MC',1,0);
INSERT INTO `c048_reporttype` VALUES('C048036','Inward Freight Report (Date | Transporter | Vehicle | Trip) II','MC',1,0);

-- Dump completed on 2026-05-12 17:14:40
