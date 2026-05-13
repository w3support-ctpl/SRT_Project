-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesCommon_Master` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesCommon_Master`(
    var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_ParentField_Id varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	if (var_Method_Name = 'GetState') then
    
		select State_Id as Item_Id, State_Name as Item_Value
		from ml02_state where Org_Id = var_Org_Id order by State_Name asc ;
	
    elseif(var_Method_Name = 'GetDistrict') then
    
    	select District_Id as Item_Id, District_Name as Item_Value
		from ml03_district where Org_Id = var_Org_Id  and State_Id = var_ParentField_Id order by District_Name asc ;

    elseif(var_Method_Name = 'GetTaluka') then
    
    	select Taluka_Id as Item_Id, Taluka_Name as Item_Value
		from ml04_taluka where Org_Id = var_Org_Id  and District_Id = var_ParentField_Id and is_active = 1 order by Taluka_Name asc ;

    elseif(var_Method_Name = 'GetVillage') then
    
    	select Village_Id as Item_Id, Village_Name as Item_Value
		from ml05_village where Org_Id = var_Org_Id  and Taluka_Id = var_ParentField_Id and is_active = 1 order by Village_Name asc ;   
	
    elseif(var_Method_Name = 'Getsalesmans') then
        
		select SalesUser_Id as Item_Id, SalesUser_Name as Item_Value
		from mu12_sales_user where Org_Id = var_Org_Id  and SalesUser_Id = var_ParentField_Id and is_active = 1    
        union all 
    	select SalesUser_Id as Item_Id, SalesUser_Name as Item_Value
		from mu12_sales_user where Org_Id = var_Org_Id  and ReportingTo_Id = var_ParentField_Id and is_active = 1 ;   
        
elseif(var_Method_Name = 'Getsalesmans_1') then
        
		select mu12.SalesUser_Id as Item_Id, mu12.SalesUser_Name as Item_Value 
		from mu08_dealer mu08 
		inner join mu12_sales_user mu12 on
		mu12.Org_Id = mu08.Org_Id
		and mu12.SalesUser_Id = mu08.SalesUser_Id
		where mu08.Org_Id = var_Org_Id
        and mu08.Is_Active = 1
		and mu08.Dealer_Id = var_ParentField_Id
        group by mu12.SalesUser_Id,mu12.SalesUser_Name;
        
elseif(var_Method_Name = 'GetMaterial') then
        
		select  
		m010.Material_Group as Item_Id, m010.Material_Group as Item_Value 
		from m010_material m010
        where ifnull(MaterialType_Id,'') <>''
		group by m010.Material_Group;
elseif(var_Method_Name = 'GetDealer') then
    
    	select Dealer_Id as Item_Id, Dealer_Name as Item_Value
		from mu08_dealer where Org_Id = var_Org_Id 
        and Is_Active = 1;
        
	elseif(var_Method_Name = 'GetSalesUserRoute') then
    
        
        select Route_Id as Item_Id,Route_Name   as Item_Value
		from m019_salesuserroute_header
		where Org_Id =var_Org_Id
		and SalesUser_Id =var_ParentField_Id
        group by Route_Id,Route_Name;
        
	elseif(var_Method_Name = 'GetSalesUserDealer') then
    
        
        select Dealer_Id as Item_Id,Dealer_Name as Item_Value
			from mu08_dealer
			where Org_Id =var_Org_Id
            and Is_Active = 1
			and SalesUser_Id =var_ParentField_Id;
        
elseif(var_Method_Name = 'GetDealerwithSales') then
    
    	select Dealer_Id as Item_Id, Dealer_Name as Item_Value
		from mu08_dealer where Org_Id = var_Org_Id 
        and Is_Active = 1
        and SalesUser_Id = var_ParentField_Id; 
        
elseif(var_Method_Name = 'Getsalesarea') then
    
    	select SalesArea_Id as Item_Id, SalesArea_Name as Item_Value
		from m013_salesarea where Org_Id = var_Org_Id  ; 
        
		elseif (var_Method_Name = 'GetComplaintType') then
    
		select ComplaintType_Id as Item_Id, ComplaintType_Name as Item_Value
		from c034_complainttype where Is_Deleted = 0 order by ComplaintType_Name asc ;
	
    elseif (var_Method_Name = 'GetNotificationCodeGroup') then
    
		select NotificationCodeGroup_Id as item_id, NotificationCodeGroup_Name as item_value
		from c050_notificationcodegroup  where Org_Id = var_Org_Id order by NotificationCodeGroup_Name asc ;
        
	elseif (var_Method_Name = 'GetNotificationCode') then
    
		select NotificationCode_Id as item_id, NotificationCode_Name as item_value
		from c051_notificationcode  where Org_Id = var_Org_Id order by NotificationCode_Name asc ;
        
	elseif (var_Method_Name = 'GetNotificationPriority') then
    
		select NotificationPriority_Id as item_id, NotificationPriority_Name as item_value
		from c052_notificationpriority  where Org_Id = var_Org_Id order by NotificationPriority_Name asc ;
    
	elseif (var_Method_Name = 'GetProductOndivision') then
		begin
			select Product_Code as item_id, Product_Name as item_value , '' as item_Image
			from m017_product 
            where Is_Deleted = 0 and is_active = 1
            and Org_Id = var_Org_Id and Division_Code = var_ParentField_Id
			order by Product_Name;
		end;
	elseif (var_Method_Name = 'GetProduct') then
		begin
			select Product_Id as item_id, Product_Name as item_value , '' as item_Image
			from m017_product 
            where Is_Deleted = 0 and is_active = 1
            and Org_Id = var_Org_Id 
			order by Product_Name;
		end;
        elseif (var_Method_Name = 'GetProductOndivision_V1') then
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
                
			select m017.Product_Code as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id and Division_Code = var_ParentField_Id
			order by m017.Product_Name;
                
		end;
        elseif (var_Method_Name = 'GetDealersBySalesUser') then
		begin
			select Dealer_id as Item_Id, Dealer_Name as Item_Value
			from mu08_dealer where Org_Id = var_Org_Id and Is_Active = 1 and SalesUser_Id = var_ParentField_Id
			order by Dealer_Name;
		end;
        
        	elseif (var_Method_Name = 'GetRetailerBySalesUser') then
			
			select 
            Retailer_Id as Item_Id, 
            Retailer_Name as Item_Value
			from mu09_retailer where Org_Id = var_Org_Id and Is_Active = 1 and Dealer_Id in  (select Dealer_Id
            from mu08_dealer where SalesUser_Id = var_ParentField_Id and Is_Active = 1)
			group by Retailer_Id, Retailer_Name
            order by Retailer_Name ;
            
		elseif (var_Method_Name = 'GetQualityNotification') then
			
            SELECT ifnull(QualityNotification,'')  as QualityNotification  FROM t037_sales_complaint_header
			where Org_Id = var_Org_Id 
			and Complaint_Id = var_ParentField_Id 
			limit 1;

        end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
