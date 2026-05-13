-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesUser_Target` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesUser_Target`(
	var_Method_Name varchar(100),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
    var_SalesUser_Id varchar(20),
	var_Type varchar(20),
    var_StartDate varchar(50),
	var_EndDate varchar(50),
    Var_ItemId varchar(50),
    Var_Dealer_Id varchar(50)
)
BEGIN

	SET sql_mode = '';
    

	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	IF(var_Method_Name = 'GetTargetProduct')  then 
		begin
		/*
		SELECT Sum(t036.Quantity) as Quantity, m017.Product_Name as Name , m017.ProductGroup_Id as Id
		FROM t036_salesuser_targets t036
        Inner Join m023_product_group m017
        on t036.ProductGroup_Id=m017.ProductGroup_Id and m017.Org_Id = var_Org_Id
        where t036.Org_Id= var_Org_Id
        and t036.SalesUser_Id= var_SalesUser_Id and month(Month_Year) = month(var_StartDate) and year(Month_Year) = year(var_StartDate)
        Group by m017.Product_Name;
		*/
        
        DECLARE var_StartDate_1 DATE; 
		DECLARE var_EndDate_1 DATE;
		SET var_StartDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_StartDate, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_StartDate, ' - ', -1), '%m/%d/%Y');
        
        
        if(ifnull(Var_Dealer_Id,'') <> '')then
        
		SELECT 
        Sum(IFNULL(t036i.Quantity,0)) as Quantity, 
        m017.Product_Name as Name , m017.ProductGroup_Id as Id
		FROM t036_salesusers_targets_header t036
        inner Join t036_salesusers_targets_item t036i
        on t036.Target_Id=t036i.Target_Id and t036i.Org_Id = t036.Org_Id
        Inner Join m023_product_group m017
        on t036i.ProductGroup_Id=m017.ProductGroup_Id and m017.Org_Id = t036i.Org_Id 
        where t036.Org_Id= var_Org_Id
        and t036.SalesUser_Id= var_SalesUser_Id 
        and t036.Dealer_Id= Var_Dealer_Id 
        -- and month(t036.Month_Year) = month(var_StartDate) 
        -- and year(t036.Month_Year) = year(var_StartDate)
        AND month(t036.Month_Year) >= month(var_StartDate_1) 
        AND year(t036.Month_Year) >= year(var_StartDate_1) 
		AND month(t036.Month_Year) <= month(var_EndDate_1)
        AND year(t036.Month_Year) <= year(var_EndDate_1)
        Group by m017.Product_Name;
        
		else
        
        
        SELECT 
        Sum(IFNULL(t036i.Quantity,0)) as Quantity, 
        m017.Product_Name as Name , m017.ProductGroup_Id as Id
		FROM t036_salesusers_targets_header t036
        inner Join t036_salesusers_targets_item t036i
        on t036.Target_Id=t036i.Target_Id and t036i.Org_Id = t036.Org_Id
        Inner Join m023_product_group m017
        on t036i.ProductGroup_Id=m017.ProductGroup_Id and m017.Org_Id = t036i.Org_Id 
        where t036.Org_Id= var_Org_Id
        and t036.SalesUser_Id= var_SalesUser_Id 
        -- and month(t036.Month_Year) = month(var_StartDate) 
        -- and year(t036.Month_Year) = year(var_StartDate)
        AND month(t036.Month_Year) >= month(var_StartDate_1) 
        AND year(t036.Month_Year) >= year(var_StartDate_1) 
		AND month(t036.Month_Year) <= month(var_EndDate_1)
        AND year(t036.Month_Year) <= year(var_EndDate_1)
        Group by m017.Product_Name;
        
        end if;
        
        
        
    
    end;
	elseIF(var_Method_Name = 'GetTargetDealer')  then 
		begin
		/*
		SELECT Sum(t036.Quantity) as Quantity,  mu08.Dealer_Name As Name , mu08.Dealer_Id as Id
		FROM t036_salesuser_targets t036
		Inner Join mu08_dealer mu08
        on t036.Dealer_Id=mu08.Dealer_Id and mu08.Org_Id=var_Org_Id
        where t036.Org_Id= var_Org_Id
        and t036.SalesUser_Id= var_SalesUser_Id and month(Month_Year) = month(var_StartDate) and year(Month_Year) = year(var_StartDate)
        Group by  mu08.Dealer_Id;
		*/
        
		DECLARE var_StartDate_1 DATE; 
		DECLARE var_EndDate_1 DATE;
		SET var_StartDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_StartDate, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_StartDate, ' - ', -1), '%m/%d/%Y');
        
        if(ifnull(Var_Dealer_Id,'') <> '')then
        
        SELECT Sum(IFNULL(t036i.Quantity,0)) as Quantity, 
        mu08.Dealer_Name As Name , mu08.Dealer_Id as Id
		FROM t036_salesusers_targets_header t036
        inner Join t036_salesusers_targets_item t036i
        on t036.Target_Id=t036i.Target_Id and t036i.Org_Id = t036.Org_Id
		Inner Join mu08_dealer mu08
        on t036.Dealer_Id=mu08.Dealer_Id and mu08.Org_Id=t036.Org_Id
        where t036.Org_Id= var_Org_Id
        and t036.SalesUser_Id= var_SalesUser_Id 
        and t036.Dealer_Id= Var_Dealer_Id 
        -- and month(t036.Month_Year) = month(var_StartDate) 
        -- and year(t036.Month_Year) = year(var_StartDate)
        AND month(t036.Month_Year) >= month(var_StartDate_1) 
        AND year(t036.Month_Year) >= year(var_StartDate_1) 
		AND month(t036.Month_Year) <= month(var_EndDate_1)
        AND year(t036.Month_Year) <= year(var_EndDate_1)
        Group by  mu08.Dealer_Id;
        
        else
        
        SELECT Sum(IFNULL(t036i.Quantity,0)) as Quantity, 
        mu08.Dealer_Name As Name , mu08.Dealer_Id as Id
		FROM t036_salesusers_targets_header t036
        inner Join t036_salesusers_targets_item t036i
        on t036.Target_Id=t036i.Target_Id and t036i.Org_Id = t036.Org_Id
		Inner Join mu08_dealer mu08
        on t036.Dealer_Id=mu08.Dealer_Id and mu08.Org_Id=t036.Org_Id
        where t036.Org_Id= var_Org_Id
        and t036.SalesUser_Id= var_SalesUser_Id 
        -- and month(t036.Month_Year) = month(var_StartDate) 
        -- and year(t036.Month_Year) = year(var_StartDate)
        AND month(t036.Month_Year) >= month(var_StartDate_1) 
        AND year(t036.Month_Year) >= year(var_StartDate_1) 
		AND month(t036.Month_Year) <= month(var_EndDate_1)
        AND year(t036.Month_Year) <= year(var_EndDate_1)
        Group by  mu08.Dealer_Id;
        
        end if;
        
        

    end;
	elseIF(var_Method_Name = 'GetTargetProductone')  then 
    
		begin
        
        DECLARE var_StartDate_1 DATE; 
		DECLARE var_EndDate_1 DATE;
		SET var_StartDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_StartDate, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_StartDate, ' - ', -1), '%m/%d/%Y');
		/*
		SELECT Sum(t036.Quantity) as Quantity,  mu08.Dealer_Name As Name , mu08.Dealer_Id as Id
		FROM t036_salesuser_targets t036
		Inner Join mu08_dealer mu08
        on t036.Dealer_Id=mu08.Dealer_Id and mu08.Org_Id=var_Org_Id
        where t036.Org_Id= var_Org_Id
        and t036.SalesUser_Id= var_SalesUser_Id and month(Month_Year) = month(var_StartDate) and year(Month_Year) = year(var_StartDate)
        and t036.ProductGroup_Id = Var_ItemId
        Group by  mu08.Dealer_Id;

		*/
        
        /*
        SELECT Sum(t036.Quantity) as Quantity,  
		mu08.Dealer_Name As Name , 
		mu08.Dealer_Id as Id,
		m017.Product_Name As Product_Name , 
		t036.ProductUOM as UOM
		FROM t036_salesuser_targets t036
		Inner Join mu08_dealer mu08
		on t036.Dealer_Id=mu08.Dealer_Id and t036.Org_Id= mu08.Org_Id
		Inner Join m017_product m017
		on t036.Product_Id=m017.Product_Id and t036.Org_Id= m017.Org_Id
		where t036.Org_Id= var_Org_Id
		and t036.SalesUser_Id= var_SalesUser_Id and month(Month_Year) = month(var_StartDate) and year(Month_Year) = year(var_StartDate)
		and t036.ProductGroup_Id = Var_ItemId
		Group by  mu08.Dealer_Name,mu08.Dealer_Id,m017.Product_Name,t036.ProductUOM;
		*/
        
        SELECT Sum(IFNULL(t036i.Quantity,0)) as Quantity,  
		mu08.Dealer_Name As Name , 
		mu08.Dealer_Id as Id,
		m017.Product_Name As Product_Name , 
		t036i.ProductUOM as UOM,
        DATE_FORMAT(t036.Created_On, '%D %M %Y') as Created_On 
		FROM t036_salesusers_targets_header t036
		inner Join t036_salesusers_targets_item t036i
        on t036.Target_Id=t036i.Target_Id and t036i.Org_Id = t036.Org_Id
		Inner Join mu08_dealer mu08
		on t036.Dealer_Id=mu08.Dealer_Id and t036.Org_Id= mu08.Org_Id
		Inner Join m017_product m017
		on t036i.Product_Id=m017.Product_Id and t036i.Org_Id= m017.Org_Id
		where t036.Org_Id= var_Org_Id
		and t036.SalesUser_Id= var_SalesUser_Id
        -- and month(Month_Year) = month(var_StartDate) and year(Month_Year) = year(var_StartDate)
        
         AND month(t036.Month_Year) >= month(var_StartDate_1) 
        AND year(t036.Month_Year) >= year(var_StartDate_1) 
		AND month(t036.Month_Year) <= month(var_EndDate_1)
        AND year(t036.Month_Year) <= year(var_EndDate_1)
        
		and t036i.ProductGroup_Id = Var_ItemId
		Group by  mu08.Dealer_Name,mu08.Dealer_Id,m017.Product_Name,t036i.ProductUOM,t036.Created_On;
        
        end;
	elseIF(var_Method_Name = 'GetTargetDealerone')  then 
    
		begin
        
		/*
		SELECT Sum(t036.Quantity) as Quantity, m017.Product_Name as Name , m017.ProductGroup_Id as Id
		FROM t036_salesuser_targets t036
        Inner Join m023_product_group m017
        on t036.ProductGroup_Id=m017.ProductGroup_Id and m017.Org_Id = var_Org_Id
        where t036.Org_Id= var_Org_Id
        and t036.SalesUser_Id= var_SalesUser_Id and month(Month_Year) = month(var_StartDate) and year(Month_Year) = year(var_StartDate)
		and t036.Dealer_Id = Var_ItemId
        Group by m017.Product_Name;
		
        */
        
        /*
        SELECT Sum(t036.Quantity) as Quantity, 
		m023.Product_Name as Name , m023.ProductGroup_Id as Id,
		m017.Product_Name As Product_Name , 
		t036.ProductUOM as UOM
		FROM t036_salesuser_targets t036
		Inner Join m023_product_group m023
		on t036.ProductGroup_Id=m023.ProductGroup_Id and m023.Org_Id = t036.Org_Id
		Inner Join m017_product m017
		on t036.Product_Id=m017.Product_Id and t036.Org_Id= m017.Org_Id
		where t036.Org_Id= var_Org_Id
		and t036.SalesUser_Id= var_SalesUser_Id and month(Month_Year) = month(var_StartDate) and year(Month_Year) = year(var_StartDate)
		and t036.Dealer_Id = Var_ItemId
		Group by  m023.Product_Name,m023.ProductGroup_Id,m017.Product_Name,t036.ProductUOM;
		*/
        
        DECLARE var_StartDate_1 DATE; 
		DECLARE var_EndDate_1 DATE;
		SET var_StartDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_StartDate, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_StartDate, ' - ', -1), '%m/%d/%Y');
        
        SELECT Sum(IFNULL(t036i.Quantity,0)) as Quantity,
		m023.Product_Name as Name , m023.ProductGroup_Id as Id,
		m017.Product_Name As Product_Name , 
		t036i.ProductUOM as UOM,
        DATE_FORMAT(t036.Created_On, '%D %M %Y') as Created_On 
		FROM t036_salesusers_targets_header t036
        inner Join t036_salesusers_targets_item t036i
        on t036.Target_Id=t036i.Target_Id and t036i.Org_Id = t036.Org_Id
		Inner Join m023_product_group m023
		on t036i.ProductGroup_Id=m023.ProductGroup_Id and m023.Org_Id = t036i.Org_Id
		Inner Join m017_product m017
		on t036i.Product_Id=m017.Product_Id and t036i.Org_Id= m017.Org_Id
		where t036.Org_Id= var_Org_Id
		-- and t036.SalesUser_Id= var_SalesUser_Id and month(Month_Year) = month(var_StartDate) and year(Month_Year) = year(var_StartDate)
        
         AND month(t036.Month_Year) >= month(var_StartDate_1) 
        AND year(t036.Month_Year) >= year(var_StartDate_1) 
		AND month(t036.Month_Year) <= month(var_EndDate_1)
        AND year(t036.Month_Year) <= year(var_EndDate_1)
        
		and t036.Dealer_Id = Var_ItemId
		Group by  m023.Product_Name,m023.ProductGroup_Id,m017.Product_Name,t036i.ProductUOM,t036.Created_On;

		end;
end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
