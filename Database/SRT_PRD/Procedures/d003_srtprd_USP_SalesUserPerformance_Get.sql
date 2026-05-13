-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesUserPerformance_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesUserPerformance_Get`(
	var_Method_Name varchar(100),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
    var_SalesUser_Id varchar(20),
    var_Date varchar(255),
    var_Product_Group varchar(255)
)
BEGIN
	SET SQL_SAFE_UPDATES=0;
	IF(var_Method_Name = 'Get') THEN
		BEGIN
			declare TotalTarget int default 0;
            declare AchieveTarget int default 0;
            DECLARE var_StartDate_1 DATE; 
			DECLARE var_EndDate_1 DATE;
			SET var_StartDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
				
			if(ifnull(var_SalesUser_Id,'') <> '') then
            
            select sum(ifnull(t036i.Quantity,0)) into TotalTarget 
            from t036_salesusers_targets_header t036
			inner join t036_salesusers_targets_item t036i on
			t036.Org_Id = t036i.Org_Id
			and t036.Target_Id = t036i.Target_Id
			where t036.Org_Id = var_Org_Id
			and t036.SalesUser_Id = var_SalesUser_Id
			-- and month(t036.Month_Year) = month(var_Date) 
			-- and year(t036.Month_Year) = year(var_Date)
            AND month(t036.Month_Year) >= month(var_StartDate_1) 
			AND year(t036.Month_Year) >= year(var_StartDate_1) 
			AND month(t036.Month_Year) <= month(var_EndDate_1)
			AND year(t036.Month_Year) <= year(var_EndDate_1)
			and t036.Is_Active = 1;
            
            select sum(ifnull(f501.Quantity,0))  into AchieveTarget 
            from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id = var_SalesUser_Id
            inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
            inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
            and m017.BaseUnit = f501.BaseUnit
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date);
            AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1);
            
            select ifnull(TotalTarget,0) as TotalTarget,ifnull(AchieveTarget,0) as AchieveTarget;
            
            else
            
            select sum(ifnull(t036i.Quantity,0)) into TotalTarget 
            from t036_salesusers_targets_header t036
			inner join t036_salesusers_targets_item t036i on
			t036.Org_Id = t036i.Org_Id
			and t036.Target_Id = t036i.Target_Id
			where t036.Org_Id = var_Org_Id
			and t036.SalesUser_Id in(
									select SalesUser_Id from mu12_sales_user 
									where Org_Id = var_Org_Id
									and ReportingTo_Id = var_Profile_Id
									union all
									select SalesUser_Id from mu12_sales_user 
									where Org_Id =  var_Org_Id
									and SalesUser_Id = var_Profile_Id
									)
			-- and month(t036.Month_Year) = month(var_Date) 
			-- and year(t036.Month_Year) = year(var_Date)
            AND month(t036.Month_Year) >= month(var_StartDate_1) 
			AND year(t036.Month_Year) >= year(var_StartDate_1) 
			AND month(t036.Month_Year) <= month(var_EndDate_1)
			AND year(t036.Month_Year) <= year(var_EndDate_1)
			and t036.Is_Active = 1;
            
            select sum(ifnull(f501.Quantity,0))  into AchieveTarget 
            from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id in(
									select SalesUser_Id from mu12_sales_user 
									where Org_Id = var_Org_Id
									and ReportingTo_Id = var_Profile_Id
									union all
									select SalesUser_Id from mu12_sales_user 
									where Org_Id =  var_Org_Id
									and SalesUser_Id = var_Profile_Id
									)
            inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
            inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
            and m017.BaseUnit = f501.BaseUnit
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date);
            AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1);
            
            select ifnull(TotalTarget,0) as TotalTarget,ifnull(AchieveTarget,0) as AchieveTarget;
            
            end if;
        end;
	elseIF(var_Method_Name = 'GetDealerGroup') THEN
		BEGIN
        
			DECLARE var_StartDate_1 DATE; 
			DECLARE var_EndDate_1 DATE;
			SET var_StartDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            if(ifnull(var_SalesUser_Id,'') <> '') then
            
            select 
			m017.Product_Group
			from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id = var_SalesUser_Id
			inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
			inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date)
            AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1)
			group by m017.Product_Group
			order by m017.Product_Group;
            
            else
            
            select 
			m017.Product_Group 
			from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id in(
									select SalesUser_Id from mu12_sales_user 
									where Org_Id = var_Org_Id
									and ReportingTo_Id = var_Profile_Id
									union all
									select SalesUser_Id from mu12_sales_user 
									where Org_Id =  var_Org_Id
									and SalesUser_Id = var_Profile_Id
									)
			inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
			inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date)
            AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1)
			group by m017.Product_Group
			order by m017.Product_Group;
            
            end if;
            
            
        end;
	elseIF(var_Method_Name = 'GetDealer') THEN
		BEGIN
        
			DECLARE var_StartDate_1 DATE; 
			DECLARE var_EndDate_1 DATE;
			SET var_StartDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            if(ifnull(var_SalesUser_Id,'') <> '') then
            
            select 
			f501.Dealer_Id,
			mu08.Dealer_Name,m017.Product_Name,m017.BaseUnit,
			sum(ifnull(f501.Quantity,0)) as Quantity,
			sum(ifnull(f501.Amount,0)) as Amount
			from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id = var_SalesUser_Id
			inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
			inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
            and m017.BaseUnit = f501.BaseUnit
            and m017.Product_Group = var_Product_Group
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date)
            AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1)
			group by f501.Dealer_Id,mu08.Dealer_Name,m017.Product_Name,m017.BaseUnit
			order by mu08.Dealer_Name,m017.Product_Name,m017.BaseUnit;
            
            else
            
            select 
			f501.Dealer_Id,
			mu08.Dealer_Name,m017.Product_Name,m017.BaseUnit,
			sum(ifnull(f501.Quantity,0)) as Quantity,
			sum(ifnull(f501.Amount,0)) as Amount
			from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id in(
									select SalesUser_Id from mu12_sales_user 
									where Org_Id = var_Org_Id
									and ReportingTo_Id = var_Profile_Id
									union all
									select SalesUser_Id from mu12_sales_user 
									where Org_Id =  var_Org_Id
									and SalesUser_Id = var_Profile_Id
									)
			inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
			inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
            and m017.BaseUnit = f501.BaseUnit
            and m017.Product_Group = var_Product_Group
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date)
            AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1)
			group by f501.Dealer_Id,mu08.Dealer_Name,m017.Product_Name,m017.BaseUnit
			order by mu08.Dealer_Name,m017.Product_Name,m017.BaseUnit;
            
            end if;
            
            
        end;
	elseIF(var_Method_Name = 'GetProduct') THEN
		BEGIN
			DECLARE var_StartDate_1 DATE; 
			DECLARE var_EndDate_1 DATE;
			SET var_StartDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            if(ifnull(var_SalesUser_Id,'') <> '') then
            
            select 
			m017.Product_Group,m023.Product_Name,m017.BaseUnit,
			sum(ifnull(f501.Quantity,0)) as Quantity,
			sum(ifnull(f501.Amount,0)) as Amount
			from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id = var_SalesUser_Id
			inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
			inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
            and m017.BaseUnit = f501.BaseUnit
            and m017.Product_Group = var_Product_Group
			inner join m023_product_group m023 on
			mu12.Org_Id = m023.Org_Id
			and m017.Product_Group = m023.Product_Group
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date)
             AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1)
			group by m017.Product_Group,m023.Product_Name,m017.BaseUnit
			order by m017.Product_Group,m023.Product_Name,m017.BaseUnit;
            
            else
            
            select 
			m017.Product_Group,m023.Product_Name,m017.BaseUnit,
			sum(ifnull(f501.Quantity,0)) as Quantity,
			sum(ifnull(f501.Amount,0)) as Amount
			from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id in(
									select SalesUser_Id from mu12_sales_user 
									where Org_Id = var_Org_Id
									and ReportingTo_Id = var_Profile_Id
									union all
									select SalesUser_Id from mu12_sales_user 
									where Org_Id =  var_Org_Id
									and SalesUser_Id = var_Profile_Id
									)
			inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
			inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
            and m017.BaseUnit = f501.BaseUnit
            and m017.Product_Group = var_Product_Group
			inner join m023_product_group m023 on
			mu12.Org_Id = m023.Org_Id
			and m017.Product_Group = m023.Product_Group
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date)
             AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1)
			group by m017.Product_Group,m023.Product_Name,m017.BaseUnit
			order by m017.Product_Group,m023.Product_Name,m017.BaseUnit;
            
            end if;
            
			
		end;
	elseIF(var_Method_Name = 'GetProductGroup') THEN
		BEGIN
			DECLARE var_StartDate_1 DATE; 
			DECLARE var_EndDate_1 DATE;
			SET var_StartDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            if(ifnull(var_SalesUser_Id,'') <> '') then
            
            select 
			m017.Product_Group
			from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id = var_SalesUser_Id
			inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
			inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
			inner join m023_product_group m023 on
			mu12.Org_Id = m023.Org_Id
			and m017.Product_Group = m023.Product_Group
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date)
             AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1)
			group by m017.Product_Group
			order by m017.Product_Group;
            
            else
            
            select 
			m017.Product_Group
			from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id in(
									select SalesUser_Id from mu12_sales_user 
									where Org_Id = var_Org_Id
									and ReportingTo_Id = var_Profile_Id
									union all
									select SalesUser_Id from mu12_sales_user 
									where Org_Id =  var_Org_Id
									and SalesUser_Id = var_Profile_Id
									)
			inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
			inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
			inner join m023_product_group m023 on
			mu12.Org_Id = m023.Org_Id
			and m017.Product_Group = m023.Product_Group
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date)
             AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1)
			group by m017.Product_Group
			order by m017.Product_Group;
            
            end if;
            
			
		end;
	elseIF(var_Method_Name = 'GetGraph') THEN
		BEGIN
			
            DECLARE var_StartDate_1 DATE; 
			DECLARE var_EndDate_1 DATE;
			SET var_StartDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate_1 = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            if(ifnull(var_SalesUser_Id,'') <> '') then
            
            DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
			CREATE TEMPORARY TABLE temp_Report_1 ( 
			Product_Id varchar(20),
            BaseUnit varchar(20),
            Quantity decimal(60,3));

			insert into temp_Report_1 (Product_Id,BaseUnit, Quantity)

			select 
			m017.Product_Id,
            m017.BaseUnit,
			sum(ifnull(f501.Quantity,0)) as Quantity
			from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id = var_SalesUser_Id
			inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
			inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
            and m017.BaseUnit = f501.BaseUnit
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date)
            
             AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1)
			group by m017.Product_Id ,m017.BaseUnit
			order by m017.Product_Id, m017.BaseUnit;



			DROP TEMPORARY TABLE IF EXISTS temp_Report_2;
			CREATE TEMPORARY TABLE temp_Report_2 ( 
			Product_Id varchar(20),
            BaseUnit varchar(20),
            Quantity decimal(60,3));

			insert into temp_Report_2 (Product_Id,BaseUnit, Quantity)

			select t036i.Product_Id,
            t036i.ProductUOM,
            sum(ifnull(t036i.Quantity,0))  as Quantity
			from t036_salesusers_targets_header t036
			inner join t036_salesusers_targets_item t036i on
			t036.Org_Id = t036i.Org_Id
			and t036.Target_Id = t036i.Target_Id
			where t036.Org_Id = var_Org_Id
			and t036.SalesUser_Id = var_SalesUser_Id
			-- and month(t036.Month_Year) = month(var_Date) 
			-- and year(t036.Month_Year) = year(var_Date)
             AND month(t036.Month_Year) >= month(var_StartDate_1) 
			AND year(t036.Month_Year) >= year(var_StartDate_1) 
			AND month(t036.Month_Year) <= month(var_EndDate_1)
			AND year(t036.Month_Year) <= year(var_EndDate_1)
			and t036.Is_Active = 1
			group by t036i.Product_Id,t036i.ProductUOM
			order by t036i.Product_Id,t036i.ProductUOM;


			DROP TEMPORARY TABLE IF EXISTS temp_Report_3;
			CREATE TEMPORARY TABLE temp_Report_3 ( 
			Product_Id varchar(20),
            BaseUnit varchar(20),
            Quantity decimal(60,3),
			Type varchar(20));

			insert into temp_Report_3
			(Product_Id, Quantity,BaseUnit,Type)
			select Product_Id, Quantity ,BaseUnit,'T' from temp_Report_2
			UNION ALL
			select Product_Id, Quantity ,BaseUnit,'A' from temp_Report_1;


			DROP TEMPORARY TABLE IF EXISTS temp_Report_4;
			CREATE TEMPORARY TABLE temp_Report_4 ( 
				Product_Id varchar(20), 
                BaseUnit varchar(20),
				Quantity_T decimal(60,0) DEFAULT 0, 
				Quantity_A decimal(60,0) DEFAULT 0
			);

			INSERT INTO temp_Report_4 (Product_Id,BaseUnit, Quantity_T, Quantity_A)
			SELECT 
				Product_Id,
                BaseUnit,
				SUM(CASE WHEN Type = 'T' THEN Quantity ELSE 0 END) AS Quantity_T,
				SUM(CASE WHEN Type = 'A' THEN Quantity ELSE 0 END) AS Quantity_A
			FROM 
				temp_Report_3
			GROUP BY 
				Product_Id,BaseUnit;

			SELECT tmp4.Product_Id,concat(ifnull(m017.Product_Name,'') , ' ,  Unit: ', ifnull(tmp4.BaseUnit,'')) as Product_Name, 
			tmp4.Quantity_T,tmp4.Quantity_A
			FROM temp_Report_4 tmp4 
			inner join m017_product m017 on
			m017.Product_Id = tmp4.Product_Id;
            
            else
            
            
            DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
			CREATE TEMPORARY TABLE temp_Report_1 ( 
			Product_Id varchar(20),
            BaseUnit varchar(20),
            Quantity decimal(60,3));
			
			insert into temp_Report_1 (Product_Id,BaseUnit, Quantity)

			select 
			m017.Product_Id,
            m017.BaseUnit,
			sum(ifnull(f501.Quantity,0)) as Quantity
			from f501_salesdata f501 
			inner join mu12_sales_user mu12 on
			mu12.Org_Id = f501.Org_Id
			and mu12.SalesEmployee = f501.SalesUser_Id
			and mu12.SalesUser_Id in(
									select SalesUser_Id from mu12_sales_user 
									where Org_Id = var_Org_Id
									and ReportingTo_Id = var_Profile_Id
									union all
									select SalesUser_Id from mu12_sales_user 
									where Org_Id =  var_Org_Id
									and SalesUser_Id = var_Profile_Id
									)
			inner join mu08_dealer mu08 on
			mu12.Org_Id = mu08.Org_Id
			and mu08.SalesUser_Id = mu12.SalesUser_Id
			and mu08.Dealer_Code = f501.Dealer_Id
			inner join m017_product m017 on
			f501.Org_Id = m017.Org_Id
			and m017.Product_Code = f501.Material_Id
            and m017.BaseUnit = f501.BaseUnit
			where f501.Org_Id = var_Org_Id
			-- and month(f501.Date) = month(var_Date) 
			-- and year(f501.Date) = year(var_Date)
            
             AND month(f501.Date) >= month(var_StartDate_1) 
			AND year(f501.Date) >= year(var_StartDate_1) 
			AND month(f501.Date) <= month(var_EndDate_1)
			AND year(f501.Date) <= year(var_EndDate_1)
			group by m017.Product_Id,m017.BaseUnit
			order by m017.Product_Id,m017.BaseUnit;



			DROP TEMPORARY TABLE IF EXISTS temp_Report_2;
			CREATE TEMPORARY TABLE temp_Report_2 ( 
			Product_Id varchar(20),
            BaseUnit varchar(20),
            Quantity decimal(60,3));

			insert into temp_Report_2 (Product_Id,BaseUnit, Quantity)

			select t036i.Product_Id,
            t036i.ProductUOM,
            sum(ifnull(t036i.Quantity,0))  as Quantity
			from t036_salesusers_targets_header t036
			inner join t036_salesusers_targets_item t036i on
			t036.Org_Id = t036i.Org_Id
			and t036.Target_Id = t036i.Target_Id
			where t036.Org_Id = var_Org_Id
			and t036.SalesUser_Id in(
									select SalesUser_Id from mu12_sales_user 
									where Org_Id = var_Org_Id
									and ReportingTo_Id = var_Profile_Id
									union all
									select SalesUser_Id from mu12_sales_user 
									where Org_Id =  var_Org_Id
									and SalesUser_Id = var_Profile_Id
									)
			-- and month(t036.Month_Year) = month(var_Date) 
			-- and year(t036.Month_Year) = year(var_Date)
             AND month(t036.Month_Year) >= month(var_StartDate_1) 
			AND year(t036.Month_Year) >= year(var_StartDate_1) 
			AND month(t036.Month_Year) <= month(var_EndDate_1)
			AND year(t036.Month_Year) <= year(var_EndDate_1)
			and t036.Is_Active = 1
			group by t036i.Product_Id,t036i.ProductUOM
			order by t036i.Product_Id,t036i.ProductUOM;


			DROP TEMPORARY TABLE IF EXISTS temp_Report_3;
			CREATE TEMPORARY TABLE temp_Report_3 ( 
			Product_Id varchar(20),
            BaseUnit varchar(20),
            Quantity decimal(60,3),
			Type varchar(20));

			insert into temp_Report_3
			(Product_Id,BaseUnit, Quantity,Type)
			select Product_Id,BaseUnit, Quantity ,'T' from temp_Report_2
			UNION ALL
			select Product_Id,BaseUnit, Quantity ,'A' from temp_Report_1;


			DROP TEMPORARY TABLE IF EXISTS temp_Report_4;
			CREATE TEMPORARY TABLE temp_Report_4 ( 
				Product_Id varchar(20), 
                BaseUnit varchar(20),
				Quantity_T decimal(60,0) DEFAULT 0, 
				Quantity_A decimal(60,0) DEFAULT 0
			);

			INSERT INTO temp_Report_4 (Product_Id,BaseUnit, Quantity_T, Quantity_A)
			SELECT 
				Product_Id,
                BaseUnit,
				SUM(CASE WHEN Type = 'T' THEN Quantity ELSE 0 END) AS Quantity_T,
				SUM(CASE WHEN Type = 'A' THEN Quantity ELSE 0 END) AS Quantity_A
			FROM 
				temp_Report_3
			GROUP BY 
				Product_Id,BaseUnit;

			SELECT tmp4.Product_Id,concat(ifnull(m017.Product_Name,'') , ' ,  Unit: ', ifnull(tmp4.BaseUnit,'')) as Product_Name, 
			tmp4.Quantity_T,tmp4.Quantity_A
			FROM temp_Report_4 tmp4 
			inner join m017_product m017 on
			m017.Product_Id = tmp4.Product_Id;
            
            end if;
            

			
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
