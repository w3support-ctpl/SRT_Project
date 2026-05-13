-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_IssueCansToMcc` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_IssueCansToMcc`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Trip_Id varchar(20),
Var_Route_Id varchar(20)
)
BEGIN
	drop temporary table if exists temp_TBL;

	create temporary table temp_TBL( 
	org_id varchar(20) ,  
	MCC_Id varchar(20) ,
	Qty varchar(20) ,
	Material_Id varchar(20) 
	);


		insert into temp_TBL(org_id,MCC_Id ,Qty , Material_Id ) 
		select Var_Org_Id , t006.MCC_Id , Aluminum_Can_With_Lid  as Qty , 
        (select Material_Id from m010_material where MaterialType_Id = 'C042231000001' and Org_Id = Var_Org_Id limit 1 ) as Material_Id
		from t022_tripdocument_item t022
		inner join t004_mcccollectionshift t004 on t004.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id and  t004.Org_Id = t022.Org_Id
		inner join t006_milkcollectionagent t006 on t004.MCCCollectionShift_Id = t006.MCCCollectionShift_Id and  t004.Org_Id = t006.Org_Id
		where TripDocument_Id = Var_Trip_Id
		/*
        UNION all
		select Var_Org_Id , t006.MCC_Id , Aluminum_Can_Without_Lid  as Qty , 
        (select Material_Id from m010_material where MaterialType_Id = 'C042231000002' and Org_Id = Var_Org_Id limit 1 )  as Material_Id
		from t022_tripdocument_item t022
		inner join t004_mcccollectionshift t004 on t004.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id and  t004.Org_Id = t022.Org_Id
		inner join t006_milkcollectionagent t006 on t004.MCCCollectionShift_Id = t006.MCCCollectionShift_Id and  t004.Org_Id = t006.Org_Id
		where TripDocument_Id = Var_Trip_Id
		UNION all
		select Var_Org_Id ,  t006.MCC_Id ,Plastic_Can_With_Lid  as Qty , 
        (select Material_Id from m010_material where MaterialType_Id = 'C042231000003' and Org_Id = Var_Org_Id limit 1 ) as Material_Id
		from t022_tripdocument_item t022
		inner join t004_mcccollectionshift t004 on t004.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id and  t004.Org_Id = t022.Org_Id
		inner join t006_milkcollectionagent t006 on t004.MCCCollectionShift_Id = t006.MCCCollectionShift_Id and  t004.Org_Id = t006.Org_Id
		where TripDocument_Id = Var_Trip_Id
		UNION all
		select Var_Org_Id , t006.MCC_Id ,Plastic_Can_Without_Lid as Qty , 
        (select Material_Id from m010_material where MaterialType_Id = 'C042231000004' and Org_Id = Var_Org_Id limit 1 ) as Material_Id
		from t022_tripdocument_item t022
		inner join t004_mcccollectionshift t004 on t004.MCCCollectionShift_Id = t022.MCC_CollectionShift_Id and  t004.Org_Id = t022.Org_Id
		inner join t006_milkcollectionagent t006 on t004.MCCCollectionShift_Id = t006.MCCCollectionShift_Id and  t004.Org_Id = t006.Org_Id
		where TripDocument_Id = Var_Trip_Id
		group by MCC_Id , Material_Id , Qty
        */
        ;

set @IssueStocks_Id = '';
set @Year_Id = (select right(left(curdate(),4),(2)));
Call USP_Number_Range ('t018_issuestocks_header', @Year_Id, 'T018', '', @IssueStocks_Id);


	select Vehicle_Id , Route_Trip_Id , Driver_Id into @Vehicle_Id , @Route_Trip_Id , @Driver_Id from 
    t021_tripdocument_header where TripDocument_Id = Var_Trip_Id and Org_Id = Var_Org_Id limit 1;
    
   set @CollectionShift_Id = (select CollectionShift_Id from m006_route m006 
   inner join m008_route_vehicle m008 on m006.Org_Id = m008.Org_Id  and m006.Route_Id = m008.Route_Id
   where m008.Entry_Id = @Route_Trip_Id and m008.Org_Id = Var_Org_Id limit 1);
    

	set @Route_Id  = (select Route_Id from m008_route_vehicle
					where Org_Id = Var_Org_Id
					and Entry_Id = @Route_Trip_Id limit 1);

insert into t018_issuestocks_header (Org_Id, IssueStocks_Id, StockIssue_Type, 
Route_Id, Vehicle_Id, CollectionShift_Id, Driver_Id, Driver_Name, IssueStock_Date, Is_DriverAccepted,
 Is_Accepted, Is_Active, Is_Deleted, Created_On)  value 
 ( Var_Org_Id  , @IssueStocks_Id , 'Cans' ,  @Route_Id , @Vehicle_Id ,  @CollectionShift_Id , @Driver_Id, 
 (select Driver_Name from mu06_driver where Driver_Id = @Driver_Id and Org_Id = Var_Org_Id limit 1) , now() , 0, 0, 1, 0, now() );
 

 insert into t019_issuestocks_item (Org_Id, IssueStocks_Id, Order_Id,
 IssueStockToProfile_Id, Material_Id, MCC_Id, IssueStockToProfile_Type, MCC_CollectionShift_Id, 
 Quantity, Is_MCCAccepted)

 select Var_Org_Id , @IssueStocks_Id , '0' , (select Agent_Id from  m005_mcc where MCC_Id = temp_TBL.MCC_Id and Org_Id = Var_Org_Id ) , Material_Id ,MCC_Id,
 'MCC' , @CollectionShift_Id  , Qty , 0 from temp_TBL where Org_Id = Var_Org_Id and 
Qty > 0 ;
 
 


END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
