-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminInvoicePublish_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminInvoicePublish_Get`(
	var_Method_Name varchar(255),
	var_Org_Id varchar(10),
	var_User_Id varchar(20),
	var_Date varchar(60),
    var_VoucherType_Id  varchar(60),
    var_MCC_Id varchar(20),
    var_MCCType_Id varchar(20),
    var_MCCWorkType_Id varchar(20),
    var_Invoice_Id longtext
    )
BEGIN
	if (var_Method_Name = 'Get' and var_VoucherType_Id = 'Agent') then  
		begin
        
        /*
        DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;

		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
		select 
        t028.Voucher_Id as Invoice_Id,
		DATE_FORMAT(t028.Invoice_Date, '%d %b %Y') AS Invoice_Date,
		m005.MCC_Id as Farmer_Id,
		m005.MCC_Name as Farmer_Name,m005.MCC_Code as Farmer_Code,
		m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
		ifnull(c014.MCCType_Id,'')  as MCCType_Id,
		ifnull(c014.MCCType_Name,'')  as MCCType_Name,
		ifnull(f013.Invoice_No,'')  as Invoice_No,
		CONCAT(
		DATE_FORMAT(f013.MusterCycle_StartDate, '%d %b %Y'),
		' - ',
		DATE_FORMAT(f013.MusterCycle_EndDate, '%d %b %Y')
		) AS MusterCycle,
		ifnull(f013.NetPayable_Amount,'')  as Amount,
		DATE_FORMAT(f013.Created_On, '%d %b %Y') AS Generated_Date,
		t028.Is_InvoicePDFPublished as Is_Published
		from f013_mcc_invoice f013
		inner join t028_invoice_mcc t028 on
		t028.Org_Id = f013.Org_Id
		and t028.Invoice_No = f013.Invoice_No
        and t028.Voucher_Id  = t028.Primary_Voucher_Id
        and CAST(t028.Invoice_Date  AS DATE) >= var_StartDate 
		and CAST(t028.Invoice_Date  AS DATE)  <= var_EndDate
		inner join m005_mcc m005 on
		m005.Org_Id = f013.Org_Id
		and m005.MCC_Id = f013.MCC_Id
        and m005.MCCType_Id like var_MCCType_Id
		and m005.MCC_Id like var_MCC_Id
		inner join c014_mcctype c014 on
		m005.MCCType_Id = c014.MCCType_Id
		where f013.Org_Id =var_Org_Id
        order by m005.MCC_Name asc;
		*/
        
        select 
		f013.Invoice_Id as Invoice_Id,
		DATE_FORMAT(f013.Invoice_Date, '%d %b %Y') AS Invoice_Date,
		m005.MCC_Id as Farmer_Id,
		m005.MCC_Name as Farmer_Name,m005.MCC_Code as Farmer_Code,
		m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
		ifnull(c014.MCCType_Id,'')  as MCCType_Id,
		ifnull(c014.MCCType_Name,'')  as MCCType_Name,
		ifnull(f013.Invoice_No,'')  as Invoice_No,
		CONCAT(
		DATE_FORMAT(f013.MusterCycle_StartDate, '%d %b %Y'),
		' - ',
		DATE_FORMAT(f013.MusterCycle_EndDate, '%d %b %Y')
		) AS MusterCycle,
		ifnull(f013.NetPayable_Amount,'')  as Amount,
		DATE_FORMAT(f013.Created_On, '%d %b %Y') AS Generated_Date,
        f013.Is_InvoicePDFPublished as Is_Published
		from m005_mcc m005
		inner join c014_mcctype c014 on
		c014.MCCType_Id = m005.MCCType_Id
		inner join c023_mccworktype c023 on
		c023.MCCWorkType_Id = m005.MCCWorkType_Id
		inner join f013_mcc_invoice f013 on
		f013.Org_Id = m005.Org_Id
		and f013.MCC_Id = m005.MCC_Id
		and date(f013.Invoice_Date) = date(var_Date)
		where m005.Org_Id = var_Org_Id
		and m005.MCC_Id like var_MCC_Id
		and m005.MCCType_Id like var_MCCType_Id
		and m005.MCCWorkType_Id like  var_MCCWorkType_Id;
        end;
	elseif (var_Method_Name = 'Download' and var_VoucherType_Id = 'Agent') then
		begin
		Declare var_Destination_Name varchar(20);
		Declare var_BaseURL varchar(200);
        
        set var_Destination_Name = (select Destination_Name from c001_organization where Org_id = var_Org_Id);
		
        if (var_Destination_Name = 'PRD') then
			set var_BaseURL = 'https://appdoc.srthoratmilk.in/';
		else 
			set var_BaseURL = 'https://uatdoc.srthoratmilk.in/';
		end if;
        
        /*
        select concat('MI', Org_Id, Invoice_No ,'.pdf') as Invoice_Link ,
        concat(mu04.Farmer_Name, ' ', DATE_FORMAT(t027.MusterCycle_StartDate, '%d %b %Y') ,' - ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d %b %Y')) as Farmer_Name
        from t028_invoice_mcc
        where Org_Id = var_Org_Id 
        */
        /*
        select concat('MI', t028.Org_Id, t028.Invoice_No ,'.pdf') as Invoice_Link ,
        concat(m005.MCC_Name, ' ', DATE_FORMAT(t028.MusterCycle_StartDate, '%d %b %Y') ,' - ', DATE_FORMAT(t028.MusterCycle_EndDate, '%d %b %Y')) as Farmer_Name
        from t028_invoice_mcc t028
        inner join m005_mcc m005 on
        m005.Org_Id = t028.Org_Id
        and m005.MCC_Id = t028.MCC_Id
        where t028.Org_Id = var_Org_Id 
		and FIND_IN_SET(t028.Voucher_Id, var_Invoice_Id) > 0;
        */
        select concat('MI', t028.Org_Id, t028.Invoice_No ,'.pdf') as Invoice_Link ,
        concat(m005.MCC_Name, ' ', DATE_FORMAT(t028.MusterCycle_StartDate, '%d %b %Y') ,' - ', DATE_FORMAT(t028.MusterCycle_EndDate, '%d %b %Y')) as Farmer_Name
        from f013_mcc_invoice t028
        inner join m005_mcc m005 on
        m005.Org_Id = t028.Org_Id
        and m005.MCC_Id = t028.MCC_Id
        where t028.Org_Id = var_Org_Id 
		and FIND_IN_SET(t028.Invoice_Id, var_Invoice_Id) > 0;
        end;
	elseif (var_Method_Name = 'Get' and var_VoucherType_Id = 'Farmer') then
		begin
        
        /*
        DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;

		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
         
		select 
        t027.Voucher_Id as Invoice_Id,
		DATE_FORMAT(t027.Invoice_Date, '%d %b %Y') AS Invoice_Date,
		mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
		m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
		ifnull(c014.MCCType_Id,'')  as MCCType_Id,
		ifnull(c014.MCCType_Name,'')  as MCCType_Name,
		ifnull(f012.Invoice_No,'')  as Invoice_No,
		CONCAT(
		DATE_FORMAT(f012.MusterCycle_StartDate, '%d %b %Y'),
		' - ',
		DATE_FORMAT(f012.MusterCycle_EndDate, '%d %b %Y')
		) AS MusterCycle,
		ifnull(f012.NetPayable_Amount,'')  as Amount,
		DATE_FORMAT(f012.Created_On, '%d %b %Y') AS Generated_Date,
		t027.Is_InvoicePDFPublished as Is_Published
		from f012_farmer_invoice f012
		inner join t027_invoice_farmer t027 on
		t027.Org_Id = f012.Org_Id
		and t027.Invoice_No = f012.Invoice_No
        and CAST(t027.Invoice_Date  AS DATE) >= var_StartDate 
		and CAST(t027.Invoice_Date  AS DATE)  <= var_EndDate
		inner join mu04_farmer mu04 on
		mu04.Org_Id = f012.Org_Id
		and mu04.Farmer_Id = f012.Farmer_Id
		inner join m005_mcc m005 on
		m005.Org_Id = f012.Org_Id
		and m005.MCC_Id = f012.MCC_Id
        and m005.MCCType_Id like var_MCCType_Id
		and m005.MCC_Id like var_MCC_Id
		inner join c014_mcctype c014 on
		m005.MCCType_Id = c014.MCCType_Id
		where f012.Org_Id = var_Org_Id
        order by mu04.Farmer_Name asc,m005.MCC_Name asc;
        */
        
        select 
		f012.Invoice_Id as Invoice_Id,
		DATE_FORMAT(f012.Invoice_Date, '%d %b %Y') AS Invoice_Date,
		mu04.Farmer_Id,mu04.Farmer_Name,mu04.Farmer_Code,
		m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
		ifnull(c014.MCCType_Id,'')  as MCCType_Id,
		ifnull(c014.MCCType_Name,'')  as MCCType_Name,
		ifnull(f012.Invoice_No,'')  as Invoice_No,
		CONCAT(
		DATE_FORMAT(f012.MusterCycle_StartDate, '%d %b %Y'),
		' - ',
		DATE_FORMAT(f012.MusterCycle_EndDate, '%d %b %Y')
		) AS MusterCycle,
		ifnull(f012.NetPayable_Amount,'')  as Amount,
		DATE_FORMAT(f012.Created_On, '%d %b %Y') AS Generated_Date,
        f012.Is_InvoicePDFPublished as Is_Published
		from m005_mcc m005
		inner join c014_mcctype c014 on
		c014.MCCType_Id = m005.MCCType_Id
		inner join c023_mccworktype c023 on
		c023.MCCWorkType_Id = m005.MCCWorkType_Id
		inner join f012_farmer_invoice f012 on
		f012.Org_Id = m005.Org_Id
		and f012.MCC_Id = m005.MCC_Id
		and date(f012.Invoice_Date) = date(var_Date)
		inner join mu04_farmer mu04 on
		mu04.Org_Id = f012.Org_Id
		and mu04.Farmer_Id = f012.Farmer_Id
		where m005.Org_Id = var_Org_Id
		and m005.MCC_Id like var_MCC_Id
		and m005.MCCType_Id like var_MCCType_Id
		and m005.MCCWorkType_Id like  var_MCCWorkType_Id;
        
        end;
	elseif (var_Method_Name = 'Download' and var_VoucherType_Id = 'Farmer') then
		begin
		Declare var_Destination_Name varchar(20);
		Declare var_BaseURL varchar(200);
        
        set var_Destination_Name = (select Destination_Name from c001_organization where Org_id = var_Org_Id);
		
        if (var_Destination_Name = 'PRD') then
			set var_BaseURL = 'https://appdoc.srthoratmilk.in/';
		else 
			set var_BaseURL = 'https://uatdoc.srthoratmilk.in/';
		end if;
        
        /*
        select concat('FI', t027.Org_Id, t027.Invoice_No ,'.pdf') as Invoice_Link ,
        concat(mu04.Farmer_Name, ' ', DATE_FORMAT(t027.MusterCycle_StartDate, '%d %b %Y') ,' - ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d %b %Y')) as Farmer_Name
        from t027_invoice_farmer t027
        inner join mu04_farmer mu04 on
        mu04.Org_Id = t027.Org_Id
        and mu04.Farmer_Id = t027.Farmer_Id
        where t027.Org_Id = var_Org_Id 
		and FIND_IN_SET(t027.Voucher_Id, var_Invoice_Id) > 0;
        */
        
		select concat('FI', t027.Org_Id, t027.Invoice_No ,'.pdf') as Invoice_Link ,
        concat(mu04.Farmer_Name, ' ', DATE_FORMAT(t027.MusterCycle_StartDate, '%d %b %Y') ,' - ', DATE_FORMAT(t027.MusterCycle_EndDate, '%d %b %Y')) as Farmer_Name
        from f012_farmer_invoice t027
        inner join mu04_farmer mu04 on
        mu04.Org_Id = t027.Org_Id
        and mu04.Farmer_Id = t027.Farmer_Id
        where t027.Org_Id = var_Org_Id
		and FIND_IN_SET(t027.Invoice_Id, var_Invoice_Id) > 0;
        end;
	elseif (var_Method_Name = 'Get' and var_VoucherType_Id = 'Transporter') then
		select 1;
    elseif (var_Method_Name = 'Get_MCC' and var_VoucherType_Id = 'Farmer') then  
		begin
            select 
			m005.MCC_Id, m005.MCC_Name, m005.MCC_Code ,
			c014.MCCType_Id, c014.MCCType_Name,
			c023.MCCWorkType_Id, c023.MCCWorkType_Name
			from m005_mcc m005
			inner join c014_mcctype c014 on
			c014.MCCType_Id = m005.MCCType_Id
			inner join c023_mccworktype c023 on
			c023.MCCWorkType_Id = m005.MCCWorkType_Id
            inner join t027_invoice_farmer t027 on
			t027.Org_Id = m005.Org_Id
            and t027.MCC_Id = m005.MCC_Id
            and date(t027.Invoice_Date) = date(var_Date)
			where m005.Org_Id = var_Org_Id
			and m005.MCC_Id like var_MCC_Id
			and m005.MCCType_Id like var_MCCType_Id
			and m005.MCCWorkType_Id like var_MCCWorkType_Id
            group by m005.MCC_Id, m005.MCC_Name, m005.MCC_Code ,
			c014.MCCType_Id, c014.MCCType_Name,
			c023.MCCWorkType_Id, c023.MCCWorkType_Name;
            
        end;
	elseif (var_Method_Name = 'Get_MCC' and var_VoucherType_Id = 'Agent') then  
		begin
            select 
			m005.MCC_Id, m005.MCC_Name, m005.MCC_Code ,
			c014.MCCType_Id, c014.MCCType_Name,
			c023.MCCWorkType_Id, c023.MCCWorkType_Name
			from m005_mcc m005
			inner join c014_mcctype c014 on
			c014.MCCType_Id = m005.MCCType_Id
			inner join c023_mccworktype c023 on
			c023.MCCWorkType_Id = m005.MCCWorkType_Id
            inner join t028_invoice_mcc t028 on
			t028.Org_Id = m005.Org_Id
            and t028.MCC_Id = m005.MCC_Id
            and date(t028.Invoice_Date) = date(var_Date)
			where m005.Org_Id = var_Org_Id
			and m005.MCC_Id like var_MCC_Id
			and m005.MCCType_Id like var_MCCType_Id
			and m005.MCCWorkType_Id like var_MCCWorkType_Id
            group by m005.MCC_Id, m005.MCC_Name, m005.MCC_Code ,
			c014.MCCType_Id, c014.MCCType_Name,
			c023.MCCWorkType_Id, c023.MCCWorkType_Name;
            
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
