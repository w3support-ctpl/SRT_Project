-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRetailer_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRetailer_Get`(
    IN var_Method_Name VARCHAR(20),
    IN var_Org_Id VARCHAR(10),
    IN var_User_Id VARCHAR(20),
    IN var_SalesArea_Id VARCHAR(20),
    IN var_Dealer_Id VARCHAR(20),
    IN var_Retailer_Id VARCHAR(20),
    IN var_Retailer_Name VARCHAR(50)
)
BEGIN

    IF var_Method_Name = 'Get' THEN

       SELECT 
    r.Org_Id,
    r.Retailer_Id,
    r.Retailer_Name,
    sa.SalesArea_Id,
    sa.SalesArea_Name,
    d.Dealer_Id,
    IFNULL(d.Dealer_Name, '') AS Dealer_Name,
    
    -- 7 Columns for Sales Users assigned per day
    MAX(CASE WHEN ri.RouteDay_Id = 'C045001' and rm.Route_Name is not null THEN su.SalesUser_Name END) AS Monday_User,
    MAX(CASE WHEN ri.RouteDay_Id = 'C045002' and rm.Route_Name is not null THEN su.SalesUser_Name END) AS Tuesday_User,
    MAX(CASE WHEN ri.RouteDay_Id = 'C045003' and rm.Route_Name is not null THEN su.SalesUser_Name END) AS Wednesday_User,
    MAX(CASE WHEN ri.RouteDay_Id = 'C045004' and rm.Route_Name is not null THEN su.SalesUser_Name END) AS Thursday_User,
    MAX(CASE WHEN ri.RouteDay_Id = 'C045005' and rm.Route_Name is not null THEN su.SalesUser_Name END) AS Friday_User,
    MAX(CASE WHEN ri.RouteDay_Id = 'C045006' and rm.Route_Name is not null THEN su.SalesUser_Name END) AS Saturday_User,
    MAX(CASE WHEN ri.RouteDay_Id = 'C045007' and rm.Route_Name is not null THEN su.SalesUser_Name END) AS Sunday_User,

    -- Aggregated Route Names (if multiple routes apply to this retailer)
    GROUP_CONCAT(DISTINCT rm.Route_Name SEPARATOR ', ') AS Route_Name,
    
    r.Is_Active,
    r.Is_Deleted

FROM mu09_retailer r

-- Get Sales Area details
LEFT JOIN m013_salesarea sa
    ON sa.SalesArea_Id = r.SalesArea_Id
    AND sa.Org_Id = r.Org_Id

-- Get Dealer details
LEFT JOIN mu08_dealer d
    ON d.Dealer_Id = r.Dealer_Id
    AND d.Org_Id = r.Org_Id

-- Join with the assignment item table
LEFT JOIN m019_salesuserroute_item ri
    ON ri.Retailer_Id = r.Retailer_Id
    AND ri.Org_Id = r.Org_Id

-- Join with Sales User to get the name
LEFT JOIN mu12_sales_user su
    ON su.SalesUser_Id = ri.SalesUser_Id
    AND su.Org_Id = r.Org_Id

-- Join with Route Master for the name
LEFT JOIN mu19_route rm
    ON rm.Route_Id = ri.Route_Id
    AND rm.Org_Id = r.Org_Id

WHERE r.Org_Id = var_Org_Id
  AND r.Is_Deleted = 0
  AND sa.SalesArea_Id LIKE var_SalesArea_Id
  AND r.Dealer_Id LIKE var_Dealer_Id
  AND r.Retailer_Name LIKE var_Retailer_Name

-- Group by Retailer to collapse the 7 days into one row
GROUP BY 
    r.Org_Id, 
    r.Retailer_Id, 
    r.Retailer_Name, 
    sa.SalesArea_Id, 
    sa.SalesArea_Name, 
    d.Dealer_Id, 
    d.Dealer_Name

ORDER BY r.Retailer_Name;


    ELSEIF var_Method_Name = 'Get_One' THEN

        SELECT 
            r.Org_Id,
            r.Retailer_Id,
            r.Retailer_Name,
            r.SalesArea_Id,
            r.Route_Id,
            r.Dealer_Id,
            su.SalesUser_Id,
            IFNULL(r.Mobile_No,'') AS Mobile_No,
            IFNULL(r.Contact_Person,'') AS Contact_Person,
            IFNULL(r.Email_Id,'') AS Email_Id,
            IFNULL(r.Address_Line_1_Text,'') AS Address_Line_1_Text,
            IFNULL(r.Address_Line_2_Text,'') AS Address_Line_2_Text,
            IFNULL(r.Address_Line_3_Text,'') AS Address_Line_3_Text,
            r.State_Id,
            r.District_Id,
            r.Taluka_Id,
            r.Village_Id,
            r.Pincode,
            r.Pan_No,
            r.ShopLatitude,
            r.ShopLongitude,
            r.Shop_License_No,
            r.Pan_Card_Photo,
            r.Shop_License_Photo,
            r.Cheque_Leaf_Photo,
            r.Shop_Name_Photo,
            r.Bank_Id,
            r.Branch_Id,
            CONVERT(r.Account_No, CHAR) AS Account_No,
            r.IFSC_Code,
            r.Account_Name,
            r.FSSAI_License_No,
            r.GST_No,
            r.Aadhar_No,
            r.ASME,
            DATE_FORMAT(r.FSSAI_LicenseValidity_On, '%Y-%m-%d') AS FSSAI_LicenseValidity_On,
            CONCAT(
                DATE_FORMAT(r.AgreementValidiy_StartDate,'%m/%d/%Y'),
                ' - ',
                DATE_FORMAT(r.AgreementValidity_EndDate,'%m/%d/%Y')
            ) AS Agreement_Validity_Period,
            r.UdyamAadhar_Card_Photo,
            r.FSSAI_License_Photo,
            r.GST_Certificate_Photo,
            r.Is_Agreement_Done,
            r.SecurityDepositAmount,
            r.Is_Active,
            r.Is_Deleted,
            r.MSME,
            IFNULL(r.Landline_Number,'') AS Landline_Number

        FROM mu09_retailer r

        LEFT JOIN mu12_sales_user_route_item ri
            ON ri.Route_Id = r.Route_Id

        LEFT JOIN mu12_sales_user su
            ON su.SalesUser_Id = ri.SalesUser_Id
            AND su.Org_Id = r.Org_Id

        WHERE r.Org_Id = var_Org_Id
          AND r.Retailer_Id = var_Retailer_Id
          AND r.Is_Deleted = 0;


  ELSEIF var_Method_Name = 'Get_V1' THEN

   SELECT 
    IFNULL(r.Retailer_Id,'') AS Retailer_Id,
    IFNULL(r.Retailer_Name,'') AS Retailer_Name,

    -- 7 Columns for Sales Users assigned per day
    MAX(CASE WHEN sri.RouteDay_Id = 'C045001' and rt.Route_Name is not null THEN su_day.SalesUser_Name END) AS Monday_User,
    MAX(CASE WHEN sri.RouteDay_Id = 'C045002' and rt.Route_Name is not null THEN su_day.SalesUser_Name END) AS Tuesday_User,
    MAX(CASE WHEN sri.RouteDay_Id = 'C045003' and rt.Route_Name is not null THEN su_day.SalesUser_Name END) AS Wednesday_User,
    MAX(CASE WHEN sri.RouteDay_Id = 'C045004' and rt.Route_Name is not null THEN su_day.SalesUser_Name END) AS Thursday_User,
    MAX(CASE WHEN sri.RouteDay_Id = 'C045005' and rt.Route_Name is not null THEN su_day.SalesUser_Name END) AS Friday_User,
    MAX(CASE WHEN sri.RouteDay_Id = 'C045006' and rt.Route_Name is not null THEN su_day.SalesUser_Name END) AS Saturday_User,
    MAX(CASE WHEN sri.RouteDay_Id = 'C045007' and rt.Route_Name is not null THEN su_day.SalesUser_Name END) AS Sunday_User,

    IFNULL(rt.Route_Id,'') AS Route_Id,
    IFNULL(rt.Route_Name,'') AS Route_Name,

    IFNULL(sa.SalesArea_Name,'') AS SalesArea_Name,

    IFNULL(d.Dealer_Id,'') AS Dealer_Id,
    IFNULL(d.Dealer_Code,'') AS Dealer_Code,
    IFNULL(d.Dealer_Name,'') AS Dealer_Name,

    IFNULL(r.Mobile_No,'') AS Mobile_No,
    IFNULL(r.Contact_Person,'') AS Contact_Person,
    IFNULL(r.Email_Id,'') AS Email_Id,

    IFNULL(r.Address_Line_1_Text,'') AS Address_Line_1_Text,
    IFNULL(r.Address_Line_2_Text,'') AS Address_Line_2_Text,
    IFNULL(r.Address_Line_3_Text,'') AS Address_Line_3_Text,

    IFNULL(st.State_Name,'') AS State_Name,
    IFNULL(dt.District_Name,'') AS District_Name,
    IFNULL(tk.Taluka_Name,'') AS Taluka_Name,

    IFNULL(r.Pincode,'') AS Pincode,
    IFNULL(r.Pan_No,'') AS Pan_No,
    IFNULL(r.ShopLatitude,'') AS ShopLatitude,
    IFNULL(r.ShopLongitude,'') AS ShopLongitude,
    IFNULL(r.Shop_License_No,'') AS Shop_License_No,

    IFNULL(b.Bank_Name,'') AS Bank_Name,
    IFNULL(br.Branch_Name,'') AS Branch_Name,

    CONVERT(IFNULL(r.Account_No,''), CHAR) AS Account_No,
    IFNULL(r.IFSC_Code,'') AS IFSC_Code,
    IFNULL(r.Account_Name,'') AS Account_Name,

    IFNULL(r.FSSAI_License_No,'') AS FSSAI_License_No,
    IFNULL(DATE_FORMAT(r.FSSAI_LicenseValidity_On, '%d %M %Y'),'') AS FSSAI_LicenseValidity_On,

    IFNULL(DATE_FORMAT(r.AgreementValidiy_StartDate, '%d %M %Y'),'') AS AgreementValidiy_StartDate,
    IFNULL(DATE_FORMAT(r.AgreementValidity_EndDate, '%d %M %Y'),'') AS AgreementValidity_EndDate,

    IFNULL(r.SecurityDepositAmount,'') AS SecurityDepositAmount,
    IFNULL(r.MSME,'') AS MSME,
    IFNULL(r.Aadhar_No,'') AS Aadhar_No,
    IFNULL(r.ASME,'') AS ASME,
    IFNULL(r.GST_No,'') AS GST_No,

    r.Is_Active,
    r.Is_Deleted,

    IFNULL(r.Landline_Number,'') AS Landline_Number

FROM mu09_retailer r

LEFT JOIN m013_salesarea sa
    ON sa.Org_Id = r.Org_Id
    AND sa.SalesArea_Id = r.SalesArea_Id

LEFT JOIN mu08_dealer d
    ON d.Org_Id = r.Org_Id
    AND d.Dealer_Id = r.Dealer_Id

LEFT JOIN m019_salesuserroute_item sri
    ON sri.Retailer_Id = r.Retailer_Id
    AND sri.Org_Id = r.Org_Id

LEFT JOIN mu12_sales_user su_day
    ON su_day.SalesUser_Id = sri.SalesUser_Id
    AND su_day.Org_Id = r.Org_Id
left join mu19_route_retailer_mapping rrm
on rrm.Retailer_Id = r.Retailer_Id
LEFT JOIN (
    SELECT DISTINCT Route_Id, Route_Name
    FROM  mu19_route
) rt ON rt.Route_Id = rrm.Route_Id

LEFT JOIN ml02_state st
    ON st.Org_Id = r.Org_Id
    AND st.State_Id = r.State_Id

LEFT JOIN ml03_district dt
    ON dt.Org_Id = r.Org_Id
    AND dt.District_Id = r.District_Id

LEFT JOIN ml04_taluka tk
    ON tk.Org_Id = r.Org_Id
    AND tk.Taluka_Id = r.Taluka_Id

LEFT JOIN m015_bank b
    ON b.Org_Id = r.Org_Id
    AND b.Bank_Id = r.Bank_Id

LEFT JOIN m016_branch br
    ON br.Org_Id = r.Org_Id
    AND br.Branch_Id = r.Branch_Id

WHERE r.Org_Id = var_Org_Id
  AND r.Is_Deleted = 0
  AND ifnull(sa.SalesArea_Id,'') LIKE var_SalesArea_Id
  AND ifnull(r.Dealer_Id,'') LIKE var_Dealer_Id
  AND r.Retailer_Name LIKE var_Retailer_Name

GROUP BY 
    r.Retailer_Id, 
    r.Retailer_Name,
    rt.Route_Id,
    rt.Route_Name,
    sa.SalesArea_Name,
    d.Dealer_Id,
    d.Dealer_Code,
    d.Dealer_Name,
    r.Mobile_No,
    r.Contact_Person,
    r.Email_Id,
    r.Address_Line_1_Text,
    r.Address_Line_2_Text,
    r.Address_Line_3_Text,
    st.State_Name,
    dt.District_Name,
    tk.Taluka_Name,
    r.Pincode,
    r.Pan_No,
    r.ShopLatitude,
    r.ShopLongitude,
    r.Shop_License_No,
    b.Bank_Name,
    br.Branch_Name,
    r.Account_No,
    r.IFSC_Code,
    r.Account_Name,
    r.FSSAI_License_No,
    r.FSSAI_LicenseValidity_On,
    r.AgreementValidiy_StartDate,
    r.AgreementValidity_EndDate,
    r.SecurityDepositAmount,
    r.MSME,
    r.Aadhar_No,
    r.ASME,
    r.GST_No,
    r.Is_Active,
    r.Is_Deleted,
    r.Landline_Number
ORDER BY r.Retailer_Name;
    END IF;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
