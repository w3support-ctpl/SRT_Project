-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkRateItem_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkRateItem_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Chart_Id varchar(20),
    var_MilkRateEntryType_Id varchar(20),
    var_Entry_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			DECLARE Today_Date DATETIME;
            
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT m001.Org_Id, Entry_Id, Chart_Id, 
            c012.MilkRateEntryType_Id,c012.MilkRateEntryType_Name,
            m014.Slab_Id, m014.Slab_Name,
            CONCAT(m014.Slab_Max, ' - ', m014.Slab_Min) AS Slab_Range,
            BaseFat, BaseSNF, Version_No, Amount,
            DATE_FORMAT(Applicable_Date, '%d %b %Y %h:%i %p') AS Applicable_Date,
            m001.Is_Active,m001.Is_Deleted,
                   CASE 
                       WHEN Today_Date >= m001.Applicable_Date AND Today_Date <= DATE_ADD(m001.Applicable_Date, INTERVAL 1 DAY) THEN 1
                       WHEN Today_Date > DATE_ADD(m001.Applicable_Date, INTERVAL 1 DAY) THEN 1
                       ELSE 0
                   END AS Is_Locked,
			CASE 
				WHEN Version_No < (
					SELECT MAX(Version_No)
					FROM m001_milkrate_item AS sub_m001
					WHERE sub_m001.Org_Id = m001.Org_Id
					  AND sub_m001.Chart_Id = m001.Chart_Id
					  AND sub_m001.MilkRateEntryType_Id = m001.MilkRateEntryType_Id
                      AND ifnull(sub_m001.Slab_Id,'') = ifnull(m001.Slab_Id,'')
					  AND sub_m001.Is_Deleted = 0
				) THEN 0
				ELSE 1
			END AS Is_BackDate,
            
			ifnull((SELECT DATE_FORMAT(sub_m001.Applicable_Date, '%Y-%m-%dT%H:%i')
			FROM m001_milkrate_item AS sub_m001
			WHERE sub_m001.Org_Id = m001.Org_Id
			AND sub_m001.Chart_Id = m001.Chart_Id
			AND sub_m001.MilkRateEntryType_Id = m001.MilkRateEntryType_Id
            AND ifnull(sub_m001.Slab_Id,'') = ifnull(m001.Slab_Id,'')
			AND sub_m001.Version_No < m001.Version_No
			AND sub_m001.Is_Deleted = 0  
			order by Version_No desc limit 1),DATE_FORMAT(Applicable_Date, '%Y-%m-%dT%H:%i')) 
			AS Back_Date,
            
            CASE 
				WHEN IFNULL((
					SELECT DATE_FORMAT(sub_m001.Applicable_Date, '%Y-%m-%dT%H:%i')
					FROM m001_milkrate_item AS sub_m001
					WHERE sub_m001.Org_Id = m001.Org_Id
					  AND sub_m001.Chart_Id = m001.Chart_Id
					  AND sub_m001.MilkRateEntryType_Id = m001.MilkRateEntryType_Id
					  AND IFNULL(sub_m001.Slab_Id,'') = IFNULL(m001.Slab_Id,'')
					  AND sub_m001.Version_No < m001.Version_No
					  AND sub_m001.Is_Deleted = 0
					ORDER BY Version_No DESC LIMIT 1
				), NULL) IS NULL THEN 1
				ELSE 0
			END AS Is_AccessDate
            
			FROM m001_milkrate_item m001
			inner join c012_milkrateentrytype c012 on c012.MilkRateEntryType_Id = m001.MilkRateEntryType_Id 
            left join m014_slab m014 on m014.Slab_Id = m001.Slab_Id 
				and m014.Org_Id = m001.Org_Id 
            WHERE m001.Org_Id = var_Org_Id  
              and Chart_Id = var_Chart_Id
            and m001.MilkRateEntryType_Id = var_MilkRateEntryType_Id
            AND m001.Is_Deleted = 0
            ORDER BY DATE(m001.Applicable_Date) DESC, TIME(m001.Applicable_Date) DESC;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id,Entry_Id, Chart_Id, MilkRateEntryType_Id, Slab_Id, 
            BaseFat, BaseSNF, Version_No ,Amount, 
            DATE_FORMAT(Applicable_Date, '%Y-%m-%dT%H:%i') AS Applicable_Date,
            Is_Active, Is_Deleted
            from m001_milkrate_item 
            where Org_Id = var_Org_Id 
            and Chart_Id = var_Chart_Id
            and Entry_Id = var_Entry_Id;
		end;
	elseif (var_Method_Name = 'Get_Date') then
		begin
			SELECT ifnull(DATE_FORMAT(Applicable_Date, '%Y-%m-%dT%H:%i'),'') AS Applicable_Date   
			FROM m001_milkrate_item
			WHERE Org_Id = var_Org_Id
			AND Chart_Id = var_Chart_Id
            AND MilkRateEntryType_Id = var_MilkRateEntryType_Id
			AND Is_Deleted = 0
			ORDER BY Version_No DESC
			LIMIT 1;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
