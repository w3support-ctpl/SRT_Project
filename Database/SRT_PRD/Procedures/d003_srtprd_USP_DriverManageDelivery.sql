-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_DriverManageDelivery` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_DriverManageDelivery`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_IssueStocks_Id varchar(20),
Var_Profile_Id varchar(20),
Var_Date varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
SET sql_mode = '';

	if(Var_Method_Name = 'GetStock') then
    

        set @MCC_Count  = ( 
        select count(distinct t019.MCC_Id) 
        from t018_issuestocks_header t018 
		inner join t019_issuestocks_item t019 on  t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
		left join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id =  t019.Material_Id
        left join m005_mcc m005 on m005.Org_Id = t019.Org_Id and m005.MCC_Id = t019.MCC_Id
        left join m017_product m017 on m017.Org_Id = t019.Org_Id and t019.Material_Id = m017.Product_Id
		where  t018.Is_DriverAccepted = 0 and StockIssue_Type in ('Material' , 'Product') and  t019.Is_MCCAccepted = 0
        AND Driver_Id = Var_Profile_Id AND t018.Org_Id = Var_Org_Id
        );
        
	
		select ifnull(m010.Material_Name , m017.Product_Name) as Material_Name , @MCC_Count as MCC_Count ,
        cast(SUM(t019.Quantity) AS SIGNED) AS Quantity , m005.MCC_Id , m005.MCC_Name 
		from t018_issuestocks_header t018 
		inner join t019_issuestocks_item t019 on  t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
		left join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id =  t019.Material_Id
        left join m005_mcc m005 on m005.Org_Id = t019.Org_Id and m005.MCC_Id = t019.MCC_Id
        left join m017_product m017 on m017.Org_Id = t019.Org_Id and t019.Material_Id = m017.Product_Id
		where  t018.Is_DriverAccepted = 0 and StockIssue_Type in ('Material' , 'Product') and  t019.Is_MCCAccepted = 0
        AND Driver_Id = Var_Profile_Id AND t018.Org_Id = Var_Org_Id
		GROUP BY t019.Material_Id , m005.MCC_Id , m005.MCC_Name
        order by m005.MCC_Name  asc;


		ELSEIF(Var_Method_Name = 'AcceptStock') then
        
            update t018_issuestocks_header t018 
			inner join t019_issuestocks_item t019 on t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
            set t018.Is_DriverAccepted = 1,
            LastEditedBy_Id = Var_Profile_Id
            where Driver_Id = Var_Profile_Id and Is_Active = 1 and Is_MCCAccepted = 0 and   
			t018.Org_Id = Var_Org_Id;

			SELECT 1 AS Result_Id, 
			'Stock Accepted' AS Result_Description, 
			'' AS Result_Extra_Key;


		elseif(Var_Method_Name = 'GetHistory') then
      
        
         set @MCC_Count  = ( 
        select count(distinct t019.MCC_Id) 
        from t018_issuestocks_header t018 
		inner join t019_issuestocks_item t019 on  t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
		left join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id =  t019.Material_Id
        left join m005_mcc m005 on m005.Org_Id = t019.Org_Id and m005.MCC_Id = t019.MCC_Id
        left join m017_product m017 on m017.Org_Id = t019.Org_Id and t019.Material_Id = m017.Product_Id
		where  t018.Is_DriverAccepted = 1 and StockIssue_Type in ('Material' , 'Product') and  t019.Is_MCCAccepted = 1
        AND Driver_Id = Var_Profile_Id AND t018.Org_Id = Var_Org_Id and month(Var_Date) = month(Given_Date) and year(Var_Date) = year(Given_Date)
        );
        
	
		select ifnull(m010.Material_Name , m017.Product_Name) as Material_Name , @MCC_Count as MCC_Count ,
        cast(SUM(t019.Quantity) AS SIGNED) AS Quantity , m005.MCC_Name , DATE_FORMAT(Given_Date, '%d %M %Y') as Given_Date
		from t018_issuestocks_header t018 
		inner join t019_issuestocks_item t019 on  t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
		left join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id =  t019.Material_Id
        left join m005_mcc m005 on m005.Org_Id = t019.Org_Id and m005.MCC_Id = t019.MCC_Id
        left join m017_product m017 on m017.Org_Id = t019.Org_Id and t019.Material_Id = m017.Product_Id
		where
        -- t018.Is_DriverAccepted = 1 and StockIssue_Type in ('Material' , 'Product') and  t019.Is_MCCAccepted = 1 AND 
        Driver_Id = Var_Profile_Id AND t018.Org_Id = Var_Org_Id and  month(Var_Date) = month(Given_Date) and year(Var_Date) = year(Given_Date)
		GROUP BY t019.Material_Id , m005.MCC_Name , Given_Date
        order by Given_Date desc;

       

	END IF;
        
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
