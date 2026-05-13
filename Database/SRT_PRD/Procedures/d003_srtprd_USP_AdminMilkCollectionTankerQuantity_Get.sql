-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkCollectionTankerQuantity_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkCollectionTankerQuantity_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
    var_Entry_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_Vehicle_Id varchar(20)
    )
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Get') then
		begin
			if exists(select Vehicle_Id from m003_vehicle where Org_Id = var_Org_Id and Vehicle_Id = var_Vehicle_Id and Is_Deleted = 0 and Is_Active = 1) then
            
				select t009.Org_Id, t009.Entry_Id, t009.MilkCollectionDairy_Id,
					   t009.TripDocument_Id, t009.MCCCollectionShift_Id,t009.Batch_Id,
					   t009.MCC_Id,
                       ifnull(t009.GrossWeight,'') as Gross_Weight,
                       ifnull(t009.TareWeight,'') as Tare_Weight,
                       t009.Weight, t009.Liters, t009.Cans, t009.CellNo,
					   Time_FORMAT(t009.Start_Time, '%h:%i %p') AS Start_Time,
					   c011.MilkType_Id, c011.MilkType_Name,
					   c016.MilkStatus_Id, c016.MilkStatus_Name,
					   COALESCE(SUM(t0081.Quantity_Ltr), 0) - t009.Liters as loss
				from t009_milkcollectiondairy_quantity t009
				inner join c011_milktype c011 on c011.MilkType_Id = t009.MilkType_Id 
				inner join c016_milkstatus c016 on c016.MilkStatus_Id = t009.MilkStatus_Id 
				inner join t008_milkcollectionchemist t008 on t008.Org_Id = t009.Org_Id  and t008.Trip_Id = t009.TripDocument_Id 
				inner join t008_milkcollectionchemist_compartment t0081 on t008.Org_Id = t0081.Org_Id 
					and  t008.ChemistCollection_Id = t0081.ChemistCollection_Id
					AND t0081.Compartment_No = t009.CellNo
				where t009.Org_Id = var_Org_Id 
				and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				and t009.TripDocument_Id = var_TripDocument_Id
				GROUP BY 
					t009.Org_Id, t009.Entry_Id, t009.MilkCollectionDairy_Id,t009.TripDocument_Id, 
					t009.MCCCollectionShift_Id,t009.Batch_Id,t009.MCC_Id,t009.GrossWeight,t009.TareWeight, t009.Weight, t009.Liters, t009.Cans, t009.CellNo,
					t009.Start_Time,c011.MilkType_Id, c011.MilkType_Name,c016.MilkStatus_Id, c016.MilkStatus_Name
				order by t009.Entry_Id;
            else 
            
				select t0091.Org_Id, t0091.Entry_Id, t0091.MilkCollectionDairy_Id,
						   '' as TripDocument_Id, '' as MCCCollectionShift_Id,t0091.Batch_Id,
						   t0091.MCC_Id, 
                           ifnull(t0091.GrossWeight,0) as Gross_Weight,
                           ifnull(t0091.TareWeight,0) as Tare_Weight,
                           t0091.Weight, t0091.Liters, t0091.Cans, t0091.CellNo,
						   Time_FORMAT(t0091.Start_Time, '%h:%i %p') AS Start_Time,
						   c011.MilkType_Id, c011.MilkType_Name,
						   c016.MilkStatus_Id, c016.MilkStatus_Name,
						   '' as loss
					from t009_milkcollectiondairy_quantity t0091
					inner join c011_milktype c011 on c011.MilkType_Id = t0091.MilkType_Id 
					inner join c016_milkstatus c016 on c016.MilkStatus_Id = t0091.MilkStatus_Id 
					inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = t0091.Org_Id
					and t009.MilkCollectionDairy_Id = t0091.MilkCollectionDairy_Id
					and t009.Vehicle_Id = var_Vehicle_Id
					where t0091.Org_Id = var_Org_Id
					and t0091.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
					GROUP BY 
						t0091.Org_Id, t0091.Entry_Id, t0091.MilkCollectionDairy_Id,
						t0091.Batch_Id,t0091.MCC_Id,t0091.GrossWeight,t0091.TareWeight, t0091.Weight, t0091.Liters, t0091.Cans, t0091.CellNo,
						t0091.Start_Time,c011.MilkType_Id, c011.MilkType_Name,c016.MilkStatus_Id, c016.MilkStatus_Name
					order by t0091.Entry_Id;
            end  if;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select t009.Org_Id, t009.Entry_Id, t009.MilkCollectionDairy_Id,
				   t009.TripDocument_Id, t009.MCCCollectionShift_Id,t009.Batch_Id,
				   t009.MCC_Id, 
                   ifnull(t009.GrossWeight,0) as Gross_Weight,
                   ifnull(t009.TareWeight,0) as Tare_Weight,
                   t009.Weight, t009.Liters, t009.Cans, t009.CellNo,
				   c011.MilkType_Id, c011.MilkType_Name,
				   c016.MilkStatus_Id, c016.MilkStatus_Name,
                   t009.Reasons
            from t009_milkcollectiondairy_quantity t009
            inner join c011_milktype c011 on c011.MilkType_Id = t009.MilkType_Id 
            inner join c016_milkstatus c016 on c016.MilkStatus_Id = t009.MilkStatus_Id 
            where t009.Org_Id = var_Org_Id  
            and t009.Entry_Id = var_Entry_Id;
		end;
	elseif (var_Method_Name = 'Get_Quantity_SAP') then
		begin
			select 
				t009.Batch_Id as Batch, '1100' as Plant,
				'RMT1' as StorageLocation, 'Z61' as  GoodsMovementType , '' as PurchaseOrder,  '' as PurchaseOrderItem,
				'' as GoodsMovementRefDocType,'L' as EntryUnit, 'item test fr' as  MaterialDocumentItemText , '' as Supplier, 
				'/Date(1696671696000)/' as  ManufactureDate,t009.Liters as QuantityInEntryUnit,
                '33200' as GdsMvtExtAmtInCoCodeCrcy,
				CASE
					WHEN t009.MilkType_Id = 'C011001' and t009.MilkStatus_Id = 'C016001'  THEN 'CGM'
					WHEN t009.MilkType_Id = 'C011002' and t009.MilkStatus_Id = 'C016001' THEN 'BGM'
					ELSE '' 
				END as Material
				from t009_milkcollectiondairy_quantity t009
				where t009.Org_Id = var_Org_Id  
				and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
				and t009.TripDocument_Id = var_TripDocument_Id
				order by t009.Entry_Id;
		end;
	elseif (var_Method_Name = 'Get_BatchId') then
		begin
			select t009.Org_Id,t009.Entry_Id,t009.Batch_Id
            from t009_milkcollectiondairy_quality t009 
            where t009.Org_Id = var_Org_Id  
            and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t009.TripDocument_Id = var_TripDocument_Id
            order by t009.Entry_Id;
		end;
	elseif (var_Method_Name = 'Get_Supervisor') then
		begin
			select t009.Org_Id,t009.Entry_Id,t009.Batch_Id,
            t008.MCCCollectionShift_Id, t0081.Compartment_No,
			m005.MCC_Id ,m005.MCC_Name ,m005.MCC_Code ,
			t0081.Quantity_Kg as Weight,t0081.Quantity_Ltr as Liters 
            from t009_milkcollectiondairy_quantity t009 
            inner join t008_milkcollectionchemist t008 on  t008.Trip_Id = t009.TripDocument_Id
				and t008.Is_BMC_Accepted = '1'
				and t008.Org_Id = t009.Org_Id
            inner join t008_milkcollectionchemist_compartment t0081 on t0081.Org_Id = t008.Org_Id 
				and t0081.ChemistCollection_Id = t008.ChemistCollection_Id
				and t0081.Compartment_No = t009.CellNo
			inner join m005_mcc m005 on m005.Org_Id = t0081.Org_Id 
				and m005.MCC_Id = t0081.MCC_Id
            where t009.Org_Id = var_Org_Id  
            and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
            and t009.Entry_Id = var_Entry_Id
            order by t008.ChemistCollection_Id;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
