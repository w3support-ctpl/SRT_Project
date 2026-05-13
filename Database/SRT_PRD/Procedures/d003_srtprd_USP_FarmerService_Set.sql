-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerService_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerService_Set`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
var_MCC_Id varchar(20),
Var_Service_Id varchar(20),
Var_ServiceType_Id varchar(20),
Var_Profile_Id varchar(20),
Var_Material_Id varchar(20),
Var_Material_Quantity varchar(20),
Var_Service_Details varchar(20),
Var_Service_Remark text
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

if (Var_Method_Name = 'ApplyRequest') then

            select MCC_Id INTO @var_MCC_Id
            from mu04_farmer
            where Farmer_Id = var_Profile_Id AND Org_Id = var_Org_Id AND Is_Deleted = 0;
            

	if exists(select 1 from t003_service where Org_Id = Var_Org_Id and Service_Id = Var_Service_Id and MCC_Id = @var_MCC_Id and 
    Request_For_User_Id = Var_Profile_Id and Is_Approved = 0) then 

		select -1 as Result_Id, 'Already Applied' as Result_Description, '' as Result_Extra_Key;    

	else 
    
		if(Var_ServiceType_Id = 'C026003')then
			
			set @Order_Id = '';
			set @Year_Id = (select right(left(curdate(),4),(2)));
			
			Call USP_Number_Range ('t023_order_header', @Year_Id, 'T023', '', @Order_Id );
			
		   set @Rate = 30.20;
		   set @Total_Price = @Rate * Var_Material_Quantity;
				 
			insert into t023_order_header(Org_Id,Order_Id, Order_For, Order_For_User_Id, Order_By,Order_By_User_Id, Order_Date, Is_Approved ,
			Total_Item , Total_Price , Is_Active , Created_On , Created_By , MCC_Id , Order_Type
			) values (Var_Org_Id , @Order_Id , 'Farmer',Var_Profile_Id, 'Farmer' , Var_Profile_Id , @Current_Datetime, 0 , Var_Material_Quantity, @Total_Price , 1 ,  @Current_Datetime , Var_Profile_Id , @var_MCC_Id  , 'Material') ;
			
			insert into t023_order_item (Org_Id , Order_Id , Product_Id ,Quantity ,Rate , Total_Price ) 
			select Var_Org_Id ,  @Order_Id  ,  Var_Material_Id , Var_Material_Quantity, @Rate, @Total_Price ;
			
			select 1 as Result_Id, 'Successfully Applied' as Result_Description, '' as Result_Extra_Key;   
            
        else
		
			set @Year_Id = (select right(left(curdate(),4),(2)));
			set @Request_Id  = '';
			Call USP_Number_Range ('t003_service', @Year_Id, 'T003', '', @Request_Id );
			
			INSERT INTO t003_service (Org_Id , Request_Id, Service_Id,MCC_Id, Request_For, Request_For_User_Id , Request_By , Request_By_User_Id ,
			Request_Date,Is_Approved , Request_Amount , Request_Remark , ServiceType_Id
			) values (
			Var_Org_Id,  @Request_Id , Var_Service_Id , @var_MCC_Id , 'Farmer' , Var_Profile_Id , 'Farmer' , Var_Profile_Id , @Current_Datetime , 0 ,
             CAST(Var_Service_Details AS DECIMAL(8, 2)) , Var_Service_Remark , Var_ServiceType_Id
			) ;
	
			select 1 as Result_Id, 'Successfully Applied' as Result_Description, '' as Result_Extra_Key;   
	
    end if;
        end if;
    
end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
