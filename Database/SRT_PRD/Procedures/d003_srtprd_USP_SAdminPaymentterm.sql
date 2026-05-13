-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminPaymentterm` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminPaymentterm`(
var_method_name varchar(50),
var_org_id varchar(20),
var_xml_data longtext
)
BEGIN

	if(var_method_name = 'PaymentTerms') then
        
        set @k = 0;
		SET @row_count := extractValue(var_XML_Data,'count(//Data/Payment)');
			WHILE @k < @row_count DO
				SET @k := @k + 1;
				SET @xpath := concat('//Data/Payment[', @k, ']');
                
				if not exists (select 1 from m029_payment_terms where 
                Payment_Term = extractValue(var_XML_Data, concat(@xpath,'/PaymentTerms')) and 
                Org_Id = var_org_id ) then
                
				insert into m029_payment_terms(Org_Id, Payment_Term, PaymentTermsName) value
               ( var_org_id , extractValue(var_XML_Data, concat(@xpath,'/PaymentTerms')) , 
               extractValue(var_XML_Data, concat(@xpath,'/PaymentTermsName')) ); 
               
			end if;

        END WHILE;
        
          SELECT 1 AS Result_Id, 
		'Saved' AS Result_Description, 
		'' AS Result_Extra_Key;
        
	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
