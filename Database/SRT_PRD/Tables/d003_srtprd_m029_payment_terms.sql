-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m029_payment_terms`;
CREATE TABLE `m029_payment_terms` (
  `Org_id` varchar(20) NOT NULL,
  `Payment_Term` varchar(45) NOT NULL,
  `PaymentTermsName` text,
  PRIMARY KEY (`Org_id`,`Payment_Term`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `m029_payment_terms` VALUES('C005','0001','Payable immediately Due net');
INSERT INTO `m029_payment_terms` VALUES('C005','0002','');
INSERT INTO `m029_payment_terms` VALUES('C005','0003','');
INSERT INTO `m029_payment_terms` VALUES('C005','0004','');
INSERT INTO `m029_payment_terms` VALUES('C005','0005','');
INSERT INTO `m029_payment_terms` VALUES('C005','0006','');
INSERT INTO `m029_payment_terms` VALUES('C005','0007','');
INSERT INTO `m029_payment_terms` VALUES('C005','0008','');
INSERT INTO `m029_payment_terms` VALUES('C005','0009','');
INSERT INTO `m029_payment_terms` VALUES('C005','NT00','');
INSERT INTO `m029_payment_terms` VALUES('C005','NT08','');
INSERT INTO `m029_payment_terms` VALUES('C005','NT15','');
INSERT INTO `m029_payment_terms` VALUES('C005','NT30','');
INSERT INTO `m029_payment_terms` VALUES('C005','NT45','');
INSERT INTO `m029_payment_terms` VALUES('C005','NT60','');
INSERT INTO `m029_payment_terms` VALUES('C005','SC00','Payable immediately Due net');
INSERT INTO `m029_payment_terms` VALUES('C005','SC01','Advance Payment');
INSERT INTO `m029_payment_terms` VALUES('C005','SC02','Against Proforma Invoice');
INSERT INTO `m029_payment_terms` VALUES('C005','SC03','Against Delivery');
INSERT INTO `m029_payment_terms` VALUES('C005','SC04','After 3 days');
INSERT INTO `m029_payment_terms` VALUES('C005','SC05','After 7 days');
INSERT INTO `m029_payment_terms` VALUES('C005','SC06','After 10 days');
INSERT INTO `m029_payment_terms` VALUES('C005','SC07','After 15 days');
INSERT INTO `m029_payment_terms` VALUES('C005','SC08','21 Days Against Delivery');
INSERT INTO `m029_payment_terms` VALUES('C005','SC09','After 30 days');
INSERT INTO `m029_payment_terms` VALUES('C005','SC10','Against Bank Gurantee');
INSERT INTO `m029_payment_terms` VALUES('C005','SC11','Against Letter of Credit');
INSERT INTO `m029_payment_terms` VALUES('C005','SC12','1% Cash discount on Advance Payment');
INSERT INTO `m029_payment_terms` VALUES('C005','SV00','Pay Immediately w/o Deduction');
INSERT INTO `m029_payment_terms` VALUES('C005','SV01','14 Days 3%, 30 Net');
INSERT INTO `m029_payment_terms` VALUES('C005','SV02','14 Days 2%, 30 Net');
INSERT INTO `m029_payment_terms` VALUES('C005','SV03','21 Days 1%, 30 Net');
INSERT INTO `m029_payment_terms` VALUES('C005','SV04','21 Days 2%, 30 Net');
INSERT INTO `m029_payment_terms` VALUES('C005','SV05','Basic Due in 8 Days');
INSERT INTO `m029_payment_terms` VALUES('C005','SV06','Basic Due in 10 Days');
INSERT INTO `m029_payment_terms` VALUES('C005','SV07','Basic Due in 15 Days');
INSERT INTO `m029_payment_terms` VALUES('C005','SV08','Basic Due in 21 Days');
INSERT INTO `m029_payment_terms` VALUES('C005','SV09','Basic Due in 30 Days');
INSERT INTO `m029_payment_terms` VALUES('C005','SV10','Basic Due in 45 Days');
INSERT INTO `m029_payment_terms` VALUES('C005','SV11','Basic Due in 60 Days');
INSERT INTO `m029_payment_terms` VALUES('C005','SV12','Advance Net');
INSERT INTO `m029_payment_terms` VALUES('C005','SV13','Payable Net Upon Proforma');
INSERT INTO `m029_payment_terms` VALUES('C005','SV14','Pay Upon Delivery, COD');
INSERT INTO `m029_payment_terms` VALUES('C005','SV15','Pay Net LC');
INSERT INTO `m029_payment_terms` VALUES('C005','SV16','Advance Basic');
INSERT INTO `m029_payment_terms` VALUES('C005','SV17','Payable Basic Upon Proforma');
INSERT INTO `m029_payment_terms` VALUES('C005','SV18','Pay Net Upon Delivery');
INSERT INTO `m029_payment_terms` VALUES('C005','SV19','Pay Basic Upon Delivery');
INSERT INTO `m029_payment_terms` VALUES('C005','SV20','Advance Basic 10%, 40%, 40%, Balance 10% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV21','Advance Basic 10%, 40%, 35%, Balance 15% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV22','Advance Basic 10%, 40%, 30%, Balance 20% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV23','Advance Basic 20%, 30%, 40%, Balance 10% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV24','Advance Basic 20%, 30%, 35%, Balance 15% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV25','Advance Basic 20%, 30%, 30%, Balance 20% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV26','Advance Basic 25%, 25%, 40%, Balance 10% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV27','Advance Basic 25%, 25%, 35%, Balance 15% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV28','Advance Basic 25%, 25%, 30%, Balance 20% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV29','Advance Basic 30%, 20%, 40%, Balance 10% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV30','Advance Basic 30%, 20%, 35%, Balance 15% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV31','Advance Basic 30%, 20%, 30%, Balance 20% With GST');
INSERT INTO `m029_payment_terms` VALUES('C005','SV32','Payable Basic 4 Installment');
INSERT INTO `m029_payment_terms` VALUES('C005','SV33','Payable Basic 3 Installment');
INSERT INTO `m029_payment_terms` VALUES('C005','SV34','Payable Basic 2 Installment');
INSERT INTO `m029_payment_terms` VALUES('C005','SV35','Payable Basic 12 Installment');
INSERT INTO `m029_payment_terms` VALUES('C005','SV36','Payable Basic - Upon work completion');
INSERT INTO `m029_payment_terms` VALUES('C005','SV37','MSME Supplier Due in 15 Days');
INSERT INTO `m029_payment_terms` VALUES('C005','SV38','MSME Supplier Due in 45 Days');
INSERT INTO `m029_payment_terms` VALUES('C005','SV39','Payable Basic 12 Installment');

-- Dump completed on 2026-05-12 17:15:49
