-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerSign_In` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerSign_In`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_Mobile_No varchar(12),
    var_Password varchar(50),
    var_Profile_Id varchar(20),
    var_Device_Id text,
    var_make_model text,
    var_android_version text
)
BEGIN
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	if(var_Method_Name = 'SignIn') then
    
	
    if exists (select 1 from mu04_farmer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and BINARY Login_Password =  var_Password  ) then
		
        set var_Profile_Id = ( SELECT Farmer_Id from  mu04_farmer mu04 where mu04.Org_Id = var_Org_Id and mu04.Mobile_No = var_Mobile_No and BINARY  Login_Password =  var_Password  );
	
                
			set @MCC_Id = (select MCC_Id from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id );

			set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = @MCC_Id and is_deleted = 0 and 
			Applicable_Date <= @Current_Datetime
			order by Applicable_Date desc limit 1 ) ;
				
			Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
                
                SELECT if(mu04.Is_Active = 1 , 1, if(mu04.Is_Active = 0 , -1 , 1)) as Is_Approved , Farmer_Id AS Farmer_Id , ifnull(Farmer_Name ,'') as Farmer_Name , if(ifnull(MCC_Name,'') = '' , 'MCC Not Assigned' , MCC_Name) as Collection_Centre_Name , ifnull(mu04.Profile_Photo,'') as Profile_Photo , 
				Is_PasswordReset as Is_Password_Reset ,  ifnull(@MusterType,7) as  MusterType
                from  mu04_farmer mu04 left join m005_mcc m005 on m005.Org_Id= mu04.Org_Id and m005.MCC_Id = mu04.MCC_Id
                where mu04.Org_Id = var_Org_Id and mu04.Farmer_Id = var_Profile_Id ;

	
    elseif exists (SELECT Farmer_Id from  t002_farmerregistration  where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and BINARY Password =  var_Password) then
    
    set var_Profile_Id = ( SELECT Farmer_Id from  t002_farmerregistration  where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and BINARY Password =  var_Password LIMIT 1);
	
            
            SELECT Is_Approved as Is_Approved , Farmer_Id AS Farmer_Id , ifnull(Farmer_Name,'') as Farmer_Name , 'MCC Not Assigned' as Collection_Centre_Name , ifnull(Profile_Photo,'') as Profile_Photo , 
			0 as Is_Password_Reset , ifnull(@MusterType, 7) as MusterType
            from  t002_farmerregistration where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id  ;

	end if;
    delete from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = var_Profile_Id and User_Type = 'Farmer' and 
            LastEdited_On < DATE_SUB(@Current_Datetime, INTERVAL 1 month) ;
        
			if exists (select 1 from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = var_Profile_Id and User_Type = 'Farmer' 
				 and Device_Id = Var_Device_Id) then
				 update mu11_user_deviceid 
                 set LastEdited_On =  @Current_Datetime,
                 Android_Version = var_android_version,
                 Make_Model = var_make_model
				 where Org_Id = var_Org_Id and User_Id = var_Profile_Id and User_Type = 'Farmer' 
				 and Device_Id = Var_Device_Id;
                
             else
             
				/*
				insert into mu11_user_deviceid (Org_Id,User_Id , User_Type , Device_Id , LastEdited_On  ) values
				 (var_Org_Id , var_Profile_Id , 'Farmer' , Var_Device_Id , @Current_Datetime) ;
                 
                 */
                 
                 insert into mu11_user_deviceid (Org_Id,User_Id , User_Type , Device_Id , LastEdited_On ,Android_Version,Make_Model ) values
				 (var_Org_Id , var_Profile_Id , 'Farmer' , Var_Device_Id , @Current_Datetime,var_android_version,var_make_model) ;
                
                
           end if;
        
	
    elseif(var_Method_Name = 'SilentSignIn') then
    
    
			set @MCC_Id = (select MCC_Id from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id );

			set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = @MCC_Id and is_deleted = 0 and 
			Applicable_Date <= @Current_Datetime
			order by Applicable_Date desc limit 1 ) ;
				
			Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );

            if exists(select 1 from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id ) then 

                SELECT if(mu04.Is_Active = 1 , 1, if(mu04.Is_Active = 0 , -1 , 1)) as Is_Approved , Farmer_Id AS Farmer_Id , ifnull(Farmer_Name ,'')as Farmer_Name , if(ifnull(MCC_Name,'') = '' , 'MCC Not Assigned' , MCC_Name)  as Collection_Centre_Name , ifnull(mu04.Profile_Photo,'') as Profile_Photo , 
				Is_PasswordReset as Is_Password_Reset , ifnull(@MusterType,7) as MusterType
                from  mu04_farmer mu04 left join m005_mcc m005 on m005.Org_Id= mu04.Org_Id and m005.MCC_Id = mu04.MCC_Id
                where mu04.Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id  ;
                
		else
			SELECT Is_Approved as Is_Approved , Farmer_Id AS Farmer_Id , ifnull(Farmer_Name,'') as Farmer_Name , 'MCC Not Assigned' as Collection_Centre_Name , ifnull(Profile_Photo,'') as Profile_Photo , 
			0 as Is_Password_Reset  , ifnull(@MusterType, 7) as MusterType
             from  t002_farmerregistration where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id ;
		end if;
        
            delete from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id =var_Profile_Id and User_Type = 'Farmer' and 
            LastEdited_On < DATE_SUB(@Current_Datetime, INTERVAL 1 month) ;
        
			if exists (select 1 from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = var_Profile_Id and User_Type = 'Farmer' 
				 and Device_Id = Var_Device_Id) then
				 update mu11_user_deviceid 
                 set LastEdited_On =  @Current_Datetime,
                 Android_Version = var_android_version,
                 Make_Model = var_make_model
				 where Org_Id = var_Org_Id and User_Id = var_Profile_Id and User_Type = 'Farmer' 
				 and Device_Id = Var_Device_Id;

             else
				/*
				insert into mu11_user_deviceid (Org_Id,User_Id , User_Type , Device_Id , LastEdited_On  ) values
				 (var_Org_Id , var_Profile_Id , 'Farmer' , Var_Device_Id , @Current_Datetime) ;
                */
                insert into mu11_user_deviceid (Org_Id,User_Id , User_Type , Device_Id , LastEdited_On ,Android_Version,Make_Model ) values
				 (var_Org_Id , var_Profile_Id , 'Farmer' , Var_Device_Id , @Current_Datetime,var_android_version,var_make_model) ;
                
           end if;
  
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
