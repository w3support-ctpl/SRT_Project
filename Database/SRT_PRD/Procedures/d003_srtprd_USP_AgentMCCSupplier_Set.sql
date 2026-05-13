-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMCCSupplier_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMCCSupplier_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
	var_MCC_Id varchar(20),
    var_Supplier_Id varchar(20),
    var_Supplier_Name longtext,
    var_Address_Text longtext,
    var_Mobile_No varchar(45),
    var_ContactPerson_Name longtext,
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
            Declare New_Supplier_Id varchar(20);
			Declare Year_Id varchar(10);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            
			if exists(select Supplier_Id from m102_mcc_supplier where Org_Id = var_Org_Id 
						and MCC_Id = var_MCC_Id and Supplier_Name = var_Supplier_Name
                        and Is_Deleted = 0) then
                        
				SELECT -1 AS Result_Id, 
                'Supplier Name already exists.' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif exists(select Supplier_Id from m102_mcc_supplier where Org_Id = var_Org_Id 
						and MCC_Id = var_MCC_Id and Mobile_No = var_Mobile_No
                        and Is_Deleted = 0) then
                        
				SELECT -1 AS Result_Id, 
				'Mobile Number already exists.' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m102_mcc_supplier', Year_Id, 'M102', '', New_Supplier_Id );
                
                Insert Into m102_mcc_supplier
                (Org_Id,MCC_Id,Supplier_Id,Supplier_Name,Address_Text,
                Mobile_No,ContactPerson_Name,
                Is_Active,Is_Deleted,
                Created_On,CreatedBy_Id,CreatedBy_Name)
                value(
                var_Org_Id,var_MCC_Id,New_Supplier_Id,var_Supplier_Name,var_Address_Text,
                var_Mobile_No,var_ContactPerson_Name,
                var_Is_Active,var_Is_Deleted,
                now(),var_User_Id,var_User_Name
                );
                
                delete from m102_mcc_supplier_item
				where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
				and Supplier_Id = New_Supplier_Id;
                
                SET row_count := extractValue(var_MaterialData,'count(//Material/MaterialData)');
				WHILE k < row_count DO
					SET k := k + 1;
					SET xpath := concat('//Material/MaterialData[', k, ']');
					
					INSERT INTO m102_mcc_supplier_item (Org_Id, MCC_Id, Supplier_Id, Material_Id)
					VALUES (var_Org_Id,var_MCC_Id, New_Supplier_Id, extractValue(var_MaterialData, concat(xpath,'/Material_Id')));
			   
				END WHILE;
                
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Supplier_Id AS Result_Extra_Key;
            end if;
        end;
	elseif (var_Method_Name = 'Update') then
		begin
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            
			if exists(select Supplier_Id from m102_mcc_supplier where Org_Id = var_Org_Id 
						and MCC_Id = var_MCC_Id and Supplier_Name = var_Supplier_Name
                        and Is_Deleted = 0
                        and Supplier_Id <> var_Supplier_Id) then
                        
				SELECT -1 AS Result_Id, 
                'Supplier Name already exists.' AS Result_Description, 
                '' AS Result_Extra_Key;
                
			elseif exists(select Supplier_Id from m102_mcc_supplier where Org_Id = var_Org_Id 
						and MCC_Id = var_MCC_Id and Mobile_No = var_Mobile_No
                        and Is_Deleted = 0
                        and Supplier_Id <> var_Supplier_Id) then
                        
				SELECT -1 AS Result_Id, 
				'Mobile Number already exists.' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
				
				Update m102_mcc_supplier
                set 
                Supplier_Name = var_Supplier_Name,
                Address_Text = var_Address_Text,
                Mobile_No = var_Mobile_No,
                ContactPerson_Name = var_ContactPerson_Name,
                Is_Active = var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                LastEdited_On = now(),
                LastEditedBy_Id = var_User_Id,
                LastEditedBy_Name = var_User_Name
                where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
				and Supplier_Id = var_Supplier_Id;
                
                delete from m102_mcc_supplier_item
				where Org_Id = var_Org_Id
				and MCC_Id = var_MCC_Id
				and Supplier_Id = var_Supplier_Id;
                
                SET row_count := extractValue(var_MaterialData,'count(//Material/MaterialData)');
				WHILE k < row_count DO
					SET k := k + 1;
					SET xpath := concat('//Material/MaterialData[', k, ']');
					
					INSERT INTO m102_mcc_supplier_item (Org_Id, MCC_Id, Supplier_Id, Material_Id)
					VALUES (var_Org_Id,var_MCC_Id, var_Supplier_Id, extractValue(var_MaterialData, concat(xpath,'/Material_Id')));
			   
				END WHILE;
                
                SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Supplier_Id AS Result_Extra_Key;
                
            end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			
			Update m102_mcc_supplier
			set 
			Is_Active = 0,
			Is_Deleted = 1, 
			LastEdited_On = now(),
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and Supplier_Id = var_Supplier_Id;
			
			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Supplier_Id AS Result_Extra_Key;
                
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
