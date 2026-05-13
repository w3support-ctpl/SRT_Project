-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentManageStock` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentManageStock`(
Var_Method_Name varchar(40),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_IssueStocks_Id varchar(20),
Var_StockType varchar(50),
Var_OrderId varchar(20),
Var_Date varchar(20),
Var_Profile_Id varchar(20),
Var_Material_Id varchar(20),
Var_Farmer_Id varchar(20)
)
BEGIN
set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
	SET sql_mode = '';

	if(Var_Method_Name = 'GetReceivedStock') then
    
    drop temporary table if exists temp_tblstock;
	create Temporary table temp_tblstock(  
	Org_ID varchar(20),
    IssueStocks_Id varchar(50) default '',
    StockIssue_Type varchar(100) default '' ,
	Material_Id varchar(20) default '',
    Material_Name varchar(200) default '',
    AluminumCan_WithLid varchar(20) default '', 
    AluminumCan_WithoutLid varchar(20) default '', 
    PlasticCan_WithLid varchar(20) default '',
    PlasticCan_WiithoutLid varchar(20) default '',
    Quantity varchar(20) default '',
    Is_Approved int default 0,
    AppliedDate varchar(40)  default '',
    OrderId  varchar(40)  default ''
    );
		
		insert into temp_tblstock(Org_ID ,IssueStocks_Id , StockIssue_Type , AluminumCan_WithLid,
		AluminumCan_WithoutLid , PlasticCan_WithLid , PlasticCan_WiithoutLid , Is_Approved , AppliedDate )
		
