-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminManageTrip_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminManageTrip_Get`(
	IN `var_Method_Name` varchar(20),
	IN `var_Org_Id` varchar(10),
	IN `var_User_Id` varchar(20),
	IN `var_Date` varchar(60),
	IN `var_Route_Trip_Id` varchar(20),
	IN `var_MCC_Id` varchar(20),
	IN `var_MCCCollectionShift_Id` varchar(20),
	IN `var_TripDocument_Id` varchar(20),
	IN `var_Profile_Id` varchar(20),
	IN `var_Reason` varchar(50)
)
BEGIN
	set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
	if (var_Method_Name = 'Get') then  
		begin
			SELECT 
			m008.Entry_Id,
			m006.Route_Id,m006.Route_Name ,
            ifnull(c015.CollectionShift_Id ,'' )as CollectionShift_Id,
            ifnull(c015.CollectionShift_Name ,'' )as CollectionShift_Name,
			m003.Vehicle_Id,m003.Vehicle_No ,
			c020.VehicleType_Id,c020.VehicleType_Name,
			mu06.Driver_Id,mu06.Driver_Name ,
            mu07.Chemist_Id,ifnull(mu07.Chemist_Name ,'') as Chemist_Name,
			t021.TripDocument_Id,
			CASE WHEN t021.Route_Trip_Id IS NOT NULL AND t021.Route_Trip_Id != '' THEN 1 ELSE 0 END AS Is_TripAssigned
			FROM m008_route_vehicle m008
			inner join m006_route m006 on m006.Route_Id = m008.Route_Id and m006.Org_Id = m008.Org_Id
			left join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id
			inner join m003_vehicle m003 on m003.Vehicle_Id = m008.Vehicle_Id and m003.Org_Id = m008.Org_Id
			inner join c020_vehicletype c020 on c020.VehicleType_Id = m003.VehicleType_Id
			inner join mu06_driver mu06 on mu06.Driver_Id = m008.Driver_Id and mu06.Org_Id = m008.Org_Id
            
            left join mu07_routechemist mu07 on mu07.Chemist_Id = m008.Chemist_Id and mu07.Org_Id = m008.Org_Id
			left join t021_tripdocument_header t021 on t021.Route_Trip_Id = m008.Entry_Id  and t021.Org_Id = m008.Org_Id
			and date(t021.Created_On) = date(@Current_Datetime)
			WHERE date(@Current_Datetime) BETWEEN date(m008.From_Date) AND date(m008.To_Date)
			and m008.Org_Id = var_Org_Id
            and m008.Is_Active = 1
            and m008.Is_Deleted = 0;
		end;
	elseif (var_Method_Name = 'Get_One') then  
		begin
			SELECT 
			m008.Entry_Id,
			m006.Route_Id,m006.Route_Name ,
			c015.CollectionShift_Id,c015.CollectionShift_Name,
			m003.Vehicle_Id,m003.Vehicle_No ,
			c020.VehicleType_Id,c020.VehicleType_Name,
			mu06.Driver_Id,mu06.Driver_Name ,
            mu07.Chemist_Id,ifnull(mu07.Chemist_Name ,'') as Chemist_Name
			FROM m008_route_vehicle m008
			inner join m006_route m006 on m006.Route_Id = m008.Route_Id and m006.Org_Id = m008.Org_Id
			inner join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id
			inner join m003_vehicle m003 on m003.Vehicle_Id = m008.Vehicle_Id and m003.Org_Id = m008.Org_Id
			inner join c020_vehicletype c020 on c020.VehicleType_Id = m003.VehicleType_Id
			inner join mu06_driver mu06 on mu06.Driver_Id = m008.Driver_Id and mu06.Org_Id = m008.Org_Id
            left join mu07_routechemist mu07 on mu07.Chemist_Id = m008.Chemist_Id and mu07.Org_Id = m008.Org_Id
			 WHERE 
			 m008.Org_Id = var_Org_Id
            and m008.Entry_Id = var_Route_Trip_Id;
		end;
	elseif (var_Method_Name = 'Get_Farmer') then  
		begin
			/*
			SELECT 
				t005.Quantity_Ltr as Liters,
                t005.Quantity_Kg as Weight,
                t005.FAT,t005.SNF,
				c011.MilkType_Id,c011.MilkType_Name,
				c016.MilkStatus_Id,c016.MilkStatus_Name,
                mu04.Farmer_Id,mu04.Farmer_Name,
                 ifnull(mu04.Farmer_Code,'') as Farmer_Code
			FROM t005_milkcollectionfarmer t005
			inner join c011_milktype c011 on t005.Milktype_Id = c011.Milktype_Id
			inner join c016_milkstatus c016 on t005.MilkStatus_Id = c016.MilkStatus_Id
            inner join mu04_farmer mu04 on t005.Org_Id = mu04.Org_Id and t005.Farmer_Id = mu04.Farmer_Id
			where t005.Org_Id = var_Org_Id
			and t005.MCC_Id = var_MCC_Id
			and t005.MCCCollectionShift_Id = var_MCCCollectionShift_Id;
            */
            SELECT 
				t005.Quantity_Ltr as Liters,
                t005.Quantity_Kg as Weight,
                t005.FAT,t005.SNF,
				c011.MilkType_Id,c011.MilkType_Name,
				c016.MilkStatus_Id,c016.MilkStatus_Name,
                mu04.Farmer_Id,mu04.Farmer_Name,
                 ifnull(mu04.Farmer_Code,'') as Farmer_Code,
                 t005.Is_InvoiceCreated as Is_Locked
			FROM t005_milkcollectionfarmer t005
			inner join c011_milktype c011 on t005.Milktype_Id = c011.Milktype_Id
			inner join c016_milkstatus c016 on t005.MilkStatus_Id = c016.MilkStatus_Id
            inner join mu04_farmer mu04 on t005.Org_Id = mu04.Org_Id and t005.Farmer_Id = mu04.Farmer_Id
			where t005.Org_Id = var_Org_Id
			and t005.MCC_Id = var_MCC_Id
			and t005.MCCCollectionShift_Id = var_MCCCollectionShift_Id;
		end;
	elseif (var_Method_Name = 'Get_MCC') then  
		begin
			SELECT 
				t0061.Quantity_Ltr as Liters,t0061.FAT,t0061.SNF,
				c011.MilkType_Id,c011.MilkType_Name,
				c016.MilkStatus_Id,c016.MilkStatus_Name
			FROM t006_milkcollectionagent t006
			inner join t006_milkcollectionagent_item t0061 on t006.Org_Id = t0061.Org_Id and t006.AgentCollection_Id = t0061.AgentCollection_Id
			inner join c011_milktype c011 on t0061.Milktype_Id = c011.Milktype_Id
			inner join c016_milkstatus c016 on t0061.MilkStatus_Id = c016.MilkStatus_Id
			where t006.Org_Id = var_Org_Id
			and t006.MCC_Id = var_MCC_Id
			and t006.MCCCollectionShift_Id = var_MCCCollectionShift_Id;
		end;
	elseif (var_Method_Name = 'Get_Chemist') then  
		begin
			SELECT 
				t0081.Quantity_Ltr as Liters,
                t0081.Quantity_Kg as Weight,
                t0081.FAT,t0081.SNF,
				c011.MilkType_Id,c011.MilkType_Name,
				c016.MilkStatus_Id,c016.MilkStatus_Name,
                t0081.Comartment as Cell_No
			FROM t008_milkcollectionchemist t008
			inner join t022_tripdocument_item t022 on
            t022.Org_Id =  t008.Org_Id
            and t022.MCC_CollectionShift_Id =  t008.MCCCollectionShift_Id
            and t022.MCC_Id =  t008.MCC_Id
            and t022.DispatchNo =  t008.DispatchNo 
            and t022.TripDocument_Id  = var_TripDocument_Id
			inner join t008_milkcollectionchemist_item t0081 on t008.Org_Id = t0081.Org_Id and t008.ChemistCollection_Id = t0081.ChemistCollection_Id
			inner join c011_milktype c011 on t0081.Milktype_Id = c011.Milktype_Id
			inner join c016_milkstatus c016 on t0081.MilkStatus_Id = c016.MilkStatus_Id
			where t008.Org_Id = var_Org_Id
			and t008.MCC_Id = var_MCC_Id
			and t008.MCCCollectionShift_Id = var_MCCCollectionShift_Id;
		end;
	elseif (var_Method_Name = 'GetVehicleStatus') then 
		begin
			IF (var_TripDocument_Id = '' OR  var_TripDocument_Id IS NULL ) THEN 
            
            
				set @var_TripDocument_Id  = (select t021.TripDocument_Id from t021_tripdocument_header t021 where  Driver_Id = var_Profile_Id 
				and DATE(Created_On) = DATE(@Current_Datetime) and Org_Id = var_Org_Id order by Created_On desc limit 1);
			else
           
				set @var_TripDocument_Id = var_TripDocument_Id;
			END IF;
			
             
            set @Is_Release = (select Is_Release from t009_milkcollectiondairy_header where Org_Id = var_Org_Id 
			and TripDocument_Id = @var_TripDocument_Id and is_active = 1 limit 1 );
            
            
			set @Is_EndTrip_Available = if (@Is_Release is null , 0 , @Is_Release);
            
             
            set @VehicleType = (select VehicleType_Id from t021_tripdocument_header t021 inner join m003_vehicle m003 on  t021.Org_Id = m003.Org_Id and t021.Vehicle_Id = m003.Vehicle_Id
			where TripDocument_Id = @var_TripDocument_Id limit 1 ) ;
            
            select
            t021.Route_Trip_Id as Entry_Id,t021.Driver_Id,
            t022.TripDocument_Id ,ifnull(t022.MCC_CollectionShift_Id,'') as MCC_CollectionShift_Id, t022.MCC_Id , m005.MCC_Name , Route_Name , m006.Route_Id , DATE_FORMAT(Expected_Time, '%h:%i %p') as  Expected_Time , ifnull(Is_Reached , 0) as Is_Reached , 
			DATE_FORMAT(t021.Created_On, '%h:%i %p') as Trip_Started_On, Trip_Status, ifnull(Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown ,
            m003.Vehicle_No , m003.VehicleType_Id , ifnull(DATE_FORMAT(Arrival_At, '%h:%i %p'),'') AS Arrival_At , @Is_EndTrip_Available as Is_EndTrip_Available,Order_By,
            SUM(IFNULL(t006.Final_Qty_Cow_KG, 0) + IFNULL(t006.Final_Qty_Buf_KG, 0)) AS Weight,
			SUM(IFNULL(t006.Final_Qty_Cow_Ltr, 0) + IFNULL(t006.Final_Qty_Buf_Ltr, 0)) AS Liters,
            CASE
				WHEN t006.MCCCollectionShift_Id IS NULL OR t006.MCC_Id = '' THEN 0
				ELSE 1
			END AS Is_Collected,
            c015.CollectionShift_Id,c015.CollectionShift_Name
            from t022_tripdocument_item t022 
			inner join m005_mcc m005 on m005.Org_Id = t022.Org_Id and m005.MCC_Id = t022.MCC_Id
			inner join t021_tripdocument_header t021 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id 
			inner join  m006_route m006 on m006.Org_Id = m005.Org_Id and m006.Route_Id = t022.Route_Id 
            left join  c015_collectionshift c015 on m006.CollectionShift_Id = c015.CollectionShift_Id 
			left join m003_vehicle m003 on m003.Org_Id = t021.Org_Id and m003.Vehicle_Id =  t021.Vehicle_Id
            left join t006_milkcollectionagent t006 on t006.Org_Id = t022.Org_Id 
            and t006.MCCCollectionShift_Id =  t022.MCC_CollectionShift_Id
            and t006.MCC_Id =  t022.MCC_Id
			where t021.TripDocument_Id = @var_TripDocument_Id and t022.Org_Id = var_Org_Id
            GROUP BY
            t021.Route_Trip_Id ,t021.Driver_Id,
				t022.TripDocument_Id,t022.MCC_CollectionShift_Id ,
				t022.MCC_Id, m005.MCC_Name, Route_Name, m006.Route_Id, Expected_Time, Is_Reached,
				Trip_Started_On, Trip_Status, Is_Vehicle_Breakdown, m003.Vehicle_No, m003.VehicleType_Id,
				Arrival_At, Is_EndTrip_Available, Order_By,t006.MCCCollectionShift_Id,t006.MCC_Id,
                c015.CollectionShift_Id,c015.CollectionShift_Name
            order by Order_By asc ;
        end;
		elseif (var_Method_Name = 'GetRateMCC') then 
        begin 
			declare MilkRateFlag int;
			declare MPPIFlag int;
			declare TransporterFlag int;
			declare AnamatFlag int;
            declare RateAvailableFlag varchar(50);
            set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
            if exists(select m001.Chart_Id from m001_milkrate_mcc_header m0012
						inner join m001_milkrate_mcc_item m0011 on 
						m0012.Org_Id = m0011.Org_Id 
						and m0012.Chart_Id = m0011.Chart_Id 
						and m0011.MCC_Id = var_MCC_Id
						inner join m001_milkrate m001 on 
						m0012.Org_Id = m001.Org_Id 
						and m0012.Chart_Id = m001.Chart_Id 
						and m001.MilkType_Id in ('C011001','C011002')
						where m0012.Org_Id = var_Org_Id
						and date(m0012.Applicable_Date) <=  date(@Current_Datetime ) 
						order by m0012.Applicable_Date desc limit 1) then
                        
				set	MilkRateFlag = 1;
            else
				set	MilkRateFlag = 0;
            end if;
            
            if exists(select Entry_Id from m002_commission_mcc where Org_Id = var_Org_Id
						and MCC_Id = var_MCC_Id
						and date(Applicable_Date) <=  date(@Current_Datetime) 
						order by Applicable_Date desc limit 1) then
                        
				set	MPPIFlag = 1;
            else
				set	MPPIFlag = 0;
            end if;
            
            if exists(select Freight_PerLtr from m005_mcc_version
						where Org_Id = var_Org_Id
						and MCC_Id = var_MCC_Id
                        and Is_Active = 1
						and date(Applicable_Date) <=  date(@Current_Datetime) 
						order by Applicable_Date desc limit 1) then
                        
				set	TransporterFlag = 1;
            else
				set	TransporterFlag = 0;
            end if;
            
            if exists(select Anamat_PerLtr from m005_mcc_version
						where Org_Id = var_Org_Id
						and MCC_Id = var_MCC_Id
                        and Is_Active = 1
						and date(Applicable_Date) <=  date(@Current_Datetime) 
						order by Applicable_Date desc limit 1) then
                        
				set	AnamatFlag = 1;
            else
				set	AnamatFlag = 0;
            end if;
            
            
            set RateAvailableFlag = concat(MilkRateFlag, ' ',
											MPPIFlag, ' ',
                                            TransporterFlag, ' ',
                                            AnamatFlag);
										
			select RateAvailableFlag;
										
        
        end ;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
