-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_ChemistTripHistory_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_ChemistTripHistory_Get`(
Var_Method_Name varchar(40),
Var_Org_Id varchar(20),
Var_Profile_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Trip_Id varchar(20),
Var_Vehicle_Id varchar(20),
Var_Date varchar(20)
)
BEGIN

    set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
	
    if(Var_Method_Name = 'GetTripHistory') then 
    
		select TripDocument_Id AS Trip_Id , m006.Route_Name , m003.Vehicle_No , t021.Trip_Status, 
		DATE_FORMAT(t021.Created_On, '%d %M %Y') as Trip_Date from t021_tripdocument_header t021 inner join 
		m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id and m008.Entry_Id = t021.Route_Trip_Id 
		inner join m006_route m006 on m006.Org_Id = t021.Org_Id and m006.Route_Id = m008.Route_Id 
		inner join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id = m008.Vehicle_Id
		where month(t021.Created_On) = month(Var_Date) and year(t021.Created_On) = year(Var_Date) and m008.Chemist_Id  = Var_Profile_Id ;
    
    elseif(Var_Method_Name = 'GetTripDetails') then 
		
			select t022.MCC_Id , m005.MCC_Name , Route_Name , m006.Route_Id , 
            DATE_FORMAT(Expected_Time, '%e %b %Y %h:%i %p')  as Expected_Time , ifnull(Is_Reached , 0) as Is_Reached , 
			DATE_FORMAT(t021.Created_On, '%e %b %Y %h:%i %p')  as Trip_Started_On, Trip_Status, ifnull(Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown from t022_tripdocument_item t022 
			inner join m005_mcc m005 on m005.Org_Id = t022.Org_Id and m005.MCC_Id = t022.MCC_Id
			inner join t021_tripdocument_header t021 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id 
			inner join  m006_route m006 on m006.Org_Id = m005.Org_Id and m006.Route_Id = t022.Route_Id 
			where t021.TripDocument_Id = Var_Trip_Id and t022.Org_Id = Var_Org_Id
            order by Order_By asc ;
		
        
	elseif (Var_Method_Name = 'GetTripMCCDetails') then
  
		SELECT (Aluminum_Can - Aluminum_Lid) as AluminumCan_Without_Lid , 
        Aluminum_Lid as AluminumCan_With_Lid , 
		(Plastic_Can - Plastic_Lid) as PlasticCan_Without_Lid , 
        Plastic_Lid as PlasticCan_With_Lid ,
        Quantity_Ltr AS Total_Quantity 
        from t007_milkcollectiondriver where Trip_Id = Var_Trip_Id and t022.Org_Id = Var_Org_Id;
        
    
    elseif(Var_Method_Name = 'GetLoss') then
    
    select DATE_FORMAT(t004.Collection_Date, '%d %M %Y') AS Collection_Date,  m005.MCC_Name , m006.Route_Name , 
	t009.Liters as Qty_By_Chemist , Adjusted_Liters as Qty_By_Dairy , 
	Loss as Total_Loss  from t009_milkcollectiondairy_mccloss t009 
	inner join t021_tripdocument_header t021 on t009.Org_Id = t021.Org_Id and t009.TripDocument_Id = t021.TripDocument_Id
	inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id and t021.Route_Trip_Id = m008.Entry_Id
	inner join m006_route m006 on t021.Org_Id = m006.Org_Id and m006.Route_Id = m008.Route_Id
	inner join m005_mcc m005 on t021.Org_Id = m005.Org_Id and t009.MCC_Id = m005.MCC_Id
	inner join t004_mcccollectionshift t004 on t021.Org_Id = t004.Org_Id and t009.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
	where Loss > 0 AND month(t021.Created_On) = month(Var_Date) and year(t021.Created_On) = year(Var_Date)
	and m008.Chemist_Id = Var_Profile_Id and t009.Org_Id  = Var_Org_Id
	order by t021.Created_On desc ;

    
    END IF;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
