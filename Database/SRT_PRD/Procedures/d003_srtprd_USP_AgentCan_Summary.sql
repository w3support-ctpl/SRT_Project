-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentCan_Summary` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentCan_Summary`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Material_Id varchar(20),
Var_MCC_Id varchar(20),
var_StartDate varchar(255),
var_EndDate varchar(20),
Var_Profile_Id varchar(20)
)
BEGIN

	If(Var_Method_Name = 'GetCanSummary') then 
		
         
		select DATE_FORMAT(f006.Date, '%e %M %Y') as Date , f006.Credit , f006.Debit , 
		f006.Balance , f006.Opening_Quantity , f006.Material_Id , 00 as Closing_Quantity , 
		00 as QtyAt_MCC, 00 as Total_Qty , 00 as QtyAT_Dairy  from 
		f006_mccstocks f006 inner join m010_material m010 on m010.Org_Id = f006.Org_Id and m010.Material_Id = f006.Material_Id
		inner join c042_materialtype c042 on c042.MaterialType_Id = m010.MaterialType_Id
		where f006.MCC_Id = Var_MCC_Id and f006.Org_Id = Var_Org_Id and c042.MaterialType_Id = Var_Material_Id
        and date(f006.Date) >= date(var_StartDate)
        and date(f006.Date) <= date(var_EndDate);
         
	elseif(Var_Method_Name = 'GetCanSAP')then
		begin
			DECLARE StartDate DATE;
			DECLARE EndDate DATE;
			SET StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_StartDate, ' - ', 1), '%m/%d/%Y');
			SET EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_StartDate, ' - ', -1), '%m/%d/%Y');
            
            
            select 
			DATE_FORMAT(f017.Date, '%d %b %Y') as Date,
			ifnull(f017.MaterialDocument,'') as MaterialDocument,
			ifnull(f017.MaterialDocumentYear,'') as MaterialDocumentYear,
			ifnull(f017.Material,'') as Material,
			ifnull(f017.QuantityInBaseUnit,'') as Quantity,
			ifnull(f017.MaterialBaseUnit,'') as UOM,
			case 
				when f017.GoodsMovementType = '541' then 'Issued to MCC' 
				when f017.GoodsMovementType = '542' then 'Return from MCC'
			else '' 
			end as Status,
            case 
				when f017.Material = '860021' then 'Aluminium Can With Lid' 
				when f017.Material = '100033' then 'Bulk Milk Cooler - 5000 LTR'
                when f017.Material = '100034' then 'Bulk Milk Cooler - 1000 LTR'
                when f017.Material = '100035' then 'Bulk Milk Cooler - 2000 LTR'
                when f017.Material = '100036' then 'Bulk Milk Cooler - 3000 LTR'
                when f017.Material = '100038' then 'Dg Set - 15 KVA'
                when f017.Material = '100039' then 'Dg Set - 30 KVA'
                when f017.Material = '100040' then 'Stabilizer 12.5 KVA'
                when f017.Material = '100041' then 'Stabilizer 15 KVA'
                when f017.Material = '100042' then 'Stabilizer 25 KVA'
			else '' 
			end as Material_Description
			FROM f017_materials_issues f017 
			inner join m005_mcc m005 on
			m005.Org_Id = f017.Org_Id
			and m005.MCC_Code = f017.Supplier
			and m005.MCC_Id = Var_MCC_Id
			and Date(f017.Date) >= StartDate 
			and Date(f017.Date)  <= EndDate
			and f017.Org_Id = Var_Org_Id;
            
		end;
    end if;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
