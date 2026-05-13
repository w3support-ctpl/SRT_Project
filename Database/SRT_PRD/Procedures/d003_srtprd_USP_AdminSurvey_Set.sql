-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSurvey_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSurvey_Set`(
	var_Method_Name VARCHAR(20),
	var_Org_Id VARCHAR(10),
	var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(45),
    var_Survey_Id VARCHAR(20),
	var_Applicable_Date DATETIME,
    var_Assign INT,
	var_Chemist_Id VARCHAR(20) ,
	var_MCC_Id LONGTEXT,
	var_Is_Active INT,
	var_Is_Deleted INT
)
BEGIN

	-- -------------------------------------------------------------------------------------

	IF(var_Method_Name = 'Create') THEN
	BEGIN
    
		-- to generate new Survey Id (Primary key for table)
        DECLARE New_Survey_Id VARCHAR(20);
        DECLARE Year_Id VARCHAR(10);
		
		-- storing mcc IDs in a array
        DECLARE mccArray LONGTEXT;
        
        -- to save in DB and check available Applicable Date
        DECLARE Today_Date DATETIME;
            SET Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            -- converting DATETIME to DATE
            SET Today_Date = CAST(Today_Date AS DATE);
            
		-- validate provided Applicable Date
        -- if applicable date is less than current date
        IF (var_Applicable_Date < Today_Date) THEN
        BEGIN
			SELECT -1 AS Result_Id, 
			'Applicable Date must be greater than current date and time' AS Result_Description, 
			'' AS Result_Extra_Key;
		END;
        
        -- if applicable date already exists in table
		ELSEIF EXISTS(
			SELECT Survey_Id 
            FROM t025_survey_header
            WHERE Org_Id = var_Org_Id 
			AND Applicable_Date = var_Applicable_Date) THEN
		BEGIN
				SELECT -1 AS Result_Id, 
				'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
		END;
        
        -- save record/entry
        ELSE
        BEGIN
			
            -- generating Primary Key value for header table
            SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
				CALL USP_Number_Range ('t025_survey_header', Year_Id, 'T025', '', New_Survey_Id );
                
            
            -- insert values in parent(header) table
            INSERT INTO t025_survey_header(
				Org_Id,
                Survey_Id,
                Chemist_Id,
                Applicable_Date,
                Assign,
                Is_Active,
                Is_Deleted,
                Created_On,
                CreatedBy_Id,
                CreatedBy_Name
            )
            VALUES(
				var_Org_Id,
                New_Survey_Id,
                var_Chemist_Id,
                var_Applicable_Date,
                var_Assign,
                var_Is_Active,
                var_Is_Deleted,
                Now(), 
                var_User_Id,
                var_User_Name
            );
            
            -- insert values in child(item) table
            SET mccArray = var_MCC_Id;
			WHILE LENGTH(mccArray) > 0 DO
				SET @value = SUBSTRING_INDEX(mccArray, ',', 1);
				INSERT INTO t025_survey_item (
					Org_Id, 
					Survey_Id, 
					MCC_Id
                )
				VALUES (
					var_Org_Id,
                    New_Survey_Id,
                    @value
				);
				SET mccArray = SUBSTRING(mccArray, LENGTH(@value) + 2);
			END WHILE;
            
            SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Survey_Id AS Result_Extra_Key;
        END;
        END IF;
        
	END;
    -- END IF;
    
    -- -------------------------------------------------------------------------------------
    
    ELSEIF(var_Method_Name = 'Update') THEN
    BEGIN
		-- storing mcc IDs in a array
        DECLARE mccArray LONGTEXT;
        
        -- to save in DB and check available Applicable Date
        DECLARE Today_Date DATETIME;
            SET Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            -- converting DATETIME to DATE
            SET Today_Date = CAST(Today_Date AS DATE);
            
		-- validate provided Applicable Date
        -- if applicable date is less than current date
        IF (var_Applicable_Date < Today_Date) THEN
        BEGIN
			SELECT -1 AS Result_Id, 
			'Applicable Date must be greater than current date and time' AS Result_Description, 
			'' AS Result_Extra_Key;
		END;
        
        -- if applicable date already exists in table
		ELSEIF EXISTS(
			SELECT Survey_Id 
            FROM t025_survey_header
            WHERE Org_Id = var_Org_Id 
			AND Applicable_Date = var_Applicable_Date
            AND Survey_Id <> var_Survey_Id) THEN
		BEGIN
				SELECT -1 AS Result_Id, 
				'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
		END;
        
        -- save record/entry
        ELSE
        BEGIN
            
            -- update values in parent(header) table
            UPDATE t025_survey_header
			SET Applicable_Date = var_Applicable_Date,
				Chemist_Id = var_Chemist_Id,
                Assign = var_Assign,
				Is_Active = var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = Now(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
            WHERE Org_Id = var_Org_Id
				AND Survey_Id = var_Survey_Id;
            
            -- Delete data from child (item) table to store new values
			DELETE FROM t025_survey_item
			WHERE Org_Id = var_Org_Id
			AND Survey_Id = var_Survey_Id;
           
            
            -- insert values in child(item) table
            SET mccArray = var_MCC_Id;
			WHILE LENGTH(mccArray) > 0 DO
				SET @value = SUBSTRING_INDEX(mccArray, ',', 1);
				INSERT INTO t025_survey_item (
					Org_Id, 
					Survey_Id, 
					MCC_Id
                )
				VALUES (
					var_Org_Id,
                    var_Survey_Id,
                    @value
				);
				SET mccArray = SUBSTRING(mccArray, LENGTH(@value) + 2);
			END WHILE;
            
            SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Survey_Id AS Result_Extra_Key;
        END;
        END IF;
        
	END;
    -- END IF;
    
	-- -------------------------------------------------------------------------------------
    
    ELSEIF(var_Method_Name = 'Delete') THEN
    BEGIN
		
        -- Delete data from child (item) table
        DELETE FROM t025_survey_item
        WHERE Org_Id = var_Org_Id
        AND Survey_Id = var_Survey_Id;
        
        -- Delete data from parent (header) table
        DELETE FROM t025_survey_header
        WHERE Org_Id = var_Org_Id
        AND Survey_Id = var_Survey_Id;
        
        -- Send success message
        SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Survey_Id AS Result_Extra_Key;
        
	END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
