-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_UpdateMCC_Stock` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_UpdateMCC_Stock`(
Var_Method_Name varchar(255),
Var_Org_Id varchar(20),
Var_MCC_Id varchar(20),
Var_Material_Id varchar(20),
Var_Date varchar(20),
Var_IssueStocks_Id varchar(20)
)
BEGIN

set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));
set sql_require_primary_key = 0 ;
SET SQL_SAFE_UPDATES = 0;

	if (Var_Method_Name = 'UpdateMCCStock') then
		
        Set @OpeningBal = '';
        set @Credit = '';
        set @Debit = '';
        set @ClosingBal = '';
        
       set @OpeningBal = (select Balance from f006_mccstocks where Org_Id = Var_Org_Id and 
       MCC_Id = Var_MCC_Id and Material_Id = Var_Material_Id and date(Date) < date(Var_Date) order by Date desc limit 1 );
       
       set @Credit = (Select sum(Quantity) from t019_issuestocks_item where date(MCC_Accepted_On) = date(Var_Date)
       and Org_Id = Var_Org_Id and Material_Id = Var_Material_Id and MCC_Id = Var_MCC_Id and Is_MCCAccepted = 1);
       
       set @Debit = (Select sum(Quantity) from t019_issuestocks_item where date(MCC_Accepted_On) = date(Var_Date)
       and Org_Id = Var_Org_Id and Material_Id = Var_Material_Id and MCC_Id = Var_MCC_Id and Is_MCCAccepted = 1 and Is_Given = 1);
       
       set @ClosingBal = ( ifnull(@OpeningBal, 0) + ifnull(@Credit,0) ) - ifnull(@Debit,0);
       
       if exists(select 1 from f006_mccstocks where Org_Id = Var_Org_Id and MCC_Id = Var_MCC_Id and Material_Id = Var_Material_Id and date(Date) = date(Var_Date)) then
       
		   update f006_mccstocks 
		   set Opening_Quantity = ifnull(@OpeningBal, 0),
		   Credit = ifnull(@Credit, 0),
		   Debit = ifnull(@Debit, 0),
		   Balance = ifnull(@ClosingBal,0)
		   where Org_Id = Var_Org_Id and 
		   MCC_Id = Var_MCC_Id and Material_Id = Var_Material_Id and date(Date) = date(Var_Date);
		
        else 
			
            insert into f006_mccstocks (Org_Id , MCC_Id , Material_Id , Date , Opening_Quantity , Credit , Debit , Balance )
            value (Var_Org_Id , Var_MCC_Id , Var_Material_Id , Var_Date ,ifnull(@OpeningBal, 0) , ifnull(@Credit, 0) , ifnull(@Debit, 0), ifnull(@ClosingBal,0)  );

		end if;

	elseif(Var_Method_Name = 'UpdateMCCStockCan') then
    
    
    set @Balance = ( select ifnull(Balance,0) from f006_mccstocks 
					where Material_Id = 'M010241000020' 
                    and Org_Id = Var_Org_Id
					and  MCC_Id = Var_MCC_Id
					and Date < @Current_Datetime 
					order by Date desc limit 1);
	
    if(@Balance is null or @Balance ='')then
		set @Balance = 0;
	end if;

 /*	
insert into f006_mccstocks (Org_Id , MCC_Id , Material_Id , Date , Opening_Quantity , Credit , Debit , Balance  )
select Var_Org_Id , t019i.MCC_Id , t019i.Material_Id , @Current_Datetime , @Balance  , t019i.Quantity , 0 , t019i.Quantity  from t019_issuestocks_item t019i 
left join f006_mccstocks f006 on t019i.Org_Id = f006.Org_Id and t019i.MCC_Id = f006.MCC_Id  and t019i.Material_Id = f006.Material_Id and date(f006.Date) = date(t019i.MCC_Accepted_On)
left join t018_issuestocks_header t018 on t018.Org_Id = t019i.Org_Id  and t018.IssueStocks_Id = t019i.IssueStocks_Id
where f006.MCC_Id is null and t019i.MCC_Id = Var_MCC_Id and StockIssue_Type = 'Cans' and t019i.Org_Id = Var_Org_Id and t019i.IssueStocks_Id = Var_IssueStocks_Id;


update f006_mccstocks f006 inner join (
select f006.Org_Id , f006.MCC_Id , f006.Material_Id , max(date(f006.Date)) as Last_Date , f006.Balance , date(@Current_Datetime) as Today_Date from t019_issuestocks_item t019i 
inner join f006_mccstocks f006 on t019i.Org_Id = f006.Org_Id and t019i.MCC_Id = f006.MCC_Id  and t019i.Material_Id = f006.Material_Id 
left join t018_issuestocks_header t018 on t018.Org_Id = t019i.Org_Id  and t018.IssueStocks_Id = t019i.IssueStocks_Id 
where date(f006.Date) < date(@Current_Datetime) and t019i.MCC_Id = Var_MCC_Id and StockIssue_Type = 'Cans' and t019i.IssueStocks_Id = Var_IssueStocks_Id
group by f006.Org_Id , f006.MCC_Id , f006.Material_Id , Balance ) A on A.Org_Id = f006.Org_Id and A.MCC_Id = f006.MCC_Id and
A.Material_Id = f006.Material_Id and A.Today_Date = f006.Date
set f006.Opening_Quantity = A.Balance,
f006.Balance = (f006.Credit - f006.Debit) + A.Balance;

*/

insert into f006_mccstocks (Org_Id , MCC_Id , Material_Id , Date , Opening_Quantity , Credit , Debit , Balance  )
select 
t018.Org_Id,t019.MCC_Id,t019.Material_Id ,@Current_Datetime as Date, @Balance as Opening_Quantity,
sum(ifnull(t019.Quantity,0)) as Credit, 0  as Debit, sum(ifnull(t019.Quantity,0)) as Balance
from t018_issuestocks_header t018
inner join t019_issuestocks_item t019 on 
t019.Org_Id = t018.Org_Id
and t019.IssueStocks_Id = t018.IssueStocks_Id
and t019.MCC_Id = Var_MCC_Id
and t019.Material_Id = 'M010241000020'
where t018.Org_Id = Var_Org_Id
and t018.IssueStocks_Id = Var_IssueStocks_Id
and t018.StockIssue_Type ='Cans'
and ifnull(t018.Driver_Id ,'') = ''
group by t018.Org_Id,t019.MCC_Id,t019.Material_Id;

update f006_mccstocks f006
set
-- f006.Opening_Quantity = A.Balance,
f006.Balance = (f006.Credit - f006.Debit)  + f006.Opening_Quantity
where f006.Org_Id = var_Org_Id
and f006.Date = @Current_Datetime
and f006.MCC_Id  = Var_MCC_Id;

       


end if;

	
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
