-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerProfileData_Correction` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerProfileData_Correction`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
	var_Profile_Id varchar(20),
    Var_Mobile_Number varchar(10),
    Var_MCC_Id varchar(20),
    Var_Request_Type varchar(30),
    Var_Request_Data text,
    Var_XMLData longtext
    
)
BEGIN

  set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
  
  if (var_Method_Name = 'ChangeDetails') then
	
    IF exists (SELECT 1 FROM t026_datacorrection_request WHERE Org_Id = var_Org_Id AND Request_For_User_Id = var_Profile_Id 
    AND  Is_Approved = 0 and Request_Type =  Var_Request_Type  ) THEN 
    
            select -1 as Result_Id, 
			'Already Pending' as Result_Description,
			'' as Result_Extra_Key ;
    
    else 
		set @Year_Id = (select right(left(curdate(),4),(2)));
		Call USP_Number_Range ('t026_datacorrection_request', @Year_Id, 'T026', '', @Request_Id);
        
        set @MCC_Id = (select MCC_Id from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id );

        insert into t026_datacorrection_request(Org_Id,Request_Id, MCC_Id , Request_For , Request_For_User_Id,
        Request_By,Request_By_User_Id,Request_Type,Request_Data,Request_Date,Is_Approved
        ) values 
        (var_Org_Id , @Request_Id , @MCC_Id , 'Farmer' , var_Profile_Id , 'Farmer' , var_Profile_Id , Var_Request_Type , Var_Request_Data,
        @Current_Datetime , 0
        );
        
            select 1 as Result_Id, 
			'Applied' as Result_Description,
			'' as Result_Extra_Key ;
            
	end if;
    
    elseif (var_Method_Name = 'GetStatus') then
    
        IF exists (SELECT 1 FROM t026_datacorrection_request WHERE Org_Id = var_Org_Id AND Request_For_User_Id = var_Profile_Id 
    AND  Is_Approved = 0 and Request_Type =  Var_Request_Type   ) THEN 

		SET @Request_Data = (SELECT Request_Data FROM t026_datacorrection_request WHERE Org_Id = var_Org_Id AND Request_For_User_Id = var_Profile_Id 
    AND  Is_Approved = 0 and Request_Type =  Var_Request_Type ORDER BY Request_Id DESC LIMIT 1);

            select -1 as Result_Id, 
			'Already Pending' as Result_Description,
			@Request_Data as Result_Extra_Key ;
    
    else
			select 1 as Result_Id, 
			'' as Result_Description,
			'' as Result_Extra_Key ;
                
                	end if;
	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
