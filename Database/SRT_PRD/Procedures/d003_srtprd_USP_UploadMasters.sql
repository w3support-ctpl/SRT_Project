-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_UploadMasters` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_UploadMasters`(
Var_Method_Name varchar(50),
Var_Org_Id varchar(20)
)
BEGIN
SET SQL_SAFE_UPDATES = 0;
set sql_mode = '' ;

if(Var_Method_Name = 'UploadMcc')then 

set @Id  = 100001 ;

insert into mu05_agent (Org_Id , Agent_Id , Login_Password , Agent_Name ,  Mobile_No )
select Var_Org_Id as Org_Id, concat( 'MU05' , (@Id := @Id+1) ) , 'SRthorat@123' , Agent_Name, Mobile_No
from temp_mcc
group by Mobile_No ; 

update temp_mcc temp
left join c013_mcccategory c013 on temp.MCCCategory_Name = c013.MCCCategory_Name
left join c014_mcctype c014 on temp.MCCType_Name = c014.MCCType_Name
left join c023_mccworktype c023 on temp.MCCWorkType_Name = c023.MCCWorkType_Name
left join ml02_state ml02 on temp.State_Name = ml02.State_Name
left join ml03_district ml03 on temp.District_Name  = ml03.District_Name
left join ml04_taluka ml04 on temp.Taluka_Name = ml04.Taluka_Name
left join ml05_village ml05 on temp.Village_Name = ml05.Village_Name
left join m015_bank m015 on temp.Bank_Name = m015.Bank_Name
left join m016_branch m016 on temp.Branch_Name = m016.Branch_Name 
left join c022_mustertype c022 on temp.MusterType = c022.MusterType_Name 
left join c024_paymentcycle c024 on temp.PaymentCycle = c024.PaymentCycle_Name 
left join c033_paymenttype C033 on temp.PaymentType = C033.PaymentType_Name
left join mu05_agent mu05 on temp.Agent_Name = mu05.Agent_Name
set temp.Org_Id = Var_Org_Id ,
temp.MCCCategory_Name = c013.MCCCategory_Id,
temp.MCCType_Name = c014.MCCType_Id ,
temp.MCCWorkType_Name  = c023.MCCWorkType_Id,
temp.State_Name = ml02.State_Id,
temp.District_Name = ml03.District_Id,
temp.Taluka_Name = ml04.Taluka_Id,
temp.Village_Name = ml05.Village_Id,
temp.Bank_Name = m015.Bank_Id , 
temp.Branch_Name = m016.Branch_Id,
temp.MusterType = c022.MusterType_Id,
temp.PaymentCycle = c024.PaymentCycle_Id,
temp.PaymentType = C033.PaymentType_Id,
temp.Agent_Name = mu05.Agent_Id,
temp.MilkType_Buffalo = if (temp.MilkType_Buffalo = 'YES' , 'C011002' , '' ),
temp.MilkType_Cow = if (temp.MilkType_Cow = 'YES' , 'C011001' , '' ),
temp.CollectionShift_Morning = if (temp.CollectionShift_Morning = 'YES' , 'C015001' , '' ),
temp.CollectionShift_Evening = if (temp.CollectionShift_Evening = 'YES' , 'C015002' , '' ) ;


