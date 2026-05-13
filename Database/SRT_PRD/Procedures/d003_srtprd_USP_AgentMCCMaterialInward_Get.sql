-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCMaterialInward_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCMaterialInward_Get`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_User_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Supplier_Id varchar(20),
    var_Inward_Id varchar(20),
    var_Date VARCHAR(45)
)
BEGIN
	If(var_Method_Name = 'Get')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
			
			select t101.Inward_Id,m102.Supplier_Id,m102.Supplier_Name,
            date_format(t101.Inward_Date, '%d %M %Y') as Inward_Date,
            t101.Total_Amount
			from t101_mcc_material_inward t101
            inner join m102_mcc_supplier m102 on
            m102.Org_Id = t101.Org_Id
            and m102.Supplier_Id = t101.Supplier_Id
			where t101.Org_Id = var_Org_Id
			and t101.MCC_Id = var_MCC_Id
            AND CAST(t101.Inward_Date AS DATE) >= var_StartDate 
			AND CAST(t101.Inward_Date AS DATE) <= var_EndDate
            and t101.Is_Active = 1;
        end;
	elseif(var_Method_Name = 'Get_One')then 
		begin
			select t101.Inward_Id,m102.Supplier_Id,m102.Supplier_Name,
            date_format(t101.Inward_Date, '%d %M %Y') as Inward_Date,
            t101.Total_Amount
			from t101_mcc_material_inward t101
            inner join m102_mcc_supplier m102 on
            m102.Org_Id = t101.Org_Id
            and m102.Supplier_Id = t101.Supplier_Id
			where t101.Org_Id = var_Org_Id
			and t101.MCC_Id = var_MCC_Id
            and t101.Inward_Id = var_Inward_Id
            and t101.Is_Active = 1;
        end;
	elseif(var_Method_Name = 'Get_Material')then 
		begin
			
            select m101.Material_Name,t101.Purchase_Unit,
            -- concat('',t101.Purchase_Amount,'')  as Purchase_Amount,
            concat('',ifnull(t101.Purchase_Amount,0),'')  as Purchase_Amount,
            t101.Material_Id as Item_Id,
            concat('',ifnull(t101.Selling_Amount,0),'')  as Selling_Amount,
            concat('',ifnull(t101.Quantity,1),'')  as Quantity
            from t101_mcc_material_inward_item t101 
            inner join m101_mcc_material m101 on
             m101.Org_Id = t101.Org_Id
            and m101.Material_Id = t101.Material_Id
            where t101.Org_Id = var_Org_Id
			and t101.Inward_Id = var_Inward_Id;
            
        end;
	elseif(var_Method_Name = 'Get_Supplier')then 
		begin
			select Supplier_Id as Item_Id, Supplier_Name as Item_Value 
			from m102_mcc_supplier
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id;
        end;
	elseif(var_Method_Name = 'Get_SupplierMaterial')then 
		begin
			select m101.Material_Id as Item_Id, m101.Material_Name as Item_Value  ,m101.BaseUnit as Item_Unit 
			from m102_mcc_supplier_item m102
			inner join m101_mcc_material m101 on
			m102.Org_Id = m101.Org_Id
			and m102.Material_Id = m101.Material_Id
			where m102.Org_Id = var_Org_Id
            and m102.MCC_Id = var_MCC_Id
			and m102.Supplier_Id = var_Supplier_Id;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
