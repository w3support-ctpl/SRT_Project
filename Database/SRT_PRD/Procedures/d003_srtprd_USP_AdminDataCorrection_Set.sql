-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDataCorrection_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDataCorrection_Set`(
	var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_User_Id VARCHAR(20),
    var_User_Name VARCHAR(45),
    var_ApprovalStatus_Id INT,
    var_Request_Id VARCHAR(20),
    var_Request_Type VARCHAR(20),
    var_Request_Data LONGTEXT,
    var_Approval_Remarks LONGTEXT,
    -- values requsted to be updated
    -- mobile number
    var_Mobile_No VARCHAR(20),
    -- bank details
    var_Bank_Id VARCHAR(20),
    var_Branch_Id VARCHAR(20),
    var_Account_Name VARCHAR(45),
    var_Account_No VARCHAR(45),
    var_IFSC_Code VARCHAR(20),
    -- nominee details
    var_Nominee_Name VARCHAR(45),
    var_NomineeRelation_Id VARCHAR(20),
    var_Nominee_Mobile_No VARCHAR(20),
    var_Nominee_Aadhar_No VARCHAR(20),
	var_Request_For VARCHAR(20)
)
BEGIN        
	IF(var_Method_Name = 'Update') THEN
    BEGIN
		-- to update mobile number in farmer
		IF(var_Request_Type = 'MobileNo') THEN
        BEGIN
			-- to approve
            IF(var_ApprovalStatus_Id = 1) THEN
            BEGIN
				-- Farmer Mobile Number Update
				IF(var_Request_For = 'Farmer') THEN
                BEGIN
					 IF EXISTS(
						SELECT Farmer_Id 
                        FROM mu04_farmer
                        WHERE Org_Id = var_Org_Id 
                        AND Mobile_No = var_Mobile_No
                        AND Is_Deleted = 0) THEN
							SELECT -1 AS Result_Id, 
							'Mobile Number already exists' AS Result_Description, 
							'' AS Result_Extra_Key;
					ELSE
						UPDATE mu04_farmer
						SET Mobile_No = var_Mobile_No,
						Login_Name = var_Mobile_No
						WHERE Org_Id = var_Org_Id
						AND Farmer_ID =  (SELECT Request_For_User_Id
											FROM t026_datacorrection_request
											WHERE Request_Id = var_Request_Id);
                    END IF;
					
                END;
                -- Agent Mobile Number Update
				ELSEIF(var_Request_For = 'Agent') THEN
                BEGIN
					IF EXISTS(
						SELECT Agent_Id 
                        FROM mu05_agent
                        WHERE Org_Id = var_Org_Id 
                        AND Mobile_No = var_Mobile_No
                        AND Is_Deleted = 0) THEN
							SELECT -1 AS Result_Id, 
							'Mobile Number already exists' AS Result_Description, 
							'' AS Result_Extra_Key;
					ELSE
						UPDATE mu05_agent
						SET Mobile_No = var_Mobile_No,
						Login_Name = var_Mobile_No
						WHERE Org_Id = var_Org_Id
						AND Agent_ID =  (SELECT Request_For_User_Id
											FROM t026_datacorrection_request
											WHERE Request_Id = var_Request_Id);
                    END IF;
                END;
                END IF;
                
				
            END;
            END IF;
        
        END;
        -- to update Nominee Details
        ELSEIF(var_Request_Type = 'Nominee') THEN
        BEGIN
			-- to approve
            IF(var_ApprovalStatus_Id = 1) THEN
            BEGIN
				UPDATE mu04_farmer
                SET Nominee_Name = var_Nominee_Name,
					Nominee_Relation = var_NomineeRelation_Id,
                    Nominee_Mobile_No = var_Nominee_Mobile_No,
                    Nominee_Aadhar_No = var_Nominee_Aadhar_No
                WHERE Org_Id = var_Org_Id
                AND  Farmer_ID =  (SELECT Request_For_User_Id
									FROM t026_datacorrection_request
                                    WHERE Request_Id = var_Request_Id);
            END;
            END IF;
        END;
        ELSEIF(var_Request_Type = 'BankDetails') THEN
        BEGIN
			-- to approve
            IF(var_ApprovalStatus_Id = 1) THEN
            BEGIN
				UPDATE mu04_farmer
                SET Bank_Id = var_Bank_Id,
					Branch_Id = var_Branch_Id,
                    IFSC_Code = var_IFSC_Code,
                    Account_No = var_Account_No,
                    Account_Name = var_Account_Name
				WHERE Org_Id = var_Org_Id
                AND Farmer_ID =  (SELECT Request_For_User_Id
									FROM t026_datacorrection_request
                                    WHERE Request_Id = var_Request_Id);
            END;
            END IF;
        END;
        END IF;
        -- done updating tables
		UPDATE t026_datacorrection_request 
		SET 
			Is_Approved = var_ApprovalStatus_Id,
			Request_Data = var_Request_Data,
			Approval_Remarks = var_Approval_Remarks,
			Approved_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
			Approved_Id = var_User_Id,
			Approved_Name = var_User_Name
		WHERE Request_Id = var_Request_Id
		AND Request_For = var_Request_For
		AND Org_Id = var_Org_Id;
				
		IF(var_ApprovalStatus_Id = '1') THEN
		BEGIN
			SELECT 1 AS Result_Id, 
			'Approved' AS Result_Description, 
			var_Request_Id AS Result_Extra_Key;
		END;
		ELSEIF(var_ApprovalStatus_Id = '-1') THEN
		BEGIN
			SELECT 1 AS Result_Id, 
			'Rejected' AS Result_Description, 
			var_Request_Id AS Result_Extra_Key;
		END;
		ELSE
		BEGIN
			SELECT -1 AS Result_Id, 
			'Failed' AS Result_Description, 
			var_Request_Id AS Result_Extra_Key;
		END;
		END IF;
				
	END;
	END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
