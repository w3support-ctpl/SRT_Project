-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminDispatchStock_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminDispatchStock_Get`(
	var_Org_Id VARCHAR(20),
    var_Method_Name VARCHAR(20),
    var_User_Id VARCHAR(45),
    var_User_Name VARCHAR(45),
	var_Entry_Period VARCHAR(45),
	var_DispatchStock_Id VARCHAR(45),
    var_MCC_Id VARCHAR(45),
    var_Approval_Status VARCHAR(45)
)
BEGIN
	SET @Approval_Status = var_Approval_Status;
	IF((var_Approval_Status = '') OR (var_Approval_Status IS NULL)) THEN
    BEGIN
		SET @Approval_Status := '0,1,-1';
    END;
    END IF;

	IF(var_Method_Name = 'Get') THEN
    BEGIN
		-- If Entry Period is not provided
		IF(var_Entry_Period = '' OR var_Entry_Period = NULL) THEN
        BEGIN
			SELECT d_header.Org_Id, d_header.Dispatchstock_Id, 
				mcc.MCC_Id, mcc.MCC_Name, 
				agent.Agent_Id, agent.Agent_Name,
                agent.Mobile_No,
				d_header.Is_Dairy_Accepted,
                DATE_FORMAT(d_header.Dispatched_On,'%d %M %Y') AS Dispatched_On,
				d_header.Is_Active, d_header.Is_Deleted, 
				d_header.Created_On, d_header.Created_By, 
				d_header.LastEdited_On, d_header.LastEdited_By,
				d_header.Approval_Remarks, 
                DATE_FORMAT(d_header.Approved_On, '%d %M %Y') AS Approved_On,
				d_header.Approved_Id, d_header.Approved_Name,
                COUNT(d_item.Dispatchstock_Id) AS Total_Quantity
            FROM t032_dispatchstock_header d_header
            LEFT JOIN m005_mcc mcc 
				ON mcc.MCC_Id = d_header.MCC_Id 
				AND d_header.Org_Id = mcc.Org_Id
            LEFT JOIN mu05_agent agent 
				ON agent.Agent_Id = d_header.Agent_Id 
                AND d_header.Org_Id = agent.Org_Id
            LEFT JOIN t032_dispatchstock_item d_item 
				ON d_header.Dispatchstock_Id = d_item.Dispatchstock_Id
                AND d_header.Org_Id = d_item.Org_Id
            WHERE d_header.Org_Id = var_Org_Id
			AND FIND_IN_SET(d_header.Is_Dairy_Accepted, @Approval_Status)
            AND d_header.MCC_Id LIKE var_MCC_Id
            
            GROUP BY
				d_header.Org_Id, d_header.Dispatchstock_Id, 
				mcc.MCC_Id, mcc.MCC_Name, 
				agent.Agent_Id, agent.Agent_Name, agent.Mobile_No,
				d_header.Is_Dairy_Accepted, d_header.Dispatched_On, 
				d_header.Is_Active, d_header.Is_Deleted, 
				d_header.Created_On, d_header.Created_By, 
				d_header.LastEdited_On, d_header.LastEdited_By,
				d_header.Approval_Remarks, d_header.Approved_On, 
				d_header.Approved_Id, d_header.Approved_Name
            
            ORDER BY d_header.Dispatched_On DESC;
        END;
        ELSE
        BEGIN
			-- divide date range in two variables to get records between those two dates
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Entry_Period, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Entry_Period, ' - ', -1), '%m/%d/%Y');
    
			SELECT d_header.Org_Id, d_header.Dispatchstock_Id, 
				mcc.MCC_Id, mcc.MCC_Name, 
				agent.Agent_Id, agent.Agent_Name, agent.Mobile_No,
				d_header.Is_Dairy_Accepted, 
                DATE_FORMAT(d_header.Dispatched_On,'%d %M %Y') AS Dispatched_On, 
				d_header.Is_Active, d_header.Is_Deleted, 
				d_header.Created_On, d_header.Created_By, 
				d_header.LastEdited_On, d_header.LastEdited_By,
				d_header.Approval_Remarks,
                DATE_FORMAT(d_header.Approved_On, '%d %M %Y') AS Approved_On,
				d_header.Approved_Id, d_header.Approved_Name,
				COUNT(d_item.Dispatchstock_Id) AS Total_Quantity
            FROM t032_dispatchstock_header d_header
            LEFT JOIN m005_mcc mcc 
				ON mcc.MCC_Id = d_header.MCC_Id 
				AND d_header.Org_Id = mcc.Org_Id
            LEFT JOIN mu05_agent agent 
				ON agent.Agent_Id = d_header.Agent_Id 
                AND d_header.Org_Id = agent.Org_Id
			LEFT JOIN t032_dispatchstock_item d_item 
				ON d_header.Dispatchstock_Id = d_item.Dispatchstock_Id
                AND d_header.Org_Id = d_item.Org_Id
            WHERE d_header.Org_Id = var_Org_Id
			AND FIND_IN_SET(d_header.Is_Dairy_Accepted, @Approval_Status)
            AND d_header.MCC_Id LIKE var_MCC_Id
            AND CAST(d_header.Dispatched_On AS DATE) >= var_StartDate 
            AND CAST(d_header.Dispatched_On AS DATE) <= var_EndDate
            
            GROUP BY
				d_header.Org_Id, d_header.Dispatchstock_Id, 
				mcc.MCC_Id, mcc.MCC_Name, 
				agent.Agent_Id, agent.Agent_Name, 
				d_header.Is_Dairy_Accepted, d_header.Dispatched_On, 
				d_header.Is_Active, d_header.Is_Deleted, 
				d_header.Created_On, d_header.Created_By, 
				d_header.LastEdited_On, d_header.LastEdited_By,
				d_header.Approval_Remarks, d_header.Approved_On, 
				d_header.Approved_Id, d_header.Approved_Name
            
            ORDER BY d_header.Dispatched_On DESC;
        END;
        END IF;
    END;
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
		SELECT d_item.Org_Id, d_item.DispatchStock_Id, 
            d_item.Stock_Type, 
            d_item.Dispatched_Quantity, 
            IFNULL( 
					CASE d_item.Stock_Type
					WHEN 'Material' THEN material.Material_Id
					WHEN 'Product' THEN product.Product_Id
					END, ''
                    ) AS Material_Id,
				IFNULL( 
					CASE d_item.Stock_Type
					WHEN 'Material' THEN material.Material_Name
					WHEN 'Product' THEN product.Product_Name
					END, ''
                    ) AS Material_Name
		FROM t032_dispatchstock_item d_item
        LEFT JOIN m010_material material 
			ON material.Material_Id = d_item.Material_Id
			AND material.Org_Id = d_item.Org_Id
		LEFT JOIN m017_product product 
			ON product.Product_Id = d_item.Material_Id
			AND product.Org_Id = d_item.Org_Id
        WHERE d_item.Org_Id = var_Org_Id
        AND d_item.DispatchStock_Id = var_DispatchStock_Id;
    END;
    END IF;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:24
