-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDealerStock_Manage` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDealerStock_Manage`(
)
proc_Exit: BEGIN
        
	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    set sql_mode = '';


			insert into f011_dealer_stock( Org_Id, Dealer_Id, Material_Id, Good_Debit, Broken_Debit, ThirdParty_Debit, Date )

			SELECT distinct t038h.Org_Id  , t038h.Dealer_Id , t038i.Material_Id , sum(Good_Quantity ) , sum(Broken_Quantity),  sum(ThirdParty_Quantity)  , 
			date(t038h.Created_On) as Created_On  from t038_receivedcrate_header t038h
			inner join t038_receivedcrate_item t038i on t038h.Org_Id = t038i.Org_Id and  t038h.ReceivedCrate_Id = t038i.ReceivedCrate_Id
            left join f011_dealer_stock f011 on f011.Org_Id = t038h.Org_Id and  f011.Dealer_Id = t038h.Dealer_Id and f011.Material_Id = t038i.Material_Id and 
			date(f011.Date) = date(t038h.Created_On) where f011.Date is null and t038h.Dealer_Id is not null
			and date(t038h.Created_On) <= date(now())
            and t038h.Is_Approved = 1
            group by t038h.Org_Id  , t038h.Dealer_Id , t038i.Material_Id ,  date(t038h.Created_On) ;

			insert into f011_dealer_stock( Org_Id, Dealer_Id, Material_Id, Opening_Quantity, Good_Credit, Closing_Quantity, Date )
			select t039.Org_Id, mu08.Dealer_Id , m010.Material_Id , 0,  
			sum(FORMAT(CAST(t039.Quantity AS DECIMAL), 0))  , 0 , CAST(date(t039.Dispatch_Date) as datetime)
            from t039_dispatch_crate t039 
			inner join m010_material m010 on t039.Org_Id = m010.Org_Id
			and t039.Material_Code = m010.Material_Code
			inner join mu08_dealer mu08 on mu08.Dealer_Code = TRIM(LEADING '0' FROM t039.Dealer_Code ) and t039.Org_Id = mu08.Org_Id
            left join f011_dealer_stock f011 on f011.Org_Id = t039.Org_Id and 
			f011.Dealer_Id = mu08.Dealer_Id and f011.Material_Id = m010.Material_Id and 
            date(f011.Date) = date(t039.Dispatch_Date) 
			where mu08.Dealer_Id is not null and f011.Dealer_Id is null and MaterialType_Id in ( 'C042231000005' , 'C042231000001'  )
			and date(t039.Created_On) <= date(now())
            group by t039.Org_Id, mu08.Dealer_Id , m010.Material_Id , CAST(date(t039.Dispatch_Date) as datetime)
            order by t039.Created_On;
       
          
			drop temporary table if exists temp_tblureceivedcrate;
			create Temporary table temp_tblureceivedcrate(
			`Org_Id` varchar(45) NOT NULL,
			`Dealer_Id` varchar(20) NOT NULL,
			`Material_Id` varchar(45) DEFAULT NULL,
			`Good_Quantity` varchar(50) DEFAULT NULL,
            `Broken_Quantity` varchar(20) DEFAULT NULL,
            `ThirdParty_Quantity` varchar(20) DEFAULT NULL,
			`E_Date` varchar(20) DEFAULT NULL,
            `id` int 
			); 
            
            
            set @lastdate = (select Created_On from  t038_receivedcrate_header where date(Date) = date(now()) 
            order by Created_On asc limit 1);
            
			set @lastdate  = date('2025-12-01 00:00:00');

			set @lastdate = date(ifnull(@lastdate , now())) ;
                
            set @id = 0;
            
            insert into temp_tblureceivedcrate( Org_Id, Dealer_Id , Material_Id , Good_Quantity , Broken_Quantity   ,ThirdParty_Quantity ,
            E_Date , id ) 
            
			select  t038h.Org_Id , t038h.Dealer_Id , t038i.Material_Id , sum(t038i.Good_Quantity ) , sum( t038i.Broken_Quantity ), 
            sum(t038i.ThirdParty_Quantity ), date(t038h.Created_On) , @id :=(@id+1) from 
            t038_receivedcrate_header t038h
			inner join t038_receivedcrate_item t038i on t038h.Org_Id = t038i.Org_Id and 
			t038h.ReceivedCrate_Id = t038i.ReceivedCrate_Id 
            where t038h.Is_Approved = 1 and date(Approved_On) >= date(@lastdate ) 
			group by t038h.Org_Id , t038h.Dealer_Id , t038i.Material_Id, date(t038h.Created_On);

            
			SET @row_number = 0; 

			set @COUNT = (select COUNT(*) FROM temp_tblureceivedcrate );

			while  @row_number <= @COUNT DO
            
            update temp_tblureceivedcrate tempa
            inner join f011_dealer_stock f011 on f011.Org_Id = tempa.Org_Id and 
			f011.Dealer_Id = tempa.Dealer_Id and f011.Material_Id = tempa.Material_Id and 
			date(f011.Date) = date(tempa.E_Date)
			set f011.Good_Debit = tempa.Good_Quantity,
			f011.Broken_Debit = tempa.Broken_Quantity,
			f011.ThirdParty_Debit = tempa.ThirdParty_Quantity
            where tempa.id >=  @row_number and tempa.id <= @row_number + 20;

			set @row_number = @row_number + 20;
            
            
			END WHILE ;
            
			

			drop temporary table if exists temp_tblupdate;
			create Temporary table temp_tblupdate(
			`Org_Id` varchar(45) NOT NULL,
			`Dealer_Id` varchar(20) NOT NULL,
			`Material_Id` varchar(45) DEFAULT NULL,
			`date` date DEFAULT NULL,
            `Quantity` int DEFAULT NULL,
             `id` int 
			); 
            

			SET @InLastDate = (select date(Dispatch_Date)  from t039_dispatch_crate 
            where date(Created_On) = date(now())  order by date(Dispatch_Date)  asc limit 1);
				
             SET @InLastDate  =  @lastdate ;
			
            set @ndatez = date(ifnull(@InLastDate , now()));
            
            while @ndatez <= date(now()) do
            
            truncate temp_tblupdate;
            
            set @id = 0;
            
			insert temp_tblupdate(Org_Id, Dealer_Id ,Material_Id , date , Quantity , id)
			
            select  t039.Org_Id , TRIM(LEADING '0' FROM t039.Dealer_Code ) , t039.Material_Code , date(t039.Dispatch_Date) ,
			sum( t039.Quantity) , (@id :=(@id+1))
            from t039_dispatch_crate t039   
            inner join m010_material m010 on t039.Org_Id = m010.Org_Id and t039.Material_Code = m010.Material_Code
            where date(Dispatch_Date) is not null and MaterialType_Id in ( 'C042231000005' , 'C042231000001'  ) 
            and date(Dispatch_Date) >= @ndatez and date(Dispatch_Date) <= DATE_ADD( @ndatez , INTERVAL 1 DAY) 
			group by t039.Org_Id , TRIM(LEADING '0' FROM t039.Dealer_Code ) , t039.Material_Code , date(t039.Dispatch_Date)
            order by t039.Created_On;
			
            update temp_tblupdate a
            inner join mu08_dealer mu08 on mu08.Dealer_Code = a.Dealer_Id
            set a.Dealer_Id = mu08.Dealer_Id;
            
            update temp_tblupdate a
            inner join m010_material m010 on a.Org_Id = m010.Org_Id
			and a.Material_Id = m010.Material_Code
            set a.Material_Id = m010.Material_Id;
            
            SET @row_number = 0;

			set @COUNT = (select COUNT(*) FROM temp_tblupdate );
            
			while  @row_number <= @COUNT DO
                        
			update temp_tblupdate a
            inner join f011_dealer_stock f011 on a.Org_Id = f011.Org_Id and a.Dealer_Id = f011.Dealer_Id
            and a.Material_Id = f011.Material_Id and (a.date) = (f011.date )
			set f011.Good_Credit = a.Quantity
            where a.id >=  @row_number and a.id <= @row_number + 10;

			set @row_number = @row_number + 10;
            

			END WHILE ;
            
            set @ndatez  = DATE_ADD( @ndatez , INTERVAL 1 DAY) ;
            
            END WHILE ;
            
			


			drop temporary table if exists temp_tbl;
			create Temporary table temp_tbl(
			`Org_Id` varchar(45) NOT NULL,
			`Dealer_Id` varchar(20) NOT NULL,
			`Material_Id` varchar(45) DEFAULT NULL,
			`date` DATE DEFAULT NULL,
			`Amount` int DEFAULT NULL,
			`id` int
			); 
				
			if (date(@ndatez) < date(@lastdate)) then
				set @updatedate = date(@ndatez);
                
			elseif(date(@ndatez) > date(@lastdate)) then 
                set @updatedate = date(@lastdate);
                
			elseif(date(@ndatez) = date(@lastdate)) then 
				set @updatedate = date(@lastdate);
            
            
            end if ;
            
			set @id = 0;
            
            set @updatedate  = date('2025-12-01 00:00:00');

			insert temp_tbl(Org_Id, Dealer_Id ,Material_Id , date  , id , Amount)
			(select Org_Id, Dealer_Id, Material_Id, date(date), @id := (@id+1) , Opening_Quantity
			from f011_dealer_stock where date(date) >= date( @updatedate) 
            ) order by date(date) asc;
            
				
			set @RowCount = (select count(*) from temp_tbl );
            
			set @var_CursorTestID = 1;
            
			While @var_CursorTestID <= @RowCount Do
				
			select Org_Id , Dealer_Id ,Material_Id , date into @Org_Id , @Dealer_Id , @Material_Id , @date from temp_tbl where id = @var_CursorTestID;

			set @Openingamt = (select Closing_Quantity from f011_dealer_stock 
			where Org_Id = @Org_Id and Dealer_Id = @Dealer_Id and 
			Material_Id = @Material_Id  and date(date) < date(@date) order by date desc limit 1 ) ;

				update temp_tbl 
				set Amount = ifnull(@Openingamt , 0)
				where id = @var_CursorTestID ;

				update f011_dealer_stock f011
				inner join temp_tbl temp on f011.Org_Id = temp.Org_Id and 
				f011.Dealer_Id = temp.Dealer_Id and f011.Material_Id = temp.Material_Id and (f011.date) = (temp.date)
				set f011.Opening_Quantity = ifnull(temp.Amount ,0 )
				where f011.org_id =  @Org_Id and f011.Dealer_Id =  @Dealer_Id and f011.Material_Id =  @Material_Id 
                and f011.Date =  @date ;
                
                /*
                update f011_dealer_stock 
				set Closing_Quantity = (ifnull(Opening_Quantity , 0) - ifnull(Good_Credit ,0) - ifnull(Broken_Credit,0) - 
				ifnull(ThirdParty_Credit, 0) - ifnull(Good_Debit,0)
               -- - ifnull(Broken_Debit,0) - ifnull(ThirdParty_Debit,0)
                )
				where org_id =  @Org_Id and Dealer_Id =  @Dealer_Id and Material_Id =  @Material_Id 
                and Date =  @date ;
                */
                
                update f011_dealer_stock 
				set Closing_Quantity = ( ( ifnull(Opening_Quantity , 0) + abs(ifnull(Good_Credit ,0)) ) - ifnull(Broken_Credit,0) - 
				ifnull(ThirdParty_Credit, 0) - ifnull(Good_Debit,0)
               -- - ifnull(Broken_Debit,0) - ifnull(ThirdParty_Debit,0)
                )
				where org_id =  @Org_Id and Dealer_Id =  @Dealer_Id and Material_Id =  @Material_Id 
                and Date =  @date ;

				Set @var_CursorTestID = @var_CursorTestID + 1;
                
					
				END WHILE;
				


END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
