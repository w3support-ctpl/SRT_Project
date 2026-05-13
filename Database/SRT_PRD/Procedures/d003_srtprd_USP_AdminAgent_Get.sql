-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminAgent_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminAgent_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Agent_Id varchar(20),
    var_Search_Text varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then  
		begin
			select Org_Id,Agent_Id, Agent_Name, ifnull(Agent_Code ,'')as Agent_Code, 
            ifnull(date_format(Joining_Date, '%d %M %Y'),'') as Joining_Date, Mobile_No,Is_Active,Is_Deleted
            from mu05_agent 
            where Org_Id = var_Org_Id and Is_Deleted = 0 
            and (Agent_Name like var_Search_Text 
				or Agent_Code like var_Search_Text
                or Mobile_No like var_Search_Text
                or Pan_No like var_Search_Text)
            order by Agent_Id;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select mu05.Org_Id,mu05.Agent_Id,mu05.Agent_Name,mu05.Agent_Code,ifnull(mu05.Email_Id,'') as Email_Id, date_format(mu05.Joining_Date, '%Y-%m-%d') as Joining_Date,
            date_format(mu05.Birth_Date, '%Y-%m-%d') as Birth_Date,mu05.Mobile_No,mu05.Pan_No,mu05.Aadhar_No,
            mu05.Online_App_Flag,mu05.State_Id,mu05.District_Id,mu05.Taluka_Id,mu05.Village_Id,mu05.Address_Text,
            mu05.Profile_Photo,mu05.Pan_Card_Photo,mu05.Aadhar_Card_Photo,mu05.Is_Active,mu05.Is_Deleted ,
            CASE
					WHEN m005.Agent_Id IS NOT NULL
					THEN 1
					ELSE 0
				END AS Is_Locked
			FROM mu05_agent mu05
			LEFT JOIN (
				SELECT DISTINCT Agent_Id
				FROM m005_mcc
				WHERE Org_Id = var_Org_Id
					AND Is_Deleted = 0
			) m005 ON m005.Agent_Id = mu05.Agent_Id 
            where Org_Id = var_Org_Id and mu05.Agent_Id = var_Agent_Id
            and Is_Deleted =0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
