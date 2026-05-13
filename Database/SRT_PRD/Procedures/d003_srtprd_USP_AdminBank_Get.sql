-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminBank_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminBank_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Bank_Id varchar(20),
    var_Search_Text varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then  
		begin
			select m015.Org_Id,m015.Bank_Id, m015.Bank_Name,
            IFNULL(m016.Branch_Id,'')as Branch_Id,
            IFNULL(m016.Branch_Name,'') as Branch_Name,
            m015.Is_Active,m015.Is_Deleted
            from m015_bank m015
            left join m016_branch m016 on m016.Bank_Id = m015.Bank_Id
            and m016.Org_Id = m015.Org_Id
            and m016.Is_Deleted = 0
            and m016.Is_Active =  1 
            where m015.Org_Id = var_Org_Id and m015.Is_Deleted = 0
            and m015.Is_Active =  1 
            and (m015.Bank_Name like var_Search_Text 
				or m016.Branch_Name like var_Search_Text
                or m016.IFSC_Code like var_Search_Text)
            order by m015.Bank_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			/*select Org_Id,Bank_Id, Bank_Name,Is_Active,Is_Deleted
            from m015_bank 
            where Org_Id = var_Org_Id and Bank_Id = var_Bank_Id 
            and Is_Deleted =0;
            */
            
            select m015.Org_Id,m015.Bank_Id,m015.Bank_Name,m015.Is_Active,m015.Is_Deleted,
				CASE
			WHEN EXISTS (
				SELECT 1 FROM mu04_farmer mu04 WHERE mu04.Bank_Id = m015.Bank_Id
					and  mu04.Org_Id = m015.Org_Id
                    and  mu04.Is_Deleted = 0
			) OR EXISTS (
				SELECT 1 FROM m005_mcc m005 WHERE m005.Bank_Id = m015.Bank_Id
					and  m005.Org_Id = m015.Org_Id
                    and  m005.Is_Deleted = 0
			) OR EXISTS (
				SELECT 1 FROM m009_transporter m009 WHERE m009.Bank_Id = m015.Bank_Id
					and  m009.Org_Id = m015.Org_Id
                    and  m009.Is_Deleted = 0
			) THEN 1
			ELSE 0
			END AS Is_Locked
				from m015_bank m015
				where m015.Org_Id = var_Org_Id and m015.Bank_Id = var_Bank_Id 
				and m015.Is_Deleted =0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
