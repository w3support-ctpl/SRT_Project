-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminOrder_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminOrder_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Order_Id varchar(20),
    var_ApprovalStatus_Id varchar(20),
	var_Date varchar(60),
	var_Order_For varchar(20),
    var_Order_Type varchar(20)
)
BEGIN

	SET @ApprovalStatus_Id = var_ApprovalStatus_Id;
	IF((var_ApprovalStatus_Id = '') OR (var_ApprovalStatus_Id IS NULL)) THEN
    BEGIN
		SET @ApprovalStatus_Id := '0,1,-1';
    END;
    END IF;

    IF (var_Method_Name = 'Get') THEN
    BEGIN
        SELECT
            orderheader.Org_Id, orderheader.Order_Id, orderheader.Order_For,
            orderheader.Order_For_User_Id AS OrderFor_Id,
            IFNULL( CASE orderheader.Order_For
                    WHEN 'farmer' THEN farmer_req_for.Farmer_Id
                    WHEN 'agent' THEN agent_req_for.Agent_Id
			END, '') AS Farmer_Agent_Id_Order_For,
            IFNULL( CASE orderheader.Order_For
                    WHEN 'farmer' THEN farmer_req_for.Farmer_Name
                    WHEN 'agent' THEN agent_req_for.Agent_Name
			END, '') AS Farmer_Agent_Name_Order_For,
            IFNULL(
                CASE orderheader.Order_For
                    WHEN 'farmer' THEN farmer_req_for.Mobile_No
                    WHEN 'agent' THEN agent_req_for.Mobile_No
                    ELSE ''
			END, '') AS Mobile_No_Order_For,
            DATE_FORMAT(orderheader.Order_Date, '%d %M %Y') AS Order_Date,
            -- DATE_FORMAT(orderheader.Order_Date, '%Y-%m-%d') AS Order_Date,
            ifnull(DATE_FORMAT(orderheader.Approved_On, '%d %M %Y'),'') AS Approved_On,
            orderheader.Total_Item, orderheader.Total_Price,
            orderheader.Is_Approved, orderheader.Approval_Remarks
            -- COUNT(product.Product_Name) AS Product_Name
        FROM t023_order_header orderheader 
        LEFT JOIN mu04_farmer farmer_req_for 
			ON orderheader.Order_For = 'farmer' 
			AND farmer_req_for.Farmer_Id = orderheader.Order_For_User_Id
            AND farmer_req_for.Org_Id = orderheader.Org_Id
        LEFT JOIN mu05_agent agent_req_for 
			ON orderheader.Order_For = 'agent' 
            AND agent_req_for.Agent_Id = orderheader.Order_For_User_Id
            AND agent_req_for.Org_Id = orderheader.Org_Id
		-- LEFT JOIN t023_order_item orderitem ON orderheader.Order_Id = orderitem.Order_Id
		-- LEFT JOIN m017_product product ON orderitem.Product_Id = product.Product_Id
        WHERE orderheader.Org_Id = var_Org_Id
			AND FIND_IN_SET(orderheader.Is_Approved, @ApprovalStatus_Id)
			AND  CAST(orderheader.Order_Date  AS DATE)  
				BETWEEN STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y')
				AND STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y')
			AND orderheader.Order_For = var_Order_For
            AND orderheader.Order_Type = var_Order_Type
            
		-- GROUP BY
			-- orderheader.Org_Id, orderheader.Order_Id, orderheader.Order_For,
            -- orderheader.Order_For_User_Id, Farmer_Agent_Id_Order_For, 
            -- Farmer_Agent_Name_Order_For,Mobile_No_Order_For, Order_Date,
            -- Approved_On, orderheader.Total_Item, orderheader.Total_Price,
            -- orderheader.Is_Approved, orderheader.Approval_Remarks
        
        ORDER BY orderheader.Order_Id;
	END;
    ELSEIF (var_Method_Name = 'Get_One' )THEN
    BEGIN
        SELECT
            orderitem.Org_Id, orderitem.Order_Id, orderitem.Quantity, orderitem.Rate, orderitem.Total_Price,
            product.Product_Id, product.Product_Code, product.Product_Name, product.Product_Group
        FROM t023_order_item orderitem
        INNER JOIN m017_product product ON product.Product_Id = orderitem.Product_Id and product.Org_Id = orderitem.Org_Id
        WHERE orderitem.Org_Id = var_Org_Id 
        AND orderitem.Order_Id = var_Order_Id;
	END;

    ELSEIF (var_Method_Name = 'Get_Orders' )THEN
    BEGIN
        SELECT orderitem.Org_Id, orderitem.Order_Id, orderitem.Product_Id, product.Product_Name,
			   orderitem.Quantity, orderitem.Rate, orderitem.Total_Price, 
               IFNULL(orderitem.Approved_Quantity, '0') AS Approved_Quantity
		FROM t023_order_item orderitem
        INNER JOIN m017_product product ON product.Product_Id = orderitem.Product_Id and product.Org_Id = orderitem.Org_Id
        WHERE orderitem.Order_Id = var_Order_Id
        AND orderitem.Org_Id = var_Org_Id
        AND product.Org_Id = var_Org_Id;
	END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
