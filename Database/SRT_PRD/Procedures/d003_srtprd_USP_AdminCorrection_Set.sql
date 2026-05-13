-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminCorrection_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminCorrection_Set`(
	var_Method_Name VARCHAR(50),
    var_Org_Id VARCHAR(10),
	var_CorrectionRequest_Id VARCHAR(20),
	var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(45),
	var_ApprovalStatus_Id INT,
    var_Approved_Quantity_Ltr VARCHAR(45),
    var_Approved_Fat VARCHAR(45),
    var_Approved_SNF VARCHAR(45),
    var_ApprovalRemarks LONGTEXT
)
BEGIN
	SET SQL_SAFE_UPDATES=0;
	IF(var_Method_Name = 'Update_L1') THEN
    BEGIN
		declare set_Quantity_Ltr decimal(20,2);
		declare set_FAT decimal(20,2);
		declare set_SNF decimal(20,2);
		declare set_Rate decimal(20,2);
        DECLARE New_MilkCollectionMCCCommission_Id VARCHAR(20);
		DECLARE Year_Id VARCHAR(20);
        
		UPDATE t013_correction_request
        SET Approved_Remark_L1 = var_ApprovalRemarks, 
			Is_Approved_L1 = var_ApprovalStatus_Id, 
			Approved_On_L1 = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
            Approved_By_L1 = var_User_Id, 
            Approved_Name_L1 = var_User_Name
		WHERE Org_Id = var_Org_Id
        AND Correction_Request_Id = var_CorrectionRequest_Id;
    
		IF(var_ApprovalStatus_Id = 1) THEN
        BEGIN
			SELECT 1 AS Result_Id, 
			'Approved' AS Result_Description, 
			var_CorrectionRequest_Id AS Result_Extra_Key;
        END;
        ELSEIF(var_ApprovalStatus_Id = -1) THEN
        BEGIN
			SELECT 1 AS Result_Id, 
			'Rejected' AS Result_Description, 
			var_CorrectionRequest_Id AS Result_Extra_Key;
        END;
        ELSE
        BEGIN
			SELECT -1 AS Result_Id, 
			'Failed' AS Result_Description, 
			var_CorrectionRequest_Id AS Result_Extra_Key;
        END;
        END IF;
    END;
    
    
    
    ELSEIF(var_Method_Name = 'Update_L2') THEN
    BEGIN
		declare set_Quantity_Ltr decimal(20,2);
		declare set_FAT decimal(20,2);
		declare set_SNF decimal(20,2);
		declare set_Rate decimal(20,2);
        DECLARE New_MilkCollectionMCCCommission_Id VARCHAR(20);
		DECLARE Year_Id VARCHAR(20);
        
		UPDATE t013_correction_request
        SET Approved_Remark_L2 = var_ApprovalRemarks, 
			Is_Approved_L2 = var_ApprovalStatus_Id, 
			Approved_On_L2 = CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
            Approved_By_L2 = var_User_Id, 
            Approved_Name_L2 = var_User_Name
		WHERE Org_Id = var_Org_Id
        AND Correction_Request_Id = var_CorrectionRequest_Id;
    
		IF(var_ApprovalStatus_Id = 1) THEN
        BEGIN
			UPDATE t013_correction_request
			SET Approved_Quantity_Ltr = var_Approved_Quantity_Ltr,
				Approved_Fat = var_Approved_Fat,
				Approved_SNF = var_Approved_SNF
			WHERE Org_Id = var_Org_Id
			AND Correction_Request_Id = var_CorrectionRequest_Id;
            
            -- Farmer
            
            SET @kg_to_ltr = (SELECT Kg_To_Ltr_Farmer FROM c001_organization WHERE Org_Id = var_Org_Id);

			set @MCCCollectionShift_Id = (select t005.MCCCollectionShift_Id from t005_milkcollectionfarmer t005
											inner join t013_correction_request t013 on
											t013.Org_Id =t005.Org_Id
											and t013.FarmerCollection_Id =t005.FarmerCollection_Id
											where t013.Org_Id = var_Org_Id
											AND t013.Correction_Request_Id = var_CorrectionRequest_Id limit 1);
                                            
			set @MCC_Id =   (select MCC_Id from  t004_mcccollectionshift where 
								Org_Id = var_Org_Id
								and MCCCollectionShift_Id = @MCCCollectionShift_Id limit 1);
											
			set @set_CollectionShift_Id =   (select CollectionShift_Id from  t004_mcccollectionshift where 
												Org_Id = var_Org_Id
												and MCCCollectionShift_Id = @MCCCollectionShift_Id
												and MCC_Id = @MCC_Id limit 1);
												
			set @set_Collection_Date = (select Collection_Date from  t004_mcccollectionshift where 
											Org_Id = var_Org_Id
											and MCCCollectionShift_Id = @MCCCollectionShift_Id
											and MCC_Id = @MCC_Id limit 1);

			update t005_milkcollectionfarmer t005
			inner join t013_correction_request t013 on
			t013.Org_Id =t005.Org_Id
			and t013.FarmerCollection_Id =t005.FarmerCollection_Id
			set t005.Quantity_Ltr = t013.Approved_Quantity_Ltr,
				t005.Quantity_Kg = t013.Approved_Quantity_Ltr,
				t005.Fat = t013.Approved_Fat,
				t005.SNF = t013.Approved_SNF
			where t013.Org_Id = var_Org_Id
			AND t013.Correction_Request_Id = var_CorrectionRequest_Id;

			update t005_milkcollectionfarmer t005
			inner join t013_correction_request t013 on
			t013.Org_Id =t005.Org_Id
			and t013.FarmerCollection_Id =t005.FarmerCollection_Id
			set t005.Quantity_Ltr = t013.Approved_Quantity_Ltr,
				t005.Quantity_Kg = t013.Approved_Quantity_Ltr / @kg_to_ltr,
				t005.Fat = t013.Approved_Fat,
				t005.SNF = t013.Approved_SNF
			where t013.Org_Id = var_Org_Id
			AND t013.Correction_Request_Id = var_CorrectionRequest_Id;
					   
			update t005_milkcollectionfarmer t005
			inner join t013_correction_request t013 on
			t013.Org_Id =t005.Org_Id
			and t013.FarmerCollection_Id =t005.FarmerCollection_Id
			set t005.ApplicableRate = GetMilkRateBackDate(t005.Org_Id,t005.MCC_Id,@set_CollectionShift_Id,
															t005.Fat,t005.SNF,t005.MilkType_Id,
															@set_Collection_Date)
			where t013.Org_Id = var_Org_Id
			AND t013.Correction_Request_Id = var_CorrectionRequest_Id;

			update t005_milkcollectionfarmer t005
			inner join t013_correction_request t013 on
			t013.Org_Id =t005.Org_Id
			and t013.FarmerCollection_Id =t005.FarmerCollection_Id
			set t005.Amount = t005.ApplicableRate * t005.Quantity_Ltr
			where t013.Org_Id = var_Org_Id
			AND t013.Correction_Request_Id = var_CorrectionRequest_Id;
            
            -- Agent 
            
            if exists( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 and MCC_Id = @MCC_Id limit 1) then
            
				Set @Created_On = (select date(Collection_Date) from t004_mcccollectionshift
								where 
								Org_Id = var_Org_Id
								and MCC_Id = @MCC_Id
								and MCCCollectionShift_Id = @MCCCollectionShift_Id limit 1);
								
								
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
				and MCC_Id =@MCC_Id
				and date(Collection_Date) <= date(@Created_On)
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id 
												from t006_milkcollectionagent
												where 
												Org_Id = var_Org_Id
												and MCC_Id =@MCC_Id)
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
				and t004.MCC_Id =@MCC_Id
				and REPLACE(MCCCollectionShift_Id, 'T004', '')  <= REPLACE(@MCCCollectionShift_Id_1, 'T004', '')
				and REPLACE(MCCCollectionShift_Id, 'T004', '')  > REPLACE(@MCCCollectionShift_Id_2, 'T004', '')
				order by Collection_Date  desc;
				
				
				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = @MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;

				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = @MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';

				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = @MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = @MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = @MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;

				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = @MCC_Id
				and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main) and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;

				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = @MCC_Id
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
								and MCC_Id = @MCC_Id  
								and MCCCollectionShift_Id = @MCCCollectionShift_Id ); 
                                    
		
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
					WHERE Org_Id = var_Org_Id and MCC_Id = @MCC_Id  and MCCCollectionShift_Id = @MCCCollectionShift_Id
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
					and t005.MCC_Id = @MCC_Id  
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
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = @MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = var_Org_Id and MilkStatus_Id = 'C016001' ;
				
				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = @MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
			
				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = @MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = @MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
				 set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = @MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;
			
				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = @MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
				
				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = @MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
				
	 
				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				
				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
				
			
				set @AgentCollection_Id = (SELECT AgentCollection_Id FROM t006_milkcollectionagent where Org_Id =var_Org_Id 
									and MCC_Id = @MCC_Id  
									and MCCCollectionShift_Id = @MCCCollectionShift_Id ); 
                                    
		
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
					WHERE Org_Id = var_Org_Id and MCC_Id = @MCC_Id  and MCCCollectionShift_Id = @MCCCollectionShift_Id
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
					and t005.MCC_Id = @MCC_Id  
					and t005.MilkStatus_Id = 'C016001'
					and t005.MCCCollectionShift_Id = @MCCCollectionShift_Id
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
			
            -- Flat
            /*
            set @Entry_Id = (select Entry_Id from f010_milkcollectionmcc_final where 
				Org_Id = var_Org_Id
				and date(Collection_Date) = date(@set_Collection_Date)
				and MCC_Id = @MCC_Id
				and ifnull(CollectionShift_Id,'C015003') = @set_CollectionShift_Id
				limit 1);
                
			set @MilkCollectionDairy_Id = (select MilkCollectionDairy_Id from f010_milkcollectionmcc_final where 
							Org_Id = var_Org_Id
							and Entry_Id = @Entry_Id
							and MCC_Id = @MCC_Id
							limit 1);
                            
			set @kg_to_ltr_Agent = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = var_Org_Id);
			
            
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
			and t0061.AgentCollection_Id = t006.AgentCollection_Id 
			where t006.Org_Id = var_Org_Id
			and t006.MCC_Id = @MCC_Id 
			and t006.MCCCollectionShift_Id = @MCCCollectionShift_Id;

			UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Agent_Quantity_Kg = set_Quantity_Ltr / @kg_to_ltr_Agent,
			f010.Agent_Quantity_Ltr = set_Quantity_Ltr,
            f010.Agent_Fat = set_FAT,
			f010.Agent_SNF = set_SNF,
            f010.MilkRate = set_Rate,
            f010.MilkPrice = set_Rate * set_Quantity_Ltr
			WHERE f010.Org_Id = var_Org_Id
            AND f010.MCC_Id = @MCC_Id 
			AND f010.Entry_Id = @Entry_Id ;
            
			UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Agent_Fat_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_Fat) /100),
			f010.Agent_SNF_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_SNF) /100)
			WHERE f010.Org_Id = var_Org_Id
            AND f010.MCC_Id = @MCC_Id 
			AND f010.Entry_Id = @Entry_Id ;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.FatKG_GainLoss = (f010.Dairy_Fat_Kg - f010.Agent_Fat_Kg),
			f010.SNFKG_GainLoss = (f010.Dairy_SNF_Kg - f010.Agent_SNF_Kg)
			WHERE f010.Org_Id = var_Org_Id
            AND f010.MCC_Id = @MCC_Id 
			AND f010.Entry_Id = @Entry_Id ;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Total_GainLoss = ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
			WHERE f010.Org_Id = var_Org_Id
            AND f010.MCC_Id = @MCC_Id 
			AND f010.Entry_Id = @Entry_Id ;
            
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Is_VoucherLocked = 1,
            f010.Locked_By = var_User_Id,
            f010.Locked_On = now()
			WHERE f010.Org_Id = var_Org_Id
            AND f010.MCC_Id = @MCC_Id 
			AND f010.Entry_Id = @Entry_Id ;
            
			update t009_milkcollectiondairy_mcccommission t9
			inner join f010_milkcollectionmcc_final f010
			on t9.Org_Id = f010.Org_Id and t9.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id and t9.MCC_Id = f010.MCC_Id
			set Amount = f010.Total_GainLoss,
			MCC_Commision = f010.Total_GainLoss
			where f010.Org_Id = var_Org_Id
			and MPPIType_Id = 'C047003' 
			AND f010.MCC_Id = @MCC_Id 
			AND f010.Entry_Id = @Entry_Id ;
            
            
            delete from t009_milkcollectiondairy_mcccommission 
            where var_Org_Id = Org_Id 
            and MCC_Id =  @MCC_Id
            and MPPIType_Id = 'C047003'
            and MilkCollectionDairy_Id = @MilkCollectionDairy_Id;
            
            -- commission
            
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
			and f010.MCC_Id = @MCC_Id 
			and f010.Entry_Id = @Entry_Id 
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
				and MCC_Id = @MCC_Id 
				and Entry_Id = @Entry_Id  limit 1);
				
			
			SET @MusterType_Id = '';
			SET @MusterType_Id = (SELECT m005.MusterType_Id
										FROM m005_mcc_version m005
										WHERE m005.MCC_Id = @MCC_Id AND m005.Is_Deleted = 0
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
			*/
				
			SELECT 1 AS Result_Id, 
			'Approved' AS Result_Description, 
			var_CorrectionRequest_Id AS Result_Extra_Key; 
        END;
        ELSEIF(var_ApprovalStatus_Id = -1) THEN
        BEGIN
			SELECT 1 AS Result_Id, 
			'Rejected' AS Result_Description, 
			var_CorrectionRequest_Id AS Result_Extra_Key;
        END;
        ELSE
        BEGIN
			SELECT -1 AS Result_Id, 
			'Failed' AS Result_Description, 
			var_CorrectionRequest_Id AS Result_Extra_Key;
        END;
        END IF;
    END;
    
    
    
    /*
	ELSEIF (var_Method_Name = 'Update_L2') THEN
		BEGIN
		DECLARE var_FarmerCollection_Id VARCHAR(20);
        
				Update t013_correction_request
                set 
                Approved_Quantity_Ltr = var_Approved_Quantity_Ltr,
				Approved_Fat = var_Approved_Fat,
				Approved_SNF = var_ApprovalStatus_Id,
				Approved_By = var_User_Id,
				Approved_Name = var_Approved_SNF,
                Approved_Remark = var_ApprovalRemarks,
                Approved_On = Now(),
				Is_Approved = var_ApprovalStatus_Id
                
                where Org_Id = var_Org_Id 
                and Correction_Request_Id = var_CorrectionRequest_Id;   
                
                
                IF var_ApprovalStatus_Id = 1 THEN
               
                set var_FarmerCollection_Id = (select FarmerCollection_Id 
                from t013_correction_request
                where Org_Id = var_Org_Id 
                and Correction_Request_Id = var_CorrectionRequest_Id);
                
                
                Update t005_milkcollectionfarmer
                set 
				Quantity_Ltr = var_Approved_Quantity_Ltr,
                Fat = var_Approved_Fat,
                SNF = var_Approved_SNF
                
                where Org_Id = var_Org_Id 
                and FarmerCollection_Id = var_FarmerCollection_Id;
                
                SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_FarmerCollection_Id AS Result_Extra_Key;
               
                END IF;
               
				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_CorrectionRequest_Id AS Result_Extra_Key;
        END;
        */
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
