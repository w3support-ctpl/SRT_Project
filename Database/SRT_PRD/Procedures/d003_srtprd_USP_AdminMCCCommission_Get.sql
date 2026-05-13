-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCCommission_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCCommission_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_MilkType_Id varchar(20),
    var_MPPI_Id varchar(20),
    var_MPPI_Name varchar(20),
    var_MPPI_Type varchar(20)
)
if (var_Method_Name = 'Get') then
		begin
			select m002.Org_Id,
            m002.MPPI_Id, m002.MPPI_Name,
            c011.MilkType_Id, c011.MilkType_Name,
            -- c014.MCCType_Id, c014.MCCType_Name,
            c016.MilkStatus_Id, c016.MilkStatus_Name,
            -- ifnull(c015.CollectionShift_Id,'') as CollectionShift_Id,
            -- ifnull(c015.CollectionShift_Name,'')as CollectionShift_Name,
            c019.UOM_Id, c019.UOM_Name,
            -- c023.MCCWorkType_Id, c023.MCCWorkType_Name,
			m002.Is_Active,m002.Is_Deleted,m002.Is_Lived
            from m002_commission m002
            inner join c011_milktype c011 on c011.MilkType_Id = m002.MilkType_Id 
            -- inner join c014_mcctype c014 on c014.MCCType_Id = m002.MCCType_Id 
            inner join c016_milkstatus c016 on c016.MilkStatus_Id = m002.MilkStatus_Id 
            inner join c019_uom c019 on c019.UOM_Id = m002.UOM_Id 
            -- inner join c023_mccworktype c023 on c023.MCCWorkType_Id = m002.MCCWorkType_Id 
            -- inner join c015_collectionshift c015 on c015.CollectionShift_Id = m002.CollectionShift_Id 
            inner join c047_mppitype c047 on c047.MPPIType_Id = m002.MPPIType_Id 
            where m002.Org_Id = var_Org_Id and m002.Is_Deleted = 0 
            and m002.MilkType_Id like var_MilkType_Id
            and MPPI_Name like var_MPPI_Name
            and m002.MPPIType_Id = var_MPPI_Type
            order by MPPI_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id, MPPI_Id, MPPI_Name, MilkType_Id, MilkStatus_Id, UOM_Id,
            MCCType_Id,MCCWorkType_Id,CollectionShift_Id,Is_Active, Is_Deleted ,Is_Lived
            from m002_commission 
            where Org_Id = var_Org_Id and MPPI_Id = var_MPPI_Id 
            and Is_Deleted =0;
		end;
	end if ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
