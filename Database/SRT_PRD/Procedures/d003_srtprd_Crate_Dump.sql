-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `Crate_Dump` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `Crate_Dump`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
	var_XML_Data longtext
)
BEGIN
SET SQL_SAFE_UPDATES = 0;

	set @Year_Id = (select right(left(curdate(),4),(2)));
		set @k = 0;
		SET @row_count := extractValue(var_XML_Data,'count(//Dealer/DealerData)');
			WHILE @k < @row_count DO
				SET @k := @k + 1;
				SET @xpath := concat('//Dealer/DealerData[', @k, ']');
                
		

			insert into crate_dump (Dealer_Code,Dispatch_Date,Quantity,GoodsMovementType,Material_Code)
			value (
			extractValue(var_XML_Data, concat(@xpath,'/Customer')),
            -- FROM_UNIXTIME(SUBSTRING_INDEX(SUBSTRING_INDEX(extractValue(var_XML_Data, concat(@xpath,'/PostingDate')), '(', -1), ')', 1) / 1000),
            extractValue(var_XML_Data, concat(@xpath,'/PostingDate')),
            extractValue(var_XML_Data, concat(@xpath,'/QuantityInBaseUnit')),
            extractValue(var_XML_Data, concat(@xpath,'/GoodsMovementType')),
			extractValue(var_XML_Data, concat(@xpath,'/Material'))
			);
		   
   
			END WHILE;
            
 
		SELECT 1 AS Result_Id, 
		'Downloaded' AS Result_Description, 
		'' AS Result_Extra_Key;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
