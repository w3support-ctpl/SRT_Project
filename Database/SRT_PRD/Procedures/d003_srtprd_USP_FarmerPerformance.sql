-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerPerformance` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerPerformance`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Profile_Id varchar(20),
Var_StartDate varchar(20),
Var_EndDate varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
set Var_StartDate = date(STR_TO_DATE(Var_StartDate, '%m/%d/%Y'));
set Var_EndDate = date(STR_TO_DATE(Var_EndDate, '%m/%d/%Y'));


	if(Var_Method_Name = 'GetFarmerPerformance') then 
		
        set @Total_Milk = 0;
        set @Total_Milk = (select sum(Quantity) from f003_farmerperformance where Farmer_Id = Var_Profile_Id and Org_Id = Var_Org_Id and DATE_FORMAT(Performance_Month, '%Y-%m') between 
        DATE_FORMAT(Var_StartDate, '%Y-%m') and  DATE_FORMAT(Var_EndDate, '%Y-%m'));
        
        set @Total_Count = 0;
        set @Total_Count = (select count(*) from f003_farmerperformance where Farmer_Id = Var_Profile_Id and Org_Id = Var_Org_Id and DATE_FORMAT(Performance_Month, '%Y-%m') between 
        DATE_FORMAT(Var_StartDate, '%Y-%m') and  DATE_FORMAT(Var_EndDate, '%Y-%m'));
        
        set @QuantityRating = (select sum(Quantity_Score) from f003_farmerperformance where Farmer_Id = Var_Profile_Id and Org_Id = Var_Org_Id and DATE_FORMAT(Performance_Month, '%Y-%m') between 
        DATE_FORMAT(Var_StartDate, '%Y-%m') and  DATE_FORMAT(Var_EndDate, '%Y-%m')) / @Total_Count ;
        
        set @QualityRating = (select sum(Quality_Score) from f003_farmerperformance where Farmer_Id = Var_Profile_Id and Org_Id = Var_Org_Id and DATE_FORMAT(Performance_Month, '%Y-%m') between 
        DATE_FORMAT(Var_StartDate, '%Y-%m') and  DATE_FORMAT(Var_EndDate, '%Y-%m')) / @Total_Count ;
                
        set @AvgTS = (select sum(Quality) from f003_farmerperformance where Farmer_Id = Var_Profile_Id and Org_Id = Var_Org_Id and DATE_FORMAT(Performance_Month, '%Y-%m') between 
        DATE_FORMAT(Var_StartDate, '%Y-%m') and  DATE_FORMAT(Var_EndDate, '%Y-%m')) / @Total_Count ;
        
        select Farmer_Id, DATE_FORMAT(Performance_Month, '%M %Y') as  Performance_Month , Quality_Score , Quantity_Score, Quantity , Quality ,  @Total_Milk as  Total_Milk ,
        @QuantityRating as AvgQuantityRating , @QualityRating as AvgQualityRating , @AvgTS  as AvgTS
        from f003_farmerperformance where Farmer_Id = Var_Profile_Id and Org_Id = Var_Org_Id and DATE_FORMAT(Performance_Month, '%Y-%m') between 
        DATE_FORMAT(Var_StartDate, '%Y-%m') and DATE_FORMAT(Var_EndDate, '%Y-%m');


	end if;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
