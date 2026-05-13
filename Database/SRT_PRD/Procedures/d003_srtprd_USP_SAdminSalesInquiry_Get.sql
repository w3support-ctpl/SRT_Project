-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminSalesInquiry_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminSalesInquiry_Get`(
	var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_SalesInquiry VARCHAR(20),
    var_Date TEXT,
    var_Item_Id VARCHAR(255),
	var_Dealer_Id VARCHAR(20)
)
BEGIN
	-- get all records in the Sales Inquiry Header Table
	IF(var_Method_Name = 'Get') THEN
    
    BEGIN
    
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
        
		if(var_Dealer_Id is null or var_Dealer_Id = '') then
        
			SELECT t040.SalesInquiry AS Inquiry_No, 
				DATE_FORMAT(t040.Created_On, '%d %M %Y') AS Inquiry_Date,
				ifnull (t040.InquiryStatus_Id  , 0) AS Inquiry_Status,
				t040.CustomerReference AS Customer_Reference,
				t040.Is_Active, t040.Is_Deleted,
                mu08.Dealer_Id,
                mu08.Dealer_Name,
                mu12.SalesUser_Id,
				ifnull(mu12.SalesUser_Name,'')as SalesUser_Name,
				mu09.Retailer_Id,
				ifnull(mu09.Retailer_Name,'') as Retailer_Name
			FROM t040_salesinquiry_header t040
            inner join mu08_dealer mu08 on
            mu08.Org_Id = t040.Org_Id
            and mu08.Dealer_Id = t040.Dealer_Id
            left join mu09_retailer mu09 on
			mu09.Org_Id = t040.Org_Id
			and mu09.Retailer_Id = t040.Retailer_Id
			left join mu12_sales_user mu12 on
			mu12.Org_Id = t040.Org_Id
			and mu12.SalesUser_Id = t040.SalesUser_Id
			WHERE CAST(t040.Created_On AS DATE) >= var_StartDate
			AND CAST(t040.Created_On AS DATE) <= var_EndDate
			AND t040.Org_Id = var_Org_Id
			AND t040.Is_Deleted = 0
			ORDER BY t040.Created_On DESC;
        
        else
        
			/*
			SELECT SalesInquiry AS Inquiry_No, 
				DATE_FORMAT(Created_On, '%d %M %Y') AS Inquiry_Date,
				ifnull (InquiryStatus_Id  , 0) AS Inquiry_Status,
				CustomerReference AS Customer_Reference,
				Is_Active, Is_Deleted
			FROM t040_salesinquiry_header
			WHERE Dealer_Id = var_Dealer_Id
			AND CAST(Created_On AS DATE) >= var_StartDate
			AND CAST(Created_On AS DATE) <= var_EndDate
			AND Org_Id = var_Org_Id
			AND Is_Deleted = 0
			ORDER BY Created_On DESC;
            
            */
            
            SELECT t040.SalesInquiry AS Inquiry_No, 
				DATE_FORMAT(t040.Created_On, '%d %M %Y') AS Inquiry_Date,
				ifnull (t040.InquiryStatus_Id  , 0) AS Inquiry_Status,
				t040.CustomerReference AS Customer_Reference,
				t040.Is_Active, t040.Is_Deleted,
                mu08.Dealer_Name,
				mu12.SalesUser_Id,
				ifnull(mu12.SalesUser_Name,'')as SalesUser_Name,
				mu09.Retailer_Id,
				ifnull(mu09.Retailer_Name,'') as Retailer_Name
			FROM t040_salesinquiry_header t040
            inner join mu08_dealer mu08 on
            mu08.Org_Id = t040.Org_Id
            and mu08.Dealer_Id = t040.Dealer_Id
			left join mu09_retailer mu09 on
			mu09.Org_Id = t040.Org_Id
			and mu09.Retailer_Id = t040.Retailer_Id
			left join mu12_sales_user mu12 on
			mu12.Org_Id = t040.Org_Id
			and mu12.SalesUser_Id = t040.SalesUser_Id
			WHERE t040.Dealer_Id = var_Dealer_Id
			AND CAST(t040.Created_On AS DATE) >= var_StartDate
			AND CAST(t040.Created_On AS DATE) <= var_EndDate
			AND t040.Org_Id = var_Org_Id
			AND t040.Is_Deleted = 0
			ORDER BY t040.Created_On DESC;
        end if;
        
		
        -- to check record between given date range
		

		
    END;
    ELSEIF(var_Method_Name = 'Get_SalesUser') THEN
    BEGIN
    
    set @SalesUser_Name = (select mu12.SalesUser_Name 
	from mu08_dealer mu08 
	inner join mu12_sales_user mu12 on
	mu08.Org_Id = mu12.Org_Id
	and mu12.SalesUser_Id = mu08.SalesUser_Id
	where mu08.Org_Id = var_Org_Id and mu08.Dealer_Id = var_Dealer_Id limit 1);

	select ifnull(@SalesUser_Name,'') as sales_person;
		
    END;
    -- Get Individual Record from Sales Inquiry table with SalesInquiry = var_SalesInquiry
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
		SELECT Org_Id, SalesInquiry, 
			DestinationText AS Destination, 
            SalesNoteText AS SalesNote, 
            SalesOrganization AS SalesArea, 
            Created_On, DATE_FORMAT(Created_On, '%d %M %Y') AS Inquiry_Date,
            Is_Active, Is_Deleted,
            InquiryStatus_Id AS Inquiry_Status,
            CustomerReference AS Customer_Reference,
            SalesPerson as Sales_Person,
            SalesUser_Id as salesuser_id,
			Retailer_Id as retailer_id,
            Dealer_Id as dealer_id
		FROM t040_salesinquiry_header
        WHERE SalesInquiry = var_SalesInquiry
        AND Org_Id = var_Org_Id;
    END;
    -- Get all Item Records from Sales Inquiry Item table
    ELSEIF(var_Method_Name = 'Get_Item') THEN
    BEGIN
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
                
		SELECT inquiry.Org_Id, 
			product.Product_Id AS Item_Id, 
            product.Product_Name AS Item_Description,
			inquiry.SalesInquiry, 
            inquiry.RequestedQuantity AS Quantity, 
            inquiry.LrDetailsText AS Lr_Details, 
            inquiry.ProductionInstructionsText AS Production_Instructions,
            ifnull(inquiry.Rate,0) AS Rate,
            inquiry.UOM AS UOM,
            ifnull(Price,0) AS Price,
            inquiry.LrDetailsText as lrdetails,
           ifnull(tmp.UOM,CONCAT('[','\'', product.BaseUnit, '\'', ']')) as UOM_List
		FROM t040_salesinquiry_item  inquiry
        INNER JOIN m017_product product
        ON inquiry.Material = product.Product_Id
        AND inquiry.Org_Id = product.Org_Id
        left join temp_Report tmp on
		tmp.Org_Id = product.Org_Id 
		and tmp.Product_Code = product.Product_Code
        WHERE inquiry.SalesInquiry = var_SalesInquiry
        AND inquiry.Org_Id = var_Org_Id
        ORDER BY inquiry.Material;
    END;
    -- Get individual record from Sales Inquiry
    ELSEIF(var_Method_Name = 'Get_One_Item') THEN
    BEGIN
		/*
		SELECT Org_Id, Material AS Item_Id, 
            RequestedQuantity AS Quantity, 
            ifnull(Rate ,0)AS Rate,
            UOM AS UOM,
            ifnull(Price ,0) AS Price
		FROM t040_salesinquiry_item
        WHERE Material = var_Item_Id
        AND SalesInquiry = var_SalesInquiry
        AND Org_Id = var_Org_Id;
        */
        
        SELECT t040.Org_Id, t040.Material AS Item_Id, 
            t040.RequestedQuantity AS Quantity, 
            ifnull(t040.Rate ,0)AS Rate,
            t040.UOM AS UOM,
            ifnull(t040.Price ,0) AS Price,
            m023.ProductGroup_Id,
            t040.LrDetailsText as lrdetails
		FROM t040_salesinquiry_item t040
        inner join m017_product m017 on
        m017.Org_Id = t040.Org_Id
        and m017.Product_Id = t040.Material
        inner join m023_product_group m023 on
        m017.Org_Id = m023.Org_Id
        and m017.Product_Group = m023.Product_Group
        WHERE t040.Material = var_Item_Id
        AND t040.SalesInquiry = var_SalesInquiry
        AND t040.Org_Id = var_Org_Id;
    END;
    
	elseif(var_Method_Name = 'Get_Product') THEN
    
			select Product_Id as item_id, 
            concat(Product_Name , ' - ( ' ,BaseUnit,' )') as item_value,
            BaseUnit as item_unit 
			from m017_product
            where Is_Active = 1;
            
	elseif(var_Method_Name = 'Get_Product_V1') THEN
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
                
            
            select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_unit
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id 
			order by m017.Product_Name;
            
	elseif (var_Method_Name = 'GetProducts_V2' ) then
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
                
			if(var_Item_Id = '[Dry,Wet,Fresh]' or 
            var_Item_Id = '[Dry,Fresh,Wet]' or
            var_Item_Id = '[Wet,Dry,Fresh]' or
            var_Item_Id = '[Wet,Fresh,Dry]' or
            var_Item_Id = '[Fresh,Dry,Wet]' or
            var_Item_Id = '[Fresh,Wet,Dry]' 
            )then
            
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
            
            elseif(var_Item_Id = '[Dry, Wet, Fresh]' or 
            var_Item_Id = '[Dry, Fresh, Wet]' or
            var_Item_Id = '[Wet, Dry, Fresh]' or
            var_Item_Id = '[Wet, Fresh, Dry]' or
            var_Item_Id = '[Fresh, Dry, Wet]' or
            var_Item_Id = '[Fresh, Wet, Dry]')then
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
            
            elseif(var_Item_Id = '[Dry, Wet]' or 
            var_Item_Id = '[Wet, Dry]')then
			select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('02',03)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Dry,Wet]' or 
            var_Item_Id = '[Wet,Dry]')then
			select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('02',03)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Dry, Fresh]' or 
            var_Item_Id = '[Fresh, Dry]')then
			select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01',03)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Dry,Fresh]' or 
            var_Item_Id = '[Fresh,Dry]')then
			select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01',03)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Wet, Fresh]' or 
            var_Item_Id = '[Fresh, Wet]')then
			select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('02',01)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Wet,Fresh]' or 
            var_Item_Id = '[Fresh,Wet]')then
			select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('02',01)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Dry]')then
            
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
            
            elseif(var_Item_Id = '[Fresh]')then
            
			select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01')
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Wet]')then
            
             select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('02')
			order by m017.Product_Name;
            
           elseif(var_Item_Id = '[]')then
            
              select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[ ]')then
            
             select m017.Product_Id as item_id, m017.Product_Name as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
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
        
	elseif (var_Method_Name = 'GetProducts_V3' ) then
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
                
			if(var_Item_Id = '[Dry,Wet,Fresh]' or 
            var_Item_Id = '[Dry,Fresh,Wet]' or
            var_Item_Id = '[Wet,Dry,Fresh]' or
            var_Item_Id = '[Wet,Fresh,Dry]' or
            var_Item_Id = '[Fresh,Dry,Wet]' or
            var_Item_Id = '[Fresh,Wet,Dry]' 
            )then
            
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
            
            elseif(var_Item_Id = '[Dry, Wet, Fresh]' or 
            var_Item_Id = '[Dry, Fresh, Wet]' or
            var_Item_Id = '[Wet, Dry, Fresh]' or
            var_Item_Id = '[Wet, Fresh, Dry]' or
            var_Item_Id = '[Fresh, Dry, Wet]' or
            var_Item_Id = '[Fresh, Wet, Dry]')then
			select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01','02',03)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Dry, Wet]' or 
            var_Item_Id = '[Wet, Dry]')then
			select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('02',03)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Dry,Wet]' or 
            var_Item_Id = '[Wet,Dry]')then
			select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('02',03)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Dry, Fresh]' or 
            var_Item_Id = '[Fresh, Dry]')then
			select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01',03)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Dry,Fresh]' or 
            var_Item_Id = '[Fresh,Dry]')then
			select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01',03)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Wet, Fresh]' or 
            var_Item_Id = '[Fresh, Wet]')then
			select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('02',01)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Wet,Fresh]' or 
            var_Item_Id = '[Fresh,Wet]')then
			select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('02',01)
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Dry]')then
            
			select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('03')
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Fresh]')then
            
			select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('01')
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[Wet]')then
            
             select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
            and m017.Division_Code in('02')
			order by m017.Product_Name;
            
           elseif(var_Item_Id = '[]')then
            
              select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
			order by m017.Product_Name;
            
            elseif(var_Item_Id = '[ ]')then
            
             select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
            ifnull(tmp.UOM,CONCAT('[','\'', m017.BaseUnit, '\'', ']')) as item_uom
			from m017_product m017
            left join temp_Report tmp on
            tmp.Org_Id = m017.Org_Id 
            and tmp.Product_Code = m017.Product_Code
            where Is_Deleted = 0 and is_active = 1
            and m017.Org_Id = var_Org_Id
			order by m017.Product_Name;
		
			else
            
            select m017.Product_Id as item_id, concat(m017.Product_Name,' , Base Unit :- ',m017.BaseUnit) as item_value ,
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
    elseif(var_Method_Name = 'Get_SalesProduct') THEN
    
			select Product_Code as item_id, 
            Product_Name as item_value,
            BaseUnit as item_unit 
			from m017_product
            where Is_Active = 1;
	elseif(var_Method_Name = 'Get_SalesArea_Code') THEN
		begin
			select m013.SalesArea_Code as item_id from mu08_dealer mu08
			inner join m013_salesarea m013 on
			m013.Org_Id = mu08.Org_Id
			and m013.SalesArea_Id = mu08.SalesArea_Id
			where mu08.Org_Id = var_Org_Id
			and mu08.Dealer_Id = var_Dealer_Id;
        end;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
