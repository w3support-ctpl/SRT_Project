-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AgentReport_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AgentReport_Get`(
	var_Method_Name VARCHAR(255),
    var_Org_Id VARCHAR(10),
    var_User_Id varchar(20),
    var_MCC_Id Varchar(20),
    var_Date varchar(255)
)
BEGIN
	
	SET SQL_SAFE_UPDATES=0;
	if(var_Method_Name = 'Collection_Reports')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            
            /*
			select 
			mu04.MCC_Farmer_Code,
            ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			date_format(t103.Created_On, '%d %M %Y') as Created_On,
			t103.Amount,t103.Quantity_Ltr,
            ifnull(t103.Fat,'0') as Fat,
			ifnull(t103.SNF,'0') as SNF,
			ifnull(t103.ApplicableRate,'0') as Rate,
			CONCAT(
			DATE_FORMAT(t103.MusterCycle_StartDate, '%d'),
			' - ',
			DATE_FORMAT(t103.MusterCycle_EndDate, '%d')
			) AS MusterCycle,
            c016.MilkStatus_Id,c016.MilkStatus_Name,
            c011.MilkType_Id,c011.MilkType_Name
			from t103_milkcollectionfarmer_offline t103
			inner join mu04_farmer mu04 on 
			mu04.Org_Id = t103.Org_Id
			and mu04.Farmer_Id = t103.Farmer_Id
            inner join c011_milktype c011 on 
			c011.MilkType_Id = t103.MilkType_Id
            inner join c016_milkstatus c016 on 
			c016.MilkStatus_Id = t103.MilkStatus_Id
			where t103.Org_Id = var_Org_Id
			and t103.MCC_Id = var_MCC_Id
			and CAST(t103.Created_On  AS DATE) >= var_StartDate 
			and CAST(t103.Created_On  AS DATE)  <= var_EndDate
            
            union all
            
            select 
			mu04.MCC_Farmer_Code,
            ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			date_format(t103.Created_On, '%d %M %Y') as Created_On,
			t103.Amount,t103.Quantity_Ltr,
            ifnull(t103.Fat,'0') as Fat,
			ifnull(t103.SNF,'0') as SNF,
			ifnull(t103.ApplicableRate,'0') as Rate,
			CONCAT(
			DATE_FORMAT(t103.MusterCycle_StartDate, '%d'),
			' - ',
			DATE_FORMAT(t103.MusterCycle_EndDate, '%d')
			) AS MusterCycle,
            c016.MilkStatus_Id,c016.MilkStatus_Name,
            c011.MilkType_Id,c011.MilkType_Name
			from t005_milkcollectionfarmer t103
			inner join mu04_farmer mu04 on 
			mu04.Org_Id = t103.Org_Id
			and mu04.Farmer_Id = t103.Farmer_Id
            and mu04.Is_Offline = 0
            inner join c011_milktype c011 on 
			c011.MilkType_Id = t103.MilkType_Id
            inner join c016_milkstatus c016 on 
			c016.MilkStatus_Id = t103.MilkStatus_Id
			where t103.Org_Id = var_Org_Id
			and t103.MCC_Id = var_MCC_Id
			and CAST(t103.Created_On  AS DATE) >= var_StartDate 
			and CAST(t103.Created_On  AS DATE)  <= var_EndDate;
            
            */
            
			DROP TEMPORARY TABLE IF EXISTS temp_Report;
			CREATE TEMPORARY TABLE temp_Report (
			Org_Id varchar(20), 
			MCC_Id varchar(20),
			Farmer_Id varchar(20),
			Created_On datetime,
			Quantity_Ltr decimal(8,3),
			Fat decimal(8,2), 
			SNF decimal(8,2),
			Rate decimal(8,2),
			Amount decimal(8,2),
			MusterCycle_StartDate date, 
			MusterCycle_EndDate date,
			MilkType_Id varchar(20),
			MilkStatus_Id varchar(20),

			MCC_Farmer_Code varchar(20),
			Farmer_Name varchar(255),
			Is_Offline int,

			MilkStatus_Name varchar(50),
			MilkType_Name varchar(50)

			);

			insert into temp_Report (
				Org_Id , 
				MCC_Id ,
				Farmer_Id ,
				Created_On ,
				Quantity_Ltr ,
				Fat , 
				SNF ,
				Rate ,
				Amount ,
				MusterCycle_StartDate , 
				MusterCycle_EndDate ,
				MilkType_Id ,
				MilkStatus_Id
			)

			select 
			t103.Org_Id , 
			t103.MCC_Id ,
			t103.Farmer_Id ,
			t103.Created_On ,
			t103.Quantity_Ltr ,
			t103.Fat , 
			t103.SNF ,
			t103.ApplicableRate ,
			t103.Amount ,
			t103.MusterCycle_StartDate , 
			t103.MusterCycle_EndDate ,
			t103.MilkType_Id ,
			t103.MilkStatus_Id 
			from t103_milkcollectionfarmer_offline t103
			where t103.Org_Id = var_Org_Id
			and t103.MCC_Id = var_MCC_Id
			and CAST(t103.Created_On  AS DATE) >= var_StartDate 
			and CAST(t103.Created_On  AS DATE)  <= var_EndDate

			union all

			select 
			t103.Org_Id , 
			t103.MCC_Id ,
			t103.Farmer_Id ,
			t103.Created_On ,
			t103.Quantity_Ltr ,
			t103.Fat , 
			t103.SNF ,
			t103.ApplicableRate ,
			t103.Amount ,
			t103.MusterCycle_StartDate , 
			t103.MusterCycle_EndDate ,
			t103.MilkType_Id ,
			t103.MilkStatus_Id 
			from t005_milkcollectionfarmer t103
			where t103.Org_Id = var_Org_Id
			and t103.MCC_Id = var_MCC_Id
			and CAST(t103.Created_On  AS DATE) >= var_StartDate 
			and CAST(t103.Created_On  AS DATE)  <= var_EndDate;

			-- select * from temp_Report;

			update temp_Report temp
			inner join mu04_farmer mu04 on 
			mu04.Org_Id = temp.Org_Id
			and mu04.Farmer_Id = temp.Farmer_Id
			and mu04.MCC_Id = var_MCC_Id
			set temp.MCC_Farmer_Code =  mu04.MCC_Farmer_Code,
				temp.Farmer_Name =  mu04.Farmer_Name,
				temp.Is_Offline = mu04.Is_Offline;

			update temp_Report temp
			inner join c011_milktype c011 on 
			c011.MilkType_Id = temp.MilkType_Id
			set temp.MilkType_Name =  c011.MilkType_Name;

			update temp_Report temp
			inner join c016_milkstatus c016 on 
			c016.MilkStatus_Id = temp.MilkStatus_Id
			set temp.MilkStatus_Name =  c016.MilkStatus_Name;
 
			select 
			MCC_Farmer_Code,
			ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			date_format(Created_On, '%d %M %Y') as Created_On,
			Amount,Quantity_Ltr,
			ifnull(Fat,'0') as Fat,
			ifnull(SNF,'0') as SNF,
			ifnull(Rate,'0') as Rate,
			CONCAT(
			DATE_FORMAT(MusterCycle_StartDate, '%d'),
			' - ',
			DATE_FORMAT(MusterCycle_EndDate, '%d')
			) AS MusterCycle,
			MilkStatus_Id,MilkStatus_Name,
			MilkType_Id,MilkType_Name
			from temp_Report
            where Is_Offline in (1,0);
            
            
            
        end;
	elseif(var_Method_Name = 'GRNCollection')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');

			select 
			m005.MCC_Name  as Farmer_Name,
			ifnull(f010.Dairy_Fat,0.00) as Fat,
			ifnull(f010.Dairy_SNF,0.00) as SNF,
			ifnull(f010.Dairy_Quantity_Kg,0.00) as Quantity_Kg,
			ifnull(f010.Dairy_Quantity_Ltr,0.00) as Quantity_Ltr,
			ifnull(f010.MilkRate,0.00) as Rate,
			ifnull(f010.MilkPrice,0.00) as Amount,
			c015.CollectionShift_Name,
			date_format(f010.Collection_Date, '%e %M %Y') as Created_On
			from f010_milkcollectionmcc_final  f010
			inner join m005_mcc m005 on
			m005.Org_Id	=f010.Org_Id
			and m005.MCC_Id	=f010.MCC_Id
			inner join c015_collectionshift c015 on
			c015.CollectionShift_Id = ifnull(f010.CollectionShift_Id,'C015003')
			where f010.Org_Id = Var_Org_Id
			and f010.MCC_Id = Var_MCC_Id
            and CAST(f010.Collection_Date  AS DATE) >= var_StartDate 
			and CAST(f010.Collection_Date  AS DATE)  <= var_EndDate
			order by f010.Collection_Date desc;
            
            
        end;
	elseif(var_Method_Name = 'Invoice_Reports')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
			select 
			mu04.MCC_Farmer_Code,
            ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			date_format(t108.Invoice_Date, '%d %M %Y') as Invoice_Date,
			t108.Invoice_Amount as Amount,
			CONCAT(
			DATE_FORMAT(t108.MusterCycle_StartDate, '%d'),
			' - ',
			DATE_FORMAT(t108.MusterCycle_EndDate, '%d')
			) AS MusterCycle
			from t108_mcc_farmer_payment t108
			inner join mu04_farmer mu04 on 
			mu04.Org_Id = t108.Org_Id
			and mu04.Farmer_Id = t108.Farmer_Id
			where t108.Org_Id = var_Org_Id
			and t108.MCC_Id = var_MCC_Id
			and CAST(t108.Invoice_Date  AS DATE) >= var_StartDate 
			and CAST(t108.Invoice_Date  AS DATE)  <= var_EndDate
            
            union all
            
            select 
			mu04.MCC_Farmer_Code,
            ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			date_format(t108.Invoice_Date, '%d %M %Y') as Invoice_Date,
			t108.Invoice_Amount as Amount,
			CONCAT(
			DATE_FORMAT(t108.MusterCycle_StartDate, '%d'),
			' - ',
			DATE_FORMAT(t108.MusterCycle_EndDate, '%d')
			) AS MusterCycle
			from t027_invoice_farmer t108
			inner join mu04_farmer mu04 on 
			mu04.Org_Id = t108.Org_Id
			and mu04.Farmer_Id = t108.Farmer_Id
			where t108.Org_Id = var_Org_Id
			and t108.MCC_Id = var_MCC_Id
			and CAST(t108.Invoice_Date  AS DATE) >= var_StartDate 
			and CAST(t108.Invoice_Date  AS DATE)  <= var_EndDate;
            
        end;
	elseif(var_Method_Name = 'CattleFeedPurchase_Reports')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
			
			select  
			t101.Inward_Id,date_format(t101.Inward_Date, '%d %M %Y') as Inward_Date,
			t101.Total_Amount,
			m102.Supplier_Id,
			m102.Supplier_Name,
			m101.Material_Id,
			m101.Material_Name,
			t1011.Purchase_Amount,
			t1011.Purchase_Unit,
			t1011.Selling_Amount,
            t1011.Quantity
			from t101_mcc_material_inward t101 
			inner join t101_mcc_material_inward_item t1011 on
			t1011.Org_Id = t101.Org_Id
			and t1011.Inward_Id = t101.Inward_Id
			inner join m102_mcc_supplier m102 on
			m102.Org_Id = t101.Org_Id
			and m102.Supplier_Id = t101.Supplier_Id
			inner join m101_mcc_material m101 on
			m101.Org_Id = t1011.Org_Id
			and m101.Material_Id = t1011.Material_Id
			where t101.Org_Id = var_Org_Id
			and t101.MCC_Id = var_MCC_Id
			and CAST(t101.Inward_Date  AS DATE) >= var_StartDate 
			and CAST(t101.Inward_Date  AS DATE)  <= var_EndDate;
        end;
	elseif(var_Method_Name = 'CattleFeedIssue_Reports')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
			select 
			mu04.MCC_Farmer_Code,
			ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			date_format(t106.Issue_Date, '%d %M %Y') as Issue_Date,
			t106.Amount,t106.Quantity,t106.Material,t106.Rate,t106.Is_Paid
			from t106_mcc_material_issue t106
			inner join mu04_farmer mu04 on 
			mu04.Org_Id = t106.Org_Id
			and mu04.Farmer_Id = t106.Farmer_Id
			where t106.Org_Id = var_Org_Id
			and t106.MCC_Id = var_MCC_Id
			and CAST(t106.Issue_Date  AS DATE) >= var_StartDate 
			and CAST(t106.Issue_Date  AS DATE)  <= var_EndDate;
        end;
	elseif(var_Method_Name = 'FarmerList_Reports')then 
		begin
			select 
			MCC_Farmer_Code,
			ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			ifnull(Mobile_No,ifnull(AlternateMobile_No,'')) as Mobile_No
			from mu04_farmer 
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id;
        end;
	elseif(var_Method_Name = 'Advance_Reports')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
			
			select 
			mu04.MCC_Farmer_Code,
			ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			date_format(t015.Created_On, '%d %M %Y') as Created_On,
			ifnull(t015.Advance_Amount,0) as Advance_Amount,
			ifnull(t015.Approved_Amount,0) as Approved_Amount,
			t015.Is_Approved
			from t015_advance t015
			inner join mu04_farmer mu04 on 
			mu04.Org_Id = t015.Org_Id
			and mu04.Farmer_Id = t015.Request_For_User_Id
			where t015.Org_Id = var_Org_Id
			and t015.MCC_Id = var_MCC_Id
			and CAST(t015.Created_On  AS DATE) >= var_StartDate 
			and CAST(t015.Created_On  AS DATE)  <= var_EndDate;
        end;
	elseif(var_Method_Name = 'Advance_Reports_Offline')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
			
			select 
			ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			date_format(t107.Deduction_Date, '%d %M %Y') as Deduction_Date,
			ifnull(t107.Amount,0) as Amount,
			ifnull(t107.Deduction_Type,'') as Deduction_Type
			from t107_mcc_farmer_deduction t107
			inner join mu04_farmer mu04 on 
			mu04.Org_Id = t107.Org_Id
			and mu04.Farmer_Id = t107.Farmer_Id
			where t107.Org_Id = var_Org_Id
			and t107.MCC_Id = var_MCC_Id
			and CAST(t107.Deduction_Date  AS DATE) >= var_StartDate 
			and CAST(t107.Deduction_Date  AS DATE)  <= var_EndDate
            
            union all
            
            select 
			ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			date_format(t033i.Deduction_Date, '%d %M %Y') as Deduction_Date,
			ifnull(t033i.Deduction_Amount,0) as Amount,
			'Advance Installment' as Deduction_Type
			from t033_deductions_header_offline t033
			inner join mu04_farmer mu04 on 
			mu04.Org_Id = t033.Org_Id
			and mu04.Farmer_Id = t033.Farmer_Id
			inner join t033_deductions_item_offline t033i on
			t033.Org_Id = t033i.Org_Id
			and t033.Deductions_Id = t033i.Deductions_Id
			and CAST(t033i.Deduction_Date  AS DATE) >= var_StartDate 
			and CAST(t033i.Deduction_Date  AS DATE)  <= var_EndDate
			where t033.Org_Id = var_Org_Id
			and t033.MCC_Id = var_MCC_Id
            ;

        end;
	elseif(var_Method_Name = 'Farmer_Reports')then 
		begin
			select 
			-- ifnull(MCC_Farmer_Code,'') as MCC_Farmer_Code,
			-- ifnull(Farmer_Name,'') as Farmer_Name,
            ifnull(concat( '[' , ifnull(MCC_Farmer_Code,'') ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			ifnull(Mobile_No,ifnull(AlternateMobile_No,'')) as Mobile_No
			from mu04_farmer
			where Org_Id = var_Org_Id
			and MCC_Id = var_MCC_Id
            order by Farmer_Name;
        end ;
	elseif(var_Method_Name = 'Farmers_Reports')then 
		begin
        
            select 
			ifnull(mu04.MCC_Farmer_Code ,'')  as MCC_Farmer_Code,
			ifnull(mu04.Farmer_Name ,'')  as Farmer_Name,
			ifnull(mu04.Mobile_No ,'')  as Mobile_No,
			ifnull(mu04.AlternateMobile_No ,'')  as AlternateMobile_No,
			ifnull(mu04.Email_Id ,'')  as Email_Id,
			ifnull(date_format(mu04.Birth_Date, '%d %M %Y'),'') as Birth_Date,
			ifnull(mu04.Address_Text ,'')  as Address_Text,
			ifnull(ml02.State_Name ,'')  as State_Name,
			ifnull(ml03.District_Name ,'')  as District_Name,
			ifnull(ml04.Taluka_Name ,'')  as Taluka_Name,
			ifnull(ml05.Village_Name ,'')  as Village_Name,
			ifnull(ml05.Pin_Code ,'')  as Pin_Code,
			ifnull(mu04.Cow_Count ,'')  as Cow_Count,
			ifnull(mu04.Buffalo_Count ,'')  as Buffalo_Count,
			ifnull(mu04.Calf_Count ,'')  as Calf_Count,
			ifnull(mu04.Milk_Capacity ,'')  as Milk_Capacity,
			ifnull(mu04.Pan_No ,'')  as Pan_No,
			ifnull(mu04.Aadhar_No ,'')  as Aadhar_No,
			ifnull(m015.Bank_Name ,'')  as Bank_Name,
			ifnull(m016.Branch_Name ,'')  as Branch_Name,
			ifnull(m016.IFSC_Code ,'')  as IFSC_Code,
			ifnull(mu04.Account_No ,'')  as Account_No,
			ifnull(mu04.Account_Name ,'')  as Account_Name,
			ifnull(mu04.Nominee_Name ,'')  as Nominee_Name,
			ifnull(mu04.Account_Name ,'')  as Account_Name,
			ifnull(mu04.Nominee_Aadhar_No ,'')  as Nominee_Aadhar_No
			from mu04_farmer mu04
			left join ml02_state ml02 on
			ml02.Org_Id = mu04.Org_Id
			and ml02.State_Id = mu04.State_Id
			left join ml03_district ml03 on
			ml03.Org_Id = mu04.Org_Id
			and ml03.District_Id = mu04.District_Id
			left join ml04_taluka ml04 on
			ml04.Org_Id = mu04.Org_Id
			and ml04.Taluka_Id = mu04.Taluka_Id
			left join ml05_village ml05 on
			ml05.Org_Id = mu04.Org_Id
			and ml05.Village_Id = mu04.Village_Id
			left join m015_bank m015 on
			m015.Org_Id = mu04.Org_Id
			and m015.Bank_Id = mu04.Bank_Id
			left join m016_branch m016 on
			m016.Org_Id = mu04.Org_Id
			and m016.Bank_Id = mu04.Bank_Id
			and m016.Branch_Id = mu04.Branch_Id
			where mu04.Org_Id = var_Org_Id
			and mu04.MCC_Id = var_MCC_Id
			order by mu04.Farmer_Name;
		end;
	elseif(var_Method_Name = 'SourMilk_Reports')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            
            select 
			ifnull(concat( '[' , ifnull(mu04.MCC_Farmer_Code,'') ,  '] '  , mu04.Farmer_Name ), mu04.Farmer_Name) as Farmer_Name,
			ifnull(mu04.Mobile_No,ifnull(mu04.AlternateMobile_No,'')) as Mobile_No,
			ifnull(t005.Quantity_Ltr,0) as Quantity_Ltr,
			ifnull(t005.Fat,0) as Fat,
			ifnull(t005.SNF,0) as SNF,
			date_format(t004.Created_On, '%d %M %Y') as Created_On
			from t005_milkcollectionfarmer t005
			inner join t004_mcccollectionshift t004 on
			t004.Org_Id = t005.Org_Id
			and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
			and t004.MCC_Id = t005.MCC_Id
			and CAST(t004.Created_On  AS DATE) >= var_StartDate 
			and CAST(t004.Created_On  AS DATE)  <= var_EndDate
			inner join mu04_farmer mu04 on
			mu04.Org_Id = t005.Org_Id
			and mu04.Farmer_Id = t005.Farmer_Id
			where t005.Org_Id = var_Org_Id
			and MilkStatus_Id ='C016002'
			and t005.MCC_Id = var_MCC_Id
            
            union all
            
            select 
			ifnull(concat( '[' , ifnull(mu04.MCC_Farmer_Code,'') ,  '] '  , mu04.Farmer_Name ), mu04.Farmer_Name) as Farmer_Name,
			ifnull(mu04.Mobile_No,ifnull(mu04.AlternateMobile_No,'')) as Mobile_No,
			ifnull(t005.Quantity_Ltr,0) as Quantity_Ltr,
			ifnull(t005.Fat,0) as Fat,
			ifnull(t005.SNF,0) as SNF,
			date_format(t004.Created_On, '%d %M %Y') as Created_On
			from t103_milkcollectionfarmer_offline t005
			inner join t102_mcccollectionshift_offline t004 on
			t004.Org_Id = t005.Org_Id
			and t004.MCCCollectionShift_Id = t005.MCCCollectionShift_Id
			and t004.MCC_Id = t005.MCC_Id
			and CAST(t004.Created_On  AS DATE) >= var_StartDate 
			and CAST(t004.Created_On  AS DATE)  <= var_EndDate
			inner join mu04_farmer mu04 on
			mu04.Org_Id = t005.Org_Id
			and mu04.Farmer_Id = t005.Farmer_Id
			where t005.Org_Id = var_Org_Id
			and MilkStatus_Id ='C016002'
			and t005.MCC_Id = var_MCC_Id;

            
        end;
	elseif(var_Method_Name = 'Supplier_Reports')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            
            select 
			m102.Supplier_Name,
            -- m101.Material_Name,
			sum(ifnull(t101i.Purchase_Amount,0)) as Purchase_Amount,
			sum(ifnull(t101i.Selling_Amount,0)) as Selling_Amount,
			ifnull(t101i.Purchase_Unit,'') as Purchase_Unit,
			sum(ifnull(t101i.Quantity,0)) as Quantity,
            date_format(t101.Created_On, '%d %M %Y') as Created_On
			from t101_mcc_material_inward t101
			inner join t101_mcc_material_inward_item t101i on
			t101.Org_Id = t101i.Org_Id
			and t101.Inward_Id = t101i.Inward_Id
			inner join m102_mcc_supplier m102 on
			m102.Org_Id = t101.Org_Id
			and m102.Supplier_Id = t101.Supplier_Id
			inner join m101_mcc_material m101 on
			m101.Org_Id = t101i.Org_Id
			and m101.Material_Id = t101i.Material_Id
			where t101.Org_Id = var_Org_Id
			and t101.MCC_Id  = var_MCC_Id
            and CAST(t101.Created_On  AS DATE) >= var_StartDate 
			and CAST(t101.Created_On  AS DATE)  <= var_EndDate
            group by m102.Supplier_Name,ifnull(t101i.Purchase_Unit,''),t101.Created_On;
            
		end;
	elseif(var_Method_Name = 'Material_Report')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            
            select 
			-- m102.Supplier_Name,
            m101.Material_Name,
			sum(ifnull(t101i.Purchase_Amount,0)) as Purchase_Amount,
			sum(ifnull(t101i.Selling_Amount,0)) as Selling_Amount,
			ifnull(t101i.Purchase_Unit,'') as Purchase_Unit,
			sum(ifnull(t101i.Quantity,0)) as Quantity,
            date_format(t101.Created_On, '%d %M %Y') as Created_On
			from t101_mcc_material_inward t101
			inner join t101_mcc_material_inward_item t101i on
			t101.Org_Id = t101i.Org_Id
			and t101.Inward_Id = t101i.Inward_Id
			inner join m102_mcc_supplier m102 on
			m102.Org_Id = t101.Org_Id
			and m102.Supplier_Id = t101.Supplier_Id
			inner join m101_mcc_material m101 on
			m101.Org_Id = t101i.Org_Id
			and m101.Material_Id = t101i.Material_Id
			where t101.Org_Id = var_Org_Id
			and t101.MCC_Id  = var_MCC_Id
            and CAST(t101.Created_On  AS DATE) >= var_StartDate 
			and CAST(t101.Created_On  AS DATE)  <= var_EndDate
            group by m101.Material_Name,ifnull(t101i.Purchase_Unit,''),t101.Created_On;
            
		end;
	elseif(var_Method_Name = 'Anamat_Report')then 
		begin
			DECLARE var_StartDate DATE;
			DECLARE var_EndDate DATE;
			SET var_StartDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', 1), '%m/%d/%Y');
			SET var_EndDate = STR_TO_DATE(SUBSTRING_INDEX(var_Date, ' - ', -1), '%m/%d/%Y');
            
            
            select 
			ifnull(concat( '[' , MCC_Farmer_Code ,  '] '  , Farmer_Name ), Farmer_Name) as Farmer_Name,
			date_format(m005.Created_On, '%d %M %Y') as Created_On,
			ifnull(m005.Anamat_PerLtr,0) as Anamat_PerLtr,
			ifnull(m005.Quantity_Ltr,0) as Quantity_Ltr,
			ifnull(m005.Amount,0) as Amount,
			ifnull(m005.Is_InvoiceCreated,0) as Is_Paid
			from 
			m005_mcc_offline_anamat_amount_config m005
			inner join mu04_farmer mu04 on
			mu04.Org_Id = m005.Org_Id
			and mu04.MCC_Id = m005.MCC_Id
			and mu04.Farmer_Id = m005.Farmer_Id
			where m005.Org_Id = var_Org_Id
			and m005.MCC_Id  = var_MCC_Id
			and CAST(m005.Created_On  AS DATE) >= var_StartDate 
			and CAST(m005.Created_On  AS DATE)  <= var_EndDate;
            
		end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:29
