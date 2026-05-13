-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerComplaint_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerComplaint_Set`(
	var_Method_Name varchar(60),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
    var_ComplaintType_Id varchar(20),
	var_Complaint_Remark longtext,
	var_Complaint_Date varchar(45),
    Var_Complaint_Id varchar(20),
    Var_Complaint_Status varchar(20),
    var_Farmer_Id varchar(30)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Complaint_Id varchar(20);
			Declare Year_Id varchar(10);
            
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('t016_complaint_header', Year_Id, 'T016', '', New_Complaint_Id );
            
				Insert Into t016_complaint_header
                (Org_Id, Complaint_Id,ComplaintType_Id,Complaint_Remark,
                Complaint_For,Complaint_For_User_Id,Complaint_By,Complaint_By_User_Id,Complaint_Date , ComplaintStatus_Id )
				Values (var_Org_Id, New_Complaint_Id,var_ComplaintType_Id,var_Complaint_Remark,
                'Farmer',var_Farmer_Id,'Agent',var_Profile_Id,@Current_Datetime , 'C035001'); 

				set @Entry_Id = '';
				Call USP_Number_Range ('t016_complaint_item', Year_Id, 'T0016', '', @Entry_Id );
                
                insert into t016_complaint_item (Org_Id , Complaint_Id , Entry_Id , Action_Date , Action_By_Id , Action_By_Name , 
                Remarks , Is_Display , New_Status_Id, Current_Status_Id ) value (
                var_Org_Id, New_Complaint_Id , @Entry_Id  , @Current_Datetime, var_Profile_Id ,( (select Farmer_Name from mu04_farmer where 
                Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id)), var_Complaint_Remark  , 1 , 'C035001' ,  'C035001' 
                );
                
                SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Complaint_Id AS Result_Extra_Key;
                
		end;
        
        elseif(var_Method_Name = 'Updatecomplaint') then 
        
				set @Year_Id = (select right(left(curdate(),4),(2)));
				set @Entry_Id = '';
				Call USP_Number_Range ('t016_complaint_item', @Year_Id, 'T0016', '', @Entry_Id );
                
			
				insert into t016_complaint_item (Org_Id , Complaint_Id , Entry_Id , Action_Date , Action_By_Id , Action_By_Name , 
                Remarks , Is_Display , New_Status_Id, Current_Status_Id ) 
                select Org_Id , Complaint_Id  , @Entry_Id  , @Current_Datetime, var_Profile_Id ,( (select Farmer_Name from mu04_farmer where 
                Org_Id = var_Org_Id and Farmer_Id = var_Farmer_Id)), var_Complaint_Remark  , 1 , New_Status_Id ,  Current_Status_Id 
                from t016_complaint_item where Org_Id = var_Org_Id and Complaint_Id  = Var_Complaint_Id order by 
                Action_Date desc limit 1 ;
        
				SELECT 1 AS Result_Id,  'Saved' AS Result_Description,  '' AS Result_Extra_Key;

                
		elseif (var_Method_Name = 'Update_complaint_status') then
        
			update t016_complaint_item t016i inner join t016_complaint_header t016 on  t016.Org_Id = t016i.Org_Id 
			and t016i.Complaint_Id = t016.Complaint_Id 
			set t016.ComplaintStatus_Id = Var_Complaint_Status,
			t016.Closing_Date = @Current_Datetime ,
			t016i.New_Status_Id = Var_Complaint_Status
			where t016i.Complaint_Id = Var_Complaint_Id and t016i.Org_Id = var_Org_Id;
			
			SELECT 1 AS Result_Id,  'Saved' AS Result_Description,  '' AS Result_Extra_Key;
                 
    end if;




END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
