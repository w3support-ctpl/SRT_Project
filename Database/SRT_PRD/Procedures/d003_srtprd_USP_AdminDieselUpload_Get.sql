-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDieselUpload_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDieselUpload_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_DieselUpload_Id varchar(20),
    var_Date varchar(60)
)
BEGIN
SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Get') then  
		begin
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;

		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
        
        select 
        l004.DieselUpload_Id,
		DATE_FORMAT(l004.Upload_Date, '%d %b %Y') AS Upload_On,
		l004.File_Name,
		l004.Success_Count,
		l004.Error_Count,
		l004.Duplicate_Count,
		l004.Total_Count,
		ifnull(mu03.User_Id,'') as User_Id,
		ifnull(mu03.User_Name,'') as User_Name
		from l004_dieselupload  l004
		left join mu03_user mu03 on mu03.Org_Id = l004.Org_Id
		and mu03.User_Id = l004.UploadBy_Id
		where l004.Org_Id = var_Org_Id
		AND date(l004.Upload_Date) BETWEEN var_StartDate AND var_EndDate;
        
		end;
	elseif (var_Method_Name = 'Get_One') then  
		begin
			SELECT 
			m009.Transporter_Id,m009.Transporter_Name,m009.Transporter_Code,
			m003.Vehicle_Id,m003.Vehicle_No,
			DATE_FORMAT(t043.Entry_Date, '%d %b %Y') AS Entry_On,
			t043.Quantity_Ltr AS Quantity_Ltr,
            'Success' as Status
			FROM t043_dieselupload t043
			inner join m003_vehicle m003 on m003.Org_Id = t043.Org_Id
			and m003.Vehicle_Id = t043.Vehicle_Id
			inner join m009_transporter m009 on m009.Org_Id = t043.Org_Id
			and m009.Transporter_Id = t043.Transporter_Id
			where t043.Org_Id = var_Org_Id
			and t043.DieselUpload_Id = var_DieselUpload_Id;
		end;
	elseif (var_Method_Name = 'Get_Locked') then  
		begin
			select ifnull(Is_InvoiceCreated , 0) as Is_Locked  
            from t043_dieselupload where 
			Org_Id = var_Org_Id
			and DieselUpload_Id = var_DieselUpload_Id
			order by Is_InvoiceCreated desc
			limit 1;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
