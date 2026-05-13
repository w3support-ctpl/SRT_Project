-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMaster` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMaster`(
	IN `var_Method_Name` varchar(255),
	IN `var_Org_Id` varchar(10),
	IN `var_ParentField_Id` varchar(20),
	IN `var_User_Id` varchar(20)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'GetMilkType') then
		begin
			select MilkType_Id as item_id, MilkType_Name as item_value
			from c011_milktype where Is_Deleted = 0
			order by MilkType_Name;
		end;
	elseif (var_Method_Name = 'GetMilkRateEntryType') then
		begin
			select MilkRateEntryType_Id as item_id, MilkRateEntryType_Name as item_value
			from c012_milkrateentrytype where  Is_Deleted = 0
			order by MilkRateEntryType_Name;
		end;
	elseif (var_Method_Name = 'GetMCCCategory') then
		begin
			select MCCCategory_Id as item_id, MCCCategory_Name as item_value
			from c013_mcccategory where  Is_Deleted = 0
			order by MCCCategory_Name;
		end;
	elseif (var_Method_Name = 'GetMCCType') then
		begin
			select MCCType_Id as item_id, MCCType_Name as item_value
			from c014_mcctype where  Is_Deleted = 0
			order by MCCType_Name;
		end;
	elseif (var_Method_Name = 'GetMilkCollectionShift') then
		begin
			select CollectionShift_Id as item_id, CollectionShift_Name as item_value
			from c015_collectionshift where  Is_Deleted = 0 and CollectionShift_Id in ('C015001','C015002')
			order by CollectionShift_Name;
		end;
	elseif (var_Method_Name = 'GetMilkCollectionShiftAll') then
		begin
			select CollectionShift_Id as item_id, CollectionShift_Name as item_value
			from c015_collectionshift where  Is_Deleted = 0  
			order by CollectionShift_Name;
		end;
	elseif (var_Method_Name = 'GetMilkCollectionShiftME') then
		begin
			select CollectionShift_Id as item_id, CollectionShift_Name as item_value
			from c015_collectionshift where  Is_Deleted = 0 and CollectionShift_Id in ('C015001','C015002')
			order by CollectionShift_Name;
		end;
	elseif (var_Method_Name = 'GetMilkCollectionShiftAD') then
		begin
			select CollectionShift_Id as item_id, CollectionShift_Name as item_value
			from c015_collectionshift where  Is_Deleted = 0 and CollectionShift_Id = 'C015003'
			order by CollectionShift_Name;
		end;
	elseif (var_Method_Name = 'GetMilkStatus') then
		begin
			select MilkStatus_Id as item_id, MilkStatus_Name as item_value
			from c016_milkstatus where  Is_Deleted = 0
			order by MilkStatus_Name;
		end;
	elseif (var_Method_Name = 'GetMilkStatusGood') then
		begin
			select MilkStatus_Id as item_id, MilkStatus_Name as item_value
			from c016_milkstatus where  Is_Deleted = 0
			-- and MilkStatus_Id  in ('C016001','C016002')
			order by MilkStatus_Name;
		end;
	elseif (var_Method_Name = 'GetUOM') then
		begin
			select UOM_Id as item_id, UOM_Name as item_value
			from c019_uom where  Is_Deleted = 0
			order by UOM_Name;
		end;
	elseif (var_Method_Name = 'GetVehicleType') then
		begin
			select VehicleType_Id as item_id, VehicleType_Name as item_value
			from c020_vehicletype where  Is_Deleted = 0
			order by VehicleType_Name;
		end;
	
	elseif (var_Method_Name = 'GetOwnershipType') then
		begin
			select VehicleOwnershipType_Id as item_id, VehicleOwnershipType_Name as item_value
			from c021_vehicleownershiptype where Is_Deleted = 0
			order by VehicleOwnershipType_Name;
		end;
	elseif (var_Method_Name = 'GetMusterType') then
		begin
			select MusterType_Id as item_id, MusterType_Name as item_value
			from c022_mustertype where   Is_Deleted = 0
			order by MusterType_Id;
		end;
	elseif (var_Method_Name = 'GetMCCWorkType') then
		begin
			select MCCWorkType_Id as item_id, MCCWorkType_Name as item_value
			from c023_mccworktype where  Is_Deleted = 0
			order by MCCWorkType_Name;
		end;
	elseif (var_Method_Name = 'GetPaymentCycle') then
		begin
			select PaymentCycle_Id as item_id, PaymentCycle_Name as item_value
			from c024_paymentcycle where  Is_Deleted = 0
			order by PaymentCycle_Id;
		end;
	elseif (var_Method_Name = 'GetIncentiveType') then
		begin
			select IncentiveType_Id as item_id, IncentiveType_Name as item_value
			from c025_incentivetype where Is_Deleted = 0
			order by IncentiveType_Name;
		end;
	elseif (var_Method_Name = 'GetFrequency') then
		begin
			select IncentiveFrequency_Id as item_id, IncentiveFrequency_Name as item_value
			from c026_incentivefrequency where Is_Deleted = 0
			order by IncentiveFrequency_Name;
		end;
	elseif (var_Method_Name = 'GetServiceType') then
		begin
			select ServiceType_Id as item_id, ServiceType_Name as item_value
			from c027_servicetype where  Is_Deleted = 0
			order by ServiceType_Name;
		end;
	elseif (var_Method_Name = 'GetServiceTypeMaterialSales') then
		begin
			select ServiceType_Id as item_id, ServiceType_Name as item_value
			from c027_servicetype where  Is_Deleted = 0
            and ServiceType_Id ='C026003'
			order by ServiceType_Name;
		end;
	elseif (var_Method_Name = 'GetDriverType') then
		begin
			select DriverType_Id as item_id, DriverType_Name as item_value
			from c028_drivertype where Is_Deleted = 0
			order by DriverType_Name;
		end;
	elseif (var_Method_Name = 'GetFreightRateType') then
		begin
			select FreightRateType_Id as item_id, FreightRateType_Name as item_value
			from c029_freightratetype where Is_Deleted = 0
			order by FreightRateType_Name;
		end;
	elseif (var_Method_Name = 'GetNomineeRelation') then
		begin
			select NomineeRelation_Id as item_id, NomineeRelation_Name as item_value
			from c030_nomineerelation where Is_Deleted = 0
			order by NomineeRelation_Name;
		end;
	elseif (var_Method_Name = 'GetRouteFrequency') then
		begin
			select RouteFrequency_Id as item_id, RouteFrequency_Name as item_value
			from c031_routefrequency where Is_Deleted = 0
			order by RouteFrequency_Id;
		end;
	elseif (var_Method_Name = 'GetVehicleMake') then
		begin
			select VehicleMake_Id as item_id, VehicleMake_Name as item_value
			from c032_vehiclemake where Is_Deleted = 0
			order by VehicleMake_Name;
		end;
	elseif (var_Method_Name = 'GetPaymentType') then
		begin
			select PaymentType_Id as item_id, PaymentType_Name as item_value
			from c033_paymenttype where Is_Deleted = 0
			order by PaymentType_Name;
		end;
	elseif (var_Method_Name = 'GetComplaintType') then
		begin
			select ComplaintType_Id as item_id, ComplaintType_Name as item_value
			from c034_complainttype where Is_Deleted = 0
			order by ComplaintType_Name;
		end;
	elseif (var_Method_Name = 'GetComplaintStatus') then
		begin
			select ComplaintStatus_Id as item_id, ComplaintStatus_Name as item_value
			from c035_complaintstatus where Is_Deleted = 0
			order by ComplaintStatus_Name;
		end;
	elseif (var_Method_Name = 'GetExpenseType') then
		begin
			select ExpenseType_Id as item_id, ExpenseType_Name as item_value
			from c036_expensetype where Is_Deleted = 0
			order by ExpenseType_Name;
		end;
	elseif (var_Method_Name = 'GetMilkRejectionReason') then
		begin
			select MilkRejectionReason_Id as item_id, MilkRejectionReason_Name as item_value
			from c037_milkrejectionreason where Is_Deleted = 0
			order by MilkRejectionReason_Name;
		end;
	elseif (var_Method_Name = 'GetRequestType') then
		begin
			select RequestType_Id as item_id, RequestType_Name as item_value
			from c038_requesttype where Is_Deleted = 0
			order by RequestType_Name;
		end;
	elseif (var_Method_Name = 'GetMaterialType') then
		begin
			select MaterialType_Id as item_id, MaterialType_Name as item_value
			from c042_materialtype where Is_Deleted = 0
			order by MaterialType_Name;
		end;
	elseif (var_Method_Name = 'GetMPPIType') then
		begin
			select MPPIType_Id as item_id, MPPIType_Name as item_value
			from c047_mppitype where Is_Deleted = 0
			order by MPPIType_Name;
		end;
	elseif (var_Method_Name = 'GetStatus') THEN
        begin
            select '1' as item_id, 'Active' as item_value
            union all
            select '0' as item_id, 'In-active' as item_value;
        end;
	elseif (var_Method_Name = 'GetApprovedStatus') THEN
        begin
            select '1' as item_id, 'Approved' as item_value
            union all
            select '0' as item_id, 'Pending' as item_value
            union all
            select '-1' as item_id, 'Rejected' as item_value;
        end;
	elseif (var_Method_Name = 'GetTripDocumentStatus') THEN
        begin
            select '1' as item_id, 'Confirmed' as item_value
            union all
            select '0' as item_id, 'Pending' as item_value;
        end;
	elseif (var_Method_Name = 'GetSAPPosted') THEN
        begin
            select '0' as item_id, 'Pending' as item_value
            union all
            select '1' as item_id, 'In Queue' as item_value
            union all
            select '2' as item_id, 'Posted' as item_value
            union all
            select '4' as item_id, 'In Complete' as item_value
            union all
            select '3' as item_id, 'Error' as item_value;
        end;
	elseif (var_Method_Name = 'GetLedgerStatus') THEN
        begin
            select '1' as item_id, 'Closed' as item_value
            union all
            select '0' as item_id, 'Pending' as item_value;
        end;
	elseif (var_Method_Name = 'GetVehicleNo') THEN
        begin
            select '1' as item_id, 'Route Vehicle' as item_value
            union all
            select '0' as item_id, 'Outside Vehicle' as item_value;
        end;
