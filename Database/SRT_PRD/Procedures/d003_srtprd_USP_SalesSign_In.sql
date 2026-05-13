-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesSign_In` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesSign_In`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_Mobile_No varchar(12),
    var_Password varchar(50),
    var_Profile_Id varchar(20),
    Var_OtpValue varchar(10),
	Var_UserType varchar(40),
    var_Device_Id text,
    var_android_version text , 
    var_make_model text ,
    var_app_version text 
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

SET SQL_SAFE_UPDATES = 0;
	set @Appversion = (select Version from m025_app_version where App_Name = 'Dairylicious' and  Applicable_From < now() order by Applicable_From desc
	limit 1
	);

	if(var_Method_Name = 'SignIn') then
    
		set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
		set @SalesUser_Id = '' ;
		set @SalesUser_Id = (SELECT SalesUser_Id FROM mu12_sales_user where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id 
		and Login_Password = var_Password AND Online_App_Flag = 1 and Is_Active = 1);
        
        if(@SalesUser_Id is null or @SalesUser_Id ='')then
        
			set @SalesUser_Id = (SELECT Dealer_Id FROM mu08_dealer where Mobile_No = var_Mobile_No or Phone_No = var_Mobile_No
			AND Org_Id = var_Org_Id and Login_Password = var_Password  and Is_Active = 1 limit 1);
        
        end if;
        

		delete from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = @SalesUser_Id and User_Type = 'SalesPerson' and 
		LastEdited_On < DATE_SUB(@Current_Datetime, INTERVAL 1 month) ;

		if exists (select 1 from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = @SalesUser_Id and User_Type = 'SalesPerson' 
			and Device_Id = Var_Device_Id
            and Android_Version = var_android_version
            and Make_Model = var_make_model) then
			
			update mu11_user_deviceid 
			set LastEdited_On =  @Current_Datetime 
			where Org_Id = var_Org_Id 
			and User_Id = @SalesUser_Id 
			and User_Type = 'SalesPerson' 
			and Device_Id = Var_Device_Id
			and Android_Version = var_android_version
			and Make_Model = var_make_model;

		else

			insert into mu11_user_deviceid (Org_Id,User_Id , User_Type , 
			Device_Id ,Android_Version, Make_Model, LastEdited_On  ) values
			(var_Org_Id , @SalesUser_Id, 'SalesPerson' , Var_Device_Id ,var_android_version , 
			var_make_model, @Current_Datetime) ;

		end if;
    
		IF exists (SELECT 1 FROM mu12_sales_user where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id 
        and Login_Password = var_Password AND Online_App_Flag = 1 and Is_Active = 1) then 
    
			SELECT mu12.SalesUser_Id AS Profile_Id , mu12.SalesUser_Name as Profile_Name , ifnull(mu12r.SalesUser_Name,'Dairy') as Reporting , 
            ifnull(mu12.Is_MobileNo_Verified, 0) as Is_MobileNo_Verified ,
			ifnull(mu12.Profile_Photo,'') as Profile_Photo , '' as SalesUser_Id , '' as SalesUser_Name , mu12.Is_PasswordReset ,
            c001.Destination_Name as Destination_Name  ,
            c044.SalesUserRole_Name as UserType,
            mu12.SalesUserRole_Id as Role_Id,
            'Salesman' as LoginType,
            if(var_app_version <> @Appversion , '0' , '1' ) as App_Version
			from mu12_sales_user mu12 left join mu12_sales_user mu12r
			on mu12.Org_Id = mu12r.Org_Id and mu12.ReportingTo_Id = mu12r.SalesUser_Id
            left join c001_organization c001 on c001.Org_Id = var_Org_Id
            left join c044_sales_user_role c044 on c044.SalesUserRole_Id = mu12.SalesUserRole_Id
			where  mu12.Mobile_No = var_Mobile_No AND mu12.Org_Id = var_Org_Id 
			and mu12.Login_Password = var_Password AND mu12.Online_App_Flag = 1 and mu12.Is_Active = 1 limit 1;
    
    
		elseif exists(SELECT 1 FROM mu08_dealer where (Mobile_No = var_Mobile_No  or Phone_No = var_Mobile_No ) AND Org_Id = var_Org_Id 
			and Login_Password = var_Password AND Is_Active = 1) then 
            
			select  mu08.Dealer_Id AS Profile_Id , mu08.Dealer_Name as Profile_Name , '' as Reporting , 
			ifnull(mu08.Is_MobileNo_Verified, 0) as Is_MobileNo_Verified ,
			ifnull(mu08.Profile_Photo,'') as Profile_Photo , ifnull(mu12.SalesUser_Id,'') as SalesUser_Id , 
			ifnull(mu12.SalesUser_Name,'' ) as SalesUser_Name , mu08.Is_PasswordReset,
             c001.Destination_Name as Destination_Name,
			'Dealer' as UserType,
            '' as Role_Id,
            'Dealer' as LoginType,
             if(var_app_version <> @Appversion , '0' , '1' ) as App_Version
			from mu08_dealer mu08 left join mu12_sales_user mu12 on mu12.Org_Id = mu08.Org_Id and 
			mu12.SalesUser_Id = mu08.SalesUser_Id 
			left join c001_organization c001 on c001.Org_Id = var_Org_Id
			where (mu08.Mobile_No = var_Mobile_No  or mu08.Phone_No = var_Mobile_No ) AND mu08.Org_Id = var_Org_Id 
			and mu08.Login_Password = var_Password AND mu08.Is_Active = 1 limit 1;
    
    end if;

	elseIF(var_Method_Name = 'GenerateOTP') then 
    
    
				set @Profile_Id = (select SalesUser_Id FROM mu12_sales_user where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id  AND Online_App_Flag = 1 and Is_Active = 1 limit 1);

				if(@Profile_Id is null ) then 
                
				set @Profile_Id = (select Dealer_Id FROM mu08_dealer where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id AND Is_Active = 1 limit 1 );
				
                end if;
                
                if(@Profile_Id is null) then 
				
                select -1 as Result_Id, 'User not found' as Result_Description, @Generated_OTP as Result_Extra_Key; 
                
				else 

				set @Year_Id = '';
				set @Generated_OTP=''; 
				set @OTP_Request_Id='';
                
                set @Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
                set @Year_Id = (select right(left(curdate(),4),(2)));
                
				Call USP_Number_Range ('mu10_user_otp', @Year_Id , 'MU10', '', @OTP_Request_Id);
                
				Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
                
				values(@OTP_Request_Id, var_Org_Id, var_Mobile_No, @Generated_OTP, @Current_Datetime);   
                
                set @SMS = concat('OTP for Sales Person on S R Thorat Dairy Dairylicious App is ', @Generated_OTP,'. It is valid for 2 minutes.');


				select 1 as Result_Id, 
                'OTP Generated Successfully' as Result_Description, 
                @Generated_OTP as Result_Extra_Key,
				@SMS as Sms_Msg , 
                var_Mobile_No as Mobile_No ;     

				end if;
                
                
			elseif(var_Method_Name = 'ForgotPassword') then
				BEGIN
					
                    set @Profile_Id = (select SalesUser_Id FROM mu12_sales_user where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id  AND Online_App_Flag = 1 and Is_Active = 1 limit 1);

				if(@Profile_Id is null ) then 
                
				set @Profile_Id = (select Dealer_Id FROM mu08_dealer where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id AND Is_Active = 1 limit 1 );
				
                end if;
                
                if(@Profile_Id is null) then 
				
                select -1 as Result_Id, 'User not found' as Result_Description, @Generated_OTP as Result_Extra_Key; 
                
				else 

				set @Year_Id = '';
				set @Generated_OTP=''; 
				set @OTP_Request_Id='';
                
                set @Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
                set @Year_Id = (select right(left(curdate(),4),(2)));
                
				Call USP_Number_Range ('mu10_user_otp', @Year_Id , 'MU10', '', @OTP_Request_Id);
                
				Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
                
				values(@OTP_Request_Id, var_Org_Id, var_Mobile_No, @Generated_OTP, @Current_Datetime);   
                
                set @SMS = concat('OTP for Sales Person on S R Thorat Dairy Dairylicious App is ', @Generated_OTP,'. It is valid for 2 minutes.');


				select 1 as Result_Id, 
                'OTP Generated Successfully' as Result_Description, 
                @Generated_OTP as Result_Extra_Key,
				@SMS as Sms_Msg , 
                var_Mobile_No as Mobile_No ;  
                end if;
			END; 
		elseif(var_Method_Name = 'ResendOTP') then 
		begin
			    set @Profile_Id = (select SalesUser_Id FROM mu12_sales_user where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id  AND Online_App_Flag = 1 and Is_Active = 1 limit 1);

				if(@Profile_Id is null ) then 
                
				set @Profile_Id = (select Dealer_Id FROM mu08_dealer where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id AND Is_Active = 1 limit 1 );
				
                end if;
                
                if(@Profile_Id is null) then 
				
                select -1 as Result_Id, 'User not found' as Result_Description, @Generated_OTP as Result_Extra_Key; 
                
				else 

				set @Year_Id = '';
				set @Generated_OTP=''; 
				set @OTP_Request_Id='';
                
                set @Generated_OTP = (SELECT convert(FLOOR(RAND()*(9000)+1000), char));
                set @Year_Id = (select right(left(curdate(),4),(2)));
                
				Call USP_Number_Range ('mu10_user_otp', @Year_Id , 'MU10', '', @OTP_Request_Id);
                
				Insert into mu10_user_otp(OTP_Request_Id, Org_Id, Mobile_No, OTP, Generated_On)
                
				values(@OTP_Request_Id, var_Org_Id, var_Mobile_No, @Generated_OTP, @Current_Datetime);   
                
                set @SMS = concat('OTP for Sales Person on S R Thorat Dairy Dairylicious App is ', @Generated_OTP,'. It is valid for 2 minutes.');


				select 1 as Result_Id, 
                'OTP Generated Successfully' as Result_Description, 
                @Generated_OTP as Result_Extra_Key,
				@SMS as Sms_Msg , 
                var_Mobile_No as Mobile_No ;  
                end if;
                
			end;
		Elseif (var_Method_Name = 'VerifyOTP') then 
			     
                    set @var_Generated_On = (Select Generated_On from mu10_user_otp  
					Where OTP = var_Otpvalue and Mobile_No = var_Mobile_No and Org_Id = var_Org_Id 
					order by Generated_On desc limit 1);
                    
                    set @Dealer_Profile_Id = (select Dealer_Id FROM mu08_dealer where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id 
					AND Is_Active = 1 limit 1 );
                     
					set @salemanProfile_Id = (select SalesUser_Id FROM mu12_sales_user where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id 
					AND Online_App_Flag = 1 and Is_Active = 1 limit 1);
                     
                     
                     if( (@salemanProfile_Id is null or @salemanProfile_Id = '' ) and (@Dealer_Profile_Id is not null or @Dealer_Profile_Id <> '' )) then
                   
					set Var_UserType = 'Dealer';
                    
                   
					elseif((@salemanProfile_Id is not null or @salemanProfile_Id <> '' ) and (@Dealer_Profile_Id is  null or @Dealer_Profile_Id = '' )) then 
                    
                     set Var_UserType = 'Salesman';
	
                     end if;
                     
                     
			if(Var_UserType is null or Var_UserType = '')then 
                     
					SELECT -1 AS Result_Id,'User Not Found' AS Result_Description, '' AS Result_Extra_Key;
                     
                     else
                    
					if (TIMESTAMPDIFF(second, @var_Generated_On,Now()) < 120) then 
                    
					if(Var_UserType = 'Salesman')then 
                    
					set @Profile_Id = (select SalesUser_Id FROM mu12_sales_user where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id 
					AND Online_App_Flag = 1 and Is_Active = 1 limit 1);
                    
                    update mu12_sales_user
					set Is_MobileNo_Verified = 1
					where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id 
					AND Online_App_Flag = 1 and Is_Active = 1;
                    
					SELECT 1 AS Result_Id,'Success' AS Result_Description, 'Salesman' AS Result_Extra_Key;

                    
				
                    elseif(Var_UserType = 'Dealer') then 
						
					set @Profile_Id = (select Dealer_Id FROM mu08_dealer where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id 
					 AND Is_Active = 1 limit 1 );
                    
                    update mu08_dealer
					set Is_MobileNo_Verified = 1
					where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id 
					 AND Is_Active = 1;
                    
                    SELECT 1 AS Result_Id,'Success' AS Result_Description, 'Dealer' AS Result_Extra_Key;
					
                    end if;
					
						DELETE FROM mu10_user_otp WHERE TIMESTAMPDIFF(MINUTE,Generated_On,Now()) > 10;
                        						
					elseif(TIMESTAMPDIFF(second, @var_Generated_On,Now()) > 120) then
				
					select -1 as Result_Id,'OTP expired' as Result_Description,'' as Result_Extra_Key;
                    
					else 
						select -1 as Result_Id,'Invalid OTP' as Result_Description,'' as Result_Extra_Key;
					end if;  
                    
						end if; 
    
	Elseif(var_Method_Name = 'SetPassword') then
    
				if(Var_UserType = 'Salesman')then 
					
					update mu12_sales_user
					set Login_Password = var_Password,
					Is_PasswordReset = 0
					where Mobile_No = var_Mobile_No 
                    AND Org_Id = var_Org_Id 
					-- AND Online_App_Flag = 1 
                    -- and Is_Active = 1
                    ;
                
				elseif(Var_UserType = 'Dealer') then 
					
					update mu08_dealer
					set Login_Password = var_Password,
					Is_PasswordReset = 0
					where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id 
					 -- AND Is_Active = 1
                     ;
                
				end if;
    
    SELECT 1 AS Result_Id,'Success' AS Result_Description, '' AS Result_Extra_Key;
    
    

