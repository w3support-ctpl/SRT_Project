-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkRate_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkRate_Get`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_MilkType_Id varchar(20),
    var_MilkStatus_Id varchar(20),
    var_Date varchar(20),
    var_Chart_Id varchar(20),
    var_Chart_Name varchar(20),
    var_CollectionShift_Id varchar(20),
	var_Profile_Id varchar(20),
    Var_MCC_Id varchar(20)
)
BEGIN

	set sql_mode = '';

	if (var_Method_Name = 'Get') then
		begin
			select m001.Org_Id,
            m001.Chart_Id, m001.Chart_Name,
            c011.MilkType_Id, c011.MilkType_Name,
            ifnull(c015.CollectionShift_Id,'') as CollectionShift_Id, 
			ifnull( c015.CollectionShift_Name,'') as CollectionShift_Name,
            c016.MilkStatus_Id, c016.MilkStatus_Name,
            c019.UOM_Id, c019.UOM_Name,
			m001.Is_Active,m001.Is_Deleted,m001.Is_Lived,
            ifnull(m001.Base_Rate,'') as Base_Rate,
            ifnull(m001.Fat_Incentives,'') as Fat_Incentives,
            ifnull(m001.Fat_Deduction,'') as Fat_Deduction,
            ifnull(m001.Snf_Incentives,'') as Snf_Incentives,
            ifnull(m001.Snf_Deduction,'') as Snf_Deduction
            from m001_milkrate m001
            inner join c011_milktype c011 on c011.MilkType_Id = m001.MilkType_Id 
            inner join c015_collectionshift c015 on c015.CollectionShift_Id = m001.CollectionShift_Id 
            inner join c016_milkstatus c016 on c016.MilkStatus_Id = m001.MilkStatus_Id 
            inner join c019_uom c019 on c019.UOM_Id = m001.UOM_Id 
            where m001.Org_Id = var_Org_Id and m001.Is_Deleted = 0 
            and m001.MilkType_Id like var_MilkType_Id
            and m001.MilkStatus_Id like var_MilkStatus_Id
            and Chart_Name like var_Chart_Name
            order by Chart_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id, Chart_Id, Chart_Name, MilkType_Id, MilkStatus_Id, UOM_Id,
            CollectionShift_Id,Is_Active, Is_Deleted ,Is_Lived
            from m001_milkrate 
            where Org_Id = var_Org_Id and Chart_Id = var_Chart_Id 
            and Is_Deleted =0;
		end;
	elseif (var_Method_Name = 'Get_BaseRate') then
		begin
			select MilkType_Id, MilkType_Name, FAT as BaseFat, SNF as BaseSNF, Is_Active, Is_Deleted 
            from c011_milktype 
            where MilkType_Id = var_MilkType_Id
            and Is_Deleted =0;
		end;
	
	elseif(var_Method_Name = 'GetMilkRate') then 
			
		set sql_require_primary_key = 0 ;
		SET SQL_SAFE_UPDATES = 0;
		set @Current_Datetime = (SELECT CONVERT_TZ(Var_Date, '+00:00', '+00:00'));
	
			set @Chart_Id = (
			select mh.Chart_Id from m001_milkrate_mcc_header mh inner join m001_milkrate_mcc_item mi on mh.Org_Id = mi.Org_Id
			and mh.Chart_Id = mi.Chart_Id and mh.Version_No = mi.Version_No
			where mh.Org_Id = var_Org_Id and  MCC_Id = Var_MCC_Id and Applicable_Date <= (@Current_Datetime)
			order by Applicable_Date desc limit 1);
        
		drop temporary table if exists temp_SlabId;
        create temporary table temp_SlabId (Slab_Id varchar(20));
        
        insert into temp_SlabId (Slab_Id)
		select distinct F001.Slab_id
        from f001_milk_rate F001 
		INNER JOIN c012_milkrateentrytype C012 ON IFNULL(C012.MilkRateEntryType_Id,1) = IFNULL(F001.MilkRateEntryType_Id,1)
		INNER JOIN  m014_slab m014 ON m014.Org_Id = F001.Org_Id and ifnull(m014.Slab_Id,'') = ifnull(F001.Slab_Id , '')
		where (Header_Applicable_Date) <= (@Current_Datetime) AND (Item_Applicable_Date) <= (@Current_Datetime)
		and F001.Org_Id = var_Org_Id  AND F001.MCC_Id = Var_MCC_Id and MilkType_Id = var_MilkType_Id 
		and F001.CollectionShift_Id = var_CollectionShift_Id ;
        

		drop temporary table if exists temp_Milkrate;

		create temporary table temp_Milkrate( 
		Org_Id varchar(20) ,  
		Slab_Min varchar(20) ,
		Slab_Max varchar(20) ,
		MilkType_Id varchar(20) ,
		CollectionShift_Id varchar(20) ,
		MilkRateEntryType_Name varchar(20), 
		MilkRateEntryType_Id varchar (20),
		Slab_Id varchar(20),
		Item_Version_No varchar(20),
		Item_Applicable_Date datetime,
		Header_Applicable_Date datetime,
		Chart_Id varchar (20),
		Header_Version_No varchar(10),
        Amount decimal(8,2)
		) ;


		insert into temp_Milkrate (Org_Id , Slab_Min , Slab_Max , MilkType_Id , CollectionShift_Id, MilkRateEntryType_Name , MilkRateEntryType_Id , Slab_Id , 
		Item_Version_No , Item_Applicable_Date , Header_Applicable_Date , Chart_Id , Header_Version_No, Amount)
        
        select F001.Org_Id, m014.Slab_Min AS Slab_Min , m014.Slab_Max AS Slab_Max,  MilkType_Id , CollectionShift_Id , MilkRateEntryType_Name ,  F001.MilkRateEntryType_Id,
		ifnull(F001.Slab_Id , '') as Slab_Id , max(Item_Version_No) ,  max(Item_Applicable_Date)  as Item_Applicable_Date , 
		max(Header_Applicable_Date)  as Header_Applicable_Date , Chart_Id , max(Header_Version_No), Amount
        from f001_milk_rate F001 
		INNER JOIN c012_milkrateentrytype C012 ON IFNULL(C012.MilkRateEntryType_Id,1) = IFNULL(F001.MilkRateEntryType_Id,1)
		Inner JOIN  m014_slab m014 ON m014.Org_Id = F001.Org_Id and m014.Slab_Id = F001.Slab_Id 
		where (Header_Applicable_Date) <= (@Current_Datetime) AND (Item_Applicable_Date) <= (@Current_Datetime)
		and F001.Org_Id = var_Org_Id  AND F001.MCC_Id = Var_MCC_Id and MilkType_Id = var_MilkType_Id 
		and F001.CollectionShift_Id = var_CollectionShift_Id and F001.Chart_Id = @Chart_Id 
		group by F001.Org_Id , Slab_Min ,Slab_Max, MilkType_Id ,CollectionShift_Id ,MilkRateEntryType_Name , 
		F001.Slab_Id , F001.MilkRateEntryType_Id , Chart_Id, Amount;
        
        
		insert into temp_Milkrate (Org_Id , Slab_Min , Slab_Max , MilkType_Id , CollectionShift_Id, MilkRateEntryType_Name , MilkRateEntryType_Id , Slab_Id , 
		Item_Version_No , Item_Applicable_Date , Header_Applicable_Date , Chart_Id , Header_Version_No, Amount)
		select F001.Org_Id, '' AS Slab_Min , '' AS Slab_Max,  MilkType_Id , CollectionShift_Id , MilkRateEntryType_Name ,  F001.MilkRateEntryType_Id,
		'' as Slab_Id , max(Item_Version_No) ,  max(Item_Applicable_Date)  as Item_Applicable_Date , 
		max(Header_Applicable_Date)  as Header_Applicable_Date , Chart_Id , max(Header_Version_No), Amount 
        from f001_milk_rate F001 
		INNER JOIN c012_milkrateentrytype C012 ON IFNULL(C012.MilkRateEntryType_Id,1) = IFNULL(F001.MilkRateEntryType_Id,1)
		where (Header_Applicable_Date) <= (@Current_Datetime) AND (Item_Applicable_Date) <= (@Current_Datetime)
		and F001.Org_Id = var_Org_Id  AND F001.MCC_Id = Var_MCC_Id and MilkType_Id = var_MilkType_Id 
		and F001.CollectionShift_Id = var_CollectionShift_Id and F001.Chart_Id = @Chart_Id and F001.MilkRateEntryType_Id = 'C012001'
		group by F001.Org_Id , Slab_Min ,Slab_Max, MilkType_Id ,CollectionShift_Id ,MilkRateEntryType_Name , 
		F001.Slab_Id , F001.MilkRateEntryType_Id , Chart_Id, Amount
        order by max(Item_Applicable_Date) desc limit 1;
		
        select * from temp_Milkrate;
	elseif (var_Method_Name = 'Get_ChartMCC') then
		begin
			SET SESSION sql_require_primary_key = 0;
			 DROP TEMPORARY TABLE IF EXISTS temp;
				CREATE TEMPORARY TABLE temp (
					Org_Id VARCHAR(10),
					MCC_Id VARCHAR(20),
					CollectionShift_Id VARCHAR(20), 
					MilkType_Id VARCHAR(20), 
					Chart_Id VARCHAR(20),
					Applicable_Date DATETIME
				);
                
                INSERT INTO temp(
					Org_Id, MCC_Id, CollectionShift_Id, 
					MilkType_Id, Chart_Id,Applicable_Date
				)
				  
			 WITH MaxVersion AS (
				 SELECT m001.Org_Id, m001.Chart_Id, MAX(m001.Version_No)AS MaxVersion,m001.Applicable_Date
				 FROM m001_milkrate_mcc_header m001
				 
				 WHERE m001.Applicable_Date <= var_Date AND m001.Org_Id = var_Org_Id
				 GROUP BY m001.Org_Id, m001.Chart_Id,m001.Applicable_Date
			 )
			 
			 select m005.Org_Id,m005.MCC_Id,
			 m0051.CollectionShift_Id,
			 m0053.MilkType_Id,
			 ifnull(m0011.Chart_Id,'') as Chart_Id,
			 mv.Applicable_Date
			from m005_mcc m005 
			inner join m005_mcc_collectionshift m0051 on m0051.Org_Id =  m005.Org_Id
				and m0051.MCC_Id =  m005.MCC_Id
				and m0051.Version_No = (SELECT m0052.Version_No FROM m005_mcc_version m0052
										where m0051.Org_Id =  m0052.Org_Id
										and m0051.MCC_Id =  m0052.MCC_Id
										and m0052.Applicable_Date <= var_Date order by m0052.Applicable_Date desc limit 1)
			inner join m005_mcc_milktype m0053 on m0053.Org_Id =  m005.Org_Id
				and m0053.MCC_Id =  m005.MCC_Id
				and m0053.Version_No = (SELECT m0052.Version_No FROM m005_mcc_version m0052
										where m0053.Org_Id =  m0052.Org_Id
										and m0053.MCC_Id =  m0052.MCC_Id
										and m0052.Applicable_Date <= var_Date order by m0052.Applicable_Date desc limit 1)

			inner join MaxVersion mv ON m005.Org_Id = mv.Org_Id        
			inner join m001_milkrate_mcc_header m0012 on m0012.Org_Id =  m005.Org_Id
				and m0012.Version_No = mv.MaxVersion
				and m0012.Chart_Id = mv.Chart_Id   
			inner join m001_milkrate_mcc_item m0011 on m0011.Org_Id =  m005.Org_Id
				and m0011.MCC_Id =  m005.MCC_Id
				and m0011.Version_No = m0012.Version_No
				and m0011.Chart_Id = m0012.Chart_Id
			inner join m001_milkrate m001 
            on m0011.Org_Id =  m001.Org_Id
				and m0011.Chart_Id = m001.Chart_Id
                and m0051.CollectionShift_Id = m001.CollectionShift_Id
			where 
			m005.Org_Id =var_Org_Id
			and m005.MCCType_Id = Var_MCC_Id order by m005.MCC_Id,  mv.Applicable_Date desc;

			DROP TEMPORARY TABLE IF EXISTS temp2;
			CREATE TEMPORARY TABLE temp2 SELECT * FROM temp;
            
            DROP TEMPORARY TABLE IF EXISTS temp3;
            CREATE TEMPORARY TABLE temp3 (
					Org_Id VARCHAR(10),
					MCC_Id VARCHAR(20),
					CollectionShift_Id VARCHAR(20), 
					MilkType_Id VARCHAR(20), 
					Chart_Id VARCHAR(20),
					Applicable_Date DATETIME
				);
			INSERT INTO temp3(
					Org_Id, MCC_Id, CollectionShift_Id, 
					MilkType_Id, Chart_Id,Applicable_Date
				)
			select Org_Id ,MCC_Id ,CollectionShift_Id , MilkType_Id ,Chart_Id,Applicable_Date 
			from temp t1
			where Applicable_Date = (select max(t2.Applicable_Date) from temp2 t2
										where  t1.Org_Id = t2.Org_Id
											and t1.MCC_Id = t2.MCC_Id
											and t1.CollectionShift_Id = t2.CollectionShift_Id
											and t1.MilkType_Id = t2.MilkType_Id
											 -- and t1.Chart_Id = t2.Chart_Id
											);
                                            
				select 
				m005.MCC_Id,m005.MCC_Name,
				m001.Chart_Id,concat(m001.Chart_Name, '<br>Vaild From ',DATE_FORMAT(Applicable_Date, '%d %b %Y %h:%i %p')) as Chart_Name,
				c015.CollectionShift_Id,c015.CollectionShift_Name,
				c011.MilkType_Id,c011.MilkType_Name
				from temp3 t3
				inner join m005_mcc m005 on t3.Org_Id = m005.Org_Id and t3.MCC_Id = m005.MCC_Id
				inner join m001_milkrate m001 on t3.Org_Id = m001.Org_Id 
                and t3.Chart_Id = m001.Chart_Id
				inner join c015_collectionshift c015 on 
                t3.CollectionShift_Id = c015.CollectionShift_Id
				inner join c011_milktype c011 on 
                t3.MilkType_Id = c011.MilkType_Id
                and m001.MilkType_Id = c011.MilkType_Id
                order by m005.MCC_Name
				;
                 
		end;
		elseif(var_Method_Name = 'GetMilkRateChart') then 
        begin
        
        /*
        select 
		m001.Org_Id ,
		ifnull(m014.Slab_Min,'') as Slab_Min, ifnull(m014.Slab_Max,'') as Slab_Max,
		m001.MilkType_Id,
		m001.CollectionShift_Id ,
		c012.MilkRateEntryType_Name ,
		c012.MilkRateEntryType_Id,
		ifnull(m0011.Slab_Id,'')Slab_Id, 
		'' as Item_Version_No,
		'' as Item_Applicable_Date,
		'' as Header_Applicable_Date,
		m001.Chart_Id,
		'' as Header_Version_No,
		m0011.Amount
		from m001_milkrate m001
		inner join m001_milkrate_item m0011 on m001.Org_Id = m0011.Org_Id
			and m001.Chart_Id = m0011.Chart_Id
			and m0011.Is_Active = 1
			and m0011.Applicable_Date <= now()
		left join m014_slab m014 on m0011.Org_Id = m014.Org_Id
			and m0011.Slab_Id = m014.Slab_Id
		inner join c012_milkrateentrytype c012 on c012.MilkRateEntryType_Id = m0011.MilkRateEntryType_Id
		where m001.Org_Id  = var_Org_Id
		and m001.Chart_Id  = Var_MCC_Id
		order by c012.MilkRateEntryType_Name;
        
        */
		set @Current_Datetime = (SELECT CONVERT_TZ(Var_Date, '+00:00', '+00:00'));
        
        
			select  m001.Org_Id , m001.MilkType_Id,
			m001.CollectionShift_Id , c012.MilkRateEntryType_Name , c012.MilkRateEntryType_Id,
			m001.Chart_Id, m0011.Amount, m0011.Applicable_Date , BaseFat , BaseSNF
			into @Org_Id , @MilkType_Id, @CollectionShift_Id , @MilkRateEntryType_Name , @MilkRateEntryType_Id,
			@Chart_Id, @Amount, @Applicable_Date , @BaseFat , @BaseSNF
			from m001_milkrate m001
			inner join m001_milkrate_item m0011 on m001.Org_Id = m0011.Org_Id and m001.Chart_Id = m0011.Chart_Id and m0011.Is_Active = 1
			-- and m0011.Applicable_Date <= now()
            and date(m0011.Applicable_Date) <= date(@Current_Datetime)
			left join m014_slab m014 on m0011.Org_Id = m014.Org_Id and m0011.Slab_Id = m014.Slab_Id
			inner join c012_milkrateentrytype c012 on c012.MilkRateEntryType_Id = m0011.MilkRateEntryType_Id        
			where m0011.MilkRateEntryType_Id = 'C012001' and m001.Chart_Id = Var_MCC_Id and m001.Org_Id = var_Org_Id
			order by m0011.Applicable_Date desc
			limit 1 ;
	
    
    
			select @Org_Id as Org_Id, '' as Slab_Min , '' as Slab_Max ,  @BaseFat as basefat  , @BaseSNF  as basesnf ,
			@MilkType_Id as MilkType_Id, @CollectionShift_Id as CollectionShift_Id , @MilkRateEntryType_Name as MilkRateEntryType_Name , 
			@MilkRateEntryType_Id as MilkRateEntryType_Id , '' as Slab_Id ,  @Chart_Id as Chart_Id , CAST(ifnull(@Amount, 0) AS DECIMAL(8, 2)) as Amount , @Applicable_Date as Applicable_Date , '' as Header_Version_No, '' as Item_Version_No, '' as Item_Applicable_Date, '' as Header_Applicable_Date

			union all
    
			select  m001.Org_Id , ifnull(m014.Slab_Min,'') as Slab_Min, ifnull(m014.Slab_Max,'') as Slab_Max, '' as basefat  , ''  as basesnf ,
            m001.MilkType_Id,
			m001.CollectionShift_Id , c012.MilkRateEntryType_Name , c012.MilkRateEntryType_Id, ifnull(m0011.Slab_Id,'') as Slab_Id, 
			m001.Chart_Id, CAST(ifnull(m0011.Amount, 0) AS DECIMAL(8, 2)) as Amount , m0011.Applicable_Date, '' as Header_Version_No, '' as Item_Version_No, '' as Item_Applicable_Date, '' as Header_Applicable_Date
			from m001_milkrate m001
			inner join m001_milkrate_item m0011 on m001.Org_Id = m0011.Org_Id and m001.Chart_Id = m0011.Chart_Id and m0011.Is_Active = 1
			-- and m0011.Applicable_Date <= now()
            and date(m0011.Applicable_Date) <= date(@Current_Datetime)
			left join m014_slab m014 on m0011.Org_Id = m014.Org_Id and m0011.Slab_Id = m014.Slab_Id
			inner join c012_milkrateentrytype c012 on c012.MilkRateEntryType_Id = m0011.MilkRateEntryType_Id
			inner join ( select 
			m001.Org_Id ,
			ifnull(m014.Slab_Min,'') as Slab_Min, ifnull(m014.Slab_Max,'') as Slab_Max,
			m001.MilkType_Id,
			m001.CollectionShift_Id ,
			c012.MilkRateEntryType_Name ,
			c012.MilkRateEntryType_Id,
			ifnull(m0011.Slab_Id,'') as Slab_Id, 
			m001.Chart_Id,
			m0011.Amount,
			max(m0011.Applicable_Date) as Date 
			from m001_milkrate m001
			inner join m001_milkrate_item m0011 on m001.Org_Id = m0011.Org_Id
			and m001.Chart_Id = m0011.Chart_Id
			and m0011.Is_Active = 1
			-- and m0011.Applicable_Date <= now()
            and date(m0011.Applicable_Date) <= date(@Current_Datetime)
			left join m014_slab m014 on m0011.Org_Id = m014.Org_Id
			and m0011.Slab_Id = m014.Slab_Id
			inner join c012_milkrateentrytype c012 on c012.MilkRateEntryType_Id = m0011.MilkRateEntryType_Id 
			where m001.Org_Id  = var_Org_Id
			and m001.Chart_Id  = Var_MCC_Id
			group by m001.Org_Id ,m014.Slab_Min , m014.Slab_Max ,
			m001.MilkType_Id,
			m001.CollectionShift_Id ,
			c012.MilkRateEntryType_Name ,
			c012.MilkRateEntryType_Id,
			m0011.Slab_Id,
			m001.Chart_Id
			order by c012.MilkRateEntryType_Name
			) maxslab on maxslab.Org_Id = m001.Org_Id and maxslab.Slab_Min = m014.Slab_Min and maxslab.Slab_Max = m014.Slab_Max 
			and m001.MilkType_Id = maxslab.MilkType_Id and m0011.Applicable_Date = maxslab.Date 
			and maxslab.Slab_Id = m0011.Slab_Id
			where m001.Org_Id  = var_Org_Id
			and m001.Chart_Id  = Var_MCC_Id ;
				
                

                
        end;
     end if ;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
