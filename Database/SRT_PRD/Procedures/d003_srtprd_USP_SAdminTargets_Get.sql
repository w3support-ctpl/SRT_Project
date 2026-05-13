-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminTargets_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminTargets_Get`(
	var_Org_Id VARCHAR(10),
    var_Method_Name VARCHAR(20),
    var_User_Id VARCHAR(20),
    var_Entry_Id VARCHAR(20),
    var_SalesUser_Id VARCHAR(20),
    var_FinancialYear_Id VARCHAR(20)
)
BEGIN
	IF(var_Method_Name = 'Get') THEN
    BEGIN
		/*
		SELECT targets.Org_Id, targets.Entry_Id, 
			targets.SalesUser_Id,
            DATE_FORMAT(targets.Month_Year,'%M, %Y') AS Month_Year_Name,
			DATE_FORMAT(targets.Month_Year,'%Y-%m') AS Month_Year, 
			dealer.Dealer_Id, dealer.Dealer_Name, 
            product.Product_Group as Product_Id, product.Product_Name,
            targets.Quantity, 
            targets.Is_Active, targets.Is_Deleted
		FROM t036_salesuser_targets targets
        inner JOIN mu08_dealer dealer
			ON dealer.Dealer_Id = targets.Dealer_Id
            AND dealer.Org_Id = targets.Org_Id
		inner JOIN m023_product_group product
			ON product.ProductGroup_Id = targets.Product_Id
            AND product.Org_Id = targets.Org_Id
		WHERE targets.Org_Id = var_Org_Id
        AND targets.SalesUser_Id = var_SalesUser_Id
        -- AND targets.FinancialYear_Id = var_FinancialYear_Id
        ORDER BY Entry_Id DESC;
        */
        
        select 
        t036.Org_Id,t036.Entry_Id,
        t036.SalesUser_Id,
        DATE_FORMAT(t036.Month_Year,'%M, %Y') AS Month_Year_Name,
		DATE_FORMAT(t036.Month_Year,'%Y-%m') AS Month_Year,
        mu08.Dealer_Id, mu08.Dealer_Name, 
		m023.Product_Group as ProductGroup_Id, m023.Product_Name as ProductGroup_Name,
        m017.Product_Name as Product_Name,
		t036.ProductUOM, t036.Quantity, 
		t036.Is_Active, t036.Is_Deleted
        from t036_salesuser_targets t036
        inner JOIN mu08_dealer mu08
		ON mu08.Dealer_Id = t036.Dealer_Id
		AND mu08.Org_Id = t036.Org_Id
        inner JOIN m023_product_group m023
		ON m023.ProductGroup_Id = t036.ProductGroup_Id
		AND m023.Org_Id = t036.Org_Id
        inner JOIN m017_product m017
		ON t036.Product_Id = m017.Product_Id
		AND t036.Org_Id = m017.Org_Id
        WHERE t036.Org_Id = var_Org_Id
        AND t036.SalesUser_Id = var_SalesUser_Id
        ORDER BY Entry_Id DESC;
    END;
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
		/*
		SELECT Org_Id, Entry_Id, SalesUser_Id, 
			DATE_FORMAT(Month_Year,'%Y-%m') AS Month_Year,
            Dealer_Id, Product_Id, Quantity, 
            Is_Active, Is_Deleted
		FROM t036_salesuser_targets
        WHERE Org_Id = var_Org_Id
        AND Entry_Id = var_Entry_Id;
        -- AND SalesUser_Id = var_SalesUser_Id
        -- AND FinancialYear_Id = var_FinancialYear_Id;
        
        */
        
        
        SELECT Org_Id, Entry_Id, SalesUser_Id, 
			DATE_FORMAT(Month_Year,'%Y-%m') AS Month_Year,
            Dealer_Id,ProductGroup_Id, Product_Id,ProductUOM, Quantity, 
            Is_Active, Is_Deleted
		FROM t036_salesuser_targets
        WHERE Org_Id = var_Org_Id
        AND Entry_Id = var_Entry_Id;
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
