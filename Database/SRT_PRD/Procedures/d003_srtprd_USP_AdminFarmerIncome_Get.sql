-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFarmerIncome_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFarmerIncome_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(45),
    var_MCCType_Id varchar(20),
    var_Date varchar(45),
    var_MCC_Id varchar(20),
    var_TripDocument_Id varchar(20),
    var_MilkCollectionDairy_Id varchar(20),
	var_Entry_Id varchar(20),
    var_MCCCollectionShift_Id varchar(20)
    )
BEGIN
	if (var_Method_Name = 'Get') then
		begin
            DROP TEMPORARY TABLE IF EXISTS temp_Collection;
			CREATE TEMPORARY TABLE temp_Collection (Org_Id varchar(20), Entry_Id varchar(20),  MilkCollectionDairy_Id varchar(20),
            TripDocument_Id varchar(20), MCCCollectionShift_Id varchar(20), MCC_Id varchar(20), MCC_Name varchar(255),
            CollectionShift_Id varchar(20), CollectionShift_Name varchar(50), Agent_Ltr decimal(8,2), Agent_Fat decimal(8,2), Agent_SNF decimal(8,2),
            Dairy_Ltr decimal(8,2), Dairy_Fat decimal(8,2), Dairy_SNF decimal(8,2), Is_Locked int, MCCType_Id varchar(20), MCCWorkType_Id varchar(20));
            
            insert into temp_Collection (Org_Id, Entry_Id, MilkCollectionDairy_Id, Agent_Ltr, Agent_Fat, Agent_SNF,
            Dairy_Ltr, Dairy_Fat, Dairy_SNF, Is_Locked, MCC_Id, CollectionShift_Id)
            select Org_Id, Entry_Id, MilkCollectionDairy_Id, Agent_Quantity_Ltr, Agent_Fat, Agent_SNF,
            Dairy_Quantity_Ltr, Dairy_Fat, Dairy_SNF, Is_VoucherLocked, MCC_Id, CollectionShift_Id
            from f010_milkcollectionmcc_final f010
			where f010.Org_Id = var_Org_Id
			and date(f010.Collection_Date) = date(var_Date) ;
			
            update temp_Collection tmp
            inner join m005_mcc m005 on m005.Org_Id =  tmp.Org_Id 
			and m005.MCC_Id =  tmp.MCC_Id
            set tmp.MCC_Name = m005.MCC_Name,
            tmp.MCCType_Id = m005.MCCType_Id,
            tmp.MCCWorkType_Id = m005.MCCWorkType_Id;
            
            update temp_Collection tmp
            inner join t009_milkcollectiondairy_header t009 on t009.Org_Id =  tmp.Org_Id
			and t009.MilkCollectionDairy_Id =  tmp.MilkCollectionDairy_Id
            and t009.Is_OutsideVehicle =  0
            inner join t022_tripdocument_item t022 on t009.Org_Id =  t022.Org_Id
			and t009.TripDocument_Id =  t022.TripDocument_Id
            and t022.MCC_Id =  tmp.MCC_Id
            set tmp.TripDocument_Id = t022.TripDocument_Id,
            tmp.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id;
            
            update temp_Collection tmp
            left join c015_collectionshift c015 on c015.CollectionShift_Id =  tmp.CollectionShift_Id
            set tmp.CollectionShift_Id = ifnull(c015.CollectionShift_Id,'C015003') ,
            tmp.CollectionShift_Name = ifnull(c015.CollectionShift_Name,'All Day') ;
            
			select 
            Entry_Id as SetEntry_Id,
			MilkCollectionDairy_Id,
			ifnull(TripDocument_Id,'') TripDocument_Id,
            ifnull(MCCCollectionShift_Id,'') MCCCollectionShift_Id,
			MCC_Id,
			MCC_Name,
			ifnull(CollectionShift_Id,'C015003') CollectionShift_Id,
			ifnull(CollectionShift_Name,'All Day') CollectionShift_Name,
			ifnull(Agent_Ltr,'') as Agent_Ltr,
			ifnull(Agent_Fat,'') as Agent_Fat,
			ifnull(Agent_SNF,'') as Agent_SNF,
			ifnull(Dairy_Ltr,'') as Dairy_Ltr,
			ifnull(Dairy_Fat,'') as Dairy_Fat,
			ifnull(Dairy_SNF,'') as Dairy_SNF,
			Is_Locked as Is_Locked
			from temp_Collection 
            where MCCType_Id = var_MCCType_Id
            and  MCCType_Id  in ('C014001','C014002')
			and MCCWorkType_Id in ('C023002')
			order by MCC_Name;
            
		end;
	elseif (var_Method_Name = 'Get_OriginalFarmer') then
		begin
			select
			t005.Quantity_Ltr as Liters,
			t005.Quantity_Kg as Weight,
			t005.FAT,t005.SNF,
			c011.MilkType_Id,c011.MilkType_Name,
			c016.MilkStatus_Id,c016.MilkStatus_Name,
			mu04.Farmer_Id,mu04.Farmer_Name,
			ifnull(mu04.Farmer_Code,'') as Farmer_Code,
			ifnull(mu04.MCC_Farmer_Code,'') as MCC_Farmer_Code
			from t022_tripdocument_item t022
			inner join t005_milkcollectionfarmer t005 on
			t022.Org_Id = t005.Org_Id
			and t022.MCC_Id = t005.MCC_Id
			and t022.MCC_CollectionShift_Id = t005.MCCCollectionShift_Id
			inner join c011_milktype c011 on t005.Milktype_Id = c011.Milktype_Id
			inner join c016_milkstatus c016 on t005.MilkStatus_Id = c016.MilkStatus_Id
			inner join mu04_farmer mu04 on t005.Org_Id = mu04.Org_Id and t005.Farmer_Id = mu04.Farmer_Id
			where t022.Org_Id = var_Org_Id
			and t022.TripDocument_Id = var_TripDocument_Id
			and t022.MCC_Id = var_MCC_Id
            order by mu04.Farmer_Name;
        end;
	elseif (var_Method_Name = 'Get_MCC') then
		begin
			select
			t0061.Quantity_Ltr as Liters,t0061.FAT,t0061.SNF,
			c011.MilkType_Id,c011.MilkType_Name,
			c016.MilkStatus_Id,c016.MilkStatus_Name
			from t022_tripdocument_item t022
			inner join t006_milkcollectionagent t006 on
			t022.Org_Id = t006.Org_Id
			and t022.MCC_Id = t006.MCC_Id
			and t022.MCC_CollectionShift_Id = t006.MCCCollectionShift_Id
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join c011_milktype c011 on t0061.Milktype_Id = c011.Milktype_Id
			inner join c016_milkstatus c016 on t0061.MilkStatus_Id = c016.MilkStatus_Id
			where t022.Org_Id = var_Org_Id
			and t022.TripDocument_Id = var_TripDocument_Id
			and t022.MCC_Id = var_MCC_Id;
        end;
	elseif (var_Method_Name = 'Get_UpdatedFarmer') then
		begin
			select
            tm01.Quantity_Ltr as Liters,
			tm01.Entry_Id as Entry_Id,
			tm01.Quantity_Kg as Weight,
			tm01.FAT,tm01.SNF,
			c011.MilkType_Id,c011.MilkType_Name,
			c016.MilkStatus_Id,c016.MilkStatus_Name,
			mu04.Farmer_Id,mu04.Farmer_Name,
			 ifnull(mu04.Farmer_Code,'') as Farmer_Code
			from tm01_milkcollectionfarmer tm01
			inner join c011_milktype c011 on tm01.Milktype_Id = c011.Milktype_Id
			inner join c016_milkstatus c016 on tm01.MilkStatus_Id = c016.MilkStatus_Id
			inner join mu04_farmer mu04 on tm01.Org_Id = mu04.Org_Id and tm01.Farmer_Id = mu04.Farmer_Id
			where tm01.Org_Id = var_Org_Id
			and tm01.MCCCollectionShift_Id = var_MCCCollectionShift_Id
			and tm01.MCC_Id = var_MCC_Id
            order by mu04.Farmer_Name;
        end;
	elseif (var_Method_Name = 'Get_One') then
		begin
        select
			tm01.Entry_Id,
			tm01.Farmer_Id,
            tm01.MilkType_Id,
            tm01.MilkStatus_Id,
            tm01.Quantity_Ltr  as Liters,
			tm01.Quantity_Kg  as Weight,
            tm01.Fat,
            tm01.SNF
			from tm01_milkcollectionfarmer tm01
			where tm01.Org_Id = var_Org_Id
			and tm01.MCCCollectionShift_Id = var_MCCCollectionShift_Id
			and tm01.MCC_Id = var_MCC_Id
            and tm01.Entry_Id = var_Entry_Id;
        end;
	elseif (var_Method_Name = 'Get_Approval') then
		begin
			select 
			'Dairy' as Location,
			Roundoff('QuantityForDairy', (ifnull(f010.Dairy_Quantity_Ltr,0))) as Liters,
			Roundoff('Quantity',(ifnull(f010.Dairy_Quantity_Kg,0))) as Weight,
			Roundoff('Quality',(ifnull(f010.Dairy_Fat,0))) as FAT,
			Roundoff('Quality', (ifnull(f010.Dairy_SNF,0))) as SNF,
			Roundoff('Quantity',(ifnull(f010.Dairy_Fat_Kg,0))) as FatKG,
			Roundoff('Quantity',(ifnull(f010.Dairy_SNF_Kg,0))) as SNFKG
			from f010_milkcollectionmcc_final f010
			where f010.Org_Id = var_Org_Id
            and f010.MCC_Id = var_MCC_Id
			and f010.Entry_Id = var_MilkCollectionDairy_Id
            
			union all
			SELECT 
				'MCC - Updated' AS Location,
				Roundoff('QuantityForDairy', (IFNULL(SUM(tm01.Quantity_Ltr), 0))) AS Liters,
				Roundoff('Quantity',(IFNULL(SUM(tm01.Quantity_Kg), 0))) AS Weight,
				Roundoff('Quality',(IFNULL((SUM(tm01.Quantity_Ltr * tm01.Fat)) / SUM(tm01.Quantity_Ltr), 0))) AS FAT,
				Roundoff('Quality',(IFNULL((SUM(tm01.Quantity_Ltr * tm01.SNF)) / SUM(tm01.Quantity_Ltr), 0))) AS SNF,
				Roundoff('Quantity',(IFNULL(((SUM(tm01.Quantity_Ltr * tm01.Fat)) / SUM(tm01.Quantity_Ltr) * SUM(tm01.Quantity_Kg)) / 100, 0))) AS FatKG,
				Roundoff('Quantity',(IFNULL(((SUM(tm01.Quantity_Ltr * tm01.SNF)) / SUM(tm01.Quantity_Ltr) * SUM(tm01.Quantity_Kg)) / 100, 0))) AS SNFKG
			FROM 
				tm01_milkcollectionfarmer tm01
			WHERE 
				tm01.Org_Id = var_Org_Id
				AND tm01.MCC_Id = var_MCC_Id
				AND tm01.MCCCollectionShift_Id = var_MCCCollectionShift_Id;

        end;
	elseif (var_Method_Name = 'Get_ReverseIncome') then
		begin
			declare Is_Locked varchar(255);
            
			select 
			CASE 
				WHEN t005.Is_InvoiceCreated IS NULL OR t005.Is_InvoiceCreated = '' OR t005.Is_InvoiceCreated = 0  THEN 0
				ELSE 1
			END into Is_Locked  
			from t005_milkcollectionfarmer  t005
			WHERE 
				t005.Org_Id = var_Org_Id
				AND t005.MCC_Id = var_MCC_Id
				AND t005.MCCCollectionShift_Id = var_MCCCollectionShift_Id
			order by Is_InvoiceCreated asc limit 1;
            
            if(Is_Locked is null or Is_Locked = '') then
				set Is_Locked = 0;
            end if;
            
            select Is_Locked;
            
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