insert into m005_mcc (Org_Id, MCC_Id, MCC_Name, MCC_Code, MCCCategory_Id, MCCType_Id, 
MCCWorkType_Id, Agent_Id, Mobile_No, State_Id, District_Id, Taluka_Id, Village_Id, 
Address_Text, Pan_No, Aadhar_No, Bank_Id, Branch_Id, Account_No, IFSC_Code, FSSAILicense_No, 
FSSAILicenseValidity_On, Account_Name, MusterType_Id, PaymentCycle_Id, PaymentType_Id, MilkType_Id, 
CollectionShift_Id, Latitude, Longitude,
Is_ManualWeight, Is_ManualQuality, Is_ManualShiftEnd, Is_ExtraTime, Is_Active, Is_Deleted, Created_On )
select Var_Org_Id as Org_Id, concat( 'M005' , MCC_Code ) as MCC_Id , MCC_Name, MCC_Code,  MCCCategory_Name, MCCType_Name, 
MCCWorkType_Name, Agent_Name, Mobile_No, State_Name, District_Name, Taluka_Name, Village_Name, 
Address_Text, Pan_No, Aadhar_No, Bank_Name, Branch_Name, Account_No, IFSC_No, FSSAILicense_No, 
STR_TO_DATE(if(FSSAILicenseValidity_On in ('' , null ), now() , FSSAILicenseValidity_On),  '%Y-%m-%d %H:%i:%s'), Account_Name, MusterType, PaymentCycle, PaymentType, concat(MilkType_Buffalo, MilkType_Cow ), 
concat(CollectionShift_Morning, CollectionShift_Evening ) , Latitude, Longitude ,
 0 , 0 , 0 , 0, 1, 0 , Now()
from temp_mcc;


insert into m005_mcc_version (Org_Id, MCC_Id, Version_No, MusterType_Id, PaymentCycle_Id, CollectionShift_Name, 
MilkType_Name, Applicable_Date, Is_Active, Is_Deleted)
select tm.Org_Id , MCC_Id , 1, MusterType_Id , PaymentCycle_Id, concat(if (CollectionShift_Morning <> '' , 'Morning' , '' ) , if (CollectionShift_Morning <> '' , ' | ' , '' ) ,
if(CollectionShift_Evening <> '' , 'Evening' , '' )) , concat(if(MilkType_Cow <> '' , 'Cow' , '' ) , if(MilkType_Cow <> '' , ' | ' , '' ) ,
if(MilkType_Buffalo <> '' , 'Buffalo' , '' )) , now() , 1 , 0
from temp_mcc tm 
left join m005_mcc m005 on tm.MCC_Name = m005.MCC_Name
where tm.Org_Id = Var_Org_Id;


insert into m005_mcc_milktype (Org_Id , MCC_Id , MilkType_Id, Version_No)
select tm.Org_Id , MCC_Id , MilkType_Buffalo , 1
from temp_mcc tm 
left join m005_mcc m005 on tm.MCC_Name = m005.MCC_Name
where (MilkType_Buffalo <> '') and tm.Org_Id = Var_Org_Id;

insert into m005_mcc_milktype (Org_Id , MCC_Id , MilkType_Id, Version_No)
select tm.Org_Id , MCC_Id , MilkType_Cow , 1
from temp_mcc tm 
left join m005_mcc m005 on tm.MCC_Name = m005.MCC_Name
where (MilkType_Cow <> '') and tm.Org_Id = Var_Org_Id ;


insert into m005_mcc_collectionshift (Org_Id, MCC_Id, CollectionShift_Id, Version_No)
select tm.Org_Id , MCC_Id , CollectionShift_Evening , 1
from temp_mcc tm 
left join m005_mcc m005 on tm.MCC_Name = m005.MCC_Name
where (CollectionShift_Evening <> '') and tm.Org_Id = Var_Org_Id ;

insert into m005_mcc_collectionshift (Org_Id, MCC_Id, CollectionShift_Id, Version_No)
select tm.Org_Id , MCC_Id , CollectionShift_Morning , 1
from temp_mcc tm 
left join m005_mcc m005 on tm.MCC_Name = m005.MCC_Name
where (CollectionShift_Morning <> '') and tm.Org_Id = Var_Org_Id ;



elseif(Var_Method_Name = 'UploadFarmer')then 

set @Id  = 241026653 ;

