-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_ChemistSurvey` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_ChemistSurvey`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Profile_Id varchar(20),
Var_MCC_Id varchar (20),
Var_Survey_Id varchar(20),
Var_SurveyData longtext
)
BEGIN

    set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    SET SQL_SAFE_UPDATES = 0;
    
    if(Var_Method_Name = 'GetSurveyList') THEN
		
	select t025.Survey_Id , mu07.Chemist_Name , DATE_FORMAT(Applicable_Date, '%d %M %Y') as Applicable_Date , m005.MCC_Name , t025i.MCC_Id ,
	if(t025i.Is_Started = 0 , 'Not Started' , 'Started' ) as Is_Started, 
	if(t025i.Is_Completed = 0 and  t025i.Is_Started = 0 , 'Not Started' , if(t025i.Is_Completed = 0 and  t025i.Is_Started = 1 , 'In Process' , 'Completed' )) as Is_Completed 
	from t025_survey_header t025 
	inner join t025_survey_item t025i on t025.Survey_Id = t025i.Survey_Id
	inner join mu07_routechemist mu07 on mu07.Chemist_Id = t025.Chemist_Id
	inner join m005_mcc m005 on m005.MCC_Id = t025i.MCC_Id 
	where t025.Chemist_Id = Var_Profile_Id and t025.Org_Id = Var_Org_Id;
    
     elseif(Var_Method_Name = 'Savedata') THEN
     
    SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                '' AS Result_Extra_Key;
                
                
	elseif(Var_Method_Name = 'Startsurvay') THEN
     
     /*
     update t025_survey_header 
     set Is_Started = 1 ,
     LastEditedBy_Id= Var_Profile_Id 
     where Survey_Id = Var_Survey_Id and Org_Id = Var_Org_Id;
     */
     
	update t025_survey_item 
     set Is_Started = 1 ,
     Started_On = @Current_Datetime 
     where Survey_Id = Var_Survey_Id and Org_Id = Var_Org_Id 
     and MCC_Id = Var_MCC_Id ;
     
     
    SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                '' AS Result_Extra_Key;
     

end if;


END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
