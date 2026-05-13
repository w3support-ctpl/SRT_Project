-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `m013_salesarea_item`;
CREATE TABLE `m013_salesarea_item` (
  `Org_Id` varchar(10) NOT NULL,
  `SalesOffice_Code` varchar(10) NOT NULL,
  `SalesOrg_Code` varchar(10) NOT NULL,
  `DistChannel_Code` varchar(10) NOT NULL,
  `Division_Code` varchar(10) NOT NULL,
  `SalesOffice_Name` varchar(50) NOT NULL,
  `SAPSalesArea_Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Is_Active` int NOT NULL DEFAULT '1',
  `Is_Deleted` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`Org_Id`,`SalesOffice_Code`,`SalesOrg_Code`,`DistChannel_Code`,`Division_Code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','01','01','Sangamner Sales Off','SRT Sales Org - Milk Sales - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','01','02','Sangamner Sales Off','SRT Sales Org - Milk Sales - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','01','03','Sangamner Sales Off','SRT Sales Org - Milk Sales - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','02','01','Sangamner Sales Off','SRT Sales Org - Dairy Dealer - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','02','02','Sangamner Sales Off','SRT Sales Org - Dairy Dealer - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','02','03','Sangamner Sales Off','SRT Sales Org - Dairy Dealer - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','03','01','Sangamner Sales Off','SRT Sales Org - Dairy Retailer - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','03','02','Sangamner Sales Off','SRT Sales Org - Dairy Retailer - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','03','03','Sangamner Sales Off','SRT Sales Org - Dairy Retailer - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','04','00','Sangamner Sales Off','SRT Sales Org - Institutional Sales - Common Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','04','01','Sangamner Sales Off','SRT Sales Org - Institutional Sales - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','04','02','Sangamner Sales Off','SRT Sales Org - Institutional Sales - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','04','03','Sangamner Sales Off','SRT Sales Org - Institutional Sales - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','04','05','Sangamner Sales Office','SRT Sales Org - Institution Sales - Trading',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','05','01','Sangamner Sales Office','SRT Sales Org - Super Stockist - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','05','02','Sangamner Sales Office','SRT Sales Org - Super Stockist - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','05','03','Sangamner Sales Office','SRT Sales Org - Super Stockist - Finished Product - Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','06','01','Sangamner Sales Office','SRT Sales Org - Parlor Sales - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','06','02','Sangamner Sales Office','SRT Sales Org - Parlor Sales - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','06','03','Sangamner Sales Office','SRT Sales Org - Parlor Sales - Finished Product - Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','07','01','Sangamner Sales Office','SRT Sales Org - Franchise - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','07','02','Sangamner Sales Office','SRT Sales Org - Franchise - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','07','03','Sangamner Sales Office','SRT Sales Org - Franchise - Finished Product - Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','08','00','Sangamner Sales Office','SRT Sales Org - Trading - Common Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','08','01','Sangamner Sales Office','SRT Sales Org - Trading - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','08','02','Sangamner Sales Office','SRT Sales Org - Trading - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','08','05','Sangamner Sales Office','SRT Sales Org - Trading - Trading',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','09','01','Sangamner Sales Office','SRT Sales Org - Inward Job-Work - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','09','02','Sangamner Sales Office','SRT Sales Org - Inward Job-Work - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','09','03','Sangamner Sales Office','SRT Sales Org - Inward Job-Work - Finished Product - Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','10','04','Sangamner Sales Office','SRT Sales Org - Power Sales - Solar Power',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','11','00','Sangamner Sales Office','SRT Sales Org - Scrap Sales - Common Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','12','02','Sangamner Sales Office','SRT Sales Org - Export Sales - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1000','1000','12','03','Sangamner Sales Office','SRT Sales Org - Export Sales - Finished Product - Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','01','01','Pune Sales Office','SRT Sales Org - Milk Sales - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','01','02','Pune Sales Office','SRT Sales Org - Milk Sales - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','01','03','Pune Sales Office','SRT Sales Org - Milk Sales - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','02','01','Pune Sales Office','SRT Sales Org - Dairy Dealer - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','02','02','Pune Sales Office','SRT Sales Org - Dairy Dealer - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','02','03','Pune Sales Office','SRT Sales Org - Dairy Dealer - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','03','01','Pune Sales Office','SRT Sales Org - Dairy Retailer - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','03','02','Pune Sales Office','SRT Sales Org - Dairy Retailer - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','03','03','Pune Sales Office','SRT Sales Org - Dairy Retailer - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','04','00','Pune Sales Office','SRT Sales Org - Institutional Sales - Common Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','04','01','Pune Sales Office','SRT Sales Org - Institutional Sales - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','04','02','Pune Sales Office','SRT Sales Org - Institutional Sales - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','04','03','Pune Sales Office','SRT Sales Org - Institutional Sales - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','04','05','Pune Sales Office','SRT Sales Org - Institution Sales - Trading',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','05','01','Pune Sales Office','SRT Sales Org - Super Stockist - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','05','02','Pune Sales Office','SRT Sales Org - Super Stockist - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','05','03','Pune Sales Office','SRT Sales Org - Super Stockist - Finished Product - Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','07','01','Pune Sales Office','SRT Sales Org - Franchise - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','07','02','Pune Sales Office','SRT Sales Org - Franchise - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1100','1000','07','03','Pune Sales Office','SRT Sales Org - Franchise - Finished Product - Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','01','01','Mumbai Sales Office','SRT Sales Org - Milk Sales - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','01','02','Mumbai Sales Office','SRT Sales Org - Milk Sales - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','01','03','Mumbai Sales Office','SRT Sales Org - Milk Sales - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','02','01','Mumbai Sales Office','SRT Sales Org - Dairy Dealer - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','02','02','Mumbai Sales Office','SRT Sales Org - Dairy Dealer - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','02','03','Mumbai Sales Office','SRT Sales Org - Dairy Dealer - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','03','01','Mumbai Sales Office','SRT Sales Org - Dairy Retailer - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','03','02','Mumbai Sales Office','SRT Sales Org - Dairy Retailer - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','03','03','Mumbai Sales Office','SRT Sales Org - Dairy Retailer - Finished Product-Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','04','00','Mumbai Sales Office','SRT Sales Org - Institutional Sales - Common Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','04','01','Mumbai Sales Office','SRT Sales Org - Institutional Sales - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','04','02','Mumbai Sales Office','SRT Sales Org - Institutional Sales - Finished Product-Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','04','03','Mumbai Sales Office','SRT Sales Org - Institution Sales - Finished Product - Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','04','05','Mumbai Sales Office','SRT Sales Org - Institution Sales - Trading',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','05','01','Mumbai Sales Office','SRT Sales Org - Super Stockist - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','05','02','Mumbai Sales Office','SRT Sales Org - Super Stockist - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','05','03','Mumbai Sales Office','SRT Sales Org - Super Stockist - Finished Product - Dry',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','07','01','Mumbai Sales Office','SRT Sales Org - Franchise - Milk Division',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','07','02','Mumbai Sales Office','SRT Sales Org - Franchise - Finished Product - Wet',1,0);
INSERT INTO `m013_salesarea_item` VALUES('C005','1200','1000','07','03','Mumbai Sales Office','SRT Sales Org - Franchise - Finished Product - Dry',1,0);

-- Dump completed on 2026-05-12 17:15:48
