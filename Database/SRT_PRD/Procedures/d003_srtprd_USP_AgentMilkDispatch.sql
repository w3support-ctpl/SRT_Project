-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMilkDispatch` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMilkDispatch`(
Var_Method_Name varchar(255),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_MCC_Collection_Shift Varchar(20),
Var_Profile_Id varchar(20),
Var_Driver_Id varchar(20),
Var_MilkStatus_Id varchar(20),
Var_AluminumCan_Without_Lid varchar(20),
Var_AluminumCan_With_Lid varchar(20),
Var_PlasticCan_Without_Lid varchar(20),
Var_PlasticCan_With_Lid varchar(20) ,
Var_IssueEmptyCan_Id varchar(20),
var_XMLData TEXT ,
Var_TripDocument_Id varchar(20),
Var_Dealer_Name longtext
)
BEGIN
	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    set sql_mode = '';
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    
    insert into l003_reqbody_log(Id , Req_Body ) value 
    (Var_MCC_Id , concat(Var_MCC_Id , '>' , Var_MCC_Collection_Shift ,'>' , Var_MilkStatus_Id , '>' , var_XMLData) );
    
    if (Var_Method_Name = 'MilkDispatch') then
		begin
        	Declare RowCnt int;
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            
		set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);

        
        if exists(select 1 from t004_mcccollectionshift where  Org_Id =Var_Org_Id and MCC_Id = Var_MCC_Id  and MCCCollectionShift_Id = Var_MCC_Collection_Shift AND Is_MilkDispatch = 1 ) then 
        

			set @AgentCollection_Id = (select AgentCollection_Id from t006_milkcollectionagent 
            where  Org_Id =Var_Org_Id and MCC_Id = Var_MCC_Id  and 
            MCCCollectionShift_Id = Var_MCC_Collection_Shift limit 1 ) ;
            
	
            set @TotalMilkQuantity = '';
             set @TotalQuantity = '';
            select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001' ;
	
            
            set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = '';
            select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
            into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
            from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
		
            set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
            set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
             set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = '';
            select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
            into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
            from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;
		
            set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
            
            set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
            
            
            Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = Var_MCC_Collection_Shift and 
            MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = Var_MCC_Collection_Shift and 
            MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            
            Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = Var_MCC_Collection_Shift and 
            MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = Var_MCC_Collection_Shift and 
            MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            

			UPDATE t006_milkcollectionagent 
            SET Aluminum_Can_With_Lid =  cast(Var_AluminumCan_With_Lid as SIGNED), 
            Aluminum_Can_Without_Lid = cast(Var_AluminumCan_Without_Lid as SIGNED ), 
            Plastic_Can_With_Lid = cast(Var_PlasticCan_With_Lid as SIGNED) , 
            Plastic_Can_Without_Lid =  cast(Var_PlasticCan_Without_Lid as SIGNED),
            Final_Qty_Cow_Ltr =  Roundoff('Quantity'  , @TotalMilkQuantityCow) ,
            Final_Qty_Cow_KG = Roundoff('Quantity'  , @TotalMilkQuantityCowKG),
            Final_FAT_Cow_WtAvg = @CowFatweightAvg,
            Final_SNF_Cow_WtAvg = @CowSNFweightAvg,
            Final_Qty_Buf_Ltr = Roundoff('Quantity'  ,  @TotalMilkQuantityBuffalo),
            Final_Qty_Buf_KG  =  Roundoff('Quantity'  ,  @TotalMilkQuantityBuffaloKG),
            Final_FAT_Buf_WtAvg =  @BuffaloFatweightAvg ,
            Final_SNF_Buf_WtAvg = @BuffaloSNFweightAvg,
            Final_Amout_Cow = @TotalMilkAmountCow,
            Final_Amout_Buf =  @TotalMilkAmountBuffalo
            WHERE Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id  and MCCCollectionShift_Id = Var_MCC_Collection_Shift
            and AgentCollection_Id =  @AgentCollection_Id ;
            
		
			delete from t006_milkcollectionagent_item where  Org_Id =Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id ;
            

		    set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);
           
			SET row_count := extractValue(var_XMLData,'count(//D/R)');
			Set k := 0;
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
				INSERT INTO t006_milkcollectionagent_item (Org_Id,AgentCollection_Id, Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id) VALUES (
					Var_Org_Id,
					@AgentCollection_Id,
					extractValue(var_XMLData, concat(xpath,'/MTI')),
                    (extractValue(var_XMLData, concat(xpath,'/QTY'))),
                    -- extractValue(var_XMLData, concat(xpath,'/FAT')),
                    Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),
                    -- extractValue(var_XMLData, concat(xpath,'/SNF')),
                    Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),
					Var_MilkStatus_Id
				);
                
			END WHILE;

			delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
            ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;


			select 1 as Result_Id, 'Milk Dispatched updated' as Result_Description, '' as Result_Extra_Key;
            
		elseif exists (select 1 from t004_mcccollectionshift where  Org_Id =Var_Org_Id and MCC_Id = Var_MCC_Id  and MCCCollectionShift_Id = Var_MCC_Collection_Shift AND Is_MilkDispatch = 2) THEN
        
			select -1 as Result_Id, 'Milk alredy Dispatched' as Result_Description, '' as Result_Extra_Key;
        
        else 
        
		set @AgentCollection_Id = '';
		set @Year_Id = (select right(left(curdate(),4),(2)));
		Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
        
        
			set @TotalMilkQuantity = '';
			set @TotalQuantity = '';
            select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001' ;
	
            set @TotalMilkQuantityCow = '';
			set @TotalQuantityCow = '';
            select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
            into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
            from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
		
            set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
            set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
             set @TotalMilkQuantityBuffalo  = '';
			set @TotalQuantityBuffalo = '';
            select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
            into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
            from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;
		
            set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;
            
            set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
            and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;
            
 
            Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = Var_MCC_Collection_Shift and 
            MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = Var_MCC_Collection_Shift and 
            MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            
            Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = Var_MCC_Collection_Shift and 
            MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = Var_MCC_Collection_Shift and 
            MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
            
            
            
            set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
					Applicable_Date <= @Current_Datetime
					order by Applicable_Date desc limit 1 ) ;
                    
                    Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );

					if(@MusterType = 1)then 
					
						Set @MusterCycle_StartDate = @Current_Datetime;
						set @MusterCycle_EndDate =  @Current_Datetime;
                    
                    elseif(@MusterType = 7) then 
						
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 7 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-07');
                        
                        elseif(DATE_FORMAT(now(), '%d') BETWEEN 8 AND 14) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-14');

						elseif(DATE_FORMAT(now(), '%d') BETWEEN 15 AND 21) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-21');
                        
                      elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
					
                    end if;
                        
				elseif(@MusterType = 15) then 
                        
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 15 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
                        
                        else 
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
							set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                        
                        end if;
                        
				elseif(@MusterType = 5) then 
                        
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 5 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-05');
                        
                        elseif(DATE_FORMAT(now(), '%d') BETWEEN 6 AND 10) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

						elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 15) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
                        
                      elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 20 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');
                        
					elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 25 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-25');
					
                    elseif(DATE_FORMAT(now(), '%d') BETWEEN 26 AND 31 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                    
                    end if;
                    
                    elseif(@MusterType = 10) then 
                        
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 10 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');
                        
                        elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 20) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

						elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                    
                    end if;
                
					elseif(@MusterType = 30) then 
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                        
				end if;
            
            
			insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
			Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
            Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
            Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
			 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
			) values 
			( Var_Org_Id, @AgentCollection_Id , Var_MCC_Id , Var_MCC_Collection_Shift , Var_Profile_Id , Var_Driver_Id , 
            cast(Var_AluminumCan_With_Lid as SIGNED),
			cast(Var_AluminumCan_Without_Lid as SIGNED) ,
			cast(Var_PlasticCan_With_Lid as SIGNED), 
             cast(Var_PlasticCan_Without_Lid as SIGNED) ,
            Roundoff('Quantity'  ,  @TotalMilkQuantityCow), Roundoff('Quantity' , @TotalMilkQuantityCowKG), @CowFatweightAvg,
            @CowSNFweightAvg, Roundoff('Quantity'  ,  @TotalMilkQuantityBuffaloKG), Roundoff('Quantity', @TotalMilkQuantityBuffalo) ,
            @BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
			0,1,0,@Current_Datetime, Var_Profile_Id , (select Agent_Name from mu05_agent where Org_Id = Var_Org_Id and Agent_Id = Var_Profile_Id) , @MusterCycle_StartDate , @MusterCycle_EndDate
			) ;
	
			update t004_mcccollectionshift set Is_MilkDispatch = 1 where Org_Id = Var_Org_Id and 
            MCCCollectionShift_Id = Var_MCC_Collection_Shift ;
                
		   set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);
           
			SET row_count := extractValue(var_XMLData,'count(//D/R)');
			Set k := 0;
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
				INSERT INTO t006_milkcollectionagent_item (Org_Id,AgentCollection_Id, Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id) VALUES (
					Var_Org_Id,
					@AgentCollection_Id,
					extractValue(var_XMLData, concat(xpath,'/MTI')),
                    Roundoff('Quantity' , (extractValue(var_XMLData, concat(xpath,'/QTY')))) ,
                    -- extractValue(var_XMLData, concat(xpath,'/FAT')),
                    -- extractValue(var_XMLData, concat(xpath,'/SNF')),
                    Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),
                    Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),
                   Var_MilkStatus_Id
				);
                
                
                
			END WHILE;
            
            
			delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
            ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;

    		select 1 as Result_Id, 'Milk Dispatched' as Result_Description, '' as Result_Extra_Key;  
		
        end if;
        end;
        
        elseif(Var_Method_Name = 'ReceivedCans') then 
			
			select 
            ifnull(cast(sum(Plastic_Cans_With_Lid) as SIGNED) ,0) as Plastic_Cans_With_Lid , 
            ifnull(cast(sum(Aluminium_Cans_With_Lid ) as SIGNED ) ,0)  as Aluminium_Cans_With_Lid, 
            ifnull(cast(sum(Aluminium_Cans_Without_Lid) as SIGNED ) ,0)  as Aluminium_Cans_Without_Lid , 
            ifnull(cast(sum(Plastic_Cans_Without_Lid ) as SIGNED)  ,0) as Plastic_Cans_Without_Lid, 
            ifnull(cast(sum(Total_Can)as SIGNED ) ,0)  as Total_Can
            from t019_issueemptycans_item t019 inner join t018_issueemptycans_header t018
            on t019.Org_Id = t018.Org_Id and t019.IssueEmptyCan_Id = t018.IssueEmptyCan_Id 
            where MCC_Id = Var_MCC_Id and Is_DriverAccepted = 1 and t019.Org_Id = Var_Org_Id
           and ifnull(t019.Is_MCCAccepted,0) = 0 ;
            
            
     elseif(Var_Method_Name = 'AcceptCans') then 
     
		if exists (select 1  from t019_issueemptycans_item t019 inner join t018_issueemptycans_header t018
            on t019.Org_Id = t018.Org_Id and t019.IssueEmptyCan_Id = t018.IssueEmptyCan_Id where Is_DriverAccepted = 1
        and t019.MCC_Id = Var_MCC_Id and t019.Org_Id = Var_Org_Id and  t019.Is_MCCAccepted = 1 ) then 
        
        select -1 as Result_Id, 'Already Accepted' as Result_Description, '' as Result_Extra_Key;
        
        elseif exists (select 1  from t019_issueemptycans_item t019 inner join t018_issueemptycans_header t018
            on t019.Org_Id = t018.Org_Id and t019.IssueEmptyCan_Id = t018.IssueEmptyCan_Id where Is_DriverAccepted = 1
        and t019.MCC_Id = Var_MCC_Id and t019.Org_Id = Var_Org_Id and  t019.Is_MCCAccepted = 0 ) then 
        
        update t019_issueemptycans_item t019
        inner join t018_issueemptycans_header t018
		on t019.Org_Id = t018.Org_Id and t019.IssueEmptyCan_Id = t018.IssueEmptyCan_Id 
        set Is_MCCAccepted = 1,
        TripDocument_Id = Var_TripDocument_Id ,
        MCC_CollectionShift_Id = Var_MCC_Collection_Shift
        where t018.Is_DriverAccepted = 1 and
		t019.Is_MCCAccepted = 0 
        and MCC_Id = Var_MCC_Id and t018.Org_Id = Var_Org_Id ;
        
        select 1 as Result_Id, 'Accepted' as Result_Description, '' as Result_Extra_Key;

		
        else 
        
        select -1 as Result_Id, 'Data not found' as Result_Description, '' as Result_Extra_Key;
			
		END IF ;
        
	elseif(Var_Method_Name = 'MilkDispatchBMCOffline')then
    begin
        Declare RowCnt int;
        DECLARE k INT UNSIGNED DEFAULT 0;
        DECLARE row_count INT UNSIGNED;
        DECLARE xpath TEXT;
        
        set @Var_MCC_Collection_Shift = '';
		set @kg_to_ltr = '';
		set @ChemistCollection_Id = '';
		set @MilkStatus = '';
		set @Quantity_CowKg ='';
		set @FATCow = '';
		set @SNFCow = '';
		set @Quantity_BufKg = '';
		set @FATBuf = '';
		set @SNFBuf = '';
		set @QuantityCW  = '';
		set @FatCW = '';
		set @SnfCW  = '';
		set @AmountCW  = '';
		set @RateCW = '';
		set @QuantityBF = '';
		set @FatBF = '';
		set @SnfBF = '';
		set @AmountBF = '';
		set @RateBF = '';
		SET @qtycW = '';
		SET @qtybF = '';
		set @MusterType_Id ='';
		set @MusterType ='';
		set @MusterCycle_StartDate ='';
		set @MusterCycle_EndDate ='';
		set @AgentCollection_Id = '';
		set @Year_Id ='';
		set @R_Shift = '';
		set @Trip_Id ='';
		set @Total_MCC ='';
		set @Visited_MCC_Count ='';

        set @Var_MCC_Collection_Shift = (select MCCCollectionShift_Id from t004_mcccollectionshift
									where Org_Id = Var_Org_Id
									and MCC_Id = Var_MCC_Id
									order by Collection_Date desc
									limit 1);

        set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);

        if exists (select 1 from t004_mcccollectionshift where  Org_Id =Var_Org_Id and MCC_Id = Var_MCC_Id  and MCCCollectionShift_Id = @Var_MCC_Collection_Shift AND Is_MilkDispatch = 2) THEN
        
			select -1 as Result_Id, 'Milk alredy Dispatched' as Result_Description, '' as Result_Extra_Key;
        
        else

            set @ChemistCollection_Id = ( select ChemistCollection_Id from t008_milkcollectionchemist where Trip_Id = Var_TripDocument_Id
            and MCC_Id = Var_MCC_Id and MCCCollectionShift_Id = @Var_MCC_Collection_Shift and Is_Active = 1 limit 1) ;
            
            set @MilkStatus = (select MilkStatus_Id from t008_milkcollectionchemist_item where
            ChemistCollection_Id = @ChemistCollection_Id limit 1);

            select Quantity_Kg , FAT , SNF into @Quantity_CowKg , @FATCow ,  @SNFCow
            from t008_milkcollectionchemist_item where Org_Id = Var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id 
            and MilkType_Id = 'C011001';
            
            select Quantity_Kg , FAT , SNF into @Quantity_BufKg , @FATBuf ,  @SNFBuf
            from t008_milkcollectionchemist_item where Org_Id = Var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id 
            and MilkType_Id = 'C011002';

            select  Quantity, Fat, Snf , Amount , Rate into @QuantityCW, @FatCW, @SnfCW , @AmountCW , @RateCW
            from f009_mcc_collection where  MCC_Id = Var_MCC_Id
            and Entry_Type in ('Collection 1' , 'Collection 2' , 'Closing Bal') and Mlk_Type = 'C011001'
            order by Date desc limit 1 ;


            select  Quantity, Fat, Snf , Amount , Rate into @QuantityBF, @FatBF, @SnfBF , @AmountBF , @RateBF
            from f009_mcc_collection where  MCC_Id = Var_MCC_Id
            and Entry_Type in ('Collection 1' , 'Collection 2' , 'Closing Bal') and Mlk_Type = 'C011002'
            order by Date desc limit 1 ;

            if ( @MilkStatus = 'C016002') then 
        
                set @Quantity_CowKg = 0;
                set @Quantity_BufKg = 0;
            
            end if;
        
            
            SET @qtycW = (@kg_to_ltr * @Quantity_CowKg);
            SET @qtybF = (@kg_to_ltr * @Quantity_BufKg);


            set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
            Applicable_Date <= @Current_Datetime
            order by Applicable_Date desc limit 1 ) ;

            Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );

            if(@MusterType = 1)then 

                Set @MusterCycle_StartDate = @Current_Datetime;
                set @MusterCycle_EndDate =  @Current_Datetime;

            elseif(@MusterType = 7) then 

                if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 7 ) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-07');

                elseif(DATE_FORMAT(now(), '%d') BETWEEN 8 AND 14) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-14');

                elseif(DATE_FORMAT(now(), '%d') BETWEEN 15 AND 21) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-21');

                elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 31) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
                    set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

                end if;

            elseif(@MusterType = 15) then 

                if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 15 ) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');

                else 
                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
                    set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

                end if;

            elseif(@MusterType = 5) then 

                if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 5 ) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-05');

                elseif(DATE_FORMAT(now(), '%d') BETWEEN 6 AND 10) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

                elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 15) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');

                elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 20 ) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

                elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 25 ) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-25');

                elseif(DATE_FORMAT(now(), '%d') BETWEEN 26 AND 31 ) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
                    set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

                end if;

            elseif(@MusterType = 10) then 

                if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 10 ) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

                elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 20) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
                    set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

                elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 31) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
                    set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

                end if;

            elseif(@MusterType = 30) then 

                Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
                set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

            end if;


            set @AgentCollection_Id = '';
            set @Year_Id = (select right(left(curdate(),4),(2)));
            Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
            
            set  @R_Shift = (select CollectionShift_Id from t004_mcccollectionshift where  Org_Id =Var_Org_Id and MCC_Id = Var_MCC_Id  and MCCCollectionShift_Id = @Var_MCC_Collection_Shift limit 1);

            IF ((@FATCow IS NOT NULL OR @SNFCow IS NOT NULL) AND (@RateCW IS NULL OR @RateCW = 0 OR @RateCW = '0' OR @RateCW = '')) THEN

                set @RateCW = GetMilkRateBackDate(Var_Org_Id, Var_MCC_Id, @R_Shift, @FATCow, @SNFCow, 'C011001', @Current_Datetime);

            end if;

			IF ((@FATBuf IS NOT NULL OR @SNFBuf IS NOT NULL) AND (@RateBF IS NULL OR @RateBF = 0 OR @RateBF = '0' OR @RateBF = '')) THEN

                set @RateBF = GetMilkRateBackDate(Var_Org_Id, Var_MCC_Id, @R_Shift, @FATBuf, @SNFBuf, 'C011002', @Current_Datetime);

            end if; 

            insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
            Driver_Id, Final_Qty_Cow_KG, Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg, 
            Final_Qty_Buf_KG , Final_FAT_Buf_WtAvg, Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
            Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , Final_Qty_Cow_Ltr , Final_Qty_Buf_Ltr ,  MusterCycle_StartDate , MusterCycle_EndDate
            ) values 
            ( Var_Org_Id, @AgentCollection_Id , Var_MCC_Id , @Var_MCC_Collection_Shift , Var_Profile_Id , Var_Driver_Id , 
            Roundoff('Quantity'  ,  @Quantity_CowKg) , @FATCow  , @SNFCow , Roundoff('Quantity'  ,   @Quantity_BufKg)  ,  @FATBuf ,  @SNFBuf , 
            @qtycW * @RateCW , @qtybF * @RateBF ,
            0,1,0,@Current_Datetime, Var_Profile_Id , (select Agent_Name from mu05_agent where Org_Id = Var_Org_Id and Agent_Id = Var_Profile_Id),
            Roundoff('Quantity'  ,  @qtycW)   ,  Roundoff('Quantity'  ,  @qtybF)  , @MusterCycle_StartDate ,  @MusterCycle_EndDate
            ) ;

            update  t004_mcccollectionshift 
            set  Is_MilkDispatch = 2 
            where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id  and Collection_Date <= now() and Is_Active  = 1;


                set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);

                SET row_count := extractValue(var_XMLData,'count(//D/R)');
                Set k := 0;
                WHILE k < row_count DO        
                    SET k := k + 1;
                    SET xpath := concat('//D/R[', k, ']');
                    INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id, Milktype_Id, Quantity_Ltr, FAT, SNF, MilkStatus_Id) VALUES (
                    Var_Org_Id,
                    @AgentCollection_Id,
                    extractValue(var_XMLData, concat(xpath,'/MTI')),
                    Roundoff('Quantity' , ((extractValue(var_XMLData, concat(xpath,'/QTY'))))) ,
                    Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),
                    Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),
                    if(@MilkStatus = 'C016002' , 'C016002' , Var_MilkStatus_Id ) 
                    );


                    if exists(select 1 from f009_mcc_collection where MCCCollectionShift_Id = @Var_MCC_Collection_Shift and Org_Id  = Var_Org_Id and 
                    Entry_Type = 'Dispatch 1') then 

                        insert into f009_mcc_collection(Org_Id , MCCCollectionShift_Id , MCC_Id ,Mlk_Type , Entry_Type , 
                        Quantity ,Fat, Snf , Date, Amount , Rate ) value
                        (Var_Org_Id , @Var_MCC_Collection_Shift , Var_MCC_Id , extractValue(var_XMLData, concat(xpath,'/MTI')) , 'Dispatch 2' ,
                        (extractValue(var_XMLData, concat(xpath,'/QTY'))), extractValue(var_XMLData, concat(xpath,'/FAT')), extractValue(var_XMLData, concat(xpath,'/SNF')) , @Current_Datetime ,
                        if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' , @RateCW * ((extractValue(var_XMLData, concat(xpath,'/QTY')))), 
                        @RateBF  * (extractValue(var_XMLData, concat(xpath,'/QTY')))) , 
                        if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' ,@RateCW  , @RateBF ) 
                        );

                        insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity, 
                        Fat, Snf, Date , Amount , Rate ) 
                        select Var_Org_Id , @Var_MCC_Collection_Shift ,Var_MCC_Id, 'Opening Bal 2' , Mlk_Type , F009.Quantity - ((extractValue(var_XMLData, concat(xpath,'/QTY'))) ), 
                        Fat, Snf , @Current_Datetime , (F009.Quantity - (extractValue(var_XMLData, concat(xpath,'/QTY')))) *  Rate , Rate
                        from f009_mcc_collection F009 where F009.Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI')) and  Date < @Current_Datetime 
                        and F009.Entry_Type = 'Collection 1' and MCCCollectionShift_Id = @Var_MCC_Collection_Shift
                        order by Date desc limit 1;

                        insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity, 
                        Fat, Snf, Date , Amount , Rate  ) 
                        select Var_Org_Id , @Var_MCC_Collection_Shift ,Var_MCC_Id, 'Collection 2' , Mlk_Type , F009.Quantity , Fat, Snf , @Current_Datetime , Amount , Rate 
                        from f009_mcc_collection F009 where F009.Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI')) and  Date <= @Current_Datetime 
                        and F009.Entry_Type = 'Opening Bal 2' and MCCCollectionShift_Id = @Var_MCC_Collection_Shift
                        order by Date desc limit 1;


                    else


                        insert into f009_mcc_collection(Org_Id , MCCCollectionShift_Id , MCC_Id ,Mlk_Type , Entry_Type ,
                        Quantity ,Fat, Snf , Date , Amount , Rate ) value
                        (Var_Org_Id , @Var_MCC_Collection_Shift , Var_MCC_Id , extractValue(var_XMLData, concat(xpath,'/MTI')) , 'Dispatch 1' ,
                        (extractValue(var_XMLData, concat(xpath,'/QTY'))), extractValue(var_XMLData, concat(xpath,'/FAT')), extractValue(var_XMLData, concat(xpath,'/SNF')) , @Current_Datetime,
                        if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' , @RateCW * ((extractValue(var_XMLData, concat(xpath,'/QTY')))), 
                        @RateBF  * (extractValue(var_XMLData, concat(xpath,'/QTY')))),  if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' ,@RateCW  , @RateBF ) 
                        );

                        insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity, 
                        Fat, Snf, Date , Amount , Rate ) 
                        select Var_Org_Id , @Var_MCC_Collection_Shift ,Var_MCC_Id, 'Opening Bal 2' , Mlk_Type , (F009.Quantity - (extractValue(var_XMLData, concat(xpath,'/QTY')))  ) , Fat, Snf , @Current_Datetime , 
                        if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' , @RateCW * (F009.Quantity - (extractValue(var_XMLData, concat(xpath,'/QTY')))  ), 
                        @RateBF  * (F009.Quantity - (extractValue(var_XMLData, concat(xpath,'/QTY'))))) , if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' ,@RateCW  , @RateBF ) 
                        from f009_mcc_collection F009 where F009.Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI')) and  Date <= @Current_Datetime 
                        and F009.Entry_Type = 'Collection 1' and MCCCollectionShift_Id = @Var_MCC_Collection_Shift
                        order by Date desc limit 1;

                        insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity, 
                        Fat, Snf, Date , Amount , Rate ) 
                        select Var_Org_Id , @Var_MCC_Collection_Shift ,Var_MCC_Id, 'Collection 2' , Mlk_Type , F009.Quantity , Fat, Snf , @Current_Datetime , Amount , Rate
                        from f009_mcc_collection F009 where F009.Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI')) and  Date <= @Current_Datetime 
                        and F009.Entry_Type = 'Opening Bal 2' and MCCCollectionShift_Id = @Var_MCC_Collection_Shift
                        order by Date desc limit 1;

                    end if;

                END WHILE;

                update f009_mcc_collection 
                set Quantity = 0 ,
                Amount = 0
                where Quantity < 0 
                and MCCCollectionShift_Id = @Var_MCC_Collection_Shift ;
                
                update t008_milkcollectionchemist 
                set Is_BMC_Accepted = 1,
                LastEdited_On = @Current_Datetime ,
                LastEditedBy_Id = Var_Profile_Id
                where Org_Id = Var_Org_Id and 
                MCCCollectionShift_Id = @Var_MCC_Collection_Shift and MCC_Id = Var_MCC_Id and Is_Active = 1;
                
                set @Trip_Id = (select Trip_Id from t008_milkcollectionchemist
                where Org_Id = Var_Org_Id and 
                MCCCollectionShift_Id = @Var_MCC_Collection_Shift and MCC_Id = Var_MCC_Id and Is_Active = 1
                ) ;
                
                update t022_tripdocument_item 
                set Is_Reached = 2 ,
                MCC_CollectionShift_Id = @Var_MCC_Collection_Shift ,
                Arrival_At = @Current_Datetime 
                where Org_Id =  Var_Org_Id and
                TripDocument_Id = @Trip_Id and 
                MCC_Id = Var_MCC_Id ;

                Set @Total_MCC = (select count(*) from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id = @Trip_Id);
                set @Visited_MCC_Count = (select count(*) from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id = @Trip_Id and Is_Reached = 2);
	
                update t021_tripdocument_header 
                set Trip_Status =  if (@Total_MCC = @Visited_MCC_Count , 'ToDairy' , 'InTrip' ) ,
                Next_Destination = (select MCC_Id from t022_tripdocument_item where  Org_Id =  Var_Org_Id and
                TripDocument_Id = @Trip_Id and Is_Reached <> 2 order by Order_By asc limit 1 )
                where Org_Id = Var_Org_Id and
                TripDocument_Id = @Trip_Id ;
                
                delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
                ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;

                select 1 as Result_Id, 'Milk Collected' as Result_Description, '' as Result_Extra_Key;  

        end if;

    end;
	elseif(Var_Method_Name = 'MilkDispatchBMC')then
    begin
        	Declare RowCnt int;
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
        
        
  set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);
  
        
		if exists (select 1 from t004_mcccollectionshift where  Org_Id =Var_Org_Id and MCC_Id = Var_MCC_Id  and MCCCollectionShift_Id = Var_MCC_Collection_Shift AND Is_MilkDispatch = 2) THEN
        
			select -1 as Result_Id, 'Milk alredy Dispatched' as Result_Description, '' as Result_Extra_Key;
        
        else 
        
        
    set @ChemistCollection_Id = ( select ChemistCollection_Id from t008_milkcollectionchemist where Trip_Id = Var_TripDocument_Id
    and MCC_Id = Var_MCC_Id and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Is_Active = 1 limit 1) ;
    
    set @MilkStatus = (select MilkStatus_Id from t008_milkcollectionchemist_item where
	ChemistCollection_Id = @ChemistCollection_Id limit 1);

	select Quantity_Kg , FAT , SNF into @Quantity_CowKg , @FATCow ,  @SNFCow
	from t008_milkcollectionchemist_item where Org_Id = Var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id 
    and MilkType_Id = 'C011001';
    
	select Quantity_Kg , FAT , SNF into @Quantity_BufKg , @FATBuf ,  @SNFBuf
	from t008_milkcollectionchemist_item where Org_Id = Var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id 
    and MilkType_Id = 'C011002';
    

	
	/*
	select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
	into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
	from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
	and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;

        
	select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
	into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
	from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
	and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';
*/




