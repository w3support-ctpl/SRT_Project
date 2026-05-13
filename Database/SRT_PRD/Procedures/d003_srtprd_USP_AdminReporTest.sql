-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminReporTest` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminReporTest`(
	IN `var_org_id` VARCHAR(10),
	IN `var_Method_Name` VARCHAR(20),
	IN `var_Report_Type` VARCHAR(50),
	IN `var_MCCType_Id` text,
	IN `var_ReportPeriod` VARCHAR(50),
	IN `var_MCCCollectionShift_Id` text,
	IN `var_MilkType_Id` text,
	IN `var_MCC_Id` text,
    IN var_MCCWorkType_Id text
    
)
BEGIN

SET SQL_SAFE_UPDATES = 0;
SET @var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', 1), '%m/%d/%Y');
SET @var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_ReportPeriod, ' - ', -1), '%m/%d/%Y');

					drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCType_Id, ''));

					drop temporary table if exists temp_MCCType;
					create temporary table temp_MCCType(MCCType_Id char(255) );
					set @sql = concat('insert into temp_MCCType (MCCType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt1 from @sql;
					execute stmt1;

                    
                    -- Split MCCWorkType
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCWorkType_Id, ''));

					drop temporary table if exists temp_MCCWorkType;
					create temporary table temp_MCCWorkType(MCCWorkType_Id char(255) );
					set @sql = concat('insert into temp_MCCWorkType (MCCWorkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
					prepare stmt1 from @sql;
					execute stmt1;
                    
                    -- Split MCC Name
                    drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCC_Id, ''));
                    
					drop temporary table if exists temp_MCC;
					create temporary table temp_MCC(MCC_Id char(255) );
                    if (ifnull(var_MCC_Id, '') <> '') then
						set @sql4 = concat('insert into temp_MCC (MCC_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt4 from @sql4;
						execute stmt4;
                    else
						insert into temp_MCC (MCC_Id)
                        select MCC_Id from m005_mcc where Org_Id = var_org_id and Is_Active = 1
                        and MCCType_Id in (Select MCCType_Id from temp_MCCType)
                        and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType);
						-- and CollectionShift_Id in (Select CollectionShift_Id from temp_CollectionShift);
                    end if;
                    
                    
					drop temporary table if exists t;
					create temporary table t( txt text );
					insert into t values(ifnull(var_MCCCollectionShift_Id, ''));
                    
					drop temporary table if exists temp_CollectionShift;
					create temporary table temp_CollectionShift(CollectionShift_Id char(255) );
                    if (ifnull(var_MCCCollectionShift_Id, '') <> '') then
						set @sql3 = concat('insert into temp_CollectionShift (CollectionShift_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt3 from @sql3;
						execute stmt3;
                    else
						insert into temp_CollectionShift (CollectionShift_Id)
                        select CollectionShift_Id from c015_collectionshift;
                    end if;


						drop temporary table if exists t;
						create temporary table t( txt text );
						insert into t values(ifnull(var_MilkType_Id, ''));

						drop temporary table if exists temp_MilkType;
						create temporary table temp_MilkType(MilkType_Id char(255) );
						set @sql2 = concat('insert into temp_MilkType (MilkType_Id) values (\'', replace(( select group_concat(distinct txt) as data from t), ',', '\'),(\''),'\');');
						prepare stmt2 from @sql2;
						execute stmt2;


		drop temporary table if exists tbldate;
		create temporary table tbldate( 
		date text,
        id int 
		);
        
        set @id = 0;
        
        
insert into tbldate(date , id)

SELECT DATE_ADD('2024-02-25', INTERVAL n DAY) AS date , @id:=  @id + 1
FROM (
    SELECT n FROM (
        SELECT 
            @row := @row + 1 AS n
        FROM
            (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t,
            (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2,
            (SELECT @row := 0) r
    ) n
) dates
WHERE DATE_ADD('2024-02-25', INTERVAL n DAY) <= '2024-03-03';
        
		drop temporary table if exists tbldate1;
		create temporary table tbldate1( 
		mcc_code text , 
		mcc_name text,
		mccid text
		);
            
		insert into tbldate1 ( mcc_code ,  mcc_name) value ('MCC_CODE' , 'Mcc_Name');
        
	
       SET @row_number = 0;
       
        set @COUNT = (select COUNT(*) FROM tbldate );
                    
			while  @row_number < @COUNT DO
             
			set @cname = (select date from tbldate where id = ( @COUNT - @row_number));
                        
			SET @sql = CONCAT('ALTER TABLE tbldate1 ADD COLUMN ', '`' ,  @cname , '`', ' VARCHAR(255)');
            
            
                        
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
            
            -- replace((select date from tbldate where id = @row_number ), '''' , '"')
             set @row_number = @row_number + 1;
			
             set @MCC_CODE = 'MCC_CODE';
                          
             SET @sqla = CONCAT('update tbldate1 set ' , '`' , @cname  , '`' , ' = ''' ,  @cname , 
				''' where mcc_code = ''' , @MCC_CODE , '''' );
                
                
			PREPARE stmta FROM @sqla;
			EXECUTE stmta;
			DEALLOCATE PREPARE stmta;

			END WHILE ;
        
		drop temporary table if exists T;
		create temporary table T( 
		mcc_id text ,
        id int ,
        mcc_code text,
        mcc_name text ,
        mcc_type text ,
        mcc_worktype text
		);
		
       set @idz= 0;
	
 
        insert into T(mcc_id , id , mcc_name , mcc_code , mcc_type ,  mcc_worktype ) 
        select MCC_Id , @idz:=  @idz + 1  , MCC_Name , MCC_Code , MCCType_Id , MCCWorkType_Id
        from m005_mcc WHERE Is_Active = 1
		and MCCType_Id in (Select MCCType_Id from temp_MCCType)
       and MCC_Id in  (select MCC_ID FROM temp_MCC ) 
		and MCCWorkType_Id in (Select MCCWorkType_Id from temp_MCCWorkType) ;
        


        SET @row_number = 0;
       
       SET @sql = '';
       
        set @COUNT = (select COUNT(*) FROM T );
            
			while  @row_number < @COUNT DO
             set @row_number = @row_number + 1;
             
				set @mccid = (select mcc_id from T where id = @row_number );
                set @mcc_type = (select mcc_type from T where id = @row_number );
                set @mcc_worktype = (select mcc_worktype from T where id = @row_number );
             
					SET @row_number1 = 0;

					SET @sql1 = '';
                    
					set @COUNT1 = (select COUNT(*) FROM tbldate );

					while  @row_number1 < @COUNT1 DO
					set @row_number1 = @row_number1 + 1;

					set @Ndate = (select date from tbldate where id =  @row_number1 );
                    
                    
			if ( @mcc_type in ('C014001' , 'C014002 ') and @mcc_worktype = 'C023002' ) then
			            
				set @collection = (select sum(Quantity_Ltr) from t005_milkcollectionfarmer a
                inner join t004_mcccollectionshift b on a.MCCCollectionShift_Id = b.MCCCollectionShift_Id where 
				a.MCC_Id =  @MccId  and date(a.Created_On) = date(@Ndate) and MilkType_Id in (select MilkType_Id 
                from temp_MilkType ) and  b.CollectionShift_Id in (select CollectionShift_Id from temp_CollectionShift )
				);
			
			ELSE 
				
                set @collection = (select sum(Agent_Quantity_Ltr) from f010_milkcollectionmcc_final where 
				MCC_Id =  @MccId  and date(Collection_Date) = date(@Ndate) and MilkType_Id in (select MilkType_Id 
                from temp_MilkType ) and  ifnull(CollectionShift_Id , 'C015003') in (select CollectionShift_Id from temp_CollectionShift ));
            
			End if ;
                    
                    
                   if( @collection is null or  @collection = '') then
					
                    set  @collection = 0;
                    
                   end if ;
                   
	
				if exists (select 1 from tbldate1 where mccid = @mccid  ) then 
				
				SET @sql = CONCAT('update tbldate1 set ' , '`' , @Ndate , '`' , ' = ' ,  @collection , 
				' where mccid = ''' , @MccId , '''' );
					
                    else 
                    
                    set @mcc_code = (select mcc_code  from T where mcc_id = @MccId ) ;
                    set @mcc_name = (select mcc_name  from T where mcc_id = @MccId ) ;
                    
					SET @sql = CONCAT('insert into tbldate1 (mcc_code , mcc_name ,  mccid , `' ,  @Ndate , '` ) value ' , '( ''' , 
					@mcc_code , ''' , '''  ,  @mcc_name , ''' , ''' ,
					@MccId  , '''' , ' , ''' ,'' ,  @collection , ''' )' );
                     
                     
                     
                     end if;
					                                
					PREPARE stmt FROM @sql;
					EXECUTE stmt;
					DEALLOCATE PREPARE stmt;

					END WHILE ;

			END WHILE ;
            
			ALTER TABLE tbldate1
			DROP COLUMN MCCID;

            
        select * from tbldate1;
		
        drop temporary table if exists tbldate1;

	

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
