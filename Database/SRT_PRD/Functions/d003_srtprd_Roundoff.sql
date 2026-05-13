-- Function Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP FUNCTION IF EXISTS `Roundoff` ;;
CREATE DEFINER=`appuser`@`%` FUNCTION `Roundoff`(
var_Method varchar(50),
var_input decimal(8,3)
) RETURNS decimal(8,1)
    DETERMINISTIC
BEGIN

declare var_output decimal(8,1);

	IF(var_Method = 'Quality' ) then
    
		set var_output = (round (var_input - 0.01 , 1));
    
		return var_output;
    
	elseif(var_Method = 'Quantity')then 
	
		set var_output = (round (var_input - 0.01 , 1));
    
		return var_output;
	
    elseif(var_Method = 'QuantityForMcc')then 
    
		set var_output = (round (var_input - 0.1 ));
    
		return var_output;
	
    elseif(var_Method = 'QuantityForDairy')then 
    
		set var_output = (round (var_input - 0.1 , 0));
    
		return var_output;
    
    end if;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:33
