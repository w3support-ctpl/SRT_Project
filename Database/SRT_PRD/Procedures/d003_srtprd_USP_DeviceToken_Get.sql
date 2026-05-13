-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_DeviceToken_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_DeviceToken_Get`(
Var_Method_Name varchar(45),
Var_Org_Id varchar(20),
Var_Profile_Id varchar(20),
Var_User_Type varchar(30)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));


	if(Var_Method_Name = 'FarmerMilkCollect') then
    
    set @MilKCollectionID = (select FarmerCollection_Id from t005_milkcollectionfarmer where Farmer_Id = Var_Profile_Id and Org_Id = Var_Org_Id and date(Created_On) = date(@Current_Datetime) and Is_Active = 1 limit 1);
    
    Set @NotificationTitle = (select if(MilkStatus_Id = 'C016001' , 'Milk Collected ✔' , 'Milk Rejected ❌')  from t005_milkcollectionfarmer where
    Org_Id = Var_Org_Id and FarmerCollection_Id = @MilKCollectionID);
    
	Set @NotificationText = (select concat('Qty: ' , Quantity_Kg , ' FAT: ' , Fat , ' SNF: ' , SNF , ' Amount: ' , if(MilkStatus_Id = 'C016001' , Amount , '00' )  )  from t005_milkcollectionfarmer where
    Org_Id = Var_Org_Id and FarmerCollection_Id = @MilKCollectionID);
    
   select Device_Id , @NotificationTitle as Notification_Title , @NotificationText as Notification_Text  from mu11_user_deviceid where Org_Id =  Var_Org_Id and User_Id = Var_Profile_Id and User_Type = Var_User_Type;


	elseif (Var_Method_Name = 'StartTrip') then
    
    
    Set @TripId = (Select TripDocument_Id from t021_tripdocument_header where Org_Id = Var_Org_Id  and Driver_Id = Var_Profile_Id and date(Created_On) = date( @Current_Datetime) and  Trip_Status = 'InTrip' order by TripDocument_Id desc limit 1 );
    
	Set @DriverId = (Select Driver_Id from t021_tripdocument_header where Org_Id = Var_Org_Id  and Driver_Id = Var_Profile_Id and date(Created_On) = date( @Current_Datetime) and  Trip_Status = 'InTrip' order by TripDocument_Id desc limit 1 );

	set @VehicleNo  = (select m003.Vehicle_No from t021_tripdocument_header t021 inner join m003_vehicle m003 on t021.Org_Id = m003.Org_Id and t021.Vehicle_Id = m003.Vehicle_Id where 
    t021.TripDocument_Id = @TripId and t021.Org_Id = Var_Org_Id
    );
    

	set @Notification_Text = (select concat('Driver: ' , (select Driver_Name from mu06_driver where Driver_Id = @DriverId and Org_Id = Var_Org_Id ) , ' - ' , 
    @VehicleNo , ' \n📞 ' , (select Mobile_No from mu06_driver where Driver_Id = @DriverId and Org_Id = Var_Org_Id ) ) ) ; 
    
   select Device_Id as Device_Id, 'Milk Collection Trip Started' as Notification_Title , @Notification_Text as Notification_Text  from 
   mu11_user_deviceid where Org_Id =  Var_Org_Id and User_Id in ( select Agent_Id from t022_tripdocument_item t022 inner join m005_mcc m005 on t022.Org_Id = m005.Org_Id and m005.MCC_Id = t022.MCC_Id
   where t022.TripDocument_Id =  @TripId ) and User_Type = Var_User_Type;



	elseif (Var_Method_Name = 'NextDestination') then

    Set @TripId = (Select TripDocument_Id from t021_tripdocument_header where Org_Id = Var_Org_Id  and Driver_Id = Var_Profile_Id and date(Created_On) = date( @Current_Datetime) and  Trip_Status = 'InTrip' order by TripDocument_Id desc limit 1 );
    
	Set @DriverId = (Select Driver_Id from t021_tripdocument_header where Org_Id = Var_Org_Id  and Driver_Id = Var_Profile_Id and date(Created_On) = date( @Current_Datetime) and  Trip_Status = 'InTrip' order by TripDocument_Id desc limit 1 );

	set @Notification_Text = (select concat( 'Reaching to your centre' , 
    ' \nDriver: ' , (select Driver_Name from mu06_driver where Driver_Id = @DriverId and Org_Id = Var_Org_Id ) , ' - ' , 
    @VehicleNo , ' \n📞 ' , (select Mobile_No from mu06_driver where Driver_Id = @DriverId and Org_Id = Var_Org_Id ) ) ) ; 
    
   select Device_Id as Device_Id, 'Milk Collection Vehicle Status' as Notification_Title , @Notification_Text as Notification_Text  from 
   mu11_user_deviceid where Org_Id =  Var_Org_Id and User_Id = ( select Agent_Id from t022_tripdocument_item t022 inner join m005_mcc m005 on t022.Org_Id = m005.Org_Id and m005.MCC_Id = t022.MCC_Id
   where t022.TripDocument_Id =  @TripId and t022.Is_Reached <> 2 order by Order_By asc limit 1 ) and User_Type = Var_User_Type;

	elseif (Var_Method_Name = 'ReachedDairy') then

	Set @TripId = (Select TripDocument_Id from t021_tripdocument_header where Org_Id = Var_Org_Id  and Driver_Id = Var_Profile_Id and date(Created_On) = date( @Current_Datetime) and  Trip_Status = 'AtDairy' order by TripDocument_Id desc limit 1 );
    
	Set @DriverId = (Select Driver_Id from t021_tripdocument_header where Org_Id = Var_Org_Id  and Driver_Id = Var_Profile_Id and date(Created_On) = date( @Current_Datetime) and  Trip_Status = 'AtDairy' order by TripDocument_Id desc limit 1 );

	set @Notification_Text = 'Vehicle is at dairy milk dispatched is in process' ; 
    
   select Device_Id as Device_Id, 'Milk Collection Vehicle Status' as Notification_Title , @Notification_Text as Notification_Text  from 
   mu11_user_deviceid where Org_Id =  Var_Org_Id and User_Id in ( select Agent_Id from t022_tripdocument_item t022 inner join m005_mcc m005 on t022.Org_Id = m005.Org_Id and m005.MCC_Id = t022.MCC_Id
   where t022.TripDocument_Id =  @TripId and t022.Is_Reached = 2 ) and User_Type = Var_User_Type;

	ELSEIF(Var_Method_Name = 'DataCorrectionRequestApproved') THEN
    BEGIN
		SET @NotificationTitle = 'Data Correction Request';
		SET @NotificationText = 'Your Data Correction Request is Approved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'DataCorrectionRequestRejected') THEN
    BEGIN
		SET @NotificationTitle = 'Data Correction Request';
		SET @NotificationText = 'Your Data Correction Request is Rejected.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'FarmerRegistrationRequestApproved') THEN
    BEGIN
		SET @NotificationTitle = 'Farmer Registration Request';
		SET @NotificationText = 'Your Farmer Registration Request is Approved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'FarmerRegistrationRequestRejected') THEN
    BEGIN
		SET @NotificationTitle = 'Farmer Registration Request';
		SET @NotificationText = 'Your Farmer Registration Request is Rejected.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    
    ELSEIF(Var_Method_Name = 'FarmerServiceRequestApproved') THEN
    BEGIN
		SET @NotificationTitle = 'Farmer Service Request';
		SET @NotificationText = 'Your Farmer Service Request is Approved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'FarmerServiceRequestRejected') THEN
    BEGIN
		SET @NotificationTitle = 'Farmer Service Request';
		SET @NotificationText = 'Your Farmer Service Request is Rejected.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    
    ELSEIF(Var_Method_Name = 'AgentServiceRequestApproved') THEN
    BEGIN
		SET @NotificationTitle = 'Agent Service Request';
		SET @NotificationText = 'Your Agent Service Request is Approved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'AgentServiceRequestRejected') THEN
    BEGIN
		SET @NotificationTitle = 'Agent Service Request';
		SET @NotificationText = 'Your Agent Service Request is Rejected.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    
    ELSEIF(Var_Method_Name = 'CollectionRequestApproved') THEN
    BEGIN
		SET @NotificationTitle = 'Milk Collection Request';
		SET @NotificationText = 'Your Milk Collection Request is Approved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'CollectionRequestRejected') THEN
    BEGIN
		SET @NotificationTitle = 'Milk Collection Request';
		SET @NotificationText = 'Your Milk Collection Request is Rejected.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    
    ELSEIF(Var_Method_Name = 'FarmerOrderRequestApproved') THEN
    BEGIN
		SET @NotificationTitle = 'Farmer Order Request';
		SET @NotificationText = 'Your Farmer Order Request is Approved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'FarmerOrderRequestRejected') THEN
    BEGIN
		SET @NotificationTitle = 'Farmer Order Request';
		SET @NotificationText = 'Your Farmer Order Request is Rejected.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    
    ELSEIF(Var_Method_Name = 'AgentOrderRequestApproved') THEN
    BEGIN
		SET @NotificationTitle = 'Agent Order Request';
		SET @NotificationText = 'Your Agent Order Request is Approved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'AgentOrderRequestRejected') THEN
    BEGIN
		SET @NotificationTitle = 'Agent Order Request';
		SET @NotificationText = 'Your Agent Order Request is Rejected.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    
    ELSEIF(Var_Method_Name = 'FarmerIncentiveRequestApproved') THEN
    BEGIN
		SET @NotificationTitle = 'Farmer Incentive Request';
		SET @NotificationText = 'Your Farmer Incentive Request is Approved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'FarmerIncentiveRequestRejected') THEN
    BEGIN
		SET @NotificationTitle = 'Farmer Incentive Request';
		SET @NotificationText = 'Your Farmer Incentive Request is Rejected.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    
    ELSEIF(Var_Method_Name = 'AgentIncentiveRequestApproved') THEN
    BEGIN
		SET @NotificationTitle = 'Agent Incentive Request';
		SET @NotificationText = 'Your Agent Incentive Request is Approved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'AgentIncentiveRequestRejected') THEN
    BEGIN
		SET @NotificationTitle = 'Agent Incentive Request';
		SET @NotificationText = 'Your Agent Incentive Request is Rejected.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    -- Complaint Resolved
    ELSEIF(Var_Method_Name = 'ComplaintResolved') THEN
    BEGIN
		SET @NotificationTitle = 'Complaint Resolved';
		SET @NotificationText = 'Your Complaint is now Resolved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    
    -- Complaint Opened
    ELSEIF(Var_Method_Name = 'ComplaintOpened') THEN
    BEGIN
		SET @NotificationTitle = 'Complaint Opened';
		SET @NotificationText = 'Your Complaint is now Open.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    /*
    -- Correction Request Approved
    ELSEIF(Var_Method_Name = 'CorrectionRequestApproved') THEN
    BEGIN
		SET @NotificationTitle = 'Correction Request';
		SET @NotificationText = 'Your Correction Request is Approved.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    
    -- Correction Request Rejected
    ELSEIF(Var_Method_Name = 'CorrectionRequestRejected') THEN
    BEGIN
		SET @NotificationTitle = 'Correction Request';
		SET @NotificationText = 'Your Correction Request is Rejected.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    */
    
    
    ELSEIF(Var_Method_Name = 'CorrectionRequestApproved' and Var_User_Type = 'Farmer') THEN
    BEGIN
		SET @NotificationTitle = 'Correction Request';
		SET @NotificationText = 'Your Correction Request is Approved.';
        
        set @FarmerCollection_Id  = (select FarmerCollection_Id from t013_correction_request 
							where Org_Id = Var_Org_Id
							and Correction_Request_Id = Var_Profile_Id
							limit 1);
                            
		select MCC_Id,Farmer_Id into @MCC_Id,@Farmer_Id from t005_milkcollectionfarmer 
		where Org_Id = Var_Org_Id
		and FarmerCollection_Id = @FarmerCollection_Id limit 1;


		set @Agent_Id = (select Agent_Id from m005_mcc 
						where Org_Id = Var_Org_Id 
						and MCC_Id =  @MCC_Id);
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = @Farmer_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'CorrectionRequestRejected' and Var_User_Type = 'Farmer') THEN
    BEGIN
		SET @NotificationTitle = 'Correction Request';
		SET @NotificationText = 'Your Correction Request is Rejected.';
        
        set @FarmerCollection_Id  = (select FarmerCollection_Id from t013_correction_request 
							where Org_Id = Var_Org_Id
							and Correction_Request_Id = Var_Profile_Id
							limit 1);
                            
		select MCC_Id,Farmer_Id into @MCC_Id,@Farmer_Id from t005_milkcollectionfarmer 
		where Org_Id = Var_Org_Id
		and FarmerCollection_Id = @FarmerCollection_Id limit 1;


		set @Agent_Id = (select Agent_Id from m005_mcc 
						where Org_Id = Var_Org_Id 
						and MCC_Id =  @MCC_Id);
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = @Farmer_Id 
        AND User_Type = Var_User_Type;

    END;
    
    ELSEIF(Var_Method_Name = 'CorrectionRequestApproved' and Var_User_Type = 'Agent') THEN
    BEGIN
		SET @NotificationTitle = 'Correction Request';
		SET @NotificationText = 'Your Correction Request is Approved.';
        
        set @FarmerCollection_Id  = (select FarmerCollection_Id from t013_correction_request 
							where Org_Id = Var_Org_Id
							and Correction_Request_Id = Var_Profile_Id
							limit 1);
                            
		select MCC_Id,Farmer_Id into @MCC_Id,@Farmer_Id from t005_milkcollectionfarmer 
		where Org_Id = Var_Org_Id
		and FarmerCollection_Id = @FarmerCollection_Id limit 1;


		set @Agent_Id = (select Agent_Id from m005_mcc 
						where Org_Id = Var_Org_Id 
						and MCC_Id =  @MCC_Id);
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = @Agent_Id 
        AND User_Type = Var_User_Type;

    END;
    ELSEIF(Var_Method_Name = 'CorrectionRequestRejected' and Var_User_Type = 'Agent') THEN
    BEGIN
		SET @NotificationTitle = 'Correction Request';
		SET @NotificationText = 'Your Correction Request is Rejected.';
        
        set @FarmerCollection_Id  = (select FarmerCollection_Id from t013_correction_request 
							where Org_Id = Var_Org_Id
							and Correction_Request_Id = Var_Profile_Id
							limit 1);
                            
		select MCC_Id,Farmer_Id into @MCC_Id,@Farmer_Id from t005_milkcollectionfarmer 
		where Org_Id = Var_Org_Id
		and FarmerCollection_Id = @FarmerCollection_Id limit 1;


		set @Agent_Id = (select Agent_Id from m005_mcc 
						where Org_Id = Var_Org_Id 
						and MCC_Id =  @MCC_Id);
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = @Agent_Id 
        AND User_Type = Var_User_Type;

    END;
	ELSEIF(Var_Method_Name = 'SalesPersonBlocked') THEN
    BEGIN
		SET @NotificationTitle = 'Account Disabled';
		SET @NotificationText = 'Your Account has been Disabled by Admin. Please contact SRT Dairy.';
    
		SELECT  Device_Id, 
				@NotificationTitle AS Notification_Title, 
				@NotificationText AS Notification_Text
		FROM mu11_user_deviceid 
        WHERE Org_Id =  Var_Org_Id 
        AND User_Id = Var_Profile_Id 
        AND User_Type = Var_User_Type;

    END;
    
	END if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
