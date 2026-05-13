-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentAdvance_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentAdvance_Get`(
Var_Method_Name varchar(50),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Profile_Id varchar(20),
Var_Date varchar(20)
)
BEGIN
set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	If(Var_Method_Name = 'GetPending')then 
		
        select Advance_Id , Farmer_Name as Name , 
        ifnull(Approved_Amount,0.0) as Approved_Amount , ifnull(t008.Approved_On,'') as Approved_On, 
        ifnull(t008.Is_Approved,0) as Approved_Status ,
         t008.Created_On as Applied_Date,
        ifnull(Advance_Remark,'') as Advance_Remark , Advance_Amount 
        from t015_advance t008 inner join mu04_farmer mu04 on t008.Org_Id = mu04.Org_Id and mu04.Farmer_Id = t008.Request_For_User_Id
        where t008.MCC_Id= Var_MCC_Id and t008.Org_Id = Var_Org_Id and t008.Is_Approved = 0
        order by t008.Created_On desc;

	elseif( Var_Method_Name = 'GetPaid' ) then
    
        select Advance_Id , Farmer_Name as Name , 
        ifnull(Approved_Amount,0.0) as Approved_Amount , ifnull(t008.Approved_On,'') as Approved_On, 
        ifnull(t008.Is_Approved,0) as Approved_Status ,
        t008.Created_On as Applied_Date,
        ifnull(Advance_Remark,'') as Advance_Remark , Advance_Amount 
        from t015_advance t008 inner join mu04_farmer mu04 on t008.Org_Id = mu04.Org_Id and mu04.Farmer_Id = t008.Request_For_User_Id
        where t008.MCC_Id= Var_MCC_Id and t008.Org_Id = Var_Org_Id and Is_Approved in( -1 , 1) and  
        Date(t008.Approved_On) >= Date(@Current_Datetime)
        order by t008.Created_On desc;

        
	elseif(Var_Method_Name = 'GetHistory') then 
    
	set @Var_Month = '';
	set @Var_Month =  month(Var_Date);
    
	set @Var_Year = '';
	set @Var_Year =  year(Var_Date);
    
    
        select Advance_Id , Farmer_Name as Name , 
        ifnull(Approved_Amount,0.0) as Approved_Amount , ifnull(t008.Approved_On,'') as Approved_On, 
        ifnull(t008.Is_Approved,0) as Approved_Status ,
        t008.Created_On as Applied_Date,
        ifnull(Advance_Remark,'') as Advance_Remark , Advance_Amount 
        from t015_advance t008 inner join mu04_farmer mu04 on t008.Org_Id = mu04.Org_Id and mu04.Farmer_Id = t008.Request_For_User_Id
        where t008.MCC_Id= Var_MCC_Id and t008.Org_Id = Var_Org_Id and Is_Approved in(1 , -1) and  
		month(t008.Approved_On) = @Var_Month and Year(t008.Approved_On) = @Var_Year order by t008.Approved_On desc;
        
        
        elseif (Var_Method_Name = 'GetBalanceDeduction') then
        
		select t008.Advance_Id , Farmer_Name as Name , 
        ifnull(Deduction.Balance,Approved_Amount) as Balance_Amount, ifnull(t008.Approved_On,'') as Approved_On, 
        ifnull(t008.Is_Approved,0) as Approved_Status ,
        t008.Created_On as Applied_Date,
        ifnull(Advance_Remark,'') as Advance_Remark , Advance_Amount 
        from t015_advance t008 
        inner join mu04_farmer mu04 on t008.Org_Id = mu04.Org_Id and mu04.Farmer_Id = t008.Request_For_User_Id
		left join t033_deductions_header Deduction on Deduction.Advance_Id = t008.Advance_Id 
        where t008.MCC_Id = Var_MCC_Id and t008.Org_Id = Var_Org_Id and Is_Approved in ( 1) 
        -- and Deduction.Balance > 0 
        ; 
        
        
        
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
