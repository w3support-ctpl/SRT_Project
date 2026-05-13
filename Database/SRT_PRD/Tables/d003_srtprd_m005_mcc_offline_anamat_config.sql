-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m005_mcc_offline_anamat_config`;
CREATE TABLE `m005_mcc_offline_anamat_config` (
  `Org_Id` varchar(10) NOT NULL,
  `Entry_Id` varchar(45) NOT NULL,
  `MCC_Id` varchar(20) DEFAULT NULL,
  `Farmer_Id` varchar(45) DEFAULT NULL,
  `Anamat_PerLtr` decimal(8,2) DEFAULT NULL,
  `Created_On` datetime DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `m005_mcc_offline_anamat_config` VALUES('C005','M005251000001','M005241000078','MU04251000091',1.00,'07/18/2025 15:12:34');
INSERT INTO `m005_mcc_offline_anamat_config` VALUES('C005','M005251000002','M005242000120','MU04251000107',1.00,'07/23/2025 15:08:54');
INSERT INTO `m005_mcc_offline_anamat_config` VALUES('C005','M005251000003','M005231000014','MU04251000117',2.00,'08/12/2025 05:50:40');
INSERT INTO `m005_mcc_offline_anamat_config` VALUES('C005','M005251000004','M005241000033','MU04251000126',2.00,'08/25/2025 18:13:37');
INSERT INTO `m005_mcc_offline_anamat_config` VALUES('C005','M005251000005','M005231000008','MU04251000177',3.00,'12/10/2025 10:36:43');

-- Dump completed on 2026-05-12 17:15:48
