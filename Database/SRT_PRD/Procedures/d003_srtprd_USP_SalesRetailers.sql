-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_SalesRetailers` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_SalesRetailers`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    Var_Profile_Id varchar(20),
    Var_SalesUser_Id varchar(20),
    Var_Usetype varchar(20),
    Var_SearchText text,
    Var_XMLData longtext,
    Var_Retailer_Id varchar(20),
    
    Var_Route_Id varchar(20),
    Var_Dealer_Id varchar(20)
)
BEGIN
	set sql_require_primary_key = 0 ;
	SET SQL_SAFE_UPDATES = 0;
    
set @Current_Datetime = (SELECT CONVERT_TZ(NOW(), '+00:00', '+00:00'));

	IF(var_Method_Name = 'GetRetailers') then 
    
    if(ifnull(Var_Route_Id,'') <> ''  and ifnull(Var_Dealer_Id,'') <> '')then
        
		select mu09.Retailer_Name, mu09.Retailer_Id, ifnull(concat(ifnull(mu09.Address_Line_1_Text,'') ,'',  ifnull(mu09.Address_Line_2_Text,'') ,' ',  ifnull(ml02.State_Name,'') ,
		' ', ifnull(ml03.District_Name, '') ,' ', ifnull(ml04.Taluka_Name,'') , ifnull(ml05.Village_Name , '')),'-') as Address ,
		DATE_FORMAT(now(), '%e %b %Y') as LastOrderDate,
		mu09.Is_Approved
		from m019_salesuserroute_header m019
		inner join m019_salesuserroute_item m019i on 
		m019i.Org_Id = m019.Org_Id
		and m019i.Route_Id = m019.Route_Id
		and m019i.Route_Id = Var_Route_Id
		inner join mu09_retailer mu09 on
		mu09.Org_Id = m019.Org_Id
		and mu09.SalesUser_Id = m019.SalesUser_Id
		and mu09.Dealer_Id = Var_Dealer_Id
		and m019i.Retailer_Id = mu09.Retailer_Id
		left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
		left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
		left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
		left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
		where m019.Org_Id =var_Org_Id
		and m019.SalesUser_Id =Var_SalesUser_Id;
        
	elseif(ifnull(Var_Route_Id,'') <> ''  and ifnull(Var_Dealer_Id,'') = '')then
    
		select mu09.Retailer_Name, mu09.Retailer_Id, ifnull(concat(ifnull(mu09.Address_Line_1_Text,'') ,'',  ifnull(mu09.Address_Line_2_Text,'') ,' ',  ifnull(ml02.State_Name,'') ,
		' ', ifnull(ml03.District_Name, '') ,' ', ifnull(ml04.Taluka_Name,'') , ifnull(ml05.Village_Name , '')),'-') as Address ,
		DATE_FORMAT(now(), '%e %b %Y') as LastOrderDate,
		mu09.Is_Approved
		from m019_salesuserroute_header m019
		inner join m019_salesuserroute_item m019i on 
		m019i.Org_Id = m019.Org_Id
		and m019i.Route_Id = m019.Route_Id
		and m019i.Route_Id = Var_Route_Id
		inner join mu09_retailer mu09 on
		mu09.Org_Id = m019.Org_Id
		and mu09.SalesUser_Id = m019.SalesUser_Id
		-- and mu09.Dealer_Id = Var_Dealer_Id
		and m019i.Retailer_Id = mu09.Retailer_Id
		left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
		left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
		left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
		left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
		where m019.Org_Id =var_Org_Id
		and m019.SalesUser_Id =Var_SalesUser_Id;
        
	elseif(ifnull(Var_Route_Id,'') = ''  and ifnull(Var_Dealer_Id,'') <> '')then
    
		
        select Retailer_Name, Retailer_Id, ifnull(concat(ifnull(Address_Line_1_Text,'') ,'',  ifnull(Address_Line_2_Text,'') ,' ',  ifnull(State_Name,'') ,
		' ', ifnull(District_Name, '') ,' ', ifnull(Taluka_Name,'') , ifnull(Village_Name , '')),'-') as Address ,
		DATE_FORMAT(now(), '%e %b %Y') as LastOrderDate,
		mu09.Is_Approved from mu09_retailer mu09
		left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
		left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
		left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
		left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
		where SalesUser_Id in (Var_SalesUser_Id) and mu09.Org_Id = var_Org_Id 
        and mu09.Dealer_Id = Var_Dealer_Id;
        
	elseif(ifnull(Var_Route_Id,'') = ''  and ifnull(Var_Dealer_Id,'') = '')then
    
        select Retailer_Name, Retailer_Id, ifnull(concat(ifnull(Address_Line_1_Text,'') ,'',  ifnull(Address_Line_2_Text,'') ,' ',  ifnull(State_Name,'') ,
		' ', ifnull(District_Name, '') ,' ', ifnull(Taluka_Name,'') , ifnull(Village_Name , '')),'-') as Address ,
		DATE_FORMAT(now(), '%e %b %Y') as LastOrderDate,
		mu09.Is_Approved from mu09_retailer mu09
		left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
		left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
		left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
		left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
		where SalesUser_Id in (Var_SalesUser_Id) and mu09.Org_Id = var_Org_Id ;
        
	else
    
        select Retailer_Name, Retailer_Id, ifnull(concat(ifnull(Address_Line_1_Text,'') ,'',  ifnull(Address_Line_2_Text,'') ,' ',  ifnull(State_Name,'') ,
		' ', ifnull(District_Name, '') ,' ', ifnull(Taluka_Name,'') , ifnull(Village_Name , '')),'-') as Address ,
		DATE_FORMAT(now(), '%e %b %Y') as LastOrderDate,
		mu09.Is_Approved from mu09_retailer mu09
		left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
		left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
		left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
		left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
		where SalesUser_Id in (Var_SalesUser_Id) and mu09.Org_Id = var_Org_Id ;
        
    end if;
		
    elseif(var_Method_Name = 'GetOneDealerRetailers') then 
    begin
		SELECT 
		mu09.Org_Id, 
		mu09.Retailer_Id, 
		ifnull(mu09.Retailer_Name,'') as Retailer_Name, 
		ifnull(m013.SalesArea_Id,'')as SalesArea_Id, 
		ifnull(m013.SalesArea_Name,'')as SalesArea_Name, 
		ifnull(mu12.SalesUser_Id,'') as SalesUser_Id, 
		ifnull(mu12.SalesUser_Name,'') as SalesUser_Name, 
		ifnull(mu08.Dealer_Id,'')  as Dealer_Id, 
		ifnull(mu08.Dealer_Name,'') as Dealer_Name, 
		IFNULL(mu09.Mobile_No,'') AS Mobile_No, 
		IFNULL(mu09.Contact_Person,'') AS Contact_Person, 
		IFNULL(mu09.Email_Id,'') AS Email_Id, 
		IFNULL(mu09.Address_Line_1_Text,'') AS Address_Line_1_Text, 
		IFNULL(mu09.Address_Line_2_Text,'') AS Address_Line_2_Text, 
		IFNULL(mu09.Address_Line_3_Text,'') AS Address_Line_3_Text, 
		ifnull(ml02.State_Id,'') as State_Id, 
		ifnull(ml02.State_Name,'') as State_Name, 
		ifnull(ml03.District_Id,'') as District_Id, 
		ifnull(ml03.District_Name,'') as District_Name, 
		ifnull(ml04.Taluka_Id,'') as Taluka_Id, 
		ifnull(ml04.Taluka_Name,'') as Taluka_Name, 
		ifnull(ml05.Village_Id,'') as Village_Id, 
		ifnull(ml05.Village_Name,'') as Village_Id, 
		ifnull(mu09.Pincode,'') as Pincode, 
		ifnull(mu09.Pan_No,'')as Pan_No, 
		ifnull(mu09.ShopLatitude,'') as ShopLatitude, 
		ifnull(mu09.ShopLongitude,'') as ShopLongitude,
		ifnull(mu09.Shop_License_No,'') as Shop_License_No, 
		ifnull(mu09.Pan_Card_Photo,'') as Pan_Card_Photo, 
		ifnull(mu09.Shop_License_Photo,'') as Shop_License_Photo, 
		ifnull(mu09.Cheque_Leaf_Photo,'')as Cheque_Leaf_Photo, 
		ifnull(mu09.Shop_Name_Photo,'') as Shop_Name_Photo, 
		ifnull(m015.Bank_Id,'') as Bank_Id, 
		ifnull(m015.Bank_Name,'') as Bank_Name, 
		ifnull(m016.Branch_Id,'') as Branch_Id, 
		ifnull(m016.Branch_Name,'') as Branch_Name, 
		ifnull(mu09.Account_No,'') as Account_No, 
		ifnull(mu09.IFSC_Code,'') as IFSC_Code, 
		ifnull(mu09.Account_Name,'') as Account_Name, 
		ifnull(mu09.FSSAI_License_No,'') as FSSAI_License_No, 
		ifnull(DATE_FORMAT(mu09.FSSAI_LicenseValidity_On, '%Y-%m-%d'),'') AS FSSAI_LicenseValidity_On,  
		CONCAT(
		ifnull(DATE_FORMAT(mu09.AgreementValidiy_StartDate,'%m/%d/%Y'),''),
		' - ', 
		ifnull(DATE_FORMAT(mu09.AgreementValidity_EndDate,'%m/%d/%Y'),'')
		) AS Agreement_Validity_Period, 
		ifnull(mu09.UdyamAadhar_Card_Photo,'') as UdyamAadhar_Card_Photo, 
		ifnull(mu09.FSSAI_License_Photo,'') as FSSAI_License_Photo, 
		ifnull(mu09.GST_Certificate_Photo,'') as GST_Certificate_Photo, 
		ifnull(mu09.Is_Agreement_Done,'') as Is_Agreement_Done, 
		ifnull(mu09.SecurityDepositAmount,'') as SecurityDepositAmount, 
		ifnull(mu09.Is_Active,'') as Is_Active, 
		ifnull(mu09.Is_Deleted,'') as Is_Deleted,
		ifnull(mu09.MSME,'') as MSME,
        ifnull(mu09.GST_No,'') as GST_No,
        ifnull(mu09.Aadhar_No,'') as Aadhar_No,
        ifnull(mu09.ASME,'') as ASME
		FROM mu09_retailer mu09
		left join m013_salesarea m013 on
		m013.Org_Id = mu09.Org_Id
		and m013.SalesArea_Id = mu09.SalesArea_Id
		left join mu12_sales_user mu12 on
		mu12.Org_Id = mu09.Org_Id
		and mu12.SalesUser_Id = mu09.SalesUser_Id
		left join mu08_dealer mu08 on
		mu08.Org_Id = mu09.Org_Id
        and mu08.Is_Active = 1
		and mu08.Dealer_Id = mu09.Dealer_Id

		left join ml02_state ml02 on
		ml02.Org_Id = mu09.Org_Id
		and ml02.State_Id = mu09.State_Id

		left join ml03_district ml03 on
		ml03.Org_Id = mu09.Org_Id
		and ml03.District_Id = mu09.District_Id
		and ml03.State_Id = mu09.State_Id

		left join ml04_taluka ml04 on
		ml04.Org_Id = mu09.Org_Id
		and ml04.Taluka_Id = mu09.Taluka_Id
		and ml04.District_Id = mu09.District_Id
		and ml04.State_Id = mu09.State_Id

		left join ml05_village ml05 on
		ml05.Org_Id = mu09.Org_Id
		and ml05.Village_Id = mu09.Village_Id
		and ml05.Taluka_Id = mu09.Taluka_Id
		and ml05.District_Id = mu09.District_Id
		and ml05.State_Id = mu09.State_Id

		left join m015_bank m015 on
		m015.Org_Id = mu09.Org_Id
		and m015.Bank_Id = mu09.Bank_Id

		left join m016_branch m016 on
		m016.Org_Id = mu09.Org_Id
		and m016.Bank_Id = mu09.Bank_Id
		and m016.Branch_Id = mu09.Branch_Id

		WHERE mu09.Org_Id = var_Org_Id
		AND mu09.Retailer_Id = Var_Retailer_Id ;
    end;
