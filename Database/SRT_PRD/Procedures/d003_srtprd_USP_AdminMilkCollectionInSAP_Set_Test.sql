-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionInSAP_Set_Test` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionInSAP_Set_Test`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Entry_Id varchar(20),
    var_MilkCollectionDairy_Id longtext,
    var_Year varchar(20),
    var_SAP_Document_Id varchar(20),
    var_User_Id varchar(20),
	var_User_Name varchar(45)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'SetGRNTanker') then
		
        begin
        
            

			-- Declare variables
			DECLARE New_MilkCollectionPosting_Id VARCHAR(20);
            DECLARE Today_Date DATETIME;
            DECLARE Set_CollectionShift_Id varchar(20);
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Set_Created_On VARCHAR(20);
			DECLARE done BOOLEAN DEFAULT FALSE;
			DECLARE Set_var_MCC_Id  VARCHAR(20);
			DECLARE Set_var_MilkType_Id  VARCHAR(20);
			DECLARE Set_var_Weight  VARCHAR(20);
			DECLARE Set_var_Liters  VARCHAR(20);
			DECLARE Set_var_Set_Fat  VARCHAR(20);
			DECLARE Set_var_Set_SNF  VARCHAR(20);
            DECLARE Set_var_Amount  VARCHAR(20);
			DECLARE Year_Id varchar(10);
            

			-- Declare cursor for your SELECT query
			DECLARE cur CURSOR FOR
			SELECT
			MCC_Id as Set_var_MCC_Id,
			MilkType_Id as Set_var_MilkType_Id,
			Roundoff('Quantity', sum(Weight))  as Set_var_Weight,
			Roundoff('QuantityForDairy',  sum(Liters)) as Set_var_Liters ,
			Roundoff('Quality', (sum(Liters * Set_Fat))/sum(Liters)) as Set_var_Set_Fat ,
			Roundoff('Quality', (sum(Liters * Set_SNF))/sum(Liters))  as Set_var_Set_SNF ,
			Amount as Set_var_Amount 
			FROM (

			SELECT 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			ROUNDOFF('Quantity', SUM(t0081.Final_Quantity_Kg)) AS Weight,
			ROUNDOFF('QuantityForDairy',
			SUM(t0081.Final_Quantity_Ltr)) AS Liters,
			ROUNDOFF('Quality',
			(SUM(t0081.Final_Quantity_Ltr * t0081.Final_Fat)) / SUM(t0081.Final_Quantity_Ltr)) AS Set_Fat,
			ROUNDOFF('Quality',
			(SUM(t0081.Final_Quantity_Ltr * t0081.Final_SNF)) / SUM(t0081.Final_Quantity_Ltr)) AS Set_SNF,
			IF(t0081.MilkType_Id = 'C011001',
			t006.Final_Amout_Cow,
			IF(t0081.MilkType_Id = 'C011002',
			t006.Final_Amout_Buf,
			0.00)) AS Amount
			FROM
			t009_milkcollectiondairy_header t009
			INNER JOIN
			t021_tripdocument_header t021 ON t021.Org_Id = t009.Org_Id
			AND t021.TripDocument_Id = t009.TripDocument_Id
			INNER JOIN
			t022_tripdocument_item t022 ON t021.Org_Id = t022.Org_Id
			AND t021.TripDocument_Id = t022.TripDocument_Id
			INNER JOIN
			t008_milkcollectionchemist t008 ON t008.Org_Id = t022.Org_Id
			AND t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			AND t008.DispatchNo = t022.DispatchNo
			INNER JOIN
			t008_milkcollectionchemist_compartment t0081 ON t008.Org_Id = t0081.Org_Id
			AND t008.ChemistCollection_Id = t0081.ChemistCollection_Id
			AND t0081.MilkType_Id IN ('C011001' , 'C011002')
			and t0081.Is_Sour = 0
			INNER JOIN
			t006_milkcollectionagent t006 ON t006.Org_Id = t022.Org_Id
			AND t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			WHERE
			t009.Org_Id = var_Org_Id
			AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			AND t0081.Final_Quantity_Ltr <> 0
			AND t0081.Final_Fat <> 0
			AND t0081.Final_SNF <> 0
			GROUP BY t0081.MCC_Id , t0081.MilkType_Id , t006.Final_Amout_Cow , t006.Final_Amout_Buf

			union all

			SELECT 
			t0081.MCC_Id,
			t0081.MilkType_Id,
			ROUNDOFF('Quantity', SUM(t0081.Final_Quantity_Kg)) AS Weight,
			ROUNDOFF('QuantityForDairy',
			SUM(t0081.Final_Quantity_Ltr)) AS Liters,
			ROUNDOFF('Quality',
			(SUM(t0081.Final_Quantity_Ltr * t0081.Final_Fat)) / SUM(t0081.Final_Quantity_Ltr)) AS Set_Fat,
			ROUNDOFF('Quality',
			(SUM(t0081.Final_Quantity_Ltr * t0081.Final_SNF)) / SUM(t0081.Final_Quantity_Ltr)) AS Set_SNF,
			IF(t0081.MilkType_Id = 'C011001',
			t006.Final_Amout_Cow,
			IF(t0081.MilkType_Id = 'C011002',
			t006.Final_Amout_Buf,
			0.00)) AS Amount
			FROM
			t009_milkcollectiondairy_header t009
			INNER JOIN
			t021_tripdocument_header t021 ON t021.Org_Id = t009.Org_Id
			AND t021.TripDocument_Id = t009.TripDocument_Id
			INNER JOIN
			t022_tripdocument_item t022 ON t021.Org_Id = t022.Org_Id
			AND t021.TripDocument_Id = t022.TripDocument_Id
			INNER JOIN
			t008_milkcollectionchemist t008 ON t008.Org_Id = t022.Org_Id
			AND t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			AND t008.DispatchNo = t022.DispatchNo
			INNER JOIN
			t008_milkcollectionchemist_compartment t0081 ON t008.Org_Id = t0081.Org_Id
			AND t008.ChemistCollection_Id = t0081.ChemistCollection_Id
			AND t0081.MilkType_Id IN ('C011001' , 'C011002')
			and t0081.Is_Sour = 1
			and t0081.Sour_Compartment_GRN_Flag = 1
			INNER JOIN
			t006_milkcollectionagent t006 ON t006.Org_Id = t022.Org_Id
			AND t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			WHERE
			t009.Org_Id = var_Org_Id
			AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			AND t0081.Final_Quantity_Ltr <> 0
			AND t0081.Final_Fat <> 0
			AND t0081.Final_SNF <> 0
			GROUP BY t0081.MCC_Id , t0081.MilkType_Id , t006.Final_Amout_Cow , t006.Final_Amout_Buf
			) subquery 
			GROUP BY 
			MCC_Id,
			MilkType_Id,
			Amount;



			-- Declare exit handler to close the cursor
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
					
                    
					set  @TripId = (select TripDocument_Id from t009_milkcollectiondairy_header
					where Org_Id = var_Org_Id and  MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1 );
				   
					SELECT ifnull(TripAmount, 0.00) into @Set_TransporterCost FROM t021_tripdocument_header t021
					WHERE t021.TripDocument_Id = @TripId;
                    
                    SELECT Created_On INTO Set_Created_On 
					FROM t009_milkcollectiondairy_header 
					WHERE Org_Id = var_Org_Id AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                    
                    
                    
                    
                    set @TotalWeight =  (SELECT 
												Roundoff('Quantity', SUM(t0081.Final_Quantity_Kg)) AS Weight
											FROM t009_milkcollectiondairy_header t009
											INNER JOIN t021_tripdocument_header t021 ON t021.Org_Id = t009.Org_Id 
												AND t021.TripDocument_Id = t009.TripDocument_Id
											INNER JOIN t022_tripdocument_item t022 ON t021.Org_Id = t022.Org_Id 
												AND t021.TripDocument_Id = t022.TripDocument_Id
											INNER JOIN t008_milkcollectionchemist t008 ON t008.Org_Id = t022.Org_Id 
												AND t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
                                                and t008.DispatchNo = t022.DispatchNo
											INNER JOIN t008_milkcollectionchemist_compartment t0081 ON t008.Org_Id = t0081.Org_Id 
												AND t008.ChemistCollection_Id = t0081.ChemistCollection_Id
												AND t0081.MilkType_Id IN ('C011001', 'C011002')
											inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
												and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
											WHERE t009.Org_Id = var_Org_Id
												AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
					
                    
                   
                   
					

			-- Open the cursor
			OPEN cur;

			-- Start loop
			my_loop: WHILE NOT done DO
				-- Fetch data from the cursor into variables
				FETCH cur INTO Set_var_MCC_Id, Set_var_MilkType_Id, Set_var_Weight, Set_var_Liters, Set_var_Set_Fat, Set_var_Set_SNF,Set_var_Amount;
				select Set_var_MCC_Id, Set_var_MilkType_Id, Set_var_Weight, Set_var_Liters, Set_var_Set_Fat, Set_var_Set_SNF,Set_var_Amount;
				-- Check if data is available
				IF NOT done THEN
					-- Generate MilkCollectionPosting_Id using the stored procedure
                    
					set Year_Id = (SELECT RIGHT(LEFT(CURDATE(), 4), 2));
					CALL USP_Number_Range ('t009_milkcollectiondairy_posting', Year_Id, 'T009', '', New_MilkCollectionPosting_Id );
                    
                   set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
                    
                    set RatioFat = (SELECT Fat   FROM t024_fatsnf_ratio 
					where Ratio_Date <= now() 
					and Org_Id = var_Org_Id
					and Is_Active = 1
					and Is_Deleted = 0
					order by Ratio_Date DESC Limit 1);
                   
                    set RatioSNF = (SELECT SNF    FROM t024_fatsnf_ratio 
					where Ratio_Date <= now() 
					and Org_Id = var_Org_Id
					and Is_Active = 1
					and Is_Deleted = 0
					order by Ratio_Date DESC Limit 1);
                    
                    
					-- Insert data into the temporary table for each iteration
					INSERT INTO t009_milkcollectiondairy_posting (Org_Id,MilkCollectionPosting_Id, MCC_Id, 
                    MilkType_Id, Weight, Liters, Fat, SNF,
								Created_On,Batch_Id,MilkStatus_Id,MilkPrice)
					VALUES (var_Org_Id,New_MilkCollectionPosting_Id, Set_var_MCC_Id, 
                    Set_var_MilkType_Id, Set_var_Weight, Set_var_Liters, Set_var_Set_Fat, Set_var_Set_SNF,
                    Set_Created_On,RIGHT(New_MilkCollectionPosting_Id, 9),'C016001',Set_var_Amount);
                    
                  
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.Rate = t009.MilkPrice / t009.Liters
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                      
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FatKG = (t009.FAT * t009.Weight)/100,
                    t009.SNFKG = (t009.SNF * t009.Weight)/100 
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    select var_Org_Id,New_MilkCollectionPosting_Id, Set_var_MCC_Id, 
                    Set_var_MilkType_Id, Set_var_Weight, Set_var_Liters, Set_var_Set_Fat, Set_var_Set_SNF,
                    Set_Created_On,RIGHT(New_MilkCollectionPosting_Id, 9),'C016001',Set_var_Amount;
                    
                    select 13 Set_var_MCC_Id,@Set_TransporterCost,@TotalWeight,@Set_TransporterCost;
                    
                    select * from t009_milkcollectiondairy_posting t009
                    where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.TransporterCost = round(t009.Weight * ( @Set_TransporterCost /  @TotalWeight)),
                    t009.MilkCost = ((t009.Weight * ( t009.Weight / t009.Rate) ) + (@Set_TransporterCost)),
                    t009.AgentCost = 0.00
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                 
                 select 14;
                    
                    Update t009_milkcollectiondairy_posting t009
                    inner join t009_milkcollectiondairy_mcccommission t0091
					ON t0091.Org_Id = var_Org_Id
					AND t0091.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					AND t0091.MCC_Id = Set_var_MCC_Id
					AND t0091.MPPIType_Id = 'C047001'
					set 
					t009.AgentCost = t0091.Amount
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                   
                  
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.TotalLandedCost = round(((t009.Liters * t009.Rate) + t009.AgentCost + t009.TransporterCost))
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FEQ = ((((t009.SNFKG)*RatioSNF)/100)+(t009.FatKG))
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;


                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FatRate = (t009.TotalLandedCost /t009.FEQ)
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                  
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FatValue = (t009.FatKG *t009.FatRate )
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                 
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.SNFValue = (t009.TotalLandedCost -t009.FatValue)
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                 
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.SNFRate = (t009.SNFValue / t009.SNFKG)
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                
                    Update f010_milkcollectionmcc_final f010
					set 
					f010.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id
					where f010.Org_Id = var_Org_Id 
                    and f010.MCC_Id = Set_var_MCC_Id 
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                    
				END IF;
                
                
			END WHILE;

			-- Close the cursor
			CLOSE cur;

			SELECT 1 AS Result_Id, 
            'Locked' AS Result_Description, 
            var_MilkCollectionDairy_Id AS Result_Extra_Key;
 
        end;
	
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
