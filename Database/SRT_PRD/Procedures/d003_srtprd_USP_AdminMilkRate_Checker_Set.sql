-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkRate_Checker_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkRate_Checker_Set`(
IN `var_Method_Name` varchar(255),
IN `var_Org_Id` varchar(10),
var_User_Id varchar(20),
var_User_Name varchar(255),
var_MCC_Id varchar(255),
var_Date varchar(255)
)
BEGIN
	SET SQL_SAFE_UPDATES=0;
	if (var_Method_Name = 'Create') then
		begin
			TRUNCATE TABLE f015_milk_rate_checker;
			Insert Into f015_milk_rate_checker
			(
			Org_Id, Collection_Id, Farmer_Id, MCC_Id, MilkType_Id, Quantity_Kg, Quantity_Ltr, Fat, SNF, Old_Rate, Old_Amount,CollectionShift_Id, Created_On
			)
			select 
			t005.Org_Id,t005.FarmerCollection_Id as Collection_Id,
			t005.Farmer_Id,t005.MCC_Id,t005.MilkType_Id,
			t005.Quantity_Kg,t005.Quantity_Kg,t005.Fat,t005.SNF,
			t005.ApplicableRate as Old_Rate,t005.Amount as Old_Amount, t004.CollectionShift_Id,
			date(t005.Created_On) as Created_On
			from t005_milkcollectionfarmer t005
			Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
			and t004.MCC_Id = t005.MCC_Id
			and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
			Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id
			and m005.MCC_Id = t005.MCC_Id  
			and m005.MCCType_Id in('C014001','C014002')
			and m005.MCCWorkType_Id = 'C023002'
			where t005.Org_Id = var_Org_Id
			and t005.Is_Check = 0
			and t005.Is_InvoiceCreated = 0
			and t005.Invoice_Id is null
			and t005.MilkStatus_Id = 'C016001'

			UNION ALL
			
			select 
			f010.Org_Id,f010.Entry_Id as Collection_Id,
			f010.MCC_Id as Farmer_Id,f010.MCC_Id,f010.MilkType_Id,
			f010.Dairy_Quantity_Kg as Quantity_Kg,f010.Dairy_Quantity_Ltr as Quantity_Kg,f010.Dairy_Fat as Fat,f010.Dairy_SNF as SNF,
			f010.MilkRate as Old_Rate,f010.MilkPrice as Old_Amount, ifnull(f010.CollectionShift_Id, 'C015003')  as  CollectionShift_Id,
			date(f010.Collection_Date) as Created_On
			from f010_milkcollectionmcc_final f010
			Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id  
			and m005.MCCType_Id in('C014001','C014002')
			and m005.MCCWorkType_Id = 'C023001'
			where f010.Org_Id = var_Org_Id 
			and f010.Is_OutsideCheck = 0
			and f010.Is_OutsideInvoiceCreated = 0
			and f010.OutsideInvoice_Id is null

			UNION ALL
			
			select 
			f010.Org_Id,f010.Entry_Id as Collection_Id,
			f010.MCC_Id as Farmer_Id,f010.MCC_Id,f010.MilkType_Id,
			f010.Dairy_Quantity_Kg as Quantity_Kg,f010.Dairy_Quantity_Ltr as Quantity_Kg,f010.Dairy_Fat as Fat,f010.Dairy_SNF as SNF,
			f010.MilkRate as Old_Rate,f010.MilkPrice as Old_Amount, ifnull(f010.CollectionShift_Id, 'C015003')  as  CollectionShift_Id,
			date(f010.Collection_Date) as Created_On
			from f010_milkcollectionmcc_final f010
			Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id  
			and m005.MCCType_Id in('C014003')
			where f010.Org_Id = var_Org_Id
			and f010.Is_OutsideCheck = 0
			and f010.Is_OutsideInvoiceCreated = 0
			and f010.OutsideInvoice_Id is null;
            
            DROP TEMPORARY TABLE IF EXISTS temp_Report;
            CREATE TEMPORARY TABLE temp_Report ( 
            Org_Id varchar(20),MCC_Id varchar(20),MilkType_Id varchar(20),
            Fat decimal(8,3),SNF decimal(8,3),Created_On datetime,CollectionShift_Id varchar(20),
            New_Rate decimal(8,2),New_Amount decimal(30,2)
            );
            
            insert into temp_Report(
			Org_Id ,MCC_Id ,MilkType_Id ,
            Fat ,SNF ,Created_On ,CollectionShift_Id 
            )
            
            select 
			t005.Org_Id,t005.MCC_Id,t005.MilkType_Id,t005.Fat,t005.SNF,
			date(t005.Created_On) as Created_On, t004.CollectionShift_Id
			from t005_milkcollectionfarmer t005
			Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id 
			and t004.MCC_Id = t005.MCC_Id
			and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
			Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id
			and m005.MCC_Id = t005.MCC_Id  
			and m005.MCCType_Id in('C014001','C014002')
			and m005.MCCWorkType_Id = 'C023002'
			where t005.Org_Id = var_Org_Id
			and t005.Is_Check = 0
			and t005.Is_InvoiceCreated = 0
			and t005.Invoice_Id is null
			and t005.MilkStatus_Id = 'C016001'
			group by t005.MCC_Id,t005.Fat,t005.SNF,
			date(t005.Created_On),t005.Org_Id,t005.MilkType_Id,t004.CollectionShift_Id
			
			UNION ALL
		
			select 
			f010.Org_Id,f010.MCC_Id,f010.MilkType_Id,f010.Dairy_Fat as Fat,f010.Dairy_SNF as SNF,
			date(f010.Collection_Date) as Created_On, ifnull(f010.CollectionShift_Id, 'C015003')  as  CollectionShift_Id
			from f010_milkcollectionmcc_final f010
			Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id  
			and m005.MCCType_Id in('C014001','C014002')
			and m005.MCCWorkType_Id = 'C023001'
			where f010.Org_Id = var_Org_Id
			and f010.Is_OutsideCheck = 0
			and f010.Is_OutsideInvoiceCreated = 0
			and f010.OutsideInvoice_Id is null
			group by f010.Org_Id,f010.MCC_Id,f010.MilkType_Id,f010.Dairy_Fat,f010.Dairy_SNF,
			date(f010.Collection_Date), f010.CollectionShift_Id 

			UNION ALL
			
			select 
			f010.Org_Id,f010.MCC_Id,f010.MilkType_Id,f010.Dairy_Fat as Fat,f010.Dairy_SNF as SNF,
			date(f010.Collection_Date) as Created_On, ifnull(f010.CollectionShift_Id, 'C015003')  as  CollectionShift_Id
			from f010_milkcollectionmcc_final f010
			Inner Join m005_mcc m005 on m005.Org_Id = f010.Org_Id
			and m005.MCC_Id = f010.MCC_Id  
			and m005.MCCType_Id in('C014003')
			where f010.Org_Id = var_Org_Id
			and f010.Is_OutsideCheck = 0
			and f010.Is_OutsideInvoiceCreated = 0
			and f010.OutsideInvoice_Id is null
			group by f010.Org_Id,f010.MCC_Id,f010.MilkType_Id,f010.Dairy_Fat,f010.Dairy_SNF,
			date(f010.Collection_Date), f010.CollectionShift_Id;
            
            
            update temp_Report tmp
            set tmp.New_Rate = GetMilkRateBackDate(tmp.Org_Id, tmp.MCC_Id,tmp.CollectionShift_Id, tmp.Fat, tmp.SNF, tmp.MilkType_Id,tmp.Created_On);
            
           update f015_milk_rate_checker f015 
           inner join temp_Report tmp on
           tmp.Org_Id = f015.Org_Id
           and tmp.MCC_Id = f015.MCC_Id
           and date(tmp.Created_On) = date(f015.Created_On)
           and ifnull(tmp.CollectionShift_Id, 'C015003') = ifnull(f015.CollectionShift_Id, 'C015003')
           and tmp.MilkType_Id = f015.MilkType_Id
           and tmp.Fat = f015.Fat
           and tmp.SNF = f015.SNF
           set f015.New_Rate = tmp.New_Rate;
           
           
           update f015_milk_rate_checker f015 
           set f015.New_Amount = f015.New_Rate * f015.Quantity_Ltr;
           
           update f015_milk_rate_checker f015 
           set f015.Diff_Amount = f015.New_Amount - f015.Old_Amount;
           
			delete from f015_milk_rate_checker where Org_Id = var_Org_Id and Diff_Amount = 0;
            
            delete from f015_milk_rate_checker where Org_Id = var_Org_Id and Old_Rate = New_Rate;
           
			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
		end;
	elseif (var_Method_Name = 'Update') then
		begin
			
			update t005_milkcollectionfarmer t005
			inner join f015_milk_rate_checker f015 on
			f015.Org_Id = t005.Org_Id
			and f015.Collection_Id = t005.FarmerCollection_Id
			and f015.Farmer_Id = t005.Farmer_Id
			and f015.MCC_Id = t005.MCC_Id
			set t005.ApplicableRate = f015.New_Rate
			where f015.Org_Id = var_Org_Id
            and date(f015.Created_On) = date(var_Date)
            and f015.MCC_Id = var_MCC_Id
            and f015.MCC_Id in (
            select MCC_Id from m005_mcc 
			where MCCType_Id <> 'C014003' 
			and MCCWorkType_Id ='C023002'
			and MCC_Id = var_MCC_Id
			and Org_Id = var_Org_Id
            );

			update t005_milkcollectionfarmer t005
			inner join f015_milk_rate_checker f015 on
			f015.Org_Id = t005.Org_Id
			and f015.Collection_Id = t005.FarmerCollection_Id
			and f015.Farmer_Id = t005.Farmer_Id
			and f015.MCC_Id = t005.MCC_Id
			set t005.Amount = t005.ApplicableRate * t005.Quantity_Ltr
			where f015.Org_Id = var_Org_Id
            and date(f015.Created_On) = date(var_Date)
            and f015.MCC_Id = var_MCC_Id
            and f015.MCC_Id in (
            select MCC_Id from m005_mcc 
			where MCCType_Id <> 'C014003' 
			and MCCWorkType_Id ='C023002'
			and MCC_Id = var_MCC_Id
			and Org_Id = var_Org_Id
            );

			update f010_milkcollectionmcc_final f010
			inner join f015_milk_rate_checker f015 on
			f015.Org_Id = f010.Org_Id
			and f015.Collection_Id = f010.Entry_Id
			and f015.Farmer_Id = f010.MCC_Id
			and f015.MCC_Id = f010.MCC_Id
			set f010.MilkRate = f015.New_Rate
			where f015.Org_Id = var_Org_Id
            and date(f015.Created_On) = date(var_Date)
            and f015.MCC_Id = var_MCC_Id
            and f015.MCC_Id in (
            select MCC_Id from m005_mcc 
			where MCCType_Id <> 'C014003' 
			and MCCWorkType_Id ='C023001'
			and MCC_Id = var_MCC_Id
			and Org_Id = var_Org_Id
            );

			update f010_milkcollectionmcc_final f010
			inner join f015_milk_rate_checker f015 on
			f015.Org_Id = f010.Org_Id
			and f015.Collection_Id = f010.Entry_Id
			and f015.Farmer_Id = f010.MCC_Id
			and f015.MCC_Id = f010.MCC_Id
			set f010.MilkPrice = f010.Dairy_Quantity_Ltr * f010.MilkRate
			where f015.Org_Id = var_Org_Id
            and date(f015.Created_On) = date(var_Date)
            and f015.MCC_Id = var_MCC_Id
            and f015.MCC_Id in (
            select MCC_Id from m005_mcc 
			where MCCType_Id <> 'C014003' 
			and MCCWorkType_Id ='C023001'
			and MCC_Id = var_MCC_Id
			and Org_Id = var_Org_Id
            );
            
            
            update f010_milkcollectionmcc_final f010
			inner join f015_milk_rate_checker f015 on
			f015.Org_Id = f010.Org_Id
			and f015.Collection_Id = f010.Entry_Id
			and f015.Farmer_Id = f010.MCC_Id
			and f015.MCC_Id = f010.MCC_Id
			set f010.MilkRate = f015.New_Rate
			where f015.Org_Id = var_Org_Id
            and date(f015.Created_On) = date(var_Date)
            and f015.MCC_Id = var_MCC_Id
            and f015.MCC_Id in (
            select MCC_Id from m005_mcc 
			where MCCType_Id = 'C014003' 
			and MCC_Id = var_MCC_Id
			and Org_Id = var_Org_Id
            );

			update f010_milkcollectionmcc_final f010
			inner join f015_milk_rate_checker f015 on
			f015.Org_Id = f010.Org_Id
			and f015.Collection_Id = f010.Entry_Id
			and f015.Farmer_Id = f010.MCC_Id
			and f015.MCC_Id = f010.MCC_Id
			set f010.MilkPrice = f010.Dairy_Quantity_Ltr * f010.MilkRate
			where f015.Org_Id = var_Org_Id
            and date(f015.Created_On) = date(var_Date)
            and f015.MCC_Id = var_MCC_Id
            and f015.MCC_Id in (
            select MCC_Id from m005_mcc 
			where MCCType_Id = 'C014003' 
			and MCC_Id = var_MCC_Id
			and Org_Id = var_Org_Id
            );
            
            delete from f015_milk_rate_checker f015 
			where f015.Org_Id = var_Org_Id
			and date(f015.Created_On) = date(var_Date)
			and f015.MCC_Id = var_MCC_Id;
            
            call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				'f015_milk_rate_checker', var_MCC_Id, var_Date,'', 
				var_User_Id, var_User_Name);
                
            
            SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
            
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
