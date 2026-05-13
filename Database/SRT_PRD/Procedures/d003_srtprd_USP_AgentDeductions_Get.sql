-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentDeductions_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentDeductions_Get`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(20),
    var_Entry_Period VARCHAR(45),
    Var_Profile_Id VARCHAR(45),
    var_MCC_Id VARCHAR(45),
    var_Farmer_Id VARCHAR(45),
    var_Deductions_Id VARCHAR(45)
)
BEGIN
	if(var_Method_Name = 'Get') then
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Entry_Period, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Entry_Period, ' - ', -1), '%m/%d/%Y');
            
            select 
            t033.Deductions_Id,
			DATE_FORMAT(t033.Entry_Date,'%d %M %Y') AS Entry_Date, 
			ifnull(t033.Total_Amount,0) as Total_Amount,
			ifnull(t033.Amount_Interest,0) as Amount_Interest,
			ifnull(t033.No_Of_Installments,0) as No_Of_Installments,
			ifnull(t033.Amount_Deducted,0) as Amount_Deducted,
			ifnull(t033.Balance,0) as Balance
			from t033_deductions_header_offline t033 
			where t033.Org_Id = var_Org_Id
			and t033.MCC_Id = var_MCC_Id
			and t033.Farmer_Id = var_Farmer_Id
			and date(t033.Entry_Date) >= date(var_StartDate)
			and  date(t033.Entry_Date) <= date(var_EndDate);

        end;
	elseif(var_Method_Name = 'Get_One') then
		begin
			select 
			ifnull(t033.Entry_Id,'')as Entry_Id,
			DATE_FORMAT(ifnull(t033.Deduction_Date,''),'%d %M %Y') as Deduction_Date,
			ifnull(t033.Deduction_Amount,0)as Deduction_Amount,
			ifnull(t033.Is_Deducted,0) as Is_Deducted
			from t033_deductions_item_offline t033 
			where t033.Org_Id = var_Org_Id
			and t033.Deductions_Id = var_Deductions_Id;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
