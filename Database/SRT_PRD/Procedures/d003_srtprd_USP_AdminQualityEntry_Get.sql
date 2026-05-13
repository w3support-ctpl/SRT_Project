-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminQualityEntry_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminQualityEntry_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Date varchar(60),
    var_MilkCollectionDairy_Id varchar(20),
    var_Entry_Id varchar(20)
)
BEGIN
	 if(var_Method_Name = 'Get') then 
		BEGIN
			/*
			SELECT t009.MilkCollectionDairy_Id,t0091.Entry_Id,t0091.Sample_No,
			m003.Vehicle_Id,m003.Vehicle_No,
			c020.VehicleType_Id,c020.VehicleType_Name
			FROM t009_milkcollectiondairy_quality  t0091
			inner join  t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id
				and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
				and t009.Is_Confirm = 1
				and t009.Is_Locked = 0
                AND t009.Is_OutsideVehicle = 0
                and date(t009.Created_On) = date(var_Date)
			inner join  m003_vehicle m003 on m003.Org_Id = t009.Org_Id
				and m003.Vehicle_Id = t009.Vehicle_Id
			inner join  c020_vehicletype c020 on m003.VehicleType_Id = c020.VehicleType_Id
			where t0091.Org_Id = var_Org_Id
            
            UNION ALL
            
            select 
			t009.MilkCollectionDairy_Id,t0091.Entry_Id,t0091.Sample_No,
			 t009.Vehicle_Id,t009.Vehicle_Id as Vehicle_No,
			'BulkSupplier' as VehicleType_Id, 'BulkSupplier' as VehicleType_Name
			from t009_milkcollectiondairy_quality t0091
			inner join  t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id
				and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
				and t009.Is_Confirm = 1
				and t009.Is_Locked = 0
				AND t009.Is_OutsideVehicle = 1
				and date(t009.Created_On) = date(var_Date)
			where t0091.Org_Id = var_Org_Id;
			*/
            
            SELECT t009.MilkCollectionDairy_Id,
			-- m003.Vehicle_Id,m003.Vehicle_No,
            m003.Vehicle_Id,
			CASE 
				WHEN c020.VehicleType_Id = 'C020001' THEN '' 
				WHEN c020.VehicleType_Id = 'C020002' THEN m003.Vehicle_No
				ELSE m003.Vehicle_No -- Fallback to original value if no match
			END as Vehicle_No,
			c020.VehicleType_Id,c020.VehicleType_Name,
            ifnull(c015.CollectionShift_Id,'') as CollectionShift_Id,
            ifnull(c015.CollectionShift_Name,'') as CollectionShift_Name
			FROM t009_milkcollectiondairy_header  t009
			inner join  m003_vehicle m003 on m003.Org_Id = t009.Org_Id
				and m003.Vehicle_Id = t009.Vehicle_Id
			inner join  c020_vehicletype c020 on m003.VehicleType_Id = c020.VehicleType_Id
            inner join t021_tripdocument_header t021 on t021.Org_Id =  t009.Org_Id
				and t021.TripDocument_Id =  t009.TripDocument_Id
			INNER JOIN m008_route_vehicle m008 ON m008.Entry_Id = t021.Route_Trip_Id 
				and m008.Org_Id = t021.Org_Id 
			INNER JOIN m006_route m006 ON m006.Route_Id = m008.Route_Id
				and m006.Org_Id = m008.Org_Id
			INNER JOIN c015_collectionshift c015 ON m006.CollectionShift_Id = c015.CollectionShift_Id
			where t009.Org_Id = var_Org_Id
            -- and t009.Is_Confirm = 0
			and t009.Is_Locked = 0
			AND t009.Is_OutsideVehicle = 0
			and date(t009.Created_On) = date(var_Date)
            
            UNION ALL
            
            select 
			t009.MilkCollectionDairy_Id,
			 t009.Vehicle_Id,t009.Vehicle_Id as Vehicle_No,
			'BulkSupplier' as VehicleType_Id, 'BulkSupplier' as VehicleType_Name,
            '' as CollectionShift_Id,
            '' as CollectionShift_Name
			from t009_milkcollectiondairy_header  t009
			where t009.Org_Id = var_Org_Id
           --  and t009.Is_Confirm = 0
			and t009.Is_Locked = 0
			AND t009.Is_OutsideVehicle = 1
			and date(t009.Created_On) = date(var_Date);
        END;
	elseif(var_Method_Name = 'Get_One') then 
		BEGIN
        declare set_VehicleType_Id varchar(20);
            set set_VehicleType_Id = (select ifnull(m003.VehicleType_Id,'')as VehicleType_Id from  t009_milkcollectiondairy_header t009
									inner join  m003_vehicle m003 on m003.Org_Id =t009.Org_Id and m003.Vehicle_Id =  t009.Vehicle_Id
									where t009.Org_Id = var_Org_Id 
									and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
                
            IF (set_VehicleType_Id = 'C020002' or set_VehicleType_Id = '' OR  set_VehicleType_Id IS NULL) THEN
				select 
				MilkCollectionDairy_Id,
				Entry_Id,
                MilkStatus_Id,
				Sample_No,
				IFNULL(NULLIF(SNF, 0), '') AS SNF,
				IFNULL(NULLIF(Fat, 0), '') AS Fat,
				ifnull(Protein,'') as Protein,
				ifnull(Ash,'') as Ash,
				ifnull(Sodium,'') as Sodium,
                ifnull(Adulteration,'') as Adulteration,
				CASE 
					WHEN 
						SNF IS NOT NULL AND SNF <> '' and 
						Fat IS NOT NULL AND Fat <> '' and 
						Ash IS NOT NULL AND Ash <> '' and 
						Sodium IS NOT NULL AND Sodium <> ''
					THEN 1
					ELSE 0
					END AS Is_Locked,
                     0 as Is_MCC
				FROM t009_milkcollectiondairy_quality 
				where Org_Id =var_Org_Id
                -- AND (MilkStatus_Id = '' OR MilkStatus_Id IS NULL)
				and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

            else
				select 
				MilkCollectionDairy_Id,
				Entry_Id,
                MilkStatus_Id,
				Sample_No,
				IFNULL(NULLIF(SNF, 0), '') AS SNF,
				IFNULL(NULLIF(Fat, 0), '') AS Fat,
				ifnull(Protein,'') as Protein,
				ifnull(Ash,'') as Ash,
				ifnull(Sodium,'') as Sodium,
                ifnull(Adulteration,'') as Adulteration,
				CASE 
					WHEN 
						SNF IS NOT NULL AND SNF <> '' and 
						Fat IS NOT NULL AND Fat <> '' and 
						Ash IS NOT NULL AND Ash <> '' and 
						Sodium IS NOT NULL AND Sodium <> ''
					THEN 1
					ELSE 0
					END AS Is_Locked,
                    0 as Is_MCC
				FROM t009_milkcollectiondairy_quality 
				where Org_Id =var_Org_Id
				and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            end if;
            
           
        END;
		elseif(var_Method_Name = 'Get_One_Truck') then 
        BEGIN
			select 
				MilkCollectionDairy_Id,
				Entry_Id,
                MilkStatus_Id,
				Sample_No,
				IFNULL(NULLIF(SNF, 0), '') AS SNF,
				IFNULL(NULLIF(Fat, 0), '') AS Fat,
				ifnull(Protein,'') as Protein,
				ifnull(Ash,'') as Ash,
				ifnull(Sodium,'') as Sodium,
                ifnull(Adulteration,'') as Adulteration,
				CASE 
					WHEN 
						SNF IS NOT NULL AND SNF <> '' and 
						Fat IS NOT NULL AND Fat <> '' and 
						Ash IS NOT NULL AND Ash <> '' and 
						Sodium IS NOT NULL AND Sodium <> ''
					THEN 1
					ELSE 0
					END AS Is_Locked,
                    0 as Is_MCC
				FROM t009_milkcollectiondairy_quality 
				where Org_Id =var_Org_Id
				and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
        END;
        elseif(var_Method_Name = 'Get_One_Tanker') then 
        BEGIN
			select 
				t009.MilkCollectionDairy_Id,
				t009.Entry_Id,
                t009.MilkStatus_Id,
                CASE 
					WHEN 
						t009.Sample_No IS NOT NULL AND t009.Sample_No <> '' 
					THEN t009.Sample_No 
					ELSE m005.MCC_Name
					END AS Sample_No,
				IFNULL(NULLIF(SNF, 0), '') AS SNF,
				IFNULL(NULLIF(Fat, 0), '') AS Fat,
				ifnull(t009.Protein,'') as Protein,
				ifnull(t009.Ash,'') as Ash,
				ifnull(t009.Sodium,'') as Sodium,
                ifnull(Adulteration,'') as Adulteration,
				CASE 
					WHEN 
						t009.SNF IS NOT NULL AND t009.SNF <> '' and 
						t009.Fat IS NOT NULL AND t009.Fat <> '' and 
						t009.Ash IS NOT NULL AND t009.Ash <> '' and 
						t009.Sodium IS NOT NULL AND t009.Sodium <> ''
					THEN 1
					ELSE 0
					END AS Is_Locked,
				CASE 
					WHEN 
						t009.MCC_Id IS NOT NULL AND t009.MCC_Id <> '' 
					THEN 1
					ELSE 0
					END AS Is_MCC
				FROM t009_milkcollectiondairy_quality  t009
                left join m005_mcc m005 on m005.Org_Id = t009.Org_Id 
					and m005.MCC_Id = t009.MCC_Id
				where t009.Org_Id = var_Org_Id
                -- AND (t009.MilkStatus_Id = '' OR t009.MilkStatus_Id IS NULL)
				and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id order by Is_MCC;
        END;
     end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
