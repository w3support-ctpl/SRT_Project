-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminCollectionRequest_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminCollectionRequest_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_CollectionRequest_Id varchar(20),
    var_ApprovalStatus_Id VARCHAR(20),
	var_Date varchar(60)
)
BEGIN

	SET @ApprovalStatus_Id = var_ApprovalStatus_Id;
	IF((var_ApprovalStatus_Id = '') OR (var_ApprovalStatus_Id IS NULL)) THEN
    BEGIN
		SET @ApprovalStatus_Id := '0,1,-1';
    END;
    END IF;
    
	if (var_Method_Name = 'Get') then  
		begin
			DECLARE var_StartDate DATE;
            DECLARE var_EndDate DATE;

            SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
            SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
			SELECT request.Org_Id, CollectionRequest_Id,
				IFNULL(Request_Details,'')Request_Details,
				IFNULL(Request_Remarks,'')Request_Remarks,
				IFNULL(DATE_FORMAT(request.Approved_On, '%d %M %Y'), '') AS Approved_On,
				request.Is_Approved,
				mcc.MCC_Id,mcc.MCC_Name,
				requesttype.RequestType_Id,requesttype.RequestType_Name, 
                IFNULL(DATE_FORMAT(request.Created_On, '%d %M %Y'), '') AS Created_On,
				IFNULL(Time_FORMAT(mccshift.ShiftEnd_Time, '%h:%i %p'),'') AS ShiftEnd_Time
            FROM t010_collectionrequest request 
            LEFT JOIN c038_requesttype requesttype ON requesttype.RequestType_Id = request.RequestType_Id
            LEFT JOIN m005_mcc mcc ON mcc.MCC_Id = request.MCC_Id and mcc.Org_Id = request.Org_Id
            -- LEFT JOIN t004_mcccollectionshift mccshift ON mccshift.MCCCollectionShift_Id = request.MCC_CollectionShift_Id
            LEFT JOIN (
				SELECT MCCCollectionShift_Id, Org_Id, ShiftEnd_Time
				FROM t004_mcccollectionshift
				UNION ALL
				SELECT MCCCollectionShift_Id, Org_Id, ShiftEnd_Time
				FROM t102_mcccollectionshift_offline
			) AS mccshift
				ON mccshift.MCCCollectionShift_Id = request.MCC_CollectionShift_Id 
				AND mccshift.Org_Id = request.Org_Id
            and mccshift.Org_Id = request.Org_Id
            WHERE request.Org_Id = var_Org_Id 
				AND CAST(request.Created_On AS DATE)>= var_StartDate 
				AND CAST(request.Created_On AS DATE) <= var_EndDate
				AND FIND_IN_SET(request.Is_Approved, @ApprovalStatus_Id)
            ORDER BY request.CollectionRequest_Id;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select request.Org_Id, request.CollectionRequest_Id, request.MCC_Id, request.RequestType_Id,
            ifnull(request.Request_Details,'')Request_Details,
            ifnull(request.Request_Remarks,'')Request_Remarks,
            request.Is_Approved, mccshift.MCCCollectionShift_Id,
			-- Time_FORMAT(mccshift.ShiftEnd_Time, '%H:%i') AS ShiftEnd_Time,
			Time_FORMAT(mccshift.Expected_End_Time, '%H:%i') AS ShiftEnd_Time,
            request.CreatedBy_Id
            from t010_collectionrequest request
            -- INNER JOIN t004_mcccollectionshift mccshift ON mccshift.MCCCollectionShift_Id = request.MCC_CollectionShift_Id
            INNER JOIN (
				SELECT MCCCollectionShift_Id, Org_Id, ShiftEnd_Time,Expected_End_Time
				FROM t004_mcccollectionshift
				UNION ALL
				SELECT MCCCollectionShift_Id, Org_Id, ShiftEnd_Time,Expected_End_Time
				FROM t102_mcccollectionshift_offline
			) AS mccshift
				ON mccshift.MCCCollectionShift_Id = request.MCC_CollectionShift_Id 
				AND mccshift.Org_Id = request.Org_Id
            and mccshift.Org_Id = request.Org_Id
            where request.Org_Id = var_Org_Id 
            and request.CollectionRequest_Id = var_CollectionRequest_Id;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
