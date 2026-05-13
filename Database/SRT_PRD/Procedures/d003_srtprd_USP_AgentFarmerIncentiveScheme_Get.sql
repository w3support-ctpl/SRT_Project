-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerIncentiveScheme_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerIncentiveScheme_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
	Var_Farmer_Id varchar (30)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
			select m011.Org_Id,m011.IncentiveScheme_Id,m011.Scheme_Name,m011.Criteria,
            m011.Scheme_Description,
            CONCAT(DATE_FORMAT(m011.From_Date, '%d %M %Y'), ' - ',DATE_FORMAT(m011.To_Date, '%d %M %Y')) AS Date,
            c026.IncentiveFrequency_Id,c026.IncentiveFrequency_Name
            from m011_incentivescheme m011
			inner join c026_incentivefrequency c026 on c026.IncentiveFrequency_Id = m011.IncentiveFrequency_Id
            where m011.Org_Id = var_Org_Id and m011.Is_Deleted = 0  and m011.Is_For_Farmer = 1 and m011.is_Active = 1
            order by Scheme_Name;
		end;
        
	elseif (var_Method_Name = 'Get_Approved') then  
		begin
			select t007.Org_Id,t007.Request_Id, 
            m011.IncentiveScheme_Id,m011.Scheme_Name,m011.Criteria,
            m011.Scheme_Description,
            DATE_FORMAT(m011.Created_On, '%d %b %y') AS Created_On,
            CONCAT(DATE_FORMAT(m011.From_Date, '%d %b %y'), ' - ',DATE_FORMAT(m011.To_Date, '%d %b %y')) AS Date,
            c026.IncentiveFrequency_Id,c026.IncentiveFrequency_Name,
            t007.Is_Approved  ,
            DATE_FORMAT(t007.Approved_On, '%d %M %Y') as Approved_On
            from t017_incentives_request t007
            inner join m011_incentivescheme m011 on m011.IncentiveScheme_Id = t007.IncentiveScheme_Id 
            inner join c026_incentivefrequency c026 on c026.IncentiveFrequency_Id = m011.IncentiveFrequency_Id
            where t007.Org_Id = var_Org_Id 
            and t007.Request_For_User_Id = Var_Farmer_Id
            and t007.Request_By_User_Id = Var_Farmer_Id
            order by t007.Request_Id ;
		end;
	elseif (var_Method_Name = 'Get_V1') then
		begin
			set @MCC_Id  = (select MCC_Id from mu04_farmer where Org_Id = var_Org_Id
							and Farmer_Id = Var_Farmer_Id limit 1);
                            
			if(@MCC_Id is null or @MCC_Id = '')then
            
				set @MCC_Id  = (select MCC_Id from mu04_farmer where Org_Id = var_Org_Id
								and Farmer_Id = var_Profile_Id limit 1);
            end if;
            
			select m011.Org_Id,m011.IncentiveScheme_Id,m011.Scheme_Name,m011.Criteria,
            m011.Scheme_Description,
            CONCAT(DATE_FORMAT(m011.From_Date, '%d %M %Y'), ' - ',DATE_FORMAT(m011.To_Date, '%d %M %Y')) AS Date,
            c026.IncentiveFrequency_Id,c026.IncentiveFrequency_Name
            from m011_incentivescheme m011
            inner join m011_incentivescheme_item m0111 on
			m011.Org_Id = m0111.Org_Id
			and m011.IncentiveScheme_Id = m0111.IncentiveScheme_Id
			and m0111.MCC_Id = @MCC_Id 
			inner join c026_incentivefrequency c026 on c026.IncentiveFrequency_Id = m011.IncentiveFrequency_Id
            where m011.Org_Id = var_Org_Id and m011.Is_Deleted = 0  and m011.Is_For_Farmer = 1 and m011.is_Active = 1
            order by Scheme_Name;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
