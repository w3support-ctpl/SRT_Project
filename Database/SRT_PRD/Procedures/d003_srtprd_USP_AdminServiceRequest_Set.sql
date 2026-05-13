-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminServiceRequest_Set` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminServiceRequest_Set`(
	var_Method_Name varchar(50),
    var_Org_Id varchar(10),
	var_Request_Id varchar(20),
	var_User_Id varchar(20),
	var_User_Name varchar(45),
	var_ApprovalStatus_Id int,
    var_ApprovalRemarks longtext,
    var_Approved_Amount DECIMAL(8,2),
    var_VeterinaryService_Date DATETIME,
	var_Request_For varchar(20),
	var_Order_Type varchar(20),
    var_ServiceType_Id varchar(20),
    var_Order_Data LONGTEXT,
    var_Quantity varchar(50),
    var_Product_Id varchar(50),
    var_MCC_Id varchar(50)
)
BEGIN
	DECLARE New_Deductions_Header_Id VARCHAR(45);
    DECLARE New_Entry_Id VARCHAR(45);
    DECLARE Year_Id VARCHAR(10);
    DECLARE New_Request_User_Id VARCHAR(45);
	IF (var_Method_Name = 'Update') THEN
    BEGIN
		-- material
		IF(var_ServiceType_Id = 'C026003') THEN
		BEGIN
			IF(var_ApprovalStatus_Id = 1) THEN
			BEGIN
				DECLARE k INT UNSIGNED DEFAULT 0;
				DECLARE row_count INT UNSIGNED;
				DECLARE xpath TEXT;
				DECLARE New_Product_Id VARCHAR(20);
				DECLARE New_Approved_Quantity INT;
                DECLARE New_Total_Price DECIMAL(10,2);
                DECLARE Material_Total_Price DECIMAL(10,2);
                SET Material_Total_Price = 0.00;
                
                    
				SET row_count := extractValue(var_Order_Data,'count(//Products/ProductItem)');
				WHILE k < row_count 
				DO        
					SET k := k + 1;
					SET xpath := concat('//Products/ProductItem[', k, ']');
            
					SET New_Product_Id = extractValue(var_Order_Data, concat(xpath,'/Product_Id'));
					SET New_Approved_Quantity = extractValue(var_Order_Data, concat(xpath,'/Approved_Quantity'));
					
                    
					UPDATE t023_order_item
					SET Approved_Quantity = New_Approved_Quantity,
						Total_Price = (New_Approved_Quantity * CAST(Rate AS DECIMAL(10,2)))
					WHERE Product_Id = New_Product_Id
					AND Order_Id = var_Request_Id
					AND Org_Id = var_Org_Id;
				END WHILE;
                
				UPDATE t023_order_header
				SET Approval_Remarks = var_ApprovalRemarks,
					Approved_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
					Is_Approved = var_ApprovalStatus_Id,
					Approved_Id = var_User_Id,
					Approved_Name = var_User_Name
				WHERE Org_Id = var_Org_Id 
				AND Order_Id = var_Request_Id
				AND Order_For = var_Request_For;  
                
                SET New_Request_User_Id = (
					SELECT Order_For_User_Id
                    FROM t023_order_header
                    WHERE Org_Id = var_Org_Id 
					AND Order_Id = var_Request_Id
					AND Order_For = var_Request_For
                );
                
				/*
				SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
				CALL USP_Number_Range ('t033_deductions_header', Year_Id, 'T033', '', New_Deductions_Header_Id);
                Call USP_Number_Range ('t033_deductions_item', Year_Id, 'T033A', '', New_Entry_Id );
                
                SET Material_Total_Price = (
						SELECT SUM(Total_Price)
                        FROM t023_order_item
                        WHERE Order_Id = var_Request_Id
						AND Org_Id = var_Org_Id
					);
                    
			*/
                    
				set @MCC_Id = (select MCC_Id   
                from  t023_order_header 
                where Order_Id = var_Request_Id 
                and Org_Id = var_Org_Id limit 1) ;
                
                set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = @MCC_Id and is_deleted = 0 and 
					Applicable_Date <= now() and Org_Id = Var_Org_Id
					order by Applicable_Date desc limit 1 ) ;
                    
                    Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
                    
                    
					if(@MusterType = 1)then 
					
						Set @MusterCycle_StartDate = now();
						set @MusterCycle_EndDate =  now();
                    
                    elseif(@MusterType = 7) then 
						
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 7 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-07');
                        
                        elseif(DATE_FORMAT(now(), '%d') BETWEEN 8 AND 14) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-08');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-14');

						elseif(DATE_FORMAT(now(), '%d') BETWEEN 15 AND 21) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-15');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-21');
                        
                      elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
					
                    end if;
                        
				elseif(@MusterType = 15) then 
                        
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 15 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
                        
                        else 
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
							set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                        
                        end if;
                        
					elseif(@MusterType = 5) then 
                        
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 5 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-05');
                        
					elseif(DATE_FORMAT(now(), '%d') BETWEEN 6 AND 10) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-06');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');

					elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 15) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-15');
                        
                      elseif(DATE_FORMAT(now(), '%d') BETWEEN 16 AND 20 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');
                        
					elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 25 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-25');
					
                    elseif(DATE_FORMAT(now(), '%d') BETWEEN 26 AND 31 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                    
                    end if;
                    
				elseif(@MusterType = 10) then 
                        
                        if (DATE_FORMAT(now(), '%d') BETWEEN 1 AND 10 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-10');
                        
                        elseif(DATE_FORMAT(now(), '%d') BETWEEN 11 AND 20) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(CURDATE(), '%Y-%m-20');

						elseif(DATE_FORMAT(now(), '%d') BETWEEN 21 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-21');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                    
                    end if;
                
					elseif(@MusterType = 30) then 
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(CURDATE(), '%Y-%m-01');
						set @MusterCycle_EndDate =  LAST_DAY(CURDATE());
                        
				end if;
				/*
                
				-- Insert new row in Deductions Header table on Approval of Material
				INSERT INTO t033_deductions_header(
					Org_Id, Deductions_Id, Entry_Date, 
                    Request_User_Type, Request_User_Id, MCC_Id,
                    Request_Type, Total_Amount, 
                    Amount_Deducted, Balance, 
                    Is_Closed, No_Of_Installments, 
                    CreatedBy_Id, CreatedBy_Name 
                )
                VALUES(
					var_Org_Id, New_Deductions_Header_Id, CONVERT_TZ(NOW(), '+00:00', '+00:00'),
                    var_Request_For, @MCC_Id,@MCC_Id ,
                    'M020231000008', Material_Total_Price,
                    0, Material_Total_Price,
                    0, 1,
                    var_User_Id, var_User_Name
				);
                
				INSERT INTO t033_deductions_item (
                Org_Id,Entry_Id, Deductions_Id, Deduction_Date, Deduction_Amount, Is_Deducted, 
                MusterCycle_StartDate, MusterCycle_EndDate) 
                VALUE 
                (Var_Org_Id ,New_Entry_Id, New_Deductions_Header_Id , now() , 
                Material_Total_Price, 0 , @MusterCycle_StartDate ,
                @MusterCycle_EndDate ) ;
                */
                
                UPDATE t023_order_item
				SET MusterCycle_StartDate = @MusterCycle_StartDate,
					MusterCycle_EndDate = @MusterCycle_EndDate,
                    Is_Posted = 1
				WHERE Order_Id = var_Request_Id
				AND Org_Id = var_Org_Id;
                
				SELECT 1 AS Result_Id, 
				'Approved' AS Result_Description, 
				var_Request_Id AS Result_Extra_Key;
			END;
			ELSE 
			-- Rejected
			BEGIN
				UPDATE t023_order_header
				SET Approval_Remarks = var_ApprovalRemarks,
					Approved_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
					Is_Approved = var_ApprovalStatus_Id,
					Approved_Id = var_User_Id,
					Approved_Name = var_User_Name
				WHERE Org_Id = var_Org_Id 
				AND Order_Id = var_Request_Id
				AND Order_Type = var_Order_Type;  
            
				SELECT 1 AS Result_Id, 
				'Rejected' AS Result_Description, 
				var_Request_Id AS Result_Extra_Key;
			END;
			END IF;
		-- service type material end
		END;
        -- for other services
		ELSE
		BEGIN
			UPDATE t003_service
			SET 
				Approved_On = CONVERT_TZ(NOW(), '+00:00', '+00:00'),
				Approved_Id = var_User_Id,
				Approved_Name = var_User_Name,
				Is_Approved = var_ApprovalStatus_Id,
				Approval_Remarks = var_ApprovalRemarks,
				Approved_Amount = var_Approved_Amount,
				VeterinaryService_Date = var_VeterinaryService_Date
			WHERE Org_Id = var_Org_Id 
			AND Request_Id = var_Request_Id;   

			IF (var_ApprovalStatus_Id = 1) THEN
			BEGIN
            
				-- insert into deductions header table for Financial Services
                if(var_ServiceType_Id = 'C026002') THEN
                BEGIN
					
                    -- Generate Deductions Header ID
                    
                    SET Year_Id = (SELECT RIGHT(LEFT(CURDATE(),4),(2)));
					CALL USP_Number_Range ('t033_deductions_header', Year_Id, 'T033', '', New_Deductions_Header_Id);
                
					SET New_Request_User_Id = (
						SELECT Request_For_User_Id
						FROM t003_service
						WHERE Org_Id = var_Org_Id 
						AND Request_Id = var_Request_Id
					);
                    
                    select MCC_Id into @MCC_Id 
					from  t003_service 
					where Request_Id = var_Request_Id 
					and Org_Id = var_Org_Id;
                
					-- Insert new row in Deductions Header table on Approval
					INSERT INTO t033_deductions_header(
						Org_Id, Deductions_Id, Entry_Date, 
                        Request_User_Type, Request_User_Id, MCC_Id,
                        Request_Type, Total_Amount, 
                        Amount_Deducted, Balance, 
                        Is_Closed, No_Of_Installments, 
                        CreatedBy_Id, CreatedBy_Name 
                    )
                    VALUES(
						var_Org_Id, New_Deductions_Header_Id, CONVERT_TZ(NOW(), '+00:00', '+00:00'),
                        var_Request_For, New_Request_User_Id, @MCC_Id ,
                        'Financial', var_Approved_Amount,
                        0, var_Approved_Amount,
                        0, 0,
                        var_User_Id, var_User_Name
                    );
                END;
                END IF;
                
            
				SELECT 1 AS Result_Id, 
				'Approved' AS Result_Description, 
				var_Request_Id AS Result_Extra_Key;
			END;
			ELSE
			BEGIN
				SELECT 1 AS Result_Id, 
				'Rejected' AS Result_Description, 
				var_Request_Id AS Result_Extra_Key;
			END;
			END IF;
        
		END;
        END IF;
		
	END;
    elseif (var_Method_Name = 'Create') then
		begin
        Declare Duplicate_Flag int;
		Declare New_Order_Id varchar(20);
		Declare Year_Id varchar(10);
        
        set Year_Id = (select right(left(curdate(),4),(2)));
		Call USP_Number_Range ('t023_order_header', Year_Id, 'T023', '', New_Order_Id );
        
      set @Agent_Id = (  select Agent_Id from m005_mcc 
      where Org_Id = var_Org_Id and MCC_Id = var_MCC_Id);
        
        Insert Into t023_order_header
		(Org_Id,Order_Id,MCC_Id,Order_Type,
		Order_For,Order_For_User_Id,
		Order_By,Order_By_User_Id,
		Order_Date,Total_Item,
		Is_Approved,Approved_On,Approved_Id,Approved_Name,
		Is_Active,Is_Deleted,
		Created_On,Created_By)
		Values (var_Org_Id,New_Order_Id,var_MCC_Id,var_Order_Type,
		var_Request_For,@Agent_Id,
		var_Request_For,@Agent_Id,
		var_VeterinaryService_Date,1,
		1,now(),var_User_Id,var_User_Name,
		1,0,
		now(),var_User_Id
		); 
        
                
					set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = var_MCC_Id and is_deleted = 0 and 
					Applicable_Date <= now() and Org_Id = Var_Org_Id
					order by Applicable_Date desc limit 1 ) ;
                    
                    Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
                  
                    set @Current_times = (SELECT CONVERT_TZ(var_VeterinaryService_Date, '+00:00', '+00:00'));
                    
					if(@MusterType = 1)then 
					
						Set @MusterCycle_StartDate = @Current_times;
						set @MusterCycle_EndDate =  @Current_times;
                    
                    elseif(@MusterType = 7) then 
						
                        if (DATE_FORMAT(@Current_times, '%d') BETWEEN 1 AND 7 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-07');
                        
                        elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 8 AND 14) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-08');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-14');

						elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 15 AND 21) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-15');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-21');
                        
                      elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 16 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_times));
					
                    end if;
                        
				elseif(@MusterType = 15) then 
                        
                        if (DATE_FORMAT(@Current_times, '%d') BETWEEN 1 AND 15 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-15');
                        
                        else 
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-16');
							set @MusterCycle_EndDate =  LAST_DAY(date(@Current_times));
                        
                        end if;
                        
					elseif(@MusterType = 5) then 
                        
                        if (DATE_FORMAT(@Current_times, '%d') BETWEEN 1 AND 5 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-05');
                        
					elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 6 AND 10) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-06');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-10');

					elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 11 AND 15) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-15');
                        
                      elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 16 AND 20 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-16');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-20');
                        
					elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 21 AND 25 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-21');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-25');
					
                    elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 26 AND 31 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_times));
                    
                    end if;
                    
				elseif(@MusterType = 10) then 
                        
                        if (DATE_FORMAT(@Current_times, '%d') BETWEEN 1 AND 10 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-10');
                        
                        elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 11 AND 20) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-20');

						elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 21 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-21');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_times));
                    
                    end if;
                
					elseif(@MusterType = 30) then 
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-01');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_times));
                        
				end if;
        
        Insert Into t023_order_item
		(Org_Id,Order_Id,Product_Id,
		Quantity,Approved_Quantity,Is_Posted,
        MusterCycle_StartDate,MusterCycle_EndDate)
		Values (var_Org_Id,New_Order_Id,var_Product_Id,
        var_Quantity,var_Quantity,1,
        @MusterCycle_StartDate,@MusterCycle_EndDate
        ); 
        
		SELECT 1 AS Result_Id, 
		'Approved' AS Result_Description, 
		New_Order_Id AS Result_Extra_Key;
        
        end;
	elseif (var_Method_Name = 'Create_Farmer') then
		begin
        Declare Duplicate_Flag int;
		Declare New_Order_Id varchar(20);
		Declare Year_Id varchar(10);
        
        set Year_Id = (select right(left(curdate(),4),(2)));
		Call USP_Number_Range ('t023_order_header', Year_Id, 'T023', '', New_Order_Id );
        
        
        Insert Into t023_order_header
		(Org_Id,Order_Id,MCC_Id,Order_Type,
		Order_For,Order_For_User_Id,
		Order_By,Order_By_User_Id,
		Order_Date,Total_Item,
		Is_Approved,Approved_On,Approved_Id,Approved_Name,
		Is_Active,Is_Deleted,
		Created_On,Created_By)
		Values (var_Org_Id,New_Order_Id,var_MCC_Id,var_Order_Type,
		var_Request_For,var_Request_Id,
		var_Request_For,var_Request_Id,
		var_VeterinaryService_Date,1,
		1,now(),var_User_Id,var_User_Name,
		1,0,
		now(),var_User_Id
		); 
        
                
					set @MusterType_Id = (select m005.MusterType_Id from m005_mcc_version m005 where MCC_Id = var_MCC_Id and is_deleted = 0 and 
					Applicable_Date <= now() and Org_Id = Var_Org_Id
					order by Applicable_Date desc limit 1 ) ;
                    
                    Set @MusterType = (SELECT MusterType FROM c022_mustertype where MusterType_Id =  @MusterType_Id );
                  
                    set @Current_times = (SELECT CONVERT_TZ(var_VeterinaryService_Date, '+00:00', '+00:00'));
                    
					if(@MusterType = 1)then 
					
						Set @MusterCycle_StartDate = @Current_times;
						set @MusterCycle_EndDate =  @Current_times;
                    
                    elseif(@MusterType = 7) then 
						
                        if (DATE_FORMAT(@Current_times, '%d') BETWEEN 1 AND 7 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-07');
                        
                        elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 8 AND 14) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-08');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-14');

						elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 15 AND 21) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-15');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-21');
                        
                      elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 16 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_times));
					
                    end if;
                        
				elseif(@MusterType = 15) then 
                        
                        if (DATE_FORMAT(@Current_times, '%d') BETWEEN 1 AND 15 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-15');
                        
                        else 
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-16');
							set @MusterCycle_EndDate =  LAST_DAY(date(@Current_times));
                        
                        end if;
                        
					elseif(@MusterType = 5) then 
                        
                        if (DATE_FORMAT(@Current_times, '%d') BETWEEN 1 AND 5 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-05');
                        
					elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 6 AND 10) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-06');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-10');

					elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 11 AND 15) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-15');
                        
                      elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 16 AND 20 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-16');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-20');
                        
					elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 21 AND 25 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-21');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-25');
					
                    elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 26 AND 31 ) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-16');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_times));
                    
                    end if;
                    
				elseif(@MusterType = 10) then 
                        
                        if (DATE_FORMAT(@Current_times, '%d') BETWEEN 1 AND 10 ) then
                        
							Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-01');
							set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-10');
                        
                        elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 11 AND 20) then
                    
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-11');
						set @MusterCycle_EndDate =  DATE_FORMAT(date(@Current_times), '%Y-%m-20');

						elseif(DATE_FORMAT(@Current_times, '%d') BETWEEN 21 AND 31) then
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-21');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_times));
                    
                    end if;
                
					elseif(@MusterType = 30) then 
                        
						Set @MusterCycle_StartDate = DATE_FORMAT(date(@Current_times), '%Y-%m-01');
						set @MusterCycle_EndDate =  LAST_DAY(date(@Current_times));
                        
				end if;
        
        Insert Into t023_order_item
		(Org_Id,Order_Id,Product_Id,
		Quantity,Approved_Quantity,Is_Posted,
        MusterCycle_StartDate,MusterCycle_EndDate)
		Values (var_Org_Id,New_Order_Id,var_Product_Id,
        var_Quantity,var_Quantity,1,
        @MusterCycle_StartDate,@MusterCycle_EndDate
        ); 
        
		SELECT 1 AS Result_Id, 
		'Approved' AS Result_Description, 
		New_Order_Id AS Result_Extra_Key;
        
        end;
    END IF;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
