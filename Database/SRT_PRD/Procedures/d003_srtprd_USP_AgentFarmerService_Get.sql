-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerService_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerService_Get`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Service_Id varchar(20),
Var_SeviceType_Id varchar(20),
Var_Profile_Id varchar(20),
Var_Farmer_Id varchar(20)
)
BEGIN
set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    
	if (Var_Method_Name = 'GetService') then
		select distinct m012.ServiceType_Id , c027.Sevice_Image as Service_Image , 
        c027.Service_Description as Service_Description , c027.ServiceType_Name
        from m012_service m012 inner join c027_servicetype c027 on c027.ServiceType_Id = m012.ServiceType_Id 
        where Org_Id = Var_Org_Id and Is_For_Farmer = 1 and c027.is_active = 1 and m012.is_active = 1 ;

	elseif(Var_Method_Name = 'GetServiceById') then 
		
        select Service_Id , Service_Name , ServiceType_Id , Service_Description , Condition_1 , Material_Id , 0.0 as Material_Rate
        from 
        m012_service where Org_Id = Var_Org_Id and Is_For_Farmer = 1 and ServiceType_Id = Var_SeviceType_Id and is_active = 1;

    elseif (Var_Method_Name = 'GetAppliedServices') then 
		
     
	drop temporary table if exists temp_tblservice;
	create Temporary table temp_tblservice(  
    ServiceRequest_Id varchar(20),
    ServiceName varchar(50) ,
    ServiceTypeName varchar(100) ,
	ServiceTypeId varchar(20) ,
    Service_Id varchar(20),
    AplliedService_Details varchar(20), 
    ApprovedService_Details varchar(20), 
    ServiceProvide_Date varchar(20) ,
    Approval_Remarks varchar(250),
    Is_Approved int,
    AppliedDate varchar(40) 
    );
        
		insert into temp_tblservice(    ServiceRequest_Id  , ServiceName , ServiceTypeName , ServiceTypeId , Service_Id , AplliedService_Details , ApprovedService_Details , ServiceProvide_Date , Approval_Remarks , Is_Approved , AppliedDate )
        select Request_Id as ServiceRequest_Id,  m012.Service_Name as ServiceName, c027.ServiceType_Name as ServiceTypename , t003.ServiceType_Id as ServiceTypeId , t003.Service_Id , 
        ifnull(Request_Amount, '-') as AplliedService_Details , ifnull( if(t003.Is_Approved = 1 ,Approved_Amount , '0' ) , '0') as ApprovedService_Details ,ifnull(DATE_FORMAT(VeterinaryService_Date, '%e %b %Y') , '-')as ServiceProvide_Date , t003.Approval_Remarks as Approval_Remarks , 
        t003.Is_Approved as Is_Approved ,  DATE_FORMAT(Request_Date, '%e %b %Y') as AppliedDate
        from t003_service t003 inner join m012_service m012 on t003.Org_Id = m012.Org_Id and t003.Service_Id = m012.Service_Id
        inner join c027_servicetype c027 on c027.ServiceType_Id = t003.ServiceType_Id
        where t003.Org_Id = Var_Org_Id and Request_For_User_Id = Var_Farmer_Id;
        
		insert into temp_tblservice( ServiceRequest_Id  , ServiceName , ServiceTypeName , ServiceTypeId , Service_Id , AplliedService_Details , ApprovedService_Details , ServiceProvide_Date , Approval_Remarks , Is_Approved , AppliedDate )
		select t023.Order_Id as ServiceRequest_Id,  m010.Material_Name as ServiceName, Order_Type as ServiceTypename ,'C026003' as ServiceTypeId , t023i.Product_Id as Service_Id , 
        ifnull(Total_Item, '-') as AplliedService_Details , ifnull( if(t023.Is_Approved = 1 ,Approved_Quantity , '0' )  , '0') as ApprovedService_Details , ifnull(DATE_FORMAT(t023.Approved_On, '%e %b %Y') , '--') as ServiceProvide_Date , 
        t023.Approval_Remarks as Approval_Remarks ,  t023.Is_Approved as Is_Approved , DATE_FORMAT(t023.Order_Date, '%e %b %Y') as AppliedDate
        from t023_order_header t023 inner join t023_order_item t023i on t023.Org_Id = t023i.Org_Id and t023.Order_Id = t023i.Order_Id 
        inner join m010_material m010 on  t023i.Org_Id = m010.Org_Id and t023i.Product_Id = m010.Material_Id 
        where t023.Org_Id = Var_Org_Id and t023.Order_For_User_Id = Var_Farmer_Id and t023.Is_Active = 1;
        
        
        select * from temp_tblservice order by AppliedDate desc ;

        elseif(Var_Method_Name = 'GetServiceMaterial') then
        
        select Material_Id , Material_Code , Material_Name , MaterialType_Id from m010_material where
        Org_Id = Var_Org_Id and Is_Active = 1;
        
	end if ;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
