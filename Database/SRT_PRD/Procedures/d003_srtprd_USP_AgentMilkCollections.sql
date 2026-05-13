-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMilkCollections` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMilkCollections`(
Var_Method_Name varchar(255),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_MCC_Collection_Shift Varchar(20),
Var_ShiftType_Id varchar(20),
Var_Farmer_Id varchar(20),
Var_Milk_Quantity varchar(50),
Var_Milk_SNF varchar(50),
Var_Milk_FAT varchar(50),
Var_Milk_Type_Id varchar(10),
Var_Milk_Status varchar(20),
Var_Image text,
Var_Profile_Id varchar(20),
Var_Quantity_Auto_Flag int ,
Var_Quality_Auto_Flag int ,
var_protein varchar(50),
Var_FilePath longtext,
var_android_version  text,
var_make_model text,
var_date varchar(255)
)
proc_Exit: BEGIN


set @Current_Datetime = (SELECT CONVERT_TZ(var_date, '+00:00', '+00:00'));
 set@Current_Datetime = (SELECT DATE_FORMAT( @Current_Datetime, '%Y-%m-%d %H:%i:%s'));

set Var_MCC_Collection_Shift = ( select MCCCollectionShift_Id from t102_mcccollectionshift_offline
							where Org_Id = Var_Org_Id
							and MCC_Id =  Var_MCC_Id
							and CollectionShift_Id =  Var_ShiftType_Id
							and date(Collection_Date) = date(@Current_Datetime) limit 1);
	
	if (Var_Method_Name = 'CollectMilkOffline') then
    if(Var_MCC_Collection_Shift is null or Var_MCC_Collection_Shift ='')then
    set@Current_Datetime = (SELECT DATE_FORMAT( @Current_Datetime, '%Y-%m-%d %H:%i:%s'));

		select CollectionShift_Id , CollectionShift_Name INTO @CollectionShift_Id ,  @CollectionShift_Name  from c015_collectionshift c015 where CollectionShift_Id = Var_ShiftType_Id limit 1;
		set @Current_times = (SELECT TIME(CONVERT_TZ(@Current_Datetime, '+00:00', '+00:00')));
        
		set @Year_Id = (select right(left(date(@Current_Datetime),4),(2)));
      
		set @New_MCCCollectionShift_Id ='';
		set @Agent_Id = (
		SELECT Agent_Id FROM m005_mcc 
		where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id);
		
		Call USP_Number_Range ('t102_mcccollectionshift_offline', @Year_Id, 'T102', '', @New_MCCCollectionShift_Id);
		
		select ShiftEnd_Time INTO @ShiftEnd_Time  from c015_collectionshift where CollectionShift_Id = @CollectionShift_Id;
		
		insert into t102_mcccollectionshift_offline
		(Org_Id, MCCCollectionShift_Id , MCC_Id , Collection_Date , CollectionShift_Id , CollectionShift_Name ,
		Shift_Status, ShiftStart_Time, Is_Active , Is_Deleted , Created_On , CreatedBy_Id ,
		CreatedBy_Name , Is_MilkDispatch, Expected_End_Time) 
		( select var_Org_Id , @New_MCCCollectionShift_Id , 	var_MCC_Id , @Current_Datetime ,  @CollectionShift_Id , @CollectionShift_Name,
		1, @Current_times , 1 , 0 , @Current_Datetime, @Agent_Id , Agent_Name , 0 , @ShiftEnd_Time
		from mu05_agent where Org_Id = var_Org_Id and 
		Agent_Id = @Agent_Id limit 1 ) ;
		
        set Var_MCC_Collection_Shift = @New_MCCCollectionShift_Id;
		
    else
		set Var_MCC_Collection_Shift = Var_MCC_Collection_Shift;
    end if;
    
    
    set@Current_Datetime = (SELECT DATE_FORMAT( @Current_Datetime, '%Y-%m-%d %H:%i:%s'));



		set @Milk_Base_Rate = '';
		set @Milk_Base_FAT = '';
		set @Milk_Base_SNF = '';
		set @Milk_Fat_Deduction = '';
		set @Milk_Snf_Deduction = '';
		set @Milk_High_fat = ''; 
		set @Milk_High_Snf = '';
		set @Total_Milk_Amout = '';
		set @Milk_Quantity_ltr = '';
        
		set @Milk_Fat_Deduction1 = 0; 
		set @Milk_High_fat1 = 0;
		SET @Milk_Snf_Deduction1 = 0;
		SET @Milk_High_Snf1 = 0;

		set Var_Milk_FAT =  Roundoff('Quality'  , Var_Milk_FAT);
		set Var_Milk_SNF = Roundoff('Quality'  , Var_Milk_SNF);
		set Var_Milk_Quantity = Roundoff('Quantity'  , Var_Milk_Quantity);


		if(select 1 from t103_milkcollectionfarmer_offline where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id 
			and MCCCollectionShift_Id = Var_MCC_Collection_Shift and Farmer_Id = Var_Farmer_Id  and MilkType_Id = Var_Milk_Type_Id ) then 

			select -1 as Result_Id, 'Already Collected' as Result_Description, 'Reject' as Result_Extra_Key; 

		else
            
            /*
			Set @ChartId = ( select Chart_Id from f002_milk_rate_current where Header_Applicable_Date <= now() and 
			MCC_Id = Var_MCC_Id  and CollectionShift_Id = Var_ShiftType_Id 
			and MilkType_Id = Var_Milk_Type_Id
			order by Header_Applicable_Date desc , Item_Applicable_Date desc  limit 1 );
            
			*/
			select m005.Version_No , Anamat_PerLtr , Freight_PerLtr
			into @Version_No , @Anamat , @Freight from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = Var_Org_Id
			order by Applicable_Date desc limit 1 ;
			 
			
            /*
			SELECT Amount, Base_FAT , Base_SNF into @Milk_Base_Rate , @Milk_Base_FAT , @Milk_Base_SNF FROM f002_milk_rate_current 
			where MCC_Id = Var_MCC_Id and MilkType_Id = Var_Milk_Type_Id and CollectionShift_Id = Var_ShiftType_Id  and chart_id = @ChartId
			and MilkRateEntryType_Id = 'C012001' and Item_Applicable_Date < @Current_Datetime order by Item_Applicable_Date desc limit 1; 
			*/

			set @kg_to_ltr = (select Kg_To_Ltr_Farmer from c001_organization where Org_Id = Var_Org_Id);

			set @Milk_Quantity_ltr = Var_Milk_Quantity;

			Set @Milk_Base_Rate = CAST(@Milk_Base_Rate AS DECIMAL(8, 2));


				if (Var_Milk_Status = 'C016002')then 
                
					SET @FarmerCollection_Id = '';
					set @Year_Id = (select right(left(@Current_Datetime,4),(2)));
					Call USP_Number_Range ('t103_milkcollectionfarmer_offline', @Year_Id, 'T103', '', @FarmerCollection_Id);

					INSERT INTO t103_milkcollectionfarmer_offline ( Org_Id , FarmerCollection_Id , MCC_Id , MCCCollectionShift_Id , Farmer_Id,
					MilkType_Id , MilkStatus_Id , Quantity_Kg , Quantity_Ltr, Fat ,SNF , QuantityAuto_Flag, QualityAuto_Flag , ApplicableRate , Amount , EntryTime , Is_Active,
					Is_Deleted,Created_On , CreatedBy_Id , CreatedBy_Name 
					) VALUE 
					( Var_Org_Id , @FarmerCollection_Id , Var_MCC_Id , Var_MCC_Collection_Shift , Var_Farmer_Id , 
					Var_Milk_Type_Id , Var_Milk_Status , (Var_Milk_Quantity/@kg_to_ltr), @Milk_Quantity_ltr , Var_Milk_FAT , Var_Milk_SNF , Var_Quantity_Auto_Flag , Var_Quality_Auto_Flag,
					@Milk_Base_Rate, 0 , @Current_Datetime, 1, 0,@Current_Datetime, Var_Profile_Id , 
					(select Agent_Name from mu05_agent where Org_Id = Var_Org_Id and  Agent_Id = Var_Profile_Id limit 1) );
                    
                    
                    /*
                    insert into l006_collectionrecord(Ref_Id, Android_Version, Make_Model, Created_On) value 
                    (@FarmerCollection_Id , var_android_version , var_make_model , now()
                    );
                    
                    */


					select 3 as Result_Id, 'Milk Rejected' as Result_Description, '' as Result_Extra_Key;  
                
			else
                
			/*
			
            set @Milk_FatDeduction ='';
            set @Milk_SnfDeduction ='';
            set @Milk_Highfat ='';
            set @Milk_HighSnf ='';
            
			select slabs.Slab_Id into @Milk_FatDeduction from m014_slab m014 inner join 
			(SELECT Org_Id , Slab_Id,Amount , Item_Applicable_Date  FROM f002_milk_rate_current where MCC_Id = Var_MCC_Id and MilkType_Id = Var_Milk_Type_Id
			and CollectionShift_Id = Var_ShiftType_Id and MilkRateEntryType_Id = 'C012002' and chart_id = @ChartId and Item_Applicable_Date <=  @Current_Datetime order by Item_Applicable_Date desc  ) slabs on 
			m014.Org_Id = slabs.Org_Id and m014.Slab_Id = slabs.Slab_Id 
			where Slab_Min <= Var_Milk_FAT and Slab_Max >= Var_Milk_FAT order by slabs.Item_Applicable_Date limit 1;

		
			select slabs.Slab_Id  into @Milk_SnfDeduction from m014_slab m014 inner join 
			(SELECT Org_Id , Slab_Id,Amount , Item_Applicable_Date   FROM f002_milk_rate_current where MCC_Id = Var_MCC_Id and MilkType_Id = Var_Milk_Type_Id
			and CollectionShift_Id = Var_ShiftType_Id and MilkRateEntryType_Id = 'C012003' and chart_id = @ChartId  and Item_Applicable_Date <=  @Current_Datetime order by Item_Applicable_Date desc ) slabs on 
			m014.Org_Id = slabs.Org_Id and m014.Slab_Id = slabs.Slab_Id 
			where Slab_Min <= Var_Milk_SNF and Slab_Max >= Var_Milk_SNF order by slabs.Item_Applicable_Date desc limit 1;
            

			select slabs.Slab_Id into @Milk_Highfat from m014_slab m014 inner join 
			(SELECT Org_Id , Slab_Id ,Amount, Item_Applicable_Date FROM f002_milk_rate_current where MCC_Id = Var_MCC_Id and MilkType_Id = Var_Milk_Type_Id
			and CollectionShift_Id = Var_ShiftType_Id and MilkRateEntryType_Id = 'C012004' and chart_id = @ChartId  and Item_Applicable_Date <=  @Current_Datetime order by Item_Applicable_Date desc ) slabs on 
			m014.Org_Id =  slabs.Org_Id and m014.Slab_Id = slabs.Slab_Id 
			where Slab_Min <= Var_Milk_FAT and Slab_Max >= Var_Milk_FAT order by slabs.Item_Applicable_Date desc  limit 1;
				

			select slabs.Slab_Id into @Milk_HighSnf from m014_slab m014 inner join 
			(SELECT Org_Id , Slab_Id,Amount , Item_Applicable_Date FROM f002_milk_rate_current where MCC_Id = Var_MCC_Id and MilkType_Id = Var_Milk_Type_Id
			and CollectionShift_Id = Var_ShiftType_Id and MilkRateEntryType_Id = 'C012005' and chart_id = @ChartId  and Item_Applicable_Date <= @Current_Datetime order by Item_Applicable_Date desc  ) slabs on 
			m014.Org_Id = slabs.Org_Id and m014.Slab_Id = slabs.Slab_Id 
			where Slab_Min <= Var_Milk_SNF and Slab_Max >= Var_Milk_SNF order by slabs.Item_Applicable_Date desc limit 1;
                
                
		*/
        
        /*
		IF(Var_Milk_FAT < @Milk_Base_FAT ) THEN
			if ( @Milk_FatDeduction in (null , '') ) then
				select 2 as Result_Id, 'FAT Too Low' as Result_Description, 'Reject' as Result_Extra_Key;    
				Leave proc_Exit;
			end if;
		end if;
        
        
        IF(Var_Milk_FAT > @Milk_Base_FAT) THEN
			if (@Milk_Highfat in (null , '') )then
				select 2 as Result_Id, concat('FAT too high' ) as Result_Description, 'Reject' as Result_Extra_Key;    
				Leave proc_Exit;
			end if;
		end if;
        
        
        	IF(Var_Milk_SNF < @Milk_Base_SNF) THEN
					if( @Milk_SnfDeduction in (null , '') ) then 
						select 2 as Result_Id, 'SNF too low' as Result_Description, 'Reject' as Result_Extra_Key;    
						Leave proc_Exit;
                    end if;
		end if;
                
		IF(Var_Milk_SNF > @Milk_Base_SNF) THEN
					if( @Milk_HighSnf in (null , '') ) then 
						select 2 as Result_Id, 'SNF too high' as Result_Description, 'Reject' as Result_Extra_Key;    
						Leave proc_Exit;
				end if;
		end if;
        */
                
                
                set @Collection_Date =  (select CAST(@Current_Datetime AS CHAR));
				
                
				set @Total_Milk_Rate =  GetOffline_milk_rate_Farmer( Var_Org_Id, Var_MCC_Id,Var_Farmer_Id, Var_Milk_Type_Id,  @Collection_Date, Var_Milk_FAT,Var_Milk_SNF);
			
				
                if(ifnull(@Total_Milk_Rate, 0) in ( 0 , '') or ifnull(@Total_Milk_Rate,'') = '') then
			
					select 2 as Result_Id, 'Rate Not Maintained' as Result_Description, '' as Result_Extra_Key;  

				else
					
			
					set @MusterType_Id = (select MusterType_Id from m005_mcc_muster
						where Org_Id = Var_Org_Id
						and MCC_Id = Var_MCC_Id limit 1);
                        
					if(ifnull(@MusterType_Id,'') =''  or @MusterType_Id is null or @MusterType_Id ='')then
                    
						set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
						Applicable_Date <= @Current_Datetime
						order by Applicable_Date desc limit 1 ) ;
                    
                    else
                    
						set @MusterType_Id  = @MusterType_Id;
                    
                    end if;
                    
                    Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
                    
                    set @Current_Datetime = @Current_Datetime;
                    
					if(@MusterType = 1)then 
					
						Set @MusterCycle_StartDate = @Current_Datetime;
						set @MusterCycle_EndDate =  @Current_Datetime;
                    
                    elseif(@MusterType = 7) then 
						
                        if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 7 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-07');
                        
                        elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 8 AND 14) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-14');

						elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 15 AND 21) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-21');
                        
                      elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
					
                    end if;
                        
				elseif(@MusterType = 15) then 
                        
                        if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 15 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
                        
                        else 
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
							set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                        
                        end if;
                        
					elseif(@MusterType = 5) then 
                        
                        if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 5 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-05');
                        
					elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 6 AND 10) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

					elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 15) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
                        
                      elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 20 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');
                        
					elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 25 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-25');
					
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 26 AND 31 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                    
                    end if;
                    
				elseif(@MusterType = 10) then 
                        
                        if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 10 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');
                        
                        elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 20) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

						elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                    
                    end if;
                
					elseif(@MusterType = 30) then 
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                        
				end if;
                        
                        
					set @Total_Milk_Amout = @Total_Milk_Rate *  Var_Milk_Quantity;
                    
                   
					SET @FarmerCollection_Id = '';
					set @Year_Id = (select right(left(@Current_Datetime,4),(2)));
					Call USP_Number_Range ('t103_milkcollectionfarmer_offline', @Year_Id, 'T103', '', @FarmerCollection_Id);

					INSERT INTO t103_milkcollectionfarmer_offline ( Org_Id , FarmerCollection_Id , MCC_Id , MCCCollectionShift_Id , Farmer_Id,
					MilkType_Id , MilkStatus_Id , Quantity_Kg , Quantity_Ltr, Fat ,SNF , QuantityAuto_Flag, QualityAuto_Flag , ApplicableRate , Amount , EntryTime , Is_Active,
					Is_Deleted,Created_On , CreatedBy_Id , CreatedBy_Name  , MusterCycle_StartDate , MusterCycle_EndDate , Anamat_Charge , Freight_Charge ,Protein , Is_FromApp) VALUE 
					( Var_Org_Id , @FarmerCollection_Id , Var_MCC_Id , Var_MCC_Collection_Shift , Var_Farmer_Id , 
					Var_Milk_Type_Id , Var_Milk_Status , (Var_Milk_Quantity/@kg_to_ltr), CAST(Var_Milk_Quantity  AS DECIMAL(8,3))
                    , Var_Milk_FAT , Var_Milk_SNF , Var_Quantity_Auto_Flag , Var_Quality_Auto_Flag,
					 @Total_Milk_Rate , @Total_Milk_Amout ,  @Current_Datetime, 1, 0,@Current_Datetime, Var_Profile_Id , 
					(select Agent_Name from mu05_agent where Org_Id = Var_Org_Id and  Agent_Id = Var_Profile_Id limit 1) , @MusterCycle_StartDate , @MusterCycle_EndDate , @Anamat , @Freight , var_protein , 1);
                    
                    
                    set @Anamat_PerLtr = (select ifnull(Anamat_PerLtr,0) from m005_mcc_offline_anamat_config 
					where 
					Org_Id = Var_Org_Id
					and MCC_Id = Var_MCC_Id
					and Farmer_Id = Var_Farmer_Id
					and date(Created_On) <= date(now())
					order by Created_On desc limit 1);

					set @New_Entry_Id_Anamat = '';

					Call USP_Number_Range ('m005_mcc_offline_anamat_amount_config', @Year_Id, 'M005', '', @New_Entry_Id_Anamat );
							
					Insert Into m005_mcc_offline_anamat_amount_config
					(Org_Id, Entry_Id, MCC_Id, Farmer_Id, Anamat_PerLtr, 
					Quantity_Ltr, Created_On, 
					Is_Check, MusterCycle_StartDate, MusterCycle_EndDate, Is_InvoiceCreated)
					Values (var_Org_Id, @New_Entry_Id_Anamat, var_MCC_Id, var_Farmer_Id, ifnull(@Anamat_PerLtr,0),
					CAST(Var_Milk_Quantity  AS DECIMAL(8,3)),now(),
					0,@MusterCycle_StartDate,@MusterCycle_EndDate,0
					);


					update m005_mcc_offline_anamat_amount_config
					set Amount = ifnull(Quantity_Ltr,0) * ifnull(Anamat_PerLtr,0)
					where Org_Id = Var_Org_Id
					and MCC_Id = Var_MCC_Id
					and Farmer_Id = Var_Farmer_Id
					and Entry_Id = @New_Entry_Id_Anamat;
                    
                    
                    /*
                    Set @Mcc_Type = (select MCCType_Id from m005_mcc where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id limit 1);
                    
                    
					if (@Mcc_Type in ( 'C014002' , 'C014003') and Var_Milk_Status = 'C016001' )   then 

                     
						Set @Avgfat=  (select sum(Quantity_Ltr * Fat) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
						T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
						where T005.MCC_Id = Var_MCC_Id and T005.MCCCollectionShift_Id = Var_MCC_Collection_Shift   and 
						T005.MilkType_Id = Var_Milk_Type_Id and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);
                        

						Set @Avgsnf=  (select sum(Quantity_Ltr * SNF) / (sum(Quantity_Ltr)) from t103_milkcollectionfarmer_offline
						T005 inner join t102_mcccollectionshift_offline T004 on T005.Org_Id = T004.Org_Id and T005.MCCCollectionShift_Id = T004.MCCCollectionShift_Id
						where T005.MCC_Id = Var_MCC_Id and T005.MCCCollectionShift_Id = Var_MCC_Collection_Shift  and 
						T005.MilkType_Id = Var_Milk_Type_Id and T005.MilkStatus_Id = 'C016001'  and T005.Is_Active = 1);

						
						UPDATE  f009_mcc_collection F009
						SET Fat = if(Fat <> 0 ,  ((Fat * Quantity ) + (Var_Milk_Quantity * Var_Milk_FAT) ) / (Quantity + Var_Milk_Quantity), Var_Milk_FAT),
						Snf = if(Snf <> 0 ,((Snf * Quantity ) + (Var_Milk_Quantity * Var_Milk_SNF) ) / (Quantity + Var_Milk_Quantity), Var_Milk_SNF),
                        Quantity = Quantity + CAST(Var_Milk_Quantity  AS DECIMAL(8,3)),
						Amount = Amount +  @Total_Milk_Amout ,
                        Date = now()
                        where F009.Mlk_Type = Var_Milk_Type_Id and  Date <= Now()
						and F009.Entry_Type in ('Collection 1' , 'Collection 2') and MCCCollectionShift_Id = Var_MCC_Collection_Shift
						order by Date desc limit 1;
                        
						UPDATE  f009_mcc_collection F009
						SET Rate = Amount / Quantity
                        where F009.Mlk_Type = Var_Milk_Type_Id and  Date <= Now()
						and F009.Entry_Type in ('Collection 1' , 'Collection 2') and MCCCollectionShift_Id = Var_MCC_Collection_Shift
						order by Date desc limit 1;
                        
					end if;
                    
					insert into l006_collectionrecord(Ref_Id, Android_Version, Make_Model, Created_On) value 
                    (@FarmerCollection_Id , var_android_version , var_make_model , now()
                    );
                    
                    */ 
                    
					 if exists(select MCC_Id from t105_mcc_collection_stock_offline
								where Org_Id = Var_Org_Id
								and date(Date) = date(@Current_Datetime)
                                and MCC_Id = Var_MCC_Id
								and Mlk_Type = Var_Milk_Type_Id limit 1) then
                                
						select Quantity,Fat,Snf 
						into @var_Quantity,@var_Fat,@var_Snf 
						from t105_mcc_collection_stock_offline
						where Org_Id = var_Org_Id
						and MCC_Id = var_MCC_Id
                        and Mlk_Type = Var_Milk_Type_Id
                        and date(Date) = date(@Current_Datetime) limit 1;
                        
                        if(@var_Quantity is null or @var_Quantity = '') then
                            set @var_Quantity = 0;
                            set @var_Quantity = @var_Quantity + var_Milk_Quantity;
                        else
                            set @var_Quantity = @var_Quantity + var_Milk_Quantity;
                        end if;
                        
                        if(@var_Fat is null or @var_Fat = '') then
                            set @var_Fat = 0;
                            set @var_Fat = @var_Fat + var_Milk_FAT;
                        else
                            set @var_Fat = ( @var_Fat + var_Milk_FAT ) / 2;
                        end if;
                        
                        if(@var_Snf is null or @var_Snf = '') then
                            set @var_Snf = 0;
                            set @var_Snf = @var_Snf + var_Milk_SNF;
                        else
                            set @var_Snf = ( @var_Snf + var_Milk_SNF ) / 2;
                        end if;
                                
						update t105_mcc_collection_stock_offline
                        set 
                        Quantity = @var_Quantity,
                        Fat = @var_Fat,
                        Snf = @var_Snf
                        where Org_Id = Var_Org_Id
						and date(Date) = date(@Current_Datetime)
						and MCC_Id = Var_MCC_Id
                        and Mlk_Type = Var_Milk_Type_Id;
                    
                    
                    else
                    
						select Quantity,Fat,Snf 
						into @var_Quantity,@var_Fat,@var_Snf 
						from t105_mcc_collection_stock_offline
						where Org_Id = var_Org_Id
						and MCC_Id = var_MCC_Id
                        and Mlk_Type = Var_Milk_Type_Id
						order by Date desc limit 1;
                        
                        if(@var_Quantity is null or @var_Quantity = '') then
                            set @var_Quantity = 0;
                            set @var_Quantity = @var_Quantity + var_Milk_Quantity;
                        else
                            set @var_Quantity = @var_Quantity + var_Milk_Quantity;
                        end if;
                        
                        if(@var_Fat is null or @var_Fat = '') then
                            set @var_Fat = 0;
                            set @var_Fat = @var_Fat + var_Milk_FAT;
                        else
                            set @var_Fat = ( @var_Fat + var_Milk_FAT ) / 2;
                        end if;
                        
                        if(@var_Snf is null or @var_Snf = '') then
                            set @var_Snf = 0;
                            set @var_Snf = @var_Snf + var_Milk_SNF;
                        else
                            set @var_Snf = ( @var_Snf + var_Milk_SNF ) / 2;
                        end if;

                    
						insert into t105_mcc_collection_stock_offline (
						Org_Id,MCC_Id,Mlk_Type,Date,Quantity,Fat,Snf
						)
						value(
                        var_Org_Id,var_MCC_Id,Var_Milk_Type_Id,date(@Current_Datetime),@var_Quantity ,
                        @var_Fat,@var_Snf
                        );
                        
                     
					end if;

					

					select 3 as Result_Id,  'Milk Collected' as Result_Description, '' as Result_Extra_Key;  

				end if ;
			end if ;
		end if ;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
