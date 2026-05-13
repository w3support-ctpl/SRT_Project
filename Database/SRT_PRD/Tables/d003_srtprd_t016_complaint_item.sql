-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t016_complaint_item`;
CREATE TABLE `t016_complaint_item` (
  `Org_Id` varchar(10) NOT NULL,
  `Complaint_Id` varchar(20) NOT NULL,
  `Entry_Id` varchar(20) NOT NULL,
  `Action_Date` datetime DEFAULT NULL,
  `Action_By_Id` varchar(45) DEFAULT NULL,
  `Action_By_Name` varchar(45) DEFAULT NULL,
  `Remarks` longtext,
  `Is_Display` int DEFAULT NULL,
  `New_Status_Id` varchar(45) DEFAULT NULL,
  `Current_Status_Id` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Complaint_Id`,`Entry_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t016_complaint_item` VALUES('C005','T016241000001','T0016241000001','04/12/2024 11:30:04','MU05241000060','Sai Siddheshwar DSK V VK Sangamner','hii',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016241000002','T0016241000002','04/24/2024 21:40:40','MU05241000011','Samarth DSK Kasarwadi','साहेब पेमेंट स्लिपा कधी मिळणार 
',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016241000002','T0016241000006','05/06/2024 13:04:59','MU05241000011','Samarth DSK Kasarwadi','payment slip ',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016241000003','T0016241000003','04/25/2024 11:07:53','MU04241011533','Ravindra Gulabrao Gunjal','mahiti ublabdha nahi ',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016241000004','T0016241000004','04/26/2024 19:55:46','MU05241000006','Ganpat Kashinath Walave','dudh collection cancle 
',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016241000004','T0016241000005','04/26/2024 19:56:58','MU05241000006','Ganpat Kashinath Walave','dudh collection mistake ',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016241000005','T0016241000007','05/16/2024 08:15:43','MU04241004071','Harunrashid Yusuf Kazi','एकही अनुदान जमा झाले नाही पाच रुपये प्रमाणे 
तरी ते लवकरात लवकर जमा करावे अशी माझी विनंती आहे ',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016241000006','T0016241000008','09/26/2024 20:13:29','MU04241011611','Baban Laxman Gunjal','तुम्ही तुमच्या ॲपवर जर काहीच माहिती देणार नसेल तर त्वरित बंद करावे आणि आम्हाला रीतसर पेमेंट स्लिप मिळावी ही विनंती',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016241000007','T0016241000009','12/12/2024 12:05:20','MU05241000029','Saiyash DSK MPIC Ganore offline','rate picked up wrong 
',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016241000007','T0016241000010','12/12/2024 12:05:58','MU05241000029','Saiyash DSK MPIC Ganore offline','will need to check',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016251000001','T0016251000001','07/14/2025 10:08:13','MU04251000014','Ahmed Valibhai Shaikh','test',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000001','T0016261000001','03/10/2026 15:43:38','MU05242000112','Shivtatva Dudh Dairy BM','Cattle feed cutting excess ',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000001','T0016261000002','03/10/2026 15:45:24','MU03241000028','Sachin Atre','Will check',1,'C035003','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000001','T0016261000003','03/10/2026 15:47:00','MU05242000112','Shivtatva Dudh Dairy BM','issue with cutting amount',1,'C035003','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000001','T0016261000004','03/10/2026 15:48:22','MU05242000112','Shivtatva Dudh Dairy BM','',1,'C035003','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000001','T0016261000009','03/10/2026 18:00:27','MU03241000028','Sachin Atre','Will Check It',0,'C035002','C035003');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000002','T0016261000005','03/10/2026 15:50:00','MU05242000112','Shivtatva Dudh Dairy BM','app is working slowly

',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000002','T0016261000006','03/10/2026 15:50:14','MU05242000112','Shivtatva Dudh Dairy BM','cannot do collection ',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000002','T0016261000007','03/10/2026 17:01:35','MU03241000028','Sachin Atre','Cattle Rate not known',1,'C035003','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000003','T0016261000008','03/10/2026 17:05:39','MU05241000069','Super DSK Talegaon Dighe Offline','खाद्याची ऑर्डर देऊन पंधरा दिवस झाले तरी अजून खाद्य आले नाही. यामुळे उत्पादक नाराज होतात आणि दूध पण कमी पडतं 
',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000003','T0016261000018','03/25/2026 12:01:49','MU03241000016','Haribhau Waliba Bombale','U R order Deliver',0,'C035003','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000004','T0016261000010','03/10/2026 22:13:52','MU05241000070','Baburao Damu Chakor','हे aap खुप सुलो चालते',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000004','T0016261000011','03/10/2026 22:15:50','MU05241000070','Baburao Damu Chakor','मला रोज 20 ते 25 लिटर ची घट येत आहे',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000004','T0016261000016','03/25/2026 11:58:48','MU03241000016','Haribhau Waliba Bombale','Collection 20lit Diff solve',0,'C035003','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000004','T0016261000019','03/25/2026 12:07:05','MU03241000016','Haribhau Waliba Bombale','I am Show You 20 lit Diff',0,'C035003','C035003');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000005','T0016261000012','03/11/2026 21:28:26','MU05241000069','Super DSK Talegaon Dighe Offline','पुण्याचे इंजिनिअर येऊन लोड सेल क्लिअर करून काट कॅलिब्रेशन करून सुद्धा रोज पाच ते सहा लिटर घट येते
आज काटा तीन लिटर मायनस दाखवून सुद्धा सहा लिटर गट आली',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000005','T0016261000015','03/25/2026 11:31:22','MU03241000028','Sachin Atre','will check it',0,'C035002','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000006','T0016261000013','03/21/2026 10:51:57','MU05241000063','Amrutdhara DSK Bulk','सायंकाळ कलेक्शन चा  sms येत नाही आणि APP मध्ये पण दिसत नाही प्लीज तक्रार दखल घेवून योग्य ती सुधारणा करावी ',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000006','T0016261000014','03/25/2026 11:30:46','MU03241000028','Sachin Atre','will check it',0,'C035002','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000006','T0016261000017','03/25/2026 12:00:12','MU03241000016','Haribhau Waliba Bombale','In working',0,'C035002','C035002');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000007','T0016261000020','04/10/2026 20:24:45','MU05242000115','Sunanda Chandrakant Kanawade','21.2=कट करा 
5.3=दूध आहे ',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000007','T0016261000021','04/11/2026 15:27:49','MU03241000028','Sachin Atre','Please Correction request enter',1,'C035002','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000007','T0016261000022','04/11/2026 15:38:06','MU03241000016','Haribhau Waliba Bombale','Plz use crrection request opption',1,'C035003','C035002');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000008','T0016261000023','05/01/2026 21:13:32','MU05241000069','Inayat Salim Shaikh','सदर दोन-तीन दिवसांनी कॉलिटी कमी येत आहे आणि १-५-२०२६रोजी म्हणजे आजच 18 लिटर घट आलेले आहे. कृपयाची चौकशी करावी. 
',1,'C035001','C035001');
INSERT INTO `t016_complaint_item` VALUES('C005','T016261000008','T0016261000024','05/06/2026 11:13:29','MU03241000016','Haribhau Waliba Bombale','Every Day We found water in milk Sample',1,'C035003','C035001');

-- Dump completed on 2026-05-12 17:16:13
