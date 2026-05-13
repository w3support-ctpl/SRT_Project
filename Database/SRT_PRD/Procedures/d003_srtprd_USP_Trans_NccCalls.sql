-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_Trans_NccCalls` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_Trans_NccCalls`(IN `var_method` VARCHAR(50), IN `var_user_id` VARCHAR(50), IN `var_serviceid` VARCHAR(50), IN `var_remarkid` VARCHAR(50), IN `var_remark` VARCHAR(200), IN `var_latitude` VARCHAR(50), IN `var_longitude` VARCHAR(50), IN `var_call_id` VARCHAR(50), IN `var_sapcall_no` VARCHAR(50), IN `var_propertyid` VARCHAR(50))
if var_method = 'GetLocation' then 
		BEGIN
        
 
		Set @UserRole = '' ;
			select user_role into @UserRole from m011_ncc_user m011 inner join t011_property t011 on m011.user_id = t011.user_id 
			where t011.user_id = var_user_id limit 1;
            
				Begin
					if @UserRole = 'Owner' then 
						select 1 as ResultFlag, property_id, ifnull(CONCAT(manager_first_name,' ',manager_last_name),'-') as First_Name, ifnull(manager_last_name,'-') as Last_Name, ifnull(manager_mobile_number,'-') as Mobile_Number, ifnull(region,'-') as Region ,ifnull(city1,'-') as City1 ,city2 as City2 ,city3 as City3,
 ifnull(property_type_id,'--') as property_type_id , 
                        ifnull(area_latitude,'-')as area_latitude  , ifnull(area_longitute,'-') as area_longitute from t011_property  where user_id = var_user_id ORDER by property_id desc  
                       ;
                        
                    elseif @UserRole = 'Property Incharge' then 
						select 1 as ResultFlag, property_id ,ifnull(CONCAT(owner_first_name,' ',owner_last_name),'-')  as First_Name, ifnull(owner_last_name,'-') as Last_Name, ifnull(owner_mobile_number,'-') as Mobile_Number, ifnull(property_type_id,'--') as property_type_id , ifnull(region,'-') as Region ,ifnull(city1,'-') as City1 ,city2 as City2 ,city3 as City3,
                        ifnull(area_latitude,'-') as area_latitude  , ifnull(area_longitute,'-')as area_longitute from t011_property where user_id = var_user_id ORDER by property_id desc  ;
                        
                  
					end if ;
				end;
		END ;
        
        ELSEIF (var_method = 'CreateCall')then 
        					
                          
                    IF EXISTS (SELECT 1 from t001_calls WHERE property_id = var_propertyid and service_id = var_serviceid and call_status = 'open' )then 
                    
                   select 0 as Result_Flag, 'Call is open' as Result_Msg, 'Call is open' as Result_Details ;
                           
                     
                     else 
                           
                    set @Year_Id = (select right(left(curdate(),4),(2)));

                    Call USP_Number_Range ('t001_calls', @year_id, 'T001', '', @new_call_id );
					
					insert into t001_calls (call_id, company_id,
					service_id, location_id,equipment_id,remark_id,Is_Active,is_deleted,Created_By,Created_On,
                    location_langitude,location_latitude, additional_info , call_status, property_id )
					
					value (@new_call_id, 'NCC',var_serviceid, 
					'104391', '1004218', var_remarkid, 1, 0, var_user_id, now() , var_longitude , var_latitude , var_remark , 'OPEN' , var_propertyid) ;
					
     
     select concat( owner_first_name, '|' , owner_last_name , '|' , owner_civil_id , '|' , owner_mobile_number) , 
concat( manager_first_name, '|' , manager_last_name, '|' , manager_civil_id, '|' , manager_mobile_number) ,
concat(property_type_id, '|' , service_type_id , '|' ,coverage_type_id) , 
concat(region, '|' , city1 , '|' , city2 , '|' , city3),
concat(area_latitude, '|' , area_longitute) 
into @owener , @manager , @property , @city , @area 
from t011_property WHERE property_id = var_propertyid limit 1;

set @Role = (SELECT user_role from m011_ncc_user WHERE user_id = var_user_id limit 1);

set @details = (SELECT concat(first_name,'|' , last_name , '|' ,civil_id,'|' , mobile_number) FROM m011_ncc_user
               WHERE user_id = var_user_id limit 1);

				          
        select 1 as Result_Flag, location_id as locationid , ifnull(@new_call_id,'') as CallId,
        equipment_id as equipement , 'X' as newflag , ifnull(IF(@Role = 'Owner' , @details , @owener )  ,'')as ownerdetail , 
        ifnull(IF(@Role = 'Owner' , @manager , @details ),'') as managerdetail , ifnull(@property,'') as typeid , ifnull(@city, '') as address ,  ifnull(@area ,'')  as arealocation 
        
        from t001_calls WHERE call_id = @new_call_id;
     
     end if;
                    
       ELSEIF (var_method = 'UpdateCall')then 
        
		
        UPDATE t001_calls
        set sap_call_id = var_sapcall_no,
        call_number = var_sapcall_no
        WHERE call_id = var_call_id;
        

end if ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
