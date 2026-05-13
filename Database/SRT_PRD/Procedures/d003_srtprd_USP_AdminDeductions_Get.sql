-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDeductions_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDeductions_Get`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(20),
    var_User_Id VARCHAR(45),
    var_User_Name VARCHAR(45),
    var_Ledger_Status VARCHAR(10),
    var_Entry_Period VARCHAR(45),
    var_Deductions_Id VARCHAR(45)
)
BEGIN
	SET @Ledger_Status = var_Ledger_Status;
	IF((var_Ledger_Status = '') OR (var_Ledger_Status IS NULL)) THEN
    BEGIN
		SET @Ledger_Status := '0,1';
    END;
    END IF;

	IF(var_Method_Name = 'Get') THEN
    BEGIN
  
		-- If Entry Period is not provided
		IF(var_Entry_Period = '' OR var_Entry_Period = NULL) THEN
        BEGIN
			SELECT dd_header.Org_Id, dd_header.Deductions_Id, 
				DATE_FORMAT(dd_header.Entry_Date,'%d %M %Y') AS Entry_Date, 
				dd_header.Request_User_Type, 
				dd_header.Request_User_Id, 
				m020.DeductionHead_Name as Request_Type, 
				ifnull(dd_header.Total_Amount,0.00) as Total_Amount,
                ifnull(dd_header.Amount_Deducted,0.00) as Amount_Deducted,
                ifnull(dd_header.Balance,0.00) as Balance,
				dd_header.Is_Closed, 
				dd_header.No_Of_Installments,
				IFNULL( 
					CASE dd_header.Request_User_Type
					WHEN 'farmer' THEN farmer.Farmer_Name
					WHEN 'agent' THEN agent.MCC_Name
                    WHEN 'transporter' THEN transporter.Transporter_Name
                    -- WHEN 'mcc' THEN mcc.MCC_Name
					END, '') AS Request_User_Name,
				IFNULL( 
					CASE dd_header.Request_User_Type
					WHEN 'farmer' THEN farmer.Mobile_No
					WHEN 'agent' THEN agent.Mobile_No
                    WHEN 'transporter' THEN transporter.Mobile_No
                    -- WHEN 'mcc' THEN mcc.Mobile_No
					END, '') AS Request_User_Mobile_No,
				IFNULL( 
					CASE dd_header.Request_User_Type
					WHEN 'farmer' THEN (select ifnull(m005.MCC_Name,'') as MCC_Name from m005_mcc m005 where m005.MCC_Id = dd_header.MCC_Id and m005.Org_Id = dd_header.Org_Id limit 1)
					WHEN 'agent' THEN agent.MCC_Name
                    WHEN 'transporter' THEN ''
                    -- WHEN 'mcc' THEN mcc.MCC_Name
					END, '') AS MCC_Name
			FROM t033_deductions_header dd_header
			LEFT JOIN mu04_farmer farmer 
					ON dd_header.Request_User_Type = 'farmer' 
					AND dd_header.Request_User_Id = farmer.Farmer_Id
					and dd_header.Org_Id = farmer.Org_Id
			LEFT JOIN m005_mcc agent 
					ON dd_header.Request_User_Type = 'agent'
					AND dd_header.Request_User_Id = agent.MCC_Id
					and dd_header.Org_Id = agent.Org_Id
			LEFT JOIN m009_transporter transporter 
					ON dd_header.Request_User_Type = 'transporter'
					AND dd_header.Request_User_Id = transporter.Transporter_Id
					and dd_header.Org_Id = transporter.Org_Id
			inner join m020_deductions_head m020 on
					dd_header.Org_Id = m020.Org_Id
                    and dd_header.Request_Type = m020.DeductionHead_Id
                     and dd_header.Request_User_Type = m020.User_Type
			WHERE dd_header.Org_Id = var_Org_Id
			AND FIND_IN_SET(dd_header.Is_Closed, @Ledger_Status)
            ORDER BY dd_header.Entry_Date DESC;
            
			END;
        
        -- If Entry Period is Provided
        ELSE
        BEGIN
        
       
			-- divide date range in two variables to get records between those two dates
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Entry_Period, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Entry_Period, ' - ', -1), '%m/%d/%Y');
    
			SELECT dd_header.Org_Id, dd_header.Deductions_Id, 
				DATE_FORMAT(dd_header.Entry_Date,'%d %M %Y') AS Entry_Date, 
				dd_header.Request_User_Type, 
				dd_header.Request_User_Id, 
				m020.DeductionHead_Name as Request_Type, 
				
                -- dd_header.Total_Amount, dd_header.Amount_Deducted, 
				-- dd_header.Balance,
                ifnull(dd_header.Total_Amount,0.00) as Total_Amount,
                ifnull(dd_header.Amount_Deducted,0.00) as Amount_Deducted,
                ifnull(dd_header.Balance,0.00) as Balance,
                dd_header.Is_Closed, 
				dd_header.No_Of_Installments,
				IFNULL( 
					CASE dd_header.Request_User_Type
					WHEN 'farmer' THEN farmer.Farmer_Name
					WHEN 'agent' THEN agent.MCC_Name
                    WHEN 'transporter' THEN transporter.Transporter_Name
                    -- WHEN 'mcc' THEN mcc.MCC_Name
					END, ''
                    ) AS Request_User_Name,
				IFNULL( 
					CASE dd_header.Request_User_Type
					WHEN 'farmer' THEN farmer.Mobile_No
					WHEN 'agent' THEN agent.Mobile_No
					WHEN 'transporter' THEN transporter.Mobile_No
                    -- WHEN 'mcc' THEN mcc.Mobile_No
					END, '') AS Request_User_Mobile_No,
                    IFNULL( 
					CASE dd_header.Request_User_Type
					WHEN 'farmer' THEN (select ifnull(m005.MCC_Name ,'') as MCC_Name  from m005_mcc m005 where m005.MCC_Id = dd_header.MCC_Id and m005.Org_Id = dd_header.Org_Id limit 1)
					WHEN 'agent' THEN agent.MCC_Name
                    WHEN 'transporter' THEN ''
                    -- WHEN 'mcc' THEN mcc.MCC_Name
					END, '') AS MCC_Name
			FROM t033_deductions_header dd_header
			LEFT JOIN mu04_farmer farmer 
					ON dd_header.Request_User_Type = 'farmer' 
					AND dd_header.Request_User_Id = farmer.Farmer_Id
					and dd_header.Org_Id = farmer.Org_Id
			LEFT JOIN m005_mcc agent 
					ON dd_header.Request_User_Type = 'agent'
					AND dd_header.Request_User_Id = agent.MCC_Id
					and dd_header.Org_Id = agent.Org_Id
			LEFT JOIN m009_transporter transporter 
					ON dd_header.Request_User_Type = 'transporter'
					AND dd_header.Request_User_Id = transporter.Transporter_Id
					and dd_header.Org_Id = transporter.Org_Id
			/*
			LEFT JOIN m005_mcc mcc 
					ON dd_header.Request_User_Type = 'mcc'
					AND dd_header.Request_User_Id = mcc.MCC_Id
					and dd_header.Org_Id = mcc.Org_Id
			*/
			inner join m020_deductions_head m020 on
					dd_header.Org_Id = m020.Org_Id
                    and dd_header.Request_Type = m020.DeductionHead_Id
                     and dd_header.Request_User_Type = m020.User_Type
			WHERE dd_header.Org_Id = var_Org_Id
			AND FIND_IN_SET(dd_header.Is_Closed, @Ledger_Status)
            -- AND CAST(dd_header.Entry_Date AS DATE) >= var_StartDate 
            -- AND CAST(dd_header.Entry_Date AS DATE) <= var_EndDate
            ORDER BY dd_header.Entry_Date DESC;
        
		 END;
       END IF;
    
    END;
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
		SELECT Org_Id, Deductions_Id, 
			DATE_FORMAT(Deduction_Date, '%Y-%m-%d') AS Deduction_Date,
            Deduction_Amount, 
            Is_Deducted
		FROM t033_deductions_item
        WHERE Deductions_Id = var_Deductions_Id
        AND Org_Id = var_Org_Id
        ORDER BY Deduction_Date;
    END;
    ELSEIF(var_Method_Name = 'GetOne') THEN
    BEGIN
		SELECT dd_header.Org_Id, dd_header.Deductions_Id, 
				DATE_FORMAT(dd_header.Entry_Date,'%d %M %Y') AS Entry_Date, 
				dd_header.Request_User_Type, 
				dd_header.Request_User_Id, 
				m020.DeductionHead_Name as Request_Type, 
				dd_header.Total_Amount, dd_header.Amount_Deducted, 
				dd_header.Balance, dd_header.Is_Closed, 
				dd_header.No_Of_Installments,
				IFNULL( 
					CASE dd_header.Request_User_Type
					WHEN 'farmer' THEN farmer.Farmer_Name
					WHEN 'agent' THEN agent.MCC_Name
                    WHEN 'transporter' THEN transporter.Transporter_Name
                    -- WHEN 'mcc' THEN mcc.MCC_Name
					END, ''
                    ) AS Request_User_Name,
				IFNULL( 
					CASE dd_header.Request_User_Type
					WHEN 'farmer' THEN farmer.Mobile_No
					WHEN 'agent' THEN agent.Mobile_No
					WHEN 'transporter' THEN transporter.Mobile_No
                    -- WHEN 'mcc' THEN mcc.Mobile_No
					END, '') AS Request_User_Mobile_No
			FROM t033_deductions_header dd_header
			LEFT JOIN mu04_farmer farmer 
					ON dd_header.Request_User_Type = 'farmer' 
					AND dd_header.Request_User_Id = farmer.Farmer_Id
					and dd_header.Org_Id = farmer.Org_Id
			LEFT JOIN m005_mcc agent 
					ON dd_header.Request_User_Type = 'agent'
					AND dd_header.Request_User_Id = agent.MCC_Id
					and dd_header.Org_Id = agent.Org_Id
			LEFT JOIN m009_transporter transporter 
					ON dd_header.Request_User_Type = 'transporter'
					AND dd_header.Request_User_Id = transporter.Transporter_Id
					and dd_header.Org_Id = transporter.Org_Id
			/*LEFT JOIN m005_mcc mcc 
					ON dd_header.Request_User_Type = 'mcc'
					AND dd_header.Request_User_Id = mcc.MCC_Id
					and dd_header.Org_Id = mcc.Org_Id*/
			inner join m020_deductions_head m020 on
					dd_header.Org_Id = m020.Org_Id
                    and dd_header.Request_Type = m020.DeductionHead_Id
                     and dd_header.Request_User_Type = m020.User_Type
			WHERE dd_header.Org_Id = var_Org_Id
			AND Deductions_Id = var_Deductions_Id
            ORDER BY dd_header.Entry_Date DESC;
    END;
    ELSEIF (var_Method_Name = 'Get_Locked') then  
		begin
			declare Is_Locked varchar(20);
            
			select  
            ifnull(Is_Deducted , 0) into Is_Locked 
            from t033_deductions_item
            where Deductions_Id in (
            select Deductions_Id from t033_deductions_header
            where Org_Id = var_Org_Id
			and Deductions_Id = var_Deductions_Id
            )
            order by Is_Deducted desc
			limit 1;
            
            if(Is_Locked = '' or Is_Locked = null)then
            
            set Is_Locked = 1;
            
            end if ;
            
            select Is_Locked;
            
        end;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
