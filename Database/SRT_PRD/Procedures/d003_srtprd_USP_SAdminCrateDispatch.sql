-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminCrateDispatch` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminCrateDispatch`(
    var_Method_Name VARCHAR(20),
	var_Org_Id VARCHAR(10),
    Var_Dealer_Id varchar(30),
    var_Received_Period varchar(100)
)
BEGIN

	IF(var_Method_Name = 'GetCrates') then 

	SET @var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Received_Period, ' - ', 1), '%m/%d/%Y');
	SET @var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Received_Period, ' - ', -1), '%m/%d/%Y');
		
    	select t039.Org_Id , t039.Dispatch_Id , t039.Dispatch_Id , t039.Dealer_Code , t039.Quantity, date(t039.Dispatch_Date ) as Dispatch_Date, 
	t039.Material_Code , m010.Material_Name from t039_dispatch_crate t039 
	left join mu08_dealer mu08 on mu08.Org_Id = t039.Org_Id and mu08.Dealer_Code = TRIM(LEADING '0' FROM t039.Dealer_Code ) 
    left join m010_material m010 on m010.Org_Id = t039.Org_Id and m010.Material_Code = t039.Material_Code
	where mu08.Dealer_Id = Var_Dealer_Id and date(t039.Dispatch_Date) between date(@var_StartDate) and date(@var_EndDate)
    and m010.MaterialType_Id = 'C042231000005'
	order by date(t039.Dispatch_Date ) desc ;
    
	end if;
        

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
