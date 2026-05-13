-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerProfile_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerProfile_Set`(
	var_Method_Name varchar(20),
	var_Org_Id varchar(20),
	var_Profile_Id varchar(20),
    var_XMLData longtext,
    Var_Farmer_Id varchar(20),
    var_MCC_Id varchar(20)
)
BEGIN
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
	SET SESSION sql_require_primary_key = 0;
	SET SQL_SAFE_UPDATES = 0;
        
        
	if(var_Method_Name = 'RegisterFarmer') then
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
			set var_CursorTestID =1;

            
			set @MobileNo = (select Field_Value from temp_data where Field_Name = 'Mobile_No' limit 1);
            set @MCC_Farmer_Code = (select Field_Value from temp_data where Field_Name = 'MCC_Farmer_Code' limit 1);
	
			set @MCCWorkType_Id = (select MCCWorkType_Id from m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id limit 1);
            
            if(@MCCWorkType_Id = 'C023001') then
            
				if exists (select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and Mobile_No =  @MobileNo  ) or 
                exists(select Farmer_Id from mu04_farmer where Org_Id =  var_Org_Id  and Mobile_No = @MobileNo )  then
					select -1 as Result_Id, 'Mobile number already registered' as Result_Description, -1 as Result_Extra_Key; 
				elseif exists (select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id and MCC_Farmer_Code = @MCC_Farmer_Code  ) or 
                exists(select Farmer_Id from mu04_farmer where Org_Id =  var_Org_Id  and MCC_Id = var_MCC_Id and MCC_Farmer_Code = @MCC_Farmer_Code  )  then
					select -1 as Result_Id, 'MCC Farmer Code already registered' as Result_Description, -1 as Result_Extra_Key; 
				else
					set @New_Farmer_Id = '';
					set @Year_Id = (select right(left(curdate(),4),(2)));
					
					Call USP_Number_Range ('mu04_farmer',  @Year_Id, 'MU04', '', @New_Farmer_Id);
					
					Insert into mu04_farmer(Org_Id, Farmer_Id,Login_Name, Mobile_No,Login_Password, Created_On , CreatedBy_Id,Is_Offline,MCC_Id )
					values(var_Org_Id, @New_Farmer_Id, @MobileNo, @MobileNo, 'Abc@123' , @Current_Datetime ,var_Profile_Id,1,var_MCC_Id ); 
			   
				
				While var_CursorTestID <= RowCnt Do
					
					set @var_Field_Name = (Select Field_Name from temp_data where PKeyRowNum = var_CursorTestID);
					set @var_Field_Value = (Select Field_Value from temp_data where PKeyRowNum = var_CursorTestID);
					set @var_Org_Id = var_Org_Id;
					set @var_Profile_Id = @New_Farmer_Id;
				   

							if (@var_Field_Name = 'Birth_Date' ) then
								SET @var_SQL = concat('Update mu04_farmer set ', @var_Field_Name , ' = STR_TO_DATE(@var_Field_Value, ''%d/%m/%Y'') where Org_Id = @var_Org_Id and Farmer_Id = @var_Profile_Id');
								PREPARE dynamic_statement FROM @var_SQL;
								EXECUTE dynamic_statement;
								DEALLOCATE PREPARE dynamic_statement;
							else
							   SET @var_SQL = concat('Update mu04_farmer set ', @var_Field_Name , ' = @var_Field_Value where Org_Id = @var_Org_Id and Farmer_Id = @var_Profile_Id');
							   PREPARE dynamic_statement FROM @var_SQL;
							   EXECUTE dynamic_statement;
							
							   DEALLOCATE PREPARE dynamic_statement;
							
							end if;
					
					Set var_CursorTestID = var_CursorTestID + 1;

				END WHILE;
				 end if;
				
                
            else
            
				if exists (select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and Mobile_No =  @MobileNo  ) or 
                exists(select Farmer_Id from mu04_farmer where Org_Id =  var_Org_Id  and Mobile_No = @MobileNo )  then
					select -1 as Result_Id, 'Mobile number already registered' as Result_Description, -1 as Result_Extra_Key; 
				elseif exists (select Farmer_Id from t002_farmerregistration where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id and MCC_Farmer_Code = @MCC_Farmer_Code  ) or 
                exists(select Farmer_Id from mu04_farmer where Org_Id =  var_Org_Id  and MCC_Id = var_MCC_Id and MCC_Farmer_Code = @MCC_Farmer_Code  )  then
					select -1 as Result_Id, 'MCC Farmer Code already registered' as Result_Description, -1 as Result_Extra_Key; 
				else
					set @New_Farmer_Id = '';
					set @Year_Id = (select right(left(curdate(),4),(2)));
					
					Call USP_Number_Range ('t002_farmerregistration',  @Year_Id, 'T002', '', @New_Farmer_Id);
					
					Insert into t002_farmerregistration(Org_Id, Farmer_Id, Mobile_No, Password,Is_Approved, Request_Date, Request_By , Request_By_Id )
					values(var_Org_Id, @New_Farmer_Id, @MobileNo, 'Abc@123' ,0, @Current_Datetime , 'Agent' ,var_Profile_Id ); 
			   
				
				While var_CursorTestID <= RowCnt Do
					
					set @var_Field_Name = (Select Field_Name from temp_data where PKeyRowNum = var_CursorTestID);
					set @var_Field_Value = (Select Field_Value from temp_data where PKeyRowNum = var_CursorTestID);
					set @var_Org_Id = var_Org_Id;
					set @var_Profile_Id = @New_Farmer_Id;
				   

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
					
					Set var_CursorTestID = var_CursorTestID + 1;

				END WHILE;
				 end if;
				
            end if;
            
            drop temporary table temp_data;
            
            select 1 as Result_Id, 
			'Saved' as Result_Description,
			@New_Farmer_Id as Result_Extra_Key ;
     
END;


	elseif (var_Method_Name = 'UpdateFarmer') then


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
			set var_CursorTestID =1;
            
			
			
            set @MCCWorkType_Id = (select MCCWorkType_Id from m005_mcc where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id limit 1);
            
            if(@MCCWorkType_Id = 'C023001') then
				
                While var_CursorTestID <= RowCnt Do
					
					set @var_Field_Name = (Select Field_Name from temp_data where PKeyRowNum = var_CursorTestID);
					set @var_Field_Value = (Select Field_Value from temp_data where PKeyRowNum = var_CursorTestID);
					set @var_Org_Id = var_Org_Id;
					set @var_Profile_Id = Var_Farmer_Id;
				   
							if (@var_Field_Name = 'Birth_Date' ) then
								SET @var_SQL = concat('Update mu04_farmer set ', @var_Field_Name , ' = STR_TO_DATE(@var_Field_Value, ''%d/%m/%Y'') where Org_Id = @var_Org_Id and Farmer_Id = @var_Profile_Id');
								PREPARE dynamic_statement FROM @var_SQL;
								EXECUTE dynamic_statement;
								DEALLOCATE PREPARE dynamic_statement;
							else
							   SET @var_SQL = concat('Update mu04_farmer set ', @var_Field_Name , ' = @var_Field_Value where Org_Id = @var_Org_Id and Farmer_Id = @var_Profile_Id');
							   PREPARE dynamic_statement FROM @var_SQL;
							   EXECUTE dynamic_statement;
							
							   DEALLOCATE PREPARE dynamic_statement;
							
							end if;
					
					Set var_CursorTestID = var_CursorTestID + 1;

				END WHILE;
                
            else
				set @MobileNo = (select Field_Value from temp_data where Field_Name = 'Mobile_No' limit 1);
				if not exists (select Farmer_Id from mu04_farmer where Org_Id =  var_Org_Id  and Farmer_Id = Var_Farmer_Id )  then
			
				While var_CursorTestID <= RowCnt Do
					
					set @var_Field_Name = (Select Field_Name from temp_data where PKeyRowNum = var_CursorTestID);
					set @var_Field_Value = (Select Field_Value from temp_data where PKeyRowNum = var_CursorTestID);
					set @var_Org_Id = var_Org_Id;
					set @var_Profile_Id = Var_Farmer_Id;
				   
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
					
					Set var_CursorTestID = var_CursorTestID + 1;

				END WHILE;
				
				else 
				
					select -1 as Result_Id, 'Farmer Already Registered' as Result_Description, -1 as Result_Extra_Key;
					
				 end if;
                
            end if;
            
            
             
			drop temporary table temp_data;
            
            select 1 as Result_Id, 
			'Saved' as Result_Description,
			Var_Farmer_Id as Result_Extra_Key ;



end ;

     end if; 
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
