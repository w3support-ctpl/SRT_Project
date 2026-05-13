-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMaterial_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMaterial_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_Material_Id varchar(20),
    var_Search_Text  varchar(50)
)
BEGIN
	if (var_Method_Name = 'Get') then  
		begin
			select m010.Org_Id,m010.Material_Id, m010.Material_Name, m010.Material_Code,
            m010.Is_Active,m010.Is_Deleted,
            c042.MaterialType_Id,c042.MaterialType_Name
            from m010_material m010
            left join c042_materialtype c042 on c042.MaterialType_Id = m010.MaterialType_Id 
            where m010.Org_Id = var_Org_Id and m010.Is_Deleted = 0 
            and (m010.Material_Code like var_Search_Text 
			or m010.Material_Name like var_Search_Text)
            order by m010.Material_Name;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			select Org_Id,Material_Id, Material_Name, Material_Code,Is_Active,Is_Deleted
            from m010_material 
            where Org_Id = var_Org_Id and Material_Id = var_Material_Id 
            and Is_Deleted = 0;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
