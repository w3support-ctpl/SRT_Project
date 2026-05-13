-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminSalesUser_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminSalesUser_Get`(
	var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_User_Id VARCHAR(20),
    var_SalesUser_Id VARCHAR(20),
    var_Search_Text VARCHAR(45)
)
BEGIN
	-- Get all records from Sales User Table
    IF(var_Method_Name = 'Get') THEN
	BEGIN
		SELECT salesuser.Org_Id, salesuser.SalesUser_Id, 
			salesuser.SalesUser_Name, salesuser.SAP_BP_Partner_Code,
            IFNULL(salesuser.SalesUser_Code, '') AS SalesUser_Code, 
            IFNULL(reporting.ReportingTo_Id,'') AS ReportingTo_Id,  
            IFNULL(reporting.SalesUser_Name,'') AS ReportingTo_Name,
            IFNULL(su_role.SalesUserRole_Id,'') AS SalesUserRole_Id,  
            IFNULL(su_role.SalesUserRole_Name,'') AS SalesUserRole_Name,
            salesuser.Mobile_No, 
            IFNULL(salesuser.SAP_BP_Partner_Code,'') AS SAP_BP_Partner_Code,
            taluka.Taluka_Id, taluka.Taluka_Name, salesuser.Is_Active,
            IFNULL(salesuser.SalesEmployee, '') AS salesemployee
		FROM mu12_sales_user salesuser
		LEFT JOIN mu12_sales_user reporting
			ON reporting.SalesUser_Id = salesuser.ReportingTo_Id
            AND reporting.Org_Id = salesuser.Org_Id
		LEFT JOIN ml04_taluka taluka
			ON taluka.Taluka_Id = salesuser.Taluka_Id
            AND taluka.Org_Id = salesuser.Org_Id
		LEFT JOIN c044_sales_user_role su_role
			ON salesuser.SalesUserRole_Id = su_role.SalesUserRole_Id
		WHERE salesuser.Org_Id = var_Org_Id
        AND salesuser.Is_Deleted = 0
        AND (salesuser.SalesUser_Code LIKE var_Search_Text
			OR salesuser.SAP_BP_Partner_Code LIKE var_Search_Text
			OR salesuser.SalesUser_Name LIKE var_Search_Text
            OR salesuser.Mobile_No LIKE var_Search_Text
            OR salesuser.Taluka_Id LIKE var_Search_Text
        )
        ORDER BY salesuser.SalesUser_Name;
            
    END;
    -- Get Single record from Sales User where SalesUser_Id = var_SalesUSer_Id
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
		SELECT SalesUser_Id, SalesUser_Name,
			IFNULL(SalesUser_Code, '') AS SalesUser_Code, 
			IFNULL(ReportingTo_Id, '') AS ReportingTo_Id, 
            SalesUserRole_Id,
			Mobile_No, 
			IFNULL(Email_Id, '') AS Email_Id, 
			DATE_FORMAT(Joining_Date,'%Y-%m-%d') AS Joining_Date,  
			Address_Text, State_Id, District_Id, Taluka_Id, Village_Id, 
			Pan_No, Aadhar_No, Online_App_Flag, 
			IFNULL(SAP_BP_Partner_Code, '') AS SAP_BP_Partner_Code,
			Is_Active, Is_Deleted,
            IFNULL(SalesEmployee, '') AS salesemployee,
            IFNULL(Login_Password, '') AS login_password,
            IFNULL(SalesArea_Id, '') AS SalesArea_Id
		FROM mu12_sales_user as  U		
		WHERE Org_Id = var_Org_Id
        AND Is_Deleted = 0
        AND SalesUser_Id = var_SalesUser_Id;
    END;
    ELSEIF(var_Method_Name = 'Get_V2') THEN
    BEGIN
		
        select 
		ifnull(mu12.SalesUser_Id,'') as SalesUser_Id,
		ifnull(mu12.SAP_BP_Partner_Code,'') as SAP_BP_Partner_Code,
		ifnull(mu12.SalesUser_Name,'') as SalesUser_Name,
		ifnull(mu12.SalesEmployee,'') as salesemployee,
		ifnull(mu12.SalesUser_Code,'') as SalesUser_Code,
		IFNULL(mu12.SalesUserRole_Id,'') AS SalesUserRole_Id,  
		ifnull(c044.SalesUserRole_Name,'') as SalesUserRole_Name, 
		IFNULL(mu12.ReportingTo_Id,'') AS ReportingTo_Id, 
		-- ifnull(mu12i.SalesUser_Name,'') as reportingto_name,
        IFNULL((
        SELECT mu12x.SalesUser_Name 
        FROM mu12_sales_user mu12x 
        WHERE mu12x.Org_Id = mu12.Org_Id 
        AND mu12x.SalesUser_Id = mu12.ReportingTo_Id 
        LIMIT 1
		), '') as reportingto_name,
		ifnull(mu12.Mobile_No,'') as Mobile_No,
		ifnull(mu12.Email_Id,'') as Email_Id,
		ifnull(date_format(mu12.Birth_Date, '%d %M %Y'),'') as Birth_Date,
		ifnull(date_format(mu12.Joining_Date, '%d %M %Y'),'') as Joining_Date,
		ifnull(mu12.Address_Text,'') as Address_Text,
		ifnull(ml02.State_Name,'') as State_Name, 
		ifnull(ml03.District_Name,'') as District_Name, 
		ifnull(ml04.Taluka_Name,'') as Taluka_Name, 
		ifnull(mu12.Village_Id,'') as Village_Id, 
		ifnull(mu12.Pincode,'') as Pincode,
		ifnull(mu12.Pan_No,'') as Pan_No,
		ifnull(mu12.Aadhar_No,'') as Aadhar_No,
		ifnull(mu12.Bank_Name,'') as Bank_Name,
		ifnull(concat("'",mu12.Account_No),'') as Account_No,
		ifnull(mu12.IFSC_Code,'') as IFSC_Code,
		ifnull(mu12.Account_Name,'') as Account_Name,
              IFNULL(SalesArea_Id, '') AS SalesArea_Id,
		mu12.Is_Active,
         ( SELECT
                
        
                GROUP_CONCAT(DISTINCT Route_Name ORDER BY Route_Name SEPARATOR ', ') AS Route_Name
                
            FROM m019_salesuserroute_header
            WHERE SalesUser_Id = mu12.salesUser_Id) as Route_Name
		from mu12_sales_user mu12
		inner join c044_sales_user_role c044 on
		c044.SalesUserRole_Id = mu12.SalesUserRole_Id
		-- left join mu12_sales_user mu12i  on
		-- mu12i.Org_Id = mu12.Org_Id 
		-- and mu12i.ReportingTo_Id = mu12.SalesUser_Id 
		left join ml02_state ml02  on
		ml02.Org_Id = mu12.Org_Id 
		and ml02.State_Id = mu12.State_Id 
		left join ml03_district ml03  on
		ml03.Org_Id = mu12.Org_Id 
		and ml03.District_Id = mu12.District_Id 
		left join ml04_taluka ml04  on
		ml04.Org_Id = mu12.Org_Id 
		and ml04.Taluka_Id = mu12.Taluka_Id
		WHERE mu12.Org_Id = var_Org_Id
		AND mu12.Is_Deleted = 0
		AND (mu12.SalesUser_Code LIKE var_Search_Text
			OR mu12.SAP_BP_Partner_Code LIKE var_Search_Text
			OR mu12.SalesUser_Name LIKE var_Search_Text
			OR mu12.Mobile_No LIKE var_Search_Text
			OR mu12.Taluka_Id LIKE var_Search_Text
		)
		ORDER BY mu12.SalesUser_Name;

    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
