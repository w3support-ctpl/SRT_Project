-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminManageAgentIncentiveSchemes_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminManageAgentIncentiveSchemes_Get`(
	var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_User_Id VARCHAR(20),
    var_IncentiveStatus_Id VARCHAR(20),
    var_Scheme_Period LONGTEXT,
    var_IncentiveScheme_Id VARCHAR(20)
)
BEGIN
	IF(var_Method_Name = 'Get') THEN
    BEGIN
		
		-- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Scheme_Period, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Scheme_Period, ' - ', -1), '%m/%d/%Y');
		
        
		SELECT incentive.Org_Id, incentive.IncentiveScheme_Id, incentive.Scheme_Name, 
			itype.IncentiveType_Id, itype.IncentiveType_Name,
            incentive.IncentiveFrequency_Id, incentive.Criteria, 
            incentive.Scheme_Description, incentive.Is_Active, incentive.Is_Completed,
			CONCAT(DATE_FORMAT(incentive.From_Date,'%d %M %Y'),
					' to ', 
					DATE_FORMAT(incentive.To_Date,'%d %M %Y')) 
			AS Scheme_Duration
		FROM m011_incentivescheme incentive
        LEFT JOIN c025_incentivetype itype
			ON incentive.IncentiveType_Id = itype.IncentiveType_Id
		WHERE incentive.Is_For_Agent = 1
        AND incentive.Is_Deleted = 0
        AND incentive.Org_Id = var_Org_Id
        AND CASE WHEN var_IncentiveStatus_Id = '2' THEN incentive.Is_Completed=1
				WHEN var_IncentiveStatus_Id IS NULL THEN TRUE
				ELSE incentive.Is_Active = var_IncentiveStatus_Id AND incentive.Is_Completed=0
			END
        AND CAST(incentive.From_Date AS DATE) >= var_StartDate 
		AND CAST(incentive.To_Date AS DATE) <= var_EndDate
        ORDER BY incentive.From_Date;
    END;
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
		SELECT incentive.Org_Id, incentive.IncentiveScheme_Id, incentive.Scheme_Name, 
			itype.IncentiveType_Id, itype.IncentiveType_Name, 
            ifrequency.IncentiveFrequency_Id, ifrequency.IncentiveFrequency_Name,
            incentive.Criteria, incentive.Scheme_Description, 
            DATE_FORMAT(incentive.From_Date,'%d %M %Y') AS From_Date, 
            DATE_FORMAT(incentive.To_Date,'%d %M %Y') AS To_Date, 
            incentive.Photo, incentive.Is_Active, incentive.Is_Deleted, incentive.Is_Completed,
            CASE incentive.Is_Completed
				WHEN 1 THEN 'Completed'
                ELSE
					CASE incentive.Is_Active
						WHEN 1 THEN 'Active'
                        ELSE 'In-Active'
                    END
            END AS Scheme_Status
		FROM m011_incentivescheme incentive
        LEFT JOIN c025_incentivetype itype
			ON incentive.IncentiveType_Id = itype.IncentiveType_Id
		LEFT JOIN c026_incentivefrequency ifrequency
			ON incentive.IncentiveFrequency_Id = ifrequency.IncentiveFrequency_Id
		WHERE incentive.Is_For_Agent = 1
        AND incentive.Is_Deleted = 0
        AND incentive.Org_Id = var_Org_Id
        AND incentive.IncentiveScheme_Id = var_IncentiveScheme_Id;
    END;
    ELSEIF(var_Method_Name = 'Get_Agents') THEN
    BEGIN
		SELECT Agent.Agent_Id, mcc.MCC_Id, mcc.MCC_Name, 
			Agent.Agent_name,
			'Eligible' AS Eligibility
        FROM t017_incentives_request request
        LEFT JOIN mu05_Agent Agent
			ON request.Request_For_User_Id = Agent.Agent_Id
            AND request.Org_Id = Agent.Org_Id
		LEFT JOIN m005_mcc mcc
			ON mcc.Agent_Id = Agent.Agent_Id
            AND mcc.Org_Id = Agent.Org_Id
		WHERE request.Request_For = 'Agent'
        AND request.Org_Id = var_Org_Id
        AND request.IncentiveScheme_Id = var_IncentiveScheme_Id
        AND request.Is_Approved = 1
        AND Agent.Is_Deleted = 0;
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
