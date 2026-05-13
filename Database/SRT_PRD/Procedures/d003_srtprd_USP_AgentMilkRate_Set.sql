-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentMilkRate_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentMilkRate_Set`(
	var_Method_Name varchar(50),
	var_Org_Id varchar(20),
    var_Chart_Id varchar(20),
	var_MCC_Id varchar(20),
    var_MilkType_Id varchar(20),
    var_CollectionShift_Id varchar(20),
    var_BaseFat varchar(20),
    var_BaseSNF varchar(20),
    var_Amount varchar(20),
    var_SlabData longtext,
    var_User_Id VARCHAR(45),
    var_User_Name longtext
)
BEGIN
	if (var_Method_Name = 'Create') then
		begin
			Declare New_Chart_Id varchar(20);
			Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
            
            set @Current_Datetime = (SELECT CONVERT_TZ(var_User_Name, '+00:00', '+00:00'));
            
            set Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('m001_milk_rate_offline_mcc_header', Year_Id, 'M001', '', New_Chart_Id );
			
			Insert Into m001_milk_rate_offline_mcc_header(
			Org_Id,Chart_Id,MCC_Id,MilkType_Id,CollectionShift_Id,
			Is_Active,Is_Deleted,
			Created_On,CreatedBy_Id,CreatedBy_Name
			)
			value(
			var_Org_Id,New_Chart_Id,var_MCC_Id,var_MilkType_Id,var_CollectionShift_Id,
			1,0,
			@Current_Datetime,var_User_Id,var_User_Name
			);
                    
			
			Call USP_Number_Range ('m001_milk_rate_offline_mcc_base', Year_Id, 'M001A', '', New_Entry_Id );
			
			Insert Into m001_milk_rate_offline_mcc_base(
			Org_Id,Entry_Id,Chart_Id,
			BaseFat,BaseSNF,Amount,
			Is_Active,Is_Deleted,
			Created_On,CreatedBy_Id,CreatedBy_Name
			)
			value(
			var_Org_Id,New_Entry_Id,New_Chart_Id,
			var_BaseFat,var_BaseSNF,var_Amount,
			1,0,
			@Current_Datetime,var_User_Id,var_User_Name
			);
            
            delete from m001_milk_rate_offline_mcc_slab
			where Org_Id = var_Org_Id
			and Chart_Id = New_Chart_Id;

            SET row_count := extractValue(var_SlabData,'count(//Slabs/SlabData)');
			WHILE k < row_count DO
				SET k := k + 1;
				
                SET xpath := concat('//Slabs/SlabData[', k, ']');
                
                set New_Entry_Id ='';
				
				
                if(extractValue(var_SlabData, concat(xpath,'/Slab')) != var_BaseFat
                and 
                extractValue(var_SlabData, concat(xpath,'/Slab')) != var_BaseSNF)then
                
                Call USP_Number_Range ('m001_milk_rate_offline_mcc_slab', Year_Id, 'M001B', '', New_Entry_Id );
			
					Insert Into m001_milk_rate_offline_mcc_slab(
					Org_Id,Entry_Id,Chart_Id,Slab_Type,
					Slab_Min,
					-- Slab_Max,
					Amount,
					Is_Active,Is_Deleted,
					Created_On,CreatedBy_Id,CreatedBy_Name
					)
					value(
					var_Org_Id,New_Entry_Id,New_Chart_Id,
					extractValue(var_SlabData, concat(xpath,'/Type')),
					extractValue(var_SlabData, concat(xpath,'/Slab')),
					-- extractValue(var_SlabData, concat(xpath,'/Slab')),
					extractValue(var_SlabData, concat(xpath,'/SlabAmt')),
					1,0,
					@Current_Datetime,var_User_Id,var_User_Name
					);
                
                end if;
                
                
                
                
			END WHILE;
            
            /*
            DROP TEMPORARY TABLE IF EXISTS temp_Report_FAT;
			CREATE TEMPORARY TABLE temp_Report_FAT ( 
			Slab_Min varchar(20),Slab_Max varchar(20));


			insert into temp_Report_FAT (Slab_Min,Slab_Max)
			WITH SlabData AS (
				SELECT 
					Slab_Min,
					LEAD(Slab_Min) OVER (ORDER BY Slab_Min ASC) AS Next_Slab_Min
				FROM 
					m001_milk_rate_offline_mcc_slab 
				WHERE 
					Org_Id = var_Org_Id
					AND Chart_Id = New_Chart_Id
                    and Slab_Type = 'FAT'
				ORDER BY 
					Slab_Min ASC
			)
			SELECT
				Slab_Min AS Slab_Min,
				Next_Slab_Min AS Slab_Max
			FROM
				SlabData
			WHERE
				Next_Slab_Min IS NOT NULL
			ORDER BY
				Slab_Min ASC;
			
            
            Update m001_milk_rate_offline_mcc_slab m001
            inner join  temp_Report_FAT tmp on
            m001.Slab_Min = tmp.Slab_Min
            and m001.Slab_Max = tmp.Slab_Min
			set 
			m001.Slab_Max = tmp.Slab_Max
			where m001.Org_Id = var_Org_Id
			and m001.Chart_Id = New_Chart_Id
            and m001.Slab_Type = 'FAT';
            
            DROP TEMPORARY TABLE IF EXISTS temp_Report_SNF;
			CREATE TEMPORARY TABLE temp_Report_SNF ( 
			Slab_Min varchar(20),Slab_Max varchar(20));


			insert into temp_Report_SNF (Slab_Min,Slab_Max)
			WITH SlabData AS (
				SELECT 
					Slab_Min,
					LEAD(Slab_Min) OVER (ORDER BY Slab_Min ASC) AS Next_Slab_Min
				FROM 
					m001_milk_rate_offline_mcc_slab 
				WHERE 
					Org_Id = var_Org_Id
					AND Chart_Id = New_Chart_Id
                    and Slab_Type = 'SNF'
				ORDER BY 
					Slab_Min ASC
			)
			SELECT
				Slab_Min AS Slab_Min,
				Next_Slab_Min AS Slab_Max
			FROM
				SlabData
			WHERE
				Next_Slab_Min IS NOT NULL
			ORDER BY
				Slab_Min ASC;
                
			
            Update m001_milk_rate_offline_mcc_slab m001
            inner join  temp_Report_SNF tmp on
            m001.Slab_Min = tmp.Slab_Min
            and m001.Slab_Max = tmp.Slab_Min
			set 
			m001.Slab_Max = tmp.Slab_Max
			where m001.Org_Id = var_Org_Id
			and m001.Chart_Id = New_Chart_Id
            and m001.Slab_Type = 'SNF';
            
            
			Update m001_milk_rate_offline_mcc_slab 
			set 
			Is_Active = 0,
            Is_Deleted = 1
			where Org_Id = var_Org_Id
			and Chart_Id = New_Chart_Id
            and Slab_Min = Slab_Max;
            
            */
			
			SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			New_Chart_Id AS Result_Extra_Key;
            
            
        end;
	elseif (var_Method_Name = 'Update') then
		begin
			Declare Year_Id varchar(10);
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;
			Declare New_Entry_Id varchar(20);
            
            set Year_Id = (select right(left(curdate(),4),(2)));
			set @Current_Datetime = (SELECT CONVERT_TZ(var_User_Name, '+00:00', '+00:00'));
            
			
            Update m001_milk_rate_offline_mcc_header
			set 
			MilkType_Id = var_MilkType_Id,
			CollectionShift_Id = var_CollectionShift_Id,
            Created_On = @Current_Datetime,
			LastEdited_On = now(),
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and Chart_Id = var_Chart_Id;
            
			Update m001_milk_rate_offline_mcc_base
			set 
			BaseFat = var_BaseFat,
			BaseSNF = var_BaseSNF,
			Amount = var_Amount,
            Created_On = @Current_Datetime,
			LastEdited_On = now(),
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id
			and Chart_Id = var_Chart_Id;
		
			delete from m001_milk_rate_offline_mcc_slab
			where Org_Id = var_Org_Id
			and Chart_Id = var_Chart_Id;
			
            SET row_count := extractValue(var_SlabData,'count(//Slabs/SlabData)');
			WHILE k < row_count DO
				SET k := k + 1;
				
                SET xpath := concat('//Slabs/SlabData[', k, ']');
                
                set New_Entry_Id ='';
				
				if(extractValue(var_SlabData, concat(xpath,'/Slab')) != var_BaseFat
                and 
                extractValue(var_SlabData, concat(xpath,'/Slab')) != var_BaseSNF)then
                
                Call USP_Number_Range ('m001_milk_rate_offline_mcc_slab', Year_Id, 'M001B', '', New_Entry_Id );
			
					Insert Into m001_milk_rate_offline_mcc_slab(
					Org_Id,Entry_Id,Chart_Id,Slab_Type,
					Slab_Min,
					-- Slab_Max,
					Amount,
					Is_Active,Is_Deleted,
					Created_On,CreatedBy_Id,CreatedBy_Name
					)
					value(
					var_Org_Id,New_Entry_Id,var_Chart_Id,
					extractValue(var_SlabData, concat(xpath,'/Type')),
					extractValue(var_SlabData, concat(xpath,'/Slab')),
					-- extractValue(var_SlabData, concat(xpath,'/Slab')),
					extractValue(var_SlabData, concat(xpath,'/SlabAmt')),
					1,0,
					@Current_Datetime,var_User_Id,var_User_Name
					);
                
                end if;
                
		   
			END WHILE;
            /*
            DROP TEMPORARY TABLE IF EXISTS temp_Report_FAT;
			CREATE TEMPORARY TABLE temp_Report_FAT ( 
			Slab_Min varchar(20),Slab_Max varchar(20));


			insert into temp_Report_FAT (Slab_Min,Slab_Max)
			WITH SlabData AS (
				SELECT 
					Slab_Min,
					LEAD(Slab_Min) OVER (ORDER BY Slab_Min ASC) AS Next_Slab_Min
				FROM 
					m001_milk_rate_offline_mcc_slab 
				WHERE 
					Org_Id = var_Org_Id
					AND Chart_Id = var_Chart_Id
                    and Slab_Type = 'FAT'
				ORDER BY 
					Slab_Min ASC
			)
			SELECT
				Slab_Min AS Slab_Min,
				Next_Slab_Min AS Slab_Max
			FROM
				SlabData
			WHERE
				Next_Slab_Min IS NOT NULL
			ORDER BY
				Slab_Min ASC;
                
			
            Update m001_milk_rate_offline_mcc_slab m001
            inner join  temp_Report_FAT tmp on
            m001.Slab_Min = tmp.Slab_Min
            and m001.Slab_Max = tmp.Slab_Min
			set 
			m001.Slab_Max = tmp.Slab_Max
			where m001.Org_Id = var_Org_Id
			and m001.Chart_Id = var_Chart_Id
            and m001.Slab_Type = 'FAT';
            
            DROP TEMPORARY TABLE IF EXISTS temp_Report_SNF;
			CREATE TEMPORARY TABLE temp_Report_SNF ( 
			Slab_Min varchar(20),Slab_Max varchar(20));


			insert into temp_Report_SNF (Slab_Min,Slab_Max)
			WITH SlabData AS (
				SELECT 
					Slab_Min,
					LEAD(Slab_Min) OVER (ORDER BY Slab_Min ASC) AS Next_Slab_Min
				FROM 
					m001_milk_rate_offline_mcc_slab 
				WHERE 
					Org_Id = var_Org_Id
					AND Chart_Id = var_Chart_Id
                    and Slab_Type = 'SNF'
				ORDER BY 
					Slab_Min ASC
			)
			SELECT
				Slab_Min AS Slab_Min,
				Next_Slab_Min AS Slab_Max
			FROM
				SlabData
			WHERE
				Next_Slab_Min IS NOT NULL
			ORDER BY
				Slab_Min ASC;
                
			
            Update m001_milk_rate_offline_mcc_slab m001
            inner join  temp_Report_SNF tmp on
            m001.Slab_Min = tmp.Slab_Min
            and m001.Slab_Max = tmp.Slab_Min
			set 
			m001.Slab_Max = tmp.Slab_Max
			where m001.Org_Id = var_Org_Id
			and m001.Chart_Id = var_Chart_Id
            and m001.Slab_Type = 'SNF';
            
            
			Update m001_milk_rate_offline_mcc_slab 
			set 
			Is_Active = 0,
            Is_Deleted = 1
			where Org_Id = var_Org_Id
			and Chart_Id = var_Chart_Id
            and Slab_Min = Slab_Max;
			
            */
            
            set @var_Created_On = (select date(Created_On) from m001_milk_rate_offline_mcc_header
						where Org_Id =var_Org_Id
						and Chart_Id = var_Chart_Id
						and MCC_Id =var_MCC_Id limit 1);
                        
			set @var_MilkType_Id = (select MilkType_Id from m001_milk_rate_offline_mcc_header
									where Org_Id =var_Org_Id
									and Chart_Id = var_Chart_Id
									and MCC_Id =var_MCC_Id limit 1);


			update t103_milkcollectionfarmer_offline
			set ApplicableRate =  GetOffline_milk_rate_Farmer(Org_Id,MCC_Id,Farmer_Id,MilkType_Id,date(Created_On),Fat,SNF)
			where Org_Id =var_Org_Id
			and MCC_Id =var_MCC_Id
			and date(Created_On) >= date(@var_Created_On)
			and MilkType_Id = @var_MilkType_Id 
			and ifnull(Is_InvoiceCreated ,0)  = 0
			and MilkStatus_Id = 'C016001'
			and Farmer_Id in (
								select Farmer_Id 
								from m001_milk_rate_offline_mcc_farmer 
								where Org_Id =var_Org_Id
								and Chart_Id = var_Chart_Id
								and MCC_Id =var_MCC_Id );
								
			update t103_milkcollectionfarmer_offline
			set Amount = ApplicableRate * Quantity_Ltr
			where Org_Id =var_Org_Id
			and MCC_Id =var_MCC_Id
			and date(Created_On) >= date(@var_Created_On)
			and MilkType_Id = @var_MilkType_Id 
			and ifnull(Is_InvoiceCreated ,0)  = 0
			and MilkStatus_Id = 'C016001'
			and Farmer_Id in (
								select Farmer_Id 
								from m001_milk_rate_offline_mcc_farmer 
								where Org_Id =var_Org_Id
								and Chart_Id = var_Chart_Id
								and MCC_Id =var_MCC_Id );
            
            SELECT 1 AS Result_Id, 
			'Updated' AS Result_Description, 
			var_Chart_Id AS Result_Extra_Key;
            
        end;
     elseif (var_Method_Name = 'Delete') then
		begin
			
            Update m001_milk_rate_offline_mcc_header
			set 
			Is_Active = 0,
			Is_Deleted = 1,
			LastEdited_On = now(),
			LastEditedBy_Id = var_User_Id,
			LastEditedBy_Name = var_User_Name
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and Chart_Id = var_Chart_Id;
                    
            SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Chart_Id AS Result_Extra_Key;
            
        end;   
	elseif (var_Method_Name = 'Get') then
		begin
			
            select 
			m001.Chart_Id,
			-- ifnull(date_format(m001.Created_On, '%d %M %Y'),'') as Created_On,
            ifnull(date_format(m001.Created_On, '%d %b %Y %h:%i %p'),'') as Created_On,
			c011.MilkType_Name,
			m0011.Amount
			from m001_milk_rate_offline_mcc_header  m001
			inner join m001_milk_rate_offline_mcc_base m0011 on
			m001.Org_Id = m0011.Org_Id
			and m001.Chart_Id = m0011.Chart_Id
			inner join c011_milktype c011 on
			c011.MilkType_Id = m001.MilkType_Id
			where m001.Org_Id = var_Org_Id
			and m001.MCC_Id = var_MCC_Id;

            
        end; 
	elseif (var_Method_Name = 'Get_Farmer') then
		begin
			
            
            
            
            
            DROP TEMPORARY TABLE IF EXISTS Farmer_Data;

			CREATE TEMPORARY TABLE Farmer_Data (
				Org_Id VARCHAR(20),
				Farmer_Id VARCHAR(20),
				Chart_Id VARCHAR(20),
				Chart_Name longtext
			);

			INSERT INTO Farmer_Data (Org_Id,Farmer_Id, Chart_Id, Chart_Name)
			select 
			m001i.Org_Id,
			m001i.Farmer_Id,m001i.Chart_Id ,
			concat('Milk Type: ',ifnull(c011.MilkType_Name,'') , ' \nDate: ', ifnull(date_format(m001.Created_On, '%d %b %Y'),'') ,' Rate: ₹', ifnull(m001ii.Amount,'')) as Chart_Name
			from m001_milk_rate_offline_mcc_farmer m001i
			inner join m001_milk_rate_offline_mcc_header m001 on
			m001.Org_Id = m001i.Org_Id
			and m001.Chart_Id = m001i.Chart_Id
			and m001.MCC_Id = m001i.MCC_Id
			inner join m001_milk_rate_offline_mcc_base m001ii on
			m001.Org_Id = m001ii.Org_Id
			and m001.Chart_Id = m001ii.Chart_Id
			inner join c011_milktype c011 on
			c011.MilkType_Id = m001.MilkType_Id
			where m001i.Org_Id = var_Org_Id
			and m001i.MCC_Id = var_MCC_Id;



			select 
			ifnull(mu04.Farmer_Id,'') as Farmer_Id,concat('[ ', ifnull(mu04.MCC_Farmer_Code,'') , ' ] ',  ifnull(mu04.Farmer_Name,'')) as Farmer_Name ,
			ifnull(fd.Chart_Id,'') as Chart_Id, ifnull(fd.Chart_Name,'') as Chart_Name
			from mu04_farmer mu04
			left join Farmer_Data fd on
			fd.Org_Id = mu04.Org_Id
			and fd.Farmer_Id = mu04.Farmer_Id
			where mu04.Org_Id = var_Org_Id
			and mu04.MCC_Id = var_MCC_Id
			and mu04.Is_Offline = 1;

            
        end; 
	elseif (var_Method_Name = 'Get_RateChart') then
		begin
			select 
            ifnull(m001.Chart_Id,'') as Chart_Id,
			concat('Milk Type: ',ifnull(c011.MilkType_Name,'') , 'Date: ', ifnull(date_format(m001.Created_On, '%d %b %Y'),'') ,' Rate: ', ifnull(m0011.Amount,'')) Chart_Name
			from m001_milk_rate_offline_mcc_header m001
			inner join m001_milk_rate_offline_mcc_base m0011 on
			m001.Org_Id = m0011.Org_Id
			and m001.Chart_Id = m0011.Chart_Id
			inner join c011_milktype c011 on
			c011.MilkType_Id = m001.MilkType_Id
			where m001.Org_Id = var_Org_Id
			and m001.MCC_Id = var_MCC_Id;
        end;
	elseif (var_Method_Name = 'Create_Farmer') then
		begin
        
			delete from m001_milk_rate_offline_mcc_farmer 
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
			and Farmer_Id = var_User_Id;
            
			insert into m001_milk_rate_offline_mcc_farmer(Org_Id,Chart_Id,MCC_Id,Farmer_Id) 
			value(var_Org_Id,var_Chart_Id,var_MCC_Id,var_User_Id);
            
            
            set @var_Created_On = (select date(Created_On) from m001_milk_rate_offline_mcc_header
									where Org_Id =var_Org_Id
									and Chart_Id = var_Chart_Id
									and MCC_Id =var_MCC_Id limit 1);
									
			set @var_MilkType_Id = (select MilkType_Id from m001_milk_rate_offline_mcc_header
									where Org_Id =var_Org_Id
									and Chart_Id = var_Chart_Id
									and MCC_Id =var_MCC_Id limit 1);


			update t103_milkcollectionfarmer_offline
			set ApplicableRate =  GetOffline_milk_rate_Farmer(Org_Id,MCC_Id,Farmer_Id,MilkType_Id,date(Created_On),Fat,SNF)
			where Org_Id =var_Org_Id
			and MCC_Id =var_MCC_Id
			and date(Created_On) >= date(@var_Created_On)
			and MilkType_Id = @var_MilkType_Id 
			and ifnull(Is_InvoiceCreated ,0)  = 0
			and MilkStatus_Id = 'C016001'
			and Farmer_Id in (
								select Farmer_Id 
								from m001_milk_rate_offline_mcc_farmer 
								where Org_Id =var_Org_Id
								and Chart_Id = var_Chart_Id
								and MCC_Id =var_MCC_Id );
								
			update t103_milkcollectionfarmer_offline
			set Amount = ApplicableRate * Quantity_Ltr
			where Org_Id =var_Org_Id
			and MCC_Id =var_MCC_Id
			and date(Created_On) >= date(@var_Created_On)
			and MilkType_Id = @var_MilkType_Id 
			and ifnull(Is_InvoiceCreated ,0)  = 0
			and MilkStatus_Id = 'C016001'
			and Farmer_Id in (
								select Farmer_Id 
								from m001_milk_rate_offline_mcc_farmer 
								where Org_Id =var_Org_Id
								and Chart_Id = var_Chart_Id
								and MCC_Id =var_MCC_Id );
            
            
              SELECT 1 AS Result_Id, 
			'"Rate chart applied successfully' AS Result_Description, 
			var_Chart_Id AS Result_Extra_Key;
            
        end;
	elseif (var_Method_Name = 'Get_One') then
		begin
        
			set @MilkType_Id = (select MilkType_Id from m001_milk_rate_offline_mcc_header m001
            where m001.Org_Id = var_Org_Id
			and m001.Chart_Id = var_Chart_Id limit 1);
        
			select 
			m001.BaseFat,
			m001.BaseSNF,
			m001.Amount as BaseAmount,
			'FAT' as Slab_Type,
			m001.BaseFat  as SlabValue,
			0.00 as SlabAmount,
            @MilkType_Id as MilkType_Id
			from m001_milk_rate_offline_mcc_base m001
			where m001.Org_Id = var_Org_Id
			and m001.Chart_Id = var_Chart_Id

			UNION ALL

			select 
			m001.BaseFat,
			m001.BaseSNF,
			m001.Amount as BaseAmount,
			'FAT' as Slab_Type,
			m001.BaseFat  as SlabValue,
			0.00 as SlabAmount,
            @MilkType_Id as MilkType_Id
			from m001_milk_rate_offline_mcc_base m001
			where m001.Org_Id = var_Org_Id
			and m001.Chart_Id = var_Chart_Id
            
            UNION ALL
            
            
            select 
			m001.BaseFat,
			m001.BaseSNF,
			m001.Amount as BaseAmount,
			'SNF' as Slab_Type,
			m001.BaseSNF  as SlabValue,
			0.00 as SlabAmount,
            @MilkType_Id as MilkType_Id
			from m001_milk_rate_offline_mcc_base m001
			where m001.Org_Id = var_Org_Id
			and m001.Chart_Id = var_Chart_Id

			UNION ALL

			select 
			m001.BaseFat,
			m001.BaseSNF,
			m001.Amount as BaseAmount,
			'SNF' as Slab_Type,
			m001.BaseSNF  as SlabValue,
			0.00 as SlabAmount,
            @MilkType_Id as MilkType_Id
			from m001_milk_rate_offline_mcc_base m001
			where m001.Org_Id = var_Org_Id
			and m001.Chart_Id = var_Chart_Id
            
            UNION ALL
			
            select 
			m001.BaseFat,
			m001.BaseSNF,
			m001.Amount as BaseAmount,
			m0011.Slab_Type ,
			m0011.Slab_Min  as SlabValue,
			m0011.Amount as SlabAmount,
            @MilkType_Id as MilkType_Id
			from m001_milk_rate_offline_mcc_base m001
			inner join m001_milk_rate_offline_mcc_slab m0011 on
			m001.Org_Id = m0011.Org_Id
			and m001.Chart_Id = m0011.Chart_Id
			where m001.Org_Id = var_Org_Id
			and m001.Chart_Id = var_Chart_Id
            
            ORDER BY SlabValue, Slab_Type;

            
        end; 
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
