-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCCommissionItem_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCCommissionItem_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_MPPI_Id varchar(20),
    var_Entry_Id varchar(20)
    
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			DECLARE Today_Date DATETIME;
            
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT m002.Org_Id, Entry_Id, MPPI_Id, 
            MinimumQuantity,ifnull(MaximumQuantity,'') as MaximumQuantity, BaseRate, BaseFat, BaseSNF,
            -- MinimumFat,MinimumSNF,
            -- ifnull(MaximumFat,'') as MaximumFat,
            -- ifnull(MaximumSNF,'') as MaximumSNF,
            ifnull(MinimumFat,'-') as MinimumFat,
            ifnull(MinimumSNF,'-') as MinimumSNF,
            ifnull(MaximumFat,'-') as MaximumFat,
            ifnull(MaximumSNF,'-') as MaximumSNF,
            FAT_Incentive , FAT_Deduction , SNF_Incentive,SNF_Deduction
            ,ServiceCharge,Version_No,
            DATE_FORMAT(Applicable_Date, '%d %b %Y %h:%i %p') AS Applicable_Date,
            m002.Is_Active,m002.Is_Deleted,
            ifnull(MinimumProtein,'-') as MinimumProtein,
            ifnull(MaximumProtein,'-') as MaximumProtein,
            ifnull(MinimumAsh,'-') as MinimumAsh,
            ifnull(MaximumAsh,'-') as MaximumAsh,
                   CASE 
                       WHEN Today_Date >= m002.Applicable_Date AND Today_Date <= DATE_ADD(m002.Applicable_Date, INTERVAL 1 DAY) THEN 1
                       WHEN Today_Date > DATE_ADD(m002.Applicable_Date, INTERVAL 1 DAY) THEN 1
                       ELSE 0
                   END AS Is_Locked
			FROM m002_commission_item m002
            WHERE m002.Org_Id = var_Org_Id  
              and MPPI_Id = var_MPPI_Id
            AND m002.Is_Deleted = 0
            ORDER BY DATE(m002.Applicable_Date) DESC, TIME(m002.Applicable_Date) DESC;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id, Entry_Id, MPPI_Id, 
            -- MinimumQuantity,
            ifnull(MinimumQuantity,'') as MinimumQuantity, 
            ifnull(MaximumQuantity,'') as MaximumQuantity, 
            BaseRate, BaseFat, BaseSNF,
            ifnull(MinimumFat,'-') as MinimumFat,
            ifnull(MinimumSNF,'-') as MinimumSNF,
            ifnull(MaximumFat,'-') as MaximumFat,
            ifnull(MaximumSNF,'-') as MaximumSNF,
            -- MinimumFat,
            -- MinimumSNF,
            FAT_Incentive , FAT_Deduction , 
            SNF_Incentive,SNF_Deduction,ServiceCharge,Version_No, 
            
            DATE_FORMAT(Applicable_Date, '%Y-%m-%dT%H:%i') AS Applicable_Date,
            Is_Active, Is_Deleted,
            ifnull(MinimumProtein,'-') as MinimumProtein,
            ifnull(MaximumProtein,'-') as MaximumProtein,
            ifnull(MinimumAsh,'-') as MinimumAsh,
            ifnull(MaximumAsh,'-') as MaximumAsh
            from m002_commission_item 
            where Org_Id = var_Org_Id 
            and Entry_Id = var_Entry_Id;
		end;
	elseif (var_Method_Name = 'Get_Date') then
		begin
			SELECT DATE_FORMAT(MAX(Applicable_Date), '%Y-%m-%dT%H:%i') AS Applicable_Date
			FROM m002_commission_item
			WHERE Org_Id = var_Org_Id
			AND MPPI_Id = var_MPPI_Id
			AND Is_Deleted = 0;
			-- ORDER BY Version_No DESC
			-- LIMIT 1;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
