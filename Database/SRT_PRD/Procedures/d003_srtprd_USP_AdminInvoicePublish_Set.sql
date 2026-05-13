-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminInvoicePublish_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminInvoicePublish_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_Invoice_Id longtext,
    var_VoucherType_Id  varchar(60),
    var_Date varchar(60),
    var_User_Id varchar(20),
	var_User_Name varchar(45)
)
BEGIN
	SET SQL_SAFE_UPDATES = 0;
	if (var_Method_Name = 'MCCGenerate' and var_VoucherType_Id = 'Agent') then  
		begin
        
			delete from f013_mcc_invoice 
			where Org_Id = var_Org_Id
			and date(Invoice_Date) = date(var_Date)
			and FIND_IN_SET(MCC_Id, var_Invoice_Id) > 0;

			Update t028_invoice_mcc
			set 
            Is_InvoicePDFGenerated = 1
			where Org_Id = var_Org_Id 
            and date(Invoice_Date) = date(var_Date)
            -- and Is_InvoicePDFGenerated = 0
			and FIND_IN_SET(MCC_Id, var_Invoice_Id) > 0;
            
            SELECT 1 AS Result_Id, 
			'Generate' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
		end;
	elseif (var_Method_Name = 'MCCPublish' and var_VoucherType_Id = 'Agent') then
		begin
			Update f013_mcc_invoice
			set 
            Is_InvoicePDFPublished = 1
			where Org_Id = var_Org_Id 
            and date(Invoice_Date) = date(var_Date)
            -- and Is_InvoicePDFPublished = 0
			and FIND_IN_SET(MCC_Id, var_Invoice_Id) > 0;
            
            SELECT 1 AS Result_Id, 
			'Publish' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'MCCGenerate' and var_VoucherType_Id = 'Farmer') then
		begin
			delete from f012_farmer_invoice 
			where Org_Id = var_Org_Id
			and date(Invoice_Date) = date(var_Date)
			and FIND_IN_SET(MCC_Id, var_Invoice_Id) > 0;
            
			Update t027_invoice_farmer
			set 
            Is_InvoicePDFGenerated = 1
			where Org_Id = var_Org_Id 
            and date(Invoice_Date) = date(var_Date)
            -- and Is_InvoicePDFGenerated = 0
			and FIND_IN_SET(MCC_Id, var_Invoice_Id) > 0;
            
            SELECT 1 AS Result_Id, 
			'Generate' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
        end;
    elseif (var_Method_Name = 'MCCPublish' and var_VoucherType_Id = 'Farmer') then
		begin
			Update f012_farmer_invoice
			set 
            Is_InvoicePDFPublished = 1
			where Org_Id = var_Org_Id 
            and date(Invoice_Date) = date(var_Date)
            -- and Is_InvoicePDFPublished = 0
			and FIND_IN_SET(MCC_Id, var_Invoice_Id) > 0;
            
            SELECT 1 AS Result_Id, 
			'Publish' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
        end;
    elseif (var_Method_Name = 'Get' and var_VoucherType_Id = 'Transporter') then
		begin 
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
