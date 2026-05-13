-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminService_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminService_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_ServiceType_Id varchar(20),
    var_Service_Id varchar(20),
    var_Service_Name varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select m012.Org_Id, Service_Id, 
            c027.ServiceType_Id, c027.ServiceType_Name, 
            m010.Material_Id, ifnull(m010.Material_Name, '') AS Material_Name, 
            Service_Name, m012.Service_Description,
            m012.Is_Active, m012.Is_Deleted
            from m012_service m012
			inner join c027_servicetype c027 on c027.ServiceType_Id = m012.ServiceType_Id 
            left join m010_material m010 on m010.Material_Id = m012.Material_Id 
				and m010.Org_Id = m012.Org_Id 
            where m012.Org_Id = var_Org_Id and m012.Is_Deleted = 0 
            and m012.ServiceType_Id like var_ServiceType_Id
            and Service_Name like var_Service_Name
            order by Service_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id, Service_Id, Service_Name, ServiceType_Id, Service_Description,  Is_For_Farmer, Is_For_Agent,
			Material_Id,Condition_1,Condition_2,Condition_3,Condition_4,Condition_5,Is_Active, Is_Deleted 
            from m012_service 
            where Org_Id = var_Org_Id and Service_Id = var_Service_Id 
            and Is_Deleted =0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
