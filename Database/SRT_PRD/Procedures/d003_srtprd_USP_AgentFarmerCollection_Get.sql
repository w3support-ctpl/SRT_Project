-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerCollection_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerCollection_Get`(
	var_Method_Name varchar(255),
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
            
            SET @var_Start_Date = STR_TO_DATE(var_StartDate, '%m/%d/%Y');
            SET @var_End_Date = STR_TO_DATE(var_EndDate, '%m/%d/%Y');
            
			
            set @setIs_Offline = (select Is_Offline from mu04_farmer
									where Org_Id = var_Org_Id
									AND Farmer_Id = Var_Farmer_Id );
                                    
			if(@setIs_Offline = 0) then
			
				set @TotalCount = (SELECT count(*)  FROM t005_milkcollectionfarmer t005 
				WHERE
					t005.Org_Id = var_Org_Id
					AND t005.Is_Deleted = 0 
                    -- and 
					-- t005.Created_On between @var_Start_Date and DATE_ADD(@var_End_Date, INTERVAL 0 DAY)
                    and date(t005.Created_On) >= date(@var_Start_Date)
                    and date(t005.Created_On) <= date(@var_End_Date)
					AND t005.Farmer_Id = Var_Farmer_Id ) ;
				
				set @AvgFat = (SELECT sum(t005.Fat)  FROM t005_milkcollectionfarmer t005 WHERE
				t005.Org_Id = var_Org_Id
					AND t005.Is_Deleted = 0 
                    -- and 
					-- t005.Created_On between @var_Start_Date and DATE_ADD(@var_End_Date, INTERVAL 0 DAY)
                    and date(t005.Created_On) >= date(@var_Start_Date)
                    and date(t005.Created_On) <= date(@var_End_Date)
					AND t005.Farmer_Id = Var_Farmer_Id )/ @TotalCount ;
					
					
			  set @AvgSnf = (SELECT sum(t005.SNF)  FROM t005_milkcollectionfarmer t005  WHERE
					t005.Org_Id = var_Org_Id
					AND t005.Is_Deleted = 0 
                    -- and 
					-- t005.Created_On between @var_Start_Date and DATE_ADD(@var_End_Date, INTERVAL 0 DAY)
                    and date(t005.Created_On) >= date(@var_Start_Date)
                    and date(t005.Created_On) <= date(@var_End_Date)
					AND t005.Farmer_Id = Var_Farmer_Id ) / @TotalCount ;    
					
				
			SELECT sum(t005.Quantity_Ltr) , sum(t005.Quantity_Kg) into @TotalQuantity_Ltr ,  @TotalQuantity_Kg FROM t005_milkcollectionfarmer t005  WHERE
					t005.Org_Id = var_Org_Id
					AND t005.Is_Deleted = 0 
                    -- and 
					-- t005.Created_On between @var_Start_Date and DATE_ADD(@var_End_Date, INTERVAL 0 DAY)
                    and date(t005.Created_On) >= date(@var_Start_Date)
                    and date(t005.Created_On) <= date(@var_End_Date)
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
				AND t005.Is_Deleted = 0 
                -- and 
				-- date(t005.Created_On) between @var_Start_Date and DATE_ADD(@var_End_Date, INTERVAL 0 DAY)
                and date(t005.Created_On) >= date(@var_Start_Date)
				and date(t005.Created_On) <= date(@var_End_Date)
				AND t005.Farmer_Id = Var_Farmer_Id  ;
                
			elseif(@setIs_Offline = 1) then
            
				set @TotalCount = (SELECT count(*)  FROM t103_milkcollectionfarmer_offline t005 
				WHERE
					t005.Org_Id = var_Org_Id
					AND t005.Is_Deleted = 0 
                    -- and 
					-- t005.Created_On between @var_Start_Date and DATE_ADD(@var_End_Date, INTERVAL 0 DAY)
                    and date(t005.Created_On) >= date(@var_Start_Date)
                    and date(t005.Created_On) <= date(@var_End_Date)
					AND t005.Farmer_Id = Var_Farmer_Id ) ;
				
				set @AvgFat = (SELECT sum(t005.Fat)  FROM t103_milkcollectionfarmer_offline t005 WHERE
				t005.Org_Id = var_Org_Id
					AND t005.Is_Deleted = 0 
                    -- and 
					-- t005.Created_On between @var_Start_Date and DATE_ADD(@var_End_Date, INTERVAL 0 DAY)
                    and date(t005.Created_On) >= date(@var_Start_Date)
                    and date(t005.Created_On) <= date(@var_End_Date)
					AND t005.Farmer_Id = Var_Farmer_Id )/ @TotalCount ;
					
					
			  set @AvgSnf = (SELECT sum(t005.SNF)  FROM t103_milkcollectionfarmer_offline t005  WHERE
					t005.Org_Id = var_Org_Id
					AND t005.Is_Deleted = 0 
                    -- and 
					-- t005.Created_On between @var_Start_Date and DATE_ADD(@var_End_Date, INTERVAL 0 DAY)
                    and date(t005.Created_On) >= date(@var_Start_Date)
                    and date(t005.Created_On) <= date(@var_End_Date)
					AND t005.Farmer_Id = Var_Farmer_Id ) / @TotalCount ;    
					
				
			SELECT sum(t005.Quantity_Ltr) , sum(t005.Quantity_Kg) into @TotalQuantity_Ltr ,  @TotalQuantity_Kg FROM t103_milkcollectionfarmer_offline t005  WHERE
					t005.Org_Id = var_Org_Id
					AND t005.Is_Deleted = 0 
                    -- and 
					-- t005.Created_On between @var_Start_Date and DATE_ADD(@var_End_Date, INTERVAL 0 DAY)
                    and date(t005.Created_On) >= date(@var_Start_Date)
                    and date(t005.Created_On) <= date(@var_End_Date)
					AND t005.Farmer_Id = Var_Farmer_Id ;
				
				SELECT t005.Org_Id,t005.FarmerCollection_Id, t004.CollectionShift_Id,
				t005.MCC_Id,t005.Farmer_Id,t005.MilkType_Id,t005.MilkStatus_Id,
				t005.Quantity_Ltr, t005.Quantity_Kg, t005.Fat,t005.SNF,
				t005.ApplicableRate,t005.Amount,t005.EntryTime,
				@TotalQuantity_Ltr as TotalQuantity_Ltr ,  @TotalQuantity_Kg as TotalQuantity_Kg ,
				@AvgSnf  as AvgSnf , @AvgFat AS AvgFat ,
				date_format(t005.Created_On, '%e %M %Y') as Collection_Date
				FROM
				t103_milkcollectionfarmer_offline t005 
				inner join t102_mcccollectionshift_offline t004 on t005.Org_Id = t004.Org_Id and 
				t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id WHERE
				t005.Org_Id = var_Org_Id
				AND t005.Is_Deleted = 0 
                -- and 
				-- date(t005.Created_On) between @var_Start_Date and DATE_ADD(@var_End_Date, INTERVAL 0 DAY)
                and date(t005.Created_On) >= date(@var_Start_Date)
				and date(t005.Created_On) <= date(@var_End_Date)
				AND t005.Farmer_Id = Var_Farmer_Id  ;

				
			end if;
            
		end;
	elseif (var_Method_Name = 'GetMusterAmount') then
		begin
			DECLARE var_Start_Date DATE;
            DECLARE var_End_Date DATE;
            
            SET @var_Start_Date = STR_TO_DATE(var_StartDate, '%m/%d/%Y');
            SET @var_End_Date = STR_TO_DATE(var_EndDate, '%m/%d/%Y');
            
            
            set @MCC_Id = (select MCC_Id from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = Var_Farmer_Id limit 1);
            
            set @setIs_Offline = (select Is_Offline from mu04_farmer
									where Org_Id = var_Org_Id
									AND Farmer_Id = Var_Farmer_Id );
                                    
                                    
			
			if(@setIs_Offline = 0) then
            
            
				SELECT SUM(Amount) AS Amount FROM (
            select 
			COALESCE(SUM(IFNULL(t005.Amount, 0)), 0)as Amount 
			from t005_milkcollectionfarmer t005
			inner join m005_mcc m005 on
			m005.Org_Id = t005.Org_Id
			and m005.MCC_Id = t005.MCC_Id
			and m005.MCCType_Id in('C014001','C014002')
			and m005.MCCWorkType_Id = 'C023002'
			where t005.Org_Id = var_Org_Id
			and t005.MCC_Id = @MCC_Id
			and t005.Farmer_Id = Var_Farmer_Id
			and date(t005.Created_On) >= date(@var_Start_Date)
			and date(t005.Created_On) <= date(@var_End_Date)
			and t005.Is_InvoiceCreated = 0
			and t005.Is_Check = 0

			union all

			select COALESCE(SUM(IFNULL(f010.MilkPrice, 0)), 0)as Amount from f010_milkcollectionmcc_final f010
			inner join m005_mcc m005 on
			m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id
			and m005.MCCType_Id in('C014001','C014002')
			and m005.MCCWorkType_Id = 'C023001'
			where f010.Org_Id = var_Org_Id
			and f010.MCC_Id = @MCC_Id
			and date(f010.Collection_Date) >= date(@var_Start_Date)
			and date(f010.Collection_Date) <= date(@var_End_Date)
			and f010.Is_OutsideInvoiceCreated = 0
			and f010.Is_OutsideCheck = 0

			union all

			select COALESCE(SUM(IFNULL(f010.MilkPrice, 0)), 0)as Amount from f010_milkcollectionmcc_final f010
			inner join m005_mcc m005 on
			m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id
			and m005.MCCType_Id in('C014003')
			where f010.Org_Id = var_Org_Id
			and f010.MCC_Id = @MCC_Id
			and date(f010.Collection_Date) >= date(@var_Start_Date)
			and date(f010.Collection_Date) <= date(@var_End_Date)
			and f010.Is_OutsideInvoiceCreated = 0
			and f010.Is_OutsideCheck = 0
            ) AS subquery;
            
            elseif(@setIs_Offline = 1) then
			
			SELECT SUM(Amount) AS Amount FROM (
            select 
			COALESCE(SUM(IFNULL(t005.Amount, 0)), 0)as Amount 
			from t103_milkcollectionfarmer_offline t005
			inner join m005_mcc m005 on
			m005.Org_Id = t005.Org_Id
			and m005.MCC_Id = t005.MCC_Id
			where t005.Org_Id = var_Org_Id
			and t005.MCC_Id = @MCC_Id
			and t005.Farmer_Id = Var_Farmer_Id
			and date(t005.Created_On) >= date(@var_Start_Date)
			and date(t005.Created_On) <= date(@var_End_Date)
			and t005.Is_InvoiceCreated = 0
			and t005.Is_Check = 0
            ) AS subquery;
            
            end if;
            
            
		end;
	End if ;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
