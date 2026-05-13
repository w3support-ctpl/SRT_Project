-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminGainLossEntry_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminGainLossEntry_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Date varchar(60),
    var_MilkCollectionDairy_Id varchar(20),
    var_Entry_Id varchar(20),
    var_TripDocument_Id varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get_Confirm') then  
		begin
			DECLARE var_StartDate DATE;
            DECLARE var_EndDate DATE;

            SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
            SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            SELECT *
			FROM (
			SELECT 
				t009.Org_Id,t009.MilkCollectionDairy_Id,t021.TripDocument_Id,
				-- c015.CollectionShift_Id, c015.CollectionShift_Name,
                ifnull(c015.CollectionShift_Id ,'' )as CollectionShift_Id,
				ifnull(c015.CollectionShift_Name ,'' )as CollectionShift_Name,
                c020.VehicleType_Id, c020.VehicleType_Name,
				m006.Route_Id, m006.Route_Name, 
                Time_FORMAT(m006.End_Time, '%h:%i %p') AS End_Time,
				m003.Vehicle_Id, m003.Vehicle_No,
				t009.Is_Active, t009.Is_Deleted,
                t009.Is_Confirm,t009.Is_Release,t009.Is_Locked,
				COALESCE(SUM(t0091.Weight), 0) AS Weight,
                COALESCE(SUM(t0091.Liters), 0) AS Liters,
				COALESCE(SUM(t0091.Cans), 0) AS Total_Cans
                -- t0091.Rate AS Rate
			FROM t009_milkcollectiondairy_header t009
			INNER JOIN t021_tripdocument_header t021 ON t021.TripDocument_Id = t009.TripDocument_Id
            INNER JOIN m008_route_vehicle m008 ON m008.Entry_Id = t021.Route_Trip_Id 
			INNER JOIN m006_route m006 ON m006.Route_Id = m008.Route_Id
			left JOIN c015_collectionshift c015 ON c015.CollectionShift_Id = m006.CollectionShift_Id
			INNER JOIN m003_vehicle m003 ON m003.Vehicle_Id = m008.Vehicle_Id
            and m003.VehicleType_Id = 'C020002'
            INNER JOIN c020_vehicletype c020 ON c020.VehicleType_Id = m003.VehicleType_Id
            LEFT JOIN t009_milkcollectiondairy_quantity t0091 ON t009.Org_Id = t0091.Org_Id
            and t009.TripDocument_Id = t0091.TripDocument_Id
            and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
            and t0091.MilkStatus_Id ='C016001'
			WHERE t009.Org_Id = var_Org_Id
			AND t009.Is_Deleted = 0
            and CAST(t009.Confirm_On  AS DATE) >= var_StartDate 
            and CAST(t009.Confirm_On  AS DATE)  <= var_EndDate
            -- and m008.VehicleType = var_VehicleType
            GROUP BY
				t009.Org_Id,t009.MilkCollectionDairy_Id,t021.TripDocument_Id,
				c015.CollectionShift_Id, c015.CollectionShift_Name,
                c020.VehicleType_Id, c020.VehicleType_Name,
				m006.Route_Id, m006.Route_Name, m006.End_Time,
				m003.Vehicle_Id, m003.Vehicle_No,-- t0091.Rate,
				t009.Is_Active, t009.Is_Deleted,
                t009.Is_Confirm,t009.Is_Release
			
            /*
			UNION ALL
            
			SELECT 
				t009.Org_Id,t009.MilkCollectionDairy_Id,''as TripDocument_Id,
				'' as CollectionShift_Id, '' as CollectionShift_Name,
                'BulkSupplier' as VehicleType_Id, 'Tanker' as VehicleType_Name,
				'' as Route_Id, '' as Route_Name, 
                DATE_FORMAT(t009.Created_On, '%h:%i %p') AS End_Time,
				IFNULL(t009.Vehicle_Id, '') AS Vehicle_Id, IFNULL(t009.Vehicle_Id, '') AS Vehicle_No,
				t009.Is_Active, t009.Is_Deleted,
                t009.Is_Confirm,t009.Is_Release,t009.Is_Locked,
				COALESCE(SUM(t0091.Weight), 0) AS Weight,
                COALESCE(SUM(t0091.Liters), 0) AS Liters,
				COALESCE(SUM(t0091.Cans), 0) AS Total_Cans
                -- t0091.Rate AS Rate
			FROM t009_milkcollectiondairy_header t009
            LEFT JOIN t009_milkcollectiondairy_quantity t0091 ON t009.Org_Id = t0091.Org_Id
            and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
            and t0091.MilkStatus_Id ='C016001'
			WHERE t009.Org_Id = var_Org_Id
			AND t009.Is_Deleted = 0
            and t009.Is_OutsideVehicle =1
            and CAST(t009.Confirm_On  AS DATE) >= var_StartDate 
            and CAST(t009.Confirm_On  AS DATE)  <= var_EndDate
            GROUP BY
				t009.Org_Id,t009.MilkCollectionDairy_Id,TripDocument_Id,
				CollectionShift_Id, CollectionShift_Name,
                VehicleType_Id, VehicleType_Name,
				Route_Id, Route_Name, End_Time,
				Vehicle_Id, Vehicle_No,-- t0091.Rate,
				t009.Is_Active, t009.Is_Deleted,
                t009.Is_Confirm,t009.Is_Release
                
                */
                
			) AS CombinedResult
			ORDER BY 
				CombinedResult.MilkCollectionDairy_Id;
		end;
	elseif (var_Method_Name = 'Get_GRN_Data_V1') then  
		begin
			SELECT 
            t0081.ChemistCollection_Id, 
			t0081.Compartment_No as CellNo, 
			m005.MCC_Id,m005.MCC_Name,
			c011.MilkType_Id,c011.MilkType_Name,
            
            t0081.Sour_Compartment_GRN_Flag as Sour_Compartment_GRN_Flag, 
            t0081.Sour_Compartment_Adjustment_Flag as Sour_Compartment_Adjustment_Flag, 

			t0061.Quantity_Ltr as Agent_Ltr,
			t0061.FAT as Agent_FAT, 
			t0061.SNF as  Agent_SNF,

			t0081.Quantity_Ltr as Chemist_Ltr,
			t0082.FAT as Chemist_FAT, 
			t0082.SNF as  Chemist_SNF,

			t0091.Liters as Composite_Ltr,
			t0092.FAT as Composite_FAT, 
			t0092.SNF as  Composite_SNF,
            t0091.MilkStatus_Id as  MilkStatus_Id,
            
            ifnull(t0093.Protein,0) as Composite_Protein, 
			ifnull(t0093.Ash,0) as  Composite_Ash,
            ifnull(t0093.Sodium,0) as  Composite_Sodium,
            
            ifnull(t0093.FAT,'') as Lab_FAT, 
			ifnull(t0093.SNF,'') as  Lab_SNF,
            
            CASE
				WHEN -- t0081.Final_Quantity_Ltr IS NULL -- OR t0081.Final_Quantity_Ltr = ''  
                ifnull(t0081.Final_Quantity_Ltr,'') = ''
                THEN t0081.Quantity_Ltr
				ELSE t0081.Final_Quantity_Ltr
			END AS Final_Ltr,
            
            CASE
				WHEN -- t0081.Final_Fat  IS NULL -- OR t0081.Final_Fat = ''   
                ifnull(t0081.Final_Fat,'') = ''
                THEN t0082.FAT
				ELSE t0081.Final_Fat
			END AS Final_Fat,
            
            CASE
				WHEN -- t0081.Final_SNF IS NULL -- OR t0081.Final_SNF = ''  
                ifnull(t0081.Final_SNF,'') = ''
                THEN t0082.SNF
				ELSE t0081.Final_SNF
			END AS Final_SNF
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
				and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
				and t021.TripDocument_Id = t022.TripDocument_Id
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
				and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
                and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
				and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
				and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
				and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
				and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
				and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				and t0091.CellNo = t0081.Compartment_No
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
				and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				and t0092.CellNo = t0081.Compartment_No
			inner join m005_mcc m005 on m005.Org_Id = t0081.Org_Id 
				and m005.MCC_Id = t0081.MCC_Id
			inner join c011_milktype c011 on c011.MilkType_Id = t0081.MilkType_Id 
            left join t009_milkcollectiondairy_quality t0093 on t0093.Org_Id = t009.Org_Id 
				and t0093.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				and t0093.MCC_Id = m005.MCC_Id
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			order by t0081.Compartment_No;
        end;
		elseif (var_Method_Name = 'Get_GRN_Data') then  
		begin
			SELECT 
            t0081.ChemistCollection_Id, 
			t0081.Compartment_No as CellNo, 
			m005.MCC_Id,m005.MCC_Name,
			c011.MilkType_Id,c011.MilkType_Name,

			t0061.Quantity_Ltr as Agent_Ltr,
			t0061.FAT as Agent_FAT, 
			t0061.SNF as  Agent_SNF,

			t0081.Quantity_Ltr as Chemist_Ltr,
			t0082.FAT as Chemist_FAT, 
			t0082.SNF as  Chemist_SNF,

			t0091.Liters as Composite_Ltr,
			t0092.FAT as Composite_FAT, 
			t0092.SNF as  Composite_SNF,
            
            ifnull(t0093.Protein,0) as Composite_Protein, 
			ifnull(t0093.Ash,0) as  Composite_Ash,
            ifnull(t0093.Sodium,0) as  Composite_Sodium,
            
            ifnull(t0093.FAT,'') as Lab_FAT, 
			ifnull(t0093.SNF,'') as  Lab_SNF,
            
            CASE
				WHEN -- t0081.Final_Quantity_Ltr IS NULL -- OR t0081.Final_Quantity_Ltr = ''  
                ifnull(t0081.Final_Quantity_Ltr,'') = ''
                THEN t0081.Quantity_Ltr
				ELSE t0081.Final_Quantity_Ltr
			END AS Final_Ltr,
            
            CASE
				WHEN -- t0081.Final_Fat  IS NULL -- OR t0081.Final_Fat = ''   
                ifnull(t0081.Final_Fat,'') = ''
                THEN t0082.FAT
				ELSE t0081.Final_Fat
			END AS Final_Fat,
            
            CASE
				WHEN -- t0081.Final_SNF IS NULL -- OR t0081.Final_SNF = ''  
                ifnull(t0081.Final_SNF,'') = ''
                THEN t0082.SNF
				ELSE t0081.Final_SNF
			END AS Final_SNF
            
			FROM t009_milkcollectiondairy_header t009
			inner join t021_tripdocument_header t021 on t021.Org_Id = t009.Org_Id 
				and t021.TripDocument_Id = t009.TripDocument_Id
			inner join t022_tripdocument_item t022 on t021.Org_Id = t022.Org_Id 
				and t021.TripDocument_Id = t022.TripDocument_Id
			inner join t008_milkcollectionchemist t008 on t008.Org_Id = t022.Org_Id 
				and t008.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
                and t008.DispatchNo = t022.DispatchNo
			inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
				and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
			inner join t008_milkcollectionchemist_item t0082 on t008.Org_Id = t0082.Org_Id 
				and t008.ChemistCollection_Id = t0082.ChemistCollection_Id
			inner join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
				and t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id 
				and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join t009_milkcollectiondairy_quantity t0091 on t0091.Org_Id = t009.Org_Id 
				and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				and t0091.CellNo = t0081.Compartment_No
			inner join t009_milkcollectiondairy_quality t0092 on t0092.Org_Id = t009.Org_Id 
				and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				and t0092.CellNo = t0081.Compartment_No
			inner join m005_mcc m005 on m005.Org_Id = t0081.Org_Id 
				and m005.MCC_Id = t0081.MCC_Id
			inner join c011_milktype c011 on c011.MilkType_Id = t0081.MilkType_Id 
            left join t009_milkcollectiondairy_quality t0093 on t0093.Org_Id = t009.Org_Id 
				and t0093.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
				and t0093.MCC_Id = m005.MCC_Id
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			order by t0081.Compartment_No;
        end;
        elseif (var_Method_Name = 'Send_SMS') then  
        begin
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
                            
			Set @VehicleType_Id = (select m003.VehicleType_Id from t009_milkcollectiondairy_header t009
							inner join m003_vehicle m003 on t009.Org_Id =  m003.Org_Id
							and t009.Vehicle_Id =  m003.Vehicle_Id
							where t009.Org_Id = var_Org_Id 
							and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id  limit 1);
				if(@VehicleType_Id = 'C020001')then
                
					select
					concat('S.R.Thorat:Soc CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: ',c015.CollectionShift_Name,' CM Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: 0 ') as Message,
                    m005.Mobile_No as MobileNo
					from f010_milkcollectionmcc_final f010 
					inner join m005_mcc m005 on m005.Org_Id = f010.Org_Id
						and m005.MCC_Id = f010.MCC_Id
					inner join c015_collectionshift c015 on c015.CollectionShift_Id = @CollectionShift_Id
					where f010.Org_Id = var_Org_Id
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                
                elseif(@VehicleType_Id = 'C020002')then
                
					select
					concat('S.R.Thorat:Third party CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: ',c015.CollectionShift_Name,' Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: 0 ') as Message,
					m005.Mobile_No as MobileNo
					from f010_milkcollectionmcc_final f010 
					inner join m005_mcc m005 on m005.Org_Id = f010.Org_Id
						and m005.MCC_Id = f010.MCC_Id
					inner join c015_collectionshift c015 on c015.CollectionShift_Id = @CollectionShift_Id
					where f010.Org_Id = var_Org_Id
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                    
				elseif((@VehicleType_Id is null) or (@VehicleType_Id = ''))then
                
					select
					concat('S.R.Thorat:Third party CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: ',c015.CollectionShift_Name,' Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: 0 ') as Message,
					m005.Mobile_No as MobileNo
					from f010_milkcollectionmcc_final f010 
					inner join m005_mcc m005 on m005.Org_Id = f010.Org_Id
						and m005.MCC_Id = f010.MCC_Id
					inner join c015_collectionshift c015 on c015.CollectionShift_Id = 'C015003'
					where f010.Org_Id = var_Org_Id
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                
                end if;
                            
				
        end;
	end if;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
