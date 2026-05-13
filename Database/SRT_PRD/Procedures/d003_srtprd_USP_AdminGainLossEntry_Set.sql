-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminGainLossEntry_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminGainLossEntry_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_MilkCollectionDairy_Id varchar(20),
    var_MCCGRN longtext,
    var_User_Id varchar(20),
	var_User_Name varchar(45)
)
BEGIN
SET SESSION sql_require_primary_key = 0;
SET SQL_SAFE_UPDATES = 0;
SET @kg_to_ltr = (SELECT Kg_To_Ltr_Dairy FROM c001_organization WHERE Org_Id = var_Org_Id);
Set @CollectionShift_Id = (select m006.CollectionShift_Id from t009_milkcollectiondairy_header t009
							inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
								and t021.TripDocument_Id = t009.TripDocument_Id
							inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id 
								and t021.Route_Trip_Id = m008.Entry_Id
							inner join m006_route m006 on m006.Org_Id = m008.Org_Id 
								and m006.Route_Id = m008.Route_Id
							where 
							t009.Org_Id = var_Org_Id
							and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1);
                            
Set @Created_On = (select date(Created_On) from t009_milkcollectiondairy_header
							where 
							Org_Id = var_Org_Id
							and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1);
                            
                            
	set @kg_to_ltr = (select Kg_To_Ltr_Agent from c001_organization where Org_Id = 'C005') ;
	 
	DROP TEMPORARY TABLE IF EXISTS temp_Report;

	CREATE TEMPORARY TABLE temp_Report ( 
	Org_Id varchar(20), MCCCollectionShift_Id varchar(20), 
	MCC_Id varchar(20),Collection_Date datetime);

	insert into temp_Report (Org_Id,MCCCollectionShift_Id,MCC_Id,Collection_Date)
	select Org_Id,MCCCollectionShift_Id,MCC_Id,Collection_Date 
	from t004_mcccollectionshift 
	where 
	Org_Id = var_Org_Id
	-- and MCC_Id ='M005241000077'
    and MCC_Id in ( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 )
    and MCC_Id in ( 
					select MCC_Id from t022_tripdocument_item where Org_Id = var_Org_Id
					and TripDocument_Id in (
					select TripDocument_Id from t009_milkcollectiondairy_header 
					where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					))
	and date(Collection_Date) <= date(@Created_On)
	and MCCCollectionShift_Id in (select MCCCollectionShift_Id 
									from t006_milkcollectionagent
									where 
									Org_Id = var_Org_Id
									-- and MCC_Id ='M005241000077'
                                    and MCC_Id in ( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 )
									and MCC_Id in ( 
													select MCC_Id from t022_tripdocument_item where Org_Id = var_Org_Id
													and TripDocument_Id in (
													select TripDocument_Id from t009_milkcollectiondairy_header 
													where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
													)))
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
	-- and t004.MCC_Id ='M005241000077'
    and t004.MCC_Id in ( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 )
    and t004.MCC_Id in ( 
					select MCC_Id from t022_tripdocument_item where Org_Id = var_Org_Id
					and TripDocument_Id in (
					select TripDocument_Id from t009_milkcollectiondairy_header 
					where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					))
	and REPLACE(MCCCollectionShift_Id, 'T004', '')  <= REPLACE(@MCCCollectionShift_Id_1, 'T004', '')
	and REPLACE(MCCCollectionShift_Id, 'T004', '')  > REPLACE(@MCCCollectionShift_Id_2, 'T004', '')
	order by Collection_Date  desc;


	select 
	Roundoff('Quantity', sum(Quantity_Ltr / @kg_to_ltr ))  as Agent_Quantity_Kg,
	Roundoff('QuantityForDairy',  sum(Quantity_Ltr)) as Agent_Quantity_Ltr,
	Roundoff('Quality', (sum(Quantity_Ltr * Fat))/sum(Quantity_Ltr)) as Agent_Fat,
	Roundoff('Quality', (sum(Quantity_Ltr * SNF))/sum(Quantity_Ltr))  as Agent_SNF
	into 
	@Set_Agent_Quantity_Kg,
	@Set_Agent_Quantity_Ltr,
	@Set_Agent_Fat,
	@Set_Agent_SNF
	from t005_milkcollectionfarmer
	where 
	Org_Id = var_Org_Id
	-- and MCC_Id ='M005241000077'
    and MCC_Id in ( select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1 )
    and MCC_Id in ( 
					select MCC_Id from t022_tripdocument_item where Org_Id = var_Org_Id
					and TripDocument_Id in (
					select TripDocument_Id from t009_milkcollectiondairy_header 
					where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					))
	and MilkStatus_Id = 'C016001'
	and MCCCollectionShift_Id in (select MCCCollectionShift_Id from temp_Report_Main);
                            
                            
	DROP TEMPORARY TABLE IF EXISTS temp_anamat;
		CREATE TEMPORARY TABLE temp_anamat ( 
		Org_Id varchar(20), MCC_Id varchar(20), Max_Applicable_Date varchar(20));
		
		Insert into temp_anamat (
		Org_Id,MCC_Id,Max_Applicable_Date
		)
		SELECT 
			 Org_Id,
			 MCC_Id,
			 MAX(Applicable_Date) AS Max_Applicable_Date
		 FROM 
			 m005_mcc_version
		 WHERE 
			 Org_Id = var_Org_Id
             and Is_Active = 1
			 -- AND Anamat_Applicable_To = 'MCC'
			 AND Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
		 GROUP BY 
			 Org_Id, MCC_Id;
             
		DROP TEMPORARY TABLE IF EXISTS temp_freight;
		CREATE TEMPORARY TABLE temp_freight ( 
		Org_Id varchar(20), MCC_Id varchar(20), Max_Applicable_Date varchar(20));
		
		Insert into temp_freight (
		Org_Id,MCC_Id,Max_Applicable_Date
		)
		SELECT 
			 Org_Id,
			 MCC_Id,
			 MAX(Applicable_Date) AS Max_Applicable_Date
		 FROM 
			 m005_mcc_version
		 WHERE 
			 Org_Id = var_Org_Id
             and Is_Active = 1
			 -- AND Freight_Applicable_To = 'MCC'
			 AND Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
		 GROUP BY 
			 Org_Id, MCC_Id;
             

    if (var_Method_Name = 'Update') then
		begin
			declare var_Created_On varchar(50);
            declare var_BaseFat decimal(10,2);
            declare var_BaseSNF decimal(10,2);
            declare var_BaseRate decimal(20,2);
            declare var_RatioFat decimal(10,2);
            declare var_RatioSNF decimal(10,2);
            
            set var_Created_On = (
				select Created_On from t009_milkcollectiondairy_header where 
									Org_Id = var_Org_Id 
									and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
                                    
			SELECT Fat,SNF into var_RatioFat,var_RatioSNF  FROM t024_fatsnf_ratio 
				where Ratio_Date <= now() 
				and Org_Id = var_Org_Id
				and Is_Active = 1
				and Is_Deleted = 0
				order by Ratio_Date DESC Limit 1;
            
			
                                
			SET @row_count := extractValue(var_MCCGRN,'count(//MCC_GRN/GRN)');
			 set @kg_to_ltr = (select Kg_To_Ltr_Dairy from c001_organization where Org_Id = Var_Org_Id) ;
			Set @k := 0;
			WHILE @k < @row_count DO        
				SET @k := @k + 1;
				SET @xpath := concat('//MCC_GRN/GRN[', @k, ']');
                
                /*set @var_Chart_Id =  GetMilkBaseRate(
								var_Org_Id,extractValue(var_MCCGRN, concat(@xpath,'/MCC_Id')),
								'', var_Created_On,extractValue(var_MCCGRN, concat(@xpath,'/MilkType_Id')));
							*/
				set @var_Chart_Id =  GetMilkBaseRate(
								var_Org_Id,extractValue(var_MCCGRN, concat(@xpath,'/MCC_Id')),
								'', now(),extractValue(var_MCCGRN, concat(@xpath,'/MilkType_Id')));
                                
				
                select BaseFat,BaseSNF,Amount into var_BaseFat,var_BaseSNF,var_BaseRate
                from m001_milkrate_item where Org_Id = var_Org_Id
                and Chart_Id = @var_Chart_Id
				and MilkRateEntryType_Id ='C012001'
				-- and Applicable_Date <= var_Created_On
                and Applicable_Date <= now()
				order by Applicable_Date desc limit 1;
                
                UPDATE  t008_milkcollectionchemist_compartment 
                SET 
                Final_Quantity_Kg = extractValue(var_MCCGRN, concat(@xpath,'/Liters')) / @kg_to_ltr ,
                Final_Quantity_Ltr = extractValue(var_MCCGRN, concat(@xpath,'/Liters')),
                Final_Fat = extractValue(var_MCCGRN, concat(@xpath,'/FAT')),
                Final_SNF = extractValue(var_MCCGRN, concat(@xpath,'/SNF')),
                
                Final_Protein = extractValue(var_MCCGRN, concat(@xpath,'/Protein')),
                Final_Ash = extractValue(var_MCCGRN, concat(@xpath,'/Ash')),
                Final_Sodium = extractValue(var_MCCGRN, concat(@xpath,'/Sodium')),
                
                Is_Sour = extractValue(var_MCCGRN, concat(@xpath,'/Is_Sour')),
                Sour_Compartment_GRN_Flag = extractValue(var_MCCGRN, concat(@xpath,'/Is_GRN')),
                Sour_Compartment_Adjustment_Flag = extractValue(var_MCCGRN, concat(@xpath,'/Is_Adjustment')),
                
                FatKG_Agent = extractValue(var_MCCGRN, concat(@xpath,'/FatKG_Agent')),
                SNFKG_Agent = extractValue(var_MCCGRN, concat(@xpath,'/FatSNF_Agent'))
                WHERE ChemistCollection_Id = extractValue(var_MCCGRN, concat(@xpath,'/Chemistcollection_Id'))
                AND MCC_Id = extractValue(var_MCCGRN, concat(@xpath,'/MCC_Id'))
				AND MilkType_Id = extractValue(var_MCCGRN, concat(@xpath,'/MilkType_Id'))
                AND Compartment_No = extractValue(var_MCCGRN, concat(@xpath,'/Cell_No'));
                
               
				UPDATE  t008_milkcollectionchemist_compartment t008
                SET 
                t008.FatKG_Dairy = ((t008.Final_Quantity_Kg * t008.Final_Fat) /100),
                t008.SNFKG_Dairy = ((t008.Final_Quantity_Kg * t008.Final_SNF) /100)
                WHERE t008.ChemistCollection_Id = extractValue(var_MCCGRN, concat(@xpath,'/Chemistcollection_Id'))
                AND t008.MCC_Id = extractValue(var_MCCGRN, concat(@xpath,'/MCC_Id'))
				AND t008.MilkType_Id = extractValue(var_MCCGRN, concat(@xpath,'/MilkType_Id'))
                AND t008.Compartment_No = extractValue(var_MCCGRN, concat(@xpath,'/Cell_No'));
                
                
                select 
                sum(t0081.FatKG_Dairy) , sum(t0081.SNFKG_Dairy) 
                into @var_FatKG_Dairy , @var_SNFKG_Dairy
                from t009_milkcollectiondairy_header t009
				inner join t022_tripdocument_item t022 on t009.Org_Id = t022.Org_Id 
					and t009.TripDocument_Id = t022.TripDocument_Id
					and t022.MCC_Id = extractValue(var_MCCGRN, concat(@xpath,'/MCC_Id'))
				inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
					and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
				inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
					and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
				where t009.Org_Id = var_Org_Id
				and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                
                
                select 
                t0081.FatKG_Agent,t0081.SNFKG_Agent
                into @var_FatKG_Agent , @var_SNFKG_Agent
                from t009_milkcollectiondairy_header t009
				inner join t022_tripdocument_item t022 on t009.Org_Id = t022.Org_Id 
					and t009.TripDocument_Id = t022.TripDocument_Id
					and t022.MCC_Id = extractValue(var_MCCGRN, concat(@xpath,'/MCC_Id'))
				inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
					and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
				inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
					and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
				where t009.Org_Id = var_Org_Id
				and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1;
		
        
				UPDATE  t008_milkcollectionchemist_compartment t008
                SET 
                t008.FatKG_GainLoss =    @var_FatKG_Dairy - @var_FatKG_Agent,
                t008.SNFKG_GainLoss =    @var_SNFKG_Dairy - @var_SNFKG_Agent
                WHERE t008.ChemistCollection_Id = extractValue(var_MCCGRN, concat(@xpath,'/Chemistcollection_Id'))
                AND t008.MCC_Id = extractValue(var_MCCGRN, concat(@xpath,'/MCC_Id'))
				AND t008.MilkType_Id = extractValue(var_MCCGRN, concat(@xpath,'/MilkType_Id'))
                AND t008.Compartment_No = extractValue(var_MCCGRN, concat(@xpath,'/Cell_No'));
				
                
                UPDATE  t008_milkcollectionchemist_compartment t008
                SET 
                t008.FatKG_Rate = ((var_BaseRate * var_RatioFat ) / var_BaseFat),
                t008.SNFKG_Rate = ((var_BaseRate * var_RatioSNF ) / var_BaseSNF)
                WHERE t008.ChemistCollection_Id = extractValue(var_MCCGRN, concat(@xpath,'/Chemistcollection_Id'))
                AND t008.MCC_Id = extractValue(var_MCCGRN, concat(@xpath,'/MCC_Id'))
				AND t008.MilkType_Id = extractValue(var_MCCGRN, concat(@xpath,'/MilkType_Id'))
                AND t008.Compartment_No = extractValue(var_MCCGRN, concat(@xpath,'/Cell_No'));
                
				 UPDATE  t008_milkcollectionchemist_compartment t008
                SET 
                t008.Total_GainLoss = ((t008.FatKG_GainLoss * t008.FatKG_Rate) + (t008.SNFKG_GainLoss * t008.SNFKG_Rate))
                WHERE t008.ChemistCollection_Id = extractValue(var_MCCGRN, concat(@xpath,'/Chemistcollection_Id'))
                AND t008.MCC_Id = extractValue(var_MCCGRN, concat(@xpath,'/MCC_Id'))
				AND t008.MilkType_Id = extractValue(var_MCCGRN, concat(@xpath,'/MilkType_Id'))
                AND t008.Compartment_No = extractValue(var_MCCGRN, concat(@xpath,'/Cell_No'));
				
                
			END WHILE;
            
            set @TripDocument_Id = (select TripDocument_Id 
									from t009_milkcollectiondairy_header 
									where Org_Id = var_Org_Id
									and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1);
									
			set @Sour_Flag = (select 
								count(*)
								from t008_milkcollectionchemist_compartment 
								where Org_Id = var_Org_Id
								and ChemistCollection_Id in (
								select ChemistCollection_Id 
								from t008_milkcollectionchemist 
								where Org_Id = var_Org_Id
								and Trip_Id = @TripDocument_Id
								and Sour_Compartment_Adjustment_Flag =  1
								));
			
            if(@Sour_Flag <> 0)then
            
				if(@Sour_Flag != null or @Sour_Flag != '')then
					
					DROP TEMPORARY TABLE IF EXISTS temp_Report;
					CREATE TEMPORARY TABLE temp_Report ( 
					Org_Id varchar(20), Compartment_No varchar(20),MCC_Id varchar(20));

					insert into temp_Report (Org_Id,Compartment_No, MCC_Id )
					select 
					Org_Id,Compartment_No, MCC_Id 
					from t008_milkcollectionchemist_compartment 
					where Org_Id = var_Org_Id
					and ChemistCollection_Id in (
					select ChemistCollection_Id 
					from t008_milkcollectionchemist 
					where Org_Id = var_Org_Id
					and Trip_Id = @TripDocument_Id
					and Sour_Compartment_Adjustment_Flag =  1
					);
                    

					Update t008_milkcollectionchemist_compartment t008
					inner join temp_Report tmp on
					tmp.Org_Id = t008.Org_Id
					and tmp.Compartment_No = t008.Compartment_No
					set t008.Sour_Compartment_Adjustment_MCC_Id = tmp.MCC_Id;
					 
				end if;
            end if;
            
            
            
            SELECT 1 AS Result_Id,  
            'Updated' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Create_Truck') then
		begin
        
		DECLARE done INT DEFAULT FALSE;
		DECLARE New_Entry_Id VARCHAR(20);
        declare var_BaseFat decimal(10,2);
		declare var_BaseSNF decimal(10,2);
		declare var_BaseRate decimal(20,2);
		declare var_RatioFat decimal(10,2);
		declare var_RatioSNF decimal(10,2);
        DECLARE Year_Id VARCHAR(20);
		DECLARE Org_Id VARCHAR(10);
		DECLARE MilkCollectionDairy_Id VARCHAR(20);
		DECLARE Created_On DATETIME;
		DECLARE MCC_Id VARCHAR(20);
		DECLARE MilkType_Id VARCHAR(20);
		DECLARE Agent_Quantity_Kg DECIMAL(20, 3);
		DECLARE Agent_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Agent_Fat DECIMAL(8, 2);
		DECLARE Agent_SNF DECIMAL(8, 2);
		DECLARE Dairy_Quantity_Kg DECIMAL(20, 3);
		DECLARE Dairy_Quantity_Ltr DECIMAL(20, 3);
		DECLARE var_Dairy_Fat DECIMAL(8, 2);
		DECLARE Dairy_SNF DECIMAL(8, 2);
        DECLARE var_Dairy_Protein DECIMAL(8, 2);
		DECLARE var_Dairy_Ash DECIMAL(8, 2);
        DECLARE var_Dairy_Sodium DECIMAL(8, 2);
        declare var_MilkRate decimal(8,2);
        declare var_MilkPrice decimal(20,2);
        
        DECLARE cur CURSOR FOR
        -- Your select query here
			
             SELECT 
				t009.Org_Id,
				t009.MilkCollectionDairy_Id, 
				t009.Created_On, 
				t0091.MCC_Id, 
				t0091.MilkType_Id,
                CASE
					WHEN (t0061.Quantity_Ltr / @kg_to_ltr) IS NOT NULL
                    and (t0061.Quantity_Ltr / @kg_to_ltr) <>  '' 
                    and (t0061.Quantity_Ltr / @kg_to_ltr) <> 0 
				THEN   (t0061.Quantity_Ltr / @kg_to_ltr) 
				ELSE Roundoff('Quantity', sum(t0091.Weight)) 
				END as Agent_Quantity_Kg,
                
                CASE
					WHEN t0061.Quantity_Ltr IS NOT NULL
                    and t0061.Quantity_Ltr <> '' 
					and t0061.Quantity_Ltr <> 0
				THEN t0061.Quantity_Ltr
				ELSE Roundoff('QuantityForDairy',  sum(t0091.Liters))
				END as Agent_Quantity_Ltr,
                
                CASE
					WHEN ((t0061.Quantity_Ltr * t0061.Fat)) / (t0061.Quantity_Ltr) IS NOT NULL 
                    and ((t0061.Quantity_Ltr * t0061.Fat)) / (t0061.Quantity_Ltr) <> '' 
                    and ((t0061.Quantity_Ltr * t0061.Fat)) / (t0061.Quantity_Ltr) <> 0
				THEN ((t0061.Quantity_Ltr * t0061.Fat)) / (t0061.Quantity_Ltr)
				ELSE Roundoff('Quality', (sum(t0091.Liters * t0092.Fat)) / sum(t0091.Liters))
				END as Agent_Fat,
                
                CASE
					WHEN ((t0061.Quantity_Ltr * t0061.SNF)) / (t0061.Quantity_Ltr) IS NOT NULL 
                    and ((t0061.Quantity_Ltr * t0061.SNF)) / (t0061.Quantity_Ltr) <> '' 
					and ((t0061.Quantity_Ltr * t0061.SNF)) / (t0061.Quantity_Ltr) <> 0 
				THEN  ((t0061.Quantity_Ltr * t0061.SNF)) / (t0061.Quantity_Ltr) 
				ELSE Roundoff('Quality', (sum(t0091.Liters * t0092.SNF)) / sum(t0091.Liters))
				END as Agent_SNF,
                
                Roundoff('Quantity', sum(t0091.Weight))  as Dairy_Quantity_Kg,
				Roundoff('QuantityForDairy',  sum(t0091.Liters)) as Dairy_Quantity_Ltr,
				Roundoff('Quality', (sum(t0091.Liters * t0092.Fat)) / sum(t0091.Liters)) as var_Dairy_Fat,
				Roundoff('Quality', (sum(t0091.Liters * t0092.SNF)) / sum(t0091.Liters))  as Dairy_SNF,
                Roundoff('Quality', (sum(t0091.Liters * ifnull(t0092.Protein,0))) / sum(t0091.Liters)) as var_Dairy_Protein,
				Roundoff('Quality', (sum(t0091.Liters * ifnull(t0092.Ash,0))) / sum(t0091.Liters))  as var_Dairy_Ash,
                Roundoff('Quality', (sum(t0091.Liters * ifnull(t0092.Sodium,0))) / sum(t0091.Liters))  as var_Dairy_Sodium,
				 CASE
					WHEN if (t0091.MilkType_Id = 'C011001' and t006.Final_Amout_Cow <> 0 , t006.Final_Amout_Cow , 
							if (t0091.MilkType_Id = 'C011002' and t006.Final_Amout_Cow <> 0 , t006.Final_Amout_Buf, 0.00  )  ) IS NOT NULL 
					or if (t0091.MilkType_Id = 'C011001' and t006.Final_Amout_Cow <> 0 , t006.Final_Amout_Cow , 
							if (t0091.MilkType_Id = 'C011002' and t006.Final_Amout_Cow <> 0 , t006.Final_Amout_Buf, 0.00  )  ) <> '' 
					or if (t0091.MilkType_Id = 'C011001' and t006.Final_Amout_Cow <> 0 , t006.Final_Amout_Cow , 
							if (t0091.MilkType_Id = 'C011002' and t006.Final_Amout_Cow <> 0 , t006.Final_Amout_Buf, 0.00  )  ) <> 0 
					THEN  if (t0091.MilkType_Id = 'C011001' and t006.Final_Amout_Cow <> 0 , t006.Final_Amout_Cow , 
							if (t0091.MilkType_Id = 'C011002' and t006.Final_Amout_Cow <> 0 , t006.Final_Amout_Buf, 0.00  )  )
					ELSE  GetMilkRateBackDate(t0091.Org_Id, t0091.MCC_Id, @CollectionShift_Id , 
									Roundoff('Quality', (sum(t0091.Liters * t0092.Fat)) / sum(t0091.Liters)), 
									Roundoff('Quality', (sum(t0091.Liters * t0092.SNF)) / sum(t0091.Liters)), 
									t0091.MilkType_Id,@Created_On)  * Roundoff('QuantityForDairy',  sum(t0091.Liters))
					END as var_MilkPrice,
				CASE
					WHEN if (t0091.MilkType_Id = 'C011001' and t006.Final_Qty_Cow_Ltr <> 0 , t006.Final_Amout_Cow / t006.Final_Qty_Cow_Ltr, 
							if (t0091.MilkType_Id = 'C011002' and t006.Final_Qty_Buf_Ltr <> 0 , t006.Final_Amout_Buf / t006.Final_Qty_Buf_Ltr, 0.00  )  ) IS NOT NULL 
					or if (t0091.MilkType_Id = 'C011001' and t006.Final_Qty_Cow_Ltr <> 0 , t006.Final_Amout_Cow / t006.Final_Qty_Cow_Ltr, 
							if (t0091.MilkType_Id = 'C011002' and t006.Final_Qty_Buf_Ltr <> 0 , t006.Final_Amout_Buf / t006.Final_Qty_Buf_Ltr, 0.00  )  ) <> '' 
					or if (t0091.MilkType_Id = 'C011001' and t006.Final_Qty_Cow_Ltr <> 0 , t006.Final_Amout_Cow / t006.Final_Qty_Cow_Ltr, 
							if (t0091.MilkType_Id = 'C011002' and t006.Final_Qty_Buf_Ltr <> 0 , t006.Final_Amout_Buf / t006.Final_Qty_Buf_Ltr, 0.00  )  ) <> 0 
					THEN  if (t0091.MilkType_Id = 'C011001' and t006.Final_Qty_Cow_Ltr <> 0 , t006.Final_Amout_Cow / t006.Final_Qty_Cow_Ltr, 
							if (t0091.MilkType_Id = 'C011002' and t006.Final_Qty_Buf_Ltr <> 0 , t006.Final_Amout_Buf / t006.Final_Qty_Buf_Ltr, 0.00  )  ) 
					ELSE  GetMilkRateBackDate(t0091.Org_Id, t0091.MCC_Id, @CollectionShift_Id , 
							Roundoff('Quality', (sum(t0091.Liters * t0092.Fat)) / sum(t0091.Liters)), 
							Roundoff('Quality', (sum(t0091.Liters * t0092.SNF)) / sum(t0091.Liters)), 
							t0091.MilkType_Id,@Created_On)
					END as var_MilkRate
			FROM t009_milkcollectiondairy_header t009
			INNER JOIN t009_milkcollectiondairy_quantity t0091 
				ON t009.Org_Id = t0091.Org_Id
				AND t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
				AND t0091.MilkStatus_Id = 'C016001'
			INNER JOIN t009_milkcollectiondairy_quality t0092 
				ON t0092.Org_Id = t0091.Org_Id
				AND t0092.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
                AND t0092.MCC_Id = t0091.MCC_Id
                AND t0092.Batch_Id = t0091.Batch_Id
				AND t0092.MilkStatus_Id = 'C016001'
			INNER JOIN t022_tripdocument_item t022 
				ON t022.Org_Id = t009.Org_Id
				AND t022.TripDocument_Id = t009.TripDocument_Id
			INNER JOIN t006_milkcollectionagent t006 
				ON t022.Org_Id = t006.Org_Id
				AND t022.MCC_CollectionShift_Id = t006.MCCCollectionShift_Id
				AND t022.MCC_Id = t006.MCC_Id
				AND t0091.MCC_Id = t006.MCC_Id
			INNER JOIN t006_milkcollectionagent_item t0061 
				ON t0061.Org_Id = t006.Org_Id
				AND t0061.AgentCollection_Id = t006.AgentCollection_Id
			WHERE t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id =  var_MilkCollectionDairy_Id
			GROUP BY
				t009.Org_Id,
				t009.MilkCollectionDairy_Id, 
				t009.Created_On, 
				t0091.MCC_Id,
				t0091.MilkType_Id,
				t0061.Quantity_Ltr,
				t0061.Fat,
				t0061.SNF,
                t006.Final_Qty_Cow_Ltr,
                t006.Final_Amout_Cow,
                t006.Final_Qty_Buf_Ltr,
                t006.Final_Amout_Buf
                ;
		-- Declare continue handler for cursor
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
        
        
		-- Open cursor
		OPEN cur;
        
		-- Loop to fetch and insert data
		myLoop: LOOP
			-- Fetch data into variables
			FETCH cur INTO Org_Id, MilkCollectionDairy_Id, Created_On, MCC_Id, MilkType_Id,
				Agent_Quantity_Kg, Agent_Quantity_Ltr, Agent_Fat, Agent_SNF,
				Dairy_Quantity_Kg, Dairy_Quantity_Ltr, var_Dairy_Fat, Dairy_SNF,
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium,
                var_MilkPrice,var_MilkRate;

			-- Check if there is no more data
			IF done THEN
				LEAVE myLoop;
			END IF;

			-- Generate a new Entry_Id
			SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
			CALL USP_Number_Range('f010_milkcollectionmcc_final', Year_Id, 'F010', '', New_Entry_Id);

			-- Insert data into the table
			INSERT INTO f010_milkcollectionmcc_final (
				Org_Id, Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Collection_Date, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				Dairy_Fat, Dairy_SNF,MilkPrice,MilkRate,
                Dairy_Protein,Dairy_Ash,Dairy_Sodium
			) VALUES (
				Org_Id, New_Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Created_On, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				var_Dairy_Fat, Dairy_SNF,var_MilkPrice,var_MilkRate,
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium
			);
            
            UPDATE f010_milkcollectionmcc_final f010
			INNER JOIN (
				SELECT 
					t009.Org_Id,
					t009.MilkCollectionDairy_Id,
					t0093.MCC_Id,
					COALESCE(SUM(t0093.Liters), 0) AS Dairy_Sour_Ltr
				FROM 
					t009_milkcollectiondairy_header t009
				INNER JOIN 
					t009_milkcollectiondairy_quantity t0093 ON t009.Org_Id = t0093.Org_Id
															 AND t009.MilkCollectionDairy_Id = t0093.MilkCollectionDairy_Id
															 AND t0093.MilkStatus_Id = 'C016002'
				WHERE 
					t009.Org_Id = Org_Id
					AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				GROUP BY
					t009.Org_Id,
					t009.MilkCollectionDairy_Id,
					t0093.MCC_Id
			) AS sour_liters ON f010.Org_Id = sour_liters.Org_Id
							   AND f010.MilkCollectionDairy_Id = sour_liters.MilkCollectionDairy_Id
							   AND f010.MCC_Id = sour_liters.MCC_Id
			SET 
				f010.Dairy_Sour_Ltr = sour_liters.Dairy_Sour_Ltr;
            
            
            -- set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,@CollectionShift_Id, Created_On,MilkType_Id);
             set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,@CollectionShift_Id, now(),MilkType_Id);
                                
				
			select BaseFat,BaseSNF,Amount into var_BaseFat,var_BaseSNF,var_BaseRate
			from m001_milkrate_item where Org_Id = Org_Id
			and Chart_Id = @var_Chart_Id
			and MilkRateEntryType_Id ='C012001'
            -- and Applicable_Date <= var_Created_On
			and Applicable_Date <= now()
			order by Applicable_Date desc limit 1;
            
            SELECT Fat,SNF into var_RatioFat,var_RatioSNF  FROM t024_fatsnf_ratio 
				where Ratio_Date <= now() 
				and Org_Id = var_Org_Id
				and Is_Active = 1
				and Is_Deleted = 0
				order by Ratio_Date DESC Limit 1;
                
			UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.CollectionShift_Id = @CollectionShift_Id
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            DROP TEMPORARY TABLE IF EXISTS temp_frate;
            
           CREATE TEMPORARY TABLE temp_frate (
				PKeyRowNum int, 
				Org_Id VARCHAR(45),
				MilkCollectionDairy_Id VARCHAR(45),
				MCC_Id VARCHAR(45),
				Entry_Id VARCHAR(45),
				Rate VARCHAR(45)
				);
                
			INSERT INTO temp_frate(
			Org_Id, MilkCollectionDairy_Id, 
			MCC_Id, Entry_Id,Rate
			)
			select f010.Org_Id, f010.MilkCollectionDairy_Id,f010.MCC_Id,f010.Entry_Id,
            GetMilkRateBackDate(f010.Org_Id, f010.MCC_Id, @CollectionShift_Id, f010.Agent_Fat, f010.Agent_SNF, f010.MilkType_Id,@Created_On) as Rate
			from f010_milkcollectionmcc_final  f010
			WHERE f010.Org_Id =  Org_Id
			AND f010.Entry_Id = New_Entry_Id
			AND f010.MilkType_Id = MilkType_Id
			AND (f010.MilkRate in (null , '', 0))
            AND (f010.MilkPrice in (null , '', 0))
            ;
            
            update f010_milkcollectionmcc_final f010 
            inner join temp_frate temp  
			on f010.Org_Id = temp.Org_Id
            and f010.MilkCollectionDairy_Id = temp.MilkCollectionDairy_Id 
            and f010.MCC_Id =  temp.MCC_Id 
            and f010.Entry_Id =  temp.Entry_Id   
			set f010.MilkRate = temp.Rate,
				f010.MilkPrice = (temp.Rate* f010.Agent_Quantity_Ltr)
			WHERE f010.Org_Id =  Org_Id
			AND f010.Entry_Id = New_Entry_Id
			AND f010.MilkType_Id = MilkType_Id
			AND (f010.MilkRate in (null , '', 0))
            AND (f010.MilkPrice in (null , '', 0))
            ;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Agent_Fat_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_Fat) /100),
			f010.Agent_SNF_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_SNF) /100)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Dairy_Fat_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_Fat) /100),
			f010.Dairy_SNF_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_SNF) /100)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.FatKG_GainLoss = (f010.Dairy_Fat_Kg - f010.Agent_Fat_Kg),
			f010.SNFKG_GainLoss = (f010.Dairy_SNF_Kg - f010.Agent_SNF_Kg)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.FatKG_Rate = ((var_BaseRate * var_RatioFat ) / var_BaseFat),
			f010.SNFKG_Rate = ((var_BaseRate * var_RatioSNF ) / var_BaseSNF)
			WHERE f010.Org_Id = Org_Id
            and ifnull(var_BaseFat,0)<> 0
            and ifnull(var_BaseSNF,0)<> 0
			AND f010.Entry_Id = New_Entry_Id;
            
            /*
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Total_GainLoss = ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            */
            
            UPDATE  f010_milkcollectionmcc_final f010
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = f010.Org_Id
				AND m005.MCC_Id = f010.MCC_Id
			SET 
			f010.Total_GainLoss = CASE 
									WHEN m005.MCCWorkType_Id = 'C023001' THEN 0
									ELSE ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
								END
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
            inner join m005_mcc m005
			on m005.Org_Id = f010.Org_Id 
            and m005.MCC_Id = MCC_Id 
			SET 
			f010.Plant_Code = m005.Plant_Code
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            

		END LOOP;

		-- Close cursor
		CLOSE cur;
        
        SELECT 1 AS Result_Id, 
		'Locked' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
			
        end;
	elseif (var_Method_Name = 'Create_Tanker') then
		begin
        
		DECLARE done INT DEFAULT FALSE;
		DECLARE New_Entry_Id VARCHAR(20);
        declare var_BaseFat decimal(10,2);
		declare var_BaseSNF decimal(10,2);
		declare var_BaseRate decimal(20,2);
		declare var_RatioFat decimal(10,2);
		declare var_RatioSNF decimal(10,2);
        DECLARE Year_Id VARCHAR(20);
		DECLARE Set_Org_Id VARCHAR(10);
		DECLARE Set_MilkCollectionDairy_Id VARCHAR(20);
		DECLARE Set_Created_On DATETIME;
		DECLARE Set_MCC_Id VARCHAR(20);
		DECLARE Set_MilkType_Id VARCHAR(20);
		DECLARE Set_Agent_Quantity_Kg DECIMAL(20, 3);
		DECLARE Set_Agent_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Set_Agent_Fat DECIMAL(8, 2);
		DECLARE Set_Agent_SNF DECIMAL(8, 2);
		DECLARE Set_Dairy_Quantity_Kg DECIMAL(20, 3);
		DECLARE Set_Dairy_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Set_Dairy_Fat DECIMAL(8, 2);
		DECLARE Set_Dairy_SNF DECIMAL(8, 2);
        DECLARE Set_var_Dairy_Protein DECIMAL(8, 2);
		DECLARE Set_var_Dairy_Ash DECIMAL(8, 2);
        DECLARE Set_var_Dairy_Sodium DECIMAL(8, 2);
        
        DECLARE cur CURSOR FOR
        -- Your select query here
        
			
			SELECT
			Org_Id as Set_Org_Id,
			MilkCollectionDairy_Id as Set_MilkCollectionDairy_Id,
			Created_On as Set_Created_On,
			MCC_Id as Set_MCC_Id,
			MilkType_Id as Set_MilkType_Id,
			Agent_Quantity_Kg as Set_Agent_Quantity_Kg,
			Agent_Quantity_Ltr as Set_Agent_Quantity_Ltr,
			Agent_Fat as Set_Agent_Fat,
			Agent_SNF as Set_Agent_SNF,
			Roundoff('Quantity', sum(Dairy_Quantity_Kg))  as Set_Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(Dairy_Quantity_Ltr)) as Set_Dairy_Quantity_Ltr ,
			Roundoff('Quality', (sum(Dairy_Quantity_Ltr * Dairy_Fat))/sum(Dairy_Quantity_Ltr)) as Set_Dairy_Fat ,
			Roundoff('Quality', (sum(Dairy_Quantity_Ltr * Dairy_SNF))/sum(Dairy_Quantity_Ltr))  as Set_Dairy_Dairy_SNF ,
			Roundoff('Quality', (sum(Dairy_Quantity_Ltr * var_Dairy_Protein))/sum(Dairy_Quantity_Ltr))  as Set_Dairy_var_Dairy_Protein ,
			Roundoff('Quality', (sum(Dairy_Quantity_Ltr * var_Dairy_Ash))/sum(Dairy_Quantity_Ltr))  as Set_Dairy_var_Dairy_Ash ,
			Roundoff('Quality', (sum(Dairy_Quantity_Ltr * var_Dairy_Sodium))/sum(Dairy_Quantity_Ltr))  as Set_Dairy_var_Dairy_Sodium 
			
            FROM (
            SELECT 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			(t0061.Quantity_Ltr / @kg_to_ltr ) as Agent_Quantity_Kg,
			(t0061.Quantity_Ltr) as Agent_Quantity_Ltr,
			((t0061.Quantity_Ltr * t0061.Fat))/(t0061.Quantity_Ltr)as Agent_Fat,
			((t0061.Quantity_Ltr * t0061.SNF))/(t0061.Quantity_Ltr) as Agent_SNF,
            Roundoff('Quantity', sum(t0081.Final_Quantity_Kg))  as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0081.Final_Quantity_Ltr)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/sum(t0081.Final_Quantity_Ltr)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/sum(t0081.Final_Quantity_Ltr))  as Dairy_SNF,
            
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Protein))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Protein,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Ash))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Ash,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Sodium))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Sodium
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
			and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
			and t021.TripDocument_Id = t022.TripDocument_Id
            and t022.MCC_Id not in (select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1)
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
			and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
            and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
			and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
            and t0081.Is_Sour = '1'
            and t0081.Sour_Compartment_GRN_Flag = '1'
            and t0081.Final_Quantity_Ltr <> 0
            and t0081.Final_Quantity_Kg <> 0
            and t0081.Final_Fat <> 0
            and t0081.Final_SNF <> 0
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
			and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
			and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
			and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
			and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0091.CellNo = t0081.Compartment_No
            AND ifnull(t0091.MilkStatus_Id, '') = 'C016002'
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
			and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0092.CellNo = t0081.Compartment_No
            AND ifnull(t0092.MilkStatus_Id, '') = 'C016002'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF
            
            union all
            
            SELECT 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			@Set_Agent_Quantity_Kg as Agent_Quantity_Kg,
			@Set_Agent_Quantity_Ltr as Agent_Quantity_Ltr,
			@Set_Agent_Fat as Agent_Fat,
			@Set_Agent_SNF as Agent_SNF,
            Roundoff('Quantity', sum(t0081.Final_Quantity_Kg))  as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0081.Final_Quantity_Ltr)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/sum(t0081.Final_Quantity_Ltr)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/sum(t0081.Final_Quantity_Ltr))  as Dairy_SNF,
            
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Protein))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Protein,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Ash))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Ash,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Sodium))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Sodium
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
			and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
			and t021.TripDocument_Id = t022.TripDocument_Id
            and t022.MCC_Id in (select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1)
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
			and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
            and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
			and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
            and t0081.Is_Sour = '1'
            and t0081.Sour_Compartment_GRN_Flag = '1'
            and t0081.Final_Quantity_Ltr <> 0
            and t0081.Final_Quantity_Kg <> 0
            and t0081.Final_Fat <> 0
            and t0081.Final_SNF <> 0
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
			and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
			and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
			and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
			and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0091.CellNo = t0081.Compartment_No
            AND ifnull(t0091.MilkStatus_Id, '') = 'C016002'
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
			and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0092.CellNo = t0081.Compartment_No
            AND ifnull(t0092.MilkStatus_Id, '') = 'C016002'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF
            
            union all

            SELECT 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			(t0061.Quantity_Ltr / @kg_to_ltr ) as Agent_Quantity_Kg,
			(t0061.Quantity_Ltr) as Agent_Quantity_Ltr,
			((t0061.Quantity_Ltr * t0061.Fat))/(t0061.Quantity_Ltr)as Agent_Fat,
			((t0061.Quantity_Ltr * t0061.SNF))/(t0061.Quantity_Ltr) as Agent_SNF,
            Roundoff('Quantity', sum(t0081.Final_Quantity_Kg))  as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0081.Final_Quantity_Ltr)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/sum(t0081.Final_Quantity_Ltr)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/sum(t0081.Final_Quantity_Ltr))  as Dairy_SNF,
            
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Protein))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Protein,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Ash))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Ash,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Sodium))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Sodium
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
			and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
			and t021.TripDocument_Id = t022.TripDocument_Id
            and t022.MCC_Id not in (select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1)
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
			and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
            and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
			and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
            and t0081.Is_Sour = '0'
            and t0081.Final_Quantity_Ltr <> 0
            and t0081.Final_Quantity_Kg <> 0
            and t0081.Final_Fat <> 0
            and t0081.Final_SNF <> 0
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
			and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
			and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
			and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
			and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0091.CellNo = t0081.Compartment_No
            AND ifnull(t0091.MilkStatus_Id, '') = 'C016001'
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
			and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0092.CellNo = t0081.Compartment_No
            AND ifnull(t0092.MilkStatus_Id, '') = 'C016001'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF
            
            union all
            
            SELECT 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			@Set_Agent_Quantity_Kg as Agent_Quantity_Kg,
			@Set_Agent_Quantity_Ltr as Agent_Quantity_Ltr,
			@Set_Agent_Fat as Agent_Fat,
			@Set_Agent_SNF as Agent_SNF,
            Roundoff('Quantity', sum(t0081.Final_Quantity_Kg))  as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0081.Final_Quantity_Ltr)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/sum(t0081.Final_Quantity_Ltr)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/sum(t0081.Final_Quantity_Ltr))  as Dairy_SNF,
            
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Protein))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Protein,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Ash))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Ash,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Sodium))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Sodium
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
			and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
			and t021.TripDocument_Id = t022.TripDocument_Id
            and t022.MCC_Id  in (select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1)
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
			and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
            and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
			and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
            and t0081.Is_Sour = '0'
            and t0081.Final_Quantity_Ltr <> 0
            and t0081.Final_Quantity_Kg <> 0
            and t0081.Final_Fat <> 0
            and t0081.Final_SNF <> 0
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
			and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
			and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
			and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
			and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0091.CellNo = t0081.Compartment_No
            AND ifnull(t0091.MilkStatus_Id, '') = 'C016001'
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
			and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0092.CellNo = t0081.Compartment_No
            AND ifnull(t0092.MilkStatus_Id, '') = 'C016001'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF
            ) subquery 
			GROUP BY 
				Org_Id,
				MilkCollectionDairy_Id,
				Created_On,
				MCC_Id,
				MilkType_Id,
				Agent_Quantity_Kg,
				Agent_Quantity_Ltr,
				Agent_Fat,
				Agent_SNF;


		-- Declare continue handler for cursor
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		
		-- Open cursor
		OPEN cur;
        
		-- Loop to fetch and insert data
		myLoop: LOOP
			-- Fetch data into variables
			FETCH cur INTO Set_Org_Id,Set_MilkCollectionDairy_Id,Set_Created_On,Set_MCC_Id,
            Set_MilkType_Id,Set_Agent_Quantity_Kg,Set_Agent_Quantity_Ltr,Set_Agent_Fat,
            Set_Agent_SNF,Set_Dairy_Quantity_Kg,
            Set_Dairy_Quantity_Ltr,Set_Dairy_Fat,Set_Dairy_SNF,Set_var_Dairy_Protein,
            Set_var_Dairy_Ash,Set_var_Dairy_Sodium;

			-- Check if there is no more data
			IF done THEN
				LEAVE myLoop;
			END IF;
			
			-- Generate a new Entry_Id
			SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
			CALL USP_Number_Range('f010_milkcollectionmcc_final', Year_Id, 'F010', '', New_Entry_Id);
			
       
			-- Insert data into the table
			INSERT INTO f010_milkcollectionmcc_final (
				Org_Id, Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Collection_Date, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				Dairy_Fat, Dairy_SNF,MilkCollectionPosting_Id,
                Dairy_Protein,Dairy_Ash,Dairy_Sodium
			) VALUES (
				var_Org_Id,New_Entry_Id,Set_MilkCollectionDairy_Id,Set_MCC_Id,Set_MilkType_Id,
                Set_Created_On,Set_Agent_Quantity_Kg,Set_Agent_Quantity_Ltr,Set_Agent_Fat,
                Set_Agent_SNF,Set_Dairy_Quantity_Kg,Set_Dairy_Quantity_Ltr,Set_Dairy_Fat,Set_Dairy_SNF,'',
                Set_var_Dairy_Protein,Set_var_Dairy_Ash,Set_var_Dairy_Sodium
			);
            
            -- set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,'', Created_On,MilkType_Id);
                                
			set @var_Chart_Id =  GetMilkBaseRate(Set_Org_Id,Set_MCC_Id,'', now(),Set_MilkType_Id);
            
			select BaseFat,BaseSNF,Amount into var_BaseFat,var_BaseSNF,var_BaseRate
			from m001_milkrate_item where Org_Id = Set_Org_Id
			and Chart_Id = @var_Chart_Id
			and MilkRateEntryType_Id ='C012001'
            -- and Applicable_Date <= var_Created_On
			and Applicable_Date <= now()
			order by Applicable_Date desc limit 1;
            
            SELECT Fat,SNF into var_RatioFat,var_RatioSNF  FROM t024_fatsnf_ratio 
				where Ratio_Date <= now() 
				and Org_Id = Set_Org_Id
				and Is_Active = 1
				and Is_Deleted = 0
				order by Ratio_Date DESC Limit 1;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Agent_Fat_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_Fat) /100),
			f010.Agent_SNF_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_SNF) /100)
			WHERE f010.Org_Id = Set_Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Dairy_Fat_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_Fat) /100),
			f010.Dairy_SNF_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_SNF) /100)
			WHERE f010.Org_Id = Set_Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.FatKG_GainLoss = (f010.Dairy_Fat_Kg - f010.Agent_Fat_Kg),
			f010.SNFKG_GainLoss = (f010.Dairy_SNF_Kg - f010.Agent_SNF_Kg)
			WHERE f010.Org_Id = Set_Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.FatKG_Rate = ((var_BaseRate * var_RatioFat ) / var_BaseFat),
			f010.SNFKG_Rate = ((var_BaseRate * var_RatioSNF ) / var_BaseSNF)
			WHERE f010.Org_Id = Set_Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            /*
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Total_GainLoss = ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            */
            
            UPDATE  f010_milkcollectionmcc_final f010
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = f010.Org_Id
				AND m005.MCC_Id = f010.MCC_Id
			SET 
			f010.Total_GainLoss = CASE 
									WHEN m005.MCCWorkType_Id = 'C023001' THEN 0
									ELSE ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
								END
			WHERE f010.Org_Id = Set_Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
            inner join m005_mcc m005
			on m005.Org_Id = f010.Org_Id 
            and m005.MCC_Id = Set_MCC_Id 
			SET 
			f010.Plant_Code = m005.Plant_Code
			WHERE f010.Org_Id = Set_Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            

		END LOOP;

		-- Close cursor
		CLOSE cur;
        
        SELECT 1 AS Result_Id, 
		'Locked' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
			
        end;
		elseif (var_Method_Name = 'Create_Tanker_Sour') then
		begin
        
		DECLARE done INT DEFAULT FALSE;
		DECLARE New_Entry_Id VARCHAR(20);
        declare var_BaseFat decimal(10,2);
		declare var_BaseSNF decimal(10,2);
		declare var_BaseRate decimal(20,2);
		declare var_RatioFat decimal(10,2);
		declare var_RatioSNF decimal(10,2);
        DECLARE Year_Id VARCHAR(20);
		DECLARE Org_Id VARCHAR(10);
		DECLARE MilkCollectionDairy_Id VARCHAR(20);
		DECLARE Created_On DATETIME;
		DECLARE MCC_Id VARCHAR(20);
		DECLARE MilkType_Id VARCHAR(20);
		DECLARE Agent_Quantity_Kg DECIMAL(20, 3);
		DECLARE Agent_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Agent_Fat DECIMAL(8, 2);
		DECLARE Agent_SNF DECIMAL(8, 2);
		DECLARE Dairy_Quantity_Kg DECIMAL(20, 3);
		DECLARE Dairy_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Dairy_Fat DECIMAL(8, 2);
		DECLARE Dairy_SNF DECIMAL(8, 2);
        DECLARE var_Dairy_Protein DECIMAL(8, 2);
		DECLARE var_Dairy_Ash DECIMAL(8, 2);
        DECLARE var_Dairy_Sodium DECIMAL(8, 2);
        
        DECLARE cur CURSOR FOR
        -- Your select query here
			
		SELECT 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			(t0061.Quantity_Ltr / @kg_to_ltr ) as Agent_Quantity_Kg,
			(t0061.Quantity_Ltr) as Agent_Quantity_Ltr,
			((t0061.Quantity_Ltr * t0061.Fat))/(t0061.Quantity_Ltr)as Agent_Fat,
			((t0061.Quantity_Ltr * t0061.SNF))/(t0061.Quantity_Ltr) as Agent_SNF,
            Roundoff('Quantity', sum(t0081.Final_Quantity_Kg))  as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0081.Final_Quantity_Ltr)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/sum(t0081.Final_Quantity_Ltr)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/sum(t0081.Final_Quantity_Ltr))  as Dairy_SNF,
            
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Protein))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Protein,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Ash))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Ash,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Sodium))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Sodium
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
			and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
			and t021.TripDocument_Id = t022.TripDocument_Id
            and t022.MCC_Id not in (select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1)
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
			and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
            and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
			and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
            and t0081.Is_Sour = '1'
            and t0081.Sour_Compartment_GRN_Flag = '0'
            and t0081.Sour_Compartment_Adjustment_Flag = '0'
            and t0081.Final_Quantity_Ltr <> 0
            and t0081.Final_Quantity_Kg <> 0
            and t0081.Final_Fat <> 0
            and t0081.Final_SNF <> 0
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
			and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
			and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
			and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
			and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0091.CellNo = t0081.Compartment_No
            AND ifnull(t0091.MilkStatus_Id, '') = 'C016002'
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
			and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0092.CellNo = t0081.Compartment_No
            AND ifnull(t0092.MilkStatus_Id, '') = 'C016002'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF
            
            union all
            
            SELECT 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			@Set_Agent_Quantity_Kg as Agent_Quantity_Kg,
			@Set_Agent_Quantity_Ltr as Agent_Quantity_Ltr,
			@Set_Agent_Fat as Agent_Fat,
			@Set_Agent_SNF as Agent_SNF,
            Roundoff('Quantity', sum(t0081.Final_Quantity_Kg))  as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0081.Final_Quantity_Ltr)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/sum(t0081.Final_Quantity_Ltr)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/sum(t0081.Final_Quantity_Ltr))  as Dairy_SNF,
            
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Protein))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Protein,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Ash))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Ash,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Sodium))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Sodium
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
			and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
			and t021.TripDocument_Id = t022.TripDocument_Id
            and t022.MCC_Id in (select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1)
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
			and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
            and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
			and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
            and t0081.Is_Sour = '1'
            and t0081.Sour_Compartment_GRN_Flag = '0'
            and t0081.Sour_Compartment_Adjustment_Flag = '0'
            and t0081.Final_Quantity_Ltr <> 0
            and t0081.Final_Quantity_Kg <> 0
            and t0081.Final_Fat <> 0
            and t0081.Final_SNF <> 0
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
			and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
			and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
			and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
			and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0091.CellNo = t0081.Compartment_No
            AND ifnull(t0091.MilkStatus_Id, '') = 'C016002'
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
			and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0092.CellNo = t0081.Compartment_No
            AND ifnull(t0092.MilkStatus_Id, '') = 'C016002'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF;
            
		-- Declare continue handler for cursor
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		
		-- Open cursor
		OPEN cur;
        
		-- Loop to fetch and insert data
		myLoop: LOOP
			-- Fetch data into variables
			FETCH cur INTO Org_Id, MilkCollectionDairy_Id, Created_On, MCC_Id, MilkType_Id,
				Agent_Quantity_Kg, Agent_Quantity_Ltr, Agent_Fat, Agent_SNF,
				Dairy_Quantity_Kg, Dairy_Quantity_Ltr, Dairy_Fat, Dairy_SNF,
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium;

			-- Check if there is no more data
			IF done THEN
				LEAVE myLoop;
			END IF;
            
            select Org_Id, MilkCollectionDairy_Id, Created_On, MCC_Id, MilkType_Id,
				Agent_Quantity_Kg, Agent_Quantity_Ltr, Agent_Fat, Agent_SNF,
				Dairy_Quantity_Kg, Dairy_Quantity_Ltr, Dairy_Fat, Dairy_SNF,
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium;

			-- Generate a new Entry_Id
			SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
			CALL USP_Number_Range('f010_milkcollectionmcc_final_sour', Year_Id, 'F010A', '', New_Entry_Id);
			
			-- Insert data into the table
			INSERT INTO f010_milkcollectionmcc_final_sour (
				Org_Id, Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Collection_Date, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				Dairy_Fat, Dairy_SNF,MilkCollectionPosting_Id,
                Dairy_Protein,Dairy_Ash,Dairy_Sodium
			) VALUES (
				Org_Id, New_Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Created_On, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				Dairy_Fat, Dairy_SNF,'',
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium
			);
            
            -- set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,'', Created_On,MilkType_Id);
                                
			set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,'', now(),MilkType_Id);
            
			select BaseFat,BaseSNF,Amount into var_BaseFat,var_BaseSNF,var_BaseRate
			from m001_milkrate_item where Org_Id = Org_Id
			and Chart_Id = @var_Chart_Id
			and MilkRateEntryType_Id ='C012001'
            -- and Applicable_Date <= var_Created_On
			and Applicable_Date <= now()
			order by Applicable_Date desc limit 1;
            
            SELECT Fat,SNF into var_RatioFat,var_RatioSNF  FROM t024_fatsnf_ratio 
				where Ratio_Date <= now() 
				and Org_Id = Org_Id
				and Is_Active = 1
				and Is_Deleted = 0
				order by Ratio_Date DESC Limit 1;
            
            UPDATE  f010_milkcollectionmcc_final_sour f010
			SET 
			f010.Agent_Fat_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_Fat) /100),
			f010.Agent_SNF_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_SNF) /100)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour f010
			SET 
			f010.Dairy_Fat_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_Fat) /100),
			f010.Dairy_SNF_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_SNF) /100)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour f010
			SET 
			f010.FatKG_GainLoss = (f010.Dairy_Fat_Kg - f010.Agent_Fat_Kg),
			f010.SNFKG_GainLoss = (f010.Dairy_SNF_Kg - f010.Agent_SNF_Kg)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour f010
			SET 
			f010.FatKG_Rate = ((var_BaseRate * var_RatioFat ) / var_BaseFat),
			f010.SNFKG_Rate = ((var_BaseRate * var_RatioSNF ) / var_BaseSNF)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour f010
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = f010.Org_Id
				AND m005.MCC_Id = f010.MCC_Id
			SET 
			f010.Total_GainLoss = CASE 
									WHEN m005.MCCWorkType_Id = 'C023001' THEN 0
									ELSE ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
								END
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour f010
            inner join m005_mcc m005
			on m005.Org_Id = f010.Org_Id 
            and m005.MCC_Id = MCC_Id 
			SET 
			f010.Plant_Code = m005.Plant_Code
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            

		END LOOP;

		-- Close cursor
		CLOSE cur;
        
        SELECT 1 AS Result_Id, 
		'Locked' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
			
	end;
    elseif (var_Method_Name = 'Create_Tanker_Sour_Main') then
		begin
        
		DECLARE done INT DEFAULT FALSE;
		DECLARE New_Entry_Id VARCHAR(20);
        declare var_BaseFat decimal(10,2);
		declare var_BaseSNF decimal(10,2);
		declare var_BaseRate decimal(20,2);
		declare var_RatioFat decimal(10,2);
		declare var_RatioSNF decimal(10,2);
        DECLARE Year_Id VARCHAR(20);
		DECLARE Org_Id VARCHAR(10);
		DECLARE MilkCollectionDairy_Id VARCHAR(20);
		DECLARE Created_On DATETIME;
		DECLARE MCC_Id VARCHAR(20);
		DECLARE MilkType_Id VARCHAR(20);
		DECLARE Agent_Quantity_Kg DECIMAL(20, 3);
		DECLARE Agent_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Agent_Fat DECIMAL(8, 2);
		DECLARE Agent_SNF DECIMAL(8, 2);
		DECLARE Dairy_Quantity_Kg DECIMAL(20, 3);
		DECLARE Dairy_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Dairy_Fat DECIMAL(8, 2);
		DECLARE Dairy_SNF DECIMAL(8, 2);
        DECLARE var_Dairy_Protein DECIMAL(8, 2);
		DECLARE var_Dairy_Ash DECIMAL(8, 2);
        DECLARE var_Dairy_Sodium DECIMAL(8, 2);
        
        DECLARE cur CURSOR FOR
        -- Your select query here
			
		SELECT 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			(t0061.Quantity_Ltr / @kg_to_ltr ) as Agent_Quantity_Kg,
			(t0061.Quantity_Ltr) as Agent_Quantity_Ltr,
			((t0061.Quantity_Ltr * t0061.Fat))/(t0061.Quantity_Ltr)as Agent_Fat,
			((t0061.Quantity_Ltr * t0061.SNF))/(t0061.Quantity_Ltr) as Agent_SNF,
            Roundoff('Quantity', sum(t0081.Final_Quantity_Kg))  as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0081.Final_Quantity_Ltr)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/sum(t0081.Final_Quantity_Ltr)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/sum(t0081.Final_Quantity_Ltr))  as Dairy_SNF,
            
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Protein))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Protein,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Ash))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Ash,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Sodium))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Sodium
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
			and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
			and t021.TripDocument_Id = t022.TripDocument_Id
            and t022.MCC_Id not in (select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1)
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
			and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
            and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
			and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
            and t0081.Is_Sour = '1'
            and t0081.Sour_Compartment_Adjustment_Flag = '0'
            and t0081.Final_Quantity_Ltr <> 0
            and t0081.Final_Quantity_Kg <> 0
            and t0081.Final_Fat <> 0
            and t0081.Final_SNF <> 0
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
			and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
			and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
			and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
			and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0091.CellNo = t0081.Compartment_No
            AND ifnull(t0091.MilkStatus_Id, '') = 'C016002'
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
			and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0092.CellNo = t0081.Compartment_No
            AND ifnull(t0092.MilkStatus_Id, '') = 'C016002'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF
            
            union all
            
            SELECT 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			@Set_Agent_Quantity_Kg as Agent_Quantity_Kg,
			@Set_Agent_Quantity_Ltr as Agent_Quantity_Ltr,
			@Set_Agent_Fat as Agent_Fat,
			@Set_Agent_SNF as Agent_SNF,
            Roundoff('Quantity', sum(t0081.Final_Quantity_Kg))  as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0081.Final_Quantity_Ltr)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/sum(t0081.Final_Quantity_Ltr)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/sum(t0081.Final_Quantity_Ltr))  as Dairy_SNF,
            
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Protein))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Protein,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Ash))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Ash,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Sodium))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Sodium
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
			and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
			and t021.TripDocument_Id = t022.TripDocument_Id
            and t022.MCC_Id  in (select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1)
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
			and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
            and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
			and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
            and t0081.Is_Sour = '1'
            and t0081.Sour_Compartment_Adjustment_Flag = '0'
            and t0081.Final_Quantity_Ltr <> 0
            and t0081.Final_Quantity_Kg <> 0
            and t0081.Final_Fat <> 0
            and t0081.Final_SNF <> 0
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
			and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
			and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
			and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
			and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0091.CellNo = t0081.Compartment_No
            AND ifnull(t0091.MilkStatus_Id, '') = 'C016002'
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
			and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0092.CellNo = t0081.Compartment_No
            AND ifnull(t0092.MilkStatus_Id, '') = 'C016002'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF;
            
		-- Declare continue handler for cursor
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		
		-- Open cursor
		OPEN cur;
        
		-- Loop to fetch and insert data
		myLoop: LOOP
			-- Fetch data into variables
			FETCH cur INTO Org_Id, MilkCollectionDairy_Id, Created_On, MCC_Id, MilkType_Id,
				Agent_Quantity_Kg, Agent_Quantity_Ltr, Agent_Fat, Agent_SNF,
				Dairy_Quantity_Kg, Dairy_Quantity_Ltr, Dairy_Fat, Dairy_SNF,
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium;

			-- Check if there is no more data
			IF done THEN
				LEAVE myLoop;
			END IF;

			-- Generate a new Entry_Id
			SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
			CALL USP_Number_Range('f010_milkcollectionmcc_final_sour_main', Year_Id, 'F010B', '', New_Entry_Id);
			
			-- Insert data into the table
			INSERT INTO f010_milkcollectionmcc_final_sour_main (
				Org_Id, Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Collection_Date, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				Dairy_Fat, Dairy_SNF,MilkCollectionPosting_Id,
                Dairy_Protein,Dairy_Ash,Dairy_Sodium
			) VALUES (
				Org_Id, New_Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Created_On, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				Dairy_Fat, Dairy_SNF,'',
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium
			);
            
            -- set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,'', Created_On,MilkType_Id);
                                
			set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,'', now(),MilkType_Id);
            
			select BaseFat,BaseSNF,Amount into var_BaseFat,var_BaseSNF,var_BaseRate
			from m001_milkrate_item where Org_Id = Org_Id
			and Chart_Id = @var_Chart_Id
			and MilkRateEntryType_Id ='C012001'
            -- and Applicable_Date <= var_Created_On
			and Applicable_Date <= now()
			order by Applicable_Date desc limit 1;
            
            SELECT Fat,SNF into var_RatioFat,var_RatioSNF  FROM t024_fatsnf_ratio 
				where Ratio_Date <= now() 
				and Org_Id = Org_Id
				and Is_Active = 1
				and Is_Deleted = 0
				order by Ratio_Date DESC Limit 1;
            
            UPDATE  f010_milkcollectionmcc_final_sour_main f010
			SET 
			f010.Agent_Fat_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_Fat) /100),
			f010.Agent_SNF_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_SNF) /100)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour_main f010
			SET 
			f010.Dairy_Fat_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_Fat) /100),
			f010.Dairy_SNF_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_SNF) /100)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour_main f010
			SET 
			f010.FatKG_GainLoss = (f010.Dairy_Fat_Kg - f010.Agent_Fat_Kg),
			f010.SNFKG_GainLoss = (f010.Dairy_SNF_Kg - f010.Agent_SNF_Kg)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour_main f010
			SET 
			f010.FatKG_Rate = ((var_BaseRate * var_RatioFat ) / var_BaseFat),
			f010.SNFKG_Rate = ((var_BaseRate * var_RatioSNF ) / var_BaseSNF)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour_main f010
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = f010.Org_Id
				AND m005.MCC_Id = f010.MCC_Id
			SET 
			f010.Total_GainLoss = CASE 
									WHEN m005.MCCWorkType_Id = 'C023001' THEN 0
									ELSE ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
								END
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour_main f010
            inner join m005_mcc m005
			on m005.Org_Id = f010.Org_Id 
            and m005.MCC_Id = MCC_Id 
			SET 
			f010.Plant_Code = m005.Plant_Code
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            

		END LOOP;

		-- Close cursor
		CLOSE cur;
        
        SELECT 1 AS Result_Id, 
		'Locked' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
			
	end;
	
    elseif (var_Method_Name = 'Create_Tanker_Sour_MCC') then
		begin
        
		DECLARE done INT DEFAULT FALSE;
		DECLARE New_Entry_Id VARCHAR(20);
        declare var_BaseFat decimal(10,2);
		declare var_BaseSNF decimal(10,2);
		declare var_BaseRate decimal(20,2);
		declare var_RatioFat decimal(10,2);
		declare var_RatioSNF decimal(10,2);
        DECLARE Year_Id VARCHAR(20);
		DECLARE Org_Id VARCHAR(10);
		DECLARE MilkCollectionDairy_Id VARCHAR(20);
		DECLARE Created_On DATETIME;
		DECLARE MCC_Id VARCHAR(20);
		DECLARE MilkType_Id VARCHAR(20);
		DECLARE Agent_Quantity_Kg DECIMAL(20, 3);
		DECLARE Agent_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Agent_Fat DECIMAL(8, 2);
		DECLARE Agent_SNF DECIMAL(8, 2);
		DECLARE Dairy_Quantity_Kg DECIMAL(20, 3);
		DECLARE Dairy_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Dairy_Fat DECIMAL(8, 2);
		DECLARE Dairy_SNF DECIMAL(8, 2);
        DECLARE var_Dairy_Protein DECIMAL(8, 2);
		DECLARE var_Dairy_Ash DECIMAL(8, 2);
        DECLARE var_Dairy_Sodium DECIMAL(8, 2);
        
        DECLARE cur CURSOR FOR
        -- Your select query here
			
		SELECT 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			(t0061.Quantity_Ltr / @kg_to_ltr ) as Agent_Quantity_Kg,
			(t0061.Quantity_Ltr) as Agent_Quantity_Ltr,
			((t0061.Quantity_Ltr * t0061.Fat))/(t0061.Quantity_Ltr)as Agent_Fat,
			((t0061.Quantity_Ltr * t0061.SNF))/(t0061.Quantity_Ltr) as Agent_SNF,
            Roundoff('Quantity', sum(t0081.Final_Quantity_Kg))  as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0081.Final_Quantity_Ltr)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/sum(t0081.Final_Quantity_Ltr)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/sum(t0081.Final_Quantity_Ltr))  as Dairy_SNF,
            
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Protein))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Protein,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Ash))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Ash,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Sodium))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Sodium
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
			and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
			and t021.TripDocument_Id = t022.TripDocument_Id
            and t022.MCC_Id not in (select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1)
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
			and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
            and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
			and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
            and t0081.Is_Sour = '1'
            and t0081.Sour_Compartment_Adjustment_Flag = '1'
            and t0081.Final_Quantity_Ltr <> 0
            and t0081.Final_Quantity_Kg <> 0
            and t0081.Final_Fat <> 0
            and t0081.Final_SNF <> 0
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
			and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
			and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
			and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
			and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0091.CellNo = t0081.Compartment_No
            AND ifnull(t0091.MilkStatus_Id, '') = 'C016002'
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
			and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0092.CellNo = t0081.Compartment_No
            AND ifnull(t0092.MilkStatus_Id, '') = 'C016002'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF
            
            union all
            
            SELECT 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			@Set_Agent_Quantity_Kg as Agent_Quantity_Kg,
			@Set_Agent_Quantity_Ltr as Agent_Quantity_Ltr,
			@Set_Agent_Fat as Agent_Fat,
			@Set_Agent_SNF as Agent_SNF,
            Roundoff('Quantity', sum(t0081.Final_Quantity_Kg))  as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0081.Final_Quantity_Ltr)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/sum(t0081.Final_Quantity_Ltr)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/sum(t0081.Final_Quantity_Ltr))  as Dairy_SNF,
            
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Protein))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Protein,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Ash))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Ash,
            Roundoff('Quality', (sum(t0081.Final_Quantity_Ltr * t0081.Final_Sodium))/sum(t0081.Final_Quantity_Ltr))  as var_Dairy_Sodium
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
			and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
			and t021.TripDocument_Id = t022.TripDocument_Id
            and t022.MCC_Id in (select MCC_Id from m005_mcc where Org_Id = var_Org_Id and Is_Alternate = 1)
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
			and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
            and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
			and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
            and t0081.Is_Sour = '1'
            and t0081.Sour_Compartment_Adjustment_Flag = '1'
            and t0081.Final_Quantity_Ltr <> 0
            and t0081.Final_Quantity_Kg <> 0
            and t0081.Final_Fat <> 0
            and t0081.Final_SNF <> 0
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
			and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
			and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
			and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
			and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0091.CellNo = t0081.Compartment_No
            AND ifnull(t0091.MilkStatus_Id, '') = 'C016002'
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
			and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and t0092.CellNo = t0081.Compartment_No
            AND ifnull(t0092.MilkStatus_Id, '') = 'C016002'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			t0061.Quantity_Ltr,
			t0061.FAT,
			t0061.SNF;
            
		-- Declare continue handler for cursor
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		
		-- Open cursor
		OPEN cur;
        
		-- Loop to fetch and insert data
		myLoop: LOOP
			-- Fetch data into variables
			FETCH cur INTO Org_Id, MilkCollectionDairy_Id, Created_On, MCC_Id, MilkType_Id,
				Agent_Quantity_Kg, Agent_Quantity_Ltr, Agent_Fat, Agent_SNF,
				Dairy_Quantity_Kg, Dairy_Quantity_Ltr, Dairy_Fat, Dairy_SNF,
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium;

			-- Check if there is no more data
			IF done THEN
				LEAVE myLoop;
			END IF;

			-- Generate a new Entry_Id
			SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
			CALL USP_Number_Range('f010_milkcollectionmcc_final_sour_mcc', Year_Id, 'F010C', '', New_Entry_Id);
			
			-- Insert data into the table
			INSERT INTO f010_milkcollectionmcc_final_sour_mcc (
				Org_Id, Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Collection_Date, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				Dairy_Fat, Dairy_SNF,MilkCollectionPosting_Id,
                Dairy_Protein,Dairy_Ash,Dairy_Sodium
			) VALUES (
				Org_Id, New_Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Created_On, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				Dairy_Fat, Dairy_SNF,'',
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium
			);
            
            -- set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,'', Created_On,MilkType_Id);
                                
			set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,'', now(),MilkType_Id);
            
			select BaseFat,BaseSNF,Amount into var_BaseFat,var_BaseSNF,var_BaseRate
			from m001_milkrate_item where Org_Id = Org_Id
			and Chart_Id = @var_Chart_Id
			and MilkRateEntryType_Id ='C012001'
            -- and Applicable_Date <= var_Created_On
			and Applicable_Date <= now()
			order by Applicable_Date desc limit 1;
            
            SELECT Fat,SNF into var_RatioFat,var_RatioSNF  FROM t024_fatsnf_ratio 
				where Ratio_Date <= now() 
				and Org_Id = Org_Id
				and Is_Active = 1
				and Is_Deleted = 0
				order by Ratio_Date DESC Limit 1;
            
            UPDATE  f010_milkcollectionmcc_final_sour_mcc f010
			SET 
			f010.Agent_Fat_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_Fat) /100),
			f010.Agent_SNF_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_SNF) /100)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour_mcc f010
			SET 
			f010.Dairy_Fat_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_Fat) /100),
			f010.Dairy_SNF_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_SNF) /100)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour_mcc f010
			SET 
			f010.FatKG_GainLoss = (f010.Dairy_Fat_Kg - f010.Agent_Fat_Kg),
			f010.SNFKG_GainLoss = (f010.Dairy_SNF_Kg - f010.Agent_SNF_Kg)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour_mcc f010
			SET 
			f010.FatKG_Rate = ((var_BaseRate * var_RatioFat ) / var_BaseFat),
			f010.SNFKG_Rate = ((var_BaseRate * var_RatioSNF ) / var_BaseSNF)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour_mcc f010
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = f010.Org_Id
				AND m005.MCC_Id = f010.MCC_Id
			SET 
			f010.Total_GainLoss = CASE 
									WHEN m005.MCCWorkType_Id = 'C023001' THEN 0
									ELSE ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
								END
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final_sour_mcc f010
            inner join m005_mcc m005
			on m005.Org_Id = f010.Org_Id 
            and m005.MCC_Id = MCC_Id 
			SET 
			f010.Plant_Code = m005.Plant_Code
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            

		END LOOP;

		-- Close cursor
		CLOSE cur;
        
        SELECT 1 AS Result_Id, 
		'Locked' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
			
	end;
	elseif (var_Method_Name = 'Create_Commission_New') then
		begin 
			set @Check_CollectionShift_Id = ( select CollectionShift_Id from f010_milkcollectionmcc_final 
						where Org_Id = var_Org_Id
						and MilkCollectionDairy_Id =var_MilkCollectionDairy_Id limit 1 );

			if (@Check_CollectionShift_Id = 'C015002') then

				SET SQL_SAFE_UPDATES = 0;

				set @Collection_Date = ( select Collection_Date from f010_milkcollectionmcc_final 
										where Org_Id =  var_Org_Id
										and MilkCollectionDairy_Id =  var_MilkCollectionDairy_Id limit 1 );
                
				DROP TEMPORARY TABLE IF EXISTS temp_Report;
				CREATE TEMPORARY TABLE temp_Report 
				(Org_Id varchar(20),MCC_Id varchar(20),MilkType_Id varchar(20),
				Quantity_Kg decimal(30,3),Quantity_Ltr decimal(30,3),
				FAT decimal(18,3),SNF decimal(18,3)
				);

				insert into temp_Report ( Org_Id, MCC_Id,MilkType_Id,Quantity_Kg,Quantity_Ltr,Fat,SNF)
				select 
				Org_Id, MCC_Id,MilkType_Id,
				Dairy_Quantity_Kg as Quantity_Kg,
				Dairy_Quantity_Ltr as Quantity_Ltr,
				Dairy_Fat as Fat,
				Dairy_SNF as SNF
				from f010_milkcollectionmcc_final 
				where Org_Id =  var_Org_Id
				and MilkCollectionDairy_Id =  var_MilkCollectionDairy_Id;
                

				DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
				CREATE TEMPORARY TABLE temp_Report_1 
				(Org_Id varchar(20),MCC_Id varchar(20),MilkType_Id varchar(20),
				Quantity_Kg decimal(30,3),Quantity_Ltr decimal(30,3),
				FAT decimal(18,3),SNF decimal(18,3)
				);
                
                insert into temp_Report_1 select * from temp_Report;

				insert into temp_Report ( Org_Id, MCC_Id,MilkType_Id,Quantity_Kg,Quantity_Ltr,Fat,SNF)
				select 
				f010.Org_Id, f010.MCC_Id,f010.MilkType_Id,
				f010.Dairy_Quantity_Kg as Quantity_Kg,
				f010.Dairy_Quantity_Ltr as Quantity_Ltr,
				f010.Dairy_Fat as Fat,
				f010.Dairy_SNF as SNF
				from f010_milkcollectionmcc_final f010
				inner join temp_Report_1 tmp on
				tmp.Org_Id = f010.Org_Id
				and tmp.MCC_Id = f010.MCC_Id
				and tmp.MilkType_Id = f010.MilkType_Id
				where f010.Org_Id = var_Org_Id
				and f010.CollectionShift_Id ='C015001'
				and date(f010.Collection_Date) = date(@Collection_Date);
				
	
				DROP TEMPORARY TABLE IF EXISTS temp_Report_Data;
				CREATE TEMPORARY TABLE temp_Report_Data 
				(set_Org_Id varchar(20),set_MCC_Id varchar(20),set_MilkType_Id varchar(20),
				set_Quantity_Kg decimal(30,3),set_Quantity_Ltr decimal(30,3),
				set_FAT decimal(18,3),set_SNF decimal(18,3),Is_Commission int
				);
				insert into temp_Report_Data ( set_Org_Id, set_MCC_Id,set_MilkType_Id,set_Quantity_Kg,set_Quantity_Ltr,set_Fat,set_SNF,Is_Commission)
				select 
				Org_Id,MCC_Id,MilkType_Id,
				Roundoff('Quantity',(IFNULL(SUM(Quantity_Kg), 0)))  as Quantity_Kg,
				Roundoff('QuantityForDairy', (IFNULL(SUM(Quantity_Ltr), 0))) as Quantity_Ltr,
				Roundoff('Quality',(IFNULL((SUM(Quantity_Ltr * Fat)) / SUM(Quantity_Ltr), 0))) as Fat,
				Roundoff('Quality',(IFNULL((SUM(Quantity_Ltr * SNF)) / SUM(Quantity_Ltr), 0))) as SNF,
				0 as Is_Commission
				from temp_Report
				group by Org_Id,MCC_Id,MilkType_Id;

				UPDATE temp_Report_Data tmp
				inner JOIN t009_milkcollectiondairy_mcccommission t0091 
					ON tmp.set_Org_Id = t0091.Org_Id 
					AND tmp.set_MCC_Id = t0091.MCC_Id
					AND tmp.set_MilkType_Id = t0091.MilkType_Id 
				inner JOIN f010_milkcollectionmcc_final f010 
					ON f010.Org_Id = tmp.set_Org_Id 
					AND f010.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
					AND f010.MCC_Id = tmp.set_MCC_Id
					AND tmp.set_MilkType_Id = f010.MilkType_Id 
					AND f010.CollectionShift_Id = 'C015001'
					AND DATE(f010.Collection_Date) = DATE(@Collection_Date)
				SET tmp.Is_Commission = CASE 
					WHEN t0091.MCC_Id IS NOT NULL THEN 1 
					ELSE 0 
				END;
                

				UPDATE temp_Report_Data tmp
				inner JOIN f010_milkcollectionmcc_final f010 
					ON tmp.set_Org_Id = f010.Org_Id 
					AND f010.MilkCollectionDairy_Id =  var_MilkCollectionDairy_Id
					AND tmp.set_MCC_Id = f010.MCC_Id
					AND tmp.set_MilkType_Id = f010.MilkType_Id
				SET tmp.set_Quantity_Kg = f010.Dairy_Quantity_Kg,
				tmp.set_Quantity_Ltr = f010.Dairy_Quantity_Ltr,
				tmp.set_FAT = f010.Dairy_Fat,
				tmp.set_SNF = f010.Dairy_SNF
				where Is_Commission = 1;

			end if;
            

			if (@Check_CollectionShift_Id = 'C015002') then
				begin 
						DECLARE done INT DEFAULT FALSE;
						DECLARE New_MilkCollectionMCCCommission_Id VARCHAR(20);
						DECLARE Year_Id VARCHAR(20);
						DECLARE Org_Id VARCHAR(10);
						DECLARE MilkCollectionDairy_Id VARCHAR(20);
						DECLARE MCC_Id VARCHAR(20);
						DECLARE MPPIType_Id VARCHAR(20);
						DECLARE CollectionShift_Id VARCHAR(20);
						DECLARE MilkType_Id VARCHAR(20);
						DECLARE MilkStatus_Id VARCHAR(20);
						DECLARE Liters DECIMAL(20, 3);
						DECLARE Weight DECIMAL(20, 3);
						DECLARE Fat DECIMAL(8, 2);
						DECLARE SNF DECIMAL(8, 2);
						DECLARE Rate DECIMAL(20, 2);
						DECLARE Amount DECIMAL(20, 2);
						
						DECLARE cur CURSOR FOR
							-- Your select query here
								SELECT *
								FROM (
								SELECT 
								f010.set_Org_Id as Org_Id,
								  var_MilkCollectionDairy_Id as MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								'C015002' as CollectionShift_Id,
								f010.set_MilkType_Id as MilkType_Id,
								c016.MilkStatus_Id,
								f010.set_Quantity_Ltr as Liters,
								f010.set_Quantity_Kg  as Weight,
								f010.set_FAT as Fat,
								f010.set_SNF as SNF,
								ROUND(
									CASE
										WHEN IFNULL(SUM(f010.set_Quantity_Ltr), 0) >= m0022.MinimumQuantity
										AND IFNULL(SUM(f010.set_Quantity_Ltr), 0) <= m0022.MaximumQuantity
										AND f010.set_FAT >= m0022.MinimumFat
										AND f010.set_FAT <= m0022.MaximumFat
										AND f010.set_SNF >= m0022.MinimumSNF 
										AND f010.set_SNF <= m0022.MaximumSNF
									THEN
										m0022.BaseRate
									ELSE
										0
									END,
									2
								) as Rate,
								ROUND(
									CASE
										WHEN IFNULL(SUM(f010.set_Quantity_Ltr), 0) >= m0022.MinimumQuantity
										AND IFNULL(SUM(f010.set_Quantity_Ltr), 0) <= m0022.MaximumQuantity
										AND f010.set_FAT >= m0022.MinimumFat
										AND f010.set_FAT <= m0022.MaximumFat
										AND f010.set_SNF >= m0022.MinimumSNF 
										AND f010.set_SNF <= m0022.MaximumSNF
									THEN
										(m0022.BaseRate * IFNULL(SUM(f010.set_Quantity_Ltr), 0)) 
									ELSE
										0
									END,
									2
								) as Amount

								FROM temp_Report_Data  f010
								INNER JOIN m005_mcc m005 ON
									m005.Org_Id = f010.set_Org_Id
									AND m005.MCC_Id = f010.set_MCC_Id
								INNER JOIN c047_mppitype c047 ON
									c047.MPPIType_Id = 'C047001'
								INNER JOIN c016_milkstatus c016 ON
									c016.MilkStatus_Id = 'C016001'
								INNER JOIN m002_commission_mcc m002 ON
									m002.Org_Id = f010.set_Org_Id
									AND m002.MCC_Id = f010.set_MCC_Id
									and m002.MPPIType_Id = 'C047001'
									AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
														inner join m002_commission m002 on 
														m002.MPPI_Id = m0021.MPPI_Id 
														and m002.Org_Id = m0021.Org_Id 
														and m002.MilkType_Id = f010.set_MilkType_Id 
														and m002.MPPIType_Id = m0021.MPPIType_Id
														WHERE m0021.Org_Id =   var_Org_Id
														and m0021.MPPIType_Id = 'C047001'
														and m0021.MCC_Id = f010.set_MCC_Id
														AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
														order by m0021.Applicable_Date desc limit 1)
								INNER JOIN m002_commission_item m0022 ON
									m0022.Org_Id = f010.set_Org_Id
									and m0022.Is_Deleted = 0
									AND m0022.MPPI_Id = (SELECT m0021.MPPI_Id FROM m002_commission_mcc m0021 
														inner join m002_commission m002 on 
														m002.MPPI_Id = m0021.MPPI_Id 
														and m002.Org_Id = m0021.Org_Id 
														and m002.MilkType_Id = f010.set_MilkType_Id 
														and m002.MPPIType_Id = m0021.MPPIType_Id
														WHERE m0021.Org_Id =   var_Org_Id
														and m0021.MPPIType_Id = 'C047001'
														and m0021.MCC_Id = f010.set_MCC_Id
														AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
														order by m0021.Applicable_Date desc limit 1)
								where f010.set_Org_Id =   var_Org_Id
								GROUP BY
								f010.set_Org_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								f010.set_MilkType_Id,
								c016.MilkStatus_Id,
								f010.set_Quantity_Ltr,
								f010.set_Quantity_Kg ,
								f010.set_FAT,
								f010.set_SNF,  
								m0022.BaseRate,  
								m0022.MinimumQuantity,
								m0022.MaximumQuantity,
								m0022.MinimumFat,
								m0022.MaximumFat,
								m0022.MinimumSNF,
								m0022.MaximumSNF

								UNION ALL

								/*
								SELECT 
								f010.Org_Id,
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
									c047.MPPIType_Id = 'C047009'
								where f010.Org_Id = var_Org_Id 
								and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
								GROUP BY
								f010.Org_Id,
								f010.MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								f010.CollectionShift_Id,
								f010.MilkType_Id,
								MilkStatus_Id,
								f010.Total_GainLoss
								
								UNION ALL
								*/
								SELECT 
								f010.Org_Id,
								f010.MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
								f010.MilkType_Id,
								c016.MilkStatus_Id,
								f010.Dairy_Quantity_Ltr as Liters,
								f010.Dairy_Quantity_Kg  as Weight,
								f010.Dairy_Fat as Fat,
								f010.Dairy_SNF as SNF,
								ROUND(
									CASE
										WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
										AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
										AND f010.Dairy_Fat >= m0022.MinimumFat
										AND f010.Dairy_Fat <= m0022.MaximumFat
										AND f010.Dairy_SNF >= m0022.MinimumSNF 
										AND f010.Dairy_SNF <= m0022.MaximumSNF
									THEN
										m0022.BaseRate
									ELSE
										0
									END,
									2
								) as Rate,
								ROUND(
									CASE
										WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
										AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
										AND f010.Dairy_Fat >= m0022.MinimumFat
										AND f010.Dairy_Fat <= m0022.MaximumFat
										AND f010.Dairy_SNF >= m0022.MinimumSNF 
										AND f010.Dairy_SNF <= m0022.MaximumSNF
									THEN
										(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
									ELSE
										0
									END,
									2
								) as Amount

								FROM f010_milkcollectionmcc_final  f010
								INNER JOIN m005_mcc m005 ON
									m005.Org_Id = f010.Org_Id
									AND m005.MCC_Id = f010.MCC_Id
								INNER JOIN c047_mppitype c047 ON
									c047.MPPIType_Id = 'C047009'
								INNER JOIN c016_milkstatus c016 ON
									c016.MilkStatus_Id = 'C016001'
								INNER JOIN m002_commission_mcc m002 ON
									m002.Org_Id = f010.Org_Id
									AND m002.MCC_Id = f010.MCC_Id
									and m002.MPPIType_Id = 'C047009'
									AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
														inner join m002_commission m002 on 
														m002.MPPI_Id = m0021.MPPI_Id 
														and m002.Org_Id = m0021.Org_Id 
														and m002.MilkType_Id = f010.MilkType_Id 
														and m002.MPPIType_Id = m0021.MPPIType_Id
														WHERE m0021.Org_Id = var_Org_Id
														and m0021.MPPIType_Id = 'C047009'
														and m0021.MCC_Id = f010.MCC_Id
														AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
														and m0021.MPPIType_Id = 'C047009'
														and m0021.MCC_Id = f010.MCC_Id
														AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
														order by m0021.Applicable_Date desc limit 1)
								where f010.Org_Id = var_Org_Id
								and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
								GROUP BY
								f010.Org_Id,
								f010.MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								f010.CollectionShift_Id,
								f010.MilkType_Id,
								c016.MilkStatus_Id,
								f010.Dairy_Quantity_Ltr,
								f010.Dairy_Quantity_Kg ,
								f010.Dairy_Fat,
								f010.Dairy_SNF,  
								m0022.BaseRate,  
								m0022.MinimumQuantity,
								m0022.MaximumQuantity,
								m0022.MinimumFat,
								m0022.MaximumFat,
								m0022.MinimumSNF,
								m0022.MaximumSNF

								UNION ALL


								SELECT 
								f010.Org_Id,
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
								and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
								GROUP BY
								f010.Org_Id,
								f010.MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								f010.CollectionShift_Id,
								f010.MilkType_Id,
								MilkStatus_Id,
								f010.Total_GainLoss
								
								UNION ALL
									
									SELECT 
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										'C047004' as MPPIType_Id,
										ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
										f010.MilkType_Id,
										'C016001' as MilkStatus_Id,
										f010.Dairy_Quantity_Ltr as Liters,
										f010.Dairy_Quantity_Kg  as Weight,
										'0' as FAT,
										'0' as SNF,   
										m0051.Anamat_PerLtr as Rate,
										(m0051.Anamat_PerLtr * f010.Dairy_Quantity_Ltr) as Amount
										FROM f010_milkcollectionmcc_final  f010
										INNER JOIN m005_mcc m005 ON
											m005.Org_Id = f010.Org_Id
											AND m005.MCC_Id = f010.MCC_Id
										
										INNER JOIN 
												temp_anamat max_dates ON f010.Org_Id = max_dates.Org_Id 
																		AND f010.MCC_Id = max_dates.MCC_Id 
										INNER JOIN 
												m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
																		and m0051.Is_Active = 1
																		AND m0051.MCC_Id = max_dates.MCC_Id 
																		AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
																		AND m0051.Anamat_Applicable_To = 'MCC'
										-- INNER JOIN c047_mppitype c047 ON
											-- c047.MPPIType_Id = 'C047004'
										where f010.Org_Id =  var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
										GROUP BY
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										-- c047.MPPIType_Id,
										f010.CollectionShift_Id,
										f010.MilkType_Id,
										MilkStatus_Id,
										m0051.Anamat_PerLtr,
										f010.Dairy_Quantity_Ltr,
										f010.Dairy_Quantity_Kg
										
										UNION ALL
										
										SELECT 
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										'C047005' as MPPIType_Id,
										ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
										f010.MilkType_Id,
										'C016001' as MilkStatus_Id,
										f010.Dairy_Quantity_Ltr as Liters,
										f010.Dairy_Quantity_Kg  as Weight,
										'0' as FAT,
										'0' as SNF,   
										m0051.Freight_PerLtr as Rate,
										(m0051.Freight_PerLtr * f010.Dairy_Quantity_Ltr) as Amount
										FROM f010_milkcollectionmcc_final  f010
										INNER JOIN m005_mcc m005 ON
											m005.Org_Id = f010.Org_Id
											AND m005.MCC_Id = f010.MCC_Id
																		
										INNER JOIN 
												temp_freight max_dates ON f010.Org_Id = max_dates.Org_Id 
																		AND f010.MCC_Id = max_dates.MCC_Id 
										INNER JOIN 
												m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
																		and m0051.Is_Active = 1
																		AND m0051.MCC_Id = max_dates.MCC_Id 
																		AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
																		AND m0051.Freight_Applicable_To = 'MCC'
										-- INNER JOIN c047_mppitype c047 ON
											-- c047.MPPIType_Id = 'C047005'
										where f010.Org_Id = var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
										GROUP BY
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										-- c047.MPPIType_Id,
										f010.CollectionShift_Id,
										f010.MilkType_Id,
										MilkStatus_Id,
										m0051.Freight_PerLtr,
										f010.Dairy_Quantity_Ltr,
										f010.Dairy_Quantity_Kg
										
										UNION ALL
										
										SELECT 
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										c047.MPPIType_Id,
										ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
										f010.MilkType_Id,
										c016.MilkStatus_Id,
										f010.Dairy_Quantity_Ltr as Liters,
										f010.Dairy_Quantity_Kg  as Weight,
										f010.Dairy_Fat as Fat,
										f010.Dairy_SNF as SNF,
										ROUND(
											CASE
												WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
												AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
												AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) >= m0022.MinimumProtein 
												AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) <= m0022.MaximumProtein
											THEN
												m0022.BaseRate
											ELSE
												0
											END,
											2
										) as Rate,
										ROUND(
											CASE
												WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
												AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
												AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) >= m0022.MinimumProtein 
												AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) <= m0022.MaximumProtein
											THEN
												(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
											ELSE
												0
											END,
											2
										) as Amount

										FROM f010_milkcollectionmcc_final  f010
										INNER JOIN m005_mcc m005 ON
											m005.Org_Id = f010.Org_Id
											AND m005.MCC_Id = f010.MCC_Id
										INNER JOIN c047_mppitype c047 ON
											c047.MPPIType_Id = 'C047006'
										INNER JOIN c016_milkstatus c016 ON
											c016.MilkStatus_Id = 'C016001'
										INNER JOIN m002_commission_mcc m002 ON
											m002.Org_Id = f010.Org_Id
											AND m002.MCC_Id = f010.MCC_Id
											and m002.MPPIType_Id = 'C047006'
											AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
																inner join m002_commission m002 on 
																m002.MPPI_Id = m0021.MPPI_Id 
																and m002.Org_Id = m0021.Org_Id 
																and m002.MilkType_Id = f010.MilkType_Id 
																and m002.MPPIType_Id = m0021.MPPIType_Id
																WHERE m0021.Org_Id = var_Org_Id
																and m0021.MPPIType_Id = 'C047006'
																and m0021.MCC_Id = f010.MCC_Id
																AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
																and m0021.MPPIType_Id = 'C047006'
																and m0021.MCC_Id = f010.MCC_Id
																AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
																order by m0021.Applicable_Date desc limit 1)
										where f010.Org_Id = var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
										GROUP BY
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										c047.MPPIType_Id,
										f010.CollectionShift_Id,
										f010.MilkType_Id,
										c016.MilkStatus_Id,
										f010.Dairy_Quantity_Ltr,
										f010.Dairy_Quantity_Kg ,
										f010.Dairy_Fat,
										f010.Dairy_SNF,  
										f010.Dairy_Protein,
										m0022.BaseRate,  
										m0022.MinimumQuantity,
										m0022.MaximumQuantity,
										m0022.MinimumProtein,
										m0022.MaximumProtein
										
										UNION ALL
										
										SELECT 
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										c047.MPPIType_Id,
										ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
										f010.MilkType_Id,
										c016.MilkStatus_Id,
										f010.Dairy_Quantity_Ltr as Liters,
										f010.Dairy_Quantity_Kg  as Weight,
										f010.Dairy_Fat as Fat,
										f010.Dairy_SNF as SNF,
										ROUND(
											CASE
												WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
												AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
												AND f010.Dairy_Ash >= m0022.MinimumAsh 
												AND f010.Dairy_Ash <= m0022.MaximumAsh
											THEN
												m0022.BaseRate
											ELSE
												0
											END,
											2
										) as Rate,
										ROUND(
											CASE
												WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
												AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
												AND f010.Dairy_Ash >= m0022.MinimumAsh 
												AND f010.Dairy_Ash <= m0022.MaximumAsh
											THEN
												(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
											ELSE
												0
											END,
											2
										) as Amount

										FROM f010_milkcollectionmcc_final  f010
										INNER JOIN m005_mcc m005 ON
											m005.Org_Id = f010.Org_Id
											AND m005.MCC_Id = f010.MCC_Id
										INNER JOIN c047_mppitype c047 ON
											c047.MPPIType_Id = 'C047007'
										INNER JOIN c016_milkstatus c016 ON
											c016.MilkStatus_Id = 'C016001'
										INNER JOIN m002_commission_mcc m002 ON
											m002.Org_Id = f010.Org_Id
											AND m002.MCC_Id = f010.MCC_Id
											and m002.MPPIType_Id = 'C047007'
											AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
																inner join m002_commission m002 on 
																m002.MPPI_Id = m0021.MPPI_Id 
																and m002.Org_Id = m0021.Org_Id 
																and m002.MilkType_Id = f010.MilkType_Id 
																and m002.MPPIType_Id = m0021.MPPIType_Id
																WHERE m0021.Org_Id = var_Org_Id
																and m0021.MPPIType_Id = 'C047007'
																and m0021.MCC_Id = f010.MCC_Id
																AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
																and m0021.MPPIType_Id = 'C047007'
																and m0021.MCC_Id = f010.MCC_Id
																AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
																order by m0021.Applicable_Date desc limit 1)
										where f010.Org_Id = var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
										GROUP BY
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										c047.MPPIType_Id,
										f010.CollectionShift_Id,
										f010.MilkType_Id,
										c016.MilkStatus_Id,
										f010.Dairy_Quantity_Ltr,
										f010.Dairy_Quantity_Kg ,
										f010.Dairy_Fat,
										f010.Dairy_SNF,  
										f010.Dairy_Ash,
										m0022.BaseRate,  
										m0022.MinimumQuantity,
										m0022.MaximumQuantity,
										m0022.MinimumAsh,
										m0022.MaximumAsh
										
								)AS CombinedResult
											WHERE CombinedResult.Amount <> 0
												ORDER BY 
													CombinedResult.MCC_Id;


							-- Declare continue handler for cursor
							DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
                                    
							-- Open cursor
							OPEN cur;
							
							-- Loop to fetch and insert data
							myLoop: LOOP
								-- Fetch data into variables
								
								FETCH cur INTO Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id,
								CollectionShift_Id,MilkType_Id,
								MilkStatus_Id,Liters,Weight,Fat,SNF,Rate,Amount;

								-- Check if there is no more data
								IF done THEN
									LEAVE myLoop;
								END IF;

								
								-- Generate a new Entry_Id
								SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
								CALL USP_Number_Range('t009_milkcollectiondairy_mcccommission', Year_Id, 'T009', '', New_MilkCollectionMCCCommission_Id);
								
								-- Insert data into the table
								INSERT INTO t009_milkcollectiondairy_mcccommission (
									Org_Id, MilkCollectionMCCCommission_Id, MilkCollectionDairy_Id, 
									MCC_Id, MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
									Liters,Weight,SNF,Fat,BaseRate,Amount
									
								) VALUES (
									Org_Id,New_MilkCollectionMCCCommission_Id,MilkCollectionDairy_Id,
									MCC_Id,MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
									Liters,Weight,SNF,Fat,Rate,Amount
								);
								SET @MusterType_Id = '';
								SET @MusterType_Id = (SELECT m005.MusterType_Id
														FROM m005_mcc_version m005
														WHERE m005.MCC_Id = MCC_Id AND m005.Is_Deleted = 0
														AND m005.Org_Id = Org_Id
														AND m005.Applicable_Date <= now()
														ORDER BY m005.Applicable_Date DESC LIMIT 1);
								SET @MusterType = '';
								SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id);
								
								IF (@MusterType = 1) THEN

									SET @MusterCycle_StartDate = @Current_Datetime;
									SET @MusterCycle_EndDate = @Current_Datetime;

								ELSEIF (@MusterType = 7) THEN

									IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 7) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-07');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 8 AND 14) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-14');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 15 AND 21) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 16 AND 31) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
										SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

									END IF;

								ELSEIF (@MusterType = 15) THEN

									IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 15) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');

									ELSE

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
										SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

									END IF;

								ELSEIF (@MusterType = 5) THEN

									IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 5) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-05');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 6 AND 10) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-10');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 11 AND 15) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 16 AND 20) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-20');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 21 AND 25) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-25');
									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 26 AND 31) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-26');
										SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

									END IF;

								ELSEIF (@MusterType = 10) THEN

									IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 10) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-10');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 11 AND 20) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-20');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 21 AND 31) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
										SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

									END IF;

								ELSEIF (@MusterType = 30) THEN

									SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
									SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

								END IF;
								
								UPDATE  t009_milkcollectiondairy_mcccommission t009
								SET 
								t009.MusterType_Id = @MusterType_Id,
								t009.MusterCycle_StartDate = @MusterCycle_StartDate,
								t009.MusterCycle_EndDate = @MusterCycle_EndDate
								WHERE t009.Org_Id = Org_Id
								AND t009.MilkCollectionMCCCommission_Id = New_MilkCollectionMCCCommission_Id;
								
								
							END LOOP;

							-- Close cursor
							CLOSE cur;
				end;
			else
				begin 
						DECLARE done INT DEFAULT FALSE;
						DECLARE New_MilkCollectionMCCCommission_Id VARCHAR(20);
						DECLARE Year_Id VARCHAR(20);
						DECLARE Org_Id VARCHAR(10);
						DECLARE MilkCollectionDairy_Id VARCHAR(20);
						DECLARE MCC_Id VARCHAR(20);
						DECLARE MPPIType_Id VARCHAR(20);
						DECLARE CollectionShift_Id VARCHAR(20);
						DECLARE MilkType_Id VARCHAR(20);
						DECLARE MilkStatus_Id VARCHAR(20);
						DECLARE Liters DECIMAL(20, 3);
						DECLARE Weight DECIMAL(20, 3);
						DECLARE Fat DECIMAL(8, 2);
						DECLARE SNF DECIMAL(8, 2);
						DECLARE Rate DECIMAL(20, 2);
						DECLARE Amount DECIMAL(20, 2);
						
						DECLARE cur CURSOR FOR
							-- Your select query here
								SELECT *
								FROM (
								SELECT 
								f010.Org_Id,
								f010.MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
								f010.MilkType_Id,
								c016.MilkStatus_Id,
								f010.Dairy_Quantity_Ltr as Liters,
								f010.Dairy_Quantity_Kg  as Weight,
								f010.Dairy_Fat as Fat,
								f010.Dairy_SNF as SNF,
								ROUND(
									CASE
										WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
										AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
										AND f010.Dairy_Fat >= m0022.MinimumFat
										AND f010.Dairy_Fat <= m0022.MaximumFat
										AND f010.Dairy_SNF >= m0022.MinimumSNF 
										AND f010.Dairy_SNF <= m0022.MaximumSNF
									THEN
										m0022.BaseRate
									ELSE
										0
									END,
									2
								) as Rate,
								ROUND(
									CASE
										WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
										AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
										AND f010.Dairy_Fat >= m0022.MinimumFat
										AND f010.Dairy_Fat <= m0022.MaximumFat
										AND f010.Dairy_SNF >= m0022.MinimumSNF 
										AND f010.Dairy_SNF <= m0022.MaximumSNF
									THEN
										(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
									ELSE
										0
									END,
									2
								) as Amount

								FROM f010_milkcollectionmcc_final  f010
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
														AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
														AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
														order by m0021.Applicable_Date desc limit 1)
								where f010.Org_Id = var_Org_Id
								and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
								GROUP BY
								f010.Org_Id,
								f010.MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								f010.CollectionShift_Id,
								f010.MilkType_Id,
								c016.MilkStatus_Id,
								f010.Dairy_Quantity_Ltr,
								f010.Dairy_Quantity_Kg ,
								f010.Dairy_Fat,
								f010.Dairy_SNF,  
								m0022.BaseRate,  
								m0022.MinimumQuantity,
								m0022.MaximumQuantity,
								m0022.MinimumFat,
								m0022.MaximumFat,
								m0022.MinimumSNF,
								m0022.MaximumSNF

								UNION ALL

								/*
								SELECT 
								f010.Org_Id,
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
									c047.MPPIType_Id = 'C047009'
								where f010.Org_Id = var_Org_Id 
								and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
								GROUP BY
								f010.Org_Id,
								f010.MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								f010.CollectionShift_Id,
								f010.MilkType_Id,
								MilkStatus_Id,
								f010.Total_GainLoss
								
								UNION ALL
								*/
								SELECT 
								f010.Org_Id,
								f010.MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
								f010.MilkType_Id,
								c016.MilkStatus_Id,
								f010.Dairy_Quantity_Ltr as Liters,
								f010.Dairy_Quantity_Kg  as Weight,
								f010.Dairy_Fat as Fat,
								f010.Dairy_SNF as SNF,
								ROUND(
									CASE
										WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
										AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
										AND f010.Dairy_Fat >= m0022.MinimumFat
										AND f010.Dairy_Fat <= m0022.MaximumFat
										AND f010.Dairy_SNF >= m0022.MinimumSNF 
										AND f010.Dairy_SNF <= m0022.MaximumSNF
									THEN
										m0022.BaseRate
									ELSE
										0
									END,
									2
								) as Rate,
								ROUND(
									CASE
										WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
										AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
										AND f010.Dairy_Fat >= m0022.MinimumFat
										AND f010.Dairy_Fat <= m0022.MaximumFat
										AND f010.Dairy_SNF >= m0022.MinimumSNF 
										AND f010.Dairy_SNF <= m0022.MaximumSNF
									THEN
										(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
									ELSE
										0
									END,
									2
								) as Amount

								FROM f010_milkcollectionmcc_final  f010
								INNER JOIN m005_mcc m005 ON
									m005.Org_Id = f010.Org_Id
									AND m005.MCC_Id = f010.MCC_Id
								INNER JOIN c047_mppitype c047 ON
									c047.MPPIType_Id = 'C047009'
								INNER JOIN c016_milkstatus c016 ON
									c016.MilkStatus_Id = 'C016001'
								INNER JOIN m002_commission_mcc m002 ON
									m002.Org_Id = f010.Org_Id
									AND m002.MCC_Id = f010.MCC_Id
									and m002.MPPIType_Id = 'C047009'
									AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
														inner join m002_commission m002 on 
														m002.MPPI_Id = m0021.MPPI_Id 
														and m002.Org_Id = m0021.Org_Id 
														and m002.MilkType_Id = f010.MilkType_Id 
														and m002.MPPIType_Id = m0021.MPPIType_Id
														WHERE m0021.Org_Id = var_Org_Id
														and m0021.MPPIType_Id = 'C047009'
														and m0021.MCC_Id = f010.MCC_Id
														AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
														and m0021.MPPIType_Id = 'C047009'
														and m0021.MCC_Id = f010.MCC_Id
														AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
														order by m0021.Applicable_Date desc limit 1)
								where f010.Org_Id = var_Org_Id
								and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
								GROUP BY
								f010.Org_Id,
								f010.MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								f010.CollectionShift_Id,
								f010.MilkType_Id,
								c016.MilkStatus_Id,
								f010.Dairy_Quantity_Ltr,
								f010.Dairy_Quantity_Kg ,
								f010.Dairy_Fat,
								f010.Dairy_SNF,  
								m0022.BaseRate,  
								m0022.MinimumQuantity,
								m0022.MaximumQuantity,
								m0022.MinimumFat,
								m0022.MaximumFat,
								m0022.MinimumSNF,
								m0022.MaximumSNF

								UNION ALL


								SELECT 
								f010.Org_Id,
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
								and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
								GROUP BY
								f010.Org_Id,
								f010.MilkCollectionDairy_Id,
								m005.MCC_Id,
								c047.MPPIType_Id,
								f010.CollectionShift_Id,
								f010.MilkType_Id,
								MilkStatus_Id,
								f010.Total_GainLoss
								
								UNION ALL
									
									SELECT 
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										'C047004' as MPPIType_Id,
										ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
										f010.MilkType_Id,
										'C016001' as MilkStatus_Id,
										f010.Dairy_Quantity_Ltr as Liters,
										f010.Dairy_Quantity_Kg  as Weight,
										'0' as FAT,
										'0' as SNF,   
										m0051.Anamat_PerLtr as Rate,
										(m0051.Anamat_PerLtr * f010.Dairy_Quantity_Ltr) as Amount
										FROM f010_milkcollectionmcc_final  f010
										INNER JOIN m005_mcc m005 ON
											m005.Org_Id = f010.Org_Id
											AND m005.MCC_Id = f010.MCC_Id
										
										INNER JOIN 
												temp_anamat max_dates ON f010.Org_Id = max_dates.Org_Id 
																		AND f010.MCC_Id = max_dates.MCC_Id 
										INNER JOIN 
												m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
																		and m0051.Is_Active = 1
																		AND m0051.MCC_Id = max_dates.MCC_Id 
																		AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
																		AND m0051.Anamat_Applicable_To = 'MCC'
										-- INNER JOIN c047_mppitype c047 ON
											-- c047.MPPIType_Id = 'C047004'
										where f010.Org_Id =  var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
										GROUP BY
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										-- c047.MPPIType_Id,
										f010.CollectionShift_Id,
										f010.MilkType_Id,
										MilkStatus_Id,
										m0051.Anamat_PerLtr,
										f010.Dairy_Quantity_Ltr,
										f010.Dairy_Quantity_Kg
										
										UNION ALL
										
										SELECT 
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										'C047005' as MPPIType_Id,
										ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
										f010.MilkType_Id,
										'C016001' as MilkStatus_Id,
										f010.Dairy_Quantity_Ltr as Liters,
										f010.Dairy_Quantity_Kg  as Weight,
										'0' as FAT,
										'0' as SNF,   
										m0051.Freight_PerLtr as Rate,
										(m0051.Freight_PerLtr * f010.Dairy_Quantity_Ltr) as Amount
										FROM f010_milkcollectionmcc_final  f010
										INNER JOIN m005_mcc m005 ON
											m005.Org_Id = f010.Org_Id
											AND m005.MCC_Id = f010.MCC_Id
																		
										INNER JOIN 
												temp_freight max_dates ON f010.Org_Id = max_dates.Org_Id 
																		AND f010.MCC_Id = max_dates.MCC_Id 
										INNER JOIN 
												m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
																		and m0051.Is_Active = 1
																		AND m0051.MCC_Id = max_dates.MCC_Id 
																		AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
																		AND m0051.Freight_Applicable_To = 'MCC'
										-- INNER JOIN c047_mppitype c047 ON
											-- c047.MPPIType_Id = 'C047005'
										where f010.Org_Id = var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
										GROUP BY
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										-- c047.MPPIType_Id,
										f010.CollectionShift_Id,
										f010.MilkType_Id,
										MilkStatus_Id,
										m0051.Freight_PerLtr,
										f010.Dairy_Quantity_Ltr,
										f010.Dairy_Quantity_Kg
										
										UNION ALL
										
										SELECT 
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										c047.MPPIType_Id,
										ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
										f010.MilkType_Id,
										c016.MilkStatus_Id,
										f010.Dairy_Quantity_Ltr as Liters,
										f010.Dairy_Quantity_Kg  as Weight,
										f010.Dairy_Fat as Fat,
										f010.Dairy_SNF as SNF,
										ROUND(
											CASE
												WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
												AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
												AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) >= m0022.MinimumProtein 
												AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) <= m0022.MaximumProtein
											THEN
												m0022.BaseRate
											ELSE
												0
											END,
											2
										) as Rate,
										ROUND(
											CASE
												WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
												AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
												AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) >= m0022.MinimumProtein 
												AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) <= m0022.MaximumProtein
											THEN
												(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
											ELSE
												0
											END,
											2
										) as Amount

										FROM f010_milkcollectionmcc_final  f010
										INNER JOIN m005_mcc m005 ON
											m005.Org_Id = f010.Org_Id
											AND m005.MCC_Id = f010.MCC_Id
										INNER JOIN c047_mppitype c047 ON
											c047.MPPIType_Id = 'C047006'
										INNER JOIN c016_milkstatus c016 ON
											c016.MilkStatus_Id = 'C016001'
										INNER JOIN m002_commission_mcc m002 ON
											m002.Org_Id = f010.Org_Id
											AND m002.MCC_Id = f010.MCC_Id
											and m002.MPPIType_Id = 'C047006'
											AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
																inner join m002_commission m002 on 
																m002.MPPI_Id = m0021.MPPI_Id 
																and m002.Org_Id = m0021.Org_Id 
																and m002.MilkType_Id = f010.MilkType_Id 
																and m002.MPPIType_Id = m0021.MPPIType_Id
																WHERE m0021.Org_Id = var_Org_Id
																and m0021.MPPIType_Id = 'C047006'
																and m0021.MCC_Id = f010.MCC_Id
																AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
																and m0021.MPPIType_Id = 'C047006'
																and m0021.MCC_Id = f010.MCC_Id
																AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
																order by m0021.Applicable_Date desc limit 1)
										where f010.Org_Id = var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
										GROUP BY
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										c047.MPPIType_Id,
										f010.CollectionShift_Id,
										f010.MilkType_Id,
										c016.MilkStatus_Id,
										f010.Dairy_Quantity_Ltr,
										f010.Dairy_Quantity_Kg ,
										f010.Dairy_Fat,
										f010.Dairy_SNF,  
										f010.Dairy_Protein,
										m0022.BaseRate,  
										m0022.MinimumQuantity,
										m0022.MaximumQuantity,
										m0022.MinimumProtein,
										m0022.MaximumProtein
										
										UNION ALL
										
										SELECT 
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										c047.MPPIType_Id,
										ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
										f010.MilkType_Id,
										c016.MilkStatus_Id,
										f010.Dairy_Quantity_Ltr as Liters,
										f010.Dairy_Quantity_Kg  as Weight,
										f010.Dairy_Fat as Fat,
										f010.Dairy_SNF as SNF,
										ROUND(
											CASE
												WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
												AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
												AND f010.Dairy_Ash >= m0022.MinimumAsh 
												AND f010.Dairy_Ash <= m0022.MaximumAsh
											THEN
												m0022.BaseRate
											ELSE
												0
											END,
											2
										) as Rate,
										ROUND(
											CASE
												WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
												AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
												AND f010.Dairy_Ash >= m0022.MinimumAsh 
												AND f010.Dairy_Ash <= m0022.MaximumAsh
											THEN
												(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
											ELSE
												0
											END,
											2
										) as Amount

										FROM f010_milkcollectionmcc_final  f010
										INNER JOIN m005_mcc m005 ON
											m005.Org_Id = f010.Org_Id
											AND m005.MCC_Id = f010.MCC_Id
										INNER JOIN c047_mppitype c047 ON
											c047.MPPIType_Id = 'C047007'
										INNER JOIN c016_milkstatus c016 ON
											c016.MilkStatus_Id = 'C016001'
										INNER JOIN m002_commission_mcc m002 ON
											m002.Org_Id = f010.Org_Id
											AND m002.MCC_Id = f010.MCC_Id
											and m002.MPPIType_Id = 'C047007'
											AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
																inner join m002_commission m002 on 
																m002.MPPI_Id = m0021.MPPI_Id 
																and m002.Org_Id = m0021.Org_Id 
																and m002.MilkType_Id = f010.MilkType_Id 
																and m002.MPPIType_Id = m0021.MPPIType_Id
																WHERE m0021.Org_Id = var_Org_Id
																and m0021.MPPIType_Id = 'C047007'
																and m0021.MCC_Id = f010.MCC_Id
																AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
																and m0021.MPPIType_Id = 'C047007'
																and m0021.MCC_Id = f010.MCC_Id
																AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
																order by m0021.Applicable_Date desc limit 1)
										where f010.Org_Id = var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
										GROUP BY
										f010.Org_Id,
										f010.MilkCollectionDairy_Id,
										m005.MCC_Id,
										c047.MPPIType_Id,
										f010.CollectionShift_Id,
										f010.MilkType_Id,
										c016.MilkStatus_Id,
										f010.Dairy_Quantity_Ltr,
										f010.Dairy_Quantity_Kg ,
										f010.Dairy_Fat,
										f010.Dairy_SNF,  
										f010.Dairy_Ash,
										m0022.BaseRate,  
										m0022.MinimumQuantity,
										m0022.MaximumQuantity,
										m0022.MinimumAsh,
										m0022.MaximumAsh
										
								)AS CombinedResult
											WHERE CombinedResult.Amount <> 0
												ORDER BY 
													CombinedResult.MCC_Id;


							-- Declare continue handler for cursor
							DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

							
							-- Open cursor
							OPEN cur;
							
							-- Loop to fetch and insert data
							myLoop: LOOP
								-- Fetch data into variables
								
								FETCH cur INTO Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id,
								CollectionShift_Id,MilkType_Id,
								MilkStatus_Id,Liters,Weight,Fat,SNF,Rate,Amount;

								-- Check if there is no more data
								IF done THEN
									LEAVE myLoop;
								END IF;

								select '1', Org_Id,New_MilkCollectionMCCCommission_Id,MilkCollectionDairy_Id,
									MCC_Id,MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
									Liters,Weight,SNF,Fat,Rate,Amount;
								
								-- Generate a new Entry_Id
								SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
								CALL USP_Number_Range('t009_milkcollectiondairy_mcccommission', Year_Id, 'T009', '', New_MilkCollectionMCCCommission_Id);
								
								-- Insert data into the table
								INSERT INTO t009_milkcollectiondairy_mcccommission (
									Org_Id, MilkCollectionMCCCommission_Id, MilkCollectionDairy_Id, 
									MCC_Id, MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
									Liters,Weight,SNF,Fat,BaseRate,Amount
									
								) VALUES (
									Org_Id,New_MilkCollectionMCCCommission_Id,MilkCollectionDairy_Id,
									MCC_Id,MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
									Liters,Weight,SNF,Fat,Rate,Amount
								);
								SET @MusterType_Id = '';
								SET @MusterType_Id = (SELECT m005.MusterType_Id
														FROM m005_mcc_version m005
														WHERE m005.MCC_Id = MCC_Id AND m005.Is_Deleted = 0
														AND m005.Org_Id = Org_Id
														AND m005.Applicable_Date <= now()
														ORDER BY m005.Applicable_Date DESC LIMIT 1);
								SET @MusterType = '';
								SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id);
								
								IF (@MusterType = 1) THEN

									SET @MusterCycle_StartDate = @Current_Datetime;
									SET @MusterCycle_EndDate = @Current_Datetime;

								ELSEIF (@MusterType = 7) THEN

									IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 7) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-07');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 8 AND 14) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-14');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 15 AND 21) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 16 AND 31) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
										SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

									END IF;

								ELSEIF (@MusterType = 15) THEN

									IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 15) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');

									ELSE

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
										SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

									END IF;

								ELSEIF (@MusterType = 5) THEN

									IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 5) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-05');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 6 AND 10) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-10');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 11 AND 15) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 16 AND 20) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-20');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 21 AND 25) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-25');
									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 26 AND 31) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-26');
										SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

									END IF;

								ELSEIF (@MusterType = 10) THEN

									IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 10) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-10');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 11 AND 20) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
										SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-20');

									ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 21 AND 31) THEN

										SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
										SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

									END IF;

								ELSEIF (@MusterType = 30) THEN

									SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
									SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

								END IF;
								
								UPDATE  t009_milkcollectiondairy_mcccommission t009
								SET 
								t009.MusterType_Id = @MusterType_Id,
								t009.MusterCycle_StartDate = @MusterCycle_StartDate,
								t009.MusterCycle_EndDate = @MusterCycle_EndDate
								WHERE t009.Org_Id = Org_Id
								AND t009.MilkCollectionMCCCommission_Id = New_MilkCollectionMCCCommission_Id;
								
								
							END LOOP;

							-- Close cursor
							CLOSE cur;
				end;
			end if;

			SELECT 1 AS Result_Id, 
			'Locked' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
		end;
    elseif (var_Method_Name = 'Create_Commission') then
    begin 
    DECLARE done INT DEFAULT FALSE;
	DECLARE New_MilkCollectionMCCCommission_Id VARCHAR(20);
    DECLARE Year_Id VARCHAR(20);
    DECLARE Org_Id VARCHAR(10);
	DECLARE MilkCollectionDairy_Id VARCHAR(20);
	DECLARE MCC_Id VARCHAR(20);
	DECLARE MPPIType_Id VARCHAR(20);
	DECLARE CollectionShift_Id VARCHAR(20);
	DECLARE MilkType_Id VARCHAR(20);
	DECLARE MilkStatus_Id VARCHAR(20);
	DECLARE Liters DECIMAL(20, 3);
	DECLARE Weight DECIMAL(20, 3);
	DECLARE Fat DECIMAL(8, 2);
	DECLARE SNF DECIMAL(8, 2);
    DECLARE Rate DECIMAL(20, 2);
	DECLARE Amount DECIMAL(20, 2);
    
    DECLARE cur CURSOR FOR
        -- Your select query here
			SELECT *
			FROM (
			SELECT 
			f010.Org_Id,
			f010.MilkCollectionDairy_Id,
			m005.MCC_Id,
			c047.MPPIType_Id,
			ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
			f010.MilkType_Id,
			c016.MilkStatus_Id,
			f010.Dairy_Quantity_Ltr as Liters,
			f010.Dairy_Quantity_Kg  as Weight,
			f010.Dairy_Fat as Fat,
			f010.Dairy_SNF as SNF,
			ROUND(
				CASE
					WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
					AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
					AND f010.Dairy_Fat >= m0022.MinimumFat
					AND f010.Dairy_Fat <= m0022.MaximumFat
					AND f010.Dairy_SNF >= m0022.MinimumSNF 
					AND f010.Dairy_SNF <= m0022.MaximumSNF
				THEN
					m0022.BaseRate
				ELSE
					0
				END,
				2
			) as Rate,
			ROUND(
				CASE
					WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
					AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
					AND f010.Dairy_Fat >= m0022.MinimumFat
					AND f010.Dairy_Fat <= m0022.MaximumFat
					AND f010.Dairy_SNF >= m0022.MinimumSNF 
					AND f010.Dairy_SNF <= m0022.MaximumSNF
				THEN
					(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
				ELSE
					0
				END,
				2
			) as Amount

			FROM f010_milkcollectionmcc_final  f010
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
									AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
									AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
									order by m0021.Applicable_Date desc limit 1)
			where f010.Org_Id = var_Org_Id
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			GROUP BY
			f010.Org_Id,
			f010.MilkCollectionDairy_Id,
			m005.MCC_Id,
			c047.MPPIType_Id,
			f010.CollectionShift_Id,
			f010.MilkType_Id,
			c016.MilkStatus_Id,
			f010.Dairy_Quantity_Ltr,
			f010.Dairy_Quantity_Kg ,
			f010.Dairy_Fat,
			f010.Dairy_SNF,  
			m0022.BaseRate,  
			m0022.MinimumQuantity,
			m0022.MaximumQuantity,
			m0022.MinimumFat,
			m0022.MaximumFat,
			m0022.MinimumSNF,
			m0022.MaximumSNF

			UNION ALL

			/*
			SELECT 
			f010.Org_Id,
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
				c047.MPPIType_Id = 'C047009'
			where f010.Org_Id = var_Org_Id 
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			GROUP BY
			f010.Org_Id,
			f010.MilkCollectionDairy_Id,
			m005.MCC_Id,
			c047.MPPIType_Id,
			f010.CollectionShift_Id,
			f010.MilkType_Id,
			MilkStatus_Id,
			f010.Total_GainLoss
            
            UNION ALL
            */
            
            SELECT 
			f010.Org_Id,
			f010.MilkCollectionDairy_Id,
			m005.MCC_Id,
			c047.MPPIType_Id,
			ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
			f010.MilkType_Id,
			c016.MilkStatus_Id,
			f010.Dairy_Quantity_Ltr as Liters,
			f010.Dairy_Quantity_Kg  as Weight,
			f010.Dairy_Fat as Fat,
			f010.Dairy_SNF as SNF,
			ROUND(
				CASE
					WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
					AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
					AND f010.Dairy_Fat >= m0022.MinimumFat
					AND f010.Dairy_Fat <= m0022.MaximumFat
					AND f010.Dairy_SNF >= m0022.MinimumSNF 
					AND f010.Dairy_SNF <= m0022.MaximumSNF
				THEN
					m0022.BaseRate
				ELSE
					0
				END,
				2
			) as Rate,
			ROUND(
				CASE
					WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
					AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
					AND f010.Dairy_Fat >= m0022.MinimumFat
					AND f010.Dairy_Fat <= m0022.MaximumFat
					AND f010.Dairy_SNF >= m0022.MinimumSNF 
					AND f010.Dairy_SNF <= m0022.MaximumSNF
				THEN
					(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
				ELSE
					0
				END,
				2
			) as Amount

			FROM f010_milkcollectionmcc_final  f010
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = f010.Org_Id
				AND m005.MCC_Id = f010.MCC_Id
			INNER JOIN c047_mppitype c047 ON
				c047.MPPIType_Id = 'C047009'
			INNER JOIN c016_milkstatus c016 ON
				c016.MilkStatus_Id = 'C016001'
			INNER JOIN m002_commission_mcc m002 ON
				m002.Org_Id = f010.Org_Id
				AND m002.MCC_Id = f010.MCC_Id
				and m002.MPPIType_Id = 'C047009'
				AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
									inner join m002_commission m002 on 
									m002.MPPI_Id = m0021.MPPI_Id 
									and m002.Org_Id = m0021.Org_Id 
									and m002.MilkType_Id = f010.MilkType_Id 
									and m002.MPPIType_Id = m0021.MPPIType_Id
									WHERE m0021.Org_Id = var_Org_Id
									and m0021.MPPIType_Id = 'C047009'
									and m0021.MCC_Id = f010.MCC_Id
									AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
									and m0021.MPPIType_Id = 'C047009'
									and m0021.MCC_Id = f010.MCC_Id
									AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
									order by m0021.Applicable_Date desc limit 1)
			where f010.Org_Id = var_Org_Id
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			GROUP BY
			f010.Org_Id,
			f010.MilkCollectionDairy_Id,
			m005.MCC_Id,
			c047.MPPIType_Id,
			f010.CollectionShift_Id,
			f010.MilkType_Id,
			c016.MilkStatus_Id,
			f010.Dairy_Quantity_Ltr,
			f010.Dairy_Quantity_Kg ,
			f010.Dairy_Fat,
			f010.Dairy_SNF,  
			m0022.BaseRate,  
			m0022.MinimumQuantity,
			m0022.MaximumQuantity,
			m0022.MinimumFat,
			m0022.MaximumFat,
			m0022.MinimumSNF,
			m0022.MaximumSNF

			UNION ALL


			SELECT 
			f010.Org_Id,
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
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			GROUP BY
			f010.Org_Id,
			f010.MilkCollectionDairy_Id,
			m005.MCC_Id,
			c047.MPPIType_Id,
			f010.CollectionShift_Id,
			f010.MilkType_Id,
			MilkStatus_Id,
			f010.Total_GainLoss
            
            UNION ALL
				
				SELECT 
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					'C047004' as MPPIType_Id,
					ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
					f010.MilkType_Id,
					'C016001' as MilkStatus_Id,
					f010.Dairy_Quantity_Ltr as Liters,
					f010.Dairy_Quantity_Kg  as Weight,
					'0' as FAT,
					'0' as SNF,   
					m0051.Anamat_PerLtr as Rate,
					(m0051.Anamat_PerLtr * f010.Dairy_Quantity_Ltr) as Amount
					FROM f010_milkcollectionmcc_final  f010
					INNER JOIN m005_mcc m005 ON
						m005.Org_Id = f010.Org_Id
						AND m005.MCC_Id = f010.MCC_Id
                    
					INNER JOIN 
							temp_anamat max_dates ON f010.Org_Id = max_dates.Org_Id 
													 AND f010.MCC_Id = max_dates.MCC_Id 
                    INNER JOIN 
							m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
													and m0051.Is_Active = 1
													 AND m0051.MCC_Id = max_dates.MCC_Id 
													 AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
													 AND m0051.Anamat_Applicable_To = 'MCC'
					-- INNER JOIN c047_mppitype c047 ON
						-- c047.MPPIType_Id = 'C047004'
					where f010.Org_Id =  var_Org_Id
                    and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					GROUP BY
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					-- c047.MPPIType_Id,
					f010.CollectionShift_Id,
					f010.MilkType_Id,
					MilkStatus_Id,
					m0051.Anamat_PerLtr,
					f010.Dairy_Quantity_Ltr,
					f010.Dairy_Quantity_Kg
					
					UNION ALL
					
					SELECT 
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					'C047005' as MPPIType_Id,
					ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
					f010.MilkType_Id,
					'C016001' as MilkStatus_Id,
					f010.Dairy_Quantity_Ltr as Liters,
					f010.Dairy_Quantity_Kg  as Weight,
					'0' as FAT,
					'0' as SNF,   
					m0051.Freight_PerLtr as Rate,
					(m0051.Freight_PerLtr * f010.Dairy_Quantity_Ltr) as Amount
					FROM f010_milkcollectionmcc_final  f010
					INNER JOIN m005_mcc m005 ON
						m005.Org_Id = f010.Org_Id
						AND m005.MCC_Id = f010.MCC_Id
                                                     
					INNER JOIN 
							temp_freight max_dates ON f010.Org_Id = max_dates.Org_Id 
													 AND f010.MCC_Id = max_dates.MCC_Id 
                    INNER JOIN 
							m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
													and m0051.Is_Active = 1
													 AND m0051.MCC_Id = max_dates.MCC_Id 
													 AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
													 AND m0051.Freight_Applicable_To = 'MCC'
					-- INNER JOIN c047_mppitype c047 ON
						-- c047.MPPIType_Id = 'C047005'
					where f010.Org_Id = var_Org_Id
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					GROUP BY
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					-- c047.MPPIType_Id,
					f010.CollectionShift_Id,
					f010.MilkType_Id,
					MilkStatus_Id,
					m0051.Freight_PerLtr,
					f010.Dairy_Quantity_Ltr,
					f010.Dairy_Quantity_Kg
                    
                    UNION ALL
                    
                    SELECT 
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					c047.MPPIType_Id,
					ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
					f010.MilkType_Id,
					c016.MilkStatus_Id,
					f010.Dairy_Quantity_Ltr as Liters,
					f010.Dairy_Quantity_Kg  as Weight,
					f010.Dairy_Fat as Fat,
					f010.Dairy_SNF as SNF,
					ROUND(
						CASE
							WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) >= m0022.MinimumProtein 
							AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) <= m0022.MaximumProtein
						THEN
							m0022.BaseRate
						ELSE
							0
						END,
						2
					) as Rate,
					ROUND(
						CASE
							WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) >= m0022.MinimumProtein 
							AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) <= m0022.MaximumProtein
						THEN
							(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
						ELSE
							0
						END,
						2
					) as Amount

					FROM f010_milkcollectionmcc_final  f010
					INNER JOIN m005_mcc m005 ON
						m005.Org_Id = f010.Org_Id
						AND m005.MCC_Id = f010.MCC_Id
					INNER JOIN c047_mppitype c047 ON
						c047.MPPIType_Id = 'C047006'
					INNER JOIN c016_milkstatus c016 ON
						c016.MilkStatus_Id = 'C016001'
					INNER JOIN m002_commission_mcc m002 ON
						m002.Org_Id = f010.Org_Id
						AND m002.MCC_Id = f010.MCC_Id
						and m002.MPPIType_Id = 'C047006'
						AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
											inner join m002_commission m002 on 
											m002.MPPI_Id = m0021.MPPI_Id 
											and m002.Org_Id = m0021.Org_Id 
											and m002.MilkType_Id = f010.MilkType_Id 
											and m002.MPPIType_Id = m0021.MPPIType_Id
											WHERE m0021.Org_Id = var_Org_Id
											and m0021.MPPIType_Id = 'C047006'
											and m0021.MCC_Id = f010.MCC_Id
											AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
											and m0021.MPPIType_Id = 'C047006'
											and m0021.MCC_Id = f010.MCC_Id
											AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
											order by m0021.Applicable_Date desc limit 1)
					where f010.Org_Id = var_Org_Id
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					GROUP BY
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					c047.MPPIType_Id,
					f010.CollectionShift_Id,
					f010.MilkType_Id,
					c016.MilkStatus_Id,
					f010.Dairy_Quantity_Ltr,
					f010.Dairy_Quantity_Kg ,
					f010.Dairy_Fat,
					f010.Dairy_SNF,  
					f010.Dairy_Protein,
					m0022.BaseRate,  
					m0022.MinimumQuantity,
					m0022.MaximumQuantity,
					m0022.MinimumProtein,
					m0022.MaximumProtein
                    
                    UNION ALL
                    
                    SELECT 
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					c047.MPPIType_Id,
					ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
					f010.MilkType_Id,
					c016.MilkStatus_Id,
					f010.Dairy_Quantity_Ltr as Liters,
					f010.Dairy_Quantity_Kg  as Weight,
					f010.Dairy_Fat as Fat,
					f010.Dairy_SNF as SNF,
					ROUND(
						CASE
							WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND f010.Dairy_Ash >= m0022.MinimumAsh 
							AND f010.Dairy_Ash <= m0022.MaximumAsh
						THEN
							m0022.BaseRate
						ELSE
							0
						END,
						2
					) as Rate,
					ROUND(
						CASE
							WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND f010.Dairy_Ash >= m0022.MinimumAsh 
							AND f010.Dairy_Ash <= m0022.MaximumAsh
						THEN
							(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
						ELSE
							0
						END,
						2
					) as Amount

					FROM f010_milkcollectionmcc_final  f010
					INNER JOIN m005_mcc m005 ON
						m005.Org_Id = f010.Org_Id
						AND m005.MCC_Id = f010.MCC_Id
					INNER JOIN c047_mppitype c047 ON
						c047.MPPIType_Id = 'C047007'
					INNER JOIN c016_milkstatus c016 ON
						c016.MilkStatus_Id = 'C016001'
					INNER JOIN m002_commission_mcc m002 ON
						m002.Org_Id = f010.Org_Id
						AND m002.MCC_Id = f010.MCC_Id
						and m002.MPPIType_Id = 'C047007'
						AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
											inner join m002_commission m002 on 
											m002.MPPI_Id = m0021.MPPI_Id 
											and m002.Org_Id = m0021.Org_Id 
											and m002.MilkType_Id = f010.MilkType_Id 
											and m002.MPPIType_Id = m0021.MPPIType_Id
											WHERE m0021.Org_Id = var_Org_Id
											and m0021.MPPIType_Id = 'C047007'
											and m0021.MCC_Id = f010.MCC_Id
											AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
											and m0021.MPPIType_Id = 'C047007'
											and m0021.MCC_Id = f010.MCC_Id
											AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
											order by m0021.Applicable_Date desc limit 1)
					where f010.Org_Id = var_Org_Id
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					GROUP BY
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					c047.MPPIType_Id,
					f010.CollectionShift_Id,
					f010.MilkType_Id,
					c016.MilkStatus_Id,
					f010.Dairy_Quantity_Ltr,
					f010.Dairy_Quantity_Kg ,
					f010.Dairy_Fat,
					f010.Dairy_SNF,  
					f010.Dairy_Ash,
					m0022.BaseRate,  
					m0022.MinimumQuantity,
					m0022.MaximumQuantity,
					m0022.MinimumAsh,
					m0022.MaximumAsh
                    
			)AS CombinedResult
						WHERE CombinedResult.Amount <> 0
							ORDER BY 
								CombinedResult.MCC_Id;


		-- Declare continue handler for cursor
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		
		-- Open cursor
		OPEN cur;
        
		-- Loop to fetch and insert data
		myLoop: LOOP
			-- Fetch data into variables
            
			FETCH cur INTO Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id,
            CollectionShift_Id,MilkType_Id,
			MilkStatus_Id,Liters,Weight,Fat,SNF,Rate,Amount;

			-- Check if there is no more data
			IF done THEN
				LEAVE myLoop;
			END IF;

			-- Generate a new Entry_Id
			SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
			CALL USP_Number_Range('t009_milkcollectiondairy_mcccommission', Year_Id, 'T009', '', New_MilkCollectionMCCCommission_Id);
			
			-- Insert data into the table
			INSERT INTO t009_milkcollectiondairy_mcccommission (
				Org_Id, MilkCollectionMCCCommission_Id, MilkCollectionDairy_Id, 
                MCC_Id, MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
                Liters,Weight,SNF,Fat,BaseRate,Amount
				
			) VALUES (
				Org_Id,New_MilkCollectionMCCCommission_Id,MilkCollectionDairy_Id,
                MCC_Id,MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
                Liters,Weight,SNF,Fat,Rate,Amount
			);
			SET @MusterType_Id = '';
            SET @MusterType_Id = (SELECT m005.MusterType_Id
									FROM m005_mcc_version m005
									WHERE m005.MCC_Id = MCC_Id AND m005.Is_Deleted = 0
									AND m005.Org_Id = Org_Id
									AND m005.Applicable_Date <= now()
									ORDER BY m005.Applicable_Date DESC LIMIT 1);
			SET @MusterType = '';
			SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id);
            
            IF (@MusterType = 1) THEN

				SET @MusterCycle_StartDate = @Current_Datetime;
				SET @MusterCycle_EndDate = @Current_Datetime;

			ELSEIF (@MusterType = 7) THEN

				IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 7) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-07');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 8 AND 14) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-14');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 15 AND 21) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 16 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

				END IF;

			ELSEIF (@MusterType = 15) THEN

				IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');

				ELSE

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

				END IF;

			ELSEIF (@MusterType = 5) THEN

				IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 5) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-05');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 6 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 11 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 16 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 21 AND 25) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-25');
				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 26 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-26');
					SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

				END IF;

			ELSEIF (@MusterType = 10) THEN

				IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 11 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 21 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
					SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

				END IF;

			ELSEIF (@MusterType = 30) THEN

				SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
				SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

			END IF;
            
            UPDATE  t009_milkcollectiondairy_mcccommission t009
			SET 
			t009.MusterType_Id = @MusterType_Id,
            t009.MusterCycle_StartDate = @MusterCycle_StartDate,
            t009.MusterCycle_EndDate = @MusterCycle_EndDate
			WHERE t009.Org_Id = Org_Id
			AND t009.MilkCollectionMCCCommission_Id = New_MilkCollectionMCCCommission_Id;
            
            
		END LOOP;

		-- Close cursor
		CLOSE cur;
        
        SELECT 1 AS Result_Id, 
		'Locked' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
    
	
		
    end;
	elseif (var_Method_Name = 'Create_Commission_Sour') then
    begin 
    DECLARE done INT DEFAULT FALSE;
	DECLARE New_MilkCollectionMCCCommission_Id VARCHAR(20);
    DECLARE Year_Id VARCHAR(20);
    DECLARE Org_Id VARCHAR(10);
	DECLARE MilkCollectionDairy_Id VARCHAR(20);
	DECLARE MCC_Id VARCHAR(20);
	DECLARE MPPIType_Id VARCHAR(20);
	DECLARE CollectionShift_Id VARCHAR(20);
	DECLARE MilkType_Id VARCHAR(20);
	DECLARE MilkStatus_Id VARCHAR(20);
	DECLARE Liters DECIMAL(20, 3);
	DECLARE Weight DECIMAL(20, 3);
	DECLARE Fat DECIMAL(8, 2);
	DECLARE SNF DECIMAL(8, 2);
    DECLARE Rate DECIMAL(20, 2);
	DECLARE Amount DECIMAL(20, 2);
    
    DECLARE cur CURSOR FOR
        -- Your select query here
			SELECT *
			FROM (
			SELECT 
			f010.Org_Id,
			f010.MilkCollectionDairy_Id,
			m005.MCC_Id,
			c047.MPPIType_Id,
			ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
			f010.MilkType_Id,
			c016.MilkStatus_Id,
			f010.Dairy_Quantity_Ltr as Liters,
			f010.Dairy_Quantity_Kg  as Weight,
			f010.Dairy_Fat as Fat,
			f010.Dairy_SNF as SNF,
			ROUND(
				CASE
					WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
					AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
					AND f010.Dairy_Fat >= m0022.MinimumFat
					AND f010.Dairy_Fat <= m0022.MaximumFat
					AND f010.Dairy_SNF >= m0022.MinimumSNF 
					AND f010.Dairy_SNF <= m0022.MaximumSNF
				THEN
					m0022.BaseRate
				ELSE
					0
				END,
				2
			) as Rate,
			ROUND(
				CASE
					WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
					AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
					AND f010.Dairy_Fat >= m0022.MinimumFat
					AND f010.Dairy_Fat <= m0022.MaximumFat
					AND f010.Dairy_SNF >= m0022.MinimumSNF 
					AND f010.Dairy_SNF <= m0022.MaximumSNF
				THEN
					(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
				ELSE
					0
				END,
				2
			) as Amount

			FROM f010_milkcollectionmcc_final_sour  f010
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
									AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
									AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
									order by m0021.Applicable_Date desc limit 1)
			where f010.Org_Id = var_Org_Id
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			GROUP BY
			f010.Org_Id,
			f010.MilkCollectionDairy_Id,
			m005.MCC_Id,
			c047.MPPIType_Id,
			f010.CollectionShift_Id,
			f010.MilkType_Id,
			c016.MilkStatus_Id,
			f010.Dairy_Quantity_Ltr,
			f010.Dairy_Quantity_Kg ,
			f010.Dairy_Fat,
			f010.Dairy_SNF,  
			m0022.BaseRate,  
			m0022.MinimumQuantity,
			m0022.MaximumQuantity,
			m0022.MinimumFat,
			m0022.MaximumFat,
			m0022.MinimumSNF,
			m0022.MaximumSNF

			UNION ALL

			/*
			SELECT 
			f010.Org_Id,
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
			FROM f010_milkcollectionmcc_final_sour  f010
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = f010.Org_Id
				AND m005.MCC_Id = f010.MCC_Id
			INNER JOIN c047_mppitype c047 ON
				c047.MPPIType_Id = 'C047003'
			where f010.Org_Id = var_Org_Id 
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			GROUP BY
			f010.Org_Id,
			f010.MilkCollectionDairy_Id,
			m005.MCC_Id,
			c047.MPPIType_Id,
			f010.CollectionShift_Id,
			f010.MilkType_Id,
			MilkStatus_Id,
			f010.Total_GainLoss
            
            UNION ALL
			*/
				SELECT 
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					'C047004' as MPPIType_Id,
					ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
					f010.MilkType_Id,
					'C016001' as MilkStatus_Id,
					f010.Dairy_Quantity_Ltr as Liters,
					f010.Dairy_Quantity_Kg  as Weight,
					'0' as FAT,
					'0' as SNF,   
					m0051.Anamat_PerLtr as Rate,
					(m0051.Anamat_PerLtr * f010.Dairy_Quantity_Ltr) as Amount
					FROM f010_milkcollectionmcc_final_sour  f010
					INNER JOIN m005_mcc m005 ON
						m005.Org_Id = f010.Org_Id
						AND m005.MCC_Id = f010.MCC_Id
                    
					INNER JOIN 
							temp_anamat max_dates ON f010.Org_Id = max_dates.Org_Id 
													 AND f010.MCC_Id = max_dates.MCC_Id 
                    INNER JOIN 
							m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
													and m0051.Is_Active = 1
													 AND m0051.MCC_Id = max_dates.MCC_Id 
													 AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
													 AND m0051.Anamat_Applicable_To = 'MCC'
					-- INNER JOIN c047_mppitype c047 ON
						-- c047.MPPIType_Id = 'C047004'
					where f010.Org_Id =  var_Org_Id
                    and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					GROUP BY
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					-- c047.MPPIType_Id,
					f010.CollectionShift_Id,
					f010.MilkType_Id,
					MilkStatus_Id,
					m0051.Anamat_PerLtr,
					f010.Dairy_Quantity_Ltr,
					f010.Dairy_Quantity_Kg
					
					UNION ALL
					
					SELECT 
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					'C047005' as MPPIType_Id,
					ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
					f010.MilkType_Id,
					'C016001' as MilkStatus_Id,
					f010.Dairy_Quantity_Ltr as Liters,
					f010.Dairy_Quantity_Kg  as Weight,
					'0' as FAT,
					'0' as SNF,   
					m0051.Freight_PerLtr as Rate,
					(m0051.Freight_PerLtr * f010.Dairy_Quantity_Ltr) as Amount
					FROM f010_milkcollectionmcc_final_sour  f010
					INNER JOIN m005_mcc m005 ON
						m005.Org_Id = f010.Org_Id
						AND m005.MCC_Id = f010.MCC_Id
                                                     
					INNER JOIN 
							temp_freight max_dates ON f010.Org_Id = max_dates.Org_Id 
													 AND f010.MCC_Id = max_dates.MCC_Id 
                    INNER JOIN 
							m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
													and m0051.Is_Active = 1
													 AND m0051.MCC_Id = max_dates.MCC_Id 
													 AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
													 AND m0051.Freight_Applicable_To = 'MCC'
					-- INNER JOIN c047_mppitype c047 ON
						-- c047.MPPIType_Id = 'C047005'
					where f010.Org_Id = var_Org_Id
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					GROUP BY
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					-- c047.MPPIType_Id,
					f010.CollectionShift_Id,
					f010.MilkType_Id,
					MilkStatus_Id,
					m0051.Freight_PerLtr,
					f010.Dairy_Quantity_Ltr,
					f010.Dairy_Quantity_Kg
                    
                    UNION ALL
                    
                    SELECT 
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					c047.MPPIType_Id,
					ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
					f010.MilkType_Id,
					c016.MilkStatus_Id,
					f010.Dairy_Quantity_Ltr as Liters,
					f010.Dairy_Quantity_Kg  as Weight,
					f010.Dairy_Fat as Fat,
					f010.Dairy_SNF as SNF,
					ROUND(
						CASE
							WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) >= m0022.MinimumProtein 
							AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) <= m0022.MaximumProtein
						THEN
							m0022.BaseRate
						ELSE
							0
						END,
						2
					) as Rate,
					ROUND(
						CASE
							WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) >= m0022.MinimumProtein 
							AND ((f010.Dairy_Protein / f010.Dairy_SNF)*100) <= m0022.MaximumProtein
						THEN
							(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
						ELSE
							0
						END,
						2
					) as Amount

					FROM f010_milkcollectionmcc_final_sour  f010
					INNER JOIN m005_mcc m005 ON
						m005.Org_Id = f010.Org_Id
						AND m005.MCC_Id = f010.MCC_Id
					INNER JOIN c047_mppitype c047 ON
						c047.MPPIType_Id = 'C047006'
					INNER JOIN c016_milkstatus c016 ON
						c016.MilkStatus_Id = 'C016001'
					INNER JOIN m002_commission_mcc m002 ON
						m002.Org_Id = f010.Org_Id
						AND m002.MCC_Id = f010.MCC_Id
						and m002.MPPIType_Id = 'C047006'
						AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
											inner join m002_commission m002 on 
											m002.MPPI_Id = m0021.MPPI_Id 
											and m002.Org_Id = m0021.Org_Id 
											and m002.MilkType_Id = f010.MilkType_Id 
											and m002.MPPIType_Id = m0021.MPPIType_Id
											WHERE m0021.Org_Id = var_Org_Id
											and m0021.MPPIType_Id = 'C047006'
											and m0021.MCC_Id = f010.MCC_Id
											AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
											and m0021.MPPIType_Id = 'C047006'
											and m0021.MCC_Id = f010.MCC_Id
											AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
											order by m0021.Applicable_Date desc limit 1)
					where f010.Org_Id = var_Org_Id
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					GROUP BY
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					c047.MPPIType_Id,
					f010.CollectionShift_Id,
					f010.MilkType_Id,
					c016.MilkStatus_Id,
					f010.Dairy_Quantity_Ltr,
					f010.Dairy_Quantity_Kg ,
					f010.Dairy_Fat,
					f010.Dairy_SNF,  
					f010.Dairy_Protein,
					m0022.BaseRate,  
					m0022.MinimumQuantity,
					m0022.MaximumQuantity,
					m0022.MinimumProtein,
					m0022.MaximumProtein
                    
                    UNION ALL
                    
                    SELECT 
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					c047.MPPIType_Id,
					ifnull(f010.CollectionShift_Id ,'') as CollectionShift_Id,
					f010.MilkType_Id,
					c016.MilkStatus_Id,
					f010.Dairy_Quantity_Ltr as Liters,
					f010.Dairy_Quantity_Kg  as Weight,
					f010.Dairy_Fat as Fat,
					f010.Dairy_SNF as SNF,
					ROUND(
						CASE
							WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND f010.Dairy_Ash >= m0022.MinimumAsh 
							AND f010.Dairy_Ash <= m0022.MaximumAsh
						THEN
							m0022.BaseRate
						ELSE
							0
						END,
						2
					) as Rate,
					ROUND(
						CASE
							WHEN IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) >= m0022.MinimumQuantity
							AND IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) <= m0022.MaximumQuantity
							AND f010.Dairy_Ash >= m0022.MinimumAsh 
							AND f010.Dairy_Ash <= m0022.MaximumAsh
						THEN
							(m0022.BaseRate * IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0)) 
						ELSE
							0
						END,
						2
					) as Amount

					FROM f010_milkcollectionmcc_final_sour  f010
					INNER JOIN m005_mcc m005 ON
						m005.Org_Id = f010.Org_Id
						AND m005.MCC_Id = f010.MCC_Id
					INNER JOIN c047_mppitype c047 ON
						c047.MPPIType_Id = 'C047007'
					INNER JOIN c016_milkstatus c016 ON
						c016.MilkStatus_Id = 'C016001'
					INNER JOIN m002_commission_mcc m002 ON
						m002.Org_Id = f010.Org_Id
						AND m002.MCC_Id = f010.MCC_Id
						and m002.MPPIType_Id = 'C047007'
						AND m002.Entry_Id = (SELECT m0021.Entry_Id FROM m002_commission_mcc m0021
											inner join m002_commission m002 on 
											m002.MPPI_Id = m0021.MPPI_Id 
											and m002.Org_Id = m0021.Org_Id 
											and m002.MilkType_Id = f010.MilkType_Id 
											and m002.MPPIType_Id = m0021.MPPIType_Id
											WHERE m0021.Org_Id = var_Org_Id
											and m0021.MPPIType_Id = 'C047007'
											and m0021.MCC_Id = f010.MCC_Id
											AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
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
											and m0021.MPPIType_Id = 'C047007'
											and m0021.MCC_Id = f010.MCC_Id
											AND m0021.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
											order by m0021.Applicable_Date desc limit 1)
					where f010.Org_Id = var_Org_Id
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					GROUP BY
					f010.Org_Id,
					f010.MilkCollectionDairy_Id,
					m005.MCC_Id,
					c047.MPPIType_Id,
					f010.CollectionShift_Id,
					f010.MilkType_Id,
					c016.MilkStatus_Id,
					f010.Dairy_Quantity_Ltr,
					f010.Dairy_Quantity_Kg ,
					f010.Dairy_Fat,
					f010.Dairy_SNF,  
					f010.Dairy_Ash,
					m0022.BaseRate,  
					m0022.MinimumQuantity,
					m0022.MaximumQuantity,
					m0022.MinimumAsh,
					m0022.MaximumAsh
                    
			)AS CombinedResult
						WHERE CombinedResult.Amount <> 0
							ORDER BY 
								CombinedResult.MCC_Id;


		-- Declare continue handler for cursor
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		
		-- Open cursor
		OPEN cur;
        
		-- Loop to fetch and insert data
		myLoop: LOOP
			-- Fetch data into variables
            
			FETCH cur INTO Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id,
            CollectionShift_Id,MilkType_Id,
			MilkStatus_Id,Liters,Weight,Fat,SNF,Rate,Amount;

			-- Check if there is no more data
			IF done THEN
				LEAVE myLoop;
			END IF;

			-- Generate a new Entry_Id
			SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
			CALL USP_Number_Range('t009_milkcollectiondairy_mcccommission', Year_Id, 'T009', '', New_MilkCollectionMCCCommission_Id);
			
			-- Insert data into the table
			INSERT INTO t009_milkcollectiondairy_mcccommission (
				Org_Id, MilkCollectionMCCCommission_Id, MilkCollectionDairy_Id, 
                MCC_Id, MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
                Liters,Weight,SNF,Fat,BaseRate,Amount,Is_Sour_Check
				
			) VALUES (
				Org_Id,New_MilkCollectionMCCCommission_Id,MilkCollectionDairy_Id,
                MCC_Id,MPPIType_Id,CollectionShift_Id,MilkType_Id,MilkStatus_Id,
                Liters,Weight,SNF,Fat,Rate,Amount,1
			);
			SET @MusterType_Id = '';
            SET @MusterType_Id = (SELECT m005.MusterType_Id
									FROM m005_mcc_version m005
									WHERE m005.MCC_Id = MCC_Id AND m005.Is_Deleted = 0
									AND m005.Org_Id = Org_Id
									AND m005.Applicable_Date <= now()
									ORDER BY m005.Applicable_Date DESC LIMIT 1);
			SET @MusterType = '';
			SET @MusterType = (SELECT MusterType FROM c022_mustertype WHERE MusterType_Id = @MusterType_Id);
            
            IF (@MusterType = 1) THEN

				SET @MusterCycle_StartDate = @Current_Datetime;
				SET @MusterCycle_EndDate = @Current_Datetime;

			ELSEIF (@MusterType = 7) THEN

				IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 7) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-07');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 8 AND 14) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-14');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 15 AND 21) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 16 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

				END IF;

			ELSEIF (@MusterType = 15) THEN

				IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');

				ELSE

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
					SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

				END IF;

			ELSEIF (@MusterType = 5) THEN

				IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 5) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-05');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 6 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 11 AND 15) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 16 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 21 AND 25) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-25');
				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 26 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-26');
					SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

				END IF;

			ELSEIF (@MusterType = 10) THEN

				IF (DATE_FORMAT(NOW(), '%d') BETWEEN 1 AND 10) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-10');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 11 AND 20) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
					SET @MusterCycle_EndDate = DATE_FORMAT(CURDATE(), '%Y-%m-20');

				ELSEIF (DATE_FORMAT(NOW(), '%d') BETWEEN 21 AND 31) THEN

					SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
					SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

				END IF;

			ELSEIF (@MusterType = 30) THEN

				SET @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
				SET @MusterCycle_EndDate = LAST_DAY(CURDATE());

			END IF;
            
            UPDATE  t009_milkcollectiondairy_mcccommission t009
			SET 
			t009.MusterType_Id = @MusterType_Id,
            t009.MusterCycle_StartDate = @MusterCycle_StartDate,
            t009.MusterCycle_EndDate = @MusterCycle_EndDate
			WHERE t009.Org_Id = Org_Id
			AND t009.MilkCollectionMCCCommission_Id = New_MilkCollectionMCCCommission_Id;
            
            
		END LOOP;

		-- Close cursor
		CLOSE cur;
        
        SELECT 1 AS Result_Id, 
		'Locked' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
    
	
		
    end;
    elseif (var_Method_Name = 'Delete_MCC') then
    begin
		delete from f010_milkcollectionmcc_final where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
        delete from f010_milkcollectionmcc_final_sour where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
        delete from f010_milkcollectionmcc_final_sour_main where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
        delete from f010_milkcollectionmcc_final_sour_mcc where Org_Id = var_Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
		SELECT 1 AS Result_Id, 
		'Locked' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
    end;
    elseif (var_Method_Name = 'Delete_Commission') then
    begin
		delete from t009_milkcollectiondairy_mcccommission where var_Org_Id = Org_Id and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
		SELECT 1 AS Result_Id, 
		'Locked' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
    end;
    
    elseif (var_Method_Name = 'Create_BulkSupplier') then
		begin
        
		DECLARE done INT DEFAULT FALSE;
		DECLARE New_Entry_Id VARCHAR(20);
        declare var_BaseFat decimal(10,2);
		declare var_BaseSNF decimal(10,2);
		declare var_BaseRate decimal(20,2);
		declare var_RatioFat decimal(10,2);
		declare var_RatioSNF decimal(10,2);
        DECLARE Year_Id VARCHAR(20);
		DECLARE Org_Id VARCHAR(10);
		DECLARE MilkCollectionDairy_Id VARCHAR(20);
		DECLARE Created_On DATETIME;
		DECLARE MCC_Id VARCHAR(20);
		DECLARE MilkType_Id VARCHAR(20);
		DECLARE Agent_Quantity_Kg DECIMAL(20, 3);
		DECLARE Agent_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Agent_Fat DECIMAL(8, 2);
		DECLARE Agent_SNF DECIMAL(8, 2);
		DECLARE Dairy_Quantity_Kg DECIMAL(20, 3);
		DECLARE Dairy_Quantity_Ltr DECIMAL(20, 3);
		DECLARE Dairy_Fat DECIMAL(8, 2);
		DECLARE Dairy_SNF DECIMAL(8, 2);
        DECLARE var_Dairy_Protein DECIMAL(8, 2);
		DECLARE var_Dairy_Ash DECIMAL(8, 2);
        DECLARE var_Dairy_Sodium DECIMAL(8, 2);
        
        DECLARE cur CURSOR FOR
        -- Your select query here
			select 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0091.MCC_Id,
			t0091.MilkType_Id,
			Roundoff('Quantity', sum(t0091.Weight)) as Agent_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0091.Liters)) as Agent_Quantity_Ltr,
			Roundoff('Quality', (sum(t0091.Liters * t0092.Fat))/sum(t0091.Liters))  as Agent_Fat,
			Roundoff('Quality', (sum(t0091.Liters * t0092.SNF))/sum(t0091.Liters)) as Agent_SNF,
			Roundoff('Quantity', sum(t0091.Weight))	as Dairy_Quantity_Kg,
			Roundoff('QuantityForDairy',  sum(t0091.Liters)) as Dairy_Quantity_Ltr,
			Roundoff('Quality', (sum(t0091.Liters * t0092.Fat))/sum(t0091.Liters)) as Dairy_Fat,
			Roundoff('Quality', (sum(t0091.Liters * t0092.SNF))/sum(t0091.Liters)) as Dairy_SNF,
            Roundoff('Quality', (sum(t0091.Liters * ifnull(t0092.Protein,0))) / sum(t0091.Liters)) as var_Dairy_Protein,
			Roundoff('Quality', (sum(t0091.Liters * ifnull(t0092.Ash,0))) / sum(t0091.Liters))  as var_Dairy_Ash,
			Roundoff('Quality', (sum(t0091.Liters * ifnull(t0092.Sodium,0))) / sum(t0091.Liters))  as var_Dairy_Sodium
			from t009_milkcollectiondairy_header t009
			inner join t009_milkcollectiondairy_quantity t0091 on
			t009.Org_Id = t0091.Org_Id
			and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
            AND t0091.MilkStatus_Id = 'C016001'
			inner join t009_milkcollectiondairy_quality t0092 on
			t009.Org_Id = t0092.Org_Id
			and t009.MilkCollectionDairy_Id = t0092.MilkCollectionDairy_Id
			and t0091.MCC_Id = t0092.MCC_Id
            and t0091.CellNo = t0092.CellNo
            AND t0092.MilkStatus_Id = 'C016001'
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by 
			t009.Org_Id,
			t009.MilkCollectionDairy_Id, 
			t009.Created_On, 
			t0091.MCC_Id,
			t0091.MilkType_Id;

		-- Declare continue handler for cursor
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		
		-- Open cursor
		OPEN cur;
        
		-- Loop to fetch and insert data
		myLoop: LOOP
			-- Fetch data into variables
			FETCH cur INTO Org_Id, MilkCollectionDairy_Id, Created_On, MCC_Id, MilkType_Id,
				Agent_Quantity_Kg, Agent_Quantity_Ltr, Agent_Fat, Agent_SNF,
				Dairy_Quantity_Kg, Dairy_Quantity_Ltr, Dairy_Fat, Dairy_SNF,
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium;

			-- Check if there is no more data
			IF done THEN
				LEAVE myLoop;
			END IF;

			-- Generate a new Entry_Id
			SET Year_Id = RIGHT(LEFT(CURDATE(), 4), 2);
			CALL USP_Number_Range('f010_milkcollectionmcc_final', Year_Id, 'F010', '', New_Entry_Id);
			
			-- Insert data into the table
			INSERT INTO f010_milkcollectionmcc_final (
				Org_Id, Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Collection_Date, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				Dairy_Fat, Dairy_SNF,MilkCollectionPosting_Id,
                Dairy_Protein,Dairy_Ash,Dairy_Sodium
			) VALUES (
				Org_Id, New_Entry_Id, MilkCollectionDairy_Id, MCC_Id, MilkType_Id,
				Created_On, Agent_Quantity_Kg, Agent_Quantity_Ltr,
				Agent_Fat, Agent_SNF, Dairy_Quantity_Kg, Dairy_Quantity_Ltr,
				Dairy_Fat, Dairy_SNF,'',
                var_Dairy_Protein,var_Dairy_Ash,var_Dairy_Sodium
			);
            
            
            -- set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,'', Created_On,MilkType_Id);
                                
			set @var_Chart_Id =  GetMilkBaseRate(Org_Id,MCC_Id,'', now(),MilkType_Id);
			select BaseFat,BaseSNF,Amount into var_BaseFat,var_BaseSNF,var_BaseRate
			from m001_milkrate_item where Org_Id = Org_Id
			and Chart_Id = @var_Chart_Id
			and MilkRateEntryType_Id ='C012001'
			-- and Applicable_Date <= Created_On 
            and Applicable_Date <= now() 
			order by Applicable_Date desc limit 1;
            
            SELECT Fat,SNF into var_RatioFat,var_RatioSNF  FROM t024_fatsnf_ratio 
				where Ratio_Date <= now() 
				and Org_Id = Org_Id
				and Is_Active = 1
				and Is_Deleted = 0
				order by Ratio_Date DESC Limit 1;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Agent_Fat_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_Fat) /100),
			f010.Agent_SNF_Kg = ((f010.Agent_Quantity_Kg * f010.Agent_SNF) /100)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Dairy_Fat_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_Fat) /100),
			f010.Dairy_SNF_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_SNF) /100)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.FatKG_GainLoss = (f010.Dairy_Fat_Kg - f010.Agent_Fat_Kg),
			f010.SNFKG_GainLoss = (f010.Dairy_SNF_Kg - f010.Agent_SNF_Kg)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            /*
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.FatKG_Rate = ((var_BaseRate * var_RatioFat ) / var_BaseFat),
			f010.SNFKG_Rate = ((var_BaseRate * var_RatioSNF ) / var_BaseSNF)
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            */
            
            UPDATE f010_milkcollectionmcc_final f010
			SET 
				f010.FatKG_Rate = CASE 
									WHEN var_BaseFat = 0 THEN 0
									ELSE (var_BaseRate * var_RatioFat) / var_BaseFat
								  END,
				f010.SNFKG_Rate = ((var_BaseRate * var_RatioSNF) / var_BaseSNF)
			WHERE f010.Org_Id = Org_Id
			  AND f010.Entry_Id = New_Entry_Id;

            /*
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Total_GainLoss = ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            */
            
            UPDATE  f010_milkcollectionmcc_final f010
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = f010.Org_Id
				AND m005.MCC_Id = f010.MCC_Id
			SET 
			f010.Total_GainLoss = CASE 
									WHEN m005.MCCWorkType_Id = 'C023001' THEN 0
									ELSE ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
								END
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            
            
            UPDATE  f010_milkcollectionmcc_final f010
            inner join m005_mcc m005
			on m005.Org_Id = f010.Org_Id 
            and m005.MCC_Id = MCC_Id 
			SET 
			f010.Plant_Code = m005.Plant_Code
			WHERE f010.Org_Id = Org_Id
			AND f010.Entry_Id = New_Entry_Id;
            

		END LOOP;

		-- Close cursor
		CLOSE cur;
        
        SELECT 1 AS Result_Id, 
		'Locked' AS Result_Description, 
		var_MilkCollectionDairy_Id AS Result_Extra_Key;
			
        end;
	elseif (var_Method_Name = 'Create_GainLoss') then
		begin
			SET SQL_SAFE_UPDATES = 0;
			DROP TEMPORARY TABLE IF EXISTS temp_gain_loss;
			CREATE TEMPORARY TABLE temp_gain_loss ( 
			Org_Id varchar(20), MilkCollectionPosting_Id varchar(20), 
            Total_GainLoss decimal(20,2),
            MilkPrice decimal(20,2)
            );
			
			Insert into temp_gain_loss (
			Org_Id,MilkCollectionPosting_Id
			)
			select Org_Id, MilkCollectionPosting_Id
			from f010_milkcollectionmcc_final where 
			Org_Id = var_Org_Id
			AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by Org_Id,MilkCollectionPosting_Id;
            
             
            Update temp_gain_loss t
				set 
				t.Total_GainLoss = (SELECT SUM(IFNULL(f010_sub.Total_GainLoss, 0))
							FROM (
								SELECT f010.Total_GainLoss, f010.MilkCollectionPosting_Id
								FROM f010_milkcollectionmcc_final f010
								WHERE t.Org_Id = f010.Org_Id
									AND t.MilkCollectionPosting_Id = f010.MilkCollectionPosting_Id
							) f010_sub
							GROUP BY f010_sub.MilkCollectionPosting_Id),
				t.MilkPrice = (SELECT SUM(IFNULL(f010_sub.MilkPrice, 0))
							FROM (
								SELECT f010.MilkPrice, f010.MilkCollectionPosting_Id
								FROM f010_milkcollectionmcc_final f010
								WHERE t.Org_Id = f010.Org_Id
									AND t.MilkCollectionPosting_Id = f010.MilkCollectionPosting_Id
							) f010_sub
							GROUP BY f010_sub.MilkCollectionPosting_Id)
				where t.Org_Id = var_Org_Id;
                
			
            UPDATE t009_milkcollectiondairy_posting t009
			INNER JOIN temp_gain_loss t ON
				t009.Org_Id = t.Org_Id
				AND t009.MilkCollectionPosting_Id = t.MilkCollectionPosting_Id
			SET t009.MilkPrice = t.MilkPrice,
				t009.Total_GainLoss = 0
			WHERE t.Org_Id = var_Org_Id;
            
            
            UPDATE t009_milkcollectiondairy_posting t009
			INNER JOIN temp_gain_loss t ON
				t009.Org_Id = t.Org_Id
				AND t009.MilkCollectionPosting_Id = t.MilkCollectionPosting_Id
			SET t009.Original_MilkPrice = t009.MilkPrice,
				t009.Total_GainLoss = 0
			WHERE t.Org_Id = var_Org_Id;
            
            
            UPDATE t009_milkcollectiondairy_posting t009
            INNER JOIN temp_gain_loss t ON
				t009.Org_Id = t.Org_Id
				AND t009.MilkCollectionPosting_Id = t.MilkCollectionPosting_Id
			SET t009.MilkPrice = t009.Original_MilkPrice + t009.Total_GainLoss
			WHERE t.Org_Id = var_Org_Id;
            
			
            
            UPDATE t009_milkcollectiondairy_posting t009
            INNER JOIN temp_gain_loss t ON
				t009.Org_Id = t.Org_Id
				AND t009.MilkCollectionPosting_Id = t.MilkCollectionPosting_Id
			SET t009.TotalLandedCost = ifnull(t009.MilkPrice,0)  +  ifnull(t009.TransporterCost,0) +  ifnull(t009.AgentCost,0) 
			WHERE t.Org_Id = var_Org_Id;
            
            
			UPDATE t009_milkcollectiondairy_posting t009
            INNER JOIN temp_gain_loss t ON
				t009.Org_Id = t.Org_Id
				AND t009.MilkCollectionPosting_Id = t.MilkCollectionPosting_Id
			SET t009.Original_FatRate = t009.FatRate,
            t009.Original_FatValue = t009.FatValue,
            t009.Original_SNFRate = t009.SNFRate,
            t009.Original_SNFValue = t009.SNFValue
			WHERE t.Org_Id = var_Org_Id;
            
            Update t009_milkcollectiondairy_posting t009
            INNER JOIN temp_gain_loss t ON
				t009.Org_Id = t.Org_Id
				AND t009.MilkCollectionPosting_Id = t.MilkCollectionPosting_Id
			set 
			t009.FatRate = (t009.TotalLandedCost /t009.FEQ)
			where t009.Org_Id = var_Org_Id ;
			
			Update t009_milkcollectiondairy_posting t009
            INNER JOIN temp_gain_loss t ON
				t009.Org_Id = t.Org_Id
				AND t009.MilkCollectionPosting_Id = t.MilkCollectionPosting_Id
			set 
			t009.FatValue = (t009.FatKG *t009.FatRate )
			where t009.Org_Id = var_Org_Id;
			
			Update t009_milkcollectiondairy_posting t009
            INNER JOIN temp_gain_loss t ON
				t009.Org_Id = t.Org_Id
				AND t009.MilkCollectionPosting_Id = t.MilkCollectionPosting_Id
			set 
			t009.SNFValue = (t009.TotalLandedCost -t009.FatValue)
			where t009.Org_Id = var_Org_Id;
			
			Update t009_milkcollectiondairy_posting t009
            INNER JOIN temp_gain_loss t ON
				t009.Org_Id = t.Org_Id
				AND t009.MilkCollectionPosting_Id = t.MilkCollectionPosting_Id
			set 
			t009.SNFRate = (t009.SNFValue / t009.SNFKG)
			where t009.Org_Id = var_Org_Id;
            
            SELECT 1 AS Result_Id, 
			'Locked' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Create_Rate') then
		begin
			-- MilkPrice is null then
			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id,'C015003', f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where  m5.MCCType_Id = 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where  m5.MCCType_Id = 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            
            update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            update f010_milkcollectionmcc_final_sour f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id,'C015003', f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where  m5.MCCType_Id = 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where  m5.MCCType_Id = 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            
            update f010_milkcollectionmcc_final_sour f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id,'C015003', f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where  m5.MCCType_Id = 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where  m5.MCCType_Id = 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            
            update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            
            
            update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id,'C015003', f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where  m5.MCCType_Id = 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where  m5.MCCType_Id = 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            
            update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_main f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 


			update f010_milkcollectionmcc_final_sour_mcc f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id,'C015003', f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where  m5.MCCType_Id = 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_mcc f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where  m5.MCCType_Id = 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_mcc f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_mcc f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            
            update f010_milkcollectionmcc_final_sour_mcc f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 

			update f010_milkcollectionmcc_final_sour_mcc f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023002' and m5.MCCType_Id <> 'C014003' 
            and f10.Org_Id = var_Org_Id
			AND f10.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
            delete from bk_f010_milkcollectionmcc_final 
            where Org_Id = var_Org_Id 
            and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
            INSERT INTO bk_f010_milkcollectionmcc_final
            (
            Org_Id   ,
			Entry_Id   ,
			MilkCollectionDairy_Id  ,
			MCC_Id  ,
			CollectionShift_Id  ,
			MilkType_Id  ,
			Collection_Date ,
			Agent_Quantity_Kg ,
			Agent_Quantity_Ltr ,
			Agent_Fat ,
			Agent_SNF ,
			Agent_Fat_Kg  ,
			Agent_SNF_Kg  ,
			Dairy_Quantity_Kg ,
			Dairy_Quantity_Ltr ,
			Dairy_Fat ,
			Dairy_SNF ,
            Dairy_Protein,
            Dairy_Ash,
            Dairy_Sodium,
			Dairy_Fat_Kg  ,
			Dairy_SNF_Kg  ,
			FatKG_GainLoss ,
			SNFKG_GainLoss ,
			FatKG_Rate ,
			SNFKG_Rate ,
			Total_GainLoss ,
			MilkCollectionPosting_Id  ,
			AgentCost  ,
			TransporterCost  ,
			MilkPrice  ,
			MilkRate ,
			Plant_Code  ,
			Dairy_Sour_Ltr 
            )
            select 
            Org_Id,
			Entry_Id,
			MilkCollectionDairy_Id,
			MCC_Id,
			ifnull(CollectionShift_Id,'') as CollectionShift_Id,
			MilkType_Id,
			Collection_Date,
			ifnull(Agent_Quantity_Kg,'0') as Agent_Quantity_Kg,
			ifnull(Agent_Quantity_Ltr,'0') as Agent_Quantity_Ltr,
			ifnull(Agent_Fat,'0') as Agent_Fat,
			ifnull(Agent_SNF,'0') as Agent_SNF,
			ifnull(Agent_Fat_Kg,'0') as Agent_Fat_Kg,
			ifnull(Agent_SNF_Kg,'0') as Agent_SNF_Kg,
			ifnull(Dairy_Quantity_Kg,'0') as Dairy_Quantity_Kg,
			ifnull(Dairy_Quantity_Ltr,'0') as Dairy_Quantity_Ltr,
			ifnull(Dairy_Fat,'0') as Dairy_Fat,
			ifnull(Dairy_SNF,'0') as Dairy_SNF,
            
            ifnull(Dairy_Protein,'0') as Dairy_Protein,
            ifnull(Dairy_Ash,'0') as Dairy_Ash,
            ifnull(Dairy_Sodium,'0') as Dairy_Sodium,
            
			ifnull(Dairy_Fat_Kg,'0') as Dairy_Fat_Kg,
			ifnull(Dairy_SNF_Kg,'0') as Dairy_SNF_Kg,
			ifnull(FatKG_GainLoss,'0') as FatKG_GainLoss,
			ifnull(SNFKG_GainLoss,'0') as SNFKG_GainLoss,
			ifnull(FatKG_Rate,'0') as FatKG_Rate,
			ifnull(SNFKG_Rate,'0') as SNFKG_Rate,
			ifnull(Total_GainLoss,'0') as Total_GainLoss,
			ifnull(MilkCollectionPosting_Id,'0') as MilkCollectionPosting_Id,
			ifnull(AgentCost,'0') as AgentCost,
			ifnull(TransporterCost,'0') as TransporterCost,
			ifnull(MilkPrice,'0') as MilkPrice,
			ifnull(MilkRate,'0') as MilkRate,
			ifnull(Plant_Code,'') as Plant_Code,
			ifnull(Dairy_Sour_Ltr,'0') as Dairy_Sour_Ltr
			from f010_milkcollectionmcc_final
            where
			Org_Id = var_Org_Id 
			AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
            
             SELECT 1 AS Result_Id, 
			'Rate' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
        end;
		elseif (var_Method_Name = 'Clear_Ash') then
		begin
        
			DROP TEMPORARY TABLE IF EXISTS temp_Report;

			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), 
			MCC_Id varchar(20),
			MPPIType_Id varchar(20),
			MaxAmount decimal(30,3));

			insert into temp_Report (Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id,MaxAmount)
			SELECT MPPI.Org_Id,MPPI.MilkCollectionDairy_Id,MPPI.MCC_Id,MPPI.MPPIType_Id,MaxAmount
			FROM (
			select 
			Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id ,
			MAX(Amount) AS MaxAmount,
			count(MPPIType_Id) as MPPITypeCount
			from t009_milkcollectiondairy_mcccommission
			where 
			Org_Id = var_Org_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and MPPIType_Id ='C047007'
			and Is_Sour_Check = 0
			group by Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id
			having MPPITypeCount >= 2
			) as MPPI;

			DELETE t009 from t009_milkcollectiondairy_mcccommission t009
			inner join temp_Report tmp on
			tmp.Org_Id = t009.Org_Id
			and tmp.Org_Id = t009.Org_Id
			and tmp.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and tmp.MCC_Id = t009.MCC_Id
			and tmp.MPPIType_Id = t009.MPPIType_Id
			and tmp.MaxAmount = t009.Amount
			where 
			t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.MPPIType_Id ='C047007'
			and t009.Is_Sour_Check = 0;
            
            SELECT 1 AS Result_Id, 
			'Clear' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Clear_Protein') then
		begin
        
			DROP TEMPORARY TABLE IF EXISTS temp_Report;

			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), 
			MCC_Id varchar(20),
			MPPIType_Id varchar(20),
			MaxAmount decimal(30,3));

			insert into temp_Report (Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id,MaxAmount)
			SELECT MPPI.Org_Id,MPPI.MilkCollectionDairy_Id,MPPI.MCC_Id,MPPI.MPPIType_Id,MaxAmount
			FROM (
			select 
			Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id ,
			MAX(Amount) AS MaxAmount,
			count(MPPIType_Id) as MPPITypeCount
			from t009_milkcollectiondairy_mcccommission
			where 
			Org_Id = var_Org_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and MPPIType_Id ='C047006'
			and Is_Sour_Check = 0
			group by Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id
			having MPPITypeCount >= 2
			) as MPPI;

			DELETE t009 from t009_milkcollectiondairy_mcccommission t009
			inner join temp_Report tmp on
			tmp.Org_Id = t009.Org_Id
			and tmp.Org_Id = t009.Org_Id
			and tmp.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and tmp.MCC_Id = t009.MCC_Id
			and tmp.MPPIType_Id = t009.MPPIType_Id
			and tmp.MaxAmount = t009.Amount
			where 
			t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.MPPIType_Id ='C047006'
			and t009.Is_Sour_Check = 0;
            
            SELECT 1 AS Result_Id, 
			'Clear' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Clear_Data') then
		begin
        
			DROP TEMPORARY TABLE IF EXISTS temp_Report;

			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), 
			MCC_Id varchar(20),
			MaxAmount decimal(30,3));

			insert into temp_Report (Org_Id,MilkCollectionDairy_Id,MCC_Id,MaxAmount)
			SELECT MPPI.Org_Id,MPPI.MilkCollectionDairy_Id,MPPI.MCC_Id,MaxAmount
			FROM (
			select 
			Org_Id,MilkCollectionDairy_Id,MCC_Id,
			MAX(Amount) AS MaxAmount,
			count(MPPIType_Id) as MPPITypeCount
			from t009_milkcollectiondairy_mcccommission
			where 
			Org_Id = var_Org_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and MPPIType_Id in('C047007','C047006')
			and Is_Sour_Check = 0
			group by Org_Id,MilkCollectionDairy_Id,MCC_Id
			having MPPITypeCount >= 2
			) as MPPI;
            
            DROP TEMPORARY TABLE IF EXISTS temp_Report_2;

			CREATE TEMPORARY TABLE temp_Report_2 ( 
			MilkCollectionMCCCommission_Id varchar(20));

			insert into temp_Report_2 (MilkCollectionMCCCommission_Id)
			select t009.MilkCollectionMCCCommission_Id 
            from t009_milkcollectiondairy_mcccommission t009
			inner join temp_Report tmp on
			tmp.Org_Id = t009.Org_Id
			and tmp.Org_Id = t009.Org_Id
			and tmp.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and tmp.MCC_Id = t009.MCC_Id
			and tmp.MaxAmount = t009.Amount
			where 
			t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.MPPIType_Id in('C047007','C047006')
			and t009.Is_Sour_Check = 0
            /*
            AND t009.MilkCollectionMCCCommission_Id = (
				SELECT MIN(t.MilkCollectionMCCCommission_Id)
				FROM t009_milkcollectiondairy_mcccommission t
				WHERE t.Org_Id = t.Org_Id
				AND t.MilkCollectionDairy_Id = t.MilkCollectionDairy_Id
				AND t.MCC_Id = t.MCC_Id
				AND t.Amount = t.Amount
                and t.Org_Id = var_Org_Id
				and t.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				and t.MPPIType_Id in('C047007','C047006')
				and t.Is_Sour_Check = 0
			)
            */
            ;
            
            DELETE t009 from t009_milkcollectiondairy_mcccommission t009
			where 
			t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.MPPIType_Id in('C047007','C047006')
			and t009.Is_Sour_Check = 0
            and t009.MilkCollectionMCCCommission_Id in (select MilkCollectionMCCCommission_Id from temp_Report_2);
            
            			INSERT INTO f010_milkcollectionmcc_final(
			Org_Id  ,
			Entry_Id ,  
			MilkCollectionDairy_Id , 
			MCC_Id , 
			CollectionShift_Id , 
			MilkType_Id , 
			Collection_Date , 
			Agent_Quantity_Kg , 
			Agent_Quantity_Ltr , 
			Agent_Fat ,
			Agent_SNF ,
			Agent_Fat_Kg , 
			Agent_SNF_Kg , 
			Dairy_Quantity_Kg , 
			Dairy_Quantity_Ltr , 
			Dairy_Fat ,
			Dairy_SNF ,
			Dairy_Protein ,
			Dairy_Ash ,
			Dairy_Sodium ,
			Dairy_Fat_Kg , 
			Dairy_SNF_Kg , 
			FatKG_GainLoss , 
			SNFKG_GainLoss , 
			FatKG_Rate , 
			SNFKG_Rate , 
			Total_GainLoss , 
			MilkCollectionPosting_Id , 
			AgentCost , 
			TransporterCost , 
			MilkPrice , 
			MilkRate ,
			Plant_Code , 
			Is_VoucherLocked ,
			Locked_By , 
			Locked_On , 
			Dairy_Sour_Ltr , 
			OutsideInvoice_Id , 
			Is_OutsideCheck ,
			OutsideInvoiceCreated_On , 
			Is_OutsideInvoiceCreated 
            )
            select 
            f010.Org_Id  ,
			f010.Entry_Id ,  
			f010.MilkCollectionDairy_Id , 
			f010.MCC_Id , 
			f010.CollectionShift_Id , 
			f010.MilkType_Id , 
			f010.Collection_Date , 
			f010.Agent_Quantity_Kg , 
			f010.Agent_Quantity_Ltr , 
			f010.Agent_Fat ,
			f010.Agent_SNF ,
			f010.Agent_Fat_Kg , 
			f010.Agent_SNF_Kg , 
			f010.Dairy_Quantity_Kg , 
			f010.Dairy_Quantity_Ltr , 
			f010.Dairy_Fat ,
			f010.Dairy_SNF ,
			f010.Dairy_Protein ,
			f010.Dairy_Ash ,
			f010.Dairy_Sodium ,
			f010.Dairy_Fat_Kg , 
			f010.Dairy_SNF_Kg , 
			f010.FatKG_GainLoss , 
			f010.SNFKG_GainLoss , 
			f010.FatKG_Rate , 
			f010.SNFKG_Rate , 
			f010.Total_GainLoss , 
			f010.MilkCollectionPosting_Id , 
			f010.AgentCost , 
			f010.TransporterCost , 
			f010.MilkPrice , 
			f010.MilkRate ,
			f010.Plant_Code , 
			f010.Is_VoucherLocked ,
			f010.Locked_By , 
			f010.Locked_On , 
			f010.Dairy_Sour_Ltr , 
			f010.OutsideInvoice_Id , 
			f010.Is_OutsideCheck ,
			f010.OutsideInvoiceCreated_On , 
			f010.Is_OutsideInvoiceCreated 
            from f010_milkcollectionmcc_final_sour f010
            inner join m005_mcc m5 on f010.Org_Id = m5.Org_Id and f010.MCC_Id = m5.MCC_Id
            and m5.MCCType_Id = 'C014003' 
            where f010.Org_Id = var_Org_Id
            and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            
            UNION ALL
            
            select 
            f010.Org_Id  ,
			f010.Entry_Id ,  
			f010.MilkCollectionDairy_Id , 
			f010.MCC_Id , 
			f010.CollectionShift_Id , 
			f010.MilkType_Id , 
			f010.Collection_Date , 
			f010.Agent_Quantity_Kg , 
			f010.Agent_Quantity_Ltr , 
			f010.Agent_Fat ,
			f010.Agent_SNF ,
			f010.Agent_Fat_Kg , 
			f010.Agent_SNF_Kg , 
			f010.Dairy_Quantity_Kg , 
			f010.Dairy_Quantity_Ltr , 
			f010.Dairy_Fat ,
			f010.Dairy_SNF ,
			f010.Dairy_Protein ,
			f010.Dairy_Ash ,
			f010.Dairy_Sodium ,
			f010.Dairy_Fat_Kg , 
			f010.Dairy_SNF_Kg , 
			f010.FatKG_GainLoss , 
			f010.SNFKG_GainLoss , 
			f010.FatKG_Rate , 
			f010.SNFKG_Rate , 
			f010.Total_GainLoss , 
			f010.MilkCollectionPosting_Id , 
			f010.AgentCost , 
			f010.TransporterCost , 
			f010.MilkPrice , 
			f010.MilkRate ,
			f010.Plant_Code , 
			f010.Is_VoucherLocked ,
			f010.Locked_By , 
			f010.Locked_On , 
			f010.Dairy_Sour_Ltr , 
			f010.OutsideInvoice_Id , 
			f010.Is_OutsideCheck ,
			f010.OutsideInvoiceCreated_On , 
			f010.Is_OutsideInvoiceCreated 
            from f010_milkcollectionmcc_final_sour f010
            inner join m005_mcc m5 on f010.Org_Id = m5.Org_Id and f010.MCC_Id = m5.MCC_Id
            and m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            where f010.Org_Id = var_Org_Id
            and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
            Update t009_milkcollectiondairy_header
			set 
            Is_Locked =  1,
			LastEditedBy_Id = var_User_Id ,
            LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
            SELECT 1 AS Result_Id, 
			'Clear' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;

        end;
		elseif (var_Method_Name = 'Clear_Ash_Sour') then
		begin
        
			DROP TEMPORARY TABLE IF EXISTS temp_Report;

			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), 
			MCC_Id varchar(20),
			MPPIType_Id varchar(20),
			MaxAmount decimal(30,3));

			insert into temp_Report (Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id,MaxAmount)
			SELECT MPPI.Org_Id,MPPI.MilkCollectionDairy_Id,MPPI.MCC_Id,MPPI.MPPIType_Id,MaxAmount
			FROM (
			select 
			Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id ,
			MAX(Amount) AS MaxAmount,
			count(MPPIType_Id) as MPPITypeCount
			from t009_milkcollectiondairy_mcccommission
			where 
			Org_Id = var_Org_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and MPPIType_Id ='C047007'
			and Is_Sour_Check = 1
			group by Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id
			having MPPITypeCount >= 2
			) as MPPI;

			DELETE t009 from t009_milkcollectiondairy_mcccommission t009
			inner join temp_Report tmp on
			tmp.Org_Id = t009.Org_Id
			and tmp.Org_Id = t009.Org_Id
			and tmp.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and tmp.MCC_Id = t009.MCC_Id
			and tmp.MPPIType_Id = t009.MPPIType_Id
			and tmp.MaxAmount = t009.Amount
			where 
			t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.MPPIType_Id ='C047007'
			and t009.Is_Sour_Check = 1;
            
            SELECT 1 AS Result_Id, 
			'Clear' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Clear_Protein_Sour') then
		begin
        
			DROP TEMPORARY TABLE IF EXISTS temp_Report;

			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), 
			MCC_Id varchar(20),
			MPPIType_Id varchar(20),
			MaxAmount decimal(30,3));

			insert into temp_Report (Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id,MaxAmount)
			SELECT MPPI.Org_Id,MPPI.MilkCollectionDairy_Id,MPPI.MCC_Id,MPPI.MPPIType_Id,MaxAmount
			FROM (
			select 
			Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id ,
			MAX(Amount) AS MaxAmount,
			count(MPPIType_Id) as MPPITypeCount
			from t009_milkcollectiondairy_mcccommission
			where 
			Org_Id = var_Org_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and MPPIType_Id ='C047006'
			and Is_Sour_Check = 1
			group by Org_Id,MilkCollectionDairy_Id,MCC_Id,MPPIType_Id
			having MPPITypeCount >= 2
			) as MPPI;

			DELETE t009 from t009_milkcollectiondairy_mcccommission t009
			inner join temp_Report tmp on
			tmp.Org_Id = t009.Org_Id
			and tmp.Org_Id = t009.Org_Id
			and tmp.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and tmp.MCC_Id = t009.MCC_Id
			and tmp.MPPIType_Id = t009.MPPIType_Id
			and tmp.MaxAmount = t009.Amount
			where 
			t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.MPPIType_Id ='C047006'
			and t009.Is_Sour_Check = 1;
            
            SELECT 1 AS Result_Id, 
			'Clear' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Clear_Data_Sour') then
		begin
        
			DROP TEMPORARY TABLE IF EXISTS temp_Report;

			CREATE TEMPORARY TABLE temp_Report ( 
			Org_Id varchar(20), MilkCollectionDairy_Id varchar(20), 
			MCC_Id varchar(20),
			MaxAmount decimal(30,3));

			insert into temp_Report (Org_Id,MilkCollectionDairy_Id,MCC_Id,MaxAmount)
			SELECT MPPI.Org_Id,MPPI.MilkCollectionDairy_Id,MPPI.MCC_Id,MaxAmount
			FROM (
			select 
			Org_Id,MilkCollectionDairy_Id,MCC_Id,
			MAX(Amount) AS MaxAmount,
			count(MPPIType_Id) as MPPITypeCount
			from t009_milkcollectiondairy_mcccommission
			where 
			Org_Id = var_Org_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and MPPIType_Id in('C047007','C047006')
			and Is_Sour_Check = 1
			group by Org_Id,MilkCollectionDairy_Id,MCC_Id
			having MPPITypeCount >= 2
			) as MPPI;
            
            DROP TEMPORARY TABLE IF EXISTS temp_Report_2;

			CREATE TEMPORARY TABLE temp_Report_2 ( 
			MilkCollectionMCCCommission_Id varchar(20));

			insert into temp_Report_2 (MilkCollectionMCCCommission_Id)
			select t009.MilkCollectionMCCCommission_Id 
            from t009_milkcollectiondairy_mcccommission t009
			inner join temp_Report tmp on
			tmp.Org_Id = t009.Org_Id
			and tmp.Org_Id = t009.Org_Id
			and tmp.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
			and tmp.MCC_Id = t009.MCC_Id
			and tmp.MaxAmount = t009.Amount
			where 
			t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.MPPIType_Id in('C047007','C047006')
			and t009.Is_Sour_Check = 1
            /*
            AND t009.MilkCollectionMCCCommission_Id = (
				SELECT MIN(t.MilkCollectionMCCCommission_Id)
				FROM t009_milkcollectiondairy_mcccommission t
				WHERE t.Org_Id = t.Org_Id
				AND t.MilkCollectionDairy_Id = t.MilkCollectionDairy_Id
				AND t.MCC_Id = t.MCC_Id
				AND t.Amount = t.Amount
                and t.Org_Id = var_Org_Id
				and t.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				and t.MPPIType_Id in('C047007','C047006')
				and t.Is_Sour_Check = 1
			)
            */
            ;
            
            DELETE t009 from t009_milkcollectiondairy_mcccommission t009
			where 
			t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.MPPIType_Id in('C047007','C047006')
			and t009.Is_Sour_Check = 1
            and t009.MilkCollectionMCCCommission_Id in (select MilkCollectionMCCCommission_Id from temp_Report_2);
            
            SELECT 1 AS Result_Id, 
			'Clear' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;

        end;
	elseif (var_Method_Name = 'Deductions') then
		begin
			Declare New_Deductions_Id varchar(20);
            Declare New_Entry_Id varchar(20);
            Declare Year_Id varchar(10);
			DECLARE k INT UNSIGNED DEFAULT 0;
            DECLARE j INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            DECLARE loop_counter INT UNSIGNED DEFAULT 1;
			DECLARE total_rows INT;
            
			DECLARE current_org_id varchar(10);
			DECLARE current_mcc_id varchar(20);
            DECLARE current_milkprice decimal(30,3);
			DECLARE current_milktype_id varchar(20);
			DECLARE current_compartment_no varchar(20);
            DECLARE current_chemistcollection_id varchar(20);
            
            SET SQL_SAFE_UPDATES = 0;
            
            set @TripDocument_Id = (select TripDocument_Id 
							from t009_milkcollectiondairy_header 
							where Org_Id = var_Org_Id
							and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1);
                            
			

            
			DROP TEMPORARY TABLE IF EXISTS temp_Report_0;
			CREATE TEMPORARY TABLE temp_Report_0 (Deductions_Id  varchar(20));

			insert into temp_Report_0 (Deductions_Id )
			select 
			Sour_Compartment_Adjustment_Entry_Id
			from t008_milkcollectionchemist_compartment 
			where Org_Id = var_Org_Id
			and ChemistCollection_Id in (
			select ChemistCollection_Id 
			from t008_milkcollectionchemist 
			where Org_Id = var_Org_Id
			and Trip_Id = @TripDocument_Id
			and Is_Sour = 1
			and Sour_Compartment_Adjustment_Flag =  1
			);

			

			DROP TEMPORARY TABLE IF EXISTS temp_Report_01;
			CREATE TEMPORARY TABLE temp_Report_01 ( 
			Deductions_Id  varchar(20));

			insert into temp_Report_01 (Deductions_Id )
			select 
			Sour_Compartment_Adjustment_Entry_Id
			from t008_milkcollectionchemist_compartment 
			where Org_Id = var_Org_Id
			and ChemistCollection_Id in (
			select ChemistCollection_Id 
			from t008_milkcollectionchemist 
			where Org_Id = var_Org_Id
			and Trip_Id = @TripDocument_Id
			and Is_Sour = 1
			and Sour_Compartment_Adjustment_Flag =  1
			);
			
            
			delete from t033_deductions_item where var_Org_Id = Org_Id and Deductions_Id in(select Deductions_Id from temp_Report_0); 

			
            
			delete from t033_deductions_header where var_Org_Id = Org_Id and Deductions_Id in(select Deductions_Id from temp_Report_01);
			
            
            delete from t009_milkcollectiondairy_mcccommission
			where Org_Id = var_Org_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and MPPIType_Id ='C047003'
			and MCC_Id in(
				select MCC_Id from f010_milkcollectionmcc_final_sour_main 
				where Org_Id = var_Org_Id
				and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				group by MCC_Id
			);
			
          
			DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
			CREATE TEMPORARY TABLE temp_Report_1 ( 
            PKeyRowNum int AUTO_INCREMENT PRIMARY KEY,
			Org_Id varchar(20),ChemistCollection_Id varchar(20),MilkType_Id varchar(20),
            Compartment_No varchar(20), MCC_Id varchar(20),MilkPrice decimal(30,2));

			insert into temp_Report_1 (Org_Id,ChemistCollection_Id,MilkType_Id, Compartment_No,MCC_Id )
			select 
			Org_Id,ChemistCollection_Id,MilkType_Id,Compartment_No, 
            MCC_Id 
			from t008_milkcollectionchemist_compartment 
			where Org_Id = var_Org_Id
			and ChemistCollection_Id in (
			select ChemistCollection_Id 
			from t008_milkcollectionchemist 
			where Org_Id = var_Org_Id
			and Trip_Id = @TripDocument_Id
			and Is_Sour = 1
			and Sour_Compartment_Adjustment_Flag =  1
			);
          
            DROP TEMPORARY TABLE IF EXISTS temp_Report_0;
			CREATE TEMPORARY TABLE temp_Report_0 ( 
			Org_Id varchar(20),ChemistCollection_Id varchar(20),Compartment_No varchar(20), MCC_Id varchar(20),MilkPrice decimal(30,2));

			insert into temp_Report_0 (Org_Id,ChemistCollection_Id, Compartment_No,MCC_Id )
			select 
			Org_Id,ChemistCollection_Id,Compartment_No, MCC_Id 
			from t008_milkcollectionchemist_compartment 
			where Org_Id = var_Org_Id
			and ChemistCollection_Id in (
			select ChemistCollection_Id 
			from t008_milkcollectionchemist 
			where Org_Id = var_Org_Id
			and Trip_Id = @TripDocument_Id
			and Is_Sour = 1
			and Sour_Compartment_Adjustment_Flag =  1
			);
			
		
			DROP TEMPORARY TABLE IF EXISTS temp_Report_2;
			CREATE TEMPORARY TABLE temp_Report_2 ( 
			Org_Id varchar(20),Compartment_No varchar(20), MCC_Id varchar(20),Is_GRN varchar(20));

			insert into temp_Report_2 (Org_Id,Compartment_No, MCC_Id ,Is_GRN)
			select 
			Org_Id,Compartment_No, MCC_Id ,Sour_Compartment_GRN_Flag
			from t008_milkcollectionchemist_compartment 
			where Org_Id = var_Org_Id
			and ChemistCollection_Id in (
			select ChemistCollection_Id 
			from t008_milkcollectionchemist 
			where Org_Id = var_Org_Id
			and Trip_Id = @TripDocument_Id
			and Is_Sour = 1
			and Sour_Compartment_Adjustment_Flag =  0
			);
			
			DROP TEMPORARY TABLE IF EXISTS temp_Report_3;
			CREATE TEMPORARY TABLE temp_Report_3 ( 
			Org_Id varchar(20),Compartment_No varchar(20), MCC_Id varchar(20),Is_GRN varchar(20));

			insert into temp_Report_3 (Org_Id,Compartment_No, MCC_Id ,Is_GRN)
			select 
			Org_Id,Compartment_No, MCC_Id ,Sour_Compartment_GRN_Flag
			from t008_milkcollectionchemist_compartment 
			where Org_Id = var_Org_Id
			and ChemistCollection_Id in (
			select ChemistCollection_Id 
			from t008_milkcollectionchemist 
			where Org_Id = var_Org_Id
			and Trip_Id = @TripDocument_Id
			and Is_Sour = 1
			and Sour_Compartment_Adjustment_Flag =  0
			);
            
            DROP TEMPORARY TABLE IF EXISTS temp_Report_31;
			CREATE TEMPORARY TABLE temp_Report_31 ( 
			Org_Id varchar(20),Compartment_No varchar(20), MCC_Id varchar(20),Is_GRN varchar(20));
            
            insert into temp_Report_31 (Org_Id,Compartment_No, MCC_Id ,Is_GRN)
			select 
			Org_Id,Compartment_No, MCC_Id ,Sour_Compartment_GRN_Flag
			from t008_milkcollectionchemist_compartment 
			where Org_Id = var_Org_Id
			and ChemistCollection_Id in (
			select ChemistCollection_Id 
			from t008_milkcollectionchemist 
			where Org_Id = var_Org_Id
			and Trip_Id = @TripDocument_Id
			and Is_Sour = 1
			and Sour_Compartment_Adjustment_Flag =  1
			);
			
			
			DROP TEMPORARY TABLE IF EXISTS temp_Report_4;
			CREATE TEMPORARY TABLE temp_Report_4 ( 
			Compartment_No varchar(20), MilkPrice decimal(30,2));

			insert into temp_Report_4 (Compartment_No,MilkPrice)
			SELECT Compartment_No,sum(MilkPrice)  as MilkPrice
			FROM (
			select tmp.Compartment_No,COALESCE(SUM(IFNULL(f010.MilkPrice, 0)), 0) as MilkPrice
			from f010_milkcollectionmcc_final_sour_main f010
			inner join temp_Report_2 tmp on
			tmp.Org_Id = f010.Org_Id
			and tmp.MCC_Id = f010.MCC_Id
			and tmp.Is_GRN =  0
			where f010.Org_Id =var_Org_Id
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by tmp.Compartment_No
			
			UNION ALL
            
            select tmp.Compartment_No,COALESCE(SUM(IFNULL(f010.MilkPrice, 0)), 0) as MilkPrice
			from f010_milkcollectionmcc_final_sour_mcc f010
			inner join temp_Report_31 tmp on
			tmp.Org_Id = f010.Org_Id
			and tmp.MCC_Id = f010.MCC_Id
			and tmp.Is_GRN =  0
			where f010.Org_Id =var_Org_Id
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			group by tmp.Compartment_No
            
            UNION ALL
			
			select tmp.Compartment_No,COALESCE(SUM(IFNULL(f010.Amount, 0)), 0) as MilkPrice 
			from t009_milkcollectiondairy_mcccommission f010
			inner join temp_Report_3 tmp on
			tmp.Org_Id = f010.Org_Id
			and tmp.MCC_Id = f010.MCC_Id
			where f010.Org_Id =var_Org_Id
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and f010.MPPIType_Id in ('C047001','C047003','C047004','C047005','C047006','C047007')
            and f010.Is_Sour_Check = 1
			group by tmp.Compartment_No
            
            
			) subquery
			WHERE subquery.MilkPrice <> 0
            group by subquery.Compartment_No;
		
			update temp_Report_1 tmp1
			inner join temp_Report_4 tmp4 on
			tmp1.Compartment_No = tmp4.Compartment_No
			set tmp1.MilkPrice = tmp4.MilkPrice;
            	
				SELECT COUNT(*) INTO total_rows FROM temp_Report_1;
                
				WHILE loop_counter <= total_rows DO
                    
					SELECT Org_Id,ChemistCollection_Id,Compartment_No, MCC_Id, MilkPrice,MilkType_Id
					INTO current_org_id,current_chemistcollection_id,current_compartment_no, current_mcc_id, current_milkprice,current_milktype_id
					FROM temp_Report_1
					WHERE PKeyRowNum = loop_counter;
                    
					set Year_Id = (select right(left(curdate(),4),(2)));
                    
					Call USP_Number_Range ('t033_deductions_header', Year_Id, 'T033', '', New_Deductions_Id );
					Call USP_Number_Range ('t033_deductions_item', Year_Id, 'T033A', '', New_Entry_Id );
                    
                    

					set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = current_mcc_id and is_deleted = 0 and 
						date(Applicable_Date) <= date(@Created_On)
						order by Applicable_Date desc limit 1 ) ;
							
						Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
							
						set @Current_Datetime =  @Created_On;
						if(@MusterType = 1)then 
								
								Set @MusterCycle_StartDate = @Current_Datetime;
								set @MusterCycle_EndDate =  @Current_Datetime;
								
							elseif(@MusterType = 7) then 
									
								if (DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 1 AND 7 ) then
									
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-07');
									
								elseif(DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 8 AND 14) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-08');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-14');

								elseif(DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 15 AND 21) then
									
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-15');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-21');
									
								elseif(DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 16 AND 31) then
									
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-16');
									set @MusterCycle_EndDate =  LAST_DAY( date(@Created_On));
								
								end if;
									
							elseif(@MusterType = 15) then 
									
								if (DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 1 AND 15 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-15');
								
								else 
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-16');
									set @MusterCycle_EndDate =  LAST_DAY( date(@Created_On));
								
								end if;
									
							elseif(@MusterType = 5) then 
									
								if (DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 1 AND 5 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-05');
								
								elseif(DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 6 AND 10) then
							
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-06');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-10');

								elseif(DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 11 AND 15) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-11');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-15');
								
								elseif(DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 16 AND 20 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-16');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-20');
								
								elseif(DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 21 AND 25 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-21');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-25');
								
								elseif(DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 26 AND 31 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-16');
									set @MusterCycle_EndDate =  LAST_DAY( date(@Created_On));
							
								end if;
								
							elseif(@MusterType = 10) then 
									
								if (DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 1 AND 10 ) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-01');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-10');
								
								elseif(DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 11 AND 20) then
							
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-11');
									set @MusterCycle_EndDate =  DATE_FORMAT( date(@Created_On), '%Y-%m-20');

								elseif(DATE_FORMAT(CAST(@Created_On AS DATE), '%d') BETWEEN 21 AND 31) then
								
									Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-21');
									set @MusterCycle_EndDate =  LAST_DAY( date(@Created_On));
							
								end if;
							
							elseif(@MusterType = 30) then 
									
								Set @MusterCycle_StartDate = DATE_FORMAT( date(@Created_On), '%Y-%m-01');
								set @MusterCycle_EndDate =  LAST_DAY( date(@Created_On));
									
							end if;
                              
                          

							INSERT INTO t033_deductions_header(
							Org_Id, Deductions_Id, Entry_Date, 
							Request_User_Type, Request_User_Id,MCC_Id,
							Request_Type, Total_Amount, 
							Amount_Deducted, Balance, 
							Is_Closed, No_Of_Installments
							)
							VALUES(
								current_org_id,New_Deductions_Id,@Created_On,
								'Agent',current_mcc_id,current_mcc_id,
								'M020231000010',current_milkprice,
								0,current_milkprice,0,1
							);
                            
							
                                
							INSERT INTO t033_deductions_item(
							Org_Id,Entry_Id,Deductions_Id,Deduction_Date,
							Deduction_Amount,Is_Deducted,
							MusterCycle_StartDate,MusterCycle_EndDate
							)
							VALUES (
							current_org_id,
							New_Entry_Id,
							New_Deductions_Id,
							@Created_On,
							current_milkprice,
							0,
							@MusterCycle_StartDate,
							@MusterCycle_EndDate
							);	

							UPDATE t008_milkcollectionchemist_compartment
							SET 
							Sour_Compartment_Adjustment_Entry_Id = New_Deductions_Id,
							Sour_Compartment_Adjustment_Done_Flag = 1
							WHERE 
                            Org_Id = current_org_id
                            and Compartment_No = current_compartment_no
                            and MilkType_Id = current_milktype_id
                            and ChemistCollection_Id = current_chemistcollection_id;


					SET loop_counter = loop_counter + 1;
                    
				END WHILE;
                
			SELECT 1 AS Result_Id, 
			'Deductions' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
                    
        end;
	end if;


END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
