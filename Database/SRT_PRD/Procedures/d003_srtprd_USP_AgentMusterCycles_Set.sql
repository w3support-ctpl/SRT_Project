-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMusterCycles_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMusterCycles_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_User_Id varchar(20),
	var_MCC_Id varchar(20),
    var_MusterType_Id  varchar(20)
)
BEGIN
	SET SQL_SAFE_UPDATES = 0;

	If(var_Method_Name = 'Create')then 
		begin
        
			delete from m005_mcc_muster where 
			Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id;
						
			INSERT INTO m005_mcc_muster (Org_Id , MCC_Id, MusterType_Id 
			) values (
			Var_Org_Id,var_MCC_Id,var_MusterType_Id
			) ;
            
				SELECT 1 AS Result_Id, 
				'Saved' AS Result_Description, 
				'Saved' AS Result_Extra_Key;
            
        end;
	elseIf(var_Method_Name = 'Get')then 
		begin
        
			Declare MusterType_Name varchar(20);
            
			set MusterType_Name = (select c022.MusterType_Name from m005_mcc_muster m005
			inner join c022_mustertype c022 on
			c022.MusterType_Id = m005.MusterType_Id
			where m005.Org_Id = var_Org_Id
			and m005.MCC_Id = var_MCC_Id limit 1);
            
            if(ifnull(MusterType_Name,'') = '')then
				set MusterType_Name = '';
			else
				set MusterType_Name = MusterType_Name;
			end if;
            select MusterType_Name;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
