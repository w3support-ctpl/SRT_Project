-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentExpense_Common` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentExpense_Common`(
Var_Method_Name varchar(20),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_ExpenseType_Id varchar(20),
Var_Amount varchar(10),
Var_Remark Text,
Var_Date varchar(20) ,
Var_Profile_Id varchar(20)
)
BEGIN
	set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

    if(Var_Method_Name = 'SaveExpense') then
    
		set @Year_Id = (select right(left(curdate(),4),(2)));
		set @Expense_Id  = '';
		Call USP_Number_Range ('t014_agent_expense', @Year_Id, 'T007', '', @Expense_Id );
        
        insert into t014_agent_expense(Org_Id , Expense_Id, MCC_Id,  ExpenseType_id , Expense_Amount, Expense_Remark , 
        Is_Active , Created_On , CreatedBy_Id ) values
		(Var_Org_Id , @Expense_Id ,Var_MCC_Id ,  Var_ExpenseType_Id , Var_Amount , Var_Remark , 
        1, @Current_Datetime , Var_Profile_Id 
        );
 
 		select 1 as Result_Id, 'Expense Added' as Result_Description, '' as Result_Extra_Key;   
 
	elseif(Var_Method_Name = 'GetExpense') then
    
    set @Var_Month = '';
	set @Var_Month =  month(Var_Date);
    
	set @Var_Year = '';
	set @Var_Year =  year(Var_Date);

	Set @ThisMonth_Expense = (select sum(Expense_Amount) from t014_agent_expense  t007  where t007.MCC_Id = Var_MCC_Id and Org_Id = Var_Org_Id and 
		month(t007.Created_On) = @Var_Month and Year(t007.Created_On) = @Var_Year);
        
        insert into temp(text) value (@ThisMonth_Expense);
        
	Set @LastMonth_Expense = (select sum(Expense_Amount) from t014_agent_expense t007 where t007.MCC_Id = Var_MCC_Id and Org_Id = Var_Org_Id and 
		month(t007.Created_On) = if(@Var_Month = 1 , 12 , @Var_Month - 1 ) and Year(t007.Created_On) = if(@Var_Month = 1 , @Var_Year - 1 , @Var_Year));

	select Expense_Id , ExpenseType_Name , Expense_Amount , Expense_Remark , ifnull(@LastMonth_Expense,0.0) as LastMonth_Expense , 
    ifnull(@ThisMonth_Expense,0.0) as ThisMonth_Expense ,
    DATE_FORMAT(t007.Created_On, '%e %M %Y')  as Created_Date from t014_agent_expense t007 inner join 
		c036_expensetype c036 on t007.ExpenseType_id = c036.ExpenseType_Id 
        where t007.MCC_Id = Var_MCC_Id and Org_Id = Var_Org_Id and 
		month(t007.Created_On) = @Var_Month and Year(t007.Created_On) = @Var_Year ;
    
    end if;
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:28
