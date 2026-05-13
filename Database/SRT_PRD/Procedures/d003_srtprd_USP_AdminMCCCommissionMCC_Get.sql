-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMCCCommissionMCC_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMCCCommissionMCC_Get`(
	var_Method_Name varchar(20),
    var_Org_Id varchar(10),
    var_User_Id varchar(20),
    var_MPPI_Id varchar(20),
    var_Version_No varchar(20),
    var_MCCType_Id varchar(20),
    var_MCCWorkType_Id varchar(20),
    var_Search_MCC text,
    var_Applicable_Date varchar(45)
)
BEGIN
	if (var_Method_Name = 'Get') then
		begin
        DECLARE Today_Date DATETIME;
            
            set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
            
			select Org_Id,
            MPPI_Id, Version_No,
			DATE_FORMAT(Applicable_Date, '%d %b %Y %h:%i %p') AS Applicable_Date,
            DATE_FORMAT(Applicable_Date, '%Y-%m-%dT%H:%i') AS Set_Date,
            CASE 
			   WHEN Today_Date > Applicable_Date THEN 1
			   ELSE 0
			END AS Is_Locked
            
            from m002_commission_mcc_header 
            where Org_Id = var_Org_Id 
            and MPPI_Id = var_MPPI_Id
            ORDER BY DATE(Applicable_Date) DESC, TIME(Applicable_Date) DESC;
		end;
	elseif (var_Method_Name = 'Get_One') then
		begin
			/*select  m0051.MCC_Id, m0051.MCC_Name  ,m0051.MCC_Code, MAX(B.Is_Locked) AS Is_Locked
            from m002_commission m002
            inner join m005_mcc m0051 on m0051.MCCWorkType_Id = m002.MCCWorkType_Id 
            and  m0051.MCCType_Id = m002.MCCType_Id
            and  m0051.Org_Id = m002.Org_Id
            inner join (
			SELECT
				m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
				CASE 
					WHEN m002.MCC_Id IS NOT NULL THEN 1
					ELSE 0
				END AS Is_Locked
			FROM m005_mcc m005
			left JOIN m002_commission_mcc_item m002 ON m005.MCC_Id = m002.MCC_Id
				AND m002.Org_Id = m005.Org_Id  
				AND m002.MPPI_Id = var_MPPI_Id
				AND m002.Version_No = var_Version_No
			WHERE m005.Org_Id = var_Org_Id ) B on B.MCC_Id = m0051.MCC_Id 
            where m002.Org_Id = var_Org_Id
            and m002.MCCType_Id = var_MCCType_Id
            and m002.MCCWorkType_Id = var_MCCWorkType_Id
            and m0051.Is_Deleted =0
            and (m0051.MCC_Name like concat('%' , var_Search_MCC , '%')
				or m0051.MCC_Code like concat('%' , var_Search_MCC , '%'))
			GROUP BY m0051.MCC_Id, m0051.MCC_Name, m0051.MCC_Code;
            
            */
            /*
            select  m0051.MCC_Id, m0051.MCC_Name  ,m0051.MCC_Code, MAX(B.Is_Locked) AS Is_Locked,
			ml04.Taluka_Id, ml04.Taluka_Name,
			ml05.Village_Id, ml05.Village_Name
            from m002_commission m002
            inner join m005_mcc m0051 on m0051.MCCWorkType_Id = m002.MCCWorkType_Id 
            and  m0051.MCCType_Id = m002.MCCType_Id
            and  m0051.Org_Id = m002.Org_Id
             inner join ml04_taluka ml04 on ml04.Taluka_Id = m0051.Taluka_Id 
				and ml04.Org_Id = m0051.Org_Id
            inner join ml05_village ml05 on ml05.Village_Id = m0051.Village_Id
				and ml05.Org_Id = m0051.Org_Id
            inner join (
			SELECT
				m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
				CASE 
					WHEN m002.MCC_Id IS NOT NULL THEN 1
					ELSE 0
				END AS Is_Locked
			FROM m005_mcc m005
			left JOIN m002_commission_mcc_item m002 ON m005.MCC_Id = m002.MCC_Id
				AND m002.Org_Id = m005.Org_Id  
				AND m002.MPPI_Id = var_MPPI_Id
				AND m002.Version_No = var_Version_No
			WHERE m005.Org_Id = var_Org_Id ) B on B.MCC_Id = m0051.MCC_Id 
            where m002.Org_Id = var_Org_Id
            and m002.MCCType_Id = var_MCCType_Id
            and m002.MCCWorkType_Id = var_MCCWorkType_Id
            and m0051.Is_Deleted =0
            and (m0051.MCC_Name like var_Search_MCC 
				or m0051.MCC_Code like var_Search_MCC
                or ml04.Taluka_Name like var_Search_MCC
                or ml05.Village_Name like var_Search_MCC)
			GROUP BY m0051.MCC_Id, m0051.MCC_Name, m0051.MCC_Code,
            ml04.Taluka_Id, ml04.Taluka_Name,
			ml05.Village_Id, ml05.Village_Name;
            
            */
			/*
            WITH MaxVersion AS (
			SELECT m0051.Org_Id, m0051.MCC_Id, MAX(m0051.Version_No) AS MaxVersion
			FROM m005_mcc_version m0051
			inner join m005_mcc m005 on m005.MCC_Id = m0051.MCC_Id
			and  m0051.Org_Id = m005.Org_Id 
			and  m005.Is_Active = 1
			and  m005.Is_Deleted = 0
			WHERE m0051.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00') AND m0051.Org_Id =var_Org_Id
			GROUP BY m0051.Org_Id, m0051.MCC_Id
					)
					


		 select  m005.MCC_Id, m005.MCC_Name  ,m005.MCC_Code, MAX(B.Is_Locked) AS Is_Locked,
			ml04.Taluka_Id, ml04.Taluka_Name,
			ml05.Village_Id, ml05.Village_Name
            from m002_commission m002
            INNER JOIN
				m005_mcc m005 ON m002.Org_Id = m005.Org_Id
                and m005.MCCWorkType_Id = m002.MCCWorkType_Id 
            and  m005.MCCType_Id = m002.MCCType_Id
			INNER JOIN
				MaxVersion mv ON m005.Org_Id = mv.Org_Id AND m005.MCC_Id = mv.MCC_Id
			INNER JOIN
				m005_mcc_collectionshift m0052 ON m0052.CollectionShift_Id = m002.CollectionShift_Id
				AND m0052.Org_Id = mv.Org_Id
				AND m0052.MCC_Id = mv.MCC_Id
				AND m0052.Version_No = mv.MaxVersion
			INNER JOIN
				m005_mcc_milktype m0053 ON m0053.MilkType_Id = m002.MilkType_Id
				AND m0053.Org_Id = mv.Org_Id
				AND m0053.MCC_Id = mv.MCC_Id
				AND m0053.Version_No = mv.MaxVersion
            inner join ml04_taluka ml04 on ml04.Taluka_Id = m005.Taluka_Id 
				and ml04.Org_Id = m005.Org_Id 
            inner join ml05_village ml05 on ml05.Village_Id = m005.Village_Id 
            inner join (
			SELECT
				m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
				CASE 
					WHEN m002.MCC_Id IS NOT NULL THEN 1
					ELSE 0
				END AS Is_Locked
			FROM m005_mcc m005
			left JOIN m002_commission_mcc_item m002 ON m005.MCC_Id = m002.MCC_Id
				AND m002.Org_Id = m005.Org_Id  
				AND m002.MPPI_Id = var_MPPI_Id
				AND m002.Version_No = var_Version_No
			WHERE m005.Org_Id = var_Org_Id ) B on B.MCC_Id = m005.MCC_Id 
            where m002.Org_Id = var_Org_Id
            and m002.MCCType_Id = var_MCCType_Id
            and m002.MCCWorkType_Id = var_MCCWorkType_Id
            and m005.Is_Deleted =0
            and (m005.MCC_Name like var_Search_MCC 
				or m005.MCC_Code like var_Search_MCC 
                or ml04.Taluka_Name like var_Search_MCC 
                or ml05.Village_Name like var_Search_MCC )
			GROUP BY m005.MCC_Id, m005.MCC_Name, m005.MCC_Code,
            ml04.Taluka_Id, ml04.Taluka_Name,
			ml05.Village_Id, ml05.Village_Name;
            */
            WITH MaxVersion AS (
			SELECT m0051.Org_Id, m0051.MCC_Id, MAX(m0051.Version_No) AS MaxVersion
			FROM m005_mcc_version m0051
			inner join m005_mcc m005 on m005.MCC_Id = m0051.MCC_Id
			and  m0051.Org_Id = m005.Org_Id 
			and  m005.Is_Active = 1
			and  m005.Is_Deleted = 0
			WHERE m0051.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00') AND m0051.Org_Id =var_Org_Id
			GROUP BY m0051.Org_Id, m0051.MCC_Id
					)
					


		 select  m005.MCC_Id, m005.MCC_Name  ,m005.MCC_Code, MAX(B.Is_Locked) AS Is_Locked,
			ml04.Taluka_Id, ml04.Taluka_Name,
			ml05.Village_Id, ml05.Village_Name
            from m002_commission m002
            INNER JOIN
				m005_mcc m005 ON m002.Org_Id = m005.Org_Id
                and m005.MCCWorkType_Id = m002.MCCWorkType_Id 
				and  m005.MCCType_Id = m002.MCCType_Id
			INNER JOIN
				MaxVersion mv ON m005.Org_Id = mv.Org_Id AND m005.MCC_Id = mv.MCC_Id
			INNER JOIN
				m005_mcc_collectionshift m0052 ON m0052.CollectionShift_Id = m002.CollectionShift_Id
				AND m0052.Org_Id = mv.Org_Id
				AND m0052.MCC_Id = mv.MCC_Id
				AND m0052.Version_No = mv.MaxVersion
			INNER JOIN
				m005_mcc_milktype m0053 ON m0053.MilkType_Id = m002.MilkType_Id
				AND m0053.Org_Id = mv.Org_Id
				AND m0053.MCC_Id = mv.MCC_Id
				AND m0053.Version_No = mv.MaxVersion
            inner join ml04_taluka ml04 on ml04.Taluka_Id = m005.Taluka_Id 
				and ml04.Org_Id = m005.Org_Id 
            inner join ml05_village ml05 on ml05.Village_Id = m005.Village_Id 
            inner join (
			SELECT
				m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
				CASE 
					WHEN m002.MCC_Id IS NOT NULL THEN 1
					ELSE 0
				END AS Is_Locked
			FROM m005_mcc m005
			left JOIN m002_commission_mcc_item m002 ON m005.MCC_Id = m002.MCC_Id
				AND m002.Org_Id = m005.Org_Id  
				AND m002.MPPI_Id = var_MPPI_Id
				AND m002.Version_No = var_Version_No
			WHERE m005.Org_Id = var_Org_Id ) B on B.MCC_Id = m005.MCC_Id 
            where m002.Org_Id = var_Org_Id
           and m002.MCCType_Id = var_MCCType_Id
				and m002.MCCWorkType_Id = var_MCCWorkType_Id
            and m005.Is_Deleted =0
            and (m005.MCC_Name like var_Search_MCC 
				or m005.MCC_Code like var_Search_MCC  
                or ml04.Taluka_Name like var_Search_MCC  
                or ml05.Village_Name like var_Search_MCC  )
			GROUP BY m005.MCC_Id, m005.MCC_Name, m005.MCC_Code,
            ml04.Taluka_Id, ml04.Taluka_Name,
			ml05.Village_Id, ml05.Village_Name;
		end;
	elseif (var_Method_Name = 'Get_MCC') then
	
            /* select  m005.MCC_Id, m005.MCC_Code, m005.MCC_Name
            from m002_commission m002
            inner join m005_mcc m005 on m005.MCCWorkType_Id = m002.MCCWorkType_Id 
            and  m005.MCCType_Id = m002.MCCType_Id
            where m002.Org_Id = var_Org_Id
            and m002.MCCType_Id = var_MCCType_Id
            and m002.MCCWorkType_Id = var_MCCWorkType_Id
            and m002.Is_Deleted =0
            GROUP BY m005.MCC_Id, m005.MCC_Code, m005.MCC_Name;
            */
            /*
            select  m0051.MCC_Id, m0051.MCC_Code, m0051.MCC_Name,
			ml04.Taluka_Id, ml04.Taluka_Name,
			ml05.Village_Id, ml05.Village_Name
            from m005_mcc m0051
            left join ml04_taluka ml04 on ml04.Taluka_Id = m0051.Taluka_Id 
				and ml04.Org_Id = m0051.Org_Id
            inner join ml05_village ml05 on ml05.Village_Id = m0051.Village_Id 
				and ml05.Org_Id = m0051.Org_Id
            where m0051.Org_Id = var_Org_Id and 
            m0051.MCCType_Id = var_MCCType_Id
            and m0051.Is_Deleted = 0 
            and (m0051.MCC_Name like concat('%' , var_Search_MCC , '%')
				or m0051.MCC_Code like concat('%' , var_Search_MCC , '%')
                or ml04.Taluka_Name like concat('%' , var_Search_MCC , '%')
                or ml05.Village_Name like concat('%' , var_Search_MCC , '%') )
            GROUP BY m0051.MCC_Id, m0051.MCC_Code, m0051.MCC_Name,
            ml04.Taluka_Id, ml04.Taluka_Name,
			ml05.Village_Id, ml05.Village_Name;
            */
            WITH MaxVersion AS (
				SELECT m0051.Org_Id, m0051.MCC_Id, MAX(m0051.Version_No) AS MaxVersion
				FROM m005_mcc_version m0051
                inner join m005_mcc m005 on m005.MCC_Id = m0051.MCC_Id
				and  m0051.Org_Id = m005.Org_Id 
				and  m005.Is_Active = 1
				and  m005.Is_Deleted = 0
				WHERE m0051.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00') AND m0051.Org_Id =var_Org_Id
				GROUP BY m0051.Org_Id, m0051.MCC_Id
			)

			SELECT
				m005.MCC_Id,
				m005.MCC_Code,
				m005.MCC_Name,
				ml04.Taluka_Id,
				ml04.Taluka_Name,
				ml05.Village_Id,
				ml05.Village_Name
			FROM
				m002_commission m002
			INNER JOIN
				m005_mcc m005 ON m002.Org_Id = m005.Org_Id
                and m005.MCCWorkType_Id = m002.MCCWorkType_Id 
                 and  m005.MCCType_Id = m002.MCCType_Id
			INNER JOIN
				MaxVersion mv ON m005.Org_Id = mv.Org_Id AND m005.MCC_Id = mv.MCC_Id
			INNER JOIN
				m005_mcc_collectionshift m0052 ON m0052.CollectionShift_Id = m002.CollectionShift_Id
				AND m0052.Org_Id = m005.Org_Id
				AND m0052.MCC_Id = m005.MCC_Id
				AND m0052.Version_No = mv.MaxVersion
			INNER JOIN
				m005_mcc_milktype m0053 ON m0053.MilkType_Id = m002.MilkType_Id
				AND m0053.Org_Id = m005.Org_Id
				AND m0053.MCC_Id = m005.MCC_Id
				AND m0053.Version_No = mv.MaxVersion
			INNER JOIN
				ml04_taluka ml04 ON ml04.Taluka_Id = m005.Taluka_Id
				AND ml04.Org_Id = m005.Org_Id
			INNER JOIN
				ml05_village ml05 ON ml05.Village_Id = m005.Village_Id
				AND ml05.Org_Id = m005.Org_Id
			WHERE
				m002.Org_Id = var_Org_Id
				 and m002.MCCType_Id = var_MCCType_Id
				and m002.MCCWorkType_Id = var_MCCWorkType_Id
				AND m002.Is_Deleted = 0
				AND (
					m005.MCC_Name LIKE var_Search_MCC
					OR m005.MCC_Code LIKE var_Search_MCC
					OR ml04.Taluka_Name LIKE var_Search_MCC
					OR ml05.Village_Name LIKE var_Search_MCC
				)
			GROUP BY
				m005.MCC_Id,
				m005.MCC_Code,
				m005.MCC_Name,
				ml04.Taluka_Id,
				ml04.Taluka_Name,
				ml05.Village_Id,
				ml05.Village_Name;
                
                
        
	elseif (var_Method_Name = 'Get_Date') then
		begin
			SELECT DATE_FORMAT(MAX(Applicable_Date), '%Y-%m-%dT%H:%i') AS Applicable_Date
			FROM m002_commission_mcc_header
			WHERE Org_Id = var_Org_Id
			AND MPPI_Id = var_MPPI_Id;
			-- ORDER BY Version_No DESC
			-- LIMIT 1;
		end;
	elseif (var_Method_Name = 'Get_View') then
		begin


select  m0051.MCC_Id, m0051.MCC_Name  ,m0051.MCC_Code, MAX(B.Is_Locked) AS Is_Locked,
             ml04.Taluka_Id, ml04.Taluka_Name,
			ml05.Village_Id, ml05.Village_Name
            from m002_commission m002
            left join m002_commission_mcc_item m0021 on  m0021.MPPI_Id = m002.MPPI_Id
				and m0021.Org_Id = m002.Org_Id
            inner join m005_mcc m0051 on m0021.MCC_Id = m0051.MCC_Id 
				and m0021.Org_Id = m0051.Org_Id 
            inner join ml04_taluka ml04 on ml04.Taluka_Id = m0051.Taluka_Id 
				and ml04.Org_Id = m0051.Org_Id
            inner join ml05_village ml05 on ml05.Village_Id = m0051.Village_Id
				and ml05.Org_Id = m0051.Org_Id
            inner join (
			SELECT
				m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
				CASE 
					WHEN m002.MCC_Id IS NOT NULL THEN 1
					ELSE 0
				END AS Is_Locked
			FROM m005_mcc m005
			left JOIN m002_commission_mcc_item m002 ON m005.MCC_Id = m002.MCC_Id
				AND m002.Org_Id = m005.Org_Id  
				AND m002.MPPI_Id = var_MPPI_Id
				AND m002.Version_No = var_Version_No
			WHERE m005.Org_Id = var_Org_Id ) B on B.MCC_Id = m0051.MCC_Id
            where m002.Org_Id = var_Org_Id
            and m002.MCCType_Id = var_MCCType_Id
            and m002.MCCWorkType_Id = var_MCCWorkType_Id
            and m002.Is_Deleted =0
			GROUP BY m0051.MCC_Id, m0051.MCC_Name, m0051.MCC_Code,
            ml04.Taluka_Id, ml04.Taluka_Name,
			ml05.Village_Id, ml05.Village_Name;
		end;
		elseif (var_Method_Name = 'Get_AssignMCC') then
		begin
        
        
        IF (var_MPPI_Id IS NULL or var_MPPI_Id = '') THEN 
			SET @var_MilkType_Id = '';
		ELSE
			SET @var_MilkType_Id = (SELECT MilkType_Id FROM m002_commission WHERE Org_Id = var_Org_Id AND MPPI_Id = var_MPPI_Id);
		END IF;
        
        
		WITH MaxVersion AS (
			SELECT m0051.Org_Id, m0051.MCC_Id, MAX(m0051.Version_No) AS MaxVersion
			FROM m005_mcc_version m0051
			INNER JOIN m005_mcc m005 ON m005.MCC_Id = m0051.MCC_Id
				AND m0051.Org_Id = m005.Org_Id 
				AND m005.Is_Active = 1
				AND m005.Is_Deleted = 0
			WHERE m0051.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00') AND m0051.Org_Id = var_Org_Id
			GROUP BY m0051.Org_Id, m0051.MCC_Id
		)

		SELECT
			m005.MCC_Id,
			m005.MCC_Code,
			m005.MCC_Name,
			ifnull(ml04.Taluka_Id,'') as Taluka_Id,
            ifnull(ml04.Taluka_Name,'') as Taluka_Name,
            ifnull(ml05.Village_Id,'') as Village_Id,
            ifnull(ml05.Village_Name,'') as Village_Name,
			-- CASE WHEN m002.MCC_Id IS NOT NULL AND m002.Applicable_Date <= NOW() THEN 1 ELSE 0 END AS
            '0' as is_mcc
		FROM
			m005_mcc m005
		INNER JOIN
			MaxVersion mv ON m005.Org_Id = mv.Org_Id AND m005.MCC_Id = mv.MCC_Id
		INNER JOIN
			m005_mcc_milktype m0053 ON m0053.MilkType_Id = @var_MilkType_Id 
				AND m0053.Org_Id = m005.Org_Id
				AND m0053.MCC_Id = m005.MCC_Id
				AND m0053.Version_No = mv.MaxVersion
		LEFT JOIN
			ml04_taluka ml04 ON ml04.Taluka_Id = m005.Taluka_Id
			AND ml04.Org_Id = m005.Org_Id
		LEFT JOIN
			ml05_village ml05 ON ml05.Village_Id = m005.Village_Id
			AND ml05.Org_Id = m005.Org_Id
		LEFT JOIN
			m002_commission_mcc m002 ON m002.MCC_Id = m005.MCC_Id
			and m002.Org_Id = var_Org_Id
			and m002.MPPI_Id = var_MPPI_Id
		WHERE
			m005.Org_Id = var_Org_Id
			AND m005.MCCType_Id = var_MCCType_Id
			AND m005.Is_Deleted = 0
		GROUP BY
			m005.MCC_Id,
			m005.MCC_Code,
			m005.MCC_Name,
			ml04.Taluka_Id,
			ml04.Taluka_Name,
			ml05.Village_Id,
			ml05.Village_Name
            -- ,m002.Applicable_Date
            ;

/*
			WITH MaxVersion AS (
				SELECT m0051.Org_Id, m0051.MCC_Id, MAX(m0051.Version_No) AS MaxVersion
				FROM m005_mcc_version m0051
                inner join m005_mcc m005 on m005.MCC_Id = m0051.MCC_Id
				and  m0051.Org_Id = m005.Org_Id 
				and  m005.Is_Active = 1
				and  m005.Is_Deleted = 0
				WHERE m0051.Applicable_Date <= CONVERT_TZ(NOW(), '+00:00', '+00:00') AND m0051.Org_Id = var_Org_Id
				GROUP BY m0051.Org_Id, m0051.MCC_Id
			)
            

			SELECT
				m005.MCC_Id,
				m005.MCC_Code,
				m005.MCC_Name,
				ml04.Taluka_Id,
				ml04.Taluka_Name,
				ml05.Village_Id,
				ml05.Village_Name
				-- CASE WHEN m002.MCC_Id IS NOT NULL AND m002.Applicable_Date <= NOW() THEN 1 ELSE 0 END AS is_mcc
			FROM
				m005_mcc m005
			INNER JOIN
				MaxVersion mv ON m005.Org_Id = mv.Org_Id AND m005.MCC_Id = mv.MCC_Id
			INNER JOIN
				m005_mcc_milktype m0053 ON m0053.MilkType_Id = @var_MilkType_Id
				AND m0053.Org_Id = m005.Org_Id
				AND m0053.MCC_Id = m005.MCC_Id
				AND m0053.Version_No = mv.MaxVersion
			left JOIN
				ml04_taluka ml04 ON ml04.Taluka_Id = m005.Taluka_Id
				AND ml04.Org_Id = m005.Org_Id
			left JOIN
				ml05_village ml05 ON ml05.Village_Id = m005.Village_Id
				AND ml05.Org_Id = m005.Org_Id
			
			WHERE
				m005.Org_Id = var_Org_Id
				and  m005.MCCType_Id = var_MCCType_Id
				AND m005.Is_Deleted = 0
			GROUP BY
				m005.MCC_Id,
				m005.MCC_Code,
				m005.MCC_Name,
				ml04.Taluka_Id,
				ml04.Taluka_Name,
				ml05.Village_Id,
				ml05.Village_Name
                -- m002.Applicable_Date
                ;
                
                */
                
             
                
                
        end;
	elseif (var_Method_Name = 'GetAssignMCC') then
		begin
			select 
				m002.Org_Id,
				m0021.MPPI_Name,
				m005.MCC_Name,
				DATE_FORMAT(m002.Applicable_Date, '%d %b %Y %h:%i %p') AS Applicable_Date
			from m002_commission_mcc m002
			inner join m002_commission m0021 on m0021.Org_Id = m002.Org_Id 
				and m0021.MPPI_Id = m002.MPPI_Id
			inner join m005_mcc m005 on m005.Org_Id = m002.Org_Id 
				and m005.MCC_Id = m002.MCC_Id
				and m005.MCCType_Id =  var_MCCType_Id
			where m002.Org_Id = var_Org_Id
			and m002.Applicable_Date <= var_Applicable_Date
			ORDER BY DATE(m002.Applicable_Date) DESC, TIME(m002.Applicable_Date) DESC;
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:25
