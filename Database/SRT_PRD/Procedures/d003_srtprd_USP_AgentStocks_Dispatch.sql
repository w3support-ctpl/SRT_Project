-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentStocks_Dispatch` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentStocks_Dispatch`(
Var_Method_Name varchar(40),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Profile_Id varchar(20),
var_Material_Id varchar(20),
Var_Dispatch_Qty varchar(20),
Var_XMLData longtext
)
BEGIN
set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
SET sql_mode = '';

	if(Var_Method_Name = 'GetStock') then
    
		/*
        select t019.Material_Id , CAST(sum(Quantity)  AS SIGNED)  as Quantity , ifnull(m010.Material_Name , Product_Name )  as IssueStock_Name ,
		IF(m010.Material_Name IS NULL , 'Product' , 'Material') as Stocktype
		from t019_issuestocks_item t019 
		inner join t018_issuestocks_header t018 on t018.Org_Id = t019.Org_Id and t018.IssueStocks_Id = t019.IssueStocks_Id
		left join m010_material m010 
		on m010.Org_Id = t019.Org_Id and m010.Material_Id = t019.Material_Id  
		left join m017_product m017 on m017.Org_Id = t019.Org_Id and m017.Product_Id = t019.Material_Id 
		where t019.MCC_Id = Var_MCC_Id  and t019.Org_Id = Var_Org_Id and Is_MCCAccepted = 1 and t019.Is_Given = 0
		group by t019.Material_Id  ;
		*/
		
        -- new changes 
        /*
        select f006.Material_Id , ifnull(m010.Material_Name , Product_Name ) as IssueStock_Name , CAST(Balance  AS SIGNED) as Quantity, 
		IF(m010.Material_Name IS NULL , 'Product' , 'Material') as Stocktype ,  f006.Org_Id, 
        if(f006.Material_Id  in  (select Material_Id from t032_dispatchstock_item A inner join t032_dispatchstock_header B on A.Org_Id = B.Org_Id and 
        A.Dispatchstock_Id = B.Dispatchstock_Id where Is_Dairy_Accepted = 0 and B.MCC_Id = Var_MCC_Id and A.Org_Id = Var_Org_Id ) , 0 , 1) as Availabletodispatch,
        ifnull((select Dispatched_Quantity from t032_dispatchstock_item A inner join t032_dispatchstock_header B on A.Org_Id = B.Org_Id and  
        A.Dispatchstock_Id = B.Dispatchstock_Id where Is_Dairy_Accepted = 0 and B.MCC_Id = Var_MCC_Id and A.Org_Id = Var_Org_Id  and A.Material_Id = f006.Material_Id limit 1 ), 0) as Dispatched_Quantity
        from f006_mccstocks f006 left join m010_material m010 
		on m010.Org_Id = f006.Org_Id and m010.Material_Id = f006.Material_Id  
        left join m017_product m017 on m017.Org_Id = f006.Org_Id and m017.Product_Id = f006.Material_Id 
        left join t032_dispatchstock_item t032 on t032.Org_Id = f006.Org_Id and t032.Material_Id = f006.Material_Id
		left join t032_dispatchstock_header t032h on t032.Org_Id = t032h.Org_Id and t032.Dispatchstock_Id = t032h.Dispatchstock_Id 
        where f006.MCC_Id= Var_MCC_Id and f006.Org_Id= Var_Org_Id
        group by f006.Material_Id 
        having Quantity > 0 
		order by Material_Id; 
        
        */
        set @Balance = ( select ifnull(Balance,0) from f006_mccstocks 
					where Material_Id = 'M010241000020' 
					and  MCC_Id = Var_MCC_Id
					and Date < @Current_Datetime 
					order by Date desc limit 1);
                    
		select f006.Material_Id , ifnull(m010.Material_Name , '' ) as IssueStock_Name , @Balance as Quantity, 
		IF(m010.Material_Name IS NULL , 'Product' , 'Material') as Stocktype ,  f006.Org_Id, 
        if(f006.Material_Id  in  (select Material_Id from t032_dispatchstock_item A inner join t032_dispatchstock_header B on A.Org_Id = B.Org_Id and 
        A.Dispatchstock_Id = B.Dispatchstock_Id where Is_Dairy_Accepted = 0 and B.MCC_Id = Var_MCC_Id and A.Org_Id = Var_Org_Id ) , 0 , 1) as Availabletodispatch,
        ifnull((select Dispatched_Quantity from t032_dispatchstock_item A inner join t032_dispatchstock_header B on A.Org_Id = B.Org_Id and  
        A.Dispatchstock_Id = B.Dispatchstock_Id where Is_Dairy_Accepted = 0 and B.MCC_Id = Var_MCC_Id and A.Org_Id = Var_Org_Id  and A.Material_Id = f006.Material_Id limit 1 ), 0) as Dispatched_Quantity
        from f006_mccstocks f006 inner join m010_material m010 
		on m010.Org_Id = f006.Org_Id and m010.Material_Id = f006.Material_Id 
        -- left join m017_product m017 on m017.Org_Id = f006.Org_Id and m017.Product_Id = f006.Material_Id 
        left join t032_dispatchstock_item t032 on t032.Org_Id = f006.Org_Id and t032.Material_Id = f006.Material_Id
		left join t032_dispatchstock_header t032h on t032.Org_Id = t032h.Org_Id and t032.Dispatchstock_Id = t032h.Dispatchstock_Id 
        where f006.MCC_Id= Var_MCC_Id and f006.Org_Id= Var_Org_Id
        group by f006.Material_Id 
        having Quantity > 0 
		order by Material_Id; 
        
        

    elseif(Var_Method_Name = 'DispatchStock') then
    
		set @Year_Id = (select right(left(curdate(),4),(2)));
		Call USP_Number_Range ('t032_dispatchstock_header', @Year_Id, 'T032', '', @New_Dispatchstock_Id );
        
		insert into t032_dispatchstock_header(Org_Id , Dispatchstock_Id , MCC_Id , Agent_Id , Dispatched_On , Created_On , 
        Created_By ) value (Var_Org_Id , @New_Dispatchstock_Id , Var_MCC_Id, Var_Profile_Id , @Current_Datetime , @Current_Datetime , 
        Var_Profile_Id );
       
       SET @row_counts := extractValue(var_XMLData,'count(//D/R)');
			Set @k := 0;
			WHILE @k < @row_counts DO        
				SET @k := @k + 1;
				SET @xpath := concat('//D/R[', @k, ']');
				INSERT INTO t032_dispatchstock_item (Org_Id, Dispatchstock_Id ,Material_Id,Stock_Type,Dispatched_Quantity) VALUES (
					Var_Org_Id,
                    @New_Dispatchstock_Id,
					extractValue(var_XMLData, concat(@xpath,'/MI')),
                    extractValue(var_XMLData, concat(@xpath,'/ST')),
                    extractValue(var_XMLData, concat(@xpath,'/DQ'))
				);    

		END WHILE;
        
        	SELECT 1 AS Result_Id, 
			'Entry Saved' AS Result_Description, 
			'' AS Result_Extra_Key;
            
            
            
	elseif(Var_Method_Name = 'GetPendingStock') then
            
        select t032.Material_Id , ifnull(m010.Material_Name , Product_Name ) as IssueStock_Name , 
        t032.Dispatchstock_Id , t032.Stock_Type , t032.Dispatched_Quantity , Dispatched_On 
        from  t032_dispatchstock_item t032 	inner join t032_dispatchstock_header t032h 
        on t032.Org_Id = t032h.Org_Id and t032.Dispatchstock_Id = t032h.Dispatchstock_Id 
        left join m017_product m017 on m017.Org_Id = t032.Org_Id and m017.Product_Id = t032.Material_Id 
        left join m010_material m010 on m010.Org_Id = t032.Org_Id and m010.Material_Id = t032.Material_Id
		where t032.MCC_Id= Var_MCC_Id and t032.Org_Id= Var_Org_Id;
	
  
    
	elseif(Var_Method_Name = 'UpdatePendingStock') then
    

    set @Dispatchstock_Id = (SELECT t032h.Dispatchstock_Id FROM t032_dispatchstock_item t032
    inner join t032_dispatchstock_header t032h 
        on t032.Org_Id = t032h.Org_Id and t032.Dispatchstock_Id = t032h.Dispatchstock_Id 
    WHERE
    t032h.MCC_Id= Var_MCC_Id and t032h.Org_Id= Var_Org_Id and t032.Material_Id = var_Material_Id AND Is_Dairy_Accepted = 0 order by Dispatched_On
    desc limit 1);

     update t032_dispatchstock_item t032 
     set t032.Dispatched_Quantity = Var_Dispatch_Qty
     where  t032.Org_Id= Var_Org_Id and t032.Material_Id = var_Material_Id and 
     t032.Dispatchstock_Id = @Dispatchstock_Id ;
    
    
	SELECT 1 AS Result_Id, 'Saved' AS Result_Description,  '' AS Result_Extra_Key;
    
    
    end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
