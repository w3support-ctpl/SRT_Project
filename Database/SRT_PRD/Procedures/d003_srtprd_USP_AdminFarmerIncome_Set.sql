-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFarmerIncome_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFarmerIncome_Set`(
	var_Method_Name varchar(20),
	var_Org_Id varchar(20),
    var_Entry_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_MCCCollectionShift_Id varchar(20),
	var_MCC_Id varchar(20),
	var_Farmer_Id varchar(20),
	var_Weight varchar(45),
	var_SNF varchar(45),
    var_Fat varchar(45),
    var_Protein varchar(45),
	var_MilkType_Id varchar(20),
    var_MilkStatus_Id varchar(20),
    var_CollectionData longtext,
    var_Date varchar(60),
	var_User_Id varchar(20),
	var_User_Name varchar(100)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
    SET SQL_SAFE_UPDATES = 0;

	set @set_CollectionShift_Id =   (select CollectionShift_Id from  t004_mcccollectionshift where 
									Org_Id = var_Org_Id
									and MCCCollectionShift_Id = var_MCCCollectionShift_Id
									and MCC_Id = var_MCC_Id);
                                    
	set @set_Collection_Date = (select Collection_Date from  t004_mcccollectionshift where 
									Org_Id = var_Org_Id
									and MCCCollectionShift_Id = var_MCCCollectionShift_Id
									and MCC_Id = var_MCC_Id);
                                    
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            
			SET @kg_to_ltr = (SELECT Kg_To_Ltr_Farmer FROM c001_organization WHERE Org_Id = var_Org_Id);
			
			if exists(select Entry_Id from tm01_milkcollectionfarmer where 
						Org_Id = var_Org_Id 
						and MCC_Id = var_MCC_Id 
                        and MCCCollectionShift_Id = var_MCCCollectionShift_Id 
                        and Farmer_Id = var_Farmer_Id 
					) then
                    
			SELECT -1 AS Result_Id, 
			'Farmer data already exists' AS Result_Description, 
			'' AS Result_Extra_Key;
			
			else
            
				set Year_Id = (select right(left(curdate(),4),(2)));

				Call USP_Number_Range ('tm01_milkcollectionfarmer', Year_Id, 'TM01', '', New_Entry_Id );

				Insert Into tm01_milkcollectionfarmer
				(Org_Id,Entry_Id,MCC_Id,MCCCollectionShift_Id,Farmer_Id,MilkType_Id,
				MilkStatus_Id,Quantity_Ltr,Quantity_Kg,Fat,SNF,Protein,Collection_On,
				Created_On,CreatedBy_Id,CreatedBy_Name,
                Run_ApplicableRate)
				Values 
				(var_Org_Id,New_Entry_Id,var_MCC_Id,var_MCCCollectionShift_Id,var_Farmer_Id,var_MilkType_Id,
				var_MilkStatus_Id,var_Weight,(var_Weight / @kg_to_ltr),var_Fat,var_SNF,var_Protein,var_Date,
				now(),var_User_Id,var_User_Name,
                GetMilkRateBackDate(var_Org_Id, var_MCC_Id,@set_CollectionShift_Id , var_Fat, var_SNF,var_MilkType_Id,@set_Collection_Date)
                ); 
			
			end if;

				
                
				SELECT 1 AS Result_Id, 
				'Saved' AS Result_Description, 
				New_Entry_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Update') then
		begin
        
        SET @kg_to_ltr = (SELECT Kg_To_Ltr_Farmer FROM c001_organization WHERE Org_Id = var_Org_Id);
			
            
			Update tm01_milkcollectionfarmer
			set 
            MilkType_Id = var_MilkType_Id,
			MilkStatus_Id = var_MilkStatus_Id,
            Quantity_Ltr = var_Weight,
            Quantity_Kg = (var_Weight / @kg_to_ltr),
            Fat = var_Fat,
            SNF = var_SNF,
            Protein = var_Protein,
            Run_ApplicableRate = GetMilkRateBackDate(var_Org_Id, var_MCC_Id,@set_CollectionShift_Id , var_Fat, var_SNF,var_MilkType_Id,@set_Collection_Date)
			where Org_Id = var_Org_Id 
            and MCCCollectionShift_Id = var_MCCCollectionShift_Id
            and MCC_Id = var_MCC_Id
			and Farmer_Id = var_Farmer_Id
            and Entry_Id = var_Entry_Id;    

			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Update_Rate') then
		begin
			SET SQL_SAFE_UPDATES = 0;

			DROP TEMPORARY TABLE IF EXISTS temp_Report;
			
			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20), MCC_Id varchar(20), Fat decimal(18,3),
            SNF decimal(18,3),rate decimal(18,3),
            Collection_On datetime,CollectionShift_Id  varchar(20),MilkType_Id  varchar(20)
            );
            
            insert into temp_Report (
			 Org_Id,MCC_Id,Fat,SNF ,Collection_On,CollectionShift_Id,MilkType_Id
			 )
            select tm01.Org_Id,tm01.MCC_Id,tm01.Fat,tm01.SNF,
            date(tm01.Collection_On) as Collection_On,t004.CollectionShift_Id,tm01.MilkType_Id
			from tm01_milkcollectionfarmer tm01
			inner join t004_mcccollectionshift t004 on
			t004.Org_Id = tm01.Org_Id
			and t004.MCCCollectionShift_Id = tm01.MCCCollectionShift_Id
			and t004.MCC_Id = tm01.MCC_Id
			where tm01.MCC_Id = var_MCC_Id
            and tm01.Org_Id = var_Org_Id
			and tm01.MCCCollectionShift_Id = var_MCCCollectionShift_Id
			group by tm01.Org_Id,tm01.MCC_Id,tm01.Fat,tm01.SNF,
            tm01.MilkType_Id,
            date(tm01.Collection_On),t004.CollectionShift_Id;
            
            
            
           
            update temp_Report 
			set rate = GetMilkRateBackDate(Org_Id, MCC_Id,CollectionShift_Id, Fat, SNF,MilkType_Id,Collection_On) ;
            
            
            update tm01_milkcollectionfarmer tm01
			inner join temp_Report tmp on
			tmp.Org_Id = tm01.Org_Id
			and tmp.MCC_Id = tm01.MCC_Id
			and tmp.Fat = tm01.Fat
			and tmp.SNF = tm01.SNF
			set tm01.Run_ApplicableRate = tmp.rate
			where tm01.MCC_Id = var_MCC_Id
            and tm01.Org_Id = var_Org_Id
			and tm01.MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
			
        end;
	elseif (var_Method_Name = 'ExcelUpload') then
		begin
			Declare Year_Id varchar(10);
			Declare Set_Farmer_Id varchar(20);
            Declare Set_MCCType_Id varchar(20);
            Declare Set_MCCWorkType_Id varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            Declare New_Entry_Id varchar(20);
            SET SQL_SAFE_UPDATES = 0;
            
            DELETE FROM tm01_milkcollectionfarmer
            where Org_Id = var_Org_Id 
            and MCCCollectionShift_Id = var_MCCCollectionShift_Id
            and MCC_Id = var_MCC_Id;
            
            select MCCType_Id,MCCWorkType_Id 
            into Set_MCCType_Id, Set_MCCWorkType_Id
            from m005_mcc 
            where MCC_Id = var_MCC_Id 
            and Org_Id = var_Org_Id;
            
            
            SET @kg_to_ltr = (SELECT Kg_To_Ltr_Farmer FROM c001_organization WHERE Org_Id = var_Org_Id);
			
            
            SET row_count := extractValue(var_CollectionData,'count(//CollectionData/Farmer)');
			
            WHILE k < row_count DO
				SET k := k + 1;
                set Set_Farmer_Id = '';
				SET xpath := concat('//CollectionData/Farmer[', k, ']');
                
                set Year_Id = (select right(left(curdate(),4),(2)));
                
                select Farmer_Id into Set_Farmer_Id from mu04_farmer where Org_Id = var_Org_Id
				and MCC_Farmer_Code = extractValue(var_CollectionData, concat(xpath,'/MCC_Farmer_Code'))
				and MCC_Id = var_MCC_Id and Is_Active = 1;
                if(extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')) = 'C011001' 
                or extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')) = 'C011002'
                or extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')) = 'C011003' 
                or extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')) = 'C011004'
                ) then
                if(Set_Farmer_Id is not null and Set_Farmer_Id <> '') then
                if exists(select Entry_Id from tm01_milkcollectionfarmer where 
						Org_Id = var_Org_Id 
						and MCC_Id = var_MCC_Id 
                        and MCCCollectionShift_Id = var_MCCCollectionShift_Id 
							and Farmer_Id = Set_Farmer_Id  limit 1
						) then
                        
                        
                        set @var_Entry_Id = ( select Entry_Id from tm01_milkcollectionfarmer where 
											Org_Id = var_Org_Id 
											and MCC_Id = var_MCC_Id 
											and MCCCollectionShift_Id = var_MCCCollectionShift_Id 
											and Farmer_Id = Set_Farmer_Id 
                                            and MilkType_Id =  extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')));
                                            
                        if(Set_MCCType_Id = 'C014002' and Set_MCCWorkType_Id ='C023002')then
                        
							drop temporary table if exists temp_milkcollectionfarmer_data;
							create Temporary table temp_milkcollectionfarmer_data(
                            PKeyRowNum int, 
							Org_Id varchar(20), 
                            MCC_Id varchar(20), 
                            MCCCollectionShift_Id varchar(20), 
                            Farmer_Id varchar(20), 
							MilkType_Id varchar(20), 
							MilkStatus_Id varchar(20),
							Quantity_Ltr varchar(10),
							Fat varchar(10),
							SNF varchar(10));
                            
                            drop temporary table if exists temp_milkcollectionfarmer_data_set;
							create Temporary table temp_milkcollectionfarmer_data_set(
                            PKeyRowNum int, 
							Org_Id varchar(20), 
                            MCC_Id varchar(20), 
                            MCCCollectionShift_Id varchar(20), 
                            Farmer_Id varchar(20), 
							MilkType_Id varchar(20), 
							MilkStatus_Id varchar(20),
							Quantity_Ltr varchar(10),
							Fat varchar(10),
							SNF varchar(10));
                            
                            INSERT INTO temp_milkcollectionfarmer_data (
                            Org_Id,MCC_Id,MCCCollectionShift_Id,Farmer_Id,
                            MilkType_Id,MilkStatus_Id,Quantity_Ltr,
                            Fat,SNF)
							(select 
							Org_Id ,
                            MCC_Id,
                            MCCCollectionShift_Id,
                            Farmer_Id,
							MilkType_Id,
							MilkStatus_Id,
							Quantity_Ltr,
							Fat,
							SNF
							from tm01_milkcollectionfarmer 
							where 
							Org_Id = var_Org_Id 
							and MCC_Id = var_MCC_Id 
							and MCCCollectionShift_Id = var_MCCCollectionShift_Id 
							and Farmer_Id = Set_Farmer_Id 
							and MilkType_Id =  extractValue(var_CollectionData, concat(xpath,'/MilkType_Id'))
							union all
							select
							var_Org_Id,
                            var_MCC_Id,
                            var_MCCCollectionShift_Id,
                            Set_Farmer_Id,
							extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')),
							extractValue(var_CollectionData, concat(xpath,'/MilkStatus_Id')),
							extractValue(var_CollectionData, concat(xpath,'/Liters')),
							extractValue(var_CollectionData, concat(xpath,'/Fat')),
							extractValue(var_CollectionData, concat(xpath,'/SNF')));
                            
                            INSERT INTO temp_milkcollectionfarmer_data_set (
                            Org_Id,MCC_Id,MCCCollectionShift_Id,Farmer_Id,
                            MilkType_Id,MilkStatus_Id,Quantity_Ltr,
                            Fat,SNF)
                            (select 
							Org_Id ,
                            MCC_Id,
                            MCCCollectionShift_Id,
                            Farmer_Id,
							MilkType_Id,
							MilkStatus_Id,
							sum(Quantity_Ltr),
							(sum(Quantity_Ltr * Fat))/sum(Quantity_Ltr),
							(sum(Quantity_Ltr * SNF))/sum(Quantity_Ltr)
							from temp_milkcollectionfarmer_data
                            group by 
                            Org_Id ,
                            MCC_Id,
                            MCCCollectionShift_Id,
                            Farmer_Id,
							MilkType_Id,
							MilkStatus_Id);
                            
                            Update tm01_milkcollectionfarmer tm01
                            inner join temp_milkcollectionfarmer_data_set tm on
							tm01.Org_Id = tm.Org_Id
                            and tm01.MCC_Id = tm.MCC_Id
                            and tm01.MCCCollectionShift_Id = tm.MCCCollectionShift_Id
                            and tm01.Farmer_Id = tm.Farmer_Id
							set 
							tm01.MilkType_Id = tm.MilkType_Id,
							tm01.MilkStatus_Id = tm.MilkStatus_Id,
							tm01.Quantity_Ltr = tm.Quantity_Ltr,
							tm01.Quantity_Kg = ( tm.Quantity_Ltr / @kg_to_ltr),
							tm01.Fat = tm.Fat,
							tm01.SNF = tm.SNF,
							Protein = var_Protein
							where tm01.Org_Id = var_Org_Id 
							and tm01.MCCCollectionShift_Id = var_MCCCollectionShift_Id
							and tm01.MCC_Id = var_MCC_Id
							and tm01.Farmer_Id = Set_Farmer_Id
							and tm01.Entry_Id = @var_Entry_Id; 
                        else
							
							Update tm01_milkcollectionfarmer
								set 
								MilkType_Id = extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')),
								MilkStatus_Id = extractValue(var_CollectionData, concat(xpath,'/MilkStatus_Id')),
								Quantity_Ltr = extractValue(var_CollectionData, concat(xpath,'/Liters')),
								Quantity_Kg = (extractValue(var_CollectionData, concat(xpath,'/Liters')) / @kg_to_ltr),
								Fat = extractValue(var_CollectionData, concat(xpath,'/Fat')),
								SNF = extractValue(var_CollectionData, concat(xpath,'/SNF')),
								Protein = var_Protein
								where Org_Id = var_Org_Id 
								and MCCCollectionShift_Id = var_MCCCollectionShift_Id
								and MCC_Id = var_MCC_Id
								and Farmer_Id = Set_Farmer_Id
								and Entry_Id = @var_Entry_Id; 
                        end if;
				else
                
					Call USP_Number_Range ('tm01_milkcollectionfarmer', Year_Id, 'TM01', '', New_Entry_Id );
					
					Insert Into tm01_milkcollectionfarmer
					(Org_Id,Entry_Id,MCC_Id,MCCCollectionShift_Id,Farmer_Id,MilkType_Id,
					MilkStatus_Id,Quantity_Ltr,Quantity_Kg,Fat,SNF,Protein,Collection_On,
					Created_On,CreatedBy_Id,CreatedBy_Name)
					Values 
					(var_Org_Id,New_Entry_Id,var_MCC_Id,var_MCCCollectionShift_Id,
					Set_Farmer_Id,
					extractValue(var_CollectionData, concat(xpath,'/MilkType_Id')),
					extractValue(var_CollectionData, concat(xpath,'/MilkStatus_Id')),
					extractValue(var_CollectionData, concat(xpath,'/Liters')),
					(extractValue(var_CollectionData, concat(xpath,'/Liters')) / @kg_to_ltr),
					extractValue(var_CollectionData, concat(xpath,'/Fat')),
					extractValue(var_CollectionData, concat(xpath,'/SNF')),
					var_Protein,
					var_Date,
					now(),var_User_Id,var_User_Name); 
                
                end if;
                end if;
                end if;
			END WHILE;
            
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_MCC_Id AS Result_Extra_Key;
			
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
            DELETE FROM tm01_milkcollectionfarmer
            where Org_Id = var_Org_Id 
            and Entry_Id = var_Entry_Id;
            
            SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Delete_FarmerData') then
		begin
        
			INSERT INTO bk05_milkcollectionfarmer(
			Org_Id ,  
			FarmerCollection_Id , 
			MCC_Id ,
			MCCCollectionShift_Id ,
			Farmer_Id ,
			MilkType_Id ,
			MilkStatus_Id ,
			Quantity_Ltr ,
			Quantity_Kg ,
			Fat , 
			SNF , 
			Protein,
			QuantityAuto_Flag , 
			QualityAuto_Flag , 
			ApplicableRate , 
			Amount , 
			EntryTime,
			Is_Corrected , 
			Correction_Request_Id ,
			MusterCycle_StartDate ,
			MusterCycle_EndDate ,
			Invoice_Id ,
			Is_InvoiceCreated , 
			InvoiceCreated_On , 
			Is_Active , 
			Is_Deleted , 
			Created_On , 
			LastEdited_On , 
			CreatedBy_Id ,
			CreatedBy_Name ,
			LastEditedBy_Id ,
			LastEditedBy_Name ,
			Is_Check , 
			Anamat_Charge,
			Freight_Charge, 
			Is_FromApp )
			SELECT 
			Org_Id ,  
			FarmerCollection_Id , 
			MCC_Id ,
			MCCCollectionShift_Id ,
			Farmer_Id ,
			MilkType_Id ,
			MilkStatus_Id ,
			Quantity_Ltr ,
			Quantity_Kg ,
			Fat , 
			SNF , 
			Protein ,
			QuantityAuto_Flag , 
			QualityAuto_Flag , 
			ApplicableRate , 
			Amount , 
			EntryTime,
			Is_Corrected , 
			Correction_Request_Id ,
			MusterCycle_StartDate ,
			MusterCycle_EndDate ,
			Invoice_Id ,
			Is_InvoiceCreated , 
			InvoiceCreated_On , 
			Is_Active , 
			Is_Deleted , 
			Created_On , 
			LastEdited_On , 
			CreatedBy_Id ,
			CreatedBy_Name ,
			LastEditedBy_Id ,
			LastEditedBy_Name ,
			Is_Check , 
			Anamat_Charge , 
			Freight_Charge , 
			Is_FromApp 
			FROM t005_milkcollectionfarmer
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and MCCCollectionShift_Id = var_MCCCollectionShift_Id;
			
			DELETE from t005_milkcollectionfarmer
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            
             SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_Approval') then
		begin
        DECLARE done INT DEFAULT FALSE;
		DECLARE New_FarmerCollection_Id VARCHAR(20);
        DECLARE New_Org_Id VARCHAR(20);
        DECLARE New_MCC_Id VARCHAR(20);
        DECLARE New_MCCCollectionShift_Id VARCHAR(20);
        DECLARE New_Farmer_Id VARCHAR(20);
        DECLARE New_MilkType_Id VARCHAR(20);
        DECLARE New_MilkStatus_Id VARCHAR(20);
		DECLARE New_Quantity_Ltr DECIMAL(20, 3);
        DECLARE New_Quantity_Kg DECIMAL(20, 3);
		DECLARE New_Fat DECIMAL(8, 2);
		DECLARE New_SNF DECIMAL(8, 2);
        DECLARE New_Created_On DATETIME;
        DECLARE Year_Id VARCHAR(20);
        
        
		   DECLARE cur CURSOR FOR
			-- Your select query here
				select 
				tm01.Org_Id AS New_Org_Id,
				tm01.MCC_Id  AS New_MCC_Id,
				tm01.MCCCollectionShift_Id AS New_MCCCollectionShift_Id,
				tm01.Farmer_Id AS New_Farmer_Id,
				tm01.MilkType_Id AS New_MilkType_Id,
				tm01.MilkStatus_Id AS New_MilkStatus_Id,
                tm01.Quantity_Ltr AS New_Quantity_Ltr,
                tm01.Quantity_Kg AS New_Quantity_Kg,
				Roundoff('Quality', (tm01.Fat)) as New_Fat,
				Roundoff('Quality', (tm01.SNF)) as New_SNF,
				tm01.Collection_On as New_Created_On
				from tm01_milkcollectionfarmer tm01
				where tm01.Org_Id = var_Org_Id
				and tm01.MCC_Id = var_MCC_Id
				and tm01.MCCCollectionShift_Id = var_MCCCollectionShift_Id;

			-- Declare continue handler for cursor
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

			
			-- Open cursor
			OPEN cur;
			
			-- Loop to fetch and insert data
			myLoop: LOOP
				-- Fetch data into variables
				FETCH cur INTO New_Org_Id ,New_MCC_Id ,New_MCCCollectionShift_Id ,New_Farmer_Id ,
				 New_MilkType_Id ,New_MilkStatus_Id ,New_Quantity_Ltr ,New_Quantity_Kg ,
				 New_Fat,New_SNF ,New_Created_On ;

				-- Check if there is no more data
				IF done THEN
					LEAVE myLoop;
				END IF;

				-- Generate a new Entry_Id
				SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
				CALL USP_Number_Range('t005_milkcollectionfarmer', Year_Id, 'T005', '', New_FarmerCollection_Id);
				
				-- Insert data into the table
				INSERT INTO t005_milkcollectionfarmer (
					Org_Id, FarmerCollection_Id,MCC_Id,MCCCollectionShift_Id,
                    Farmer_Id,MilkType_Id,MilkStatus_Id,Quantity_Ltr,Quantity_Kg,
                    Fat,SNF,Created_On,CreatedBy_Id,CreatedBy_Name,
                    LastEdited_On,LastEditedBy_Id,LastEditedBy_Name
				) VALUES (
					New_Org_Id,New_FarmerCollection_Id,New_MCC_Id,New_MCCCollectionShift_Id,
                    New_Farmer_Id,New_MilkType_Id,New_MilkStatus_Id,New_Quantity_Ltr,New_Quantity_Kg,
                    New_Fat,New_SNF,New_Created_On,var_User_Id,var_User_Name,
                    now(),var_User_Id,var_User_Name
				);
                
			set @CurrentMilkRate = GetMilkRateBackDate(New_Org_Id,New_MCC_Id,@set_CollectionShift_Id,
												New_Fat,New_SNF,New_MilkType_Id,
												@set_Collection_Date);
                                                
			UPDATE  t005_milkcollectionfarmer t005
			SET 
			t005.ApplicableRate = @CurrentMilkRate,
            t005.Amount = @CurrentMilkRate * t005.Quantity_Ltr
			WHERE t005.Org_Id = New_Org_Id
			AND t005.FarmerCollection_Id = New_FarmerCollection_Id;
            
            set @MusterType_Id = '';
            SET @MusterType_Id = (SELECT m005.MusterType_Id
											FROM m005_mcc_version m005
											WHERE MCC_Id = New_MCC_Id AND is_deleted = 0
												AND Applicable_Date <= New_Created_On
											ORDER BY Applicable_Date DESC LIMIT 1);

			SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id);

			set @Current_Datetime = New_Created_On;
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
            
            UPDATE  t005_milkcollectionfarmer t005
			SET 
			t005.MusterCycle_StartDate = @MusterCycle_StartDate,
            t005.MusterCycle_EndDate = @MusterCycle_EndDate
			WHERE t005.Org_Id = New_Org_Id
			AND t005.FarmerCollection_Id = New_FarmerCollection_Id;
                    

			END LOOP;

			-- Close cursor
			CLOSE cur;
			
			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
		
        end;
	elseif (var_Method_Name = 'Set_Approval_V1') then
		begin
        DECLARE done INT DEFAULT FALSE;
		DECLARE New_FarmerCollection_Id VARCHAR(20);
        DECLARE New_Org_Id VARCHAR(20);
        DECLARE New_MCC_Id VARCHAR(20);
        DECLARE New_MCCCollectionShift_Id VARCHAR(20);
        DECLARE New_Farmer_Id VARCHAR(20);
        DECLARE New_MilkType_Id VARCHAR(20);
        DECLARE New_MilkStatus_Id VARCHAR(20);
		DECLARE New_Quantity_Ltr DECIMAL(20, 3);
        DECLARE New_Quantity_Kg DECIMAL(20, 3);
		DECLARE New_Fat DECIMAL(8, 2);
		DECLARE New_SNF DECIMAL(8, 2);
        DECLARE New_Rate DECIMAL(8, 2);
        DECLARE New_Created_On DATETIME;
        DECLARE Year_Id VARCHAR(20);
        
        
		   DECLARE cur CURSOR FOR
			-- Your select query here
				select 
				tm01.Org_Id AS New_Org_Id,
				tm01.MCC_Id  AS New_MCC_Id,
				tm01.MCCCollectionShift_Id AS New_MCCCollectionShift_Id,
				tm01.Farmer_Id AS New_Farmer_Id,
				tm01.MilkType_Id AS New_MilkType_Id,
				tm01.MilkStatus_Id AS New_MilkStatus_Id,
                tm01.Quantity_Ltr AS New_Quantity_Ltr,
                tm01.Quantity_Kg AS New_Quantity_Kg,
				Roundoff('Quality', (tm01.Fat)) as New_Fat,
				Roundoff('Quality', (tm01.SNF)) as New_SNF,
                tm01.Run_ApplicableRate AS New_Rate,
				tm01.Collection_On as New_Created_On
				from tm01_milkcollectionfarmer tm01
				where tm01.Org_Id = var_Org_Id
				and tm01.MCC_Id = var_MCC_Id
				and tm01.MCCCollectionShift_Id = var_MCCCollectionShift_Id;

			-- Declare continue handler for cursor
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

			
			-- Open cursor
			OPEN cur;
			
			-- Loop to fetch and insert data
			myLoop: LOOP
				-- Fetch data into variables
				FETCH cur INTO New_Org_Id ,New_MCC_Id ,New_MCCCollectionShift_Id ,New_Farmer_Id ,
				 New_MilkType_Id ,New_MilkStatus_Id ,New_Quantity_Ltr ,New_Quantity_Kg ,
				 New_Fat,New_SNF ,New_Rate,New_Created_On ;

				-- Check if there is no more data
				IF done THEN
					LEAVE myLoop;
				END IF;

				-- Generate a new Entry_Id
				SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
				CALL USP_Number_Range('t005_milkcollectionfarmer', Year_Id, 'T005', '', New_FarmerCollection_Id);
				
				-- Insert data into the table
				INSERT INTO t005_milkcollectionfarmer (
					Org_Id, FarmerCollection_Id,MCC_Id,MCCCollectionShift_Id,
                    Farmer_Id,MilkType_Id,MilkStatus_Id,Quantity_Ltr,Quantity_Kg,
                    Fat,SNF,Created_On,CreatedBy_Id,CreatedBy_Name,
                    LastEdited_On,LastEditedBy_Id,LastEditedBy_Name,ApplicableRate
				) VALUES (
					New_Org_Id,New_FarmerCollection_Id,New_MCC_Id,New_MCCCollectionShift_Id,
                    New_Farmer_Id,New_MilkType_Id,New_MilkStatus_Id,New_Quantity_Ltr,New_Quantity_Kg,
                    New_Fat,New_SNF,New_Created_On,var_User_Id,var_User_Name,
                    now(),var_User_Id,var_User_Name,New_Rate
				);
                
			/*
                
			set @CurrentMilkRate = GetMilkRateBackDate(New_Org_Id,New_MCC_Id,@set_CollectionShift_Id,
												New_Fat,New_SNF,New_MilkType_Id,
												@set_Collection_Date);
                                                
			*/
			
			UPDATE  t005_milkcollectionfarmer t005
			SET 
			-- t005.ApplicableRate = @CurrentMilkRate,
            t005.Amount = t005.ApplicableRate * t005.Quantity_Ltr
			WHERE t005.Org_Id = New_Org_Id
			AND t005.FarmerCollection_Id = New_FarmerCollection_Id;
            
            set @MusterType_Id = '';
            SET @MusterType_Id = (SELECT m005.MusterType_Id
											FROM m005_mcc_version m005
											WHERE MCC_Id = New_MCC_Id AND is_deleted = 0
												AND Applicable_Date <= New_Created_On
											ORDER BY Applicable_Date DESC LIMIT 1);

			SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id);

			set @Current_Datetime = New_Created_On;
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
            
            UPDATE  t005_milkcollectionfarmer t005
			SET 
			t005.MusterCycle_StartDate = @MusterCycle_StartDate,
            t005.MusterCycle_EndDate = @MusterCycle_EndDate
			WHERE t005.Org_Id = New_Org_Id
			AND t005.FarmerCollection_Id = New_FarmerCollection_Id;
                    

			END LOOP;

			-- Close cursor
			CLOSE cur;
			
			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
		
        end;
	
    elseif (var_Method_Name = 'Set_Agent') then
		begin
			if exists( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 and MCC_Id = var_MCC_Id limit 1) then
            
				Set @Created_On = (select date(Collection_Date) from t004_mcccollectionshift
								where 
								Org_Id = var_Org_Id
								and MCC_Id = var_MCC_Id
								and MCCCollectionShift_Id = var_MCCCollectionShift_Id limit 1);
								
								
				set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id) ;
	 
				DROP TEMPORARY TABLE IF EXISTS temp_Report;

				CREATE TEMPORARY TABLE temp_Report ( 
				Org_Id varchar(20), MCCCollectionShift_Id varchar(20), 
				MCC_Id varchar(20),Collection_Date datetime);

				insert into temp_Report (Org_Id,MCCCollectionShift_Id,MCC_Id,Collection_Date)
				select Org_Id,MCCCollectionShift_Id,MCC_Id,Collection_Date 
				from t004_mcccollectionshift 
				where 
				Org_Id = var_Org_Id
				and MCC_Id =var_MCC_Id
				and date(Collection_Date) <= date(@Created_On)
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id 
												from t006_milkcollectionagent
												where 
												Org_Id = var_Org_Id
												and MCC_Id =var_MCC_Id)
												and date(Created_On) <= date(@Created_On)
				order by Collection_Date  desc
				limit 2;

				set @MCCCollectionShift_Id_1  = (select MCCCollectionShift_Id from temp_Report order by Collection_Date  desc limit 1);
				set @MCCCollectionShift_Id_2  = (select MCCCollectionShift_Id from temp_Report order by Collection_Date  asc limit 1);


				DROP TEMPORARY TABLE IF EXISTS temp_Report_Main;

				CREATE TEMPORARY TABLE temp_Report_Main ( 
				Org_Id varchar(20), MCCCollectionShift_Id varchar(20), 
				MCC_Id varchar(20));

				insert into temp_Report_Main (Org_Id,MCCCollectionShift_Id,MCC_Id)
				select t004.Org_Id,t004.MCCCollectionShift_Id,t004.MCC_Id 
				from t004_mcccollectionshift t004
				where t004.Org_Id = var_Org_Id
				and t004.MCC_Id =var_MCC_Id
				and REPLACE(MCCCollectionShift_Id, 'T004', '')  <= REPLACE(@MCCCollectionShift_Id_1, 'T004', '')
				and REPLACE(MCCCollectionShift_Id, 'T004', '')  > REPLACE(@MCCCollectionShift_Id_2, 'T004', '')
				order by Collection_Date  desc;
				
				
				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;

				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';

				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;

				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;

				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;


				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);


				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
                
                
                set @AgentCollection_Id = (SELECT AgentCollection_Id FROM t006_milkcollectionagent where Org_Id =var_Org_Id 
										and MCC_Id = var_MCC_Id  
										and MCCCollectionShift_Id = var_MCCCollectionShift_Id ); 
		
				UPDATE t006_milkcollectionagent 
					SET Aluminum_Can_With_Lid =  1, 
					Aluminum_Can_Without_Lid = 1 ,
					Plastic_Can_With_Lid = 1, 
					Plastic_Can_Without_Lid =  1,
					Final_Qty_Cow_Ltr = @TotalMilkQuantityCow,
					Final_Qty_Cow_KG = @TotalMilkQuantityCowKG,
					Final_FAT_Cow_WtAvg = @CowFatweightAvg,
					Final_SNF_Cow_WtAvg = @CowSNFweightAvg,
					Final_Qty_Buf_Ltr = @TotalMilkQuantityBuffalo,
					Final_Qty_Buf_KG  =  @TotalMilkQuantityBuffaloKG,
					Final_FAT_Buf_WtAvg =  @BuffaloFatweightAvg ,
					Final_SNF_Buf_WtAvg = @BuffaloSNFweightAvg,
					Final_Amout_Cow = @TotalMilkAmountCow,
					Final_Amout_Buf =  @TotalMilkAmountBuffalo
					WHERE Org_Id = var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = var_MCCCollectionShift_Id
					and AgentCollection_Id =  @AgentCollection_Id ;
					
					set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);
					   
					DROP TEMPORARY TABLE IF EXISTS temp_milkcollectionagent_item;
					CREATE TEMPORARY TABLE temp_milkcollectionagent_item (
						PKeyRowNum int, 
						Org_Id VARCHAR(45),
						Milktype_Id VARCHAR(45), 
						Quantity_Ltr DECIMAL(8,2), 
						FAT DECIMAL(8,2), 
						SNF DECIMAL(8,2)
					);
					
					INSERT INTO temp_milkcollectionagent_item (
						Org_Id	,
						Milktype_Id,Quantity_Ltr,FAT,SNF)
					select 
					t005.Org_Id, t005.MilkType_Id,sum(t005.Quantity_Ltr),
					Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.Fat))/sum(t005.Quantity_Ltr)),
					Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.SNF))/sum(t005.Quantity_Ltr))
					from t005_milkcollectionfarmer  t005
					WHERE t005.Org_Id = var_Org_Id 
					and t005.MCC_Id = var_MCC_Id  
					and t005.MilkStatus_Id = 'C016001'
					and t005.MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main)
					group by  t005.Org_Id, t005.MilkType_Id;
					
					
					UPDATE t006_milkcollectionagent_item  t006
					inner join temp_milkcollectionagent_item t005 on
					t005.Org_Id = t006.Org_Id
					and t005.MilkType_Id in ('C011001','C011002')
					SET 
					t006.Quantity_Ltr =  t005.Quantity_Ltr, 
					t006.FAT =  t005.FAT,
					t006.SNF = t005.SNF
					WHERE t006.Org_Id = var_Org_Id 
					and t006.AgentCollection_Id =  @AgentCollection_Id
					and t006.Milktype_Id in ('C011001','C011002') ;
								
				
            else
            
				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = var_MCCCollectionShift_Id and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;
				
				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
			
				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
				 set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;
			
				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
				
				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
				and MCCCollectionShift_Id = var_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
	 
				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				
				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = var_MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
			
			set @AgentCollection_Id = (SELECT AgentCollection_Id FROM t006_milkcollectionagent where Org_Id =var_Org_Id 
										and MCC_Id = var_MCC_Id  
										and MCCCollectionShift_Id = var_MCCCollectionShift_Id ); 
		
			UPDATE t006_milkcollectionagent 
				SET Aluminum_Can_With_Lid =  1, 
				Aluminum_Can_Without_Lid = 1 ,
				Plastic_Can_With_Lid = 1, 
				Plastic_Can_Without_Lid =  1,
				Final_Qty_Cow_Ltr = @TotalMilkQuantityCow,
				Final_Qty_Cow_KG = @TotalMilkQuantityCowKG,
				Final_FAT_Cow_WtAvg = @CowFatweightAvg,
				Final_SNF_Cow_WtAvg = @CowSNFweightAvg,
				Final_Qty_Buf_Ltr = @TotalMilkQuantityBuffalo,
				Final_Qty_Buf_KG  =  @TotalMilkQuantityBuffaloKG,
				Final_FAT_Buf_WtAvg =  @BuffaloFatweightAvg ,
				Final_SNF_Buf_WtAvg = @BuffaloSNFweightAvg,
				Final_Amout_Cow = @TotalMilkAmountCow,
				Final_Amout_Buf =  @TotalMilkAmountBuffalo
				WHERE Org_Id = var_Org_Id and MCC_Id = var_MCC_Id  and MCCCollectionShift_Id = var_MCCCollectionShift_Id
				and AgentCollection_Id =  @AgentCollection_Id ;
				
				set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);
				   
				DROP TEMPORARY TABLE IF EXISTS temp_milkcollectionagent_item;
				CREATE TEMPORARY TABLE temp_milkcollectionagent_item (
					PKeyRowNum int, 
					Org_Id VARCHAR(45),
					Milktype_Id VARCHAR(45), 
					Quantity_Ltr DECIMAL(8,2), 
					FAT DECIMAL(8,2), 
					SNF DECIMAL(8,2)
				);
				
				INSERT INTO temp_milkcollectionagent_item (
					Org_Id	,
					Milktype_Id,Quantity_Ltr,FAT,SNF)
				select 
				t005.Org_Id, t005.MilkType_Id,sum(t005.Quantity_Ltr),
				Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.Fat))/sum(t005.Quantity_Ltr)),
				Roundoff('Quality',(sum(t005.Quantity_Ltr * t005.SNF))/sum(t005.Quantity_Ltr))
				from t005_milkcollectionfarmer  t005
				WHERE t005.Org_Id = var_Org_Id 
				and t005.MCC_Id = var_MCC_Id  
				and t005.MilkStatus_Id = 'C016001'
				and t005.MCCCollectionShift_Id = var_MCCCollectionShift_Id
				group by  t005.Org_Id, t005.MilkType_Id;
				
				
				UPDATE t006_milkcollectionagent_item  t006
				inner join temp_milkcollectionagent_item t005 on
				t005.Org_Id = t006.Org_Id
				and t005.MilkType_Id in ('C011001','C011002')
				SET 
				t006.Quantity_Ltr =  t005.Quantity_Ltr, 
				t006.FAT =  t005.FAT,
				t006.SNF = t005.SNF
				WHERE t006.Org_Id = var_Org_Id 
				and t006.AgentCollection_Id =  @AgentCollection_Id
				and t006.Milktype_Id in ('C011001','C011002') ;
            
            end if;
			
		
            
            
            -- delete from t006_milkcollectionagent_item where  Org_Id = var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
			-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
			
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Update_flat') then
		begin
			declare set_Quantity_Ltr decimal(20,2);
            declare set_FAT decimal(20,2);
            declare set_SNF decimal(20,2);
            declare set_Rate decimal(20,2);
            
            set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);
			
            
            select 
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF,
            if (t0061.MilkType_Id = 'C011001' and t006.Final_Qty_Cow_Ltr <> 0 , t006.Final_Amout_Cow / t006.Final_Qty_Cow_Ltr, 
			if (t0061.MilkType_Id = 'C011002' and t006.Final_Qty_Buf_Ltr <> 0 , t006.Final_Amout_Buf / t006.Final_Qty_Buf_Ltr, 0.00  )  ) 
            into 
            set_Quantity_Ltr,
            set_FAT,
            set_SNF,
            set_Rate
			from t006_milkcollectionagent t006
			inner join t006_milkcollectionagent_item t0061 on
			t0061.Org_Id = t006.Org_Id 
            and ifnull(t0061.Milktype_Id,'') <>  ''
			and t0061.AgentCollection_Id = t006.AgentCollection_Id 
			where t006.Org_Id = var_Org_Id
			and t006.MCC_Id = var_MCC_Id
			and t006.MCCCollectionShift_Id = var_MCCCollectionShift_Id;

			UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Agent_Quantity_Kg = set_Quantity_Ltr / @kg_to_ltr,
			f010.Agent_Quantity_Ltr = set_Quantity_Ltr,
            f010.Agent_Fat = set_FAT,
			f010.Agent_SNF = set_SNF,
            f010.MilkRate = set_Rate,
            f010.MilkPrice = set_Rate * set_Quantity_Ltr
			WHERE f010.Org_Id = var_Org_Id
            AND f010.MCC_Id = var_MCC_Id
			AND f010.Entry_Id = var_MilkCollectionDairy_Id;
            
			UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Agent_Fat_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_Fat) /100),
			f010.Agent_SNF_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_SNF) /100)
			WHERE f010.Org_Id = var_Org_Id
            AND f010.MCC_Id = var_MCC_Id
			AND f010.Entry_Id = var_MilkCollectionDairy_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.FatKG_GainLoss = (f010.Dairy_Fat_Kg - f010.Agent_Fat_Kg),
			f010.SNFKG_GainLoss = (f010.Dairy_SNF_Kg - f010.Agent_SNF_Kg)
			WHERE f010.Org_Id = var_Org_Id
            AND f010.MCC_Id = var_MCC_Id
			AND f010.Entry_Id = var_MilkCollectionDairy_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Total_GainLoss = ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
			WHERE f010.Org_Id = var_Org_Id
            AND f010.MCC_Id = var_MCC_Id
			AND f010.Entry_Id = var_MilkCollectionDairy_Id;
            
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Is_VoucherLocked = 1,
            f010.Locked_By = var_User_Id,
            f010.Locked_On = now()
			WHERE f010.Org_Id = var_Org_Id
            AND f010.MCC_Id = var_MCC_Id
			AND f010.Entry_Id = var_MilkCollectionDairy_Id;
            
			update t009_milkcollectiondairy_mcccommission t9
			inner join f010_milkcollectionmcc_final f010
			on t9.Org_Id = f010.Org_Id and t9.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id and t9.MCC_Id = f010.MCC_Id
			set Amount = f010.Total_GainLoss,
			MCC_Commision = f010.Total_GainLoss
			where f010.Org_Id = var_Org_Id
			and MPPIType_Id = 'C047003' 
			AND f010.MCC_Id = var_MCC_Id
			AND f010.Entry_Id = var_MilkCollectionDairy_Id;
            
             SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
			
        end;
	elseif (var_Method_Name = 'Set_ReverseIncome') then
		begin
			update f010_milkcollectionmcc_final  f010
            set f010.Is_VoucherLocked = 0
			where f010.Org_Id = var_Org_Id
            and f010.MCC_Id = var_MCC_Id
			and f010.Entry_Id = var_MilkCollectionDairy_Id;
            
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Set_ApproveIncome') then
		begin
			update f010_milkcollectionmcc_final  f010
            set f010.Is_VoucherLocked = 1,
            f010.Locked_By = var_User_Id,
            f010.Locked_On = now()
			where f010.Org_Id = var_Org_Id
            and f010.MCC_Id = var_MCC_Id
			and f010.Entry_Id = var_MilkCollectionDairy_Id;
            
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Delete_Commission') then
		begin
			set @MilkCollectionDairy_Id = (select MilkCollectionDairy_Id from f010_milkcollectionmcc_final 
			where Org_Id = var_Org_Id
            and MCC_Id = var_MCC_Id
			and Entry_Id = var_MilkCollectionDairy_Id limit 1);
            
			delete from t009_milkcollectiondairy_mcccommission 
            where var_Org_Id = Org_Id 
            and MCC_Id = var_MCC_Id
            and MPPIType_Id = 'C047003'
            and MilkCollectionDairy_Id = @MilkCollectionDairy_Id;
            
			SELECT 1 AS Result_Id, 
			'Locked' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Create_Commission') then
		begin 
		DECLARE New_MilkCollectionMCCCommission_Id VARCHAR(20);
		DECLARE Year_Id VARCHAR(20);
        
        SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
		CALL USP_Number_Range('t009_milkcollectiondairy_mcccommission', Year_Id, 'T009', '', New_MilkCollectionMCCCommission_Id);
		
        
        INSERT INTO t009_milkcollectiondairy_mcccommission (
			Org_Id, MilkCollectionMCCCommission_Id, MilkCollectionDairy_Id, 
			MCC_Id, MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
			Liters,Weight,SNF,Fat,BaseRate,Amount
			
		)
        SELECT 
		f010.Org_Id,
        New_MilkCollectionMCCCommission_Id,
		f010.MilkCollectionDairy_Id,
		m005.MCC_Id,
		c047.MPPIType_Id,
		ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
		f010.MilkType_Id,
		'C016001' as MilkStatus_Id,
		'0' as Liters,
		'0' as Weight,
		'0' as FAT,
		'0' as SNF,   
		'0' as Rate,
		f010.Total_GainLoss as Amount
		FROM f010_milkcollectionmcc_final  f010
		INNER JOIN m005_mcc m005 ON
			m005.Org_Id = f010.Org_Id
			AND m005.MCC_Id = f010.MCC_Id
		INNER JOIN c047_mppitype c047 ON
			c047.MPPIType_Id = 'C047003'
		where f010.Org_Id = var_Org_Id 
        and f010.MCC_Id = var_MCC_Id
		and f010.Entry_Id = var_MilkCollectionDairy_Id
		GROUP BY
		f010.Org_Id,
		f010.MilkCollectionDairy_Id,
		m005.MCC_Id,
		c047.MPPIType_Id,
		f010.CollectionShift_Id,
		f010.MilkType_Id,
		MilkStatus_Id,
		f010.Total_GainLoss;
        
        set @Collection_Date = (select Collection_Date from f010_milkcollectionmcc_final 
			where Org_Id = var_Org_Id
            and MCC_Id = var_MCC_Id
			and Entry_Id = var_MilkCollectionDairy_Id limit 1);
            
		
        SET @MusterType_Id = '';
        SET @MusterType_Id = (SELECT m005.MusterType_Id
									FROM m005_mcc_version m005
									WHERE m005.MCC_Id = var_MCC_Id AND m005.Is_Deleted = 0
									AND m005.Org_Id = var_Org_Id
									AND m005.Applicable_Date <= @Collection_Date
									ORDER BY m005.Applicable_Date DESC LIMIT 1);
         
         SET @MusterType = '';
		SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id); 
            
            IF (@MusterType = 1) THEN

				SET @MusterCycle_StartDate = @Collection_Date;
				SET @MusterCycle_EndDate = @Collection_Date;

			ELSEIF (@MusterType = 7) THEN

				IF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 1 AND 7) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-07');

				ELSEIF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 8 AND 14) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-08');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-14');

				ELSEIF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 15 AND 21) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-15');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-21');

				ELSEIF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 16 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Collection_Date));

				END IF;

			ELSEIF (@MusterType = 15) THEN

				IF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 1 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-15');

				ELSE

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Collection_Date));

				END IF;

			ELSEIF (@MusterType = 5) THEN

				IF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 1 AND 5) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-05');

				ELSEIF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 6 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-06');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 11 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-15');

				ELSEIF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 16 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-16');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 21 AND 25) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-21');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-25');
				ELSEIF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 26 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-26');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Collection_Date));

				END IF;

			ELSEIF (@MusterType = 10) THEN

				IF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 1 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 11 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(@Collection_Date, '%d') BETWEEN 21 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-21');
					SET @MusterCycle_EndDate = LAST_DAY(date(@Collection_Date));

				END IF;

			ELSEIF (@MusterType = 30) THEN

				SET @MusterCycle_StartDate = DATE_FORMAT(date(@Collection_Date), '%Y-%m-01');
				SET @MusterCycle_EndDate = LAST_DAY(date(@Collection_Date));

			END IF;
            
            
            UPDATE  t009_milkcollectiondairy_mcccommission t009
			SET 
			t009.MusterType_Id = @MusterType_Id,
            t009.MusterCycle_StartDate = @MusterCycle_StartDate,
            t009.MusterCycle_EndDate = @MusterCycle_EndDate
			WHERE t009.Org_Id = Org_Id
			AND t009.MilkCollectionMCCCommission_Id = New_MilkCollectionMCCCommission_Id;
                                    
			SELECT 1 AS Result_Id, 
			'Locked' AS Result_Description, 
			var_MCCCollectionShift_Id AS Result_Extra_Key;
		end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
