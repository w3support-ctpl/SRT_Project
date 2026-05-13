-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTripDocumentKM_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTripDocumentKM_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
	var_TripDocument_Id varchar(20),
    var_Out_KM varchar(45),
    var_IN_KM varchar(45),
    var_User_Id varchar(20),
	var_User_Name varchar(45)
)
BEGIN
	if (var_Method_Name = 'Update') then
		begin
				Update t021_tripdocument_header
				set 
				Out_KM = var_Out_KM,
				IN_KM = var_IN_KM,
				In_Locked_KM = 1
				where Org_Id = var_Org_Id 
				and TripDocument_Id = var_TripDocument_Id;   

				SELECT 1 AS Result_Id, 
				'Updated' AS Result_Description, 
				var_TripDocument_Id AS Result_Extra_Key;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
