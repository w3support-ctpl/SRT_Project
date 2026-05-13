-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMissingFarmer_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMissingFarmer_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Date varchar(60),
    var_FarmerCollection_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then  
			begin
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;

				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
                
                select 
				t005.Org_Id,
                t005.FarmerCollection_Id,
				date_format(t005.Created_On, '%d %M %Y') as Collection_Date,
				t005.Quantity_Ltr as Liters,
				t005.Quantity_Kg as Weight,
				t005.Fat,
				t005.SNF,
				mu04.Farmer_Code,
				mu04.Farmer_Id,
				mu04.Farmer_Name,
				c011.MilkType_Id,
				c011.MilkType_Name,
				c016.MilkStatus_Id,
				c016.MilkStatus_Name,
                t005.Is_InvoiceCreated as Is_Posted
				from t005_milkcollectionfarmer t005
				inner join mu04_farmer mu04 on
				mu04.Org_Id = t005.Org_Id 
				and mu04.Farmer_Id = t005.Farmer_Id 
				inner join c011_milktype c011 on
				c011.MilkType_Id = t005.MilkType_Id 
				inner join c016_milkstatus c016 on
				c016.MilkStatus_Id = t005.MilkStatus_Id 
				where t005.Org_Id = var_Org_Id 
				and CAST(t005.Created_On  AS DATE) >= var_StartDate 
				and CAST(t005.Created_On  AS DATE)  <= var_EndDate
				and t005.Is_Missing = 1
				order by t005.FarmerCollection_Id;
			end;
		elseif (var_Method_Name = 'Get_One') then  
			begin
				select 
				Org_Id, 
				FarmerCollection_Id,
				Farmer_Id,
				MilkType_Id,
				MilkStatus_Id,
				Quantity_Ltr as Liters,
				Quantity_Kg as Weight,
				Fat,
				SNF,
				date_format(Created_On, '%Y-%m-%d') as Collection_Date
				from t005_milkcollectionfarmer 
				where Org_Id = var_Org_Id
				and FarmerCollection_Id = var_FarmerCollection_Id;
            end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
