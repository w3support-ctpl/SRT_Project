-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminMaster` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminMaster`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_ParentField_Id varchar(200),
    var_User_Id varchar(20)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	
    
	if (var_Method_Name = 'GetMaterial') then
		begin
			select Material_Id as item_id, Material_Name as item_value
			from m010_material where Org_Id = var_Org_Id and Is_Active = 1
			order by Material_Name;
		end;
	elseif (var_Method_Name = 'GetSalesArea') then
		begin
			select SalesArea_Id as item_id, SalesArea_Name as item_value
			from m013_salesarea where Org_Id = var_Org_Id and Is_Active = 1
			order by SalesArea_Name;
		end;
        
	elseif (var_Method_Name = 'GetSalesAreaforSaleOrder') then
		
        begin
			select SalesArea_Code as item_id, SalesArea_Name as item_value
			from m013_salesarea where Org_Id = var_Org_Id and Is_Active = 1
			order by SalesArea_Name;
		end;
        
	elseif (var_Method_Name = 'GetSalesAreaCode') then
		begin
			select SalesArea_Code as item_id, SalesArea_Name as item_value
			from m013_salesarea where Org_Id = var_Org_Id 
            and Is_Active = 1
            and SalesArea_Code = var_ParentField_Id
			order by SalesArea_Name;
		end;
	elseif (var_Method_Name = 'GetSalesAreaName') then
		begin
                        
            select concat(m013.SalesArea_Code , ' - ',m0131.SalesOffice_Code , ' - ',m0131.SalesOrg_Code , ' - ',m0131.DistChannel_Code , ' - ',m0131.Division_Code) as item_id,
			concat(m0131.SAPSalesArea_Name , '-' , m0131.Division_Code) as item_value
			from m013_salesarea_item m0131
			inner join m013_salesarea m013 on
			m013.Org_Id = m0131.Org_Id 
			and m013.SalesOffice_Code =  m0131.SalesOffice_Code
            INNER JOIN m022_dealer_distchannel m022
            on m022.Org_Id = m0131.Org_Id and m022.SalesOrg_Code = m0131.SalesOrg_Code
            and m022.DistChannel_Code = m0131.DistChannel_Code and m022.Division_Code = m0131.Division_Code
            inner join mu08_dealer mu08 on mu08.Dealer_Id = m022.Dealer_Id and mu08.SalesArea_Id = m013.SalesArea_Id
            where mu08.Dealer_code = var_ParentField_Id and 
            m022.Org_Id = var_Org_Id 
            order by SAPSalesArea_Name;
		end;
        
        elseif (var_Method_Name = 'GetSalesAreaNameByDealer') then
		begin
            
       
            
            select concat(m013.SalesArea_Code , ' - ',m0131.SalesOffice_Code , ' - ',m0131.SalesOrg_Code , ' - ',m0131.DistChannel_Code , ' - ',m0131.Division_Code) as item_id,
			concat(m0131.SAPSalesArea_Name , '-' , m0131.Division_Code ) as item_value
			from m013_salesarea_item m0131
			inner join m013_salesarea m013 on
			m013.Org_Id = m0131.Org_Id 
			and m013.SalesOffice_Code =  m0131.SalesOffice_Code
            INNER JOIN m022_dealer_distchannel m022
            on m022.Org_Id = m0131.Org_Id and m022.SalesOrg_Code = m0131.SalesOrg_Code
            and m022.DistChannel_Code = m0131.DistChannel_Code and m022.Division_Code = m0131.Division_Code
            inner join mu08_dealer mu08 on mu08.Dealer_Id = m022.Dealer_Id and mu08.SalesArea_Id = m013.SalesArea_Id
            where mu08.Dealer_Id = var_ParentField_Id and 
            m022.Org_Id = var_Org_Id 
            order by SAPSalesArea_Name;
            
            
		end;
        
        
	elseif (var_Method_Name = 'GetFatSlab') then
		begin
			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id and Is_Active = 1 and Slab_Type = 'fat'
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'GetSNFSlab') then
		begin
			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id and Is_Active = 1 and Slab_Type = 'snf'
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'Get_FatDeduction') then
		begin
			set @FAT = (select FAT from c011_milktype
			where Is_Deleted = var_Org_Id
			and MilkType_Id = var_ParentField_Id) ;

			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id 
			and Is_Active = 1 
			and Slab_Type = 'fat'
			and Slab_Max <= @FAT
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'Get_FatIncentives') then
		begin
			set @FAT = (select FAT from c011_milktype
			where Is_Deleted = var_Org_Id
			and MilkType_Id = var_ParentField_Id) ;

			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id 
			and Is_Active = 1 
			and Slab_Type = 'fat'
			and Slab_Max > @FAT
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'Get_SNFDeduction') then
		begin
			set @SNF = (select SNF from c011_milktype
			where Is_Deleted = var_Org_Id
			and MilkType_Id = var_ParentField_Id) ;

			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id 
			and Is_Active = 1 
			and Slab_Type = 'snf'
			and Slab_Max <= @SNF
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'Get_SNFIncentives') then
		begin
			set @SNF = (select SNF from c011_milktype
			where Is_Deleted = var_Org_Id
			and MilkType_Id = var_ParentField_Id) ;

			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id 
			and Is_Active = 1 
			and Slab_Type = 'snf'
			and Slab_Max > @SNF
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'GetBank') then
		begin
			select Bank_Id as item_id, Bank_Name as item_value
			from m015_bank where Org_Id = var_Org_Id and Is_Active = 1
			order by Bank_Name;
		end;
	elseif (var_Method_Name = 'GetBranch') then
		begin
			select Branch_Id as item_id, Branch_Name as item_value
			from m016_branch where Org_Id = var_Org_Id and Bank_Id = var_ParentField_Id and Is_Active = 1
			order by Branch_Name;
		end;
	elseif (var_Method_Name = 'GetState') then
		begin
			select State_Id as item_id, State_Name as item_value
			from ml02_state where Org_Id = var_Org_Id and Is_Active = 1
			order by State_Name;
		end;
	elseif (var_Method_Name = 'GetDistrict') then
		begin
			select District_Id as item_id, District_Name as item_value
			from ml03_district where Org_Id = var_Org_Id and State_Id = var_ParentField_Id and Is_Active = 1
			order by District_Name;
		end;
	elseif (var_Method_Name = 'GetTaluka') then
		begin
			select Taluka_Id as item_id, Taluka_Name as item_value
			from ml04_taluka where Org_Id = var_Org_Id and District_Id = var_ParentField_Id and Is_Active = 1
			order by Taluka_Name;
		end;
	elseif (var_Method_Name = 'GetVillage') then
		begin
			select Village_Id as item_id, Village_Name as item_value
			from ml05_village where Org_Id = var_Org_Id and Taluka_Id = var_ParentField_Id and Is_Active = 1
			order by Village_Name;
		end;
	elseif (var_Method_Name = 'GetUserRole') then
		begin
			select Role_Id as item_id, Role_Name as item_value
			from mu01_role where Org_Id = var_Org_Id and Is_Active = 1
            and Is_Deleted = 0
			order by Role_Name;
		end;
	elseif (var_Method_Name = 'GetMCCFarmer') then
		begin
			SELECT Farmer_Id as item_id, Farmer_Name as item_value
            FROM mu04_farmer
			where MCC_Id = var_ParentField_Id
			and Org_Id = var_Org_Id
			and Is_Active = 1
			and Is_Deleted = 0
			order by Farmer_Name;
		end;
	elseif (var_Method_Name = 'GetAgent') then
		begin
			select Agent_Id as item_id, Agent_Name as item_value
			from mu05_agent where Org_Id = var_Org_Id and Is_Active = 1
			order by Agent_Name;
		end;
	elseif (var_Method_Name = 'GetDriver') then
		begin
			select Driver_Id as item_id, Driver_Name as item_value
			from mu06_driver where Org_Id = var_Org_Id and Is_Active = 1
			order by Driver_Name;
		end;
	elseif (var_Method_Name = 'GetRouteChemist') then
		begin
			select Chemist_Id as item_id, Chemist_Name as item_value
			from mu07_routechemist where Org_Id = var_Org_Id and Is_Active = 1
			order by Chemist_Name;
		end;
	elseif (var_Method_Name = 'GetComplaintType') then
		begin
			select ComplaintType_Id as item_id, ComplaintType_Name as item_value
			from c034_complainttype where Is_Active = 1
			order by ComplaintType_Name;
		end;
	elseif (var_Method_Name = 'GetComplaintStatus') then
		begin
			select ComplaintStatus_Id as item_id, ComplaintStatus_Name as item_value
			from c035_complaintstatus where Is_Active = 1
			order by ComplaintStatus_Name;
		end;
	elseif (var_Method_Name = 'GetComplaintStatusOpenResolved') then
		begin
			select ComplaintStatus_Id as item_id, ComplaintStatus_Name as item_value
			from c035_complaintstatus 
            where ComplaintStatus_Id IN ('C035002','C035003')
            and Is_Active = 1
			order by ComplaintStatus_Name;
		end;
	-- SALES :: get id & name of all sales user in mu12_sales_user table
    elseif (var_Method_Name = 'GetDealer') then
		begin
			select Dealer_Id as item_id, concat( Dealer_Code , ' - ' , Dealer_Name)as item_value
			from mu08_dealer where Org_Id = var_Org_Id and Is_Active = 1
			order by Dealer_Name;
		end;
        elseif (var_Method_Name = 'GetRetailer') then
		begin
			select Retailer_Id as item_id, Retailer_Name as item_value
			from mu09_retailer where Org_Id = var_Org_Id and Is_Active = 1
            and Is_Approved = 1
			order by Retailer_Name;
		end;
	elseif (var_Method_Name = 'GetAreaSalesManager') then
		begin
			select SalesUser_Id as item_id, SalesUser_Name as item_value
			from mu12_sales_user 
            where Is_Deleted = 0
            and SalesUserRole_Id = 'C044002'
			order by SalesUser_Name;
		end;
        elseif (var_Method_Name = 'GetSalesUser') then
		begin
			select SalesUser_Id as item_id, SalesUser_Name as item_value
			from mu12_sales_user 
            where Is_Deleted = 0
			order by SalesUser_Name;
		end;
	elseif (var_Method_Name = 'GetIFSCCode') then
		begin
			select Branch_Id as item_id, IFSC_Code as item_value
			from m016_branch 
            where Is_Deleted = 0
            AND Branch_Id = var_ParentField_Id;
		end;
	elseif (var_Method_Name = 'GetProducts') then
		begin
			select Product_Id as item_id, Product_Name as item_value
			from m017_product 
            where Is_Deleted = 0 and is_active = 1
            and Org_Id = var_Org_Id
			order by Product_Name;
		end;
	elseif (var_Method_Name = 'GetProducts_V2' ) then
		begin
			if(var_ParentField_Id = 'Dry')then
            
				select m017.Product_Group as item_id,m023.Product_Name as item_value 
				from m017_product m017
				inner join m023_product_group m023 on
				m023.Org_Id = m017.Org_Id
				and m023.Product_Group = m017.Product_Group
				where m017.Org_Id = var_Org_Id
				and m017.Division_Code in('03')
				group by m017.Product_Group, m023.Product_Name
				order by m023.Product_Name;
                
            elseif(var_ParentField_Id = 'Wet')then
				select m017.Product_Group as item_id,m023.Product_Name as item_value 
				from m017_product m017
				inner join m023_product_group m023 on
				m023.Org_Id = m017.Org_Id
				and m023.Product_Group = m017.Product_Group
				where m017.Org_Id = var_Org_Id
				and m017.Division_Code in('01','02')
				group by m017.Product_Group, m023.Product_Name
				order by m023.Product_Name;
            end if;
        end;
	elseif (var_Method_Name = 'GetProducts_V3' ) then
		begin
			if(var_ParentField_Id = 'Dry')then
            
				select m017.Product_Group as item_id,m023.Product_Name as item_value 
				from m017_product m017
				inner join m023_product_group m023 on
				m023.Org_Id = m017.Org_Id
				and m023.Product_Group = m017.Product_Group
				where m017.Org_Id = var_Org_Id
				and m017.Division_Code in('03')
				group by m017.Product_Group, m023.Product_Name
				order by m023.Product_Name;
                
            elseif(var_ParentField_Id = 'Wet')then
				select m017.Product_Group as item_id,m023.Product_Name as item_value 
				from m017_product m017
				inner join m023_product_group m023 on
				m023.Org_Id = m017.Org_Id
				and m023.Product_Group = m017.Product_Group
				where m017.Org_Id = var_Org_Id
				and m017.Division_Code in('02')
				group by m017.Product_Group, m023.Product_Name
				order by m023.Product_Name;
			elseif(var_ParentField_Id = 'Fresh')then
				select m017.Product_Group as item_id,m023.Product_Name as item_value 
				from m017_product m017
				inner join m023_product_group m023 on
				m023.Org_Id = m017.Org_Id
				and m023.Product_Group = m017.Product_Group
				where m017.Org_Id = var_Org_Id
				and m017.Division_Code in('01')
				group by m017.Product_Group, m023.Product_Name
				order by m023.Product_Name;
            end if;
        end;
	elseif (var_Method_Name = 'GetProducts_V1' ) then
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
                
			if(var_ParentField_Id = '[Dry,Wet]')then
            
            select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id  
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01','02',03)
			order by m017.Product_Name;
            
            elseif(var_ParentField_Id = '[Wet,Dry]')then
            
            select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01','02',03)
			order by m017.Product_Name;
            
            elseif(var_ParentField_Id = '[Dry, Wet]')then
            
            select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01','02',03)
			order by m017.Product_Name;
            
            elseif(var_ParentField_Id = '[Wet, Dry]')then
            
            
			select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01','02',03)
			order by m017.Product_Name;
            
            elseif(var_ParentField_Id = '[Dry]')then
            
			select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('03')
			order by m017.Product_Name;
            
            elseif(var_ParentField_Id = '[Wet]')then
            
             select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01','02')
			order by m017.Product_Name;
            
           
		
			else
            
            select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
			order by m017.Product_Name;
            
            end if;

		end;
	elseif (var_Method_Name = 'GetProductsCode') then
		begin
			select Product_Code as item_id, Product_Name as item_value
			from m017_product 
            where Is_Deleted = 0
            and Org_Id = var_Org_Id
			order by Product_Name;
		end;
        
	elseif (var_Method_Name = 'GetProductOndivision') then
		begin
			select Product_Code as item_id, Product_Name as item_value
			from m017_product 
            where Is_Deleted = 0 and is_active = 1
            and Org_Id = var_Org_Id and Division_Code = var_ParentField_Id
			order by Product_Name;
		end;
	elseif (var_Method_Name = 'GetProductOndivision_V1') then
		begin
			select Product_Code as item_id, concat(Product_Name , ' - ( ' ,BaseUnit,' )') as item_value
			from m017_product 
            where Is_Deleted = 0 and is_active = 1
            and Org_Id = var_Org_Id and Division_Code = var_ParentField_Id
			order by Product_Name;
		end;
    elseif (var_Method_Name = 'GetProductByProductGroup') then
		begin
			select m017.Product_Id as item_id, m017.Product_Name as item_value
			from m017_product m017
            inner join m023_product_group m023 on
            m023.Org_Id = m017.Org_Id
            and m023.Product_Group = m017.Product_Group
            and m023.ProductGroup_Id = var_ParentField_Id
            where m017.Is_Deleted = 0 
            and m017.is_active = 1
            and m017.Org_Id = var_Org_Id
			order by m017.Product_Name;
        end;
	elseif (var_Method_Name = 'GetProductRate') then
		begin
			select Product_Id as item_id, 
            ifnull(Rate, '') as item_value
			from m017_product 
            where Is_Deleted = 0
            AND Product_Id = var_ParentField_Id;
		end;
	elseif (var_Method_Name = 'GetProductUOM') then
		begin
			select m027.UOM as item_id, m027.UOM as item_value
			from m017_product m017
            inner join m027_product_uom m027 on
            m027.Org_Id = m017.Org_Id
            and m027.Product_Code = m017.Product_Code
            where m017.Is_Deleted = 0 
            and m017.is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Product_Id = var_ParentField_Id
			order by m027.UOM;
        end;
	elseif (var_Method_Name = 'GetProductUOMByCode') then
		begin
			
            SELECT 
				Product_Code as item_id, 
				CONCAT('[', GROUP_CONCAT('\'', UOM, '\'' ORDER BY UOM SEPARATOR ','), ']') AS item_value 
			FROM 
				m027_product_uom 
			where
				Org_Id = var_Org_Id
                and Product_Code = var_ParentField_Id
			GROUP BY 
				Product_Code;
                
			/*
			select m027.UOM as item_id, m027.UOM as item_value
			from m017_product m017
            inner join m027_product_uom m027 on
            m027.Org_Id = m017.Org_Id
            and m027.Product_Code = m017.Product_Code
            where m017.Is_Deleted = 0 
            and m017.is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Product_Code = var_ParentField_Id
			order by m027.UOM;
            */
        end;
	elseif (var_Method_Name = 'GetUOM') then
		begin
			select UOM as item_id, UOM as item_value
			from m027_product_uom 
            where Org_Id = var_Org_Id and Product_Code = var_ParentField_Id
			order by UOM;
        end;
	elseif (var_Method_Name = 'GetSalesUserRole') then
		begin
			select SalesUserRole_Id as item_id, 
            SalesUserRole_Name as item_value
			from c044_sales_user_role;
		end;
	elseif (var_Method_Name = 'GetFinancialYear') then
		begin
			select Year_Id as item_id, 
            Year_Name as item_value
			from c046_financial_year;
		end;
	elseif (var_Method_Name = 'GetUserType') then
		begin
			select User_Type as item_id,
			User_Type as item_value
			from  m020_deductions_head
			where Org_Id = var_Org_Id
            and Is_Active = 1
			group by User_Type;
		end;
	elseif (var_Method_Name = 'GetFarmer') then
		begin
			select Farmer_Id as item_id, 
            Farmer_Name as item_value
			from mu04_farmer 
            where Is_Active = 1
            and Org_Id = var_Org_Id
            order by Farmer_Name;
		end;
	elseif (var_Method_Name = 'GetRequestTypes') then
		begin
			select DeductionHead_Id as item_id,
			DeductionHead_Name as item_value
			from  m020_deductions_head
			where Org_Id = var_Org_Id
            and Is_Active = 1
			AND User_Type = var_ParentField_Id;
		end;
	elseif (var_Method_Name = 'GetIncentiveTypes') then
		begin
			select IncentiveHead_Id as item_id,
			IncentiveHead_Name as item_value
			from  m020_incentives_head
			where Org_Id = var_Org_Id
            and Is_Active = 1
			AND User_Type = var_ParentField_Id;
		end;
        
	elseif (var_Method_Name = 'GetSchemeStatus') THEN
        begin
            select '1' as item_id, 'Active' as item_value
            union all
            select '0' as item_id, 'In-Active' as item_value
            union all
            select '2' as item_id, 'Completed' as item_value;
        end;
	elseif (var_Method_Name = 'GetInquiryStatus') THEN
        begin
            select '1' as item_id, 'Successfully Closed' as item_value
            union all
            select '0' as item_id, 'Open' as item_value
            union all
            select '-1' as item_id, 'Cancelled' as item_value;
        end;
	elseif (var_Method_Name = 'GetReportTypes') then
		begin
			select '' as item_id, 'Select Report Type' as item_value

            union all
			select ReportType_Id as item_id,
			ReportType_Name as item_value
			from  c048_reporttype
			where 
            Is_Active = 1
			AND ReportGroup = var_ParentField_Id;
		end;
        
	elseif (var_Method_Name = 'GetReportTypes_v1') then
		begin
			
            set @Role_Id = (select Role_Id from mu03_user
			where  Org_Id = var_Org_Id 
			and User_Id = var_User_Id
			limit 1);

			select '' as item_id, 'Select Report Type' as item_value

			union all

			select c048.ReportType_Id as item_id,c048.ReportType_Name as item_value 
			from mu02_role_report mu02
			inner join c048_reporttype c048 on
			c048.ReportType_Id = mu02.ReportType_Id
			and c048.ReportGroup = var_ParentField_Id
			where mu02.Org_Id = var_Org_Id 
			and mu02.Flag = 1
			and mu02.Role_Id = @Role_Id;
			
		end;

    elseif (var_Method_Name = 'GetDealerBySalesGroup') then
		begin
			select Dealer_Id as item_id, Dealer_Name as item_value
			from mu08_dealer where Org_Id = var_Org_Id and Is_Active = 1 and SalesArea_Id like var_ParentField_Id
			order by Dealer_Name;
		end;    
      elseif (var_Method_Name = 'GetDealerBySalesGroup_v1') then
		begin
			select Dealer_Id as item_id, Dealer_Name as item_value
			from mu08_dealer where Org_Id = var_Org_Id and Is_Active = 1 and SalesArea_Id = var_ParentField_Id
			order by Dealer_Name;
		end;      
        
	elseif (var_Method_Name = 'GetSalesUserbydealer') then
		begin
			select mu12.SalesUser_Id as item_id, mu12.SalesUser_Name as item_value
				from mu12_sales_user mu12 where  mu12.Org_Id = var_Org_Id
				and mu12.Is_Deleted = 0 
				order by SalesUser_Name;
			/*
			set @SalesArea_Id = (select SalesArea_Id 
									from mu08_dealer
									where Org_Id = var_Org_Id
									and Dealer_Id = var_ParentField_Id limit 1);
                                    
                                    
			if(@SalesArea_Id = '' or @SalesArea_Id is null)then
				select mu12.SalesUser_Id as item_id, mu12.SalesUser_Name as item_value
				from mu12_sales_user mu12 where  mu12.Org_Id = var_Org_Id
				and mu12.Is_Deleted = 0 
				order by SalesUser_Name;
            else
				select mu12.SalesUser_Id as item_id, mu12.SalesUser_Name as item_value
				from mu08_dealer mu08 
				inner join mu12_sales_user mu12 on mu12.Org_Id = mu08.Org_Id and mu12.SalesUser_Id = mu08.SalesUser_Id 
				where mu12.Is_Deleted = 0 and 
				mu08.Dealer_Id like var_ParentField_Id
				order by SalesUser_Name;
            end if;
            */
		end;  
        
        elseif (var_Method_Name = 'GetAllDealers') then
		begin
			select Dealer_Code as item_id, Dealer_Name as item_value
			from mu08_dealer where Org_Id = var_Org_Id and Is_Active = 1
			order by Dealer_Name;
		end;
        
	elseif (var_Method_Name = 'getDealersalesgroup') then
		begin
			select mu08.Dealer_Code as item_id, mu08.Dealer_Name as item_value
			from mu08_dealer mu08 
            inner join m013_salesarea m013 on mu08.SalesArea_Id = m013.SalesArea_Id
            where mu08.Org_Id = var_Org_Id and mu08.Is_Active = 1 and m013.SalesArea_Code = var_ParentField_Id
			order by Dealer_Name;
		end;
        
	elseif (var_Method_Name = 'GetSalesAreaonDealer') then
		begin
			select m013.SalesArea_Code as item_id, m013.SalesArea_Name as item_value
			from mu08_dealer mu08 
            inner join m013_salesarea m013 on mu08.SalesArea_Id = m013.SalesArea_Id
            where mu08.Org_Id = var_Org_Id and mu08.Is_Active = 1 and mu08.Dealer_Code = var_ParentField_Id
			order by m013.SalesArea_Name;
		end;
 elseif (var_Method_Name = 'GetRetailerByDealer') then
		begin
			select Retailer_Id as item_id, Retailer_Name as item_value
			from mu09_retailer where Org_Id = var_Org_Id and Is_Active = 1 
            and Is_Approved = 1
            and Dealer_Id = var_ParentField_Id
			order by Retailer_Name;
		end;

