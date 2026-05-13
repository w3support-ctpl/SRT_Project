-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminRetailerOrder_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminRetailerOrder_Get`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(255),
    var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(45),
    var_RetailerOrder_Id VARCHAR(20),
    var_RetailerOrderItem_Id VARCHAR(20),
    var_Order_Period VARCHAR(45),
    var_SalesUser_Id VARCHAR(20),
    var_SalesArea_Id VARCHAR(20),
    var_Dealer_Id  VARCHAR(20)
)
BEGIN
	-- retailer order table
	IF(var_Method_Name = 'Get') THEN
    BEGIN
		-- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', -1), '%m/%d/%Y');
		
        if(ifnull(var_Dealer_Id,'') <> '') then
        
        SELECT ro_header.Org_Id, ro_header.RetailerOrder_Id, 
			retailer.Retailer_Id, retailer.Retailer_Name, 
			dealer.Dealer_Id, dealer.Dealer_Name,
            salesuser.SalesUser_Id, salesuser.SalesUser_Name,
            ro_header.Order_No, ro_header.Remarks, ro_header.Is_Active, ro_header.Is_Deleted,
            DATE_FORMAT(ro_header.Order_Date, '%d %M %Y') AS Order_Date,
            IFNULL(
				(SELECT COUNT(Product_Id)
                FROM t034_retailerorder_item
                WHERE RetailerOrder_Id = ro_header.RetailerOrder_Id
                )
            ,'') AS No_Of_Items,
            ifnull(ro_header.Is_Closed ,0) as Is_Closed 
		FROM t034_retailerorder_header ro_header
        LEFT JOIN mu09_retailer retailer
			ON	retailer.Retailer_Id = ro_header.Retailer_Id
            AND retailer.Org_Id = ro_header.Org_Id
		LEFT JOIN mu08_dealer dealer
			ON dealer.Dealer_Id = ro_header.Dealer_Id
            AND dealer.Org_Id = ro_header.Org_Id
		LEFT JOIN mu12_sales_user salesuser
			ON	salesuser.SalesUser_Id = ro_header.SalesUser_Id
            AND salesuser.Org_Id = ro_header.Org_Id
		LEFT JOIN t034_retailerorder_item ro_item
			ON ro_item.RetailerOrder_Id = ro_header.RetailerOrder_Id
            AND ro_item.Org_Id = ro_header.Org_Id
		WHERE ro_header.Org_Id = var_Org_Id
        AND salesuser.SalesUser_Id LIKE var_SalesUser_Id
		AND CAST(ro_header.Order_Date AS DATE) >= var_StartDate 
		AND CAST(ro_header.Order_Date AS DATE) <= var_EndDate
		AND retailer.SalesArea_Id LIKE var_SalesArea_Id
		AND ro_header.Is_Deleted = 0
        and ro_header.Dealer_Id = var_Dealer_Id
        
        GROUP BY ro_header.Org_Id, ro_header.RetailerOrder_Id, 
			retailer.Retailer_Id, retailer.Retailer_Name, 
			dealer.Dealer_Id, dealer.Dealer_Name,
            salesuser.SalesUser_Id, salesuser.SalesUser_Name,
            ro_header.Order_No, ro_header.Remarks, ro_header.Is_Active, 
            ro_header.Is_Deleted,ro_header.Order_Date
        
        ORDER BY ro_header.Order_Date DESC;
        
        else
        
        SELECT ro_header.Org_Id, ro_header.RetailerOrder_Id, 
			retailer.Retailer_Id, retailer.Retailer_Name, 
			dealer.Dealer_Id, dealer.Dealer_Name,
            salesuser.SalesUser_Id, salesuser.SalesUser_Name,
            ro_header.Order_No, ro_header.Remarks, ro_header.Is_Active, ro_header.Is_Deleted,
            DATE_FORMAT(ro_header.Order_Date, '%d %M %Y') AS Order_Date,
            IFNULL(
				(SELECT COUNT(Product_Id)
                FROM t034_retailerorder_item
                WHERE RetailerOrder_Id = ro_header.RetailerOrder_Id
                )
            ,'') AS No_Of_Items,
            ifnull(ro_header.Is_Closed ,0) as Is_Closed 
		FROM t034_retailerorder_header ro_header
        LEFT JOIN mu09_retailer retailer
			ON	retailer.Retailer_Id = ro_header.Retailer_Id
            AND retailer.Org_Id = ro_header.Org_Id
		LEFT JOIN mu08_dealer dealer
			ON dealer.Dealer_Id = ro_header.Dealer_Id
            AND dealer.Org_Id = ro_header.Org_Id
		LEFT JOIN mu12_sales_user salesuser
			ON	salesuser.SalesUser_Id = ro_header.SalesUser_Id
            AND salesuser.Org_Id = ro_header.Org_Id
		LEFT JOIN t034_retailerorder_item ro_item
			ON ro_item.RetailerOrder_Id = ro_header.RetailerOrder_Id
            AND ro_item.Org_Id = ro_header.Org_Id
		WHERE ro_header.Org_Id = var_Org_Id
        AND salesuser.SalesUser_Id LIKE var_SalesUser_Id
		AND CAST(ro_header.Order_Date AS DATE) >= var_StartDate 
		AND CAST(ro_header.Order_Date AS DATE) <= var_EndDate
		AND retailer.SalesArea_Id LIKE var_SalesArea_Id
		AND ro_header.Is_Deleted = 0
        
        GROUP BY ro_header.Org_Id, ro_header.RetailerOrder_Id, 
			retailer.Retailer_Id, retailer.Retailer_Name, 
			dealer.Dealer_Id, dealer.Dealer_Name,
            salesuser.SalesUser_Id, salesuser.SalesUser_Name,
            ro_header.Order_No, ro_header.Remarks, ro_header.Is_Active, 
            ro_header.Is_Deleted,ro_header.Order_Date
        
        ORDER BY ro_header.Order_Date DESC;
        
        end if;
        
		
    END;
    elseIF(var_Method_Name = 'GetSummarySales') THEN
    BEGIN
		-- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', -1), '%m/%d/%Y');
		
        if(ifnull(var_Dealer_Id,'') <> '') then
        
			select 
			m017.Product_Name,
			t034i.UOM,
			sum(ifnull(t034i.Quantity,0)) as Quantity
			from t034_retailerorder_item t034i 
			inner join t034_retailerorder_header t034 on
			t034.Org_Id = t034i.Org_Id
			and t034.RetailerOrder_Id = t034i.RetailerOrder_Id
			and t034.SalesUser_Id = var_SalesUser_Id
            and t034.Dealer_Id = var_Dealer_Id
			AND DATE(t034.Order_Date) >= var_StartDate
			AND DATE(t034.Order_Date) <= var_EndDate
			inner join m017_product m017 on
			t034i.Org_Id = m017.Org_Id
			and t034i.Product_Id = m017.Product_Id
			where t034i.Org_Id = var_Org_Id
			group by 
			m017.Product_Name,
			t034i.UOM
			order by m017.Product_Name;
            
		else
        
        
			select 
			m017.Product_Name,
			t034i.UOM,
			sum(ifnull(t034i.Quantity,0)) as Quantity
			from t034_retailerorder_item t034i 
			inner join t034_retailerorder_header t034 on
			t034.Org_Id = t034i.Org_Id
			and t034.RetailerOrder_Id = t034i.RetailerOrder_Id
			and t034.SalesUser_Id = var_SalesUser_Id
			AND DATE(t034.Order_Date) >= var_StartDate
			AND DATE(t034.Order_Date) <= var_EndDate
			inner join m017_product m017 on
			t034i.Org_Id = m017.Org_Id
			and t034i.Product_Id = m017.Product_Id
			where t034i.Org_Id = var_Org_Id
			group by 
			m017.Product_Name,
			t034i.UOM
			order by m017.Product_Name;
		
		end if;
            
		
    END;
    elseIF(var_Method_Name = 'GetSummarySalesTotal') THEN
    BEGIN
		-- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', -1), '%m/%d/%Y');
        
        if(ifnull(var_Dealer_Id,'') <> '') then
        
        set  @Quantity = ( select 
		sum(ifnull(t034i.Quantity,0))
		from t034_retailerorder_item t034i 
		inner join t034_retailerorder_header t034 on
		t034.Org_Id = t034i.Org_Id
		and t034.RetailerOrder_Id = t034i.RetailerOrder_Id
		and t034.SalesUser_Id =var_SalesUser_Id
        and t034.Dealer_Id = var_Dealer_Id
		AND DATE(t034.Order_Date) >= date(var_StartDate) 
		AND DATE(t034.Order_Date) <= date(var_EndDate)
		where t034i.Org_Id = var_Org_Id);


		select 
		 @Quantity as no_of_items,
		t034i.UOM,
		sum(ifnull(t034i.Quantity,0)) as Quantity
		from t034_retailerorder_item t034i 
		inner join t034_retailerorder_header t034 on
		t034.Org_Id = t034i.Org_Id
		and t034.RetailerOrder_Id = t034i.RetailerOrder_Id
		and t034.SalesUser_Id =var_SalesUser_Id
        and t034.Dealer_Id = var_Dealer_Id
		AND DATE(t034.Order_Date) >= date(var_StartDate) 
		AND DATE(t034.Order_Date) <= date(var_EndDate)
		where t034i.Org_Id = var_Org_Id
		group by 
		t034i.UOM
		order by t034i.UOM;
            
		else
        
        
        set  @Quantity = ( select 
		sum(ifnull(t034i.Quantity,0))
		from t034_retailerorder_item t034i 
		inner join t034_retailerorder_header t034 on
		t034.Org_Id = t034i.Org_Id
		and t034.RetailerOrder_Id = t034i.RetailerOrder_Id
		and t034.SalesUser_Id =var_SalesUser_Id
		AND DATE(t034.Order_Date) >= date(var_StartDate) 
		AND DATE(t034.Order_Date) <= date(var_EndDate)
		where t034i.Org_Id = var_Org_Id);


		select 
		 @Quantity as no_of_items,
		t034i.UOM,
		sum(ifnull(t034i.Quantity,0)) as Quantity
		from t034_retailerorder_item t034i 
		inner join t034_retailerorder_header t034 on
		t034.Org_Id = t034i.Org_Id
		and t034.RetailerOrder_Id = t034i.RetailerOrder_Id
		and t034.SalesUser_Id =var_SalesUser_Id
		AND DATE(t034.Order_Date) >= date(var_StartDate) 
		AND DATE(t034.Order_Date) <= date(var_EndDate)
		where t034i.Org_Id = var_Org_Id
		group by 
		t034i.UOM
		order by t034i.UOM;
		
		end if;
		
		
    END;
    elseIF(var_Method_Name = 'GetSummaryDealer') THEN
    BEGIN
		-- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', -1), '%m/%d/%Y');
		
		select 
		m017.Product_Name,
		t034i.UOM,
		sum(ifnull(t034i.Quantity,0)) as Quantity
		from t034_retailerorder_item t034i 
		inner join t034_retailerorder_header t034 on
		t034.Org_Id = t034i.Org_Id
		and t034.RetailerOrder_Id = t034i.RetailerOrder_Id
		and t034.SalesUser_Id = var_SalesUser_Id
		AND t034.Dealer_Id = var_RetailerOrder_Id
		AND DATE(t034.Order_Date) >= var_StartDate
		AND DATE(t034.Order_Date) <= var_EndDate
		inner join m017_product m017 on
		t034i.Org_Id = m017.Org_Id
		and t034i.Product_Id = m017.Product_Id
		where t034i.Org_Id = var_Org_Id
		group by 
		m017.Product_Name,
		t034i.UOM
		order by m017.Product_Name;
    END;
    elseIF(var_Method_Name = 'GetSummaryDealerTotal') THEN
    BEGIN
		-- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', -1), '%m/%d/%Y');
		
		set  @Quantity = ( select 
		sum(ifnull(t034i.Quantity,0))
		from t034_retailerorder_item t034i 
		inner join t034_retailerorder_header t034 on
		t034.Org_Id = t034i.Org_Id
		and t034.RetailerOrder_Id = t034i.RetailerOrder_Id
		and t034.SalesUser_Id =var_SalesUser_Id
		AND t034.Dealer_Id = var_RetailerOrder_Id
		AND DATE(t034.Order_Date) >= date(var_StartDate) 
		AND DATE(t034.Order_Date) <= date(var_EndDate)
		where t034i.Org_Id = var_Org_Id);


		select 
		 @Quantity as no_of_items,
		t034i.UOM,
		sum(ifnull(t034i.Quantity,0)) as Quantity
		from t034_retailerorder_item t034i 
		inner join t034_retailerorder_header t034 on
		t034.Org_Id = t034i.Org_Id
		and t034.RetailerOrder_Id = t034i.RetailerOrder_Id
		and t034.SalesUser_Id =var_SalesUser_Id
		AND t034.Dealer_Id = var_RetailerOrder_Id
		AND DATE(t034.Order_Date) >= date(var_StartDate) 
		AND DATE(t034.Order_Date) <= date(var_EndDate)
		where t034i.Org_Id = var_Org_Id
		group by 
		t034i.UOM
		order by t034i.UOM;
    END;
    elseif(var_Method_Name = 'GetByDealer') THEN
    BEGIN
		-- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Order_Period, ' - ', -1), '%m/%d/%Y');
		
		SELECT ro_header.Org_Id, ro_header.RetailerOrder_Id, 
			retailer.Retailer_Id, retailer.Retailer_Name, 
			dealer.Dealer_Id, dealer.Dealer_Name,
            salesuser.SalesUser_Id, salesuser.SalesUser_Name,
            ro_header.Order_No, ro_header.Remarks, ro_header.Is_Active, ro_header.Is_Deleted,
            DATE_FORMAT(ro_header.Order_Date, '%d %M %Y') AS Order_Date,
            IFNULL(
				(SELECT COUNT(Product_Id)
                FROM t034_retailerorder_item
                WHERE RetailerOrder_Id = ro_header.RetailerOrder_Id
                )
            ,'') AS No_Of_Items
		FROM t034_retailerorder_header ro_header
        LEFT JOIN mu09_retailer retailer
			ON	retailer.Retailer_Id = ro_header.Retailer_Id
            AND retailer.Org_Id = ro_header.Org_Id
		inner JOIN mu08_dealer dealer
			ON dealer.Dealer_Id = ro_header.Dealer_Id
            AND dealer.Org_Id = ro_header.Org_Id
            AND dealer.Dealer_Id = var_RetailerOrder_Id
		LEFT JOIN mu12_sales_user salesuser
			ON	salesuser.SalesUser_Id = ro_header.SalesUser_Id
            AND salesuser.Org_Id = ro_header.Org_Id
		LEFT JOIN t034_retailerorder_item ro_item
			ON ro_item.RetailerOrder_Id = ro_header.RetailerOrder_Id
            AND ro_item.Org_Id = ro_header.Org_Id
		WHERE ro_header.Org_Id = var_Org_Id
        AND salesuser.SalesUser_Id LIKE var_SalesUser_Id
		AND CAST(ro_header.Order_Date AS DATE) >= var_StartDate 
		AND CAST(ro_header.Order_Date AS DATE) <= var_EndDate
		AND retailer.SalesArea_Id LIKE var_SalesArea_Id
		AND ro_header.Is_Deleted = 0
        GROUP BY ro_header.Org_Id, ro_header.RetailerOrder_Id, 
			retailer.Retailer_Id, retailer.Retailer_Name, 
			dealer.Dealer_Id, dealer.Dealer_Name,
            salesuser.SalesUser_Id, salesuser.SalesUser_Name,
            ro_header.Order_No, ro_header.Remarks, ro_header.Is_Active, 
            ro_header.Is_Deleted,ro_header.Order_Date
        
        ORDER BY ro_header.Order_Date DESC;
    end;
    
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
		SELECT Org_Id, RetailerOrder_Id, Retailer_Id, 
			Dealer_Id, SalesUser_Id, Order_No,
            DATE_FORMAT(Order_Date, '%Y-%m-%d') AS Order_Date,
            Remarks, Is_Active, Is_Deleted,ifnull(Is_Closed ,0) as Is_Closed 
		FROM t034_retailerorder_header
        WHERE RetailerOrder_Id = var_RetailerOrder_Id
        AND Org_Id = var_Org_Id;
    END;
    
    -- retailer order item table
    ELSEIF(var_Method_Name = 'Get_Item') THEN
    BEGIN
		
        
		SELECT ro_item.Org_Id, ro_item.RetailerOrder_Id, ro_item.RetailerOrderItem_Id, 
			product.Product_Id, product.Product_Name,ifnull( ro_item.UOM,'') as UOM,
			ro_item.Quantity, ro_item.Is_Active, ro_item.Is_Deleted,t034.Is_Closed
        FROM t034_retailerorder_item ro_item
        LEFT JOIN m017_product product
			ON product.Product_Id = ro_item.Product_Id
            AND product.Org_Id = ro_item.Org_Id
		inner join t034_retailerorder_header t034 on
        t034.Org_Id = ro_item.Org_Id
        and t034.RetailerOrder_Id = ro_item.RetailerOrder_Id
		WHERE ro_item.RetailerOrder_Id = var_RetailerOrder_Id
        AND ro_item.Org_Id = var_Org_Id
        ORDER BY product.Product_Name;
    END;
    
    
    -- retailer order item single record
    ELSEIF(var_Method_Name = 'Get_One_Item') THEN
    BEGIN
		

		SELECT ro_item.Org_Id, ro_item.RetailerOrder_Id, ro_item.RetailerOrderItem_Id, 
			product.Product_Id, product.Rate,ifnull( ro_item.UOM,'') as UOM,
            ro_item.Quantity, ro_item.Is_Active, ro_item.Is_Deleted 
		FROM t034_retailerorder_item ro_item
        LEFT JOIN m017_product product
			ON product.Product_Id = ro_item.Product_Id
            AND product.Org_Id = ro_item.Org_Id
		WHERE ro_item.Org_Id = var_Org_Id and 
        product.Org_Id = var_Org_Id
        AND RetailerOrder_Id = var_RetailerOrder_Id
        AND RetailerOrderItem_Id = var_RetailerOrderItem_Id;
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
