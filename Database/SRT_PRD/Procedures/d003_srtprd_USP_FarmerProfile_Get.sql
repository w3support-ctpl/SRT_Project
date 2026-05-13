-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerProfile_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerProfile_Get`(
	var_Method_Name varchar(20),
	var_Org_Id varchar(20),
	var_Profile_Id varchar(20)
)
BEGIN
	if(var_Method_Name = 'GetFarmerInfo' ) then
		if((select Is_Approved from t002_farmerregistration where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id) = 0 ) then
			select Is_Approved as Is_Approved , Farmer_Id , ifnull(Farmer_Name,'') as Farmer_Name ,
            ifnull(Address_Text,'') as Address_Text , ifnull(State_Id,'') as State_Id, 
            ifnull(District_Id,'') as District_Id, ifnull(Village_Id,'') as Village_Id, 
            ifnull(Taluka_Id,'') as Taluka_Id , 
            ifnull(Pincode,'') as Pincode, 
            ifnull(Cow_Count,'') as Cow_Count, 
            ifnull(Buffalo_Count,'') as Buffalo_Count , 
            ifnull(Calf_Count,'') as Calf_Count, 
            ifnull(Milk_Capacity,'') as Milk_Capacity , 
            ifnull(Bank_Id,'') as Bank_Id, 
            ifnull(Account_Name,'') as Account_Name, 
            ifnull(Account_No,'') as Account_No, 
            ifnull(Branch_Id,'') as Branch_Id,
            ifnull(IFSC_Code,'') as  IFSC_Code , 
            ifnull(Nominee_Name,'') as Nominee_Name, 
            ifnull(Nominee_Relation,'') as Nominee_Relation,
            ifnull(NomineeRelation_Name, '') as NomineeRelation_Name,
			ifnull(Nominee_Mobile_No,'') as Nominee_Mobile_No,
			ifnull(Nominee_Aadhar_No,'') as Nominee_Aadhar_No,
            ifnull(Birth_Date ,'') as Birth_Date,
            ifnull(Profile_Photo,'') as Profile_Photo,
            ifnull(Pan_Card_Photo,'') as Pan_Card_Photo,
            ifnull(Aadhar_Card_Photo,'') as Aadhar_Card_Photo,
            ifnull(Ration_Card_Photo,'') as Ration_Card_Photo,
            ifnull(Bank_Cheque_PBook_Photo,'') as Bank_Cheque_Photo,
			ifnull(Email_Id,'') as Email_Id,
            ifnull(Pan_No,'') as Pan_No,
			ifnull(Aadhar_No,'') as Aadhar_No,
            ifnull(AlternateMobile_No,'') as AlternateMobile_No
            from t002_farmerregistration t002 left join c030_nomineerelation c030 on t002.Nominee_Relation =  c030.NomineeRelation_Id
            where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id;
            

          select  t002.State_Id as Item_Id, ml02.State_Name as Item_Value  from t002_farmerregistration t002 inner join ml02_state ml02 on 
            t002.Org_Id = ml02.Org_Id and  t002.State_Id = ml02.State_Id where  
            t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;
            
            select  t002.District_Id as Item_Id, District_Name as Item_Value from t002_farmerregistration t002 inner join ml03_district ml03 on 
             t002.Org_Id = ml03.Org_Id and  t002.District_Id = ml03.District_Id where  
             t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;
             
                         
			select  t002.Village_Id as Item_Id, Village_Name as Item_Value from t002_farmerregistration t002 inner join ml05_village ml05 on 
             t002.Org_Id = ml05.Org_Id and  t002.Village_Id = ml05.Village_Id where  
             t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;
             
             
            
            select  t002.Taluka_Id as Item_Id, Taluka_Name as Item_Value from t002_farmerregistration t002 inner join ml04_taluka ml04 on 
             t002.Org_Id = ml04.Org_Id and  t002.Taluka_Id = ml04.Taluka_Id where  
             t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;

			select  t002.Bank_Id as Item_Id, Bank_Name as Item_Value from t002_farmerregistration t002 inner join m015_bank m015 on 
             t002.Org_Id = m015.Org_Id and  t002.Bank_Id = m015.Bank_Id where  
             t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;   
             
             select t002.Branch_Id as Item_Id, Branch_Name as Item_Value from t002_farmerregistration t002 inner join m016_branch m016 on 
             t002.Org_Id = m016.Org_Id and  t002.Branch_Id = m016.Branch_Id where  
             t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;  
             
            
            
		else 
           select 1 as Is_Approved , Farmer_Id , ifnull(Farmer_Name,'') as Farmer_Name ,
            ifnull(Address_Text,'') as Address_Text , ifnull(State_Id,'') as State_Id, 
            ifnull(District_Id,'') as District_Id, ifnull(Village_Id,'') as Village_Id, 
            ifnull(Taluka_Id,'') as Taluka_Id , 
            ifnull(Pincode,'') as Pincode, 
            ifnull(Cow_Count,'') as Cow_Count, 
            ifnull(Buffalo_Count,'') as Buffalo_Count , 
            ifnull(Calf_Count,'') as Calf_Count, 
            ifnull(Milk_Capacity,'') as Milk_Capacity , 
            ifnull(Bank_Id,'') as Bank_Id, 
            ifnull(Account_Name,'') as Account_Name, 
            ifnull(Account_No,'') as Account_No, 
            ifnull(IFSC_Code,'') as  IFSC_Code , 
            ifnull(Branch_Id,'') as Branch_Id,
            ifnull(Nominee_Name,'') as Nominee_Name, 
            ifnull(Nominee_Relation,'') as Nominee_Relation,
            ifnull(NomineeRelation_Name, '') as NomineeRelation_Name,
			ifnull(Nominee_Mobile_No,'') as Nominee_Mobile_No,
			ifnull(Nominee_Aadhar_No,'') as Nominee_Aadhar_No,
            ifnull(Birth_Date,'') as Birth_Date,
            ifnull(Profile_Photo,'') as Profile_Photo,
            ifnull(Pan_Card_Photo,'') as Pan_Card_Photo,
            ifnull(Aadhar_Card_Photo,'') as Aadhar_Card_Photo,
            ifnull(Ration_Card_Photo,'') as Ration_Card_Photo,
            ifnull(Bank_Cheque_PBook_Photo,'') as Bank_Cheque_Photo,
            ifnull(Email_Id,'') as Email_Id,
            ifnull(Pan_No,'') as Pan_No,
			ifnull(Aadhar_No,'') as Aadhar_No,
            ifnull(AlternateMobile_No,'') as AlternateMobile_No
            from mu04_farmer mu04 left join c030_nomineerelation c030 on mu04.Nominee_Relation =  c030.NomineeRelation_Id
            where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id;


			select  t002.State_Id as Item_Id, ml02.State_Name as Item_Value  from mu04_farmer t002 inner join ml02_state ml02 on 
            t002.Org_Id = ml02.Org_Id and  t002.State_Id = ml02.State_Id where  
            t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;
            
            select  t002.District_Id as Item_Id, District_Name as Item_Value from mu04_farmer t002 inner join ml03_district ml03 on 
             t002.Org_Id = ml03.Org_Id and  t002.District_Id = ml03.District_Id where  
             t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;
            
    
			select  t002.Village_Id as Item_Id, Village_Name as Item_Value from mu04_farmer t002 inner join ml05_village ml05 on 
             t002.Org_Id = ml05.Org_Id and  t002.Village_Id = ml05.Village_Id where  
             t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;    
             
                     select  t002.Taluka_Id as Item_Id, Taluka_Name as Item_Value from mu04_farmer t002 inner join ml04_taluka ml04 on 
             t002.Org_Id = ml04.Org_Id and  t002.Taluka_Id = ml04.Taluka_Id where  
             t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;
            
             
             select  t002.Bank_Id as Item_Id, Bank_Name as Item_Value from mu04_farmer t002 inner join m015_bank m015 on 
             t002.Org_Id = m015.Org_Id and  t002.Bank_Id = m015.Bank_Id where  
             t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;   
             
             select t002.Branch_Id as Item_Id, Branch_Name as Item_Value from mu04_farmer t002 inner join m016_branch m016 on 
             t002.Org_Id = m016.Org_Id and  t002.Branch_Id = m016.Branch_Id where  
             t002.Org_Id = var_Org_Id and  t002.Farmer_Id = var_Profile_Id;   
            
		end if;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
