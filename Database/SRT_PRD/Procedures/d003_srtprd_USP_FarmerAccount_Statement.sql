-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerAccount_Statement` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerAccount_Statement`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Profile_Id varchar(20),
Var_StartDate varchar(20),
Var_EndDate varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

if(Var_Method_Name = 'GetAccoutStatement') then 

select DATE_FORMAT(Statement_Date ,'%e %M %Y') as Collection_Date , Opening_Balance , Credit , Debit , FAT , SNF , Quantity ,Current_Balance
from f004_farmeraccount_statement where Org_Id = Var_Org_Id  and Farmer_Id = Var_Profile_Id
and date(Statement_Date) between date(STR_TO_DATE(Var_StartDate, '%m/%d/%Y')) and date(STR_TO_DATE(Var_EndDate, '%m/%d/%Y'));

-- select t005.FarmerCollection_Id, t005.MCCCollectionShift_Id, c015.CollectionShift_Name, t005.Quantity_Ltr, t005.Quantity_Kg, t005.ApplicableRate , t005.Amount , 
-- DATE_FORMAT(t005.Created_On, '%d %M %Y')  as Collection_Date
-- from t005_milkcollectionfarmer t005 inner join t004_mcccollectionshift t004 on t005.Org_Id = t004.Org_Id and 
-- t005.MCCCollectionShift_Id = t004.MCCCollectionShift_Id
-- inner join c015_collectionshift c015 on c015.CollectionShift_Id = t004.CollectionShift_Id
-- where t005.Farmer_Id = Var_Profile_Id and t005.Org_Id = Var_Org_Id and date(t005.Created_On) between 

end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
