-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTripDocument_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTripDocument_Set`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
	var_TripDocument_Id varchar(20),
    var_FreightRateType_Id varchar(20),
    var_FinalDistance varchar(45),
    var_Rate varchar(45),
    var_TripAmount varchar(45),
    var_DieselBaseRate varchar(45),
    var_CurrentDieselRate varchar(45),
    var_Weight varchar(45),
    var_Liters varchar(45),
    var_User_Id varchar(20),
	var_User_Name varchar(45),
    var_FleetX_Id  varchar(45),
    var_DistanceAsPerFleetX  varchar(45),
    var_DistanceAsPerApp  varchar(45)
)
BEGIN
	if (var_Method_Name = 'Update') then
		begin
			Declare var_MCCCollectionShift_Id varchar(20);
			Declare AverageKM varchar(20);
            Declare AverageLiters varchar(20);
            Declare Cost varchar(20);
            Declare TotalFreight varchar(20);
            Declare Current_Datetime datetime;
            declare var_Weight varchar(45);
            
            set @kg_to_ltr = (select Kg_To_Ltr_Dairy from c001_organization where Org_Id = Var_Org_Id) ;
            
            set var_Weight = var_Liters / @kg_to_ltr;
			set Current_Datetime = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
            SELECT m003.VehicleAverage into AverageKM FROM t021_tripdocument_header t021
			inner join m003_vehicle m003 on m003.Vehicle_Id = t021.Vehicle_Id and m003.Org_Id = t021.Org_Id
			where t021.TripDocument_Id = var_TripDocument_Id
			and t021.Org_Id =  var_Org_Id;
		
			set  AverageLiters =  (var_FinalDistance * 1) / AverageKM;
            
             if(var_FreightRateType_Id = 'C029001') then
				set Cost =  var_TripAmount;
				set TotalFreight =  (AverageLiters * (var_CurrentDieselRate - var_DieselBaseRate)) + Cost;
			elseif(var_FreightRateType_Id = 'C029002') then
				set Cost =  var_Rate * var_FinalDistance;
                set TotalFreight =  (AverageLiters * (var_CurrentDieselRate - var_DieselBaseRate)) + Cost;
			elseif(var_FreightRateType_Id = 'C029003') then
				set Cost =  var_Rate * var_Liters;
				set TotalFreight =  (AverageLiters * (var_CurrentDieselRate - var_DieselBaseRate)) + Cost;
            end if;
            
			Update t021_tripdocument_header
			set 
			Locked_On = Current_Datetime,
			Locked_By = var_User_Id,
			FreightRateType_Id = var_FreightRateType_Id,
			FinalDistance = var_FinalDistance,
			Rate = var_Rate,
			TripAmount = var_TripAmount,
			DieselBaseRate = var_DieselBaseRate,
			CurrentDieselRate = var_CurrentDieselRate,
			Weight = var_Weight,
			Liters = var_Liters,
            Average_KM = AverageKM,
            Average_Liters = AverageLiters,
            Cost = Cost,
            Total_Freight = TotalFreight,
            FleetX_Id = var_FleetX_Id,
            DistanceAsPerFleetX = var_DistanceAsPerFleetX,
            DistanceAsPerApp = var_DistanceAsPerApp,
			Is_TripDocument_Locked = 1,
            Diesel_Difference = (var_CurrentDieselRate - var_DieselBaseRate)
			where Org_Id = var_Org_Id 
			and TripDocument_Id = var_TripDocument_Id;   

			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_TripDocument_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Update_Liters') then
		begin
			set @MilkCollectionDairy_Id = (select MilkCollectionDairy_Id 
							from t009_milkcollectiondairy_header 
							where 
							Org_Id = var_Org_Id
							and TripDocument_Id = var_TripDocument_Id
							limit 1);
							
			set @Weight = (select sum(Weight) from t009_milkcollectiondairy_quantity 
							where Org_Id = var_Org_Id
							and MilkCollectionDairy_Id = @MilkCollectionDairy_Id
							and MilkStatus_Id ='C016001');

			set @Liters = (select sum(Liters) from t009_milkcollectiondairy_quantity 
							where Org_Id = var_Org_Id
							and MilkCollectionDairy_Id = @MilkCollectionDairy_Id
							and MilkStatus_Id ='C016001');
						
			Delete from t009_milkcollectiondairy_milk
            where Org_Id = var_Org_Id
			and MilkCollectionDairy_Id = @MilkCollectionDairy_Id; 

			INSERT INTO t009_milkcollectiondairy_milk
			(Org_Id, MilkCollectionDairy_Id, MilkType_Id,MilkStatus_Id,Weight,Liters)
			VALUES (var_Org_Id, @MilkCollectionDairy_Id,'C011001','C016001',@Weight,@Liters); 
                
			SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_TripDocument_Id AS Result_Extra_Key;
                
        end;
	elseif (var_Method_Name = 'Reverse') then
		begin
			
            UPDATE t021_tripdocument_header 
			SET Is_TripDocument_Locked = 0 
			where Org_Id = var_Org_Id
			and TripDocument_Id = var_TripDocument_Id;
            
             call USP_AdminReverseLog_Set ('Create', var_Org_Id, '', 
				't021_tripdocument_header', var_TripDocument_Id, '', '', 
				var_User_Id, var_User_Name);
                
			SELECT 1 AS Result_Id, 
			'Reverse' AS Result_Description, 
			var_TripDocument_Id AS Result_Extra_Key;
        end;
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
