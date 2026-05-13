-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminDealerSalesGroup_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminDealerSalesGroup_Set`(
var_Method_Name varchar(50),
	var_Org_Id varchar(20),
	var_XML_Data longtext
)
BEGIN
SET SQL_SAFE_UPDATES = 0;

	set @Year_Id = (select right(left(curdate(),4),(2)));
		set @k = 0;
        set @test = 0;
		SET @row_count := extractValue(var_XML_Data,'count(//Dealer/DealerData)');
			WHILE @k < @row_count DO
				SET @k := @k + 1;
                
				SET @xpath := concat('//Dealer/DealerData[', @k, ']');
                
                set @Dealer_Id = (select Dealer_Id from mu08_dealer where Org_Id = var_Org_Id and Dealer_Code =
				extractValue(var_XML_Data, concat(@xpath,'/DealerCode')) limit 1);
                
                if(@test = 0)then
					SET SQL_SAFE_UPDATES = 0;
					delete from m022_dealer_distchannel
					where Org_Id = var_Org_Id
					and Dealer_Id =  @Dealer_Id;
                    
                    set @test = 1;
                end if;
                
		
        
       

                
		if EXISTS(select Entry_Id from m022_dealer_distchannel
					where Org_Id = var_Org_Id
					and Dealer_Id =  @Dealer_Id
					and SalesOrg_Code = extractValue(var_XML_Data, concat(@xpath,'/SalesOrganization'))
					and DistChannel_Code = extractValue(var_XML_Data, concat(@xpath,'/DistributionChannel'))
					and Division_Code = extractValue(var_XML_Data, concat(@xpath,'/Division')) limit 1) then 
                
               update m022_dealer_distchannel 
				set SalesOrg_Code = extractValue(var_XML_Data, concat(@xpath,'/SalesOrganization')),
					DistChannel_Code = extractValue(var_XML_Data, concat(@xpath,'/DistributionChannel')),
					Division_Code = extractValue(var_XML_Data, concat(@xpath,'/Division'))
				where Org_Id = var_Org_Id 
				and Dealer_Id = @Dealer_Id
                and Entry_Id = @var_Entry_Id
                ;
                    
			else
            
			
				CALL USP_Number_Range ('m022_dealer_distchannel', @Year_Id, 'M022', '', @New_Entry_Id );


                insert into m022_dealer_distchannel (Org_Id, Entry_Id, Dealer_Id, SalesOrg_Code, DistChannel_Code, Division_Code)
				value (
				var_Org_Id,@New_Entry_Id,@Dealer_Id,
				extractValue(var_XML_Data, concat(@xpath,'/SalesOrganization')),
				extractValue(var_XML_Data, concat(@xpath,'/DistributionChannel')),
				extractValue(var_XML_Data, concat(@xpath,'/Division'))
				);
               
			end if;
   
			END WHILE;
            
 
		SELECT 1 AS Result_Id, 
		'Downloaded' AS Result_Description, 
		'' AS Result_Extra_Key;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
