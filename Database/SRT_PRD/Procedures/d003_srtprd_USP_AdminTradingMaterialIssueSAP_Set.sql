-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTradingMaterialIssueSAP_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTradingMaterialIssueSAP_Set`(
	var_Method_Name varchar(255),
	var_Org_Id varchar(255),
    var_Product_Id varchar(255),
	var_Order_Id varchar(255),
    var_SalesOrder varchar(255),
    var_NetAmount int
)
BEGIN
	if (var_Method_Name = 'Success') then
		begin
			DECLARE New_Deductions_Header_Id VARCHAR(45);
			DECLARE New_Entry_Id VARCHAR(45);
			DECLARE Year_Id VARCHAR(10);
            declare Set_MusterCycle_StartDate date;
            declare Set_MusterCycle_EndDate date;
    
			Update t023_order_item
			set 
            Is_Posted = 2,
			SalesOrder = var_SalesOrder,
            Total_Price = var_NetAmount
			where Org_Id = var_Org_Id 
            and Product_Id = var_Product_Id
			and Order_Id = var_Order_Id;  
            
            SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
			CALL USP_Number_Range ('t033_deductions_header', Year_Id, 'T033', '', New_Deductions_Header_Id);
			Call USP_Number_Range ('t033_deductions_item', Year_Id, 'T033A', '', New_Entry_Id );
		
            INSERT INTO t033_deductions_header(
				Org_Id, Deductions_Id, Entry_Date, 
				Request_User_Type, Request_User_Id, MCC_Id,
				Request_Type, Total_Amount, 
				Amount_Deducted, Balance, 
				Is_Closed, No_Of_Installments,
                 CreatedBy_Id, CreatedBy_Name
			)
			select 
			t023.Org_Id,
			New_Deductions_Header_Id,
			CONVERT_TZ(NOW(), '+00:00', '+00:00'),
			t023.Order_For,
			t023.MCC_Id,
			t023.MCC_Id,
			'M020231000008',
			t0231.Total_Price,
			0,
			t0231.Total_Price,
			0,1,
			t023.Approved_Id,t023.Approved_Name
			from t023_order_header t023
			inner join t023_order_item t0231 on
			t023.Org_Id = t0231.Org_Id
			and t023.Order_Id = t0231.Order_Id
			and t0231.Product_Id = var_Product_Id
			where t023.Org_Id = var_Org_Id
			and t023.Order_Id = var_Order_Id
            and t023.Order_For ='agent'
            and t023.Order_By ='agent'
            
            union all
            
            select 
			t023.Org_Id,
			New_Deductions_Header_Id,
			CONVERT_TZ(NOW(), '+00:00', '+00:00'),
			t023.Order_For,
			t023.Order_For_User_Id,
			t023.MCC_Id,
			'M020231000014',
			t0231.Total_Price,
			0,
			t0231.Total_Price,
			0,1,
			t023.Approved_Id,t023.Approved_Name
			from t023_order_header t023
			inner join t023_order_item t0231 on
			t023.Org_Id = t0231.Org_Id
			and t023.Order_Id = t0231.Order_Id
			and t0231.Product_Id = var_Product_Id
			where t023.Org_Id = var_Org_Id
			and t023.Order_Id = var_Order_Id
            and t023.Order_For ='farmer'
            and t023.Order_By ='farmer'
            ;
			
			INSERT INTO t033_deductions_item (
			Org_Id,Entry_Id, Deductions_Id, Deduction_Date, Deduction_Amount, Is_Deducted, 
			MusterCycle_StartDate, MusterCycle_EndDate) 
			select 
			t023.Org_Id,
			New_Entry_Id,
			New_Deductions_Header_Id,
			t023.Order_Date,
			t0231.Total_Price,
			0,
			t0231.MusterCycle_StartDate,
			t0231.MusterCycle_EndDate
			from t023_order_header t023
			inner join t023_order_item t0231 on
			t023.Org_Id = t0231.Org_Id
			and t023.Order_Id = t0231.Order_Id
			and t0231.Product_Id = var_Product_Id
			where t023.Org_Id = var_Org_Id
			and t023.Order_Id = var_Order_Id;
            
            
            Update t023_order_item
			set 
            Is_Deducted = 1
			where Org_Id = var_Org_Id 
            and Product_Id = var_Product_Id
			and Order_Id = var_Order_Id;  
            

			SELECT 1 AS Result_Id, 
			'Success' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Error') then
		begin
			Update t023_order_item
			set 
            Is_Posted = 3
			where Org_Id = var_Org_Id 
            and Product_Id = var_Product_Id
			and Order_Id = var_Order_Id;  

			SELECT 1 AS Result_Id, 
			'Error' AS Result_Description, 
			var_Org_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
