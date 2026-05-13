-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentIncentives_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentIncentives_Get`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Incentive_Id varchar(20),
Var_Profile_Id varchar(20)
)
BEGIN
set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	if(Var_Method_Name = 'GetIncentives') then 
		
        select IncentiveScheme_Id, Scheme_Name, IncentiveFrequency_Name as IncentiveFrequency , IncentiveType_Id , Criteria , Scheme_Description , ifnull(Photo,'https://th.bing.com/th/id/OIG.CO2sHWK_IEYIwzXsC2hX') as Photo , DATE_FORMAT(From_Date, '%d %b %y') AS From_Date ,
        DATE_FORMAT(To_Date, '%d %b %y') AS To_Date
        from m011_incentivescheme m011 
        inner join c026_incentivefrequency c026 on c026.IncentiveFrequency_Id = m011.IncentiveFrequency_Id
        where Is_For_Agent = 1  and m011.Org_Id = Var_Org_Id and date(m011.To_Date) >= date(@Current_Datetime) and 
        m011.Is_Active = 1 order by m011.To_Date desc; 
        
	elseif(Var_Method_Name = 'GetActiveIncentive') then 
		
        select Request_Id ,Scheme_Name , ifnull(DATE_FORMAT(Approved_On, '%d %b %y') ,'')as Approved_On , 
        ifnull(Approval_Remarks ,'') as Approval_Remarks , ifnull(Is_Approved,0) as Is_Approved , 
        ifnull( DATE_FORMAT(Request_Date, '%d %b %y'),'') as Request_Date , IncentiveFrequency_Name as IncentiveFrequency , IncentiveType_Id , Criteria , Scheme_Description , ifnull(Photo,'https://th.bing.com/th/id/OIG.CO2sHWK_IEYIwzXsC2hX') as Photo , DATE_FORMAT(From_Date, '%d %b %y') AS From_Date ,
        DATE_FORMAT(To_Date, '%d %b %y') AS To_Date
        from 
        t017_incentives_request t007 inner join m011_incentivescheme m011 on t007.IncentiveScheme_Id = m011.IncentiveScheme_Id
        inner join c026_incentivefrequency c026 on c026.IncentiveFrequency_Id = m011.IncentiveFrequency_Id
		and t007.Org_Id = m011.Org_Id 
        where t007.MCC_Id = Var_MCC_Id and t007.Org_Id =  Var_Org_Id and Request_For = 'Agent'
        order by Request_Date desc;
	elseif(Var_Method_Name = 'GetIncentives_V1') then 
		
        select m011.IncentiveScheme_Id, Scheme_Name, IncentiveFrequency_Name as IncentiveFrequency , IncentiveType_Id , Criteria , Scheme_Description , ifnull(Photo,'https://th.bing.com/th/id/OIG.CO2sHWK_IEYIwzXsC2hX') as Photo , DATE_FORMAT(From_Date, '%d %b %y') AS From_Date ,
        DATE_FORMAT(To_Date, '%d %b %y') AS To_Date
        from m011_incentivescheme m011 
        inner join m011_incentivescheme_item m0111 on
        m011.Org_Id = m0111.Org_Id
        and m011.IncentiveScheme_Id = m0111.IncentiveScheme_Id
        and m0111.MCC_Id = Var_MCC_Id
        inner join c026_incentivefrequency c026 on c026.IncentiveFrequency_Id = m011.IncentiveFrequency_Id
        where Is_For_Agent = 1  and m011.Org_Id = Var_Org_Id and date(m011.To_Date) >= date(@Current_Datetime) and 
        m011.Is_Active = 1 order by m011.To_Date desc; 
    end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
