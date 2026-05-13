-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMilkRate_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMilkRate_Get`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Date varchar(20),
Var_Milk_Type_Id Varchar(20),
Var_Milk_FAT varchar(10),
Var_Milk_SNF varchar(20),
Var_Profile_Id varchar(20),
Var_Collection_Shift varchar(20)

)
proc_Exit: BEGIN

	set @Current_Datetime = (SELECT CONVERT_TZ(Var_Date, '+00:00', '+00:00'));
    
	If(Var_Method_Name = 'GetMilkRate') then 

			Set @ChartId = ( select Chart_Id from f002_milk_rate_current where Header_Applicable_Date <= @Current_Datetime and 
			MCC_Id = Var_MCC_Id and CollectionShift_Id = Var_Collection_Shift 
			and MilkType_Id = Var_Milk_Type_Id
			order by Header_Applicable_Date desc limit 1 );
            
			SELECT Amount, Base_FAT , Base_SNF into @Milk_Base_Rate , @Milk_Base_FAT , @Milk_Base_SNF FROM f002_milk_rate_current 
			where MCC_Id = Var_MCC_Id and MilkType_Id = Var_Milk_Type_Id and CollectionShift_Id = Var_Collection_Shift  and chart_id = @ChartId
			and MilkRateEntryType_Id = 'C012001' and Item_Applicable_Date < @Current_Datetime order by Item_Applicable_Date desc limit 1; 

        -- GetMilkBaseRate('', '', '', '', '');
		set @Total_Milk_Amout =  GetMilkRateDate(Var_Org_Id, Var_MCC_Id, Var_Collection_Shift, Var_Milk_FAT, Var_Milk_SNF, Var_Milk_Type_Id , Var_Date);
           
       select if(@Total_Milk_Amout is null , -1 , 1 ) as Result_Id, if(@Total_Milk_Amout is null , 'Rate Not Maintained' , 'Ok' ) as Result_Description, ifnull(ROUND(@Milk_Base_Rate), 0.0) as Base_Rate , 
       ifnull(ROUND(@Total_Milk_Amout , 2), 0.0 ) as Total_Milk_Amout ,  
       CAST(ifnull(Var_Milk_FAT, 0) AS DECIMAL(10, 2))  AS Milk_FAT , 
       CAST(ifnull(Var_Milk_SNF, 0) AS DECIMAL(10, 2))  AS Milk_SNF;
       
		select -1 as Result_Id, 'Low Quality' as Result_Description, ifnull(ROUND(@Milk_Base_Rate), 0.0) as Base_Rate , ifnull(ROUND(@Total_Milk_Amout , 2), 0.0 ) as Total_Milk_Amout ,  Var_Milk_FAT AS Milk_FAT , Var_Milk_SNF AS Milk_SNF;

    
    ELSEIF(Var_Method_Name = 'GetMilkRateSlab')THEN 
		
	
	set sql_mode = '';
    
   Set @minfatCw = 0 ; set @maxfatCw = 0 ; 
   set @minsnfCw = 0 ; set @MaxsnfCw = 0;
   set @minfatBf = 0 ; set @maxfatBf = 0;
   set @minsnfBf = 0 ;  set @maxsnfBf = 0 ;
   
        
	Set @ChartIdcw = ( select Chart_Id from f002_milk_rate_current where Header_Applicable_Date <= now() and 
	MCC_Id = Var_MCC_Id  and CollectionShift_Id = Var_Collection_Shift
	and MilkType_Id = 'C011001'
	order by Header_Applicable_Date desc limit 1 );
    
	Set @ChartIdbf= ( select Chart_Id from f002_milk_rate_current where Header_Applicable_Date <= now() and 
	MCC_Id = Var_MCC_Id  and CollectionShift_Id = Var_Collection_Shift
	and MilkType_Id = 'C011002'
	order by Header_Applicable_Date desc limit 1 );
    

SELECT MIN(Slab_Min) , MAX(Slab_Max) into @minfatCw , @maxfatCw FROM m001_milkrate_item M001
INNER JOIN m014_slab M014 ON M001.Slab_Id = M014.Slab_Id
INNER JOIN c012_milkrateentrytype C012 ON M001.MilkRateEntryType_Id = C012.MilkRateEntryType_Id
WHERE M001.Chart_Id = @ChartIdcw and (C012.MilkRateEntryType_Id in ('C012004' , 'C012002'))
GROUP BY M001.Chart_Id ;


SELECT MIN(Slab_Min) , MAX(Slab_Max) into @minsnfCw , @maxsnfCw FROM m001_milkrate_item M001
INNER JOIN m014_slab M014 ON M001.Slab_Id = M014.Slab_Id
INNER JOIN c012_milkrateentrytype C012 ON M001.MilkRateEntryType_Id = C012.MilkRateEntryType_Id
WHERE M001.Chart_Id = @ChartIdcw and (C012.MilkRateEntryType_Id in ('C012003' , 'C012005'))
GROUP BY M001.Chart_Id;


SELECT MIN(Slab_Min) , MAX(Slab_Max) into @minfatBf , @maxfatBf FROM m001_milkrate_item M001
INNER JOIN m014_slab M014 ON M001.Slab_Id = M014.Slab_Id
INNER JOIN c012_milkrateentrytype C012 ON M001.MilkRateEntryType_Id = C012.MilkRateEntryType_Id
WHERE M001.Chart_Id = @ChartIdbf and (C012.MilkRateEntryType_Id in ('C012004' , 'C012002'))
GROUP BY M001.Chart_Id ;

SELECT MIN(Slab_Min) , MAX(Slab_Max) into @minsnfBf , @maxsnfBf FROM m001_milkrate_item M001
INNER JOIN m014_slab M014 ON M001.Slab_Id = M014.Slab_Id
INNER JOIN c012_milkrateentrytype C012 ON M001.MilkRateEntryType_Id = C012.MilkRateEntryType_Id
WHERE M001.Chart_Id = @ChartIdbf and (C012.MilkRateEntryType_Id in ('C012003' , 'C012005'))
GROUP BY M001.Chart_Id;

            
            
	select CAST(ifnull(@minfatCw , 0) AS DECIMAL(10, 2))  as Minfatcow , 
	CAST(ifnull(@maxfatCw , 0) AS DECIMAL(10, 2))    as Maxfatcow, 
	CAST(ifnull( @minsnfCw , 0) AS DECIMAL(10, 2))    as MinSnfcow, 
	CAST(ifnull(@maxsnfCw , 0) AS DECIMAL(10, 2))   as MaxSnfCow, 
	CAST(ifnull(@minfatBf , 0) AS DECIMAL(10, 2))   as MinFatBuffalo ,
	CAST(ifnull(@maxfatBf , 0) AS DECIMAL(10, 2))  as MaxFatBuffalo , 
	CAST(ifnull( @minsnfBf , 0) AS DECIMAL(10, 2))  as MinSnfBuffalo , 
	CAST(ifnull(@maxsnfBf, 0) AS DECIMAL(10, 2))    as MaxSnfBuffalo;
            
            
    
    
     end if ;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
