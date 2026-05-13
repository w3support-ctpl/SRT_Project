-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SAdminfleetx_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SAdminfleetx_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
    var_Route_Id varchar(20),
    var_Route_Name longtext,
    var_Vehicle_No longtext,
    var_Is_Active int,
    var_Is_Deleted int,
	var_CreatedBy_Id varchar(20),
	var_CreatedBy_Name varchar(255),
    var_Entry_Id varchar(20),
    var_User_Id varchar(20),
    var_Type varchar(20),
    var_Title longtext,
    var_Body longtext
)
BEGIN
	SET SQL_SAFE_UPDATES = 0;
    SET SESSION sql_require_primary_key = 0;
	if (var_Method_Name = 'Create_h') then
		begin
			Declare New_Route_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select Route_Id from m006_fleetx_route 
							where Org_Id = var_Org_Id 
                            and Route_Name = var_Route_Name 
                            and Vehicle_No = var_Vehicle_No 
                            and Is_Deleted = 0) then
					SELECT -1 AS Result_Id, 
					'A route with this name and vehicle number already exists.' AS Result_Description, 
					'' AS Result_Extra_Key;
			else
            
				set Year_Id = (select right(left(curdate(),4),(2)));
				Call USP_Number_Range ('m006_fleetx_route', Year_Id, 'M006', '', New_Route_Id );
				
				
				Insert Into m006_fleetx_route
				(Org_Id,Route_Id,Route_Name,Vehicle_No,Is_Active,Is_Deleted,Created_On,CreatedBy_Id,CreatedBy_Name,LastEdited_On)
				Values (
				var_Org_Id, New_Route_Id, var_Route_Name, var_Vehicle_No, var_Is_Active, var_Is_Deleted, now(), var_CreatedBy_Id, var_CreatedBy_Name, now()
				); 

				SELECT 1 AS Result_Id, 
				'Saved' AS Result_Description, 
				New_Route_Id AS Result_Extra_Key;
            
            end if;
            
			
        end;
	elseif (var_Method_Name = 'Update_h') then
		begin
			
            if exists(
            select Route_Id from m006_fleetx_route 
							where Org_Id = var_Org_Id 
                            and Route_Name = var_Route_Name 
                            and Vehicle_No = var_Vehicle_No 
                            and Is_Deleted = 0
                            and Route_Id <> var_Route_Id
                            
            ) then
				SELECT -1 AS Result_Id, 
				'A route with this name and vehicle number already exists.' AS Result_Description, 
				'' AS Result_Extra_Key;
			
            else
			
				update m006_fleetx_route
				set Route_Name = var_Route_Name,
				Vehicle_No = var_Vehicle_No,
				Is_Active = var_Is_Active,
				Is_Deleted = var_Is_Deleted,
				LastEdited_On = now(),
				LastEditedBy_Id =  var_CreatedBy_Id,
				LastEditedBy_Name = var_CreatedBy_Name
				where 
				Org_Id = var_Org_Id
				and Route_Id = var_Route_Id;
				
				
				SELECT 1 AS Result_Id, 
				'Updated' AS Result_Description, 
				var_Route_Id AS Result_Extra_Key;
            
            end if;
            
        end;
	elseif (var_Method_Name = 'Delete_h') then
		begin
        
			update m006_fleetx_route
            set Is_Deleted = 1,
            LastEdited_On = now(),
            LastEditedBy_Id =  var_CreatedBy_Id,
            LastEditedBy_Name = var_CreatedBy_Name
            where 
            Org_Id = var_Org_Id
            and Route_Id = var_Route_Id;
            
            
            SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Route_Id AS Result_Extra_Key;
			
        end;
	elseif (var_Method_Name = 'Create_i') then
		begin
        
			Declare New_Entry_Id varchar(20);
			Declare Year_Id varchar(10);
            
            if exists(select Entry_Id from m006_fleetx_route_item 
						where Org_Id = var_Org_Id
						and Route_Id = var_Route_Id
						and User_Id = var_User_Id limit 1) then
					SELECT -1 AS Result_Id, 
					concat('This ', var_Type ,' already exists in this route.') AS Result_Description, 
					'' AS Result_Extra_Key;
			else
            
            set Year_Id = (select right(left(curdate(),4),(2)));
			Call USP_Number_Range ('m006_fleetx_route_item', Year_Id, 'M006A', '', New_Entry_Id );
            
            
			Insert Into m006_fleetx_route_item
			(Org_Id,Entry_Id,Route_Id,Type,User_Id)
			Values (
            var_Org_Id, New_Entry_Id,var_Route_Id, var_Type, var_User_Id
            ); 
            
            update m006_fleetx_route_item
            set Is_Notify =0
            where 
            Org_Id = var_Org_Id
            and Route_Id = var_Route_Id;
            
            if(var_Type = 'Dealer')then
            
				select ShopLatitude,ShopLongitude
                into @var_ShopLatitude,@var_ShopLongitude
                from mu08_dealer
				where Org_Id = var_Org_Id
				and Dealer_Id = var_User_Id
				limit 1;
            
			elseif(var_Type = 'Retailer')then
            
				select ShopLatitude,ShopLongitude 
                into @var_ShopLatitude,@var_ShopLongitude
                from mu09_retailer
				where Org_Id = var_Org_Id
				and Retailer_Id = var_User_Id
				limit 1;
            
            end if;
            
            if(@var_ShopLatitude is null or @var_ShopLatitude = '' or 
				@var_ShopLongitude is null or @var_ShopLongitude ='')then
                
                SELECT 1 AS Result_Id, 
				'Data saved successfully, but user latitude and longitude are missing.' AS Result_Description, 
				New_Entry_Id AS Result_Extra_Key;
                
			else
            
				SELECT 1 AS Result_Id, 
				'Saved' AS Result_Description, 
				New_Entry_Id AS Result_Extra_Key;
			
            end if;


			end if;
			
			
        end;
	elseif (var_Method_Name = 'Update_i') then
		begin
			if exists(select Entry_Id from m006_fleetx_route_item 
						where Org_Id = var_Org_Id
						and Route_Id = var_Route_Id
						and User_Id = var_User_Id 
                        and Entry_Id <> var_Entry_Id
                        limit 1) then
                        
					SELECT -1 AS Result_Id, 
					concat('This ', var_Type ,' already exists in this route.') AS Result_Description, 
					'' AS Result_Extra_Key;
			else
            
			update m006_fleetx_route_item
            set Type = var_Type,
            User_Id = var_User_Id
            where 
            Org_Id = var_Org_Id
            and Entry_Id = var_Entry_Id
            and Route_Id = var_Route_Id;
            
            
            update m006_fleetx_route_item
            set Is_Notify =0
            where 
            Org_Id = var_Org_Id
            and Route_Id = var_Route_Id;
            
            
            
            update m006_fleetx_route
			set LastEdited_On = now(),
			LastEditedBy_Id =  var_CreatedBy_Id,
			LastEditedBy_Name = var_CreatedBy_Name
			where 
			Org_Id = var_Org_Id
			and Route_Id = var_Route_Id;
            
            if(var_Type = 'Dealer')then
            
				select ShopLatitude,ShopLongitude
                into @var_ShopLatitude,@var_ShopLongitude
                from mu08_dealer
				where Org_Id = var_Org_Id
				and Dealer_Id = var_User_Id
				limit 1;
            
			elseif(var_Type = 'Retailer')then
            
				select ShopLatitude,ShopLongitude 
                into @var_ShopLatitude,@var_ShopLongitude
                from mu09_retailer
				where Org_Id = var_Org_Id
				and Retailer_Id = var_User_Id
				limit 1;
            
            end if;
            
            if(@var_ShopLatitude is null or @var_ShopLatitude = '' or 
				@var_ShopLongitude is null or @var_ShopLongitude ='')then
                
                SELECT 1 AS Result_Id, 
				'Data Updated successfully, but user latitude and longitude are missing.' AS Result_Description, 
				var_Entry_Id AS Result_Extra_Key;
                
			else
            
				SELECT 1 AS Result_Id, 
				'Saved' AS Result_Description, 
				var_Entry_Id AS Result_Extra_Key;
			
            end if;
            
            end if;
            
        end;
	elseif (var_Method_Name = 'Delete_i') then
		begin
			delete from m006_fleetx_route_item
            where 
            Org_Id = var_Org_Id
            and Entry_Id = var_Entry_Id
            and Route_Id = var_Route_Id;
            
            SELECT 1 AS Result_Id, 
			'Deleted' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
        end;
	elseif (var_Method_Name = 'Update_Notify') then
		begin
			update m006_fleetx_route_item
            set Is_Notify =1,
            Title =  var_Title,
			Body = var_Body,
            Created_On = now()
            where 
            Org_Id = var_Org_Id
            and Entry_Id = var_Entry_Id
            and Route_Id = var_Route_Id;
            
            SELECT 1 AS Result_Id, 
			'Saved' AS Result_Description, 
			var_Entry_Id AS Result_Extra_Key;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:31
