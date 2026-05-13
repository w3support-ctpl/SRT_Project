-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDashboard` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDashboard`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_MCC_Id varchar(255),
    var_Date varchar(255),
    var_Type varchar(255)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
    SET SQL_SAFE_UPDATES = 0;
	if (var_Method_Name = 'Get_Collection') then
		begin
			Declare var_collection_rmrdmorning varchar(20);
            Declare var_collection_rmrdevening varchar(20);
            Declare var_collection_bmc varchar(20);
            Declare var_collection_outside varchar(20);
            Declare var_collection_total varchar(20);
            Declare var_grn_rmrdmorning varchar(20);
            Declare var_grn_rmrdevening varchar(20);
            Declare var_grn_bmc varchar(20);
            Declare var_grn_total varchar(20);
            
            
            -- Set the current date and time
			SET @Current_Datetime = CONVERT_TZ(NOW(), '+00:00', '+00:00');

			-- Set the date and time from 5 days ago
			SET @Five_Days_Back = DATE_SUB(@Current_Datetime, INTERVAL 5 DAY);

			set @Is_Blocked = (SELECT count(*) FROM tm02_mcc_block 
			where date(Date) = date(@Current_Datetime)
			and Org_Id =  var_Org_Id);

			
            if(@Is_Blocked = 0)then
            
				DROP TEMPORARY TABLE IF EXISTS temp_Report;

				CREATE TEMPORARY TABLE temp_Report ( 
				Org_Id varchar(20), MCC_Id varchar(20), 
				Count varchar(20));

				insert into temp_Report (Org_Id,MCC_Id,Count)
				select 
				m005.Org_Id ,
				m005.MCC_Id ,
				count(f010.MCC_Id) as Count
				from m005_mcc m005
				left join f010_milkcollectionmcc_final f010 on
				f010.Org_Id = m005.Org_Id
				and date(f010.Collection_Date) >= date(@Five_Days_Back)
				and date(f010.Collection_Date) <= date(@Current_Datetime)
				and f010.MCC_Id = m005.MCC_Id
				where m005.Is_Active = 1
				and m005.Org_Id = var_Org_Id
				group by 
				m005.Org_Id,
				m005.MCC_Id
				HAVING 
				Count = 0;

                Update m005_mcc
				set 
				Is_Active = 0,
				Blocked_On = now()
				where Org_Id = var_Org_Id 
                and MCC_Id in ( select MCC_Id from temp_Report); 
                
                Insert Into tm02_mcc_block
                (Org_Id, Date,Is_Blocked)
                Values (var_Org_Id,now(),1);
            
            end if;
						
            
            
            set var_collection_rmrdmorning = (
												select IFNULL(round(SUM(t0091.Liters)), 0) from t009_milkcollectiondairy_header t009
												inner join t021_tripdocument_header t021 on t009.Org_Id = t021.Org_Id
													and t009.TripDocument_Id = t021.TripDocument_Id
												inner join m008_route_vehicle m008 on m008.Org_Id = t021.Org_Id
													and m008.Entry_Id = t021.Route_Trip_Id
												inner join m006_route m006 on m008.Org_Id = m006.Org_Id
													and m008.Route_Id = m006.Route_Id
													and m006.CollectionShift_Id = 'C015001'
												inner join m003_vehicle m003 on m003.Org_Id = t009.Org_Id
													and m003.Vehicle_Id = t009.Vehicle_Id
													and m003.VehicleType_Id = 'C020001'
												inner join t009_milkcollectiondairy_quantity t0091 on t009.Org_Id = t0091.Org_Id
													and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
													and t0091.TripDocument_Id = t009.TripDocument_Id
                                                    and t0091.MilkStatus_Id = 'C016001'
												where t009.Org_Id = var_Org_Id
												and date(t009.Created_On) = date(now())
												);
                                                
            set var_collection_rmrdevening = (
												select IFNULL(round(SUM(t0091.Liters)), 0) from t009_milkcollectiondairy_header t009
												inner join t021_tripdocument_header t021 on t009.Org_Id = t021.Org_Id
													and t009.TripDocument_Id = t021.TripDocument_Id
												inner join m008_route_vehicle m008 on m008.Org_Id = t021.Org_Id
													and m008.Entry_Id = t021.Route_Trip_Id
												inner join m006_route m006 on m008.Org_Id = m006.Org_Id
													and m008.Route_Id = m006.Route_Id
													and m006.CollectionShift_Id = 'C015002'
												inner join m003_vehicle m003 on m003.Org_Id = t009.Org_Id
													and m003.Vehicle_Id = t009.Vehicle_Id
													and m003.VehicleType_Id = 'C020001'
												inner join t009_milkcollectiondairy_quantity t0091 on t009.Org_Id = t0091.Org_Id
													and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
													and t0091.TripDocument_Id = t009.TripDocument_Id
                                                    and t0091.MilkStatus_Id = 'C016001'
												where t009.Org_Id = var_Org_Id
												and date(t009.Created_On) = date(now())
												);
            set var_collection_bmc = (select IFNULL(round(SUM(t0091.Liters)), 0) from t009_milkcollectiondairy_header t009
										inner join t021_tripdocument_header t021 on t009.Org_Id = t021.Org_Id
											and t009.TripDocument_Id = t021.TripDocument_Id
										inner join m008_route_vehicle m008 on m008.Org_Id = t021.Org_Id
											and m008.Entry_Id = t021.Route_Trip_Id
										inner join m006_route m006 on m008.Org_Id = m006.Org_Id
											and m008.Route_Id = m006.Route_Id
										inner join m003_vehicle m003 on m003.Org_Id = t009.Org_Id
											and m003.Vehicle_Id = t009.Vehicle_Id
											and m003.VehicleType_Id = 'C020002'
										inner join t009_milkcollectiondairy_quantity t0091 on t009.Org_Id = t0091.Org_Id
											and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
											and t0091.TripDocument_Id = t009.TripDocument_Id
                                            and t0091.MilkStatus_Id = 'C016001'
										where t009.Org_Id = var_Org_Id
										and date(t009.Created_On) = date(now()));
                                        
				set var_collection_outside = (select IFNULL(round(SUM(t0091.Weight)), 0) from t009_milkcollectiondairy_header  t009
										inner join t009_milkcollectiondairy_quantity t0091 on
										t0091.Org_Id = t009.Org_Id
                                        and t0091.MilkStatus_Id = 'C016001'
										and t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
										where date(t009.Created_On) = date(now()) 
										and t009.Org_Id = var_Org_Id
										and t009.Is_OutsideVehicle = 1);
                                        
			set var_collection_bmc = var_collection_bmc +var_collection_outside;
                                        
                                        
            set var_collection_total = var_collection_rmrdmorning + var_collection_rmrdevening + var_collection_bmc;
            set var_collection_total = FORMAT(var_collection_total, 3);
            
            set var_collection_total = REPLACE(var_collection_total, ',', '');
            
            set var_grn_rmrdmorning = (select IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) 
										from f010_milkcollectionmcc_final f010
										inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id
											and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
										inner join m003_vehicle m003 on m003.Org_Id = t009.Org_Id
											and m003.Vehicle_Id = t009.Vehicle_Id
											and m003.VehicleType_Id = 'C020001'
										where f010.Org_Id = var_Org_Id
										and f010.CollectionShift_Id ='C015001'
										and f010.MCC_Id is not null
										and f010.CollectionShift_Id is  not null
										and date(f010.Collection_Date) = date(now())
										);
            set var_grn_rmrdevening =  (select IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) 
										from f010_milkcollectionmcc_final f010
										inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id
											and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
										inner join m003_vehicle m003 on m003.Org_Id = t009.Org_Id
											and m003.Vehicle_Id = t009.Vehicle_Id
											and m003.VehicleType_Id = 'C020001'
										where f010.Org_Id = var_Org_Id
										and f010.CollectionShift_Id ='C015002'
										and f010.MCC_Id is not null
										and f010.CollectionShift_Id is  not null
										and date(f010.Collection_Date) = date(now())
										);
            set var_grn_bmc =  (select IFNULL(SUM(f010.Dairy_Quantity_Ltr), 0) 
								from f010_milkcollectionmcc_final f010
								inner join t009_milkcollectiondairy_header t009 on t009.Org_Id = f010.Org_Id
									and t009.MilkCollectionDairy_Id = f010.MilkCollectionDairy_Id
								inner join m003_vehicle m003 on m003.Org_Id = t009.Org_Id
									and m003.Vehicle_Id = t009.Vehicle_Id
									and m003.VehicleType_Id = 'C020002'
								where f010.Org_Id = var_Org_Id
								and f010.MCC_Id is not null
								and f010.CollectionShift_Id is null
								and date(f010.Collection_Date) = date(now()));
            
            -- If differnece between Milk Collected and GRN is less than 10 Ltr then make it same
            if (abs (var_grn_rmrdmorning - var_collection_rmrdmorning) < 10 ) then
				set var_grn_rmrdmorning = var_collection_rmrdmorning;
            end if;
            
            -- If differnece between Milk Collected and GRN is less than 10 Ltr then make it same
            if (abs (var_grn_rmrdevening - var_collection_rmrdevening) < 10 ) then
				set var_grn_rmrdevening = var_collection_rmrdevening;
            end if;
            
            -- If differnece between Milk Collected and GRN is less than 10 Ltr then make it same
            if (abs (var_grn_bmc - var_collection_bmc) < 10 ) then
				set var_grn_bmc = var_collection_bmc;
            end if;
            
            set var_grn_total = var_grn_rmrdmorning + var_grn_rmrdevening + var_grn_bmc;
            set var_grn_total = FORMAT(var_grn_total, 3);
            
            set var_grn_total = REPLACE(var_grn_total, ',', '');
            
           select var_collection_rmrdmorning as collection_rmrdmorning, 
            var_collection_rmrdevening as collection_rmrdevening, 
            var_collection_bmc as collection_bmc, 
            var_collection_total as collection_total,
            var_grn_rmrdmorning as grn_rmrdmorning, 
            var_grn_rmrdevening as grn_rmrdevening, 
            var_grn_bmc as grn_bmc, 
            var_grn_total as grn_total;
		end;
	elseif (var_Method_Name = 'Blocked_MCC') then
		begin
			SET @Current_Datetime = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            SET @Ten_Days_Back = DATE_SUB(@Current_Datetime, INTERVAL 10 DAY);
            
            select 
            date_format(m005.Blocked_On, '%d %M %Y') as Date,
			m005.MCC_Code,
			m005.MCC_Name,
			c014.MCCType_Name,
			c023.MCCWorkType_Name
			from m005_mcc m005
			inner join c014_mcctype c014 on
			c014.MCCType_Id = m005.MCCType_Id
			inner join c023_mccworktype c023 on
			c023.MCCWorkType_Id = m005.MCCWorkType_Id
			where 
            Org_Id = var_Org_Id
             and date(m005.Blocked_On) >= date(@Ten_Days_Back)
			and date(m005.Blocked_On) <= date(@Current_Datetime)
            
            ORDER BY m005.Blocked_On desc;
            
            
        end;
	elseif (var_Method_Name = 'Rate_Change') then
		begin
        
			select 
			f015.Collection_Id,
			m005.MCC_Code as Farmer_Code,
			m005.MCC_Name as Farmer_Name,
			m005.MCC_Code,
			m005.MCC_Name,
			c014.MCCType_Name,
			c023.MCCWorkType_Name,
			f015.Quantity_Ltr,
			f015.Fat,
			f015.SNF,
			f015.Old_Rate,
			f015.Old_Amount,
			f015.New_Rate,
			f015.New_Amount,
			f015.Diff_Amount,
			c015.CollectionShift_Name,
			date_format(f015.Created_On, '%d %M %Y') as Date
			from f015_milk_rate_checker f015 
			inner join m005_mcc m005 on
			m005.Org_Id = f015.Org_Id
			and m005.MCC_Id = f015.MCC_Id
			inner join m005_mcc m0051 on
			m0051.Org_Id = f015.Org_Id
			and m0051.MCC_Id = f015.Farmer_Id
			inner join c014_mcctype c014 on
			c014.MCCType_Id = m005.MCCType_Id
			inner join c023_mccworktype c023 on
			c023.MCCWorkType_Id = m005.MCCWorkType_Id
			inner join c015_collectionshift c015 on
			c015.CollectionShift_Id = f015.CollectionShift_Id
			where f015.Org_Id = var_Org_Id
            and year(f015.Created_On) = year(now())

			UNION ALL

			select 
			f015.Collection_Id,
			mu04.Farmer_Code,
			mu04.Farmer_Name,
			m005.MCC_Code,
			m005.MCC_Name,
			c014.MCCType_Name,
			c023.MCCWorkType_Name,
			f015.Quantity_Ltr,
			f015.Fat,
			f015.SNF,
			f015.Old_Rate,
			f015.Old_Amount,
			f015.New_Rate,
			f015.New_Amount,
			f015.Diff_Amount,
			c015.CollectionShift_Name,
			date_format(f015.Created_On, '%d %M %Y') as Date
			from f015_milk_rate_checker f015 
			inner join m005_mcc m005 on
			m005.Org_Id = f015.Org_Id
			and m005.MCC_Id = f015.MCC_Id
			inner join mu04_farmer mu04 on
			mu04.Org_Id = f015.Org_Id
			and mu04.Farmer_Id = f015.Farmer_Id
			inner join c014_mcctype c014 on
			c014.MCCType_Id = m005.MCCType_Id
			inner join c023_mccworktype c023 on
			c023.MCCWorkType_Id = m005.MCCWorkType_Id
			inner join c015_collectionshift c015 on
			c015.CollectionShift_Id = f015.CollectionShift_Id
			where f015.Org_Id = var_Org_Id
            and year(f015.Created_On) = year(now())
            ORDER BY Date;
            
            
        end;
	elseif (var_Method_Name = 'Rate_Change_All') then
		begin
			select 
            m005.MCC_Id,
			m005.MCC_Name,
            concat(date(f015.Created_On)) as Created_On,
            date_format(f015.Created_On, '%d %M %Y') as Date
            from f015_milk_rate_checker f015
            inner join m005_mcc m005 on
			m005.Org_Id = f015.Org_Id
			and m005.MCC_Id = f015.MCC_Id
            where f015.Org_Id = var_Org_Id
            and year(f015.Created_On) = year(now())
            group by 
            m005.MCC_Id,
			m005.MCC_Name,
            f015.Created_On
            ORDER BY f015.Created_On desc;
        end;
	elseif (var_Method_Name = 'Payment_Pending') then
		begin
			SELECT 
				m005.MCC_Id AS Id,
				m005.MCC_Name AS Name,
				DATE_FORMAT(t027.Invoice_Date, '%Y-%m-%d') AS Created_On,
				DATE_FORMAT(t027.Invoice_Date, '%d %M %Y') AS Date,
				'Farmer' AS User_Type
			FROM t027_invoice_farmer t027
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = t027.Org_Id AND
				m005.MCC_Id = t027.MCC_Id
			WHERE 
				t027.Org_Id = var_Org_Id AND
				t027.Is_IncomePosted = 0 AND
				t027.Is_DeductionPosted = 0
                and year(t027.Invoice_Date) = year(now())
			GROUP BY 
				m005.MCC_Id,
				m005.MCC_Name,
				t027.Invoice_Date

			UNION ALL

			SELECT 
				m005.MCC_Id AS Id,
				m005.MCC_Name AS Name,
				DATE_FORMAT(t028.Invoice_Date, '%Y-%m-%d') AS Created_On,
				DATE_FORMAT(t028.Invoice_Date, '%d %M %Y') AS Date,
				'MCC' AS User_Type
			FROM t028_invoice_mcc t028
			INNER JOIN m005_mcc m005 ON
				m005.Org_Id = t028.Org_Id AND
				m005.MCC_Id = t028.MCC_Id
			WHERE 
				t028.Org_Id = var_Org_Id AND
				t028.Is_Posted = 0
                and year(t028.Invoice_Date) = year(now())
			GROUP BY 
				m005.MCC_Id,
				m005.MCC_Name,
				t028.Invoice_Date

			UNION ALL

			SELECT 
				m009.Transporter_Id AS Id,
				m009.Transporter_Name AS Name,
				DATE_FORMAT(t029.Invoice_Date, '%Y-%m-%d') AS Created_On,
				DATE_FORMAT(t029.Invoice_Date, '%d %M %Y') AS Date,
				'Transporter' AS User_Type
			FROM t029_invoice_transpoter t029
			INNER JOIN m009_transporter m009 ON
				m009.Transporter_Id = t029.Transporter_Id AND
				m009.Transporter_Id = t029.Org_Id
                and year(t029.Invoice_Date) = year(now())
			WHERE 
				t029.Org_Id = var_Org_Id AND
				t029.Is_Posted = 0
			GROUP BY 
				m009.Transporter_Id,
				m009.Transporter_Name,
				t029.Invoice_Date

			ORDER BY Created_On DESC;

        end;
	elseif (var_Method_Name = 'Rate_Change_MCC') then
		begin
			select 
			f015.Collection_Id,
			m005.MCC_Code as Farmer_Code,
			m005.MCC_Name as Farmer_Name,
			m005.MCC_Code,
			m005.MCC_Name,
			c014.MCCType_Name,
			c023.MCCWorkType_Name,
			f015.Quantity_Ltr,
			f015.Fat,
			f015.SNF,
			f015.Old_Rate,
			f015.Old_Amount,
			f015.New_Rate,
			f015.New_Amount,
			f015.Diff_Amount,
			c015.CollectionShift_Name,
			date_format(f015.Created_On, '%d %M %Y') as Date
			from f015_milk_rate_checker f015 
			inner join m005_mcc m005 on
			m005.Org_Id = f015.Org_Id
			and m005.MCC_Id = f015.MCC_Id
			inner join m005_mcc m0051 on
			m0051.Org_Id = f015.Org_Id
			and m0051.MCC_Id = f015.Farmer_Id
			inner join c014_mcctype c014 on
			c014.MCCType_Id = m005.MCCType_Id
			inner join c023_mccworktype c023 on
			c023.MCCWorkType_Id = m005.MCCWorkType_Id
			inner join c015_collectionshift c015 on
			c015.CollectionShift_Id = f015.CollectionShift_Id
			where f015.Org_Id = var_Org_Id
            and date(f015.Created_On) = date(var_Date)
            and f015.MCC_Id = var_MCC_Id
            and year(f015.Created_On) = year(now())

			UNION ALL

			select 
			f015.Collection_Id,
			mu04.Farmer_Code,
			mu04.Farmer_Name,
			m005.MCC_Code,
			m005.MCC_Name,
			c014.MCCType_Name,
			c023.MCCWorkType_Name,
			f015.Quantity_Ltr,
			f015.Fat,
			f015.SNF,
			f015.Old_Rate,
			f015.Old_Amount,
			f015.New_Rate,
			f015.New_Amount,
			f015.Diff_Amount,
			c015.CollectionShift_Name,
			date_format(f015.Created_On, '%d %M %Y') as Date
			from f015_milk_rate_checker f015 
			inner join m005_mcc m005 on
			m005.Org_Id = f015.Org_Id
			and m005.MCC_Id = f015.MCC_Id
			inner join mu04_farmer mu04 on
			mu04.Org_Id = f015.Org_Id
			and mu04.Farmer_Id = f015.Farmer_Id
			inner join c014_mcctype c014 on
			c014.MCCType_Id = m005.MCCType_Id
			inner join c023_mccworktype c023 on
			c023.MCCWorkType_Id = m005.MCCWorkType_Id
			inner join c015_collectionshift c015 on
			c015.CollectionShift_Id = f015.CollectionShift_Id
			where f015.Org_Id = var_Org_Id
            and date(f015.Created_On) = date(var_Date)
            and f015.MCC_Id = var_MCC_Id
            and year(f015.Created_On) = year(now())
            ORDER BY Date;
        end;
	elseif(var_Method_Name = 'GetPaymentPending') then
		begin
			if (var_Type = 'Farmer') then
            
				select 
				mu04.Farmer_Name as Name,
				mu04.Farmer_Code as Code,
				CONCAT(
				DATE_FORMAT(t027.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t027.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
				DATE_FORMAT(t027.Invoice_Date, '%d %M %Y') AS Date,
				Invoice_Amount as Amount 
				from t027_invoice_farmer t027
				inner join mu04_farmer mu04 on
				mu04.Org_Id = t027.Org_Id
				and mu04.Farmer_Id = t027.Farmer_Id
				where t027.Org_Id = var_Org_Id
				and t027.MCC_Id = var_MCC_Id
				and Date(t027.Invoice_Date) = date(var_Date)
				and t027.Is_IncomePosted = 0 
				AND t027.Is_DeductionPosted = 0

				UNION ALL
				 
				select 
				m005.MCC_Name as Name,
				m005.MCC_Code as Code,
				CONCAT(
				DATE_FORMAT(t027.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t027.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
				DATE_FORMAT(t027.Invoice_Date, '%d %M %Y') AS Date,
				Invoice_Amount as Amount 
				from t027_invoice_farmer t027
				inner join m005_mcc m005 on
				m005.Org_Id = t027.Org_Id
				and m005.MCC_Id = t027.MCC_Id
				and m005.MCC_Id = t027.Farmer_Id
				where t027.Org_Id = var_Org_Id
				and t027.MCC_Id = var_MCC_Id
				and Date(t027.Invoice_Date) = date(var_Date)
				and t027.Is_IncomePosted = 0 
				AND t027.Is_DeductionPosted = 0

				ORDER BY Name asc;
            
            elseif (var_Type = 'MCC') then
            
				select 
				m005.MCC_Name as Name,
				m005.MCC_Code as Code,
				CONCAT(
				DATE_FORMAT(t028.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t028.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
				DATE_FORMAT(t028.Invoice_Date, '%d %M %Y') AS Date,
				Invoice_Amount as Amount 
				from t028_invoice_mcc t028
				inner join m005_mcc m005 on
				m005.Org_Id = t028.Org_Id
				and m005.MCC_Id = t028.MCC_Id
				where t028.Org_Id = var_Org_Id
				and t028.MCC_Id = var_MCC_Id
				and Date(t028.Invoice_Date) = date(var_Date)
				and t028.Is_Posted = 0 
				ORDER BY Name asc;
            
            elseif (var_Type = 'Transporter') then
            
				select 
				m009.Transporter_Name as Name,
				m009.Transporter_Code as Code,
				CONCAT(
				DATE_FORMAT(t029.MusterCycle_StartDate, '%d'),
				' - ',
				DATE_FORMAT(t029.MusterCycle_EndDate, '%d')
				) AS MusterCycle,
				DATE_FORMAT(t029.Invoice_Date, '%d %M %Y') AS Date,
				Invoice_Amount as Amount 
				from t029_invoice_transpoter t029
				INNER JOIN m009_transporter m009 ON
				m009.Transporter_Id = t029.Transporter_Id 
				AND m009.Transporter_Id = t029.Org_Id
				where t029.Org_Id = var_Org_Id
				and t029.Transporter_Id = var_MCC_Id
				and Date(t029.Invoice_Date) = date(var_Date)
				and t029.Is_Posted = 0 

				ORDER BY Name asc;
            
            
			end if;
        
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
