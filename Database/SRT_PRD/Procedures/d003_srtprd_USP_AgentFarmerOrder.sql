-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentFarmerOrder` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentFarmerOrder`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_Profile_Id varchar(20),
var_XMLData longtext,
Var_Farmer_Id varchar(20)
)
BEGIN
		set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
        
	If (Var_Method_Name = 'GetProduct') then
		
         select Product_Id , Product_Code , Product_Name , Product_Group,  IFNULL(Rate , '0') as Rate , 
        Image 
        from m017_product where Org_Id = Var_Org_Id and Is_Active = 1;
	
    elseif(Var_Method_Name = 'PlaceOrder') then
    
		set @Order_Id = '';
        set @Year_Id = (select right(left(curdate(),4),(2)));
        
	Call USP_Number_Range ('t023_order_header', @Year_Id, 'T023', '', @Order_Id );
        
    drop temporary table if exists temp_tbl;
	create Temporary table temp_tbl(
    Org_Id varchar(20) not null, 
    Order_Id varchar(20) not null, 
    Product_Id varchar(20) not null ,
    Product_Quantity varchar(10),
    Rate varchar(10),
    Total_Price varchar(10),
    primary key(Org_Id,Order_Id,Product_Id));
  
        	SET @row_counts := extractValue(var_XMLData,'count(//D/R)');
			Set @k := 0;
			WHILE @k < @row_counts DO        
				SET @k := @k + 1;
				SET @xpath := concat('//D/R[', @k, ']');
				INSERT INTO temp_tbl (Org_Id,Order_Id,Product_Id,Product_Quantity,Rate,Total_Price) VALUES (
					Var_Org_Id,
                    @Order_Id,
					extractValue(var_XMLData, concat(@xpath,'/PI')),
                    extractValue(var_XMLData, concat(@xpath,'/PQ')),
                    extractValue(var_XMLData, concat(@xpath,'/RT')),
                    extractValue(var_XMLData, concat(@xpath,'/TP'))
				);    
                
			END WHILE;
        
		set @Total_Items = (Select count(*) from temp_tbl where Org_Id = Var_Org_Id and Order_Id = @Order_Id) ;
        set @Total_Price = (Select sum(Total_Price) from temp_tbl where Org_Id = Var_Org_Id and Order_Id = @Order_Id) ;

  set @MCC_Id = (select MCC_Id from mu04_farmer where Org_Id = var_Org_Id and Farmer_Id = Var_Farmer_Id );


        insert into t023_order_header(Org_Id,Order_Id, Order_For, Order_For_User_Id, Order_By,Order_By_User_Id, Order_Date, Is_Approved ,
        Total_Item , Total_Price , Is_Active , Created_On , Created_By , MCC_Id , Order_Type
        ) values (Var_Org_Id , @Order_Id , 'Farmer',Var_Farmer_Id, 'Agent' , Var_Profile_Id , @Current_Datetime, 0 , @Total_Items, @Total_Price , 1 ,  @Current_Datetime , Var_Profile_Id , @MCC_Id , 'Product' ) ;
        
	
        insert into t023_order_item (Org_Id , Order_Id , Product_Id ,Quantity ,Rate , Total_Price ) 
        select Var_Org_Id ,  @Order_Id  ,  Product_Id , Product_Quantity, Rate, Total_Price from temp_tbl where 
        Org_Id = Var_Org_Id and Order_Id = @Order_Id ;
    
		drop table temp_tbl;
    
		select 1 as Result_Id, 'Order Placed' as Result_Description, @Order_Id as Result_Extra_Key;

    
		elseif (Var_Method_Name = 'GetOrderHistory')Then 
        
        
			select t023i.Order_Id , t023i.Product_Id , m017.Product_Name, t023i.Quantity , t023i.Rate , t023i.Total_Price ,
            Is_Approved ,  DATE_FORMAT(Order_Date, '%e %b %Y') as Order_Date from t023_order_item t023i 
            inner join t023_order_header t023 on t023i.Org_Id = t023.Org_Id and t023i.Order_Id = t023.Order_Id
            inner join m017_product m017 on m017.Org_Id = t023i.Org_Id and t023i.Product_Id = m017.Product_Id
            where Order_For_User_Id = Var_Profile_Id and Order_For_User_Id = Var_Profile_Id and t023.Is_Active = 1 
            order by Order_Date desc;

    
    end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
