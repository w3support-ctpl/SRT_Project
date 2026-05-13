-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminProduct_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminProduct_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Product_Id varchar(20),
    var_Search_Text  varchar(50)
)
BEGIN
if (var_Method_Name = 'Get') then  
		begin
			select Org_Id,Product_Id, Product_Name, Product_Code,
            Product_Group,Rate,Image,Is_Active,Is_Deleted
            from m017_product 
            where Org_Id = var_Org_Id and Is_Deleted = 0 
            and (Product_Code like var_Search_Text 
			or Product_Name like var_Search_Text)
            order by Product_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id,Product_Id, Product_Name, Product_Code,
            Product_Group,Rate,Image,Is_Active,Is_Deleted
            from m017_product 
            where Org_Id = var_Org_Id and Product_Id = var_Product_Id 
            and Is_Deleted = 0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