select Var_Org_Id, A.IssueStocks_Id , A.StockIssue_Type,
A.AluminumCan_WithLid AS AluminumCan_WithLid ,
     A.AluminumCan_WithoutLid AS A ,
     A.PlasticCan_WithLid AS PlasticCan_WithLid ,
     A.PlasticCan_WithoutLid  AS PlasticCan_WithoutLid ,
     A.Is_DriverAccepted , A.IssueStock_Date FROM
     (select Var_Org_Id , t018.IssueStocks_Id,  StockIssue_Type, 
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000001' THEN Quantity ELSE NULL END) ,0) AS AluminumCan_WithLid,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000002' THEN Quantity ELSE NULL END) , 0)AS AluminumCan_WithoutLid,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000003' THEN Quantity ELSE NULL END),0) AS PlasticCan_WithLid,
    ifnull(sum(CASE WHEN m010.MaterialType_Id = 'C042231000004' THEN Quantity  ELSE NULL END),0) AS PlasticCan_WithoutLid,
		Is_DriverAccepted , DATE_FORMAT(IssueStock_Date, '%d %M %Y') AS IssueStock_Date
		from t018_issuestocks_header t018 
		inner join t019_issuestocks_item t019 on  t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
		left join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id =  t019.Material_Id
         left join m017_product m017 on m017.Org_Id = t019.Org_Id and t019.Material_Id = m017.Product_Id
		where (if(t018.Driver_Id <> 'Other' , t018.Is_DriverAccepted = 1 , 1 = 1 )) 
		and t019.Is_MCCAccepted = 0 and StockIssue_Type in ('Cans') and t019.MCC_Id = Var_MCC_Id and t019.Org_Id = Var_Org_Id
		group by t018.IssueStocks_Id, IssueStockToProfile_Id , StockIssue_Type , IssueStock_Date , Var_Org_Id , Is_DriverAccepted ) A
        where A.AluminumCan_WithLid <> 0 or  A.AluminumCan_WithoutLid <> 0 or A.PlasticCan_WithLid <> 0  or A.PlasticCan_WithoutLid <> 0;
           
		insert into temp_tblstock ( Org_ID , IssueStocks_Id , StockIssue_Type , Material_Id , Material_Name, Quantity, Is_Approved , AppliedDate , OrderId)
        select Var_Org_Id , t018.IssueStocks_Id,  StockIssue_Type, t019.Material_Id ,  ifnull(m010.Material_Name , m017.Product_Name) as Material_Name , t019.Quantity , 
		Is_DriverAccepted , DATE_FORMAT(IssueStock_Date, '%d %M %Y') , Order_Id
		from t018_issuestocks_header t018 
		inner join t019_issuestocks_item t019 on  t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
		left join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id =  t019.Material_Id
		left join m017_product m017 on m017.Org_Id = t019.Org_Id and t019.Material_Id = m017.Product_Id
		where (if(t018.Driver_Id <> 'Other' , t018.Is_DriverAccepted = 1 , 1 = 1 )) 
		and t019.Is_MCCAccepted = 0 and StockIssue_Type in ('Material' , 'Product') and t019.MCC_Id = Var_MCC_Id and t019.Org_Id = Var_Org_Id ;
        
        select * from temp_tblstock order by StockIssue_Type asc ;
        
        elseif (Var_Method_Name = 'AcceptStock') then 
			
            if(Var_StockType = 'Cans') then 
            update t018_issuestocks_header t018 
			inner join t019_issuestocks_item t019 on t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
            set Is_MCCAccepted = 1 ,
            Is_Given = 1 ,
            Given_Date = @Current_Datetime ,
            MCC_Accepted_On = @Current_Datetime
            where t018.IssueStocks_Id = Var_IssueStocks_Id and t019.MCC_Id = Var_MCC_Id;
            
          
			call USP_UpdateMCC_Stock('UpdateMCCStockCan', Var_Org_Id, Var_MCC_Id, Var_Material_Id, @Current_Datetime, Var_IssueStocks_Id);

           
            
            elseif(Var_StockType = 'Material') then
			
            update t018_issuestocks_header t018 
			inner join t019_issuestocks_item t019 on t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
            set Is_MCCAccepted = 1,
			MCC_Accepted_On = @Current_Datetime
            where t018.IssueStocks_Id = Var_IssueStocks_Id and t019.MCC_Id = Var_MCC_Id and  t019.Material_Id = Var_Material_Id
            and t019.Order_Id =  Var_OrderId;
                
			update t018_issuestocks_header t018 
			inner join t019_issuestocks_item t019 on t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
            set Is_Given = 1 ,
            Given_Date = @Current_Datetime 
            where t018.IssueStocks_Id = Var_IssueStocks_Id and t019.MCC_Id = Var_MCC_Id and  t019.Material_Id = Var_Material_Id
            and t019.Order_Id =  Var_OrderId and IssueStockToProfile_Type = 'Agent' and IssueStockToProfile_Id = Var_Profile_Id;
                
			call USP_UpdateMCC_Stock('UpdateMCCStock', Var_Org_Id, Var_MCC_Id, Var_Material_Id, @Current_Datetime, '');

            end if;
            
         
         elseif (Var_Method_Name = 'GetStockDistribution') then 
			
          
		select t019.IssueStockToProfile_Id , '123' as IssueStockToProfile_Code , t019.IssueStocks_Id ,
		ifnull(mu04.Farmer_Name , '') as IssueStockToProfile_Name , t019.Material_Id , t019.IssueStockToProfile_Type , ifnull(m010.Material_Name ,  m017.Product_Name ) as Material_Name, 
		t023.Order_Id , t023i.Quantity  , t019.Quantity as ApprovedQty
		from t018_issuestocks_header t018 
		inner join t019_issuestocks_item t019 on  t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
		left join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id =  t019.Material_Id
		left join m017_product m017 on m017.Org_Id = t019.Org_Id and t019.Material_Id = m017.Product_Id
		left join t023_order_header t023 on t023.Org_Id = t019.Org_Id and t023.Order_Id =  t019.Order_Id and t023.Order_For_User_Id = t019.IssueStockToProfile_Id 
		left join t023_order_item t023i on t023i.Org_Id = t019.Org_Id and t023i.Order_Id =  t023.Order_Id and t023i.Product_Id = t019.Material_Id
		left join mu04_farmer mu04 on mu04.Org_Id = t019.Org_Id and mu04.Farmer_Id = t019.IssueStockToProfile_Id 
		where StockIssue_Type <> 'Cans' and t019.MCC_Id = Var_MCC_Id and t019.Org_Id = Var_Org_Id and IssueStockToProfile_Type = 'Farmer' and Is_Given <> 1 and 
        Is_MCCAccepted = 1 and 
		(mu04.Farmer_Id LIKE CONCAT('%', Var_Farmer_Id, '%') or mu04.Farmer_Name LIKE CONCAT('%', Var_Farmer_Id, '%'));
				
            
	elseif (Var_Method_Name = 'GiveIssueStock')then 
            
            update t019_issuestocks_item 
            set Is_Given = 1 ,
            Given_Date = @Current_Datetime
            where Org_Id = Var_Org_Id and  
			IssueStocks_Id = Var_IssueStocks_Id and 
			Order_Id = Var_OrderId and 
			IssueStockToProfile_Id = Var_Farmer_Id and 
			Material_Id = Var_Material_Id and 
			MCC_Id = Var_MCC_Id;
            
			call USP_UpdateMCC_Stock('UpdateMCCStock', Var_Org_Id, Var_MCC_Id, Var_Material_Id, @Current_Datetime , '');

            
			SELECT 1 AS Result_Id, 
			'Given To Farmer' AS Result_Description, 
			'' AS Result_Extra_Key;
            
            
