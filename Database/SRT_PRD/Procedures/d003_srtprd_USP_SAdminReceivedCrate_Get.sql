-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminReceivedCrate_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminReceivedCrate_Get`(
	var_Org_Id VARCHAR(10),
    var_Method_Name VARCHAR(100),
    var_User_Id VARCHAR(20),
    var_ReceivedCrate_Id VARCHAR(20),
    var_Received_Period LONGTEXT,
    var_Dealer_Id VARCHAR(20),
    var_Is_Approved INT
)
BEGIN
	

	IF(var_Method_Name = 'Get') THEN
    BEGIN
    -- divide date range in two variables to get records between those two dates
	DECLARE var_StartDate DATE;
	DECLARE var_EndDate DATE;
	SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Received_Period, ' - ', 1), '%m/%d/%Y');
	SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Received_Period, ' - ', -1), '%m/%d/%Y');
		
		SELECT rc_header.Org_Id, 
			rc_header.ReceivedCrate_Id, 
			dealer.Dealer_Id, dealer.Dealer_Name, 
			ifnull(rc_header.Is_Approved  , 1) as Is_Approved, 
			ifnull(sum(f011.Closing_Quantity ), 0) as CrateBalance, 
			IFNULL(DATE_FORMAT(rc_header.Created_On, '%d %M %Y') , '' ) AS Created_On,
            
			ifnull( CASE rc_header.Is_Approved
				WHEN 1 THEN SUM(rc_item.Good_Quantity) + SUM(rc_item.Broken_Quantity) + SUM(rc_item.ThirdParty_Quantity)
                WHEN 0 THEN SUM(rc_item.Good_Quantity) + SUM(rc_item.Broken_Quantity) + SUM(rc_item.ThirdParty_Quantity)
			END  , 0) 
            AS Quantity
            
		FROM t038_receivedcrate_header rc_header
		LEFT JOIN t038_receivedcrate_item rc_item
			ON rc_header.ReceivedCrate_Id = rc_item.ReceivedCrate_Id
			AND rc_header.Org_Id = rc_item.Org_Id
		LEFT JOIN mu08_dealer dealer
			ON rc_header.Dealer_Id = dealer.Dealer_Id
			AND rc_header.Org_Id = dealer.Org_Id
		left join f011_dealer_stock f011 on f011.Org_Id = rc_header.Org_Id and 
        f011.Dealer_Id = rc_header.Dealer_Id  and 
         date(f011.Date) = date(rc_header.Created_On) and
         f011.Material_Id = rc_item.Material_Id 
		WHERE rc_header.Org_Id = var_Org_Id
        AND CAST(rc_header.Created_On AS DATE) >= var_StartDate 
		AND CAST(rc_header.Created_On AS DATE) <= var_EndDate
        AND rc_header.Dealer_Id LIKE var_Dealer_Id
        
        GROUP BY
        rc_header.Org_Id, rc_header.ReceivedCrate_Id, 
		dealer.Dealer_Id, dealer.Dealer_Name, 
		rc_header.Is_Approved,
		rc_header.Created_On
        
        ORDER BY rc_header.Created_On desc;
	
	END;
    
    ELSEIF(var_Method_Name = 'Get_One') THEN
    BEGIN
    
		-- get all the rows in item table that has ReceivedCrate_Id same as provided
        SELECT rc_item.Org_Id, rc_item.ReceivedCrate_Id, 
			material.Material_Id, material.Material_Name, 
			rc_item.MaterialType_Id, 
            rc_item.Quantity, 
            rc_item.Good_Quantity,
			rc_item.Broken_Quantity,
			rc_item.ThirdParty_Quantity,
            rc_item.Is_Approved
		FROM t038_receivedcrate_item rc_item
        LEFT JOIN m010_material material
			ON material.Material_Id = rc_item.Material_Id
            AND material.Org_Id = rc_item.Org_Id
        WHERE rc_item.Org_Id = var_Org_Id
        AND rc_item.ReceivedCrate_Id = var_ReceivedCrate_Id;
    
    END;
    ELSEIF(var_Method_Name = 'Get_Material') THEN
    BEGIN
    
		-- get all the materials from Material table where material type is C042231000005
        SELECT m010.Org_Id, 'New' as ReceivedCrate_Id, 
			m010.Material_Id, m010.Material_Name, 
			m010.MaterialType_Id, 0 Quantity, 
            0 Approved_Quantity, 0 as Is_Approved
		FROM m010_material m010
        WHERE m010.Org_Id = var_Org_Id and MaterialType_Id in ( 'C042231000005'  , 'C042231000001') and Is_Active = 1;
    
    END;
    elseif (var_Method_Name = 'Get_GoodsMovementCode') then
		begin
			DECLARE GoodsMovementCode varchar(255);
			SELECT Constant_Value as GoodsMovementCode FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'GoodsMovementCode';
		end;
	elseif (var_Method_Name = 'Get_Quantity_SAP') then
		begin
			
            DECLARE RatioFat decimal(8,2);
            DECLARE RatioSNF decimal(8,2);
            DECLARE Today_Date DATETIME;
            DECLARE Plant varchar(255);
			DECLARE StorageLocation varchar(255);
            DECLARE GoodsMovementType varchar(255);
			DECLARE Material1 varchar(255);
            DECLARE Material2 varchar(255);
            
            SELECT Constant_Value into Plant  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Plant';
			SELECT Constant_Value into StorageLocation  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'StorageLocation';
			SELECT Constant_Value into GoodsMovementType  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'GoodsMovementType';
			SELECT Constant_Value into Material1  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material1';
			SELECT Constant_Value into Material2  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='MaterialDocumentHeader' and Constant_Name = 'Material2';

           
                
                select 
				'' as Batch, Plant as Plant,
				'CACR' as StorageLocation, 'Z01' as  GoodsMovementType , '' as PurchaseOrder,  '' as PurchaseOrderItem,
				'' as GoodsMovementRefDocType,'EA' as EntryUnit, '' as  MaterialDocumentItemText , '' as Supplier, 
                -- concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(NOW(), '+00:00', '+00:00')) * 1000),')/') as  ManufactureDate,
                '27.000' as QuantityInEntryUnit,
                -- t009.TotalLandedCost as GdsMvtExtAmtInCoCodeCrcy,
				/*CASE
					WHEN t009.MilkType_Id = 'C011001' and t009.MilkStatus_Id = 'C016001'  THEN Material1
					WHEN t009.MilkType_Id = 'C011002' and t009.MilkStatus_Id = 'C016001' THEN Material2
					ELSE '' 
				END as Material*/
				'860004' as Material,
                '530025' as Customer;
		end;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
