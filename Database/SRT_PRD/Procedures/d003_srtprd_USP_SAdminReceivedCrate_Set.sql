-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminReceivedCrate_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminReceivedCrate_Set`(
	var_Org_Id VARCHAR(10),
    var_Method_Name VARCHAR(20),
    var_User_Id VARCHAR(20),
    var_User_Name VARCHAR(45),
    var_Dealer_Id varchar(45),
    var_ReceivedCrate_Id VARCHAR(20),
    var_Is_Approved INT,
    var_Approved_Data LONGTEXT,
    Var_Date varchar(20)
)
BEGIN
SET SQL_SAFE_UPDATES = 0;

	IF(var_Method_Name = 'Update') THEN
    BEGIN
    
		UPDATE t038_receivedcrate_header
        SET Is_Approved = 0,
		ApprovedBy_Id = var_User_Id,
		ApprovedBy_Name = var_User_Name
        WHERE ReceivedCrate_Id = var_ReceivedCrate_Id
        AND Org_Id = var_Org_Id;
        
        -- set approved quantity to item table
        SET @row_count := extractValue(var_Approved_Data,'count(//ApprovedData/Item)');
		SET @k := 0;
		WHILE @k < @row_count DO        
			SET @k := @k + 1;
			SET @xpath := concat('//ApprovedData/Item[', @k, ']');
			
            UPDATE  t038_receivedcrate_item 
			SET Is_Approved = 0, 
            -- Quantity =   extractValue(var_Approved_Data, concat(@xpath,'/GoodQuantity')) + 
            -- extractValue(var_Approved_Data, concat(@xpath,'/BrokenQuantity')) + 
            -- extractValue(var_Approved_Data, concat(@xpath,'/ThirdPartyQuantity')) ,
            Quantity =  extractValue(var_Approved_Data, concat(@xpath,'/Quantity')),
            Good_Quantity = extractValue(var_Approved_Data, concat(@xpath,'/GoodQuantity')),
            Broken_Quantity =  extractValue(var_Approved_Data, concat(@xpath,'/BrokenQuantity')),
            ThirdParty_Quantity = extractValue(var_Approved_Data, concat(@xpath,'/ThirdPartyQuantity'))
			WHERE ReceivedCrate_Id = var_ReceivedCrate_Id
			AND Material_Id = extractValue(var_Approved_Data, concat(@xpath,'/MaterialId'))
            AND Org_Id = var_Org_Id;
			
		END WHILE;
        
        -- Send Success Message
		SELECT 1 AS Result_Id, 
		'Approved' AS Result_Description, 
		var_ReceivedCrate_Id AS Result_Extra_Key;
    
    END;
    
	ELSEIF (var_Method_Name = 'Create' or var_Method_Name = 'CreateNew') THEN
    Begin
		-- Declare required variabled for new record
		DECLARE New_CrateReceipt_Id VARCHAR(20);
		DECLARE Year_Id VARCHAR(10);
        
        
        If exists (select 1 from t038_receivedcrate_header 
        where Dealer_Id = var_Dealer_Id and date(Created_On) = date(Var_Date) and var_Method_Name = 'Create') then
		
			SELECT -1 AS Result_Id, 
			'Alredy Crate Received' AS Result_Description, 
			'' AS Result_Extra_Key;
	
    else

        -- Generate Id
		SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
		CALL USP_Number_Range ('t038_receivedcrate_header', Year_Id, 'T038', '', New_CrateReceipt_Id);
			
	
		Insert into t038_receivedcrate_header 
        (Org_Id, ReceivedCrate_Id, Dealer_Id, SalesUser_Id, UserType, Is_Approved, Date,
        ApprovedBy_Id, ApprovedBy_Name  , Created_On , CreatedBy_Id )
        values (var_Org_Id, New_CrateReceipt_Id, var_Dealer_Id, '', 'Dealer', 0,
        now() , var_User_Id, var_User_Name , Var_Date , var_User_Id);
               
        -- set approved quantity to item table
        SET @row_count := extractValue(var_Approved_Data,'count(//ApprovedData/Item)');
		SET @k := 0;
		WHILE @k < @row_count DO        
			SET @k := @k + 1;
			SET @xpath := concat('//ApprovedData/Item[', @k, ']');
            
            insert into t038_receivedcrate_item(
           Org_Id, ReceivedCrate_Id, Material_Id, MaterialType_Id, Quantity, Good_Quantity, Broken_Quantity, ThirdParty_Quantity, Is_Approved , Is_Posted
            ) value
            (var_Org_Id,
            New_CrateReceipt_Id,
            extractValue(var_Approved_Data, concat(@xpath,'/MaterialId')),
            (select MaterialType_Id from m010_material
            where Org_Id = var_Org_Id and Material_Id = extractValue(var_Approved_Data, concat(@xpath,'/MaterialId'))),
           extractValue(var_Approved_Data, concat(@xpath,'/GoodQuantity')) + 
            extractValue(var_Approved_Data, concat(@xpath,'/BrokenQuantity')) + 
            extractValue(var_Approved_Data, concat(@xpath,'/ThirdPartyQuantity')) ,
            
            extractValue(var_Approved_Data, concat(@xpath,'/GoodQuantity')),
            extractValue(var_Approved_Data, concat(@xpath,'/BrokenQuantity')),
            extractValue(var_Approved_Data, concat(@xpath,'/ThirdPartyQuantity')),
            1 , 1
            );

					
		END WHILE;
        
        -- Send Success Message
		SELECT 1 AS Result_Id, 
		'Saved' AS Result_Description, 
		New_CrateReceipt_Id AS Result_Extra_Key;
	
		end if;
        
    End;
	ELSEIF (var_Method_Name = 'Create_1' or var_Method_Name = 'CreateNew_1') THEN
    Begin
		-- Declare required variabled for new record
		DECLARE New_CrateReceipt_Id VARCHAR(20);
		DECLARE Year_Id VARCHAR(10);
        
        
        If exists (select 1 from t038_receivedcrate_header 
        where Dealer_Id = var_Dealer_Id and date(Created_On) = date(Var_Date) and var_Method_Name = 'Create') then
		
			SELECT -1 AS Result_Id, 
			'Alredy Crate Received' AS Result_Description, 
			'' AS Result_Extra_Key;
	
    else

        -- Generate Id
		SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
		CALL USP_Number_Range ('t038_receivedcrate_header', Year_Id, 'T038', '', New_CrateReceipt_Id);
			
	
		Insert into t038_receivedcrate_header 
        (Org_Id, ReceivedCrate_Id, Dealer_Id, SalesUser_Id, UserType, Is_Approved, Date,
        ApprovedBy_Id, ApprovedBy_Name  , Created_On , CreatedBy_Id )
        values (var_Org_Id, New_CrateReceipt_Id, var_Dealer_Id, '', 'Dealer', 0,
        now() , var_User_Id, var_User_Name , Var_Date , var_User_Id);
               
        -- set approved quantity to item table
        SET @row_count := extractValue(var_Approved_Data,'count(//ApprovedData/Item)');
		SET @k := 0;
		WHILE @k < @row_count DO        
			SET @k := @k + 1;
			SET @xpath := concat('//ApprovedData/Item[', @k, ']');
            
            insert into t038_receivedcrate_item(
           Org_Id, ReceivedCrate_Id, Material_Id, MaterialType_Id, Quantity, Good_Quantity, Broken_Quantity, ThirdParty_Quantity, Is_Approved , Is_Posted
            ) value
            (var_Org_Id,
            New_CrateReceipt_Id,
            extractValue(var_Approved_Data, concat(@xpath,'/MaterialId')),
            (select MaterialType_Id from m010_material
            where Org_Id = var_Org_Id and Material_Id = extractValue(var_Approved_Data, concat(@xpath,'/MaterialId'))),
           -- extractValue(var_Approved_Data, concat(@xpath,'/Quantity')) + 
            -- extractValue(var_Approved_Data, concat(@xpath,'/BrokenQuantity')) + 
            -- extractValue(var_Approved_Data, concat(@xpath,'/ThirdPartyQuantity')) ,
            extractValue(var_Approved_Data, concat(@xpath,'/Quantity')),
            extractValue(var_Approved_Data, concat(@xpath,'/GoodQuantity')),
            extractValue(var_Approved_Data, concat(@xpath,'/BrokenQuantity')),
            extractValue(var_Approved_Data, concat(@xpath,'/ThirdPartyQuantity')),
            1 , 1
            );

					
		END WHILE;
        
        -- Send Success Message
		SELECT 1 AS Result_Id, 
		'Saved' AS Result_Description, 
		New_CrateReceipt_Id AS Result_Extra_Key;
	
		end if;
        
    End;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
