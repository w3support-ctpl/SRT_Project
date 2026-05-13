-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminRetailerAuthorization_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminRetailerAuthorization_Get`(
	var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_User_Id VARCHAR(20),
    var_SalesUser_Id VARCHAR(20),
    var_ApprovalStatus_Id VARCHAR(20),
    var_Request_Period VARCHAR(45),
    var_Retailer_Id VARCHAR(20)
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
        
			-- to check record between given date range
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Request_Period, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Request_Period, ' - ', -1), '%m/%d/%Y');
            
			-- extract records of retailer based on provided values
			SELECT 
				retailer.Retailer_Id, 
                retailer.Retailer_Name,
				salesarea.SalesArea_Id, 
                salesarea.SalesArea_Name, 
                salesuser.SalesUser_Id, 
                salesuser.SalesUser_Name, 
				dealer.Dealer_Id, 
                dealer.Dealer_Name,
                DATE_FORMAT(retailer.Created_On, '%d %M %Y') AS Created_On
            FROM mu09_retailer retailer
			LEFT JOIN m013_salesarea salesarea
				ON salesarea.SalesArea_Id = retailer.SalesArea_Id
				AND salesarea.Org_Id = retailer.Org_Id
			LEFT JOIN mu12_sales_user salesuser
				ON salesuser.SalesUser_Id = retailer.SalesUser_Id
                AND salesuser.Org_Id = retailer.Org_Id
            LEFT JOIN mu08_dealer dealer
				ON dealer.Dealer_Id = retailer.Dealer_Id 
				AND  dealer.Org_Id = retailer.Org_Id 
            WHERE retailer.Org_Id = var_Org_Id
            AND retailer.Is_Deleted = 0 
            AND (FIND_IN_SET(retailer.Is_Approved, @ApprovalStatus_Id)
				OR (CAST(retailer.Created_On AS DATE) >= var_StartDate 
				AND CAST(retailer.Created_On AS DATE) <= var_EndDate)
				OR retailer.SalesUser_Id LIKE var_SalesUser_Id_Id)
            ORDER BY retailer.Created_On;
		END;
	ELSEIF (var_Method_Name = 'Get_One') THEN
		BEGIN
			SELECT Retailer_Id, Retailer_Name, 
				SalesArea_Id, SalesUser_Id, Dealer_Id, Mobile_No, 
                Contact_Person, Email_Id, Address_Line_1_Text, Address_Line_2_Text, 
                State_Id, District_Id, Taluka_Id, Village_Id, Pincode, 
                Pan_No, ShopLatitude, ShopLongitude, Shop_License_No, Pan_Card_Photo, 
                Shop_License_Photo, Cheque_Leaf_Photo, Shop_Name_Photo, 
                Bank_Id, Branch_Id, Account_No, IFSC_Code, Account_Name, 
                FSSAI_License_No, GST_No,
                DATE_FORMAT(FSSAI_LicenseValidity_On, '%Y-%m-%d') AS FSSAI_LicenseValidity_On,  
                CONCAT(
                DATE_FORMAT(AgreementValidiy_StartDate,'%m/%d/%Y'),
                ' - ', 
                DATE_FORMAT(AgreementValidity_EndDate,'%m/%d/%Y')
                ) AS Agreement_Validity_Period, 
                UdyamAadhar_Card_Photo, FSSAI_License_Photo, GST_Certificate_Photo, 
                Is_Agreement_Done, SecurityDepositAmount, Is_Active, Is_Deleted,
                Is_Approved, Approved_On, Approved_Id, Approved_Name, Approval_Remarks
            FROM mu09_retailer 
            WHERE Org_Id = var_Org_Id
            AND Retailer_Id = var_Retailer_Id 
            AND Is_Deleted = 0;
		END;
	END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
