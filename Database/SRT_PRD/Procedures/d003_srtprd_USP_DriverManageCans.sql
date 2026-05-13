-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_DriverManageCans` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_DriverManageCans`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Profile_Id varchar(20),
Var_Date varchar(20),
Var_MCC_Id Text,
Var_IssueStocks_Id varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	if(Var_Method_Name = 'GetCanDistribution') then
		
		select m006.Route_Id , m006.Route_Name, Vehicle_Id, Driver_Id into @Route_Id , @Route_name  , @Vehicle_Id, @Driver_Id
		from m008_route_vehicle m008 inner join m006_route m006 on m006.Org_Id = m008.Org_Id and m006.Route_Id =  m008.Route_Id 
		where Driver_Id = Var_Profile_Id and m006.Org_Id = Var_Org_Id and 
		date(DATE_ADD(@Current_Datetime, INTERVAL 1 DAY)) between date(From_Date) and date(To_Date)
		and m008.Is_Active = 1 limit 1; 

	set @VehicleNo = (select Vehicle_No from m003_vehicle where Vehicle_Id = @Vehicle_Id and Org_Id = Var_Org_Id  );


	select issuecan.IssueStocks_Id , issuecan.MCC_Id , issuecan.MCC_Name ,
    CAST(issuecan.Aluminum_Can_withlid AS  SIGNED ) AS AluminumCan_WithLid ,
    CAST(issuecan.Aluminum_Can_withoutlid  AS  SIGNED )  AS AluminumCan_WithoutLid ,
	CAST(issuecan.Plastic_Can_withlid  AS  SIGNED )  AS PlasticCan_WithLid ,
	CAST(issuecan.Plastic_Can_withoutlid   AS  SIGNED )  AS PlasticCan_WithoutLid ,
    CAST(issuecan.Total_Can   AS  SIGNED ) as Total_Can , 
    0 as Total_Lid , 
     @Route_Id as Route_Id , @Route_name as Route_name, @VehicleNo as VehicleNo, @Driver_Id as Driver_Id
    from (SELECT 
    t018.IssueStocks_Id, 
    t019.MCC_Id,
    m005.MCC_Name as MCC_Name,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000001' THEN Quantity ELSE NULL END) ,0) AS Aluminum_Can_withlid,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000002' THEN Quantity ELSE NULL END) , 0)AS Aluminum_Can_withoutlid,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000003' THEN Quantity ELSE NULL END),0) AS Plastic_Can_withlid,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000004' THEN Quantity  ELSE NULL END),0) AS Plastic_Can_withoutlid,
	ifnull(CAST((Sum(CASE WHEN m010.MaterialType_Id in( 'C042231000004' ,'C042231000002', 'C042231000001' , 'C042231000003' )THEN Quantity ELSE NULL END)) AS SIGNED) ,0) AS Total_Lid,
	ifnull(CAST((Sum(CASE WHEN m010.MaterialType_Id in( 'C042231000004' ,'C042231000002', 'C042231000001' , 'C042231000003' )THEN Quantity ELSE NULL END) ) AS SIGNED),0) AS Total_Can
FROM 
    t018_issuestocks_header t018 inner join t019_issuestocks_item t019 on t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
        inner join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id = t019.Material_Id
        inner join c042_materialtype c042 on c042.MaterialType_Id = m010.MaterialType_Id
        inner join m005_mcc m005 on m005.Org_Id= t019.Org_Id and m005.MCC_Id= t019.MCC_Id
        where t018.Route_Id = @Route_Id and t018.Vehicle_Id = @Vehicle_Id and Is_DriverAccepted = 0 
	GROUP BY  IssueStocks_Id, MCC_Id ,  m005.MCC_Name ) issuecan 
    where issuecan.Aluminum_Can_withlid <> 0 or  issuecan.Aluminum_Can_withoutlid <> 0 or issuecan.Plastic_Can_withlid <> 0  or issuecan.Plastic_Can_withoutlid <> 0;
    

	elseif(Var_Method_Name = 'CollectCans') then 
			
		update t018_issuestocks_header 
		set  Is_DriverAccepted  = 1 ,
        Driver_Id = Var_Profile_Id,
		LastEditedBy_Id = Var_Profile_Id,
		LastEditedBy_Name = (select Driver_Name from mu06_driver where Org_Id = Var_Org_Id and Driver_Id = Var_Profile_Id )
		where IssueStocks_Id = Var_IssueStocks_Id and Org_Id = Var_Org_Id ;
            
		select 1 as Result_Id, 'collected' as Result_Description, '' as Result_Extra_Key;

	elseif(Var_Method_Name = 'CansHistory') then 
    