insert into mu04_farmer (Org_Id, Farmer_Id, Login_Name, Login_Password, Farmer_Name, Farmer_Code, MCC_Farmer_Code, Mobile_No,
 AlternateMobile_No, Email_Id, Birth_Date, Is_MobileNo_Verified, Address_Text, State_Id, District_Id,
 Taluka_Id, Village_Id, Pincode, Cow_Count, Buffalo_Count, Calf_Count, Milk_Capacity, Pan_No, 
 Aadhar_No, Bank_Id, Branch_Id, IFSC_Code, Account_No, Account_Name, Nominee_Name, Nominee_Relation, 
 Nominee_Mobile_No, Nominee_Aadhar_No, MCC_Id, Agent_Id )
select Var_Org_Id ,   concat( 'MU04' , (@Id := @Id+1) ),temp.Farmer_Name ,  'Srthorat@123',
 temp.Farmer_Name, temp.Farmer_Code, temp.MCC_Farmer_Code, 
temp.Mobile_No, temp.AlternateMobile_No, temp.Email_Id, temp.Birth_Date, 0,  temp.Address_Text, ml02.State_Id,
 ml03.District_Id, ml04.Taluka_Id, ml05.Village_Id, Pincode, Cow_Count, Buffalo_Count, 
 temp.Calf_Count, temp.Milk_Capacity, temp.Pan_No, temp.Aadhar_No, m015.Bank_Id, m016.Branch_Id, temp.IFSC_Code,
 temp.Account_No, temp.Account_Name, temp.Nominee_Name, c030.NomineeRelation_Id , temp.Nominee_Mobile_No, 
 temp.Nominee_Aadhar_No, m005.MCC_Id , m005.Agent_Id from temp_farmer4 temp
left join ml02_state ml02 on temp.State_Name = ml02.State_Name
left join ml03_district ml03 on temp.District_Name  = ml03.District_Name
left join ml04_taluka ml04 on temp.Taluka_Name = ml04.Taluka_Name
left join ml05_village ml05 on temp.Village_Name = ml05.Village_Name 
left join m015_bank m015 on temp.Bank_Name = m015.Bank_Name
left join m016_branch m016 on temp.Branch_Name = m016.Branch_Name 
left join c030_nomineerelation c030 on temp.Nominee_Relation = c030.NomineeRelation_Name
left join m005_mcc m005 on temp.MCC_Code = m005.MCC_Code 
group by temp.Farmer_Code;


else 


set @Id = 1;
insert into m009_transporter(Org_Id, Transporter_Id, Transporter_Name, Transporter_Code, 
ContactPerson_Name, Mobile_No, Is_MobileNo_Verified , 
State_Id, District_Id, Taluka_Id, Village_Id, Pincode, Bank_Id, Branch_Id, Account_No, IFSC_Code,
 Account_Name, LicenseValidity_On, Company_Pan_No, FSSAI_License_No, Is_Active, Is_Deleted )
select Var_Org_Id , concat( 'MU04' , (@Id := @Id+1) ) , temp.Transporter_Name, temp.Transporter_Code, 
temp.ContactPerson_Name, temp.Mobile_No, 1, ml02.State_Id,
 ml03.District_Id, ml04.Taluka_Id, ml05.Village_Id,
temp.Pincode, m015.Bank_Id, m016.Branch_Id , temp.Account_No, temp.IFSC_No, 
temp.Account_Name, STR_TO_DATE(if(temp.LicenseValidity_On in ('' , null ), now() , temp.LicenseValidity_On),  '%Y-%m-%d %H:%i:%s') , 
temp.Company_Pan_No, temp.FSSAI_License_No , 1 , 0
from temp_transporter temp 
left join ml02_state ml02 on temp.State_Name = ml02.State_Name
left join ml03_district ml03 on temp.Distict_Name  = ml03.District_Name
left join ml04_taluka ml04 on temp.Taluka_Name = ml04.Taluka_Name
left join ml05_village ml05 on temp.Village_Name = ml05.Village_Name 
left join m015_bank m015 on temp.Bank_Name = m015.Bank_Name
left join m016_branch m016 on temp.Branch_Name = m016.Branch_Name 
group by temp.Transporter_Code;


end if;


END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
