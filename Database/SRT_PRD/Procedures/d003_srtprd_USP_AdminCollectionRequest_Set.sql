-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminCollectionRequest_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminCollectionRequest_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_CollectionRequest_Id varchar(20),
	var_User_Id varchar(20),
	var_User_Name varchar(45),
	var_ApprovalStatus_Id int,
    var_Expected_Time time,
    var_MCCCollectionShift_Id VARCHAR(20)
)
BEGIN
	IF (var_Method_Name = 'Update') THEN
	BEGIN
		-- DECLARE var_MCCCollectionShift_Id varchar(20);
        
        -- update in collection request table
		UPDATE t010_collectionrequest
			SET
				Approved_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
				Approved_Id = var_User_Id,
				Approved_Name = var_User_Name,
				Is_Approved = var_ApprovalStatus_Id,
                Expected_Time = var_Expected_Time
		WHERE Org_Id = var_Org_Id 
		AND CollectionRequest_Id = var_CollectionRequest_Id;   
                
		-- approve in mcc collection 
		IF (var_ApprovalStatus_Id = 1) THEN
		BEGIN
                -- set var_MCCCollectionShift_Id = (select MCC_CollectionShift_Id 
                -- from t010_collectionrequest
                -- where Org_Id = var_Org_Id 
                -- and CollectionRequest_Id = var_CollectionRequest_Id);
                
                
			UPDATE t004_mcccollectionshift
			SET Expected_End_Time = var_Expected_Time,
				Shift_Status = 1
			WHERE Org_Id = var_Org_Id 
			AND MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            
            UPDATE t102_mcccollectionshift_offline
			SET Expected_End_Time = var_Expected_Time,
				Shift_Status = 1
			WHERE Org_Id = var_Org_Id 
			AND MCCCollectionShift_Id = var_MCCCollectionShift_Id;
                
			SELECT 1 AS Result_Id, 
            'Approved' AS Result_Description, 
            var_CollectionRequest_Id AS Result_Extra_Key;
		END;                     
		ELSE
        BEGIN
			SELECT 1 AS Result_Id, 
			'Rejected' AS Result_Description, 
			var_CollectionRequest_Id AS Result_Extra_Key;
        END;
		END IF;
			
	END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
