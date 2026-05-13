-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_ChemistManageTrip` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_ChemistManageTrip`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Route_Trip_Id varchar(20),
Var_Vehicle_No varchar(20),
Var_Profile_Id varchar(20),
Var_VehicleTrip_Id varchar(20),
Var_MCC_Id varchar (20)
)
BEGIN

    set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    SET SQL_SAFE_UPDATES = 0;
	
    if(Var_Method_Name = 'GetTrip') THEN
		
        insert into temp (text) value ( concat('nitzzz' , Var_VehicleTrip_Id , ' ' , Var_Org_Id));
        
		select t022.MCC_Id , m005.MCC_Name , Route_Name , m006.Route_Id , DATE_FORMAT(Expected_Time, '%h:%i %p') AS Expected_Time , ifnull(Is_Reached , 0) as Is_Reached , 
		DATE_FORMAT(t021.Created_On, '%h:%i %p') as  Trip_Started_On, Trip_Status, ifnull(Is_Vehicle_Breakdown,0) as Is_Vehicle_Breakdown 
        
        from t022_tripdocument_item t022 
		inner join m005_mcc m005 on m005.Org_Id = t022.Org_Id and m005.MCC_Id = t022.MCC_Id
		inner join t021_tripdocument_header t021 on t021.Org_Id = t022.Org_Id and t021.TripDocument_Id = t022.TripDocument_Id 
		inner join  m006_route m006 on m006.Org_Id = m005.Org_Id and m006.Route_Id = t022.Route_Id 
		where t021.TripDocument_Id = Var_VehicleTrip_Id and t022.Org_Id = Var_Org_Id
		order by Order_By asc ;
		
	elseif(Var_Method_Name = 'GetBMCDetails' ) then 
		
		select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and Applicable_Date <= @Current_Datetime and Org_Id = Var_Org_Id
		order by Applicable_Date desc limit 1 ;
        
        set @MCC_MilkType_Id =  (select group_concat(MilkType_Id) from m005_mcc_milktype where 
		MCC_ID = Var_MCC_Id and Version_No = @Version_No) ;
        
        insert into temp(text) value (Var_Vehicle_No);
        
       set @NoOfCellsInTanker = (select NoOfCellsInTanker from m003_vehicle where Org_Id = Var_Org_Id and Vehicle_Id =  (select Vehicle_Id from 
       m003_vehicle where Vehicle_No = Var_Vehicle_No and Org_Id = Var_Org_Id and Is_Active = 1 ) and Is_Active = 1 limit 1) ;

		set @IS_MilkCollected = 0;
        
        if exists (select ChemistCollection_Id from t008_milkcollectionchemist where Org_Id = Var_Org_Id and Trip_Id = Var_VehicleTrip_Id and 
       MCC_Id = Var_MCC_Id AND  Is_Active = 1  and Chemist_Id = Var_Profile_Id ) then
     
     set @IS_MilkCollected = 1;
			
            else 
             set @IS_MilkCollected = 0;
  end if;
  
  set @IS_CollectionLocked = if((select 1 from t008_milkcollectionchemist where Org_Id = Var_Org_Id and Trip_Id = Var_VehicleTrip_Id and 
        Is_Active = 1 and Is_BMC_Accepted = 1 and MCC_Id = Var_MCC_Id  and Chemist_Id = Var_Profile_Id)  = 1 , 1 , 0);

		select @MCC_MilkType_Id as MCC_MilkType_Id, CAST(@NoOfCellsInTanker AS SIGNED) as NoOfCellsInTanker ,  CAST(@IS_MilkCollected AS SIGNED) as IS_MilkCollected  , @IS_CollectionLocked as Is_CollectionLocked;
 
		elseif(Var_Method_Name = 'GetBMCDetailsdata' ) then 
 
		set @ChemistCollection_Id = ( select ChemistCollection_Id from t008_milkcollectionchemist where Org_Id = Var_Org_Id and Trip_Id = Var_VehicleTrip_Id and 
		Is_Active = 1 and  MCC_Id = Var_MCC_Id   and Chemist_Id = Var_Profile_Id order by ChemistCollection_Id desc limit 1 );
       
	
		select group_concat(Compartment_No) , group_concat(Quantity_Kg) into @CowCompartment_No , @CowQuantityInCompartment
        from t008_milkcollectionchemist_compartment where Org_Id = Var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id 
        and MilkType_Id = 'C011001'
        order by Compartment_No ;
        
		select group_concat(Compartment_No) , group_concat(Quantity_Kg) into @BufCompartment_No , @BufQuantityInCompartment
        from t008_milkcollectionchemist_compartment where Org_Id = Var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id 
        and MilkType_Id = 'C011002'
        order by Compartment_No ;
	
        select MilkType_Id , CAST(Quantity_ltr as CHAR(50)) as  Quantity_Kg , CAST(FAT as CHAR(50)) as  FAT , CAST(SNF as CHAR(50)) as SNF, 
        Milk_Alcohol , Milk_Temparature , Milk_Acidity , Comartment , Is_OrganolepticTest_Done , MilkStatus_Id , 
        if(MilkType_Id  = 'C011001' , @CowCompartment_No , @BufCompartment_No )  as CompartmentNo ,
        if(MilkType_Id  = 'C011001' , @CowQuantityInCompartment , @BufQuantityInCompartment )  as CompartmentQTY ,
        'MilkData' as EntryType from t008_milkcollectionchemist_item where Org_Id = Var_Org_Id and ChemistCollection_Id =  @ChemistCollection_Id;
        
	  end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
