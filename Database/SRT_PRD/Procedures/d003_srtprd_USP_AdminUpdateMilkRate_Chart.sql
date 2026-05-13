-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminUpdateMilkRate_Chart` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminUpdateMilkRate_Chart`(
	var_Method_Name varchar(40),
    var_Org_Id varchar(10),
    Var_ChartId varchar(20)
)
BEGIN

set sql_mode = '';

if(var_Method_Name = 'Update_MilkRateChart') then


set @Base_Rate = (
	select  
     GROUP_CONCAT( concat(BaseFat , '-' ,  BaseSNF, ' ₹ ', Amount )  ) AS SlabName 
    from (
            select 
			m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, MilkRateEntryType_Name , m001a.Slab_Id, Slab_Name as SlabName , 
            BaseFat, BaseSNF, Version_No, Amount ,
            max(Applicable_Date)
            from m001_milkrate_item m001a 
            left join c012_milkrateentrytype c012 on m001a.MilkRateEntryType_Id = c012.MilkRateEntryType_Id
            left join m014_slab m014 on m014.Slab_Id = m001a.Slab_Id
            where m001a.Org_Id = var_Org_Id and m001a.Is_Deleted = 0 
            and Chart_Id = Var_ChartId 
            and m001a.MilkRateEntryType_Id  = 'C012001'
            group by m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, m001a.Slab_Id 
) slab 
group by slab.Chart_Id ) ;

		
	SET @Fat_Deduction  = (
	select  
    GROUP_CONCAT( concat(slab.SlabName , ' ₹', Amount ) ,  '</br>'  ) AS SlabName 
    from (
            select 
			m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, MilkRateEntryType_Name , m001a.Slab_Id, Slab_Name as SlabName , 
            BaseFat, BaseSNF, Version_No, Amount ,
            max(Applicable_Date)
            from m001_milkrate_item m001a 
            inner join c012_milkrateentrytype c012 on m001a.MilkRateEntryType_Id = c012.MilkRateEntryType_Id
            inner join m014_slab m014 on m014.Slab_Id = m001a.Slab_Id
            where m001a.Org_Id = var_Org_Id and m001a.Is_Deleted = 0 
            and Chart_Id = Var_ChartId
            and m001a.MilkRateEntryType_Id  = 'C012002'
            group by m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, m001a.Slab_Id
) slab 
group by slab.Chart_Id ) ;


set @SNF_Deduction = (
select  
    GROUP_CONCAT( concat(slab.SlabName , ' ₹', Amount ) , '</br>'  ) AS SlabName
    from (
            select 
			m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, MilkRateEntryType_Name , m001a.Slab_Id, Slab_Name as SlabName , 
            BaseFat, BaseSNF, Version_No, Amount ,
            max(Applicable_Date)
            from m001_milkrate_item m001a 
            inner join c012_milkrateentrytype c012 on m001a.MilkRateEntryType_Id = c012.MilkRateEntryType_Id
            inner join m014_slab m014 on m014.Slab_Id = m001a.Slab_Id
            where m001a.Org_Id = var_Org_Id and m001a.Is_Deleted = 0 
            and Chart_Id = Var_ChartId
            and m001a.MilkRateEntryType_Id  = 'C012003'
            group by m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, m001a.Slab_Id
) slab 
group by slab.Chart_Id ) ;



set  @Fat_High = (
	select  
    GROUP_CONCAT( concat(slab.SlabName , ' ₹', Amount ) , '</br>'  ) AS SlabName
    from (
            select 
			m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, MilkRateEntryType_Name , m001a.Slab_Id, Slab_Name as SlabName , 
            BaseFat, BaseSNF, Version_No, Amount ,
            max(Applicable_Date)
            from m001_milkrate_item m001a 
            inner join c012_milkrateentrytype c012 on m001a.MilkRateEntryType_Id = c012.MilkRateEntryType_Id
            inner join m014_slab m014 on m014.Slab_Id = m001a.Slab_Id
            where m001a.Org_Id = var_Org_Id and m001a.Is_Deleted = 0 
            and Chart_Id = Var_ChartId
            and m001a.MilkRateEntryType_Id  = 'C012004'
            group by m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, m001a.Slab_Id
) slab 
group by slab.Chart_Id ) ;


set  @SNF_High  = (
select  
    GROUP_CONCAT( concat(slab.SlabName , ' ₹', Amount ) , '</br>'  ) AS SlabName
    from (
            select 
			m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, MilkRateEntryType_Name , m001a.Slab_Id, Slab_Name as SlabName , 
            BaseFat, BaseSNF, Version_No, Amount ,
            max(Applicable_Date)
            from m001_milkrate_item m001a 
            inner join c012_milkrateentrytype c012 on m001a.MilkRateEntryType_Id = c012.MilkRateEntryType_Id
            inner join m014_slab m014 on m014.Slab_Id = m001a.Slab_Id
            where m001a.Org_Id = var_Org_Id and m001a.Is_Deleted = 0 
            and Chart_Id = Var_ChartId
            and m001a.MilkRateEntryType_Id  = 'C012005'
            group by m001a.Org_Id, Chart_Id, m001a.MilkRateEntryType_Id, m001a.Slab_Id
) slab 
group by slab.Chart_Id ) ;

update m001_milkrate set 
Base_Rate= @Base_Rate, 
Fat_Incentives= @Fat_High,
Fat_Deduction= @Fat_Deduction,
Snf_Incentives= @SNF_High,
Snf_Deduction= @SNF_Deduction
where Chart_Id = Var_ChartId and Org_Id =  var_Org_Id;




end if ;

END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
