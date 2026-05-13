-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFarmerDataCorrection_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFarmerDataCorrection_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Date varchar(60),
    var_ApprovalStatus_Id varchar(20),
    var_Request_Id varchar(20)
)
BEGIN
	SET @ApprovalStatus_Id = var_ApprovalStatus_Id;
	IF((var_ApprovalStatus_Id = '') OR (var_ApprovalStatus_Id IS NULL)) THEN
    BEGIN
		SET @ApprovalStatus_Id := '0,1,-1';
    END;
    END IF;
    
	-- getting all records within given search period and given approval status
	IF(var_Method_Name = 'Get') THEN
    BEGIN
		SELECT request.Org_Id, request.Request_Id,  
			   request.Request_Type, farmer.Farmer_Name, farmer.Mobile_No,
               request.Is_Approved, village.Village_Name,
               DATE_FORMAT(request.Request_Date, '%d %M %Y') AS Request_Date,
               DATE_FORMAT(request.Approved_On, '%d %M %Y') AS Approved_On
		FROM t026_farmerdatacorrection_request request
        INNER JOIN mu04_farmer farmer
        ON request.Request_For_User_Id = farmer.Farmer_Id and request.Org_Id = farmer.Org_Id
        INNER JOIN ml05_village village
        ON farmer.Village_Id = village.Village_Id and farmer.Org_Id = village.Org_Id
        WHERE request.Org_Id = var_Org_Id
		AND farmer.Org_Id = var_Org_Id
		AND village.Org_Id = var_Org_Id
		AND FIND_IN_SET(request.Is_Approved, @ApprovalStatus_Id)
			-- OR var_ApprovalStatus_Id = '%%')
        -- AND request.Is_Approved LIKE var_ApprovalStatus_Id
		AND CAST(request.Request_Date AS DATE)
			BETWEEN STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y')
			AND STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y')
        ORDER BY request.Request_Id;
        
    END;
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
		SELECT request.Org_Id, request.Request_Id, request.Is_Approved, request.Approval_Remarks,
			   farmer.Farmer_Name, DATE_FORMAT(farmer.Birth_Date, '%d %M %Y') AS Birth_Date, farmer.Mobile_No,
               farmer.Email_Id, farmer.MCC_Id, farmer.Pan_No, farmer.Aadhar_No,
               farmer.AlternateMobile_No, farmer.Bank_Id, farmer.Branch_Id, 
               farmer.IFSC_Code, farmer.Account_Name, farmer.Account_No, 
               farmer.Nominee_Name, farmer.Nominee_Relation, 
               farmer.Nominee_Mobile_No, farmer.Nominee_Aadhar_No, request.Request_Data,
               request.Request_For_User_Id AS Farmer_Id
        FROM t026_farmerdatacorrection_request request
        INNER JOIN mu04_farmer farmer
        ON farmer.Farmer_Id = request.Request_For_User_Id and farmer.Org_Id = request.Org_Id
        -- INNER JOIN m005_mcc mcc
        -- ON mcc.MCC_Id = farmer.MCC_Id
        -- INNER JOIN m015_bank bank
        -- ON farmer.Bank_Id = bank.Bank_Id
        -- INNER JOIN m016_branch branch
        -- ON farmer.Branch_Id = branch.Branch_Id
        WHERE request.Org_Id = var_Org_Id
		AND farmer.Org_Id = var_Org_Id
        -- AND mcc.Org_Id = var_Org_Id
        AND request.Request_Id = var_Request_Id;
              
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
