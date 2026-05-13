-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminSalesInquiry_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminSalesInquiry_Set`(
	var_Org_Id VARCHAR(20),
	var_Method_Name VARCHAR(20),
	var_User_Id VARCHAR(20),
	var_User_Name VARCHAR(45),
	var_SalesInquiry VARCHAR(20),
    var_SalesArea VARCHAR(20),
    var_Destination VARCHAR(45),
    var_CustomerReference VARCHAR(45),
    var_SalesNote VARCHAR(45),
    var_Item_Id VARCHAR(20),
    var_Rate DECIMAL(10,2),
    var_Quantity VARCHAR(45),
    var_UOM VARCHAR(45),
    var_Price DECIMAL(10,2),
    var_LrDetails LONGTEXT,
    var_ProductionInstructions LONGTEXT,
    var_Is_Active INT,
    var_Is_Deleted INT,
    var_Entry_Item_Id VARCHAR(20),
    var_Dealer_Id VARCHAR(20),
    var_Inquiry_Status INT,
    var_sales_person varchar(20),
    var_Retailer_Id VARCHAR(45),
    var_SalesUser_Id VARCHAR(45)
)
BEGIN
	-- create new record in sales inquiry header table
	IF(var_Method_Name = 'Create') THEN
    BEGIN
		-- generate new SalesInquiry ID for new record
        -- Declare required variabled for new record
		DECLARE New_SalesInquiry VARCHAR(20);
		DECLARE Year_Id VARCHAR(10);
        -- Generate Id
		SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
		CALL USP_Number_Range ('t040_salesinquiry_header', Year_Id, 'T040', '', New_SalesInquiry);
        
        -- create new record in header table
        INSERT INTO t040_salesinquiry_header(
			Org_Id, SalesInquiry, 
            Dealer_Id, CustomerReference, InquiryStatus_Id,
            SalesInquiryType, SalesOrganization, 
            DistributionChannel, OrganizationDivision, CustomerPaymentTerms, 
            IncotermsClassification, PurchaseOrderByCustomer, DestinationText, 
            SalesNoteText, SoldToParty, ShipToParty, BillToParty, Transporter, Payer, 
            SalesPerson, 
            Is_Active, Is_Deleted, 
            Created_On, 
            CreatedBy_Id, CreatedBy_Name,
            Retailer_Id,SalesUser_Id
        )
		VALUES(
			var_Org_Id, New_SalesInquiry, 
            var_Dealer_Id, var_CustomerReference, var_Inquiry_Status,
            '', var_SalesArea, 
            var_SalesArea, var_SalesArea, '', 
            '', '', var_Destination, 
            var_SalesNote, '', '', '', '', '', var_sales_person, 
            var_Is_Active, var_Is_Deleted, 
            CONVERT_TZ(NOW(), '+00:00', '+00:00'), 
            var_User_Id, var_User_Name ,var_Retailer_Id,var_SalesUser_Id
        );
	   SELECT 1 AS Result_Id, 
		'Created' AS Result_Description, 
		New_SalesInquiry AS Result_Extra_Key;
    END;
    -- update existing record in sales inquiry header table
    ELSEIF(var_Method_Name = 'Update') THEN
    BEGIN
		UPDATE t040_salesinquiry_header
        SET
			Dealer_Id = var_Dealer_Id, 
			CustomerReference = var_CustomerReference, 
			InquiryStatus_Id = var_Inquiry_Status,
            SalesInquiryType = '', 
            SalesOrganization = var_SalesArea, 
            DistributionChannel = var_SalesArea, 
            OrganizationDivision = var_SalesArea, 
            CustomerPaymentTerms = '', 
            IncotermsClassification = '', 
            PurchaseOrderByCustomer = '', 
            DestinationText = var_Destination, 
            SalesNoteText= var_SalesNote, 
            SoldToParty = '', 
            ShipToParty = '', 
            BillToParty = '', 
            Transporter = '', 
            Payer = '', 
            SalesPerson = var_sales_person, 
            Is_Active = var_Is_Active, 
            Is_Deleted = var_Is_Deleted,
            LastEdited_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
            LastEditedBy_Id = var_User_Id,
            LastEditedBy_Name = var_User_Name
		WHERE Org_Id = var_Org_Id
        AND SalesInquiry = var_SalesInquiry;
		SELECT 1 AS Result_Id, 
		'Updated' AS Result_Description, 
		var_SalesInquiry AS Result_Extra_Key;
    END;
    -- delete record from sales inquiry header table and all related 
    -- records in sales inquiry item table
    ELSEIF(var_Method_Name = 'Delete') THEN
    BEGIN
		-- set is_deleted=1 for header table
        UPDATE t040_salesinquiry_header
        SET Is_Deleted = 1
        WHERE Org_Id = var_Org_Id
        AND SalesInquiry = var_SalesInquiry;
        
        -- delete record where salesinquiry = var_salesinquiry
        DELETE FROM mu13_salesinquiry_item
		WHERE Org_Id = var_Org_Id
        AND SalesInquiry = var_SalesInquiry;
        
        SELECT 1 AS Result_Id, 
		'Deleted' AS Result_Description, 
		var_SalesInquiry AS Result_Extra_Key;
    END;
    -- create new record in item table
    ELSEIF(var_Method_Name = 'Create_Item') THEN
    BEGIN
		-- check if the item already exists in the table, if yes, then don't let user add the data.
        -- if no, create record and add to table
        IF EXISTS(
			SELECT Material
            FROM t040_salesinquiry_item
            WHERE Org_Id = var_Org_Id
			AND SalesInquiry = var_SalesInquiry
			AND Material = var_Item_Id
        ) THEN
        BEGIN
			SELECT -1 AS Result_Id, 
			'Item already exists' AS Result_Description, 
			'' AS Result_Extra_Key;
        END;
        ELSE
        BEGIN
			INSERT INTO t040_salesinquiry_item(
				Org_Id, Material, SalesInquiry, 
                RequestedQuantity, LrDetailsText, ProductionInstructionsText , Rate  , UOM , Price
            )
            VALUES(
				var_Org_Id, var_Item_Id, var_SalesInquiry,
                var_Quantity, var_LrDetails, '' , var_Rate , var_UOM , 
                -- var_Rate*var_Quantity
                CAST(var_Rate * var_Quantity AS DECIMAL(30,2))
            );
            SELECT 1 AS Result_Id, 
			'Created' AS Result_Description, 
			var_Item_Id AS Result_Extra_Key;
        END;
        END IF;
    END;
    -- update existing record in the item table
    ELSEIF(var_Method_Name = 'Update_Item') THEN
    BEGIN
		-- check if the item already exists in the table, if yes, then don't let user add the data.
        -- if no, update record in the table
        IF EXISTS(
			SELECT Material
            FROM t040_salesinquiry_item
            WHERE Org_Id = var_Org_Id
			AND SalesInquiry = var_SalesInquiry
			AND Material = var_Item_Id
            AND RequestedQuantity = var_Quantity
            and UOM = var_UOM
            and Rate = var_Rate
            -- and Price = var_Rate * var_Quantity
            and Price = CAST(var_Rate * var_Quantity AS DECIMAL(30,2))
        ) THEN
        BEGIN
			SELECT -1 AS Result_Id, 
			'Item already exists' AS Result_Description, 
			'' AS Result_Extra_Key;
        END;
        ELSE
        BEGIN
			UPDATE t040_salesinquiry_item
            SET Material = var_Item_Id, 
				SalesInquiry = var_SalesInquiry, 
                RequestedQuantity = var_Quantity,
                ProductionInstructionsText = '',
                Rate = var_Rate , 
                UOM = var_UOM,
                -- Price = var_Rate * var_Quantity
                Price = CAST(var_Rate * var_Quantity AS DECIMAL(30,2)),
                LrDetailsText =  var_LrDetails
			WHERE Org_Id = var_Org_Id
			AND SalesInquiry = var_SalesInquiry
			AND Material = var_Entry_Item_Id;
            
            SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_SalesInquiry AS Result_Extra_Key;
		END;
        END IF;
    END;
    -- delete individual record from item table where item_id = var_item_id
    ELSEIF(var_Method_Name = 'Delete_Item') THEN
    BEGIN
		-- delete record where salesinquiry = var_salesinquiry
        DELETE FROM t040_salesinquiry_item
		WHERE Org_Id = var_Org_Id
        AND SalesInquiry = var_SalesInquiry
        AND Material = var_Item_Id;
        
        SELECT 1 AS Result_Id, 
		'Deleted' AS Result_Description, 
		var_Item_Id AS Result_Extra_Key;
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
