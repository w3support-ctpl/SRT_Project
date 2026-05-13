-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_MCCCollection_Update` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_MCCCollection_Update`(
Var_Method_Name varchar(50),
Var_MCC_Id varchar(20),
Var_Org_Id varchar(20),
Var_MCCCollectionshift_Id varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
set sql_require_primary_key = 0 ;
SET SQL_SAFE_UPDATES = 0;

	if(Var_Method_Name = 'UpdateCollection')then 
    
		INSERT INTO f009_mcc_collection(Org_Id, MCCCollectionShift_Id, MCC_Id, Date, Opening_Quantity, Collection, Dispatch, Adjust, Closing_Quantity)
		SELECT  T004.Org_Id , MAX(T004.MCCCollectionShift_Id) , T004.MCC_Id , MAX(T004.Collection_Date) ,
		ifnull(LastQTY.Closing_Quantity , 0),  SUM(T005.Quantity_Ltr) , 0 , 0 , (SUM(T005.Quantity_Ltr) +  ifnull(LastQTY.Closing_Quantity , 0))
		FROM t004_mcccollectionshift T004
		INNER JOIN t005_milkcollectionfarmer T005 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
		LEFT JOIN f009_mcc_collection FOO9 ON DATE(FOO9.Date) = DATE(T004.Collection_Date) AND  FOO9.Org_Id = T004.Org_Id
		left join (SELECT Org_Id, MCCCollectionShift_Id, MCC_Id, Date, Opening_Quantity, Collection, Dispatch, Adjust, Closing_Quantity
		FROM f009_mcc_collection
		WHERE (Org_Id , MCC_Id, Date) IN (
		SELECT Org_Id , MCC_Id, MAX(Date) AS MaxDate
		FROM f009_mcc_collection
		GROUP BY MCC_Id) ) LastQTY ON LastQTY.Org_Id = T004.Org_Id AND LastQTY.MCC_Id = T004.MCC_Id 
		WHERE Is_MilkDispatch <> 2 and FOO9.MCCCollectionShift_Id is null and Shift_Status = 2 
		GROUP BY T004.Org_Id ,T004.MCC_Id , DATE(T004.Collection_Date);
        
	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
