-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminMilkRateMCC_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminMilkRateMCC_Get`(
  var_Method_Name varchar(255),
     var_Org_Id varchar(10),
     var_User_Id varchar(20),
     var_Chart_Id varchar(20),
     var_Version_No varchar(20),
     var_MilkType_Id varchar(20),
     var_CollectionShift_Id varchar(20),
     var_Search_Text longtext
 )
BEGIN
  if (var_Method_Name = 'Get') then
   begin
         DECLARE Today_Date DATETIME;
             
             set Today_Date = CONVERT_TZ(NOW(), '+00:00', '+00:00');
             

				select 
				m001.Org_Id,
				m001.Chart_Id, m001.Version_No,
				DATE_FORMAT(m001.Applicable_Date, '%d %b %Y %h:%i %p') AS Applicable_Date,
				DATE_FORMAT(m001.Applicable_Date, '%Y-%m-%dT%H:%i') AS Set_Date,
				CASE 
				WHEN Today_Date >= m001.Applicable_Date AND Today_Date <= DATE_ADD(m001.Applicable_Date, INTERVAL 1 DAY) THEN 1
				WHEN Today_Date > DATE_ADD(m001.Applicable_Date, INTERVAL 1 DAY) THEN 1
				ELSE 0
				END AS Is_Locked,
				CASE 
					WHEN Version_No < (
						SELECT MAX(Version_No)
						FROM m001_milkrate_mcc_header AS sub_m001
						WHERE sub_m001.Org_Id = m001.Org_Id
						  AND sub_m001.Chart_Id = m001.Chart_Id
					) THEN 0
					ELSE 1
				END AS Is_BackDate,
				ifnull((SELECT DATE_FORMAT(sub_m001.Applicable_Date, '%Y-%m-%dT%H:%i')
				FROM m001_milkrate_mcc_header AS sub_m001
				WHERE sub_m001.Org_Id = m001.Org_Id
				AND sub_m001.Chart_Id = m001.Chart_Id
				AND sub_m001.Version_No < m001.Version_No
				order by sub_m001.Version_No desc limit 1),DATE_FORMAT(m001.Applicable_Date, '%Y-%m-%dT%H:%i')) 
				AS Back_Date,
                
                CASE 
				WHEN IFNULL((
					SELECT DATE_FORMAT(sub_m001.Applicable_Date, '%Y-%m-%dT%H:%i')
				FROM m001_milkrate_mcc_header AS sub_m001
				WHERE sub_m001.Org_Id = m001.Org_Id
				AND sub_m001.Chart_Id = m001.Chart_Id
				AND sub_m001.Version_No < m001.Version_No
				order by sub_m001.Version_No desc limit 1
				), NULL) IS NULL THEN 1
				ELSE 0
			END AS Is_AccessDate

				from m001_milkrate_mcc_header m001
				where m001.Org_Id = var_Org_Id
				and m001.Chart_Id = var_Chart_Id
				ORDER BY  DATE(m001.Applicable_Date) DESC, TIME(m001.Applicable_Date) DESC;
   end;
  elseif (var_Method_Name = 'Get_One') then
   begin
    /*
    select  m0051.MCC_Id, m0051.MCC_Name  ,m0051.MCC_Code, MAX(B.Is_Locked) AS Is_Locked,
             ml04.Taluka_Id, ml04.Taluka_Name,
    ml05.Village_Id, ml05.Village_Name
             from m001_milkrate m001
             left join m005_mcc_collectionshift m0052 on  m0052.CollectionShift_Id = m001.CollectionShift_Id
     and m0052.Org_Id = m001.Org_Id
    left join m005_mcc_milktype m0053 on   m0053.MilkType_Id = m001.MilkType_Id
     and m0053.Org_Id = m001.Org_Id
             inner join m005_mcc m0051 on m0053.MCC_Id = m0051.MCC_Id or  m0052.MCC_Id = m0051.MCC_Id
     and m0053.Org_Id = m0051.Org_Id or  m0052.Org_Id = m0051.Org_Id
             inner join ml04_taluka ml04 on ml04.Taluka_Id = m0051.Taluka_Id 
     and ml04.Org_Id = m0051.Org_Id 
             inner join ml05_village ml05 on ml05.Village_Id = m0051.Village_Id 
     and ml05.Org_Id = m0051.Org_Id 
             inner join (
    SELECT
     m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
     CASE 
      WHEN m001.MCC_Id IS NOT NULL THEN 1
      ELSE 0
     END AS Is_Locked
    FROM m005_mcc m005
    left JOIN m001_milkrate_mcc_item m001 ON m005.MCC_Id = m001.MCC_Id
     AND m001.Org_Id = m005.Org_Id  
     AND m001.Chart_Id = var_Chart_Id
     AND m001.Version_No = var_Version_No
    WHERE m005.Org_Id = var_Org_Id ) B on B.MCC_Id = m0051.MCC_Id
             where m001.Org_Id = var_Org_Id
             and m001.MilkType_Id = var_MilkType_Id
             and m001.CollectionShift_Id = var_CollectionShift_Id
             and m001.Is_Deleted =0
             and (m0051.MCC_Name like var_Search_Text 
     or m0051.MCC_Code like var_Search_Text
                 or ml04.Taluka_Name like var_Search_Text
                 or ml05.Village_Name like var_Search_Text)
    GROUP BY m0051.MCC_Id, m0051.MCC_Name, m0051.MCC_Code,
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
 
 
 select  
 ifnull(m005.MCC_Id,'')MCC_Id,
 ifnull(m005.MCC_Name,'')MCC_Name,
 ifnull(m005.MCC_Code,'')MCC_Code,
 MAX(B.Is_Locked) AS Is_Locked,
            --  ml04.Taluka_Id, ml04.Taluka_Name,
    -- ml05.Village_Id, ml05.Village_Name,
			ifnull(c014.MCCType_Id,'')MCCType_Id,
			ifnull(c014.MCCType_Name,'')MCCType_Name,
			ifnull(ml03.District_Id,'')District_Id,
			ifnull(ml03.District_Name,'')District_Name,
			ifnull(ml04.Taluka_Id,'')Taluka_Id,
			ifnull(ml04.Taluka_Name,'')Taluka_Name,
			ifnull(ml05.Village_Id,'')Village_Id,
			ifnull(ml05.Village_Name,'')Village_Name
                 
             from m001_milkrate m001
             INNER JOIN
     m005_mcc m005 ON m001.Org_Id = m005.Org_Id
    INNER JOIN
     MaxVersion mv ON m005.Org_Id = mv.Org_Id AND m005.MCC_Id = mv.MCC_Id
    inner JOIN
     m005_mcc_collectionshift m0052 ON m0052.CollectionShift_Id = m001.CollectionShift_Id
     AND m0052.Org_Id = m005.Org_Id
     AND m0052.MCC_Id = m005.MCC_Id
     AND m0052.Version_No = mv.MaxVersion
    inner JOIN
     m005_mcc_milktype m0053 ON m0053.MilkType_Id = m001.MilkType_Id
     AND m0053.Org_Id = m005.Org_Id
     AND m0053.MCC_Id = m005.MCC_Id
     AND m0053.Version_No = mv.MaxVersion
			inner join c014_mcctype c014 on c014.MCCType_Id = m005.MCCType_Id 
			left join ml03_district ml03 on ml03.District_Id = m005.District_Id 
     and ml03.Org_Id = m005.Org_Id
             left join ml04_taluka ml04 on ml04.Taluka_Id = m005.Taluka_Id 
     and ml04.Org_Id = m005.Org_Id 
             left join ml05_village ml05 on ml05.Village_Id = m005.Village_Id 
     and ml05.Org_Id = m005.Org_Id 
             inner join (
    SELECT
     m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
     CASE 
      WHEN m001.MCC_Id IS NOT NULL THEN 1
      ELSE 0
     END AS Is_Locked
    FROM m005_mcc m005
    left JOIN m001_milkrate_mcc_item m001 ON m005.MCC_Id = m001.MCC_Id
     AND m001.Org_Id = m005.Org_Id  
     AND m001.Chart_Id = var_Chart_Id
     AND m001.Version_No = var_Version_No
    WHERE m005.Org_Id = var_Org_Id ) B on B.MCC_Id = m005.MCC_Id
              where m001.Org_Id = var_Org_Id
             and m001.MilkType_Id = var_MilkType_Id
             and m001.CollectionShift_Id = var_CollectionShift_Id
      and m001.Is_Deleted =0
             and ( m005.MCC_Name like var_Search_Text 
     or m005.MCC_Code like var_Search_Text
                 or ml04.Taluka_Name like var_Search_Text
                 or ml05.Village_Name like var_Search_Text)
    GROUP BY m005.MCC_Id, m005.MCC_Name, m005.MCC_Code,
			c014.MCCType_Id, c014.MCCType_Name,
			ml03.District_Id, ml03.District_Name,
             ml04.Taluka_Id, ml04.Taluka_Name,
    ml05.Village_Id, ml05.Village_Name;
             
             
             
   end;
  elseif (var_Method_Name = 'Get_MCC') then
   begin
             /*
             select  m0051.MCC_Id, m0051.MCC_Code, m0051.MCC_Name,
    ml04.Taluka_Id, ml04.Taluka_Name,
    ml05.Village_Id, ml05.Village_Name
             from m001_milkrate m001
             left join m005_mcc_collectionshift m0052 on  m0052.CollectionShift_Id = m001.CollectionShift_Id
     and m0052.Org_Id = m001.Org_Id
    left join m005_mcc_milktype m0053 on   m0053.MilkType_Id = m001.MilkType_Id
     and m0053.Org_Id = m001.Org_Id
             inner join m005_mcc m0051 on m0053.MCC_Id = m0051.MCC_Id or  m0052.MCC_Id = m0051.MCC_Id
     and m0053.Org_Id = m0051.Org_Id or  m0052.Org_Id = m0051.Org_Id
             inner join ml04_taluka ml04 on ml04.Taluka_Id = m0051.Taluka_Id 
     and ml04.Org_Id = m0051.Org_Id 
             inner join ml05_village ml05 on ml05.Village_Id = m0051.Village_Id 
     and ml05.Org_Id = m0051.Org_Id 
             where m001.Org_Id = var_Org_Id
             and m001.MilkType_Id = var_MilkType_Id
             and m001.CollectionShift_Id = var_CollectionShift_Id
             and m001.Is_Deleted =0
             and (m0051.MCC_Name like var_Search_Text 
     or m0051.MCC_Code like var_Search_Text
                 or ml04.Taluka_Name like var_Search_Text
                 or ml05.Village_Name like var_Search_Text)
             GROUP BY m0051.MCC_Id, m0051.MCC_Code, m0051.MCC_Name,
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
			 
				SELECT
				 m005.MCC_Id,
				 m005.MCC_Code,
				 m005.MCC_Name,
				 ifnull(ml04.Taluka_Id,'')Taluka_Id,
							 ifnull(ml04.Taluka_Name,'')Taluka_Name,
							 ifnull(ml05.Village_Id,'')Village_Id,
							 ifnull(ml05.Village_Name,'')Village_Name
				FROM
				 m001_milkrate m001
				INNER JOIN
				 m005_mcc m005 ON m001.Org_Id = m005.Org_Id
				INNER JOIN
				 MaxVersion mv ON m005.Org_Id = mv.Org_Id AND m005.MCC_Id = mv.MCC_Id
				left JOIN
				 m005_mcc_collectionshift m0052 ON m0052.CollectionShift_Id = m001.CollectionShift_Id
				 AND m0052.Org_Id = m005.Org_Id
				 AND m0052.MCC_Id = m005.MCC_Id
				 AND m0052.Version_No = mv.MaxVersion
				left JOIN
				 m005_mcc_milktype m0053 ON m0053.MilkType_Id = m001.MilkType_Id
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
				 m001.Org_Id = var_Org_Id
				 AND m001.MilkType_Id = var_MilkType_Id
				 AND m001.CollectionShift_Id = var_CollectionShift_Id
				 AND m001.Is_Deleted = 0
				 AND (
				  m005.MCC_Name LIKE var_Search_Text
				  OR m005.MCC_Code LIKE var_Search_Text
				  OR ml04.Taluka_Name LIKE var_Search_Text
				  OR ml05.Village_Name LIKE var_Search_Text
				 )
				
				GROUP BY
				 m005.MCC_Id,
				 m005.MCC_Code,
				 m005.MCC_Name,
				 ml04.Taluka_Id,
				 ml04.Taluka_Name,
				 ml05.Village_Id,
				 ml05.Village_Name
                 order by m005.MCC_Name;
               
               */
               
               set @Applicable_Date = (select Applicable_Date from m001_milkrate_mcc_header
						where Chart_Id = var_Chart_Id
                        and Org_Id = var_Org_Id
						order by Applicable_Date desc
						limit 1);
                        
                        DROP TEMPORARY TABLE IF EXISTS temp_Report;

						CREATE TEMPORARY TABLE temp_Report ( 
						MCC_Id varchar(20));

						insert into temp_Report (MCC_Id)
						select MCC_Id from m001_milkrate_mcc_header m001
                        inner join m001_milkrate m0012 on
						m001.Org_Id = m0012.Org_Id
						and m001.Chart_Id = m0012.Chart_Id
                        and m0012.CollectionShift_Id = var_CollectionShift_Id
						inner join m001_milkrate_mcc_item m0011 on
						m001.Org_Id = m0011.Org_Id
						and m001.Chart_Id = m0011.Chart_Id
						and m001.Version_No = m0011.Version_No
						and m001.Chart_Id <> var_Chart_Id
						and m001.Applicable_Date  >= @Applicable_Date
						and m001.Org_Id = var_Org_Id
						group by MCC_Id;

				
               
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
						 
						 
						 select  
                          ifnull(m005.MCC_Id,'')MCC_Id,
						 ifnull(m005.MCC_Name,'')MCC_Name,
						 ifnull(m005.MCC_Code,'')MCC_Code,
                         MAX(CASE 
								WHEN B.Is_Locked = 1 AND temp.MCC_Id IS NOT NULL THEN 0
								ELSE B.Is_Locked
							END) AS Is_Locked,
                         -- MAX(B.Is_Locked) AS Is_Locked,
									--  ml04.Taluka_Id, ml04.Taluka_Name,
							-- ml05.Village_Id, ml05.Village_Name,
							   ifnull(c014.MCCType_Id,'')MCCType_Id,
							 ifnull(c014.MCCType_Name,'')MCCType_Name,
							ifnull(ml03.District_Id,'')District_Id,
							 ifnull(ml03.District_Name,'')District_Name,
							 ifnull(ml04.Taluka_Id,'')Taluka_Id,
							 ifnull(ml04.Taluka_Name,'')Taluka_Name,
							 ifnull(ml05.Village_Id,'')Village_Id,
							 ifnull(ml05.Village_Name,'')Village_Name
										 
									 from m001_milkrate m001
									 INNER JOIN
							 m005_mcc m005 ON m001.Org_Id = m005.Org_Id
							INNER JOIN
							 MaxVersion mv ON m005.Org_Id = mv.Org_Id AND m005.MCC_Id = mv.MCC_Id
							inner JOIN
							 m005_mcc_collectionshift m0052 ON m0052.CollectionShift_Id = m001.CollectionShift_Id
							 AND m0052.Org_Id = m005.Org_Id
							 AND m0052.MCC_Id = m005.MCC_Id
							 AND m0052.Version_No = mv.MaxVersion
							inner JOIN
							 m005_mcc_milktype m0053 ON m0053.MilkType_Id = m001.MilkType_Id
							 AND m0053.Org_Id = m005.Org_Id
							 AND m0053.MCC_Id = m005.MCC_Id
							 AND m0053.Version_No = mv.MaxVersion
                             	inner join c014_mcctype c014 on c014.MCCType_Id = m005.MCCType_Id 
									left join ml03_district ml03 on ml03.District_Id = m005.District_Id 
							 and ml03.Org_Id = m005.Org_Id 
									 left join ml04_taluka ml04 on ml04.Taluka_Id = m005.Taluka_Id 
							 and ml04.Org_Id = m005.Org_Id 
									 left join ml05_village ml05 on ml05.Village_Id = m005.Village_Id 
							 and ml05.Org_Id = m005.Org_Id 
									 inner join (
							SELECT
							 m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
							 CASE 
							  WHEN m001.MCC_Id IS NOT NULL THEN 1
							  ELSE 0
							 END AS Is_Locked
							FROM m005_mcc m005
							left JOIN m001_milkrate_mcc_item m001 ON m005.MCC_Id = m001.MCC_Id
							 AND m001.Org_Id = m005.Org_Id  
							 AND m001.Chart_Id = var_Chart_Id
							 AND m001.Version_No = var_Version_No
							WHERE m005.Org_Id = var_Org_Id ) B on B.MCC_Id = m005.MCC_Id
							LEFT JOIN temp_Report temp ON m005.MCC_Id = temp.MCC_Id
									  where m001.Org_Id = var_Org_Id
									 and m001.MilkType_Id = var_MilkType_Id
									 and m001.CollectionShift_Id = var_CollectionShift_Id
							  and m001.Is_Deleted =0
									 and ( m005.MCC_Name like var_Search_Text 
							 or m005.MCC_Code like var_Search_Text
										 or ml04.Taluka_Name like var_Search_Text
										 or ml05.Village_Name like var_Search_Text)
							GROUP BY m005.MCC_Id, m005.MCC_Name, m005.MCC_Code,
								c014.MCCType_Id, c014.MCCType_Name,
				ml03.District_Id, ml03.District_Name,
									 ml04.Taluka_Id, ml04.Taluka_Name,
							ml05.Village_Id, ml05.Village_Name;
			
 
   end;
elseif (var_Method_Name = 'Get_View') then
   begin
   /*
    select  m0051.MCC_Id, m0051.MCC_Name  ,m0051.MCC_Code, MAX(B.Is_Locked) AS Is_Locked,
              ml04.Taluka_Id, ml04.Taluka_Name,
    ml05.Village_Id, ml05.Village_Name
             from m001_milkrate m001
             left join m005_mcc_collectionshift m0052 on  m0052.CollectionShift_Id = m001.CollectionShift_Id
     and m0052.Org_Id = m001.Org_Id
    left join m005_mcc_milktype m0053 on   m0053.MilkType_Id = m001.MilkType_Id
     and  m0053.Org_Id = m001.Org_Id
             left join m005_mcc m0051 on m0053.MCC_Id = m0051.MCC_Id or  m0052.MCC_Id = m0051.MCC_Id
     and m0053.Org_Id = m0051.Org_Id or  m0052.Org_Id = m0051.Org_Id
             left join ml04_taluka ml04 on ml04.Taluka_Id = m0051.Taluka_Id 
     and ml04.Org_Id = m0051.Org_Id
             left join ml05_village ml05 on ml05.Village_Id = m0051.Village_Id
     and ml05.Org_Id = m0051.Org_Id
             inner join (
    SELECT
     m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
     CASE 
      WHEN m001.MCC_Id IS NOT NULL THEN 1
      ELSE 0
     END AS Is_Locked
    FROM m005_mcc m005
    left JOIN m001_milkrate_mcc_item m001 ON m005.MCC_Id = m001.MCC_Id
     AND m001.Org_Id = m005.Org_Id  
     AND m001.Chart_Id = var_Chart_Id
     AND m001.Version_No = var_Version_No
    WHERE m005.Org_Id = var_Org_Id ) B on B.MCC_Id = m0051.MCC_Id
             where m001.Org_Id = var_Org_Id
             and m001.MilkType_Id = var_MilkType_Id
             and m001.CollectionShift_Id = var_CollectionShift_Id
             and m001.Is_Deleted =0
    GROUP BY m0051.MCC_Id, m0051.MCC_Name, m0051.MCC_Code,
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
 
 
 select  
 ifnull(m005.MCC_Id,'')MCC_Id,
 ifnull(m005.MCC_Name,'')MCC_Name,
 ifnull(m005.MCC_Code,'')MCC_Code,
 MAX(B.Is_Locked) AS Is_Locked,
             -- ml04.Taluka_Id, ml04.Taluka_Name,
    -- ml05.Village_Id, ml05.Village_Name
    ifnull(c014.MCCType_Id,'')MCCType_Id,
	 ifnull(c014.MCCType_Name,'')MCCType_Name,
	ifnull(ml03.District_Id,'')District_Id,
	 ifnull(ml03.District_Name,'')District_Name,
    ifnull(ml04.Taluka_Id,'')Taluka_Id,
	 ifnull(ml04.Taluka_Name,'')Taluka_Name,
	 ifnull(ml05.Village_Id,'')Village_Id,
	 ifnull(ml05.Village_Name,'')Village_Name
             from m001_milkrate m001
             INNER JOIN
     m005_mcc m005 ON m001.Org_Id = m005.Org_Id
    INNER JOIN
     MaxVersion mv ON m005.Org_Id = mv.Org_Id AND m005.MCC_Id = mv.MCC_Id
    left JOIN
     m005_mcc_collectionshift m0052 ON m0052.CollectionShift_Id = m001.CollectionShift_Id
     AND m0052.Org_Id = m005.Org_Id
     AND m0052.MCC_Id = m005.MCC_Id
     AND m0052.Version_No = mv.MaxVersion
    left JOIN
     m005_mcc_milktype m0053 ON m0053.MilkType_Id = m001.MilkType_Id
     AND m0053.Org_Id = m005.Org_Id
     AND m0053.MCC_Id = m005.MCC_Id
     AND m0053.Version_No = mv.MaxVersion
			inner join c014_mcctype c014 on c014.MCCType_Id = m005.MCCType_Id 
			left join ml03_district ml03 on ml03.District_Id = m005.District_Id 
     and ml03.Org_Id = m005.Org_Id 
             left join ml04_taluka ml04 on ml04.Taluka_Id = m005.Taluka_Id 
     and ml04.Org_Id = m005.Org_Id 
             left join ml05_village ml05 on ml05.Village_Id = m005.Village_Id 
     and ml05.Org_Id = m005.Org_Id 
             inner join (
    SELECT
     m005.MCC_Id,m005.MCC_Name,m005.MCC_Code,
     CASE 
      WHEN m001.MCC_Id IS NOT NULL THEN 1
      ELSE 0
     END AS Is_Locked
    FROM m005_mcc m005
    left JOIN m001_milkrate_mcc_item m001 ON m005.MCC_Id = m001.MCC_Id
     AND m001.Org_Id = m005.Org_Id  
     AND m001.Chart_Id = var_Chart_Id
     AND m001.Version_No = var_Version_No
    WHERE m005.Org_Id = var_Org_Id ) B on B.MCC_Id = m005.MCC_Id
              where m001.Org_Id = var_Org_Id
             and m001.MilkType_Id = var_MilkType_Id
             and m001.CollectionShift_Id = var_CollectionShift_Id
      and m001.Is_Deleted =0
             and ( m005.MCC_Name like '%%' 
     or m005.MCC_Code like '%%' 
                 or ml04.Taluka_Name like '%%' 
                 or ml05.Village_Name like '%%' )
    GROUP BY m005.MCC_Id, m005.MCC_Name, m005.MCC_Code,
    c014.MCCType_Id, c014.MCCType_Name,
			ml03.District_Id, ml03.District_Name,
             ml04.Taluka_Id, ml04.Taluka_Name,
    ml05.Village_Id, ml05.Village_Name;
   end;
	elseif (var_Method_Name = 'Get_One_MCC') then
		begin
            
            select 
            Org_Id,Chart_Id,Version_No,
            DATE_FORMAT(Applicable_Date, '%Y-%m-%dT%H:%i') AS Applicable_Date
            from m001_milkrate_mcc_header
             where Org_Id = var_Org_Id 
			and Chart_Id = var_Chart_Id
             and Version_No = var_Version_No;
		end;
  end if;
     
 END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
