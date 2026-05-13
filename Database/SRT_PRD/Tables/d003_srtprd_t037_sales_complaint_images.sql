-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t037_sales_complaint_images`;
CREATE TABLE `t037_sales_complaint_images` (
  `Org_Id` varchar(10) NOT NULL,
  `Entry_Id` varchar(20) NOT NULL,
  `Complaint_Id` varchar(20) NOT NULL,
  `Photo` longtext,
  PRIMARY KEY (`Org_Id`,`Entry_Id`,`Complaint_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000001','T037241000006','/SalesUser/1a51aaa5-ced3-4a6e-8b56-45bc5d92c569_1000288580.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000002','T037241000007','/SalesUser/5dcbb591-a843-4fea-8a63-62363a4b969d_1000288580.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000003','T037241000006','/SalesUser/01189c13-d36f-44a2-b6a7-30ccb7b6d7b8_1000287882.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000004','T037241000007','/SalesUser/7568c355-fbcc-4c8a-9bc0-ecaddbcef858_1000287882.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000005','T037241000006','/SalesUser/4c10c7a7-a835-4bc4-ab8f-2b930123bc2f_1000288159.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000006','T037241000007','/SalesUser/b3f42fae-9a42-4553-8ca9-6579c8e9be49_1000288159.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000007','T037241000006','/SalesUser/32abf3c5-e248-49d7-ba3f-1c2520e140c9_1000288758.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000008','T037241000007','/SalesUser/016ffb91-e0b1-42ee-a1c1-b78d88946c06_1000288758.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000009','T037241000006','/SalesUser/f556d1c7-69c6-42e9-bb9c-4fd8a5b2aab7_1000288580.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000010','T037241000007','/SalesUser/bf160432-a229-46ef-8b26-d9c216b82352_1000288580.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000011','T037241000006','/SalesUser/c4874e0c-24b9-4137-ba7f-f86eab6a9d9d_1000288561.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000012','T037241000007','/SalesUser/010ac424-c330-4cf7-a6a5-4bdf163588f6_1000288561.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000013','T037241000008','/SalesUser/3a29520d-d5d5-443d-9269-318a1252ab24_1000002107.png');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000014','T037241000008','/SalesUser/c050328c-ec78-41cb-b555-d02b0b865b5d_1000002106.png');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000015','T037241000008','/SalesUser/4bccfae4-f763-4d63-a083-282974eeaae8_1000002103.png');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000016','T037241000009','/SalesUser/36f61f49-7516-4b80-be7a-32c355817d44_1000331199.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037241000017','T037241000010','/SalesUser/43c0e340-9770-44da-bde0-d12d09de92a6_1000331199.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037261000001','T037261000001','/SalesUser/5eaa4682-0e00-4d03-8612-6784d2a4fd32_573424.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037261000002','T037261000002','/SalesUser/dc68e2eb-adda-4a1b-9c89-07ceb7aab85e_573424.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037261000003','T037261000001','/SalesUser/4830476f-b360-4703-b0c0-a989ad496201_573422.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037261000004','T037261000002','/SalesUser/87bb17f8-f713-40f4-a916-8b04a5add2d7_573422.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037261000005','T037261000001','/SalesUser/f17fbd77-2105-42ec-a75e-7f359d719b00_573423.jpg');
INSERT INTO `t037_sales_complaint_images` VALUES('C005','T037261000006','T037261000002','/SalesUser/be1ef6d1-b4e7-4ded-a180-726d15358fc6_573423.jpg');

-- Dump completed on 2026-05-12 17:16:17
