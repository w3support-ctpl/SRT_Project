-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_CrateOpening_Closing` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_CrateOpening_Closing`()
BEGIN

SET SQL_SAFE_UPDATES = 0;
set sql_mode = '' ;

 SET @updatedate = DATE('2024-02-01 16:40:55');

			drop temporary table if exists temp_tbl;
			create Temporary table temp_tbl(
			`Org_Id` varchar(45) NOT NULL,
			`Dealer_Id` varchar(20) NOT NULL,
			`Material_Id` varchar(45) DEFAULT NULL,
			`date` DATE DEFAULT NULL,
			`Amount` int DEFAULT NULL,
			`id` int
			); 
				
		            
			set @id = 0;

			insert temp_tbl(Org_Id, Dealer_Id ,Material_Id , date  , id , Amount)
			(select Org_Id, Dealer_Id, Material_Id, date(date), @id := (@id+1) , Opening_Quantity
			from f011_dealer_stock where date(date) >= date( @updatedate) 
            ) order by date(date) asc;
            
				
			set @RowCount = (select count(*) from temp_tbl );
            
            select @RowCount;
            
			set @var_CursorTestID = 1;
            
			While @var_CursorTestID <= @RowCount Do
				
			select Org_Id , Dealer_Id ,Material_Id , date into @Org_Id , @Dealer_Id , @Material_Id , @Ndate from temp_tbl where id = @var_CursorTestID;

			set @Openingamt = (select Closing_Quantity from f011_dealer_stock 
			where Org_Id = @Org_Id and Dealer_Id = @Dealer_Id and 
			Material_Id = @Material_Id  and date(date) < date(@Ndate) order by date desc limit 1 ) ;

				update temp_tbl 
				set Amount = ifnull(@Openingamt , 0)
				where id = @var_CursorTestID ;
                
                update f011_dealer_stock f011
				inner join temp_tbl temp on f011.Org_Id = temp.Org_Id and 
				f011.Dealer_Id = temp.Dealer_Id and f011.Material_Id = temp.Material_Id and (f011.date) = (temp.date)
				set f011.Opening_Quantity = ifnull(temp.Amount ,0 )
				where f011.org_id =  @Org_Id and f011.Dealer_Id =  @Dealer_Id and f011.Material_Id =  @Material_Id 
                and f011.Date =  @Ndate ;
                
                update f011_dealer_stock 
				set Closing_Quantity = (ifnull(Opening_Quantity , 0) + ifnull(Good_Credit ,0)+ ifnull(Broken_Credit,0) + 
				ifnull(ThirdParty_Credit, 0) - ifnull(Good_Debit,0) - ifnull(Broken_Debit,0) - ifnull(ThirdParty_Debit,0))
				where org_id =  @Org_Id and Dealer_Id =  @Dealer_Id and Material_Id =  @Material_Id 
                and Date =  @Ndate ;
                
                
				Set @var_CursorTestID = @var_CursorTestID + 1;
				    
				select 1;
					
				END WHILE;
				
                
	
		insert into temp(text) value(concat('Crate DONE' ));


END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
