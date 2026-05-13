-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCFarmerDeduction_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCFarmerDeduction_Get`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_User_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Farmer_Id varchar(20),
    var_Deduction_Id varchar(20),
    var_Date VARCHAR(45)
)
BEGIN
	If(var_Method_Name = 'Get')then 
		begin
			set @Var_Month = '';
			set @Var_Month =  month(var_Date);

			set @Var_Year = '';
			set @Var_Year =  year(Var_Date);
			
			select t107.Deduction_Id,
            -- mu04.Farmer_Id,mu04.Farmer_Name,
            date_format(t107.Deduction_Date, '%d %M %Y') as Deduction_Date,
            t107.Deduction_Type,t107.Amount,t107.Is_Check,t107.Description,
            ifnull(t107.Is_InvoiceCreated,0) as Is_locked
			from t107_mcc_farmer_deduction t107
            -- inner join mu04_farmer mu04 on
            -- mu04.Org_Id = t107.Org_Id
            -- and mu04.Farmer_Id = t107.Farmer_Id
			where t107.Org_Id = var_Org_Id
			and t107.MCC_Id = var_MCC_Id
            and t107.Farmer_Id = var_Farmer_Id
            AND month(t107.Deduction_Date ) =  @Var_Month and @Var_Year = year(t107.Deduction_Date)
            and t107.Is_Active = 1;
        end;
	elseif(var_Method_Name = 'Get_One')then 
		begin
			select t107.Deduction_Id,
            -- mu04.Farmer_Id,mu04.Farmer_Name,
            date_format(t107.Deduction_Date, '%d %M %Y') as Deduction_Date,
            t107.Deduction_Type,t107.Amount,t107.Is_Check,t107.Description,
            ifnull(t107.Is_InvoiceCreated,0) as Is_locked
			from t107_mcc_farmer_deduction t107
            -- inner join mu04_farmer mu04 on
            -- mu04.Org_Id = t107.Org_Id
            -- and mu04.Farmer_Id = t107.Farmer_Id
			where t107.Org_Id = var_Org_Id
			and t107.MCC_Id = var_MCC_Id
            and t107.Farmer_Id = var_Farmer_Id
            and t107.Deduction_Id = var_Deduction_Id
            and t107.Is_Active = 1;
        end;
	elseif (Var_Method_Name = 'GetDeductionType') then
		begin
			/*
			SELECT 'TDS SEC 194Q' as item_Id, 'TDS SEC 194Q' as item_Value
			UNION ALL
			SELECT 'Bank Advance' as item_Id, 'Bank Advance' as item_Value
			UNION ALL
			SELECT 'Management Charge' as item_Id, 'Management Charge' as item_Value
			UNION ALL
			SELECT 'Other Payment' as item_Id, 'Other Payment' as item_Value
			UNION ALL
			SELECT 'Diesel Expenses' as item_Id, 'Diesel Expenses' as item_Value
			UNION ALL
			SELECT 'Rate Diff' as item_Id, 'Rate Diff' as item_Value
			UNION ALL
			SELECT 'Contribution' as item_Id, 'Contribution' as item_Value
			UNION ALL
			SELECT 'Veterinary/Doctor' as item_Id, 'Veterinary/Doctor' as item_Value
			UNION ALL
			SELECT 'Grocery' as item_Id, 'Grocery' as item_Value
			-- UNION ALL
			-- SELECT 'Anamat' as item_Id, 'Anamat' as item_Value
			UNION ALL
			SELECT 'Advance' as item_Id, 'Advance' as item_Value
            UNION ALL
			SELECT '4Q' as item_Id, '4Q' as item_Value
            UNION ALL
			SELECT '1H' as item_Id, '1H' as item_Value
            UNION ALL
			SELECT 'TDS' as item_Id, 'TDS' as item_Value;
            
            
            */
            
            SELECT 'Bank EMI' as item_Id, 'Bank EMI' as item_Value
			UNION ALL
			SELECT 'Products Sales' as item_Id, 'Products Sales' as item_Value
            -- UNION ALL
			-- SELECT 'Trading Material' as item_Id, 'Trading Material' as item_Value
            UNION ALL
			SELECT 'Milk Transport' as item_Id, 'Milk Transport' as item_Value
            UNION ALL
			SELECT 'TDS' as item_Id, 'TDS' as item_Value;
            
			

        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
