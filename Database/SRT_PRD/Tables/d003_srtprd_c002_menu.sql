-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c002_menu`;
CREATE TABLE `c002_menu` (
  `Menu_Id` varchar(20) NOT NULL,
  `Application_Id` varchar(10) DEFAULT NULL,
  `Menu_Name` varchar(50) DEFAULT NULL,
  `Menu_Level` int DEFAULT NULL COMMENT '1 = Top Level, 2 = Sub Menu',
  `Parent_Menu_Id` varchar(10) DEFAULT NULL COMMENT 'Parent Menu Id if Menu_Level is 2',
  `Display_Order_Number` decimal(4,2) DEFAULT NULL,
  `Menu_Link` varchar(200) DEFAULT NULL,
  `Menu_Icon_Name` varchar(50) DEFAULT NULL,
  `Menu_Tooltip` varchar(100) DEFAULT NULL,
  `Is_Active` int DEFAULT NULL,
  `Is_Deleted` int DEFAULT NULL,
  PRIMARY KEY (`Menu_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c002_menu` VALUES('M001','MI','Dashboard',0,'0',1.00,'/Home/Index','fe-airplay',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M002','MI','Users',NULL,'0',2.00,'#','fe-users',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M003','MI','Farmer',NULL,'M002',2.10,'/Users/Farmer',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M004','MI','Agent',NULL,'M002',2.20,'/Users/Agent',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M005','MI','Driver',NULL,'M002',2.30,'/Users/Driver',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M006','MI','Chemist',NULL,'M002',2.40,'/Users/Chemist',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M007','MI','Office User',NULL,'M002',2.50,'/Users/User',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M008','MI','Role',NULL,'M050',5.95,'/Masters/Role','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M009','MI','Milk',NULL,'M014',4.30,'/Rate/Milk','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M010','MI','Incentive Scheme',NULL,'M050',5.70,'/Masters/IncentiveScheme','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M011','MI','MCC Commission',NULL,'M014',4.40,'/Rate/MCCCommission',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M012','MI','Correction Requests',NULL,'M033',10.10,'/Approvals/CorrectionL2','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M013','MI','Vehicle',NULL,'M050',5.30,'/Masters/Vehicle',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M014','MI','Rate',NULL,'0',4.00,'','fe-book-open',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M015','MI','Vehicle Freight',NULL,'M014',4.50,'/Rate/Freight',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M016','MI','Services',NULL,'M050',5.80,'/Masters/Services',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M017','MI','Facilities',NULL,'M050',5.90,'/Masters/Facilities',NULL,NULL,0,1);
INSERT INTO `c002_menu` VALUES('M018','MI','Transporter',NULL,'M050',5.20,'/Masters/Transporter',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M019','MI','MCC',NULL,'M050',5.10,'/Masters/MCC',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M020','MI','Approvals L1',NULL,'0',9.00,'#','fe-check',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M021','MI','Material',NULL,'M050',5.60,'/Masters/Material','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M022','MI','Route',NULL,'M063',6.10,'/Transporter/Route','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M023','MI','Truck Sheet',NULL,'M063',6.30,'/Transporter/TruckSheet',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M024','MI','Manage',NULL,'0',11.00,'#','fe-cpu',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M025','MI','Reports',NULL,'0',12.00,'#','fe-filter',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M026','MI','Issue Empty Cans',NULL,'M024',11.35,'/Manage/IssueEmptyCans',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M028','MI','Location',NULL,'0',3.00,'#','fe-map-pin',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M029','MI','State',NULL,'M028',3.10,'/Location/State',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M030','MI','District',NULL,'M028',3.20,'/Location/District',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M031','MI','Taluka',NULL,'M028',3.30,'/Location/Taluka',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M032','MI','Village',NULL,'M028',3.40,'/Location/Village',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M033','MI','Approvals L2',NULL,'0',10.00,'#','fe-check-circle',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M034','MI','Agent Registration',NULL,'M020',9.20,'#',NULL,NULL,0,0);
INSERT INTO `c002_menu` VALUES('M035','MI','Farmer Registration',NULL,'M020',9.10,'/Approvals/FarmerRegistration',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M036','MI','Agent Service Request',NULL,'M020',9.45,'/Approvals/AgentService',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M037','MI','Farmer Service Request',NULL,'M020',9.40,'/Approvals/FarmerService ',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M038','MI','Farmer Incentive Request',NULL,'M020',9.50,'/Approvals/FarmerIncentive',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M039','MI','Agent Incentive Request',NULL,'M020',9.55,'/Approvals/AgentIncentive',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M040','MI','Correction Requests',NULL,'M020',9.30,'/Approvals/CorrectionL1',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M041','MI','Deductions',NULL,'M070',8.03,'/Manage/Deductions',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M042','MI','Farmer Incentive Schemes',NULL,'M024',11.20,'/Manage/FarmerIncentiveSchemes',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M043','MI','Agent Incentive Schemes',NULL,'M024',11.30,'/Manage/AgentIncentiveSchemes',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M044','MI','Material Issue to MCC',NULL,'M024',11.40,'/Manage/MaterialIssueToMCC',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M045','MI','Milk Collection',NULL,'M025',12.10,'/Report/MilkCollection','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M046','MI','Milk Collection',NULL,'0',7.00,'#','fe-database',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M047','MI','Milk Receipt',NULL,'M046',7.10,'/Collection/MilkCollection',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M049','MI','Trip Document',NULL,'M046',7.30,'/Collection/Trip',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M050','MI','Masters',NULL,'0',5.00,'#','fe-grid',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M051','MI','SNF Slabs',NULL,'M014',4.20,'/Rate/SNFSlab',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M052','MI','Fat Slabs',NULL,'M014',4.10,'/Rate/FatSlab',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M053','MI','Diesel',NULL,'M014',4.60,'/Rate/Diesel',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M054','MI','Product',NULL,'M050',5.65,'/Masters/Product','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M055','MI','Bank',NULL,'M050',5.91,'/Masters/Bank','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M056','MI','Material Return from MCC',NULL,'M024',11.50,'/Manage/MaterialReturnFromMCC',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M057','MI','Complaints',NULL,'M024',11.60,'/Manage/Complaints',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M058','MI','Remote Calibration',NULL,'M024',11.70,'/Manage/RemoteCalibration',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M059','MI','Farmer Orders',NULL,'M020',9.85,'/Approvals/FarmerOrders',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M060','MI','Agent Orders',NULL,'M020',9.90,'/Approvals/AgentOrders',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M061','MI','Milk Collection Requests',NULL,'M020',9.29,'/Approvals/CollectionRequest',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M062','MI','Tanker Sheet',NULL,'M063',6.20,'/Transporter/TankerSheet','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M063','MI','Transporter',NULL,'0',6.00,'#','fe-truck',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M064','MI','Manage Trip',NULL,'M063',6.40,'/Transporter/ManageTrip','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M065','MI','Fat SNF Ratio',NULL,'M014',4.70,'/Rate/FatSNFRatio',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M066','MI','Goods Inward Posting',NULL,'M046',7.50,'/Collection/GoodsInwardPosting',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M067','MI','Survey',NULL,'M063',6.50,'/Transporter/Survey','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M068','MI','Farmer Data Correction',NULL,'M020',9.11,'/Approvals/FarmerDataCorrection',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M069','MI','Collection Approval',NULL,'M046',7.40,'/Collection/CollectionApproval',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M070','MI','Procurement Invoicing',NULL,'0',8.00,'#','fe-file-text',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M071','MI','Farmer Posting',NULL,'M070',8.10,'/Invoice/Farmer',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M072','MI','MCC Posting',NULL,'M070',8.20,'/Invoice/MCC',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M073','MI','Transporter Posting',NULL,'M070',8.30,'/Invoice/Transporter',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M074','MI','Agent Data Correction',NULL,'M020',9.25,'/Approvals/AgentDataCorrection',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M075','MI','Quality Entry',NULL,'M046',7.20,'/Collection/QualityEntry',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M076','MI','Gain - Loss Entry',NULL,'M046',7.35,'/Collection/GainLossEntry',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M077','MI','Farmer Income',NULL,'M070',8.01,'/Invoice/FarmerIncome',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M078','MI','Procurement Invoice',NULL,'M025',12.20,'/Report/Invoice','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M079','MI','Incentives',NULL,'M070',8.02,'/Manage/Incentives',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M080','MI','Invoice Publish',NULL,'M070',8.40,'/Invoice/InvoicePublish',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M081','MI','Diesel Upload',NULL,'M063',6.60,'/Transporter/DieselUpload','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M082','MI','Missing Farmer Milk Entry',NULL,'M070',8.50,'/Invoice/MissingFarmerMilkEntry',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M083','MI','Rebate',NULL,'M070',8.60,'/Invoice/Rebate',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M084','MI','Rate Change',NULL,'M070',8.70,'/Invoice/RateChange',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M085','MI','SAP Posting',NULL,'M070',8.80,'/Invoice/SAPPosting',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M501','MO','Dashboard',NULL,'0',1.00,'/Home/Index','fe-airplay',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M502','MO','Masters',NULL,'0',2.00,'#','fe-layers',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M503','MO','Dealer',NULL,'M502',2.40,'/Masters/Dealer','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M504','MO','Retailer',NULL,'M502',2.50,'/Masters/Retailer','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M505','MO','Sales Group',NULL,'M502',2.20,'/Masters/SalesGroup','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M506','MO','Primary',NULL,'0',3.00,'#','fe-send',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M507','MO','Inquiry',NULL,'M506',3.10,'/Inquiry/index','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M508','MO','Quotation',NULL,'M506',3.20,'/Quotation/index','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M509','MO','Sales Order',NULL,'M506',3.30,'/SalesOrder/index','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M510','MO','Delivery',NULL,'M506',3.40,'/Delivery/index','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M511','MO','Invoice',NULL,'M506',3.50,'/Invoice/index','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M512','MO','Payment',NULL,'M506',3.60,'/Payment/index','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M513','MO','Sales Return Request',NULL,'M506',3.70,'/SalesReturnRequest/index','',NULL,0,1);
INSERT INTO `c002_menu` VALUES('M514','MO','Credit Memo Request',NULL,'M506',3.80,'/CreditMemoRequest/index','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M515','MO','Secondary',NULL,'0',4.00,'#','fe-tag',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M516','MO','Retailer Order',NULL,'M515',4.10,'/Secondary/RetailerOrder','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M517','MO','Retailer Delivery',NULL,'M515',4.50,'/RetailerDelivery/index','',NULL,0,1);
INSERT INTO `c002_menu` VALUES('M518','MO','Retailer Sales Return',NULL,'M515',4.30,'/RetailerSalesReturn/index','',NULL,0,1);
INSERT INTO `c002_menu` VALUES('M519','MO','Damage/Scrap entry',NULL,'M515',4.40,'/DamageScrapEntry/index','',NULL,0,1);
INSERT INTO `c002_menu` VALUES('M520','MO','Transactions',NULL,'0',5.00,'#','fe-package',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M521','MO','Sales User Route',NULL,'M502',5.10,'/Transactions/SalesUserRoute','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M522','MO','Targets',NULL,'M520',5.20,'/Transactions/Targets','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M523','MO','Retailers Authorization',NULL,'M520',5.30,'/Transactions/RetailersAuthorization','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M524','MO','Crate Dispatch to Dealer',NULL,'M520',5.40,'/Transactions/CrateDispatched','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M525','MO','Crate Received from Dealer',NULL,'M520',5.50,'/Transactions/CrateReceived','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M526','MO','Notification',NULL,'M520',5.60,'/Transactions/Notification','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M527','MO','Complaints',NULL,'M520',5.70,'/Transactions/Complaints','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M528','MO','Product',NULL,'M502',2.10,'/Masters/Product','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M529','MO','Sales User',NULL,'M502',2.30,'/Masters/SalesUser','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M530','MO','Role',NULL,'M502',2.60,'/Masters/Role','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M531','MO','Office Users',NULL,'M502',2.70,'/Masters/OfficeUsers','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M532','MO','Schemes',NULL,'M502',2.80,'/Masters/Schemes','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M533','MO','Dealer Stock',NULL,'M515',4.20,'/Secondary/DealerStock','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M534','MO','Debit Memo Request',NULL,'M506',3.90,'/DebitMemoRequest/Index',NULL,NULL,1,0);
INSERT INTO `c002_menu` VALUES('M535','MO','Account Statement',NULL,'M506',3.95,'/AccountStatement/Index',NULL,NULL,0,1);
INSERT INTO `c002_menu` VALUES('M536','MO','Crate Approve',NULL,'M520',5.55,'/Transactions/CrateApprove','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M537','MO','Reports',NULL,'0',6.00,'#','fe-filter',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M538','MO','Crate Register',NULL,'M537',6.10,'/Report/CrateRegister','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M539','MO','Master Sync SAP',NULL,'M502',2.65,'/Masters/MasterSync','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M540','MO','Complaint Type',NULL,'M502',2.90,'/Masters/ComplaintType','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M541','MO','Transporter',NULL,'0',7.00,'#','fe-truck',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M542','MO','Route',NULL,'M541',7.10,'/Transporter/Route','',NULL,1,0);
INSERT INTO `c002_menu` VALUES('M543','MO','Route',NULL,'M502',2.40,'/Masters/Route',NULL,NULL,1,0);

-- Dump completed on 2026-05-12 17:14:38
