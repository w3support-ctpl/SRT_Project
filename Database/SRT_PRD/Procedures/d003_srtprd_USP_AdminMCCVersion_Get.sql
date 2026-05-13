-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCVersion_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCVersion_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_MCC_Id varchar(20),
    var_Version_No varchar(10)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
            DECLARE Today_Date DATETIME;
            
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT m005.Org_Id,
                   c022.MusterType_Id, c022.MusterType_Name,
                   c024.PaymentCycle_Id, c024.PaymentCycle_Name,
                   CollectionShift_Name,MilkType_Name,
                   DATE_FORMAT(Applicable_Date, '%d %b %Y %h:%i %p') AS Applicable_Date,
                   m005.Version_No, m005.Is_Active, m005.Is_Deleted,
                   -- ifnull(m005.Anamat_PerLtr,'') as anamat, 
                   -- ifnull(m005.Freight_PerLtr,'') as freight,
                   concat(ifnull(m005.Anamat_PerLtr,'') , ' for ', ifnull(m005.Anamat_Applicable_To,''))as anamat, 
                   concat(ifnull(m005.Freight_PerLtr,'') , ' for ', ifnull(m005.Freight_Applicable_To,''))as freight, 
                   ifnull(m005.Anamat_Applicable_To,'') as anamat_tds, 
                   ifnull(m005.Freight_Applicable_To,'') as freight_tds,
                    ifnull(m005.Rebate_PerLtr,'') as rebate,
                   CASE 
                       WHEN Today_Date >= m005.Applicable_Date AND Today_Date <= DATE_ADD(m005.Applicable_Date, INTERVAL 1 DAY) THEN 1
                       WHEN Today_Date > DATE_ADD(m005.Applicable_Date, INTERVAL 1 DAY) THEN 1
                       ELSE 0
                   END AS Is_Locked
            FROM m005_mcc_version m005
            inner JOIN c022_mustertype c022 ON c022.MusterType_Id = m005.MusterType_Id 
            inner JOIN c024_paymentcycle c024 ON c024.PaymentCycle_Id = m005.PaymentCycle_Id
            WHERE m005.Org_Id = var_Org_Id  
              AND m005.MCC_Id = var_MCC_Id
              AND m005.Is_Deleted = 0
			ORDER BY DATE(m005.Applicable_Date) DESC, TIME(m005.Applicable_Date) DESC;
           
        end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			SELECT m005.Org_Id, m005.MCC_Id, m005.Version_No, m005.MusterType_Id, m005.PaymentCycle_Id,
                   DATE_FORMAT(Applicable_Date, '%Y-%m-%dT%H:%i') AS Applicable_Date,
                   m005.Is_Active, m005.Is_Deleted,
                   ifnull(m005.Anamat_PerLtr,'') as anamat, 
                   ifnull(m005.Freight_PerLtr,'') as freight,
                   ifnull(m005.Anamat_Applicable_To,'') as anamat_tds, 
                   ifnull(m005.Freight_Applicable_To,'') as freight_tds,
                    ifnull(m005.Rebate_PerLtr,'') as rebate,
                   (
					SELECT CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('"', m0051.CollectionShift_Id, '"')), ']')
					FROM m005_mcc_collectionshift m0051
					WHERE m0051.Org_Id = m005.Org_Id AND m0051.MCC_Id = m005.MCC_Id AND m0051.Version_No = m005.Version_No
					) AS CollectionShift_Id,
					(
					SELECT CONCAT('[', GROUP_CONCAT(DISTINCT CONCAT('"', m0052.MilkType_Id, '"')), ']')
					FROM m005_mcc_milktype m0052
					WHERE m0052.Org_Id = m005.Org_Id AND m0052.MCC_Id = m005.MCC_Id AND m0052.Version_No = m005.Version_No
					) AS MilkType_Id
            FROM m005_mcc_version m005
            inner JOIN m005_mcc_milktype m0052 ON m0052.Version_No = m005.Version_No 
				and m0052.Org_Id = m005.Org_Id 
            inner JOIN m005_mcc_collectionshift m0051 ON m0051.Version_No = m005.Version_No
            WHERE m005.Org_Id = var_Org_Id 
              AND m005.MCC_Id = var_MCC_Id
              AND m005.Version_No = var_Version_No
			GROUP BY m005.Org_Id, m005.MCC_Id, m005.Version_No, m005.MusterType_Id, m005.PaymentCycle_Id, m005.Applicable_Date, m005.Is_Active, m005.Is_Deleted;
		end;
	elseif (var_Method_Name = 'Get_Date') then
		begin
			SELECT DATE_FORMAT(Applicable_Date, '%Y-%m-%dT%H:%i') AS Applicable_Date
			FROM m005_mcc_version
			WHERE Org_Id = var_Org_Id
			AND MCC_Id = var_MCC_Id
			AND Is_Deleted = 0
			ORDER BY Version_No DESC
			LIMIT 1;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
