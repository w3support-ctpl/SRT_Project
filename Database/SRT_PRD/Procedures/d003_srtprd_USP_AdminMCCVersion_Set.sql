-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCVersion_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCVersion_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
	var_MCC_Id varchar(20),
    var_Version_No int,
    var_MusterType_Id varchar(20),
    var_PaymentCycle_Id varchar(20),
    var_CollectionShift_Id LONGTEXT,
    var_MilkType_Id LONGTEXT,
	var_Applicable_Date DATETIME,
    var_Is_Active int,
    var_Is_Deleted int,
    var_DateCheck varchar(2),
    var_Anamat  varchar(20),
	var_Freight  varchar(45),
    var_Anamat_TDS  varchar(45),
	var_Freight_TDS  varchar(45),
    var_Rebate  varchar(45)
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare New_Version_No int;
            DECLARE collectionShiftArray LONGTEXT;
            DECLARE milkTypeArray LONGTEXT;
            DECLARE collectionShiftName LONGTEXT;
            DECLARE milkTypeName LONGTEXT;
            DECLARE Latest_Applicable_Date datetime;
            
            Declare Today_Date datetime;
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT Applicable_Date INTO Latest_Applicable_Date
			FROM m005_mcc_version
			WHERE Org_Id = var_Org_Id
			AND MCC_Id = var_MCC_Id
			AND Is_Deleted = 0
			ORDER BY Version_No DESC
			LIMIT 1;
            
            if (var_Applicable_Date < Today_Date and var_DateCheck = '1') then
                SELECT -1 AS Result_Id, 
                'Applicable Date must be greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (var_Applicable_Date <= Latest_Applicable_Date) then
				SELECT -1 AS Result_Id, 
				'Applicable Date must be greater than the latest Applicable date and time' AS Result_Description, 
				'' AS Result_Extra_Key;
            elseif exists(select MCC_Id from m005_mcc_version where Org_Id = var_Org_Id 
					and MCC_Id = var_MCC_Id and Applicable_Date = var_Applicable_Date and Is_Deleted = 0 ) then
                SELECT -1 AS Result_Id, 
                'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
            else
                select coalesce(MAX(Version_No), 0) + 1 INTO New_Version_No
				from m005_mcc_version
				where MCC_Id = var_MCC_Id and Org_Id = var_Org_Id;
				Insert Into m005_mcc_version
                (Org_Id, MCC_Id,Version_No,MusterType_Id,PaymentCycle_Id,
				Applicable_Date,Is_Active,Is_Deleted,Anamat_PerLtr,Freight_PerLtr,
                Anamat_Applicable_To,Freight_Applicable_To,Rebate_PerLtr)
				Values (var_Org_Id, var_MCC_Id,New_Version_No,var_MusterType_Id,var_PaymentCycle_Id,
				var_Applicable_Date,var_Is_Active, var_Is_Deleted,var_Anamat,var_Freight,
                var_Anamat_TDS,var_Freight_TDS,var_Rebate); 
                
                
                SET collectionShiftArray = var_CollectionShift_Id;
					WHILE LENGTH(collectionShiftArray) > 0 DO
						SET @value = SUBSTRING_INDEX(collectionShiftArray, ',', 1);
                        
						INSERT INTO m005_mcc_collectionshift (Org_Id, MCC_Id, CollectionShift_Id, Version_No)
						VALUES (var_Org_Id, var_MCC_Id, @value, New_Version_No);
						SET collectionShiftArray = SUBSTRING(collectionShiftArray, LENGTH(@value) + 2);
					END WHILE; 

					set collectionShiftName = (select GROUP_CONCAT(CollectionShift_Name separator ' | ') 
					from c015_collectionshift c015 
					inner join m005_mcc_collectionshift m005 on 
					c015.CollectionShift_Id = m005.CollectionShift_Id 
					where m005.Org_Id= var_Org_Id 
					and m005.MCC_Id = var_MCC_Id
					and m005.Version_No = New_Version_No);

					SET milkTypeArray = var_MilkType_Id;
					WHILE LENGTH(milkTypeArray) > 0 DO
						SET @value = SUBSTRING_INDEX(milkTypeArray, ',', 1);
						
						INSERT INTO m005_mcc_milktype (Org_Id, MCC_Id, MilkType_Id, Version_No)
						VALUES (var_Org_Id, var_MCC_Id, @value, New_Version_No);
						SET milkTypeArray = SUBSTRING(milkTypeArray, LENGTH(@value) + 2);
					END WHILE; 

					set milkTypeName = (select GROUP_CONCAT(MilkType_Name separator ' | ') 
					from c011_milktype c015 
					inner join m005_mcc_milktype m005 on 
					c015.MilkType_Id = m005.MilkType_Id 
					where m005.Org_Id= var_Org_Id 
					and m005.MCC_Id = var_MCC_Id
					and m005.Version_No = New_Version_No);


					Update m005_mcc_version
					set 
					MilkType_Name = milkTypeName,
					CollectionShift_Name = collectionShiftName
					where Org_Id = var_Org_Id 
					and MCC_Id = var_MCC_Id
					and Version_No = New_Version_No;
                
				SELECT 1 AS Result_Id, 
                'Saved' AS Result_Description, 
                New_Version_No AS Result_Extra_Key;
			end if;
		end;
	elseif (var_Method_Name = 'Update') then
		begin	
			DECLARE collectionShiftArray LONGTEXT;
            DECLARE milkTypeArray LONGTEXT;
            DECLARE collectionShiftName LONGTEXT;
            DECLARE milkTypeName LONGTEXT;
            Declare Today_Date datetime;
            DECLARE Latest_Applicable_Date datetime;
            SET SQL_SAFE_UPDATES = 0;
		
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT Applicable_Date INTO Latest_Applicable_Date
			FROM m005_mcc_version
			WHERE Org_Id = var_Org_Id
			AND MCC_Id <> var_MCC_Id
			AND Is_Deleted = 0
			ORDER BY Version_No DESC
			LIMIT 1;
            
            if (var_Applicable_Date < Today_Date) then
                SELECT -1 AS Result_Id, 
                'Applicable Date is greater than current date and time' AS Result_Description, 
                '' AS Result_Extra_Key;
			elseif (var_Applicable_Date <= Latest_Applicable_Date) then
				SELECT -1 AS Result_Id, 
				'Applicable Date must be greater than the latest Applicable date and time' AS Result_Description, 
				'' AS Result_Extra_Key;
            elseif exists(select Version_No from m005_mcc_version where Org_Id = var_Org_Id
				and Applicable_Date = var_Applicable_Date 
				and Version_No = var_Version_No
				and Is_Deleted = 0 and MCC_Id <> var_MCC_Id) then
                SELECT -1 AS Result_Id, 
                'Applicable Date already exists' AS Result_Description, 
                '' AS Result_Extra_Key;
			else
            
				Update m005_mcc_version
                set 
                MusterType_Id = var_MusterType_Id,
                PaymentCycle_Id = var_PaymentCycle_Id,
                Applicable_Date = var_Applicable_Date,
                Is_Active =  var_Is_Active,
                Is_Deleted = var_Is_Deleted,
                Anamat_PerLtr =  var_Anamat,
                Freight_PerLtr = var_Freight,
                Anamat_Applicable_To =  var_Anamat_TDS,
                Freight_Applicable_To = var_Freight_TDS,
                Rebate_PerLtr = var_Rebate
                where Org_Id = var_Org_Id 
                and MCC_Id = var_MCC_Id
                and Version_No = var_Version_No; 
                
                
                 
				DELETE FROM m005_mcc_collectionshift
				WHERE Org_Id = var_Org_Id 
                AND MCC_Id = var_MCC_Id 
                and Version_No = var_Version_No;
                
                SET collectionShiftArray = var_CollectionShift_Id;
					WHILE LENGTH(collectionShiftArray) > 0 DO
						SET @value = SUBSTRING_INDEX(collectionShiftArray, ',', 1);
                            
						INSERT INTO m005_mcc_collectionshift (Org_Id, MCC_Id, CollectionShift_Id, Version_No)
						VALUES (var_Org_Id, var_MCC_Id, @value, var_Version_No);
                    
						SET collectionShiftArray = SUBSTRING(collectionShiftArray, LENGTH(@value) + 2);
					END WHILE; 
                    
                  
              	
				set collectionShiftName = (select GROUP_CONCAT(CollectionShift_Name separator ' | ') 
					from c015_collectionshift c015 
					inner join m005_mcc_collectionshift m005 on 
					c015.CollectionShift_Id = m005.CollectionShift_Id 
					where m005.Org_Id= var_Org_Id 
					and m005.MCC_Id = var_MCC_Id
					and m005.Version_No = var_Version_No);


				DELETE FROM m005_mcc_milktype
				WHERE Org_Id = var_Org_Id 
                AND MCC_Id = var_MCC_Id 
                and Version_No = var_Version_No;
                
				SET milkTypeArray = var_MilkType_Id;
					WHILE LENGTH(milkTypeArray) > 0 DO
						SET @value = SUBSTRING_INDEX(milkTypeArray, ',', 1);
					
						INSERT INTO m005_mcc_milktype (Org_Id, MCC_Id, MilkType_Id, Version_No)
						VALUES (var_Org_Id, var_MCC_Id, @value, var_Version_No);
                            
						SET milkTypeArray = SUBSTRING(milkTypeArray, LENGTH(@value) + 2);
					END WHILE; 

				set milkTypeName = (select GROUP_CONCAT(MilkType_Name separator ' | ') 
					from c011_milktype c015 
					inner join m005_mcc_milktype m005 on 
					c015.MilkType_Id = m005.MilkType_Id 
					where m005.Org_Id= var_Org_Id 
					and m005.MCC_Id = var_MCC_Id
					and m005.Version_No = var_Version_No);


				Update m005_mcc_version
					set 
					MilkType_Name = milkTypeName,
					CollectionShift_Name = collectionShiftName
					where Org_Id = var_Org_Id 
					and MCC_Id = var_MCC_Id
					and Version_No = var_Version_No;
                
				SELECT 1 AS Result_Id, 
                'Updated' AS Result_Description, 
                var_Version_No AS Result_Extra_Key;
			end if;
        end;
	elseif (var_Method_Name = 'Delete') then
		begin
			Update m005_mcc_version
			set 
            Is_Active = 0,
			Is_Deleted = 1
			 where Org_Id = var_Org_Id 
			and MCC_Id = var_MCC_Id
			and Version_No = var_Version_No; 

			SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Version_No AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
