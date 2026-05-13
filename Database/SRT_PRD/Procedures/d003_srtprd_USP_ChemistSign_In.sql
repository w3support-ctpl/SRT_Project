-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_ChemistSign_In` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_ChemistSign_In`(
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
    	SET SQL_SAFE_UPDATES = 0;
        
        	set @Appversion = (select Version from m025_app_version where App_Name = 'QACheck' and  Applicable_From < now() order by Applicable_From desc
            limit 1
            );

		if(var_Method_Name = 'SignIn') then
        
        	set @Chemist_Id = '' ;
			set @Chemist_Id = (Select chemist_Id from mu07_routechemist where  Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and  Login_Password = var_Password and Is_Active = 1 limit 1 );

			delete from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = @Chemist_Id and User_Type = 'chemist' and 
            LastEdited_On < DATE_SUB(@Current_Datetime, INTERVAL 1 month) ;
        
			if exists (select 1 from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = @Chemist_Id and User_Type = 'chemist' 
				 and Device_Id = Var_Device_Id) then
				 update mu11_user_deviceid 
                 set LastEdited_On =  @Current_Datetime ,
                 Android_Version = var_android_version,
                 Make_Model = var_make_model
				where Org_Id = var_Org_Id and User_Id = @Chemist_Id and User_Type = 'chemist' 
				 and Device_Id = Var_Device_Id;
                
             else
				insert into mu11_user_deviceid (Org_Id,User_Id , User_Type , Device_Id , LastEdited_On  ,Android_Version,Make_Model) values
				 (var_Org_Id , @Chemist_Id, 'chemist' , Var_Device_Id , @Current_Datetime,var_android_version,var_make_model) ;
                
           end if;
        
			SET @SurveyCount = (select count(*) from t025_survey_header where date(Applicable_Date) = date(@Current_Datetime) and
            Survey_Id = @Chemist_Id );
 
    
			Select Chemist_Id, Profile_Photo , Chemist_Name, Is_MobileNo_Verified as Is_Verify , Is_PasswordReset , 
            if(@SurveyCount <> 0 or @SurveyCount is not null , 1, 0) as SurveyAvailable,
			if(var_app_version <> @Appversion , 0 , 1 ) as App_Version

            from mu07_routechemist
            where Org_Id = var_Org_Id and chemist_Id = @Chemist_Id limit 1;

		
      elseIF(var_Method_Name = 'SilentSignIn') then
        
        	set @Chemist_Id = '' ;
			set @Chemist_Id = var_Profile_Id ;

			delete from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = @Chemist_Id and User_Type = 'chemist' and 
            LastEdited_On < DATE_SUB(@Current_Datetime, INTERVAL 1 month) ;
        
			if exists (select 1 from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = @Chemist_Id and User_Type = 'chemist' 
				 and Device_Id = Var_Device_Id) then
				 update mu11_user_deviceid 
                 set LastEdited_On =  @Current_Datetime,
                 Android_Version = var_android_version,
                 Make_Model = var_make_model
				where Org_Id = var_Org_Id and User_Id = @Chemist_Id and User_Type = 'chemist' 
				 and Device_Id = Var_Device_Id;
                
             else
				insert into mu11_user_deviceid (Org_Id,User_Id , User_Type , Device_Id , LastEdited_On  ,Android_Version,Make_Model) values
				 (var_Org_Id , @Chemist_Id, 'chemist' , Var_Device_Id , @Current_Datetime,var_android_version,var_make_model) ;
                
           end if;
        
	
			SET @SurveyCount = (select count(*) from t025_survey_header where date(Applicable_Date) = date(@Current_Datetime) and
            Survey_Id = @Chemist_Id );
            
			Select Chemist_Id, Profile_Photo , Chemist_Name, Is_MobileNo_Verified as Is_Verify , 
            Is_PasswordReset ,  if(@SurveyCount <> 0 or @SurveyCount is not null , 1, 0) as SurveyAvailable,
            if(var_app_version <> @Appversion , 0 , 1 ) as App_Version
            from mu07_routechemist
            where Org_Id = var_Org_Id and chemist_Id = @Chemist_Id limit 1;
        
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
                
                 set @SMS = concat('OTP for Chemist on S R Thorat Dairy Chemist App is ',  Generated_OTP,'. It is valid for 2 minutes.');

				select 1 as Result_Id, 'OTP Generated Successfully' as Result_Description, Generated_OTP as Result_Extra_Key , @SMS as Sms_Msg , var_Mobile_No as Mobile_No;    
			End;
		
        	Elseif (var_Method_Name = 'VerifyOTP') then 
				Begin       
                
					set @Chemist_Id= (Select chemist_Id from mu07_routechemist where  Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Active = 1 limit 1 );  
                    
					set  @var_Generated_On = '' ;
					set @Last_Otp = '';
                    
                    Select Generated_On , OTP INTO @var_Generated_On , @Last_Otp from mu10_user_otp  
					Where OTP = var_Otpvalue and Mobile_No = var_Mobile_No and Org_Id = var_Org_Id 
					order by Generated_On desc limit 1;
					
					if (TIMESTAMPDIFF(second, @var_Generated_On,Now()) < 120) then 
						
                        if(@Last_Otp = var_Otpvalue)then 
							DELETE FROM mu10_user_otp WHERE TIMESTAMPDIFF(MINUTE,Generated_On,Now()) > 10;
							SELECT 1 AS Result_Id,'Success' AS Result_Description, ifnull(@Profile_Id,'') AS Result_Extra_Key;
                        else
							select -1 as Result_Id,'OTP expired' as Result_Description,'' as Result_Extra_Key;
                            
						end if;
                        
					elseif(TIMESTAMPDIFF(second, @var_Generated_On,Now()) > 120) then
						select -1 as Result_Id,'OTP expired' as Result_Description,'' as Result_Extra_Key;
					else 
						select -1 as Result_Id,'Invalid OTP' as Result_Description,'' as Result_Extra_Key;
					end if;  
				End;
			
             Elseif(var_Method_Name = 'SetPassword') then
				BEGIN
                
               set @Chemist_Id = (Select chemist_Id from mu07_routechemist where  Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Active = 1 limit 1 );  
					
                
					if(@Chemist_Id is not null or @Chemist_Id <> '') then
						update mu07_routechemist set Login_Password = var_Password , Is_PasswordReset = 0,
                        Is_MobileNo_Verified = 1
                        where Org_Id = var_Org_Id and chemist_Id = @Chemist_Id;
						
                        select 1 as Result_Id, 'Password Updated' as Result_Description, 1 as Result_Extra_Key; 
					else   
						select -1 as Result_Id, 'Chemist Not Found' as Result_Description, '' as Result_Extra_Key;    
					end if;
				END;
        
			elseif(var_Method_Name = 'ForgotPassword') then
				BEGIN
					DECLARE OTP_Request_Id VARCHAR (20);
					
                    set @Chemist_Id = (Select chemist_Id from mu07_routechemist where  Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and Is_Active = 1 limit 1 );  

					if (@Chemist_Id is not null or @Chemist_Id <> '') then
                    
						set @Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
						set @Year_Id = (select right(left(curdate(),4),(2)));
						
						Call USP_Number_Range ('mu10_user_otp', @Year_Id, 'MU10', '', OTP_Request_Id);
						Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
						values(OTP_Request_Id, var_Org_Id, var_Mobile_No, @Generated_OTP, now()); 
                        
                       set @SMS = concat('OTP for Chemist on S R Thorat Dairy Chemist App is ',  @Generated_OTP,'. It is valid for 2 minutes.');

						select 1 as Result_Id, @Chemist_Id as Result_Description, @Generated_OTP as Result_Extra_Key , @SMS as Sms_Msg , var_Mobile_No as Mobile_No;    
					
                    else 
                    
						select -1 as Result_Id, 'Chemist Not Fount' as Result_Description, '' as Result_Extra_Key; 
                        
					end if;
				END;  
                
			elseif (var_Method_Name = 'UpdatePassword') then
            
             set @Chemist_Id = (Select chemist_Id from mu07_routechemist where  Org_Id = var_Org_Id and chemist_Id = var_Profile_Id and Is_Active = 1 limit 1 );  

				if (@Chemist_Id is not null or @Chemist_Id <> '' ) then
                
				update mu07_routechemist set Login_Password = var_Password ,
                Is_PasswordReset = 0 ,
                Is_MobileNo_Verified = 1 where Org_Id = var_Org_Id and chemist_Id = @Chemist_Id;
                
					SELECT 1 AS Result_Id, 'Password updated Successfully' AS Result_Description, '' AS Result_Extra_Key;
                else
					SELECT -1 AS Result_Id, 'Invalid Credential' AS Result_Description, '' AS Result_Extra_Key;
				end if;
			END IF;		
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
