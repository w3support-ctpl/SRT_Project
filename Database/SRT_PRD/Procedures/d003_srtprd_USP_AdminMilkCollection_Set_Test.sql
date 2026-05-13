-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollection_Set_Test` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollection_Set_Test`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_MilkCollectionDairy_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_MCCCollectionShift_Id varchar(20),
    var_MCC_Id varchar(20),
    var_Vehicle_Id varchar(20),
    var_VehicleType_Id varchar(20),
    var_MilkData longtext,
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int,
    var_MCCCommission longtext,
    var_Date varchar(45)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
    SET SQL_SAFE_UPDATES = 0;

    if (var_Method_Name = 'Locked' AND var_VehicleType_Id = 'C020002') then
		begin
			
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Set_TransporterCost varchar(20);
            DECLARE MinimumQuantity decimal(8,2);
            DECLARE MinimumFat decimal(8,2);
            DECLARE MinimumSNF decimal(8,2);
            DECLARE BaseRate decimal(8,2);
            DECLARE FAT_Incentive decimal(8,3);
            DECLARE SNF_Incentive decimal(8,3);
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            DECLARE Today_Date DATETIME;
            DECLARE Set_CollectionShift_Id varchar(20);
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            
            
            SELECT Fat,SNF into RatioFat,RatioSNF  FROM t024_fatsnf_ratio 
            where Ratio_Date <= Today_Date 
            and Org_Id = var_Org_Id
            and Is_Active = 1
            and Is_Deleted = 0
            order by Ratio_Date DESC Limit 1;
            
            set  @TripId = (select TripDocument_Id from t009_milkcollectiondairy_header
            where Org_Id = var_Org_Id and  MilkCollectionDairy_Id = var_MilkCollectionDairy_Id limit 1 );
           
			select ifnull(sum(t006.Final_Amout_Cow),0.00),ifnull(sum(t006.Final_Amout_Buf),0.00) into @CowAmount,@BufAmount from t022_tripdocument_item t022 
			inner join t006_milkcollectionagent t006 on t006.MCC_Id = t022.MCC_Id 
			and  t006.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id 
			where t022.Org_Id = var_Org_Id and  t022.TripDocument_Id = var_TripDocument_Id;
            
			set  @QuantityCow = (select sum(Weight) from t009_milkcollectiondairy_quantity
			where Org_Id = var_Org_Id and  MilkCollectionDairy_Id = var_MilkCollectionDairy_Id 
            and  MilkType_Id = 'C011001');
             
             set  @QuantityBuf = (select sum(Weight) from t009_milkcollectiondairy_quantity
			where Org_Id = var_Org_Id and  MilkCollectionDairy_Id = var_MilkCollectionDairy_Id 
            and  MilkType_Id = 'C011002');
             
            SELECT ifnull(TripAmount, 0.00) into Set_TransporterCost FROM t021_tripdocument_header t021
			WHERE t021.TripDocument_Id = var_TripDocument_Id;
            
			update t009_milkcollectiondairy_quantity t009        
			set t009.Rate = if (t009.MilkType_Id = 'C011001', 
            case when @QuantityCow <> 0 then @CowAmount / @QuantityCow else  0 end, 
			if (t009.MilkType_Id = 'C011002',
            case when @QuantityBuf <> 0 then @BufAmount / @QuantityBuf else  0 end , 0.00  )  )
            
            -- set t009.Rate = if (t009.MilkType_Id = 'C011001' and t006.Final_Qty_Cow_KG <> 0 , t006.Final_Amout_Cow / t006.Final_Qty_Cow_KG, 
			-- if (t009.MilkType_Id = 'C011002' and t006.Final_Qty_Buf_KG <> 0 , t006.Final_Amout_Buf / t006.Final_Qty_Buf_KG, 0.00  )  )
			where t009.Org_Id = var_Org_Id 
			and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			and t009.TripDocument_Id = var_TripDocument_Id
            and t009.MilkStatus_Id = 'C016001';
            
            -- Update FAT & SNF
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
			set t0092.Fat = (SELECT FORMAT(AVG(t0091.Fat), 2) FROM t009_milkcollectiondairy_quality t0091
					   WHERE t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo 
                       and t0092.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id ),
			t0092.SNF = (SELECT FORMAT(AVG(t0091.SNF), 2) FROM t009_milkcollectiondairy_quality t0091
					WHERE t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
                    and t0092.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id )            
            where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
            
            
            
            -- Update FATKG and SNF KG
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
			set FatKG = t0092.FAT * Weight,
			SNFKG = t0092.SNF * Weight          
            where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND Weight > 0
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t0092.MilkStatus_Id = 'C016001';
            
            -- Update FatCost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id 
            and t0092.CellNo = t0091.CellNo
			set FatCost =  ( case when SNFKG <> 0 then
            FatKG * (( t0092.Weight * t0092.Rate) / (SNFKG * RatioSNF / RatioFat) )  else 0 end
            )
			where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            AND t0092.Weight > 0
            and t0092.MilkStatus_Id = 'C016001';
          
            -- Update SNF Cost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
            set SNFCost = ( t0092.Weight * t0092.Rate) - FatCost
            where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
             AND t0092.Weight > 0
             and t0092.MilkStatus_Id = 'C016001';
          
             
             set @TotalWeight = ( select sum(t0092.Weight)  from t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
			where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
             AND t0092.Weight > 0
             and t0092.MilkStatus_Id = 'C016001') ;
             
            
            -- Update MilkCost, TransporterCost and AgentCost
            Update t009_milkcollectiondairy_quantity t0092
            inner join t009_milkcollectiondairy_quality t0091
			on t0092.Org_Id = t0091.Org_Id and t0092.CellNo = t0091.CellNo
			set       
            TransporterCost = t0092.Weight * ( Set_TransporterCost / @TotalWeight),
            MilkCost = ((t0092.Weight * ( case when t0092.Rate <> 0 then  t0092.Weight / t0092.Rate else 0 end) ) + (Set_TransporterCost)),
            AgentCost = 0.00
			where t0092.Org_Id = var_Org_Id 
            and t0092.TripDocument_Id = t0091.TripDocument_Id
            AND t0092.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
			AND t0092.Weight > 0
            and t0092.MilkStatus_Id = 'C016001';
            
            /*
            Update t009_milkcollectiondairy_header
			set 
            Is_Locked =  1,
			LastEditedBy_Id = var_User_Id ,
            LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id 
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            */
            
            call USP_AdminMilkCollectionInSAP_Set_Test('SetGRNTanker', var_Org_Id, '', var_MilkCollectionDairy_Id, '', '',var_User_Id, var_User_Name);
			
            SELECT 1 AS Result_Id, 
			'Locked' AS Result_Description, 
			var_MilkCollectionDairy_Id AS Result_Extra_Key;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
