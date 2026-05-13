-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_DriverSign_In` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_DriverSign_In`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_Mobile_No varchar(12),
    var_Password varchar(50),
    var_Profile_Id varchar(20),
	var_Otpvalue varchar(10)
)
BEGIN
		if(var_Method_Name = 'SignIn') then
        
			set @Driver_Id = '' ;
			set @Driver_Id = (Select Driver_Id from mu06_driver where  Org_Id = var_Org_Id and Mobile_No = var_Mobile_No and 
            BINARY Login_Password = var_Password limit 1 );
           

			Select mu06.Driver_Id , mu06.Driver_Name,mu06.Driver_Code,mu06.DrivingLicense_No,
            c028.DriverType_Id,c028.DriverType_Name,
            mu06.Is_PasswordReset AS Is_Password_Reset,  mu06.Online_App_Flag as Is_App_Active,
            1 as is_vehicle_assigned
			from mu06_driver mu06 
            inner join c028_drivertype c028 on mu06.DriverType_Id = c028.DriverType_Id 
            where  mu06.Org_Id = var_Org_Id and mu06.Driver_Id = @Driver_Id limit 1;
		
      elseIF(var_Method_Name = 'SilentSignIn') then
        
			Select mu06.Driver_Id , mu06.Driver_Name,mu06.Driver_Code,mu06.DrivingLicense_No,
            c028.DriverType_Id,c028.DriverType_Name,
            mu06.Is_PasswordReset AS Is_Password_Reset,  mu06.Online_App_Flag as Is_App_Active,
            1 as is_vehicle_assigned
			from mu06_driver mu06 
            inner join c028_drivertype c028 on mu06.DriverType_Id = c028.DriverType_Id 
            where mu06.Org_Id = var_Org_Id and mu06.Driver_Id = var_Profile_Id limit 1;
        
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
                
				set @SMS = concat('OTP for Driver on S R Thorat Dairy Driver App is ', Generated_OTP,'. It is valid for 2 minutes.');


				select 1 as Result_Id, 'OTP Generated Successfully' as Result_Description, Generated_OTP as Result_Extra_Key, @SMS as Sms_Msg , var_Mobile_No as Mobile_No ;    
			End;
		
        	Elseif (var_Method_Name = 'VerifyOTP') then 
				Begin       
					set @Profile_Id= (select Driver_Id from mu06_driver where Mobile_No = var_Mobile_No and Org_Id = var_Org_Id limit 1 );
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
					if exists (select Driver_Id from mu06_driver where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No ) then
						update mu06_driver set Login_Password = var_Password ,
                        Is_PasswordReset = 0 
                        where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No;
						select 1 as Result_Id, 'Password Set Successfully' as Result_Description, 1 as Result_Extra_Key; 
					else   
						select -1 as Result_Id, 'Driver Not Found' as Result_Description, '' as Result_Extra_Key;    
					end if;
				END;
        
			elseif(var_Method_Name = 'ForgotPassword') then
				BEGIN
					DECLARE OTP_Request_Id VARCHAR (20);
					
					if exists (select Driver_Id from mu06_driver where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No AND Is_Active = 1 ) then
						SET @Driver_Id = (select Driver_Id from mu06_driver where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No LIMIT 1);
                        
                       
						set @Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
						set @Year_Id = (select right(left(curdate(),4),(2)));
						
						Call USP_Number_Range ('mu10_user_otp', @Year_Id, 'MU10', '', OTP_Request_Id);
						Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
						values(OTP_Request_Id, var_Org_Id, var_Mobile_No, @Generated_OTP, now());        
                        
                      set @SMS = concat('OTP for Driver on S R Thorat Dairy Driver App is ',  @Generated_OTP,'. It is valid for 2 minutes.');

                        
						select 1 as Result_Id, @Driver_Id as Result_Description, @Generated_OTP as Result_Extra_Key, @SMS as Sms_Msg , var_Mobile_No as Mobile_No;    
				
                else   
						select -1 as Result_Id, 'Driver Not Fount' as Result_Description, '' as Result_Extra_Key;    
					end if;
				END;  
                
			elseif (var_Method_Name = 'UpdatePassword') then
            
				
				if exists(select 1 from mu06_driver where  Org_Id = var_Org_Id and Driver_Id = var_Profile_Id ) then
					update mu06_driver set Login_Password = var_Password ,
                    Is_PasswordReset = 0 
                    where Org_Id = var_Org_Id and Driver_Id = var_Profile_Id;
					SELECT 1 AS Result_Id, 'Password updated Successfully' AS Result_Description, '' AS Result_Extra_Key;
                else
					SELECT -1 AS Result_Id, 'Invalid Credential' AS Result_Description, '' AS Result_Extra_Key;
				end if;
			END IF;		
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
