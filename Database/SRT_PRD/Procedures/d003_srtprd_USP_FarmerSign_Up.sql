-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerSign_Up` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerSign_Up`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_Mobile_No varchar(12),
    var_Otpvalue varchar(6),
    var_Password varchar(50),
    var_Profile_Id varchar(20),
    Var_Farmer_Name varchar(50)
)
BEGIN

  set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	If (var_Method_Name = 'GenerateOTP') then
		BEGIN
			declare Year_Id varchar(10);
			Declare Generated_OTP varchar(10);  
			Declare OTP_Request_Id varchar(20); 
        
            if exists ( select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No  ) OR exists (select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No  ) then
				select -1 as Result_Id, 'Mobile number already registered' as Result_Description, -1 as Result_Extra_Key; 
			else
				set Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
			
                set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('mu10_user_otp', Year_Id, 'MU10', '', OTP_Request_Id);
				Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
				values(OTP_Request_Id, var_Org_Id, var_Mobile_No, Generated_OTP, now());       
                
				set @SMS = concat('OTP for Farmer on S R Thorat Dairy Farmer App is ', Generated_OTP,'. It is valid for 2 minutes.');
                
				select 1 as Result_Id, 'OTP Generated Successfully' as Result_Description, Generated_OTP as Result_Extra_Key , @SMS as Sms_Msg , var_Mobile_No as Mobile_No ;    
            end if;
		END;
	Elseif (var_Method_Name = 'VerifyOTP') then 
        Begin       
			set @Profile_Id= ifnull((select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No),(select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No));
			
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
	
    elseif(var_Method_Name = 'RegisterFarmer') then
		BEGIN

            if exists (select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No )  then
				select -1 as Result_Id, 'Mobile number already registered' as Result_Description, -1 as Result_Extra_Key; 
			else
				set @New_Farmer_Id = '';
                set @Year_Id = (select right(left(curdate(),4),(2)));
                
				Call USP_Number_Range ('t002_farmerregistration',  @Year_Id, 'T002', '', @New_Farmer_Id);
                
				Insert into t002_farmerregistration(Org_Id, Farmer_Id, Mobile_No, Password,Is_Approved, Request_Date ,Farmer_Name )
				values(var_Org_Id, @New_Farmer_Id, var_Mobile_No, var_Password ,0,@Current_Datetime , Var_Farmer_Name); 
                
                
				select 1 as Result_Id, 'Registered Successfully' as Result_Description, @New_Farmer_Id as Result_Extra_Key  ;    
            end if;
		END;
        
    elseif(var_Method_Name = 'ForgotPassword') then
		BEGIN
        DECLARE OTP_Request_Id VARCHAR (20);

            if exists (select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No  ) OR exists (select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No) then
				SET @Farmer_Id = ifnull((select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No),(select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No));
				set @Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
                set @Year_Id = (select right(left(curdate(),4),(2)));
                
				Call USP_Number_Range ('mu10_user_otp', @Year_Id, 'MU10', '', OTP_Request_Id);
				Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
				values(OTP_Request_Id, var_Org_Id, var_Mobile_No, @Generated_OTP, now());        
                
				set @SMS = concat('OTP for Farmer on S R Thorat Dairy Farmer App is ', @Generated_OTP,'. It is valid for 2 minutes.');

				select 1 as Result_Id, @Farmer_Id as Result_Description, @Generated_OTP as Result_Extra_Key , var_Mobile_No as Mobile_No , @SMS as Sms_Msg;    
			else   
				select -1 as Result_Id, 'Farmer Not Found' as Result_Description, -1 as Result_Extra_Key;    
            end if;
		END;        
	elseif (var_Method_Name = 'UpdatePassword') then
    
		update t002_farmerregistration set Password = var_Password where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id;
       
       update mu04_farmer set Login_Password = var_Password,
        Is_MobileNo_Verified = 1,
        Is_PasswordReset = 0
        where Org_Id = var_Org_Id and Farmer_Id = var_Profile_Id ;
        
		SELECT 1 AS Result_Id, 'Password updated Successfully' AS Result_Description, '' AS Result_Extra_Key;
        
	
    elseif(var_Method_Name = 'ResendOTP') then 
    
    /*
    if exists (select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No  ) OR (select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No) then
				SET @Farmer_Id = ifnull((select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No),(select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No));
				set @Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
                set @Year_Id = (select right(left(curdate(),4),(2)));
                
				Call USP_Number_Range ('mu10_user_otp', @Year_Id, 'MU10', '', @OTP_Request_Id);
				Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
				values(@OTP_Request_Id, var_Org_Id, var_Mobile_No, @Generated_OTP, now());   
                
               set @SMS = concat('OTP for Farmer on S R Thorat Dairy Farmer App is ', @Generated_OTP,'. It is valid for 2 minutes.');

				select 1 as Result_Id, @Farmer_Id as Result_Description, @Generated_OTP as Result_Extra_Key , @SMS as Sms_Msg , var_Mobile_No as Mobile_No ;    
			
            else   
            
				select -1 as Result_Id, 'Farmer Not Found' as Result_Description, -1 as Result_Extra_Key; 
                
            end if;
    
    */
    
				SET @Farmer_Id = ifnull((select Farmer_Id from mu04_farmer where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No),(select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and Mobile_No = var_Mobile_No));
				set @Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
                set @Year_Id = (select right(left(curdate(),4),(2)));
                
				Call USP_Number_Range ('mu10_user_otp', @Year_Id, 'MU10', '', @OTP_Request_Id);
				Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
				values(@OTP_Request_Id, var_Org_Id, var_Mobile_No, @Generated_OTP, now());   
                
				set @SMS = concat('OTP for Farmer on S R Thorat Dairy Farmer App is ', @Generated_OTP,'. It is valid for 2 minutes.');

				select 1 as Result_Id, @Farmer_Id as Result_Description, @Generated_OTP as Result_Extra_Key , @SMS as Sms_Msg , var_Mobile_No as Mobile_No ;   
    
    
	END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
