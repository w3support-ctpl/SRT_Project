-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollection_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollection_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_MilkCollectionDairy_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_MCCCollectionShift_Id varchar(20),
    var_MCC_Id varchar(20),
    var_Vehicle_Id varchar(20),
    var_VehicleType_Id varchar(20),
    var_MilkData longtext,
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_MCCCommission longtext,
    var_Date varchar(45)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
    SET SQL_SAFE_UPDATES = 0;

    if (var_Method_Name = 'Create') then
		begin
			Declare New_MilkCollectionDairy_Id varchar(20);
            Declare Set_MilkCollectionDairy_Id varchar(20);
			Declare Year_Id varchar(10);
            DECLARE New_Driver_Id  varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            DECLARE Today_Date DATETIME;
            set Today_Date = CONVERT_TZ(var_Date, '+00:00', '+00:00');
            -- CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            set Year_Id = (select right(left(date(Today_Date),4),(2)));
			Call USP_Number_Range ('t009_milkcollectiondairy_header', Year_Id, 'T009', '', New_MilkCollectionDairy_Id );
            
            select Driver_Id INTO New_Driver_Id
            from t021_tripdocument_header
            where TripDocument_Id = var_TripDocument_Id;
            
		if (var_MilkCollectionDairy_Id is Not Null and var_MilkCollectionDairy_Id != '') then
        
			if(ifnull(var_MCCCollectionShift_Id, '') = '' or var_MCCCollectionShift_Id = 'null') then
           
				set @Year_Id = (select right(left(date(Today_Date),4),(2)));
                
                set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
                
                set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
                
				set @Agent_Id = (
				SELECT Agent_Id FROM m005_mcc 
				where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
                
                
                set @Agent_Name = (
				SELECT Agent_Name FROM mu05_agent 
				where Agent_Id = @Agent_Id and Org_Id = var_Org_Id);

                select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = var_Org_Id
				order by Applicable_Date desc limit 1 ;
                
                SET @CollectionShift_Id = (select m006.CollectionShift_Id from t021_tripdocument_header  t021
				inner join m008_route_vehicle  m008 on m008.Org_Id = t021.Org_Id 
					and m008.Entry_Id = t021.Route_Trip_Id 
				inner join m006_route  m006 on m008.Org_Id = m006.Org_Id 
					and m008.Route_Id = m006.Route_Id 
				where  t021.Org_Id =  var_Org_Id
				and t021.TripDocument_Id = var_TripDocument_Id);
                
               set @CollectionShift_Name =( SELECT CollectionShift_Name FROM c015_collectionshift where CollectionShift_Id = @CollectionShift_Id );

				select ShiftEnd_Time INTO @ShiftEnd_Time  from c015_collectionshift where CollectionShift_Id = @CollectionShift_Id;
				
                set @New_MCCCollectionShift_Id =  (select MCCCollectionShift_Id from t004_mcccollectionshift
												where Org_Id = var_Org_Id
												and MCC_Id = var_MCC_Id
												and date(Collection_Date) = @Current_Datetime
												and CollectionShift_Id = @CollectionShift_Id limit 1);
                                                
				if(@New_MCCCollectionShift_Id is not null or @New_MCCCollectionShift_Id <> '')then
                
					set @New_MCCCollectionShift_Id  = @New_MCCCollectionShift_Id;
                    
                    
                    
                    update t022_tripdocument_item 
					set Is_Reached = 1 ,
					Arrival_At = @Current_Datetime ,
					MCC_CollectionShift_Id = @New_MCCCollectionShift_Id
					where Org_Id = var_Org_Id 
					and TripDocument_Id = var_TripDocument_Id
					and MCC_Id = var_MCC_Id;
                    
                    set @AgentCollection_Id =  (select AgentCollection_Id from t006_milkcollectionagent
												where Org_Id = var_Org_Id
												and MCC_Id = var_MCC_Id
                                                and MCCCollectionShift_Id = @New_MCCCollectionShift_Id
                                                limit 1);
					
					if(@AgentCollection_Id is null or @AgentCollection_Id = '')then
                   
						SET @MusterType_Id = (SELECT m005.MusterType_Id
												FROM m005_mcc_version m005
												WHERE MCC_Id = var_MCC_Id AND is_deleted = 0
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
                        
                        set @Agent_Id = (
						SELECT Agent_Id FROM m005_mcc 
						where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
                    
						set @TotalMilkQuantity = '';
						set @TotalQuantity = '';
						select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;
						
						set @TotalMilkQuantityCow = '';
						set @TotalQuantityCow = '';
						select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
						into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
						from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
					
						set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
						
						set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
						
						set @TotalMilkQuantityBuffalo  = '';
						set @TotalQuantityBuffalo = '';
						select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
						into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
						from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;
					
						set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
						
						set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
						
			 
						Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @New_MCCCollectionShift_Id and 
						MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
						
						Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @New_MCCCollectionShift_Id and 
						MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
						
						
						Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @New_MCCCollectionShift_Id and 
						MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
						
						Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @New_MCCCollectionShift_Id and 
						MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
						
                        Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
                
						insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
						Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
						Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
						Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
						 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
						) values 
						( var_Org_Id, @AgentCollection_Id , var_MCC_Id , @New_MCCCollectionShift_Id , @Agent_Id  , New_Driver_Id , 
						1,
						1 ,
						1, 
						1,
						@TotalMilkQuantityCow, @TotalMilkQuantityCowKG, @CowFatweightAvg,
						@CowSNFweightAvg, @TotalMilkQuantityBuffaloKG, @TotalMilkQuantityBuffalo,
						@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
						0,1,0,@Current_Datetime, var_User_Id  , var_User_Name , @MusterCycle_StartDate , @MusterCycle_EndDate
						) ;
                        
                        INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id,
						Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id)
                        select var_Org_Id, @AgentCollection_Id , MilkType_Id,sum(Quantity_Ltr),
						Roundoff('Quality',sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)))  as Fat,
						Roundoff('Quality',sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr))) as SNF,
						MilkStatus_Id 
						from t005_milkcollectionfarmer where 
						Org_Id = var_Org_Id
						and MCC_Id = var_MCC_Id
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id
                        and MilkStatus_Id = 'C016001' 
						group by MilkType_Id , MilkStatus_Id;
                        
						-- delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
						-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
								
                    end if;
                    
                else
                
					Call USP_Number_Range ('t004_mcccollectionshift', @Year_Id, 'T004', '', @New_MCCCollectionShift_Id);
					
					insert into t004_mcccollectionshift
					(Org_Id, MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
					Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , Created_On , CreatedBy_Id ,
					CreatedBy_Name , Is_MilkDispatch, Expected_End_Time) 
					( select var_Org_Id , @New_MCCCollectionShift_Id , 	var_MCC_Id , @Current_Datetime ,  @CollectionShift_Id , @CollectionShift_Name,
					2, @Current_times , 1 , 0 , @Current_Datetime, @Agent_Id , @Agent_Name , 0 , @ShiftEnd_Time
					from mu05_agent where Org_Id = var_Org_Id and 
					Agent_Id = @Agent_Id limit 1 ) ;
                    
                    
                     update t022_tripdocument_item 
						set Is_Reached = 1 ,
						Arrival_At = @Current_Datetime ,
						MCC_CollectionShift_Id = @New_MCCCollectionShift_Id
						where Org_Id = var_Org_Id 
						and TripDocument_Id = var_TripDocument_Id
						and MCC_Id = var_MCC_Id;
                    
                    
                    Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
                
					SET @MusterType_Id = (SELECT m005.MusterType_Id
												FROM m005_mcc_version m005
												WHERE MCC_Id = var_MCC_Id AND is_deleted = 0
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
					
					
					insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
					Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
					Final_Qty_Cow_Ltr,  
					Final_Qty_Cow_KG,  
					Final_FAT_Cow_WtAvg, 
					Final_SNF_Cow_WtAvg,
					Final_Qty_Buf_KG , 
					Final_Qty_Buf_Ltr, 
					Final_FAT_Buf_WtAvg , 
					Final_SNF_Buf_WtAvg, 
					Final_Amout_Cow , 
					Final_Amout_Buf,
					 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
					) values 
					( var_Org_Id, @AgentCollection_Id , var_MCC_Id , @New_MCCCollectionShift_Id , @Agent_Id  , New_Driver_Id , 
					0,
					0 ,
					0, 
					0,
					0, 0, 0,
					0, 0, 0,
					0 , 0, 0, 0,
					0,1,0,@Current_Datetime, @Agent_Id  , @Agent_Name  , @MusterCycle_StartDate , @MusterCycle_EndDate
					) ;
					
					INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id,
					Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id) 
					value 
					(var_Org_Id,@AgentCollection_Id, 'C011001', 0 , 0, 0, 'C016001' );
                
                end if;

                -- Save Data in mu02_role_menu table from temp table
				INSERT INTO t009_milkcollectiondairy_mcc
				(Org_Id,MilkCollectionDairy_Id, MCCCollectionShift_Id,
				MCC_Id, MilkType_Id,MilkStatus_Id, Is_Active, Is_Deleted, 
				Created_On, CreatedBy_Id, CreatedBy_Name)
				Values ( var_Org_Id ,var_MilkCollectionDairy_Id, @New_MCCCollectionShift_Id,
				var_MCC_Id, 'C011001','C016001', 1, 0, 
				Today_Date, var_User_Id, var_User_Name);  
                
			else
        
			-- Agent Entry Table (on front end) passed as XML in var_MilkData
			-- save it to temp_menu
		
				DROP TEMPORARY TABLE IF EXISTS temp_menu;
				CREATE TEMPORARY TABLE temp_menu (PKeyRowNum int, 
				MilkType_Id varchar(20), MilkStatus_Id varchar(20));
					
				SET row_count := extractValue(var_MilkData,'count(//Milk/MilkData)');
				WHILE k < row_count DO
					SET k := k + 1;
					SET xpath := concat('//Milk/MilkData[', k, ']');
					INSERT INTO temp_menu VALUES (
						k,
						extractValue(var_MilkData, concat(xpath,'/MilkType_Id')),
						extractValue(var_MilkData, concat(xpath,'/MilkStatus_Id'))
					);
				END WHILE;
				
				-- Save Data in mu02_role_menu table from temp table
				Insert into t009_milkcollectiondairy_mcc
				(Org_Id,MilkCollectionDairy_Id, MCCCollectionShift_Id,MCC_Id,
				MilkType_Id,MilkStatus_Id,
				Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
				SELECT var_Org_Id,var_MilkCollectionDairy_Id, var_MCCCollectionShift_Id,var_MCC_Id,
				MilkType_Id,MilkStatus_Id,
				1, 0,Today_Date, var_User_Id,var_User_Name
				from temp_menu; 
                
                
                set @AgentCollection_Id =  (select AgentCollection_Id from t006_milkcollectionagent
												where Org_Id = var_Org_Id
												and MCC_Id = var_MCC_Id
                                                and MCCCollectionShift_Id = var_MCCCollectionShift_Id
                                                limit 1);

												
				if(@AgentCollection_Id is null or @AgentCollection_Id = '')then



					set @Year_Id = (select right(left(date(Today_Date),4),(2)));

					set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));

					set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));

					set @Agent_Id = (
					SELECT Agent_Id FROM m005_mcc 
					where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);


					set @Agent_Name = (
					SELECT Agent_Name FROM mu05_agent 
					where Agent_Id = @Agent_Id and Org_Id = var_Org_Id);

					select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = var_Org_Id
					order by Applicable_Date desc limit 1 ;

					SET @CollectionShift_Id = (select m006.CollectionShift_Id from t021_tripdocument_header  t021
					inner join m008_route_vehicle  m008 on m008.Org_Id = t021.Org_Id 
					and m008.Entry_Id = t021.Route_Trip_Id 
					inner join m006_route  m006 on m008.Org_Id = m006.Org_Id 
					and m008.Route_Id = m006.Route_Id 
					where  t021.Org_Id =  var_Org_Id
					and t021.TripDocument_Id = var_TripDocument_Id);

					set @CollectionShift_Name =( SELECT CollectionShift_Name FROM c015_collectionshift where CollectionShift_Id = @CollectionShift_Id );

					select ShiftEnd_Time INTO @ShiftEnd_Time  from c015_collectionshift where CollectionShift_Id = @CollectionShift_Id;

                   
						SET @MusterType_Id = (SELECT m005.MusterType_Id
												FROM m005_mcc_version m005
												WHERE MCC_Id = var_MCC_Id AND is_deleted = 0
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
                        
                        set @Agent_Id = (
						SELECT Agent_Id FROM m005_mcc 
						where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
                    
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
						
                        Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
                
						insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
						Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
						Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
						Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
						 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
						) values 
						( var_Org_Id, @AgentCollection_Id , var_MCC_Id , var_MCCCollectionShift_Id , @Agent_Id  , New_Driver_Id , 
						1,
						1 ,
						1, 
						1,
						@TotalMilkQuantityCow, @TotalMilkQuantityCowKG, @CowFatweightAvg,
						@CowSNFweightAvg, @TotalMilkQuantityBuffaloKG, @TotalMilkQuantityBuffalo,
						@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
						0,1,0,@Current_Datetime, var_User_Id  , var_User_Name , @MusterCycle_StartDate , @MusterCycle_EndDate
						) ;
                        
                        INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id,
						Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id)
                        select var_Org_Id, @AgentCollection_Id , MilkType_Id,sum(Quantity_Ltr),
						Roundoff('Quality',sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)))  as Fat,
						Roundoff('Quality',sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr))) as SNF,
						MilkStatus_Id 
						from t005_milkcollectionfarmer where 
						Org_Id = var_Org_Id
						and MCC_Id = var_MCC_Id
						and MCCCollectionShift_Id = var_MCCCollectionShift_Id
                        and MilkStatus_Id = 'C016001' 
						group by MilkType_Id , MilkStatus_Id;
                        
						-- delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
						-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
								
                    end if;
            
            end if;

			
			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
		-- if var_MilkCollectionDairy_Id is NULL
		else
			if (ifnull(var_MCCCollectionShift_Id, '') = '' or var_MCCCollectionShift_Id = 'null' ) then
           
				set @Year_Id = (select right(left(date(Today_Date),4),(2)));
                
                set @Current_times = (SELECT TIME(CONVERT_TZ(var_Date, '+00:00', '+00:00')));
                
                set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
                
				set @Agent_Id = (
				SELECT Agent_Id FROM m005_mcc 
				where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
                
                
                set @Agent_Name = (
				SELECT Agent_Name FROM mu05_agent 
				where Agent_Id = @Agent_Id and Org_Id = var_Org_Id);

                select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = var_Org_Id
				order by Applicable_Date desc limit 1 ;
                
                SET @CollectionShift_Id = (select m006.CollectionShift_Id from t021_tripdocument_header  t021
				inner join m008_route_vehicle  m008 on m008.Org_Id = t021.Org_Id 
					and m008.Entry_Id = t021.Route_Trip_Id 
				inner join m006_route  m006 on m008.Org_Id = m006.Org_Id 
					and m008.Route_Id = m006.Route_Id 
				where  t021.Org_Id =  var_Org_Id
				and t021.TripDocument_Id = var_TripDocument_Id);
                
               set @CollectionShift_Name =( SELECT CollectionShift_Name FROM c015_collectionshift where CollectionShift_Id = @CollectionShift_Id );

				select ShiftEnd_Time INTO @ShiftEnd_Time  from c015_collectionshift where CollectionShift_Id = @CollectionShift_Id;
                
                set @New_MCCCollectionShift_Id =  (select MCCCollectionShift_Id from t004_mcccollectionshift
												where Org_Id = var_Org_Id
												and MCC_Id = var_MCC_Id
												and date(Collection_Date) = @Current_Datetime
												and CollectionShift_Id = @CollectionShift_Id limit 1);
                                                
				if(@New_MCCCollectionShift_Id is not null or @New_MCCCollectionShift_Id <> '')then
                
					set @New_MCCCollectionShift_Id  = @New_MCCCollectionShift_Id;
                    
                    update t022_tripdocument_item 
					set Is_Reached = 1 ,
					Arrival_At = @Current_Datetime ,
					MCC_CollectionShift_Id = @New_MCCCollectionShift_Id
					where Org_Id = var_Org_Id 
					and TripDocument_Id = var_TripDocument_Id
					and MCC_Id = var_MCC_Id;
                    
					set @AgentCollection_Id =  (select AgentCollection_Id from t006_milkcollectionagent
							where Org_Id = var_Org_Id
							and MCC_Id = var_MCC_Id
							and MCCCollectionShift_Id = @New_MCCCollectionShift_Id
							limit 1);
                                                
					if(@AgentCollection_Id is null or @AgentCollection_Id = '')then
                    
						SET @MusterType_Id = (SELECT m005.MusterType_Id
												FROM m005_mcc_version m005
												WHERE MCC_Id = var_MCC_Id AND is_deleted = 0
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
                        
                        set @Agent_Id = (
						SELECT Agent_Id FROM m005_mcc 
						where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
                    
						set @TotalMilkQuantity = '';
						set @TotalQuantity = '';
						select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;
						
						set @TotalMilkQuantityCow = '';
						set @TotalQuantityCow = '';
						select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
						into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
						from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
					
						set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
						
						set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
						
						set @TotalMilkQuantityBuffalo  = '';
						set @TotalQuantityBuffalo = '';
						select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
						into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
						from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;
					
						set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
						
						set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = var_MCC_Id 
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
						
			 
						Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @New_MCCCollectionShift_Id and 
						MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
						
						Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @New_MCCCollectionShift_Id and 
						MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
						
						
						Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @New_MCCCollectionShift_Id and 
						MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
						
						Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @New_MCCCollectionShift_Id and 
						MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
						
                        Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
                
						insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
						Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
						Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
						Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
						 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
						) values 
						( var_Org_Id, @AgentCollection_Id , var_MCC_Id , @New_MCCCollectionShift_Id , @Agent_Id  , New_Driver_Id , 
						1,
						1 ,
						1, 
						1,
						@TotalMilkQuantityCow, @TotalMilkQuantityCowKG, @CowFatweightAvg,
						@CowSNFweightAvg, @TotalMilkQuantityBuffaloKG, @TotalMilkQuantityBuffalo,
						@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
						0,1,0,@Current_Datetime, var_User_Id  , var_User_Name , @MusterCycle_StartDate , @MusterCycle_EndDate
						) ;
                        
                        INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id,
						Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id)
                        select var_Org_Id, @AgentCollection_Id , MilkType_Id,sum(Quantity_Ltr),
						Roundoff('Quality',sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)))  as Fat,
						Roundoff('Quality',sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr))) as SNF,
						MilkStatus_Id 
						from t005_milkcollectionfarmer where 
						Org_Id = var_Org_Id
						and MCC_Id = var_MCC_Id
						and MCCCollectionShift_Id = @New_MCCCollectionShift_Id
                        and MilkStatus_Id = 'C016001'  
						group by MilkType_Id , MilkStatus_Id;
                        
						-- delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
						-- ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
								
                    end if;
                    
                    
                else
                
					Call USP_Number_Range ('t004_mcccollectionshift', @Year_Id, 'T004', '', @New_MCCCollectionShift_Id);
                
					insert into t004_mcccollectionshift
					(Org_Id, MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
					Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , Created_On , CreatedBy_Id ,
					CreatedBy_Name , Is_MilkDispatch, Expected_End_Time) 
					( select var_Org_Id , @New_MCCCollectionShift_Id , 	var_MCC_Id , @Current_Datetime ,  @CollectionShift_Id , @CollectionShift_Name,
					2, @Current_times , 1 , 0 , @Current_Datetime, @Agent_Id , @Agent_Name , 0 , @ShiftEnd_Time
					from mu05_agent where Org_Id = var_Org_Id and 
					Agent_Id = @Agent_Id limit 1 ) ;
				   
					update t022_tripdocument_item 
					set Is_Reached = 1 ,
					Arrival_At = @Current_Datetime ,
					MCC_CollectionShift_Id = @New_MCCCollectionShift_Id
					where Org_Id = var_Org_Id 
					and TripDocument_Id = var_TripDocument_Id
					and MCC_Id = var_MCC_Id;
				   
					Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
					
					SET @MusterType_Id = (SELECT m005.MusterType_Id
												FROM m005_mcc_version m005
												WHERE MCC_Id = var_MCC_Id AND is_deleted = 0
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
					
					insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
					Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
					Final_Qty_Cow_Ltr,  
					Final_Qty_Cow_KG,  
					Final_FAT_Cow_WtAvg, 
					Final_SNF_Cow_WtAvg,
					Final_Qty_Buf_KG , 
					Final_Qty_Buf_Ltr, 
					Final_FAT_Buf_WtAvg , 
					Final_SNF_Buf_WtAvg, 
					Final_Amout_Cow , 
					Final_Amout_Buf,
					 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
					) values 
					( var_Org_Id, @AgentCollection_Id , var_MCC_Id , @New_MCCCollectionShift_Id , @Agent_Id  , New_Driver_Id , 
					0,
					0 ,
					0, 
					0,
					0, 0, 0,
					0, 0, 0,
					0 , 0, 0, 0,
					0,1,0,@Current_Datetime, @Agent_Id  , @Agent_Name  , @MusterCycle_StartDate , @MusterCycle_EndDate
					) ;
					
					INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id,
					Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id)
					value 
					(var_Org_Id,@AgentCollection_Id, 'C011001', 0 , 0, 0, 'C016001' );
                
                end if;
				
                INSERT INTO t009_milkcollectiondairy_header
				(Org_Id, MilkCollectionDairy_Id, TripDocument_Id, Vehicle_Id,
				Is_Active, Is_Deleted, Created_On, CreatedBy_Id, CreatedBy_Name)
				VALUES (var_Org_Id, New_MilkCollectionDairy_Id, var_TripDocument_Id, 
				var_Vehicle_Id, 1, 0, Today_Date, var_User_Id, var_User_Name);  
              
                -- Save Data in mu02_role_menu table from temp table
				INSERT INTO t009_milkcollectiondairy_mcc
				(Org_Id,MilkCollectionDairy_Id, MCCCollectionShift_Id,
				MCC_Id, MilkType_Id,MilkStatus_Id, Is_Active, Is_Deleted, 
				Created_On, CreatedBy_Id, CreatedBy_Name)
				Values ( var_Org_Id ,New_MilkCollectionDairy_Id, @New_MCCCollectionShift_Id,
				var_MCC_Id, 'C011001','C016001', 1, 0, 
				Today_Date, var_User_Id, var_User_Name);  

				INSERT INTO t009_milkcollectiondairy_milk
				(Org_Id,MilkCollectionDairy_Id, MilkType_Id,MilkStatus_Id)
				SELECT var_Org_Id,New_MilkCollectionDairy_Id,
				'C011001','C016001'; 
                
				

				UPDATE t009_milkcollectiondairy_header
				SET Driver_Id = New_Driver_Id
				WHERE Org_Id = var_Org_Id 
				AND MilkCollectionDairy_Id = New_MilkCollectionDairy_Id; 
                
			else
				INSERT INTO t009_milkcollectiondairy_header
				(Org_Id, MilkCollectionDairy_Id, TripDocument_Id, Vehicle_Id,
				Is_Active, Is_Deleted, Created_On, CreatedBy_Id, CreatedBy_Name)
				VALUES (var_Org_Id, New_MilkCollectionDairy_Id, var_TripDocument_Id, 
				var_Vehicle_Id, 1, 0, Today_Date, var_User_Id, var_User_Name);  
				
						
				-- Convert XML Data to Table format
				DROP TEMPORARY TABLE IF EXISTS temp_menu;
				CREATE TEMPORARY TABLE temp_menu (PKeyRowNum int, 
				MilkType_Id varchar(20), MilkStatus_Id varchar(20));
					
				SET row_count := extractValue(var_MilkData,'count(//Milk/MilkData)');
				WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//Milk/MilkData[', k, ']');
					INSERT INTO temp_menu VALUES (
						k,
						extractValue(var_MilkData, concat(xpath,'/MilkType_Id')),
						extractValue(var_MilkData, concat(xpath,'/MilkStatus_Id'))
					);
				END WHILE;
				
				-- Save Data in mu02_role_menu table from temp table
				INSERT INTO t009_milkcollectiondairy_mcc
				(Org_Id,MilkCollectionDairy_Id, MCCCollectionShift_Id,
				MCC_Id, MilkType_Id,MilkStatus_Id, Is_Active, Is_Deleted, 
				Created_On, CreatedBy_Id, CreatedBy_Name)
				SELECT var_Org_Id ,New_MilkCollectionDairy_Id, var_MCCCollectionShift_Id,
				var_MCC_Id, MilkType_Id,MilkStatus_Id, 1, 0, 
				Today_Date, var_User_Id, var_User_Name
				FROM temp_menu;  

				INSERT INTO t009_milkcollectiondairy_milk
				(Org_Id,MilkCollectionDairy_Id, MilkType_Id,MilkStatus_Id)
				SELECT var_Org_Id,New_MilkCollectionDairy_Id,
				MilkType_Id,MilkStatus_Id
				FROM temp_menu;  
				
				-- Drop temp table
				DROP TEMPORARY TABLE temp_menu;
				
				UPDATE t009_milkcollectiondairy_header
				SET Driver_Id = New_Driver_Id
				WHERE Org_Id = var_Org_Id 
				AND MilkCollectionDairy_Id = New_MilkCollectionDairy_Id; 
                
			end if;
            
            
			
			
           
			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			New_MilkCollectionDairy_Id AS Result_Extra_Key;
		end if;
		end;
        elseif (var_Method_Name = 'Update') then
		begin
			DECLARE New_Driver_Id  varchar(20);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
			DECLARE Today_Date DATETIME;
            set Today_Date = CONVERT_TZ(var_Date, '+00:00', '+00:00');
            -- CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            select Driver_Id INTO New_Driver_Id
            from t021_tripdocument_header
            where TripDocument_Id = var_TripDocument_Id;
            
			Update t009_milkcollectiondairy_header
			set 
            TripDocument_Id = var_TripDocument_Id,
            Vehicle_Id = var_Vehicle_Id,
            Is_Active =  0,
			Is_Deleted = 1,
			LastEdited_On = Today_Date,
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name 
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;   
            
					
				-- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_menu;
			CREATE TEMPORARY TABLE temp_menu (PKeyRowNum int, 
			MilkType_Id varchar(20), MilkStatus_Id varchar(20));
				
			SET row_count := extractValue(var_MilkData,'count(//Milk/MilkData)');
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//Milk/MilkData[', k, ']');
				INSERT INTO temp_menu VALUES (
					k,
					extractValue(var_MilkData, concat(xpath,'/MilkType_Id')),
					extractValue(var_MilkData, concat(xpath,'/MilkStatus_Id'))
				);
			END WHILE;
			
			-- Save Data in mu02_role_menu table from temp table
			Insert into t009_milkcollectiondairy_mcc
			(Org_Id,MilkCollectionDairy_Id, MCCCollectionShift_Id,MCC_Id,
			MilkType_Id,MilkStatus_Id,
			Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name)
			SELECT var_Org_Id,var_MilkCollectionDairy_Id, var_MCCCollectionShift_Id,var_MCC_Id,
			MilkType_Id,MilkStatus_Id,
			1, 0,Today_Date, var_User_Id,var_User_Name
			from temp_menu;  

			Insert into t009_milkcollectiondairy_milk
			(Org_Id,MilkCollectionDairy_Id,
			MilkType_Id,MilkStatus_Id)
			SELECT var_Org_Id,var_MilkCollectionDairy_Id,
			MilkType_Id,MilkStatus_Id
			from temp_menu;  
			
			-- Drop temp table
			drop temporary table temp_menu; 
            
            Update t009_milkcollectiondairy_header
			set 
            Driver_Id = New_Driver_Id
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            

			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
			
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			DECLARE Today_Date DATETIME;
            set Today_Date = CONVERT_TZ(var_Date, '+00:00', '+00:00');

			Update t009_milkcollectiondairy_header
			set 
            Is_Active =  0,
			Is_Deleted = 1,
			LastEdited_On = Today_Date,
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name 
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;   
            
            Update t009_milkcollectiondairy_mcc
			set 
            Is_Active =  0,
			Is_Deleted = 1,
			LastEdited_On = Today_Date,
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name 
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;   
            
            Delete from t009_milkcollectiondairy_milk
            where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Confirm' and var_VehicleType_Id  ='C020001') then
		begin
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Set_TransporterCost varchar(20);
			DECLARE Today_Date DATETIME;
            set Today_Date = CONVERT_TZ(var_Date, '+00:00', '+00:00');
            -- CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            
            
            Update t009_milkcollectiondairy_header
			set 
            Is_Confirm =  1,
			Confirm_On = Today_Date,
			Confirm_By = var_User_Id 
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
		
            SELECT 1 AS Result_Id, 
			'Confirm' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
		end;
	elseif (var_Method_Name = 'Confirm' and var_VehicleType_Id  ='C020002') then
		begin
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Set_TransporterCost varchar(20);
			DECLARE Today_Date DATETIME;
            set Today_Date = CONVERT_TZ(var_Date, '+00:00', '+00:00');
            -- CONVERT_TZ(NOW(), '+00:00', '+00:00');
           
            Update t009_milkcollectiondairy_header
			set 
            Is_Confirm =  1,
			Confirm_On = Today_Date,
			Confirm_By = var_User_Id 
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
		
            SELECT 1 AS Result_Id, 
			'Confirm' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
		end;
	
    elseif (var_Method_Name = 'Release') then
		begin
			DECLARE Today_Date DATETIME;
            set Today_Date = CONVERT_TZ(var_Date, '+00:00', '+00:00');
            -- CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            Update t009_milkcollectiondairy_header
			set 
            Is_Release =  1,
			Release_On = Today_Date,
			Release_By = var_User_Id 
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
           
			update t004_mcccollectionshift t004
			inner join t022_tripdocument_item t022 on
			t022.Org_Id = t004.Org_Id
			and t022.MCC_CollectionShift_Id = t004.MCCCollectionShift_Id
			and t022.MCC_Id = t004.MCC_Id
			inner join t009_milkcollectiondairy_header t009 on
			t009.Org_Id = t022.Org_Id
			and t009.TripDocument_Id = t022.TripDocument_Id
			and t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			set Shift_Status = '2',
				Is_MilkDispatch = '2';
                            
                            
            
            SELECT 1 AS Result_Id, 
			'Release' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
            if(var_VehicleType_Id = 'C020001')then
            
				set @TripDocument_Id  = (select TripDocument_Id from t009_milkcollectiondairy_header
								where Org_Id = var_Org_Id 
								and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1);
				
				
				call USP_IssueCansToMcc('', var_Org_Id,@TripDocument_Id, '');
				
            end if;
            
             

            
            
		end;
        elseif (var_Method_Name = 'Locked' and var_VehicleType_Id  ='C020001') then
		begin
			
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Set_TransporterCost varchar(20);
            DECLARE Today_Date DATETIME;
            Declare Year_Id varchar(10);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
			DECLARE Set_CollectionShift_Id varchar(20);
			set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            Set Set_CollectionShift_Id = (select m006.CollectionShift_Id from t009_milkcollectiondairy_header t009
							inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
								and t021.TripDocument_Id = t009.TripDocument_Id
							inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id 
								and t021.Route_Trip_Id = m008.Entry_Id
							inner join m006_route m006 on m006.Org_Id = m008.Org_Id 
								and m006.Route_Id = m008.Route_Id
							where 
							t009.Org_Id = var_Org_Id
							and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1);
            
            
            -- Update FAT & SNF
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0091.TripDocument_Id = t0092.TripDocument_Id
			and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.Batch_Id = t0092.Batch_Id
			set t0092.Fat = (SELECT FORMAT(AVG(t0091.Fat), 2) FROM t009_milkcollectiondairy_quality t0091
					   WHERE t0092.Org_Id = t0091.Org_Id 
                       and t0091.TripDocument_Id = t0092.TripDocument_Id
						and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
						and t0091.MCC_Id = t0092.MCC_Id
                        and t0091.Batch_Id = t0092.Batch_Id
                       ),
			t0092.SNF = (SELECT FORMAT(AVG(t0091.SNF), 2) FROM t009_milkcollectiondairy_quality t0091
					WHERE t0092.Org_Id = t0091.Org_Id 
                    and t0091.TripDocument_Id = t0092.TripDocument_Id
					and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
					and t0091.MCC_Id = t0092.MCC_Id
                    and t0091.Batch_Id = t0092.Batch_Id
                    )            
            where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.Batch_Id = t0092.Batch_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
            
            
            update t009_milkcollectiondairy_quantity t009 
            inner join t006_milkcollectionagent t006  
			on t009.Org_Id = t006.Org_Id
            and t009.MCCCollectionShift_Id = t006.MCCCollectionShift_Id 
            and t009.MCC_Id =  t006.MCC_Id         
			set t009.Rate = if (t009.MilkType_Id = 'C011001' and t006.Final_Qty_Cow_Ltr <> 0 , t006.Final_Amout_Cow / t006.Final_Qty_Cow_Ltr, 
			if (t009.MilkType_Id = 'C011002' and t006.Final_Qty_Buf_Ltr <> 0 , t006.Final_Amout_Buf / t006.Final_Qty_Buf_Ltr, 0.00  )  )
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.TripDocument_Id = var_TripDocument_Id
            and t009.MilkStatus_Id = 'C016001';
            
          
          
            DROP TEMPORARY TABLE IF EXISTS temp_rate;
			CREATE TEMPORARY TABLE temp_rate (
				PKeyRowNum int, 
				Org_Id VARCHAR(45),
				MilkCollectionDairy_Id VARCHAR(45),
				MCC_Id VARCHAR(45),
				Batch_Id VARCHAR(45),
				Rate VARCHAR(45)
				);
			   
			INSERT INTO temp_rate(
			Org_Id, MilkCollectionDairy_Id, 
			MCC_Id, Batch_Id,Rate
			)
			select t0091.Org_Id, t0091.MilkCollectionDairy_Id,t0091.MCC_Id,t0091.Batch_Id, 
            GetMilkRate(t0091.Org_Id, t0091.MCC_Id, Set_CollectionShift_Id, t0091.Fat, t0091.SNF, t0091.MilkType_Id) as Rate
			from t009_milkcollectiondairy_quantity  t0091
			WHERE t0091.Org_Id =  var_Org_Id
			AND t0091.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			AND t0091.MilkStatus_Id = 'C016001'
			AND t0091.TripDocument_Id =  var_TripDocument_Id
			AND (t0091.Rate in (null , '', 0))
            ;
            
          
            SELECT Fat,SNF into RatioFat,RatioSNF  FROM t024_fatsnf_ratio 
            where Ratio_Date <= Today_Date 
            and Org_Id = var_Org_Id
            and Is_Active = 1
            and Is_Deleted = 0
            order by Ratio_Date DESC Limit 1;
            
              
            
           set  @TripId = (select TripDocument_Id from t009_milkcollectiondairy_header
           where Org_Id = var_Org_Id and  MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1 );
		
            SELECT ifnull(TripAmount, 0.00) into Set_TransporterCost FROM t021_tripdocument_header t021
			WHERE t021.TripDocument_Id = var_TripDocument_Id;

            
            -- Update FATKG and SNF KG
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0091.TripDocument_Id = t0092.TripDocument_Id
			and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.Batch_Id = t0092.Batch_Id
			set FatKG =  t0092.FAT * Weight,
			SNFKG = t0092.SNF * Weight          
            where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.Batch_Id = t0092.Batch_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
            
			update t009_milkcollectiondairy_quantity t009 
            inner join temp_rate temp  
			on t009.Org_Id = temp.Org_Id
            and t009.MilkCollectionDairy_Id = temp.MilkCollectionDairy_Id 
            and t009.MCC_Id =  temp.MCC_Id 
            and t009.Batch_Id =  temp.Batch_Id   
			set t009.Rate =   temp.Rate 
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.TripDocument_Id = var_TripDocument_Id
            and t009.MilkStatus_Id = 'C016001'
            AND (t009.Rate in (null , '', 0))
            ;

			DROP TEMPORARY TABLE IF EXISTS temp_rate;
            
            -- Update FatCost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0091.TripDocument_Id = t0092.TripDocument_Id
			and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.Batch_Id = t0092.Batch_Id
			set 
			FatCost =  ( FatKG * (( t0092.Weight * t0092.Rate) / (SNFKG * RatioSNF / RatioFat) ))
			where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.Batch_Id = t0092.Batch_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
     
            
            -- Update SNF Cost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0091.TripDocument_Id = t0092.TripDocument_Id
			and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.Batch_Id = t0092.Batch_Id
            set SNFCost = ( t0092.Weight * t0092.Rate) - FatCost
            where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.Batch_Id = t0092.Batch_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
            
            set @TotalWeight = ( 
            select sum(t0092.Weight)  from t009_milkcollectiondairy_quantity t0092
            where t0092.Org_Id = var_Org_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001'
            ) ;
            
            -- Update MilkCost, TransporterCost and AgentCost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id
            and t0091.TripDocument_Id = t0092.TripDocument_Id
			and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.Batch_Id = t0092.Batch_Id
			set   
            TransporterCost = t0092.Weight * ( Set_TransporterCost / @TotalWeight),
            MilkCost = if(t0092.Rate <> 0 , ((t0092.Weight * ( t0092.Weight / t0092.Rate) ) + (Set_TransporterCost)), 0),
            AgentCost = 0.00
			where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            and t0091.MCCCollectionShift_Id = t0092.MCCCollectionShift_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.Batch_Id = t0092.Batch_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
            
            
            Update f010_milkcollectionmcc_final f010
			-- INNER JOIN t009_milkcollectiondairy_quantity t009
			-- ON t009.Org_Id = f010.Org_Id
			-- AND t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
			-- AND t009.MCC_Id = f010.MCC_Id
			set 
			f010.TransporterCost = 
						(SELECT SUM(t0092_sub.TransporterCost)
							FROM (
								SELECT TransporterCost, MCC_Id
								FROM t009_milkcollectiondairy_quantity
								WHERE Org_Id = f010.Org_Id
									AND MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
									AND MCC_Id = f010.MCC_Id
							) t0092_sub
							GROUP BY t0092_sub.MCC_Id)
                
			where f010.Org_Id = var_Org_Id 
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
            
            UPDATE t009_milkcollectiondairy_quantity t0092
			INNER JOIN t009_milkcollectiondairy_mcccommission t0091
			ON t0092.Org_Id = t0091.Org_Id
				AND t0091.MilkCollectionDairy_Id = t0092.MilkCollectionDairy_Id
				AND t0091.MCC_Id = t0092.MCC_Id
				AND t0091.MPPIType_Id = 'C047001'
			SET AgentCost = ((t0092.Weight * t0091.Amount) / (
				SELECT SUM(t0092_sub.Weight)
				FROM (
					SELECT Weight, MCC_Id
					FROM t009_milkcollectiondairy_quantity
					WHERE Org_Id = var_Org_Id
						AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
						AND MilkStatus_Id = 'C016001'
						AND MCC_Id = t0092.MCC_Id
				) t0092_sub
				GROUP BY t0092_sub.MCC_Id
			))
			WHERE t0092.Org_Id = var_Org_Id
				AND t0092.MCC_Id = t0092.MCC_Id
				AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				AND t0092.MilkStatus_Id = 'C016001';
                
                
                
                Update f010_milkcollectionmcc_final f010
                -- INNER JOIN t009_milkcollectiondairy_quantity t009
				-- ON t009.Org_Id = f010.Org_Id
				-- AND t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
				-- AND t009.MCC_Id = f010.MCC_Id
				set 
				f010.AgentCost = (SELECT SUM(t0092_sub.AgentCost)
							FROM (
								SELECT AgentCost, MCC_Id
								FROM t009_milkcollectiondairy_quantity
								WHERE Org_Id = f010.Org_Id
									AND MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
									AND MCC_Id = f010.MCC_Id
							) t0092_sub
							GROUP BY t0092_sub.MCC_Id)
				where f010.Org_Id = var_Org_Id 
				and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;


			/*
			Update t009_milkcollectiondairy_header
			set 
            Is_Locked =  1,
			LastEditedBy_Id = var_User_Id ,
            LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            */

			Update t009_milkcollectiondairy_quantity t009
			set 
			FatKG = (t009.FatKG / 100),
            SNFKG = (t009.SNFKG / 100),
            t009.MilkPrice = (t009.Liters * t009.Rate),
            t009.TotalLandedCost = ((t009.Liters * t009.Rate) + t009.AgentCost + t009.TransporterCost)
            where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
            Update t009_milkcollectiondairy_quantity t009
			set 
			t009.FEQ = ((((t009.SNFKG)*RatioSNF)/100)+(t009.FatKG))
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
          
			call USP_AdminMilkCollectionInSAP_Set('SetNewGRNTruck', var_Org_Id, '', var_MilkCollectionDairy_Id, '', '',var_User_Id, var_User_Name);

			
			
            
            SELECT 1 AS Result_Id, 
			'Locked' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
		end;
	elseif (var_Method_Name = 'Locked' AND var_VehicleType_Id = 'C020002') then
		begin
			
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Set_TransporterCost varchar(20);
            DECLARE MinimumQuantity decimal(8,2);
            DECLARE MinimumFat decimal(8,2);
            DECLARE MinimumSNF decimal(8,2);
            DECLARE BaseRate decimal(8,2);
            DECLARE FAT_Incentive decimal(8,3);
            DECLARE SNF_Incentive decimal(8,3);
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            DECLARE Today_Date DATETIME;
            DECLARE Set_CollectionShift_Id varchar(20);
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            
            
            SELECT Fat,SNF into RatioFat,RatioSNF  FROM t024_fatsnf_ratio 
            where Ratio_Date <= Today_Date 
            and Org_Id = var_Org_Id
            and Is_Active = 1
            and Is_Deleted = 0
            order by Ratio_Date DESC Limit 1;
            
            set  @TripId = (select TripDocument_Id from t009_milkcollectiondairy_header
            where Org_Id = var_Org_Id and  MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1 );
           
			select ifnull(sum(t006.Final_Amout_Cow),0.00),ifnull(sum(t006.Final_Amout_Buf),0.00) into @CowAmount,@BufAmount from t022_tripdocument_item t022 
			inner join t006_milkcollectionagent t006 on t006.MCC_Id = t022.MCC_Id 
			and  t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id 
			where t022.Org_Id = var_Org_Id and  t022.TripDocument_Id = var_TripDocument_Id;
            
			set  @QuantityCow = (select sum(Weight) from t009_milkcollectiondairy_quantity
			where Org_Id = var_Org_Id and  MilkCollectionDairy_Id = var_MilkCollectionDairy_Id 
            and  MilkType_Id = 'C011001');
             
             set  @QuantityBuf = (select sum(Weight) from t009_milkcollectiondairy_quantity
			where Org_Id = var_Org_Id and  MilkCollectionDairy_Id = var_MilkCollectionDairy_Id 
            and  MilkType_Id = 'C011002');
             
            SELECT ifnull(TripAmount, 0.00) into Set_TransporterCost FROM t021_tripdocument_header t021
			WHERE t021.TripDocument_Id = var_TripDocument_Id;
            
			update t009_milkcollectiondairy_quantity t009        
			set t009.Rate = if (t009.MilkType_Id = 'C011001', 
            case when @QuantityCow <> 0 then @CowAmount / @QuantityCow else  0 end, 
			if (t009.MilkType_Id = 'C011002',
            case when @QuantityBuf <> 0 then @BufAmount / @QuantityBuf else  0 end , 0.00  )  )
            
            -- set t009.Rate = if (t009.MilkType_Id = 'C011001' and t006.Final_Qty_Cow_KG <> 0 , t006.Final_Amout_Cow / t006.Final_Qty_Cow_KG, 
			-- if (t009.MilkType_Id = 'C011002' and t006.Final_Qty_Buf_KG <> 0 , t006.Final_Amout_Buf / t006.Final_Qty_Buf_KG, 0.00  )  )
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.TripDocument_Id = var_TripDocument_Id
            and t009.MilkStatus_Id = 'C016001';
            
            -- Update FAT & SNF
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
			set t0092.Fat = (SELECT FORMAT(AVG(t0091.Fat), 2) FROM t009_milkcollectiondairy_quality t0091
					   WHERE t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo 
                       and t0092.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id ),
			t0092.SNF = (SELECT FORMAT(AVG(t0091.SNF), 2) FROM t009_milkcollectiondairy_quality t0091
					WHERE t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
                    and t0092.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id )            
            where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
            
            
            
            -- Update FATKG and SNF KG
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
			set FatKG = t0092.FAT * Weight,
			SNFKG = t0092.SNF * Weight          
            where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND Weight > 0
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
            
            -- Update FatCost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0092.CellNo = t0091.CellNo
			set FatCost =  ( case when SNFKG <> 0 then
            FatKG * (( t0092.Weight * t0092.Rate) / (SNFKG * RatioSNF / RatioFat) )  else 0 end
            )
			where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            AND t0092.Weight > 0
            and t0092.MilkStatus_Id = 'C016001';
          
            -- Update SNF Cost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
            set SNFCost = ( t0092.Weight * t0092.Rate) - FatCost
            where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
             AND t0092.Weight > 0
             and t0092.MilkStatus_Id = 'C016001';
          
             
             set @TotalWeight = ( select sum(t0092.Weight)  from t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
			where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
             AND t0092.Weight > 0
             and t0092.MilkStatus_Id = 'C016001') ;
             
            
            -- Update MilkCost, TransporterCost and AgentCost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
			set       
            TransporterCost = t0092.Weight * ( Set_TransporterCost / @TotalWeight),
            MilkCost = ((t0092.Weight * ( case when t0092.Rate <> 0 then  t0092.Weight / t0092.Rate else 0 end) ) + (Set_TransporterCost)),
            AgentCost = 0.00
			where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			AND t0092.Weight > 0
            and t0092.MilkStatus_Id = 'C016001';
            
            /*
            Update t009_milkcollectiondairy_header
			set 
            Is_Locked =  1,
			LastEditedBy_Id = var_User_Id ,
            LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            */
            call USP_AdminMilkCollectionInSAP_Set('SetGRNTanker', var_Org_Id, '', var_MilkCollectionDairy_Id, '', '',var_User_Id, var_User_Name);

            SELECT 1 AS Result_Id, 
			'Locked' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
		end;
	elseif (var_Method_Name = 'Locked' AND var_VehicleType_Id = 'BulkSupplier') then
		begin
			
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Set_TransporterCost varchar(20);
            DECLARE MinimumQuantity decimal(8,2);
            DECLARE MinimumFat decimal(8,2);
            DECLARE MinimumSNF decimal(8,2);
            DECLARE BaseRate decimal(8,2);
            DECLARE FAT_Incentive decimal(8,3);
            DECLARE SNF_Incentive decimal(8,3);
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            DECLARE Today_Date DATETIME;
            DECLARE Set_CollectionShift_Id varchar(20);
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT Fat,SNF into RatioFat,RatioSNF  FROM t024_fatsnf_ratio 
            where Ratio_Date <= Today_Date 
            and Org_Id = var_Org_Id
            and Is_Active = 1
            and Is_Deleted = 0
            order by Ratio_Date DESC Limit 1;
            
           
            
			-- Update FAT & SNF
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0092.CellNo = t0091.CellNo
            and t0092.MCC_Id = t0091.MCC_Id
            and t0092.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
			set t0092.Fat = t0091.Fat,
			t0092.SNF = t0091.SNF            
            where t0092.Org_Id = var_Org_Id 
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
            
            
            
            UPDATE t009_milkcollectiondairy_quantity t0092
			SET t0092.Rate = (
				SELECT GetMilkRate(t0091_sub.Org_Id, t0091_sub.MCC_Id, 'C015003', t0091_sub.Fat, t0091_sub.SNF, t0091_sub.MilkType_Id)
				FROM (
					SELECT t0091.Org_Id, t0091.MCC_Id, t0091.Fat, t0091.SNF, t0091.MilkType_Id
					FROM t009_milkcollectiondairy_quantity t0091
					WHERE t0091.Org_Id = t0092.Org_Id
						AND t0091.MilkCollectionDairy_Id = t0092.MilkCollectionDairy_Id
						AND t0091.MCC_Id = t0092.MCC_Id
						AND t0091.CellNo = t0092.CellNo
				) t0091_sub
			)
			WHERE t0092.Org_Id = var_Org_Id
				AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				AND t0092.MilkStatus_Id = 'C016001';
            
            
            -- Update FATKG and SNF KG
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quantity t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0092.CellNo = t0091.CellNo
            and t0092.MCC_Id = t0091.MCC_Id
            and t0092.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
			set t0092.FatKG = t0091.FAT * t0091.Weight,
			t0092.SNFKG = t0091.SNF * t0091.Weight          
            where t0092.Org_Id = var_Org_Id 
            AND t0092.Weight > 0
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
            
            -- Update FatCost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quantity t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0092.CellNo = t0091.CellNo
            and t0092.MCC_Id = t0091.MCC_Id
            and t0092.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
			set t0092.FatCost =  ( t0091.FatKG * (( t0091.Weight * t0091.Rate) / (t0091.SNFKG * RatioSNF / RatioFat) )
            )
			where t0092.Org_Id = var_Org_Id 
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            AND t0092.Weight > 0
            and t0092.MilkStatus_Id = 'C016001';
          
            -- Update SNF Cost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quantity t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0092.CellNo = t0091.CellNo
            and t0092.MCC_Id = t0091.MCC_Id
            and t0092.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
            set t0092.SNFCost = ( t0091.Weight * t0091.Rate) - t0091.FatCost
            where t0092.Org_Id = var_Org_Id 
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			AND t0092.Weight > 0
			and t0092.MilkStatus_Id = 'C016001';
		
             
            
            -- Update MilkCost, TransporterCost and AgentCost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quantity t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0092.CellNo = t0091.CellNo
            and t0092.MCC_Id = t0091.MCC_Id
            and t0092.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
			set       
            t0092.TransporterCost = 0.00,
            t0092.MilkCost = ((t0091.Weight * ( t0091.Weight / t0091.Rate) )),
            t0092.AgentCost = 0.00
			where t0092.Org_Id = var_Org_Id 
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			AND t0092.Weight > 0
            and t0092.MilkStatus_Id = 'C016001';
            
            /*
            Update t009_milkcollectiondairy_header
			set 
            Is_Locked =  1,
			LastEditedBy_Id = var_User_Id ,
            LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            */
            call USP_AdminMilkCollectionInSAP_Set('SetGRNBulkSupplier', var_Org_Id, '', var_MilkCollectionDairy_Id, '', '',var_User_Id, var_User_Name);

            SELECT 1 AS Result_Id, 
			'Locked' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
		end;
    elseif (var_Method_Name = 'BulkSupplier') then
		begin
			Declare New_MilkCollectionDairy_Id varchar(20);
			Declare Year_Id varchar(10);
            DECLARE Today_Date DATETIME;
            set Today_Date = CONVERT_TZ(var_Date, '+00:00', '+00:00');
            -- CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            set Year_Id = (select right(left(date(Today_Date),4),(2)));
			Call USP_Number_Range ('t009_milkcollectiondairy_header', Year_Id, 'T009', '', New_MilkCollectionDairy_Id );
            
            INSERT INTO t009_milkcollectiondairy_header
			(Org_Id, MilkCollectionDairy_Id, Vehicle_Id,
            Is_Active, Is_Deleted,Is_OutsideVehicle, Created_On, CreatedBy_Id, CreatedBy_Name)
			VALUES (var_Org_Id, New_MilkCollectionDairy_Id, 
            var_Vehicle_Id, 1, 0,1, Today_Date, var_User_Id, var_User_Name); 
            
            INSERT INTO t009_milkcollectiondairy_milk
			(Org_Id, MilkCollectionDairy_Id, MilkType_Id,MilkStatus_Id)
			VALUES (var_Org_Id, New_MilkCollectionDairy_Id,'C011001','C016001'); 
            
            
            INSERT INTO t009_milkcollectiondairy_mcc
			(Org_Id, MilkCollectionDairy_Id,MCCCollectionShift_Id,MCC_Id,
            MilkType_Id,MilkStatus_Id,
            Is_Active, Is_Deleted, Created_On, CreatedBy_Id, CreatedBy_Name)
			VALUES (var_Org_Id, New_MilkCollectionDairy_Id,'',var_MCC_Id,
            'C011001','C016001',
             1, 0, Today_Date, var_User_Id, var_User_Name); 
             
			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			New_MilkCollectionDairy_Id AS Result_Extra_Key;
	
        end;
	elseif (var_Method_Name = 'SetData') then
        begin
        
		DECLARE Year_Id varchar(10);
        DECLARE Set_CollectionShift_Id varchar(20);
        DECLARE New_MilkCollectionPosting_Id VARCHAR(20);
        DECLARE milkTypeValue VARCHAR(20);
        DECLARE Set_Created_On VARCHAR(20);
         DECLARE done INT DEFAULT FALSE;
         

        DECLARE milkTypeCursor CURSOR FOR
            SELECT MilkType_Id
            FROM t009_milkcollectiondairy_quantity 
            WHERE Org_Id = var_Org_Id
                AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                AND MilkType_Id IN ('C011001', 'C011002')
            GROUP BY MilkType_Id;
            
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

        -- Open the cursor
        OPEN milkTypeCursor;

        milkTypeLoop: LOOP
            FETCH milkTypeCursor INTO milkTypeValue;

            -- Exit the loop if there are no more rows
            IF done THEN
                LEAVE milkTypeLoop;
            END IF;

            -- Your existing code here...
            
            
            
            SELECT Created_On INTO Set_Created_On 
            FROM t009_milkcollectiondairy_header 
            WHERE Org_Id = var_Org_Id AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

            set Set_CollectionShift_Id = (
                SELECT m006.CollectionShift_Id  
                FROM t009_milkcollectiondairy_header t009
                INNER JOIN t021_tripdocument_header t021 ON t021.TripDocument_Id = t009.TripDocument_Id AND t021.Org_Id = t009.Org_Id 
                INNER JOIN m008_route_vehicle m008 ON m008.Entry_Id = t021.Route_Trip_Id AND m008.Org_Id = t021.Org_Id 
                INNER JOIN m006_route m006 ON m006.Route_Id = m008.Route_Id AND m006.Org_Id = m008.Org_Id 
                WHERE t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                AND t009.Org_Id = var_Org_Id 
            );

			
            if exists (
                SELECT MilkCollectionPosting_Id 
                FROM t009_milkcollectiondairy_posting 
                WHERE Org_Id = var_Org_Id 
                    AND CollectionShift_Id = Set_CollectionShift_Id 
                    AND DATE(Created_On) = DATE(Set_Created_On)
                    AND (Year IS NULL OR Year = '' OR SAP_Document_Id IS NULL OR SAP_Document_Id = '')
                    AND MilkType_Id = milkTypeValue
            ) THEN
                set @MilkCollectionPosting_Id = (
                    SELECT MilkCollectionPosting_Id 
                    FROM t009_milkcollectiondairy_posting 
                    WHERE Org_Id = var_Org_Id 
                        AND CollectionShift_Id = Set_CollectionShift_Id 
                        AND DATE(Created_On) = DATE(Set_Created_On)
                        AND MilkType_Id = milkTypeValue
                );
                
               

                UPDATE t009_milkcollectiondairy_posting t0091
                inner join t009_milkcollectiondairy_quantity t0092 on  
                t0092.Org_Id = t0091.Org_Id
                and t0092.MilkStatus_Id = 'C016001'
                and t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                inner join t009_milkcollectiondairy_header t009 on  
                t009.Org_Id = t0091.Org_Id or t009.Org_Id = t0092.Org_Id
                and t009.Is_Confirm =1
                and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                SET 
                t0091.Weight = t0091.Weight + COALESCE((SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity WHERE Org_Id = t0091.Org_Id AND MilkStatus_Id = 'C016001' and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id AND MilkType_Id = milkTypeValue), 0),
                t0091.Liters = t0091.Liters + COALESCE((SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity WHERE Org_Id = t0091.Org_Id AND MilkStatus_Id = 'C016001' and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id AND MilkType_Id = milkTypeValue), 0),
                t0091.Fat = t0091.Fat + COALESCE((SELECT AVG(Fat) FROM t009_milkcollectiondairy_quantity WHERE Org_Id = t0091.Org_Id AND MilkStatus_Id = 'C016001' and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id AND MilkType_Id = milkTypeValue), 0),
                t0091.FatKG = t0091.FatKG + COALESCE((SELECT sum(FatKG) FROM t009_milkcollectiondairy_quantity WHERE Org_Id = t0091.Org_Id AND MilkStatus_Id = 'C016001' and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id AND MilkType_Id = milkTypeValue), 0),
                t0091.SNF = t0091.SNF + COALESCE((SELECT avg(SNF) FROM t009_milkcollectiondairy_quantity WHERE Org_Id = t0091.Org_Id AND MilkStatus_Id = 'C016001' and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id AND MilkType_Id = milkTypeValue), 0),
                t0091.SNFKG = t0091.SNFKG + COALESCE((SELECT sum(SNFKG) FROM t009_milkcollectiondairy_quantity WHERE Org_Id = t0091.Org_Id AND MilkStatus_Id = 'C016001' and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id AND MilkType_Id = milkTypeValue), 0),
                t0091.TotalLandedCost = t0091.TotalLandedCost + COALESCE((SELECT sum(TotalLandedCost) FROM t009_milkcollectiondairy_quantity WHERE Org_Id = t0091.Org_Id AND MilkStatus_Id = 'C016001' and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id AND MilkType_Id = milkTypeValue), 0),
                t0091.FatRate = t0091.FatRate + COALESCE((SELECT sum(FatRate) FROM t009_milkcollectiondairy_quantity WHERE Org_Id = t0091.Org_Id AND MilkStatus_Id = 'C016001' and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id AND MilkType_Id = milkTypeValue), 0),
                t0091.SNFRate = t0091.SNFRate + COALESCE((SELECT sum(SNFRate) FROM t009_milkcollectiondairy_quantity WHERE Org_Id = t0091.Org_Id AND MilkStatus_Id = 'C016001' and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id AND MilkType_Id = milkTypeValue), 0)
                where 
                t0091.Org_Id = var_Org_Id
                and t0091.CollectionShift_Id = Set_CollectionShift_Id
                and date(t0091.Created_On) = date(Set_Created_On)
                and t0091.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
                
                
            ELSE
                set Year_Id = (SELECT RIGHT(LEFT(CURDATE(), 4), 2));
                CALL USP_Number_Range ('t009_milkcollectiondairy_posting', Year_Id, 'T009', '', New_MilkCollectionPosting_Id );

                INSERT INTO t009_milkcollectiondairy_posting(
                Org_Id ,MilkCollectionPosting_Id ,CollectionShift_Id ,Created_On ,Batch_Id ,MilkStatus_Id ,
                MilkType_Id ,
                Weight ,Liters ,Fat  , FatKG ,SNF  , SNFKG ,
                    TotalLandedCost , FatRate , SNFRate 
                )
                SELECT t0091.Org_Id, New_MilkCollectionPosting_Id, Set_CollectionShift_Id,date(Set_Created_On),RIGHT(New_MilkCollectionPosting_Id, 9),t0091.MilkStatus_Id,
                milkTypeValue,
                    sum(t0091.Weight) ,sum(t0091.Liters) ,avg(t0091.Fat) , sum(ifnull(t0091.FatKG,0)) ,avg(t0091.SNF)  , sum(ifnull(t0091.SNFKG,0)) ,
                    sum(ifnull(t0091.TotalLandedCost,0)) ,sum(ifnull(t0091.FatRate,0)) , sum(ifnull(t0091.SNFRate,0)) 
                FROM t009_milkcollectiondairy_quantity t0091
                inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id
                and t009.Is_Confirm =1
                and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                where t0091.MilkStatus_Id = 'C016001'
                and t0091.Org_Id = var_Org_Id
                and t0091.MilkType_Id = milkTypeValue
                and t0091.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                GROUP BY
                t0091.Org_Id, New_MilkCollectionPosting_Id, Set_CollectionShift_Id, 
                milkTypeValue, 
                t0091.MilkStatus_Id; 
			
            END IF;
           
        END LOOP milkTypeLoop;

        -- Close the cursor
        CLOSE milkTypeCursor;

        SELECT 1 AS Result_Id, 
            'Locked' AS Result_Description, 
            var_MilkCollectionDairy_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Clear') then
		begin
			delete from t009_milkcollectiondairy_header where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
			delete from t009_milkcollectiondairy_mcc where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
			delete from t009_milkcollectiondairy_mccloss where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
			delete from t009_milkcollectiondairy_milk where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
			delete from t009_milkcollectiondairy_quality where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
			delete from t009_milkcollectiondairy_quantity where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
            call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
			't009_milkcollectiondairy_header', var_MilkCollectionDairy_Id, '', '', 
			var_User_Id, var_User_Name);
             
            SELECT 1 AS Result_Id, 
            'Clear' AS Result_Description, 
            var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Reverse') then
		begin
			
			set @var_Is_Locked = (select Is_Locked from t009_milkcollectiondairy_header 
			where Org_Id = var_Org_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
            
            if(@var_Is_Locked is null or @var_Is_Locked = '')then
				set @var_Is_Locked =0;
			else
				set @var_Is_Locked =@var_Is_Locked;
            end if;
            
            if(@var_Is_Locked = '1' or @var_Is_Locked =1)then
				
                SELECT -1 AS Result_Id, 
				'Reverse' AS Result_Description, 
				var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
            else
				
				UPDATE t009_milkcollectiondairy_header 
				SET Confirm_On = NULL ,
				Confirm_By = NULL,
				Is_Confirm = 0 
				where Org_Id = var_Org_Id
				and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				and Is_Locked = 0;
                
                set @var_TripDocument_Id = (select TripDocument_Id from t009_milkcollectiondairy_header 
				where Org_Id = var_Org_Id
				and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
                
                
                UPDATE t021_tripdocument_header 
				SET Is_TripDocument_Locked = 0 
				where Org_Id = var_Org_Id
				and TripDocument_Id = @var_TripDocument_Id;
                
            
				call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				't009_milkcollectiondairy_header', var_MilkCollectionDairy_Id, '', '', 
				var_User_Id, var_User_Name);
                
                call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				't021_tripdocument_header', @var_TripDocument_Id, '', '', 
				var_User_Id, var_User_Name);
				 
				SELECT 1 AS Result_Id, 
				'Reverse' AS Result_Description, 
				var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
            end if;

            
            
            
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
