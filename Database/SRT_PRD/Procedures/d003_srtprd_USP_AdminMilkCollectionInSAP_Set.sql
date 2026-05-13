-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionInSAP_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionInSAP_Set`(
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
	if (var_Method_Name = 'PostInSAP') then
		begin
			DECLARE Today_Date DATETIME;
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            Update t009_milkcollectiondairy_posting
			set 
            Year = var_Year,
            SAP_Document_Id = var_SAP_Document_Id,
            Is_Posted = var_Entry_Id
			where Org_Id = var_Org_Id 
			and MilkCollectionPosting_Id = var_MilkCollectionDairy_Id;
            
            SELECT 1 AS Result_Id, 
			'Posted In SAP' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
		end;
elseif (var_Method_Name = 'SetGRNTruck') then
        begin
        
		DECLARE Year_Id varchar(10);
        DECLARE Set_CollectionShift_Id varchar(20);
        DECLARE New_MilkCollectionPosting_Id VARCHAR(20);
        DECLARE milkTypeValue VARCHAR(20);
        DECLARE Set_Created_On VARCHAR(20);
        declare Today_Date datetime;
		DECLARE RatioFat decimal(8,2);
		DECLARE RatioSNF decimal(8,2);
		DECLARE done INT DEFAULT FALSE;
        
        
        
         

        DECLARE milkTypeCursor CURSOR FOR
            SELECT MilkType_Id
            FROM t009_milkcollectiondairy_quantity 
            WHERE Org_Id = var_Org_Id
                AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                AND MilkType_Id IN ('C011001', 'C011002')
            GROUP BY MilkType_Id;
            
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            
            
            SELECT Fat,SNF into RatioFat,RatioSNF  FROM t024_fatsnf_ratio 
            where Ratio_Date <= Today_Date 
            and Org_Id = var_Org_Id
            and Is_Active = 1
            and Is_Deleted = 0
            order by Ratio_Date DESC Limit 1;

        -- Open the cursor
        OPEN milkTypeCursor;

        milkTypeLoop: LOOP
            FETCH milkTypeCursor INTO milkTypeValue;

            -- Exit the loop if there are no more rows
            IF done THEN
                LEAVE milkTypeLoop;
            END IF;

            -- Your existing code here...
            
            
            
            SELECT Created_On INTO Set_Created_On 
            FROM t009_milkcollectiondairy_header 
            WHERE Org_Id = var_Org_Id AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

            set Set_CollectionShift_Id = (
                SELECT m006.CollectionShift_Id  
                FROM t009_milkcollectiondairy_header t009
                INNER JOIN t021_tripdocument_header t021 ON t021.TripDocument_Id = t009.TripDocument_Id AND t021.Org_Id = t009.Org_Id 
                INNER JOIN m008_route_vehicle m008 ON m008.Entry_Id = t021.Route_Trip_Id AND m008.Org_Id = t021.Org_Id 
                INNER JOIN m006_route m006 ON m006.Route_Id = m008.Route_Id AND m006.Org_Id = m008.Org_Id 
                WHERE t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                AND t009.Org_Id = var_Org_Id 
            );

			
            if exists (
                SELECT MilkCollectionPosting_Id 
                FROM t009_milkcollectiondairy_posting 
                WHERE Org_Id = var_Org_Id 
                    AND CollectionShift_Id = Set_CollectionShift_Id 
                    AND DATE(Created_On) = DATE(Set_Created_On)
                    AND (Year IS NULL OR Year = '' OR SAP_Document_Id IS NULL OR SAP_Document_Id = '')
                    AND MilkType_Id = milkTypeValue
            ) THEN
                set @MilkCollectionPosting_Id = (
                    SELECT MilkCollectionPosting_Id 
                    FROM t009_milkcollectiondairy_posting 
                    WHERE Org_Id = var_Org_Id 
                        AND CollectionShift_Id = Set_CollectionShift_Id 
                        AND DATE(Created_On) = DATE(Set_Created_On)
                        AND MilkType_Id = milkTypeValue
                );
                
               

                UPDATE t009_milkcollectiondairy_posting t0091
                inner join t009_milkcollectiondairy_header t009 on  
                t009.Org_Id = t0091.Org_Id or t009.Org_Id = t0091.Org_Id
                and t009.Is_Confirm =1
                and t009.Is_Locked =1
                and t009.Is_Posted = 0
                inner join t009_milkcollectiondairy_quantity t0092 on  
                t009.Org_Id = t0091.Org_Id
                and t0092.MilkStatus_Id = 'C016001'
                and t0092.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id 
                -- and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                SET 
                t0091.Weight =  COALESCE((
                                SELECT 
                                Roundoff('Quantity', sum(t0093.Weight))
                                FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0),
                t0091.Liters = COALESCE((
                                SELECT 
                                Roundoff('Quantity',  sum(t0093.Liters))
                                FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0),
                t0091.Fat = COALESCE((
                                SELECT 
                                Roundoff('Quality', (sum(t0093.Liters * t0093.Fat))/sum(t0093.Liters))
                                FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0),
				/*
                t0091.FatKG = COALESCE((
                                SELECT sum(t0093.FatKG) FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0),
				*/
                t0091.SNF =  COALESCE((
                                SELECT 
                                 Roundoff('Quality', (sum(t0093.Liters * t0093.SNF))/sum(t0093.Liters))
                                FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0),
				/*
                t0091.SNFKG =  COALESCE((
                                SELECT sum(t0093.SNFKG) FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0),
				*/
				t0091.MilkCost =  COALESCE((
                                SELECT sum(t0093.MilkCost) FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0),
				t0091.AgentCost =  COALESCE((
                                SELECT sum(t0093.AgentCost) FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0),
				t0091.TransporterCost =  COALESCE((
                                SELECT sum(t0093.TransporterCost) FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0),
				t0091.MilkPrice =  COALESCE((
                                SELECT sum(t0093.MilkPrice) FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0),
                t0091.TotalLandedCost =  COALESCE((
                                SELECT sum(t0093.TotalLandedCost) FROM t009_milkcollectiondairy_quantity  t0093
                                inner join t009_milkcollectiondairy_header t0094 on 
                                t0094.Org_Id = t0093.Org_Id 
                                and date(t0094.Created_On) = date(Set_Created_On)
                                and t0094.Is_Confirm =1
                                and t0094.Is_Locked =1
                                and t0094.Is_Posted = 0
                                inner join t021_tripdocument_header t021 on t021.Org_Id = t0094.Org_Id
                                and t021.TripDocument_Id = t0094.TripDocument_Id
                                inner join m008_route_vehicle m008 on t021.Org_Id = m008.Org_Id
                                and t021.Route_Trip_Id = m008.Entry_Id
                                inner join m006_route m006 on m006.Org_Id = m008.Org_Id
                                and m006.Route_Id = m008.Route_Id
                                and m006.CollectionShift_Id = Set_CollectionShift_Id
                                WHERE t0093.Org_Id = var_Org_Id 
                                and t0093.Org_Id = t0091.Org_Id 
                                AND MilkStatus_Id = 'C016001'  
                                AND t0093.MilkType_Id = milkTypeValue
                                AND t0093.MilkCollectionDairy_Id = t0094.MilkCollectionDairy_Id
                                ), 0)
                where 
                t0091.Org_Id = var_Org_Id
                and t0091.CollectionShift_Id = Set_CollectionShift_Id
                and date(t0091.Created_On) = date(Set_Created_On)
                and t0091.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
                
                
            ELSE
                set Year_Id = (SELECT RIGHT(LEFT(CURDATE(), 4), 2));
                CALL USP_Number_Range ('t009_milkcollectiondairy_posting', Year_Id, 'T009', '', New_MilkCollectionPosting_Id );
				set @MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                INSERT INTO t009_milkcollectiondairy_posting(
                Org_Id ,MilkCollectionPosting_Id ,CollectionShift_Id ,Created_On ,Batch_Id ,MilkStatus_Id ,
                MilkType_Id ,
                Weight ,Liters ,Fat  , 
                -- FatKG ,
                SNF  , 
                -- SNFKG ,
				TotalLandedCost , 
				MilkCost,AgentCost,TransporterCost,
                MilkPrice
                )
                SELECT t0091.Org_Id, New_MilkCollectionPosting_Id, Set_CollectionShift_Id,date(Set_Created_On),RIGHT(New_MilkCollectionPosting_Id, 9),t0091.MilkStatus_Id,
                milkTypeValue,
                    Roundoff('Quantity', sum(t0091.Weight)),
                    Roundoff('Quantity',  sum(t0091.Liters)),
                    Roundoff('Quality', (sum(t0091.Liters * t0091.Fat))/sum(t0091.Liters)),
                    -- sum(ifnull(t0091.FatKG,0)) ,
                    Roundoff('Quality', (sum(t0091.Liters * t0091.SNF))/sum(t0091.Liters)),
                    -- sum(ifnull(t0091.SNFKG,0)) ,
                    sum(ifnull(t0091.TotalLandedCost,0)) ,
					sum(ifnull(t0091.MilkCost,0)) ,
					sum(ifnull(t0091.AgentCost,0)) ,
					sum(ifnull(t0091.TransporterCost,0)) ,
					sum(ifnull(t0091.MilkPrice,0)) 
                FROM t009_milkcollectiondairy_quantity t0091
                inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id
                and t009.Is_Confirm =1
                and t009.Is_Locked =1
                and t009.Is_Posted = 0
                and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                where t0091.MilkStatus_Id = 'C016001'
                and t0091.Org_Id = var_Org_Id
                and t0091.MilkType_Id = milkTypeValue
                and t0091.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                GROUP BY
                t0091.Org_Id, New_MilkCollectionPosting_Id, Set_CollectionShift_Id, 
                milkTypeValue, 
                t0091.MilkStatus_Id; 
			
            END IF;
            
            Update t009_milkcollectiondairy_posting t009
			set 
			t009.FatKG = ((t009.FAT * t009.Weight)/100),
            t009.SNFKG = ((t009.SNF * t009.Weight)/100)
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
            
			Update t009_milkcollectiondairy_posting t009
			set 
			t009.FEQ = ((((t009.SNFKG)*RatioSNF)/100)+(t009.FatKG))
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
			
			Update t009_milkcollectiondairy_posting t009
			set 
			t009.FatRate = (t009.TotalLandedCost /t009.FEQ)
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
			
			Update t009_milkcollectiondairy_posting t009
			set 
			t009.FatValue = (t009.FatKG *t009.FatRate )
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
			
			Update t009_milkcollectiondairy_posting t009
			set 
			t009.SNFValue = (t009.TotalLandedCost -t009.FatValue)
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
			
			Update t009_milkcollectiondairy_posting t009
			set 
			t009.SNFRate = (t009.SNFValue / t009.SNFKG)
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
            
            Update f010_milkcollectionmcc_final f010
			set 
			f010.MilkCollectionPosting_Id = @MilkCollectionPosting_Id
			where f010.Org_Id = var_Org_Id 
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

           
        END LOOP milkTypeLoop;

        -- Close the cursor
        CLOSE milkTypeCursor;
        
        
        

        SELECT 1 AS Result_Id, 
            'Locked' AS Result_Description, 
            var_MilkCollectionDairy_Id AS Result_Extra_Key;
		end;
	/*
    elseif (var_Method_Name = 'SetGRNTanker') then
    
        begin
        
            

			-- Declare variables
			DECLARE New_MilkCollectionPosting_Id VARCHAR(20);
            DECLARE Today_Date DATETIME;
            DECLARE Set_CollectionShift_Id varchar(20);
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Set_Created_On VARCHAR(20);
			DECLARE done BOOLEAN DEFAULT FALSE;
			DECLARE MCC_Id  VARCHAR(20);
			DECLARE MilkType_Id  VARCHAR(20);
			DECLARE Weight  VARCHAR(20);
			DECLARE Liters  VARCHAR(20);
			DECLARE Set_Fat  VARCHAR(20);
			DECLARE Set_SNF  VARCHAR(20);
            DECLARE Amount  VARCHAR(20);
			DECLARE Year_Id varchar(10);
            

			-- Declare cursor for your SELECT query
			DECLARE cur CURSOR FOR
			SELECT 
				t0081.MCC_Id,
				t0081.MilkType_Id,
                Roundoff('Quantity', SUM(t0081.Final_Quantity_Kg)) AS Weight,
				Roundoff('QuantityForDairy',  SUM(t0081.Final_Quantity_Ltr)) AS Liters,
				Roundoff('Quality', (SUM(t0081.Final_Quantity_Ltr * t0081.Final_Fat))/SUM(t0081.Final_Quantity_Ltr)) AS Set_Fat,
				Roundoff('Quality', (SUM(t0081.Final_Quantity_Ltr * t0081.Final_SNF))/SUM(t0081.Final_Quantity_Ltr)) AS Set_SNF,
                if (t0081.MilkType_Id = 'C011001', t006.Final_Amout_Cow, 
				if (t0081.MilkType_Id = 'C011002', t006.Final_Amout_Buf, 0.00  )  ) 
                as Amount
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
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                and t0081.Final_Quantity_Ltr <> 0
                and t0081.Final_Fat <> 0
                and t0081.Final_SNF <> 0
			GROUP BY t0081.MCC_Id, t0081.MilkType_Id,t006.Final_Amout_Cow,t006.Final_Amout_Buf;



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
				FETCH cur INTO MCC_Id, MilkType_Id, Weight, Liters, Set_Fat, Set_SNF,Amount;
				
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
					VALUES (var_Org_Id,New_MilkCollectionPosting_Id, MCC_Id, 
                    MilkType_Id, Weight, Liters, Set_Fat, Set_SNF,
                    Set_Created_On,RIGHT(New_MilkCollectionPosting_Id, 9),'C016001',Amount);
                    
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.Rate = t009.MilkPrice / t009.Liters
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FatKG = (t009.FAT * t009.Weight)/100,
                    t009.SNFKG = (t009.SNF * t009.Weight)/100 
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.TransporterCost = round(t009.Weight * ( @Set_TransporterCost /  @TotalWeight)),
                    t009.MilkCost = ((t009.Weight * ( t009.Weight / t009.Rate) ) + (@Set_TransporterCost)),
                    t009.AgentCost = 0.00
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    
                    Update t009_milkcollectiondairy_posting t009
                    inner join t009_milkcollectiondairy_mcccommission t0091
					ON t0091.Org_Id = var_Org_Id
					AND t0091.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					AND t0091.MCC_Id = MCC_Id
					AND t0091.MPPIType_Id = 'C047001'
					set 
					t009.AgentCost = t0091.Amount
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                   
                    
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.TotalLandedCost = round(((t009.Liters * t009.Rate) + t009.AgentCost + t009.TransporterCost))
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FEQ = ((((t009.SNFKG)*RatioSNF)/100)+(t009.FatKG))
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;

                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FatRate = (t009.TotalLandedCost /t009.FEQ)
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FatValue = (t009.FatKG *t009.FatRate )
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.SNFValue = (t009.TotalLandedCost -t009.FatValue)
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.SNFRate = (t009.SNFValue / t009.SNFKG)
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update f010_milkcollectionmcc_final f010
					set 
					f010.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id
					where f010.Org_Id = var_Org_Id 
                    and f010.MCC_Id = MCC_Id 
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                    
				END IF;
                
                
			END WHILE;

			-- Close the cursor
			CLOSE cur;

			SELECT 1 AS Result_Id, 
            'Locked' AS Result_Description, 
            var_MilkCollectionDairy_Id AS Result_Extra_Key;
 
        end;
	
    */
    elseif (var_Method_Name = 'SetGRNTanker') then
		
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
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.TransporterCost = round(t009.Weight * ( @Set_TransporterCost /  @TotalWeight)),
                    t009.MilkCost = ((t009.Weight * ( t009.Weight / t009.Rate) ) + (@Set_TransporterCost)),
                    t009.AgentCost = 0.00
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = Set_var_MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    
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
	
    elseif (var_Method_Name = 'SetNewGRNTruck') then
    begin
		DECLARE Year_Id varchar(10);
        DECLARE Set_CollectionShift_Id varchar(20);
        DECLARE New_MilkCollectionPosting_Id VARCHAR(20);
        DECLARE milkTypeValue VARCHAR(20);
        DECLARE Set_Created_On VARCHAR(20);
        declare Today_Date datetime;
		DECLARE RatioFat decimal(8,2);
		DECLARE RatioSNF decimal(8,2);
		DECLARE done INT DEFAULT FALSE;
        
        
        
         

        DECLARE milkTypeCursor CURSOR FOR
            SELECT MilkType_Id
            FROM t009_milkcollectiondairy_quantity 
            WHERE Org_Id = var_Org_Id
                AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                AND MilkType_Id IN ('C011001', 'C011002')
            GROUP BY MilkType_Id;
            
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            
            
            SELECT Fat,SNF into RatioFat,RatioSNF  FROM t024_fatsnf_ratio 
            where Ratio_Date <= Today_Date 
            and Org_Id = var_Org_Id
            and Is_Active = 1
            and Is_Deleted = 0
            order by Ratio_Date DESC Limit 1;

        -- Open the cursor
        OPEN milkTypeCursor;

        milkTypeLoop: LOOP
            FETCH milkTypeCursor INTO milkTypeValue;

            -- Exit the loop if there are no more rows
            IF done THEN
                LEAVE milkTypeLoop;
            END IF;

            -- Your existing code here...
            
            
            
            SELECT Created_On INTO Set_Created_On 
            FROM t009_milkcollectiondairy_header 
            WHERE Org_Id = var_Org_Id AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

            set Set_CollectionShift_Id = (
                SELECT m006.CollectionShift_Id  
                FROM t009_milkcollectiondairy_header t009
                INNER JOIN t021_tripdocument_header t021 ON t021.TripDocument_Id = t009.TripDocument_Id AND t021.Org_Id = t009.Org_Id 
                INNER JOIN m008_route_vehicle m008 ON m008.Entry_Id = t021.Route_Trip_Id AND m008.Org_Id = t021.Org_Id 
                INNER JOIN m006_route m006 ON m006.Route_Id = m008.Route_Id AND m006.Org_Id = m008.Org_Id 
                WHERE t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                AND t009.Org_Id = var_Org_Id 
            );

			
            if exists (
                SELECT MilkCollectionPosting_Id 
                FROM t009_milkcollectiondairy_posting 
                WHERE Org_Id = var_Org_Id 
                    AND CollectionShift_Id = Set_CollectionShift_Id 
                    AND DATE(Created_On) = DATE(Set_Created_On)
                    AND (Year IS NULL OR Year = '' OR SAP_Document_Id IS NULL OR SAP_Document_Id = '')
                    AND MilkType_Id = milkTypeValue
            ) THEN
                set @MilkCollectionPosting_Id = (
                    SELECT MilkCollectionPosting_Id 
                    FROM t009_milkcollectiondairy_posting 
                    WHERE Org_Id = var_Org_Id 
                        AND CollectionShift_Id = Set_CollectionShift_Id 
                        AND DATE(Created_On) = DATE(Set_Created_On)
                        AND MilkType_Id = milkTypeValue
                        and Is_Posted = 0
                );
                
                UPDATE t009_milkcollectiondairy_posting t0091
                SET 
                t0091.Weight =  (select Roundoff('Quantity', sum(f010.Dairy_Quantity_Kg)) 
								from f010_milkcollectionmcc_final f010
								where  f010.Org_Id = t0091.Org_Id 
								and f010.CollectionShift_Id = t0091.CollectionShift_Id 
								and f010.MilkType_Id = milkTypeValue
								and date(f010.Collection_Date) = date(Set_Created_On)),
                t0091.Liters = (select Roundoff('QuantityForDairy',  sum(f010.Dairy_Quantity_Ltr))
								from f010_milkcollectionmcc_final f010
								where  f010.Org_Id = t0091.Org_Id 
								and f010.CollectionShift_Id = t0091.CollectionShift_Id 
								and f010.MilkType_Id = milkTypeValue
								and date(f010.Collection_Date) = date(Set_Created_On)),
                t0091.Fat = (select Roundoff('Quality', (sum(f010.Dairy_Quantity_Ltr * f010.Dairy_Fat))/sum(f010.Dairy_Quantity_Ltr))
								from f010_milkcollectionmcc_final f010
								where  f010.Org_Id = t0091.Org_Id 
								and f010.CollectionShift_Id = t0091.CollectionShift_Id 
								and f010.MilkType_Id = milkTypeValue
								and date(f010.Collection_Date) = date(Set_Created_On)),
                t0091.SNF =  (select Roundoff('Quality', (sum(f010.Dairy_Quantity_Ltr * f010.Dairy_SNF))/sum(f010.Dairy_Quantity_Ltr))
								from f010_milkcollectionmcc_final f010
								where  f010.Org_Id = t0091.Org_Id 
								and f010.CollectionShift_Id = t0091.CollectionShift_Id 
								and f010.MilkType_Id = milkTypeValue
								and date(f010.Collection_Date) = date(Set_Created_On)),
				t0091.MilkCost =  (select sum(ifnull(f010.MilkPrice,0))  +  sum(ifnull(f010.TransporterCost,0))
								from f010_milkcollectionmcc_final f010
								where  f010.Org_Id = t0091.Org_Id 
								and f010.CollectionShift_Id = t0091.CollectionShift_Id 
								and f010.MilkType_Id = milkTypeValue
								and date(f010.Collection_Date) = date(Set_Created_On)),
				t0091.AgentCost =  (select sum(ifnull(f010.AgentCost,0)) 
								from f010_milkcollectionmcc_final f010
								where  f010.Org_Id = t0091.Org_Id 
								and f010.CollectionShift_Id = t0091.CollectionShift_Id 
								and f010.MilkType_Id = milkTypeValue
								and date(f010.Collection_Date) = date(Set_Created_On)),
				t0091.TransporterCost =  (select sum(ifnull(f010.TransporterCost,0)) 
								from f010_milkcollectionmcc_final f010
								where  f010.Org_Id = t0091.Org_Id 
								and f010.CollectionShift_Id = t0091.CollectionShift_Id 
								and f010.MilkType_Id = milkTypeValue
								and date(f010.Collection_Date) = date(Set_Created_On)),
				t0091.MilkPrice =  (select sum(ifnull(f010.MilkPrice,0)) 
								from f010_milkcollectionmcc_final f010
								where  f010.Org_Id = t0091.Org_Id 
								and f010.CollectionShift_Id = t0091.CollectionShift_Id 
								and f010.MilkType_Id = milkTypeValue
								and date(f010.Collection_Date) = date(Set_Created_On)),
                t0091.TotalLandedCost =  (select sum(ifnull(f010.MilkPrice,0))  +  sum(ifnull(f010.TransporterCost,0)) +  sum(ifnull(f010.AgentCost,0)) 
								from f010_milkcollectionmcc_final f010
								where  f010.Org_Id = t0091.Org_Id 
								and f010.CollectionShift_Id = t0091.CollectionShift_Id 
								and f010.MilkType_Id = milkTypeValue
								and date(f010.Collection_Date) = date(Set_Created_On))
                where 
                t0091.Org_Id = var_Org_Id
                and t0091.CollectionShift_Id = Set_CollectionShift_Id
                and date(t0091.Created_On) = date(Set_Created_On)
                and t0091.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
                
                
            ELSE
                set Year_Id = (SELECT RIGHT(LEFT(CURDATE(), 4), 2));
                CALL USP_Number_Range ('t009_milkcollectiondairy_posting', Year_Id, 'T009', '', New_MilkCollectionPosting_Id );
				set @MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                INSERT INTO t009_milkcollectiondairy_posting(
                Org_Id ,MilkCollectionPosting_Id ,CollectionShift_Id ,Created_On ,Batch_Id ,MilkStatus_Id ,
                MilkType_Id ,
                Weight ,Liters ,Fat  , 
                SNF  , 
				TotalLandedCost , 
				MilkCost,AgentCost,TransporterCost,
                MilkPrice
                )
                SELECT f010.Org_Id, 
                New_MilkCollectionPosting_Id, 
                Set_CollectionShift_Id,
                date(Set_Created_On),
                RIGHT(New_MilkCollectionPosting_Id, 9),
                'C016001',
                milkTypeValue,
				Roundoff('Quantity', sum(f010.Dairy_Quantity_Kg)),
				Roundoff('QuantityForDairy',  sum(f010.Dairy_Quantity_Ltr)),
				Roundoff('Quality', (sum(f010.Dairy_Quantity_Ltr * f010.Dairy_Fat))/sum(f010.Dairy_Quantity_Ltr)),
				Roundoff('Quality', (sum(f010.Dairy_Quantity_Ltr * f010.Dairy_SNF))/sum(f010.Dairy_Quantity_Ltr)),
				sum(ifnull(f010.MilkPrice,0))  +  sum(ifnull(f010.TransporterCost,0)) +  sum(ifnull(f010.AgentCost,0)),
				sum(ifnull(f010.MilkPrice,0))  +  sum(ifnull(f010.TransporterCost,0)),
				sum(ifnull(f010.AgentCost,0)) ,
				sum(ifnull(f010.TransporterCost,0)) ,
				sum(ifnull(f010.MilkPrice,0)) 
                FROM f010_milkcollectionmcc_final f010
				where f010.Org_Id = var_Org_Id
                and f010.MilkType_Id = milkTypeValue
                and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
                GROUP BY
                f010.Org_Id, 
                New_MilkCollectionPosting_Id, 
                Set_CollectionShift_Id, 
                milkTypeValue, 
                'C016001'; 
			
            END IF;
            
            Update t009_milkcollectiondairy_posting t009
			set 
			t009.FatKG = ((t009.FAT * t009.Weight)/100),
            t009.SNFKG = ((t009.SNF * t009.Weight)/100)
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
            
			Update t009_milkcollectiondairy_posting t009
			set 
			t009.FEQ = ((((t009.SNFKG)*RatioSNF)/100)+(t009.FatKG))
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
			
			Update t009_milkcollectiondairy_posting t009
			set 
			t009.FatRate = (t009.TotalLandedCost /t009.FEQ)
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
			
			Update t009_milkcollectiondairy_posting t009
			set 
			t009.FatValue = (t009.FatKG *t009.FatRate )
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
			
			Update t009_milkcollectiondairy_posting t009
			set 
			t009.SNFValue = (t009.TotalLandedCost -t009.FatValue)
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
			
			Update t009_milkcollectiondairy_posting t009
			set 
			t009.SNFRate = (t009.SNFValue / t009.SNFKG)
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionPosting_Id = @MilkCollectionPosting_Id;
            
            Update f010_milkcollectionmcc_final f010
			set 
			f010.MilkCollectionPosting_Id = @MilkCollectionPosting_Id
			where f010.Org_Id = var_Org_Id 
			and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;

           
        END LOOP milkTypeLoop;

        -- Close the cursor
        CLOSE milkTypeCursor;
        
        
        

        SELECT 1 AS Result_Id, 
            'Locked' AS Result_Description, 
            var_MilkCollectionDairy_Id AS Result_Extra_Key;
    end;
	
    elseif (var_Method_Name = 'SetGRNBulkSupplier') then
        begin
        
            

			-- Declare variables
			DECLARE New_MilkCollectionPosting_Id VARCHAR(20);
            DECLARE Today_Date DATETIME;
            DECLARE Set_CollectionShift_Id varchar(20);
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Set_Created_On VARCHAR(20);
			DECLARE done BOOLEAN DEFAULT FALSE;
			DECLARE MCC_Id  VARCHAR(20);
			DECLARE MilkType_Id  VARCHAR(20);
			DECLARE Weight  VARCHAR(20);
			DECLARE Liters  VARCHAR(20);
			DECLARE Set_Fat  VARCHAR(20);
			DECLARE Set_SNF  VARCHAR(20);
            DECLARE Amount  VARCHAR(20);
			DECLARE Year_Id varchar(10);
            

			-- Declare cursor for your SELECT query
			DECLARE cur CURSOR FOR
			SELECT 
				t0091.MCC_Id,
				t0091.MilkType_Id,
                Roundoff('Quantity', SUM(t0091.Weight)) AS Weight,
				Roundoff('QuantityForDairy',  SUM(t0091.Liters)) AS Liters,
				Roundoff('Quality', (SUM(t0091.Liters * t0091.Fat))/SUM(t0091.Liters)) AS Set_Fat,
				Roundoff('Quality', (SUM(t0091.Liters * t0091.SNF))/SUM(t0091.Liters)) AS Set_SNF,
                SUM(t0091.Liters * t0091.Rate)as Amount
			FROM t009_milkcollectiondairy_header t009
            inner join t009_milkcollectiondairy_quantity t0091 on
				t009.Org_Id = t0091.Org_Id
                and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
				and t0091.MilkStatus_Id = 'C016001'
			WHERE t009.Org_Id = var_Org_Id 
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			GROUP BY t0091.MCC_Id, t0091.MilkType_Id;

			-- Declare exit handler to close the cursor
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
					
                   
                    
                    SELECT Created_On INTO Set_Created_On 
					FROM t009_milkcollectiondairy_header 
					WHERE Org_Id = var_Org_Id AND MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                    
                    
                    
                    
                    set @TotalWeight =  (SELECT sum(Weight) FROM t009_milkcollectiondairy_quantity where 
										Org_Id = var_Org_Id
										and MilkCollectionDairy_Id =var_MilkCollectionDairy_Id);
					

			-- Open the cursor
			OPEN cur;

			-- Start loop
			my_loop: WHILE NOT done DO
				-- Fetch data from the cursor into variables
				FETCH cur INTO MCC_Id, MilkType_Id, Weight, Liters, Set_Fat, Set_SNF,Amount;
				
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
					VALUES (var_Org_Id,New_MilkCollectionPosting_Id, MCC_Id, 
                    MilkType_Id, Weight, Liters, Set_Fat, Set_SNF,
                    Set_Created_On,RIGHT(New_MilkCollectionPosting_Id, 9),'C016001',Amount);
                    
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.Rate = t009.MilkPrice / t009.Liters
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FatKG = (t009.FAT * t009.Weight)/100,
                    t009.SNFKG = (t009.SNF * t009.Weight)/100 
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.TransporterCost = 0.00,
                    t009.MilkCost = ((t009.Weight * ( t009.Weight / t009.Rate) ) ),
                    t009.AgentCost = 0.00
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    
                    Update t009_milkcollectiondairy_posting t009
                    inner join t009_milkcollectiondairy_mcccommission t0091
					ON t0091.Org_Id = var_Org_Id
					AND t0091.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					AND t0091.MCC_Id = MCC_Id
					AND t0091.MPPIType_Id = 'C047001'
					set 
					t009.AgentCost = t0091.Amount
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                   
                    
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.TotalLandedCost = round(((t009.Liters * t009.Rate) + t009.AgentCost + t009.TransporterCost))
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FEQ = ((((t009.SNFKG)*RatioSNF)/100)+(t009.FatKG))
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;

                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FatRate = (t009.TotalLandedCost /t009.FEQ)
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.FatValue = (t009.FatKG *t009.FatRate )
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.SNFValue = (t009.TotalLandedCost -t009.FatValue)
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update t009_milkcollectiondairy_posting t009
					set 
					t009.SNFRate = (t009.SNFValue / t009.SNFKG)
					where t009.Org_Id = var_Org_Id 
                    and t009.MCC_Id = MCC_Id 
					and t009.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id;
                    
                    Update f010_milkcollectionmcc_final f010
					set 
					f010.MilkCollectionPosting_Id = New_MilkCollectionPosting_Id
					where f010.Org_Id = var_Org_Id 
                    and f010.MCC_Id = MCC_Id 
					and f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                    
				END IF;
                
                
			END WHILE;

			-- Close the cursor
			CLOSE cur;

			SELECT 1 AS Result_Id, 
            'Locked' AS Result_Description, 
            var_MilkCollectionDairy_Id AS Result_Extra_Key;
 
        end;
	elseif (var_Method_Name = 'SetFlag') then
		begin
        
			Update t009_milkcollectiondairy_posting
			set 
            Is_Posted = 1
			where Org_Id = var_Org_Id 
            and Is_Posted = 0
            and ifnull(SAP_Document_Id,'') =''
            and ifnull(Year,'') = ''
			and FIND_IN_SET(MilkCollectionPosting_Id, var_MilkCollectionDairy_Id) > 0;
            
            SELECT 1 AS Result_Id, 
			'Flag' AS Result_Description, 
			'' AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'CratePostInSAP') then
		begin
			DECLARE Today_Date DATETIME;
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            Update t038_receivedcrate_item
				set 
	            Year = var_Year,
	            SAP_Document = var_SAP_Document_Id,
	            Is_Posted = var_Entry_Id
				where Org_Id = var_Org_Id 
				and ReceivedCrate_Id = var_User_Id
				AND Material_Id = var_MilkCollectionDairy_Id ;
            
            SELECT 1 AS Result_Id, 
			'Posted In SAP' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
		end;
	elseif (var_Method_Name = 'Set_ReverseGRN') then
		begin
        
        DECLARE Counter INT DEFAULT 0;
        
			SELECT 
			    CASE 
			        WHEN t009.SAP_Document_Id IS NULL OR t009.SAP_Document_Id = '' THEN 0
			        ELSE 1
			    END into Counter
			FROM 
			    f010_milkcollectionmcc_final f010 
			    left JOIN t009_milkcollectiondairy_posting t009 ON
			        f010.Org_Id =  t009.Org_Id
			        AND f010.MilkCollectionPosting_Id =  t009.MilkCollectionPosting_Id
			WHERE 
			    f010.Org_Id = var_Org_Id
			    AND f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id 
			ORDER BY 
			    t009.SAP_Document_Id DESC 
			LIMIT 1;
            
		if(Counter = 1)then
        
			SELECT -1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
        else
			
            set @VehicleType_Id = (select m003.VehicleType_Id
									from t009_milkcollectiondairy_header t009 
									inner join m003_vehicle m003 on m003.Org_Id = t009.Org_Id
									and m003.Vehicle_Id = t009.Vehicle_Id
									where t009.Org_Id = var_Org_Id
									and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1);

			if(@VehicleType_Id = 'C020001')then
            
				UPDATE  t009_milkcollectiondairy_header t009
				SET 
				t009.Is_Locked = 0
				WHERE t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                
			else
				
                /*
				DELETE FROM t009_milkcollectiondairy_posting t009
				WHERE t009.Org_Id = var_Org_Id 
				AND t009.MilkCollectionPosting_Id IN (
					SELECT f010.MilkCollectionPosting_Id
					FROM f010_milkcollectionmcc_final f010 
					WHERE f010.Org_Id = var_Org_Id
					AND f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				);
                
                */
                
                set @set_Created_On  =  (select date(Created_On) from t009_milkcollectiondairy_header
									where Org_Id = var_Org_Id
									and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
													
                DELETE FROM t009_milkcollectiondairy_posting t009
				WHERE t009.Org_Id = var_Org_Id 
                and date(t009.Created_On) = date(@set_Created_On) 
                and t009.SAP_Document_Id is null
				AND t009.MCC_Id IN (
					SELECT MCC_Id
					FROM (
						SELECT f010.MCC_Id
						FROM f010_milkcollectionmcc_final f010 
						WHERE f010.Org_Id = var_Org_Id
						  AND f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
						UNION ALL
						SELECT f010.MCC_Id
						FROM f010_milkcollectionmcc_final_sour f010 
						WHERE f010.Org_Id = var_Org_Id
						  AND f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					) AS combined_ids
					GROUP BY MCC_Id
				);
				
				UPDATE  t009_milkcollectiondairy_header t009
				SET 
				t009.Is_Locked = 0
				WHERE t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                
            end if;
			/*
			UPDATE  t009_milkcollectiondairy_header t0091
			SET 
			t0091.Is_Locked = 0
			WHERE t0091.Org_Id = var_Org_Id
			AND t0091.MilkCollectionDairy_Id in (SELECT DISTINCT f0101.MilkCollectionDairy_Id
			FROM f010_milkcollectionmcc_final f0101 
			WHERE f0101.Org_Id = var_Org_Id
			and f0101.MilkCollectionPosting_Id  in(
				select t009.MilkCollectionPosting_Id FROM t009_milkcollectiondairy_posting t009
				WHERE t009.Org_Id = var_Org_Id
				AND t009.MilkCollectionPosting_Id IN (
				SELECT f010.MilkCollectionPosting_Id
				FROM f010_milkcollectionmcc_final f010 
				WHERE f010.Org_Id = var_Org_Id
				AND f010.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				)));
				*/
			
			SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
        end if;
		END;
	elseif (var_Method_Name = 'Set_Pending') then
		begin
        
			select 
			MilkCollectionPosting_Id, 
			ifnull(SAP_Document_Id,'') as SAP_Document_Id, ifnull(Year,'') as Year
			into 
			@MilkCollectionPosting_Id,
			@SAP_Document_Id,@Year
			from t009_milkcollectiondairy_posting
			where Org_Id = var_Org_Id 
			and MilkCollectionPosting_Id = var_MilkCollectionDairy_Id;
            
            
			call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
			't009_milkcollectiondairy_posting', @MilkCollectionPosting_Id, @SAP_Document_Id, @Year, 
			var_User_Id, var_User_Name);
               
			Update t009_milkcollectiondairy_posting
			set 
            Is_Posted = 0,
            SAP_Document_Id = '',
            Year = ''
			where Org_Id = var_Org_Id 
			and MilkCollectionPosting_Id = var_MilkCollectionDairy_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
        end ;
	elseif (var_Method_Name = 'Set_Reverse') then
		begin
        
			Update t009_milkcollectiondairy_posting
			set 
            Is_Posted = 1
			where Org_Id = var_Org_Id 
			and MilkCollectionPosting_Id = var_MilkCollectionDairy_Id;
            
            SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
        end;
		elseif (var_Method_Name = 'Set_Delete') then 
		begin

			DECLARE Set_MCC_Id varchar(255);
			DECLARE Set_Created_On DATETIME;
			DECLARE Set_CollectionShift_Id varchar(255);
			DECLARE Set_MilkCollectionDairy_Id varchar(255);
            DECLARE Set_SAP_Document_Id varchar(255);

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
			ifnull(SAP_Document_Id,'') into Set_SAP_Document_Id 
			from t009_milkcollectiondairy_posting
			where Org_Id =  var_Org_Id
			and MCC_Id  in (select MCC_Id from f010_milkcollectionmcc_final where Org_Id =  var_Org_Id and MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id )
			and date(Created_On) = date(Set_Created_On)
			and ifnull(CollectionShift_Id,'C015003') = Set_CollectionShift_Id
            order by SAP_Document_Id desc limit 1;
            
            
            if(Set_SAP_Document_Id is null or Set_SAP_Document_Id = '' or ifnull(Set_SAP_Document_Id,'') = '')then
            
            
				insert into bk_t009_milkcollectiondairy_posting
                select * from t009_milkcollectiondairy_posting 
				where Org_Id =  var_Org_Id
				and MCC_Id  in (select MCC_Id from f010_milkcollectionmcc_final where Org_Id =  var_Org_Id and MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id )
				and date(Created_On) = date(Set_Created_On)
				and ifnull(CollectionShift_Id,'C015003') = Set_CollectionShift_Id;
            
				delete from t009_milkcollectiondairy_posting 
				where Org_Id =  var_Org_Id
				and MCC_Id  in (select MCC_Id from f010_milkcollectionmcc_final where Org_Id =  var_Org_Id and MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id )
				and date(Created_On) = date(Set_Created_On)
				and ifnull(CollectionShift_Id,'C015003') = Set_CollectionShift_Id;
                
                update f010_milkcollectionmcc_final
                set MilkCollectionPosting_Id = ''
				where Org_Id =  var_Org_Id 
                and MilkCollectionDairy_Id = Set_MilkCollectionDairy_Id;
                
				SELECT 1 AS Result_Id, 
				'Delete' AS Result_Description, 
				var_MilkCollectionDairy_Id AS Result_Extra_Key;
            else
				SELECT -1 AS Result_Id, 
				'Material document Found' AS Result_Description, 
				var_MilkCollectionDairy_Id AS Result_Extra_Key;
            end if;
            
		end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
