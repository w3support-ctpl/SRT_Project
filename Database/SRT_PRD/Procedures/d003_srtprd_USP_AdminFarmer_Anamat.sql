-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminFarmer_Anamat` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminFarmer_Anamat`(
var_method_name varchar(30),
var_org_id varchar(30),
var_farmer_id varchar(30),
var_type varchar(20),
var_amount LONGTEXT,
var_date datetime,
out output LONGTEXT
)
BEGIN

	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    
    
	if(var_method_name = 'Create') then 
	
		set @Year_Id = (select right(left(curdate(),4),(2)));
		set @New_Id= '' ;
		CALL USP_Number_Range ('f014_farmer_anamat', @Year_Id, 'F014', '', @New_Id );
		
		if exists (select 1 from f014_farmer_anamat where Farmer_Id = var_farmer_id and Org_Id = var_org_id) then 
		
			if(var_type= 'Dr') then
		  
				if exists (select 1 from f014_farmer_anamat where Farmer_Id = var_farmer_id and Org_Id = var_org_id and date(Date) = date(var_date) 
				and Type = var_type) then
				
					update f014_farmer_anamat
					set Balance = (Balance - var_amount),
					Amount = Amount + var_amount
					where Farmer_Id = var_farmer_id and Org_Id = var_org_id and date(Date) = date(var_date)
					 and Type = var_type;
				
				else
				
					insert into f014_farmer_anamat (Org_Id, Entry_Id, Farmer_Id, Type, Amount, Balance, Date)  
					(select var_org_id , @New_Id , var_farmer_id , var_type ,var_amount , (Balance - var_amount) ,
					var_date from f014_farmer_anamat where Farmer_Id = var_farmer_id and Org_Id = var_org_id and Date <= var_date order by Date desc limit 1);

				end if;

			elseif (var_type= 'Cr') then 
				 
				if exists (select 1 from f014_farmer_anamat where Farmer_Id = var_farmer_id and Org_Id = var_org_id and date(Date) = date(var_date) 
				and Type = var_type) then
		   
				
					update f014_farmer_anamat
					set Balance = (Balance + var_amount),
					Amount = Amount + var_amount
					where Farmer_Id = var_farmer_id and Org_Id = var_org_id and date(Date) = date(var_date)
					and Type = var_type;
			
				else
			 
					insert into f014_farmer_anamat (Org_Id, Entry_Id, Farmer_Id, Type, Amount, Balance, Date)  
					(select var_org_id , @New_Id , var_farmer_id , var_type ,var_amount , (Balance + var_amount) ,
					var_date from f014_farmer_anamat where Farmer_Id = var_farmer_id and Org_Id = var_org_id and Date <= var_date order by Date desc limit 1);

				end if;
			
			end if;

		else
					
			insert into f014_farmer_anamat (Org_Id, Entry_Id, Farmer_Id, Type, Amount, Balance, Date)  value
			(var_org_id , @New_Id , var_farmer_id , var_type ,var_amount , var_amount ,var_date);

		end if;


		drop temporary table if exists temp_tbl;
		create Temporary table temp_tbl(
		  `Org_Id` varchar(45) NOT NULL,
		  `Entry_Id` varchar(20) NOT NULL,
		  `Farmer_Id` varchar(45) DEFAULT NULL,
		  `Type` varchar(45) DEFAULT NULL,
		  `Amount` LONGTEXT DEFAULT NULL,
		  `Balance` LONGTEXT DEFAULT NULL,
		  `Date` datetime DEFAULT NULL,
		  `id` int
		);


		set @id = 0;
		insert into temp_tbl (Org_Id, Entry_Id, Farmer_Id, Type, Amount, Balance, Date , id ) 
		(select Org_Id, Entry_Id, Farmer_Id, Type, Amount, Balance, Date , @id :=(@id+1)
		from f014_farmer_anamat where Farmer_Id = var_farmer_id and Org_Id = var_org_id and date(Date) >= date(var_date) order by Date asc);
		
		
		set @RowCount = (select COUNT(*) from temp_tbl);
		
		set @var_CursorTestID = 1;

		While @var_CursorTestID <= @RowCount Do
			
			set @Amount = (select Balance from temp_tbl where id = @var_CursorTestID);

			UPDATE temp_tbl 
			SET 
			Balance = IF(Type = 'cr',
			Amount + @Amount,
			IF(Type = 'dr', @Amount - Amount, 0))
			WHERE
			id = @var_CursorTestID + 1;

			Set @var_CursorTestID = @var_CursorTestID + 1;

		END WHILE;


		UPDATE f014_farmer_anamat a
		INNER JOIN
		temp_tbl b ON a.Org_Id = b.Org_Id
		AND a.Entry_Id = b.Entry_Id 
		SET 
		a.Balance = b.Balance;
			
		set output = 0;
			
	elseif (var_method_name = 'GetOpeningBal') then 
			
			set @OpeningBalance = 0;
			set @OpeningBalance = (select Balance from f014_farmer_anamat where Farmer_Id = var_farmer_id and Org_Id = var_org_id and date(Date) < date(var_date) order by Date desc limit 1);

			set output = ifnull(@OpeningBalance , 0);
				
	end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
