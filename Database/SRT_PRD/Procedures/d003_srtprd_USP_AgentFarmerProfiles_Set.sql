-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerProfiles_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerProfiles_Set`(
		var_Method_Name longtext,
		var_Org_Id longtext,
		var_Farmer_Id longtext,
		var_Farmer_Name longtext,
		var_MCC_Farmer_Code longtext,
		var_Mobile_No longtext,
		var_AlternateMobile_No longtext,
		var_Email_Id longtext,
		var_Birth_Date longtext,
		var_Address_Text longtext,
		var_State_Id longtext,
		var_District_Id longtext,
		var_Taluka_Id longtext,
		var_Village_Id longtext,
		var_Cow_Count int,
		var_Buffalo_Count int,
		var_Calf_Count int,
		var_Milk_Capacity int,
		var_Pan_No longtext,
		var_Aadhar_No longtext,
		var_Bank_Id longtext,
		var_Branch_Id longtext,
		var_IFSC_Code longtext,
		var_Account_No longtext,
		var_Account_Name longtext,
		var_Nominee_Name longtext,
		var_NomineeRelation_Id longtext,
		var_Nominee_Mobile_No longtext,
		var_Nominee_Aadhar_No longtext
)
BEGIN
	if (var_Method_Name = 'Update') then
		begin
        
        set @var_MCC_Id = (select MCC_Id from mu04_farmer where Org_Id = var_Org_Id  and  Farmer_Id =  var_Farmer_Id) ;
        
		if exists(select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id 
              and MCC_Id = @var_MCC_Id   and MCC_Farmer_Code = var_MCC_Farmer_Code and Is_Deleted = 0 and Farmer_Id <> var_Farmer_Id) then
				SELECT -1 AS Result_Id, 
                'MCC Farmer Code already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0 and Farmer_Id <> var_Farmer_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0 and Farmer_Id <> var_Farmer_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Pan Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Aadhar_No = var_Aadhar_No and Is_Deleted = 0 and Farmer_Id <> var_Farmer_Id
            ) then
				SELECT -1 AS Result_Id, 
                'Aadhar Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
            -- Pincode = var_Pincode ,
            
				set @var_Pincode = (select Pin_Code from ml05_village 
                where Org_Id = var_Org_Id
                and Village_Id = var_Village_Id);
            
				Update mu04_farmer
					set
				Org_Id = var_Org_Id ,
				Farmer_Id = var_Farmer_Id ,
				Farmer_Name = var_Farmer_Name ,
				MCC_Farmer_Code = var_MCC_Farmer_Code ,
				Mobile_No = var_Mobile_No ,
				AlternateMobile_No = var_AlternateMobile_No ,
				Email_Id = var_Email_Id ,
				Birth_Date = var_Birth_Date ,
				Address_Text = var_Address_Text ,
				State_Id = var_State_Id ,
				District_Id = var_District_Id ,
				Taluka_Id = var_Taluka_Id ,
				Village_Id = var_Village_Id ,
				Pincode = @var_Pincode,
				Cow_Count = var_Cow_Count ,
				Buffalo_Count = var_Buffalo_Count ,
				Calf_Count = var_Calf_Count ,
				Milk_Capacity = var_Milk_Capacity ,
				Pan_No = var_Pan_No ,
				Aadhar_No = var_Aadhar_No ,
				Bank_Id = var_Bank_Id ,
				Branch_Id = var_Branch_Id ,
				IFSC_Code = var_IFSC_Code ,
				Account_No = var_Account_No ,
				Account_Name = var_Account_Name ,
				Nominee_Name = var_Nominee_Name ,
				Nominee_Relation = var_NomineeRelation_Id ,
				Nominee_Mobile_No = var_Nominee_Mobile_No ,
				Nominee_Aadhar_No = var_Nominee_Aadhar_No 
				where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id; 
                
                SELECT 1 AS Result_Id, 
				'Updated' AS Result_Description, 
				var_Farmer_Id AS Result_Extra_Key;
		
			end if;
			
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
