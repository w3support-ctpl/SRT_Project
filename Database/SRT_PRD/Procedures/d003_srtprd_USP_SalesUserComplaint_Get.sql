-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesUserComplaint_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesUserComplaint_Get`(
var_Method_Name varchar(50),
var_Org_Id varchar(10),
var_Complaint_Id varchar(20),
Var_SalesUser_Id varchar(20),
var_Profile_Id varchar(20),
var_Search_Period  VARCHAR(45),
var_Dealer_Id  VARCHAR(45)
)
BEGIN

	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

   IF(var_Method_Name = 'GetComplaintsDealer')  then 
   
		begin
		
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Search_Period, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Search_Period, ' - ', -1), '%m/%d/%Y');
   
		if(ifnull(var_Dealer_Id,'') <> '')then
        
        SELECT T037.Org_Id,T037.Complaint_Id,T037.Complaint_Remark,MU08.Dealer_Name as Name,
        T037.Complaint_By,T037.Complaint_For,C035.ComplaintStatus_Name,DATE_FORMAT(T037.Complaint_Date, '%D %M %Y') as Complaint_Date,
        c034.ComplaintType_Name,
        ifnull(T037.QualityNotification,'') as QualityNotification,
        ifnull(c050.NotificationCodeGroup_Id,'') as NotificationCodeGroup_Id,
		ifnull(c050.NotificationCodeGroup_Name,'') as NotificationCodeGroup_Name,
		ifnull(c051.NotificationCode_Id,'') as NotificationCode_Id,
		ifnull(c051.NotificationCode_Name,'') as NotificationCode_Name,
		ifnull(c052.NotificationPriority_Id,'') as NotificationPriority_Id,
		ifnull(c052.NotificationPriority_Name,'') as NotificationPriority_Name,
        ifnull(m017.Product_Id,'') as Product_Id,
		ifnull(m017.Product_Name,'') as Product_Name
		FROM t037_sales_complaint_header T037
		INNER JOIN mu08_dealer MU08 on T037.Complaint_For_User_Id=MU08.Dealer_Id  
        and MU08.Org_Id= T037.Org_Id
        and T037.Complaint_For_User_Id = var_Dealer_Id
		INNER JOIN c035_complaintstatus C035 on T037.ComplaintStatus_Id=C035.ComplaintStatus_Id 
        inner join c034_complainttype c034 on c034.ComplaintType_Id = T037.ComplaintType_Id 
        left join c050_notificationcodegroup  c050 on 
		c050.Org_Id = t037.Org_Id
		and c050.NotificationCodeGroup_Id = t037.NotificationCodeGroup_Id
		left join c051_notificationcode  c051 on 
		c051.Org_Id = t037.Org_Id
		and c051.NotificationCode_Id = t037.NotificationCode_Id
		left join c052_notificationpriority  c052 on 
		c052.Org_Id = t037.Org_Id
		and c052.NotificationPriority_Id = t037.NotificationPriority_Id
        left join m017_product m017 on
		m017.Org_Id = t037.Org_Id
		and m017.Product_Id = t037.Product_Id
        where T037.Org_Id=var_Org_Id and T037.Complaint_By_User_Id=Var_SalesUser_Id
        AND CAST(T037.Complaint_Date AS DATE) >= var_StartDate 
		AND CAST(T037.Complaint_Date AS DATE) <= var_EndDate;
        
        else
        
        
        SELECT T037.Org_Id,T037.Complaint_Id,T037.Complaint_Remark,MU08.Dealer_Name as Name,
        T037.Complaint_By,T037.Complaint_For,C035.ComplaintStatus_Name,DATE_FORMAT(T037.Complaint_Date, '%D %M %Y') as Complaint_Date,
        c034.ComplaintType_Name,
        ifnull(T037.QualityNotification,'') as QualityNotification,
        ifnull(c050.NotificationCodeGroup_Id,'') as NotificationCodeGroup_Id,
		ifnull(c050.NotificationCodeGroup_Name,'') as NotificationCodeGroup_Name,
		ifnull(c051.NotificationCode_Id,'') as NotificationCode_Id,
		ifnull(c051.NotificationCode_Name,'') as NotificationCode_Name,
		ifnull(c052.NotificationPriority_Id,'') as NotificationPriority_Id,
		ifnull(c052.NotificationPriority_Name,'') as NotificationPriority_Name,
        ifnull(m017.Product_Id,'') as Product_Id,
		ifnull(m017.Product_Name,'') as Product_Name
		FROM t037_sales_complaint_header T037
		INNER JOIN mu08_dealer MU08 on T037.Complaint_For_User_Id=MU08.Dealer_Id  
        and MU08.Org_Id= T037.Org_Id
		INNER JOIN c035_complaintstatus C035 on T037.ComplaintStatus_Id=C035.ComplaintStatus_Id 
        inner join c034_complainttype c034 on c034.ComplaintType_Id = T037.ComplaintType_Id 
        left join c050_notificationcodegroup  c050 on 
		c050.Org_Id = t037.Org_Id
		and c050.NotificationCodeGroup_Id = t037.NotificationCodeGroup_Id
		left join c051_notificationcode  c051 on 
		c051.Org_Id = t037.Org_Id
		and c051.NotificationCode_Id = t037.NotificationCode_Id
		left join c052_notificationpriority  c052 on 
		c052.Org_Id = t037.Org_Id
		and c052.NotificationPriority_Id = t037.NotificationPriority_Id
        left join m017_product m017 on
		m017.Org_Id = t037.Org_Id
		and m017.Product_Id = t037.Product_Id
        where T037.Org_Id=var_Org_Id and T037.Complaint_By_User_Id=Var_SalesUser_Id
        AND CAST(T037.Complaint_Date AS DATE) >= var_StartDate 
		AND CAST(T037.Complaint_Date AS DATE) <= var_EndDate;
        
        end if;
		
        
        end;

    elseif(var_Method_Name = 'GetComplaintsRetailer') then
    
		begin
		
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Search_Period, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Search_Period, ' - ', -1), '%m/%d/%Y');
		
		SELECT T037.Org_Id,T037.Complaint_Id,T037.Complaint_Remark,MU09.Retailer_Name as Name,
        T037.Complaint_By,T037.Complaint_For,C035.ComplaintStatus_Name,DATE_FORMAT(T037.Complaint_Date, '%D %M %Y') as Complaint_Date,
        c034.ComplaintType_Name,
        ifnull(T037.QualityNotification,'') as QualityNotification,
        ifnull(c050.NotificationCodeGroup_Id,'') as NotificationCodeGroup_Id,
		ifnull(c050.NotificationCodeGroup_Name,'') as NotificationCodeGroup_Name,
		ifnull(c051.NotificationCode_Id,'') as NotificationCode_Id,
		ifnull(c051.NotificationCode_Name,'') as NotificationCode_Name,
		ifnull(c052.NotificationPriority_Id,'') as NotificationPriority_Id,
		ifnull(c052.NotificationPriority_Name,'') as NotificationPriority_Name,
        ifnull(m017.Product_Id,'') as Product_Id,
		ifnull(m017.Product_Name,'') as Product_Name
		FROM t037_sales_complaint_header T037
		INNER JOIN mu09_retailer MU09 on T037.Complaint_For_User_Id=MU09.Retailer_Id and MU09.Org_Id=var_Org_Id
		INNER JOIN c035_complaintstatus C035 on T037.ComplaintStatus_Id=C035.ComplaintStatus_Id  
		inner join c034_complainttype c034 on c034.ComplaintType_Id = T037.ComplaintType_Id 
		left join c050_notificationcodegroup  c050 on 
		c050.Org_Id = t037.Org_Id
		and c050.NotificationCodeGroup_Id = t037.NotificationCodeGroup_Id
		left join c051_notificationcode  c051 on 
		c051.Org_Id = t037.Org_Id
		and c051.NotificationCode_Id = t037.NotificationCode_Id
		left join c052_notificationpriority  c052 on 
		c052.Org_Id = t037.Org_Id
		and c052.NotificationPriority_Id = t037.NotificationPriority_Id
        left join m017_product m017 on
		m017.Org_Id = t037.Org_Id
		and m017.Product_Id = t037.Product_Id
        where T037.Org_Id=var_Org_Id and T037.Complaint_By_User_Id = Var_SalesUser_Id
        AND CAST(T037.Complaint_Date AS DATE) >= var_StartDate 
		AND CAST(T037.Complaint_Date AS DATE) <= var_EndDate;
	
		end;
     elseif(var_Method_Name = 'Getone') then 
     
		SELECT T037.Org_Id,T037.Complaint_Id,T037.Complaint_Remark,IFNULL(MU09.Retailer_Name,MU08.Dealer_Name) as Name,T037.Complaint_By,T037.Complaint_For,C035.ComplaintStatus_Name,DATE_FORMAT(T037.Complaint_Date, '%D %M %Y') as Complaint_Date
		FROM t037_sales_complaint_header T037
		INNER JOIN mu09_retailer MU09 on T037.Complaint_For_User_Id=MU09.Retailer_Id and MU09.Org_Id=var_Org_Id
		INNER JOIN c035_complaintstatus C035 on T037.ComplaintStatus_Id=C035.ComplaintStatus_Id  
        INNER JOIN mu08_dealer MU08 on T037.Complaint_For_User_Id=MU08.Dealer_Id  and MU08.Org_Id=var_Org_Id
        where T037.Org_Id=var_Org_Id and T037.Complaint_Id= var_Complaint_Id;
        
	elseif (var_Method_Name = 'Complaintchat')then
        
		select t037i.Complaint_Id, t037i.Remarks, DATE_FORMAT(t037i.Action_Date, '%d %M %Y') as Action_Date , ComplaintType_Name , ComplaintStatus_Name, t037.ComplaintStatus_Id ,
        if(Action_By_Id = var_Profile_Id , 1 , 0 )  as Chatside from 
        t037_sales_complaint_item t037i inner join t037_sales_complaint_header t037 on  t037.Org_Id = t037i.Org_Id 
		and t037i.Complaint_Id = t037.Complaint_Id 
		inner join c035_complaintstatus  c035 on t037.ComplaintStatus_Id = c035.ComplaintStatus_Id
		inner join c034_complainttype c034 on t037.ComplaintType_Id = c034.ComplaintType_Id
		where t037i.Complaint_Id = Var_Complaint_Id and t037i.Org_Id = var_Org_Id
        order by Action_Date asc;
	
    elseif(var_Method_Name = 'NotificationHeader') then 
		
        set @Complaint_For = (select Complaint_For from t037_sales_complaint_header t037
							where t037.Org_Id = var_Org_Id
							and t037.Complaint_Id = var_Complaint_Id limit 1);
        
        if(@Complaint_For = 'Retailer')then
        
			set @Retailer_Id = (select Complaint_For_User_Id from t037_sales_complaint_header t037
			where t037.Org_Id = var_Org_Id
			and t037.Complaint_Id = var_Complaint_Id limit 1);
            
            set @Retailer_Name = (select LEFT(Retailer_Name, 29) from mu09_retailer 
			where Org_Id = var_Org_Id
			and Retailer_Id = @Retailer_Id limit 1);


			set @Dealer_Id = (select Dealer_Id from mu09_retailer 
			where Org_Id = var_Org_Id
			and Retailer_Id = @Retailer_Id limit 1);

			set @Dealer_Code = (select Dealer_Code from mu08_dealer 
			where Org_Id = var_Org_Id
			and Dealer_Id = @Dealer_Id limit 1);
            
            if(@Dealer_Code is null or @Dealer_Code = '')then
            
				set @Dealer_Code = '';
                
			end if;
			
        end if;
        
		select 
		'W/"SADL-020240120045637C~20240120045637"' as '@odata.etag',
		'' as QualityNotification,
		'Q1' as NotificationOrigin,
		'Q1' as NotificationType,
		'EN' as MasterLanguage,
		 CASE 
			WHEN t037.Complaint_For = 'Dealer' THEN concat('Dealer - ', LEFT(mu08.Dealer_Name, 31))
			WHEN t037.Complaint_For = 'Retailer' THEN concat('Retailer - ', @Retailer_Name)
			ELSE ''
		END as NotificationText,
		'QM' as NotificationPriorityType,
		t037.NotificationPriority_Id as NotificationPriority,
		'QM000200000000' as NotificationStatusObject,
		'4' as NotifProcessingPhase,
		'D' as NotificationCatalog,
		t037.NotificationCodeGroup_Id as NotificationCodeGroup,
		t037.NotificationCode_Id as NotificationCodeID,
		concat(date(Complaint_Date)) as NotificationReportingDate,
		concat(date(Complaint_Date)) as NotificationCompletionDate,
		concat(date(Complaint_Date)) as NotificationRequiredStartDate,
		time(Complaint_Date) as NotificationRequiredStartTime,
		concat(date(Complaint_Date)) as NotificationRequiredEndDate,
		time(Complaint_Date) as NotificationRequiredEndTime,
		'INDIA' as NotificationTimeZone,
		'' as Supplier,
		CASE 
			WHEN t037.Complaint_For = 'Dealer' THEN mu08.Dealer_Code
			WHEN t037.Complaint_For = 'Retailer' THEN @Dealer_Code
			ELSE ''
		END as Customer,
		ifnull(m017.Product_Code,'') as Material,
		ifnull(m017.Product_Group,'') as MaterialGroup,
		'1100' as Plant,
		'' as PurchasingDocument,
		'0' as PurchasingDocumentItem,
		'' as PurchasingOrganization,
		'' as PurchasingGroup,
		'01' as ActiveDivision,
		'1000' as SalesOrganization,
		'01' as DistributionChannel,
		'0' as WBSElementInternalID,
		'' as WorkCenterTypeCode,
		'0' as MainWorkCenterInternalID,
		'' as MainWorkCenterPlant,
		'0' as InspectionLot,
		'' as Batch,
		'0000' as MaterialDocumentYear,
		'' as MaterialDocument,
		'0' as MaterialDocumentItem,
		false as IsBusinessPurposeCompleted,
		false as IsDeleted,
		'CB9980000018' as CreatedByUser,
		concat(date(Complaint_Date)) as CreationDate,
		'' as LastChangedByUser,
		CONCAT(DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%dT%H:%i:%s'), 'Z') as ChangedDateTime
		from t037_sales_complaint_header t037 
		left join m017_product m017 on
		m017.Org_Id = t037.Org_Id
		and m017.Product_Id = t037.Product_Id
		left join mu08_dealer mu08 on
		mu08.Org_Id = t037.Org_Id
		and mu08.Dealer_Id = t037.Complaint_For_User_Id
		where t037.Org_Id = var_Org_Id
		and t037.Complaint_Id = var_Complaint_Id limit 1;
		
	elseif(var_Method_Name = 'NotificationItem') then 
     
		select 
        'KU' as PartnerFunction,
        'CB9980000018' as NotificationPartner limit 1;
		
	
	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