Elseif(var_Method_Name = 'SilentSignin') then
    
		set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
		set @SalesUser_Id = '' ;
		set @SalesUser_Id = (SELECT SalesUser_Id FROM mu12_sales_user where Mobile_No = var_Mobile_No AND Org_Id = var_Org_Id 
		and Login_Password = var_Password AND Online_App_Flag = 1 and Is_Active = 1);
        
        if(@SalesUser_Id is null or @SalesUser_Id ='')then
			set @SalesUser_Id = (SELECT SalesUser_Id FROM mu12_sales_user where SalesUser_Id =var_Profile_Id AND Org_Id = var_Org_Id  AND Online_App_Flag = 1 and Is_Active = 1);
        end if;
        
        if(@SalesUser_Id is null or @SalesUser_Id ='')then
        
			set @SalesUser_Id = (SELECT Dealer_Id FROM mu08_dealer where Mobile_No = var_Mobile_No or Phone_No = var_Mobile_No
			AND Org_Id = var_Org_Id and Login_Password = var_Password  and Is_Active = 1 limit 1);
        
        end if;

		delete from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = @SalesUser_Id and User_Type = 'SalesPerson' and 
		LastEdited_On < DATE_SUB(@Current_Datetime, INTERVAL 1 month) ;
        
        

		if exists (select 1 from mu11_user_deviceid where Org_Id = var_Org_Id and User_Id = @SalesUser_Id and User_Type = 'SalesPerson' 
			and Device_Id = Var_Device_Id
            and Android_Version = var_android_version
            and Make_Model = var_make_model) then
			
			update mu11_user_deviceid 
			set LastEdited_On =  @Current_Datetime 
			where Org_Id = var_Org_Id 
			and User_Id = @SalesUser_Id 
			and User_Type = 'SalesPerson' 
			and Device_Id = Var_Device_Id
			and Android_Version = var_android_version
			and Make_Model = var_make_model;

		else

			insert into mu11_user_deviceid (Org_Id,User_Id , User_Type , 
			Device_Id ,Android_Version, Make_Model, LastEdited_On  ) values
			(var_Org_Id , @SalesUser_Id, 'SalesPerson' , Var_Device_Id ,var_android_version , 
			var_make_model, @Current_Datetime) ;

		end if;
        
    
    IF exists (SELECT 1 FROM mu12_sales_user where SalesUser_Id = var_Profile_Id AND Org_Id = var_Org_Id 
        AND Online_App_Flag = 1 and Is_Active = 1) then 
    
			SELECT mu12.SalesUser_Id AS Profile_Id , mu12.SalesUser_Name as Profile_Name , ifnull(mu12r.SalesUser_Name,'Dairy') as Reporting , 
            ifnull(mu12.Is_MobileNo_Verified, 0) as Is_MobileNo_Verified ,
			ifnull(mu12.Profile_Photo,'') as Profile_Photo , '' as SalesUser_Id , '' as SalesUser_Name , mu12.Is_PasswordReset ,
            c001.Destination_Name as Destination_Name  ,
            c044.SalesUserRole_Name as UserType,
            mu12.SalesUserRole_Id as Role_Id,
            'Salesman' as LoginType,
            if(var_app_version <> @Appversion , '0' , '1' ) as App_Version
			from mu12_sales_user mu12 left join mu12_sales_user mu12r
			on mu12.Org_Id = mu12r.Org_Id and mu12.ReportingTo_Id = mu12r.SalesUser_Id
            left join c001_organization c001 on c001.Org_Id = var_Org_Id
			left join c044_sales_user_role c044 on c044.SalesUserRole_Id = mu12.SalesUserRole_Id
			where  mu12.SalesUser_Id = var_Profile_Id AND mu12.Org_Id = var_Org_Id 
			 AND mu12.Online_App_Flag = 1 and mu12.Is_Active = 1 limit 1;
    
		elseif exists(SELECT 1 FROM mu08_dealer where Dealer_Id = var_Profile_Id AND Org_Id = var_Org_Id 
			AND Is_Active = 1) then 
            
			select  mu08.Dealer_Id AS Profile_Id , mu08.Dealer_Name as Profile_Name , '' as Reporting , 
			ifnull(mu08.Is_MobileNo_Verified, 0) as Is_MobileNo_Verified ,
			ifnull(mu08.Profile_Photo,'') as Profile_Photo , ifnull(mu12.SalesUser_Id,'') as SalesUser_Id , 
			ifnull(mu12.SalesUser_Name,'' ) as SalesUser_Name , mu08.Is_PasswordReset,
             c001.Destination_Name as Destination_Name,
			'Dealer' as UserType,
			'' as Role_Id,
            'Dealer' as LoginType,
            if(var_app_version <> @Appversion , '0' , '1' ) as App_Version
			from mu08_dealer mu08 left join mu12_sales_user mu12 on mu12.Org_Id = mu08.Org_Id and 
			mu12.SalesUser_Id = mu08.SalesUser_Id 
			left join c001_organization c001 on c001.Org_Id = var_Org_Id
			where mu08.Dealer_Id = var_Profile_Id AND mu08.Org_Id = var_Org_Id 
			AND mu08.Is_Active = 1 limit 1;
    
    end if;
    
    

end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
