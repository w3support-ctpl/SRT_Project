-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerAdvance_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerAdvance_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
    var_Date varchar(30)
)
BEGIN
	if (var_Method_Name = 'Get') then  

            set @AdvanceTaken  = 000;
            set @DeductionRemaining = 000;
            
			set @Var_Month = '';
			set @Var_Month =  month(var_Date);

			set @Var_Year = '';
			set @Var_Year =  year(Var_Date);
            
            
			select sum(Approved_Amount) into @AdvanceTaken
            from t015_advance 
            where Org_Id = var_Org_Id 
            and Is_Deleted = 0 
            and Request_For_User_Id = var_Profile_Id and 
            month(Created_On ) =  @Var_Month and @Var_Year = year(Created_On);
            
			select Org_Id,Advance_Id, ifnull(@AdvanceTaken , 00.0) as AdvanceTaken , @DeductionRemaining as DeductionRemaining ,
            AdvanceType_Id, Advance_Amount, Advance_Remark,
            MCC_Id,Is_Approved,Is_Active,Is_Deleted,
            date_format(Created_On, '%d %b %Y %h:%i %p') as Created_On
            from t015_advance 
            where Org_Id = var_Org_Id 
            and Is_Deleted = 0 
            and Request_For_User_Id = var_Profile_Id and 
            month(Created_On ) =  @Var_Month and @Var_Year = year(Created_On)
            order by Advance_Id;
            
            

	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
