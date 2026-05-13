-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerProfile_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerProfile_Set`(
	var_Method_Name varchar(20),
	var_Org_Id varchar(20),
	var_Profile_Id varchar(20),
    Var_Mobile_Number varchar(10),
    var_XMLData longtext
)
BEGIN
		SET SESSION sql_require_primary_key = 0;
        SET SQL_SAFE_UPDATES = 0;
		if (var_Method_Name = 'UpdateFarmerXML') then
		begin
			Declare RowCnt int;
			Declare var_CursorTestID int;
			Declare SQL_Qry text;
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE i INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;

			-- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_data;
			CREATE TEMPORARY TABLE temp_data (PKeyRowNum int, Field_Name varchar(50),
			Field_Value text);
			
            set @Is_Approved = (select Is_Approved from t002_farmerregistration where Org_Id = var_Org_Id and Farmer_Id =  var_Profile_Id ) ;
           
			SET row_count := extractValue(var_XMLData,'count(//D/R)');
			Set k := 0;
            
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');

				INSERT INTO temp_data VALUES (
					k,
					extractValue(var_XMLData, concat(xpath,'/FN')),
					extractValue(var_XMLData, concat(xpath,'/FV'))
				);
			END WHILE;
            
			set RowCnt = (select COUNT(*) from temp_data);
			set var_CursorTestID =0;
            
			While var_CursorTestID <= RowCnt Do
				
				set @var_Field_Name = (Select Field_Name from temp_data where PKeyRowNum = var_CursorTestID);
				set @var_Field_Value = (Select Field_Value from temp_data where PKeyRowNum = var_CursorTestID);
				set @var_Org_Id = var_Org_Id;
				set @var_Profile_Id = var_Profile_Id;
               
				if isnull(@var_Field_Name) = 0 then 
					if(@Is_Approved = 0) then 
						if (@var_Field_Name = 'Birth_Date' ) then
							SET @var_SQL = concat('Update t002_farmerregistration set ', @var_Field_Name , ' = STR_TO_DATE(@var_Field_Value, ''%d/%m/%Y'') where Org_Id = @var_Org_Id and Farmer_Id = @var_Profile_Id');
							PREPARE dynamic_statement FROM @var_SQL;
							EXECUTE dynamic_statement;
							DEALLOCATE PREPARE dynamic_statement;
						else
						   SET @var_SQL = concat('Update t002_farmerregistration set ', @var_Field_Name , ' = @var_Field_Value where Org_Id = @var_Org_Id and Farmer_Id = @var_Profile_Id');
						   PREPARE dynamic_statement FROM @var_SQL;
						   EXECUTE dynamic_statement;
						
						   DEALLOCATE PREPARE dynamic_statement;
						end if;
					else 
						if (@var_Field_Name = 'Birth_Date' ) then
								SET @var_SQL = concat('Update mu04_farmer set ', @var_Field_Name , ' = STR_TO_DATE(@var_Field_Value, ''%d/%m/%Y'') , LastEdited_On = now() , LastEditedBy_Id = @var_Profile_Id   where Org_Id = @var_Org_Id and Farmer_Id = @var_Profile_Id');
								PREPARE dynamic_statement FROM @var_SQL;
								EXECUTE dynamic_statement;
								DEALLOCATE PREPARE dynamic_statement;
							else
							   SET @var_SQL = concat('Update mu04_farmer set ', @var_Field_Name , ' = @var_Field_Value , LastEdited_On = now() , LastEditedBy_Id = @var_Profile_Id  where Org_Id = @var_Org_Id and Farmer_Id = @var_Profile_Id');
							   PREPARE dynamic_statement FROM @var_SQL;
							   EXECUTE dynamic_statement;
							   DEALLOCATE PREPARE dynamic_statement;
							end if;
					end if;
				end if;
				
				Set var_CursorTestID = var_CursorTestID + 1;

			END WHILE;
			drop temporary table temp_data;
            
            select 1 as Result_Id, 
			'Saved' as Result_Description,
			var_Profile_Id as Result_Extra_Key ;
		end;
        
        
	elseif (var_Method_Name = 'UpdateMobileNumber') then
		
        
	set @Is_Approved = (select Is_Approved from t002_farmerregistration where Org_Id = var_Org_Id and Farmer_Id =  var_Profile_Id ) ;
        
	if(@Is_Approved = 0) then 
		
		update t002_farmerregistration 
       set Mobile_No = Var_Mobile_Number 
       where Farmer_Id = var_Profile_Id ;
       
	 select 1 as Result_Id, 
			'Saved' as Result_Description,
			var_Profile_Id as Result_Extra_Key ;
    
    elseif(@Is_Approved = 0) then 
		
       update mu04_farmer 
       set Mobile_No = Var_Mobile_Number 
       where Farmer_Id = var_Profile_Id ;
       
        select 1 as Result_Id, 
			'Saved' as Result_Description,
			var_Profile_Id as Result_Extra_Key ;
        
	
    else 
    
     select -1 as Result_Id, 
			'Farmer Not Found' as Result_Description,
			var_Profile_Id as Result_Extra_Key ;
    
    	end if;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