-- Master Data Related Tables
	elseif (var_Method_Name = 'GetChart') then
		begin
			select Chart_Id as item_id, Chart_Name as item_value
			from m001_milkrate where Org_Id = var_Org_Id and Is_Active = 1
			order by Chart_Name;
		end;
	elseif (var_Method_Name = 'GetMPPI') then
		begin
			select MPPI_Id as item_id, MPPI_Name as item_value  from m002_commission 
			where Org_Id = var_Org_Id 
             and MPPIType_Id = var_ParentField_Id
			and Is_Lived = 1 
			and Is_Active = 1;
		end;
	elseif (var_Method_Name = 'GetVehicle') then
		begin
			select Vehicle_Id as item_id, Vehicle_No as item_value
			from m003_vehicle where Org_Id = var_Org_Id and Is_Active = 1
			order by Vehicle_No;
		end;
	elseif (var_Method_Name = 'GetTruckVehicle') then
		begin
			select Vehicle_Id as item_id, Vehicle_No as item_value
			from m003_vehicle where Org_Id = var_Org_Id and Is_Active = 1 and VehicleType_Id =  'C020001'
			order by Vehicle_No;
		end;
	elseif (var_Method_Name = 'GetTankerVehicle') then
		begin
			select Vehicle_Id as item_id, Vehicle_No as item_value 
			from m003_vehicle where Org_Id = var_Org_Id and Is_Active = 1 and VehicleType_Id =  'C020002'
			order by Vehicle_No;
		end;
	elseif (var_Method_Name = 'GetVehicleNoType') then
		begin
            SELECT c020.VehicleType_Id as item_id,c020.VehicleType_Name as item_value 
            FROM m003_vehicle m003
			inner join  c020_vehicletype c020 on c020.VehicleType_Id = m003.VehicleType_Id
			where m003.Org_Id = var_Org_Id
			and  m003.Vehicle_Id = var_ParentField_Id;
		end;
	elseif (var_Method_Name = 'GetNoOfCellsInTanker') then
		begin
			DECLARE CellSet varchar(255);
            DECLARE k INT UNSIGNED DEFAULT 1;
            DECLARE tempValue VARCHAR(20);
			SET SESSION sql_require_primary_key = 0;
            /*
			SELECT   NoOfCellsInTanker into @NoOfCellsInTankers
			FROM m003_vehicle
			where Org_Id = var_Org_Id and Is_Active = 1
			and Vehicle_Id = var_ParentField_Id;
            
            DROP TEMPORARY TABLE IF EXISTS temp_number;
			CREATE TEMPORARY TABLE temp_number (PKeyRowNum int,item_id int, item_value int);

			Set @n  = 1;

			WHILE @n <= @NoOfCellsInTankers do
			 BEGIN
				INSERT INTO temp_number (PKeyRowNum, item_id, item_value) VALUES (@n, @n, @n);
				SET @n = @n + 1;
			 END;
			END WHILE;
            
			SELECT item_id, item_value
			FROM temp_number
			ORDER BY item_id;
			*/
            
		if (var_ParentField_Id IS NOT NULL AND var_ParentField_Id <> '') then
            
            SELECT count(t008A.Comartment) into @CountCheck
			FROM t008_milkcollectionchemist t008
			inner join t008_milkcollectionchemist_item t008A on 
			t008A.ChemistCollection_Id = t008.ChemistCollection_Id
			and t008A.Org_Id = t008.Org_Id
			where t008.Org_Id = var_Org_Id 
            and MilkStatus_Id = 'C016001'
			and t008.Trip_Id = var_ParentField_Id;
            
            if @CountCheck > 1 then
                SELECT 
				CONCAT('[', REPLACE(REPLACE(
				CONCAT('[', GROUP_CONCAT(t008A.Comartment ORDER BY t008A.Comartment SEPARATOR ', '), ']')
				, ']', ''), '[', ''), ']')
				into CellSet FROM t008_milkcollectionchemist t008
				inner join t008_milkcollectionchemist_item t008A on 
				t008A.ChemistCollection_Id = t008.ChemistCollection_Id
				and t008A.Org_Id = t008.Org_Id
				where t008.Org_Id = var_Org_Id 
				and t008.Trip_Id = var_ParentField_Id
                and MilkStatus_Id = 'C016001';
            else
				SELECT t008A.Comartment into CellSet 
                FROM t008_milkcollectionchemist t008
				inner join t008_milkcollectionchemist_item t008A on 
				t008A.ChemistCollection_Id = t008.ChemistCollection_Id
				and t008A.Org_Id = t008.Org_Id
				where t008.Org_Id = var_Org_Id 
				and t008.Trip_Id = var_ParentField_Id
                and MilkStatus_Id = 'C016001';
			end if;
			
            
            DROP TEMPORARY TABLE IF EXISTS temp_table;
            CREATE TEMPORARY TABLE temp_table (PKeyRowNum int, item_value int);
            
            SET CellSet = REPLACE(REPLACE(CellSet, '[', ''), ']', '');
			
            WHILE k <= LENGTH(CellSet) - LENGTH(REPLACE(CellSet, ',', '')) + 1 DO
                SET tempValue = SUBSTRING_INDEX(SUBSTRING_INDEX(CellSet, ',', k), ',', -1);
                INSERT INTO temp_table (PKeyRowNum, item_value) VALUES (k, tempValue);
                SET k = k + 1;
            END WHILE;
            
            select DISTINCT
            item_value as item_id ,item_value as item_value
            from  temp_table order by item_id ASC;
            
            else
				select '1' as item_id, '1' as item_value
				union all
				select '2' as item_id, '2' as item_value
				union all
				select '3' as item_id, '3' as item_value
				union all
				select '4' as item_id, '4' as item_value
				union all
				select '5' as item_id, '5' as item_value
				union all
				select '6' as item_id, '6' as item_value
				union all
				select '7' as item_id, '7' as item_value
				union all
				select '8' as item_id, '8' as item_value;
            end if;
		end;
	
	elseif (var_Method_Name = 'GetNoOfCellsInManageTrip') then
		begin
			DECLARE counter INT DEFAULT 1;
			DECLARE intNoOfCells INT;

			SELECT CAST(NoOfCellsInTanker AS SIGNED) INTO intNoOfCells FROM m003_vehicle 
			WHERE Vehicle_Id = var_ParentField_Id AND Org_Id = var_Org_Id ANd VehicleType_Id ='C020002';

			DROP TEMPORARY TABLE IF EXISTS temp_items;
			CREATE TEMPORARY TABLE temp_items (
				item_id INT,
				item_value INT
			);

			WHILE counter <= intNoOfCells DO
				INSERT INTO temp_items (item_id, item_value) VALUES (counter, counter);
				SET counter = counter + 1;
			END WHILE;

			SELECT * FROM temp_items;
        end;
	
	elseif (var_Method_Name = 'GetMCC') then
		begin
			select MCC_Id as item_id, MCC_Name as item_value
			from m005_mcc where Org_Id = var_Org_Id and Is_Active = 1
			order by MCC_Name;
		end;
	elseif (var_Method_Name = 'GetBMCMCC') then
		begin
			select MCC_Id as item_id, concat(ifnull(MCC_Code,''),' - ',MCC_Name)  as item_value
			from m005_mcc where Org_Id = var_Org_Id and Is_Active = 1 and MCCType_Id in ('C014002','C014003')
			order by MCC_Name;
		end;
	elseif (var_Method_Name = 'GetCanMCC') then
		begin
			select MCC_Id as item_id, concat(ifnull(MCC_Code,''),' - ',MCC_Name) as item_value
			from m005_mcc where Org_Id = var_Org_Id and Is_Active = 1 and MCCType_Id = 'C014001'
			order by MCC_Name;
		end;
	elseif (var_Method_Name = 'GetBulkSupplierMCC') then
		begin
			select MCC_Id as item_id, MCC_Name as item_value
			from m005_mcc where Org_Id = var_Org_Id and Is_Active = 1 and MCCType_Id = 'C014003'
			order by MCC_Name;
		end;
	elseif (var_Method_Name = 'Get_MCC') then
		begin
			select MCC_Id as item_id, MCC_Name as item_value  from m005_mcc 
			where Org_Id = var_Org_Id 
             and MCCType_Id = var_ParentField_Id
			and Is_Active = 1;
		end;
	elseif (var_Method_Name = 'Get_MCC_ALL') then
		begin
			select MCC_Id as item_id, MCC_Name as item_value
			from m005_mcc where Org_Id = var_Org_Id 
			order by MCC_Name;
		end;
	elseif (var_Method_Name = 'GetRoute') then
		begin
			select Route_Id as item_id, Route_Name as item_value
			from m006_route where Org_Id = var_Org_Id and Is_Active = 1
			order by Route_Name;
		end;
	elseif (var_Method_Name = 'GetRouteLive') then
		begin
			Declare Current_Datetime datetime;
			set Current_Datetime = CAST(CONVERT_TZ(NOW(), '+00:00', '+00:00') AS DATE);
            
			select Route_Id as item_id, Route_Name as item_value
			from m006_route where Org_Id = var_Org_Id 
            and End_Date >= Current_Datetime
            and VehicleType_Id = var_ParentField_Id
            and Is_Active = 1 
            and Is_Lived = 1
			order by Route_Name;
		end;
	elseif (var_Method_Name = 'GetIssueEmptyCansRoute') then
		begin
			select m006.Route_Id as item_id, m006.Route_Name as item_value
			from m008_route_vehicle m008
            INNER JOIN m006_route m006 ON m006.Route_Id = m008.Route_Id and m006.Org_Id = m008.Org_Id
            where m008.Org_Id = var_Org_Id and m008.Is_Active = 1 and m008.VehicleType = 'truck'
            GROUP BY m006.Route_Id,m006.Route_Name
			order by m006.Route_Name; 
		end;
	elseif (var_Method_Name = 'GetTransporter') then
		begin
			select Transporter_Id as item_id, Transporter_Name as item_value
			from m009_transporter where Org_Id = var_Org_Id and Is_Active = 1
			order by Transporter_Name;
		end;
	elseif (var_Method_Name = 'GetMaterial') then
		begin
			select Material_Id as item_id, Material_Name as item_value
			from m010_material where Org_Id = var_Org_Id and Is_Active = 1
			order by Material_Name;
		end;
	elseif (var_Method_Name = 'GetMaterials') then
		begin
			/*
			select Material_Id as item_id, Material_Name as item_value
			from m010_material where Org_Id = var_Org_Id and Is_Active = 1
			and (MaterialType_Id is not null or MaterialType_Id <> '')
			order by Material_Name;
            */
            select Material_Id as item_id, Material_Name as item_value
			from m010_material where Org_Id = var_Org_Id and Is_Active = 1
			and (MaterialType_Id is not null or MaterialType_Id <> '')
            and Is_TradingMaterial = 0
            
            union all
            
            select Material_Id as item_id, Material_Name as item_value
			from m010_material where Org_Id = var_Org_Id and Is_Active = 1
			and (MaterialType_Id is not null or MaterialType_Id <> '')
            and Is_TradingMaterial = 1
            
            union all
            
            select Material_Id as item_id, Material_Name as item_value
			from m010_material where Org_Id = var_Org_Id and Is_Active = 1
			and (MaterialType_Id is null or MaterialType_Id = '')
            and Is_TradingMaterial = 1;
		end;
	elseif (var_Method_Name = 'GetSalesArea') then
		begin
			select SalesArea_Id as item_id, SalesArea_Name as item_value
			from m013_salesarea where Org_Id = var_Org_Id and Is_Active = 1
			order by SalesArea_Name;
		end;
        
	elseif (var_Method_Name = 'GetSalesAreaforSaleOrder') then
		begin
			select SalesArea_Code as item_id, SalesArea_Name as item_value
			from m013_salesarea where Org_Id = var_Org_Id and Is_Active = 1
			order by SalesArea_Name;
		end;
        
	elseif (var_Method_Name = 'GetSalesAreaCode') then
		begin
			select SalesArea_Code as item_id, SalesArea_Name as item_value
			from m013_salesarea where Org_Id = var_Org_Id 
            and Is_Active = 1
            and SalesArea_Code = var_ParentField_Id
			order by SalesArea_Name;
		end;
	elseif (var_Method_Name = 'GetSalesAreaName') then
		begin
			select concat(m013.SalesArea_Code , ' - ',m0131.SalesOffice_Code , ' - ',m0131.SalesOrg_Code , ' - ',m0131.DistChannel_Code , ' - ',m0131.Division_Code) as item_id,
			m0131.SAPSalesArea_Name as item_value
			from m013_salesarea_item m0131
			inner join m013_salesarea m013 on
			m013.Org_Id = m0131.Org_Id 
			and m013.SalesOffice_Code =  m0131.SalesOffice_Code
			and m013.SalesArea_Code = var_ParentField_Id
			where m0131.Org_Id = var_Org_Id
			and m0131.Is_Active = 1
			order by SAPSalesArea_Name;
		end;
	elseif (var_Method_Name = 'GetFatSlab') then
		begin
			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id and Is_Active = 1 and Slab_Type = 'fat'
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'GetSNFSlab') then
		begin
			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id and Is_Active = 1 and Slab_Type = 'snf'
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'Get_FatDeduction') then
		begin
			set @FAT = (select FAT from c011_milktype
			where Is_Deleted = var_Org_Id
			and MilkType_Id = var_ParentField_Id) ;

			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id 
			and Is_Active = 1 
			and Slab_Type = 'fat'
			and Slab_Max <= @FAT
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'Get_FatIncentives') then
		begin
			set @FAT = (select FAT from c011_milktype
			where Is_Deleted = var_Org_Id
			and MilkType_Id = var_ParentField_Id) ;

			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id 
			and Is_Active = 1 
			and Slab_Type = 'fat'
			and Slab_Max > @FAT
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'Get_SNFDeduction') then
		begin
			set @SNF = (select SNF from c011_milktype
			where Is_Deleted = var_Org_Id
			and MilkType_Id = var_ParentField_Id) ;

			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id 
			and Is_Active = 1 
			and Slab_Type = 'snf'
			and Slab_Max <= @SNF
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'Get_SNFIncentives') then
		begin
			set @SNF = (select SNF from c011_milktype
			where Is_Deleted = var_Org_Id
			and MilkType_Id = var_ParentField_Id) ;

			select Slab_Id as item_id, Slab_Name as item_value
			from m014_slab where Org_Id = var_Org_Id 
			and Is_Active = 1 
			and Slab_Type = 'snf'
			and Slab_Max > @SNF
			order by Slab_Name;
		end;
	elseif (var_Method_Name = 'GetBank') then
		begin
			select Bank_Id as item_id, Bank_Name as item_value
			from m015_bank where Org_Id = var_Org_Id and Is_Active = 1
			order by Bank_Name;
		end;
	elseif (var_Method_Name = 'GetBranch') then
		begin
			select Branch_Id as item_id, Branch_Name as item_value
			from m016_branch where Org_Id = var_Org_Id and Bank_Id = var_ParentField_Id and Is_Active = 1
			order by Branch_Name;
		end;
	elseif (var_Method_Name = 'GetState') then
		begin
			select State_Id as item_id, State_Name as item_value
			from ml02_state where Org_Id = var_Org_Id and Is_Active = 1
			order by State_Name;
		end;
	elseif (var_Method_Name = 'GetDistrict') then
		begin
			select District_Id as item_id, District_Name as item_value
			from ml03_district where Org_Id = var_Org_Id and State_Id = var_ParentField_Id and Is_Active = 1
			order by District_Name;
		end;
	elseif (var_Method_Name = 'GetTaluka') then
		begin
			select Taluka_Id as item_id, Taluka_Name as item_value
			from ml04_taluka where Org_Id = var_Org_Id and District_Id = var_ParentField_Id and Is_Active = 1
			order by Taluka_Name;
		end;
	elseif (var_Method_Name = 'GetVillage') then
		begin
			select Village_Id as item_id, Village_Name as item_value
			from ml05_village where Org_Id = var_Org_Id and Taluka_Id = var_ParentField_Id and Is_Active = 1
			order by Village_Name;
		end;
	elseif (var_Method_Name = 'GetUserRole') then
		begin
			select Role_Id as item_id, Role_Name as item_value
			from mu01_role where Org_Id = var_Org_Id and Is_Active = 1
            and Is_Deleted = 0
			order by Role_Name;
		end;
	elseif (var_Method_Name = 'GetMCCFarmer') then
		begin
			SELECT Farmer_Id as item_id, Farmer_Name as item_value
            FROM mu04_farmer
			where MCC_Id = var_ParentField_Id
			and Org_Id = var_Org_Id
			and Is_Active = 1
			and Is_Deleted = 0
			order by Farmer_Name;
		end;
	elseif (var_Method_Name = 'GetAgent') then
		begin
			select Agent_Id as item_id, Agent_Name as item_value
			from mu05_agent where Org_Id = var_Org_Id and Is_Active = 1
			order by Agent_Name;
		end;
	elseif (var_Method_Name = 'GetDriver') then
		begin
			select Driver_Id as item_id, Driver_Name as item_value
			from mu06_driver where Org_Id = var_Org_Id and Is_Active = 1
			order by Driver_Name;
		end;
	elseif (var_Method_Name = 'GetRouteChemist') then
		begin
			select Chemist_Id as item_id, Chemist_Name as item_value
			from mu07_routechemist where Org_Id = var_Org_Id and Is_Active = 1
			order by Chemist_Name;
		end;
	elseif (var_Method_Name = 'GetComplaintType') then
		begin
			select ComplaintType_Id as item_id, ComplaintType_Name as item_value
			from c034_complainttype where Is_Active = 1
			order by ComplaintType_Name;
		end;
	elseif (var_Method_Name = 'GetComplaintStatus') then
		begin
			select ComplaintStatus_Id as item_id, ComplaintStatus_Name as item_value
			from c035_complaintstatus where Is_Active = 1
			order by ComplaintStatus_Name;
		end;
	elseif (var_Method_Name = 'GetComplaintStatusOpenResolved') then
		begin
			select ComplaintStatus_Id as item_id, ComplaintStatus_Name as item_value
			from c035_complaintstatus 
            where ComplaintStatus_Id IN ('C035002','C035003')
            and Is_Active = 1
			order by ComplaintStatus_Name;
		end;
	-- SALES :: get id & name of all sales user in mu12_sales_user table
    elseif (var_Method_Name = 'GetDealer') then
		begin
			select Dealer_Id as item_id, concat(Dealer_Code , ' - ',Dealer_Name) as item_value
			from mu08_dealer where Org_Id = var_Org_Id and Is_Active = 1
			order by Dealer_Name;
		end;
        elseif (var_Method_Name = 'GetRetailer') then
		begin
			select Retailer_Id as item_id, Retailer_Name as item_value
			from mu09_retailer where Org_Id = var_Org_Id and Is_Active = 1
			order by Retailer_Name;
		end;
	elseif (var_Method_Name = 'GetAreaSalesManager') then
		begin
			select SalesUser_Id as item_id, SalesUser_Name as item_value
			from mu12_sales_user 
            where Is_Deleted = 0
            and SalesUserRole_Id = 'C044002'
			order by SalesUser_Name;
		end;
        elseif (var_Method_Name = 'GetSalesUser') then
		begin
			select SalesUser_Id as item_id, SalesUser_Name as item_value
			from mu12_sales_user 
            where Is_Deleted = 0
			order by SalesUser_Name;
		end;
	elseif (var_Method_Name = 'GetIFSCCode') then
		begin
			select Branch_Id as item_id, IFSC_Code as item_value
			from m016_branch 
            where Is_Deleted = 0
            AND Branch_Id = var_ParentField_Id;
		end;
	elseif (var_Method_Name = 'GetProducts') then
		begin
			select Product_Id as item_id, Product_Name as item_value
			from m017_product 
            where Is_Deleted = 0
            and Org_Id = var_Org_Id
			order by Product_Name;
		end;
	elseif (var_Method_Name = 'GetProductsCode') then
		begin
			select Product_Code as item_id, Product_Name as item_value
			from m017_product 
            where Is_Deleted = 0
            and Org_Id = var_Org_Id
			order by Product_Name;
		end;
        
	elseif (var_Method_Name = 'GetProductOndivision') then
		begin
			select Product_Code as item_id, Product_Name as item_value
			from m017_product 
            where Is_Deleted = 0
            and Org_Id = var_Org_Id and Division_Code = var_ParentField_Id
			order by Product_Name;
		end;
    
	elseif (var_Method_Name = 'GetProductRate') then
		begin
			select Product_Id as item_id, 
            ifnull(Rate, '') as item_value
			from m017_product 
            where Is_Deleted = 0
            AND Product_Id = var_ParentField_Id;
		end;
	elseif (var_Method_Name = 'GetSalesUserRole') then
		begin
			select SalesUserRole_Id as item_id, 
            SalesUserRole_Name as item_value
			from c044_sales_user_role;
		end;
	elseif (var_Method_Name = 'GetFinancialYear') then
		begin
			select Year_Id as item_id, 
            Year_Name as item_value
			from c046_financial_year;
		end;
	elseif (var_Method_Name = 'GetUserType') then
		begin
			select User_Type as item_id,
			User_Type as item_value
			from  m020_deductions_head
			where Org_Id = var_Org_Id
            and Is_Active = 1
			group by User_Type;
		end;
	elseif (var_Method_Name = 'GetFarmer') then
		begin
			select Farmer_Id as item_id, 
            Farmer_Name as item_value
			from mu04_farmer 
            where Is_Active = 1
            and Org_Id = var_Org_Id
            order by Farmer_Name;
		end;
	elseif (var_Method_Name = 'GetRequestTypes') then
		begin
			select DeductionHead_Id as item_id,
			DeductionHead_Name as item_value
			from  m020_deductions_head
			where Org_Id = var_Org_Id
            and Is_Active = 1
			AND User_Type = var_ParentField_Id;
		end;
	elseif (var_Method_Name = 'GetIncentiveTypes') then
		begin
			select IncentiveHead_Id as item_id,
			IncentiveHead_Name as item_value
			from  m020_incentives_head
			where Org_Id = var_Org_Id
            and Is_Active = 1
			AND User_Type = var_ParentField_Id;
		end;
        
	elseif (var_Method_Name = 'GetSchemeStatus') THEN
        begin
            select '1' as item_id, 'Active' as item_value
            union all
            select '0' as item_id, 'In-Active' as item_value
            union all
            select '2' as item_id, 'Completed' as item_value;
        end;
	elseif (var_Method_Name = 'GetInquiryStatus') THEN
        begin
            select '1' as item_id, 'Successfully Closed' as item_value
            union all
            select '0' as item_id, 'Open' as item_value
            union all
            select '-1' as item_id, 'Cancelled' as item_value;
        end;
	elseif (var_Method_Name = 'GetReportTypes') then
		begin
			select '' as item_id, 'Select Report Type' as item_value

            union all
			select ReportType_Id as item_id,
			ReportType_Name as item_value
			from  c048_reporttype
			where 
            Is_Active = 1
			AND ReportGroup = var_ParentField_Id;
		end;
	elseif (var_Method_Name = 'GetWithholdingTaxType') then
			begin
				select WithholdingTaxType_Id as item_id,
				WithholdingTaxType_Name as item_value
				from  c049_withholding_tax_type
				where Is_Deleted = 0;
			end;
    elseif (var_Method_Name = 'GetDealerBySalesGroup') then
		begin
			select Dealer_Id as item_id, Dealer_Name as item_value
			from mu08_dealer where Org_Id = var_Org_Id and Is_Active = 1 and SalesArea_Id like var_ParentField_Id
			order by Dealer_Name;
		end;    
        
        
	elseif (var_Method_Name = 'GetSalesUserbydealer') then
		begin
        
			select mu12.SalesUser_Id as item_id, mu12.SalesUser_Name as item_value
			from mu08_dealer mu08 
            inner join mu12_sales_user mu12 on mu12.Org_Id = mu08.Org_Id and mu12.SalesUser_Id = mu08.SalesUser_Id 
            where mu12.Is_Deleted = 0 and 
            mu08.Dealer_Id like var_ParentField_Id
			order by SalesUser_Name;
		end;   
        
        elseif (var_Method_Name = 'GetAllDealers') then
		begin
			select Dealer_Code as item_id, Dealer_Name as item_value
			from mu08_dealer where Org_Id = var_Org_Id and Is_Active = 1
			order by Dealer_Name;
		end;
        
           elseif (var_Method_Name = 'getDealersalesgroup') then
		begin
			select mu08.Dealer_Code as item_id, mu08.Dealer_Name as item_value
			from mu08_dealer mu08 
            inner join m013_salesarea m013 on mu08.SalesArea_Id = m013.SalesArea_Id
            where mu08.Org_Id = var_Org_Id and mu08.Is_Active = 1 and m013.SalesArea_Code = var_ParentField_Id
			order by Dealer_Name;
		end;
	elseif (var_Method_Name = 'GetFMStatus') THEN
        begin
            select 'Farmer' as item_id, 'Farmer' as item_value
            union all
            select 'MCC' as item_id, 'MCC' as item_value;
        end;

	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
