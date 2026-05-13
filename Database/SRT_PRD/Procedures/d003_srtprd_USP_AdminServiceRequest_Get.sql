-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminServiceRequest_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminServiceRequest_Get`(
    var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Date varchar(60),
    var_ApprovalStatus_Id varchar(20),
    var_Request_Id varchar(20),
	var_Request_For varchar(20),
	var_Order_Type varchar(20),
    var_ServiceType_Id varchar(20)
)
BEGIN

	SET @ApprovalStatus_Id = var_ApprovalStatus_Id;
	IF((var_ApprovalStatus_Id = '') OR (var_ApprovalStatus_Id IS NULL)) THEN
    BEGIN
		SET @ApprovalStatus_Id := '0,1,-1';
    END;
    END IF;
    
    IF (var_Method_Name = 'Get') THEN
    BEGIN
    
		-- drop and then create temp table to store output
        DROP TEMPORARY TABLE IF EXISTS temp_services;
        CREATE TEMPORARY TABLE temp_services(
        Org_Id VARCHAR(20),
        Request_Id VARCHAR(20),
        Service_Id VARCHAR(20),
        Service_Name VARCHAR(50),
        Request_For VARCHAR(20),
        RequestFor_Id VARCHAR(20),
        Request_By VARCHAR(20),
        Farmer_Agent_Id_Request_For longtext,
        Farmer_Agent_Name_Request_For longtext,
        Mobile_No_Request_For VARCHAR(20),
        Farmer_Agent_Id_Request_By longtext,
        Farmer_Agent_Name_Request_By longtext,
        Mobile_No_Request_By VARCHAR(20),
		Request_Date VARCHAR(20),
        Approved_On VARCHAR(20),
        Is_Approved INT,
        Approval_Remarks LONGTEXT,
        ServiceType_Id VARCHAR(20),
        ServiceType_Name VARCHAR(20),
        PRIMARY KEY (Org_Id, Request_Id)
        );
        
        
        
       -- append material data from t003_service table
        INSERT INTO temp_services(
			Org_Id, Request_Id, Service_Id, Service_Name, Request_For, RequestFor_Id,
			Request_By, Farmer_Agent_Id_Request_For, Farmer_Agent_Name_Request_For, 
            Mobile_No_Request_For, Farmer_Agent_Id_Request_By, Farmer_Agent_Name_Request_By,
            Mobile_No_Request_By, Request_Date, Approved_On, Is_Approved, 
            Approval_Remarks, ServiceType_Id, ServiceType_Name
        )
			SELECT
				request.Org_Id AS Org_Id, 
                request.Request_Id AS Request_Id,
				service.Service_Id AS Service_Id, 
                service.Service_Name AS Service_Name,
				request.Request_For AS Request_For, 
                request.Request_For_User_Id AS RequestFor_Id,
				request.Request_By AS Request_By,
				IFNULL( 
					CASE request.Request_For
					WHEN 'farmer' THEN farmer_req_for.Farmer_Id
					WHEN 'agent' THEN agent_req_for.Agent_Id
					END, '') AS Farmer_Agent_Id_Request_For,
				IFNULL( 
					CASE request.Request_For
					WHEN 'farmer' THEN farmer_req_for.Farmer_Name
					WHEN 'agent' THEN agent_req_for.Agent_Name
					END, '') AS Farmer_Agent_Name_Request_For,
				IFNULL(
					CASE request.Request_For
                    WHEN 'farmer' THEN farmer_req_for.Mobile_No
                    WHEN 'agent' THEN agent_req_for.Mobile_No
                    ELSE ''
					END, '') AS Mobile_No_Request_For,
				IFNULL( 
					CASE request.Request_By
                    WHEN 'farmer' THEN farmer_req_by.Farmer_Id
                    WHEN 'agent' THEN agent_req_by.Agent_Id
					END, '' ) AS Farmer_Agent_Id_Request_By,
				IFNULL( 
					CASE request.Request_By
                    WHEN 'farmer' THEN farmer_req_by.Farmer_Name
                    WHEN 'agent' THEN agent_req_by.Agent_Name
					END, '' ) AS Farmer_Agent_Name_Request_By,
				IFNULL(
					CASE request.Request_By
                    WHEN 'farmer' THEN farmer_req_by.Mobile_No
                    WHEN 'agent' THEN agent_req_by.Mobile_No
                    ELSE ''
					END, '') AS Mobile_No_Request_By,
				DATE_FORMAT(request.Request_Date, '%d %M %Y') AS Request_Date,
				ifnull(DATE_FORMAT(request.Approved_On, '%d %M %Y'),'') AS Approved_On,
				request.Is_Approved AS Is_Approved,
                IFNULL(request.Approval_Remarks,'') AS Approval_Remarks, 
                request.ServiceType_Id AS ServiceType_Id,
				servicetype.ServiceType_Name AS ServiceType_Name
			FROM t003_service request 
			INNER JOIN m012_service service ON service.Service_Id = request.Service_Id
				and service.Org_Id = request.Org_Id
			INNER JOIN c027_servicetype servicetype ON request.ServiceType_Id = servicetype.ServiceType_Id
			LEFT JOIN mu04_farmer farmer_req_for ON request.Request_For = 'farmer' 
				AND farmer_req_for.Farmer_Id = request.Request_For_User_Id
				AND farmer_req_for.Org_Id = request.Org_Id
			LEFT JOIN mu05_agent agent_req_for ON request.Request_For = 'agent' 
				AND agent_req_for.Agent_Id = request.Request_For_User_Id
                AND agent_req_for.Org_Id = request.Org_Id
			LEFT JOIN mu04_farmer farmer_req_by ON request.Request_By = 'farmer' 
				AND farmer_req_by.Farmer_Id = request.Request_By_User_Id
                AND farmer_req_by.Org_Id = request.Org_Id
			LEFT JOIN mu05_agent agent_req_by ON request.Request_By = 'agent' 
				AND agent_req_by.Agent_Id = request.Request_By_User_Id
                AND agent_req_by.Org_Id = request.Org_Id
			WHERE request.Org_Id = var_Org_Id
			AND FIND_IN_SET(request.Is_Approved, @ApprovalStatus_Id)
			AND CAST(request.Request_Date AS DATE) BETWEEN STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y')
			AND STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y')
			AND request.Request_For = var_Request_For
			ORDER BY request.Request_Id;
		
        -- append material data from order header table
        INSERT INTO temp_services(
			Org_Id, Request_Id, Service_Id, Service_Name, Request_For, RequestFor_Id,
			Request_By, Farmer_Agent_Id_Request_For, Farmer_Agent_Name_Request_For, 
            Mobile_No_Request_For, Farmer_Agent_Id_Request_By, Farmer_Agent_Name_Request_By,
            Mobile_No_Request_By, Request_Date, Approved_On, Is_Approved, 
            Approval_Remarks, ServiceType_Id, ServiceType_Name
        )
        SELECT
            orderheader.Org_Id AS Org_Id, 
            orderheader.Order_Id AS Request_Id,
            IFNULL(material.Material_Id,'') AS Service_Id, 
            IFNULL(material.Material_Name, '') AS Service_Name,
            orderheader.Order_For AS Request_For,
            orderheader.Order_For_User_Id AS RequestFor_Id,
            orderheader.Order_By AS Request_By,
            IFNULL( CASE orderheader.Order_For
                    WHEN 'farmer' THEN farmer_req_for.Farmer_Id
                    WHEN 'agent' THEN agent_req_for.Agent_Id
					END, '') AS Farmer_Agent_Id_Request_For,
            IFNULL( CASE orderheader.Order_For
                    WHEN 'farmer' THEN farmer_req_for.Farmer_Name
                    WHEN 'agent' THEN agent_req_for.Agent_Name
					END, '') AS Farmer_Agent_Name_Request_For,
            IFNULL(
                CASE orderheader.Order_For
                    WHEN 'farmer' THEN farmer_req_for.Mobile_No
                    WHEN 'agent' THEN agent_req_for.Mobile_No
                    ELSE ''
					END, '') AS Mobile_No_Request_For,
            IFNULL( 
				CASE orderheader.Order_By
                    WHEN 'farmer' THEN farmer_req_by.Farmer_Id
                    WHEN 'agent' THEN agent_req_by.Agent_Id
					END, '' ) AS Farmer_Agent_Id_Request_By,
			IFNULL( 
					CASE orderheader.Order_By
                    WHEN 'farmer' THEN farmer_req_by.Farmer_Name
                    WHEN 'agent' THEN agent_req_by.Agent_Name
					END, '' ) AS Farmer_Agent_Name_Request_By,
			IFNULL(
					CASE orderheader.Order_By
                    WHEN 'farmer' THEN farmer_req_by.Mobile_No
                    WHEN 'agent' THEN agent_req_by.Mobile_No
                    ELSE ''
					END, '') AS Mobile_No_Request_By,
            DATE_FORMAT(orderheader.Order_Date, '%d %M %Y') AS Request_Date,
            -- DATE_FORMAT(orderheader.Order_Date, '%Y-%m-%d') AS Order_Date,
            ifnull(DATE_FORMAT(orderheader.Approved_On, '%d %M %Y'),'') AS Approved_On,
            orderheader.Is_Approved AS Is_Approved,
            orderheader.Approval_Remarks AS Approval_Remarks,
            'C026003' AS ServiceType_Id,
            'Material Sales' AS ServiceType_Name
        FROM t023_order_header orderheader 
        LEFT JOIN t023_order_item orderitem ON orderitem.Order_Id = orderheader.Order_Id
			and orderitem.Org_Id = orderheader.Org_Id
        LEFT JOIN m010_material material ON orderitem.Product_Id = material.Material_Id
			and orderitem.Org_Id = material.Org_Id
        LEFT JOIN mu04_farmer farmer_req_for ON orderheader.Order_For = 'farmer' 
			AND farmer_req_for.Farmer_Id = orderheader.Order_For_User_Id
            AND farmer_req_for.Org_Id = orderheader.Org_Id
        LEFT JOIN mu05_agent agent_req_for ON orderheader.Order_For = 'agent' 
			AND agent_req_for.Agent_Id = orderheader.Order_For_User_Id
            AND agent_req_for.Org_Id = orderheader.Org_Id
		LEFT JOIN mu04_farmer farmer_req_by ON orderheader.Order_By = 'farmer' 
			AND farmer_req_by.Farmer_Id = orderheader.Order_By_User_Id
            AND farmer_req_by.Org_Id = orderheader.Org_Id
		LEFT JOIN mu05_agent agent_req_by ON orderheader.Order_By = 'agent' 
			AND agent_req_by.Agent_Id = orderheader.Order_By_User_Id
            AND agent_req_by.Org_Id = orderheader.Org_Id
        WHERE orderheader.Org_Id = var_Org_Id
			AND FIND_IN_SET(orderheader.Is_Approved, @ApprovalStatus_Id)
			AND  CAST(orderheader.Order_Date  AS DATE)  
				BETWEEN STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y')
				AND STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y')
			AND orderheader.Order_For = var_Request_For
            AND orderheader.Order_Type = var_Order_Type
        ORDER BY orderheader.Order_Id;
        
        -- send the whole table
        SELECT * FROM temp_services
        ORDER BY Request_Date DESC;
        
    END;
    ELSEIF (var_Method_Name = 'Get_One' )THEN
    BEGIN
    
		-- if material, then
		IF(var_ServiceType_Id = 'C026003') THEN
        BEGIN
			SELECT orderitem.Org_Id AS Org_Id, 
				orderitem.Order_Id AS Request_Id, 
				orderitem.Product_Id AS Material_Id, 
                material.Material_Name, 
                orderitem.Quantity, 
				orderitem.Rate, 
                orderitem.Total_Price, 
				IFNULL(orderitem.Approved_Quantity, '0') AS Approved_Quantity
			FROM t023_order_item orderitem
			INNER JOIN m010_material material ON material.Material_Id = orderitem.Product_Id
			WHERE orderitem.Order_Id = var_Request_Id
			AND orderitem.Org_Id = var_Org_Id
			AND material.Org_Id = var_Org_Id;
        END;
        ELSE
        BEGIN
			SELECT
				request.Org_Id, request.Request_Id, request.Service_Id,request.Request_For,
				request.Request_For_User_Id, request.Request_By,request.Request_By_User_Id,
				DATE_FORMAT(request.Request_Date, '%Y-%m-%d') AS Request_Date, request.Is_Approved,
				request.Approval_Remarks, request.ServiceType_Id, request.Request_Amount, 
				request.Request_Remark, request.Approved_Amount, request.VeterinaryService_Date,
				service.Service_Name
			FROM t003_service request
			INNER JOIN m012_service service ON request.Service_Id = service.Service_Id
				and request.Org_Id = service.Org_Id
			WHERE request.Org_Id = var_Org_Id 
			AND request.Request_Id = var_Request_Id
			AND request.Request_For = var_Request_For;
        END;
        END IF;
    
        
    END;
    
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
