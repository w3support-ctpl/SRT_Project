-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerCollection` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerCollection`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
    var_StartDate varchar(20),
    var_EndDate varchar(20),
    Var_Farmer_Id varchar(20)
)
BEGIN

    set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));


	if (var_Method_Name= 'GetDashboard')then

    set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    
	select MCC_Id into @MCC_Id from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = Var_Farmer_Id;
    
	select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = @MCC_Id and Applicable_Date <= @Current_Datetime
    order by Applicable_Date desc limit 1 ;
    
     set @CollectionShift = (select count(CollectionShift_Id) from c015_collectionshift where CollectionShift_Id in 
		(select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = @MCC_Id and Version_No = @Version_No)) ;
		
        if(@CollectionShift > 1) then
			set @CollectionShift_Id = '';
			select CollectionShift_Id into @CollectionShift_Id from c015_collectionshift where CollectionShift_Id = 'C015001'  limit 1;
			
			-- if (@CollectionShift_Id is null ) then 
            
				-- set @CollectionShift_Id =( select CollectionShift_Id  from c015_collectionshift where @Current_timez <= ShiftEnd_Time limit 1) ;
			-- end if;
        else 
			set @CollectionShift_Id = ( select CollectionShift_Id from m005_mcc_collectionshift where MCC_Id = @MCC_Id and Version_No = @Version_No);
        end if ;
        
        
			SELECT IFNULL(Amount, '00') into @Today_Rate 
			FROM f002_milk_rate_current WHERE Org_Id = var_Org_Id AND MCC_Id = @MCC_Id  AND CollectionShift_Id =  @CollectionShift_Id
			AND MilkRateEntryType_Id = 'C012001' order by Item_Applicable_Date desc limit 1;
            
        
			-- Use the CTE value in the second query
            if(select count(*)
			from t005_milkcollectionfarmer t005 where t005.Is_Active = 1 and 
			t005.Org_Id = var_Org_Id AND t005.Is_Deleted = 0
			AND t005.Farmer_Id = Var_Farmer_Id and date(Created_On) = date(@Current_Datetime) > 0 ) then 
				
			select t005.FarmerCollection_Id , @Today_Rate  as Today_Rate  , t005.Fat , t005.SNF , Quantity_Kg , Quantity_Ltr , 1 as Datacount
			from t005_milkcollectionfarmer t005 where t005.Is_Active = 1 and 
			t005.Org_Id = var_Org_Id AND t005.Is_Deleted = 0
			AND t005.Farmer_Id = Var_Farmer_Id and date(Created_On) = date(@Current_Datetime) ;
		
			else 
				
			select '' as FarmerCollection_Id , @Today_Rate  as Today_Rate  , 0.0 as Fat , 
            0.0 as SNF ,  0.0 as Quantity_Kg , 0.0 as Quantity_Ltr , 0 as Datacount ;
            
			end if;
        
        elseif (var_Method_Name = 'Get') then
		begin
			DECLARE var_Start_Date DATE;
            DECLARE var_End_Date DATE;
            
            SET var_Start_Date = STR_TO_DATE(var_StartDate, '%m/%d/%Y');
            SET var_End_Date = STR_TO_DATE(var_EndDate, '%m/%d/%Y');
			
            set @TotalCount = (SELECT count(*)  FROM t005_milkcollectionfarmer t005 
            WHERE
				t005.Org_Id = var_Org_Id
				AND t005.Is_Deleted = 0 and 
                t005.Created_On between var_Start_Date and DATE_ADD(var_End_Date, INTERVAL 1 DAY)
				AND t005.Farmer_Id = Var_Farmer_Id ) ;
            
            set @AvgFat = (SELECT sum(t005.Fat)  FROM t005_milkcollectionfarmer t005 WHERE
			t005.Org_Id = var_Org_Id
				AND t005.Is_Deleted = 0 and 
                t005.Created_On between var_Start_Date and DATE_ADD(var_End_Date, INTERVAL 1 DAY)
				AND t005.Farmer_Id = Var_Farmer_Id )/ @TotalCount ;
                
          set @AvgSnf = (SELECT sum(t005.SNF)  FROM t005_milkcollectionfarmer t005  WHERE
				t005.Org_Id = var_Org_Id
				AND t005.Is_Deleted = 0 and 
                t005.Created_On between var_Start_Date and DATE_ADD(var_End_Date, INTERVAL 1 DAY)
				AND t005.Farmer_Id = Var_Farmer_Id ) / @TotalCount ;    
                
			
		SELECT sum(t005.Quantity_Ltr) , sum(t005.Quantity_Kg) into @TotalQuantity_Ltr ,  @TotalQuantity_Kg FROM t005_milkcollectionfarmer t005  WHERE
				t005.Org_Id = var_Org_Id
				AND t005.Is_Deleted = 0 and 
                t005.Created_On between var_Start_Date and DATE_ADD(var_End_Date, INTERVAL 1 DAY)
				AND t005.Farmer_Id = Var_Farmer_Id ;
            
			SELECT t005.Org_Id,t005.FarmerCollection_Id, t004.CollectionShift_Id,
			t005.MCC_Id,t005.Farmer_Id,t005.MilkType_Id,t005.MilkStatus_Id,
			t005.Quantity_Ltr, t005.Quantity_Kg, t005.Fat,t005.SNF,
			t005.ApplicableRate,t005.Amount,t005.EntryTime,
			@TotalQuantity_Ltr as TotalQuantity_Ltr ,  @TotalQuantity_Kg as TotalQuantity_Kg ,
			@AvgSnf  as AvgSnf , @AvgFat AS AvgFat ,
			date_format(t005.Created_On, '%e %M %Y') as Collection_Date
			FROM
			t005_milkcollectionfarmer t005 
			inner join t004_mcccollectionshift t004 on t005.Org_Id = t004.Org_Id and 
			t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id WHERE
			t005.Org_Id = var_Org_Id
			AND t005.Is_Deleted = 0 and 
			t005.Created_On between var_Start_Date and DATE_ADD(var_End_Date, INTERVAL 1 DAY)
			AND t005.Farmer_Id = Var_Farmer_Id  ;
            
            
		end;
	End if ;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
