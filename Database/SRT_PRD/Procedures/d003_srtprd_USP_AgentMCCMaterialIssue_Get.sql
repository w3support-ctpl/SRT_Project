-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCMaterialIssue_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCMaterialIssue_Get`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_User_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Farmer_Id varchar(20),
    var_Issue_Id varchar(20),
    var_Date VARCHAR(45)
)
BEGIN
	If(var_Method_Name = 'Get')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
			
			select t106.Issue_Id,mu04.Farmer_Id,
            mu04.Farmer_Name,mu04.MCC_Farmer_Code,
            date_format(t106.Issue_Date, '%d %M %Y') as Issue_Date,
            t106.Material,t106.Quantity,t106.Rate,t106.Amount,t106.Is_Paid
			from t106_mcc_material_issue t106
            inner join mu04_farmer mu04 on
            mu04.Org_Id = t106.Org_Id
            and mu04.Farmer_Id = t106.Farmer_Id
			where t106.Org_Id = var_Org_Id
			and t106.MCC_Id = var_MCC_Id
            AND CAST(t106.Issue_Date AS DATE) >= var_StartDate 
			AND CAST(t106.Issue_Date AS DATE) <= var_EndDate
            and t106.Is_Active = 1;
        end;
	elseif(var_Method_Name = 'Get_One')then 
		begin
			select t106.Issue_Id,mu04.Farmer_Id,
            -- mu04.Farmer_Name,
            concat(mu04.Farmer_Name,' [ ' , mu04.MCC_Farmer_Code , ' ] ') as Farmer_Name,
            date_format(t106.Issue_Date, '%d %M %Y') as Issue_Date,
            t106.Material,t106.Quantity,t106.Rate,t106.Amount,t106.Is_Paid,
            t106.Amount_Interest,t106.No_Of_Installments
			from t106_mcc_material_issue t106
            inner join mu04_farmer mu04 on
            mu04.Org_Id = t106.Org_Id
            and mu04.Farmer_Id = t106.Farmer_Id
			where t106.Org_Id = var_Org_Id
			and t106.MCC_Id = var_MCC_Id
            and t106.Issue_Id = var_Issue_Id
            and t106.Is_Active = 1;
        end;
	elseif (Var_Method_Name = 'GetFarmer') then
		begin
			select 
			Farmer_Id, 
            concat(Farmer_Name,' [ ' , MCC_Farmer_Code , ' ] ') as Farmer_Name
			from mu04_farmer
			where Org_Id = Var_Org_Id
			and MCC_Id = Var_MCC_Id
            and MCC_Farmer_Code = var_Farmer_Id
            and Is_Active = 1
            and Is_Deleted = 0;
        end;
	elseif (Var_Method_Name = 'GetMaterial') then
		begin
			SELECT 'Milk' as item_Id, 'Milk' as item_Value
			UNION ALL
			SELECT 'Butter' as item_Id, 'Butter' as item_Value
			UNION ALL
			SELECT 'Cheese' as item_Id, 'Cheese' as item_Value
			UNION ALL
			SELECT 'Yogurt' as item_Id, 'Yogurt' as item_Value
			UNION ALL
			SELECT 'Cream' as item_Id, 'Cream' as item_Value
			UNION ALL
			SELECT 'Ice Cream' as item_Id, 'Ice Cream' as item_Value
			UNION ALL
			SELECT 'Cottage Cheese' as item_Id, 'Cottage Cheese' as item_Value
			UNION ALL
			SELECT 'Sour Cream' as item_Id, 'Sour Cream' as item_Value
			UNION ALL
			SELECT 'Whipping Cream' as item_Id, 'Whipping Cream' as item_Value
			UNION ALL
			SELECT 'Ghee' as item_Id, 'Ghee' as item_Value
            UNION ALL
            select Material_Id as item_Id, Material_Name as item_Value
			from m101_mcc_material
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
            and Is_Active = 1;

            
            
        end;
	elseif (Var_Method_Name = 'GetView') then
		begin
			select 
			ifnull(t106.Entry_Id,'')as Entry_Id,
			DATE_FORMAT(ifnull(t106.Date,''),'%d %M %Y') as Deduction_Date,
			ifnull(t106.Amount,0)as Deduction_Amount,
			ifnull(t106.Is_Deducted,0) as Is_Deducted
			from t106_mcc_material_issue_item t106 
			where t106.Org_Id = var_Org_Id
			and t106.Issue_Id = var_Issue_Id;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
