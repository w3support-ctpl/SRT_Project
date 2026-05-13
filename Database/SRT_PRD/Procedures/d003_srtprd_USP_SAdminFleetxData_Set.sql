-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminFleetxData_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminFleetxData_Set`(
var_Method_Name varchar(30),
var_XML_Data longtext
)
BEGIN

insert into temp(text ) value (var_XML_Data);

set @Year_Id = (select right(left(curdate(),4),(2)));
		set @k = 0;
		SET @row_count := extractValue(var_XML_Data,'count(//Vehicle/Vehicledata)');
			WHILE @k < @row_count DO
				SET @k := @k + 1;
				SET @xpath := concat('//Vehicle/Vehicledata[', @k, ']');
                
				CALL USP_Number_Range ('l005_fleetx_routevehicle', @Year_Id, 'L005', '', @New_Id );
   
                insert into l005_fleetx_routevehicle (Entry_Id, FleetX_RouteId, Latitude, Longitude, Update_On, Created_On) value 
                (@New_Id,  extractValue(var_XML_Data, concat(@xpath,'/accountId')), 
                extractValue(var_XML_Data, concat(@xpath,'/latitude')),  
                extractValue(var_XML_Data, concat(@xpath,'/longitude')), 
				(extractValue(var_XML_Data, concat(@xpath,'/lastUpdatedAt'))), 
                 now()
                );
                
			END WHILE;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
