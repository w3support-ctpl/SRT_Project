-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerProfiles_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerProfiles_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_Farmer_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get_One') then
		begin
			select 
			IFNULL(mu04.Org_Id, '') AS Org_Id,
			IFNULL(mu04.Farmer_Id, '') AS Farmer_Id,
			IFNULL(mu04.Farmer_Name, '') AS Farmer_Name,
			IFNULL(mu04.MCC_Farmer_Code, '') AS MCC_Farmer_Code,
			IFNULL(mu04.Mobile_No, '') AS Mobile_No,
			IFNULL(mu04.AlternateMobile_No, '') AS AlternateMobile_No,
			IFNULL(mu04.Email_Id, '') AS Email_Id,
			IFNULL(date(mu04.Birth_Date), '') AS Birth_Date,
			IFNULL(mu04.Address_Text, '') AS Address_Text,
			IFNULL(ml02.State_Id, '') AS State_Id,IFNULL(ml02.State_Name, '') AS State_Name,
			IFNULL(ml03.District_Id, '') AS District_Id,IFNULL(ml03.District_Name, '') AS District_Name,
			IFNULL(ml04.Taluka_Id, '') AS Taluka_Id,IFNULL(ml04.Taluka_Name, '') AS Taluka_Name,
			IFNULL(ml05.Village_Id, '') AS Village_Id,IFNULL(ml05.Village_Name, '') AS Village_Name,
			IFNULL(ml05.Pin_Code, '') AS Pincode,
			IFNULL(mu04.Cow_Count, '') AS Cow_Count,
			IFNULL(mu04.Buffalo_Count, '') AS Buffalo_Count,
			IFNULL(mu04.Calf_Count, '') AS Calf_Count,
			IFNULL(mu04.Milk_Capacity, '') AS Milk_Capacity,
			IFNULL(mu04.Pan_No, '') AS Pan_No,
			IFNULL(mu04.Aadhar_No, '') AS Aadhar_No,
			IFNULL(m015.Bank_Id, '') AS Bank_Id,IFNULL(m015.Bank_Name, '') AS Bank_Name,
			IFNULL(m016.Branch_Id, '') AS Branch_Id,IFNULL(m016.Branch_Name, '') AS Branch_Name,
			IFNULL(m016.IFSC_Code, '') AS IFSC_Code,
			IFNULL(mu04.Account_No, '') AS Account_No,
			IFNULL(mu04.Account_Name, '') AS Account_Name,
			IFNULL(mu04.Nominee_Name, '') AS Nominee_Name,
			IFNULL(c030.NomineeRelation_Id, '') AS NomineeRelation_Id,IFNULL(c030.NomineeRelation_Name, '') AS NomineeRelation_Name,
			IFNULL(mu04.Nominee_Mobile_No, '') AS Nominee_Mobile_No,
			IFNULL(mu04.Nominee_Aadhar_No, '') AS Nominee_Aadhar_No
			from mu04_farmer mu04
			left join m005_mcc m005 on m005.MCC_Id = mu04.MCC_Id and m005.Org_Id = mu04.Org_Id 
			left join ml02_state ml02 on ml02.Org_Id = mu04.Org_Id and ml02.State_Id = mu04.State_Id
			left join ml03_district ml03 on ml03.Org_Id = mu04.Org_Id and ml03.District_Id = mu04.District_Id
			left join ml04_taluka ml04 on ml04.Org_Id = mu04.Org_Id and ml04.Taluka_Id = mu04.Taluka_Id
			left join ml05_village ml05 on ml05.Village_Id = mu04.Village_Id and ml05.Org_Id = mu04.Org_Id
			left join m015_bank m015 on m015.Org_Id = mu04.Org_Id and m015.Bank_Id = mu04.Bank_Id
			left join m016_branch m016 on m016.Org_Id = mu04.Org_Id and m016.Branch_Id = mu04.Branch_Id
			and m016.Bank_Id = mu04.Bank_Id
			left join c030_nomineerelation c030 on c030.NomineeRelation_Id = mu04.Nominee_Relation
			where mu04.Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id
			and mu04.Is_Offline = 1
			and mu04.Is_Deleted = 0;
        end;
	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
