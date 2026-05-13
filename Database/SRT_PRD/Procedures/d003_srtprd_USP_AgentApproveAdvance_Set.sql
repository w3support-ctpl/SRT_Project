-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentApproveAdvance_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentApproveAdvance_Set`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Advance_Id Varchar(20),
Var_Profile_Id varchar(20),
Var_Amount decimal(8,2),
Var_Installment int,
Var_Approve int,
var_XMLData longtext 
)
BEGIN
set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	If (Var_Method_Name = 'ApproveAdvance') then
		
		update t015_advance 
        set Is_Approved = Var_Approve,
        Approved_Amount = Var_Amount,
        Installment = Var_Installment,
        Approved_On = @Current_Datetime,
        Approved_By = Var_Profile_Id,
        LastEdited_On =  @Current_Datetime,
        LastEditedBy_Id = Var_Profile_Id
        where Org_Id = Var_Org_Id  and Advance_Id = Var_Advance_Id;
		
        if (Var_Approve = 1) then
			select 1 as Result_Id, 'Advance Approved' as Result_Description, '' as Result_Extra_Key;  
		else 
			select 1 as Result_Id, 'Advance Rejected' as Result_Description, '' as Result_Extra_Key;  
		end if;
	
    
    elseif (Var_Method_Name = 'AddDeduction') then
    
        SET @row_count := extractValue(var_XMLData,'count(//D/R)');
			Set @k := 0;
			WHILE @k < @row_count DO        
				SET @k := @k + 1;
				SET @xpath := concat('//D/R[', @k, ']');

                set @Current_Datetime = date(extractValue(var_XMLData, concat(@xpath,'/DD')));

                set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = Var_MCC_Id and is_deleted = 0 and 
                Applicable_Date <= @Current_Datetime and Org_Id = Var_Org_Id
                order by Applicable_Date desc limit 1 ) ;

                Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );


                if(@MusterType = 1)then 

                    Set @MusterCycle_StartDate = @Current_Datetime;
                    set @MusterCycle_EndDate =  @Current_Datetime;

                elseif(@MusterType = 7) then 
                    
                    if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 7 ) then
                    
                        Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-01');
                        set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-07');
                    
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 8 AND 14) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-08');
                    set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-14');

                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 15 AND 21) then
                    
                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-15');
                    set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-21');
                    
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 31) then
                    
                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-16');
                    set @MusterCycle_EndDate =  LAST_DAY(@Current_Datetime);

                end if;
                    
                elseif(@MusterType = 15) then 
                    
                    if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 15 ) then
                    
                        Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-01');
                        set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-15');
                    
                    else 
                        Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-16');
                        set @MusterCycle_EndDate =  LAST_DAY(@Current_Datetime);
                    
                    end if;
                    
                elseif(@MusterType = 5) then 
                    
                    if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 5 ) then
                    
                        Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-01');
                        set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-05');
                    
                elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 6 AND 10) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-06');
                    set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-10');

                elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 15) then
                    
                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-11');
                    set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-15');
                    
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 16 AND 20 ) then
                    
                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-16');
                    set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-20');
                    
                elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 25 ) then
                    
                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-21');
                    set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-25');

                elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 26 AND 31 ) then
                    
                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-16');
                    set @MusterCycle_EndDate =  LAST_DAY(@Current_Datetime);

                end if;

                elseif(@MusterType = 10) then 
                    
                    if (DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 1 AND 10 ) then
                    
                        Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-01');
                        set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-10');
                    
                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 11 AND 20) then

                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-11');
                    set @MusterCycle_EndDate =  DATE_FORMAT(@Current_Datetime, '%Y-%m-20');

                    elseif(DATE_FORMAT(@Current_Datetime, '%d') BETWEEN 21 AND 31) then
                    
                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-21');
                    set @MusterCycle_EndDate =  LAST_DAY(@Current_Datetime);

                end if;

                elseif(@MusterType = 30) then 
                    
                    Set @MusterCycle_StartDate = DATE_FORMAT(@Current_Datetime, '%Y-%m-01');
                    set @MusterCycle_EndDate =  LAST_DAY(@Current_Datetime);
                    
                end if;
                
            if exists( select 1 from t033_deductions_header where Org_Id = Var_Org_Id and Advance_Id = 
            extractValue(var_XMLData, concat(@xpath,'/AI'))
            ) then 
                
                SET @DeductionId = (select Deductions_Id from t033_deductions_header
                where Org_Id = Var_Org_Id and Advance_Id = 
                extractValue(var_XMLData, concat(@xpath,'/AI')) limit 1 );
                
                set @Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('t033_deductions_item', @Year_Id, 'T033A', '', @New_Id );
            
				update t033_deductions_header
				set Amount_Deducted = Amount_Deducted + extractValue(var_XMLData, concat(@xpath,'/DA')) ,
                Balance = Balance - extractValue(var_XMLData, concat(@xpath,'/DA'))
                where Org_Id = Var_Org_Id and Deductions_Id = @DeductionId; 
                
                
                INSERT INTO t033_deductions_item (
                Org_Id,Entry_Id, Deductions_Id, Deduction_Date, Deduction_Amount, Is_Deducted, 
                MusterCycle_StartDate, MusterCycle_EndDate) VALUE 
                (Var_Org_Id ,@New_Id, @DeductionId , extractValue(var_XMLData, concat(@xpath,'/DD')) , 
                extractValue(var_XMLData, concat(@xpath,'/DA')) , 0 , @MusterCycle_StartDate ,
                @MusterCycle_EndDate ) ;
                
                
			else 
					
                set @Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('t033_deductions_header', @Year_Id, 'T033', '', @New_Id );
                
                set @Request_For_User_Id = (Select Request_For_User_Id from 
                t015_advance where Org_Id = Var_Org_Id and Advance_Id = extractValue(var_XMLData, concat(@xpath,'/AI')) limit 1 );
                
                set @Request_For = (Select Request_For from 
                t015_advance where Org_Id = Var_Org_Id and Advance_Id = extractValue(var_XMLData, concat(@xpath,'/AI')) limit 1 );
                
                insert into t033_deductions_header(
                Org_Id, Deductions_Id, Advance_Id, Entry_Date, Request_User_Type, Request_User_Id, 
                MCC_Id, Request_Type, Total_Amount, Amount_Deducted, Balance, Is_Closed, 
                No_Of_Installments, CreatedBy_Id ) value 
                (Var_Org_Id , @New_Id , extractValue(var_XMLData, concat(@xpath,'/AI')) ,
                now() , @Request_For ,  @Request_For_User_Id , Var_MCC_Id , 'M020231000012' , 
                extractValue(var_XMLData, concat(@xpath,'/BA')), 
                0
                , 
                extractValue(var_XMLData, concat(@xpath,'/BA')) , 0 , 1, Var_Profile_Id
                );

                Call USP_Number_Range ('t033_deductions_item', @Year_Id, 'T033A', '', @New_Id_Item );
			
                
                INSERT INTO t033_deductions_item (
                Org_Id,Entry_Id, Deductions_Id, Deduction_Date, Deduction_Amount, Is_Deducted, 
                MusterCycle_StartDate, MusterCycle_EndDate) VALUE 
                (Var_Org_Id ,@New_Id_Item,  @New_Id , extractValue(var_XMLData, concat(@xpath,'/DD')) , 
                extractValue(var_XMLData, concat(@xpath,'/DA')) , 0 , @MusterCycle_StartDate ,
                @MusterCycle_EndDate ) ;
                
                
                
                update t033_deductions_header
				set Amount_Deducted = Amount_Deducted + extractValue(var_XMLData, concat(@xpath,'/DA')) ,
                 Balance = Balance - extractValue(var_XMLData, concat(@xpath,'/DA'))
                where Org_Id = Var_Org_Id and Deductions_Id = @New_Id; 
				
                
                end if;
                
                
			END WHILE;
            
            select 1 as Result_Id, 'Deduction Added' as Result_Description, '' as Result_Extra_Key;  
        
        
    end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
