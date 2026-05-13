-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_FarmerComplaint_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_FarmerComplaint_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_Profile_Id varchar(20),
    Var_Complaint_Id Varchar(20)
)
BEGIN
	if (var_Method_Name = 'Get') then  
		begin
			select t016.Org_Id,Complaint_Id, ComplaintType_Name, Complaint_Remark,
            ComplaintStatus_Name, t016.ComplaintStatus_Id,
            date_format(Complaint_Date, '%d %b %Y %h:%i %p') as Complaint_Date
            from t016_complaint_header t016
            inner join c035_complaintstatus  c035 on t016.ComplaintStatus_Id = c035.ComplaintStatus_Id
            inner join c034_complainttype c034 on t016.ComplaintType_Id = c034.ComplaintType_Id
            where Org_Id = var_Org_Id 
            and Complaint_For_User_Id = var_Profile_Id
            order by Complaint_Date desc limit 15; 
		end;
        
		elseif (var_Method_Name = 'Complaintchat')then
        
		select t016i.Complaint_Id, t016i.Remarks, DATE_FORMAT(t016i.Action_Date, '%d %M %Y') as Action_Date , ComplaintType_Name , ComplaintStatus_Name, t016.ComplaintStatus_Id ,
        if(Action_By_Id = var_Profile_Id , 1 , 0 )  as Chatside from  t016_complaint_item t016i inner join t016_complaint_header t016 on  t016.Org_Id = t016i.Org_Id 
		and t016i.Complaint_Id = t016.Complaint_Id 
		inner join c035_complaintstatus  c035 on t016.ComplaintStatus_Id = c035.ComplaintStatus_Id
		inner join c034_complainttype c034 on t016.ComplaintType_Id = c034.ComplaintType_Id
		where t016i.Complaint_Id = Var_Complaint_Id and t016i.Org_Id = var_Org_Id
        order by Action_Date asc;
        
        
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
