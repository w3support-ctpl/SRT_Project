-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentCollectionRequest_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentCollectionRequest_Set`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    Var_MCC_Id varchar(20),
    Var_Shift_Id varchar(20),
	Var_RequestType_Id varchar(20),
    Var_RequestDetails varchar(50),
    Var_RequestRemark varchar(150),
    var_Profile_Id varchar(20)
)
BEGIN

	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
    

	set @Check_MCCWorkType_Id = (select MCCWorkType_Id from m005_mcc where Org_Id = var_Org_Id and MCC_Id = Var_MCC_Id limit 1);
    
    if(@Check_MCCWorkType_Id = 'C023001')then
		
		Set @CollectionShift = ( select MCCCollectionShift_Id from t102_mcccollectionshift_offline where 
		Org_Id = var_Org_Id and MCC_Id = Var_MCC_Id and date(Collection_Date) = date(now())
        order by Collection_Date desc limit 1
        );
        
    elseif(@Check_MCCWorkType_Id = 'C023002')then
		
        Set @CollectionShift = ( select MCCCollectionShift_Id from t004_mcccollectionshift where 
		Org_Id = var_Org_Id and MCC_Id = Var_MCC_Id and date(Collection_Date) = date(now())
        order by Collection_Date desc limit 1
        );
    
    end if;
    
    
        
    
	if (var_Method_Name = 'Request') then 
			
		if(Var_Shift_Id is null ) then
        
			select -1 as Result_Id, 'Shift Not Found' as Result_Description, '' as Result_Extra_Key; 

	elseif(@CollectionShift is null) then 
    			
                select -1 as Result_Id, 'Shift Not Found' as Result_Description, '' as Result_Extra_Key; 

	else
		
    IF(@CollectionShift = Var_Shift_Id ) THEN
        
		if exists (select 1 from t010_collectionrequest where Org_Id = var_Org_Id and MCC_Id = Var_MCC_Id and 
        MCC_CollectionShift_Id = Var_Shift_Id and RequestType_Id = RequestType_Id and Is_Approved = 0 ) then  

			select -1 as Result_Id, 'Already Applied' as Result_Description, '' as Result_Extra_Key;    
        
        else 
			

			set @CollectionRequest_Id = '';
			set @Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('t010_collectionrequest', @Year_Id, 'T010', '', @CollectionRequest_Id );
            
            insert into t010_collectionrequest (Org_Id,CollectionRequest_Id, MCC_Id,MCC_CollectionShift_Id,RequestType_Id,Request_Details,
            Request_Remarks,Is_Approved ,Created_On ,CreatedBy_Id,CreatedBy_Name
            ) value 
            (var_Org_Id,@CollectionRequest_Id,Var_MCC_Id,Var_Shift_Id,Var_RequestType_Id,Var_RequestDetails,Var_RequestRemark,
            0,@Current_Datetime,var_Profile_Id, (select Agent_Name from mu05_agent where Agent_Id = var_Profile_Id and Org_Id = var_Org_Id )
            ) ;
            
			select 1 as Result_Id, 'Success' as Result_Description, '' as Result_Extra_Key;    
            
end if;
			
            select -1 as Result_Id, 'No Shift' as Result_Description, '' as Result_Extra_Key;  

	end if;
	end if;

end if;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
