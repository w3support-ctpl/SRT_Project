-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDispatchStock_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDispatchStock_Set`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(20),
    var_User_Id VARCHAR(45),
    var_User_Name VARCHAR(45),
	var_Approval_Remarks LONGTEXT,
	var_DispatchStock_Id VARCHAR(45),
    var_ApprovalStatus_Id INT
)
BEGIN
	IF(var_Method_Name = 'Update') THEN
    BEGIN
		set @Current_Datetime  = now();
        
		UPDATE t032_dispatchstock_header
        SET Is_Dairy_Accepted = var_ApprovalStatus_Id,
			Approval_Remarks = var_Approval_Remarks,
			Approved_On = NOW(),
			Approved_Id = var_User_Id,
            Approved_Name = var_User_Name
        WHERE Org_Id = var_Org_Id
        AND DispatchStock_Id = var_DispatchStock_Id;
        
        set @Balance = ( select ifnull(Balance,0) from f006_mccstocks 
					where Material_Id = 'M010241000020' 
                    and Org_Id = var_Org_Id
						and  MCC_Id in (select MCC_Id from t032_dispatchstock_header where Org_Id = var_Org_Id  and Dispatchstock_Id = var_DispatchStock_Id)
						and Date < @Current_Datetime 
						order by Date desc limit 1);
                        
		
		
		if(@Balance is null or @Balance ='')then
			set @Balance = 0;
		end if;
        
        
       
        insert into f006_mccstocks (Org_Id , MCC_Id , Material_Id , Date , Opening_Quantity , Credit , Debit , Balance  )
		select 
		t032.Org_Id,t032.MCC_Id,t032i.Material_Id,@Current_Datetime as Date ,@Balance as Opening_Quantity,0 as Credit,sum(ifnull(Dispatched_Quantity,0)) as Debit,0 as Balance
		From t032_dispatchstock_header t032
		inner join t032_dispatchstock_item t032i on
		t032i.Org_Id = t032.Org_Id 
		and t032i.Dispatchstock_Id = t032.Dispatchstock_Id 
		and t032i.Material_Id = 'M010241000020'
		where t032.Org_Id = var_Org_Id
		-- and t032.MCC_Id = 'M005241000001'
		and t032.Is_Dairy_Accepted = 1
        and t032.Dispatchstock_Id = var_DispatchStock_Id
		-- and date(t032.Dispatched_On) = date(now())
		group by t032.Org_Id,t032.MCC_Id,t032i.Material_Id;
        
        
        update f006_mccstocks f006
		set
		-- f006.Opening_Quantity = A.Balance,
		f006.Balance = (f006.Credit - f006.Debit)  + f006.Opening_Quantity
        where f006.Org_Id = var_Org_Id
        and f006.Date = @Current_Datetime
        and f006.MCC_Id  in (select MCC_Id from t032_dispatchstock_header where Org_Id = var_Org_Id and Is_Dairy_Accepted = 1 and Dispatchstock_Id = var_DispatchStock_Id);

       
        
        
        IF(var_ApprovalStatus_Id = 1) THEN
        BEGIN
			SELECT 1 AS Result_Id, 
			'Approved' AS Result_Description, 
			var_DispatchStock_Id AS Result_Extra_Key;
        END;
        ELSEIF(var_ApprovalStatus_Id = -1) THEN
        BEGIN
			SELECT 1 AS Result_Id, 
			'Rejected' AS Result_Description, 
			var_DispatchStock_Id AS Result_Extra_Key;
        END;
        ELSE
        BEGIN
			SELECT -1 AS Result_Id, 
			'Failed' AS Result_Description, 
			var_DispatchStock_Id AS Result_Extra_Key;
        END;
        END IF;
    END;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
