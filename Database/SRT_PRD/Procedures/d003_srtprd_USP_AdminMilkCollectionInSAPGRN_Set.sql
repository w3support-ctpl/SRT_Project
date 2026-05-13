-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionInSAPGRN_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionInSAPGRN_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_Entry_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
    var_MCC_Id varchar(20),
    var_Weight varchar(45),
	var_SNF varchar(45),
    var_Fat varchar(45),
    var_Protein varchar(45),
    var_Ash varchar(45),
    var_Sodium varchar(45),
    var_User_Id varchar(20),
	var_User_Name varchar(45)
)
BEGIN
	SET SQL_SAFE_UPDATES = 0;
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
			 -- AND Freight_Applicable_To = 'MCC'
			 AND Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00')
		 GROUP BY 
			 Org_Id, MCC_Id;

	if (var_Method_Name = 'Update') then
		BEGIN
			SET @kg_to_ltr = (SELECT Kg_To_Ltr_Dairy FROM c001_organization WHERE Org_Id = var_Org_Id limit 1);
            
			delete from bk_f010_milkcollectionmcc_final_grn
            where Org_Id = var_Org_Id
            and Entry_Id = var_Entry_Id
            and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and MCC_Id = var_MCC_Id;
            
			insert into bk_f010_milkcollectionmcc_final_grn 
            select * from f010_milkcollectionmcc_final
            where Org_Id = var_Org_Id
            and Entry_Id = var_Entry_Id
            and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and MCC_Id = var_MCC_Id;
            
            delete from bk_t009_milkcollectiondairy_mcccommission_grn
            where Org_Id = var_Org_Id
            and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and MCC_Id = var_MCC_Id;
            
			insert into bk_t009_milkcollectiondairy_mcccommission_grn 
            select * from t009_milkcollectiondairy_mcccommission
            where Org_Id = var_Org_Id
            and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and MCC_Id = var_MCC_Id;
            
            delete from t009_milkcollectiondairy_mcccommission
            where Org_Id = var_Org_Id
            and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and MCC_Id = var_MCC_Id;
            
            set  @var_Dairy_Quantity_Kg = (var_Weight / @kg_to_ltr);
            
            update f010_milkcollectionmcc_final
			set Dairy_Quantity_Kg = Roundoff('Quantity', @var_Dairy_Quantity_Kg),
            Dairy_Quantity_Ltr = var_Weight,
            Dairy_Fat = var_Fat,
            Dairy_SNF = var_SNF,
            Dairy_Protein = var_Protein,
            Dairy_Ash = var_Ash,
            Dairy_Sodium = var_Sodium
			where Org_Id = var_Org_Id
            and Entry_Id = var_Entry_Id
            and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and MCC_Id = var_MCC_Id;
            
            update f010_milkcollectionmcc_final 
			set MilkRate = GetMilkRateBackDate(Org_Id, MCC_Id, ifnull(CollectionShift_Id,'C015003'), Dairy_Fat, Dairy_SNF, MilkType_Id,collection_date)
			where Org_Id = var_Org_Id
            and Entry_Id = var_Entry_Id
            and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and MCC_Id = var_MCC_Id;
            
            update f010_milkcollectionmcc_final 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where Org_Id = var_Org_Id
            and Entry_Id = var_Entry_Id
            and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and MCC_Id = var_MCC_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.Dairy_Fat_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_Fat) /100),
			f010.Dairy_SNF_Kg = ((f010.Dairy_Quantity_Kg * f010.Dairy_SNF) /100)
			where f010.Org_Id = var_Org_Id
            and f010.Entry_Id = var_Entry_Id
            and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and f010.MCC_Id = var_MCC_Id;
            
			UPDATE  f010_milkcollectionmcc_final f010
			SET 
			f010.FatKG_GainLoss = (f010.Dairy_Fat_Kg - f010.Agent_Fat_Kg),
			f010.SNFKG_GainLoss = (f010.Dairy_SNF_Kg - f010.Agent_SNF_Kg)
			where f010.Org_Id = var_Org_Id
            and f010.Entry_Id = var_Entry_Id
            and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and f010.MCC_Id = var_MCC_Id;
            
            UPDATE  f010_milkcollectionmcc_final f010
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = f010.Org_Id
				AND m005.MCC_Id = f010.MCC_Id
			SET 
			f010.Total_GainLoss = CASE 
									WHEN m005.MCCWorkType_Id = 'C023001' THEN 0
									ELSE ((f010.FatKG_GainLoss * f010.FatKG_Rate) + (f010.SNFKG_GainLoss * f010.SNFKG_Rate))
								END
			where f010.Org_Id = var_Org_Id
            and f010.Entry_Id = var_Entry_Id
            and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and f010.MCC_Id = var_MCC_Id; 
            
            call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				'f010_milkcollectionmcc_final', var_Entry_Id, '', '', 
				var_User_Id, var_User_Name);
                
			SELECT 1 AS Result_Id, 
			'Update' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
            
        end;
        elseif (var_Method_Name = 'Create_Commission_New') then
		begin 
			set @Check_CollectionShift_Id = ( select CollectionShift_Id from f010_milkcollectionmcc_final 
						where Org_Id = var_Org_Id
                        and MCC_Id = var_MCC_Id
						and MilkCollectionDairy_Id =var_MilkCollectionDairy_Id limit 1 );

			if (@Check_CollectionShift_Id = 'C015002') then

				SET SQL_SAFE_UPDATES = 0;

				set @Collection_Date = ( select Collection_Date from f010_milkcollectionmcc_final 
										where Org_Id =  var_Org_Id
                                        and MCC_Id = var_MCC_Id
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
                and MCC_Id = var_MCC_Id
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
                and f010.MCC_Id = var_MCC_Id
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
                    and f010.MCC_Id = var_MCC_Id
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
                                and f010.MCC_Id = var_MCC_Id
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
                                and f010.MCC_Id = var_MCC_Id
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
                                and f010.MCC_Id = var_MCC_Id
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
																		AND m0051.MCC_Id = max_dates.MCC_Id 
																		AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
																		AND m0051.Anamat_Applicable_To = 'MCC'
										-- INNER JOIN c047_mppitype c047 ON
											-- c047.MPPIType_Id = 'C047004'
										where f010.Org_Id =  var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                                        and f010.MCC_Id = var_MCC_Id
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
																		AND m0051.MCC_Id = max_dates.MCC_Id 
																		AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
																		AND m0051.Freight_Applicable_To = 'MCC'
										-- INNER JOIN c047_mppitype c047 ON
											-- c047.MPPIType_Id = 'C047005'
										where f010.Org_Id = var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                                        and f010.MCC_Id = var_MCC_Id
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
                                        and f010.MCC_Id = var_MCC_Id
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
                                        and f010.MCC_Id = var_MCC_Id
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
                                and f010.MCC_Id = var_MCC_Id
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
									c047.MPPIType_Id = 'C047009'
								where f010.Org_Id = var_Org_Id 
								and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                                and f010.MCC_Id = var_MCC_Id
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
                                and f010.MCC_Id = var_MCC_Id
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
                                and f010.MCC_Id = var_MCC_Id
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
																		AND m0051.MCC_Id = max_dates.MCC_Id 
																		AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
																		AND m0051.Anamat_Applicable_To = 'MCC'
										-- INNER JOIN c047_mppitype c047 ON
											-- c047.MPPIType_Id = 'C047004'
										where f010.Org_Id =  var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                                        and f010.MCC_Id = var_MCC_Id
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
																		AND m0051.MCC_Id = max_dates.MCC_Id 
																		AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
																		AND m0051.Freight_Applicable_To = 'MCC'
										-- INNER JOIN c047_mppitype c047 ON
											-- c047.MPPIType_Id = 'C047005'
										where f010.Org_Id = var_Org_Id
										and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                                        and f010.MCC_Id = var_MCC_Id
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
                                        and f010.MCC_Id = var_MCC_Id
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
                                        and f010.MCC_Id = var_MCC_Id
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
			var_Org_Id AS Result_Extra_Key;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
