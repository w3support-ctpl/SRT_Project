-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminSalesUser_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminSalesUser_Set`(
	var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_User_Id VARCHAR(20),
    var_User_Name VARCHAR(20),
    var_Is_Active INT,
    var_Is_Deleted INT,
    var_SalesUser_Id VARCHAR(20),
    var_SalesArea_Id VARCHAR(20),
    var_SalesUser_Name VARCHAR(45),
    var_SalesUser_Code VARCHAR(20),
    var_SAP_BP_Partner_Code VARCHAR(20),
    var_Mobile_No VARCHAR(20),
    var_Joining_Date VARCHAR(20),
    var_Email_Id VARCHAR(45),
    var_ReportingTo_Id VARCHAR(20),
    var_SalesUserRole_Id VARCHAR(20),
    var_Pan_No VARCHAR(20),
    var_Aadhar_No VARCHAR(20),
    var_State_Id VARCHAR(20),
    var_District_Id VARCHAR(20),
    var_Taluka_Id VARCHAR(20),
    var_Village_Id VARCHAR(20),
    var_Address_Text LONGTEXT,
    var_Online_App_Flag INT,
    var_SalesEmployee LONGTEXT,
    var_Login_Password LONGTEXT
)
BEGIN
    -- Declare required variables
    DECLARE New_SalesUser_Id VARCHAR(20);
    DECLARE Year_Id VARCHAR(10);
    DECLARE New_Password VARCHAR(45);
    DECLARE New_Route_Id VARCHAR(20);
    
    -- Variables for route parsing loop
    DECLARE v_current_route_id VARCHAR(50);
    DECLARE v_remaining_routes LONGTEXT;

    IF(var_Method_Name = 'Create') THEN
    BEGIN
        -- Check if Mobile No exists
        IF EXISTS(SELECT SalesUser_Id FROM mu12_sales_user WHERE Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id AND Is_Deleted = 0) THEN
            SELECT -1 AS Result_Id, 'Mobile Number already exists' AS Result_Description, '' AS Result_Extra_Key;
        -- Check if Pan No exists
        ELSEIF EXISTS(SELECT SalesUser_Id FROM mu12_sales_user WHERE Pan_No = var_Pan_No AND Org_Id = var_Org_Id AND Is_Deleted = 0) THEN
            SELECT -1 AS Result_Id, 'Pan No already exists' AS Result_Description, '' AS Result_Extra_Key;
        -- Check if Aadhar No exists
        ELSEIF EXISTS(SELECT SalesUser_Id FROM mu12_sales_user WHERE Aadhar_No = var_Aadhar_No AND Org_Id = var_Org_Id AND Is_Deleted = 0) THEN
            SELECT -1 AS Result_Id, 'Aadhar No already exists' AS Result_Description, '' AS Result_Extra_Key;
        ELSE
        BEGIN
            IF (var_SalesUserRole_Id = 'C044002') THEN
                SET var_ReportingTo_Id = '';
            END IF;

            -- Generate Id
            SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
            CALL USP_Number_Range ('mu12_sales_user', Year_Id, 'MU12', '', New_SalesUser_Id );
            SET New_Password = CONCAT('Welcome@', YEAR(CURDATE()));

            -- Insert into mu12_sales_user
            INSERT INTO mu12_sales_user(
                Org_Id, SalesUser_Id, Login_Name, Login_Password, SalesUser_Name, 
                SAP_BP_Partner_Code, ReportingTo_Id, SalesUserRole_Id, Mobile_No, Email_Id, 
                Joining_Date, Address_Text, State_Id, District_Id, Taluka_Id, Village_Id,
                Pan_No, Aadhar_No, Online_App_Flag, Is_Active, Is_Deleted, 
                Created_On, CreatedBy_Id, CreatedBy_Name, SalesEmployee, SalesArea_Id
            )
            VALUES(
                var_Org_Id, New_SalesUser_Id, var_Mobile_No, var_Login_Password, var_SalesUser_Name,
                var_SAP_BP_Partner_Code, var_ReportingTo_Id, var_SalesUserRole_Id, var_Mobile_No , var_Email_Id,
                var_Joining_Date, var_Address_Text, var_State_Id, var_District_Id, var_Taluka_Id, var_Village_Id,
                var_Pan_No, var_Aadhar_No, var_Online_App_Flag, var_Is_Active, var_Is_Deleted,
                CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name, var_SalesEmployee, var_SalesArea_Id
            );

            -- --- START ROUTE INSERT LOGIC ---
          

            -- Create placeholder route headers for 7 days
            -- (Abbreviated for clarity, same logic as your original)
         /*   SET @day_count = 1;
            WHILE @day_count <= 7 DO
                CALL USP_Number_Range ('m019_salesuserroute_header', Year_Id, 'M019', '', New_Route_Id );
                INSERT INTO m019_salesuserroute_header(
                    Org_Id, Route_Id, SalesUser_Id, RouteDay_Id, Working_Status, Total_Retailers, 
                    Is_Active, Is_Deleted, Created_On, CreatedBy_Id, CreatedBy_Name, SalesArea_Id
                ) VALUES (
                    var_Org_Id, New_Route_Id, New_SalesUser_Id, CONCAT('C04500', @day_count), 0, 0, 
                    var_Is_Active, var_Is_Deleted, CONVERT_TZ(NOW(), '+00:00', '+00:00'), var_User_Id, var_User_Name, var_SalesArea_Id
                );
                SET @day_count = @day_count + 1;
            END WHILE;*/

            SELECT 1 AS Result_Id, 'Created' AS Result_Description, New_SalesUser_Id AS Result_Extra_Key;
        END;
        END IF;
    END;
    ELSEIF(var_Method_Name = 'Update') THEN
    BEGIN
		-- Check if Mobile No is already present in the table, if yes, then send error message
        IF EXISTS(
			SELECT SalesUser_Id
            FROM mu12_sales_user
            WHERE Mobile_No = var_Mobile_No
            AND Org_Id = var_Org_Id
            AND Is_Deleted = 0
            AND SalesUser_Id <> var_SalesUser_Id
        ) THEN
        BEGIN
			SELECT -1 AS Result_Id, 
			'Mobile Number already exists' AS Result_Description, 
			'' AS Result_Extra_Key;
		END;
        -- Check if Pan No is already present in the table, if yes, then send error message
        ELSEIF EXISTS(
			SELECT SalesUser_Id
            FROM mu12_sales_user
            WHERE Pan_No = var_Pan_No
            AND Org_Id = var_Org_Id
            AND Is_Deleted = 0
            AND SalesUser_Id <> var_SalesUser_Id
        ) THEN
        BEGIN
			SELECT -1 AS Result_Id, 
			'Pan No already exists' AS Result_Description, 
			'' AS Result_Extra_Key;
		END;
        -- Check if Aadhar No is already present in the table, if yes, then send error message
        ELSEIF EXISTS(
			SELECT SalesUser_Id
            FROM mu12_sales_user
            WHERE Aadhar_No = var_Aadhar_No
            AND Org_Id = var_Org_Id
            AND Is_Deleted = 0
            AND SalesUser_Id <> var_SalesUser_Id
        ) THEN
        BEGIN
			SELECT -1 AS Result_Id, 
			'Aadhar No already exists' AS Result_Description, 
			'' AS Result_Extra_Key;
		END;
        -- If no errors, then save the record in the table
        ELSE
        BEGIN
			if (var_SalesUserRole_Id = 'C044002') then
				set var_ReportingTo_Id = '';
            end if;
            
            -- Update existing record with var_SalesUser_Id in the table with provided values
            UPDATE mu12_sales_user
            SET	SalesUser_Name = var_SalesUser_Name, 
				SAP_BP_Partner_Code = var_SAP_BP_Partner_Code,
                ReportingTo_Id = var_ReportingTo_Id, 
                SalesUserRole_Id = var_SalesUserRole_Id,
                Mobile_No = var_Mobile_No,
                Email_Id = var_Email_Id, 
                Joining_Date = var_Joining_Date,
                Address_Text = var_Address_Text, 
                State_Id = var_State_Id,
                District_Id = var_District_Id,
                Taluka_Id = var_Taluka_Id,
                Village_Id = var_Village_Id,
                Pan_No = var_Pan_No,
                Aadhar_No = var_Aadhar_No,
                Online_App_Flag = var_Online_App_Flag, 
                Is_Active = var_Is_Active, 
                Is_Deleted = var_Is_Deleted, 
                LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
                LastEditedBy_Id = var_User_Id, 
                LastEditedBy_Name = var_User_Name,
                SalesEmployee = var_SalesEmployee,
                Login_Password = var_Login_Password,
                SalesArea_Id	= var_SalesArea_Id
            WHERE Org_Id = var_Org_Id
            AND SalesUser_Id = var_SalesUSer_Id;
            
           
           
            -- Send Success Message
            SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			 var_SalesUser_Id AS Result_Extra_Key;
        END;
        END IF;
    END;
    -- To delete Record in the table with Sales USer Id as provided
    ELSEIF(var_Method_Name = 'Delete') THEN
    BEGIN
		UPDATE mu12_sales_user
        SET
			Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
		WHERE Org_Id = var_Org_Id
        AND SalesUser_Id = var_SalesUser_Id;
        
        -- Send Success Message
            SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_SalesUser_Id AS Result_Extra_Key;
    END;
    -- To update Sales User Code
    ELSEIF(var_Method_Name = 'UpdateSalesUserCode') THEN
    BEGIN
		UPDATE mu12_sales_user
        SET SalesUser_Code = var_SalesUser_Code
        WHERE Org_Id = var_Org_Id
		AND SalesUser_Id = var_SalesUSer_Id;
            
		-- Send Success Message
		SELECT 1 AS Result_Id, 
		'Updated' AS Result_Description, 
		var_SalesUser_Id AS Result_Extra_Key; 
    END;
	END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
