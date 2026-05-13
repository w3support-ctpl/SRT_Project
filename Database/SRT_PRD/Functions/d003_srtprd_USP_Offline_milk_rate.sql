-- Function Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP FUNCTION IF EXISTS `USP_Offline_milk_rate` ;;
CREATE DEFINER=`appuser`@`%` FUNCTION `USP_Offline_milk_rate`(
    var_org_id VARCHAR(20),
    var_mcc_id VARCHAR(20),
    var_milk_type_id VARCHAR(20),
    var_date VARCHAR(20),
    var_fat VARCHAR(20),
    var_snf VARCHAR(20)
) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN
    -- Get the Chart_Id based on the most recent created date less than or equal to var_date
    SET @Chart_Id = (
        SELECT Chart_Id 
        FROM m001_milk_rate_offline_mcc_header 
        WHERE org_id = var_org_id  
          AND MCC_Id = var_mcc_id 
          AND MilkType_Id = var_milk_type_id
          AND DATE(Created_On) <= DATE(var_date) 
        ORDER BY Created_On DESC 
        LIMIT 1
    );

    -- Retrieve base values for fat and SNF
    SELECT BaseFat, BaseSNF, Amount INTO @BaseFat, @BaseSNF, @Amount
    FROM m001_milk_rate_offline_mcc_base 
    WHERE Chart_Id = @Chart_Id 
      AND org_id = var_org_id 
    LIMIT 1;
    /*
    		set @Chart_Id = (select Chart_Id from m001_milk_rate_offline_mcc_header where 
						org_id = var_org_id  and MCC_Id = var_mcc_id and MilkType_Id = var_milk_type_id
						and date(Created_On) <= date(var_date) order by Created_On desc limit 1);
*/
		select BaseFat , BaseSNF , Amount into @BaseFat , @BaseSNF , @Amount from m001_milk_rate_offline_mcc_base 
		where Chart_Id = @Chart_Id and org_id = var_org_id limit 1;
    
    
		select max(Slab_Min) into @Slab_Max_Fat from m001_milk_rate_offline_mcc_slab 
		where Chart_Id = @Chart_Id  and org_id = var_org_id and Slab_Type = 'FAT' limit 1;
    
		
        select max(Slab_Min) into @Slab_Max_SNF from m001_milk_rate_offline_mcc_slab 
		where Chart_Id = @Chart_Id and org_id = var_org_id and Slab_Type = 'SNF' limit 1;
        
        
	DROP TEMPORARY TABLE IF EXISTS temp_slab_table_fat_ded;
	CREATE TEMPORARY TABLE temp_slab_table_fat_ded AS
	SELECT 
	a.Slab_Min as min_slab,
	a.amount
	FROM 
	m001_milk_rate_offline_mcc_slab a 
	WHERE 
	a.Chart_Id = @Chart_Id 
	AND a.Slab_Min < @BaseFat and 
	a.Slab_Type = 'FAT' ;
    
    
	DROP TEMPORARY TABLE IF EXISTS temp_slab_table_fat_inc;
	CREATE TEMPORARY TABLE temp_slab_table_fat_inc AS
	SELECT 
	a.Slab_Min as min_slab,
	a.amount
	FROM 
	m001_milk_rate_offline_mcc_slab a 
	WHERE 
	a.Chart_Id = @Chart_Id 
	AND a.Slab_Min > @BaseFat and 
	a.Slab_Type = 'FAT' ;
    

	DROP TEMPORARY TABLE IF EXISTS temp_slab_table_snf_inc;
	CREATE TEMPORARY TABLE temp_slab_table_snf_inc AS
	SELECT 
	a.Slab_Min as min_slab,
	a.amount
	FROM 
	m001_milk_rate_offline_mcc_slab a 
	WHERE 
	a.Chart_Id = @Chart_Id 
	AND a.Slab_Min >  @BaseSNF  and 
	a.Slab_Type = 'SNF' ;
    

	DROP TEMPORARY TABLE IF EXISTS temp_slab_table_snf_ded;
	CREATE TEMPORARY TABLE temp_slab_table_snf_ded AS
	SELECT 
	a.Slab_Min as min_slab,
	a.amount
	FROM 
	m001_milk_rate_offline_mcc_slab a 
	WHERE 
	a.Chart_Id = @Chart_Id
	AND a.Slab_Min < @BaseSNF  and 
	a.Slab_Type = 'SNF' ;
    
    
    -- calculation
    
    
    
    
    select round(sum(((if( var_fat >= k.min_slab and  var_fat <= k.max_slab  , k.max_slab -  var_fat , k.max_slab - k.min_slab   ) + 0.1 ) * k.Amount ) * 10) , 1)
   into @total_fat_ded from (
    SELECT   
    a.Slab_Min as min_slab,
    COALESCE(MIN(b.min_slab), @BaseFat) - 0.1 AS max_slab,
     a.Amount 
FROM 
    m001_milk_rate_offline_mcc_slab a
LEFT JOIN 
    temp_slab_table_fat_ded b 
ON a.Slab_Min < b.min_slab
WHERE 
a.Slab_Min < @BaseFat -- and b.min_slab > 3.5
 and a.Slab_Type = 'FAT' 
and a.Chart_Id = @Chart_Id
GROUP BY 
    a.Slab_Min ,  a.Amount
ORDER BY 
    a.Slab_Min ) k 
    where k.max_slab >= var_fat;


	select round(sum(((if( var_snf >= k.min_slab and  var_snf <= k.max_slab  , k.max_slab -  var_snf , k.max_slab - k.min_slab   ) + 0.1 ) * k.Amount ) * 10) , 1)
    into @total_snf_ded from (
    SELECT   
    a.Slab_Min as min_slab,
    COALESCE(MIN(b.min_slab),  @BaseSNF) - 0.1 AS max_slab,
     a.Amount 
FROM 
    m001_milk_rate_offline_mcc_slab a
LEFT JOIN 
    temp_slab_table_snf_ded b 
ON a.Slab_Min < b.min_slab
WHERE 
a.Slab_Min < @BaseSNF -- and b.min_slab > 3.5
 and a.Slab_Type = 'SNF' 
and a.Chart_Id = @Chart_Id 
GROUP BY 
    a.Slab_Min ,  a.Amount
ORDER BY 
    a.Slab_Min ) k 
    where k.max_slab >= var_snf;


    select round(sum(((if( var_fat >= k.min_slab and  var_fat <= k.max_slab  ,var_fat -  k.min_slab , k.max_slab - k.min_slab   ) + 0.1 ) * k.Amount ) * 10) , 1)
	into @total_fat_inc  from (
    SELECT   
    a.Slab_Min as min_slab,
    round(if(MIN(b.min_slab) is null , COALESCE(MIN(b.min_slab), @Slab_Max_Fat)  ,  COALESCE(MIN(b.min_slab), @Slab_Max_Fat)  - 0.1 ), 1 )AS max_slab,
	a.Amount 
FROM 
    m001_milk_rate_offline_mcc_slab a
LEFT JOIN 
    temp_slab_table_fat_inc b 
ON a.Slab_Min < b.min_slab
WHERE 
a.Slab_Min > @BaseFat  -- and b.min_slab > 3.5
 and a.Slab_Type = 'FAT' 
and a.Chart_Id = @Chart_Id 
GROUP BY 
    a.Slab_Min ,  a.Amount
ORDER BY 
    a.Slab_Min) k 
    where k.min_slab <=  var_fat ;




    select round(sum(((if( var_snf >= k.min_slab and  var_snf <= k.max_slab  ,var_snf -  k.min_slab , k.max_slab - k.min_slab   ) + 0.1 ) * k.Amount ) * 10) , 1)
into @total_snf_inc  from (
    SELECT   
    a.Slab_Min as min_slab,
    round(if(MIN(b.min_slab) is null , COALESCE(MIN(b.min_slab), @Slab_Max_snf)  ,  COALESCE(MIN(b.min_slab), @Slab_Max_snf)  - 0.1 ), 1 )AS max_slab,
     a.Amount 
FROM 
    m001_milk_rate_offline_mcc_slab a
LEFT JOIN 
    temp_slab_table_snf_inc b 
ON a.Slab_Min < b.min_slab
WHERE 
a.Slab_Min > @BaseSNF -- and b.min_slab > 3.5
 and a.Slab_Type = 'SNF' 
and a.Chart_Id = @Chart_Id 
GROUP BY 
    a.Slab_Min ,  a.Amount
ORDER BY 
    a.Slab_Min ) k
    where k.min_slab <=  var_snf  ;


set @var_FinalMilkRate =  @Amount + ifnull(@total_snf_inc , 0) + ifnull(@total_fat_inc,0) - ifnull(@total_snf_ded ,0) - ifnull(@total_fat_ded , 0) ;

RETURN  @var_FinalMilkRate;
	

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:33
