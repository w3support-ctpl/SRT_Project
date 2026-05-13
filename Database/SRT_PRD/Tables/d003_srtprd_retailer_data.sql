-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `retailer_data`;
CREATE TABLE `retailer_data` (
  `Org_Id` text,
  `Retailer_Id` text,
  `Retailer_Name` text,
  `SalesArea_Name` text,
  `Route_Id` text,
  `Dealer_Code` text,
  `Mobile_No` text,
  `Contact_Person` text,
  `Is_MobileNo_Verified` text,
  `Email_Id` text,
  `Address_Line_1_Text` text,
  `Address_Line_2_Text` text,
  `Address_Line_3_Text` text,
  `State_Name` text,
  `District_Name` text,
  `Taluka_Name` text,
  `Village_Name` text,
  `Pincode` text,
  `Pan_No` text,
  `ShopLatitude` text,
  `ShopLongitude` text,
  `Shop_License_No` text,
  `Pan_Card_Photo` text,
  `Shop_License_Photo` text,
  `Cheque_Leaf_Photo` text,
  `Shop_Name_Photo` text,
  `Bank_Id` text,
  `Branch_Id` text,
  `Account_No` text,
  `IFSC_Code` text,
  `Account_Name` text,
  `FSSAI_License_No` text,
  `FSSAI_LicenseValidity_On` text,
  `UdyamAadhar_Card_Photo` text,
  `FSSAI_License_Photo` text,
  `GST_Certificate_Photo` text,
  `Is_Agreement_Done` text,
  `AgreementValidiy_StartDate` text,
  `AgreementValidity_EndDate` text,
  `SecurityDepositAmount` text,
  `Is_Approved` text,
  `Is_Active` text,
  `Is_Deleted` text,
  `Is_PasswordReset` text,
  `Created_On` text,
  `CreatedBy_Id` text,
  `CreatedBy_Name` text,
  `LastEdited_On` text,
  `LastEditedBy_Id` text,
  `LastEditedBy_Name` text,
  `Approval_Remarks` text,
  `Approved_On` text,
  `Approved_Id` text,
  `Approved_Name` text,
  `MSME` text,
  `Aadhar_No` text,
  `ASME` text,
  `GST_No` text,
  `Landline_Number` text,
  `SalesUser_Id` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `retailer_data` VALUES('C005','MU09231000001','Raj Traders','Pune Sales Group','','700770','9921074216','Kavita Bothara','1','','Sr. No. 20, Balaji Complex','Dhankawadi,Pune','','MH','Pune','Haveli','Balajinagar','411043','','18.4660724','73.8602634','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000002','Mataji Super Market','Pune Sales Group','','700770','9921786342','Mahendra Choudhary','1','','22/74, Dhanashree Co-Op Hsg Society','Dhankawadi,Pune','','MH','Pune','Haveli','Balajinagar','411043','','18.457012','73.866533','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000003','Priyanka Super Market','Pune Sales Group','','700770','9970250870','Jalaram Shabri','1','','23/21, Prerna Hights','Dhankawadi,Pune','','MH','Pune','Haveli','Balajinagar','411043','','18.4657883','73.8587989','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000004','Chaudhary Super Market','Pune Sales Group','','700770','9822268997','Chaudhary Gisaram','1','','Dhankawadi','Dhankawadi,Pune','','MH','Pune','Haveli','Balajinagar','411043','','18.4657733','73.8587883','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000005','Balaji Super Market','Pune Sales Group','','700770','9766263690','Solanki Mangilala','1','','Mahesh Society,Bibwewadi,','Pune','','MH','Pune','Haveli','Bibwewadi','411037','','18.469315','73.866308','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000006','Laxmi Super Market','Pune Sales Group','','700770','9561172192','Dhanraaj Choudhary','1','','Opp. Ambika Sweet Mart','Sukhsagarnagar','','MH','Pune','Haveli','Sukhsagarnagar','411037','','18.455622','73.871342','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000007','Pooja Tobaco','Pune Sales Group','','700770','9595170890','Rekha Chandak','1','','Warje','Dhankawadi,Pune','','MH','Pune','Haveli','Malwadi','411052','','18.4832193','73.8090448','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000008','Ganesh Provision Stores','Pune Sales Group','','700770','9096360199','Nilesh Dharmavat','1','','Gulab Nagar,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.465652','73.854435','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000009','M/s.R R Vyas & Co','Pune Sales Group','','700770','8412983060','Santosh Vyas','1','','New Nurses Town Cooprative Society,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.466094','73.854186','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000010','Komal Sweets','Pune Sales Group','','700770','9604101785','Nemaram Shivpuri','1','','Chadrbhaga Nagar,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.465983','73.853512','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000011','Shree Charbhuja Super Mart','Pune Sales Group','','700770','9767032665','Laxman Parmar','1','','Gulab Nagar,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.465582','73.85423','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000012','Santosh Super Market','Pune Sales Group','','700770','8888885513','Santosh Uneja','1','','Jedhe Nagar Sangam Society','Bibwewadi, Pune','','MH','Pune','Haveli','Dhankawadi','411037','','18.475133','73.861315','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000013','Bhawani Super Market','Pune Sales Group','','700770','9890750291','Mulchand Dangi','1','','Kamal Vihar,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.465238','73.848219','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000014','New Bikaner Sweet','Pune Sales Group','','700770','9923321992','Suraj Choudhari','1','','Pratibha Nagar,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.46562','73.850096','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000015','Bhawani Sweet','Pune Sales Group','','700770','9610176214','Kishan Sharma','1','','Dhankwadi Police Station Rd,Chandrbhaga Nagar,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.465517','73.849575','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000016','Shree Ramdev Super Market','Pune Sales Group','','700770','9371415172','Mithalal Unecha','1','','Swami Nagar,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.465935','73.848036','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000017','Siddheshwar Market','Pune Sales Group','','700770','8551003535','Pandharinath Shendge','1','','Swami Nagar,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.465672','73.848066','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000018','Jogmaya Traders','Pune Sales Group','','700770','9552118697','Narayan Chaudhari','1','','Shree Ram Nagar,Swami Nagar,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.465029','73.848343','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000019','Mataji Sweet','Pune Sales Group','','700770','9822913825','Naresh Chaudhari','1','','Mohan Nagar Rd,Swami Nagar,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.464689','73.848361','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000020','Shriram Super Market','Pune Sales Group','','700770','9527017562','Prem Chaudhari','1','','1158,Dhankwadi Pune','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.465072','73.849015','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000021','Abhiman Dairy','Pune Sales Group','','700770','8767597317','Chinmai Fatak','1','','Bharti Veedyapeeth,','Dhankawadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.462617','73.85327','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000022','Ganraj Provision Store','Pune Sales Group','','700770','9881328537','Sanjay Jaju','1','','Shivdarshan Purgrast Colony,','Parvati,Pune','','MH','Pune','Haveli','Sahakarnagar','411009','','18.49109','73.852014','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000023','Maa Kali Super Market','Pune Sales Group','','700770','7875617693','Hukumrao Choudhary','1','','Janta Vasahat','Janta Vasahat','','MH','Pune','Haveli','Janta Vasahat','411009','','18.496287','73.843093','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000024','Amrut Provision Stores','Pune Sales Group','','700770','9764505915','Datta Shinde','1','','Janta Vasahat','Janta Vasahat','','MH','Pune','Haveli','Janta Vasahat','411009','','18.49629','73.842933','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000025','Kisan Milk Product','Pune Sales Group','','700770','9975826070','Ambadas Nehe','1','','Mahadik Hostel Building, Near Trimurti Chowk','Bharti Vidhyapeeth, Katraj','','MH','Pune','Haveli','Ambegaon Pathar','411046','','18.45718','73.849','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000026','Mauli Trading Co.','Pune Sales Group','','700770','8446148042','Rahul Bansode','1','','Kundan Ngar,','Dhankawadi,Pune','','MH','Pune','Haveli','Padmawati Taljai','411037','','18.467668','73.854567','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000027','Shri Soda Shop','Pune Sales Group','','700770','8999026042','Chandrakant Lottode','1','','Shiv Darshan Rd,Navmahrashtra Society,','Parvatipaytha,Pune','','MH','Pune','Haveli','Sahakarnagar','411009','','18.491288','73.854153','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000028','Santosh Provision Store','Pune Sales Group','','700770','9423225236','Shivaji Wagh','1','','Mahatma Gandhi Society,Bodh Vasti,','Parvatipaytha Pune','','MH','Pune','Haveli','Padmawati Taljai','411037','','18.475212','73.851304','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000029','Kiran Provision Store','Pune Sales Group','','700770','9921434118','Mithalal Vyas','1','','Taljai Vasahat,','Padmavati Nagar,Pune','','MH','Pune','Haveli','Padmawati Taljai','411037','','18.475385','73.850758','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000030','Shree Ganesh Super Market','Pune Sales Group','','700770','9545140688','Dinesh Joshi','1','','Pratibha Society,','Parvati Darshan,Pune','','MH','Pune','Haveli','Sahakarnagar','411009','','18.494115','73.852045','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000031','Anmol Super Market','Pune Sales Group','','700770','9860848865','Raju Prajapati','1','','Upper Kondawa, Swami Vivekannad Rd,','Bibwewadi,Pune','','MH','Pune','Haveli','Upper Gokul Nagar','411048','','18.46127','73.875815','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000032','Shree Baba Ramdev Super Market','Pune Sales Group','','700770','9950147475','Naresh Choudhary','1','','Ganesh Nagar,','Dhankwadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.463985','73.84568','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000033','Shivshambho Gen. Stores','Pune Sales Group','','700770','9975546958','Shubham Kondake','1','','Keshvnagar,','Dhankwadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.463656','73848434','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000034','Padmavati Super Market','Pune Sales Group','','700770','9405593961','Devendra Chhajed','1','','Shakar Nagar,Jyoti Society,','Padmavati Payth,Pune','','MH','Pune','Haveli','Padmawati Taljai','411037','','18.479024','73.552337','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000035','Mehbub Bhajipala Center','Pune Sales Group','','700770','9881676817','Mehbub Muzawar','1','','Shakar Nagar,Jyoti Society,','Padmavati Payth,Pune','','MH','Pune','Haveli','Padmawati Taljai','411037','','18.479035','73.852334','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000036','Tirupati Kirana & Gen. Stores','Pune Sales Group','','700770','7768981356','Mangal Jagdale','1','','Sambhaji Nagar Road','Vanrai Colony','','MH','Pune','Haveli','Dhankawadi','411043','','18.463464','73.848488','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000037','Shree Sadguru Dudhaly','Pune Sales Group','','700770','7268864373','Bhupendra Khopde','1','','Velankar Nagar,Parvati Paytha,','Parvati Paytha,Pune','','MH','Pune','Haveli','Sahakarnagar','411009','','18.496087','73.854657','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000038','Rajesh Gen. Stores','Pune Sales Group','','700770','8605697758','Balasaheb Chorghe','1','','Bajirao Rd,Ambegaon Pathar,','Pathar,Pune','','MH','Pune','Haveli','Ambegaon Pathar','411046','','18.456039','73.844627','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000039','Tuljai Mata Pro. Stores','Pune Sales Group','','700770','8055365944','Rupesh Prajapati','1','','Mahatma Gandhi Society,Bodh Vasti,','Parvati Paytha,Pune','','MH','Pune','Haveli','Padmawati Taljai','411037','','18.475256','73.851996','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000040','Tanishka Gen. Stores','Pune Sales Group','','700770','7447866814','Tushar Shinde','1','','Jay Bhawaninagar,Janta Vasahat Rammandir,','Parvati Paya,Pune','','MH','Pune','Haveli','Janta Vasahat','411009','','18.492145','73.839378','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000041','Mahalaxmi Super Market','Pune Sales Group','','700770','9370781454','Ruparam Choudhary','1','','Mohan Nagar Rd,Dhankwadi,Pune','Dhankwadi,Pune','','MH','Pune','Haveli','Padmawati Taljai','411037','','18.461522','73.850366','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000042','Omkar Doodhwale','Pune Sales Group','','700770','8956321877','Omkar Sheli Makar','1','','Sambhaji Nagar Road','Dhankwadi Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.462277','73.848762','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000043','Sarthak Dairy Farm','Pune Sales Group','','700770','7020889144','Datta Sendkar','1','','Chadrbhaga Nagar,','Dhankwadi,Pune','','MH','Pune','Haveli','Dhankawadi','411043','','18.465242','73.848372','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000044','S Attari Masalewale','Pune Sales Group','','700770','93702541660','Shahebaz Attar','1','','Pavan Nagar,','Bibwewadi,Pune','','MH','Pune','Haveli','Sahakarnagar','411009','','18.461288','73.871715','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');
INSERT INTO `retailer_data` VALUES('C005','MU09231000045','Ramdev Traders','Pune Sales Group','','700770','9284246210','Bharat Kumar','1','','Santoshnagar','Santoshnagar','','MH','Pune','Haveli','Katraj','411046','','18.446043','73.858765','','','','','','','','','','','','','','','','1','','','0','1','1','0','0','','','','','','','','','','','','','','','','');

-- Dump completed on 2026-05-12 17:15:51
