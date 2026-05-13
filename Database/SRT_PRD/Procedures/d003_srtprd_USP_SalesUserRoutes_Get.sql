-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesUserRoutes_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesUserRoutes_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    Var_Profile_Id varchar(20),
    Var_SalesUser_Id varchar(20),
    Var_Day Varchar(20),
    
    Var_Route_Id varchar(20),
    Var_Dealer_Id varchar(20)
)
BEGIN

	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	IF(var_Method_Name = 'GetRoutes') then 
    
			if(ifnull(Var_Route_Id,'') <> '' and  ifnull(Var_Dealer_Id,'') <> '') then
            
				SELECT m019.Route_Id as Route_Id , mu09.Retailer_Name , ifnull(concat(Address_Line_1_Text ,'',  Address_Line_2_Text ,' ',  State_Name ,
				' ', District_Name ,' ', Taluka_Name , ifnull(Village_Name , '')),'-') as Address 
				FROM m019_salesuserroute_header m019 
				inner join m019_salesuserroute_item m019i on m019i.Route_Id = m019.Route_Id 
				inner join c045_route_day c045 on m019.RouteDay_Id = c045.RouteDay_Id
				left join mu12_sales_user mu12 on mu12.SalesUser_Id = m019.SalesUser_Id
				inner join mu09_retailer mu09 on mu09.Retailer_Id = m019i.Retailer_Id
                and mu09.Dealer_Id = Var_Dealer_Id
				left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
				left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
				left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
				left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
				where m019.RouteDay_Id = Var_Day
				and m019.SalesUser_Id = Var_SalesUser_Id
                and m019.Route_Id = Var_Route_Id
				and m019.Org_Id = var_Org_Id;
            
            elseif(ifnull(Var_Route_Id,'') <> '' and  ifnull(Var_Dealer_Id,'') = '') then
            
				SELECT m019.Route_Id as Route_Id , mu09.Retailer_Name , ifnull(concat(Address_Line_1_Text ,'',  Address_Line_2_Text ,' ',  State_Name ,
				' ', District_Name ,' ', Taluka_Name , ifnull(Village_Name , '')),'-') as Address 
				FROM m019_salesuserroute_header m019 
				inner join m019_salesuserroute_item m019i on m019i.Route_Id = m019.Route_Id 
				inner join c045_route_day c045 on m019.RouteDay_Id = c045.RouteDay_Id
				left join mu12_sales_user mu12 on mu12.SalesUser_Id = m019.SalesUser_Id
				inner join mu09_retailer mu09 on mu09.Retailer_Id = m019i.Retailer_Id
				left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
				left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
				left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
				left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
				where m019.RouteDay_Id = Var_Day
				and m019.SalesUser_Id = Var_SalesUser_Id
                and m019.Route_Id = Var_Route_Id
				and m019.Org_Id = var_Org_Id;
            
            elseif(ifnull(Var_Route_Id,'') = '' and  ifnull(Var_Dealer_Id,'') <> '') then
            
				SELECT m019.Route_Id as Route_Id , mu09.Retailer_Name , ifnull(concat(Address_Line_1_Text ,'',  Address_Line_2_Text ,' ',  State_Name ,
				' ', District_Name ,' ', Taluka_Name , ifnull(Village_Name , '')),'-') as Address 
				FROM m019_salesuserroute_header m019 
				inner join m019_salesuserroute_item m019i on m019i.Route_Id = m019.Route_Id 
				inner join c045_route_day c045 on m019.RouteDay_Id = c045.RouteDay_Id
				left join mu12_sales_user mu12 on mu12.SalesUser_Id = m019.SalesUser_Id
				inner join mu09_retailer mu09 on mu09.Retailer_Id = m019i.Retailer_Id
                and mu09.Dealer_Id = Var_Dealer_Id
				left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
				left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
				left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
				left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
				where m019.RouteDay_Id = Var_Day
				and m019.SalesUser_Id = Var_SalesUser_Id
				and m019.Org_Id = var_Org_Id;
            
            elseif(ifnull(Var_Route_Id,'') <> '' and  ifnull(Var_Dealer_Id,'') <> '') then
            
				SELECT m019.Route_Id as Route_Id , mu09.Retailer_Name , ifnull(concat(Address_Line_1_Text ,'',  Address_Line_2_Text ,' ',  State_Name ,
				' ', District_Name ,' ', Taluka_Name , ifnull(Village_Name , '')),'-') as Address 
				FROM m019_salesuserroute_header m019 
				inner join m019_salesuserroute_item m019i on m019i.Route_Id = m019.Route_Id 
				inner join c045_route_day c045 on m019.RouteDay_Id = c045.RouteDay_Id
				left join mu12_sales_user mu12 on mu12.SalesUser_Id = m019.SalesUser_Id
				left join mu09_retailer mu09 on mu09.Retailer_Id = m019i.Retailer_Id
				left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
				left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
				left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
				left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
				where m019.RouteDay_Id = Var_Day
				and m019.SalesUser_Id = Var_SalesUser_Id
				and m019.Org_Id = var_Org_Id;
            
            else
            
				SELECT m019.Route_Id as Route_Id , mu09.Retailer_Name , ifnull(concat(Address_Line_1_Text ,'',  Address_Line_2_Text ,' ',  State_Name ,
				' ', District_Name ,' ', Taluka_Name , ifnull(Village_Name , '')),'-') as Address 
				FROM m019_salesuserroute_header m019 
				inner join m019_salesuserroute_item m019i on m019i.Route_Id = m019.Route_Id 
				inner join c045_route_day c045 on m019.RouteDay_Id = c045.RouteDay_Id
				left join mu12_sales_user mu12 on mu12.SalesUser_Id = m019.SalesUser_Id
				left join mu09_retailer mu09 on mu09.Retailer_Id = m019i.Retailer_Id
				left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
				left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
				left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
				left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
				where m019.RouteDay_Id = Var_Day
				and m019.SalesUser_Id = Var_SalesUser_Id
				and m019.Org_Id = var_Org_Id;
            
            end if;
            


	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
