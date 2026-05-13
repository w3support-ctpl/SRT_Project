-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDieselUpload_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDieselUpload_Set`(
	var_Method_Name VARCHAR(255),
    var_Org_Id VARCHAR(20),
    var_DieselUpload_Id VARCHAR(45),
    var_File_Name LONGTEXT,
    var_DieselUpload_Data LONGTEXT,
    var_User_Id VARCHAR(45),
    var_User_Name VARCHAR(45)
)
BEGIN
SET SESSION sql_require_primary_key = 0;
SET SQL_SAFE_UPDATES=0;
	if (var_Method_Name = 'ExcelUpload') then  
		begin
        DECLARE k INT UNSIGNED DEFAULT 0;
		DECLARE row_count INT UNSIGNED;
		DECLARE xpath TEXT;
		Declare Year_Id varchar(10);
		Declare New_Entry_Id varchar(20);
        DECLARE New_DieselUpload_Id VARCHAR(45);
        DECLARE Set_Transporter_Id VARCHAR(45);
        DECLARE Set_Vehicle_Id VARCHAR(45);
		
		SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
		CALL USP_Number_Range ('l004_dieselupload', Year_Id, 'L004', '', New_DieselUpload_Id);
        
        
		INSERT INTO l004_dieselupload(
			Org_Id, DieselUpload_Id, File_Name, 
			Upload_Date, Upload_On,UploadBy_Id,UploadBy_Name
		)
		VALUES(
			var_Org_Id,New_DieselUpload_Id,var_File_Name,
            date(now()),now(),var_User_Id,var_User_Name
		);
        
        
        -- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_dieselupload;
			CREATE TEMPORARY TABLE temp_dieselupload (
				PKeyRowNum int, 
                Org_Id VARCHAR(20),
                Entry_Id VARCHAR(45),
                DieselUpload_Id VARCHAR(45),
                Transporter_Id VARCHAR(45),
                Vehicle_Id VARCHAR(45),
				Entry_Date DATETIME, 
				Quantity_Ltr DECIMAL(30,2),
                Status longtext
			);
            
            -- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_dieselupload_success;
			CREATE TEMPORARY TABLE temp_dieselupload_success (
				PKeyRowNum int, 
                Org_Id VARCHAR(20),
                Entry_Id VARCHAR(45),
                DieselUpload_Id VARCHAR(45),
                Transporter_Id VARCHAR(45),
                Vehicle_Id VARCHAR(45),
				Entry_Date DATETIME, 
				Quantity_Ltr DECIMAL(30,2)
			);
        
        SET row_count := extractValue(var_DieselUpload_Data,'count(//DieselUpload/DieselUploadItem)');
        
        
        WHILE k < row_count DO
			SET k := k + 1;
			SET xpath := concat('//DieselUpload/DieselUploadItem[', k, ']');
            set New_Entry_Id = '';
            set Set_Transporter_Id = '';
            set Set_Vehicle_Id = '';
            
            select Transporter_Id into Set_Transporter_Id 
			from m009_transporter where Org_Id = var_Org_Id
			and Transporter_Code = extractValue(var_DieselUpload_Data, concat(xpath,'/Transporter_Id'));
            
            if(Set_Transporter_Id is not null and Set_Transporter_Id <> '') then
            
			select Vehicle_Id into Set_Vehicle_Id 
			from m003_vehicle where Org_Id = var_Org_Id
			and Transporter_Id = Set_Transporter_Id
			and Vehicle_No = extractValue(var_DieselUpload_Data, concat(xpath,'/Vehicle_Id'));
            
				if(Set_Vehicle_Id is not null and Set_Vehicle_Id <> '') then
					Call USP_Number_Range ('t043_dieselupload', Year_Id, 'T034', '', New_Entry_Id );
            
					INSERT INTO temp_dieselupload VALUES (
							k,
							var_Org_Id,
							New_Entry_Id,
							New_DieselUpload_Id,
							extractValue(var_DieselUpload_Data, concat(xpath,'/Transporter_Id')),
							extractValue(var_DieselUpload_Data, concat(xpath,'/Vehicle_Id')),
							CAST(extractValue(var_DieselUpload_Data, concat(xpath,'/Entry_Date')) AS DATE),
							CAST(extractValue(var_DieselUpload_Data, concat(xpath,'/Quantity_Ltr')) AS DECIMAL(10,2)),
							'Success'
						);
                        
                        INSERT INTO temp_dieselupload_success VALUES (
							k,
							var_Org_Id,
							New_Entry_Id,
							New_DieselUpload_Id,
							Set_Transporter_Id,
							Set_Vehicle_Id,
							CAST(extractValue(var_DieselUpload_Data, concat(xpath,'/Entry_Date')) AS DATE),
							CAST(extractValue(var_DieselUpload_Data, concat(xpath,'/Quantity_Ltr')) AS DECIMAL(10,2))
						);
                else
						INSERT INTO temp_dieselupload VALUES (
							k,
							var_Org_Id,
							'',
							'',
							extractValue(var_DieselUpload_Data, concat(xpath,'/Transporter_Id')),
							extractValue(var_DieselUpload_Data, concat(xpath,'/Vehicle_Id')),
							CAST(extractValue(var_DieselUpload_Data, concat(xpath,'/Entry_Date')) AS DATE),
							CAST(extractValue(var_DieselUpload_Data, concat(xpath,'/Quantity_Ltr')) AS DECIMAL(10,2)),
							'Error'
						);
                end if;
				
            else
				INSERT INTO temp_dieselupload VALUES (
						k,
						var_Org_Id,
						'',
						'',
						extractValue(var_DieselUpload_Data, concat(xpath,'/Transporter_Id')),
						extractValue(var_DieselUpload_Data, concat(xpath,'/Vehicle_Id')),
						CAST(extractValue(var_DieselUpload_Data, concat(xpath,'/Entry_Date')) AS DATE),
						CAST(extractValue(var_DieselUpload_Data, concat(xpath,'/Quantity_Ltr')) AS DECIMAL(10,2)),
						'Error'
					);
            end if;
						
			
			
        END WHILE;
        
		
        INSERT INTO t043_dieselupload(
			Org_Id,Entry_Id, DieselUpload_Id, Transporter_Id,
			Vehicle_Id, Entry_Date,Quantity_Ltr
		)
		SELECT Org_Id,Entry_Id, DieselUpload_Id, Transporter_Id,
			Vehicle_Id, Entry_Date,Quantity_Ltr
		FROM temp_dieselupload_success; 
        
        set @Total_Count  = (select count(*) from temp_dieselupload);
        
        set @Success_Count  = (select count(*) from temp_dieselupload
								where  Status ='Success');
        
        set @Error_Count  = (select count(*) from temp_dieselupload
								where  Status ='Error');
        
   
        Update l004_dieselupload
		set 
		Success_Count = @Success_Count,
		Error_Count = @Error_Count, 
		Total_Count = @Total_Count
		where Org_Id = var_Org_Id and DieselUpload_Id = New_DieselUpload_Id;  
        
       
        /*
        DROP TEMPORARY TABLE IF EXISTS temp_rate_data;
		CREATE TEMPORARY TABLE temp_rate_data ( 
		Entry_Id varchar(20), DieselRate decimal(30,2), Max_Applicable_Date varchar(20));
        
        set sql_mode='';
        Insert into temp_rate_data (
		Entry_Id,DieselRate,Max_Applicable_Date
		)
		select Entry_Id, Quantity_Ltr,Entry_Date, max(DieselRate_Date),DieselRate from t043_dieselupload t043
		inner join t001_dieselrate t001 on
		t001.Org_Id = t043.Org_Id
		and date(t043.Entry_Date) > date(t001.DieselRate_Date)
		where Org_Id = var_Org_Id 
        and DieselUpload_Id = New_DieselUpload_Id
		group by Entry_Id, Quantity_Ltr,Entry_Date;
        
		Update t043_dieselupload t043
        inner join temp_rate_data temp on
        temp.Entry_Id = t043.Entry_Id
		set t043.Amount =  t043.Quantity_Ltr * temp.DieselRate
		where Org_Id = var_Org_Id and DieselUpload_Id = New_DieselUpload_Id; 
		*/
        SET SQL_SAFE_UPDATES=0;
		DROP TEMPORARY TABLE IF EXISTS temp_rate_data;
		CREATE TEMPORARY TABLE temp_rate_data ( 
        Id varchar(10) , Entry_Id varchar(20), DieselRate varchar(30) , Entry_Date varchar(40));
        
        
        set @Id = 0;
        
        insert into temp_rate_data (Id , Entry_Id , Entry_Date  )
		select @Id:= @Id+ 1 , Entry_Id , Entry_Date from t043_dieselupload 
        where Org_Id = var_Org_Id 
        and DieselUpload_Id = New_DieselUpload_Id;
        
       
			set @RowCount = (select count(*) from temp_rate_data );

			set @var_CursorTestID = 1;

		While @var_CursorTestID <= @RowCount Do
				
 
			set @Entry_Date = (select Entry_Date from  temp_rate_data where  Id = @var_CursorTestID ) ;
            
           set @DieselRate = ( select DieselRate from t001_dieselrate where date(DieselRate_Date) <= date(@Entry_Date) order by DieselRate_Date desc limit 1);
           
			update temp_rate_data
            set DieselRate = @DieselRate
            where id = @var_CursorTestID;
         
			Set @var_CursorTestID = @var_CursorTestID + 1;
        
        end while;
        
        Update t043_dieselupload t043
        inner join temp_rate_data temp on
        temp.Entry_Id = t043.Entry_Id
		set t043.Amount =  t043.Quantity_Ltr * temp.DieselRate
		where t043.Org_Id = var_Org_Id and t043.DieselUpload_Id = New_DieselUpload_Id; 
        
		select Transporter_Id,
		Vehicle_Id,DATE_FORMAT(Entry_Date, '%d %b %Y') AS Entry_Date,
		Quantity_Ltr,Status from temp_dieselupload;
         
		DROP TEMPORARY TABLE temp_dieselupload;
        DROP TEMPORARY TABLE temp_dieselupload_success;
            
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
        
			delete from l004_dieselupload
			where Org_Id = var_Org_Id and DieselUpload_Id = var_DieselUpload_Id;   
            
            delete from t043_dieselupload
			where Org_Id = var_Org_Id and DieselUpload_Id = var_DieselUpload_Id; 
            
            call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
			'l004_dieselupload', var_DieselUpload_Id, '', '', 
			var_User_Id, var_User_Name);
			
			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_DieselUpload_Id AS Result_Extra_Key;
            
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
