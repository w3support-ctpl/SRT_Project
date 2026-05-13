-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRateChange_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRateChange_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
	var_Date varchar(60),
    var_MCC_Id varchar(20),
    var_MCCType_Id varchar(20),
    var_Chart_Id varchar(20),
    var_Invoice_Id varchar(20)
)
BEGIN
	if(var_Method_Name = 'Get') then 
		begin
            set @Old_Rate = (select 
								m0013.Amount
								from m001_milkrate_mcc_header m0011 
								inner join m001_milkrate_mcc_item m0012 on
								m0012.Org_Id = m0011.Org_Id 
								and m0012.Chart_Id = m0011.Chart_Id 
								and m0012.Version_No = m0011.Version_No 
								and m0012.MCC_Id = var_MCC_Id
								inner join m001_milkrate_item m0013 on
								m0013.Org_Id = m0011.Org_Id 
								and m0013.Chart_Id = m0011.Chart_Id 
								and m0013.MilkRateEntryType_Id = 'C012001'
								where date(m0011.Applicable_Date) <= date(var_Date)
								and m0011.Org_Id = var_Org_Id
								order by 
								m0011.Applicable_Date desc,
								m0013.Applicable_Date desc
								limit 1);
                                
			SELECT * FROM (
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                round(@Old_Rate,2) as Old_Rate,
				Round(sum(t005.Amount),2)  as Old_Amount,
                '' as New_Rate,
                '' as New_Amount
				from t027_invoice_farmer t027
                inner join t005_milkcollectionfarmer t005 on
                t027.Org_Id = t005.Org_Id 
                and t027.MCC_Id = t005.MCC_Id
                and t027.Voucher_Id = t005.Invoice_Id
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
                and m005.MCC_Id = t005.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
                and m005.MCCWorkType_Id = 'C023002'
                and m005.MCC_Id = var_MCC_Id
				where t027.Org_Id = var_Org_Id
                and date(t027.Invoice_Date) = date(var_Date)
                group by
                t027.Voucher_Id,
                t027.Invoice_No,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code
				
				union all
				
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                round(@Old_Rate,2) as Old_Rate,
				Round(sum(f010.MilkPrice),2)  as Old_Amount,
                '' as New_Rate,
                '' as New_Amount
				from t027_invoice_farmer t027
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = t027.Org_Id 
                and f010.MCC_Id = t027.MCC_Id
                and f010.OutsideInvoice_Id = t027.Voucher_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id and mu04.Farmer_Id = t027.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t027.Org_Id 
                and m005.MCC_Id = t027.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
                and m005.MCC_Id = var_MCC_Id
				where t027.Org_Id = var_Org_Id
                and date(t027.Invoice_Date) = date(var_Date)
                group by
                t027.Voucher_Id,
                t027.Invoice_No,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code
				
				union all
                
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                round(@Old_Rate,2) as Old_Rate,
				Round(sum(f010.MilkPrice),2)  as Old_Amount,
                '' as New_Rate,
                '' as New_Amount
				from t027_invoice_farmer t027
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = t027.Org_Id 
                and f010.MCC_Id = t027.MCC_Id
                and f010.OutsideInvoice_Id = t027.Voucher_Id
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id and mu04.Farmer_Id = t027.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t027.Org_Id 
                and m005.MCC_Id = t027.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014003')
                and m005.MCC_Id = var_MCC_Id
				where t027.Org_Id = var_Org_Id
                and date(t027.Invoice_Date) = date(var_Date)
                group by
                t027.Voucher_Id,
                t027.Invoice_No,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code
			) AS subquery
			ORDER BY subquery.Farmer_Name asc;
        end;
	elseif(var_Method_Name = 'Get_NewRate') then 
		begin
			/*
            DROP TEMPORARY TABLE IF EXISTS temp_Check_Data_1;
				CREATE TEMPORARY TABLE temp_Check_Data_1 ( 
				Org_Id varchar(20), Check_Data longtext);
				
				Insert into temp_Check_Data_1 (
				Org_Id,Check_Data
				)
				select Org_Id, concat(
				Farmer_Id,MCC_Id
				) as Check_Data from t027_invoice_farmer where Is_RateChange =1 
                and MCC_Id = var_MCC_Id
                and Org_Id = var_Org_Id
                and date(Invoice_Date) = date(var_Date)
				group by Org_Id, Farmer_Id,MCC_Id,Invoice_Date,MusterCycle_StartDate,MusterCycle_EndDate;
                
                
				DROP TEMPORARY TABLE IF EXISTS temp_Check_Data_2;
				CREATE TEMPORARY TABLE temp_Check_Data_2 ( 
				Org_Id varchar(20), Check_Data longtext);
				
				Insert into temp_Check_Data_2 (
				Org_Id,Check_Data
				)
				select Org_Id, concat(
				Farmer_Id,MCC_Id
				) as Check_Data from t027_invoice_farmer where Is_RateChange =1 
                and MCC_Id = var_MCC_Id
                and Org_Id = var_Org_Id
                and date(Invoice_Date) = date(var_Date)
				group by Org_Id, Farmer_Id,MCC_Id,Invoice_Date,MusterCycle_StartDate,MusterCycle_EndDate;
                
                
                
                DROP TEMPORARY TABLE IF EXISTS temp_Check_Data_3;
				CREATE TEMPORARY TABLE temp_Check_Data_3 ( 
				Org_Id varchar(20), Check_Data longtext);
				
				Insert into temp_Check_Data_3 (
				Org_Id,Check_Data
				)
				select Org_Id, concat(
				Farmer_Id,MCC_Id
				) as Check_Data from t027_invoice_farmer where Is_RateChange =1 
                and MCC_Id = var_MCC_Id
                and Org_Id = var_Org_Id
                and date(Invoice_Date) = date(var_Date)
				group by Org_Id, Farmer_Id,MCC_Id,Invoice_Date,MusterCycle_StartDate,MusterCycle_EndDate;
            
			set @Old_Rate = (select 
								m0013.Amount
								from m001_milkrate_mcc_header m0011 
								inner join m001_milkrate_mcc_item m0012 on
								m0012.Org_Id = m0011.Org_Id 
								and m0012.Chart_Id = m0011.Chart_Id 
								and m0012.Version_No = m0011.Version_No 
								and m0012.MCC_Id = var_MCC_Id
								inner join m001_milkrate_item m0013 on
								m0013.Org_Id = m0011.Org_Id 
								and m0013.Chart_Id = m0011.Chart_Id 
								and m0013.MilkRateEntryType_Id = 'C012001'
								where date(m0011.Applicable_Date) <= date(var_Date)
								and m0011.Org_Id = var_Org_Id
								order by 
								m0011.Applicable_Date desc,
								m0013.Applicable_Date desc
								limit 1);
			
            set @New_Rate = (select Amount from m001_milkrate_item 
								where Org_Id = var_Org_Id
								and Chart_Id  = var_Chart_Id
								and MilkRateEntryType_Id = 'C012001'
                                and date(Applicable_Date) <= date(var_Date)
								order by 
								Applicable_Date desc
								limit 1);

                                
			SELECT * FROM (
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate as startdate,
				t027.MusterCycle_EndDate as enddate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				round(@Old_Rate,2) as Old_Rate,
				Round(sum(t005.Amount),2)  as Old_Amount,
                round(@New_Rate,2) as New_Rate,
                Round(sum(GetMilkBaseChartIdRate(t005.Org_Id, t005.MCC_Id, var_Chart_Id, 
				Roundoff('Quality', ((t005.Fat))), 
				Roundoff('Quality', ((t005.SNF))), 
				t005.MilkType_Id,var_Date)  * (t005.Quantity_Ltr)),2) as New_Amount
				from t027_invoice_farmer t027
                inner join t005_milkcollectionfarmer t005 on
                t027.Org_Id = t005.Org_Id 
                and t027.MCC_Id = t005.MCC_Id
                and t027.Voucher_Id = t005.Invoice_Id
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id 
                and mu04.Farmer_Id = t005.Farmer_Id
                and (t005.Amount is not null  or t005.Amount <> '')
                and (t005.ApplicableRate is not null  or t005.ApplicableRate <> '')
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
                and m005.MCC_Id = t005.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
                and m005.MCCWorkType_Id = 'C023002'
                and m005.MCC_Id = var_MCC_Id
				where t027.Org_Id = var_Org_Id
                and date(t027.Invoice_Date) = date(var_Date)
                and concat( t027.Farmer_Id,t027.MCC_Id ) not in (select Check_Data from temp_Check_Data_1)
                group by
                t027.Voucher_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate,
				t027.MusterCycle_EndDate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                t005.Org_Id, t005.MCC_Id,
                t005.MilkType_Id
				
				union all
				
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate as startdate,
				t027.MusterCycle_EndDate as enddate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                round(@Old_Rate,2) as Old_Rate,
				Round(sum(f010.MilkPrice),2)  as Old_Amount,
                round(@New_Rate,2) as New_Rate,
				round(sum(GetMilkBaseChartIdRate(f010.Org_Id, f010.MCC_Id, var_Chart_Id, 
				Roundoff('Quality', ((f010.Dairy_Fat))), 
				Roundoff('Quality', ((f010.Dairy_SNF))), 
				f010.MilkType_Id,var_Date)  *(f010.Dairy_Quantity_Ltr)),2) as New_Amount
				from t027_invoice_farmer t027
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = t027.Org_Id 
                and f010.MCC_Id = t027.MCC_Id
                and f010.OutsideInvoice_Id = t027.Voucher_Id
                and (f010.MilkPrice is not null  or f010.MilkPrice <> '')
                and (f010.MilkRate is not null  or f010.MilkRate <> '')
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id and mu04.Farmer_Id = t027.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t027.Org_Id 
                and m005.MCC_Id = t027.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
                and m005.MCC_Id = var_MCC_Id
				where t027.Org_Id = var_Org_Id
                and date(t027.Invoice_Date) = date(var_Date)
                and concat( t027.Farmer_Id,t027.MCC_Id ) not in (select Check_Data from temp_Check_Data_2)
                group by
                t027.Voucher_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate,
				t027.MusterCycle_EndDate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
				f010.Org_Id, f010.MCC_Id,f010.MilkType_Id
                
				union all
                
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate as startdate,
				t027.MusterCycle_EndDate as enddate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                round(@Old_Rate,2) as Old_Rate,
				Round(sum(f010.MilkPrice),2)  as Old_Amount,
                round(@New_Rate,2) as New_Rate,
                round(sum(GetMilkBaseChartIdRate(f010.Org_Id, f010.MCC_Id, var_Chart_Id, 
				Roundoff('Quality', ((f010.Dairy_Fat))), 
				Roundoff('Quality', ((f010.Dairy_SNF))), 
				f010.MilkType_Id,var_Date)  * (f010.Dairy_Quantity_Ltr)),2) as New_Amount
				from t027_invoice_farmer t027
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = t027.Org_Id 
                and f010.MCC_Id = t027.MCC_Id
                and f010.OutsideInvoice_Id = t027.Voucher_Id
                and (f010.MilkPrice is not null  or f010.MilkPrice <> '')
                and (f010.MilkRate is not null  or f010.MilkRate <> '')
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id and mu04.Farmer_Id = t027.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t027.Org_Id 
                and m005.MCC_Id = t027.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014003')
                and m005.MCC_Id = var_MCC_Id
				where t027.Org_Id = var_Org_Id
                and date(t027.Invoice_Date) = date(var_Date)
                and concat( t027.Farmer_Id,t027.MCC_Id ) not in (select Check_Data from temp_Check_Data_3)
                group by
                t027.Voucher_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate,
				t027.MusterCycle_EndDate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                f010.Org_Id, f010.MCC_Id,f010.MilkType_Id
			) AS subquery
			ORDER BY subquery.Farmer_Name asc;
            */
            				
                SET SQL_SAFE_UPDATES = 0;
                DROP TEMPORARY TABLE IF EXISTS temp_Check_Data_1;
				CREATE TEMPORARY TABLE temp_Check_Data_1 ( 
				Org_Id varchar(20), Check_Data longtext);
				
				Insert into temp_Check_Data_1 (
				Org_Id,Check_Data
				)
				select Org_Id, concat(
				Farmer_Id,MCC_Id
				) as Check_Data from t027_invoice_farmer where Is_RateChange =1 
                and MCC_Id = var_MCC_Id
                and Org_Id = var_Org_Id
                and date(Invoice_Date) = date(var_Date)
				group by Org_Id, Farmer_Id,MCC_Id,Invoice_Date,MusterCycle_StartDate,MusterCycle_EndDate;
                
                
				DROP TEMPORARY TABLE IF EXISTS temp_Check_Data_2;
				CREATE TEMPORARY TABLE temp_Check_Data_2 ( 
				Org_Id varchar(20), Check_Data longtext);
				
				Insert into temp_Check_Data_2 (
				Org_Id,Check_Data
				)
				select Org_Id, concat(
				Farmer_Id,MCC_Id
				) as Check_Data from t027_invoice_farmer where Is_RateChange =1 
                and MCC_Id = var_MCC_Id
                and Org_Id = var_Org_Id
                and date(Invoice_Date) = date(var_Date)
				group by Org_Id, Farmer_Id,MCC_Id,Invoice_Date,MusterCycle_StartDate,MusterCycle_EndDate;
                
                
                
                DROP TEMPORARY TABLE IF EXISTS temp_Check_Data_3;
				CREATE TEMPORARY TABLE temp_Check_Data_3 ( 
				Org_Id varchar(20), Check_Data longtext);
				
				Insert into temp_Check_Data_3 (
				Org_Id,Check_Data
				)
				select Org_Id, concat(
				Farmer_Id,MCC_Id
				) as Check_Data from t027_invoice_farmer where Is_RateChange =1 
                and MCC_Id = var_MCC_Id
                and Org_Id = var_Org_Id
                and date(Invoice_Date) = date(var_Date)
				group by Org_Id, Farmer_Id,MCC_Id,Invoice_Date,MusterCycle_StartDate,MusterCycle_EndDate;
            
			set @Old_Rate = (select 
								m0013.Amount
								from m001_milkrate_mcc_header m0011 
								inner join m001_milkrate_mcc_item m0012 on
								m0012.Org_Id = m0011.Org_Id 
								and m0012.Chart_Id = m0011.Chart_Id 
								and m0012.Version_No = m0011.Version_No 
								and m0012.MCC_Id = var_MCC_Id
								inner join m001_milkrate_item m0013 on
								m0013.Org_Id = m0011.Org_Id 
								and m0013.Chart_Id = m0011.Chart_Id 
								and m0013.MilkRateEntryType_Id = 'C012001'
								where date(m0011.Applicable_Date) <= date(var_Date)
								and m0011.Org_Id = var_Org_Id
								order by 
								m0011.Applicable_Date desc,
								m0013.Applicable_Date desc
								limit 1);
			
            set @New_Rate = (select Amount from m001_milkrate_item 
								where Org_Id = var_Org_Id
								and Chart_Id  = var_Chart_Id
								and MilkRateEntryType_Id = 'C012001'
                                and date(Applicable_Date) <= date(var_Date)
								order by 
								Applicable_Date desc
								limit 1);

                                
				DROP TEMPORARY TABLE IF EXISTS temp_Report;
				CREATE TEMPORARY TABLE temp_Report ( 
				Invoice_Id varchar(20), Invoice_No varchar(20), Invoice_Date date,startdate date,enddate date,
                Farmer_Id varchar(20),Farmer_Name varchar(255),Farmer_Code varchar(20),
                MCC_Id varchar(20),MCC_Name varchar(255),MCC_Code varchar(20),
                MilkPrice decimal(30,2),Org_Id varchar(20),Fat decimal(30,3),SNF decimal(30,3),MilkType_Id varchar(20),Quantity_Ltr decimal(30,3),
                New_Rate decimal(30,3)
                );
				
                insert into temp_Report (
                Invoice_Id , Invoice_No , Invoice_Date ,startdate ,enddate ,
                Farmer_Id ,Farmer_Name ,Farmer_Code ,
                MCC_Id ,MCC_Name ,MCC_Code ,
                MilkPrice ,Org_Id ,Fat ,SNF ,MilkType_Id ,Quantity_Ltr 
                )
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate as startdate,
				t027.MusterCycle_EndDate as enddate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                t005.Amount as MilkPrice,
                t005.Org_Id,
                t005.Fat,
                t005.SNF,
                t005.MilkType_Id,
                t005.Quantity_Ltr
				from t027_invoice_farmer t027
                inner join t005_milkcollectionfarmer t005 on
                t027.Org_Id = t005.Org_Id 
                and t027.MCC_Id = t005.MCC_Id
                and t027.Voucher_Id = t005.Invoice_Id
                Inner Join t004_mcccollectionshift t004 on 
                t004.Org_Id = t005.Org_Id 
                and t004.MCC_Id = t005.MCC_Id
                and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id 
                and mu04.Farmer_Id = t005.Farmer_Id
                and ifnull(t005.Amount ,'') <> ''
                and ifnull(t005.ApplicableRate ,'') <> ''
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
                and m005.MCC_Id = t005.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
                and m005.MCCWorkType_Id = 'C023002'
                and m005.MCC_Id = var_MCC_Id
				where t027.Org_Id = var_Org_Id
                and date(t027.Invoice_Date) = date(var_Date)
                and concat( t027.Farmer_Id,t027.MCC_Id ) not in (select Check_Data from temp_Check_Data_1)
				
				union all
				
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate as startdate,
				t027.MusterCycle_EndDate as enddate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                f010.MilkPrice,
                f010.Org_Id,
                f010.Dairy_Fat as Fat,
                f010.Dairy_SNF as SNF,
                f010.MilkType_Id,
                f010.Dairy_Quantity_Ltr as Quantity_Ltr
				from t027_invoice_farmer t027
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = t027.Org_Id 
                and f010.MCC_Id = t027.MCC_Id
                and f010.OutsideInvoice_Id = t027.Voucher_Id
                and ifnull(f010.MilkPrice ,'') <> ''
                and ifnull(f010.MilkRate ,'') <> ''
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id and mu04.Farmer_Id = t027.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t027.Org_Id 
                and m005.MCC_Id = t027.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
                and m005.MCC_Id = var_MCC_Id
				where t027.Org_Id = var_Org_Id
                and date(t027.Invoice_Date) = date(var_Date)
                and concat( t027.Farmer_Id,t027.MCC_Id ) not in (select Check_Data from temp_Check_Data_2)
                
				union all
                
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate as startdate,
				t027.MusterCycle_EndDate as enddate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                f010.MilkPrice,
                f010.Org_Id,
                f010.Dairy_Fat as Fat,
                f010.Dairy_SNF as SNF,
                f010.MilkType_Id,
                f010.Dairy_Quantity_Ltr as Quantity_Ltr
				from t027_invoice_farmer t027
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = t027.Org_Id 
                and f010.MCC_Id = t027.MCC_Id
                and f010.OutsideInvoice_Id = t027.Voucher_Id
                and ifnull(f010.MilkPrice ,'') <> ''
                and ifnull(f010.MilkRate ,'') <> ''
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id and mu04.Farmer_Id = t027.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t027.Org_Id 
                and m005.MCC_Id = t027.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014003')
                and m005.MCC_Id = var_MCC_Id
				where t027.Org_Id = var_Org_Id
                and date(t027.Invoice_Date) = date(var_Date)
                and concat( t027.Farmer_Id,t027.MCC_Id ) not in (select Check_Data from temp_Check_Data_3);
                
               
               
                
                
             
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report_Check;
				CREATE TEMPORARY TABLE temp_Report_Check ( 
				Org_Id varchar(20), MCC_Id varchar(20),Fat decimal(30,3),SNF decimal(30,3),
                MilkType_Id varchar(20),New_Rate decimal(30,3)
                );
				
                insert into temp_Report_Check (
                Org_Id,MCC_Id,Fat,SNF,MilkType_Id
                )
                select Org_Id,MCC_Id,Fat,SNF,MilkType_Id 
                from temp_Report
                group by Org_Id,MCC_Id,Fat,SNF,MilkType_Id;
                
                Update temp_Report_Check 
				set New_Rate = GetMilkBaseChartIdRate(Org_Id, MCC_Id, var_Chart_Id, 
									Roundoff('Quality', ((Fat))), 
									Roundoff('Quality', ((SNF))), 
									MilkType_Id,var_Date);
                                    
                
                
                Update temp_Report tmp
                    inner join temp_Report_Check tmpc on tmp.Org_Id = tmpc.Org_Id 
                    and tmp.MCC_Id = tmpc.MCC_Id
                    and tmp.Fat = tmpc.Fat
                    and tmp.SNF = tmpc.SNF
                    set tmp.New_Rate = tmpc.New_Rate ;
                    
				
				select 
				Invoice_Id,
				Invoice_No,
				Invoice_Date,
				startdate,
				enddate,
				Farmer_Id,Farmer_Name,Farmer_Code,
				MCC_Id, MCC_Name,MCC_Code,
				round(@Old_Rate,2) as Old_Rate,
				Round(sum(MilkPrice),2)  as Old_Amount,
				round(@New_Rate,2) as New_Rate,
                Round(sum(New_Rate * Quantity_Ltr),2) as New_Amount
				from temp_Report
                group by Invoice_Id,
				Invoice_No,
				Invoice_Date,
				startdate,
				enddate,
				Farmer_Id,Farmer_Name,Farmer_Code,
				MCC_Id, MCC_Name,MCC_Code
                ORDER BY Farmer_Name asc;
        end;
	elseif(var_Method_Name = 'Get_One') then 
		begin
			SELECT * FROM (
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                t005.Fat as Fat,
                t005.SNF as SNF,
				ApplicableRate as Old_Rate,
				Amount  as Old_Amount,
                GetMilkBaseChartIdRate(t005.Org_Id, t005.MCC_Id, var_Chart_Id, 
				Roundoff('Quality', ((t005.Fat))), 
				Roundoff('Quality', ((t005.SNF))), 
				t005.MilkType_Id,var_Date) as New_Rate,
                round(GetMilkBaseChartIdRate(t005.Org_Id, t005.MCC_Id, var_Chart_Id, 
				Roundoff('Quality', ((t005.Fat))), 
				Roundoff('Quality', ((t005.SNF))), 
				t005.MilkType_Id,var_Date) * (t005.Quantity_Ltr),2) as New_Amount,
                c011.MilkType_Name,
                c011.MilkType_Id,
                DATE_FORMAT(t005.Created_On, '%d %b %Y') AS Invoice_Date,
                t005.Quantity_Ltr as quantity
				from t027_invoice_farmer t027
                inner join t005_milkcollectionfarmer t005 on
                t027.Org_Id = t005.Org_Id 
                and t027.MCC_Id = t005.MCC_Id
                and t027.Voucher_Id = t005.Invoice_Id
                and (t005.Amount is not null  or t005.Amount <> '')
                and (t005.ApplicableRate is not null  or t005.ApplicableRate <> '')
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id
                and t004.MCC_Id = t005.MCC_Id
                and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id and mu04.Farmer_Id = t005.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
                and m005.MCC_Id = t005.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
                and m005.MCCWorkType_Id = 'C023002'
                and m005.MCC_Id = var_MCC_Id
                Inner Join c011_milktype c011 on c011.MilkType_Id = t005.MilkType_Id
				where t027.Org_Id = var_Org_Id
                and t027.Voucher_Id = var_Invoice_Id
				
				union all
				
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                f010.Dairy_Fat as Fat,
                f010.Dairy_SNF as SNF,
                f010.MilkRate as Old_Rate,
				f010.MilkPrice  as Old_Amount,
                GetMilkBaseChartIdRate(f010.Org_Id, f010.MCC_Id, var_Chart_Id, 
				Roundoff('Quality', ((f010.Dairy_Fat))), 
				Roundoff('Quality', ((f010.Dairy_SNF))), 
				f010.MilkType_Id,var_Date) as New_Rate,
				round(GetMilkBaseChartIdRate(f010.Org_Id, f010.MCC_Id, var_Chart_Id, 
				Roundoff('Quality', ((f010.Dairy_Fat))), 
				Roundoff('Quality', (( f010.Dairy_SNF))), 
				f010.MilkType_Id,var_Date)  * (f010.Dairy_Quantity_Ltr),2) as New_Amount,
                c011.MilkType_Name,
                c011.MilkType_Id,
                DATE_FORMAT(f010.Collection_Date, '%d %b %Y') AS Invoice_Date,
                f010.Dairy_Quantity_Ltr as quantity
				from t027_invoice_farmer t027
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = t027.Org_Id 
                and f010.MCC_Id = t027.MCC_Id
                and f010.OutsideInvoice_Id = t027.Voucher_Id
                and (f010.MilkPrice is not null  or f010.MilkPrice <> '')
                and (f010.MilkRate is not null  or f010.MilkRate <> '')
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id and mu04.Farmer_Id = t027.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t027.Org_Id 
                and m005.MCC_Id = t027.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
                and m005.MCC_Id = var_MCC_Id
                Inner Join c011_milktype c011 on c011.MilkType_Id = f010.MilkType_Id
				where t027.Org_Id = var_Org_Id
                and t027.Voucher_Id = var_Invoice_Id
                
				union all
                
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                f010.Dairy_Fat as Fat,
                f010.Dairy_SNF as SNF,
                f010.MilkRate as Old_Rate,
				f010.MilkPrice  as Old_Amount,
                GetMilkBaseChartIdRate(f010.Org_Id, f010.MCC_Id, var_Chart_Id, 
				Roundoff('Quality', ((f010.Dairy_Fat))), 
				Roundoff('Quality', ((f010.Dairy_SNF))), 
				f010.MilkType_Id,var_Date) as New_Rate,
				round(GetMilkBaseChartIdRate(f010.Org_Id, f010.MCC_Id, var_Chart_Id, 
				Roundoff('Quality', ((f010.Dairy_Fat))), 
				Roundoff('Quality', ((f010.Dairy_SNF))), 
				f010.MilkType_Id,var_Date)  * (f010.Dairy_Quantity_Ltr),2) as New_Amount,
                c011.MilkType_Name,
                c011.MilkType_Id,
                DATE_FORMAT(f010.Collection_Date, '%d %b %Y') AS Invoice_Date,
                f010.Dairy_Quantity_Ltr as quantity
				from t027_invoice_farmer t027
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = t027.Org_Id 
                and f010.MCC_Id = t027.MCC_Id
                and f010.OutsideInvoice_Id = t027.Voucher_Id
                and (f010.MilkPrice is not null  or f010.MilkPrice <> '')
                and (f010.MilkRate is not null  or f010.MilkRate <> '')
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id and mu04.Farmer_Id = t027.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t027.Org_Id 
                and m005.MCC_Id = t027.MCC_Id
                and m005.MCCType_Id = var_MCCType_Id
                and m005.MCCType_Id in('C014003')
                and m005.MCC_Id = var_MCC_Id
                Inner Join c011_milktype c011 on c011.MilkType_Id = f010.MilkType_Id
				where t027.Org_Id = var_Org_Id
                and t027.Voucher_Id = var_Invoice_Id
			) AS subquery
			ORDER BY subquery.Farmer_Name asc;
        end;
	elseif (var_Method_Name = 'test') then
		begin
                SET SQL_SAFE_UPDATES = 0;
                DROP TEMPORARY TABLE IF EXISTS temp_Check_Data_1;
				CREATE TEMPORARY TABLE temp_Check_Data_1 ( 
				Org_Id varchar(20), Check_Data longtext);
				
				Insert into temp_Check_Data_1 (
				Org_Id,Check_Data
				)
				select Org_Id, concat(
				Farmer_Id,MCC_Id
				) as Check_Data from t027_invoice_farmer where Is_RateChange =1 
                and MCC_Id = 'M005241000074'
                and Org_Id = 'C005'
                and date(Invoice_Date) = date('2024-02-10')
				group by Org_Id, Farmer_Id,MCC_Id,Invoice_Date,MusterCycle_StartDate,MusterCycle_EndDate;
                
                
				DROP TEMPORARY TABLE IF EXISTS temp_Check_Data_2;
				CREATE TEMPORARY TABLE temp_Check_Data_2 ( 
				Org_Id varchar(20), Check_Data longtext);
				
				Insert into temp_Check_Data_2 (
				Org_Id,Check_Data
				)
				select Org_Id, concat(
				Farmer_Id,MCC_Id
				) as Check_Data from t027_invoice_farmer where Is_RateChange =1 
                and MCC_Id = 'M005241000074'
                and Org_Id = 'C005'
                and date(Invoice_Date) = date('2024-02-10')
				group by Org_Id, Farmer_Id,MCC_Id,Invoice_Date,MusterCycle_StartDate,MusterCycle_EndDate;
                
                
                
                DROP TEMPORARY TABLE IF EXISTS temp_Check_Data_3;
				CREATE TEMPORARY TABLE temp_Check_Data_3 ( 
				Org_Id varchar(20), Check_Data longtext);
				
				Insert into temp_Check_Data_3 (
				Org_Id,Check_Data
				)
				select Org_Id, concat(
				Farmer_Id,MCC_Id
				) as Check_Data from t027_invoice_farmer where Is_RateChange =1 
                and MCC_Id = 'M005241000074'
                and Org_Id = 'C005'
                and date(Invoice_Date) = date('2024-02-10')
				group by Org_Id, Farmer_Id,MCC_Id,Invoice_Date,MusterCycle_StartDate,MusterCycle_EndDate;
            
			set @Old_Rate = (select 
								m0013.Amount
								from m001_milkrate_mcc_header m0011 
								inner join m001_milkrate_mcc_item m0012 on
								m0012.Org_Id = m0011.Org_Id 
								and m0012.Chart_Id = m0011.Chart_Id 
								and m0012.Version_No = m0011.Version_No 
								and m0012.MCC_Id = 'M005241000074'
								inner join m001_milkrate_item m0013 on
								m0013.Org_Id = m0011.Org_Id 
								and m0013.Chart_Id = m0011.Chart_Id 
								and m0013.MilkRateEntryType_Id = 'C012001'
								where date(m0011.Applicable_Date) <= date('2024-02-10')
								and m0011.Org_Id = 'C005'
								order by 
								m0011.Applicable_Date desc,
								m0013.Applicable_Date desc
								limit 1);
			
            set @New_Rate = (select Amount from m001_milkrate_item 
								where Org_Id = 'C005'
								and Chart_Id  = 'M001241000002'
								and MilkRateEntryType_Id = 'C012001'
                                and date(Applicable_Date) <= date('2024-02-10')
								order by 
								Applicable_Date desc
								limit 1);

                                
				DROP TEMPORARY TABLE IF EXISTS temp_Report;
				CREATE TEMPORARY TABLE temp_Report ( 
				Invoice_Id varchar(20), Invoice_No varchar(20), Invoice_Date date,startdate date,enddate date,
                Farmer_Id varchar(20),Farmer_Name varchar(255),Farmer_Code varchar(20),
                MCC_Id varchar(20),MCC_Name varchar(255),MCC_Code varchar(20),
                MilkPrice decimal(30,2),Org_Id varchar(20),Fat decimal(30,3),SNF decimal(30,3),MilkType_Id varchar(20),Quantity_Ltr decimal(30,3),
                New_Rate decimal(30,3)
                );
				
                insert into temp_Report (
                Invoice_Id , Invoice_No , Invoice_Date ,startdate ,enddate ,
                Farmer_Id ,Farmer_Name ,Farmer_Code ,
                MCC_Id ,MCC_Name ,MCC_Code ,
                MilkPrice ,Org_Id ,Fat ,SNF ,MilkType_Id ,Quantity_Ltr 
                )
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate as startdate,
				t027.MusterCycle_EndDate as enddate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                t005.Amount as MilkPrice,
                t005.Org_Id,
                t005.Fat,
                t005.SNF,
                t005.MilkType_Id,
                t005.Quantity_Ltr
				from t027_invoice_farmer t027
                inner join t005_milkcollectionfarmer t005 on
                t027.Org_Id = t005.Org_Id 
                and t027.MCC_Id = t005.MCC_Id
                and t027.Voucher_Id = t005.Invoice_Id
                Inner Join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
				Inner Join mu04_farmer mu04 on mu04.Org_Id = t005.Org_Id 
                and mu04.Farmer_Id = t005.Farmer_Id
                and ifnull(t005.Amount ,'') <> ''
                and ifnull(t005.ApplicableRate ,'') <> ''
				Inner Join m005_mcc m005 on m005.Org_Id = t005.Org_Id 
                and m005.MCC_Id = t005.MCC_Id
                and m005.MCCType_Id = 'C014002'
                and m005.MCCType_Id in('C014001','C014002')
                and m005.MCCWorkType_Id = 'C023002'
                and m005.MCC_Id = 'M005241000074'
				where t027.Org_Id = 'C005'
                and date(t027.Invoice_Date) = date('2024-02-10')
                and concat( t027.Farmer_Id,t027.MCC_Id ) not in (select Check_Data from temp_Check_Data_1)
				
				union all
				
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate as startdate,
				t027.MusterCycle_EndDate as enddate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                f010.MilkPrice,
                f010.Org_Id,
                f010.Dairy_Fat as Fat,
                f010.Dairy_SNF as SNF,
                f010.MilkType_Id,
                f010.Dairy_Quantity_Ltr as Quantity_Ltr
				from t027_invoice_farmer t027
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = t027.Org_Id 
                and f010.MCC_Id = t027.MCC_Id
                and f010.OutsideInvoice_Id = t027.Voucher_Id
                and ifnull(f010.MilkPrice ,'') <> ''
                and ifnull(f010.MilkRate ,'') <> ''
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id and mu04.Farmer_Id = t027.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t027.Org_Id 
                and m005.MCC_Id = t027.MCC_Id
                and m005.MCCType_Id = 'C014002'
                and m005.MCCType_Id in('C014001','C014002')
				and m005.MCCWorkType_Id = 'C023001'
                and m005.MCC_Id = 'M005241000074'
				where t027.Org_Id = 'C005'
                and date(t027.Invoice_Date) = date('2024-02-10')
                and concat( t027.Farmer_Id,t027.MCC_Id ) not in (select Check_Data from temp_Check_Data_2)
                
				union all
                
				select 
				t027.Voucher_Id as Invoice_Id,
                t027.Invoice_No,
                t027.Invoice_Date,
				t027.MusterCycle_StartDate as startdate,
				t027.MusterCycle_EndDate as enddate,
                mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
				m005.MCC_Id, m005.MCC_Name,m005.MCC_Code,
                f010.MilkPrice,
                f010.Org_Id,
                f010.Dairy_Fat as Fat,
                f010.Dairy_SNF as SNF,
                f010.MilkType_Id,
                f010.Dairy_Quantity_Ltr as Quantity_Ltr
				from t027_invoice_farmer t027
                inner join f010_milkcollectionmcc_final f010 on
                f010.Org_Id = t027.Org_Id 
                and f010.MCC_Id = t027.MCC_Id
                and f010.OutsideInvoice_Id = t027.Voucher_Id
                and ifnull(f010.MilkPrice ,'') <> ''
                and ifnull(f010.MilkRate ,'') <> ''
                Inner Join mu04_farmer mu04 on mu04.Org_Id = t027.Org_Id and mu04.Farmer_Id = t027.Farmer_Id
				Inner Join m005_mcc m005 on m005.Org_Id = t027.Org_Id 
                and m005.MCC_Id = t027.MCC_Id
                and m005.MCCType_Id = 'C014002'
                and m005.MCCType_Id in('C014003')
                and m005.MCC_Id = 'M005241000074'
				where t027.Org_Id = 'C005'
                and date(t027.Invoice_Date) = date('2024-02-10')
                and concat( t027.Farmer_Id,t027.MCC_Id ) not in (select Check_Data from temp_Check_Data_3);
                
               
               
                
                
             
                
                DROP TEMPORARY TABLE IF EXISTS temp_Report_Check;
				CREATE TEMPORARY TABLE temp_Report_Check ( 
				Org_Id varchar(20), MCC_Id varchar(20),Fat decimal(30,3),SNF decimal(30,3),
                MilkType_Id varchar(20),New_Rate decimal(30,3)
                );
				
                insert into temp_Report_Check (
                Org_Id,MCC_Id,Fat,SNF,MilkType_Id
                )
                select Org_Id,MCC_Id,Fat,SNF,MilkType_Id 
                from temp_Report
                group by Org_Id,MCC_Id,Fat,SNF,MilkType_Id;
                
                Update temp_Report_Check 
				set New_Rate = GetMilkBaseChartIdRate(Org_Id, MCC_Id, 'M001241000002', 
									Roundoff('Quality', ((Fat))), 
									Roundoff('Quality', ((SNF))), 
									MilkType_Id,'2024-02-10');
                                    
                
                
                Update temp_Report tmp
                    inner join temp_Report_Check tmpc on tmp.Org_Id = tmpc.Org_Id 
                    and tmp.MCC_Id = tmpc.MCC_Id
                    and tmp.Fat = tmpc.Fat
                    and tmp.SNF = tmpc.SNF
                    set tmp.New_Rate = tmpc.New_Rate ;
                    
				
				select 
				Invoice_Id,
				Invoice_No,
				Invoice_Date,
				startdate,
				enddate,
				Farmer_Id,Farmer_Name,Farmer_Code,
				MCC_Id, MCC_Name,MCC_Code,
				round(@Old_Rate,2) as Old_Rate,
				Round(sum(MilkPrice),2)  as Old_Amount,
				round(@New_Rate,2) as New_Rate,
                Round(sum(New_Rate * Quantity_Ltr),2) as New_Amount
				from temp_Report
                group by Invoice_Id,
				Invoice_No,
				Invoice_Date,
				startdate,
				enddate,
				Farmer_Id,Farmer_Name,Farmer_Code,
				MCC_Id, MCC_Name,MCC_Code;
                
    end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