select  Quantity, Fat, Snf , Amount , Rate into @QuantityCW, @FatCW, @SnfCW , @AmountCW , @RateCW
from f009_mcc_collection where  MCC_Id = Var_MCC_Id
and Entry_Type in ('Collection 1' , 'Collection 2' , 'Closing Bal') and Mlk_Type = 'C011001'
order by Date desc limit 1 ;


select  Quantity, Fat, Snf , Amount , Rate into @QuantityBF, @FatBF, @SnfBF , @AmountBF , @RateBF
from f009_mcc_collection where  MCC_Id = Var_MCC_Id
and Entry_Type in ('Collection 1' , 'Collection 2' , 'Closing Bal') and Mlk_Type = 'C011002'
order by Date desc limit 1 ;


		if ( @MilkStatus = 'C016002') then 
        
			set @Quantity_CowKg = 0;
			set @Quantity_BufKg = 0;
            
		end if;
    
    
    SET @qtycW = (@kg_to_ltr * @Quantity_CowKg);
    SET @qtybF = (@kg_to_ltr * @Quantity_BufKg);


/*
Set @CurCollection = (select @qty - sum(Quantity_Ltr) from
t004_mcccollectionshift t004 inner join 
t005_milkcollectionfarmer t005  on t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
where t004.Is_MilkDispatch <> 2 and t004.MCC_Id = 'M005241000004' and t004.MCCCollectionShift_Id <> 'T004241000689'
group by t004.MCC_Id );


select @qty , @Quantity_CowKg , sum(Amt.Amount) 
into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow  from( select if(t004.MCCCollectionShift_Id <> 'T004241000689' , sum(t005.Amount) , 
((sum(t005.Amount)/ sum(t005.Quantity_Ltr) ) * (sum(t005.Quantity_Ltr) - @CurCollection )) ) As Amount from
t004_mcccollectionshift t004 inner join 
t005_milkcollectionfarmer t005  on t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
where t004.Is_MilkDispatch <> 2 and t004.MCC_Id = Var_MCC_Id
group by t004.MCCCollectionShift_Id) Amt;

*/

  
  set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
					Applicable_Date <= @Current_Datetime
					order by Applicable_Date desc limit 1 ) ;
                    
                    Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );

					if(@MusterType = 1)then 
					
						Set @MusterCycle_StartDate = @Current_Datetime;
						set @MusterCycle_EndDate =  @Current_Datetime;
                    
                    elseif(@MusterType = 7) then 
						
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 7 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-07');
                        
                    elseif(DATE_FORMAT(now(), '%d') BETWEEN 8 AND 14) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-14');

						elseif(DATE_FORMAT(now(), '%d') BETWEEN 15 AND 21) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-21');
                        
                      elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
					
                    end if;
                        
				elseif(@MusterType = 15) then 
                        
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 15 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
                        
                        else 
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
							set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                        
                        end if;
                        
				elseif(@MusterType = 5) then 
                        
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 5 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-05');
                        
                        elseif(DATE_FORMAT(now(), '%d') BETWEEN 6 AND 10) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

						elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 15) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
                        
                      elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 20 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');
                        
					elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 25 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-25');
					
                    elseif(DATE_FORMAT(now(), '%d') BETWEEN 26 AND 31 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                    
                    end if;
                    
                    elseif(@MusterType = 10) then 
                        
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 10 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');
                        
                        elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 20) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

						elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                    
                    end if;
                
					elseif(@MusterType = 30) then 
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                        
				end if;
            
           
    
		set @AgentCollection_Id = '';
		set @Year_Id = (select right(left(curdate(),4),(2)));
		Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
        
			insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
			Driver_Id, Final_Qty_Cow_KG, Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg, 
            Final_Qty_Buf_KG , Final_FAT_Buf_WtAvg, Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
			 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , Final_Qty_Cow_Ltr , Final_Qty_Buf_Ltr ,  MusterCycle_StartDate , MusterCycle_EndDate
			) values 
			( Var_Org_Id, @AgentCollection_Id , Var_MCC_Id , Var_MCC_Collection_Shift , Var_Profile_Id , Var_Driver_Id , 
            Roundoff('Quantity'  ,  @Quantity_CowKg) , @FATCow  , @SNFCow , Roundoff('Quantity'  ,   @Quantity_BufKg)  ,  @FATBuf ,  @SNFBuf , 
            @qtycW * @RateCW , @qtybF * @RateBF ,
			0,1,0,@Current_Datetime, Var_Profile_Id , (select Agent_Name from mu05_agent where Org_Id = Var_Org_Id and Agent_Id = Var_Profile_Id),
           Roundoff('Quantity'  ,  @qtycW)   ,  Roundoff('Quantity'  ,  @qtybF)  , @MusterCycle_StartDate ,  @MusterCycle_EndDate
			) ;
        
		update  t004_mcccollectionshift 
		set  Is_MilkDispatch = 2 
		where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id  and Collection_Date <= now() and Is_Active  = 1;
                
			set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);
		
			SET row_count := extractValue(var_XMLData,'count(//D/R)');
			Set k := 0;
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
				INSERT INTO t006_milkcollectionagent_item (Org_Id, AgentCollection_Id, Milktype_Id, Quantity_Ltr, FAT, SNF, MilkStatus_Id) VALUES (
					Var_Org_Id,
					@AgentCollection_Id,
					extractValue(var_XMLData, concat(xpath,'/MTI')),
					Roundoff('Quantity' , ((extractValue(var_XMLData, concat(xpath,'/QTY'))))) ,
                    -- extractValue(var_XMLData, concat(xpath,'/FAT')),
                    -- extractValue(var_XMLData, concat(xpath,'/SNF')),
                    Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),
                    Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),
                    if(@MilkStatus = 'C016002' , 'C016002' , Var_MilkStatus_Id ) 
				);
                
                
                if exists(select 1 from f009_mcc_collection where MCCCollectionShift_Id = Var_MCC_Collection_Shift and Org_Id  = Var_Org_Id and 
                Entry_Type = 'Dispatch 1') then 
                
				insert into f009_mcc_collection(Org_Id , MCCCollectionShift_Id , MCC_Id ,Mlk_Type , Entry_Type , 
				Quantity ,Fat, Snf , Date, Amount , Rate ) value
                (Var_Org_Id , Var_MCC_Collection_Shift , Var_MCC_Id , extractValue(var_XMLData, concat(xpath,'/MTI')) , 'Dispatch 2' ,
				(extractValue(var_XMLData, concat(xpath,'/QTY'))), extractValue(var_XMLData, concat(xpath,'/FAT')), extractValue(var_XMLData, concat(xpath,'/SNF')) , @Current_Datetime ,
                if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' , @RateCW * ((extractValue(var_XMLData, concat(xpath,'/QTY')))), 
                @RateBF  * (extractValue(var_XMLData, concat(xpath,'/QTY')))) , 
                if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' ,@RateCW  , @RateBF ) 
                );
			
				insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity, 
				Fat, Snf, Date , Amount , Rate ) 
				select Var_Org_Id , Var_MCC_Collection_Shift ,Var_MCC_Id, 'Opening Bal 2' , Mlk_Type , F009.Quantity - ((extractValue(var_XMLData, concat(xpath,'/QTY'))) ), 
                Fat, Snf , @Current_Datetime , (F009.Quantity - (extractValue(var_XMLData, concat(xpath,'/QTY')))) *  Rate , Rate
				from f009_mcc_collection F009 where F009.Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI')) and  Date < @Current_Datetime 
				and F009.Entry_Type = 'Collection 1' and MCCCollectionShift_Id = Var_MCC_Collection_Shift
				order by Date desc limit 1;
                
                insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity, 
				Fat, Snf, Date , Amount , Rate  ) 
				select Var_Org_Id , Var_MCC_Collection_Shift ,Var_MCC_Id, 'Collection 2' , Mlk_Type , F009.Quantity , Fat, Snf , @Current_Datetime , Amount , Rate 
				from f009_mcc_collection F009 where F009.Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI')) and  Date <= @Current_Datetime 
				and F009.Entry_Type = 'Opening Bal 2' and MCCCollectionShift_Id = Var_MCC_Collection_Shift
				order by Date desc limit 1;
       
       
			else
            
 
                insert into f009_mcc_collection(Org_Id , MCCCollectionShift_Id , MCC_Id ,Mlk_Type , Entry_Type ,
				Quantity ,Fat, Snf , Date , Amount , Rate ) value
                (Var_Org_Id , Var_MCC_Collection_Shift , Var_MCC_Id , extractValue(var_XMLData, concat(xpath,'/MTI')) , 'Dispatch 1' ,
				(extractValue(var_XMLData, concat(xpath,'/QTY'))), extractValue(var_XMLData, concat(xpath,'/FAT')), extractValue(var_XMLData, concat(xpath,'/SNF')) , @Current_Datetime,
                if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' , @RateCW * ((extractValue(var_XMLData, concat(xpath,'/QTY')))), 
                @RateBF  * (extractValue(var_XMLData, concat(xpath,'/QTY')))),  if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' ,@RateCW  , @RateBF ) 
                );
			
				insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity, 
				Fat, Snf, Date , Amount , Rate ) 
				select Var_Org_Id , Var_MCC_Collection_Shift ,Var_MCC_Id, 'Opening Bal 2' , Mlk_Type , (F009.Quantity - (extractValue(var_XMLData, concat(xpath,'/QTY')))  ) , Fat, Snf , @Current_Datetime , 
                if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' , @RateCW * (F009.Quantity - (extractValue(var_XMLData, concat(xpath,'/QTY')))  ), 
                @RateBF  * (F009.Quantity - (extractValue(var_XMLData, concat(xpath,'/QTY'))))) , if(extractValue(var_XMLData, concat(xpath,'/MTI')) = 'C011001' ,@RateCW  , @RateBF ) 
				from f009_mcc_collection F009 where F009.Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI')) and  Date <= @Current_Datetime 
				and F009.Entry_Type = 'Collection 1' and MCCCollectionShift_Id = Var_MCC_Collection_Shift
				order by Date desc limit 1;
					
				insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity, 
				Fat, Snf, Date , Amount , Rate ) 
				select Var_Org_Id , Var_MCC_Collection_Shift ,Var_MCC_Id, 'Collection 2' , Mlk_Type , F009.Quantity , Fat, Snf , @Current_Datetime , Amount , Rate
				from f009_mcc_collection F009 where F009.Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI')) and  Date <= @Current_Datetime 
				and F009.Entry_Type = 'Opening Bal 2' and MCCCollectionShift_Id = Var_MCC_Collection_Shift
				order by Date desc limit 1;
                
                end if;
                
			END WHILE;
            
			update f009_mcc_collection 
			set Quantity = 0 ,
			Amount = 0
			where Quantity < 0 
			and MCCCollectionShift_Id = Var_MCC_Collection_Shift ;
            
            update t008_milkcollectionchemist 
            set Is_BMC_Accepted = 1,
            LastEdited_On = @Current_Datetime ,
            LastEditedBy_Id = Var_Profile_Id
            where Org_Id = Var_Org_Id and 
            MCCCollectionShift_Id = Var_MCC_Collection_Shift and MCC_Id = Var_MCC_Id and Is_Active = 1;
            
            set @Trip_Id = (select Trip_Id from t008_milkcollectionchemist
             where Org_Id = Var_Org_Id and 
            MCCCollectionShift_Id = Var_MCC_Collection_Shift and MCC_Id = Var_MCC_Id and Is_Active = 1
            ) ;
		      
			update t022_tripdocument_item 
			set Is_Reached = 2 ,
            MCC_CollectionShift_Id = Var_MCC_Collection_Shift ,
			Arrival_At = @Current_Datetime 
			where Org_Id =  Var_Org_Id and
			TripDocument_Id = @Trip_Id and 
			MCC_Id = Var_MCC_Id ;
			
		Set @Total_MCC = (select count(*) from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id = @Trip_Id);
        set @Visited_MCC_Count = (select count(*) from t022_tripdocument_item where Org_Id = Var_Org_Id and  TripDocument_Id = @Trip_Id and Is_Reached = 2);
	
			update t021_tripdocument_header 
			set Trip_Status =  if (@Total_MCC = @Visited_MCC_Count , 'ToDairy' , 'InTrip' ) ,
            Next_Destination = (select MCC_Id from t022_tripdocument_item where  Org_Id =  Var_Org_Id and
			TripDocument_Id = @Trip_Id and Is_Reached <> 2 order by Order_By asc limit 1 )
			where Org_Id = Var_Org_Id and
			TripDocument_Id = @Trip_Id ;
            
			delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
            ( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;

    		select 1 as Result_Id, 'Milk Collected' as Result_Description, '' as Result_Extra_Key;  
		
        end if;
        end;
        
	
    elseif(Var_Method_Name = 'GetMyBMCCollection') then 
		
	set @ChemistCollection_Id = ( select ChemistCollection_Id from t008_milkcollectionchemist where Trip_Id = Var_TripDocument_Id
    and MCC_Id = Var_MCC_Id and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Is_Active = 1 LIMIT 1) ;

	select MilkType_Id , CAST(Quantity_Ltr as CHAR(50)) as  Quantity_Kg , CAST(FAT as CHAR(50)) as  FAT , CAST(SNF as CHAR(50)) as SNF,
	Milk_Alcohol , Milk_Temparature , Milk_Acidity , Comartment , Is_OrganolepticTest_Done , MilkStatus_Id
	from t008_milkcollectionchemist_item where Org_Id = Var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id;
    
    elseif(Var_Method_Name = 'GetMyBMCCollectionOffline') then 
		
	select 
	Collection_Date,
	CollectionShift_Id 
	into 
	@Collection_Date,
	@CollectionShift_Id 
	from t102_mcccollectionshift_offline
	where Org_Id = Var_Org_Id 
	and MCC_Id = Var_MCC_Id 
	and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Is_Active = 1 LIMIT 1;

	select 
	MCCCollectionShift_Id
	into 
	@MCCCollectionShift_Id
	from t004_mcccollectionshift
	where Org_Id = Var_Org_Id 
	and MCC_Id = Var_MCC_Id 
	and Collection_Date = @Collection_Date
	and CollectionShift_Id = @CollectionShift_Id 
	and Is_Active = 1 LIMIT 1;

	set @ChemistCollection_Id = ( select ChemistCollection_Id from t008_milkcollectionchemist where Trip_Id = Var_TripDocument_Id
	and MCC_Id = Var_MCC_Id and MCCCollectionShift_Id = @MCCCollectionShift_Id and Is_Active = 1 LIMIT 1) ;

	select MilkType_Id , CAST(Quantity_Ltr as CHAR(50)) as  Quantity_Kg , CAST(FAT as CHAR(50)) as  FAT , CAST(SNF as CHAR(50)) as SNF,
	Milk_Alcohol , Milk_Temparature , Milk_Acidity , Comartment , Is_OrganolepticTest_Done , MilkStatus_Id
	from t008_milkcollectionchemist_item where Org_Id = Var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id;
		
    
    elseif (Var_Method_Name = 'MilkDispatchOffline') then
		begin
        	Declare RowCnt int;
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            
            
            set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);
            set @Year_Id = (select right(left(curdate(),4),(2)));
            set @Farmer_Id = (select Farmer_Id from mu04_farmer where Org_Id = Var_Org_Id
					and MCC_Id = Var_MCC_Id
					and Is_Offline = 0 limit 1);
                    
			select Collection_Date,CollectionShift_Id 
			into @var_Collection_Date,@var_CollectionShift_Id 
			from  t102_mcccollectionshift_offline 
			where Org_Id = Var_Org_Id
            and MCC_Id = Var_MCC_Id
			and MCCCollectionShift_Id = Var_MCC_Collection_Shift;
            
            SET @MCCCollectionShift_Id = '';
            
			set @set_MCCCollectionShift_Id = '';
            
			select MCCCollectionShift_Id into @set_MCCCollectionShift_Id  
            from t004_mcccollectionshift 
			where Org_Id = Var_Org_Id
            and MCC_Id = Var_MCC_Id
			and date(Collection_Date) = date(@var_Collection_Date)
			and CollectionShift_Id = @var_CollectionShift_Id limit 1;
            
            
            SET row_count := extractValue(var_XMLData,'count(//D/R)');
					
				Set k := 0;
				WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
                
                Call USP_Number_Range ('t104_mcc_collection_offline', @Year_Id, 'T104', '', @Entry_Id);
				
					INSERT INTO t104_mcc_collection_offline (
					Org_Id,Entry_Id, 
					MCCCollectionShift_Id,MCC_Id,Mlk_Type,Entry_Type,
					Quantity,Fat,Snf,Date
					) VALUES (
					Var_Org_Id,
					@Entry_Id,Var_MCC_Collection_Shift,Var_MCC_Id,
					extractValue(var_XMLData, concat(xpath,'/MTI')),
					'Dispatch',
					extractValue(var_XMLData, concat(xpath,'/QTY')),
					ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
					ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
					@var_Collection_Date
					);
                    
                    update t105_mcc_collection_stock_offline
					set 
					Quantity = Quantity - extractValue(var_XMLData, concat(xpath,'/QTY')),
					Fat = ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
					Snf = ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0)
					where Org_Id = Var_Org_Id
					and date(Date) = date(@var_Collection_Date)
					and MCC_Id = Var_MCC_Id
					and Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI'));
					
					update t105_mcc_collection_stock_offline
					set 
					Fat = 0,
					Snf = 0
					where Org_Id = Var_Org_Id
					and date(Date) = date(@var_Collection_Date)
					and MCC_Id = Var_MCC_Id
					and Quantity = 0
					and Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI'));

			END WHILE;
            
            
             
            if(@set_MCCCollectionShift_Id  is null or @set_MCCCollectionShift_Id  = '')then
            
				
				Call USP_Number_Range ('t004_mcccollectionshift', @Year_Id, 'T004', '', @MCCCollectionShift_Id);
                
                insert into t004_mcccollectionshift (
				Org_Id,MCCCollectionShift_Id,MCC_Id,Collection_Date,CollectionShift_Id,CollectionShift_Name,Shift_Status,ShiftStart_Time,Expected_End_Time,
				Is_MilkDispatch,Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,Is_FromApp
				) 
				select 
				Org_Id,@MCCCollectionShift_Id,MCC_Id,Collection_Date,CollectionShift_Id,CollectionShift_Name,Shift_Status,ShiftStart_Time,Expected_End_Time,
				Is_MilkDispatch,Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,Is_FromApp
				from t102_mcccollectionshift_offline 
				where Org_Id = Var_Org_Id and MCCCollectionShift_Id = Var_MCC_Collection_Shift;
			
				set @MCCCollectionShift_Id = @MCCCollectionShift_Id;
				
            else
				set @MCCCollectionShift_Id = @set_MCCCollectionShift_Id;
            end if;
            
            
            update t022_tripdocument_item 
			set MCC_CollectionShift_Id = @MCCCollectionShift_Id
			where 
            Org_Id = Var_Org_Id 
            and TripDocument_Id = Var_TripDocument_Id
			and MCC_Id = Var_MCC_Id;
            
            select EntryTime,MusterCycle_StartDate,MusterCycle_EndDate,Created_On,CreatedBy_Id,CreatedBy_Name,Anamat_Charge,Freight_Charge,Is_FromApp
			into @var_EntryTime,@var_MusterCycle_StartDate,@var_MusterCycle_EndDate,@var_Created_On,@var_CreatedBy_Id,@var_CreatedBy_Name,@var_Anamat_Charge,@var_Freight_Charge,@var_Is_FromApp
			from t103_milkcollectionfarmer_offline 
			where Org_Id = Var_Org_Id and MCCCollectionShift_Id = Var_MCC_Collection_Shift
			and MilkStatus_Id ='C016001' limit 1;
            
			delete from t005_milkcollectionfarmer where Org_Id = Var_Org_Id and MCCCollectionShift_Id = @MCCCollectionShift_Id;
            
			SET row_count := extractValue(var_XMLData,'count(//D/R)');
			Set k := 0;
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
                
					
						if (
						extractValue(var_XMLData, concat(xpath,'/QTY')) <> 0 and
						extractValue(var_XMLData, concat(xpath,'/FAT')) <> 0 and
						extractValue(var_XMLData, concat(xpath,'/SNF')) <> 0 
						)then
						
						
						Call USP_Number_Range ('t005_milkcollectionfarmer', @Year_Id, 'T005', '', @FarmerCollection_Id);
						
						set @Total_Milk_Rate =  GetMilkRateDate(
						Var_Org_Id, 
						Var_MCC_Id, 
						@var_CollectionShift_Id, 
						ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0), 
						ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0) ,
						extractValue(var_XMLData, concat(xpath,'/MTI')),
						@var_Collection_Date);
						
						set @Total_Milk_Amout = @Total_Milk_Rate *  (extractValue(var_XMLData, concat(xpath,'/QTY')));
						
						
						
						INSERT INTO t005_milkcollectionfarmer (
						Org_Id,FarmerCollection_Id,MCC_Id,MCCCollectionShift_Id,Farmer_Id,MilkType_Id,MilkStatus_Id,
						Quantity_Ltr,Quantity_Kg,Fat,SNF,
						ApplicableRate,Amount,
						Is_Active,Is_Deleted,
						EntryTime,MusterCycle_StartDate,MusterCycle_EndDate,Created_On,CreatedBy_Id,CreatedBy_Name,Anamat_Charge,Freight_Charge,Is_FromApp) 
						VALUES (
						Var_Org_Id,@FarmerCollection_Id,Var_MCC_Id,@MCCCollectionShift_Id,@Farmer_Id,
						extractValue(var_XMLData, concat(xpath,'/MTI')),
						Var_MilkStatus_Id,
						(extractValue(var_XMLData, concat(xpath,'/QTY'))),
						((extractValue(var_XMLData, concat(xpath,'/QTY')) / @kg_to_ltr )),
						 ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
						ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
						@Total_Milk_Rate,@Total_Milk_Amout,
						1,0,
						@var_EntryTime,@var_MusterCycle_StartDate,@var_MusterCycle_EndDate,@var_Created_On,@var_CreatedBy_Id,@var_CreatedBy_Name,@var_Anamat_Charge,@var_Freight_Charge,@var_Is_FromApp );
                    
				end if;
					
				
			END WHILE;
            
            set @AgentCollection_Id = (select AgentCollection_Id from t006_milkcollectionagent 
            where  Org_Id =Var_Org_Id and MCC_Id = Var_MCC_Id  and 
            MCCCollectionShift_Id = @MCCCollectionShift_Id limit 1 ) ;
            
            
            if(@AgentCollection_Id is not null or @AgentCollection_Id <> '') then
				
                set @AgentCollection_Id = (select AgentCollection_Id from t006_milkcollectionagent 
				where  Org_Id =Var_Org_Id and MCC_Id = Var_MCC_Id  and 
				MCCCollectionShift_Id = @MCCCollectionShift_Id limit 1 ) ;

				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001' ;


				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';

				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;

				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;

				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;



				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);


				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				
				UPDATE t006_milkcollectionagent 
				SET Aluminum_Can_With_Lid =  cast(Var_AluminumCan_With_Lid as SIGNED), 
				Aluminum_Can_Without_Lid = cast(Var_AluminumCan_Without_Lid as SIGNED ), 
				Plastic_Can_With_Lid = cast(Var_PlasticCan_With_Lid as SIGNED) , 
				Plastic_Can_Without_Lid =  cast(Var_PlasticCan_Without_Lid as SIGNED),
				Final_Qty_Cow_Ltr =  Roundoff('Quantity'  , @TotalMilkQuantityCow) ,
				Final_Qty_Cow_KG = Roundoff('Quantity'  , @TotalMilkQuantityCowKG),
				Final_FAT_Cow_WtAvg = @CowFatweightAvg,
				Final_SNF_Cow_WtAvg = @CowSNFweightAvg,
				Final_Qty_Buf_Ltr = Roundoff('Quantity'  ,  @TotalMilkQuantityBuffalo),
				Final_Qty_Buf_KG  =  Roundoff('Quantity'  ,  @TotalMilkQuantityBuffaloKG),
				Final_FAT_Buf_WtAvg =  @BuffaloFatweightAvg ,
				Final_SNF_Buf_WtAvg = @BuffaloSNFweightAvg,
				Final_Amout_Cow = @TotalMilkAmountCow,
				Final_Amout_Buf =  @TotalMilkAmountBuffalo
				WHERE Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id  and MCCCollectionShift_Id = @MCCCollectionShift_Id
				and AgentCollection_Id =  @AgentCollection_Id ;

			
				delete from t006_milkcollectionagent_item where  Org_Id =Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id ;
				
                
                /*
                select 
                Var_Org_Id, @AgentCollection_Id , Var_MCC_Id , @MCCCollectionShift_Id , Var_Profile_Id , Var_Driver_Id , 
				cast(Var_AluminumCan_With_Lid as SIGNED),
				cast(Var_AluminumCan_Without_Lid as SIGNED) ,
				cast(Var_PlasticCan_With_Lid as SIGNED), 
				 cast(Var_PlasticCan_Without_Lid as SIGNED) ,
				Roundoff('Quantity'  ,  @TotalMilkQuantityCow), Roundoff('Quantity' , @TotalMilkQuantityCowKG), @CowFatweightAvg,
				@CowSNFweightAvg, Roundoff('Quantity'  ,  @TotalMilkQuantityBuffaloKG), Roundoff('Quantity', @TotalMilkQuantityBuffalo) ,
				@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
				0,1,0,@Current_Datetime, Var_Profile_Id , (select Agent_Name from mu05_agent where Org_Id = Var_Org_Id and Agent_Id = Var_Profile_Id) , @MusterCycle_StartDate , @MusterCycle_EndDate;
                */

				set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);

				SET row_count := extractValue(var_XMLData,'count(//D/R)');
				Set k := 0;
				WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
                
                INSERT INTO t006_milkcollectionagent_item (Org_Id,AgentCollection_Id, Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id) VALUES (
				Var_Org_Id,
				@AgentCollection_Id,
				extractValue(var_XMLData, concat(xpath,'/MTI')),
				extractValue(var_XMLData, concat(xpath,'/QTY')),
				ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
				ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
				Var_MilkStatus_Id
				);
				

				END WHILE;

				
				delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
				( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;

			
				select 1 as Result_Id, 'Milk Dispatched updated' as Result_Description, '' as Result_Extra_Key;
					
            else
				set @AgentCollection_Id = '';
				set @Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
                
				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001' ;

				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';

				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;

				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;

				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;


				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);


				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
               
				set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
				Applicable_Date <= @Current_Datetime
				order by Applicable_Date desc limit 1 ) ;

				Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );

				if(@MusterType = 1)then 

					Set @MusterCycle_StartDate = @Current_Datetime;
					set @MusterCycle_EndDate =  @Current_Datetime;

				elseif(@MusterType = 7) then 

					if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 7 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-07');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 8 AND 14) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-14');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 15 AND 21) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-21');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 31) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

					end if;

				elseif(@MusterType = 15) then 

					if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 15 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');

					else 
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

					end if;

				elseif(@MusterType = 5) then 

					if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 5 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-05');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 6 AND 10) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 15) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 20 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 25 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-25');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 26 AND 31 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

					end if;

				elseif(@MusterType = 10) then 

					if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 10 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 20) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 31) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

					end if;

				elseif(@MusterType = 30) then 

					Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
					set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

				end if;
              
                insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
				Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
				Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
				Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
				 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
				) values 
				( Var_Org_Id, @AgentCollection_Id , Var_MCC_Id , @MCCCollectionShift_Id , Var_Profile_Id , Var_Driver_Id , 
				cast(Var_AluminumCan_With_Lid as SIGNED),
				cast(Var_AluminumCan_Without_Lid as SIGNED) ,
				cast(Var_PlasticCan_With_Lid as SIGNED), 
				 cast(Var_PlasticCan_Without_Lid as SIGNED) ,
				Roundoff('Quantity'  ,  @TotalMilkQuantityCow), Roundoff('Quantity' , @TotalMilkQuantityCowKG), @CowFatweightAvg,
				@CowSNFweightAvg, Roundoff('Quantity'  ,  @TotalMilkQuantityBuffaloKG), Roundoff('Quantity', @TotalMilkQuantityBuffalo) ,
				@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
				0,1,0,@Current_Datetime, Var_Profile_Id , (select Agent_Name from mu05_agent where Org_Id = Var_Org_Id and Agent_Id = Var_Profile_Id) , @MusterCycle_StartDate , @MusterCycle_EndDate
				) ;
                
                update t004_mcccollectionshift 
                set Is_MilkDispatch = 1 ,
                Shift_Status = 2
                where Org_Id = Var_Org_Id and 
				MCCCollectionShift_Id = @MCCCollectionShift_Id ;
				
                update t102_mcccollectionshift_offline 
                set Is_MilkDispatch = 1,
                Shift_Status = 2
                where Org_Id = Var_Org_Id and 
				MCCCollectionShift_Id = Var_MCC_Collection_Shift ;
                
                SET row_count := extractValue(var_XMLData,'count(//D/R)');
				Set k := 0;
				WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//D/R[', k, ']');
                    
						INSERT INTO t006_milkcollectionagent_item (Org_Id,AgentCollection_Id, Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id) VALUES (
						Var_Org_Id,
						@AgentCollection_Id,
						extractValue(var_XMLData, concat(xpath,'/MTI')),
						extractValue(var_XMLData, concat(xpath,'/QTY')),
						ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
						ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
						Var_MilkStatus_Id
						);
                    
					
					
				END WHILE;
                
                
                delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
				( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
				
				select 1 as Result_Id, 'Milk Dispatched' as Result_Description, '' as Result_Extra_Key;
               
            end if;
            
			
		end;
	elseif (Var_Method_Name = 'MilkDispatchOfflineNew') then
		begin
        	Declare RowCnt int;
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            
            
            set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);
            set @Year_Id = (select right(left(curdate(),4),(2)));
            set @Farmer_Id = (select Farmer_Id from mu04_farmer where Org_Id = Var_Org_Id
					and MCC_Id = Var_MCC_Id
					and Is_Offline = 0 limit 1);
                    
			select Collection_Date,CollectionShift_Id 
			into @var_Collection_Date,@var_CollectionShift_Id 
			from  t102_mcccollectionshift_offline 
			where Org_Id = Var_Org_Id
            and MCC_Id = Var_MCC_Id
			and MCCCollectionShift_Id = Var_MCC_Collection_Shift;
            
            SET @MCCCollectionShift_Id = '';
            
			set @set_MCCCollectionShift_Id = '';
            
			select MCCCollectionShift_Id into @set_MCCCollectionShift_Id  
            from t004_mcccollectionshift 
			where Org_Id = Var_Org_Id
            and MCC_Id = Var_MCC_Id
			and date(Collection_Date) = date(@var_Collection_Date)
			and CollectionShift_Id = @var_CollectionShift_Id limit 1;
            
            
            SET row_count := extractValue(var_XMLData,'count(//D/R)');
					
				Set k := 0;
				WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
                
                Call USP_Number_Range ('t104_mcc_collection_offline', @Year_Id, 'T104', '', @Entry_Id);
				
					INSERT INTO t104_mcc_collection_offline (
					Org_Id,Entry_Id, 
					MCCCollectionShift_Id,MCC_Id,Mlk_Type,Entry_Type,
					Quantity,Fat,Snf,Date
					) VALUES (
					Var_Org_Id,
					@Entry_Id,Var_MCC_Collection_Shift,Var_MCC_Id,
					extractValue(var_XMLData, concat(xpath,'/milktype')),
					'Dispatch',
					extractValue(var_XMLData, concat(xpath,'/quantity')),
					ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0),
					ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0),
					@var_Collection_Date
					);
                    
                    update t105_mcc_collection_stock_offline
					set 
					Quantity = Quantity - extractValue(var_XMLData, concat(xpath,'/quantity')),
					Fat = ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0),
					Snf = ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0)
					where Org_Id = Var_Org_Id
					and date(Date) = date(@var_Collection_Date)
					and MCC_Id = Var_MCC_Id
					and Mlk_Type = extractValue(var_XMLData, concat(xpath,'/milktype'));
					
					update t105_mcc_collection_stock_offline
					set 
					Fat = 0,
					Snf = 0
					where Org_Id = Var_Org_Id
					and date(Date) = date(@var_Collection_Date)
					and MCC_Id = Var_MCC_Id
					and Quantity = 0
					and Mlk_Type = extractValue(var_XMLData, concat(xpath,'/milktype'));

			END WHILE;
            
            
             
            if(@set_MCCCollectionShift_Id  is null or @set_MCCCollectionShift_Id  = '')then
            
				
				Call USP_Number_Range ('t004_mcccollectionshift', @Year_Id, 'T004', '', @MCCCollectionShift_Id);
                
                insert into t004_mcccollectionshift (
				Org_Id,MCCCollectionShift_Id,MCC_Id,Collection_Date,CollectionShift_Id,CollectionShift_Name,Shift_Status,ShiftStart_Time,Expected_End_Time,
				Is_MilkDispatch,Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,Is_FromApp
				) 
				select 
				Org_Id,@MCCCollectionShift_Id,MCC_Id,Collection_Date,CollectionShift_Id,CollectionShift_Name,Shift_Status,ShiftStart_Time,Expected_End_Time,
				'1',Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,Is_FromApp
				from t102_mcccollectionshift_offline 
				where Org_Id = Var_Org_Id and MCCCollectionShift_Id = Var_MCC_Collection_Shift;
			
				set @MCCCollectionShift_Id = @MCCCollectionShift_Id;
				
            else
				set @MCCCollectionShift_Id = @set_MCCCollectionShift_Id;
            end if;
            
            
            update t022_tripdocument_item 
			set MCC_CollectionShift_Id = @MCCCollectionShift_Id
			where 
            Org_Id = Var_Org_Id 
            and TripDocument_Id = Var_TripDocument_Id
			and MCC_Id = Var_MCC_Id;
            
            select EntryTime,MusterCycle_StartDate,MusterCycle_EndDate,Created_On,CreatedBy_Id,CreatedBy_Name,Anamat_Charge,Freight_Charge,Is_FromApp
			into @var_EntryTime,@var_MusterCycle_StartDate,@var_MusterCycle_EndDate,@var_Created_On,@var_CreatedBy_Id,@var_CreatedBy_Name,@var_Anamat_Charge,@var_Freight_Charge,@var_Is_FromApp
			from t103_milkcollectionfarmer_offline 
			where Org_Id = Var_Org_Id and MCCCollectionShift_Id = Var_MCC_Collection_Shift
			and MilkStatus_Id ='C016001' limit 1;
            
			delete from t005_milkcollectionfarmer where Org_Id = Var_Org_Id and MCCCollectionShift_Id = @MCCCollectionShift_Id;
            
			SET row_count := extractValue(var_XMLData,'count(//D/R)');
			Set k := 0;
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
                
					
						if (
						extractValue(var_XMLData, concat(xpath,'/quantity')) <> 0 and
						extractValue(var_XMLData, concat(xpath,'/FAT')) <> 0 and
						extractValue(var_XMLData, concat(xpath,'/SNF')) <> 0 
						)then
						
						
						Call USP_Number_Range ('t005_milkcollectionfarmer', @Year_Id, 'T005', '', @FarmerCollection_Id);
						
						set @Total_Milk_Rate =  GetMilkRateDate(
						Var_Org_Id, 
						Var_MCC_Id, 
						@var_CollectionShift_Id, 
						ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0), 
						ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0) ,
						extractValue(var_XMLData, concat(xpath,'/milktype')),
						@var_Collection_Date);
						
						set @Total_Milk_Amout = @Total_Milk_Rate *  (extractValue(var_XMLData, concat(xpath,'/quantity')));
						
						
						
						INSERT INTO t005_milkcollectionfarmer (
						Org_Id,FarmerCollection_Id,MCC_Id,MCCCollectionShift_Id,Farmer_Id,MilkType_Id,MilkStatus_Id,
						Quantity_Ltr,Quantity_Kg,Fat,SNF,
						ApplicableRate,Amount,
						Is_Active,Is_Deleted,
						EntryTime,MusterCycle_StartDate,MusterCycle_EndDate,Created_On,CreatedBy_Id,CreatedBy_Name,Anamat_Charge,Freight_Charge,Is_FromApp) 
						VALUES (
						Var_Org_Id,@FarmerCollection_Id,Var_MCC_Id,@MCCCollectionShift_Id,@Farmer_Id,
						extractValue(var_XMLData, concat(xpath,'/milktype')),
						Var_MilkStatus_Id,
						(extractValue(var_XMLData, concat(xpath,'/quantity'))),
						((extractValue(var_XMLData, concat(xpath,'/quantity')) / @kg_to_ltr )),
						 ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0),
						ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0),
						@Total_Milk_Rate,@Total_Milk_Amout,
						1,0,
						@var_EntryTime,@var_MusterCycle_StartDate,@var_MusterCycle_EndDate,@var_Created_On,@var_CreatedBy_Id,@var_CreatedBy_Name,@var_Anamat_Charge,@var_Freight_Charge,@var_Is_FromApp );
                    
				end if;
					
				
			END WHILE;
            
            /*
            set @AgentCollection_Id = (select AgentCollection_Id from t006_milkcollectionagent 
            where  Org_Id =Var_Org_Id and MCC_Id = Var_MCC_Id  and 
            MCCCollectionShift_Id = @MCCCollectionShift_Id limit 1 ) ;
            
            
            if(@AgentCollection_Id is not null or @AgentCollection_Id <> '') then
				
                set @AgentCollection_Id = (select AgentCollection_Id from t006_milkcollectionagent 
				where  Org_Id =Var_Org_Id and MCC_Id = Var_MCC_Id  and 
				MCCCollectionShift_Id = @MCCCollectionShift_Id limit 1 ) ;

				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001' ;


				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';

				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;

				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;

				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;



				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);


				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				
				UPDATE t006_milkcollectionagent 
				SET Aluminum_Can_With_Lid =  cast(Var_AluminumCan_With_Lid as SIGNED), 
				Aluminum_Can_Without_Lid = cast(Var_AluminumCan_Without_Lid as SIGNED ), 
				Plastic_Can_With_Lid = cast(Var_PlasticCan_With_Lid as SIGNED) , 
				Plastic_Can_Without_Lid =  cast(Var_PlasticCan_Without_Lid as SIGNED),
				Final_Qty_Cow_Ltr =  Roundoff('Quantity'  , @TotalMilkQuantityCow) ,
				Final_Qty_Cow_KG = Roundoff('Quantity'  , @TotalMilkQuantityCowKG),
				Final_FAT_Cow_WtAvg = @CowFatweightAvg,
				Final_SNF_Cow_WtAvg = @CowSNFweightAvg,
				Final_Qty_Buf_Ltr = Roundoff('Quantity'  ,  @TotalMilkQuantityBuffalo),
				Final_Qty_Buf_KG  =  Roundoff('Quantity'  ,  @TotalMilkQuantityBuffaloKG),
				Final_FAT_Buf_WtAvg =  @BuffaloFatweightAvg ,
				Final_SNF_Buf_WtAvg = @BuffaloSNFweightAvg,
				Final_Amout_Cow = @TotalMilkAmountCow,
				Final_Amout_Buf =  @TotalMilkAmountBuffalo
				WHERE Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id  and MCCCollectionShift_Id = @MCCCollectionShift_Id
				and AgentCollection_Id =  @AgentCollection_Id ;

			
				delete from t006_milkcollectionagent_item where  Org_Id =Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id ;
				
				set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);

				SET row_count := extractValue(var_XMLData,'count(//D/R)');
				Set k := 0;
				WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
                
                INSERT INTO t006_milkcollectionagent_item (Org_Id,AgentCollection_Id, Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id) VALUES (
				Var_Org_Id,
				@AgentCollection_Id,
				extractValue(var_XMLData, concat(xpath,'/milktype')),
				extractValue(var_XMLData, concat(xpath,'/quantity')),
				ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0),
				ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0),
				Var_MilkStatus_Id
				);
				

				END WHILE;

				
				delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
				( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;

			
				select 1 as Result_Id, 'Milk Dispatched updated' as Result_Description, '' as Result_Extra_Key;
					
            else
				set @AgentCollection_Id = '';
				set @Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('t006_milkcollectionagent', @Year_Id, 'T006', '', @AgentCollection_Id);
                
				set @TotalMilkQuantity = '';
				set @TotalQuantity = '';
				select sum(Quantity_Ltr) , count(*) into @TotalMilkQuantity , @TotalQuantity from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id and MilkStatus_Id = 'C016001' ;

				set @TotalMilkQuantityCow = '';
				set @TotalQuantityCow = '';
				select sum(Quantity_Ltr) , sum(Quantity_Kg)  , sum(Amount), count(*) 
				into @TotalMilkQuantityCow , @TotalMilkQuantityCowKG  , @TotalMilkAmountCow   , @TotalQuantityCow 
				from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001';

				set @AvgSNFCow = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @AvgFatCow = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001') / @TotalQuantity;

				set @TotalMilkQuantityBuffalo  = '';
				set @TotalQuantityBuffalo = '';
				select sum(Quantity_Ltr) ,sum(Quantity_Kg), sum(Amount) , count(*) 
				into @TotalMilkQuantityBuffalo ,  @TotalMilkQuantityBuffaloKG , @TotalMilkAmountBuffalo ,  @TotalQuantityBuffalo 
				from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ;

				set @AvgSNFBuffalo = (select sum(SNF)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001' ) / @TotalQuantity;

				set @AvgFatBuffalo = (select sum(Fat)  from t005_milkcollectionfarmer where MCC_Id = Var_MCC_Id 
				and MCCCollectionShift_Id = @MCCCollectionShift_Id and Org_Id = Var_Org_Id AND MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001') / @TotalQuantity;


				Set @CowFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloFatweightAvg =  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);


				Set @CowSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011001' and MilkStatus_Id = 'C016001'  and Is_Active = 1);

				Set @BuffaloSNFweightAvg =  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t005_milkcollectionfarmer where MCCCollectionShift_Id = @MCCCollectionShift_Id and 
				MilkType_Id = 'C011002' and MilkStatus_Id = 'C016001'  and Is_Active = 1);
               
				set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
				Applicable_Date <= @Current_Datetime
				order by Applicable_Date desc limit 1 ) ;

				Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );

				if(@MusterType = 1)then 

					Set @MusterCycle_StartDate = @Current_Datetime;
					set @MusterCycle_EndDate =  @Current_Datetime;

				elseif(@MusterType = 7) then 

					if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 7 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-07');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 8 AND 14) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-14');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 15 AND 21) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-21');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 31) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

					end if;

				elseif(@MusterType = 15) then 

					if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 15 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');

					else 
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

					end if;

				elseif(@MusterType = 5) then 

					if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 5 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-05');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 6 AND 10) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 15) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 20 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 25 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-25');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 26 AND 31 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

					end if;

				elseif(@MusterType = 10) then 

					if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 10 ) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 20) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 31) then

						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

					end if;

				elseif(@MusterType = 30) then 

					Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
					set @MusterCycle_EndDate =  LAST_DAY(CURDATE());

				end if;
              
                insert into t006_milkcollectionagent (Org_Id, AgentCollection_Id , MCC_Id , MCCCollectionShift_Id , Agent_Id ,
				Driver_Id,  Aluminum_Can_With_Lid , Aluminum_Can_Without_Lid , Plastic_Can_With_Lid , Plastic_Can_Without_Lid ,
				Final_Qty_Cow_Ltr,  Final_Qty_Cow_KG,  Final_FAT_Cow_WtAvg, Final_SNF_Cow_WtAvg,
				Final_Qty_Buf_KG , Final_Qty_Buf_Ltr, Final_FAT_Buf_WtAvg , Final_SNF_Buf_WtAvg, Final_Amout_Cow , Final_Amout_Buf,
				 Is_Locked , Is_Active , Is_Deleted , Created_On , CreatedBy_Id , CreatedBy_Name , MusterCycle_StartDate , MusterCycle_EndDate
				) values 
				( Var_Org_Id, @AgentCollection_Id , Var_MCC_Id , @MCCCollectionShift_Id , Var_Profile_Id , Var_Driver_Id , 
				cast(Var_AluminumCan_With_Lid as SIGNED),
				cast(Var_AluminumCan_Without_Lid as SIGNED) ,
				cast(Var_PlasticCan_With_Lid as SIGNED), 
				 cast(Var_PlasticCan_Without_Lid as SIGNED) ,
				Roundoff('Quantity'  ,  @TotalMilkQuantityCow), Roundoff('Quantity' , @TotalMilkQuantityCowKG), @CowFatweightAvg,
				@CowSNFweightAvg, Roundoff('Quantity'  ,  @TotalMilkQuantityBuffaloKG), Roundoff('Quantity', @TotalMilkQuantityBuffalo) ,
				@BuffaloFatweightAvg , @BuffaloSNFweightAvg, @TotalMilkAmountCow, @TotalMilkAmountBuffalo,
				0,1,0,@Current_Datetime, Var_Profile_Id , (select Agent_Name from mu05_agent where Org_Id = Var_Org_Id and Agent_Id = Var_Profile_Id) , @MusterCycle_StartDate , @MusterCycle_EndDate
				) ;
                
                update t004_mcccollectionshift set Is_MilkDispatch = 1 where Org_Id = Var_Org_Id and 
				MCCCollectionShift_Id = @MCCCollectionShift_Id ;
				
                update t102_mcccollectionshift_offline set Is_MilkDispatch = 1 where Org_Id = Var_Org_Id and 
				MCCCollectionShift_Id = Var_MCC_Collection_Shift ;
                
                SET row_count := extractValue(var_XMLData,'count(//D/R)');
				Set k := 0;
				WHILE k < row_count DO        
					SET k := k + 1;
					SET xpath := concat('//D/R[', k, ']');
                    
						INSERT INTO t006_milkcollectionagent_item (Org_Id,AgentCollection_Id, Milktype_Id,Quantity_Ltr,FAT,SNF,MilkStatus_Id) VALUES (
						Var_Org_Id,
						@AgentCollection_Id,
						extractValue(var_XMLData, concat(xpath,'/milktype')),
						extractValue(var_XMLData, concat(xpath,'/quantity')),
						ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0),
						ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/quantity'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/quantity')))))),0),
						Var_MilkStatus_Id
						);
                    
					
					
				END WHILE;
                
                
                delete from t006_milkcollectionagent_item where  Org_Id = Var_Org_Id and AgentCollection_Id =  @AgentCollection_Id and
				( Quantity_Ltr = 0 or FAT = 0 or SNF = 0 or Quantity_Ltr is null or FAT is null or SNF is null or Quantity_Ltr = 0.0 ) ;
				
				select 1 as Result_Id, 'Milk Dispatched' as Result_Description, '' as Result_Extra_Key;
               
            end if;
            */
            select 1 as Result_Id, 'Milk Dispatched' as Result_Description, '' as Result_Extra_Key;
			
		end;
	elseif (Var_Method_Name = 'MilkSellOffline') then
		begin
			Declare RowCnt int;
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
        
			SET row_count := extractValue(var_XMLData,'count(//D/R)');
					
			Set k := 0;
            
            
            if(Var_MCC_Collection_Shift is null or Var_MCC_Collection_Shift = '')then
            
				set @var_Collection_Date = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
                
            else
	
				select Collection_Date
				into @var_Collection_Date
				from  t102_mcccollectionshift_offline 
				where Org_Id = Var_Org_Id
				and MCCCollectionShift_Id = Var_MCC_Collection_Shift;
            
            end if;
            
            
            set @Year_Id = (select right(left(curdate(),4),(2)));
                
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
				
				Call USP_Number_Range ('t104_mcc_collection_offline', @Year_Id, 'T104', '', @Entry_Id);
				
				
				INSERT INTO t104_mcc_collection_offline (
				Org_Id,Entry_Id, 
				MCCCollectionShift_Id,MCC_Id,Mlk_Type,Entry_Type,
				Quantity,Fat,Snf,Date,Dealer_Name
				) VALUES (
				Var_Org_Id,
				@Entry_Id,Var_MCC_Collection_Shift,Var_MCC_Id,
				extractValue(var_XMLData, concat(xpath,'/MTI')),
                'Sell',
				(extractValue(var_XMLData, concat(xpath,'/QTY'))),
				ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
				ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
				@var_Collection_Date,
                Var_Dealer_Name
				);
                
                
                update t105_mcc_collection_stock_offline
				set 
				Quantity = Quantity - (extractValue(var_XMLData, concat(xpath,'/QTY'))),
				Fat = ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
				Snf = ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0)
				where Org_Id = Var_Org_Id
				and date(Date) = date(@var_Collection_Date)
				and MCC_Id = Var_MCC_Id
				and Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI'));
                
                update t105_mcc_collection_stock_offline
				set 
				Fat = 0,
				Snf = 0
				where Org_Id = Var_Org_Id
				and date(Date) = date(@var_Collection_Date)
				and MCC_Id = Var_MCC_Id
                and Quantity = 0
				and Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI'));
                
                
                
			END WHILE;
            
            select 1 as Result_Id, 'Milk Sell' as Result_Description, '' as Result_Extra_Key;
        end;
	elseif (Var_Method_Name = 'MilkResetOffline') then
		begin
			Declare RowCnt int;
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
        
			SET row_count := extractValue(var_XMLData,'count(//D/R)');
					
			Set k := 0;
            
            
            if(Var_MCC_Collection_Shift is null or Var_MCC_Collection_Shift = '')then
            
				set @var_Collection_Date = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
                
            else
	
				select Collection_Date
				into @var_Collection_Date
				from  t102_mcccollectionshift_offline 
				where Org_Id = Var_Org_Id
				and MCCCollectionShift_Id = Var_MCC_Collection_Shift;
            
            end if;
            
            set @Year_Id = (select right(left(curdate(),4),(2)));
                
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
				
				Call USP_Number_Range ('t104_mcc_collection_offline', @Year_Id, 'T104', '', @Entry_Id);
				
				
				INSERT INTO t104_mcc_collection_offline (
				Org_Id,Entry_Id, 
				MCCCollectionShift_Id,MCC_Id,Mlk_Type,Entry_Type,
				Quantity,Fat,Snf,Date
				) VALUES (
				Var_Org_Id,
				@Entry_Id,Var_MCC_Collection_Shift,Var_MCC_Id,
				extractValue(var_XMLData, concat(xpath,'/MTI')),
                'Reset',
				(extractValue(var_XMLData, concat(xpath,'/QTY'))),
				ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/FAT'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
				ifnull(Roundoff('Quality',((extractValue(var_XMLData, concat(xpath,'/QTY'))) * extractValue(var_XMLData, concat(xpath,'/SNF'))) / (((extractValue(var_XMLData, concat(xpath,'/QTY')))))),0),
				@var_Collection_Date
				);
                
                SET SQL_SAFE_UPDATES = 0;
                
                 DELETE FROM t105_mcc_collection_stock_offline_reset
					where Org_Id = Var_Org_Id
					and date(Date) = date(now())
					and MCC_Id = Var_MCC_Id
					and Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI'));
                
                insert into t105_mcc_collection_stock_offline_reset (
						Org_Id,MCC_Id,Mlk_Type,Date,Quantity,Fat,Snf
					)
					select Org_Id,MCC_Id,Mlk_Type,Date,Quantity,Fat,Snf from 
					t105_mcc_collection_stock_offline
					where Org_Id = Var_Org_Id
					-- and date(Date) = date(@var_Collection_Date)
					and MCC_Id = Var_MCC_Id
					and Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI'));
                    
                    
                    
                    DELETE FROM t105_mcc_collection_stock_offline
					where Org_Id = Var_Org_Id
					-- and date(Date) = date(@var_Collection_Date)
					and MCC_Id = Var_MCC_Id
					and Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI'));
                
                /*
                update t105_mcc_collection_stock_offline
				set 
				Quantity = 0,
				Fat = 0,
				Snf = 0
				where Org_Id = Var_Org_Id
				and date(Date) = date(@var_Collection_Date)
				and MCC_Id = Var_MCC_Id
				and Mlk_Type = extractValue(var_XMLData, concat(xpath,'/MTI'));
                */
                
                
			END WHILE;
            
            select 1 as Result_Id, 'Milk Reset' as Result_Description, '' as Result_Extra_Key;
        end;
        
	elseif (Var_Method_Name = 'TodayMilkSell') then
		begin
			select 
			Dealer_Name,Quantity,Fat,Snf,
			DATE_FORMAT(Date, '%d %b %Y %h:%i %p') AS Date
			from t104_mcc_collection_offline
			where Org_Id = Var_Org_Id
			and MCC_Id = Var_MCC_Id
			and Entry_Type ='Sell'
			and Date(Date) = date(now())
			and Quantity <> 0
			and Fat <> 0
			and Snf <> 0;
        end;
	elseif (Var_Method_Name = 'CheckMilkSell') then
		begin
			SET @var_Date = CONVERT_TZ(var_XMLData, '+00:00', '+00:00');
            
			select 
			Dealer_Name,Quantity,Fat,Snf,
			DATE_FORMAT(Date, '%d %b %Y %h:%i %p') AS Date
			from t104_mcc_collection_offline
			where Org_Id = Var_Org_Id
			and MCC_Id = Var_MCC_Id
			and Entry_Type ='Sell'
			and Date(Date) = date(@var_Date)
			and Quantity <> 0
			and Fat <> 0
			and Snf <> 0;
        end;
	end if ;
	
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
