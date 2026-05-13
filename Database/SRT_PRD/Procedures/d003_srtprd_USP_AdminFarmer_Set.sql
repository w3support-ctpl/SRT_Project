-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFarmer_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFarmer_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Farmer_Id varchar(20),
    var_MCC_Farmer_Code varchar(20),
    var_Farmer_Code varchar(20),
	var_Farmer_Name varchar(45),
	var_Mobile_No varchar(20),
    var_AlternateMobile_No varchar(20),
    var_Email_Id varchar(45),
    var_Birth_Date DATETIME,
    var_Address_Text longtext,
	var_State_Id varchar(20),
	var_District_Id varchar(20),
	var_Taluka_Id varchar(20),
    var_Village_Id varchar(20),
    var_Cow_Count int,
    var_Buffalo_Count int,
    var_Calf_Count int,
    var_Milk_Capacity int,
	var_Pan_No varchar(20),
	var_Aadhar_No varchar(20),
	var_Bank_Id varchar(45),
    var_Branch_Id varchar(45),
	var_Account_No varchar(45),
	var_Account_Name varchar(45),
    var_Nominee_Name varchar(45),
	var_Nominee_Relation varchar(45),
	var_Nominee_Mobile_No varchar(45),
	var_Nominee_Aadhar_No varchar(45),
    var_Agent_Id varchar(20),
    var_MCC_Id varchar(20),
    var_Profile_Photo varchar(255),
	var_Pan_Card_Photo varchar(255),
	var_Aadhar_Card_Photo varchar(255),
	var_Ration_Card_Photo varchar(255),
    var_Bank_Cheque_PBook_Photo varchar(255),
	var_CreatedBy_Id varchar(20),
	var_CreatedBy_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_WithholdingTaxType_Id varchar(20),
    var_Gov_Farmer_Id varchar(50),
    var_Gov_Farmer_Name varchar(50)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Farmer_Id varchar(20);
			Declare Year_Id varchar(10);
            Declare New_Password varchar(45);
            Declare Set_MCCWorkType_Id varchar(45);
            Declare Set_MCC_Code varchar(45);
            /*
            if exists(select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id 
                and MCC_Id = var_MCC_Id and MCC_Farmer_Code = var_MCC_Farmer_Code and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'MCC Farmer Code already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
            elseif exists(select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Mobile Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Pan_No = var_Pan_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Pan Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Aadhar_No = var_Aadhar_No and Is_Deleted = 0) then
				SELECT -1 AS Result_Id, 
                'Aadhar Number already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            */
				set Year_Id = (select right(left(curdate(),4),(2)));
               
				Call USP_Number_Range ('mu04_farmer', Year_Id, 'MU04', '', New_Farmer_Id );
				set New_Password = CONCAT('Welcome@', YEAR(CURDATE()));
                
                SELECT MCCWorkType_Id into Set_MCCWorkType_Id  FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;
                
                IF Set_MCCWorkType_Id = 'C023001' THEN
                
					SELECT MCC_Code into Set_MCC_Code  FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;
                
					Insert Into mu04_farmer
					(Org_Id, Farmer_Id,Login_Name,Login_Password,Farmer_Code,Farmer_Name, Mobile_No,AlternateMobile_No,Email_Id,Is_MobileNo_Verified,Address_Text,Birth_Date, 
						State_Id,District_Id,Taluka_Id,Village_Id,Cow_Count,Buffalo_Count,Calf_Count,Milk_Capacity,
						Pan_No,Aadhar_No,Bank_Id,Branch_Id,Account_No,Account_Name,Nominee_Name,Nominee_Relation,
						Nominee_Mobile_No,Nominee_Aadhar_No,MCC_Id,Profile_Photo,Pan_Card_Photo,Aadhar_Card_Photo,
						Ration_Card_Photo,Bank_Cheque_PBook_Photo,
						Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,MCC_Farmer_Code,WithholdingTaxType_Id,
                        Gov_Farmer_Id,Gov_Farmer_Name)
					Values (var_Org_Id, New_Farmer_Id,var_Mobile_No,New_Password,Set_MCC_Code,var_Farmer_Name,var_Mobile_No,var_AlternateMobile_No,var_Email_Id,1,var_Address_Text,var_Birth_Date,
						var_State_Id,var_District_Id,var_Taluka_Id,var_Village_Id,var_Cow_Count,var_Buffalo_Count,var_Calf_Count,var_Milk_Capacity,
						var_Pan_No,var_Aadhar_No,var_Bank_Id,var_Branch_Id,var_Account_No,var_Account_Name,var_Nominee_Name,var_Nominee_Relation,
						var_Nominee_Mobile_No,var_Nominee_Aadhar_No,var_MCC_Id,var_Profile_Photo,var_Pan_Card_Photo,var_Aadhar_Card_Photo,
						var_Ration_Card_Photo,var_Bank_Cheque_PBook_Photo,
						var_Is_Active, var_Is_Deleted, Now(), var_CreatedBy_Id,var_CreatedBy_Name,var_MCC_Farmer_Code,var_WithholdingTaxType_Id,
                        var_Gov_Farmer_Id,var_Gov_Farmer_Name); 
				else
					Insert Into mu04_farmer
					(Org_Id, Farmer_Id,Login_Name,Login_Password,Farmer_Name, Mobile_No,AlternateMobile_No,Email_Id,Is_MobileNo_Verified,Address_Text,Birth_Date, 
						State_Id,District_Id,Taluka_Id,Village_Id,Cow_Count,Buffalo_Count,Calf_Count,Milk_Capacity,
						Pan_No,Aadhar_No,Bank_Id,Branch_Id,Account_No,Account_Name,Nominee_Name,Nominee_Relation,
						Nominee_Mobile_No,Nominee_Aadhar_No,MCC_Id,Profile_Photo,Pan_Card_Photo,Aadhar_Card_Photo,
						Ration_Card_Photo,Bank_Cheque_PBook_Photo,
						Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,MCC_Farmer_Code,WithholdingTaxType_Id,
                        Gov_Farmer_Id,Gov_Farmer_Name)
					Values (var_Org_Id, New_Farmer_Id,var_Mobile_No,New_Password,var_Farmer_Name,var_Mobile_No,var_AlternateMobile_No,var_Email_Id,1,var_Address_Text,var_Birth_Date,
						var_State_Id,var_District_Id,var_Taluka_Id,var_Village_Id,var_Cow_Count,var_Buffalo_Count,var_Calf_Count,var_Milk_Capacity,
						var_Pan_No,var_Aadhar_No,var_Bank_Id,var_Branch_Id,var_Account_No,var_Account_Name,var_Nominee_Name,var_Nominee_Relation,
						var_Nominee_Mobile_No,var_Nominee_Aadhar_No,var_MCC_Id,var_Profile_Photo,var_Pan_Card_Photo,var_Aadhar_Card_Photo,
						var_Ration_Card_Photo,var_Bank_Cheque_PBook_Photo,
						var_Is_Active, var_Is_Deleted, Now(), var_CreatedBy_Id,var_CreatedBy_Name,var_MCC_Farmer_Code,var_WithholdingTaxType_Id,
                        var_Gov_Farmer_Id,var_Gov_Farmer_Name); 
               end if;
                
                
                IF Set_MCCWorkType_Id = 'C023001' THEN
					SELECT 3 AS Result_Id, 
					'Saved' AS Result_Description, 
					New_Farmer_Id AS Result_Extra_Key;
				ELSE
					SELECT 1 AS Result_Id, 
					'Saved' AS Result_Description, 
					New_Farmer_Id AS Result_Extra_Key;
				END IF;
                
			-- end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			Declare Set_MCCWorkType_Id varchar(45);
            Declare Set_MCC_Code varchar(45);
            /*
			if exists(select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id 
                and MCC_Id = var_MCC_Id and MCC_Farmer_Code = var_MCC_Farmer_Code and Is_Deleted = 0 and Farmer_Id <> var_Farmer_Id) then
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
            */
				SELECT MCCWorkType_Id into Set_MCCWorkType_Id  FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;
                
                set @set_Is_Offline = (select Is_Offline 
										From mu04_farmer 
                                        where Org_Id = var_Org_Id 
                                        and Farmer_Id = var_Farmer_Id);
                                        
				if(@set_Is_Offline = '1' or @set_Is_Offline = 1) then
                
					Update mu04_farmer
					set 
					Login_Name = var_Mobile_No,
					Farmer_Name = var_Farmer_Name,
                    Farmer_Code = '',
					Mobile_No = var_Mobile_No,
					AlternateMobile_No = var_AlternateMobile_No,
					Email_Id = var_Email_Id,
					Address_Text = var_Address_Text,
					Birth_Date = var_Birth_Date,
					State_Id = var_State_Id,
					District_Id = var_District_Id,
					Taluka_Id = var_Taluka_Id,
					Village_Id = var_Village_Id,
					Cow_Count = var_Cow_Count,
					Buffalo_Count = var_Buffalo_Count,
					Calf_Count = var_Calf_Count,
					Milk_Capacity = var_Milk_Capacity,
					Pan_No = var_Pan_No,
					Aadhar_No = var_Aadhar_No,
					Bank_Id = var_Bank_Id, 
					Branch_Id = var_Branch_Id, 
					Account_No = var_Account_No,
					Account_Name = var_Account_Name,
					Nominee_Name = var_Nominee_Name,
					Nominee_Relation = var_Nominee_Relation,
					Nominee_Mobile_No = var_Nominee_Mobile_No,
					Nominee_Aadhar_No = var_Nominee_Aadhar_No,
					MCC_Id = var_MCC_Id,
					Profile_Photo = var_Profile_Photo,
					Pan_Card_Photo = var_Pan_Card_Photo,
					Aadhar_Card_Photo = var_Aadhar_Card_Photo,
					Ration_Card_Photo = var_Ration_Card_Photo,
					Bank_Cheque_PBook_Photo = var_Bank_Cheque_PBook_Photo,
					Is_Active =  var_Is_Active,
					Is_Deleted = var_Is_Deleted,
					LastEdited_On = NOW(),
					LastEditedBy_Id = var_CreatedBy_Id,
					LastEditedBy_Name = var_CreatedBy_Name ,
					MCC_Farmer_Code = var_MCC_Farmer_Code ,
                    WithholdingTaxType_Id = var_WithholdingTaxType_Id,
                    Gov_Farmer_Id = var_Gov_Farmer_Id,
                    Gov_Farmer_Name = var_Gov_Farmer_Name
					where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id; 
                
                else
                
                
                IF Set_MCCWorkType_Id = 'C023001' THEN
					SELECT MCC_Code into Set_MCC_Code  FROM m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id;
                
					Update mu04_farmer
					set 
					Login_Name = var_Mobile_No,
					Farmer_Name = var_Farmer_Name,
                    Farmer_Code = Set_MCC_Code,
					Mobile_No = var_Mobile_No,
					AlternateMobile_No = var_AlternateMobile_No,
					Email_Id = var_Email_Id,
					Address_Text = var_Address_Text,
					Birth_Date = var_Birth_Date,
					State_Id = var_State_Id,
					District_Id = var_District_Id,
					Taluka_Id = var_Taluka_Id,
					Village_Id = var_Village_Id,
					Cow_Count = var_Cow_Count,
					Buffalo_Count = var_Buffalo_Count,
					Calf_Count = var_Calf_Count,
					Milk_Capacity = var_Milk_Capacity,
					Pan_No = var_Pan_No,
					Aadhar_No = var_Aadhar_No,
					Bank_Id = var_Bank_Id, 
					Branch_Id = var_Branch_Id, 
					Account_No = var_Account_No,
					Account_Name = var_Account_Name,
					Nominee_Name = var_Nominee_Name,
					Nominee_Relation = var_Nominee_Relation,
					Nominee_Mobile_No = var_Nominee_Mobile_No,
					Nominee_Aadhar_No = var_Nominee_Aadhar_No,
					MCC_Id = var_MCC_Id,
					Profile_Photo = var_Profile_Photo,
					Pan_Card_Photo = var_Pan_Card_Photo,
					Aadhar_Card_Photo = var_Aadhar_Card_Photo,
					Ration_Card_Photo = var_Ration_Card_Photo,
					Bank_Cheque_PBook_Photo = var_Bank_Cheque_PBook_Photo,
					Is_Active =  var_Is_Active,
					Is_Deleted = var_Is_Deleted,
					LastEdited_On = NOW(),
					LastEditedBy_Id = var_CreatedBy_Id,
					LastEditedBy_Name = var_CreatedBy_Name ,
					MCC_Farmer_Code = var_MCC_Farmer_Code ,
                    WithholdingTaxType_Id = var_WithholdingTaxType_Id,
                    Gov_Farmer_Id = var_Gov_Farmer_Id,
                    Gov_Farmer_Name = var_Gov_Farmer_Name
					where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id;   
				else
					Update mu04_farmer
					set 
					Login_Name = var_Mobile_No,
					Farmer_Name = var_Farmer_Name,
					Mobile_No = var_Mobile_No,
					AlternateMobile_No = var_AlternateMobile_No,
					Email_Id = var_Email_Id,
					Address_Text = var_Address_Text,
					Birth_Date = var_Birth_Date,
					State_Id = var_State_Id,
					District_Id = var_District_Id,
					Taluka_Id = var_Taluka_Id,
					Village_Id = var_Village_Id,
					Cow_Count = var_Cow_Count,
					Buffalo_Count = var_Buffalo_Count,
					Calf_Count = var_Calf_Count,
					Milk_Capacity = var_Milk_Capacity,
					Pan_No = var_Pan_No,
					Aadhar_No = var_Aadhar_No,
					Bank_Id = var_Bank_Id, 
					Branch_Id = var_Branch_Id, 
					Account_No = var_Account_No,
					Account_Name = var_Account_Name,
					Nominee_Name = var_Nominee_Name,
					Nominee_Relation = var_Nominee_Relation,
					Nominee_Mobile_No = var_Nominee_Mobile_No,
					Nominee_Aadhar_No = var_Nominee_Aadhar_No,
					MCC_Id = var_MCC_Id,
					Profile_Photo = var_Profile_Photo,
					Pan_Card_Photo = var_Pan_Card_Photo,
					Aadhar_Card_Photo = var_Aadhar_Card_Photo,
					Ration_Card_Photo = var_Ration_Card_Photo,
					Bank_Cheque_PBook_Photo = var_Bank_Cheque_PBook_Photo,
					Is_Active =  var_Is_Active,
					Is_Deleted = var_Is_Deleted,
					LastEdited_On = NOW(),
					LastEditedBy_Id = var_CreatedBy_Id,
					LastEditedBy_Name = var_CreatedBy_Name ,
					MCC_Farmer_Code = var_MCC_Farmer_Code ,
                    WithholdingTaxType_Id = var_WithholdingTaxType_Id,
                    Gov_Farmer_Id = var_Gov_Farmer_Id,
                    Gov_Farmer_Name = var_Gov_Farmer_Name,
                    Is_Posted = 1
					where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id; 
				end if;
                
                end if;
                
                
                
                
                
                                        
				if(@set_Is_Offline = '1' or @set_Is_Offline = 1) then
                
					SELECT 3 AS Result_Id, 
					'Updated' AS Result_Description, 
					var_Farmer_Id AS Result_Extra_Key;
                
                else
                
					IF Set_MCCWorkType_Id = 'C023001' THEN
						SELECT 3 AS Result_Id, 
						'Updated' AS Result_Description, 
						var_Farmer_Id AS Result_Extra_Key;
					ELSE
						SELECT 1 AS Result_Id, 
						'Updated' AS Result_Description, 
						var_Farmer_Id AS Result_Extra_Key;
					END IF;
                
                end if;
                
			
			-- end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update mu04_farmer
			set 
            Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = Now(), 
			LastEditedBy_Id = var_CreatedBy_Id,
			LastEditedBy_Name = var_CreatedBy_Name
			where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id;    

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Farmer_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'UpdateFarmerCode') then
		begin
			Update mu04_farmer
			set 
            Farmer_Code = var_Farmer_Code
			where Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id;    

			SELECT 1 AS Result_Id, 
			'Update' AS Result_Description, 
			var_Farmer_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
