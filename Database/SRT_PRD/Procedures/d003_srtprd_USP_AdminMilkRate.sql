-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkRate` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkRate`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Date varchar(20),
Var_Milk_Type_Id Varchar(20),
Var_ShiftType_Id varchar(20),
Var_Profile_Id varchar(20)

)
BEGIN
	set @Current_Datetime = (SELECT CONVERT_TZ(Var_Date, '+00:00', '+00:00'));
    
	If(Var_Method_Name = 'GetMilkRate') then 
		
	set @Version_No = (select m005.Version_No from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
    Applicable_Date <= @Current_Datetime
    order by Applicable_Date desc limit 1 ) ;
    
	if( ifnull(@Version_No , 0) = 0 ) then 
    
	select -1 as Result_Flag , ifnull(ROUND(@Milk_Base_Rate), 0.0) as Base_Rate , ifnull(ROUND(@Total_Milk_Amout , 2), 0.0 ) as Total_Milk_Amout ;
	
    else
    
     set @CollectionShift = Var_ShiftType_Id;
	
    SELECT @CollectionShift;
    
       SELECT Amount, Base_FAT , Base_SNF into @Milk_Base_Rate , @Milk_Base_FAT , @Milk_Base_SNF FROM f001_milk_rate 
		where MCC_Id = Var_MCC_Id and MilkType_Id = Var_Milk_Type_Id and CollectionShift_Id = @CollectionShift_Id  
		and MilkRateEntryType_Id = 'C012001'  and Header_Applicable_Date <= @Current_Datetime and Item_Applicable_Date <= @Current_Datetime
        order by Item_Applicable_Date desc limit 1;
        
         SELECT @Milk_Base_Rate , @Milk_Base_FAT , @Milk_Base_SNF , @CollectionShift , Var_Milk_Type_Id , Var_MCC_Id  , @Current_Datetime;
        

		select @Milk_Base_Rate AS Milk_Base_Rate , @Milk_Base_FAT AS Milk_Base_FAT, 
        @Milk_Base_SNF AS Milk_Base_SNF, Slab_Name , Amount , m014.Slab_Min , m014.Slab_Max , MilkRateEntryType_Id , Item_Applicable_Date from m014_slab m014 inner join f001_milk_rate f001 on 
		m014.Org_Id = f001.Org_Id and m014.Slab_Id = f001.Slab_Id 
		where MCC_Id = Var_MCC_Id and MilkType_Id = Var_Milk_Type_Id
		and CollectionShift_Id = @CollectionShift and Item_Applicable_Date <=  @Current_Datetime  ;
	
       
	end if ;
     end if ;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
