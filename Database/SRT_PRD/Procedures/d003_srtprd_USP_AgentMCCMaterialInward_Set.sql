-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCMaterialInward_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCMaterialInward_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_Inward_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Supplier_Id varchar(20),
    var_Inward_Date varchar(20),
    var_MaterialData longtext,
    var_Is_Active int,
    var_Is_Deleted int,
    var_User_Id VARCHAR(45),
    var_User_Name longtext
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare Duplicate_Flag int;
            Declare New_Inward_Id varchar(20);
            Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            
            
			set Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('t101_mcc_material_inward', Year_Id, 'T101', '', New_Inward_Id );
			
			Insert Into t101_mcc_material_inward
			(Org_Id,Inward_Id,MCC_Id,Supplier_Id,Inward_Date,
			Is_Active,Is_Deleted,
			Created_On,CreatedBy_Id,CreatedBy_Name)
			value(
			var_Org_Id,New_Inward_Id,var_MCC_Id,var_Supplier_Id,var_Inward_Date,
			var_Is_Active,var_Is_Deleted,
			now(),var_User_Id,var_User_Name
			);
			
			delete from t101_mcc_material_inward_item
			where Org_Id = var_Org_Id
			and Inward_Id = New_Inward_Id;
			
			SET row_count := extractValue(var_MaterialData,'count(//Material/MaterialData)');
			WHILE k < row_count DO
				SET k := k + 1;
				
                SET xpath := concat('//Material/MaterialData[', k, ']');
                
                set New_Entry_Id ='';
				
                CALL USP_Number_Range ('t101_mcc_material_inward_item', Year_Id, 'T101A', '', New_Entry_Id );
				
                
                INSERT INTO t101_mcc_material_inward_item 
                (Org_Id, Entry_Id, Inward_Id, Material_Id,
                Purchase_Amount,Purchase_Unit,
                Selling_Amount,Quantity)
				VALUES (var_Org_Id,New_Entry_Id,New_Inward_Id, 
                extractValue(var_MaterialData, concat(xpath,'/Material_Id')),
                extractValue(var_MaterialData, concat(xpath,'/Purchase_Amount')),
                extractValue(var_MaterialData, concat(xpath,'/Purchase_Unit')),
                extractValue(var_MaterialData, concat(xpath,'/Selling_Amount')),
                extractValue(var_MaterialData, concat(xpath,'/Quantity'))
                );
                
		   
			END WHILE;
			set @Total_Amount  = (select sum(ifnull(Purchase_Amount,0)) from t101_mcc_material_inward_item 
									where Org_Id = var_Org_Id
									and Inward_Id = New_Inward_Id
									);
                                    
			Update t101_mcc_material_inward
			set 
			Total_Amount = ifnull(@Total_Amount,0)
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and Inward_Id = New_Inward_Id;
            
			
			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			New_Inward_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Update') then
		begin
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            
				
				Update t101_mcc_material_inward
                set 
				Supplier_Id = var_Supplier_Id,
                Inward_Date = var_Inward_Date,
                Is_Active = var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = now(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
                where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
                and Inward_Id = var_Inward_Id;
                
                delete from t101_mcc_material_inward_item
				where Org_Id = var_Org_Id
				and Inward_Id = var_Inward_Id;
                
            
            
				set Year_Id = (select right(left(curdate(),4),(2)));
				
				SET row_count := extractValue(var_MaterialData,'count(//Material/MaterialData)');
				WHILE k < row_count DO
					SET k := k + 1;
					
					SET xpath := concat('//Material/MaterialData[', k, ']');
					
					set New_Entry_Id ='';
					
					CALL USP_Number_Range ('t101_mcc_material_inward_item', Year_Id, 'T101A', '', New_Entry_Id );
					
					INSERT INTO t101_mcc_material_inward_item 
					(Org_Id, Entry_Id, Inward_Id, Material_Id,Purchase_Amount,Purchase_Unit,
                    Selling_Amount,Quantity)
					VALUES (var_Org_Id,New_Entry_Id,var_Inward_Id, 
					extractValue(var_MaterialData, concat(xpath,'/Material_Id')),
					extractValue(var_MaterialData, concat(xpath,'/Purchase_Amount')),
					extractValue(var_MaterialData, concat(xpath,'/Purchase_Unit')),
                    extractValue(var_MaterialData, concat(xpath,'/Selling_Amount')),
					extractValue(var_MaterialData, concat(xpath,'/Quantity'))
					);
			   
				END WHILE;
                
                set @Total_Amount  = (select sum(ifnull(Purchase_Amount,0)) from t101_mcc_material_inward_item 
									where Org_Id = var_Org_Id
									and Inward_Id = var_Inward_Id
									);
                                    
				Update t101_mcc_material_inward
				set 
				Total_Amount = ifnull(@Total_Amount,0)
				where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
				and Inward_Id = var_Inward_Id;
            
                SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Inward_Id AS Result_Extra_Key;
                
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			
			Update t101_mcc_material_inward
			set 
			Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = now(),
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id
			and Inward_Id = var_Inward_Id;
			
			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Inward_Id AS Result_Extra_Key;
                
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
