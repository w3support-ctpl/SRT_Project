-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminCorrection_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminCorrection_Get`(
  var_Method_Name VARCHAR(20),
     var_Org_Id VARCHAR(10),
     var_User_Id VARCHAR(20),
     var_CorrectionRequest_Id VARCHAR(20),
     var_ApprovalStatus_Id VARCHAR(20),
  var_Date VARCHAR(60)
 )
BEGIN
  DECLARE var_StartDate DATE;
  DECLARE var_EndDate DATE;
  SET @ApprovalStatus_Id = var_ApprovalStatus_Id;
  IF((var_ApprovalStatus_Id = '') OR (var_ApprovalStatus_Id IS NULL)) THEN
     BEGIN
   SET @ApprovalStatus_Id := '0,1,-1';
     END;
     END IF;
  IF (var_Method_Name = 'GetL1') THEN  
   BEGIN
 
             SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
             SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
             
    SELECT request.Org_Id,
     request.Correction_Request_Id,
                 request.Is_Approved_L1,
                 ifnull(request.Approved_Remark_L1,'') as Approved_Remark_L1,
                 request.Is_Approved_L2,
     IFNULL(DATE_FORMAT(request.Approved_On_L1, '%d %M %Y'), '') AS Approved_On_L1,
                 IFNULL(DATE_FORMAT(request.Approved_On_L2, '%d %M %Y'), '') AS Approved_On_L2,
     DATE_FORMAT(cfarmer.Created_On, '%d %M %Y') as Created_On,
                 agent.Agent_Name, 
                 agent.Agent_Id,
                 agent.Mobile_No,
                 mcc.MCC_Name,
                 farmer.Farmer_Name,
                 c015.CollectionShift_Name
             FROM t013_correction_request request 
             LEFT JOIN t005_milkcollectionfarmer cfarmer 
     ON cfarmer.FarmerCollection_Id = request.FarmerCollection_Id
     AND cfarmer.Org_Id = request.Org_Id
     LEFT JOIN t004_mcccollectionshift t004 
     ON t004.Org_Id = cfarmer.Org_Id
     and t004.MCC_Id = cfarmer.MCC_Id
     and t004.MCCCollectionShift_Id = cfarmer.MCCCollectionShift_Id
     left join c015_collectionshift c015 on
     c015.CollectionShift_Id =  t004.CollectionShift_Id
             LEFT JOIN m005_mcc mcc 
     ON cfarmer.MCC_Id = mcc.MCC_Id
     AND mcc.Org_Id = request.Org_Id
             LEFT JOIN mu05_agent agent 
     ON mcc.Agent_Id = agent.Agent_Id
     AND agent.Org_Id = request.Org_Id
    LEFT JOIN mu04_farmer farmer 
     ON cfarmer.Farmer_Id = farmer.Farmer_Id
     AND farmer.Org_Id = farmer.Org_Id
             WHERE request.Org_Id = var_Org_Id 
    AND CAST(request.Created_On AS DATE) >= var_StartDate 
             AND CAST(request.Created_On AS DATE) <= var_EndDate
             AND FIND_IN_SET(request.Is_Approved_L1, @ApprovalStatus_Id)
             and request.Is_Approved_L1 = @ApprovalStatus_Id
             -- and request.Is_Approved_L1 = var_ApprovalStatus_Id
             and ifnull(agent.Agent_Id,'') <> ''
             ORDER BY request.Correction_Request_Id;
   END;
  ELSEIF (var_Method_Name = 'GetL2') THEN  
   BEGIN
 
             SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
             SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
             
    SELECT request.Org_Id,
     request.Correction_Request_Id,
                 request.Is_Approved_L1,
                 request.Is_Approved_L2,
     IFNULL(DATE_FORMAT(request.Approved_On_L1, '%d %M %Y'), '') AS Approved_On_L1,
                 IFNULL(DATE_FORMAT(request.Approved_On_L2, '%d %M %Y'), '') AS Approved_On_L2,
     DATE_FORMAT(cfarmer.Created_On, '%d %M %Y') as Created_On,
                 agent.Agent_Name, 
                 agent.Agent_Id,
                 agent.Mobile_No,
                 mcc.MCC_Name,
                 farmer.Farmer_Name,
                 c015.CollectionShift_Name
             FROM t013_correction_request request 
             LEFT JOIN t005_milkcollectionfarmer cfarmer 
     ON cfarmer.FarmerCollection_Id = request.FarmerCollection_Id
     AND cfarmer.Org_Id = request.Org_Id
     LEFT JOIN t004_mcccollectionshift t004 
     ON t004.Org_Id = cfarmer.Org_Id
     and t004.MCC_Id = cfarmer.MCC_Id
     and t004.MCCCollectionShift_Id = cfarmer.MCCCollectionShift_Id
     left join c015_collectionshift c015 on
     c015.CollectionShift_Id =  t004.CollectionShift_Id
             LEFT JOIN m005_mcc mcc 
     ON cfarmer.MCC_Id = mcc.MCC_Id
     AND mcc.Org_Id = request.Org_Id
             LEFT JOIN mu05_agent agent 
     ON mcc.Agent_Id = agent.Agent_Id
     AND agent.Org_Id = request.Org_Id
    LEFT JOIN mu04_farmer farmer 
     ON cfarmer.Farmer_Id = farmer.Farmer_Id
     AND farmer.Org_Id = farmer.Org_Id
             WHERE request.Org_Id = var_Org_Id 
    AND CAST(request.Created_On AS DATE) >= var_StartDate 
             AND CAST(request.Created_On AS DATE) <= var_EndDate
             AND request.Is_Approved_L1 = 1
             AND FIND_IN_SET(request.Is_Approved_L2, @ApprovalStatus_Id)
             and ifnull(agent.Agent_Id,'') <> ''
             and request.Is_Approved_L2 = @ApprovalStatus_Id
             -- and request.Is_Approved_L2 = var_ApprovalStatus_Id
             ORDER BY request.Correction_Request_Id;
   END;
  ELSEIF (var_Method_Name = 'Get_One') THEN
   BEGIN
    SELECT request.Org_Id,
     request.Correction_Request_Id,
     IFNULL(request.Request_Quantity_Ltr,'') AS Request_Quantity_Ltr,
     IFNULL(request.Request_Fat,'') AS Request_Fat,
     IFNULL(request.Request_SNF,'') AS Request_SNF,
     IFNULL(request.Approved_Quantity_Ltr,'') AS Approved_Quantity_Ltr,
	IFNULL(request.Approved_Fat,'') AS Approved_Fat,
	IFNULL(request.Approved_SNF,'') AS Approved_SNF,
     IFNULL(request.Request_Remark,'') AS Request_Remark,
     cfarmer.FarmerCollection_Id,
     IFNULL(cfarmer.Quantity_Ltr,'') AS Current_Quantity_Ltr,
     IFNULL(cfarmer.Fat,'') AS Current_Fat,
     IFNULL(cfarmer.SNF,'') AS Current_SNF,
     agent.Agent_Id,
                 agent.Agent_Name,
                 agent.Mobile_No,
     mcc.MCC_Id,
                 mcc.MCC_Name,
                 farmer.Farmer_Name,
                 mcc.MCC_Code,
                 request.Created_On,
     -- DATE_FORMAT(request.Created_On, '%Y-%m-%d') AS Created_On,
                 request.Approved_Remark_L1, 
                 request.Is_Approved_L1,
                 request.Approved_On_L1, 
                 request.Approved_By_L1, 
     request.Approved_Name_L1,
                 request.Approved_Remark_L2, 
                 request.Is_Approved_L2,
                 request.Approved_On_L2, 
                 request.Approved_By_L2, 
     request.Approved_Name_L2,
                 IFNULL(DATE_FORMAT(request.Approved_On_L1, '%d %M %Y'), '') AS Approved_On_L1,
                 IFNULL(DATE_FORMAT(request.Approved_On_L2, '%d %M %Y'), '') AS Approved_On_L2,
                 DATE_FORMAT(cfarmer.Created_On, '%d %M %Y') as Created_On,
                 c015.CollectionShift_Name
             FROM t013_correction_request request
             LEFT JOIN t005_milkcollectionfarmer cfarmer 
     ON cfarmer.FarmerCollection_Id = request.FarmerCollection_Id
     AND cfarmer.Org_Id = request.Org_Id
     LEFT JOIN t004_mcccollectionshift t004 
     ON t004.Org_Id = cfarmer.Org_Id
     and t004.MCC_Id = cfarmer.MCC_Id
     and t004.MCCCollectionShift_Id = cfarmer.MCCCollectionShift_Id
     left join c015_collectionshift c015 on
     c015.CollectionShift_Id =  t004.CollectionShift_Id
             LEFT JOIN m005_mcc mcc 
     ON cfarmer.MCC_Id = mcc.MCC_Id
     AND mcc.Org_Id = request.Org_Id
             LEFT JOIN mu05_agent agent 
     ON mcc.Agent_Id = agent.Agent_Id
     AND agent.Org_Id = request.Org_Id
    LEFT JOIN mu04_farmer farmer 
     ON cfarmer.Farmer_Id = farmer.Farmer_Id
     AND farmer.Org_Id = farmer.Org_Id
             WHERE request.Org_Id = var_Org_Id 
             AND request.Correction_Request_Id = var_CorrectionRequest_Id;
   END;
  elseif (var_Method_Name = 'Lock') then
   begin
             DECLARE Is_Locked varchar(10);
             
     set @FarmerCollection_Id = (select FarmerCollection_Id from t013_correction_request 
     where Org_Id = var_Org_Id
     and  Correction_Request_Id = var_CorrectionRequest_Id limit 1);
 
     set @Is_Locked = (select ifnull(Is_InvoiceCreated,0) from t005_milkcollectionfarmer 
     where Org_Id = var_Org_Id
     and  FarmerCollection_Id = @FarmerCollection_Id limit 1);
                                     
     if(@Is_Locked is null or @Is_Locked = '')then
      set @Is_Locked  = 0;
                 end if;
                 
     set Is_Locked = @Is_Locked ;
                 
     select Is_Locked;
   end;
  END IF;
 END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:23
