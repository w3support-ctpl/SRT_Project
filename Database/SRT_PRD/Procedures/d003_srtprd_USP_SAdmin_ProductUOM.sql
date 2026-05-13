-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdmin_ProductUOM` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdmin_ProductUOM`(
var_Org_Id VARCHAR (40),
Var_Method_Name varchar(50),
var_xml_data longtext

)
BEGIN

	if (Var_Method_Name = 'SaveProductUOM') then 
    
set @Year_Id = (select right(left(curdate(),4),(2)));
		set @k = 0;
		SET @row_count := extractValue(var_XML_Data,'count(//product/ProductData)');
			WHILE @k < @row_count DO
				SET @k := @k + 1;
				SET @xpath := concat('//product/ProductData[', @k, ']');
                
                if exists(select 1 from m027_product_uom where Org_Id = var_Org_Id and Product_Code =
				extractValue(var_XML_Data, concat(@xpath,'/ProductCode')) AND
                UOM = extractValue(var_XML_Data, concat(@xpath,'/Productuom'))
 ) then 
		
              
              select 1;
                    
			else
		

                insert into m027_product_uom (
                Org_Id, Product_Code, UOM 
                )  value (
                var_Org_Id, extractValue(var_XML_Data, concat(@xpath,'/ProductCode')), 
                extractValue(var_XML_Data, concat(@xpath,'/Productuom'))
                
                ) ;
               
			end if;
		
		
        
        
        END WHILE;

    
    else 
    
    
			drop temporary table if exists temp_tblupdate;
			create Temporary table temp_tblupdate(
			`Product_Code` varchar(20) NOT NULL,
            `id` int
			); 
            
            set @id= 0;
            
            insert into temp_tblupdate(Product_Code , id) 
            select Product_Code , (@id := @id+1) 
            from m017_product where is_active = 1;
            
            
            
			drop temporary table if exists temp_tbluout;
			create Temporary table temp_tbluout(
			`Productcode` longtext
			); 
            
    
	SET @row_number = 0;

	set @COUNT = (select COUNT(*) FROM temp_tblupdate );
    

    while  @row_number <= @COUNT DO
    
    insert into temp_tbluout (Productcode)
    select replace( group_CONCAT('Product eq ', '''', Product_Code , '''') , ',' , ' or ' ) as  Productcode 
    from temp_tblupdate  where id >=  @row_number and id <= @row_number + 25;
    
    set @row_number = @row_number + 25;
    
    END WHILE ;

		
        select Productcode as Productcode from temp_tbluout;


    /*
   select replace( group_CONCAT('Product eq ', '''', Product_Code , '''') , ',' , ' or ' ) as  Productcode 
    from m017_product 
    where Product_Code in ( select Product_Code from m017_product where is_active = 1 );
    
    -- select CONCAT('Product eq ', '''', 700008 , '''') AS Productcode ;

	*/

	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
