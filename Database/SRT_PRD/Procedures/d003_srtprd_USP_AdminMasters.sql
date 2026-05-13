-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMasters` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMasters`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_Param1 varchar(20),
    var_Param2 varchar(20),
    var_User_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get_MCC') then
		begin
			select MCC_Id as item_id, MCC_Name as item_value  from m005_mcc 
			where Org_Id = var_Org_Id 
			and MCCType_Id = var_Param1
			and MCCWorkType_Id = var_Param2
			and Is_Active = 1;
		end;
	elseif (var_Method_Name = 'Get_Chart') then
		begin
			select 
			m001.Chart_Id as item_id,
			m001.Chart_Name as item_value
			from m001_milkrate_mcc_header m0011 
			inner join m001_milkrate_mcc_item m0012 on
			m0012.Org_Id = m0011.Org_Id 
			and m0012.Chart_Id = m0011.Chart_Id 
            and m0012.Version_No = m0011.Version_No 
			and m0012.MCC_Id = var_Param2
			inner join m001_milkrate m001 on
			m001.Org_Id = m0011.Org_Id 
			and m001.Chart_Id = m0011.Chart_Id 
			where 
            date(Applicable_Date) <= date(var_Param1)
			and 
            m0011.Org_Id = var_Org_Id
			group by m001.Chart_Id,m001.Chart_Name
            order by m001.Chart_Name;
        end;
	elseif (var_Method_Name = 'GetDealerRetailerSalesUser') then
		begin
			
            select 
			SalesUser_Id as item_id,SalesUser_Name as item_value
			from mu12_sales_user
			where Org_Id = var_Org_Id
            and Is_Active = 1
			and SalesUser_Id in (
								select 
								SalesUser_Id
								from mu09_retailer
								where Org_Id = var_Org_Id
								and Dealer_Id = var_Param1
								and Retailer_Id = var_Param2
								group by SalesUser_Id
								)
            order by SalesUser_Name asc;
            
        end;
	elseif (var_Method_Name = 'Get_Products') then
		begin
			
			DROP TEMPORARY TABLE IF EXISTS temp_Report;
			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20),Product_Code varchar(20),UOM longtext
			);

			insert into temp_Report(
			Org_Id,Product_Code,UOM
			)
			SELECT 
				Org_Id, 
				Product_Code, 
				CONCAT('[', GROUP_CONCAT('\'', UOM, '\'' ORDER BY UOM SEPARATOR ','), ']') AS UOM 
			FROM 
				m027_product_uom 
			where
				Org_Id = var_Org_Id
			GROUP BY 
				Org_Id, 
				Product_Code;
                
			if(var_Param1 = 'Dry')then
          
            
				select m017.Product_Id as item_id, m017.Product_Name as item_value ,
				ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
				from m017_product m017
				left join temp_Report tmp on
				tmp.Org_Id = m017.Org_Id 
				and tmp.Product_Code = m017.Product_Code
				where Is_Deleted = 0 and is_active = 1
				and m017.Org_Id = var_Org_Id
                and m017.Product_Group = var_Param2
				and m017.Division_Code in('03')
				order by m017.Product_Name;
                
            elseif(var_Param1 = 'Wet')then
             
				select m017.Product_Id as item_id, m017.Product_Name as item_value ,
				ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
				from m017_product m017
				left join temp_Report tmp on
				tmp.Org_Id = m017.Org_Id 
				and tmp.Product_Code = m017.Product_Code
				where Is_Deleted = 0 and is_active = 1
				and m017.Org_Id = var_Org_Id
                and m017.Product_Group = var_Param2
				and m017.Division_Code in('01','02')
				order by m017.Product_Name;
            end if;
        end;
	elseif (var_Method_Name = 'Get_Products_V1') then
		begin
			
			DROP TEMPORARY TABLE IF EXISTS temp_Report;
			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20),Product_Code varchar(20),UOM longtext
			);

			insert into temp_Report(
			Org_Id,Product_Code,UOM
			)
			SELECT 
				Org_Id, 
				Product_Code, 
				CONCAT('[', GROUP_CONCAT('\'', UOM, '\'' ORDER BY UOM SEPARATOR ','), ']') AS UOM 
			FROM 
				m027_product_uom 
			where
				Org_Id = var_Org_Id
			GROUP BY 
				Org_Id, 
				Product_Code;
                
			if(var_Param1 = 'Dry')then
          
            
				select m017.Product_Id as item_id, m017.Product_Name as item_value ,
				ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
				from m017_product m017
				left join temp_Report tmp on
				tmp.Org_Id = m017.Org_Id 
				and tmp.Product_Code = m017.Product_Code
				where Is_Deleted = 0 and is_active = 1
				and m017.Org_Id = var_Org_Id
                and m017.Product_Group = var_Param2
				and m017.Division_Code in('03')
				order by m017.Product_Name;
                
            elseif(var_Param1 = 'Wet')then
             
				select m017.Product_Id as item_id, m017.Product_Name as item_value ,
				ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
				from m017_product m017
				left join temp_Report tmp on
				tmp.Org_Id = m017.Org_Id 
				and tmp.Product_Code = m017.Product_Code
				where Is_Deleted = 0 and is_active = 1
				and m017.Org_Id = var_Org_Id
                and m017.Product_Group = var_Param2
				and m017.Division_Code in('02')
				order by m017.Product_Name;
                
			elseif(var_Param1 = 'Fresh')then
             
				select m017.Product_Id as item_id, m017.Product_Name as item_value ,
				ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
				from m017_product m017
				left join temp_Report tmp on
				tmp.Org_Id = m017.Org_Id 
				and tmp.Product_Code = m017.Product_Code
				where Is_Deleted = 0 and is_active = 1
				and m017.Org_Id = var_Org_Id
                and m017.Product_Group = var_Param2
				and m017.Division_Code in('01')
				order by m017.Product_Name;
            end if;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
