-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionInSAP_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionInSAP_Get`(
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
			
			UNION ALL
            
			SELECT 
				t009.Org_Id,t009.MilkCollectionDairy_Id,''as TripDocument_Id,
				'' as CollectionShift_Id, '' as CollectionShift_Name,
                'BulkSupplier' as VehicleType_Id, 'BulkSupplier' as VehicleType_Name,
				'' as Route_Id, m005.MCC_Name as Route_Name, 
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
            LEFT JOIN m005_mcc m005 ON m005.Org_Id = t0091.Org_Id
            and m005.MCC_Id = t0091.MCC_Id
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
                
			) AS CombinedResult
			ORDER BY 
				CombinedResult.MilkCollectionDairy_Id;
		end;
	elseif (var_Method_Name = 'Get_Locked') then  
		begin
			
            DECLARE var_StartDate DATE;
            DECLARE var_EndDate DATE;
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Today_Date DATETIME;

            SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
            SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT Fat,SNF into RatioFat,RatioSNF  FROM t024_fatsnf_ratio 
            where Ratio_Date <= Today_Date 
            and Org_Id = var_Org_Id 
            and Is_Active = 1
            and Is_Deleted = 0
            order by Ratio_Date DESC Limit 1;
            
            
            select 
			t009.MilkCollectionPosting_Id as MilkCollectionDairy_Id,
			t009.Batch_Id,
            ifnull(t009.SAP_Document_Id, '') as SAP_Document_Id,
            ifnull(t009.Year,'') as Year,
			date_format(t009.Created_On, '%d %M %Y') as Posting_Date,
			ifnull(t009.Weight ,'') as Quantity,
			ifnull(t009.Liters ,'') as Quality, 
			ifnull(t009.MilkPrice ,'') as MilkPrice, 
			ifnull(t009.AgentCost,'') as Agentcost,
			ifnull(t009.TransporterCost,'') as Transportcost,
			ifnull(t009.TotalLandedCost,'') as TotalLandedCost,
			ifnull(t009.Fat,'') as Fat,
			ifnull(t009.FatCost,'') as FatCost,
			ifnull(t009.FatKG,'') as FatKG,
			ifnull(t009.SNF,'') as SNF,
			ifnull(t009.SNFCost,'') as SNFCost,
			ifnull(t009.SNFKG,'') as SNFKG,
			ifnull(t009.FEQ,'') as FEQ,
			ifnull(t009.FatRate,'') as FatRate,
			ifnull(t009.FatValue,'') as FatValue,
			ifnull(t009.SNFValue,'') as SNFValue,
			ifnull(t009.SNFRate,'') as SNFRate,
            c011.MilkType_Id, c011.MilkType_Name,
			c016.MilkStatus_Id, c016.MilkStatus_Name,
            /*
            CASE
				WHEN t009.Year IS NULL OR t009.Year = '' OR t009.SAP_Document_Id IS NULL OR t009.SAP_Document_Id = '' THEN 0
				ELSE 1
			END AS Is_Posted
            */
            Is_Posted as Is_Posted
			from t009_milkcollectiondairy_posting t009
            inner join c011_milktype c011 on c011.MilkType_Id = t009.MilkType_Id 
			inner join c016_milkstatus c016 on c016.MilkStatus_Id = t009.MilkStatus_Id
			where Org_Id = var_Org_Id
            and t009.MilkStatus_Id ='C016001'
            and CAST(t009.Created_On  AS DATE) >= var_StartDate 
            and CAST(t009.Created_On  AS DATE)  <= var_EndDate
            order by t009.MilkCollectionPosting_Id;
		end;
	elseif (var_Method_Name = 'Get_Quantity_SAP') then
		begin
			
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Today_Date DATETIME;
            DECLARE Plant varchar(255);
			DECLARE StorageLocation varchar(255);
            DECLARE GoodsMovementType varchar(255);
			DECLARE Material1 varchar(255);
            DECLARE Material2 varchar(255);
            DECLARE Material3 varchar(255);
            DECLARE Material4 varchar(255);
            DECLARE Material5 varchar(255);
            
            -- SELECT Constant_Value into Plant  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Plant';
			SELECT Constant_Value into StorageLocation  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'StorageLocation';
			SELECT Constant_Value into GoodsMovementType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'GoodsMovementType';
			SELECT Constant_Value into Material1  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material1';
			SELECT Constant_Value into Material2  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material2';
			SELECT Constant_Value into Material3  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material3';
			SELECT Constant_Value into Material4  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material4';
			SELECT Constant_Value into Material5  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material5';

            select m005.Plant_Code into Plant from t009_milkcollectiondairy_posting t009 
			inner join m005_mcc m005 on m005.Org_Id = t009.Org_Id
			and m005.MCC_Id = t009.MCC_Id
			where t009.Org_Id =  var_Org_Id
			and t009.MilkCollectionPosting_Id = var_MilkCollectionDairy_Id;
			
			if(Plant is null or Plant = '') then
				set Plant ='1100';
			end if;
                
                select 
				t009.Batch_Id as Batch, Plant as Plant,
				StorageLocation as StorageLocation, GoodsMovementType as  GoodsMovementType , '' as PurchaseOrder,  '' as PurchaseOrderItem,
				'' as GoodsMovementRefDocType,'L' as EntryUnit, concat('MilkIn ', date_format(t009.Created_On, '%d %M %Y')) as  MaterialDocumentItemText , '' as Supplier, 
                concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t009.Created_On, '+00:00', '+05:30')) * 1000),')/') as  ManufactureDate,
                t009.Liters as QuantityInEntryUnit,
                t009.TotalLandedCost as GdsMvtExtAmtInCoCodeCrcy,
                CASE
					WHEN t009.MilkType_Id = 'C011001' and t009.MilkStatus_Id = 'C016001' and t009.CollectionShift_Id IS NOT NULL AND t009.CollectionShift_Id <> '' THEN Material1
					WHEN t009.MilkType_Id = 'C011002' and t009.MilkStatus_Id = 'C016001' and t009.CollectionShift_Id IS NOT NULL AND t009.CollectionShift_Id <> '' THEN Material2
					WHEN t009.MilkType_Id = 'C011001' and t009.MilkStatus_Id = 'C016001' and t009.MCC_Id IS NOT NULL AND t009.MCC_Id <> '' THEN Material3
					WHEN t009.MilkType_Id = 'C011002' and t009.MilkStatus_Id = 'C016001' and t009.MCC_Id IS NOT NULL AND t009.MCC_Id <> '' THEN Material4
                    WHEN t009.MilkType_Id = 'C011003' and t009.MilkStatus_Id = 'C016001' THEN Material5
					ELSE '' 
				END as Material
				from t009_milkcollectiondairy_posting t009
				where t009.Org_Id = var_Org_Id
				and t009.MilkCollectionPosting_Id = var_MilkCollectionDairy_Id;
		end;
	elseif (var_Method_Name = 'Get_Quantity_SAPCost') then
		begin
        
			DECLARE Plant varchar(255);
			DECLARE StorageLocation varchar(255);
            DECLARE GoodsMovementType varchar(255);
            DECLARE Material1 varchar(255);
            DECLARE Material2 varchar(255);
            DECLARE Material3 varchar(255);
            DECLARE Material4 varchar(255);
            DECLARE Material5 varchar(255);
            
            DECLARE CharcInternalID_TOTQTY varchar(255);
            DECLARE CharcInternalID_FAT varchar(255);
            DECLARE CharcInternalID_SNF varchar(255);
            DECLARE CharcInternalID_TOTFAT varchar(255);
            DECLARE CharcInternalID_TOTSNF varchar(255);
            DECLARE CharcInternalID_FATCOST varchar(255);
            DECLARE CharcInternalID_SNFCOST varchar(255);
            DECLARE CharcInternalID_SPGRYCOST varchar(255);
            
            
            -- SELECT Constant_Value into Plant  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Plant';
			SELECT Constant_Value into StorageLocation  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'StorageLocation';
			SELECT Constant_Value into GoodsMovementType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'GoodsMovementType';
			SELECT Constant_Value into Material1  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material1';
			SELECT Constant_Value into Material2  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material2';
            SELECT Constant_Value into Material3  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material3';
			SELECT Constant_Value into Material4  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material4';
			SELECT Constant_Value into Material5  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material5';

            
            SELECT Constant_Value into CharcInternalID_TOTQTY  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='BATCH' and Constant_Name = 'CharcInternalID_TOTQTY';
			SELECT Constant_Value into CharcInternalID_FAT  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='BATCH' and Constant_Name = 'CharcInternalID_FAT';
			SELECT Constant_Value into CharcInternalID_SNF  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='BATCH' and Constant_Name = 'CharcInternalID_SNF';
			SELECT Constant_Value into CharcInternalID_TOTFAT  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='BATCH' and Constant_Name = 'CharcInternalID_TOTFAT';
			SELECT Constant_Value into CharcInternalID_TOTSNF  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='BATCH' and Constant_Name = 'CharcInternalID_TOTSNF';
			SELECT Constant_Value into CharcInternalID_FATCOST  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='BATCH' and Constant_Name = 'CharcInternalID_FATCOST';
			SELECT Constant_Value into CharcInternalID_SNFCOST  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='BATCH' and Constant_Name = 'CharcInternalID_SNFCOST';
            SELECT Constant_Value into CharcInternalID_SPGRYCOST  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='BATCH' and Constant_Name = 'CharcInternalID_SPGRYCOST';


			select m005.Plant_Code into Plant from t009_milkcollectiondairy_posting t009 
			inner join m005_mcc m005 on m005.Org_Id = t009.Org_Id
			and m005.MCC_Id = t009.MCC_Id
			where t009.Org_Id =  var_Org_Id
			and t009.MilkCollectionPosting_Id = var_MilkCollectionDairy_Id;
			
			if(Plant is null or Plant = '') then
				set Plant ='1100';
			end if;
        
			
                
                select 
				t009.Batch_Id as Batch, Plant as Plant,
				StorageLocation as StorageLocation, GoodsMovementType as  GoodsMovementType , '' as PurchaseOrder,  '' as PurchaseOrderItem,
				'' as GoodsMovementRefDocType,'L' as EntryUnit, concat('MilkIn ', date_format(t009.Created_On, '%d %M %Y')) as  MaterialDocumentItemText , '' as Supplier, 
                concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(t009.Created_On, '+00:00', '+05:30')) * 1000),')/') as  ManufactureDate,
                t009.Liters as QuantityInEntryUnit,
                t009.TotalLandedCost as GdsMvtExtAmtInCoCodeCrcy,
                t009.Fat as Fat,
                t009.FatRate as FatCost,
                t009.FatKG  as TOTFAT,
                t009.SNF as SNF,
                t009.SNFRate as SNFCost,
                t009.SNFKG as TOTSNF,
                round(t009.Weight ,2) as TOTQTY,
                CharcInternalID_TOTQTY,CharcInternalID_FAT,CharcInternalID_SNF,CharcInternalID_TOTFAT,CharcInternalID_TOTSNF,
				CharcInternalID_FATCOST,CharcInternalID_SNFCOST,
                CharcInternalID_SPGRYCOST,
                CASE
					WHEN t009.MilkType_Id = 'C011001' and t009.MilkStatus_Id = 'C016001' and t009.CollectionShift_Id IS NOT NULL AND t009.CollectionShift_Id <> '' THEN Material1
					WHEN t009.MilkType_Id = 'C011002' and t009.MilkStatus_Id = 'C016001' and t009.CollectionShift_Id IS NOT NULL AND t009.CollectionShift_Id <> '' THEN Material2
					WHEN t009.MilkType_Id = 'C011001' and t009.MilkStatus_Id = 'C016001' and t009.MCC_Id IS NOT NULL AND t009.MCC_Id <> '' THEN Material3
					WHEN t009.MilkType_Id = 'C011002' and t009.MilkStatus_Id = 'C016001' and t009.MCC_Id IS NOT NULL AND t009.MCC_Id <> '' THEN Material4
                    WHEN t009.MilkType_Id = 'C011003' and t009.MilkStatus_Id = 'C016001' THEN Material5
					ELSE '' 
				END as Material,
                CASE
					WHEN t009.MilkType_Id = 'C011001' and t009.MilkStatus_Id = 'C016001' and t009.CollectionShift_Id IS NOT NULL AND t009.CollectionShift_Id <> '' THEN '1.03'
					WHEN t009.MilkType_Id = 'C011002' and t009.MilkStatus_Id = 'C016001' and t009.CollectionShift_Id IS NOT NULL AND t009.CollectionShift_Id <> '' THEN '1.03'
					WHEN t009.MilkType_Id = 'C011001' and t009.MilkStatus_Id = 'C016001' and t009.MCC_Id IS NOT NULL AND t009.MCC_Id <> '' THEN '1.03'
					WHEN t009.MilkType_Id = 'C011002' and t009.MilkStatus_Id = 'C016001' and t009.MCC_Id IS NOT NULL AND t009.MCC_Id <> '' THEN '1.03'
                    WHEN t009.MilkType_Id = 'C011003' and t009.MilkStatus_Id = 'C016001' THEN '1.033'
					ELSE '' 
				END as SPGRYCost
				from t009_milkcollectiondairy_posting t009
				where t009.Org_Id = var_Org_Id 
				and t009.MilkCollectionPosting_Id = var_MilkCollectionDairy_Id
				order by t009.MilkCollectionPosting_Id;
		end;
	elseif (var_Method_Name = 'Get_FarmerData') then
		begin
			set @postedCount = (select count(*)  from t009_milkcollectiondairy_quantity t009
            where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.TripDocument_Id = var_TripDocument_Id and ifnull(t009.SAP_Document_Id,'')<>'' );
            if @postedCount = 0 then
				select 
				t005.Amount,mu04.Farmer_Code,right(t005.FarmerCollection_Id,9)as FarmerCollection_Id
				from t009_milkcollectiondairy_quantity t009
				inner join  t022_tripdocument_item t022 on t022.TripDocument_Id = t009.TripDocument_Id
				inner join  t005_milkcollectionfarmer t005 on t005.MCC_Id = t022.MCC_Id
				and t005.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id
				inner join  mu04_farmer mu04 on mu04.Farmer_Id = t005.Farmer_Id
				where t009.Org_Id = var_Org_Id 
				and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				and t009.TripDocument_Id = var_TripDocument_Id
				and t009.Entry_Id = var_Entry_Id
				order by t009.Entry_Id;
            end if;
		end;
        elseif (var_Method_Name = 'Get_GoodsMovementCode') then
			begin
				DECLARE GoodsMovementCode varchar(255);
				SELECT Constant_Value as GoodsMovementCode FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'GoodsMovementCode';
			end;
	elseif (var_Method_Name = 'Get_One') then  
		begin
			select 
			date_format(t009.Created_On, '%d %M %Y') as Posting_Date,
			t009.Batch_Id,
			CASE
				WHEN t009.MCC_Id IS NULL OR t009.MCC_Id = '' THEN 'Truck'
				WHEN t009.CollectionShift_Id IS NULL OR t009.CollectionShift_Id = '' THEN 'Tanker'
				ELSE '' 
			END AS VehicleType_Name,
			ifnull(m005.MCC_Id,'') as MCC_Id,
			ifnull(m005.MCC_Name,'') as MCC_Name,
			ifnull(m005.MCC_Code,'') as MCC_Code,
			ifnull(c015.CollectionShift_Id,'') as CollectionShift_Id,
			ifnull(c015.CollectionShift_Name,'') as CollectionShift_Name,
			c011.MilkType_Id, 
			c011.MilkType_Name,
            ifnull(t009.Weight ,'') as Quantity,
			ifnull(t009.Liters ,'') as Quality,
			ifnull(t009.MilkPrice ,'') as MilkPrice, 
            ifnull(t009.Total_GainLoss ,'') as Total_GainLoss, 
			ifnull(t009.AgentCost,'') as Agentcost,
			ifnull(t009.TransporterCost,'') as Transportcost,
			ifnull(t009.TotalLandedCost,'') as TotalLandedCost,
            ifnull(t009.Fat,'') as Fat,
			ifnull(t009.FatCost,'') as FatCost,
			ifnull(t009.FatKG,'') as FatKG,
			ifnull(t009.SNF,'') as SNF,
			ifnull(t009.SNFCost,'') as SNFCost,
			ifnull(t009.SNFKG,'') as SNFKG,
			ifnull(t009.FEQ,'') as FEQ,
			ifnull(t009.FatRate,'') as FatRate,
			ifnull(t009.FatValue,'') as FatValue,
			ifnull(t009.SNFValue,'') as SNFValue,
			ifnull(t009.SNFRate,'') as SNFRate
			from t009_milkcollectiondairy_posting t009
			inner join c011_milktype c011 on c011.MilkType_Id = t009.MilkType_Id
			left join m005_mcc m005 on m005.Org_Id = t009.Org_Id
				and m005.MCC_Id = t009.MCC_Id
			left join c015_collectionshift c015 on c015.CollectionShift_Id = t009.CollectionShift_Id
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionPosting_Id = var_MilkCollectionDairy_Id;
		end;
	elseif (var_Method_Name = 'Get_Farmer') then  
		begin
			select 
			ifnull(mu04.Farmer_Id ,'') as Farmer_Id,
			ifnull(mu04.Farmer_Name ,'') as Farmer_Name,
			ifnull(mu04.Farmer_Code ,'') as Farmer_Code,
			ifnull(t005.Quantity_Kg ,'') as Quantity,
			ifnull(t005.Quantity_Ltr ,'') as Quality,
			ifnull(t005.Fat,'') as Fat,
			ifnull(t005.SNF,'') as SNF,
			ifnull(t005.ApplicableRate,'') as Rate,
			ifnull(t005.Amount,'') as Amount
			from t009_milkcollectiondairy_posting t0091
			inner join f010_milkcollectionmcc_final f010 on
				f010.Org_Id = t0091.Org_Id 
				and f010.MilkCollectionPosting_Id = t0091.MilkCollectionPosting_Id 
			inner join t009_milkcollectiondairy_header t009 on
				t009.Org_Id = f010.Org_Id 
				and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id 
			inner join t022_tripdocument_item t022 on
				t009.Org_Id = t022.Org_Id 
				and t009.TripDocument_Id  = t022.TripDocument_Id 
                and f010.MCC_Id  = t022.MCC_Id 
			inner join t005_milkcollectionfarmer t005 on
				t005.Org_Id = t022.Org_Id 
				and t005.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id 
				and t005.MilkType_Id = t0091.MilkType_Id
                and f010.MCC_Id  = t005.MCC_Id
			inner join mu04_farmer mu04 on
				t005.Org_Id = mu04.Org_Id 
				and t005.Farmer_Id = mu04.Farmer_Id 
			where t0091.Org_Id = var_Org_Id
			and t0091.MilkCollectionPosting_Id = var_MilkCollectionDairy_Id;
        end;
	elseif (var_Method_Name = 'Get_Dairy') then  
		begin
			select 
            ifnull(f010.Entry_Id ,'') as Entry_Id,
            ifnull(f010.MilkCollectionDairy_Id ,'') as MilkCollectionDairy_Id,
			ifnull(m005.MCC_Id ,'') as MCC_Id,
			ifnull(m005.MCC_Name ,'') as MCC_Name,
			ifnull(m005.MCC_Code ,'') as MCC_Code,
			ifnull(f010.Dairy_Quantity_Kg ,0) as Quantity,
			ifnull(f010.Dairy_Quantity_Ltr ,0) as Quality,
			ifnull(f010.Dairy_Fat,'') as Fat,
			ifnull(f010.Dairy_SNF,'') as SNF,
            ifnull(f010.Dairy_Protein,'') as Protein,
			ifnull(f010.Dairy_Ash,'') as Ash,
            ifnull(f010.Dairy_Sodium,'') as Sodium,
			ifnull(f010.Dairy_Fat_Kg,0) as FatKG,
			ifnull(f010.Dairy_SNF_Kg,0) as SNFKG,
            ifnull(f010.Total_GainLoss,0) as Total_GainLoss,
            ifnull(f010.MilkRate,0) as Rate,
            ifnull(f010.MilkPrice,0) as Amount
			from t009_milkcollectiondairy_posting t009
			inner join f010_milkcollectionmcc_final f010 on
				f010.Org_Id = t009.Org_Id 
				and f010.MilkCollectionPosting_Id = t009.MilkCollectionPosting_Id 
			inner join m005_mcc m005 on
				f010.Org_Id = m005.Org_Id 
				and f010.MCC_Id = m005.MCC_Id 
			where t009.Org_Id = var_Org_Id
			and t009.MilkCollectionPosting_Id = var_MilkCollectionDairy_Id;
        end;
	elseif (var_Method_Name = 'Check_Data_Truck') then  
		begin
			declare Trip_Count int;
			declare Dairy_Count int;
			declare ManageTrip_Count int;
			declare Farmer_Count int;
            declare Agent_Count int;
            declare CheckAvailableFlag varchar(50);
            
			set @TripDocument_Id = (select t009.TripDocument_Id from t009_milkcollectiondairy_header t009 
			where t009.Org_Id= var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);

			-- Trip Document 
			SELECT 
			CASE 
				WHEN IFNULL(FreightRateType_Id, '') != '' THEN 1 
				ELSE 0 
			END into Trip_Count 
			FROM t021_tripdocument_header  
			WHERE Org_Id =  var_Org_Id
			AND TripDocument_Id = @TripDocument_Id 
			LIMIT 1;

			-- Dairy 
			SELECT COUNT(*) into Dairy_Count
			FROM (
				SELECT t0091.MCC_Id AS MCC_Id, t0091.MCCCollectionShift_Id AS MCCCollectionShift_Id
				FROM t009_milkcollectiondairy_header t009 
				INNER JOIN t009_milkcollectiondairy_quantity t0091
				ON t009.Org_Id = t0091.Org_Id
				AND t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
				WHERE t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id =  var_MilkCollectionDairy_Id
				GROUP BY t0091.MCC_Id, t0091.MCCCollectionShift_Id
			) AS subquery;

			-- ManageTrip
			SELECT COUNT(*) into ManageTrip_Count
			FROM (
				select t022.MCC_Id as MCC_Id,  
				t022.MCC_CollectionShift_Id as MCCCollectionShift_Id
				from t022_tripdocument_item t022
				where t022.Org_Id =  var_Org_Id
				and t022.TripDocument_Id = @TripDocument_Id
				group by t022.MCC_Id ,  t022.MCC_CollectionShift_Id 
			) AS subquery;


			-- Farmer
			SELECT COUNT(*) into Farmer_Count
			FROM (
				select t005.MCC_Id as MCC_Id,
				t005.MCCCollectionShift_Id  as MCCCollectionShift_Id
				from t022_tripdocument_item t022
				inner join t005_milkcollectionfarmer t005 on
				t005.Org_Id = t022.Org_Id
				and t022.MCC_CollectionShift_Id = t005.MCCCollectionShift_Id
				and t022.MCC_Id = t005.MCC_Id
				where t022.Org_Id =  var_Org_Id
				and t022.TripDocument_Id = @TripDocument_Id
				group by  t005.MCC_Id,t005.MCCCollectionShift_Id
			) AS subquery;

			-- Agent
			SELECT COUNT(*) into Agent_Count
			FROM (
				select t006.MCC_Id as MCC_Id,
				t006.MCCCollectionShift_Id  as MCCCollectionShift_Id
				from t022_tripdocument_item t022
				inner join t006_milkcollectionagent t006 on
				t006.Org_Id = t022.Org_Id
				and t022.MCC_CollectionShift_Id = t006.MCCCollectionShift_Id
				and t022.MCC_Id = t006.MCC_Id
				inner join t006_milkcollectionagent_item t0061 on
				t006.Org_Id = t0061.Org_Id
				and t0061.AgentCollection_Id = t006.AgentCollection_Id
				where t022.Org_Id = var_Org_Id
				and t022.TripDocument_Id = @TripDocument_Id
				group by  t006.MCC_Id,t006.MCCCollectionShift_Id
			) AS subquery;
            
            
            set CheckAvailableFlag = concat(Trip_Count, ' ',
											Dairy_Count, ' ',
                                            ManageTrip_Count, ' ',
                                            Agent_Count, ' ',
                                            Agent_Count);
			select CheckAvailableFlag;

        end;
	
    elseif (var_Method_Name = 'Check_Data_Tanker') then  
		begin
			declare Trip_Count int;
			declare Chemist_Count int;
			declare ManageTrip_Count int;
			declare Farmer_Count int;
            declare Agent_Count int;
            declare CheckAvailableFlag varchar(50);
            
            
            set @TripDocument_Id = (select t009.TripDocument_Id from t009_milkcollectiondairy_header t009 
			where t009.Org_Id= var_Org_Id
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);

			-- Trip Document 
			SELECT 
			CASE 
				WHEN IFNULL(FreightRateType_Id, '') != '' THEN 1 
				ELSE 0 
			END into Trip_Count 
			FROM t021_tripdocument_header  
			WHERE Org_Id =  var_Org_Id
			AND TripDocument_Id = @TripDocument_Id 
			LIMIT 1;

			-- ManageTrip
			SELECT COUNT(*) into ManageTrip_Count
			FROM (
				select t022.MCC_Id as MCC_Id,  
				t022.MCC_CollectionShift_Id as MCCCollectionShift_Id
				from t022_tripdocument_item t022
				where t022.Org_Id =  var_Org_Id
				and t022.TripDocument_Id = @TripDocument_Id
				group by t022.MCC_Id ,  t022.MCC_CollectionShift_Id 
			) AS subquery;
            
            
            -- Farmer
			SELECT COUNT(*) into Farmer_Count
			FROM (
				select t005.MCC_Id as MCC_Id,
				t005.MCCCollectionShift_Id  as MCCCollectionShift_Id
				from t022_tripdocument_item t022
				inner join t005_milkcollectionfarmer t005 on
				t005.Org_Id = t022.Org_Id
				and t022.MCC_CollectionShift_Id = t005.MCCCollectionShift_Id
				and t022.MCC_Id = t005.MCC_Id
				where t022.Org_Id =  var_Org_Id
				and t022.TripDocument_Id = @TripDocument_Id
				group by  t005.MCC_Id,t005.MCCCollectionShift_Id
			) AS subquery;

			-- Agent
			SELECT COUNT(*) into Agent_Count
			FROM (
				select t006.MCC_Id as MCC_Id,
				t006.MCCCollectionShift_Id  as MCCCollectionShift_Id
				from t022_tripdocument_item t022
				inner join t006_milkcollectionagent t006 on
				t006.Org_Id = t022.Org_Id
				and t022.MCC_CollectionShift_Id = t006.MCCCollectionShift_Id
				and t022.MCC_Id = t006.MCC_Id
				inner join t006_milkcollectionagent_item t0061 on
				t006.Org_Id = t0061.Org_Id
				and t0061.AgentCollection_Id = t006.AgentCollection_Id
				where t022.Org_Id = var_Org_Id
				and t022.TripDocument_Id = @TripDocument_Id
				group by  t006.MCC_Id,t006.MCCCollectionShift_Id
			) AS subquery;
            
            
            -- Chemist
			SELECT COUNT(*) into Chemist_Count
			FROM (
				select t008.MCC_Id as MCC_Id,
				t008.MCCCollectionShift_Id  as MCCCollectionShift_Id
				from t022_tripdocument_item t022
				inner join t008_milkcollectionchemist t008 on
				t008.Org_Id = t022.Org_Id
				and t022.MCC_CollectionShift_Id = t008.MCCCollectionShift_Id
				and t022.MCC_Id = t008.MCC_Id
				inner join t008_milkcollectionchemist_compartment t0081 on
				t008.Org_Id = t0081.Org_Id
				and t0081.ChemistCollection_Id = t008.ChemistCollection_Id
                and t0081.MCC_Id = t008.MCC_Id
                and t0081.Final_Quantity_Kg is not null
                and t0081.Final_Quantity_Ltr is not null
                and t0081.Final_SNF is not null
                and t0081.Final_Fat is not null
                and t0081.FatKG_Agent is not null
                and t0081.SNFKG_Agent is not null
                and t0081.FatKG_Dairy is not null
                and t0081.SNFKG_Dairy is not null
                and t0081.FatKG_GainLoss is not null
                and t0081.SNFKG_GainLoss is not null
                and t0081.FatKG_Rate is not null
                and t0081.SNFKG_Rate is not null
                and t0081.Total_GainLoss is not null
				where t022.Org_Id = var_Org_Id
				and t022.TripDocument_Id = @TripDocument_Id
				group by  t008.MCC_Id,t008.MCCCollectionShift_Id
			) AS subquery;
            
            
            set CheckAvailableFlag = concat(Trip_Count, ' ',
                                            ManageTrip_Count, ' ',
                                            Agent_Count, ' ',
                                            Chemist_Count, ' ',
                                            Farmer_Count);
			select CheckAvailableFlag;
            
        end;
     elseif (var_Method_Name = 'Get_CrateQuantity_SAP') then
		begin
			
         DECLARE var_Plant varchar(255);
			DECLARE var_StorageLocation varchar(255);
         DECLARE var_GoodsMovementType varchar(255);
			DECLARE var_EntryUnit varchar(255);
            
         set var_StorageLocation = (SELECT Constant_Value  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeaderCrate' and Constant_Name = 'StorageLocation');
			set var_GoodsMovementType = (SELECT Constant_Value  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeaderCrate' and Constant_Name = 'GoodsMovementType');
			set var_Plant = (SELECT Constant_Value  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Plant');
			SET var_EntryUnit = (SELECT Constant_Value FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeaderCrate' and Constant_Name = 'EntryUnit');

         select 
			'' as Batch, 
			var_Plant as Plant,
			var_StorageLocation as StorageLocation,
			var_GoodsMovementType as  GoodsMovementType , 
			'' as PurchaseOrder,  
			'' as PurchaseOrderItem,
			'' as GoodsMovementRefDocType,
			var_EntryUnit as EntryUnit, 
			'' as  MaterialDocumentItemText , 
			'' as Supplier, 
			mu08.Dealer_code as Customer, 
			t0381.Good_Quantity as QuantityInEntryUnit,
			m010.Material_Code as Material
			from t038_receivedcrate_item t0381
			inner join t038_receivedcrate_header t038 on 
			t038.Org_Id = t0381.Org_Id
			and t038.ReceivedCrate_Id = t0381.ReceivedCrate_Id
			and t038.Is_Approved = 1
			and t0381.Is_Posted = 1
            inner join m010_material m010 on 
			m010.Org_Id = t0381.Org_Id
			and m010.Material_Id = t0381.Material_Id
			inner join mu08_dealer mu08 on 
			t038.Org_Id = mu08.Org_Id
			and t038.Dealer_Id = mu08.Dealer_Id
			where t0381.Org_Id = var_Org_Id
			and t0381.ReceivedCrate_Id = var_Entry_Id 
			AND t0381.Material_Id = var_MilkCollectionDairy_Id;
		end;
    elseif (var_Method_Name = 'Get_ReverseGRN') then
		begin
			SELECT 
			    CASE 
			        WHEN t009.SAP_Document_Id IS NULL OR t009.SAP_Document_Id = '' THEN 0
			        ELSE 1
			    END AS Is_Locked
			FROM 
			    f010_milkcollectionmcc_final f010 
			    left JOIN t009_milkcollectiondairy_posting t009 ON
			        f010.Org_Id =  t009.Org_Id
			        AND f010.MilkCollectionPosting_Id =  t009.MilkCollectionPosting_Id
			--        AND t009.Year IS NULL
			--        AND t009.SAP_Document_Id IS NULL
			WHERE 
			    f010.Org_Id = var_Org_Id
			    AND f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id 
			ORDER BY 
			    t009.SAP_Document_Id DESC 
			LIMIT 1;

		END;
	elseif (var_Method_Name = 'Get_Delete') then 
		begin

			DECLARE Set_MCC_Id varchar(255);
			DECLARE Set_Created_On DATETIME;
			DECLARE Set_CollectionShift_Id varchar(255);
			DECLARE Set_MilkCollectionDairy_Id varchar(255);

			select 
			MCC_Id,Created_On,ifnull(CollectionShift_Id,'C015003')  as CollectionShift_Id
			into Set_MCC_Id,Set_Created_On,Set_CollectionShift_Id
			from t009_milkcollectiondairy_posting
			where Org_Id =  var_Org_Id
			and MilkCollectionPosting_Id = var_MilkCollectionDairy_Id limit 1;


			select MilkCollectionDairy_Id 
			into Set_MilkCollectionDairy_Id
			from f010_milkcollectionmcc_final 
			where 
			Org_Id =  var_Org_Id
			and MCC_Id = Set_MCC_Id
			and date(Collection_Date) = date(Set_Created_On)
			and ifnull(CollectionShift_Id,'C015003') = Set_CollectionShift_Id limit 1; 

			select 
			Batch_Id,
			ifnull(Year,'') as year,
			ifnull(SAP_Document_Id,'') as sap_document_id ,
			CASE 
				WHEN IFNULL(SAP_Document_Id, '') <> '' THEN 1 
				ELSE 0 
			END AS is_posted
			from t009_milkcollectiondairy_posting
			where Org_Id =  var_Org_Id
			and MCC_Id  in(select MCC_Id from f010_milkcollectionmcc_final where Org_Id =  var_Org_Id and MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id )
			and date(Created_On) = date(Set_Created_On)
			and ifnull(CollectionShift_Id,'C015003') = Set_CollectionShift_Id;
            

		end;
    
   end if;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
