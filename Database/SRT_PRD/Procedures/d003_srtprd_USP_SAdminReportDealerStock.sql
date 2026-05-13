-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminReportDealerStock` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminReportDealerStock`(
	var_Org_id VARCHAR(10),
	var_Method_Name VARCHAR(20),
	var_Report_Type VARCHAR(50),
	var_ReportPeriod VARCHAR(50),
    var_Dealer_Id longtext
)
BEGIN
	set sql_mode = '';
	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;

	if (var_Method_Name = 'Get') then
		if (var_Report_Type = 'C048010') then
			begin 
            
				set var_Dealer_Id = ifnull(var_Dealer_Id , '');
				SET @var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET @var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
								
				  
					set @cnt = (select length(var_Dealer_Id) - length(replace(var_Dealer_Id , ',' , '')));
					
					DROP TEMPORARY TABLE IF EXISTS temp_dealeropeningstock;
					create temporary table temp_dealeropeningstock( dealer_id varchar(20) , Material_Id varchar(20) , openingstock int , date varchar(50)  );
				
				INSERT INTO temp_dealeropeningstock(dealer_id , Material_Id ,  openingstock , date)
				SELECT  Dealer_id , Material_Id , Opening_Quantity , max(Date) from 
				f011_dealer_stock where  date(date)  = date( @var_StartDate)
				group by Dealer_id , Opening_Quantity , Material_Id 
				order by Date desc ;

					set @var_CursorTestID = 1;
					
					

					DROP TEMPORARY TABLE IF EXISTS temp_dealer;
					create temporary table temp_dealer( dealer_id varchar(20) );

					if(@cnt > 0) then
					
						While @var_CursorTestID <= @cnt + 1  Do
						set @Dealerid = (select SUBSTRING_INDEX(SUBSTRING_INDEX(var_Dealer_Id, ',', @var_CursorTestID), ',', -1));
							
							insert into temp_dealer(dealer_id) value
							(@Dealerid);
							
							Set @var_CursorTestID = @var_CursorTestID + 1;

						END WHILE;
					
					end if ;
					
				
					select 'TH' as RowType ,  'Dealer Code' as Dealer_Code , 'Dealer Name' as Dealer_Name, 
					'Material' as Material , 'Opening Balance' as Opening_Quantity , 'Dispatch Crate' as Good_Credit ,
					'Received' as Good_Debit , 
                    -- 'Returned-Broken' as Broken_Debit , 'Returned-ThirdParty' as ThirdParty_Debit ,
					'Closing Balance' as Closing_Quantity 

				union all


				select 'TR' as RowType , mu08.Dealer_code as Dealer_Code , mu08.Dealer_Name as Dealer_Name, 
				m010.Material_Name as Material , IFNULL(temptbl.openingstock , 0) as Opening_Quantity , 
				replace(IFNULL(sum(abs(Good_Credit)),0),'-' , '') as Good_Credit ,
				IFNULL(sum(Good_Debit),0) as Good_Debit , 
				-- IFNULL(sum(Broken_Debit) ,0)as Broken_Debit , 
				-- IFNULL(sum(ThirdParty_Debit),0) as ThirdParty_Debit ,  
				IFNULL((temptbl.openingstock + replace(sum(abs(Good_Credit)) ,'-' , '') - sum(Good_Debit) - sum(Broken_Debit) - sum(ThirdParty_Debit) ),0) as 
				Closing_Quantity from f011_dealer_stock f011
				inner join mu08_dealer mu08 on f011.Dealer_Id = mu08.Dealer_Id
				inner join m010_material m010 on m010.Material_Id = f011.Material_Id 
				INNER join temp_dealeropeningstock temptbl on temptbl.Dealer_id = f011.Dealer_id and temptbl.Material_Id = f011.Material_Id 
				where DATE(f011.Date) between date(@var_StartDate) and DATE_ADD(date(@var_EndDate), INTERVAL 0 DAY) 
				and if(@cnt > 0 ,  mu08.Dealer_Id  in (select dealer_id from temp_dealer) , 
				IF(var_Dealer_Id <> '' and @cnt = 0 , mu08.Dealer_Id =  var_Dealer_Id , 1=1)
				) group by mu08.Dealer_Code , m010.Material_Name;
                
			end;
		elseif (var_Report_Type = 'C048022') then
			begin
					SET @var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
					SET @var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');
		
					/*
				
					select 'TH' as RowType ,  'Dealer Code' as Dealer_Code , 'Dealer Name' as Dealer_Name, 
					'Material' as Material , 'Opening Quantity' as Opening_Quantity , 'Issued' as Good_Credit ,
					'Returned-Good' as Good_Debit , 'Returned-Broken' as Broken_Debit , 'Returned-ThirdParty' as ThirdParty_Debit ,
					'Closing Quantity' as Closing_Quantity ,'Date' as Date
										
					union all


					select
					'TR' as RowType , mu08.Dealer_code as Dealer_Code , mu08.Dealer_Name as Dealer_Name,m010.Material_Name as Material,
					ifnull(f011.Opening_Quantity,0) as Opening_Quantity,ifnull(f011.Good_Credit,0) as Good_Credit,
					ifnull(f011.Good_Debit,0) as Good_Debit,ifnull(f011.Broken_Debit,0) as Broken_Debit,
					ifnull(f011.ThirdParty_Debit,0) as ThirdParty_Debit,ifnull(f011.Closing_Quantity,0) as Closing_Quantity,
					DATE_FORMAT(f011.Date, '%d %b %Y') AS Date
					from f011_dealer_stock f011
					inner join mu08_dealer mu08 on
					mu08.Org_Id = f011.Org_Id
					and mu08.Dealer_Id = f011.Dealer_Id
					inner join m010_material m010 on
					m010.Org_Id = f011.Org_Id
					and m010.Material_Id = f011.Material_Id
					where f011.Org_Id =  var_Org_id
					and f011.Dealer_Id = var_Dealer_Id
					and date(f011.Date) >= date(@var_StartDate)
					and date(f011.Date) <= date(@var_EndDate)
					and f011.Material_Id <> 'M010241000020'
					and f011.Material_Id = 'M010241000022'

					union all

					select
					'TR' as RowType , mu08.Dealer_code as Dealer_Code , mu08.Dealer_Name as Dealer_Name,m010.Material_Name as Material,
					ifnull(f011.Opening_Quantity,0) as Opening_Quantity,ifnull(f011.Good_Credit,0) as Good_Credit,
					ifnull(f011.Good_Debit,0) as Good_Debit,ifnull(f011.Broken_Debit,0) as Broken_Debit,
					ifnull(f011.ThirdParty_Debit,0) as ThirdParty_Debit,ifnull(f011.Closing_Quantity,0) as Closing_Quantity,
					DATE_FORMAT(f011.Date, '%d %b %Y') AS Date
					from f011_dealer_stock f011
					inner join mu08_dealer mu08 on
					mu08.Org_Id = f011.Org_Id
					and mu08.Dealer_Id = f011.Dealer_Id
					inner join m010_material m010 on
					m010.Org_Id = f011.Org_Id
					and m010.Material_Id = f011.Material_Id
					where f011.Org_Id =  var_Org_id
					and f011.Dealer_Id = var_Dealer_Id
					and date(f011.Date) >= date(@var_StartDate)
					and date(f011.Date) <= date(@var_EndDate)
					and f011.Material_Id <> 'M010241000020'
					and f011.Material_Id = 'M010241000023';
                    
                    */
                    
                    select 'TH' as RowType ,  'Dealer Code' as Dealer_Code , 'Dealer Name' as Dealer_Name, 
					'Material' as Material , 'Opening Balance' as Opening_Quantity , 'Dispatch Crate' as Good_Credit ,
					'Received' as Good_Debit , 
                    -- 'Returned-Broken' as Broken_Debit , 'Returned-ThirdParty' as ThirdParty_Debit ,
					'Closing Balance' as Closing_Quantity ,'Date' as Date
										
					union all


					select
					'TR' as RowType , mu08.Dealer_code as Dealer_Code , mu08.Dealer_Name as Dealer_Name,m010.Material_Name as Material,
					ifnull(f011.Opening_Quantity,0) as Opening_Quantity,ifnull(f011.Good_Credit,0) as Good_Credit,
					ifnull(f011.Good_Debit,0) as Good_Debit,
                    -- ifnull(f011.Broken_Debit,0) as Broken_Debit,
					-- ifnull(f011.ThirdParty_Debit,0) as ThirdParty_Debit,
                    ifnull(f011.Closing_Quantity,0) as Closing_Quantity,
					DATE_FORMAT(f011.Date, '%d %b %Y') AS Date
					from f011_dealer_stock f011
					inner join mu08_dealer mu08 on
					mu08.Org_Id = f011.Org_Id
					and mu08.Dealer_Id = f011.Dealer_Id
					inner join m010_material m010 on
					m010.Org_Id = f011.Org_Id
					and m010.Material_Id = f011.Material_Id
					where f011.Org_Id =  var_Org_id
					and f011.Dealer_Id = var_Dealer_Id
					and date(f011.Date) >= date(@var_StartDate)
					and date(f011.Date) <= date(@var_EndDate);
                    
                    
                    
                    /*
                    DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
                    
                    CREATE TEMPORARY TABLE temp_Report_1 ( 
                    Dealer_code varchar(255),Dealer_Name varchar(255),Material varchar(255),
                    Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
                    ThirdParty_Debit varchar(255),Closing_Quantity varchar(255),Date varchar(255)
                    );
                    
                    insert into temp_Report_1 (
                    Dealer_code ,Dealer_Name ,Material ,
                    Opening_Quantity ,Good_Credit ,Good_Debit ,Broken_Debit ,
                    ThirdParty_Debit ,Closing_Quantity ,Date 
                    )
                    select mu08.Dealer_code as Dealer_Code , mu08.Dealer_Name as Dealer_Name,m010.Material_Name as Material,
					ifnull(f011.Opening_Quantity,0) as Opening_Quantity,ifnull(f011.Good_Credit,0) as Good_Credit,
					ifnull(f011.Good_Debit,0) as Good_Debit,ifnull(f011.Broken_Debit,0) as Broken_Debit,
					ifnull(f011.ThirdParty_Debit,0) as ThirdParty_Debit,ifnull(f011.Closing_Quantity,0) as Closing_Quantity,
					DATE_FORMAT(f011.Date, '%d %b %Y') AS Date
					from f011_dealer_stock f011
					inner join mu08_dealer mu08 on
					mu08.Org_Id = f011.Org_Id
					and mu08.Dealer_Id = f011.Dealer_Id
					inner join m010_material m010 on
					m010.Org_Id = f011.Org_Id
					and m010.Material_Id = f011.Material_Id
					where f011.Org_Id =  var_Org_id
					and f011.Dealer_Id = var_Dealer_Id
					and date(f011.Date) >= date(@var_StartDate)
					and date(f011.Date) <= date(@var_EndDate)
					and f011.Material_Id <> 'M010241000020'
					and f011.Material_Id in ('M010241000022') 
                    ORDER BY 
					m010.Material_Name ASC, 
					f011.Date ASC;
                    
                    DROP TEMPORARY TABLE IF EXISTS temp_Report_2;
                    
                    CREATE TEMPORARY TABLE temp_Report_2 ( 
                    Dealer_code varchar(255),Dealer_Name varchar(255),Material varchar(255),
                    Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
                    ThirdParty_Debit varchar(255),Closing_Quantity varchar(255),Date varchar(255)
                    );
                    
                    insert into temp_Report_2 (
                    Dealer_code ,Dealer_Name ,Material ,
                    Opening_Quantity ,Good_Credit ,Good_Debit ,Broken_Debit ,
                    ThirdParty_Debit ,Closing_Quantity ,Date 
                    )
                    select mu08.Dealer_code as Dealer_Code , mu08.Dealer_Name as Dealer_Name,m010.Material_Name as Material,
					ifnull(f011.Opening_Quantity,0) as Opening_Quantity,ifnull(f011.Good_Credit,0) as Good_Credit,
					ifnull(f011.Good_Debit,0) as Good_Debit,ifnull(f011.Broken_Debit,0) as Broken_Debit,
					ifnull(f011.ThirdParty_Debit,0) as ThirdParty_Debit,ifnull(f011.Closing_Quantity,0) as Closing_Quantity,
					DATE_FORMAT(f011.Date, '%d %b %Y') AS Date
					from f011_dealer_stock f011
					inner join mu08_dealer mu08 on
					mu08.Org_Id = f011.Org_Id
					and mu08.Dealer_Id = f011.Dealer_Id
					inner join m010_material m010 on
					m010.Org_Id = f011.Org_Id
					and m010.Material_Id = f011.Material_Id
					where f011.Org_Id =  var_Org_id
					and f011.Dealer_Id = var_Dealer_Id
					and date(f011.Date) >= date(@var_StartDate)
					and date(f011.Date) <= date(@var_EndDate)
					and f011.Material_Id <> 'M010241000020'
					and f011.Material_Id in ('M010241000023') 
                    ORDER BY 
					m010.Material_Name ASC, 
					f011.Date ASC;
                    
                    
                   DROP TEMPORARY TABLE IF EXISTS temp_Report_3;
                    
                    CREATE TEMPORARY TABLE temp_Report_3 ( 
                    Dealer_code varchar(255),Dealer_Name varchar(255),Material varchar(255),
                    Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
                    ThirdParty_Debit varchar(255),Closing_Quantity varchar(255),Date varchar(255)
                    );
                    
                    insert into temp_Report_3 (
                    Dealer_code ,Dealer_Name ,Material ,
                    Opening_Quantity ,Good_Credit ,Good_Debit ,Broken_Debit ,
                    ThirdParty_Debit ,Closing_Quantity ,Date 
                    )
                    select 
                    Dealer_code ,Dealer_Name ,Material ,
                    Opening_Quantity ,Good_Credit ,Good_Debit ,Broken_Debit ,
                    ThirdParty_Debit ,Closing_Quantity ,Date
                    from temp_Report_1
                    
                    union all

					select
					 '<br>' Dealer_Code , '<br>' as Dealer_Name,'<br>' as Material,
					'<br>' as Opening_Quantity,'<br>' as Good_Credit,
					'<br>' as Good_Debit,'<br>' as Broken_Debit,
					'<br>' as ThirdParty_Debit,'<br>' as Closing_Quantity,
					'<br>' AS Date
                    
					union all
                    
                    select 
                    Dealer_code ,Dealer_Name ,Material ,
                    Opening_Quantity ,Good_Credit ,Good_Debit ,Broken_Debit ,
                    ThirdParty_Debit ,Closing_Quantity ,Date
                    from temp_Report_2;
                    
					
                    
                    select 'TH' as RowType ,  'Dealer Code' as Dealer_Code , 'Dealer Name' as Dealer_Name, 
					'Material' as Material , 'Opening Quantity' as Opening_Quantity , 'Issued' as Good_Credit ,
					'Returned-Good' as Good_Debit , 'Returned-Broken' as Broken_Debit , 'Returned-ThirdParty' as ThirdParty_Debit ,
					'Closing Quantity' as Closing_Quantity ,'Date' as Date
										
					union all
                    select 
                    'TR' as RowType ,Dealer_code ,Dealer_Name ,Material ,
                    Opening_Quantity ,Good_Credit ,Good_Debit ,Broken_Debit ,
                    ThirdParty_Debit ,Closing_Quantity ,Date
                    from temp_Report_3
                    ;
                    
                    */
                    
                    
                    
                    
            end;
				elseif (var_Report_Type = 'C048023') then
			begin

				SET @var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET @var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');

				DROP TEMPORARY TABLE IF EXISTS temp_dates;

				CREATE TEMPORARY TABLE temp_dates (Date DATE);

				INSERT INTO temp_dates (Date) 
				select Date from f011_dealer_stock f011
				where f011.Org_Id = var_Org_id
				and f011.Dealer_Id = var_Dealer_Id
				and date(f011.Date) >= date(@var_StartDate)
				and date(f011.Date) <= date(@var_EndDate)
				-- and Material_Id <> 'M010241000020'
				group by Date;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
									
				CREATE TEMPORARY TABLE temp_Report_1 (
				Start_Date date, End_Date date,
				Dealer_ID varchar(255),Material_Id varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255)
				);

				insert into temp_Report_1 (
				Start_Date ,End_Date 
				)

				SELECT 
					MIN(Date) AS Start_Date, 
					MAX(Date) AS End_Date
				FROM (
					SELECT 
						Date, 
						DATE_SUB(Date, INTERVAL (WEEKDAY(Date) + 1) DAY) AS Week_Start
					FROM temp_dates
					WHERE Date BETWEEN @var_StartDate AND @var_EndDate
				) AS Week_Dates
				GROUP BY Week_Start
				ORDER BY Start_Date;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_1_1;
									
				CREATE TEMPORARY TABLE temp_Report_1_1 (
				Start_Date date, End_Date date,
				Dealer_ID varchar(255),Material_Id varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255)
				);

				insert into temp_Report_1_1 select * from temp_Report_1;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_1_2;

				CREATE TEMPORARY TABLE temp_Report_1_2 (
				Start_Date date, End_Date date,
				Dealer_ID varchar(255),Material_Id varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255)
				);

				insert into temp_Report_1_2 select * from temp_Report_1;



				DROP TEMPORARY TABLE IF EXISTS temp_Report_2;
									
				CREATE TEMPORARY TABLE temp_Report_2 (
				Start_Date date, End_Date date,
				Material_Id varchar(255),
				Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255)
				);

				insert into temp_Report_2 (
				Start_Date ,End_Date ,
				Material_Id,
				Good_Credit ,Good_Debit ,Broken_Debit ,
				ThirdParty_Debit 
				)
				select 
				tmp.Start_Date,tmp.End_Date ,
				f011.Material_Id,
				sum(abs(ifnull(f011.Good_Credit,0))) as Good_Credit,
				sum(ifnull(f011.Good_Debit,0)) as Good_Debit,sum(ifnull(f011.Broken_Debit,0)) as Broken_Debit,
				sum(ifnull(f011.ThirdParty_Debit,0)) as ThirdParty_Debit
				from temp_Report_1 tmp
				inner join f011_dealer_stock f011 on
				date(f011.Date) >= date(tmp.Start_Date)
				and date(f011.Date) <= date(tmp.End_Date)
				-- and f011.Material_Id <> 'M010241000020'
				and f011.Dealer_Id = var_Dealer_Id
				and date(f011.Date) >= date(@var_StartDate)
				and date(f011.Date) <= date(@var_EndDate)
				group by tmp.Start_Date,tmp.End_Date ,
				f011.Material_Id;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_3;
									
				CREATE TEMPORARY TABLE temp_Report_3 (
				Start_Date date, End_Date date,
				Material_Id varchar(255),
				Opening_Quantity varchar(255), date date
				);

				insert into temp_Report_3 (
				Start_Date ,End_Date ,
				Material_Id,
				Opening_Quantity ,
				date
				)
				SELECT 
					tmp.Start_Date,
					tmp.End_Date,
					f011.Material_Id,
					ifnull(f011.Opening_Quantity, 0) as Opening_Quantity,
					f011.date
				FROM (
					SELECT 
						tmp.Start_Date,
						tmp.End_Date,
						f011.Material_Id,
						MIN(f011.Date) as date
					FROM temp_Report_1_1 tmp
					INNER JOIN f011_dealer_stock f011 ON
						date(f011.Date) >= date(tmp.Start_Date) AND
						date(f011.Date) <= date(tmp.End_Date) AND
						-- f011.Material_Id <> 'M010241000020' AND
						f011.Dealer_Id =  var_Dealer_Id AND
						date(f011.Date) >= date(@var_StartDate) AND
						date(f011.Date) <= date(@var_EndDate)
					GROUP BY tmp.Start_Date, tmp.End_Date, f011.Material_Id
				) min_dates
				INNER JOIN f011_dealer_stock f011 ON
					min_dates.Material_Id = f011.Material_Id AND
					min_dates.date = f011.Date
				INNER JOIN temp_Report_1 tmp ON
					tmp.Start_Date = min_dates.Start_Date AND
					tmp.End_Date = min_dates.End_Date
				WHERE 
					date(f011.Date) >= date(tmp.Start_Date) AND
					date(f011.Date) <= date(tmp.End_Date) AND
					-- f011.Material_Id <> 'M010241000020' AND
					f011.Dealer_Id =  var_Dealer_Id AND
					date(f011.Date) >= date(@var_StartDate) AND
					date(f011.Date) <= date(@var_EndDate);


				DROP TEMPORARY TABLE IF EXISTS temp_Report_4;
									
				CREATE TEMPORARY TABLE temp_Report_4 (
				Start_Date date, End_Date date,
				Material_Id varchar(255),
				Closing_Quantity varchar(255), date date
				);

				insert into temp_Report_4 (
				Start_Date ,End_Date ,
				Material_Id,
				Closing_Quantity ,
				date
				)
				SELECT 
					tmp.Start_Date,
					tmp.End_Date,
					f011.Material_Id,
					ifnull(f011.Closing_Quantity, 0) as Closing_Quantity,
					f011.date
				FROM (
					SELECT 
						tmp.Start_Date,
						tmp.End_Date,
						f011.Material_Id,
						MAX(f011.Date) as date
					FROM temp_Report_1_2 tmp
					INNER JOIN f011_dealer_stock f011 ON
						date(f011.Date) >= date(tmp.Start_Date) AND
						date(f011.Date) <= date(tmp.End_Date) AND
						-- f011.Material_Id <> 'M010241000020' AND
						f011.Dealer_Id =  var_Dealer_Id AND
						date(f011.Date) >= date(@var_StartDate) AND
						date(f011.Date) <= date(@var_EndDate)
					GROUP BY tmp.Start_Date, tmp.End_Date, f011.Material_Id
				) min_dates
				INNER JOIN f011_dealer_stock f011 ON
					min_dates.Material_Id = f011.Material_Id AND
					min_dates.date = f011.Date
				INNER JOIN temp_Report_1 tmp ON
					tmp.Start_Date = min_dates.Start_Date AND
					tmp.End_Date = min_dates.End_Date
				WHERE 
					date(f011.Date) >= date(tmp.Start_Date) AND
					date(f011.Date) <= date(tmp.End_Date) AND
					-- f011.Material_Id <> 'M010241000020' AND
					f011.Dealer_Id =  var_Dealer_Id AND
					date(f011.Date) >= date(@var_StartDate) AND
					date(f011.Date) <= date(@var_EndDate);


				DROP TEMPORARY TABLE IF EXISTS temp_Report_Main;
									
				CREATE TEMPORARY TABLE temp_Report_Main ( 
				Start_Date date, End_Date date,
				-- date longtext,
				Dealer_Id varchar(255),Dealer_code varchar(255),Dealer_Name varchar(255),
				Material_Id varchar(255),Material_Name varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255),Date varchar(255)
				);

				insert into temp_Report_Main (
				Start_Date ,End_Date ,
				Material_Id ,
				Opening_Quantity ,Good_Credit ,Good_Debit ,Broken_Debit ,
				ThirdParty_Debit ,Closing_Quantity  
				)
				select 
				tm2.Start_Date,tm2.End_Date,tm2.Material_Id,
				tm3.Opening_Quantity,
				tm2.Good_Credit,tm2.Good_Debit,tm2.Broken_Debit,tm2.ThirdParty_Debit,
				tm4.Closing_Quantity
				from temp_Report_2 tm2 
				inner join temp_Report_3 tm3 on
				date(tm2.Start_Date) =  date(tm3.Start_Date)
				and date(tm2.End_Date) =  date(tm3.End_Date)
				and tm2.Material_Id =  tm3.Material_Id
				inner join temp_Report_4 tm4 on
				date(tm2.Start_Date) =  date(tm4.Start_Date)
				and date(tm2.End_Date) =  date(tm4.End_Date)
				and tm2.Material_Id =  tm4.Material_Id 
				order by tm2.Material_Id  asc, tm2.Start_Date asc;

				select 'TH' as RowType ,  'Dealer Code' as Dealer_Code , 'Dealer Name' as Dealer_Name, 
				'Material' as Material , 'Opening Balance' as Opening_Quantity , 'Dispatch Crate' as Good_Credit ,
				'Received' as Good_Debit , 
                -- 'Returned-Broken' as Broken_Debit , 'Returned-ThirdParty' as ThirdParty_Debit ,
				'Closing Balance' as Closing_Quantity ,'Date' as Date

				union all

				select 
				'TR' as RowType , mu08.Dealer_code as Dealer_Code , mu08.Dealer_Name as Dealer_Name,m010.Material_Name as Material,
				ifnull(f011.Opening_Quantity,0) as Opening_Quantity,ifnull(f011.Good_Credit,0) as Good_Credit,
				ifnull(f011.Good_Debit,0) as Good_Debit,
                -- ifnull(f011.Broken_Debit,0) as Broken_Debit,
				-- ifnull(f011.ThirdParty_Debit,0) as ThirdParty_Debit,
                ifnull(f011.Closing_Quantity,0) as Closing_Quantity,
				concat(DATE_FORMAT(f011.Start_Date, '%d %b %Y'), ' - ', DATE_FORMAT(f011.End_Date, '%d %b %Y')) AS Date
				from temp_Report_Main f011
				inner join mu08_dealer mu08 on
				mu08.Dealer_Id =  var_Dealer_Id
				inner join m010_material m010 on
				m010.Material_Id = f011.Material_Id;

			end;
		elseif (var_Report_Type = 'C048024') then
			begin

				SET @var_StartDate = STR_TO_DATE(SUBSTRING_INDEX( var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET @var_EndDate = STR_TO_DATE(SUBSTRING_INDEX( var_ReportPeriod, ' - ', -1), '%m/%d/%Y');

				DROP TEMPORARY TABLE IF EXISTS temp_dates;

				CREATE TEMPORARY TABLE temp_dates (Date DATE);

				INSERT INTO temp_dates (Date) 
				select Date from f011_dealer_stock f011
				where f011.Org_Id = var_Org_id
				and f011.Dealer_Id = var_Dealer_Id
				and date(f011.Date) >= date(@var_StartDate)
				and date(f011.Date) <= date(@var_EndDate)
				-- and Material_Id <> 'M010241000020'
				group by Date;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
									
				CREATE TEMPORARY TABLE temp_Report_1 (
				Start_Date date, End_Date date,
				Dealer_ID varchar(255),Material_Id varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255)
				);

				insert into temp_Report_1 (
				Start_Date ,End_Date 
				)

				SELECT 
					MIN(Date) AS Start_Date, 
					MAX(Date) AS End_Date
				FROM (
					SELECT 
						Date, 
						DATE_FORMAT(Date, '%Y-%m-01') AS Month_Start
					FROM temp_dates
					WHERE Date BETWEEN @var_StartDate AND @var_EndDate
				) AS Month_Dates
				GROUP BY Month_Start
				ORDER BY Start_Date;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_1_1;
									
				CREATE TEMPORARY TABLE temp_Report_1_1 (
				Start_Date date, End_Date date,
				Dealer_ID varchar(255),Material_Id varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255)
				);

				insert into temp_Report_1_1 select * from temp_Report_1;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_1_2;

				CREATE TEMPORARY TABLE temp_Report_1_2 (
				Start_Date date, End_Date date,
				Dealer_ID varchar(255),Material_Id varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255)
				);

				insert into temp_Report_1_2 select * from temp_Report_1;



				DROP TEMPORARY TABLE IF EXISTS temp_Report_2;
									
				CREATE TEMPORARY TABLE temp_Report_2 (
				Start_Date date, End_Date date,
				Material_Id varchar(255),
				Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255)
				);

				insert into temp_Report_2 (
				Start_Date ,End_Date ,
				Material_Id,
				Good_Credit ,Good_Debit ,Broken_Debit ,
				ThirdParty_Debit 
				)
				select 
				tmp.Start_Date,tmp.End_Date ,
				f011.Material_Id,
				sum(abs(ifnull(f011.Good_Credit,0))) as Good_Credit,
				sum(ifnull(f011.Good_Debit,0)) as Good_Debit,sum(ifnull(f011.Broken_Debit,0)) as Broken_Debit,
				sum(ifnull(f011.ThirdParty_Debit,0)) as ThirdParty_Debit
				from temp_Report_1 tmp
				inner join f011_dealer_stock f011 on
				date(f011.Date) >= date(tmp.Start_Date)
				and date(f011.Date) <= date(tmp.End_Date)
				-- and f011.Material_Id <> 'M010241000020'
				and f011.Dealer_Id = var_Dealer_Id
				and date(f011.Date) >= date(@var_StartDate)
				and date(f011.Date) <= date(@var_EndDate)
				group by tmp.Start_Date,tmp.End_Date ,
				f011.Material_Id;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_3;
									
				CREATE TEMPORARY TABLE temp_Report_3 (
				Start_Date date, End_Date date,
				Material_Id varchar(255),
				Opening_Quantity varchar(255), date date
				);

				insert into temp_Report_3 (
				Start_Date ,End_Date ,
				Material_Id,
				Opening_Quantity ,
				date
				)
				SELECT 
					tmp.Start_Date,
					tmp.End_Date,
					f011.Material_Id,
					ifnull(f011.Opening_Quantity, 0) as Opening_Quantity,
					f011.date
				FROM (
					SELECT 
						tmp.Start_Date,
						tmp.End_Date,
						f011.Material_Id,
						MIN(f011.Date) as date
					FROM temp_Report_1_1 tmp
					INNER JOIN f011_dealer_stock f011 ON
						date(f011.Date) >= date(tmp.Start_Date) AND
						date(f011.Date) <= date(tmp.End_Date) AND
						-- f011.Material_Id <> 'M010241000020' AND
						f011.Dealer_Id =  var_Dealer_Id AND
						date(f011.Date) >= date(@var_StartDate) AND
						date(f011.Date) <= date(@var_EndDate)
					GROUP BY tmp.Start_Date, tmp.End_Date, f011.Material_Id
				) min_dates
				INNER JOIN f011_dealer_stock f011 ON
					min_dates.Material_Id = f011.Material_Id AND
					min_dates.date = f011.Date
				INNER JOIN temp_Report_1 tmp ON
					tmp.Start_Date = min_dates.Start_Date AND
					tmp.End_Date = min_dates.End_Date
				WHERE 
					date(f011.Date) >= date(tmp.Start_Date) AND
					date(f011.Date) <= date(tmp.End_Date) AND
					-- f011.Material_Id <> 'M010241000020' AND
					f011.Dealer_Id =  var_Dealer_Id AND
					date(f011.Date) >= date(@var_StartDate) AND
					date(f011.Date) <= date(@var_EndDate);



				DROP TEMPORARY TABLE IF EXISTS temp_Report_4;
									
				CREATE TEMPORARY TABLE temp_Report_4 (
				Start_Date date, End_Date date,
				Material_Id varchar(255),
				Closing_Quantity varchar(255), date date
				);

				insert into temp_Report_4 (
				Start_Date ,End_Date ,
				Material_Id,
				Closing_Quantity ,
				date
				)
				SELECT 
					tmp.Start_Date,
					tmp.End_Date,
					f011.Material_Id,
					ifnull(f011.Closing_Quantity, 0) as Closing_Quantity,
					f011.date
				FROM (
					SELECT 
						tmp.Start_Date,
						tmp.End_Date,
						f011.Material_Id,
						MAX(f011.Date) as date
					FROM temp_Report_1_2 tmp
					INNER JOIN f011_dealer_stock f011 ON
						date(f011.Date) >= date(tmp.Start_Date) AND
						date(f011.Date) <= date(tmp.End_Date) AND
						-- f011.Material_Id <> 'M010241000020' AND
						f011.Dealer_Id =  var_Dealer_Id AND
						date(f011.Date) >= date(@var_StartDate) AND
						date(f011.Date) <= date(@var_EndDate)
					GROUP BY tmp.Start_Date, tmp.End_Date, f011.Material_Id
				) min_dates
				INNER JOIN f011_dealer_stock f011 ON
					min_dates.Material_Id = f011.Material_Id AND
					min_dates.date = f011.Date
				INNER JOIN temp_Report_1 tmp ON
					tmp.Start_Date = min_dates.Start_Date AND
					tmp.End_Date = min_dates.End_Date
				WHERE 
					date(f011.Date) >= date(tmp.Start_Date) AND
					date(f011.Date) <= date(tmp.End_Date) AND
					-- f011.Material_Id <> 'M010241000020' AND
					f011.Dealer_Id =  var_Dealer_Id AND
					date(f011.Date) >= date(@var_StartDate) AND
					date(f011.Date) <= date(@var_EndDate);



				DROP TEMPORARY TABLE IF EXISTS temp_Report_Main;
									
				CREATE TEMPORARY TABLE temp_Report_Main ( 
				Start_Date date, End_Date date,
				-- date longtext,
				Dealer_Id varchar(255),Dealer_code varchar(255),Dealer_Name varchar(255),
				Material_Id varchar(255),Material_Name varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255),Date varchar(255)
				);

				insert into temp_Report_Main (
				Start_Date ,End_Date ,
				Material_Id ,
				Opening_Quantity ,Good_Credit ,Good_Debit ,Broken_Debit ,
				ThirdParty_Debit ,Closing_Quantity  
				)
				select 
				tm2.Start_Date,tm2.End_Date,tm2.Material_Id,
				tm3.Opening_Quantity,
				tm2.Good_Credit,tm2.Good_Debit,tm2.Broken_Debit,tm2.ThirdParty_Debit,
				tm4.Closing_Quantity
				from temp_Report_2 tm2 
				inner join temp_Report_3 tm3 on
				date(tm2.Start_Date) =  date(tm3.Start_Date)
				and date(tm2.End_Date) =  date(tm3.End_Date)
				and tm2.Material_Id =  tm3.Material_Id
				inner join temp_Report_4 tm4 on
				date(tm2.Start_Date) =  date(tm4.Start_Date)
				and date(tm2.End_Date) =  date(tm4.End_Date)
				and tm2.Material_Id =  tm4.Material_Id 
				order by tm2.Material_Id  asc, tm2.Start_Date asc;

				select 'TH' as RowType ,  'Dealer Code' as Dealer_Code , 'Dealer Name' as Dealer_Name, 
				'Material' as Material , 'Opening Balance' as Opening_Quantity , 'Dispatch Crate' as Good_Credit ,
				'Received' as Good_Debit , 
                -- 'Returned-Broken' as Broken_Debit , 'Returned-ThirdParty' as ThirdParty_Debit ,
				'Closing Balance' as Closing_Quantity ,'Date' as Date

				union all

				select 
				'TR' as RowType , mu08.Dealer_code as Dealer_Code , mu08.Dealer_Name as Dealer_Name,m010.Material_Name as Material,
				ifnull(f011.Opening_Quantity,0) as Opening_Quantity,ifnull(f011.Good_Credit,0) as Good_Credit,
				ifnull(f011.Good_Debit,0) as Good_Debit,
                -- ifnull(f011.Broken_Debit,0) as Broken_Debit,
				-- ifnull(f011.ThirdParty_Debit,0) as ThirdParty_Debit,
                ifnull(f011.Closing_Quantity,0) as Closing_Quantity,
				concat(DATE_FORMAT(f011.Start_Date, '%d %b %Y'), ' - ', DATE_FORMAT(f011.End_Date, '%d %b %Y')) AS Date
				from temp_Report_Main f011
				inner join mu08_dealer mu08 on
				mu08.Dealer_Id =  var_Dealer_Id
				inner join m010_material m010 on
				m010.Material_Id = f011.Material_Id;

			end;
				elseif (var_Report_Type = 'C048025') then
			begin

				SET @var_StartDate = STR_TO_DATE(SUBSTRING_INDEX( var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
				SET @var_EndDate = STR_TO_DATE(SUBSTRING_INDEX( var_ReportPeriod, ' - ', -1), '%m/%d/%Y');

				DROP TEMPORARY TABLE IF EXISTS temp_dates;

				CREATE TEMPORARY TABLE temp_dates (Date DATE);

				INSERT INTO temp_dates (Date) 
				select Date from f011_dealer_stock f011
				where f011.Org_Id = var_Org_id
				and f011.Dealer_Id = var_Dealer_Id
				and date(f011.Date) >= date(@var_StartDate)
				and date(f011.Date) <= date(@var_EndDate)
				-- and Material_Id <> 'M010241000020'
				group by Date;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_1;
									
				CREATE TEMPORARY TABLE temp_Report_1 (
				Start_Date date, End_Date date,
				Dealer_ID varchar(255),Material_Id varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255)
				);

				insert into temp_Report_1 (
				Start_Date ,End_Date 
				)

				SELECT 
					MIN(Date) AS Start_Date, 
					MAX(Date) AS End_Date
				FROM (
					SELECT 
						Date, 
						DATE_FORMAT(Date, '%Y-01-01') AS Year_Start
					FROM temp_dates
					WHERE Date BETWEEN @var_StartDate AND @var_EndDate
				) AS Year_Dates
				GROUP BY Year_Start
				ORDER BY Start_Date;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_1_1;
									
				CREATE TEMPORARY TABLE temp_Report_1_1 (
				Start_Date date, End_Date date,
				Dealer_ID varchar(255),Material_Id varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255)
				);

				insert into temp_Report_1_1 select * from temp_Report_1;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_1_2;

				CREATE TEMPORARY TABLE temp_Report_1_2 (
				Start_Date date, End_Date date,
				Dealer_ID varchar(255),Material_Id varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255)
				);

				insert into temp_Report_1_2 select * from temp_Report_1;



				DROP TEMPORARY TABLE IF EXISTS temp_Report_2;
									
				CREATE TEMPORARY TABLE temp_Report_2 (
				Start_Date date, End_Date date,
				Material_Id varchar(255),
				Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255)
				);

				insert into temp_Report_2 (
				Start_Date ,End_Date ,
				Material_Id,
				Good_Credit ,Good_Debit ,Broken_Debit ,
				ThirdParty_Debit 
				)
				select 
				tmp.Start_Date,tmp.End_Date ,
				f011.Material_Id,
				sum(abs(ifnull(f011.Good_Credit,0))) as Good_Credit,
				sum(ifnull(f011.Good_Debit,0)) as Good_Debit,sum(ifnull(f011.Broken_Debit,0)) as Broken_Debit,
				sum(ifnull(f011.ThirdParty_Debit,0)) as ThirdParty_Debit
				from temp_Report_1 tmp
				inner join f011_dealer_stock f011 on
				date(f011.Date) >= date(tmp.Start_Date)
				and date(f011.Date) <= date(tmp.End_Date)
				-- and f011.Material_Id <> 'M010241000020'
				and f011.Dealer_Id = var_Dealer_Id
				and date(f011.Date) >= date(@var_StartDate)
				and date(f011.Date) <= date(@var_EndDate)
				group by tmp.Start_Date,tmp.End_Date ,
				f011.Material_Id;


				DROP TEMPORARY TABLE IF EXISTS temp_Report_3;
									
				CREATE TEMPORARY TABLE temp_Report_3 (
				Start_Date date, End_Date date,
				Material_Id varchar(255),
				Opening_Quantity varchar(255), date date
				);

				insert into temp_Report_3 (
				Start_Date ,End_Date ,
				Material_Id,
				Opening_Quantity ,
				date
				)
				SELECT 
					tmp.Start_Date,
					tmp.End_Date,
					f011.Material_Id,
					ifnull(f011.Opening_Quantity, 0) as Opening_Quantity,
					f011.date
				FROM (
					SELECT 
						tmp.Start_Date,
						tmp.End_Date,
						f011.Material_Id,
						MIN(f011.Date) as date
					FROM temp_Report_1_1 tmp
					INNER JOIN f011_dealer_stock f011 ON
						date(f011.Date) >= date(tmp.Start_Date) AND
						date(f011.Date) <= date(tmp.End_Date) AND
						-- f011.Material_Id <> 'M010241000020' AND
						f011.Dealer_Id =  var_Dealer_Id AND
						date(f011.Date) >= date(@var_StartDate) AND
						date(f011.Date) <= date(@var_EndDate)
					GROUP BY tmp.Start_Date, tmp.End_Date, f011.Material_Id
				) min_dates
				INNER JOIN f011_dealer_stock f011 ON
					min_dates.Material_Id = f011.Material_Id AND
					min_dates.date = f011.Date
				INNER JOIN temp_Report_1 tmp ON
					tmp.Start_Date = min_dates.Start_Date AND
					tmp.End_Date = min_dates.End_Date
				WHERE 
					date(f011.Date) >= date(tmp.Start_Date) AND
					date(f011.Date) <= date(tmp.End_Date) AND
					-- f011.Material_Id <> 'M010241000020' AND
					f011.Dealer_Id =  var_Dealer_Id AND
					date(f011.Date) >= date(@var_StartDate) AND
					date(f011.Date) <= date(@var_EndDate);


				DROP TEMPORARY TABLE IF EXISTS temp_Report_4;
									
				CREATE TEMPORARY TABLE temp_Report_4 (
				Start_Date date, End_Date date,
				Material_Id varchar(255),
				Closing_Quantity varchar(255), date date
				);

				insert into temp_Report_4 (
				Start_Date ,End_Date ,
				Material_Id,
				Closing_Quantity ,
				date
				)
				SELECT 
					tmp.Start_Date,
					tmp.End_Date,
					f011.Material_Id,
					ifnull(f011.Closing_Quantity, 0) as Closing_Quantity,
					f011.date
				FROM (
					SELECT 
						tmp.Start_Date,
						tmp.End_Date,
						f011.Material_Id,
						MAX(f011.Date) as date
					FROM temp_Report_1_2 tmp
					INNER JOIN f011_dealer_stock f011 ON
						date(f011.Date) >= date(tmp.Start_Date) AND
						date(f011.Date) <= date(tmp.End_Date) AND
						-- f011.Material_Id <> 'M010241000020' AND
						f011.Dealer_Id =  var_Dealer_Id AND
						date(f011.Date) >= date(@var_StartDate) AND
						date(f011.Date) <= date(@var_EndDate)
					GROUP BY tmp.Start_Date, tmp.End_Date, f011.Material_Id
				) min_dates
				INNER JOIN f011_dealer_stock f011 ON
					min_dates.Material_Id = f011.Material_Id AND
					min_dates.date = f011.Date
				INNER JOIN temp_Report_1 tmp ON
					tmp.Start_Date = min_dates.Start_Date AND
					tmp.End_Date = min_dates.End_Date
				WHERE 
					date(f011.Date) >= date(tmp.Start_Date) AND
					date(f011.Date) <= date(tmp.End_Date) AND
					-- f011.Material_Id <> 'M010241000020' AND
					f011.Dealer_Id =  var_Dealer_Id AND
					date(f011.Date) >= date(@var_StartDate) AND
					date(f011.Date) <= date(@var_EndDate);


				DROP TEMPORARY TABLE IF EXISTS temp_Report_Main;
									
				CREATE TEMPORARY TABLE temp_Report_Main ( 
				Start_Date date, End_Date date,
				-- date longtext,
				Dealer_Id varchar(255),Dealer_code varchar(255),Dealer_Name varchar(255),
				Material_Id varchar(255),Material_Name varchar(255),
				Opening_Quantity varchar(255),Good_Credit varchar(255),Good_Debit varchar(255),Broken_Debit varchar(255),
				ThirdParty_Debit varchar(255),Closing_Quantity varchar(255),Date varchar(255)
				);

				insert into temp_Report_Main (
				Start_Date ,End_Date ,
				Material_Id ,
				Opening_Quantity ,Good_Credit ,Good_Debit ,Broken_Debit ,
				ThirdParty_Debit ,Closing_Quantity  
				)
				select 
				tm2.Start_Date,tm2.End_Date,tm2.Material_Id,
				tm3.Opening_Quantity,
				tm2.Good_Credit,tm2.Good_Debit,tm2.Broken_Debit,tm2.ThirdParty_Debit,
				tm4.Closing_Quantity
				from temp_Report_2 tm2 
				inner join temp_Report_3 tm3 on
				date(tm2.Start_Date) =  date(tm3.Start_Date)
				and date(tm2.End_Date) =  date(tm3.End_Date)
				and tm2.Material_Id =  tm3.Material_Id
				inner join temp_Report_4 tm4 on
				date(tm2.Start_Date) =  date(tm4.Start_Date)
				and date(tm2.End_Date) =  date(tm4.End_Date)
				and tm2.Material_Id =  tm4.Material_Id 
				order by tm2.Material_Id  asc, tm2.Start_Date asc;

				select 'TH' as RowType ,  'Dealer Code' as Dealer_Code , 'Dealer Name' as Dealer_Name, 
				'Material' as Material , 'Opening Balance' as Opening_Quantity , 'Dispatch Crate' as Good_Credit ,
				'Received' as Good_Debit , 
                -- 'Returned-Broken' as Broken_Debit , 'Returned-ThirdParty' as ThirdParty_Debit ,
				'Closing Balance' as Closing_Quantity ,'Date' as Date

				union all

				select 
				'TR' as RowType , mu08.Dealer_code as Dealer_Code , mu08.Dealer_Name as Dealer_Name,m010.Material_Name as Material,
				ifnull(f011.Opening_Quantity,0) as Opening_Quantity,ifnull(f011.Good_Credit,0) as Good_Credit,
				ifnull(f011.Good_Debit,0) as Good_Debit,
                -- ifnull(f011.Broken_Debit,0) as Broken_Debit,
				-- ifnull(f011.ThirdParty_Debit,0) as ThirdParty_Debit,
                ifnull(f011.Closing_Quantity,0) as Closing_Quantity,
				concat(DATE_FORMAT(f011.Start_Date, '%d %b %Y'), ' - ', DATE_FORMAT(f011.End_Date, '%d %b %Y')) AS Date
				from temp_Report_Main f011
				inner join mu08_dealer mu08 on
				mu08.Dealer_Id =  var_Dealer_Id
				inner join m010_material m010 on
				m010.Material_Id = f011.Material_Id;

			end;
		end if;
    end if;
        
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
