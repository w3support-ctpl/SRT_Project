-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentCollectionShift_End` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentCollectionShift_End`()
BEGIN

	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    set sql_mode = '';

	drop temporary table if exists temp_tbl;

	create Temporary table temp_tbl(
	id int AUTO_INCREMENT PRIMARY KEY,
	mccid varchar(20),
    colectionshift varchar(20)
    );
    
    insert into temp_tbl(mccid , colectionshift )
    select t004.MCC_Id , t004.MCCCollectionShift_Id from t004_mcccollectionshift t004 
    inner join m005_mcc m005 on m005.Org_Id = t004.Org_Id and t004.MCC_Id = m005.MCC_Id
    where t004.Org_Id = m005.Org_Id and t004.Shift_Status <> 2 and time(Expected_End_Time)  < time(now()) ;
    
update t004_mcccollectionshift 
set Shift_Status = 2 ,
ShiftEnd_Time = now()
where date(Collection_Date) = date(now()) and time(Expected_End_Time)  < time(now()) ;

update f009_mcc_collection 
set Quantity = 0 ,
Amount = 0
where Quantity < 0 ;


		set @RowCount = (select COUNT(*) from temp_tbl);
        
		set @var_Id = 1;

		While @var_Id <= @RowCount Do
        
			SET @row_number = 0; 
                
            DROP TEMPORARY TABLE IF EXISTS temp_data;
			CREATE TEMPORARY TABLE temp_data (PKeyRowNum int, Field_Value text);
            
            set @mccid = (select mccid from temp_tbl where id = @var_Id);
			set @mcccollectionid = (select colectionshift from temp_tbl where id = @var_Id);
            
			select m005.Version_No into @Version_No from m005_mcc_version m005 where MCC_Id = @mccid and Applicable_Date <= now() 
			order by Applicable_Date desc limit 1 ;
            
            
            insert into temp_data(PKeyRowNum , Field_Value)
			select (@row_number := @row_number + 1) , MilkType_Id from m005_mcc_milktype where 
			MCC_ID = @mccid and Version_No = @Version_No ;
                        
			set @RowCnt = (select COUNT(*) from temp_data);

			set @var_CursorTestID = 1;

			While @var_CursorTestID <= @RowCnt Do
            
            set @Field_Value = (select Field_Value from temp_data where PKeyRowNum = @var_CursorTestID );

			if not exists (select 1 from f009_mcc_collection where 
			Mlk_Type = @Field_Value and Entry_Type = 'Closing Bal' and MCCCollectionShift_Id = @mcccollectionid ) then 
            
			insert into f009_mcc_collection (Org_Id, MCCCollectionShift_Id, MCC_Id, Entry_Type, Mlk_Type, Quantity, 
			Fat, Snf, Date , Amount , Rate ) 
			select Org_Id , MCCCollectionShift_Id , MCC_Id, 'Closing Bal' , @Field_Value , Quantity , Fat, Snf , now() , Amount , Rate 
            from f009_mcc_collection where Mlk_Type = @Field_Value and  Date <= now() 
            and Entry_Type in ('Collection 1' , 'Collection 2' )  and MCCCollectionShift_Id = @mcccollectionid
            order by Date desc limit 1;
            
            
            end if;
            
			Set @var_CursorTestID = @var_CursorTestID + 1;

			END WHILE;
            
            Set @var_Id = @var_Id + 1;
            
END WHILE;

-- and MCC_Id in (select MCC_Id from m005_mcc where Is_ManualShiftEnd = 0);

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
