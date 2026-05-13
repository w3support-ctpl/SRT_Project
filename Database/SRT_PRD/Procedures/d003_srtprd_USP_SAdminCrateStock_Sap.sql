-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminCrateStock_Sap` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminCrateStock_Sap`(
var_method varchar(100),
var_dealer_code varchar(20),
var_start_date varchar(50),
var_end_date varchar(50)
)
BEGIN

set sql_mode = '';

        set @openingBan = (select Closing_Quantity from f011_dealer_stock where 
        date(date) < date(var_start_date) and Material_Id = 'M010241000023'
        order by date desc limit 1
        );
        
		set @openingBan1 = (select Closing_Quantity from f011_dealer_stock where 
        date(date) < date(var_start_date) and Material_Id = 'M010241000022' 
        order by date desc limit 1
        );
        

	if(var_method = 'CrateStock') then 
    
    
		/*
		select m010.Material_Name as Material_Name , m010.Material_Code as Material_Code , 
        CAST(f011.Closing_Quantity AS SIGNED) as Quantity ,
        if(m010.Material_Code = '860024' , @openingBan1  , @openingBan) as Opening_Stock
        from f011_dealer_stock f011
		inner join mu08_dealer mu08 on f011.Org_Id = mu08.Org_Id and f011.Dealer_Id = mu08.Dealer_Id
		inner join m010_material m010 on m010.Material_Id = f011.Material_Id and m010.Org_Id = f011.Org_Id
		where mu08.Dealer_Code = var_dealer_code and date(f011.date) = date(var_start_date);
        
        */
        
		select f011.DATE AS Date , m010.MATERIAL_CODE as Material ,  f011.Opening_Quantity as Opening_Quantity from f011_dealer_stock f011
		inner join mu08_dealer mu08 on f011.Org_Id = mu08.Org_Id and f011.Dealer_Id = mu08.Dealer_Id
		inner join m010_material m010 on m010.Material_Id = f011.Material_Id and m010.Org_Id = f011.Org_Id
        where mu08.Dealer_Code = var_dealer_code  and date(f011.date) = date(var_start_date) order by f011.date desc ;
        
	
    elseif (var_method = 'CratesSend') then 
    
    

		
		/*
        select m010.Material_Name as Material_Name , m010.Material_Code as Material_Code ,  
		CAST(SUM(f011.Good_Credit + f011.Broken_Credit + f011.ThirdParty_Credit) AS SIGNED)  
        as Quantity ,
		if(m010.Material_Code = '860024' , @openingBan1  , @openingBan) as Opening_Stock
        from f011_dealer_stock f011
		inner join mu08_dealer mu08 on f011.Org_Id = mu08.Org_Id and f011.Dealer_Id = mu08.Dealer_Id
		inner join m010_material m010 on m010.Material_Id = f011.Material_Id and m010.Org_Id = f011.Org_Id
		where mu08.Dealer_Code = var_dealer_code and 
        date(date) >= date(var_start_date) AND date(date) <= date(var_end_date) 
        GROUP BY m010.Material_Name ,  m010.Material_Code ;
		*/
        
		select  m010.Material_Name as Material_Name , m010.Material_Code as Material_Code ,  
		CAST(SUM(t039.Quantity) AS SIGNED)  
        as Quantity  from t039_dispatch_crate t039
       	inner join mu08_dealer mu08 on t039.Org_Id = mu08.Org_Id and TRIM(LEADING '0' FROM t039.Dealer_Code ) = mu08.Dealer_Code
		inner join m010_material m010 on m010.Material_Code = t039.Material_Code and m010.Org_Id = t039.Org_Id
        where mu08.Dealer_Code = var_dealer_code and 
        date(Dispatch_Date) >= date(var_start_date) AND date(Dispatch_Date) <= date(var_end_date) 
        GROUP BY m010.Material_Name ,  m010.Material_Code;
        
		
        
	elseif (var_method = 'CratesReceived') then 
    
		/*
		
        select m010.Material_Name as Material_Name , m010.Material_Code as Material_Code ,  
        CAST( SUM(f011.Good_Debit) AS SIGNED)
        as Quantity , 
        if(m010.Material_Code = '860024' , @openingBan1  , @openingBan) as Opening_Stock        
        from f011_dealer_stock f011
		inner join mu08_dealer mu08 on f011.Org_Id = mu08.Org_Id and f011.Dealer_Id = mu08.Dealer_Id
		inner join m010_material m010 on m010.Material_Id = f011.Material_Id and m010.Org_Id = f011.Org_Id
		where mu08.Dealer_Code = var_dealer_code and 
        date(date) >= date(var_start_date) AND date(date) <= date(var_end_date) 
        GROUP BY m010.Material_Name ,  m010.Material_Code ;
        */
        
		select  m010.Material_Name as Material_Name , m010.Material_Code as Material_Code ,  
		CAST(SUM(Good_Quantity + Broken_Quantity + ThirdParty_Quantity) AS SIGNED)  
        as Quantity  from t038_receivedcrate_header t038
        inner join t038_receivedcrate_item t038i on t038.ReceivedCrate_Id = t038i.ReceivedCrate_Id
       	inner join mu08_dealer mu08 on t038.Org_Id = mu08.Org_Id and t038.Dealer_Id = mu08.Dealer_Id
		inner join m010_material m010 on m010.Material_Id = t038i.Material_Id and m010.Org_Id = t038.Org_Id
        where mu08.Dealer_Code = var_dealer_code and 
        date(t038.Created_On) >= date(var_start_date) AND date(t038.Created_On) <= date(var_end_date) 
        GROUP BY m010.Material_Name ,  m010.Material_Code;

    end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
