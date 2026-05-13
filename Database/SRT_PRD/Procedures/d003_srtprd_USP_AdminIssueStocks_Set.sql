-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminIssueStocks_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminIssueStocks_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_IssueStocks_Id varchar(20),
    Var_IssueStock_Type varchar(45),
    var_Route_Id varchar(20),
    Var_MCC_Id varchar(20),
    var_Vehicle_Id varchar(20),
    var_CollectionShift_Id varchar(20),
    var_IssueStocks_Date date,
    var_Driver_Id varchar(20),
    Var_Driver_Name varchar(255),
    Var_Vehicle_No varchar(20),
    Var_DriverMobile_No varchar(10),
    Var_Profile_Id varchar(20),
    Var_XMLData longtext,
    var_Mobile_No varchar(20)
)
BEGIN
	SET SESSION sql_require_primary_key = 0;
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

   if(var_Method_Name = 'Create') then
	
    
		set @Year_Id = (select right(left(curdate(),4),(2)));
		Call USP_Number_Range ('t018_issuestocks_header', @Year_Id, 'T018', '', @IssueStocks_Id );
        
        
		INSERT INTO t018_issuestocks_header(
			Org_Id ,IssueStocks_Id, StockIssue_Type, MCC_Id, 
            Route_Id, Vehicle_Id, Driver_Name, Vehicle_Number,
			CollectionShift_Id, Driver_Id, IssueStock_Date, 
            Created_On, CreatedBy_Id, Mobile_No
		) 
		VALUES(
			var_Org_Id, @IssueStocks_Id, Var_IssueStock_Type, Var_MCC_Id,
            var_Route_Id, var_Vehicle_Id, Var_Driver_Name, Var_Vehicle_No,
			var_CollectionShift_Id, var_Driver_Id, var_IssueStocks_Date, 
			@Current_Datetime, Var_Profile_Id, var_Mobile_No
		);
       
       IF(Var_IssueStock_Type = 'Cans') THEN
       BEGIN
       
			UPDATE t018_issuestocks_header
            SET Vehicle_Number =
            IFNULL((
				SELECT Vehicle_No 
                FROM m003_vehicle
                WHERE Vehicle_Id = var_Vehicle_Id
            ),'');
       
			-- save all mcc & materials with quantity as null to issuestocks_item table
			INSERT INTO t019_issuestocks_item(
				Org_Id, IssueStocks_Id, IssueStockToProfile_Id, 
                Order_Id,
				Material_Id, MCC_Id, IssueStockToProfile_Type, 
				MCC_CollectionShift_Id, Quantity, Is_MCCAccepted, TripDocument_Id
			)
			SELECT var_Org_Id AS Org_Id, @IssueStocks_Id AS IssueStocks_Id, mcc.MCC_Id AS IssueStockToProfile_Id,
				'0',
                material.Material_Id, mcc.MCC_Id, 'MCC' AS IssueStockToProfile_Type,
				var_CollectionShift_Id AS MCC_CollectionShift_Id, 0 AS Quantity,
				0 AS Is_MCCAccepted, '' AS TripDocument_Id
			FROM m007_route_item routeitem, m010_material material, m005_mcc mcc
			WHERE mcc.mcc_id = routeitem.mcc_id
			AND material.MaterialType_Id in ('C042231000001','C042231000002','C042231000003','C042231000004')
			AND routeitem.route_id = var_Route_Id
            AND material.Org_Id = var_Org_Id
            AND routeitem.Org_Id = var_Org_Id
            AND mcc.Org_Id = var_Org_Id
			ORDER BY @IssueStocks_Id, mcc.mcc_id;
       
       END;
       END IF;
        
			SELECT 1 AS Result_Id,  
			'Saved' AS Result_Description, 
			@IssueStocks_Id AS Result_Extra_Key;
   
   elseif (var_Method_Name = 'Update') then 
		-- for issue empty cans
		IF(Var_IssueStock_Type = 'Cans') THEN
        BEGIN
			
            SET @row_count := extractValue(var_XMLData,'count(//D/R)');
   
			Set @k := 0;
			WHILE @k < @row_count DO        
				SET @k := @k + 1;
				SET @xpath := concat('//D/R[', @k, ']');
                
                UPDATE  t019_issuestocks_item 
                SET Quantity = extractValue(var_XMLData, concat(@xpath,'/MaterialQty'))
                WHERE IssueStocks_Id = var_IssueStocks_Id
                AND MCC_Id = extractValue(var_XMLData, concat(@xpath,'/MCC'))
                AND Material_Id = extractValue(var_XMLData, concat(@xpath,'/MaterialId'));
                -- AND IssueStockToProfile_Id = extractValue(var_XMLData, concat(@xpath,'/ProfileId'))
                -- AND IssueStockToProfile_Type = extractValue(var_XMLData, concat(@xpath,'/ProfileType'));
                
			END WHILE;
            
            SELECT 1 AS Result_Id,  'Updated' AS Result_Description, 
                var_IssueStocks_Id AS Result_Extra_Key;
            
        END;
        
        -- for Manage > Material Issue To MCC
        ELSE
		BEGIN
        
			DELETE FROM t019_issuestocks_item
            WHERE IssueStocks_Id = var_IssueStocks_Id;
        
			SET @row_count := extractValue(var_XMLData,'count(//D/R)');
   
			Set @k := 0;
			WHILE @k < @row_count DO        
				SET @k := @k + 1;
				SET @xpath := concat('//D/R[', @k, ']');
                IF(extractValue(var_XMLData, concat(@xpath,'/IsDelivered')) = '1') THEN
                BEGIN
					INSERT INTO t019_issuestocks_item(
						Org_Id, IssueStocks_Id, 
						IssueStockToProfile_Id, 
                        Order_Id,
						Material_Id, 
						MCC_Id, 
						IssueStockToProfile_Type, 
						MCC_CollectionShift_Id, 
						Quantity, 
						Is_MCCAccepted, TripDocument_Id
					)
					VALUES(
						var_Org_Id, var_IssueStocks_Id, 
						extractValue(var_XMLData, concat(@xpath,'/ProfileId')),
						extractValue(var_XMLData, concat(@xpath,'/OrderId')),
						extractValue(var_XMLData, concat(@xpath,'/MaterialId')),
						extractValue(var_XMLData, concat(@xpath,'/MCC')),
						extractValue(var_XMLData, concat(@xpath,'/ProfileType')),
						'',
						extractValue(var_XMLData, concat(@xpath,'/MaterialQty')),
						0, ''
					);
                END;
                END IF;
                
                
                UPDATE t023_order_item
                SET Is_Delivered = CAST(extractValue(var_XMLData, concat(@xpath,'/IsDelivered')) AS UNSIGNED),
                Delivery_Id = extractValue(var_XMLData, concat(@xpath,'/DeliveryId'))
                WHERE Org_Id = var_Org_Id
                AND Order_Id = extractValue(var_XMLData, concat(@xpath,'/OrderId'))
                AND Product_Id = extractValue(var_XMLData, concat(@xpath,'/MaterialId'));
                
                -- SET Delivery Id if IsDelivered = 1
                IF (extractValue(var_XMLData, concat(@xpath,'/IsDelivered')) = '1') THEN
                BEGIN
					UPDATE t023_order_item
					SET Delivery_Id = extractValue(var_XMLData, concat(@xpath,'/DeliveryId'))
					WHERE Org_Id = var_Org_Id
					AND Order_Id = extractValue(var_XMLData, concat(@xpath,'/OrderId'))
					AND Product_Id = extractValue(var_XMLData, concat(@xpath,'/MaterialId'));
				END;
                -- Else Set Delivery Id to null string
                ELSE
                BEGIN
					BEGIN
					UPDATE t023_order_item
					SET Delivery_Id = ''
					WHERE Org_Id = var_Org_Id
					AND Order_Id = extractValue(var_XMLData, concat(@xpath,'/OrderId'))
					AND Product_Id = extractValue(var_XMLData, concat(@xpath,'/MaterialId'));
				END;
                END;
                END IF;
                
			END WHILE;
            
            SELECT 1 AS Result_Id,  'Updated' AS Result_Description, 
                var_IssueStocks_Id AS Result_Extra_Key;
        END;
		END IF;
	
		
   
   end if;
   
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
