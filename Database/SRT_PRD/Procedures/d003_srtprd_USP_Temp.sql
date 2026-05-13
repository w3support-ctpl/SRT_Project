-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_Temp` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_Temp`(
	var_Org_Id varchar(20),
	var_MCC_Id varchar(20),
    var_CollectionShift_Id varchar(20),
    var_Fat decimal(8,2),
    var_SNF decimal(8,2),
    var_MilkType_Id varchar(20)
)
proc_Exit:BEGIN    
	declare var_FinalMilkRate decimal(8,2);
		SET @Milk_Base_Rate = '';
		SET @Milk_Base_FAT = '';
		SET @Milk_Base_SNF = '';
		SET @Milk_Fat_Deduction = '';
		SET @Milk_Snf_Deduction = '';
		SET @Milk_High_fat = '';
		SET @Milk_High_Snf = '';
		SET @Total_Milk_Amout = '';
		SET @Milk_Quantity_ltr = '';
        
        Set @ChartId = ( select Chart_Id from f002_milk_rate_current where Header_Applicable_Date <= now() and 
			MCC_Id = var_MCC_Id  and CollectionShift_Id = var_CollectionShift_Id 
			and MilkType_Id = var_MilkType_Id
			order by Header_Applicable_Date desc limit 1 );
        
        SELECT Amount, Base_FAT, Base_SNF INTO @Milk_Base_Rate, @Milk_Base_FAT, @Milk_Base_SNF
		FROM f002_milk_rate_current
		WHERE MCC_Id = var_MCC_Id AND MilkType_Id = var_MilkType_Id AND CollectionShift_Id = var_CollectionShift_Id
			AND MilkRateEntryType_Id = 'C012001' 
            AND Chart_Id < @ChartId
		ORDER BY Item_Applicable_Date DESC LIMIT 1;
        
        select @Milk_Base_Rate;
	
    
        IF (var_Fat = @Milk_Base_FAT  and var_SNF = @Milk_Base_SNF)then
			
				SET var_FinalMilkRate = @Milk_Base_Rate;
		end if;
		
		set @Milk_Fat_Deduction1 = 0;
		set @Milk_High_fat1 = 0;
		SET @Milk_Snf_Deduction1 = 0;
		SET @Milk_High_Snf1 = 0;
        
        IF (var_Fat < @Milk_Base_FAT) THEN
        
			set @Milk_Fat_Deduction1 = (select
                        format(sum((points * 10) * Amount ), 2) 
                        from ( SELECT  format( if ( Slab_Min <= var_Fat  and Slab_Max >= var_Fat , (Slab_Max - var_Fat) + if (Slab_Max = @Milk_Base_FAT , 0 , 0.1) , (Slab_Max - Slab_Min ) + if (Slab_Max = @Milk_Base_FAT ,0, 0.1) ),2) as points ,Amount , MAX(Item_Applicable_Date)
						FROM f002_milk_rate_current F002 
                        LEFT JOIN  m014_slab M014 ON F002.Slab_Id = M014.Slab_Id
						WHERE MCC_Id = var_MCC_Id  AND F002.Slab_Id IS NOT NULL 
						and Slab_Max >= var_Fat and CollectionShift_Id = var_CollectionShift_Id 
						and MilkRateEntryType_Id = 'C012002'  and F002.MilkType_Id = var_MilkType_Id and  Chart_Id = @chartid 
						GROUP BY F002.Slab_Id , F002.MilkType_Id , F002.CollectionShift_Id , F002.Org_Id , F002.MilkRateEntryType_Id,
						 F002.MilkRateEntryType_Id , points , Amount
						) slabrate);
                        
				select @Milk_Fat_Deduction1;
                                        
		ELSEIF (var_Fat > @Milk_Base_FAT) THEN
			
                           
						select  format(sum((points * 10) * Amount ), 2)  into @Milk_High_fat1 from (
						SELECT 
						format(if ( Slab_Min <= var_Fat  and Slab_Max >=  var_Fat , (var_Fat - Slab_Min) + if (Slab_Min = @Milk_Base_FAT , 0 , 0.1) , (Slab_Max - Slab_Min)  + if (Slab_Min = @Milk_Base_FAT , 0 , 0.1)  ),2) as points ,
						Amount
						FROM f002_milk_rate_current F002 LEFT JOIN 
						m014_slab M014 ON F002.Slab_Id = M014.Slab_Id
						WHERE MCC_Id = var_MCC_Id AND F002.Slab_Id IS NOT NULL 
						and Slab_Min <= var_Fat and CollectionShift_Id = var_CollectionShift_Id 
						and MilkRateEntryType_Id = 'C012004' and F002.MilkType_Id = var_MilkType_Id and Chart_Id = @chartid 
						GROUP BY F002.Slab_Id , F002.MilkType_Id , F002.CollectionShift_Id , F002.Org_Id , F002.MilkRateEntryType_Id,
						 F002.MilkRateEntryType_Id , points , Amount
						) slabrate;
				select @Milk_High_fat1 ;
		END IF;
		IF (var_SNF < @Milk_Base_SNF) THEN
			
                                    
							select format(sum((points * 10) * Amount ), 2)  into @Milk_Snf_Deduction1 from ( SELECT 
							format( if ( Slab_Min <= var_SNF  and Slab_Max >= var_SNF , (Slab_Max - var_SNF )  +  if (Slab_Max = @Milk_Base_SNF , 0 , 0.1) , (Slab_Max - Slab_Min)  + if (Slab_Max = @Milk_Base_SNF , 0 , 0.1) ),2) as points ,
							Amount , MAX(Item_Applicable_Date)
							FROM f002_milk_rate_current F002 LEFT JOIN 
							m014_slab M014 ON F002.Slab_Id = M014.Slab_Id
							WHERE MCC_Id = var_MCC_Id  AND F002.Slab_Id IS NOT NULL 
							and Slab_Max >= var_SNF and CollectionShift_Id = var_CollectionShift_Id 
							and MilkRateEntryType_Id = 'C012003'  and F002.MilkType_Id = var_MilkType_Id and Chart_Id = @chartid 
							GROUP BY F002.Slab_Id , F002.MilkType_Id , F002.CollectionShift_Id , F002.Org_Id , F002.MilkRateEntryType_Id,
							F002.MilkRateEntryType_Id , points , Amount
							) slabrate;
                            
			select @Milk_Snf_Deduction1 ;
		ELSEIF (var_SNF > @Milk_Base_SNF) THEN
			

			select format(sum((points * 10) * Amount ), 2)  into @Milk_High_Snf1 from (
			SELECT 
			format(if ( Slab_Min <= var_SNF  and Slab_Max >=  var_SNF , (var_SNF - Slab_Min )  + if (Slab_Min = @Milk_Base_SNF , 0 , 0.1)  , (Slab_Max - Slab_Min)  +if (Slab_Min = @Milk_Base_SNF , 0 , 0.1)),2) as points ,
			Amount
			FROM f002_milk_rate_current F002 LEFT JOIN 
			m014_slab M014 ON F002.Slab_Id = M014.Slab_Id
			WHERE MCC_Id = var_MCC_Id AND F002.Slab_Id IS NOT NULL 
			and Slab_Min <= var_SNF and CollectionShift_Id = var_CollectionShift_Id 
			and MilkRateEntryType_Id = 'C012005' and F002.MilkType_Id = var_MilkType_Id and Chart_Id = @chartid 
			GROUP BY F002.Slab_Id , F002.MilkType_Id , F002.CollectionShift_Id , F002.Org_Id , F002.MilkRateEntryType_Id,
             F002.MilkRateEntryType_Id , points , Amount
			) slabrate;
            
            select @Milk_High_Snf1 ;
		END IF;
        
        
	SET var_FinalMilkRate =  @Milk_Base_Rate - @Milk_Fat_Deduction1 + @Milk_High_fat1 - @Milk_Snf_Deduction1 + @Milk_High_Snf1;
        
        
	select var_FinalMilkRate;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:32
