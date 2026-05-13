-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesUserCrate` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesUserCrate`(
	Var_Method_Name varchar(255),
    Var_Org_Id varchar(10),
    Var_Profile_Id varchar(20),
    Var_SalesUser_Id varchar(20),
    Var_UserType varchar(50),
    Var_XMLData longtext,
    Var_Dealer_Id varchar(20),
	Var_Date varchar(255),
    var_Material_Group varchar(255) 
)
BEGIN
	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    
		if(Var_Method_Name = 'GetCrateStock') then 
        
			select Material_Id , Material_Name 
			from m010_material where Org_Id = Var_Org_Id and 
            MaterialType_Id in ('C042231000005','C042231000001')
            and ifnull(Material_Group,'') <> '';
		
        elseif(Var_Method_Name = 'ReturnCrate') then 
        
			set @Year_Id = (select right(left(curdate(),4),(2)));
			SET @ReceivedCrate_Id = '';
			Call USP_Number_Range ('t038_receivedcrate_header', @Year_Id, 'T038', '', @ReceivedCrate_Id );
            
            insert into t038_receivedcrate_header (Org_Id , ReceivedCrate_Id , Dealer_Id , SalesUser_Id , UserType , 
            Is_Approved , Created_On , CreatedBy_Id) value 
            (Var_Org_Id , @ReceivedCrate_Id, Var_Dealer_Id , Var_SalesUser_Id , Var_UserType , 0 , now() , Var_Profile_Id );
		
            
            SET @row_count := extractValue(Var_XMLData,'count(//D/R)');
            
			Set @k := 0;
			WHILE @k < @row_count DO        
				SET @k := @k + 1;
				SET @xpath := concat('//D/R[', @k, ']');
				INSERT INTO t038_receivedcrate_item (Org_Id,ReceivedCrate_Id, Material_Id, MaterialType_Id ,Quantity) VALUES (
					Var_Org_Id,
					@ReceivedCrate_Id,
					extractValue(var_XMLData, concat(@xpath,'/MI')),
                    (select MaterialType_Id from m010_material where Material_Id = extractValue(var_XMLData, concat(@xpath,'/MI')) and 
                    Is_Active = 1 limit 1 ),
                    extractValue(var_XMLData, concat(@xpath,'/MQ'))
				);
                
			END WHILE;
            
			
            select 1 as Result_Id, 'Crate Returned' as Result_Description, '' as Result_Extra_Key;


		elseif(Var_Method_Name = 'CrateHistory') then 

	
		SELECT  t038i.ReceivedCrate_Id , Material_Name, Good_Quantity , Broken_Quantity , ThirdParty_Quantity ,
        date(Created_On)  as Created_On
        FROM t038_receivedcrate_header t038
        inner join t038_receivedcrate_item t038i on t038.Org_Id = t038i.Org_Id and t038.ReceivedCrate_Id = t038i.ReceivedCrate_Id
        inner join m010_material m010 on m010.Org_Id = t038i.Org_Id and t038i.Material_Id = m010.Material_Id;

		
        elseif(Var_Method_Name = 'CrateHistory_V1') then 
        
        begin
        -- divide date range in two variables to get records between those two dates
		DECLARE var_StartDate DATE;
		DECLARE var_EndDate DATE;
		SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(Var_Date, ' - ', 1), '%m/%d/%Y');
		SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(Var_Date, ' - ', -1), '%m/%d/%Y');


		/*
		SELECT  t038i.ReceivedCrate_Id , Material_Name, Good_Quantity , Broken_Quantity , ThirdParty_Quantity ,
        date(t038.Created_On)  as Created_On
        FROM t038_receivedcrate_header t038
        inner join t038_receivedcrate_item t038i on t038.Org_Id = t038i.Org_Id and t038.ReceivedCrate_Id = t038i.ReceivedCrate_Id
        inner join m010_material m010 on m010.Org_Id = t038i.Org_Id 
        and t038i.Material_Id = m010.Material_Id
        and m010.Material_Group =  var_Material_Group
        where t038.Org_Id = Var_Org_Id
        and t038.CreatedBy_Id = Var_Profile_Id
        AND CAST(t038.Created_On AS DATE) >= var_StartDate 
		AND CAST(t038.Created_On AS DATE) <= var_EndDate;
        
        */
        
        SELECT 
			ReceivedCrate_Id,
			Material_Name,
			Good_Quantity AS Good_Quantity,
			Broken_Quantity AS Broken_Quantity,
			ThirdParty_Quantity AS ThirdParty_Quantity,
			Created_On
		FROM (
			SELECT  
				t038i.ReceivedCrate_Id, 
				Material_Name, 
				Good_Quantity, 
				Broken_Quantity, 
				ThirdParty_Quantity,
				DATE(t038.Created_On) AS Created_On
			FROM 
				t038_receivedcrate_header t038
			INNER JOIN 
				t038_receivedcrate_item t038i 
				ON t038.Org_Id = t038i.Org_Id AND t038.ReceivedCrate_Id = t038i.ReceivedCrate_Id
			INNER JOIN 
				m010_material m010 
				ON m010.Org_Id = t038i.Org_Id AND t038i.Material_Id = m010.Material_Id
                and m010.Material_Group =  var_Material_Group
			WHERE 
				m010.Material_Group = var_Material_Group
				AND t038.Org_Id = Var_Org_Id
				AND t038.CreatedBy_Id = Var_Profile_Id
				AND CAST(t038.Created_On AS DATE) >= var_StartDate 
				AND CAST(t038.Created_On AS DATE) <= var_EndDate

			UNION ALL

			SELECT  
				t038i.ReceivedCrate_Id, 
				Material_Name, 
				Good_Quantity, 
				Broken_Quantity, 
				ThirdParty_Quantity,
				DATE(t038.Created_On) AS Created_On
			FROM 
				t038_receivedcrate_header t038
			INNER JOIN 
				t038_receivedcrate_item t038i 
				ON t038.Org_Id = t038i.Org_Id AND t038.ReceivedCrate_Id = t038i.ReceivedCrate_Id
			INNER JOIN 
				m010_material m010 
				ON m010.Org_Id = t038i.Org_Id AND t038i.Material_Id = m010.Material_Id
                and m010.Material_Group =  var_Material_Group
			WHERE 
				m010.Material_Group = var_Material_Group
				AND t038.Org_Id = Var_Org_Id
				AND t038.CreatedBy_Id = Var_Dealer_Id
				AND CAST(t038.Created_On AS DATE) >= var_StartDate 
				AND CAST(t038.Created_On AS DATE) <= var_EndDate
		) AS CombinedResults
		GROUP BY 
			ReceivedCrate_Id, 
			Material_Name, 
            Good_Quantity, 
			Broken_Quantity, 
			ThirdParty_Quantity,
			Created_On;


		end;
        
        elseif(Var_Method_Name = 'CrateHistory_V2') then 
        
        begin
				-- divide date range in two variables to get records between those two dates
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;
				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(Var_Date, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(Var_Date, ' - ', -1), '%m/%d/%Y');

				select
                DATE_FORMAT(f011.Date, '%d %b %Y') AS Date,
				m010.Material_Name as Material,
				ifnull(f011.Opening_Quantity,0) as Opening_Quantity,ifnull(f011.Good_Credit,0) as Good_Credit,
				ifnull(f011.Good_Debit,0) as Good_Debit,ifnull(f011.Broken_Debit,0) as Broken_Debit,
				ifnull(f011.ThirdParty_Debit,0) as ThirdParty_Debit,ifnull(f011.Closing_Quantity,0) as Closing_Quantity
				from f011_dealer_stock f011
				inner join m010_material m010 on
				m010.Org_Id = f011.Org_Id
				and m010.Material_Id = f011.Material_Id
				and m010.Material_Group = var_Material_Group
				where f011.Org_Id =  Var_Org_Id
				and f011.Dealer_Id = Var_Dealer_Id
                AND CAST(f011.Date AS DATE) >= var_StartDate 
				AND CAST(f011.Date AS DATE) <= var_EndDate
                order by m010.Material_Name asc,f011.Date asc;
            
			end;
		elseif(Var_Method_Name = 'CrateHistory_SAP') then 
        
        begin
				-- divide date range in two variables to get records between those two dates
				DECLARE var_StartDate DATE;
				DECLARE var_EndDate DATE;
				SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(Var_Date, ' - ', 1), '%m/%d/%Y');
				SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(Var_Date, ' - ', -1), '%m/%d/%Y');

				select
                DATE_FORMAT(f011.Date, '%d %b %Y') AS Date,
				m010.Material_Name as Material,
				ifnull(f011.Opening_Quantity,0) as Opening_Quantity,ifnull(f011.Good_Credit,0) as Good_Credit,
				ifnull(f011.Good_Debit,0) as Good_Debit,ifnull(f011.Broken_Debit,0) as Broken_Debit,
				ifnull(f011.ThirdParty_Debit,0) as ThirdParty_Debit,ifnull(f011.Closing_Quantity,0) as Closing_Quantity
				from f011_dealer_stock f011
				inner join m010_material m010 on
				m010.Org_Id = f011.Org_Id
				and m010.Material_Id = f011.Material_Id
				and m010.Material_Group = var_Material_Group
                inner join mu08_dealer mu08 on
				mu08.Org_Id = f011.Org_Id
				and mu08.Dealer_Id = f011.Dealer_Id
                and mu08.Dealer_Code = Var_Dealer_Id
				where f011.Org_Id =  Var_Org_Id
                AND CAST(f011.Date AS DATE) >= var_StartDate 
				AND CAST(f011.Date AS DATE) <= var_EndDate
                order by m010.Material_Name asc,f011.Date asc;
            
			end;
		elseif(Var_Method_Name = 'CrateHistoryMonthly') then 
			begin
				
						
				
				DROP TEMPORARY TABLE IF EXISTS temp_dates;

				CREATE TEMPORARY TABLE temp_dates (Date DATE);

				INSERT INTO temp_dates (Date) 
				select Date from f011_dealer_stock f011
				where f011.Org_Id = Var_Org_Id
				and f011.Dealer_Id = Var_Dealer_Id
				and month(f011.Date) = month(Var_Date)
				and year(f011.Date) = year(Var_Date)
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
					WHERE 
					month(Date) = month(Var_Date)
					and year(Date) = year(Var_Date)
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
				and f011.Dealer_Id = Var_Dealer_Id
				and month(f011.Date) = month(Var_Date)
				and year(f011.Date) = year(Var_Date)
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
						f011.Dealer_Id =  Var_Dealer_Id 
						and month(f011.Date) = month(Var_Date)
						and year(f011.Date) = year(Var_Date)
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
					f011.Dealer_Id =  Var_Dealer_Id 
					and month(f011.Date) = month(Var_Date)
					and year(f011.Date) = year(Var_Date);



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
						f011.Dealer_Id =  Var_Dealer_Id 
						and month(f011.Date) = month(Var_Date)
						and year(f011.Date) = year(Var_Date)
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
					f011.Dealer_Id =  Var_Dealer_Id 
					and month(f011.Date) = month(Var_Date)
					and year(f011.Date) = year(Var_Date);



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

				
				select 
				concat(DATE_FORMAT(f011.Start_Date, '%d %b %Y'), ' - ', DATE_FORMAT(f011.End_Date, '%d %b %Y')) AS Date,
				m010.Material_Name as Material,
				ifnull(f011.Opening_Quantity,0) as Opening_Quantity,
				ifnull(f011.Good_Credit,0) as Good_Credit,
				ifnull(f011.Good_Debit,0) as Good_Debit,
				0 as Broken_Debit,
                0 as ThirdParty_Debit,
                ifnull(f011.Closing_Quantity,0) as Closing_Quantity
				from temp_Report_Main f011
				inner join mu08_dealer mu08 on
				mu08.Dealer_Id =  Var_Dealer_Id
				inner join m010_material m010 on
				m010.Material_Id = f011.Material_Id
				and m010.Material_Group = var_Material_Group;
                
            end;
		end if;
				
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
