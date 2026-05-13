-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminQualityEntry_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminQualityEntry_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Entry_Id varchar(20),
	var_MilkCollectionDairy_Id varchar(20),
    var_SNF varchar(45),
    var_Fat varchar(45),
    var_Protein varchar(45),
    var_Ash varchar(45),
    var_Sodium varchar(45),
    var_Adulteration varchar(45),
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_Is_Active int,
    var_Is_Deleted int
)
BEGIN
	if (var_Method_Name = 'Update') then
		BEGIN
			declare set_VehicleType_Id varchar(20);
            declare set_CellNo varchar(20);
            declare set_Entry_Id varchar(20);
            DECLARE Set_MCC_Id  varchar(20);
            
			Update t009_milkcollectiondairy_quality
			set 
            MilkStatus_Id =  var_User_Id,
			SNF = var_SNF,
			Fat =  var_Fat,
            Protein = var_Protein,
			Ash =  var_Ash,
            Sodium =  var_Sodium,
            Adulteration =  var_Adulteration
			where Org_Id = var_Org_Id 
            and Entry_Id = var_Entry_Id
			and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
            
            set set_VehicleType_Id = (select ifnull(m003.VehicleType_Id,'')as VehicleType_Id from  t009_milkcollectiondairy_header t009
									inner join  m003_vehicle m003 on m003.Org_Id =t009.Org_Id and m003.Vehicle_Id =  t009.Vehicle_Id
									where t009.Org_Id = var_Org_Id 
									and t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
                                    
             IF (set_VehicleType_Id = 'C020002') THEN 
				set  set_CellNo = (SELECT CellNo FROM t009_milkcollectiondairy_quality  
								where Org_Id = var_Org_Id
								and Entry_Id = var_Entry_Id
								and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
					set set_Entry_Id =( SELECT Entry_Id FROM t009_milkcollectiondairy_quantity  
									where Org_Id = var_Org_Id
									and CellNo = set_CellNo
									and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
                IF (var_User_Id = 'C016002') then
					
					Update t009_milkcollectiondairy_quantity t009
					set 
					t009.MilkStatus_Id = var_User_Id,
					t009.GrossWeight = t009.GrossWeight,
					t009.TareWeight = t009.GrossWeight,
					t009.Weight = 0,
					t009.Liters =  0
					where Org_Id = var_Org_Id 
					and Entry_Id = set_Entry_Id
                    and CellNo = set_CellNo
					and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
					
				end if;
                UPDATE t009_milkcollectiondairy_milk AS t009
					SET
						Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
								  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id),
						Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
								  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id)
					WHERE
						t009.Org_Id = var_Org_Id
						AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                
             end if;
             IF (set_VehicleType_Id = '' OR  set_VehicleType_Id IS NULL) THEN 
                
					set  set_CellNo = (SELECT CellNo FROM t009_milkcollectiondairy_quality  
								where Org_Id = var_Org_Id
								and Entry_Id = var_Entry_Id
								and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
                                
					set set_Entry_Id =( SELECT Entry_Id FROM t009_milkcollectiondairy_quantity  
									where Org_Id = var_Org_Id
									and CellNo = set_CellNo
									and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id);
					IF (var_User_Id = 'C016002') then
                    
					SELECT MCC_Id into Set_MCC_Id FROM t009_milkcollectiondairy_mcc 
					where Org_Id = var_Org_Id 
					and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
                                    
					
					Update t009_milkcollectiondairy_quantity t009
					set 
					t009.MilkStatus_Id = var_User_Id,
					t009.GrossWeight = t009.GrossWeight,
					t009.TareWeight = t009.GrossWeight,
					t009.Weight = 0,
					t009.Liters =  0
					where Org_Id = var_Org_Id 
					and Entry_Id = set_Entry_Id
                    and CellNo = set_CellNo
					and MilkCollectionDairy_Id = var_MilkCollectionDairy_Id; 
				end if;
				
                UPDATE t009_milkcollectiondairy_mcc AS t009
					SET
						Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
								  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
								  and t0091.MCC_Id = t009.MCC_Id),
						Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
								  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id
								  and t0091.MCC_Id = t009.MCC_Id)
						-- Final_Amout =  @Final_Amout
					WHERE
						t009.Org_Id = var_Org_Id
						AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id
						and t009.MCC_Id =Set_MCC_Id;
                        
					UPDATE t009_milkcollectiondairy_milk AS t009
					SET
						Weight = (SELECT SUM(Weight) FROM t009_milkcollectiondairy_quantity t0091
								  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id),
						Liters = (SELECT SUM(Liters) FROM t009_milkcollectiondairy_quantity t0091
								  WHERE t0091.MilkCollectionDairy_Id = t009.MilkCollectionDairy_Id)
					WHERE
						t009.Org_Id = var_Org_Id
						AND t009.MilkCollectionDairy_Id = var_MilkCollectionDairy_Id;
             end if;
            
            SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
		END;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
