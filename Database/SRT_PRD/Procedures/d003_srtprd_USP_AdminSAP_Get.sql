-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSAP_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSAP_Get`(
var_Method_Name varchar(255),
var_Org_Id varchar(255)
)
BEGIN
	if (var_Method_Name = 'Get_GRN') then  
		begin
			select 
			'PostInSAP' as method_name,
			t009.Org_Id as org_id,
			'' as api_end_point,
			1 as is_active,
			0 as is_deleted,
			'' as user_id,
			'' as destination_name,
			'' as user_name,
			t009.Batch_Id as batch_id,
			DATE_FORMAT(t009.Created_On, '%Y-%m-%dT%H:%i:%s') as search_period,
			t009.MilkCollectionPosting_Id as milkcollectiondairy_id,
			t009.Batch_Id as entry_id,
			t009.Batch_Id as tripdocument_id
			from t009_milkcollectiondairy_posting t009
			where t009.Org_Id = var_Org_Id 
            and t009.Is_Posted = 1;
        end;
	elseif (var_Method_Name = 'Get_CrateGRN') then  
		begin
            select
				'CratePostInSAP' as method_name,
				t038.Org_Id as org_id,
				'' as api_end_point,
				1 as is_active,
				0 as is_deleted,
				'' as  user_id,
				'' as  destination_name,
				'' as  user_name,
				t038.ReceivedCrate_Id as  batch_id,
				-- DATE_FORMAT(t038.Approved_On, '%Y-%m-%dT%H:%i:%s') as  search_period,
                DATE_FORMAT(t038.Created_On, '%Y-%m-%dT%H:%i:%s') as  search_period,
				t038i.Material_Id as dealer_id
			from t038_receivedcrate_header t038
            inner join t038_receivedcrate_item t038i on t038.Org_Id = t038i.Org_Id and t038.ReceivedCrate_Id = t038i.ReceivedCrate_Id
			where t038.Org_Id = var_Org_Id 
			and t038.Is_Approved = 1
			and t038i.Is_Posted = 1 and t038i.Good_Quantity > 0;
        end;
    elseif (var_Method_Name = 'Get_Farmer') then  
		begin
			select
			'Get_Voucher' as method_name ,
			t027.Org_Id as org_id ,
			'' as user_id ,
			'' as user_name ,
			'' as destination_name ,
			'' as is_active ,
			'' as is_deleted ,
			'' as api_end_point ,
			'' as created_on ,
			'' as farmer_name ,
			'' as mcc_name ,
			'' as milktype_name ,
			'' as quantity ,
			'' as quality ,
			'' as rate ,
			'' as amount ,
			'' as farmercollection_id ,
			'' as farmer_code ,
			'' as search_period ,
			'' as invoicedata ,
			'' as sap_document_id ,
			'' as sap_document_year ,
			t027.Voucher_Id as invoice_id ,
			'' as approvalstatus_id ,
			'' as mcc_id ,
			'' as mcctype_id 
			from t027_invoice_farmer t027
			where t027.Org_Id = var_Org_Id 
			and t027.Is_Posted = 1;
        end;
	elseif (var_Method_Name = 'Get_Farmer_Income') then  
		begin
			select
			'Get_Income_Header' as method_name ,
			t027.Org_Id as org_id ,
			'' as user_id ,
			'' as user_name ,
			'' as destination_name ,
			'' as is_active ,
			'' as is_deleted ,
			'' as api_end_point ,
			'' as created_on ,
			'' as farmer_name ,
			'' as mcc_name ,
			'' as milktype_name ,
			'' as quantity ,
			'' as quality ,
			'' as rate ,
			'' as amount ,
			'' as farmercollection_id ,
			'' as farmer_code ,
			'' as search_period ,
			'' as invoicedata ,
			'' as sap_document_id ,
			'' as sap_document_year ,
			t027.Voucher_Id as invoice_id ,
			t027.Is_IncomePosted as approvalstatus_id ,
			'' as mcc_id ,
			'' as mcctype_id 
			from t027_invoice_farmer t027
			where t027.Org_Id = var_Org_Id 
            and t027.Is_RateChange = 0
			and (t027.Is_IncomePosted = 1 or t027.Is_IncomePosted = 10) ;
		
        end;
	elseif (var_Method_Name = 'Get_Farmer_Income_SAPPosting') then  
		begin
			
			select
			'Get_Income_Header' as method_name ,
			t045.Org_Id as org_id ,
			'' as user_id ,
			'' as user_name ,
			'' as destination_name ,
			'' as is_active ,
			'' as is_deleted ,
			'' as api_end_point ,
			'' as created_on ,
			'' as farmer_name ,
			'' as mcc_name ,
			'' as milktype_name ,
			'' as quantity ,
			'' as quality ,
			'' as rate ,
			'' as amount ,
			'' as farmercollection_id ,
			'' as farmer_code ,
			'' as search_period ,
			'' as invoicedata ,
			'' as sap_document_id ,
			'' as sap_document_year ,
			t045.Voucher_Id as invoice_id ,
			t045.Is_Posted as approvalstatus_id ,
			'' as mcc_id ,
			'' as mcctype_id 
			from t045_sapposting t045
			where t045.Org_Id = var_Org_Id 
			and t045.Is_Posted = 1  ; 
			
		end;
	elseif (var_Method_Name = 'Get_Farmer_Income_SAPPostingDebit') then  
		begin
			
			select
			'Get_Income_Header' as method_name ,
			t046.Org_Id as org_id ,
			'' as user_id ,
			'' as user_name ,
			'' as destination_name ,
			'' as is_active ,
			'' as is_deleted ,
			'' as api_end_point ,
			'' as created_on ,
			'' as farmer_name ,
			'' as mcc_name ,
			'' as milktype_name ,
			'' as quantity ,
			'' as quality ,
			'' as rate ,
			'' as amount ,
			'' as farmercollection_id ,
			'' as farmer_code ,
			'' as search_period ,
			'' as invoicedata ,
			'' as sap_document_id ,
			'' as sap_document_year ,
			t046.Voucher_Id as invoice_id ,
			t046.Is_Posted as approvalstatus_id ,
			'' as mcc_id ,
			'' as mcctype_id 
			from t046_debitsapposting t046
			where t046.Org_Id = var_Org_Id 
			and t046.Is_Posted = 1  ; 
			
		end;
	elseif (var_Method_Name = 'Get_Rate_Change_Farmer_Income') then  
		begin
	
			select
			'Get_Rate_Change_Income_Header' as method_name ,
			t027.Org_Id as org_id ,
			'' as user_id ,
			'' as user_name ,
			'' as destination_name ,
			'' as is_active ,
			'' as is_deleted ,
			'' as api_end_point ,
			'' as created_on ,
			'' as farmer_name ,
			'' as mcc_name ,
			'' as milktype_name ,
			'' as quantity ,
			'' as quality ,
			'' as rate ,
			'' as amount ,
			'' as farmercollection_id ,
			'' as farmer_code ,
			'' as search_period ,
			'' as invoicedata ,
			'' as sap_document_id ,
			'' as sap_document_year ,
			t027.Voucher_Id as invoice_id ,
			t027.Is_IncomePosted as approvalstatus_id ,
			'' as mcc_id ,
			'' as mcctype_id 
			from t027_invoice_farmer t027
			where t027.Org_Id = var_Org_Id 
            and t027.Is_RateChange = 1
			and t027.Is_IncomePosted = 1;
		
        end;
	elseif (var_Method_Name = 'Get_Farmer_Deduction') then  
		begin
			
			select
			'Get_Voucher_Deductions' as method_name ,
			t027.Org_Id as org_id ,
			'' as user_id ,
			'' as user_name ,
			'' as destination_name ,
			'' as is_active ,
			'' as is_deleted ,
			'' as api_end_point ,
			'' as created_on ,
			'' as farmer_name ,
			'' as mcc_name ,
			'' as milktype_name ,
			'' as quantity ,
			'' as quality ,
			'' as rate ,
			'' as amount ,
			'' as farmercollection_id ,
			'' as farmer_code ,
			'' as search_period ,
			'' as invoicedata ,
			'' as sap_document_id ,
			'' as sap_document_year ,
			t027.Voucher_Id as invoice_id ,
			t027.Is_DeductionPosted as approvalstatus_id ,
			'' as mcc_id ,
			'' as mcctype_id 
			from t027_invoice_farmer t027
			where t027.Org_Id = var_Org_Id 
			and (t027.Is_DeductionPosted = 1 or t027.Is_DeductionPosted = 10);
        end;
    elseif (var_Method_Name = 'Get_MCC') then  
		begin
			select
			'Get_Voucher' as  method_name ,
			t028.Org_Id as  org_id ,
			'' as  user_id ,
			'' as  user_name ,
			'' as  destination_name ,
			'' as  is_active ,
			'' as  is_deleted ,
			'' as  api_end_point ,
			'' as  created_on ,
			'' as  farmer_name ,
			'' as  mcc_name ,
			'' as  milktype_name ,
			'' as  quantity ,
			'' as  quality ,
			'' as  rate ,
			'' as  amount ,
			'' as  farmercollection_id ,
			'' as  farmer_code ,
			'' as  search_period ,
			'' as  invoicedata ,
			'' as  sap_document_id ,
			'' as  sap_document_year ,
			t028.Voucher_Id as  invoice_id ,
			'' as  approvalstatus_id ,
			'' as  mcc_code ,
			'' as  mcc_id ,
			'' as  mcctype_id 
			from t028_invoice_mcc t028
			where t028.Org_Id = var_Org_Id 
			and t028.Is_Posted = 1;
            
        end;
	elseif (var_Method_Name = 'Get_MCC_Income') then  
		begin
			
			select
			'Get_Income_Header' as  method_name ,
			t028.Org_Id as  org_id ,
			'' as  user_id ,
			'' as  user_name ,
			'' as  destination_name ,
			'' as  is_active ,
			'' as  is_deleted ,
			'' as  api_end_point ,
			'' as  created_on ,
			'' as  farmer_name ,
			'' as  mcc_name ,
			'' as  milktype_name ,
			'' as  quantity ,
			'' as  quality ,
			'' as  rate ,
			'' as  amount ,
			'' as  farmercollection_id ,
			'' as  farmer_code ,
			'' as  search_period ,
			'' as  invoicedata ,
			'' as  sap_document_id ,
			'' as  sap_document_year ,
			t028.Voucher_Id as  invoice_id ,
			'' as  approvalstatus_id ,
			'' as  mcc_code ,
			'' as  mcc_id ,
			'' as  mcctype_id 
			from t028_invoice_mcc t028
			where t028.Org_Id = var_Org_Id 
			and t028.Is_Posted = 1
            and t028.MPPIType_Id = 'C047001';
            
        end;
	elseif (var_Method_Name = 'Get_MCC_Deduction') then  
		begin
       
			select
			'Get_Voucher_Deductions' as  method_name ,
			t028.Org_Id as  org_id ,
			'' as  user_id ,
			'' as  user_name ,
			'' as  destination_name ,
			'' as  is_active ,
			'' as  is_deleted ,
			'' as  api_end_point ,
			'' as  created_on ,
			'' as  farmer_name ,
			'' as  mcc_name ,
			'' as  milktype_name ,
			'' as  quantity ,
			'' as  quality ,
			'' as  rate ,
			'' as  amount ,
			'' as  farmercollection_id ,
			'' as  farmer_code ,
			'' as  search_period ,
			'' as  invoicedata ,
			'' as  sap_document_id ,
			'' as  sap_document_year ,
			t028.Voucher_Id as  invoice_id ,
			'' as  approvalstatus_id ,
			'' as  mcc_code ,
			'' as  mcc_id ,
			'' as  mcctype_id 
			from t028_invoice_mcc t028
			where t028.Org_Id = var_Org_Id 
			and t028.Is_Posted = 1
            and (t028.MPPIType_Id is null or t028.MPPIType_Id = '');
            
        end;
	elseif (var_Method_Name = 'Get_Voucher_GainLoss') then  
		begin
        
			select
			'Get_Voucher_GainLoss' as  method_name ,
			t028.Org_Id as  org_id ,
			'' as  user_id ,
			'' as  user_name ,
			'' as  destination_name ,
			'' as  is_active ,
			'' as  is_deleted ,
			'' as  api_end_point ,
			'' as  created_on ,
			'' as  farmer_name ,
			'' as  mcc_name ,
			'' as  milktype_name ,
			'' as  quantity ,
			'' as  quality ,
			'' as  rate ,
			'' as  amount ,
			'' as  farmercollection_id ,
			'' as  farmer_code ,
			'' as  search_period ,
			'' as  invoicedata ,
			'' as  sap_document_id ,
			'' as  sap_document_year ,
			t028.Voucher_Id as  invoice_id ,
			'' as  approvalstatus_id ,
			'' as  mcc_code ,
			'' as  mcc_id ,
			'' as  mcctype_id 
			from t028_invoice_mcc t028
			where t028.Org_Id = var_Org_Id 
			and t028.Is_Posted = 1
            and t028.MPPIType_Id = 'C047003';
            
        end;
    elseif (var_Method_Name = 'Get_Transpoter') then  
		begin
			select
			'Get_Voucher_IncomeDeductions' as  method_name ,
			t029.Org_Id as  org_id ,
			'' as  user_id ,
			'' as  user_name ,
			'' as  destination_name ,
			'' as  is_active ,
			'' as  is_deleted ,
			'' as  api_end_point ,
			'' as  created_on ,
			'' as  farmer_name ,
			'' as  mcc_name ,
			'' as  milktype_name ,
			'' as  quantity ,
			'' as  quality ,
			'' as  rate ,
			'' as  amount ,
			'' as  farmercollection_id ,
			'' as  farmer_code ,
			'' as  search_period ,
			'' as  invoicedata ,
			'' as  sap_document_id ,
			'' as  sap_document_year ,
			t029.Voucher_Id as  invoice_id ,
			'' as  approvalstatus_id ,
			'' as  mcc_code ,
			'' as  mcc_id ,
			'' as  transporter_code ,
			'' as  transporter_id ,
			'' as  transporter_name 
			from t029_invoice_transpoter t029
			where t029.Org_Id = var_Org_Id 
			and t029.Is_Posted = 1;
        end;
	elseif (var_Method_Name = 'Get_BPUpdate') then
		begin
			-- Do this activity only for Farmers of Online Centers
			select 'Farmer' as BPType, Farmer_Id as User_Id, Farmer_Code as SAP_Code, m4.Org_Id
            from mu04_farmer m4 inner join m005_mcc m5 on m4.Org_Id = m5.Org_Id and m4.MCC_Id = m5.MCC_Id
            and m5.MCCWorkType_Id = 'C023002'
            where m4.Is_Posted = 1
            and m4.Org_Id = var_Org_Id 
            union
            select 'MCC' as BPType, MCC_Id as User_Id, MCC_Code as SAP_Code, Org_Id
            from m005_mcc 
            where Is_Posted = 1
            and Org_Id = var_Org_Id 
            union
            select 'Transporter' as BPType, Transporter_Id as User_Id, Transporter_Code as SAP_Code, Org_Id
            from m009_transporter 
            where Is_Posted = 1
            and Org_Id = var_Org_Id ;
        end;
	elseif (var_Method_Name = 'Get_TDS') then
		begin
			select
			'Set_TDS' as method_name ,
            'Farmer' as type,
			t027.Org_Id as org_id ,
            MCC_Id as mcc_id,
			t027.Voucher_Id as voucher_id ,
			Income_SAP_Document_Id as income_sap_document_id ,
			Income_SAP_Document_Year as income_sap_document_year ,
			Deduction_SAP_Document_Id as deduction_sap_document_id ,
            Deduction_SAP_Document_Year as deduction_sap_document_year
			from t027_invoice_farmer t027
			where t027.Org_Id = var_Org_Id 
			and t027.Is_IncomePosted = 2 and Is_TDSDownloaded = 0 
            and (t027.Income_SAP_Document_Id <> 'DUMMYPOSTING' and t027.Income_SAP_Document_Id <> 'Manual')
            -- and (t027.Deduction_SAP_Document_Id <> 'DUMMYPOSTING' and t027.Deduction_SAP_Document_Id <> 'Manual')
            union all
            select
			'Set_TDS' as method_name ,
            'MCC' as type,
			t028.Org_Id as org_id ,
            MCC_Id as mcc_id,
			t028.Voucher_Id as voucher_id ,
			SAP_Document_Id as income_sap_document_id ,
			SAP_Document_Year as income_sap_document_year ,
			'' as deduction_sap_document_id ,
            '' as deduction_sap_document_year
			from t028_invoice_mcc t028
			where t028.Org_Id = var_Org_Id
            and t028.SAP_Document_Id <> 'DUMMYPOSTING' 
            and t028.SAP_Document_Id <> 'Manual'
			and t028.Is_Posted = 2 and Is_TDSDownloaded = 0 ;
        end;
	elseif (var_Method_Name = 'Get_TradingMaterialIssue') then
		begin
			select 
			'Get_SalesOrderHeader' as method_name ,
			t0231.Org_Id,
			t0231.Product_Id,
			t0231.Order_Id
			from t023_order_item t0231
            inner join t023_order_header t023 on
			t023.Org_Id = t0231.Org_Id
			and t023.Order_Id = t0231.Order_Id
			and t023.Is_Approved = 1
            and t023.Order_Type = 'Material'
			where t0231.Org_Id = var_Org_Id
			and t0231.Is_Posted = 1
			and t0231.Is_Deducted = 0;
        end;
	elseif (var_Method_Name = 'Get_Rebate') then  
		begin
			select
			'Get_Voucher' as  method_name ,
			t044.Org_Id as  org_id ,
			'' as  user_id ,
			'' as  user_name ,
			'' as  destination_name ,
			'' as  is_active ,
			'' as  is_deleted ,
			'' as  api_end_point ,
			'' as  created_on ,
			'' as  farmer_name ,
			'' as  mcc_name ,
			'' as  milktype_name ,
			'' as  quantity ,
			'' as  quality ,
			'' as  rate ,
			'' as  amount ,
			'' as  farmercollection_id ,
			'' as  farmer_code ,
			'' as  search_period ,
			'' as  invoicedata ,
			'' as  sap_document_id ,
			'' as  sap_document_year ,
			t044.Entry_Id as  invoice_id ,
			'' as  approvalstatus_id ,
			'' as  mcc_code ,
			'' as  mcc_id ,
			'' as  mcctype_id 
			from t044_rebate t044
			where t044.Org_Id = var_Org_Id 
			and t044.Is_Posted = 1;
        end;
	elseif (var_Method_Name = 'Get_DealerSalesArea') then  
		begin
			select 
            '' as method_name,
			Org_Id as org_id,
            Dealer_Id as dealer_id,
            Dealer_Code as dealer_code,
			'' as api_end_point,
			'' as user_id,
			'' as destination_name,
			'' as user_name,
            '' as dealerdata
            from mu08_dealer
            where Org_Id = var_Org_Id 
            and Is_Active = 1;
        end;
	elseif (var_Method_Name = 'Get_Dealer') then  
		begin
			
            select 
			Dealer_Code AS SoldToParty,
			CONCAT(DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 1 DAY), '%Y-%m-%d'), 'T00:00:00') AS BillingDocumentDate
			from mu08_dealer
			where Org_Id = var_Org_Id
            order by Dealer_Code;
            
        end;
	elseif (var_Method_Name = 'Get_RetailerOrder') then  
		begin
			
            SELECT Org_Id,RetailerOrder_Id
			FROM t034_retailerorder_header
			WHERE Org_Id = var_Org_Id
			and DATEDIFF(NOW(), Order_Date) > 7
			and ifnull(Is_Closed ,0) = 0;
            
        end;
	elseif (var_Method_Name = 'Get_Materials') then  
		begin
			
            DECLARE current_dates DATE;
            DECLARE start_date DATE;
			set start_date = '2024-02-01';
			-- set start_date = SELECT CURDATE() - INTERVAL 1 DAY;
			
			DROP TEMPORARY TABLE IF EXISTS TempDates;
			CREATE TEMPORARY TABLE TempDates (date_val DATE);
			
			SET current_dates = start_date;

			WHILE current_dates < CURDATE() DO
				INSERT INTO TempDates (date_val) VALUES (current_dates);
				SET current_dates = DATE_ADD(current_dates, INTERVAL 1 DAY);
			END WHILE;

		   
			SELECT 
			'Create' as method_name,
			DATE_FORMAT(date_val, '%Y-%m-%dT%H:%i:%s') AS formatted_date ,
			concat('',date_val,'') as Date,
			var_Org_Id as Org_Id
			FROM TempDates;
            
        end;
	elseif (var_Method_Name = 'Get_Billing_Document') then  
		begin
			
            DECLARE current_dates DATE;
            DECLARE start_date DATE;
			set start_date = '2025-03-01';
			-- set start_date = SELECT CURDATE() - INTERVAL 1 DAY;
			
			DROP TEMPORARY TABLE IF EXISTS TempDates;
			CREATE TEMPORARY TABLE TempDates (date_val DATE);
			
			SET current_dates = start_date;

			WHILE current_dates < CURDATE() DO
				INSERT INTO TempDates (date_val) VALUES (current_dates);
				SET current_dates = DATE_ADD(current_dates, INTERVAL 1 DAY);
			END WHILE;

		   
			SELECT 
			'Update_V2' as method_name,
			DATE_FORMAT(date_val, '%Y-%m-%dT%H:%i:%s') AS formatted_date ,
			concat('',date_val,'') as BillingDocumentDate,
			var_Org_Id as Org_Id
			FROM TempDates;
            
            /*
            select 
			Dealer_Code AS SoldToParty,
			CONCAT(DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 1 DAY), '%Y-%m-%d'), 'T00:00:00') AS BillingDocumentDate
			from mu08_dealer
			where Org_Id = var_Org_Id
            order by Dealer_Code;
            
            select 
			mu08.Dealer_Code AS SoldToParty,
			-- CONCAT(DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 1 DAY), '%Y-%m-%d'), 'T00:00:00') AS BillingDocumentDate
            DATE_FORMAT(date_val, '%Y-%m-%dT%H:%i:%s') AS formatted_date ,
			CONCAT(DATE_FORMAT(DATE_SUB(date_val, INTERVAL 1 DAY), '%Y-%m-%d'), 'T00:00:00') as BillingDocumentDate
			from mu08_dealer mu08
            left join TempDates t on mu08.Org_Id = var_Org_Id
			where mu08.Org_Id = var_Org_Id
            order by mu08.Dealer_Code;
            
            */
            
            
            
        end;
	elseif (var_Method_Name = 'Get_FleetX') then  
		begin
			SELECT Entry_Id,Org_Id, User_Id, Device_Id,Vehicle_No,ShopLatitude,ShopLongitude,User_Name,Route_Id
			FROM (
				SELECT  mu11.Org_Id, mu11.User_Id, mu11.Device_Id,m006.Vehicle_No,mu08.ShopLatitude,mu08.ShopLongitude,
                mu08.Dealer_Name as User_Name,
                m006i.Entry_Id,m006i.Route_Id
				FROM m006_fleetx_route m006
				INNER JOIN m006_fleetx_route_item m006i 
					ON m006.Org_Id = m006i.Org_Id AND m006.Route_Id = m006i.Route_Id
                    and m006i.Type = 'Dealer'
                    and m006i.Is_Notify = 0 
				INNER JOIN mu08_dealer mu08 
					ON mu08.Org_Id = m006i.Org_Id AND mu08.Dealer_Id = m006i.User_Id
				INNER JOIN mu11_user_deviceid mu11 
					ON mu11.Org_Id = m006i.Org_Id AND mu11.User_Id = mu08.Dealer_Id
				WHERE m006.Org_Id = var_Org_Id
				  AND m006.Is_Active = 1
				  AND DATE(m006.Created_On) = DATE(NOW())

				UNION ALL
                
                SELECT mu11.Org_Id, mu11.User_Id, mu11.Device_Id,m006.Vehicle_No,mu08.ShopLatitude,mu08.ShopLongitude,
                mu08.Dealer_Name as User_Name,
                m006i.Entry_Id,m006i.Route_Id
				FROM m006_fleetx_route m006
				INNER JOIN m006_fleetx_route_item m006i 
					ON m006.Org_Id = m006i.Org_Id AND m006.Route_Id = m006i.Route_Id
                    and m006i.Type = 'Dealer'
                    and m006i.Is_Notify = 0 
				INNER JOIN mu08_dealer mu08 
					ON mu08.Org_Id = m006i.Org_Id AND mu08.Dealer_Id = m006i.User_Id
				INNER JOIN mu11_user_deviceid mu11 
					ON mu11.Org_Id = m006i.Org_Id AND mu11.User_Id = mu08.Dealer_Id
				WHERE m006.Org_Id = var_Org_Id
				  AND m006.Is_Active = 1
				  AND DATE(m006.LastEdited_On) = DATE(NOW())
                
                UNION ALL
				
				SELECT mu11.Org_Id, mu11.User_Id, mu11.Device_Id,m006.Vehicle_No,mu08.ShopLatitude,mu08.ShopLongitude,
                mu08.Dealer_Name as User_Name,
                m006i.Entry_Id,m006i.Route_Id
				FROM m006_fleetx_route m006
				INNER JOIN m006_fleetx_route_item m006i 
					ON m006.Org_Id = m006i.Org_Id AND m006.Route_Id = m006i.Route_Id
                    and m006i.Type = 'Dealer'
                    and m006i.Is_Notify = 0 
				INNER JOIN mu08_dealer mu08 
					ON mu08.Org_Id = m006i.Org_Id AND mu08.Dealer_Id = m006i.User_Id
				INNER JOIN mu11_user_deviceid mu11 
					ON mu11.Org_Id = m006i.Org_Id AND mu11.User_Id = mu08.SalesUser_Id
				WHERE m006.Org_Id = var_Org_Id
				  AND m006.Is_Active = 1
				  AND DATE(m006.Created_On) = DATE(NOW())

				UNION ALL

				SELECT mu11.Org_Id, mu11.User_Id, mu11.Device_Id,m006.Vehicle_No,mu08.ShopLatitude,mu08.ShopLongitude,
                mu08.Dealer_Name as User_Name,
                m006i.Entry_Id,m006i.Route_Id
				FROM m006_fleetx_route m006
				INNER JOIN m006_fleetx_route_item m006i 
					ON m006.Org_Id = m006i.Org_Id AND m006.Route_Id = m006i.Route_Id
                    and m006i.Type = 'Dealer'
                    and m006i.Is_Notify = 0 
				INNER JOIN mu08_dealer mu08 
					ON mu08.Org_Id = m006i.Org_Id AND mu08.Dealer_Id = m006i.User_Id
				INNER JOIN mu11_user_deviceid mu11 
					ON mu11.Org_Id = m006i.Org_Id AND mu11.User_Id = mu08.SalesUser_Id
				WHERE m006.Org_Id = var_Org_Id
				  AND m006.Is_Active = 1
				  AND DATE(m006.LastEdited_On) = DATE(NOW())
                  
                  UNION ALL
				
				SELECT mu11.Org_Id, mu11.User_Id, mu11.Device_Id,m006.Vehicle_No,mu09.ShopLatitude,mu09.ShopLongitude,
                mu09.Retailer_Name as User_Name,
                m006i.Entry_Id,m006i.Route_Id
				FROM m006_fleetx_route m006
				INNER JOIN m006_fleetx_route_item m006i 
					ON m006.Org_Id = m006i.Org_Id AND m006.Route_Id = m006i.Route_Id
                    and m006i.Type = 'Retailer'
                    and m006i.Is_Notify = 0 
				INNER JOIN mu09_retailer mu09 
					ON mu09.Org_Id = m006i.Org_Id AND mu09.Retailer_Id = m006i.User_Id
				INNER JOIN mu11_user_deviceid mu11 
					ON mu11.Org_Id = m006i.Org_Id AND mu11.User_Id = mu09.SalesUser_Id
				WHERE m006.Org_Id = var_Org_Id
				  AND m006.Is_Active = 1
				  AND DATE(m006.Created_On) = DATE(NOW())

				UNION ALL

				SELECT mu11.Org_Id, mu11.User_Id, mu11.Device_Id,m006.Vehicle_No,mu09.ShopLatitude,mu09.ShopLongitude,
                mu09.Retailer_Name as User_Name,
                m006i.Entry_Id,m006i.Route_Id
				FROM m006_fleetx_route m006
				INNER JOIN m006_fleetx_route_item m006i 
					ON m006.Org_Id = m006i.Org_Id AND m006.Route_Id = m006i.Route_Id
                    and m006i.Type = 'Retailer'
                    and m006i.Is_Notify = 0 
				INNER JOIN mu09_retailer mu09 
					ON mu09.Org_Id = m006i.Org_Id AND mu09.Retailer_Id = m006i.User_Id
				INNER JOIN mu11_user_deviceid mu11 
					ON mu11.Org_Id = m006i.Org_Id AND mu11.User_Id = mu09.SalesUser_Id
				WHERE m006.Org_Id = var_Org_Id
				  AND m006.Is_Active = 1
				  AND DATE(m006.LastEdited_On) = DATE(NOW())
			) AS CombinedResults
			GROUP BY Entry_Id, Org_Id, User_Id, Device_Id,Vehicle_No,ShopLatitude,ShopLongitude,User_Name,Route_Id;
        end;
	elseif (var_Method_Name = 'Get_Dealer_Crate') then  
		begin
			select 
			'' as method_name,
			Org_Id as org_id,
            Dealer_Id as dealer_id,
            Dealer_Code as dealer_code,
			CONCAT(DATE('2024-01-31 00:00:00'), 'T00:00:00') as formattedstartdate,
			CONCAT(DATE(NOW()), 'T00:00:00') as formattedenddate,
            '' as method_name,
            '' as api_end_point,
			'' as user_id,
			'' as destination_name,
			'' as user_name,
            '' as dealerdata
			from mu08_dealer
			-- where Dealer_Code = '700000'
            ;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
