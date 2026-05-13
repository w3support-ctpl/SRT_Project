-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `t016_complaint_header`;
CREATE TABLE `t016_complaint_header` (
  `Org_Id` varchar(10) NOT NULL,
  `Complaint_Id` varchar(20) NOT NULL,
  `ComplaintType_Id` varchar(45) DEFAULT NULL,
  `Complaint_Remark` text,
  `Complaint_For` varchar(45) DEFAULT NULL,
  `Complaint_For_User_Id` varchar(20) DEFAULT NULL,
  `Complaint_By` varchar(45) DEFAULT NULL,
  `Complaint_By_User_Id` varchar(20) DEFAULT NULL,
  `Complaint_Date` datetime DEFAULT NULL,
  `ComplaintStatus_Id` varchar(45) DEFAULT '0',
  `Closing_Date` datetime DEFAULT NULL,
  PRIMARY KEY (`Org_Id`,`Complaint_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `t016_complaint_header` VALUES('C005','T016241000001','C034002','hii','Farmer','MU04241025683','Agent','MU05241000060','04/12/2024 11:30:04','C035001',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016241000002','C034002','साहेब पेमेंट स्लिपा कधी मिळणार 
','Farmer','MU04241025986','Agent','MU05241000011','04/24/2024 21:40:40','C035001',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016241000003','C034001','mahiti ublabdha nahi ','Farmer','MU04241011533','Farmer','MU04241011533','04/25/2024 11:07:53','C035001',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016241000004','C034002','dudh collection cancle 
','Farmer','MU04241001562','Agent','MU05241000006','04/26/2024 19:55:46','C035001',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016241000005','C034001','एकही अनुदान जमा झाले नाही पाच रुपये प्रमाणे 
तरी ते लवकरात लवकर जमा करावे अशी माझी विनंती आहे ','Farmer','MU04241004071','Farmer','MU04241004071','05/16/2024 08:15:43','C035001',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016241000006','C034001','तुम्ही तुमच्या ॲपवर जर काहीच माहिती देणार नसेल तर त्वरित बंद करावे आणि आम्हाला रीतसर पेमेंट स्लिप मिळावी ही विनंती','Farmer','MU04241011611','Farmer','MU04241011611','09/26/2024 20:13:29','C035001',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016241000007','C034002','rate picked up wrong 
','Farmer','MU04242026786','Agent','MU05241000029','12/12/2024 12:05:20','C035001',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016251000001','C034001','test','Farmer','MU04251000014','Farmer','MU04251000014','07/14/2025 10:08:13','C035001',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016261000001','C034001','Cattle feed cutting excess ','Farmer','MU04242026877','Agent','MU05242000112','03/10/2026 15:43:38','C035002',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016261000002','C034002','app is working slowly

','Farmer','MU04242026877','Agent','MU05242000112','03/10/2026 15:50:00','C035003',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016261000003','C034001','खाद्याची ऑर्डर देऊन पंधरा दिवस झाले तरी अजून खाद्य आले नाही. यामुळे उत्पादक नाराज होतात आणि दूध पण कमी पडतं 
','Farmer','MU04242026788','Agent','MU05241000069','03/10/2026 17:05:39','C035003',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016261000004','C034261000002','हे aap खुप सुलो चालते','Farmer','MU04241003369','Agent','MU05241000070','03/10/2026 22:13:52','C035003',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016261000005','C034261000001','पुण्याचे इंजिनिअर येऊन लोड सेल क्लिअर करून काट कॅलिब्रेशन करून सुद्धा रोज पाच ते सहा लिटर घट येते
आज काटा तीन लिटर मायनस दाखवून सुद्धा सहा लिटर गट आली','Farmer','MU04242026788','Agent','MU05241000069','03/11/2026 21:28:26','C035002',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016261000006','C034261000001','सायंकाळ कलेक्शन चा  sms येत नाही आणि APP मध्ये पण दिसत नाही प्लीज तक्रार दखल घेवून योग्य ती सुधारणा करावी ','Farmer','MU04251000152','Agent','MU05241000063','03/21/2026 10:51:57','C035002',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016261000007','C034261000001','21.2=कट करा 
5.3=दूध आहे ','Farmer','MU04242026886','Agent','MU05242000115','04/10/2026 20:24:45','C035003',NULL);
INSERT INTO `t016_complaint_header` VALUES('C005','T016261000008','C034261000001','सदर दोन-तीन दिवसांनी कॉलिटी कमी येत आहे आणि १-५-२०२६रोजी म्हणजे आजच 18 लिटर घट आलेले आहे. कृपयाची चौकशी करावी. 
','Farmer','MU04251000075','Agent','MU05241000069','05/01/2026 21:13:32','C035003',NULL);

-- Dump completed on 2026-05-12 17:16:13
