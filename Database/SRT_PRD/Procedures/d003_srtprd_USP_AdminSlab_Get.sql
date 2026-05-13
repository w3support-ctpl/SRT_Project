-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminSlab_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminSlab_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Slab_Id varchar(20),
    var_Slab_Name varchar(50),
    var_Slab_Type varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then  
		begin
			select Org_Id,Slab_Id, Slab_Name, Slab_Min,
            Slab_Max,Is_Active,Is_Deleted
            from m014_slab 
            where Org_Id = var_Org_Id and Is_Deleted = 0 
            and Slab_Name like var_Slab_Name
            and Slab_Type = var_Slab_Type
            order by Slab_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select m014.Org_Id,m014.Slab_Id, m014.Slab_Name, m014.Slab_Min,
            m014.Slab_Max,m014.Is_Active,m014.Is_Deleted,
				CASE
					WHEN m001.Slab_Id IS NOT NULL
					THEN 1
					ELSE 0
				END AS Is_Locked
			FROM m014_slab m014
			LEFT JOIN (
				SELECT DISTINCT Slab_Id
				FROM m001_milkrate_item
				WHERE Org_Id = var_Org_Id
					AND Is_Deleted = 0
			) m001 ON m001.Slab_Id = m014.Slab_Id
            where m014.Org_Id = var_Org_Id and m014.Slab_Id = var_Slab_Id 
            and m014.Is_Deleted =0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
