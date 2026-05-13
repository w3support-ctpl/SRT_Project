-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSurvey_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSurvey_Get`(
	var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_User_Id VARCHAR(20),
    var_Date VARCHAR(60),
    var_Survey_Id VARCHAR(20)
)
BEGIN

	-- to restrict past Applicable Date from updating and locking values
        DECLARE Today_Date DATETIME;
            SET Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
			-- converting DATETIME to DATE
            SET Today_Date = CAST(Today_Date AS DATE);

	-- getting all records from the survey header table
	IF(var_Method_Name = 'Get') THEN
    BEGIN
    
		-- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
        
        -- select records between start date and end date
        SELECT survey.Org_Id, survey.Survey_Id, chemist.Chemist_Name, survey.Assign, survey.Conducted, 
				survey.Is_Active, survey.Is_Deleted,
				DATE_FORMAT(survey.Applicable_Date, '%d %M %Y') as Applicable_Date,
                CASE 
					WHEN survey.Applicable_Date < Today_Date THEN 1
					ELSE 0
				END AS Is_Locked
		FROM t025_survey_header survey
        INNER JOIN mu07_routechemist chemist
			ON survey.chemist_id = chemist.chemist_id
				and survey.Org_Id = chemist.Org_Id
        WHERE 	survey.Org_Id = var_Org_Id 
            AND chemist.Org_Id = var_Org_Id
			AND survey.Is_Deleted = 0 
			AND chemist.Is_Deleted = 0
			AND CAST(survey.Applicable_Date  AS DATE) >= var_StartDate 
            AND CAST(survey.Applicable_Date  AS DATE) <= var_EndDate
		ORDER BY survey.Survey_Id;
        
		-- Get Method End
    END;
    END IF;
    
    -- get one record from survey header and related records from survey item table
    IF(var_Method_Name = 'Get_One') THEN
    BEGIN
		
    
    
    
		SELECT Org_Id, Survey_Id, Chemist_Id, Is_Active, Is_Deleted,
				DATE_FORMAT(Applicable_Date, '%Y-%m-%d') as Applicable_Date,
                CASE 
					WHEN Applicable_Date < Today_Date THEN 1
					ELSE 0
				END AS Is_Locked
		FROM t025_survey_header
        WHERE 	Survey_Id = var_Survey_Id
            AND Org_Id = var_Org_Id
            AND Is_Deleted = 0
		ORDER BY Survey_Id;
            
        -- Get_One Method End
    END;
    END IF;
    
    -- getting max date in survey header table
    IF(var_Method_Name = 'Get_Date') THEN
	BEGIN
		-- SELECT DATE_FORMAT(MAX(CAST(Applicable_Date AS DATE)), '%Y-%m-%d') as Applicable_Date
		SELECT DATE_FORMAT(MAX(CAST(Applicable_Date AS DATE)),'%Y-%m-%d') as Applicable_Date
		FROM t025_survey_header
		WHERE 	Org_Id = var_Org_Id
			AND Is_Deleted = 0;
		-- ORDER BY Applicable_Date DESC
		-- LIMIT 1;
        
    END;
    END IF;
    
    -- getting the list of mcc
    IF(var_Method_Name = 'Get_MCCList') THEN
    BEGIN
		-- All MCC for New survey
		IF(ISNULL(var_Survey_Id)) THEN
        BEGIN
			-- all active mcc from mcc table, also taluka name and village name from respective tables
            -- depending on taluka id and village id
			SELECT  mcc.MCC_Id, mcc.MCC_Code, mcc.MCC_Name,
					taluka.Taluka_Id, taluka.Taluka_Name,
					village.Village_Id, village.Village_Name
			FROM m005_mcc mcc
			INNER JOIN ml04_taluka taluka 
				ON taluka.Taluka_Id = mcc.Taluka_Id 
                and  taluka.Org_Id = mcc.Org_Id 
            INNER JOIN ml05_village village 
				ON village.Village_Id = mcc.Village_Id
                and  village.Org_Id = mcc.Org_Id 
			WHERE 	mcc.Org_Id = var_Org_Id
				AND mcc.Is_Deleted = 0
				AND mcc.Is_Active = 1
			ORDER BY MCC_Id;
          -- End of All MCC for new survey                            
        END;
        
        -- All MCC for existing survey
        ELSE
        BEGIN
			-- all active, not deleted mcc from mcc table, also taluka name and village name from respective tables
            -- depending on taluka id and village id
            -- set is_locked = 1 for mcc present in survey_item table
            -- where survey_id = var_survey_id
			SELECT  mcc.MCC_Id, mcc.MCC_Code, mcc.MCC_Name,
					taluka.Taluka_Id, taluka.Taluka_Name,
					village.Village_Id, village.Village_Name,
                    CASE 
						WHEN s_item.MCC_Id IS NOT NULL THEN 1
						ELSE 0
					END AS Is_Locked
			FROM m005_mcc mcc
			INNER JOIN ml04_taluka taluka 
				ON taluka.Taluka_Id = mcc.Taluka_Id 
                and taluka.Org_Id = mcc.Org_Id 
            INNER JOIN ml05_village village 
				ON village.Village_Id = mcc.Village_Id
                and village.Org_Id = mcc.Org_Id 
			LEFT JOIN t025_survey_item s_item 
				ON mcc.MCC_Id = s_item.MCC_Id
				AND s_item.Org_Id = mcc.Org_Id
				AND s_item.Survey_Id = var_Survey_Id
			WHERE mcc.Org_Id = var_Org_Id
				AND mcc.Is_Deleted = 0
				AND mcc.Is_Active = 1
			ORDER BY MCC_Id;
            
            -- End of All MCC for existing survey
        END;
        END IF;
    END;
    END IF;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
