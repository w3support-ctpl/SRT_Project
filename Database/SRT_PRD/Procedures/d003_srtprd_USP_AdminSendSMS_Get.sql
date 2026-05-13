-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSendSMS_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSendSMS_Get`(
	IN `var_Method_Name` varchar(255),
	IN `var_Org_Id` varchar(10),
	IN `var_MilkCollectionDairy_Id` longtext
)
BEGIN
	SET SQL_SAFE_UPDATES=0;
	if (var_Method_Name = 'Send_SMS') then
		begin
			
            /*
			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRate(f10.Org_Id, f10.MCC_Id,'C015003', f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id)
			where  m5.MCCType_Id = 'C014003' and date(collection_date ) = date(now()); 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where  m5.MCCType_Id = 'C014003' and date(collection_date) = date(now()); 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id)
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' and date(collection_date) = date(now()); 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' and date(collection_date) = date(now()); 

			-- MilkPrice is null then
			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id,'C015003', f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where  m5.MCCType_Id = 'C014003' -- and date(collection_date ) = date(now())
            and MilkPrice is null; 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where  m5.MCCType_Id = 'C014003' -- and date(collection_date) = date(now())
            and MilkPrice is null; 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' -- and date(collection_date) = date(now())
            and MilkPrice is null; 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' -- and date(collection_date) = date(now())
            and MilkPrice is null;
            
            
            -- MilkPrice is Yesterday Update
            
			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id,'C015003', f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where  m5.MCCType_Id = 'C014003' 
            and date(collection_date ) = date(DATE_SUB(NOW(), INTERVAL 1 DAY)); 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where  m5.MCCType_Id = 'C014003' 
            and date(collection_date ) = date(DATE_SUB(NOW(), INTERVAL 1 DAY)); 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkRate = GetMilkRateBackDate(f10.Org_Id, f10.MCC_Id, ifnull(f10.CollectionShift_Id,'C015003'), f10.Dairy_Fat, f10.Dairy_SNF, f10.MilkType_Id,f10.collection_date)
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and date(collection_date ) = date(DATE_SUB(NOW(), INTERVAL 1 DAY)); 

			update f010_milkcollectionmcc_final f10 
			inner join m005_mcc m5 on f10.Org_Id = m5.Org_Id and f10.MCC_Id = m5.MCC_Id 
			set MilkPrice = MilkRate * Dairy_Quantity_Ltr
			where m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003' 
            and date(collection_date ) = date(DATE_SUB(NOW(), INTERVAL 1 DAY)); 
            */
            
            
            /*
            
			select 
			concat('S.R.Thorat:Soc CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: ',c015.CollectionShift_Name,' CM Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: ',ifnull(f010.Dairy_Sour_Ltr,0)) as Message,
			m005.Mobile_No as MobileNo,
			'C020001' as VehicleType_Id
			from f010_milkcollectionmcc_final  f010
			inner join c015_collectionshift c015 on c015.CollectionShift_Id = f010.CollectionShift_Id
			inner join m005_mcc m005 on m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id
			where f010.Org_Id = var_Org_Id
			and f010.CollectionShift_Id is not null
			and FIND_IN_SET(f010.MilkCollectionPosting_Id, var_MilkCollectionDairy_Id) > 0

			UNION ALL

			select 
			concat('S.R.Thorat:Third party CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: All Day Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: 0 ') as Message,
			m005.Mobile_No as MobileNo,
			'C020002' as VehicleType_Id
			from f010_milkcollectionmcc_final  f010
			inner join m005_mcc m005 on m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id
			where f010.Org_Id = var_Org_Id
			and (f010.CollectionShift_Id is null or f010.CollectionShift_Id  ='')
			and FIND_IN_SET(f010.MilkCollectionPosting_Id, var_MilkCollectionDairy_Id) > 0;
			*/
            
            select 
			concat('S.R.Thorat:Soc CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: ',c015.CollectionShift_Name,' CM Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: ',ifnull(f010.Dairy_Sour_Ltr,0)) as Message,
			m005.Mobile_No as MobileNo,
			'C020001' as VehicleType_Id
			from f010_milkcollectionmcc_final  f010
			inner join c015_collectionshift c015 on c015.CollectionShift_Id = f010.CollectionShift_Id
			inner join m005_mcc m005 on m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id
            inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id
			and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
            and t009.Is_OutsideVehicle = 0
            inner join t021_tripdocument_header t021 on t009.Org_Id = t021.Org_Id
			and t009.TripDocument_Id = t021.TripDocument_Id
            inner join t022_tripdocument_item t022 on t022.Org_Id = t021.Org_Id
			and t022.TripDocument_Id = t021.TripDocument_Id
            and t022.MCC_Id = f010.MCC_Id
            inner join t005_milkcollectionfarmer t005 on t022.Org_Id = t005.Org_Id
			and t022.MCC_CollectionShift_Id = t005.MCCCollectionShift_Id
            and t022.MCC_Id = t005.MCC_Id
			where f010.Org_Id = var_Org_Id
			and f010.CollectionShift_Id is not null
			and FIND_IN_SET(f010.MilkCollectionPosting_Id, var_MilkCollectionDairy_Id) > 0
            group by
            concat('S.R.Thorat:Soc CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: ',c015.CollectionShift_Name,' CM Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: ',ifnull(f010.Dairy_Sour_Ltr,0)),
			m005.Mobile_No

			UNION ALL

			select 
			concat('S.R.Thorat:Third party CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: All Day Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: 0 ') as Message,
			m005.Mobile_No as MobileNo,
			'C020002' as VehicleType_Id
			from f010_milkcollectionmcc_final  f010
			inner join m005_mcc m005 on m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id
            inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id
			and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
            and t009.Is_OutsideVehicle = 0
            inner join t021_tripdocument_header t021 on t009.Org_Id = t021.Org_Id
			and t009.TripDocument_Id = t021.TripDocument_Id
            inner join t022_tripdocument_item t022 on t022.Org_Id = t021.Org_Id
			and t022.TripDocument_Id = t021.TripDocument_Id
            and t022.MCC_Id = f010.MCC_Id
            inner join t005_milkcollectionfarmer t005 on t022.Org_Id = t005.Org_Id
			and t022.MCC_CollectionShift_Id = t005.MCCCollectionShift_Id
            and t022.MCC_Id = t005.MCC_Id
			where f010.Org_Id = var_Org_Id
			and (f010.CollectionShift_Id is null or f010.CollectionShift_Id  ='')
			and FIND_IN_SET(f010.MilkCollectionPosting_Id, var_MilkCollectionDairy_Id) > 0
            group by 
            concat('S.R.Thorat:Third party CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: All Day Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: 0 '),
			m005.Mobile_No
            
            UNION ALL
            
            select 
			concat('S.R.Thorat:Soc CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: ',c015.CollectionShift_Name,' CM Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: ',ifnull(f010.Dairy_Sour_Ltr,0)) as Message,
			m005.Mobile_No as MobileNo,
			'C020001' as VehicleType_Id
			from f010_milkcollectionmcc_final  f010
			inner join c015_collectionshift c015 on c015.CollectionShift_Id = f010.CollectionShift_Id
			inner join m005_mcc m005 on m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id
            inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id
			and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
            and t009.Is_OutsideVehicle = 1
			where f010.Org_Id = var_Org_Id
			and f010.CollectionShift_Id is not null
			and FIND_IN_SET(f010.MilkCollectionPosting_Id, var_MilkCollectionDairy_Id) > 0
            group by
            concat('S.R.Thorat:Soc CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: ',c015.CollectionShift_Name,' CM Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: ',ifnull(f010.Dairy_Sour_Ltr,0)),
			m005.Mobile_No

			UNION ALL

			select 
			concat('S.R.Thorat:Third party CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: All Day Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: 0 ') as Message,
			m005.Mobile_No as MobileNo,
			'C020002' as VehicleType_Id
			from f010_milkcollectionmcc_final  f010
			inner join m005_mcc m005 on m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id
            inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id
			and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
            and t009.Is_OutsideVehicle = 1
			where f010.Org_Id = var_Org_Id
			and (f010.CollectionShift_Id is null or f010.CollectionShift_Id  ='')
			and FIND_IN_SET(f010.MilkCollectionPosting_Id, var_MilkCollectionDairy_Id) > 0
            group by 
            concat('S.R.Thorat:Third party CODE: ',m005.MCC_Code,' Date: ',date_format(f010.Collection_Date, '%d-%b-%Y'),' Shift: All Day Ltrs: ',f010.Dairy_Quantity_Ltr,' FAT: ',f010.Dairy_Fat,' SNF: ',f010.Dairy_SNF,' Sour Milk: 0 '),
			m005.Mobile_No;
            
		END;
	elseif (var_Method_Name = 'DataShift') then
		begin
        
			Insert Into f010_milkcollectionmcc_final
			( Org_Id, Entry_Id, MilkCollectionDairy_Id, MCC_Id, CollectionShift_Id, MilkType_Id, Collection_Date, Agent_Quantity_Kg, Agent_Quantity_Ltr, Agent_Fat, Agent_SNF, Agent_Fat_Kg, Agent_SNF_Kg, Dairy_Quantity_Kg, Dairy_Quantity_Ltr, Dairy_Fat, Dairy_SNF, Dairy_Protein, Dairy_Ash, Dairy_Sodium, Dairy_Fat_Kg, Dairy_SNF_Kg, FatKG_GainLoss, SNFKG_GainLoss, FatKG_Rate, SNFKG_Rate, Total_GainLoss, MilkPrice, MilkRate, Plant_Code, Is_VoucherLocked, Dairy_Sour_Ltr, OutsideInvoice_Id, Is_OutsideCheck, Is_OutsideInvoiceCreated
			)
			select f010.Org_Id, f010.Entry_Id, f010.MilkCollectionDairy_Id, f010.MCC_Id, 
			f010.CollectionShift_Id, f010.MilkType_Id, f010.Collection_Date, f010.Agent_Quantity_Kg, 
			f010.Agent_Quantity_Ltr, f010.Agent_Fat, f010.Agent_SNF, 
			f010.Agent_Fat_Kg, f010.Agent_SNF_Kg, f010.Dairy_Quantity_Kg, f010.Dairy_Quantity_Ltr, 
			f010.Dairy_Fat, f010.Dairy_SNF, f010.Dairy_Protein, f010.Dairy_Ash, f010.Dairy_Sodium, 
			f010.Dairy_Fat_Kg, f010.Dairy_SNF_Kg, f010.FatKG_GainLoss, 
			f010.SNFKG_GainLoss, f010.FatKG_Rate, f010.SNFKG_Rate, 
			f010.Total_GainLoss, f010.MilkPrice, f010.MilkRate, 
			f010.Plant_Code, f010.Is_VoucherLocked, f010.Dairy_Sour_Ltr, f010.OutsideInvoice_Id, 
			f010.Is_OutsideCheck, f010.Is_OutsideInvoiceCreated
			from f010_milkcollectionmcc_final_sour f010 
			inner join m005_mcc m5 on f010.Org_Id = m5.Org_Id and f010.MCC_Id = m5.MCC_Id 
			and m5.MCCType_Id = 'C014003'
			where f010.Org_Id = var_Org_Id
			and f010.MilkCollectionDairy_Id in (
												select f010.MilkCollectionDairy_Id from f010_milkcollectionmcc_final f010
												where f010.Org_Id = var_Org_Id
												and FIND_IN_SET(f010.MilkCollectionPosting_Id, var_MilkCollectionDairy_Id) > 0
												group by f010.MilkCollectionDairy_Id
												)
												
			union all

			select f010.Org_Id, f010.Entry_Id, f010.MilkCollectionDairy_Id, f010.MCC_Id, 
			f010.CollectionShift_Id, f010.MilkType_Id, f010.Collection_Date, f010.Agent_Quantity_Kg, 
			f010.Agent_Quantity_Ltr, f010.Agent_Fat, f010.Agent_SNF, 
			f010.Agent_Fat_Kg, f010.Agent_SNF_Kg, f010.Dairy_Quantity_Kg, f010.Dairy_Quantity_Ltr, 
			f010.Dairy_Fat, f010.Dairy_SNF, f010.Dairy_Protein, f010.Dairy_Ash, f010.Dairy_Sodium, 
			f010.Dairy_Fat_Kg, f010.Dairy_SNF_Kg, f010.FatKG_GainLoss, 
			f010.SNFKG_GainLoss, f010.FatKG_Rate, f010.SNFKG_Rate, 
			f010.Total_GainLoss, f010.MilkPrice, f010.MilkRate, 
			f010.Plant_Code, f010.Is_VoucherLocked, f010.Dairy_Sour_Ltr, f010.OutsideInvoice_Id, 
			f010.Is_OutsideCheck, f010.Is_OutsideInvoiceCreated
			from f010_milkcollectionmcc_final_sour f010 
			inner join m005_mcc m5 on f010.Org_Id = m5.Org_Id and f010.MCC_Id = m5.MCC_Id 
			and m5.MCCWorkType_Id = 'C023001' and m5.MCCType_Id <> 'C014003'
			where f010.Org_Id = var_Org_Id
			and f010.MilkCollectionDairy_Id in (
												select f010.MilkCollectionDairy_Id from f010_milkcollectionmcc_final f010
												where f010.Org_Id = var_Org_Id
												and FIND_IN_SET(f010.MilkCollectionPosting_Id, var_MilkCollectionDairy_Id) > 0
												group by f010.MilkCollectionDairy_Id
												);
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