elseif (var_Method_Name = 'GetDealersBySalesUser') then
		begin
			select Dealer_id as item_id, Dealer_Name as item_value
			from mu08_dealer where Org_Id = var_Org_Id and Is_Active = 1 and SalesUser_Id = var_ParentField_Id
			order by Dealer_Name;
		end;
        
        elseif (var_Method_Name = 'GetApprovedStatus') THEN
        begin
            select '1' as item_id, 'Approved' as item_value
            union all
            select '0' as item_id, 'Pending' as item_value
            union all
            select '-1' as item_id, 'Rejected' as item_value;
        end;
        
        	elseif (var_Method_Name = 'GetSalesAreabyDealerid') then
		begin
			select m013.SalesArea_Code as item_id, m013.SalesArea_Name as item_value
			from mu08_dealer mu08 
            inner join m013_salesarea m013 on mu08.SalesArea_Id = m013.SalesArea_Id
            where mu08.Org_Id = var_Org_Id and mu08.Is_Active = 1 and mu08.Dealer_Id = var_ParentField_Id
			order by m013.SalesArea_Name;
		end;
        
        
        
      elseif (var_Method_Name = 'GetProductsfortarget') then
		
        
        /*
        select Product_Id as item_id , Product_Name as item_value
			from m017_product 
            where Is_Deleted = 0 and is_active = 1
            and Org_Id = var_Org_Id and Division_Code in  (
            select m0131.Division_Code 
			from m013_salesarea_item m0131
			inner join m013_salesarea m013 on
			m013.Org_Id = m0131.Org_Id 
			and m013.SalesOffice_Code =  m0131.SalesOffice_Code
            INNER JOIN m022_dealer_distchannel m022
            on m022.Org_Id = m0131.Org_Id and m022.SalesOrg_Code = m0131.SalesOrg_Code
            and m022.DistChannel_Code = m0131.DistChannel_Code and m022.Division_Code = m0131.Division_Code
            inner join mu08_dealer mu08 on mu08.Dealer_Id = m022.Dealer_Id and mu08.SalesArea_Id = m013.SalesArea_Id
            where mu08.Dealer_Id = var_ParentField_Id and 
            m022.Org_Id = var_Org_Id 
            order by SAPSalesArea_Name)
			order by Product_Name;
        */
			select ProductGroup_Id as item_id , Product_Name as item_value
			from m023_product_group 
			where Is_Deleted = 0 and is_active = 1 and Org_Id = var_Org_Id ;
        
        
		elseif (var_Method_Name = 'GetRetailerBySalesUser') then
			
			select Retailer_Id as Item_Id, Retailer_Name as Item_Value
			from mu09_retailer where Org_Id = var_Org_Id 
            and Is_Approved = 1
            and Is_Active = 1 and Dealer_Id in  (select Dealer_Id
            from mu08_dealer where SalesUser_Id = var_ParentField_Id )
			order by Retailer_Name;
        
        elseif (var_Method_Name = 'GetDealerdebitmemo') then
		begin
			select mu08.Dealer_Code as item_id, mu08.Dealer_Name as item_value
			from mu08_dealer mu08 
            where mu08.Org_Id = var_Org_Id and mu08.Is_Active = 1 and  mu08.Dealer_Code = var_ParentField_Id
			order by Dealer_Name;
		end;
	elseif (var_Method_Name = 'GetPaymentTerms') then
		begin
			select Payment_Term as item_id, PaymentTermsName as item_value
			from m029_payment_terms 
            where Org_Id = var_Org_Id
			order by PaymentTermsName;
		end;
	elseif (var_Method_Name = 'GetDealerBySalesPerson_V1') then
		begin
			select Dealer_Id as item_id, Dealer_Name as item_value from mu08_dealer where 
			Org_Id = var_Org_Id
			and SalesUser_Id = var_ParentField_Id
			order by Dealer_Name asc;
		end; 
	elseif (var_Method_Name = 'GetRetailerByDealer_V1') then
		begin
			select Retailer_Id as item_id, Retailer_Name as item_value from mu09_retailer where 
			Org_Id = var_Org_Id
            and Is_Approved = 1
			and Dealer_Id = var_ParentField_Id
			order by Retailer_Name asc;
		end; 
	elseif (var_Method_Name = 'GetReportType') then
		begin
			select ReportType_Id as item_id, ReportType_Name as item_value 
            from c048_reporttype where 
			ReportGroup = 'CR'
			order by ReportType_Name asc; 
		end; 
	elseif (var_Method_Name = 'GetDealerSalesUser') then
		begin
            
			select 
			SalesUser_Id as item_id,SalesUser_Name as item_value
			from mu12_sales_user
			where Org_Id = var_Org_Id
            and Is_Active = 1
			and SalesUser_Id in (
            select SalesUser_Id from mu08_dealer
						where Org_Id = var_Org_Id
						and Dealer_Id = var_ParentField_Id group by SalesUser_Id
            )
            order by SalesUser_Name asc;
		end; 
	elseif (var_Method_Name = 'GetDealerRetailer') then
		begin
            
            select 
			Retailer_Id as item_id,Retailer_Name as item_value
			from mu09_retailer
			where Org_Id = var_Org_Id
			and Dealer_Id = var_ParentField_Id
            and Is_Approved = 1
            and Is_Active = 1
            group by Retailer_Id,Retailer_Name
			order by Retailer_Name asc;
		end; 
	elseif (var_Method_Name = 'GetType') THEN

        begin

            select 'Dealer' as item_id, 'Dealer' as item_value

            union all

            select 'Retailer' as item_id, 'Retailer' as item_value;

        end;
        
         elseif (var_Method_Name = 'GetRouteDay') THEN

        begin

            select RouteDay_Id as item_id, RouteDay_Name as item_value

          from c045_route_day;

        end;
       ELSEIF (var_Method_Name = 'GetRouteNameWSU') THEN
    BEGIN
        -- Extracting values if var_ParentField_Id is passed as 'Value1,Value2'
      

        SELECT 
        distinct
            a.Route_Id AS item_id, 
            a.Route_Name AS item_value
        FROM mu19_route a 
      

     
        -- Assuming the first part is Org_Id and second is a specific Area or Type
        WHERE 
         a.SalesArea_Id  = var_ParentField_Id
          AND a.Is_Active = 1
          AND a.Is_Deleted = 0;
    END;
	
     ELSEIF (var_Method_Name = 'GetRouteNameDrp') THEN
    BEGIN
        -- Extracting values if var_ParentField_Id is passed as 'Value1,Value2'
      

      select 
      distinct
          a.Route_Id AS item_id, 
            a.Route_Name AS item_value
      from mu19_route a
      inner join mu12_sales_user b on a.salesarea_id = b.salesarea_Id 

     
        -- Assuming the first part is Org_Id and second is a specific Area or Type
        WHERE
         b.salesUser_Id  = var_ParentField_Id
          AND a.Is_Active = 1
          AND a.Is_Deleted = 0;
    END;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
