-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminSalesAreaItem_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminSalesAreaItem_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
	var_XML_Data longtext
)
BEGIN
SET SQL_SAFE_UPDATES = 0;

	set @Year_Id = (select right(left(curdate(),4),(2)));
		set @k = 0;
		SET @row_count := extractValue(var_XML_Data,'count(//SalesArea/SalesAreaData)');
			WHILE @k < @row_count DO
				SET @k := @k + 1;
				SET @xpath := concat('//SalesArea/SalesAreaData[', @k, ']');
               
                
		if EXISTS(select Org_Id from m013_salesarea_item
					where Org_Id = var_Org_Id
					and SalesOffice_Code = extractValue(var_XML_Data, concat(@xpath,'/SalesOffice'))
					and SalesOrg_Code = extractValue(var_XML_Data, concat(@xpath,'/SalesOrganization')) 
					and DistChannel_Code = extractValue(var_XML_Data, concat(@xpath,'/DistributionChannel'))
					and Division_Code = extractValue(var_XML_Data, concat(@xpath,'/OrganizationDivision')) 
					limit 1) then 
                
               update m013_salesarea_item 
				set SalesOffice_Name = extractValue(var_XML_Data, concat(@xpath,'/SalesOfficeName')),
				SAPSalesArea_Name = CONCAT(
										extractValue(var_XML_Data, concat(@xpath, '/SalesOrganizationName')), ' - ',
										extractValue(var_XML_Data, concat(@xpath, '/DistributionChannelName')), ' - ',
										extractValue(var_XML_Data, concat(@xpath, '/DivisionName'))
									)
				where Org_Id = var_Org_Id
				and SalesOffice_Code = extractValue(var_XML_Data, concat(@xpath,'/SalesOffice'))
				and SalesOrg_Code = extractValue(var_XML_Data, concat(@xpath,'/SalesOrganization')) 
				and DistChannel_Code = extractValue(var_XML_Data, concat(@xpath,'/DistributionChannel'))
				and Division_Code = extractValue(var_XML_Data, concat(@xpath,'/OrganizationDivision'))
				;

                    
			else
            
			insert into m013_salesarea_item 
			(Org_Id, SalesOffice_Code, SalesOrg_Code, DistChannel_Code, Division_Code, 
			SalesOffice_Name,SAPSalesArea_Name,
			Is_Active,Is_Deleted)
			value (
			var_Org_Id,
			extractValue(var_XML_Data, concat(@xpath,'/SalesOffice')),
			extractValue(var_XML_Data, concat(@xpath,'/SalesOrganization')),
			extractValue(var_XML_Data, concat(@xpath,'/DistributionChannel')),
			extractValue(var_XML_Data, concat(@xpath,'/OrganizationDivision')),
			extractValue(var_XML_Data, concat(@xpath,'/SalesOfficeName')),
			CONCAT(
			extractValue(var_XML_Data, concat(@xpath, '/SalesOrganizationName')), ' - ',
			extractValue(var_XML_Data, concat(@xpath, '/DistributionChannelName')), ' - ',
			extractValue(var_XML_Data, concat(@xpath, '/DivisionName'))
			),
			1,0
			);
                
               
			end if;
   
			END WHILE;
            
 
		SELECT 1 AS Result_Id, 
		'Downloaded' AS Result_Description, 
		'' AS Result_Extra_Key;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
