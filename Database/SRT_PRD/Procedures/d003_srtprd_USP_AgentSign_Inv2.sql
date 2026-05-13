-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentSign_Inv2` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentSign_Inv2`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_Mobile_No varchar(12),
    var_Password varchar(50),
    var_Profile_Id varchar(20),
	var_Otpvalue varchar(10),
    Var_Device_Id text,
    var_android_version  text,
    var_make_model text,
    var_app_version varchar(20)
)
BEGIN

	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
	SET SQL_SAFE_UPDATES=0;

		if(var_Method_Name = 'SignIn') then
        
			set @Agent_Id = '' ;
			set @Agent_Id = (Select Agent_Id from mu05_agent where  Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and BINARY Login_Password = var_Password limit 1 );
            set @MCC_Count = (Select count(*) from m005_mcc where  Org_Id = var_Org_Id and Agent_Id = @Agent_Id and Is_Active = 1 );

            
            delete from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = @Agent_Id and User_Type = 'Agent' and 
            LastEdited_On < DATE_SUB(@Current_Datetime, INTERVAL 1 month) ;
        
			if exists (select 1 from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = @Agent_Id and User_Type = 'Agent' 
				 and Device_Id = Var_Device_Id) then
				 update mu11_user_deviceid 
                 set LastEdited_On =  @Current_Datetime ,
                 Android_Version = var_android_version,
                 Make_Model = var_make_model
				where Org_Id = var_Org_Id and User_Id = @Agent_Id and User_Type = 'Agent' 
				 and Device_Id = Var_Device_Id;
                
             else
				insert into mu11_user_deviceid (Org_Id,User_Id , User_Type , Device_Id , LastEdited_On  ,Android_Version,Make_Model) values
				 (var_Org_Id , @Agent_Id, 'Agent' , Var_Device_Id , @Current_Datetime,var_android_version,var_make_model) ;
                
           end if;
        
        
			set @MCC_Id = (Select MCC_Id from m005_mcc where  Org_Id = var_Org_Id and Agent_Id = @Agent_Id and Is_Active = 1 limit 1);
			set @MCC_Name = (Select MCC_Name from m005_mcc where  Org_Id = var_Org_Id and MCC_Id = @MCC_Id limit 1);
        
			set @Appversion = (select Version from m025_app_version where App_Name = 'SankalanPoint' and  Applicable_From < now() order by Applicable_From desc
            limit 1
            );
        
			Select mu05.Agent_Id , mu05.Agent_Name, ifnull(@MCC_Name,'') as Collection_Centre_Name , 
            ifnull(@MCC_Id,'') as MCC_Id,
            mu05.Is_PasswordReset AS Is_Password_Reset,  mu05.Online_App_Flag as Is_App_Active ,
            ifnull(if(@MCC_Count > 1 , 1 ,0),0) as is_multiple_centre , mu05.Profile_Photo as Profile_Photo,
            m005.Is_ManualWeight , Is_ManualQuality, Is_ExtraTime,
            if(var_app_version = @Appversion , 1 , 0 ) as App_Version
			from mu05_agent mu05 left join m005_mcc m005 on mu05.Org_Id = m005.Org_Id and mu05.MCC_Id = m005.MCC_Id
            and mu05.Agent_Id = m005.Agent_Id
            where  mu05.Org_Id = var_Org_Id and mu05.Agent_Id = @Agent_Id limit 1;
		
      elseIF(var_Method_Name = 'SilentSignIn') then
        
        
			set @Appversion = (select Version from m025_app_version where App_Name = 'SankalanPoint' and  Applicable_From < now() order by Applicable_From desc
            limit 1
            );
            
           delete from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = var_Profile_Id and User_Type = 'Agent' and 
            LastEdited_On < DATE_SUB(@Current_Datetime, INTERVAL 1 month) ;
        
			if exists (select 1 from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = var_Profile_Id and User_Type = 'Agent' 
				 and Device_Id = Var_Device_Id) then
				 update mu11_user_deviceid 
                 set LastEdited_On =  @Current_Datetime ,
                 Android_Version = var_android_version,
                 Make_Model = var_make_model
				where Org_Id = var_Org_Id and User_Id = var_Profile_Id and User_Type = 'Agent' 
				 and Device_Id = Var_Device_Id;
                
             else
				insert into mu11_user_deviceid (Org_Id,User_Id , User_Type , Device_Id , LastEdited_On  ,Android_Version,Make_Model) values
				 (var_Org_Id , var_Profile_Id, 'Agent' , Var_Device_Id , @Current_Datetime,var_android_version,var_make_model) ;
                
           end if;
        
			set @MCC_Count = (Select count(*) from m005_mcc where  Org_Id = var_Org_Id and Agent_Id = var_Profile_Id and Is_Active = 1 );
            
            set @MCC_Id = (Select MCC_Id from m005_mcc where  Org_Id = var_Org_Id and Agent_Id = var_Profile_Id and Is_Active = 1 limit 1);
			set @MCC_Name = (Select MCC_Name from m005_mcc where  Org_Id = var_Org_Id and MCC_Id = @MCC_Id limit 1);
            
			Select mu05.Agent_Id , mu05.Agent_Name, ifnull(@MCC_Name,'') as Collection_Centre_Name , 
            ifnull(@MCC_Id,'') as MCC_Id,
            mu05.Is_PasswordReset AS Is_Password_Reset,  mu05.Online_App_Flag as Is_App_Active ,
            ifnull(if(@MCC_Count > 1 , 1 ,0),0) as is_multiple_centre , mu05.Profile_Photo as Profile_Photo,
            m005.Is_ManualWeight , Is_ManualQuality, Is_ExtraTime ,
			if(var_app_version = @Appversion , 1 , 0 ) as App_Version
			from mu05_agent mu05 left join m005_mcc m005 on mu05.Org_Id = m005.Org_Id and mu05.MCC_Id = m005.MCC_Id
            and mu05.Agent_Id = m005.Agent_Id
            where mu05.Org_Id = var_Org_Id and mu05.Agent_Id = var_Profile_Id limit 1;
        
		elseIF(var_Method_Name = 'GenerateOTP') then 
			Begin
				declare Year_Id varchar(10);
				Declare Generated_OTP varchar(10);  
				Declare OTP_Request_Id varchar(20); 
                
                set Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
                
                set Year_Id = (select right(left(curdate(),4),(2)));
                
				Call USP_Number_Range ('mu10_user_otp', Year_Id, 'MU10', '', OTP_Request_Id);
                
				Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
				values(OTP_Request_Id, var_Org_Id, var_Mobile_No, Generated_OTP, now());   
                
			set @SMS = concat('OTP for Agent on S R Thorat Dairy Agent App is ', Generated_OTP,'. It is valid for 2 minutes.');

                
                select 1 as Result_Id, 'OTP Generated Successfully' as Result_Description, Generated_OTP as Result_Extra_Key ,  @SMS as Sms_Msg , var_Mobile_No as Mobile_No;    
			
            End;
		
        	Elseif (var_Method_Name = 'VerifyOTP') then 
				Begin       
					set @Profile_Id= (select Agent_Id from mu05_agent where Mobile_No = var_Mobile_No and Org_Id = var_Org_Id limit 1 );
					set @var_Generated_On = (Select Generated_On from mu10_user_otp  
					Where OTP = var_Otpvalue and Mobile_No = var_Mobile_No and Org_Id = var_Org_Id 
					order by Generated_On desc limit 1);
					
					if (TIMESTAMPDIFF(second, @var_Generated_On,Now()) < 120) then 
					
						DELETE FROM mu10_user_otp WHERE TIMESTAMPDIFF(MINUTE,Generated_On,Now()) > 10;
						
						SELECT 1 AS Result_Id,'Success' AS Result_Description, ifnull(@Profile_Id,'') AS Result_Extra_Key;
						
					elseif(TIMESTAMPDIFF(second, @var_Generated_On,Now()) > 120) then
						select -1 as Result_Id,'OTP expired' as Result_Description,'' as Result_Extra_Key;
					else 
						select -1 as Result_Id,'Invalid OTP' as Result_Description,'' as Result_Extra_Key;
					end if;  
				End;
			
             Elseif(var_Method_Name = 'SetPassword') then
				BEGIN
					if exists (select Agent_Id from mu05_agent where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No ) then
						update mu05_agent set Login_Password = var_Password , Is_PasswordReset = 0  where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No;
						
                        select 1 as Result_Id, 'Password Updated' as Result_Description, 1 as Result_Extra_Key; 
					else   
						select -1 as Result_Id, 'Agent Not Found' as Result_Description, '' as Result_Extra_Key;    
					end if;
				END;
        
			elseif(var_Method_Name = 'ForgotPassword') then
				BEGIN
					DECLARE OTP_Request_Id VARCHAR (20);
					
					if exists (select Agent_Id from mu05_agent where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No AND Is_Active = 1 ) then
						SET @Agent_Id = (select Agent_Id from mu05_agent where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No);
						set @Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
						set @Year_Id = (select right(left(curdate(),4),(2)));
						
						Call USP_Number_Range ('mu10_user_otp', @Year_Id, 'MU10', '', OTP_Request_Id);
						Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
						values(OTP_Request_Id, var_Org_Id, var_Mobile_No, @Generated_OTP, now()); 
                        
				set @SMS = concat('OTP for Agent on S R Thorat Dairy Agent App is ', @Generated_OTP,'. It is valid for 2 minutes.');


						select 1 as Result_Id, @Agent_Id as Result_Description, @Generated_OTP as Result_Extra_Key , @SMS as Sms_Msg , var_Mobile_No as Mobile_No;    
					else   
						select -1 as Result_Id, 'Agent Not Fount' as Result_Description, -1 as Result_Extra_Key;    
					end if;
				END;  
                
			elseif (var_Method_Name = 'UpdatePassword') then
				if exists(select 1 from mu05_agent where  Org_Id = var_Org_Id and Agent_Id = var_Profile_Id ) then
					update mu05_agent set Login_Password = var_Password ,
                    Is_PasswordReset = 0 where Org_Id = var_Org_Id and Agent_Id = var_Profile_Id;
					SELECT 1 AS Result_Id, 'Password updated Successfully' AS Result_Description, '' AS Result_Extra_Key;
                else
					SELECT -1 AS Result_Id, 'Invalid Credential' AS Result_Description, '' AS Result_Extra_Key;
				end if;
			END IF;		
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