-- where made serch add krych like 
	elseif(var_Method_Name = 'GetDealerRetailers') then 
    begin
    
		select mu09.Dealer_Id ,  Retailer_Name, Retailer_Id, ifnull(concat(ifnull(Address_Line_1_Text,'') ,'',  ifnull(Address_Line_2_Text,'') ,' ',  ifnull(State_Name,'') ,
		' ', ifnull(District_Name, '') ,' ', ifnull(Taluka_Name,'') , ifnull(Village_Name , '')),'-') as Address ,
		DATE_FORMAT(now(), '%e %b %Y') as LastOrderDate,
		mu09.Is_Approved from mu09_retailer mu09
		left join ml02_state ml02 on ml02.Org_Id = mu09.Org_Id and ml02.State_Id = mu09.State_Id
		left join ml03_district ml03 on mu09.Org_Id = ml03.Org_Id and ml03.District_Id = mu09.District_Id
		left join ml04_taluka ml04 on mu09.Org_Id = ml04.Org_Id and mu09.Taluka_Id = ml04.Taluka_Id
		left join ml05_village ml05 on mu09.Org_Id = ml05.Org_Id and mu09.Village_Id = ml05.Village_Id
		where SalesUser_Id in ( Var_SalesUser_Id ) and mu09.Org_Id = var_Org_Id
        and mu09.Is_Approved = 1
		and mu09.Dealer_Id = Var_Retailer_Id;
    
    
    end;
	elseif(var_Method_Name = 'CreateRetailer') then 
    
    begin
			Declare RowCnt int;
			Declare var_CursorTestID int;
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE i INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;

			-- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_data;
			CREATE TEMPORARY TABLE temp_data (PKeyRowNum int, Field_Name varchar(50),
			Field_Value text);
			
			SET row_count := extractValue(Var_XMLData,'count(//D/R)');
			Set k := 0;
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
				INSERT INTO temp_data VALUES (
					k,
					extractValue(var_XMLData, concat(xpath,'/FN')),
					extractValue(var_XMLData, concat(xpath,'/FV'))
				);
			END WHILE;
            
            
            set @MobileNo = (select Field_Value from temp_data where Field_Name = 'Mobile_No' limit 1);
            
            
		if exists (select 1 from mu09_retailer where Org_Id = var_Org_Id and Mobile_No = @MobileNo and Is_Active = 1 ) then
            
			select -1 as Result_Id, 'Mobile_Already Exist' as Result_Description, '' as Result_Extra_Key; 
            
		else 
				
        		set @Year_Id = (select right(left(curdate(),4),(2)));
                SET @New_Retailer_Id = '';
				Call USP_Number_Range ('mu09_retailer', @Year_Id, 'MU09', '', @New_Retailer_Id );
            
				insert into mu09_retailer (Org_Id, Retailer_Id , Created_On , CreatedBy_Id , CreatedBy_Name ) VALUE
                (var_Org_Id , @New_Retailer_Id , @Current_Datetime , Var_Profile_Id , (SELECT SalesUser_Name FROM
                mu12_sales_user  WHERE Org_Id = var_Org_Id AND SalesUser_Id = Var_Profile_Id LIMIT 1) );
                
                set @RowCnt = (select COUNT(*) from temp_data);
                
			
			set @var_CursorTestID =1;
         
			While @var_CursorTestID <= @RowCnt Do
            
				set @var_Field_Name = (Select Field_Name from temp_data where PKeyRowNum = @var_CursorTestID);
				set @var_Field_Value = (Select Field_Value from temp_data where PKeyRowNum = @var_CursorTestID);
				set @var_Org_Id = var_Org_Id;
				
 
                SET @var_SQL = CONCAT('Update mu09_retailer set ', @var_Field_Name , ' = ''', @var_Field_Value , ''' where  Org_Id = ''', @var_Org_Id , ''' and Retailer_Id = ''', @New_Retailer_Id,'''');
                
                PREPARE dynamic_statement FROM @var_SQL;

				EXECUTE dynamic_statement;
				DEALLOCATE PREPARE dynamic_statement;	
                    
				Set @var_CursorTestID = @var_CursorTestID + 1;

			END WHILE;
             
            drop temporary table temp_data;
            
            select 1 as Result_Id, 'Saved' as Result_Description, @New_Retailer_Id as Result_Extra_Key; 
            

            
	    end if;
		
    end;
    
elseif(var_Method_Name = 'UpdateRetailer') then 

    begin
			Declare RowCnt int;
			Declare var_CursorTestID int;
			DECLARE k INT UNSIGNED DEFAULT 0;
			DECLARE i INT UNSIGNED DEFAULT 0;
			DECLARE row_count INT UNSIGNED;
			DECLARE xpath TEXT;

			-- Convert XML Data to Table format
			DROP TEMPORARY TABLE IF EXISTS temp_data;
			CREATE TEMPORARY TABLE temp_data (PKeyRowNum int, Field_Name varchar(50),
			Field_Value text);
			
			SET row_count := extractValue(Var_XMLData,'count(//D/R)');
			Set k := 0;
			WHILE k < row_count DO        
				SET k := k + 1;
				SET xpath := concat('//D/R[', k, ']');
				INSERT INTO temp_data VALUES (
					k,
					extractValue(var_XMLData, concat(xpath,'/FN')),
					extractValue(var_XMLData, concat(xpath,'/FV'))
				);
			END WHILE;
            
            
            set @MobileNo = (select Field_Value from temp_data where Field_Name = 'Mobile_No' limit 1);
            
            
		if exists (select 1 from mu09_retailer where Org_Id = var_Org_Id and Mobile_No = @MobileNo and Is_Active = 1 and Retailer_Id <> Var_Retailer_Id) then
            
			select -1 as Result_Id, 'Mobile_Already Exist' as Result_Description, '' as Result_Extra_Key; 
            
		else 
				
			SET @New_Retailer_Id = Var_Retailer_Id;

			set @RowCnt = (select COUNT(*) from temp_data);
                
			set @var_CursorTestID =1;
         
			While @var_CursorTestID <= @RowCnt Do
            
				set @var_Field_Name = (Select Field_Name from temp_data where PKeyRowNum = @var_CursorTestID);
				set @var_Field_Value = (Select Field_Value from temp_data where PKeyRowNum = @var_CursorTestID);
				set @var_Org_Id = var_Org_Id;
				
 
                SET @var_SQL = CONCAT('Update mu09_retailer set ', @var_Field_Name , ' = ''', @var_Field_Value , ''' where  Org_Id = ''', @var_Org_Id , ''' and Retailer_Id = ''', @New_Retailer_Id,'''');
                
                PREPARE dynamic_statement FROM @var_SQL;

				EXECUTE dynamic_statement;
				DEALLOCATE PREPARE dynamic_statement;	
                    
				Set @var_CursorTestID = @var_CursorTestID + 1;

			END WHILE;
             
            drop temporary table temp_data;
            
            select 1 as Result_Id, 'Saved' as Result_Description, @New_Retailer_Id as Result_Extra_Key; 
    
	    end if;
		
    end;
    
    elseif(var_Method_Name = 'GetRouteBySalesUser') then 
		begin
			select 
			m019.Route_Id,ifnull(m019.Route_Name,'')  as Route_Name
            -- ,c045.RouteDay_Id,c045.RouteDay_Name
			from m019_salesuserroute_header m019
			inner join c045_route_day c045 on
			c045.RouteDay_Id = m019.RouteDay_Id
			-- and c045.RouteDay_Name = DAYNAME(CURDATE())
			where m019.Org_Id = var_Org_Id
			and m019.SalesUser_Id = Var_SalesUser_Id
            group by m019.Route_Id,m019.Route_Name;
		end;
	elseif(var_Method_Name = 'GetRetailerBySalesUserAndRoute') then 
		begin
			select 
			-- m019.Route_Id, 
            mu09.Retailer_Id,mu09.Retailer_Name
			from m019_salesuserroute_item m019
			inner join mu09_retailer mu09 on
			mu09.Org_Id = m019.Org_Id
			and mu09.Retailer_Id = m019.Retailer_Id
			where m019.Org_Id = var_Org_Id
			and m019.SalesUser_Id = Var_SalesUser_Id 
			and m019.Route_Id = Var_Route_Id
            group by mu09.Retailer_Id,mu09.Retailer_Name;
		end;
	elseif(var_Method_Name = 'GetDealerByRetailer') then 
		begin
			select  
			mu08.Dealer_Id,mu08.Dealer_Name 
			from mu09_retailer mu09
			inner join mu08_dealer mu08 on
			mu08.Org_Id = mu09.Org_Id
			and mu08.Dealer_Id = mu09.Dealer_Id
            and mu08.Is_Active = 1
			where mu09.Org_Id = var_Org_Id
			and mu09.Retailer_Id = Var_Retailer_Id 
            group by mu08.Dealer_Id,mu08.Dealer_Name;
		end;
	elseif(var_Method_Name = 'GetDealerBySalesUser_V1') then 
		begin
			/*
			select mu08.Dealer_Id,mu08.Dealer_Name 
			from mu08_dealer mu08
			where mu08.Org_Id = var_Org_Id
			and mu08.SalesUser_Id = Var_SalesUser_Id 
			group by mu08.Dealer_Id,mu08.Dealer_Name;
            */
            
            SELECT Dealer_Id, Dealer_Name
			FROM (
				SELECT mu08.Dealer_Id, mu08.Dealer_Name
				FROM mu08_dealer mu08
				WHERE mu08.Org_Id = var_Org_Id
                and mu08.Is_Active = 1
				AND mu08.SalesUser_Id = Var_SalesUser_Id

				UNION ALL

				SELECT mu08.Dealer_Id, mu08.Dealer_Name
				FROM m019_salesuserroute_item_dealer m019
				INNER JOIN mu08_dealer mu08 
					ON mu08.Org_Id = m019.Org_Id
					AND mu08.Dealer_Id = m019.Dealer_Id
                    and mu08.Is_Active = 1
				WHERE m019.Org_Id = var_Org_Id
				AND m019.SalesUser_Id = Var_SalesUser_Id
			) AS t
			GROUP BY Dealer_Id, Dealer_Name
            ORDER BY Dealer_Name;
		end;
	elseif(var_Method_Name = 'GetRouteByDealer_SalesUser_V1') then 
		begin
			/*
			select 
			m019.Route_Id,ifnull(m019.Route_Name,'')  as Route_Name
			from mu19_route m019
			where m019.Org_Id = var_Org_Id
			-- and m019.SalesUser_Id = Var_SalesUser_Id
			and m019.Dealer_Id = Var_Dealer_Id
			group by m019.Route_Id,m019.Route_Name;
            
            */
            
            SELECT 
				Route_Id,
				Route_Name
			FROM
			(
            /*
				SELECT 
					m019.Route_Id,
					IFNULL(m019.Route_Name,'') AS Route_Name
				FROM mu19_route m019
				WHERE m019.Org_Id = var_Org_Id
				  AND m019.Dealer_Id = Var_Dealer_Id
				GROUP BY m019.Route_Id, m019.Route_Name

				UNION ALL
                
                */

				SELECT 
					mu19.Route_Id,
					mu19.Route_Name
				FROM m019_salesuserroute_header m019
				INNER JOIN c045_route_day c045 
					ON c045.RouteDay_Id = m019.RouteDay_Id
				   -- AND c045.RouteDay_Name = DAYNAME(CURDATE())
				INNER JOIN mu19_route mu19 
					ON mu19.Org_Id = m019.Org_Id
				   AND mu19.Route_Id = m019.Route_Id
				WHERE m019.Org_Id = var_Org_Id
				  AND m019.SalesUser_Id = Var_SalesUser_Id
			) AS t
			GROUP BY Route_Id, Route_Name
            ORDER BY Route_Name;
		end;
	elseif(var_Method_Name = 'GetRetailer_ByRoute_SalesUser_Dealer_V1') then 
		begin
			
            /*
            select  
			mu09.Retailer_Id,mu09.Retailer_Name
			from mu19_route mu19
            inner join mu19_route_retailer_mapping mu19i on
            mu19.Org_Id = mu19i.Org_Id
            and mu19.Route_Id = mu19i.Route_Id
            inner join mu09_retailer mu09 on
            mu09.Org_Id = mu19i.Org_Id
            and mu09.Retailer_Id = mu19i.Retailer_Id
            where mu19.Org_Id = var_Org_Id
            and mu19.Route_Id = Var_Route_Id
            and mu19.Dealer_Id = Var_Dealer_Id
            group by mu09.Retailer_Id,mu09.Retailer_Name;
            */
            
            SELECT 
				Retailer_Id,
				Retailer_Name
			FROM
			(
				SELECT  
					mu09.Retailer_Id,
					mu09.Retailer_Name
				FROM mu19_route mu19
				INNER JOIN mu19_route_retailer_mapping mu19i 
					ON mu19.Org_Id = mu19i.Org_Id
				   AND mu19.Route_Id = mu19i.Route_Id
				INNER JOIN mu09_retailer mu09 
					ON mu09.Org_Id = mu19i.Org_Id
				   AND mu09.Retailer_Id = mu19i.Retailer_Id
				WHERE mu19.Org_Id = var_Org_Id
				  AND mu19.Route_Id = Var_Route_Id
				  AND mu19.Dealer_Id = Var_Dealer_Id
				GROUP BY mu09.Retailer_Id, mu09.Retailer_Name

				UNION ALL

				SELECT  
					mu09.Retailer_Id,
					mu09.Retailer_Name
				FROM mu19_route mu19
				INNER JOIN mu19_route_retailer_mapping mu19i 
					ON mu19.Org_Id = mu19i.Org_Id
				   AND mu19.Route_Id = mu19i.Route_Id
				INNER JOIN mu09_retailer mu09 
					ON mu09.Org_Id = mu19i.Org_Id
				   AND mu09.Retailer_Id = mu19i.Retailer_Id
				WHERE mu19.Org_Id =  var_Org_Id
				  AND mu19.Route_Id = Var_Route_Id
				GROUP BY mu09.Retailer_Id, mu09.Retailer_Name
			) AS t
			GROUP BY Retailer_Id, Retailer_Name
            ORDER BY Retailer_Name;
		end;
    end if;
		
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
