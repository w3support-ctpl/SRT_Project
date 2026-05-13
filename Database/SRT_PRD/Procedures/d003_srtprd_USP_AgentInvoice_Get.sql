-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentInvoice_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentInvoice_Get`(
	var_Method_Name VARCHAR(20),
    var_Org_Id VARCHAR(10),
    var_MCC_Id Varchar(20),
    Var_Type varchar(20),
    var_Farmer_Id varchar(20),
    Var_Date varchar(50)
)
BEGIN

    if(var_Method_Name = 'GetMccInvoice' and Var_Type = 'MCC')then 
    
		
		SELECT Invoice_No ,
		DATE_FORMAT(Invoice_Date, '%d %b %Y') as Invoice_Date , 'MCC' Type , concat('VendorInvoices/MI', Org_Id, Invoice_No , '.pdf')  AS Pdf_Link
		from f013_mcc_invoice 
		where MCC_Id = var_MCC_Id and month(Invoice_Date) = month(Var_Date) and year(Invoice_Date) = year(Var_Date)
        and Is_InvoicePDFPublished = 1
        order by Invoice_Date desc; 


	elseif(var_Method_Name = 'GetFarmerInvoice' and Var_Type = 'Farmer')then 
	
		set @MCC_Id = (select MCC_Id from mu04_farmer 
						where Org_Id = var_Org_Id
						and Farmer_Id = var_Farmer_Id limit 1);
		SELECT Invoice_No , concat( MCC_Farmer_Code , '-' , b.Farmer_Name ) as Farmer_Name,
		DATE_FORMAT(Invoice_Date, '%d %b %Y') as Invoice_Date , 'Farmer' Type , concat('VendorInvoices/FI', a.Org_Id, Invoice_No , '.pdf')  AS Pdf_Link
		from f012_farmer_invoice a
        inner join mu04_farmer b on a.Farmer_Id = b.Farmer_Id and a.Org_Id = b.Org_Id and Is_InvoicePDFPublished = 1
        and month(Invoice_Date) = month(Var_Date) and year(Invoice_Date) = year(Var_Date)
        and a.MCC_Id = @MCC_Id  
        and a.Farmer_Id = var_Farmer_Id 
        order by Invoice_Date desc
        ;
        

        
        
	
    end if ;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
