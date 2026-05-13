-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFarmerRegistration_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFarmerRegistration_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_ApprovalStatus_Id varchar(20),
    var_Date varchar(60),
    var_Farmer_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			DECLARE var_StartDate DATE;
            DECLARE var_EndDate DATE;

            SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
            SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
			select t002.Org_Id,Farmer_Id, 
             ml05.Village_Id, ifnull(ml05.Village_Name,'') as Village_Name,
            ifnull(Farmer_Name,'') as Farmer_Name, 
            ifnull(t002.Mobile_No,'') as Mobile_No, t002.Is_Approved,
            date_format(t002.Request_Date, '%d %M %Y') as Request_Date,
			IFNULL(DATE_FORMAT(t002.Approved_On, '%d %M %Y'), '') AS Approved_On
            from t002_farmerregistration t002
            left join ml05_village ml05 on ml05.Village_Id = t002.Village_Id
            and  ml05.Org_Id = t002.Org_Id
            where t002.Org_Id = var_Org_Id 
            and (var_ApprovalStatus_Id = '' or t002.Is_Approved = var_ApprovalStatus_Id)
            and 
            CAST(t002.Request_Date AS DATE) >= var_StartDate and 
            CAST(t002.Request_Date AS DATE) <= var_EndDate
            order by t002.Request_Date DESC;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select t002.Org_Id, Farmer_Id, Farmer_Name, Mobile_No,MCC_Id,ifnull(MCC_Farmer_Code ,'') as MCC_Farmer_Code,
            ifnull(AlternateMobile_No,'') as AlternateMobile_No,ifnull(Email_Id,'') as Email_Id,
            date_format(Birth_Date, '%Y-%m-%d') as Birth_Date,
            Pan_No,Aadhar_No,Cow_Count,Buffalo_Count,Calf_Count,Milk_Capacity,
            State_Id,District_Id,Taluka_Id,Village_Id,t002.Address_Text,t002.Bank_Id,t002.Branch_Id,Account_No,
            m016.IFSC_Code,Account_Name,Nominee_Name,Nominee_Relation,Nominee_Mobile_No,
            Nominee_Aadhar_No,Profile_Photo,Pan_Card_Photo,Aadhar_Card_Photo,Ration_Card_Photo,
            Bank_Cheque_PBook_Photo ,Is_Approved,Approval_Remarks,Request_Date,
            ifnull(t002.WithholdingTaxType_Id,'') as WithholdingTaxType_Id,
            ifnull(t002.Gov_Farmer_Id,'') as Gov_Farmer_Id,
            ifnull(t002.Gov_Farmer_Name,'') as Gov_Farmer_Name
            from t002_farmerregistration t002
            left join m016_branch m016 on m016.Branch_Id = t002.Branch_Id 
            and m016.Org_Id = t002.Org_Id 
            where t002.Org_Id = var_Org_Id 
            and Farmer_Id = var_Farmer_Id;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
