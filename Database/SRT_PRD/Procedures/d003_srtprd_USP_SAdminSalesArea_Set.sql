-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminSalesArea_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminSalesArea_Set`(
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
               
                
		if EXISTS(select SalesArea_Id from m013_salesarea
					where Org_Id = var_Org_Id
					and SalesArea_Code = extractValue(var_XML_Data, concat(@xpath,'/SalesGroup'))
					and SalesOffice_Code = extractValue(var_XML_Data, concat(@xpath,'/SalesOffice')) limit 1) then 
                
               update m013_salesarea 
				set SalesArea_Name = extractValue(var_XML_Data, concat(@xpath,'/SalesOfficeName'))
				where Org_Id = var_Org_Id 
				and SalesArea_Code = extractValue(var_XML_Data, concat(@xpath,'/SalesGroup'))
				and SalesOffice_Code = extractValue(var_XML_Data, concat(@xpath,'/SalesOffice'))
                ;
                    
			else
            
			
				CALL USP_Number_Range ('m013_salesarea', @Year_Id, 'M013', '', @New_Entry_Id );


                insert into m013_salesarea (Org_Id, SalesArea_Id, SalesArea_Name, SalesArea_Code, SalesOffice_Code, Is_Active,Is_Deleted,Created_On)
				value (
				var_Org_Id,@New_Entry_Id,
				extractValue(var_XML_Data, concat(@xpath,'/SalesOfficeName')),
				extractValue(var_XML_Data, concat(@xpath,'/SalesGroup')),
				extractValue(var_XML_Data, concat(@xpath,'/SalesOffice')),
				1,0,now()
				);
               
			end if;
   
			END WHILE;
            
 
		SELECT 1 AS Result_Id, 
		'Downloaded' AS Result_Description, 
		'' AS Result_Extra_Key;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
