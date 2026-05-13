-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCCommissionYesterday_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCCommissionYesterday_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10)
)
BEGIN
	
		set sql_mode='';
		SET SQL_SAFE_UPDATES = 0;
		-- set @Yesterday = ( SELECT CURDATE() - INTERVAL 1 DAY );
        set @Yesterday = ( SELECT date('2024-04-16') - INTERVAL 1 DAY );
        
        
        delete from bk_t009_milkcollectiondairy_mcccommission
		where Org_Id = var_Org_Id
		and MilkCollectionDairy_Id in(
		select MilkCollectionDairy_Id from t009_milkcollectiondairy_header 
		where Org_Id = var_Org_Id
		and date(Created_On) = date(@Yesterday)
		)
		and MPPIType_Id ='C047001'
		and Is_Sour_Check = 0
        and ifnull(Invoice_Id,'') ='';
		
		insert into bk_t009_milkcollectiondairy_mcccommission
		select * from t009_milkcollectiondairy_mcccommission
		where Org_Id = var_Org_Id
		and MilkCollectionDairy_Id in(
		select MilkCollectionDairy_Id from t009_milkcollectiondairy_header 
		where Org_Id = var_Org_Id
		and date(Created_On) = date(@Yesterday)
		)
		and MPPIType_Id ='C047001'
		and Is_Sour_Check = 0
        and ifnull(Invoice_Id,'') ='';
		
		delete from t009_milkcollectiondairy_mcccommission
		where Org_Id = var_Org_Id
		and MilkCollectionDairy_Id in(
		select MilkCollectionDairy_Id from t009_milkcollectiondairy_header 
		where Org_Id = var_Org_Id
		and date(Created_On) = date(@Yesterday)
		)
		and MPPIType_Id ='C047001'
		and Is_Sour_Check = 0
        and ifnull(Invoice_Id,'') ='';
       
        
		
		DROP TEMPORARY TABLE IF EXISTS temp_Report;
		CREATE TEMPORARY TABLE temp_Report ( 
		Org_Id varchar(20), MCC_Id varchar(20),
		MilkType_Id varchar(20),
		Liters decimal(30,3),Weight decimal(30,3), Fat decimal(18,3), SNF decimal(18,3));

		insert into 
		temp_Report (
		Org_Id,MCC_Id,MilkType_Id,Liters,Weight,Fat,SNF
		)
		select
		f010.Org_Id,
		f010.MCC_Id,
		f010.MilkType_Id,
		Roundoff('QuantityForDairy', (IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0))) as Liters,
		Roundoff('Quantity',(IFNULL(SUM(f010.Dairy_Quantity_Kg), 0)))  as Weight,
		Roundoff('Quality',(IFNULL((SUM(f010.Dairy_Quantity_Ltr * f010.Dairy_Fat)) / SUM(f010.Dairy_Quantity_Ltr), 0))) as Fat,
		Roundoff('Quality',(IFNULL((SUM(f010.Dairy_Quantity_Ltr * f010.Dairy_SNF)) / SUM(f010.Dairy_Quantity_Ltr), 0))) as SNF
		from f010_milkcollectionmcc_final f010
		where f010.Org_Id = var_Org_Id
		and date(f010.Collection_Date) = date(@Yesterday)
		and f010.MilkType_Id ='C011001'
		group by
		f010.Org_Id,
		f010.MCC_Id,
		f010.MilkType_Id;
		
		DROP TEMPORARY TABLE IF EXISTS temp_Report_Data;
		CREATE TEMPORARY TABLE temp_Report_Data ( 
		Org_Id varchar(20), MilkCollectionDairy_Id varchar(20),MCC_Id varchar(20),
		MPPIType_Id varchar(20),MilkType_Id varchar(20),MilkStatus_Id varchar(20),
		Liters decimal(30,3),Weight decimal(30,3), Fat decimal(18,3), SNF decimal(18,3),Rate decimal(18,3),Amount decimal(30,3));
		
		insert into temp_Report_Data(
		Org_Id,MCC_Id,MPPIType_Id,MilkType_Id,MilkStatus_Id,Liters,Weight,Fat,SNF,Rate,Amount
		)
		SELECT 
		f010.Org_Id,
		m005.MCC_Id,
		c047.MPPIType_Id,
		f010.MilkType_Id,
		c016.MilkStatus_Id,
		f010.Liters as Liters,
		f010.Weight  as Weight,
		f010.Fat as Fat,
		f010.SNF as SNF,
		ROUND(
			CASE
				WHEN f010.Liters >= m0022.MinimumQuantity
				AND f010.Liters <= m0022.MaximumQuantity
				AND f010.Fat >= m0022.MinimumFat
				AND f010.Fat <= m0022.MaximumFat
				AND f010.SNF >= m0022.MinimumSNF 
				AND f010.SNF <= m0022.MaximumSNF
			THEN
				m0022.BaseRate
			ELSE
				0
			END,
			2
		) as Rate,
		ROUND(
			CASE
				WHEN f010.Liters >= m0022.MinimumQuantity
				AND f010.Liters <= m0022.MaximumQuantity
				AND f010.Fat >= m0022.MinimumFat
				AND f010.Fat <= m0022.MaximumFat
				AND f010.SNF >= m0022.MinimumSNF 
				AND f010.SNF <= m0022.MaximumSNF
			THEN
				(m0022.BaseRate * f010.Liters) 
			ELSE
				0
			END,
			2
		) as Amount

		FROM temp_Report  f010
		INNER JOIN m005_mcc m005 ON
			m005.Org_Id = f010.Org_Id
			AND m005.MCC_Id = f010.MCC_Id
		INNER JOIN c047_mppitype c047 ON
			c047.MPPIType_Id = 'C047001'
		INNER JOIN c016_milkstatus c016 ON
			c016.MilkStatus_Id = 'C016001'
		INNER JOIN m002_commission_mcc m002 ON
			m002.Org_Id = f010.Org_Id
			AND m002.MCC_Id = f010.MCC_Id
			and m002.MPPIType_Id = 'C047001'
			AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
								inner join m002_commission m002 on 
								m002.MPPI_Id = m0021.MPPI_Id 
								and m002.Org_Id = m0021.Org_Id 
								and m002.MilkType_Id = f010.MilkType_Id 
								and m002.MPPIType_Id = m0021.MPPIType_Id
								WHERE m0021.Org_Id = var_Org_Id
								and m0021.MPPIType_Id = 'C047001'
								and m0021.MCC_Id = f010.MCC_Id
								AND m0021.Applicable_Date <= CONVERT_TZ(@Yesterday, '+00:00', '+00:00')
								order by m0021.Applicable_Date desc limit 1)
		INNER JOIN m002_commission_item m0022 ON
			m0022.Org_Id = f010.Org_Id
			and m0022.Is_Deleted = 0
			AND m0022.MPPI_Id = (SELECT m0021.MPPI_Id FROM m002_commission_mcc m0021 
								inner join m002_commission m002 on 
								m002.MPPI_Id = m0021.MPPI_Id 
								and m002.Org_Id = m0021.Org_Id 
								and m002.MilkType_Id = f010.MilkType_Id 
								and m002.MPPIType_Id = m0021.MPPIType_Id
								WHERE m0021.Org_Id = var_Org_Id
								and m0021.MPPIType_Id = 'C047001'
								and m0021.MCC_Id = f010.MCC_Id
								AND m0021.Applicable_Date <= CONVERT_TZ(@Yesterday, '+00:00', '+00:00')
								order by m0021.Applicable_Date desc limit 1)
		where f010.Org_Id = var_Org_Id
		and f010.MilkType_Id ='C011001'
		GROUP BY
		f010.Org_Id,
		m005.MCC_Id,
		c047.MPPIType_Id,
		f010.MilkType_Id,
		c016.MilkStatus_Id,
		m0022.MinimumQuantity,
		m0022.MaximumQuantity,
		m0022.MinimumFat,
		m0022.MaximumFat,
		m0022.MinimumSNF,
		m0022.MaximumSNF;
		
		

		DROP TEMPORARY TABLE IF EXISTS temp_results;

		-- Create a temporary table to store the results
		CREATE TEMPORARY TABLE temp_results (
			Org_Id VARCHAR(20),
			MCC_Id VARCHAR(20),
			MilkCollectionDairy_Id VARCHAR(20)
		);
		INSERT INTO temp_results (Org_Id,MCC_Id)
		select Org_Id, MCC_Id  from f010_milkcollectionmcc_final
		where Org_Id = var_Org_Id
		and date(Collection_Date) = date(@Yesterday)
		group by Org_Id,MCC_Id;
        
	

		Update temp_results tmp
		inner join f010_milkcollectionmcc_final f010 on 
		tmp.Org_Id = f010.Org_Id and tmp.MCC_Id = f010.MCC_Id
		and date(f010.Collection_Date) = date(@Yesterday)
		set tmp.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
		where ifnull(tmp.MilkCollectionDairy_Id,'') = '';

        
		Update temp_Report_Data tmp
		inner join temp_results f010 on 
		tmp.Org_Id = f010.Org_Id and tmp.MCC_Id = f010.MCC_Id
		set tmp.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
		where ifnull(tmp.MilkCollectionDairy_Id,'') = '';
		
            
     if (var_Method_Name = 'Create_Commission') then  
		begin    
			DECLARE done INT DEFAULT FALSE;
			DECLARE New_MilkCollectionMCCCommission_Id VARCHAR(20);
			DECLARE Year_Id VARCHAR(20);
			DECLARE var_Org_Id VARCHAR(10);
			DECLARE var_MilkCollectionDairy_Id VARCHAR(20);
			DECLARE var_MCC_Id VARCHAR(20);
			DECLARE var_MPPIType_Id VARCHAR(20);
			DECLARE var_CollectionShift_Id VARCHAR(20);
			DECLARE var_MilkType_Id VARCHAR(20);
			DECLARE var_MilkStatus_Id VARCHAR(20);
			DECLARE var_Liters DECIMAL(20, 3);
			DECLARE var_Weight DECIMAL(20, 3);
			DECLARE var_Fat DECIMAL(8, 2);
			DECLARE var_SNF DECIMAL(8, 2);
			DECLARE var_Rate DECIMAL(20, 2);
			DECLARE var_Amount DECIMAL(20, 2);
            
            DECLARE cur CURSOR FOR
			-- Your select query here
				
				select 
				Org_Id as var_Org_Id,
                MilkCollectionDairy_Id as var_MilkCollectionDairy_Id,
                MCC_Id as var_MCC_Id, 
				MPPIType_Id as var_MPPIType_Id,
                ''as var_CollectionShift_Id ,
				MilkType_Id as var_MilkType_Id,
                MilkStatus_Id as var_MilkStatus_Id,
                Liters as var_Liters,
                Weight as var_Weight,
				Fat as var_Fat,
                SNF as var_SNF,
                Rate as var_Rate,
                Amount as var_Amount
				from temp_Report_Data
				where Amount <> 0;


			-- Declare continue handler for cursor
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
				
			-- Open cursor
			OPEN cur;
			
			-- Loop to fetch and insert data
			myLoop: LOOP
				-- Fetch data into variables
				
				FETCH cur INTO var_Org_Id,var_MilkCollectionDairy_Id,var_MCC_Id,
				var_MPPIType_Id ,var_CollectionShift_Id ,
				var_MilkType_Id,var_MilkStatus_Id,var_Liters,var_Weight,var_Fat,var_SNF,var_Rate,var_Amount;

				-- Check if there is no more data
				IF done THEN
					LEAVE myLoop;
				END IF;
                
				-- Generate a new Entry_Id
				SET Year_Id = RIGHT(LEFT(@Yesterday, 4), 2);
              
				CALL USP_Number_Range('t009_milkcollectiondairy_mcccommission', Year_Id, 'T009', '', New_MilkCollectionMCCCommission_Id);
				
                
				-- Insert data into the table
				INSERT INTO t009_milkcollectiondairy_mcccommission (
					Org_Id, MilkCollectionMCCCommission_Id, MilkCollectionDairy_Id, 
					MCC_Id, MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
					Liters,Weight,SNF,Fat,BaseRate,Amount
					
				) VALUES (
					var_Org_Id,New_MilkCollectionMCCCommission_Id,var_MilkCollectionDairy_Id,
					var_MCC_Id,var_MPPIType_Id,var_CollectionShift_Id,var_MilkType_Id,var_MilkStatus_Id,
					var_Liters,var_Weight,var_SNF,var_Fat,var_Rate,var_Amount
				);
				SET @MusterType_Id = '';
				SET @MusterType_Id = (SELECT m005.MusterType_Id
										FROM m005_mcc_version m005
										WHERE m005.MCC_Id = var_MCC_Id AND m005.Is_Deleted = 0
										AND m005.Org_Id = var_Org_Id
										AND date(m005.Applicable_Date) <= date(@Yesterday)
										ORDER BY m005.Applicable_Date DESC LIMIT 1);
				SET @MusterType = '';
				SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id);
				
				IF (@MusterType = 1) THEN

					SET @MusterCycle_StartDate = date(@Yesterday);
					SET @MusterCycle_EndDate = date(@Yesterday);

				ELSEIF (@MusterType = 7) THEN

					IF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 1 AND 7) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-01');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-07');

					ELSEIF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 8 AND 14) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-08');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-14');

					ELSEIF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 15 AND 21) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-15');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-21');

					ELSEIF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 16 AND 31) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-16');
						SET @MusterCycle_EndDate = LAST_DAY(date(@Yesterday));

					END IF;

				ELSEIF (@MusterType = 15) THEN

					IF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 1 AND 15) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-01');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-15');

					ELSE

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-16');
						SET @MusterCycle_EndDate = LAST_DAY(date(@Yesterday));

					END IF;

				ELSEIF (@MusterType = 5) THEN

					IF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 1 AND 5) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-01');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-05');

					ELSEIF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 6 AND 10) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-06');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-10');

					ELSEIF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 11 AND 15) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-11');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-15');

					ELSEIF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 16 AND 20) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-16');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-20');

					ELSEIF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 21 AND 25) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-21');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-25');
					ELSEIF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 26 AND 31) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-26');
						SET @MusterCycle_EndDate = LAST_DAY(date(@Yesterday));

					END IF;

				ELSEIF (@MusterType = 10) THEN

					IF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 1 AND 10) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-01');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-10');

					ELSEIF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 11 AND 20) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-11');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-20');

					ELSEIF (DATE_FORMAT(date(@Yesterday), '%d') BETWEEN 21 AND 31) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-21');
						SET @MusterCycle_EndDate = LAST_DAY(date(@Yesterday));

					END IF;

				ELSEIF (@MusterType = 30) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Yesterday), '%Y-%m-01');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Yesterday));

				END IF;
				
				UPDATE  t009_milkcollectiondairy_mcccommission t009
				SET 
				t009.MusterType_Id = @MusterType_Id,
				t009.MusterCycle_StartDate = @MusterCycle_StartDate,
				t009.MusterCycle_EndDate = @MusterCycle_EndDate
				WHERE t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionMCCCommission_Id = New_MilkCollectionMCCCommission_Id;
				
			
				
			END LOOP;

			-- Close cursor
			CLOSE cur;
			
			SELECT 1 AS Result_Id, 
			'Locked' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
