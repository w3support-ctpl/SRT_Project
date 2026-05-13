-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminIssueCrate` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminIssueCrate`(
var_Org_Id varchar(20),
var_Dealer_Code varchar(20),
var_Dealer_Name varchar(100),
var_Dispatch_Date varchar(20),
var_Quantity varchar(20),
var_Material_Code varchar(20),
var_Invoice_Number varchar(20),
var_Delivery_Item varchar(50)
)
BEGIN
	
	
    if(var_Dealer_Code in (null , '', ' ' )) then
    
    			SELECT -1 AS Result_Id, 
			'Dealer Code Should Not Be Empty' AS Result_Description, 
			'' AS Result_Extra_Key;
            
	else 
        
        DELETE FROM t039_dispatch_crate 
        WHERE Invoice_Number = var_Invoice_Number 
          AND Dealer_Code = var_Dealer_Code 
          AND Material_Code = var_Material_Code 
          AND Dispatch_Date = var_Dispatch_Date
          And Quantity = var_Quantity
          and Delivery_Item = var_Delivery_Item;
          
        
    SET @Year_Id = (select right(left(curdate(),4),(2)));
	CALL USP_Number_Range ('t039_dispatch_crate', @Year_Id, 'T039', '', @New_Id );

    insert into t039_dispatch_crate (Org_Id, Dispatch_Id, Dealer_Code, Dealer_Name,
    Dispatch_Date, Quantity, Material_Code, Invoice_Number, Created_On,Delivery_Item 
    )  
    select var_Org_Id , @New_Id , var_Dealer_Code , var_Dealer_Name , var_Dispatch_Date , 
    if (var_Quantity like '%-'  ,  replace(var_Quantity , var_Quantity , concat( '-' , replace(var_Quantity , '-','' )) ) , var_Quantity ) 
    ,var_Material_Code , var_Invoice_Number , now(),var_Delivery_Item
    ;

			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			'' AS Result_Extra_Key;
            
end if ;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
