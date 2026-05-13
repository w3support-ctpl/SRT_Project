-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t026_datacorrection_request`;
CREATE TABLE `t026_datacorrection_request` (
  `Org_Id` varchar(10) NOT NULL,
  `Request_Id` varchar(20) NOT NULL,
  `MCC_Id` varchar(45) DEFAULT NULL,
  `Request_For` varchar(45) DEFAULT NULL,
  `Request_For_User_Id` varchar(20) DEFAULT NULL,
  `Request_By` varchar(45) DEFAULT NULL,
  `Request_By_User_Id` varchar(20) DEFAULT NULL,
  `Request_Type` varchar(45) DEFAULT NULL,
  `Request_Data` longtext,
  `Request_Date` datetime DEFAULT NULL,
  `Is_Approved` int DEFAULT NULL,
  `Approval_Remarks` longtext,
  `Approved_On` datetime DEFAULT NULL,
  `Approved_Id` varchar(20) DEFAULT NULL,
  `Approved_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Request_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026241000001','M005241000076','Agent','MU05241000076','Agent','MU05241000076','MobileNo','{"mobile_no":"9822594320"}','02/23/2024 10:08:36',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026241000002','M005241000018','Farmer','MU04241002693','Farmer','MU04241002693','MobileNo','{"mobile_no":"9923253866","bank_id":"","branch_id":"","account_name":"","account_no":"","nominee_name":"","nominee_relation":"","nomineemobile_no":"","nomineeaadhar_no":"","nomRelation":"","bankName":"","branchName":"","Bank_Cheque_PBook_Photo":""}','04/12/2024 14:36:47',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026241000003','M005241000051','Agent','MU05241000051','Agent','MU05241000051','MobileNo','{"mobile_no":"9657994051"}','04/15/2024 07:41:05',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026241000004','M005231000025','Agent','MU05241000025','Agent','MU05241000025','MobileNo','{"mobile_no":"7875569171"}','05/23/2024 08:57:10',1,NULL,'05/25/2024 14:20:20','MU03241000039','Pradeep Arun Kokate');
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026241000005','M005241000070','Farmer','MU04241003642','Farmer','MU04241003642','MobileNo','{"mobile_no":"7559166820","bank_id":"","branch_id":"","account_name":"","account_no":"","nominee_name":"","nominee_relation":"","nomineemobile_no":"","nomineeaadhar_no":"","nomRelation":"","bankName":"","branchName":"","Bank_Cheque_PBook_Photo":""}','07/15/2024 13:38:14',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026241000006','M005231000025','Agent','MU05241000025','Agent','MU05241000025','MobileNo','{"mobile_no":"7875569171"}','09/04/2024 07:48:19',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026241000007','M005241000003','Farmer','MU04241009362','Farmer','MU04241009362','MobileNo','{"mobile_no":"7666077366","bank_id":"","branch_id":"","account_name":"","account_no":"","nominee_name":"","nominee_relation":"","nomineemobile_no":"","nomineeaadhar_no":"","nomRelation":"","bankName":"","branchName":"","Bank_Cheque_PBook_Photo":""}','10/20/2024 19:20:22',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026241000008','M005241000003','Farmer','MU04241009427','Farmer','MU04241009427','Nominee','{"mobile_no":"","bank_id":"","branch_id":"","account_name":"","account_no":"","nominee_name":"Tushar Ravsaheb Darade ","nominee_relation":"C030002","nomineemobile_no":"9322448070","nomineeaadhar_no":"632216703284","nomRelation":"Child","bankName":"","branchName":"","Bank_Cheque_PBook_Photo":""}','12/05/2024 14:20:50',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026241000009','M005241000076','Farmer','MU04241007698','Farmer','MU04241007698','MobileNo','{"mobile_no":"9763247301","bank_id":"","branch_id":"","account_name":"","account_no":"","nominee_name":"","nominee_relation":"","nomineemobile_no":"","nomineeaadhar_no":"","nomRelation":"","bankName":"","branchName":"","Bank_Cheque_PBook_Photo":""}','12/31/2024 14:24:33',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026251000001','M005242000123','Agent','MU05241000037','Agent','MU05241000037','MobileNo','{"mobile_no":"9967858880"}','01/03/2025 06:12:05',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026251000002','M005241000074','Farmer','MU04242026822','Farmer','MU04242026822','Nominee','{"mobile_no":"","bank_id":"","branch_id":"","account_name":"","account_no":"","nominee_name":"Kalpana KirtiKumar Ghuge","nominee_relation":"C030005","nomineemobile_no":"9892907897","nomineeaadhar_no":"364987186593","nomRelation":"Parent","bankName":"","branchName":"","Bank_Cheque_PBook_Photo":""}','04/12/2025 15:10:20',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026251000003','M005241000074','Farmer','MU04242026822','Farmer','MU04242026822','MobileNo','{"mobile_no":"9892907897","bank_id":"","branch_id":"","account_name":"","account_no":"","nominee_name":"","nominee_relation":"","nomineemobile_no":"","nomineeaadhar_no":"","nomRelation":"","bankName":"","branchName":"","Bank_Cheque_PBook_Photo":""}','04/12/2025 15:13:51',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026251000004','M005242000135','Farmer','MU04242026912','Farmer','MU04242026912','MobileNo','{"mobile_no":"9881213309","bank_id":"","branch_id":"","account_name":"","account_no":"","nominee_name":"","nominee_relation":"","nomineemobile_no":"","nomineeaadhar_no":"","nomRelation":"","bankName":"","branchName":"","Bank_Cheque_PBook_Photo":""}','04/16/2025 11:22:44',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026251000005','M005242000135','Farmer','MU04242026912','Farmer','MU04242026912','BankDetails','{"mobile_no":"","bank_id":"M015241000348","branch_id":"M016241000371","account_name":"Uttam Bapusaheb Kanawade ","account_no":"9823366207","nominee_name":"","nominee_relation":"","nomineemobile_no":"","nomineeaadhar_no":"","nomRelation":"","bankName":"Bank Of Maharashtra","branchName":"Sangamner","Bank_Cheque_PBook_Photo":""}','04/20/2025 20:35:14',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026251000006','M005241000030','Agent','MU05241000030','Agent','MU05241000030','MobileNo','{"mobile_no":"9284461083"}','07/09/2025 07:59:33',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026251000007','M005231000023','Agent','MU05241000023','Agent','MU05241000023','MobileNo','{"mobile_no":"8888143210"}','07/09/2025 19:55:41',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026251000008','M005231000069','Agent','MU05241000069','Agent','MU05241000069','MobileNo','{"mobile_no":"9765989786"}','07/15/2025 14:35:28',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026251000009','M005241000077','Farmer','MU04241010415','Farmer','MU04241010415','MobileNo','{"mobile_no":"9561425715","bank_id":"","branch_id":"","account_name":"","account_no":"","nominee_name":"","nominee_relation":"","nomineemobile_no":"","nomineeaadhar_no":"","nomRelation":"","bankName":"","branchName":"","Bank_Cheque_PBook_Photo":""}','08/06/2025 13:11:43',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026261000001','M005241000056','Agent','MU05241000056','Agent','MU05241000056','MobileNo','{"mobile_no":"9657867573"}','01/15/2026 16:47:20',0,NULL,NULL,NULL,NULL);
INSERT INTO `t026_datacorrection_request` VALUES('C005','T026261000002','M005241000076','Farmer','MU04242026675','Farmer','MU04242026675','MobileNo','{"mobile_no":"9561287050","bank_id":"","branch_id":"","account_name":"","account_no":"","nominee_name":"","nominee_relation":"","nomineemobile_no":"","nomineeaadhar_no":"","nomRelation":"","bankName":"","branchName":"","Bank_Cheque_PBook_Photo":""}','01/26/2026 12:24:53',0,NULL,NULL,NULL,NULL);

-- Dump completed on 2026-05-12 17:16:15
