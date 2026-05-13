-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminTarget_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminTarget_Get`(
	var_Org_Id VARCHAR(10),
    var_Method_Name VARCHAR(255),
    var_User_Id VARCHAR(20),
    var_Target_Id VARCHAR(20),
    var_Entry_Id VARCHAR(20),
    var_SalesUser_Id VARCHAR(20),
    var_FinancialYear_Id VARCHAR(20)
)
BEGIN
	IF(var_Method_Name = 'Get') THEN
		BEGIN
			
			select 
			t036.Org_Id,t036.Target_Id,
			t036.SalesUser_Id,
			DATE_FORMAT(t036.Month_Year,'%M, %Y') AS Month_Year_Name,
			DATE_FORMAT(t036.Month_Year,'%Y-%m') AS Month_Year,
			mu08.Dealer_Id, mu08.Dealer_Name, 
			sum(ifnull(Quantity,0)) as Quantity, 
			t036.Is_Active, 
			t036.Is_Deleted
			from t036_salesusers_targets_header t036
			left JOIN t036_salesusers_targets_item t0361
			ON t0361.Target_Id = t036.Target_Id
			AND t0361.Org_Id = t036.Org_Id
			inner JOIN mu08_dealer mu08
			ON mu08.Dealer_Id = t036.Dealer_Id
			AND mu08.Org_Id = t036.Org_Id
			WHERE t036.Org_Id = var_Org_Id
			AND t036.SalesUser_Id = var_SalesUser_Id
            and t036.Is_Active =  1
			group by 
			t036.Org_Id,t036.Target_Id,
			t036.SalesUser_Id,
			DATE_FORMAT(t036.Month_Year,'%M, %Y'),
			DATE_FORMAT(t036.Month_Year,'%Y-%m'),
			mu08.Dealer_Id, mu08.Dealer_Name
			ORDER BY t036.Target_Id DESC;
			
		END;
    ELSEIF(var_Method_Name = 'Get_One') THEN
		BEGIN
			
            select 
			t036.Org_Id,t036.Target_Id,
			t036.SalesUser_Id,
			DATE_FORMAT(t036.Month_Year,'%M, %Y') AS Month_Year_Name,
			DATE_FORMAT(t036.Month_Year,'%Y-%m') AS Month_Year,
			mu08.Dealer_Id, mu08.Dealer_Name, 
			sum(ifnull(Quantity,0)) as Quantity,
			t036.Is_Active, 
			t036.Is_Deleted
			from t036_salesusers_targets_header t036
			left JOIN t036_salesusers_targets_item t0361
			ON t0361.Target_Id = t036.Target_Id
			AND t0361.Org_Id = t036.Org_Id
			inner JOIN mu08_dealer mu08
			ON mu08.Dealer_Id = t036.Dealer_Id
			AND mu08.Org_Id = t036.Org_Id
			WHERE t036.Org_Id = var_Org_Id
			AND t036.Target_Id = var_Target_Id
			group by 
			t036.Org_Id,t036.Target_Id,
			t036.SalesUser_Id,
			DATE_FORMAT(t036.Month_Year,'%M, %Y'),
			DATE_FORMAT(t036.Month_Year,'%Y-%m'),
			mu08.Dealer_Id, mu08.Dealer_Name;
			
		END;
	ELSEIF(var_Method_Name = 'Get_Item') THEN
		BEGIN
			
            select 
			t036.Org_Id,t036.Entry_Id,t036.Target_Id,
			m023.Product_Group as ProductGroup_Id, m023.Product_Name as ProductGroup_Name,
			m017.Product_Id as Product_Id, m017.Product_Name as Product_Name,
			t036.ProductUOM, t036.Quantity
			from t036_salesusers_targets_item t036
			inner JOIN m023_product_group m023
			ON m023.ProductGroup_Id = t036.ProductGroup_Id
			AND m023.Org_Id = t036.Org_Id
			inner JOIN m017_product m017
			ON t036.Product_Id = m017.Product_Id
			AND t036.Org_Id = m017.Org_Id
			WHERE t036.Org_Id = var_Org_Id
			AND t036.Target_Id = var_Target_Id
			ORDER BY Entry_Id DESC;
			
		END;
	ELSEIF(var_Method_Name = 'Get_One_Item') THEN
		BEGIN
			
            select 
			t036.Org_Id,t036.Entry_Id,t036.Target_Id,
			t036.ProductGroup_Id as ProductGroup_Id,
			t036.Product_Id as Product_Id,
			t036.ProductUOM, t036.Quantity
			from t036_salesusers_targets_item t036
			WHERE t036.Org_Id = var_Org_Id
			AND t036.Target_Id = var_Target_Id
            AND t036.Entry_Id = var_Entry_Id;
			
		END;
        ELSEIF(var_Method_Name = 'Get_Product') THEN
		BEGIN
			
            set @BaseUnit = (select ifnull(BaseUnit,'') as BaseUnit 
							from m017_product 
							where Org_Id = var_Org_Id 
							and Product_Id = var_Entry_Id limit 1);
                            
			if(@BaseUnit is null or @BaseUnit ='')then
            
				set @BaseUnit = '';
            else 
				set @BaseUnit = @BaseUnit;
            
            
            end if;
            
            select @BaseUnit as productuom;
            
			
		END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
