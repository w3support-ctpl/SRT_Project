-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m020_deductions_head`;
CREATE TABLE `m020_deductions_head` (
  `Org_Id` varchar(20) NOT NULL,
  `DeductionHead_Id` varchar(45) NOT NULL,
  `DeductionHead_Name` varchar(45) DEFAULT NULL,
  `User_Type` varchar(45) DEFAULT NULL,
  `Deduction_Type` varchar(45) DEFAULT NULL,
  `GL_Code` varchar(45) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  `Created_On` datetime DEFAULT NULL,
  `LastEdited_On` datetime DEFAULT NULL,
  `CreatedBy_Id` varchar(20) DEFAULT NULL,
  `CreatedBy_Name` varchar(45) DEFAULT NULL,
  `LastEditedBy_Id` varchar(20) DEFAULT NULL,
  `LastEditedBy_Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`DeductionHead_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000001','Sec Dep','Transporter',NULL,'10303010',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000002','Diesel Recovery','Transporter',NULL,'40101091',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000003','Dairy Advance','Transporter','DA','20407010',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000004','Bank Loan - ICICI','Transporter','BL','610010',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000005','Can Recovery Charges','Transporter',NULL,NULL,1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000006','TDS','Transporter','','10601020',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000007','Bank Loan - ICICI','Agent','BL','610010',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000008','Trading Material','Agent','TM',NULL,1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000009','Product Sales','Agent','PS',NULL,1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000010','Dairy Advance','Agent','DA','20407010',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000011','Bank Loan - ICICI','Farmer','BL','610010',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000012','MCC Advance','Farmer','MA','20407010',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000013','Product Sales','Farmer','PS',NULL,1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000014','Trading Material','Farmer','TM',NULL,1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000015','Dairy Advance','Farmer','DA','20407010',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000016','Bank Loan - Society','Agent','BL','610011',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000017','Bank Loan - Society','Farmer','BL','610011',1,0,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `m020_deductions_head` VALUES('C005','M020231000018','Bank Loan - Society','Transporter','BL','610011',1,0,NULL,NULL,NULL,NULL,NULL,NULL);

-- Dump completed on 2026-05-12 17:15:49
