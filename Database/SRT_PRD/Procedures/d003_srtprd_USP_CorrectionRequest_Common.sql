-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_CorrectionRequest_Common` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_CorrectionRequest_Common`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Date varchar(20),
Var_CollectionShift_Id varchar(20),
Var_Farmer_Id varchar(20),
Var_Milk_Quantity varchar(10),
Var_Milk_FAT varchar(10),
Var_Milk_SNF varchar(10),
Var_Remark Text,
Var_FarmerCollection_Id Varchar(20),
Var_Profile_Id varchar(20)
)
BEGIN
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    
		if(Var_Method_Name = 'GetData')THEN 

			select ifnull(t005.FarmerCollection_Id , '') as Collection_Id , ifnull(Quantity_Ltr,0.0) as Quantity_Ltr, 
            ifnull(Fat ,0.0) as Fat , ifnull(SNF,0.0) as SNF from t005_milkcollectionfarmer t005 inner join t004_mcccollectionshift t004 
			on t005.Org_Id = t004.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
			where t005.MCC_Id = Var_MCC_Id and  Farmer_Id = Var_Farmer_Id and date(t005.Created_On) = date(Var_Date)
			and t004.CollectionShift_Id = Var_CollectionShift_Id limit 1;


		elseif(Var_Method_Name = 'ApplyCorrectionReq') THEN 

			set @Correction_Req_Id = '';
			set @Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('t013_correction_request', @Year_Id, 'T013', '', @Correction_Req_Id);

			set @kg_to_ltr = (select Kg_To_Ltr_Farmer from c001_organization where Org_Id = Var_Org_Id);
			set @Milk_Quantity_ltr =  Var_Milk_Quantity;


			if NOT exists(select 1 from t013_correction_request where Org_Id = Var_Org_Id and FarmerCollection_Id = Var_FarmerCollection_Id 
			and Is_Approved_L1 = 0 ) then 

				Insert into t013_correction_request (Org_Id , Correction_Request_Id, FarmerCollection_Id, Request_Quantity_Ltr , Request_Fat ,
				Request_SNF , Request_Remark , Is_Approved_L1, Created_On , Created_By)  values
				(Var_Org_Id, @Correction_Req_Id , Var_FarmerCollection_Id, @Milk_Quantity_ltr , Var_Milk_FAT , Var_Milk_SNF , Var_Remark , 0 , @Current_Datetime , Var_Profile_Id  ) ;

				select 1 as Result_Id, 'Applied for Request' as Result_Description, @Entry_Id as Result_Extra_Key;  
                
			else 
            
				select -1 as Result_Id, 'Already Applied for Request' as Result_Description, @Entry_Id as Result_Extra_Key;

			end if;

		elseif(Var_Method_Name = 'GetAppliedRequest') THEN 
        
			select t005.Correction_Request_Id ,mu04.Farmer_Name, c015.CollectionShift_Name as CollectionShift_Name ,
			IFNULL(t013.Is_Approved_L2 , 0) as Is_Approved , t013.Request_Quantity_Ltr , t013.Request_Fat , t013.Request_SNF , 
            ifnull(t013.Request_Remark , '')  as Request_Remark,
			ifnull(t013.Approved_Quantity_Ltr,0.0) as Approved_Quantity_Ltr , 
            ifnull(t013.Approved_Fat,0.0) as Approved_Fat , 
            ifnull(t013.Approved_SNF,0.0) as Approved_SNF, 
            ifnull(t013.Approved_Remark_L2, '' ) as Approved_Remark, 
            ifnull(t013.Is_Approved_L2, '' ) as Approved_On, 
			DATE_FORMAT(t013.Created_On, '%e %b %Y')
            as Created_On from t013_correction_request t013 inner join t005_milkcollectionfarmer t005 on t013.Org_Id = t005.Org_Id 
			and  t013.FarmerCollection_Id = t005.FarmerCollection_Id 
			inner join mu04_farmer mu04 on mu04.Farmer_Id = t005.Farmer_Id and mu04.Org_Id = t005.Org_Id 
            inner join t004_mcccollectionshift t004 on t004.Org_Id = t005.Org_Id and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id 
			inner join c015_collectionshift c015 on c015.CollectionShift_Id = t004.CollectionShift_Id
			where t005.MCC_Id = Var_MCC_Id and t005.Org_Id  = Var_Org_Id and  
			month(t013.Created_On) = month(Var_Date) and Year(t013.Created_On) = year(Var_Date);
        
        
end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
