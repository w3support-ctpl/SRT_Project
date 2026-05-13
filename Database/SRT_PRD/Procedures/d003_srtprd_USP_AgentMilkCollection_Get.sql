-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMilkCollection_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMilkCollection_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_MCC_Id varchar(20),
    var_Profile_Id varchar(20),
    var_StartDate varchar(20),
    var_EndDate varchar(20)
)
BEGIN

	if(var_Method_Name = 'GetMyCollection') then 
    
        set @Milk_Entry_Count = (select count(*) from t006_milkcollectionagent t006 
        inner join t006_milkcollectionagent_item t006i on t006.Org_Id = t006i.Org_Id and t006.AgentCollection_Id = t006i.AgentCollection_Id
        where t006.MCC_Id = var_MCC_Id and t006.Org_Id = var_Org_Id and t006i.Quantity_Ltr > 0 
        -- AND t006.Created_On between var_StartDate and DATE_ADD(var_EndDate, INTERVAL 0 DAY)
        and CAST(t006.Created_On  AS DATE) >= var_StartDate 
		and CAST(t006.Created_On  AS DATE)  <= var_EndDate
        );
        
        set @Avg_SNF = (select sum(SNF) from t006_milkcollectionagent t006 
        inner join t006_milkcollectionagent_item t006i on t006.Org_Id = t006i.Org_Id and t006i.Quantity_Ltr > 0 AND 
        t006.AgentCollection_Id = t006i.AgentCollection_Id
        where t006.MCC_Id = var_MCC_Id and t006.Org_Id = var_Org_Id 
        and  t006.Created_On between var_StartDate and DATE_ADD(var_EndDate, INTERVAL 0 DAY) ) / @Milk_Entry_Count ;
        
		set @Avg_FAT = (select sum(Fat) from t006_milkcollectionagent t006 
        inner join t006_milkcollectionagent_item t006i on t006.Org_Id = t006i.Org_Id and t006i.Quantity_Ltr > 0 AND 
        t006.AgentCollection_Id = t006i.AgentCollection_Id
        where t006.MCC_Id = var_MCC_Id and t006.Org_Id = var_Org_Id 
        -- and  t006.Created_On between var_StartDate and DATE_ADD(var_EndDate, INTERVAL 0 DAY) 
        and CAST(t006.Created_On  AS DATE) >= var_StartDate 
		and CAST(t006.Created_On  AS DATE)  <= var_EndDate 
        ) / @Milk_Entry_Count ;
        
        set @Total_Milk = (select sum(Quantity_Ltr) from t006_milkcollectionagent t006 
        inner join t006_milkcollectionagent_item t006i on t006.Org_Id = t006i.Org_Id and t006.AgentCollection_Id = t006i.AgentCollection_Id
        where t006.MCC_Id = var_MCC_Id and t006.Org_Id = var_Org_Id 
        -- and  t006.Created_On between var_StartDate and DATE_ADD(var_EndDate, INTERVAL 0 DAY) 
        and CAST(t006.Created_On  AS DATE) >= var_StartDate 
		and CAST(t006.Created_On  AS DATE)  <= var_EndDate
        ) ;
        
        select  ifnull(round(@Total_Milk,2),0.0)  as Total_Milk , 
        ifnull(round(@Avg_SNF,2),0.0)  as Avg_SNF , 
        ifnull(round(@Avg_FAT,2),0.0)  as Avg_FAT , 
        t006.AgentCollection_Id as Collection_Id , t004.CollectionShift_Id as CollectionShift,  Fat , SNF , Quantity_Ltr,
        Milktype_Id,
		DATE_FORMAT(t006.Created_On, '%e %M %Y')  as Deposited_Date from t006_milkcollectionagent t006 inner join
        t004_mcccollectionshift t004 on t006.Org_Id = t004.Org_Id and t004.MCCCollectionShift_Id =  t006.MCCCollectionShift_Id 
        inner join t006_milkcollectionagent_item t006i on t006.Org_Id = t006i.Org_Id and t006.AgentCollection_Id = t006i.AgentCollection_Id
        where t006.MCC_Id = var_MCC_Id and t006i.Quantity_Ltr > 0.0 AND 
        t006.Org_Id = var_Org_Id 
        -- and  t006.Created_On between var_StartDate 
        -- and var_EndDate;
        -- and DATE_ADD(var_EndDate, INTERVAL 0 DAY)
        and CAST(t006.Created_On  AS DATE) >= var_StartDate 
		and CAST(t006.Created_On  AS DATE)  <= var_EndDate; 
	
    elseif(var_Method_Name = 'GetMusterCycle') then 
		begin 
        
			
        
			/*
        
			select 
			ROW_NUMBER() OVER (ORDER BY MusterCycle_StartDate ASC) AS count,
			 MusterCycle_StartDate ,MusterCycle_EndDate 
			from t028_invoice_mcc 
			where MCC_Id  = var_MCC_Id
			and Org_Id = var_Org_Id
			group by MusterCycle_StartDate ,MusterCycle_EndDate 
			order by MusterCycle_StartDate asc;
			*/
            
		SET @MusterType_Id = '';
        SET @MusterType_Id = (SELECT m005.MusterType_Id
									FROM m005_mcc_version m005
									WHERE m005.MCC_Id = var_MCC_Id AND m005.Is_Deleted = 0
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
			where t028.MCC_Id  =var_MCC_Id
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
			where t028.MCC_Id  =var_MCC_Id
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
			and m005.MCCType_Id in('C014001','C014002')
			and m005.MCCWorkType_Id = 'C023002'
			where t005.MCC_Id  = var_MCC_Id
			and t005.Org_Id =var_Org_Id
			group by t005.MusterCycle_StartDate ,t005.MusterCycle_EndDate
			-- order by t005.MusterCycle_StartDate asc
            
            union all
            
            select 
			t009.MusterCycle_StartDate ,t009.MusterCycle_EndDate
			from d003_srtprd.t009_milkcollectiondairy_mcccommission t009
			where t009.MCC_Id  = var_MCC_Id
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
	
	end if ;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
