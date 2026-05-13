-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_RunEvent_DriverEndTrip` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_RunEvent_DriverEndTrip`()
BEGIN

update t021_tripdocument_header t021
inner join t009_milkcollectiondairy_header t009
on t021.Org_Id = t009.Org_Id and t009.TripDocument_Id = t021.TripDocument_Id
set t021.Trip_Status = 'EndTrip'
where Is_Release = 1;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
