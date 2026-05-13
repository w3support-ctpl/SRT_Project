-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminIssueStocks_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminIssueStocks_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_IssueStocks_Id varchar(20),
    var_Route_Id varchar(20),
    var_CollectionShift_Id varchar(20),
    var_IssueStock_Type varchar(20),
    var_MCC_Id varchar(20),
    var_Date varchar(40),
    var_Search_Id varchar(20)
)
BEGIN
	DECLARE var_StartDate DATE;
	DECLARE var_EndDate DATE;
            
	SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
    SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');

            
	if (var_Method_Name = 'GetCans') then  
		begin
       
			-- Declare Current_Datetime datetime;
			-- set Current_Datetime = CAST(CONVERT_TZ(NOW(), '+00:00', '+00:00') AS DATE);

			SELECT issueheader.Org_Id,	issueheader.IssueStocks_Id, issueheader.Is_DriverAccepted, issueheader.Is_Accepted,
				issueheader.Is_Active, issueheader.Is_Deleted, issueheader.Driver_Id, issueheader.Driver_Name,
				m003.Vehicle_Id, 
                m003.Vehicle_No as Vehicle_Number,
				IFNULL(shift.CollectionShift_Id,'') AS CollectionShift_Id, IFNULL(shift.CollectionShift_Name,'') AS CollectionShift_Name,
				IFNULL(route.Route_Id,'') AS Route_Id, IFNULL(route.Route_Name,'') AS Route_Name,
				IFNULL(mcc.MCC_Id,'') AS MCC_Id, ifnull(mcc.MCC_Name,'') as MCC_Name,
				date_format(issueheader.Created_On, '%Y-%m-%d') as IssueDate
			FROM t018_issuestocks_header issueheader
			LEFT JOIN m006_route route ON route.Route_Id = issueheader.Route_Id
				and route.Org_Id = issueheader.Org_Id
			LEFT JOIN c015_collectionshift shift ON shift.CollectionShift_Id = issueheader.CollectionShift_Id
			left JOIN m005_mcc mcc ON mcc.MCC_Id = issueheader.MCC_Id
				and mcc.Org_Id = issueheader.Org_Id
			left JOIN m003_vehicle m003 ON m003.Vehicle_Id = issueheader.Vehicle_Id
				and m003.Org_Id = issueheader.Org_Id
			WHERE issueheader.Org_Id = var_Org_Id
			AND issueheader.Is_Deleted = 0
			-- AND CAST(issueheader.Created_On AS DATE) =  Current_Datetime
            AND CAST(issueheader.Created_On AS DATE) >= var_StartDate
            AND CAST(issueheader.Created_On AS DATE) <= var_EndDate
            and issueheader.Vehicle_Id LIKE var_Search_Id
			AND issueheader.StockIssue_Type = var_IssueStock_Type     
			ORDER BY issueheader.IssueStock_Date DESC;
            
			
	end;
    elseif (var_Method_Name = 'GetMaterial') then  
		begin
			
			SELECT issueheader.Org_Id,	issueheader.IssueStocks_Id, issueheader.Is_DriverAccepted,
                issueheader.Is_Accepted, issueheader.Is_Active, issueheader.Is_Deleted, issueheader.Driver_Id, issueheader.Driver_Name,
				issueheader.Vehicle_Id, issueheader.Vehicle_Number, 
                IFNULL(issueheader.Mobile_No, '') AS DriverMobile_No,
				IFNULL(shift.CollectionShift_Id,'') AS CollectionShift_Id, IFNULL(shift.CollectionShift_Name,'') AS CollectionShift_Name,
				IFNULL(route.Route_Id,'') AS Route_Id, IFNULL(route.Route_Name,'') AS Route_Name,
				IFNULL(mcc.MCC_Id,'') AS MCC_Id, ifnull(mcc.MCC_Name,'') as MCC_Name,
				DATE_FORMAT(issueheader.Created_On, '%Y-%m-%d') as Created_On,
                DATE_FORMAT(issueheader.Created_On, '%d %M %Y') as IssueDate
			FROM t018_issuestocks_header issueheader
			LEFT JOIN m006_route route ON route.Route_Id = issueheader.Route_Id
				and route.Org_Id = issueheader.Org_Id
			LEFT JOIN c015_collectionshift shift ON shift.CollectionShift_Id = issueheader.CollectionShift_Id
			left JOIN m005_mcc mcc ON mcc.MCC_Id = issueheader.MCC_Id
				and mcc.Org_Id = issueheader.Org_Id
			WHERE issueheader.Org_Id = var_Org_Id
			AND issueheader.Is_Deleted = 0
			AND CAST(issueheader.Created_On AS DATE) >= var_StartDate
            AND CAST(issueheader.Created_On AS DATE) <= var_EndDate
            AND issueheader.MCC_Id LIKE var_Search_Id
			AND issueheader.StockIssue_Type = var_IssueStock_Type     
			ORDER BY issueheader.IssueStock_Date DESC;
            
	end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			if(var_IssueStock_Type = 'Cans') THEN
            BEGIN
			SELECT issueitem.Org_Id, 
				mcc.MCC_Id, mcc.MCC_Name, mcc.MCC_Code,
				material.Material_Id, material.Material_Name,
               IFNULL(issueitem.Quantity, 0) AS Quantity
			FROM t019_issuestocks_item issueitem
			INNER JOIN m005_mcc mcc ON mcc.MCC_Id = issueitem.MCC_Id
				and mcc.Org_Id = issueitem.Org_Id
			INNER JOIN m010_material material ON material.material_id = issueitem.material_id
				and material.Org_Id = issueitem.Org_Id
			WHERE issueitem.Org_Id = var_Org_Id
			AND issueitem.IssueStocks_Id = var_IssueStocks_Id
			ORDER BY mcc.MCC_Name;
            END;
            ELSE
            -- for Material
            BEGIN
				
                 SELECT 
                orderitem.Org_Id, orderitem.Order_Id, 
                IFNULL(material.Material_Id, product.Product_Id) AS Material_Id, 
                IFNULL(material.Material_Name, product.Product_Name) AS Material_Name,
                -- IFNULL(product.Product_Id, '') AS Product_Id,
                -- IFNULL(product.Product_Name, '') AS Product_Name,
                orderitem.Approved_Quantity as Quantity, orderitem.Delivery_Id, orderitem.Is_Received,
                IFNULL(orderitem.Is_Delivered, 0) AS Is_Delivered,
                orderheader.MCC_Id, orderheader.Order_Type, orderheader.Order_For, 
                orderheader.Order_For_User_Id,
                IFNULL( 
					CASE orderheader.Order_For
					WHEN 'farmer' THEN farmer.Farmer_Name
					WHEN 'agent' THEN agent.Agent_Name
					END, '') AS Farmer_Agent_Name
                
                -- issueitem.IssueStocks_Id, issueitem.IssueStockToProfile_Id
                
                FROM t023_order_item orderitem
                INNER JOIN t023_order_header orderheader ON orderitem.Order_id = orderheader.Order_Id
					and orderitem.Org_Id = orderheader.Org_Id
                -- LEFT JOIN t019_issuestocks_item issueitem ON orderitem.Product_Id = issueitem.Material_Id
                -- LEFT JOIN t018_issuestocks_header issueheader ON issueitem.IssueStocks_Id = issueheader.IssueStocks_Id
                LEFT JOIN m010_material material ON orderitem.Product_Id = material.Material_Id
					and  orderitem.Org_Id = material.Org_Id
                LEFT JOIN m017_product product ON orderitem.Product_Id = product.Product_Id
					and orderitem.Org_Id = product.Org_Id
                LEFT JOIN mu04_farmer farmer ON orderheader.Order_For = 'Farmer' 
					AND orderheader.Order_For_User_Id = farmer.Farmer_Id
					and orderheader.Org_Id = farmer.Org_Id
				LEFT JOIN mu05_agent agent ON orderheader.Order_For = 'Agent'
					AND orderheader.Order_For_User_Id = agent.Agent_Id
					and orderheader.Org_Id = agent.Org_Id
                WHERE orderheader.Is_Approved = 1
                AND (
						orderitem.Delivery_Id = ''
                        OR
                        orderitem.Delivery_Id IS NULL
                        OR
                        orderitem.Delivery_Id = var_IssueStocks_Id
                    )
                AND orderheader.MCC_Id = var_MCC_Id
               -- and orderitem.Is_Delivered =0
               ;
                
                
            END;
            END IF;
		end;
	elseif (var_Method_Name = 'Get_Vehicle') then
		begin
			select m008.Org_Id,
             m003.Vehicle_Id ,m003.Vehicle_No
             from m008_route_vehicle m008
			 inner join m006_route m006 on m006.Route_Id = m008.Route_Id 
				and m006.Org_Id = m008.Org_Id 
			 inner join m003_vehicle m003 on m003.Vehicle_Id = m008.Vehicle_Id 
				and m003.Org_Id = m008.Org_Id 
             inner join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id 
             where m008.Org_Id = var_Org_Id and m008.Is_Deleted = 0 
             and m008.Route_Id = var_Route_Id
             and m008.VehicleType = 'truck'
             and m006.CollectionShift_Id = var_CollectionShift_Id
            order by m003.Vehicle_Id;
		end;
        
	elseif (var_Method_Name = 'Get_CollectionShift') then
		begin
			select m006.Org_Id,
             c015.CollectionShift_Id,c015.CollectionShift_Name
             from m006_route m006
			 inner join c015_collectionshift c015 on c015.CollectionShift_Id = m006.CollectionShift_Id 
             where m006.Org_Id = var_Org_Id
             and m006.Route_Id = var_Route_Id
            order by c015.CollectionShift_Name;
		end;
        
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
