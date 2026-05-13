-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminComplaint_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminComplaint_Get`(
	 var_Org_Id VARCHAR(10),
     var_Method_Name VARCHAR(20),
     var_User_Id VARCHAR(20),
     var_Complaint_Id VARCHAR(20),
     var_ComplaintType_Id VARCHAR(20),
     var_ComplaintStatus_Id VARCHAR(20),
     var_Complaint_Period VARCHAR(45)
)
BEGIN
	IF(var_Method_Name = 'Get') THEN
    BEGIN
		-- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Complaint_Period, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Complaint_Period, ' - ', -1), '%m/%d/%Y');
		

		-- setting values in case ComplaintType_Id is not provided
		SET @NewComplaintType_Id = var_ComplaintType_Id;
		IF((var_ComplaintType_Id = '') OR (var_ComplaintType_Id IS NULL)) THEN
		BEGIN
			SET @NewComplaintType_Id := (
				SELECT GROUP_CONCAT(ComplaintType_Id)
				FROM c034_complainttype
			);
		END;
		END IF;
		
		-- setting values in case ComplaintStatus_Id is not provided
		SET @NewComplaintStatus_Id = var_ComplaintStatus_Id;
		IF((var_ComplaintStatus_Id = '') OR (var_ComplaintStatus_Id IS NULL)) THEN
		BEGIN
			SET @NewComplaintStatus_Id := (
				SELECT GROUP_CONCAT(ComplaintStatus_Id)
				FROM c035_complaintstatus
			);
		END;
		END IF;
    
    
    
		SELECT complaint.Org_Id, 
			complaint.Complaint_Id, 
			ctype.ComplaintType_Id, ctype.ComplaintType_Name, 
            complaint.Complaint_Remark, 
            complaint.Complaint_For, 
            IFNULL(
				CASE complaint.Complaint_For
					WHEN 'dealer' THEN dealer.Dealer_Id
                    WHEN 'salesuser' THEN salesuser.SalesUser_Id
				END, '') AS Complaint_For_User_Id,
			IFNULL(
				CASE complaint.Complaint_For
					WHEN 'dealer' THEN dealer.Dealer_Name
                    WHEN 'salesuser' THEN salesuser.SalesUser_Name
				END, '') AS Complaint_For_User_Name,
			complaint.Complaint_By, 
			IFNULL(
				CASE complaint.Complaint_By
					WHEN 'dealer' THEN dealer.Dealer_Id
                    WHEN 'salesuser' THEN salesuser.SalesUser_Id
				END, ''
            ) AS Complaint_By_User_Id,
			IFNULL(
				CASE complaint.Complaint_By
					WHEN 'dealer' THEN dealer.Dealer_Name
                    WHEN 'salesuser' THEN salesuser.SalesUser_Name
				END, ''
            ) AS Complaint_By_User_Name,
            complaint.Complaint_Date, 
            DATE_FORMAT(complaint.Complaint_Date, '%d %M %Y') AS Formatted_Complaint_Date,
            cstatus.ComplaintStatus_Id, cstatus.ComplaintStatus_Name, 
            IFNULL(complaint.Closing_Date, '') AS Closing_Date,
            IFNULL(DATE_FORMAT(complaint.Closing_Date, '%d %M %Y'), '') AS Formatted_Closing_Date,
            IFNULL(
				CASE complaint.ComplaintStatus_Id
                WHEN ('C035004' || 'C035005') THEN 1
                ELSE 0
                END, '') AS Is_Closed
        FROM t037_sales_complaint_header complaint
        LEFT JOIN c035_complaintstatus cstatus 
			ON complaint.ComplaintStatus_Id = cstatus.ComplaintStatus_Id
		LEFT JOIN c034_complainttype ctype
			ON ctype.ComplaintType_Id = complaint.ComplaintType_Id
        LEFT JOIN mu12_sales_user salesuser
			ON	salesuser.SalesUser_Id = complaint.Complaint_For_User_Id
            AND salesuser.Org_Id = complaint.Org_Id
		LEFT JOIN mu08_dealer dealer
			ON dealer.Dealer_Id = complaint.Complaint_For_User_Id
            AND dealer.Org_Id = complaint.Org_Id
		WHERE complaint.Org_Id = var_Org_Id
        AND FIND_IN_SET(complaint.ComplaintType_Id, @NewComplaintType_Id)
        AND FIND_IN_SET(complaint.ComplaintStatus_Id, @NewComplaintStatus_Id)
		AND CAST(complaint.Complaint_Date AS DATE) >= var_StartDate 
		AND CAST(complaint.Complaint_Date AS DATE) <= var_EndDate
        ORDER BY Complaint_Date DESC;
        
        
        
    END;
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
    
		SELECT complaint.Org_Id, 
			complaint.Complaint_Id, 
			ctype.ComplaintType_Id, ctype.ComplaintType_Name, 
            complaint.Complaint_Remark, 
            complaint.Complaint_For, 
            IFNULL(
				CASE complaint.Complaint_For
					WHEN 'dealer' THEN dealer.Dealer_Id
                    WHEN 'salesuser' THEN salesuser.SalesUser_Id
				END, '') AS Complaint_For_User_Id,
			IFNULL(
				CASE complaint.Complaint_For
					WHEN 'dealer' THEN dealer.Dealer_Name
                    WHEN 'salesuser' THEN salesuser.SalesUser_Name
				END, '') AS Complaint_For_User_Name,
			complaint.Complaint_By, 
			IFNULL(
				CASE complaint.Complaint_By
					WHEN 'dealer' THEN dealer.Dealer_Id
                    WHEN 'salesuser' THEN salesuser.SalesUser_Id
				END, ''
            ) AS Complaint_By_User_Id,
			IFNULL(
				CASE complaint.Complaint_By
					WHEN 'dealer' THEN dealer.Dealer_Name
                    WHEN 'salesuser' THEN salesuser.SalesUser_Name
				END, ''
            ) AS Complaint_By_User_Name,
            complaint.Complaint_Date, 
            DATE_FORMAT(complaint.Complaint_Date, '%d %M %Y') AS Formatted_Complaint_Date,
            cstatus.ComplaintStatus_Id, cstatus.ComplaintStatus_Name, 
            IFNULL(complaint.Closing_Date, '') AS Closing_Date,
            IFNULL(DATE_FORMAT(complaint.Closing_Date, '%d %M %Y'), '') AS Formatted_Closing_Date,
            IFNULL(
				CASE complaint.ComplaintStatus_Id
                WHEN ('C035004' || 'C035005') THEN 1
                ELSE 0
                END, '') AS Is_Closed
        FROM t037_sales_complaint_header complaint
        LEFT JOIN c035_complaintstatus cstatus 
			ON complaint.ComplaintStatus_Id = cstatus.ComplaintStatus_Id
		LEFT JOIN c034_complainttype ctype
			ON ctype.ComplaintType_Id = complaint.ComplaintType_Id
        LEFT JOIN mu12_sales_user salesuser
			ON	salesuser.SalesUser_Id = complaint.Complaint_For_User_Id
            AND salesuser.Org_Id = complaint.Org_Id
		LEFT JOIN mu08_dealer dealer
			ON dealer.Dealer_Id = complaint.Complaint_For_User_Id
            AND dealer.Org_Id = complaint.Org_Id
		WHERE complaint.Org_Id = var_Org_Id
        AND complaint.Complaint_Id = var_Complaint_Id;
    
    END;
    ELSEIF(var_Method_Name = 'Get_Item') THEN
    BEGIN
    
		SELECT complaint.Org_Id, complaint.Complaint_Id, 
			complaint.Entry_Id, 
            DATE_FORMAT(complaint.Action_Date, '%d %M %Y') AS Action_Date, 
			complaint.Action_By_Id, complaint.Action_By_Name, 
			complaint.Remarks, complaint.Is_Display, 
            complaint.New_Status_Id, cstatus.ComplaintStatus_Name AS New_Status_Name
		FROM t037_sales_complaint_item complaint
        LEFT JOIN c035_complaintstatus cstatus 
			ON complaint.New_Status_Id = cstatus.ComplaintStatus_Id
        WHERE Complaint_Id = var_Complaint_Id;
    
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
