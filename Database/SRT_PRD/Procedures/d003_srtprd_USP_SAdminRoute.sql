-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminRoute` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminRoute`(
var_method_name varchar(50),
var_org_id varchar(20),
var_xml_data longtext
)
BEGIN

	if(var_method_name = 'DealerRouteMapped') then
        
        set @k = 0;
		SET @row_count := extractValue(var_XML_Data,'count(//Data/RouteData)');
			WHILE @k < @row_count DO
				SET @k := @k + 1;
				SET @xpath := concat('//Data/RouteData[', @k, ']');
                
                update mu08_dealer 
                set FleetX_RouteId = extractValue(var_XML_Data, concat(@xpath,'/RouteId'))
                where Dealer_Code = extractValue(var_XML_Data, concat(@xpath,'/DealerCode')) and Org_Id = var_org_id;
                

        END WHILE;
        
          SELECT 1 AS Result_Id, 
		'Saved' AS Result_Description, 
		'' AS Result_Extra_Key;
        
    elseif(var_method_name = 'AllRoute') then 
    
        set @k = 0;
		SET @row_count := extractValue(var_XML_Data,'count(//Data/AllRoute)');
			WHILE @k < @row_count DO
				SET @k := @k + 1;
				SET @xpath := concat('//Data/AllRoute[', @k, ']');
                
			if not exists (select 1 from m028_fleetx_route where 
                RouteId = extractValue(var_XML_Data, concat(@xpath,'/RouteId')) and 
                Org_Id = var_org_id ) then
                
				insert into m028_fleetx_route(Org_Id, RouteId, RouteName) value
               ( var_org_id , extractValue(var_XML_Data, concat(@xpath,'/RouteId')) , 
               extractValue(var_XML_Data, concat(@xpath,'/RouteName')) ); 

		end if ;
		
        END WHILE;

		SELECT 1 AS Result_Id, 
		'Saved' AS Result_Description, 
		'' AS Result_Extra_Key;
    

	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
