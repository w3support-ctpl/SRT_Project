-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCSupplier_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCSupplier_Get`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_User_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Supplier_Id varchar(20)
)
BEGIN
	If(var_Method_Name = 'Get')then 
		begin
			select Supplier_Id,Supplier_Name,Address_Text,Mobile_No,ContactPerson_Name
			from m102_mcc_supplier
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
            and Is_Active = 1;
        end;
	elseif(var_Method_Name = 'Get_One')then 
		begin
			select Supplier_Id,Supplier_Name,Address_Text,Mobile_No,ContactPerson_Name 
			from m102_mcc_supplier
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
            and Supplier_Id = var_Supplier_Id
            and Is_Active = 1;
        end;
	elseif(var_Method_Name = 'Get_Material')then 
		begin
			
            DROP TEMPORARY TABLE IF EXISTS temp_Report;
            
			CREATE TEMPORARY TABLE temp_Report ( 
            Org_Id varchar(20),Material_Id varchar(20)
			);
            
            insert into temp_Report(
            Org_Id,Material_Id
            )
            select m102.Org_Id,m102.Material_Id
			from m102_mcc_supplier_item m102
			where m102.Org_Id = var_Org_Id
			and m102.MCC_Id = var_MCC_Id
            and m102.Supplier_Id = var_Supplier_Id;
            
            select m101.Material_Id,m101.Material_Name,m101.BaseUnit,
            CASE 
				WHEN m102.Material_Id IS NOT NULL THEN 1 
				ELSE 0 
			END AS Is_Check
			from m101_mcc_material m101
            left join temp_Report m102 on
            m101.Org_Id = m102.Org_Id
            and m101.Material_Id = m102.Material_Id
			where m101.Org_Id = var_Org_Id
			and m101.MCC_Id = var_MCC_Id;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
