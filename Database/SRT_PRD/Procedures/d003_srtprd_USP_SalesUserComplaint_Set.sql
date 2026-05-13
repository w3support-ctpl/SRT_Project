-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesUserComplaint_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesUserComplaint_Set`(
var_Method_Name varchar(50),
var_Org_Id varchar(10),
var_Complaint_Id varchar(20),
var_ComplaintType_Id varchar(20),
var_Complaint_Remark longtext,
var_Complaint_For varchar(20), 
var_Complaint_For_User_Id varchar(20), 
var_Complaint_By varchar(20),
var_Complaint_Date varchar(45),
var_ComplaintStatus_Id varchar(10),
var_Closing_Date varchar(45),
var_Profile_Id varchar(20),
var_Latitude varchar(45),
var_Longitude varchar(45),
var_Images longtext,
var_Product_Id varchar(20),
var_NotificationCodeGroup_Id varchar(255),
var_NotificationCode_Id varchar(255),
var_NotificationPriority_Id varchar(255),
var_QualityNotification varchar(255)
)
BEGIN
       set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
       IF(var_Method_Name = 'Create') then
		Begin
				Declare Duplicate_Flag int;
				Declare New_Complaint_Id varchar(20);
				Declare Year_Id varchar(10);
                DECLARE k INT UNSIGNED DEFAULT 0;
				DECLARE row_count INT UNSIGNED;
				DECLARE xpath TEXT;
            
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('t037_sales_complaint_header', Year_Id, 'T037', '', New_Complaint_Id );
                
                insert into t037_sales_complaint_header(Org_Id, Complaint_Id, ComplaintType_Id, Complaint_Remark, Complaint_For, Complaint_For_User_Id, Complaint_By, Complaint_By_User_Id, Complaint_Date, ComplaintStatus_Id,
                Latitude,Longitude,Product_Id,
                NotificationCodeGroup_Id,NotificationCode_Id,NotificationPriority_Id)
                values(var_Org_Id, New_Complaint_Id, var_ComplaintType_Id, var_Complaint_Remark, var_Complaint_For, var_Complaint_For_User_Id, var_Complaint_By, var_Profile_Id,@Current_Datetime , 'C035001',
                var_Latitude,var_Longitude,var_Product_Id,
                var_NotificationCodeGroup_Id,var_NotificationCode_Id,var_NotificationPriority_Id);
                
                set @Entry_Id = '';
				Call USP_Number_Range ('t037_sales_complaint_item', Year_Id, 'T037', '', @Entry_Id );
                
                
                insert into t037_sales_complaint_item (Org_Id , Complaint_Id , Entry_Id , Action_Date , Action_By_Id , Action_By_Name , Remarks , Is_Display , New_Status_Id, Current_Status_Id ) 
                value (var_Org_Id, New_Complaint_Id , @Entry_Id  , @Current_Datetime, var_Profile_Id ,var_Profile_Id, var_Complaint_Remark  , 1 , 'C035001' ,  'C035001');
				
                SET row_count := extractValue(var_Images,'count(//Images/Image)');
				WHILE k < row_count DO
					SET k := k + 1;
					SET xpath := concat('//Images/Image[', k, ']');
					
					
					CALL USP_Number_Range ('t037_sales_complaint_images', Year_Id, 'T037', '', @var_Entry_Id );
					-- Insert new record
					INSERT INTO t037_sales_complaint_images (Org_Id, Entry_Id, Complaint_Id, Photo)
					VALUES (var_Org_Id, @var_Entry_Id,New_Complaint_Id, extractValue(var_Images, concat(xpath,'/Image_Url')));
				
				END WHILE;
            
				SELECT 1 AS Result_Id,'Saved' AS Result_Description,New_Complaint_Id AS Result_Extra_Key;
        End;	
        
        
                elseif(var_Method_Name = 'Updatecomplaint') then 
        
				set @Year_Id = (select right(left(curdate(),4),(2)));
				set @Entry_Id = '';
				Call USP_Number_Range ('t037_sales_complaint_item', @Year_Id, 'T037', '', @Entry_Id );
                
			
				insert into t037_sales_complaint_item (Org_Id , Complaint_Id , Entry_Id , Action_Date , Action_By_Id , Action_By_Name , 
                Remarks , Is_Display , New_Status_Id, Current_Status_Id ) 
                select Org_Id , Complaint_Id  , @Entry_Id  , @Current_Datetime, var_Profile_Id ,var_Profile_Id, var_Complaint_Remark  , 1 , New_Status_Id ,  Current_Status_Id 
                from t037_sales_complaint_item where Org_Id = var_Org_Id and Complaint_Id  = Var_Complaint_Id order by 
                Action_Date desc limit 1 ;
        
				SELECT 1 AS Result_Id,  'Saved' AS Result_Description,  '' AS Result_Extra_Key;

                
		elseif (var_Method_Name = 'Update_complaint_status') then
        
			update t037_sales_complaint_item t037i inner join t037_sales_complaint_header t037 on  t037.Org_Id = t037i.Org_Id 
			and t037i.Complaint_Id = t037.Complaint_Id 
			set t037.ComplaintStatus_Id = Var_Complaint_Status,
			t037.Closing_Date = @Current_Datetime ,
			t037i.New_Status_Id = Var_Complaint_Status
			where t037i.Complaint_Id = Var_Complaint_Id and t037i.Org_Id = var_Org_Id;
			
			SELECT 1 AS Result_Id,  'Saved' AS Result_Description,  '' AS Result_Extra_Key;
            
		
        elseif (var_Method_Name = 'SaveNotification') then
        
			update t037_sales_complaint_header  
			set QualityNotification = var_QualityNotification
			where Complaint_Id = Var_Complaint_Id and Org_Id = var_Org_Id;
			
			SELECT 1 AS Result_Id,  'Saved' AS Result_Description,  '' AS Result_Extra_Key;
                 
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