SELECT DATE_FORMAT(MCC_Accepted_On, '%e %M %Y')  as StockDate,
    ifnull(cast(sum(CASE WHEN m010.MaterialType_Id = 'C042231000001' THEN Quantity ELSE NULL END)AS  SIGNED ) ,0) AS Aluminum_Can_withlid,
    ifnull(cast(sum(CASE WHEN m010.MaterialType_Id = 'C042231000002' THEN Quantity ELSE NULL END)AS  SIGNED )  , 0)AS Aluminum_Can_withoutlid,
    ifnull(cast(sum(CASE WHEN m010.MaterialType_Id = 'C042231000003' THEN Quantity ELSE NULL END)AS  SIGNED ) ,0) AS Plastic_Can_withlid,
    ifnull(cast(sum(CASE WHEN m010.MaterialType_Id = 'C042231000004' THEN Quantity  ELSE NULL END)AS  SIGNED ) ,0) AS Plastic_Can_withoutlid,
	ifnull(CAST((Sum(CASE WHEN m010.MaterialType_Id in( 'C042231000004' ,'C042231000002', 'C042231000001' , 'C042231000003' )THEN Quantity ELSE NULL END)) AS SIGNED) ,0) AS Total_Lid,
	ifnull(CAST((Sum(CASE WHEN m010.MaterialType_Id in( 'C042231000004' ,'C042231000002', 'C042231000001' , 'C042231000003' )THEN Quantity ELSE NULL END) ) AS SIGNED),0) AS Total_Can
FROM t018_issuestocks_header t018 inner join t019_issuestocks_item t019 on t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
	inner join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id = t019.Material_Id
	inner join c042_materialtype c042 on c042.MaterialType_Id = m010.MaterialType_Id
	inner join m005_mcc m005 on m005.Org_Id= t019.Org_Id and m005.MCC_Id= t019.MCC_Id
	where t018.Driver_Id = Var_Profile_Id and Is_DriverAccepted = 1 and Is_MCCAccepted = 1 and StockIssue_Type =  'Cans' and 
	t018.Org_Id =  Var_Org_Id and month(Var_Date) = month(MCC_Accepted_On) and year(Var_Date) = year(MCC_Accepted_On)
	group by MCC_Accepted_On
	order by MCC_Accepted_On desc;


	elseif(Var_Method_Name = 'GetCanStock') then 
    
		
		select m006.Route_Id , m006.Route_Name, Vehicle_Id, Driver_Id into @Route_Id , @Route_name  , @Vehicle_Id, @Driver_Id
		from m008_route_vehicle m008 inner join m006_route m006 on m006.Org_Id = m008.Org_Id and m006.Route_Id =  m008.Route_Id 
		where Driver_Id = Var_Profile_Id and m006.Org_Id = Var_Org_Id and 
		date(DATE_ADD(@Current_Datetime, INTERVAL 1 DAY)) between date(From_Date) and date(To_Date)
		and m008.Is_Active = 1 limit 1; 

		set @VehicleNo = (select Vehicle_No from m003_vehicle where Vehicle_Id = @Vehicle_Id and Org_Id = Var_Org_Id  );
        
 
 	select issuecan.IssueStocks_Id , issuecan.MCC_Id , issuecan.MCC_Name ,
    CAST(issuecan.Aluminum_Can_withlid AS  SIGNED ) AS AluminumCan_WithLid ,
    CAST(issuecan.Aluminum_Can_withoutlid  AS  SIGNED )  AS AluminumCan_WithoutLid ,
	CAST(issuecan.Plastic_Can_withlid  AS  SIGNED )  AS PlasticCan_WithLid ,
	CAST(issuecan.Plastic_Can_withoutlid   AS  SIGNED )  AS PlasticCan_WithoutLid ,
    CAST(issuecan.Total_Can   AS  SIGNED ) as Total_Can , 
    0 as Total_Lid , 
     @Route_Id as Route_Id , @Route_name as Route_name, @VehicleNo as VehicleNo, @Driver_Id as Driver_Id
    from (SELECT 
    t018.IssueStocks_Id, 
    t019.MCC_Id,
    m005.MCC_Name as MCC_Name,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000001' THEN Quantity ELSE NULL END) ,0) AS Aluminum_Can_withlid,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000002' THEN Quantity ELSE NULL END) , 0)AS Aluminum_Can_withoutlid,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000003' THEN Quantity ELSE NULL END),0) AS Plastic_Can_withlid,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000004' THEN Quantity  ELSE NULL END),0) AS Plastic_Can_withoutlid,
	ifnull(CAST((Sum(CASE WHEN m010.MaterialType_Id in( 'C042231000004' ,'C042231000002', 'C042231000001' , 'C042231000003' )THEN Quantity ELSE NULL END)) AS SIGNED) ,0) AS Total_Lid,
	ifnull(CAST((Sum(CASE WHEN m010.MaterialType_Id in( 'C042231000004' ,'C042231000002', 'C042231000001' , 'C042231000003' )THEN Quantity ELSE NULL END) ) AS SIGNED),0) AS Total_Can
FROM 
    t018_issuestocks_header t018 inner join t019_issuestocks_item t019 on t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
        inner join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id = t019.Material_Id
        inner join c042_materialtype c042 on c042.MaterialType_Id = m010.MaterialType_Id
        inner join m005_mcc m005 on m005.Org_Id= t019.Org_Id and m005.MCC_Id= t019.MCC_Id
        where t018.Route_Id = @Route_Id and t018.Vehicle_Id = @Vehicle_Id and Is_DriverAccepted = 1 and  Is_MCCAccepted <> 1
	GROUP BY  IssueStocks_Id, MCC_Id ,  m005.MCC_Name ) issuecan 
    where issuecan.Aluminum_Can_withlid <> 0 or  issuecan.Aluminum_Can_withoutlid <> 0 or issuecan.Plastic_Can_withlid <> 0  or issuecan.Plastic_Can_withoutlid <> 0;
    
 
 
 
 
 
 
 
 
 
 
 
	end if;


END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
