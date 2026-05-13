-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminIncentiveRequest_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminIncentiveRequest_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_ApprovalStatus_Id varchar(20),
    var_Date varchar(60),
	var_Request_Id varchar(20),
	var_Request_For varchar(20)
)
BEGIN
	SET @ApprovalStatus_Id = var_ApprovalStatus_Id;
	IF((var_ApprovalStatus_Id = '') OR (var_ApprovalStatus_Id IS NULL)) THEN
    BEGIN
		SET @ApprovalStatus_Id := '0,1,-1';
    END;
    END IF;
	IF (var_Method_Name = 'Get') THEN
	BEGIN
		DECLARE var_StartDate DATE;
        DECLARE var_EndDate DATE;
        SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
        SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
		SELECT
				request.Org_Id AS Org_Id, 
                request.Request_Id AS Request_Id,
				incentivescheme.IncentiveScheme_Id AS IncentiveScheme_Id, 
				incentivescheme.Scheme_Name AS Scheme_Name, 
				request.Request_For AS Request_For, 
                request.Request_For_User_Id AS RequestFor_Id,
				request.Request_By AS Request_By,
				IFNULL( 
					CASE request.Request_For
					WHEN 'farmer' THEN farmer_req_for.Farmer_Id
					WHEN 'agent' THEN agent_req_for.Agent_Id
					END, '') AS Farmer_Agent_Id_Request_For,
				IFNULL( 
					CASE request.Request_For
					WHEN 'farmer' THEN farmer_req_for.Mobile_No
					WHEN 'agent' THEN agent_req_for.Mobile_No
					END, '') AS Farmer_Agent_Mobile_Request_For,
				IFNULL( 
					CASE request.Request_For
					WHEN 'farmer' THEN farmer_req_for.Farmer_Name
					WHEN 'agent' THEN agent_req_for.Agent_Name
					END, '') AS Farmer_Agent_Name_Request_For,
				IFNULL( 
					CASE request.Request_By
                    WHEN 'farmer' THEN farmer_req_by.Farmer_Id
                    WHEN 'agent' THEN agent_req_by.Agent_Id
					END, '' ) AS Farmer_Agent_Id_Request_By,
				IFNULL( 
					CASE request.Request_By
                    WHEN 'farmer' THEN farmer_req_by.Farmer_Name
                    WHEN 'agent' THEN agent_req_by.Agent_Name
					END, '' ) AS Farmer_Agent_Name_Request_By,
				IFNULL( 
					CASE request.Request_By
					WHEN 'farmer' THEN farmer_req_by.Mobile_No
					WHEN 'agent' THEN agent_req_by.Mobile_No
					END, '') AS Farmer_Agent_Mobile_Request_By,
				DATE_FORMAT(request.Request_Date, '%d %M %Y') AS Request_Date,
				ifnull(DATE_FORMAT(request.Approved_On, '%d %M %Y'),'') AS Approved_On,
				request.Is_Approved AS Is_Approved,
                IFNULL(request.Approval_Remarks,'') AS Approval_Remarks
			FROM t017_incentives_request request 
			INNER JOIN m011_incentivescheme incentivescheme ON incentivescheme.IncentiveScheme_Id = request.IncentiveScheme_Id
				and incentivescheme.Org_Id = request.Org_Id
			LEFT JOIN mu04_farmer farmer_req_for ON request.Request_For = 'farmer' 
				AND farmer_req_for.Farmer_Id = request.Request_For_User_Id
				and farmer_req_for.Org_Id = request.Org_Id
			LEFT JOIN mu05_agent agent_req_for ON request.Request_For = 'agent' 
				AND agent_req_for.Agent_Id = request.Request_For_User_Id
				AND agent_req_for.Org_Id = request.Org_Id
			LEFT JOIN mu04_farmer farmer_req_by ON request.Request_By = 'farmer' 
				AND farmer_req_by.Farmer_Id = request.Request_By_User_Id
                AND farmer_req_by.Org_Id = request.Org_Id
			LEFT JOIN mu05_agent agent_req_by ON request.Request_By = 'agent' 
				AND agent_req_by.Agent_Id = request.Request_By_User_Id
                AND agent_req_by.Org_Id = request.Org_Id
			WHERE request.Org_Id = var_Org_Id
			AND FIND_IN_SET(request.Is_Approved, @ApprovalStatus_Id)
			AND CAST(request.Request_Date AS DATE) BETWEEN STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y')
			AND STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y')
			AND request.Request_For = var_Request_For
			ORDER BY request.Request_Id;
            
	END;
    
	ELSEIF (var_Method_Name = 'Get_One') THEN
    BEGIN
		
		SELECT
				request.Org_Id, request.Request_Id, request.Request_For,
				request.Request_For_User_Id, request.Request_By, request.Request_By_User_Id,
				DATE_FORMAT(request.Request_Date, '%Y-%m-%d') AS Request_Date, 
                request.Is_Approved, request.Approval_Remarks, 
                incentivescheme.IncentiveScheme_Id AS IncentiveScheme_Id, 
				incentivescheme.Scheme_Name AS Scheme_Name 
			FROM t017_incentives_request request 
			INNER JOIN m011_incentivescheme incentivescheme ON incentivescheme.IncentiveScheme_Id = request.IncentiveScheme_Id
				and incentivescheme.Org_Id = request.Org_Id
			WHERE request.Org_Id = var_Org_Id
            AND request.Request_Id = var_Request_Id
			AND request.Request_For = var_Request_For;
    
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
