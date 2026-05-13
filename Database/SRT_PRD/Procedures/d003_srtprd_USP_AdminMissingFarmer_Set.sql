-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMissingFarmer_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMissingFarmer_Set`(
	var_Method_Name varchar(20),
	var_Org_Id varchar(20),
	var_User_Id varchar(20),
	var_User_Name varchar(100),
	var_Farmer_Id varchar(20),
	var_Weight varchar(45),
	var_SNF varchar(45),
    var_Fat varchar(45),
	var_MilkType_Id varchar(20),
    var_MilkStatus_Id varchar(20),
    var_Date varchar(60),
    var_CollectionShift_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			declare	var_Quantity_Auto_Flag int;
			declare var_Quality_Auto_Flag int ;
            declare set_Current_Datetime datetime;
            
			set var_Quantity_Auto_Flag = 0;
        	set var_Quality_Auto_Flag = 0;
            
			set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
			set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
			set @Year_Id = (select right(left(date(@Current_Datetime),4),(2)));
            
            set @MCC_Id = (select MCC_Id 
				from mu04_farmer
				where Org_Id = var_Org_Id 
				and Farmer_Id = var_Farmer_Id);
               
            set @Agent_Id = (
			SELECT Agent_Id FROM m005_mcc 
			where MCC_Id = @MCC_Id and Org_Id = var_Org_Id);
            
         
           
            set @Agent_Name = (
			SELECT Agent_Name FROM mu05_agent 
			where Agent_Id = @Agent_Id and Org_Id = var_Org_Id);
            
		
                
			set @var_MCCCollectionShift_Id = (select MCCCollectionShift_Id 
				from t004_mcccollectionshift 
				where Org_Id = var_Org_Id
				and MCC_Id = @MCC_Id 
				and date(Collection_Date) = date(@Current_Datetime)
				and CollectionShift_Id = var_CollectionShift_Id limit 1);
                
                
                
                SET @MusterType_Id = (SELECT m005.MusterType_Id
											FROM m005_mcc_version m005
											WHERE MCC_Id = @MCC_Id  AND is_deleted = 0
												AND Applicable_Date <= @Current_Datetime
											ORDER BY Applicable_Date DESC LIMIT 1);

				SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id);

			
                
                IF (@MusterType = 1) THEN

					SET @MusterCycle_StartDate = @Current_Datetime;
					SET @MusterCycle_EndDate = @Current_Datetime;

				ELSEIF (@MusterType = 7) THEN

					IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 7) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-07');

					ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 8 AND 14) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-08');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-14');

					ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 15 AND 21) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');

					ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 31) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
						SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

					END IF;

				ELSEIF (@MusterType = 15) THEN

					IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 15) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');

					ELSE

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
						SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

					END IF;

				ELSEIF (@MusterType = 5) THEN

					IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 5) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-05');

					ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 6 AND 10) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-06');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-10');

					ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 15) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-11');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-15');

					ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 20) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-16');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-20');

					ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 25) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-25');
					ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 26 AND 31) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-26');
						SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

					END IF;

				ELSEIF (@MusterType = 10) THEN

					IF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 10) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-10');

					ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 20) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-11');
						SET @MusterCycle_EndDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-20');

					ELSEIF (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 31) THEN

						SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-21');
						SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

					END IF;

				ELSEIF (@MusterType = 30) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Current_Datetime), '%Y-%m-01');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Current_Datetime));

				END IF;
                
				CALL USP_Number_Range('t005_milkcollectionfarmer', @Year_Id, 'T005', '', @FarmerCollection_Id);

				SET @kg_to_ltr = (SELECT Kg_To_Ltr_Farmer FROM c001_organization WHERE Org_Id = var_Org_Id);

					
				SET @Milk_Quantity_ltr = var_Weight;
                
                if(date(@Current_Datetime) < date('2024-02-06'))then
					set set_Current_Datetime = date('2024-02-06');
                else
					set set_Current_Datetime = date(@Current_Datetime);
                end if;
     
				
				set @CurrentMilkRate = GetMilkRateBackDate(var_Org_Id,@MCC_Id ,var_CollectionShift_Id,var_Fat,var_SNF,var_MilkType_Id,set_Current_Datetime);
			
                SET @Total_Milk_Amout = var_Weight * @CurrentMilkRate;
                
				INSERT INTO t005_milkcollectionfarmer 
                (Org_Id, FarmerCollection_Id, MCC_Id, MCCCollectionShift_Id,
				Farmer_Id,
				MilkType_Id, MilkStatus_Id, Quantity_Kg, Quantity_Ltr, Fat,
				SNF, QuantityAuto_Flag, QualityAuto_Flag, ApplicableRate,
				Amount, EntryTime, Is_Active,
				Is_Deleted, Created_On, CreatedBy_Id,
				CreatedBy_Name, MusterCycle_StartDate, MusterCycle_EndDate,Is_Missing
				) VALUE
				(var_Org_Id, @FarmerCollection_Id, @MCC_Id, @var_MCCCollectionShift_Id, var_Farmer_Id,
				var_MilkType_Id, var_MilkStatus_Id, (var_Weight / @kg_to_ltr), var_Weight, 
				CAST(var_Fat AS DECIMAL(8,2)) , CAST(var_SNF AS DECIMAL(8,2)) ,
				var_Quantity_Auto_Flag, var_Quality_Auto_Flag,
				@CurrentMilkRate, @Total_Milk_Amout, CONVERT_TZ(var_Date, '+00:00', '+00:00'), 1, 0, CONVERT_TZ(var_Date, '+00:00', '+00:00'), var_User_Id,
				(SELECT Agent_Name FROM mu05_agent WHERE Org_Id = var_Org_Id AND Agent_Id = @Agent_Id LIMIT 1),
				@MusterCycle_StartDate, @MusterCycle_EndDate,1);
                
                
                SELECT 1 AS Result_Id, 
				'Create' AS Result_Description, 
				@FarmerCollection_Id AS Result_Extra_Key;
				
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
