-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerCollection_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerCollection_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
    var_StartDate varchar(20),
    var_EndDate varchar(20)
)
BEGIN

	if (var_Method_Name= 'GetDashboard')then

    set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    
	select MCC_Id into @MCC_Id from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id;
    
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
        
			
            Set @ChartId = ( select Chart_Id from f002_milk_rate_current where Header_Applicable_Date <= now() and 
			MCC_Id = @MCC_Id  and CollectionShift_Id = @CollectionShift_Id 
			and MilkType_Id = 'C011001' and  MilkRateEntryType_Id = 'C012001'
			order by Header_Applicable_Date desc , Item_Applicable_Date desc  limit 1 ); 
			
            
        
			SELECT IFNULL(Amount, '00') into @Today_Rate 
			FROM f002_milk_rate_current WHERE Org_Id = var_Org_Id AND MCC_Id = @MCC_Id  AND CollectionShift_Id =  @CollectionShift_Id
			AND MilkRateEntryType_Id = 'C012001'  and Chart_Id =  @ChartId
            order by Item_Applicable_Date desc limit 1;
            
        
			-- Use the CTE value in the second query
            if(select count(*)
			from t005_milkcollectionfarmer t005 where t005.Is_Active = 1 and 
			t005.Org_Id = var_Org_Id AND t005.Is_Deleted = 0
			AND t005.Farmer_Id = var_Profile_Id and date(Created_On) = date(@Current_Datetime) > 0 ) then 
				
			select t005.FarmerCollection_Id , @Today_Rate  as Today_Rate  , t005.Fat , t005.SNF , Quantity_Kg , Quantity_Ltr , 1 as Datacount
			from t005_milkcollectionfarmer t005 where t005.Is_Active = 1 and 
			t005.Org_Id = var_Org_Id AND t005.Is_Deleted = 0
			AND t005.Farmer_Id = var_Profile_Id and date(Created_On) = date(@Current_Datetime) ;
		
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
				AND t005.Farmer_Id = var_Profile_Id ) ;
            
            set @AvgFat = (SELECT sum(t005.Fat)  FROM t005_milkcollectionfarmer t005 WHERE
			t005.Org_Id = var_Org_Id
				AND t005.Is_Deleted = 0 and 
                t005.Created_On between var_Start_Date and DATE_ADD(var_End_Date, INTERVAL 1 DAY)
				AND t005.Farmer_Id = var_Profile_Id )/ @TotalCount ;
                
          set @AvgSnf = (SELECT sum(t005.SNF)  FROM t005_milkcollectionfarmer t005  WHERE
				t005.Org_Id = var_Org_Id
				AND t005.Is_Deleted = 0 and 
                t005.Created_On between var_Start_Date and DATE_ADD(var_End_Date, INTERVAL 1 DAY)
				AND t005.Farmer_Id = var_Profile_Id ) / @TotalCount ;    
                
			
		SELECT sum(t005.Quantity_Ltr) , sum(t005.Quantity_Kg) into @TotalQuantity_Ltr ,  @TotalQuantity_Kg FROM t005_milkcollectionfarmer t005  WHERE
				t005.Org_Id = var_Org_Id
				AND t005.Is_Deleted = 0 and 
                t005.Created_On between var_Start_Date and DATE_ADD(var_End_Date, INTERVAL 1 DAY)
				AND t005.Farmer_Id = var_Profile_Id ;
            
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
			AND t005.Farmer_Id = var_Profile_Id  ;
            
            
		end;
	elseif(var_Method_Name = 'GetMusterCycle') then 
		begin 
			set @var_MCC_Id = (
								select MCC_Id from mu04_farmer
								where Farmer_Id = var_Profile_Id limit 1
								);
                                
		SET @MusterType_Id = '';
        SET @MusterType_Id = (SELECT m005.MusterType_Id
									FROM m005_mcc_version m005
									WHERE m005.MCC_Id = @var_MCC_Id AND m005.Is_Deleted = 0
									AND m005.Org_Id = var_Org_Id
									AND m005.Applicable_Date <= now()
									ORDER BY m005.Applicable_Date DESC LIMIT 1);
         
         SET @MusterType = '';
		SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id); 
            
            IF (@MusterType = 1) THEN

				SET @MusterCycle_StartDate = now();
				SET @MusterCycle_EndDate = now();

			ELSEIF (@MusterType = 7) THEN

				IF (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 7) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-07');

				ELSEIF (DATE_FORMAT(now(), '%d') BETWEEN 8 AND 14) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-08');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-14');

				ELSEIF (DATE_FORMAT(now(), '%d') BETWEEN 15 AND 21) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-15');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-21');

				ELSEIF (DATE_FORMAT(now(), '%d') BETWEEN 16 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(date(now()));

				END IF;

			ELSEIF (@MusterType = 15) THEN

				IF (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-15');

				ELSE

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(date(now()));

				END IF;

			ELSEIF (@MusterType = 5) THEN

				IF (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 5) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-05');

				ELSEIF (DATE_FORMAT(now(), '%d') BETWEEN 6 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-06');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(now(), '%d') BETWEEN 11 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-15');

				ELSEIF (DATE_FORMAT(now(), '%d') BETWEEN 16 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-16');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(now(), '%d') BETWEEN 21 AND 25) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-21');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-25');
				ELSEIF (DATE_FORMAT(now(), '%d') BETWEEN 26 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-26');
					SET @MusterCycle_EndDate = LAST_DAY(date(now()));

				END IF;

			ELSEIF (@MusterType = 10) THEN

				IF (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(now(), '%d') BETWEEN 11 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(now()), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(now(), '%d') BETWEEN 21 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-21');
					SET @MusterCycle_EndDate = LAST_DAY(date(now()));

				END IF;

			ELSEIF (@MusterType = 30) THEN

				SET @MusterCycle_StartDate = DATE_FORMAT(date(now()), '%Y-%m-01');
				SET @MusterCycle_EndDate = LAST_DAY(date(now()));

			END IF;
            
            
            SELECT 
                ROW_NUMBER() OVER (ORDER BY MusterCycle_StartDate ASC) AS count,
                MusterCycle_StartDate,
                MusterCycle_EndDate
            FROM (
            select 
			-- ROW_NUMBER() OVER (ORDER BY t028.MusterCycle_StartDate ASC) AS count,
			t028.MusterCycle_StartDate ,t028.MusterCycle_EndDate 
			from t028_invoice_mcc t028
			inner join m005_mcc m005 on
			t028.Org_Id = m005.Org_Id
			and t028.MCC_Id = m005.MCC_Id
			and m005.MCCType_Id in('C014001','C014002')
			and m005.MCCWorkType_Id = 'C023001'
			where t028.MCC_Id  =@var_MCC_Id
			and t028.Org_Id =var_Org_Id
			group by t028.MusterCycle_StartDate ,t028.MusterCycle_EndDate
			-- order by t028.MusterCycle_StartDate asc
            
            union all

			select 
			-- ROW_NUMBER() OVER (ORDER BY t028.MusterCycle_StartDate ASC) AS count,
			t028.MusterCycle_StartDate ,t028.MusterCycle_EndDate 
			from t028_invoice_mcc t028
			inner join m005_mcc m005 on
			t028.Org_Id = m005.Org_Id
			and t028.MCC_Id = m005.MCC_Id
			and m005.MCCType_Id in('C014003')
			where t028.MCC_Id  =@var_MCC_Id
			and t028.Org_Id =var_Org_Id
			group by t028.MusterCycle_StartDate ,t028.MusterCycle_EndDate
            -- order by t028.MusterCycle_StartDate asc;

			union all

			select 
			-- ROW_NUMBER() OVER (ORDER BY t005.MusterCycle_StartDate ASC) AS count,
			t005.MusterCycle_StartDate ,t005.MusterCycle_EndDate 
			from t005_milkcollectionfarmer t005
			inner join m005_mcc m005 on
			t005.Org_Id = m005.Org_Id
			and t005.MCC_Id = m005.MCC_Id
            and t005.Farmer_Id = var_Profile_Id
			and m005.MCCType_Id in('C014001','C014002')
			and m005.MCCWorkType_Id = 'C023002'
			where t005.MCC_Id  = @var_MCC_Id
			and t005.Org_Id =var_Org_Id
			group by t005.MusterCycle_StartDate ,t005.MusterCycle_EndDate
			-- order by t005.MusterCycle_StartDate asc
            
            union all
            
            select 
			t009.MusterCycle_StartDate ,t009.MusterCycle_EndDate
			from d003_srtprd.t009_milkcollectiondairy_mcccommission t009
			where t009.MCC_Id  = @var_MCC_Id
			and t009.Org_Id = var_Org_Id
			group by t009.MusterCycle_StartDate ,t009.MusterCycle_EndDate
            
            union all
            
            select 
            -- '' as count,
            @MusterCycle_StartDate as MusterCycle_StartDate,
            @MusterCycle_EndDate as MusterCycle_EndDate
            ) AS combined
            group by MusterCycle_StartDate ,MusterCycle_EndDate
            ORDER BY MusterCycle_StartDate ASC;
        end;
	End if ;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
