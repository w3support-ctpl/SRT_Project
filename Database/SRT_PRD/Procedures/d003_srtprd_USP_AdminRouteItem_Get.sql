-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRouteItem_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRouteItem_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Route_Id varchar(20),
    var_Stage_No int
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select m007.Org_Id,Route_Id, Stage_No, m005.MCC_Id,m005.MCC_Name, Distance,
            Time_FORMAT(Arrival_Time, '%h:%i %p') AS Arrival_Times,
            Time_FORMAT(Departure_Time, '%h:%i %p') AS Departure_Times
            from m007_route_item m007
            inner join m005_mcc m005 on m005.MCC_Id = m007.MCC_Id and m005.Org_Id = m007.Org_Id 
            where m007.Org_Id = var_Org_Id  
            and Route_Id = var_Route_Id
            order by Stage_No;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id,Route_Id, Stage_No, MCC_Id, Distance, Arrival_Time,Departure_Time 
            from m007_route_item 
            where Org_Id = var_Org_Id 
            and Stage_No = var_Stage_No 
            and Route_Id = var_Route_Id;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
