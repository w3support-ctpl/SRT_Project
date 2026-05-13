-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminCrateApprove_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminCrateApprove_Get`(
	var_Org_Id VARCHAR(10),
    var_Method_Name VARCHAR(100),
    var_User_Id VARCHAR(20),
    var_ReceivedCrate_Id VARCHAR(20),
    var_Date text,
    var_Dealer_Id VARCHAR(20),
    var_Is_Approved INT
)
BEGIN

	DECLARE var_StartDate DATE;
	DECLARE var_EndDate DATE;
	SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
	SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
		

	IF(var_Method_Name = 'Get') THEN
    
		select t038h.ReceivedCrate_Id , t038h.Dealer_Id , mu08.Dealer_Name , 
		IFNULL(DATE_FORMAT(t038h.Created_On, '%d %M %Y') , '' ) AS Created_On,
		m010.Material_Name , Good_Quantity , Broken_Quantity , ThirdParty_Quantity , t038i.Material_Id
		from t038_receivedcrate_header t038h
		inner join t038_receivedcrate_item t038i on t038h.Org_Id = t038i.Org_Id and 
		t038h.ReceivedCrate_Id = t038i.ReceivedCrate_Id
		inner join mu08_dealer mu08 on t038h.Org_Id = mu08.Org_Id and 
		t038h.Dealer_Id = mu08.Dealer_Id 
		inner JOIN m010_material m010
		ON m010.Material_Id = t038i.Material_Id
		AND m010.Org_Id = t038i.Org_Id  
		AND CAST(t038h.Created_On AS DATE) >= var_StartDate 
		AND CAST(t038h.Created_On AS DATE) <= var_EndDate 
        and t038h.Dealer_Id like var_Dealer_Id and 
        t038h.Is_Approved = 0;
            
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