elseif (Var_Method_Name = 'GetCurrentStockHistory')then 
  
select A.Material_Id , A.IssueStock_Name , f006a.Balance  as Quantity From f006_mccstocks f006a inner join 
(select f006.Material_Id , f006.Balance as Quantity 
,  ifnull(m010.Material_Name , Product_Name )  as IssueStock_Name  
, max(date(STR_TO_DATE(date, '%Y-%m-%d'))) as Max_Date
from f006_mccstocks f006 
left join m010_material m010 
on m010.Org_Id = f006.Org_Id and m010.Material_Id = f006.Material_Id  
left join m017_product m017 on m017.Org_Id = f006.Org_Id and m017.Product_Id = f006.Material_Id 
where f006.MCC_Id = Var_MCC_Id and f006.Org_Id = Var_Org_Id
group by f006.Material_Id , IssueStock_Name  
having f006.Balance > 0 
order by STR_TO_DATE(date(f006.date), '%Y-%m-%d') desc ) A on f006a.Material_Id = A.Material_Id and A.Max_Date = date(f006a.Date) and f006a.MCC_Id = Var_MCC_Id;
		
        
 elseif (Var_Method_Name = 'IssueStockHistory')then 
 
	-- InwardStockHistory
	
		select t019.IssueStockToProfile_Id , if(Agent_Name is null , Farmer_Name , Agent_Name ) as User_Name, Quantity ,
		ifnull(if(Agent_Name is null , mu04.Profile_Photo , mu05.Profile_Photo ) , '')as Profile_Photo ,
        DATE_FORMAT(Given_Date, '%d %b %Y') as Given_Date ,
		if(m010.Material_Id is null , m017.Product_Name , m010.Material_Name ) as Material_Name
		from t019_issuestocks_item t019 
		inner join t018_issuestocks_header t018 on t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
		left join mu04_farmer mu04 on mu04.Org_Id = t019.Org_Id and mu04.Farmer_Id = t019.IssueStockToProfile_Id
		left join mu05_agent mu05 on mu05.Org_Id = mu05.Org_Id and t019.IssueStockToProfile_Id = mu05.Agent_Id
		left join m010_material m010 
		on m010.Org_Id = t019.Org_Id and m010.Material_Id = t019.Material_Id  
		left join m017_product m017 on m017.Org_Id = t019.Org_Id and m017.Product_Id = t019.Material_Id 
		where Is_Given = 1 and t019.MCC_Id = Var_MCC_Id and t019.Org_Id = Var_Org_Id and  month(Var_Date) = month(Given_Date) and 
		year(Var_Date) = year(Given_Date) and  t018.StockIssue_Type  <> 'Cans' ;
        
	elseif(Var_Method_Name = 'InwardStockHistory') then
    	
	select CAST(sum(Quantity) AS SIGNED) as Quantity , DATE_FORMAT(Given_Date, '%d %M %Y') as GivenDate ,
    if(m010.Material_Id is null , m017.Product_Name , m010.Material_Name ) as stockname
	from t019_issuestocks_item t019 
    inner join t018_issuestocks_header t018 on t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
	left join mu04_farmer mu04 on mu04.Org_Id = t019.Org_Id and mu04.Farmer_Id = t019.IssueStockToProfile_Id
	left join mu05_agent mu05 on mu05.Org_Id = mu05.Org_Id and t019.IssueStockToProfile_Id = mu05.Agent_Id
	left join m010_material m010 on m010.Org_Id = t019.Org_Id and m010.Material_Id = t019.Material_Id  
	left join m017_product m017 on m017.Org_Id = t019.Org_Id and m017.Product_Id = t019.Material_Id 
	where Is_Given = 1 and t019.MCC_Id = 'M005231000001' and t019.Org_Id = 'c001' and  month(Var_Date) = month(Given_Date) and 
	year(Var_Date) = year(Given_Date) 
	group by stockname , GivenDate ;
        

end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
