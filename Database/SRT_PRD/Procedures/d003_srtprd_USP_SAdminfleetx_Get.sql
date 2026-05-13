-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminfleetx_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminfleetx_Get`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
    var_Route_Id varchar(20),
    var_User_Id varchar(20),
    var_Route_Name longtext,
    var_Date TEXT
)
BEGIN
	if (var_Method_Name = 'Get') then  
		begin
        
        DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
        
			select 
            Org_Id,Route_Id,Route_Name,Vehicle_No,Is_Active,Is_Deleted,
            CASE 
				WHEN ifnull(LastEdited_On,'') ='' THEN DATE_FORMAT(Created_On, '%d %b %Y %h:%i %p')
				ELSE DATE_FORMAT(LastEdited_On, '%d %b %Y %h:%i %p')
			END AS Date
            from m006_fleetx_route
            where 
            Org_Id = var_Org_Id
           and  Is_Deleted = 0
           and CAST(LastEdited_On AS DATE) >= var_StartDate
			AND CAST(LastEdited_On AS DATE) <= var_EndDate
            and Route_Name like  var_Route_Name;
        end;
	elseif (var_Method_Name = 'Get_One') then  
		begin
			select 
			m006.Org_Id,m006.Entry_Id,m006.Route_Id,m006.Type,
			mu08.Dealer_Id as createdby_id,
			mu08.Dealer_Name as createdby_name
			from m006_fleetx_route_item m006
			inner join mu08_dealer mu08 on
			m006.Org_Id = mu08.Org_Id
			and m006.User_Id = mu08.Dealer_Id
			and m006.Type = 'Dealer'
			where m006.Org_Id = var_Org_Id
			and m006.Route_Id = var_Route_Id

			union all

			select 
			m006.Org_Id,m006.Entry_Id,m006.Route_Id,m006.Type,
			mu09.Retailer_Id as createdby_id,
			mu09.Retailer_Name as createdby_name
			from m006_fleetx_route_item m006
			inner join mu09_retailer mu09 on
			m006.Org_Id = mu09.Org_Id
			and m006.User_Id = mu09.Retailer_Id
			and m006.Type = 'Retailer'
			where m006.Org_Id = var_Org_Id
			and m006.Route_Id = var_Route_Id;

        end;
	elseif (var_Method_Name = 'Get_Notification') then  
		begin
			SELECT DISTINCT 
				Org_Id, Entry_Id, Route_Id, User_Id, 
				Title, Body, Created_On
			FROM (
				SELECT 
					m006.Org_Id, m006.Entry_Id, m006.Route_Id, m006.User_Id, 
					IFNULL(m006.Title, '') AS Title, IFNULL(m006.Body, '') AS Body,
					IFNULL(DATE_FORMAT(m006.Created_On, '%d %b %Y %h:%i %p'), '') AS Created_On
				FROM m006_fleetx_route_item m006
				INNER JOIN mu08_dealer mu08 
					ON mu08.Org_Id = m006.Org_Id AND m006.User_Id = mu08.Dealer_Id
				WHERE m006.Org_Id = var_Org_Id
					AND m006.Type = 'Dealer'
					AND m006.User_Id = var_User_Id
					AND m006.Is_Notify = 1

				UNION ALL

				SELECT 
					m006.Org_Id, m006.Entry_Id, m006.Route_Id, m006.User_Id, 
					IFNULL(m006.Title, '') AS Title, IFNULL(m006.Body, '') AS Body,
					IFNULL(DATE_FORMAT(m006.Created_On, '%d %b %Y %h:%i %p'), '') AS Created_On
				FROM m006_fleetx_route_item m006
				WHERE m006.Org_Id = var_Org_Id
					AND m006.Type = 'Dealer'
					AND m006.User_Id IN (
						SELECT DISTINCT Dealer_Id 
						FROM mu08_dealer 
						WHERE Org_Id = var_Org_Id
						  AND SalesUser_Id IN (
							  SELECT DISTINCT SalesUser_Id 
							  FROM mu12_sales_user
							  WHERE Org_Id = var_Org_Id
								AND (SalesUser_Id = var_User_Id OR ReportingTo_Id = var_User_Id)
						  )
					)
					AND m006.Is_Notify = 1

				UNION ALL

				SELECT 
					m006.Org_Id, m006.Entry_Id, m006.Route_Id, m006.User_Id, 
					IFNULL(m006.Title, '') AS Title, IFNULL(m006.Body, '') AS Body,
					IFNULL(DATE_FORMAT(m006.Created_On, '%d %b %Y %h:%i %p'), '') AS Created_On
				FROM m006_fleetx_route_item m006
				INNER JOIN mu08_dealer mu08 
					ON mu08.Org_Id = m006.Org_Id AND m006.User_Id = mu08.Dealer_Id
				WHERE m006.Org_Id = var_Org_Id
					AND m006.Type = 'Retailer'
					AND m006.User_Id IN (
						SELECT DISTINCT Retailer_Id 
						FROM mu09_retailer 
						WHERE Org_Id = var_Org_Id
						  AND SalesUser_Id IN (
							  SELECT DISTINCT SalesUser_Id 
							  FROM mu12_sales_user
							  WHERE Org_Id = var_Org_Id
								AND SalesUser_Id = var_User_Id
						  )
					)
					AND m006.Is_Notify = 1
			) AS AllRoutes;

        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
