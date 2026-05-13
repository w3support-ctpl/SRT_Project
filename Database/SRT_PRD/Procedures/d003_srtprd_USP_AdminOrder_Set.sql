-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminOrder_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminOrder_Set`(
	var_Method_Name VARCHAR(50),
    var_Org_Id VARCHAR(10),
	var_Order_Id VARCHAR(20),
	var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(45),
	var_ApprovalStatus_Id INT,
    var_ApprovalRemarks LONGTEXT,
	var_Order_Data LONGTEXT,
	var_Order_For VARCHAR(20),
    var_Order_Type varchar(20)
)
BEGIN
	IF (var_Method_Name = 'Update') THEN
	BEGIN
		IF(var_ApprovalStatus_Id = 1) THEN
        BEGIN
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            DECLARE New_Product_Id VARCHAR(20);
            DECLARE New_Approved_Quantity INT;
            DECLARE Material_Total_Price DECIMAL(10,2);
            DECLARE New_Request_User_Id VARCHAR(45);
            DECLARE New_Deductions_Header_Id VARCHAR(45);
			DECLARE Year_Id VARCHAR(10);
			SET Material_Total_Price = 0.00;
            
			SET row_count := extractValue(var_Order_Data,'count(//Products/ProductItem)');
			WHILE k < row_count 
            DO        
				SET k := k + 1;
				SET xpath := concat('//Products/ProductItem[', k, ']');
            
				SET New_Product_Id = extractValue(var_Order_Data, concat(xpath,'/Product_Id'));
				SET New_Approved_Quantity = extractValue(var_Order_Data, concat(xpath,'/Approved_Quantity'));
			
				UPDATE t023_order_item
				SET Approved_Quantity = New_Approved_Quantity,
                Is_Posted = 1,
					Total_Price = (New_Approved_Quantity * CAST(Rate AS UNSIGNED))
				WHERE Product_Id = New_Product_Id
                AND Order_Id = var_Order_Id
				AND Org_Id = var_Org_Id;
			END WHILE;
                
			UPDATE t023_order_header
			SET Approval_Remarks = var_ApprovalRemarks,
				Approved_On =CONVERT_TZ(NOW(), '+00:00', '+00:00'),
				Is_Approved = var_ApprovalStatus_Id,
                Approved_Id = var_User_Id,
                Approved_Name = var_User_Name
			WHERE Org_Id = var_Org_Id 
			AND Order_Id = var_Order_Id
            AND Order_Type = var_Order_Type;  
			
            SET New_Request_User_Id = (
				SELECT Order_For_User_Id
                FROM t023_order_header
                WHERE Org_Id = var_Org_Id 
				AND Order_Id = var_Order_Id
				-- AND Order_Type = var_Order_Type
			);
            
            
            
             -- Generate Deductions Header ID
			SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
			CALL USP_Number_Range ('t033_deductions_header', Year_Id, 'T033', '', New_Deductions_Header_Id);
                
            -- Getting Sum of Total Price for All Materials
            SET Material_Total_Price = (
				SELECT SUM(Total_Price)
				FROM t023_order_item
				WHERE Order_Id = var_Order_Id
				AND Org_Id = var_Org_Id
			);
            
            select MCC_Id into @MCC_Id 
            from  t023_order_header 
            where Order_Id = var_Order_Id 
            and Org_Id =Org_Id;
            
                
			-- Insert new row in Deductions Header table on Approval of Material
			INSERT INTO t033_deductions_header(
				Org_Id, Deductions_Id, Entry_Date, 
				Request_User_Type, Request_User_Id, MCC_Id,
				Request_Type, Total_Amount, 
				Amount_Deducted, Balance, 
				Is_Closed, No_Of_Installments, 
				CreatedBy_Id, CreatedBy_Name 
			)
			VALUES(
				var_Org_Id, New_Deductions_Header_Id, CONVERT_TZ(NOW(), '+00:00', '+00:00'),
				var_Order_For, New_Request_User_Id,@MCC_Id ,
				'Product', Material_Total_Price,
				0, Material_Total_Price,
				0, 0,
				var_User_Id, var_User_Name
			);
                
                       
            
			SELECT 1 AS Result_Id, 
			'Approved' AS Result_Description, 
			var_Order_Id AS Result_Extra_Key;
        END;
		ELSE 
		-- Rejected
        BEGIN
            UPDATE t023_order_header
			SET Approval_Remarks = var_ApprovalRemarks,
				Approved_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
				Is_Approved = var_ApprovalStatus_Id,
                Approved_Id = var_User_Id,
                Approved_Name = var_User_Name
			WHERE Org_Id = var_Org_Id 
			AND Order_Id = var_Order_Id
			AND Order_Type = var_Order_Type;  
            
			SELECT 1 AS Result_Id, 
			'Rejected' AS Result_Description, 
			var_Order_Id AS Result_Extra_Key;
        END;
        END IF;
	
	END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
