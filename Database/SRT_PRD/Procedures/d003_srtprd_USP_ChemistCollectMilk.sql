-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_ChemistCollectMilk` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_ChemistCollectMilk`(
Var_Method_Name varchar(30),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Trip_Id varchar(20),
Var_MilkStatus_Id varchar(20),
Var_Profile_Id varchar(20),
Var_Vehicle_No Varchar(20),
Var_ChemistCollection_Id Varchar(20),
Var_XMLData longtext ,
Var_CompartmentXMLData longtext,
Var_FilePath longtext 
)
proc_Exit: BEGIN

		set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
		SET SQL_SAFE_UPDATES = 0;
		set sql_mode = '';
        
        
	if(Var_Method_Name = 'CollectMilk') then 
    
    set @MCCWorkType_Id = (select MCCWorkType_Id from m005_mcc 
						WHERE Org_Id = Var_Org_Id 
						AND  MCC_Id = Var_MCC_Id limit 1);
                        
	set @MCCType_Id = (select MCCType_Id from m005_mcc 
						WHERE Org_Id = Var_Org_Id 
						AND  MCC_Id = Var_MCC_Id limit 1);
                        
	
    
	if(@MCCWorkType_Id = 'C023001')then
    
    
		set @set_MCCCollectionShift_Id = (select MCCCollectionShift_Id from t102_mcccollectionshift_offline
									where Org_Id = Var_Org_Id
									and MCC_Id = Var_MCC_Id
									order by Collection_Date desc
									limit 1);
			
		set @setDriver_Id = (select Driver_Id from t021_tripdocument_header where Org_Id = Var_Org_Id and TripDocument_Id = Var_Trip_Id limit 1);

			
			Call USP_AgentMilkDispatch (
			'MilkDispatchOfflineNew' ,
			Var_Org_Id ,
			Var_MCC_Id ,
			@set_MCCCollectionShift_Id ,
			Var_Profile_Id ,
			@setDriver_Id ,
			Var_MilkStatus_Id ,
			'0' ,
			'0' ,
			'0' ,
			'0'  ,
			'' ,
			Var_XMLData  ,
			Var_Trip_Id ,
			'' 
			);
            
    end if;
    
   
	set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = Var_Org_Id);
    
    set @Collection_Date = (select Collection_Date from t102_mcccollectionshift_offline
									where Org_Id = Var_Org_Id
									and MCC_Id = Var_MCC_Id
									order by Collection_Date desc
									limit 1);
                               
    
	if(@Collection_Date is null or @Collection_Date = '')then
    
		set @MCCCollectionShift_Id = ( SELECT MCCCollectionShift_Id FROM t004_mcccollectionshift 
		WHERE Org_Id = Var_Org_Id AND  MCC_Id = Var_MCC_Id and Is_Active = 1
		order by Collection_Date desc LIMIT 1 );
		
    else 
    
		set @MCCCollectionShift_Id = ( SELECT MCCCollectionShift_Id FROM t004_mcccollectionshift 
		WHERE Org_Id = Var_Org_Id AND  MCC_Id = Var_MCC_Id and Is_Active = 1
		and date(Collection_Date) = date(@Collection_Date)
		order by Collection_Date desc LIMIT 1 );
    
    end if;
    
    
	
    
		if(@MCCCollectionShift_Id is null ) then 
        
				SELECT -1 AS Result_Id, 
                'MCC Collection Not Availble' AS Result_Description, 
                '' AS Result_Extra_Key;
                
        else
        
			set @TotalQuantityCow = 0;
			set @TotalMilkQuantityCow =  ( select Quantity from f009_mcc_collection 
            where  MCCCollectionShift_Id = @MCCCollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011001' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
		

			set @TotalQuantityBuffalo = 0;
            set @TotalMilkQuantityBuffalo  = (select Quantity from f009_mcc_collection 
            where  MCCCollectionShift_Id = @MCCCollectionShift_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = 'C011002' and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
       if exists (select 1 from t008_milkcollectionchemist where Org_Id = Var_Org_Id and Trip_Id =  Var_Trip_Id and MCC_Id =  Var_MCC_Id and  Is_BMC_Accepted <> 1) then 
       
       update t008_milkcollectionchemist
		set MCCCollectionShift_Id = @MCCCollectionShift_Id 
        where Org_Id = Var_Org_Id and Trip_Id =  Var_Trip_Id and MCC_Id =  Var_MCC_Id;
        
       set @ChemistCollection_Id = (select ChemistCollection_Id from t008_milkcollectionchemist where Org_Id = Var_Org_Id and Trip_Id =  Var_Trip_Id 
	-- and MCCCollectionShift_Id =  @MCCCollectionShift_Id 
       and MCC_Id = Var_MCC_Id );
       
		
        set @CollectionShift_Id = (select CollectionShift_Id from t004_mcccollectionshift 
        where MCCCollectionShift_Id =  @MCCCollectionShift_Id );
                   
       delete from t008_milkcollectionchemist_item where Org_Id = Var_Org_Id  and ChemistCollection_Id = @ChemistCollection_Id;

        SET @row_counts = 0;
  			SET @row_counts := extractValue(var_XMLData,'count(//D/R)');
			Set @k = 0;
		
			WHILE @k < @row_counts DO        
				SET @k = @k + 1;
				SET @xpath = concat('//D/R[', @k, ']');
                
                set @TotalQuantity = 0;
			set @TotalQuantity =  ( select Quantity from f009_mcc_collection 
            where MCC_Id = Var_MCC_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = extractValue(var_XMLData, concat(@xpath,'/milktype'))
            and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            
            -- for validation high fat & snf 
            Set @ChartId = ( select Chart_Id from f002_milk_rate_current where Header_Applicable_Date <= now() and 
			MCC_Id = Var_MCC_Id  and CollectionShift_Id =  @CollectionShift_Id 
			and MilkType_Id = extractValue(var_XMLData, concat(@xpath,'/milktype'))
			order by Header_Applicable_Date desc limit 1 );
            
            
           set @Slab_Minfat = ( select min(Slab_Min) from m014_slab where Slab_Id in (select Slab_Id from f002_milk_rate_current 
							where Chart_Id = @ChartId and MilkRateEntryType_Id = 'C012002' )) ; 
            
            set @Slab_Maxfat = ( select max(Slab_Min) from m014_slab where Slab_Id in (select Slab_Id from f002_milk_rate_current 
							where Chart_Id = @ChartId and MilkRateEntryType_Id ='C012004')) ; 
            

			set @Slab_MinSnf = ( select min(Slab_Min) from m014_slab where Slab_Id in (select Slab_Id from f002_milk_rate_current 
			where Chart_Id = @ChartId and MilkRateEntryType_Id = 'C012003' )) ; 

			set @Slab_MaxSnf = ( select max(Slab_Min) from m014_slab where Slab_Id in (select Slab_Id from f002_milk_rate_current 
			where Chart_Id = @ChartId and MilkRateEntryType_Id ='C012005')) ; 
        
			
		
			if(@MCCType_Id <> 'C014003') then
            
            
            IF( @TotalQuantity - (extractValue(var_XMLData, concat(@xpath,'/quantity'))) < - 10) THEN 
				
				SELECT -1 AS Result_Id, 'Collection Too High' AS Result_Description, '' AS Result_Extra_Key;
			
				LEAVE proc_Exit;
            
            elseif ((extractValue(var_XMLData, concat(@xpath,'/quantity')) <> 0  and ( @Slab_Minfat > extractValue(var_XMLData, concat(@xpath,'/FAT')) 
					or @Slab_Maxfat < extractValue(var_XMLData, concat(@xpath,'/FAT')) or 
                    @Slab_MinSnf > extractValue(var_XMLData, concat(@xpath,'/SNF')) 
					or @Slab_MaxSnf < extractValue(var_XMLData, concat(@xpath,'/SNF'))
                    
            ))) then 
            
					SELECT -1 AS Result_Id, 'Quality Not Correct' AS Result_Description, '' AS Result_Extra_Key;
			
            LEAVE proc_Exit;
            
            end if ;
            
            end if ;
            
            
				INSERT INTO t008_milkcollectionchemist_item (Org_Id, ChemistCollection_Id, MilkType_Id, Quantity_Ltr, Quantity_Kg, FAT, SNF, Milk_Alcohol, Milk_Temparature, Milk_Acidity, Comartment, Is_OrganolepticTest_Done, MilkStatus_Id) VALUES (
					Var_Org_Id,
					@ChemistCollection_Id,
					extractValue(var_XMLData, concat(@xpath,'/milktype')),
					Roundoff('Quantity' , ( extractValue(var_XMLData, concat(@xpath,'/quantity'))))  ,
					Roundoff('Quantity' , extractValue(var_XMLData, concat(@xpath,'/quantity'))/ @kg_to_ltr) ,
                    extractValue(var_XMLData, concat(@xpath,'/FAT')),
                    extractValue(var_XMLData, concat(@xpath,'/SNF')),
                    extractValue(var_XMLData, concat(@xpath,'/alcohol')),
                    extractValue(var_XMLData, concat(@xpath,'/temparature')),
                    extractValue(var_XMLData, concat(@xpath,'/acidity')),
					extractValue(var_XMLData, concat(@xpath,'/compartment')),
                    extractValue(var_XMLData, concat(@xpath,'/organoleptic')),
                   Var_MilkStatus_Id
				);
			END WHILE;
            
            
			delete from t008_milkcollectionchemist_compartment where Org_Id = Var_Org_Id  and MCC_Id = Var_MCC_Id
            and ChemistCollection_Id = @ChemistCollection_Id;
            
            
            
			set @Vehicle_Id = (select Vehicle_Id from t021_tripdocument_header t021 where
			Org_Id = Var_Org_Id and TripDocument_Id = Var_Trip_Id limit 1);

			SET @rows_count = 0;
  			SET @rows_count := extractValue(Var_CompartmentXMLData,'count(//D/R)');
			Set @L = 0;
			WHILE @L < @rows_count DO        
				SET @L = @L + 1;
				SET @xpath1 = concat('//D/R[', @L, ']');
				INSERT INTO t008_milkcollectionchemist_compartment (Org_Id, ChemistCollection_Id, MilkType_Id, Compartment_No, MCC_Id, Quantity_Kg, Quantity_Ltr, Vehicle_Id)
                VALUES (
					Var_Org_Id,
					@ChemistCollection_Id,
					extractValue(Var_CompartmentXMLData, concat(@xpath1,'/milktype')),
                    extractValue(Var_CompartmentXMLData, concat(@xpath1,'/compartment')),
                    Var_MCC_Id,
                    Roundoff('Quantity' , extractValue(Var_CompartmentXMLData, concat(@xpath1,'/quantity'))/ @kg_to_ltr ) ,
					Roundoff('Quantity' , ( extractValue(Var_CompartmentXMLData, concat(@xpath1,'/quantity')))) ,
                    @Vehicle_Id
				);

            
			END WHILE;
            
              delete from t008_milkcollectionchemist_item where Org_Id = Var_Org_Id and (Quantity_Ltr = 0.0 or Quantity_Kg = 0.0 or
                FAT = 0 or SNF = 0 ) and ChemistCollection_Id = @ChemistCollection_Id;
				
                
                	SELECT 1 AS Result_Id, 
                'Collection Updated' AS Result_Description, 
                '' AS Result_Extra_Key;
		
       
       elseif exists (select 1 from t008_milkcollectionchemist where Org_Id = Var_Org_Id and Trip_Id =  Var_Trip_Id and MCCCollectionShift_Id =  @MCCCollectionShift_Id and  Is_BMC_Accepted = 1)then 

				SELECT -1 AS Result_Id, 
                'Already Collected' AS Result_Description, 
                '' AS Result_Extra_Key;
		
        else
        
        
    
			set @Driver_Id = (select Driver_Id from t021_tripdocument_header t021 where
			Org_Id = Var_Org_Id and TripDocument_Id = Var_Trip_Id limit 1);

			set @Year_Id = (select right(left(curdate(),4),(2)));
			set @ChemistCollection_Id  = '';
			Call USP_Number_Range ('t008_milkcollectionchemist', @Year_Id, 'T008', '', @ChemistCollection_Id );

			insert into t008_milkcollectionchemist (Org_Id ,ChemistCollection_Id, Trip_Id,Chemist_Id, MCC_Id ,Driver_Id , MCCCollectionShift_Id,
			 Is_Active , Created_On , CreatedBy_Id ) values 
			(Var_Org_Id,@ChemistCollection_Id, Var_Trip_Id ,Var_Profile_Id, Var_MCC_Id ,@Driver_Id, @MCCCollectionShift_Id, 1 , @Current_Datetime, Var_Profile_Id);

			set @Vehicle_Id = (select Vehicle_Id from t021_tripdocument_header t021 where
			Org_Id = Var_Org_Id and TripDocument_Id = Var_Trip_Id limit 1);

        SET @row_counts = 0;
  			SET @row_counts := extractValue(var_XMLData,'count(//D/R)');
			Set @k = 0;
			WHILE @k < @row_counts DO        
				SET @k = @k + 1;
				SET @xpath = concat('//D/R[', @k, ']');
                
			set @TotalQuantity = 0;
			set @TotalQuantity =  ( select Quantity from f009_mcc_collection 
            where MCC_Id = Var_MCC_Id and 
			Org_Id = Var_Org_Id AND Mlk_Type = extractValue(var_XMLData, concat(@xpath,'/milktype'))
            and Entry_Type in ('Closing Bal' , 'Collection 1' , 'Collection 2') 
            order by Date desc limit 1 );
            
            Set @ChartId = ( select Chart_Id from f002_milk_rate_current where Header_Applicable_Date <= now() and 
			MCC_Id = Var_MCC_Id  and CollectionShift_Id =  @CollectionShift_Id 
			and MilkType_Id = extractValue(var_XMLData, concat(@xpath,'/milktype'))
			order by Header_Applicable_Date desc limit 1 );
            
            
           set @Slab_Minfat = ( select min(Slab_Min) from m014_slab where Slab_Id in (select Slab_Id from f002_milk_rate_current 
							where Chart_Id = @ChartId and MilkRateEntryType_Id = 'C012002' )) ; 
            
            set @Slab_Maxfat = ( select max(Slab_Min) from m014_slab where Slab_Id in (select Slab_Id from f002_milk_rate_current 
							where Chart_Id = @ChartId and MilkRateEntryType_Id ='C012004')) ; 
            

			set @Slab_MinSnf = ( select min(Slab_Min) from m014_slab where Slab_Id in (select Slab_Id from f002_milk_rate_current 
			where Chart_Id = @ChartId and MilkRateEntryType_Id = 'C012003' )) ; 

			set @Slab_MaxSnf = ( select max(Slab_Min) from m014_slab where Slab_Id in (select Slab_Id from f002_milk_rate_current 
			where Chart_Id = @ChartId and MilkRateEntryType_Id ='C012005')) ; 
            
		
			
            if(@MCCType_Id <> 'C014003') then
            
            IF( @TotalQuantity - (extractValue(var_XMLData, concat(@xpath,'/quantity'))) < - 10) THEN 
				
				SELECT -1 AS Result_Id, 'Collection Too High' AS Result_Description, '' AS Result_Extra_Key;
			
				LEAVE proc_Exit;
            
            elseif ((extractValue(var_XMLData, concat(@xpath,'/quantity')) <> 0  and ( @Slab_Minfat > extractValue(var_XMLData, concat(@xpath,'/FAT')) 
					or @Slab_Maxfat < extractValue(var_XMLData, concat(@xpath,'/FAT')) or 
                    @Slab_MinSnf > extractValue(var_XMLData, concat(@xpath,'/SNF')) 
					or @Slab_MaxSnf < extractValue(var_XMLData, concat(@xpath,'/SNF'))
                    
            ))) then 
            
					SELECT -1 AS Result_Id, 'Quality Not Correct' AS Result_Description, '' AS Result_Extra_Key;
			
            LEAVE proc_Exit;
            
            end if ;
            end if;
			
				INSERT INTO t008_milkcollectionchemist_item (Org_Id, ChemistCollection_Id, MilkType_Id, Quantity_Ltr, Quantity_Kg, FAT, SNF, Milk_Alcohol, Milk_Temparature, Milk_Acidity, Comartment, Is_OrganolepticTest_Done, MilkStatus_Id)
                VALUES (
					Var_Org_Id,
					@ChemistCollection_Id,
					extractValue(var_XMLData, concat(@xpath,'/milktype')),
					Roundoff('Quantity' , ( extractValue(var_XMLData, concat(@xpath,'/quantity'))))  ,
					Roundoff('Quantity' , extractValue(var_XMLData, concat(@xpath,'/quantity'))/ @kg_to_ltr) ,
                    extractValue(var_XMLData, concat(@xpath,'/FAT')),
                    extractValue(var_XMLData, concat(@xpath,'/SNF')),
                    extractValue(var_XMLData, concat(@xpath,'/alcohol')),
                    extractValue(var_XMLData, concat(@xpath,'/temparature')),
                    extractValue(var_XMLData, concat(@xpath,'/acidity')),
					extractValue(var_XMLData, concat(@xpath,'/compartment')),
                    extractValue(var_XMLData, concat(@xpath,'/organoleptic')),
                   Var_MilkStatus_Id
				);
			
			END WHILE;
            
            
            delete from t008_milkcollectionchemist_compartment where Org_Id = Var_Org_Id  and MCC_Id = Var_MCC_Id
            and ChemistCollection_Id = @ChemistCollection_Id;

			SET @rows_count = 0;
  			SET @rows_count := extractValue(Var_CompartmentXMLData,'count(//D/R)');
			Set @L = 0;
			WHILE @L < @rows_count DO        
				SET @L = @L + 1;
				SET @xpath1 = concat('//D/R[', @L, ']');
				INSERT INTO t008_milkcollectionchemist_compartment (Org_Id, ChemistCollection_Id, MilkType_Id, Compartment_No, MCC_Id, Quantity_Kg, Quantity_Ltr , Vehicle_Id)
                VALUES (
					Var_Org_Id,
					@ChemistCollection_Id,
					extractValue(Var_CompartmentXMLData, concat(@xpath1,'/milktype')),
                    extractValue(Var_CompartmentXMLData, concat(@xpath1,'/compartment')),
                    Var_MCC_Id,
                    Roundoff('Quantity' , extractValue(Var_CompartmentXMLData, concat(@xpath1,'/quantity'))/ @kg_to_ltr ) ,
					Roundoff('Quantity' , ( extractValue(Var_CompartmentXMLData, concat(@xpath1,'/quantity')))) ,
                    @Vehicle_Id
				);
            
            	END WHILE;
                

			delete from t008_milkcollectionchemist_item where Org_Id = Var_Org_Id and (Quantity_Ltr = 0.0 or Quantity_Kg = 0.0 or
			FAT = 0 or SNF = 0 ) and ChemistCollection_Id = @ChemistCollection_Id;
        
                        
	SELECT 1 AS Result_Id, 'Milk Collected' AS Result_Description, '' AS Result_Extra_Key;
        
	end if;
    
    	end if;
      
        
	elseif (Var_Method_Name = 'GetCellCapacity') then 
    
		set @Vehicle_Id = (select Vehicle_Id from t021_tripdocument_header where TripDocument_Id = Var_Trip_Id
        and Org_Id = Var_Org_Id limit 1 ) ;
    
		/*
		select Compartment_No ,  m003.Capacity_Ltr as Capacity , sum(t008c.Quantity_Ltr) as filledQty
		from t008_milkcollectionchemist_compartment t008c
		inner join t008_milkcollectionchemist t008 on t008c.ChemistCollection_Id = t008.ChemistCollection_Id 
		inner join m003_vehiclecapacity m003 on m003.Vehicle_id = t008c.Vehicle_id and m003.Cell_No  = t008c.Compartment_No 
		where t008.Trip_Id = Var_Trip_Id
		group by Compartment_No ;
        
        */
                
     
		select Cell_No as Compartment_No , m003.Capacity_Ltr as Capacity ,  
        IF(Cell.Is_BMC_Accepted = 0 , ifnull(Filledcell.filledQty, 0) - Cell.filledQty , ifnull(Filledcell.filledQty, 0) ) as filledQty , 
        Cell.Is_BMC_Accepted
        from m003_vehiclecapacity m003 
        left join (
		select Compartment_No , sum(Quantity_Ltr ) as filledQty , Is_BMC_Accepted
        from t008_milkcollectionchemist_compartment t008c
		left join t008_milkcollectionchemist t008 on t008c.ChemistCollection_Id = t008.ChemistCollection_Id 
		where t008c.Vehicle_Id =  @Vehicle_Id  and Trip_Id = Var_Trip_Id
        group by Compartment_No
        ) Filledcell on Filledcell.Compartment_No = m003.Cell_No
        left join (select Compartment_No , sum(Quantity_Ltr ) as filledQty , Is_BMC_Accepted
        from t008_milkcollectionchemist_compartment t008c
		left join t008_milkcollectionchemist t008 on t008c.ChemistCollection_Id = t008.ChemistCollection_Id 
		where t008c.Vehicle_Id =  @Vehicle_Id  and Trip_Id = Var_Trip_Id  and t008c.MCC_Id = Var_MCC_Id
        group by Compartment_No ) Cell ON Cell.Compartment_No = Filledcell.Compartment_No
		where m003.Vehicle_Id = @Vehicle_Id  and m003.Org_Id = Var_Org_Id;
        
        
        /*
		select Cell_No as Compartment_No , m003.Capacity_Ltr as Capacity ,  
        ifnull(Filledcell.filledQty, 0) as filledQty
        from m003_vehiclecapacity m003 
        left join (
		select Compartment_No , sum(Quantity_Ltr ) as filledQty , Is_BMC_Accepted
        from t008_milkcollectionchemist_compartment t008c
		left join t008_milkcollectionchemist t008 on t008c.ChemistCollection_Id = t008.ChemistCollection_Id 
		where t008c.Vehicle_Id =  @Vehicle_Id  and Trip_Id = Var_Trip_Id
        group by Compartment_No
        ) Filledcell on Filledcell.Compartment_No = m003.Cell_No
		where m003.Vehicle_Id = @Vehicle_Id  and m003.Org_Id = Var_Org_Id;
        
        */
        
        
        end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
