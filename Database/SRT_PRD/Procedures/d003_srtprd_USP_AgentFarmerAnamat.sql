-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerAnamat` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerAnamat`(
var_Method_Name varchar(50),
var_Org_Id varchar(10),
var_MCC_Id varchar(20),
var_Farmer_Id varchar(20),
var_Anamat_PerLtr varchar(20)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
		Declare New_Entry_Id varchar(20);
		Declare Year_Id varchar(10);
        
        set Year_Id = (select right(left(curdate(),4),(2)));
		Call USP_Number_Range ('m005_mcc_offline_anamat_config', Year_Id, 'M005', '', New_Entry_Id );
        
        Insert Into m005_mcc_offline_anamat_config
		(Org_Id, Entry_Id, MCC_Id, Farmer_Id, Anamat_PerLtr, Created_On)
		Values (var_Org_Id, New_Entry_Id, var_MCC_Id, var_Farmer_Id, var_Anamat_PerLtr, now());
        
        SELECT 1 AS Result_Id, 
		'Saved' AS Result_Description, 
		New_Entry_Id AS Result_Extra_Key; 
				
        end;
	elseif (var_Method_Name = 'Get') then
		begin
			select
			ifnull(date_format(Created_On, '%d %b %Y %h:%i %p'),'') as Created_On ,
			ifnull(Anamat_PerLtr,0) as Anamat_PerLtr
			from m005_mcc_offline_anamat_config
			where Org_Id = var_Org_Id
			and MCC_Id =  var_MCC_Id
			and Farmer_Id =  var_Farmer_Id
			order by Created_On desc;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
