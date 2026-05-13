-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_Number_Range` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_Number_Range`(
	var_Table_Name varchar(50),
	var_Year_Id varchar(20),
	var_Number_Prefix varchar(20),
	var_Number_Suffix varchar(20),
	out New_Id varchar(30) 
)
BEGIN
	Declare RecNo varchar(20);                                
	Declare LastNum bigint;  
        
	Set RecNo = null;
	Set RecNo = (Select Last_Number_Used as Last_Number from s001_number_range where
	Table_Name = var_Table_Name 
	and Year_Id = var_Year_Id 
	and Number_Prefix = var_Number_Prefix 
	and Number_Suffix = var_Number_Suffix);    
    
	   
	if (isnull(RecNo) = 1) then
			insert into s001_number_range(Table_Name, Year_Id,
			Number_Prefix, Number_Suffix, Start_Number, End_Number, Last_Number_Used)                              
			values (var_Table_Name, var_Year_Id, 
			var_Number_Prefix, var_Number_Suffix, 1, 9999999, 1000001); 
            
			set LastNum = 1000001;                                              
	else                            
			set LastNum = RecNo + 1;                              
            
			update s001_number_range set Last_Number_Used = LastNum where 
			Table_Name = var_Table_Name
			and Year_Id = var_Year_Id 
			and Number_Prefix = var_Number_Prefix 
			and Number_Suffix = var_Number_Suffix;                              
	end if;
    
	SET New_Id = (select concat(var_Number_Prefix , var_Year_Id , cast(LastNum as char) , var_Number_Suffix)); 
    
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:30
