-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDealerStock_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDealerStock_Get`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(45),
    var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(45),
    var_DealerStock_Id VARCHAR(20),
    var_Entry_Period VARCHAR(45),
    var_Dealer_Id VARCHAR(20)
)
BEGIN

	IF(var_Method_Name = 'Get') THEN
	BEGIN
			-- divide date range in two variables to get records between those two dates
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Entry_Period, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Entry_Period, ' - ', -1), '%m/%d/%Y');
            
            SELECT ds_header.Org_Id, ds_header.DealerStock_Id, 
				dealer.Dealer_Id, dealer.Dealer_Name,  
				DATE_FORMAT(ds_header.Month_Year,'%M, %Y') AS Month_Year_Name,
                DATE_FORMAT(ds_header.Month_Year,'%Y-%m') AS Month_Year, 
                ds_header.Is_Active, ds_header.Is_Deleted, 
                ds_header.Created_On,
                DATE_FORMAT(ds_header.Created_On, '%d %M %Y') AS Entry_Date,
                IFNULL(
					CASE ds_header.Created_On
                    WHEN (
						SELECT MAX(Created_On)
                        FROM t035_dealerstock_header
                        WHERE Org_Id = var_Org_Id
                        AND Dealer_Id = dealer.Dealer_Id
                        AND Is_Deleted = 0
                        AND Is_Active = 1
                    ) THEN 0
                    ELSE 1
					END, 
				'') AS Is_Locked,
                IFNULL(
					(SELECT COUNT(ds_item.DealerStock_Id)
                    FROM t035_dealerstock_item ds_item
                    WHERE ds_item.Org_Id = var_Org_Id
                    AND DealerStock_Id = ds_header.DealerStock_Id
                    AND ds_item.Quantity <> 0),
                    '') AS No_Of_Items
			FROM t035_dealerstock_header ds_header
            LEFT JOIN mu08_dealer dealer
				ON dealer.Dealer_Id = ds_header.Dealer_Id
                AND dealer.Org_Id = ds_header.Org_Id
            WHERE ds_header.Org_Id = var_Org_Id
            AND ds_header.Is_Deleted = 0
            AND ds_header.Dealer_Id LIKE var_Dealer_Id
			AND CAST(ds_header.Created_On AS DATE) >= var_StartDate 
			AND CAST(ds_header.Created_On AS DATE) <= var_EndDate
            
            GROUP BY ds_header.Org_Id, 
				ds_header.DealerStock_Id, 
				dealer.Dealer_Id, 
                dealer.Dealer_Name,  
                Month_Year_Name, 
                Month_Year, 
                ds_header.Is_Active, 
                ds_header.Is_Deleted, 
                ds_header.Created_On
            
            ORDER BY ds_header.Created_On DESC;
            
	END;

	ELSEIF(var_Method_Name = 'GetAllProductList') THEN
	BEGIN
			
            select Product_Id, Product_Name
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
            where mu08.Dealer_Id = var_Dealer_Id and 
            m022.Org_Id = var_Org_Id 
            order by SAPSalesArea_Name)
			order by Product_Name;
            
	END;
		
		
	ELSEIF(var_Method_Name = 'Get_One') THEN
	BEGIN
			SELECT ds_item.Org_Id, ds_item.DealerStock_Id, 
				product.Product_Id, product.Product_Name,
				ds_item.Quantity
			FROM t035_dealerstock_item ds_item
			INNER JOIN m017_product product
				ON product.Product_Id = ds_item.Product_Id
				AND product.Org_Id = ds_item.Org_Id
			WHERE ds_item.Org_Id = var_Org_Id
			AND ds_item.DealerStock_Id = var_DealerStock_Id
            and ifnull(ds_item.Quantity,'') <>0
			ORDER BY product.Product_Name;
		
	END;
    ELSEIF(var_Method_Name = 'Get_Ones') THEN
	BEGIN
		select 
        DATE_FORMAT(t035.Month_Year,'%M, %Y') AS Month_Year_Name,
		DATE_FORMAT(t035.Month_Year,'%Y-%m') AS Month_Year, 
		t035.Org_Id, t035.DealerStock_Id, 
		m017.Product_Id, m017.Product_Name,
		t035i.Quantity
		FROM t035_dealerstock_header t035 
		inner join t035_dealerstock_item t035i on
		t035.Org_Id = t035i.Org_Id
		and t035.DealerStock_Id = t035i.DealerStock_Id
		and t035i.Quantity <> 0
		INNER JOIN m017_product m017 
		ON t035i.Product_Id = m017.Product_Id
		AND t035i.Org_Id = m017.Org_Id
		where t035.Org_Id = var_Org_Id
		and t035.Dealer_Id like var_Dealer_Id
		and month(t035.Month_Year) = month(var_Entry_Period)
		and year(t035.Month_Year) = year(var_Entry_Period)
        order by m017.Product_Name;
    end;
    
    
    ELSEIF(var_Method_Name = 'GetMonthAndYear') THEN
    BEGIN
		SELECT DATE_FORMAT(MAX(Month_Year), '%Y-%m') AS Month_Year
		FROM t035_dealerstock_header
		WHERE Is_Active = 1
		AND Is_Deleted = 0
		AND Org_Id = var_Org_Id;
    
    END;
    
	END IF;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
