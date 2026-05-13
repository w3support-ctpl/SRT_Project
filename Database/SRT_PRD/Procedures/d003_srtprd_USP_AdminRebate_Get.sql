-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminRebate_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminRebate_Get`(
	var_Method_Name varchar(255),
    var_Org_Id varchar(10),
    var_User_Id varchar(45),
    var_MCCType_Id varchar(20),
    var_MCCWorkType_Id varchar(20),
    var_MCC_Id varchar(20),
    var_Date varchar(45),
	var_ApprovalStatus_Id varchar(2),
    var_Invoice_Id varchar(20)
)
BEGIN
	if(var_Method_Name = 'Get') then 
		begin
			set @Current_Datetime = (SELECT CONVERT_TZ(var_Date, '+00:00', '+00:00'));
            
			DROP TEMPORARY TABLE IF EXISTS temp_rebate;
			CREATE TEMPORARY TABLE temp_rebate ( 
			Org_Id varchar(20), MCC_Id varchar(20), Max_Applicable_Date varchar(20));
			
            Insert into temp_rebate (
			Org_Id,MCC_Id,Max_Applicable_Date
			)
			SELECT 
				 Org_Id,
				 MCC_Id,
				 MAX(Applicable_Date) AS Max_Applicable_Date
			 FROM 
				 m005_mcc_version
			 WHERE 
				 Org_Id = var_Org_Id
              AND Applicable_Date <= LAST_DAY(@Current_Datetime)
			 GROUP BY 
				 Org_Id, MCC_Id;
             
			select 
			m005.Org_Id , 
			m005.MCC_Id , 
			m005.MCC_Code , 
			m005.MCC_Name , 
			CASE
				WHEN t044.Quantity_Ltr IS  NULL or t044.Quantity_Ltr = ''
				THEN sum(f010.Dairy_Quantity_Ltr)
				else t044.Quantity_Ltr
			END AS Quantity_Ltr,
			CASE
				WHEN t044.RebateRate IS  NULL or t044.RebateRate = ''
				THEN m0051.Rebate_PerLtr
				else t044.RebateRate
			END AS Rate,
			CASE
				WHEN t044.RebateMilkPrice IS  NULL or t044.RebateMilkPrice = ''
				THEN round(sum(f010.Dairy_Quantity_Ltr) *  m0051.Rebate_PerLtr)
				else t044.RebateMilkPrice
			END AS Amount,
			CASE
				WHEN t044.SAP_Document_Id IS  NULL or t044.SAP_Document_Id = ''
				THEN ''
				else t044.SAP_Document_Id
			END AS Income_Document,
			CASE
				WHEN t044.Is_Posted IS NULL or t044.Is_Posted  = ''
				THEN 0
				else t044.Is_Posted
			END AS 
             Is_Posted
			from f010_milkcollectionmcc_final f010
			inner JOIN m005_mcc m005 ON m005.MCC_Id = f010.MCC_Id
			and m005.Org_Id = f010.Org_Id
			and m005.MCCType_Id like var_MCCType_Id
			and m005.MCCWorkType_Id like var_MCCWorkType_Id
			and m005.MCC_Id like var_MCC_Id
            INNER JOIN 
					temp_rebate max_dates ON f010.Org_Id = max_dates.Org_Id 
											 AND f010.MCC_Id = max_dates.MCC_Id 
			INNER JOIN 
					m005_mcc_version m0051 ON m0051.Org_Id = max_dates.Org_Id 
											 AND m0051.MCC_Id = max_dates.MCC_Id 
											 AND m0051.Applicable_Date = max_dates.Max_Applicable_Date
                                             
			LEFT JOIN t044_rebate t044 ON t044.MCC_Id = f010.MCC_Id
			and t044.Org_Id = f010.Org_Id
			and  date(t044.Entry_Date) =  date(@Current_Datetime)
			where 
         DATE_FORMAT(f010.Collection_Date, '%Y-%m') = DATE_FORMAT(@Current_Datetime, '%Y-%m') 
			and f010.Org_Id = var_Org_Id
            and ifnull(t044.Is_Posted,0) = var_ApprovalStatus_Id
			group by 
            m005.Org_Id ,
            m005.MCC_Id , 
			m005.MCC_Code , 
			m005.MCC_Name ,
			t044.Quantity_Ltr, 
			t044.RebateRate,
			t044.RebateMilkPrice,
			t044.Is_Posted ,
			t044.SAP_Document_Id,
            m0051.Rebate_PerLtr
			order by m005.MCC_Name;
            
        end;
	elseif (var_Method_Name = 'Get_Voucher') then 
		begin
			DECLARE Set_MPPIType_Id varchar(255);
			DECLARE RebateAmount decimal(30,2);
			DECLARE DateTime varchar(255);
			DECLARE Date varchar(255);
			DECLARE MusterCycle varchar(255);
			DECLARE xmlData longtext;
			DECLARE Counter INT DEFAULT 1;
			DECLARE CompanyCode varchar(255);
			DECLARE GLAccount_Rebate varchar(255);
			DECLARE Creditor_Debtor varchar(50);

			
			SELECT m005.MCC_Code  into Creditor_Debtor FROM t044_rebate t044
			inner join  m005_mcc m005 on m005.Org_Id = t044.Org_Id 
				and m005.MCC_Id = t044.MCC_Id 
			where t044.Org_Id = var_Org_Id 
			and t044.Entry_Id = var_Invoice_Id;
			
            
			
			SELECT Constant_Value into CompanyCode  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='RebateVoucher' and Constant_Name = 'CompanyCode';
			SELECT Constant_Value into GLAccount_Rebate  FROM c043_sap_constant_data where Org_Id = var_Org_Id and API_Name ='RebateVoucher' and Constant_Name = 'GLAccount_Rebate';
			
			Set DateTime =  CONCAT(DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%dT%H:%i:%s'),'.',LPAD(EXTRACT(MICROSECOND FROM CONVERT_TZ(NOW(), '+00:00', '+00:00')), 6, '0'),'Z');
			-- set Date = DATE_FORMAT(CONVERT_TZ(NOW(), '+00:00', '+00:00'), '%Y-%m-%d');
			SELECT 
				CONCAT(DATE_FORMAT(t044.Entry_Date, '%b %y')),
				-- DATE_FORMAT(CONVERT_TZ(t044.Entry_Date, '+00:00', '+00:00'), '%Y-%m-%d')
                DATE_FORMAT(DATE_SUB(DATE_ADD(CONVERT_TZ(t044.Entry_Date, '+00:00', '+00:00'), INTERVAL 1 MONTH), INTERVAL 1 DAY), '%Y-%m-%d')
			into 
				MusterCycle,
				Date
			FROM t044_rebate t044
			WHERE 
				t044.Org_Id = var_Org_Id
				AND t044.Entry_Id = var_Invoice_Id;

			
			-- RebateAmount
			
			SELECT 
				ROUND(SUM(IFNULL(t044.RebateMilkPrice, 0)), 2)
			into 
				RebateAmount
			FROM t044_rebate t044
			WHERE 
				t044.Org_Id = var_Org_Id
				AND t044.Entry_Id = var_Invoice_Id;
			
			
		   
		   if(RebateAmount is null or RebateAmount = '' or RebateAmount = 0)then
				UPDATE t044_rebate t044
				SET t044.Is_Posted = 4
				WHERE t044.Org_Id = var_Org_Id
				AND t044.Entry_Id = var_Invoice_Id;
			end if;
				
                
					SET xmlData  = 
					concat('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
					<soapenv:Envelope
						xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"
						xmlns:sfin=\"http://sap.com/xi/SAPSCORE/SFIN\">\n    
						<soapenv:Header/>\n    
						<soapenv:Body>\n        
							<sfin:JournalEntryBulkCreateRequest>\n            
								<MessageHeader>\n                
									<CreationDateTime>',DateTime,'</CreationDateTime>\n                
									<!--Zero or more repetitions:-->\n                
									<!--Zero or more repetitions:-->\n                
									<BusinessScope>\n                    
										<TypeCode listID=\"?\" listVersionID=\"?\" listAgencyID=\"?\">?</TypeCode>\n                    
										<InstanceID schemeID=\"?\" schemeAgencyID=\"?\">?</InstanceID>\n                    
										<ID schemeID=\"?\" schemeAgencyID=\"?\">?</ID>\n                
									</BusinessScope>\n            
								</MessageHeader>\n            
								<!--1 or more repetitions:-->\n            
								<JournalEntryCreateRequest>\n                
									<MessageHeader>\n                    
										<CreationDateTime>',DateTime,'</CreationDateTime>\n                    
										<SenderParty></SenderParty>\n                    
										<!--Zero or more repetitions:-->\n                
									</MessageHeader>\n                
									<JournalEntry>\n                    
										<OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>\n                    
										<OriginalReferenceDocumentLogicalSystem>0M4U8SS</OriginalReferenceDocumentLogicalSystem>\n                    
										<BusinessTransactionType>RFBU</BusinessTransactionType>\n                    
										<AccountingDocumentType>SA</AccountingDocumentType>\n                    
										<DocumentReferenceID>',var_Invoice_Id,'</DocumentReferenceID>\n                    
										<DocumentHeaderText></DocumentHeaderText>\n                    
										<CreatedByUser>CB9980000000</CreatedByUser>\n                    
										<CompanyCode>',CompanyCode,'</CompanyCode>\n                    
										<DocumentDate>',Date,'</DocumentDate>\n                    
										<PostingDate>',Date,'</PostingDate>\n                    
										<PostingFiscalPeriod></PostingFiscalPeriod>\n                    
										<TaxReportingDate>',Date,'</TaxReportingDate>\n                    
										<TaxDeterminationDate>',Date,'</TaxDeterminationDate>\n                    
										<Reference1InDocumentHeader></Reference1InDocumentHeader>\n                    
										<Reference2InDocumentHeader></Reference2InDocumentHeader>\n');
								
					
						
					IF RebateAmount IS NOT NULL AND RebateAmount != '' AND RebateAmount <> 0 THEN
							if(RebateAmount < 0)then
								SET xmlData = CONCAT(xmlData, 
									'<Item>\n                        
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
										<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
										<GLAccount>',GLAccount_Rebate,'</GLAccount>\n                        
										<AmountInTransactionCurrency currencyCode=\"INR\">',round(RebateAmount),'</AmountInTransactionCurrency>\n                        
										<DebitCreditCode>H</DebitCreditCode>\n                        
										<DocumentItemText>Provision for Milk Rate Diff ',MusterCycle,' ',Creditor_Debtor,'</DocumentItemText>\n                        
										<Tax>\n 
											<TaxCode>0C</TaxCode>\n   
											<TaxItemGroup>000001</TaxItemGroup>\n                       
										</Tax>\n 
                                        <BusinessPlace>IN27</BusinessPlace>\n                        
										<AccountAssignment>\n     
											<ProfitCenter></ProfitCenter>\n   
											<Segment></Segment>\n                   
											<CostCenter>11001002</CostCenter>\n                        
										</AccountAssignment>\n                    
									</Item>\n\t\t '
									);
							elseif(RebateAmount > 0)then
								SET xmlData = CONCAT(xmlData, 
									'<Item>\n                        
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
										<CompanyCode>',CompanyCode,'</CompanyCode>\n                        
										<GLAccount>',GLAccount_Rebate,'</GLAccount>\n                        
										<AmountInTransactionCurrency currencyCode=\"INR\">',round(RebateAmount),'</AmountInTransactionCurrency>\n                        
										<DebitCreditCode>S</DebitCreditCode>\n                        
										<DocumentItemText>Provision for Milk Rate Diff ',MusterCycle,' ',Creditor_Debtor,'</DocumentItemText>\n                        
                                        <Tax>\n 
											<TaxCode>0C</TaxCode>\n   
											<TaxItemGroup>000001</TaxItemGroup>\n                       
										</Tax>\n  
                                        <BusinessPlace>IN27</BusinessPlace>\n                        
										<AccountAssignment>\n 
											<ProfitCenter></ProfitCenter>\n   
											<Segment></Segment>\n                       
											<CostCenter>11001002</CostCenter>\n                        
										</AccountAssignment>\n                    
									</Item>\n\t\t '
									);
							end if;
							
							SET Counter = Counter + 1;
						END IF;
					
					IF RebateAmount IS NOT NULL AND RebateAmount != '' AND RebateAmount <> 0 THEN
						
							if(RebateAmount < 0)then
								SET xmlData = CONCAT(xmlData, 
									'<CreditorItem>\n                        
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
										<Creditor>610015</Creditor>\n                    
										<AmountInTransactionCurrency currencyCode=\"INR\">',(round(RebateAmount) * -1 ) ,'</AmountInTransactionCurrency>\n                        
										<DebitCreditCode>S</DebitCreditCode>\n                        
										<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
										<DocumentItemText>Provision for Milk Rate Diff ',MusterCycle,' ',Creditor_Debtor,'</DocumentItemText>\n                          
									</CreditorItem>        \n\t\t'
									);
								
							elseif(RebateAmount > 0)then
								SET xmlData = CONCAT(xmlData, 
									'<CreditorItem>\n                        
										<ReferenceDocumentItem>', Counter, '</ReferenceDocumentItem>\n                        
										<Creditor>610015</Creditor>\n                    
										<AmountInTransactionCurrency currencyCode=\"INR\">-',round(RebateAmount) ,'</AmountInTransactionCurrency>\n                        
										<DebitCreditCode>H</DebitCreditCode>\n                        
										<AltvRecnclnAccts></AltvRecnclnAccts>\n                        
										<DocumentItemText>Provision for Milk Rate Diff ',MusterCycle,' ',Creditor_Debtor,'</DocumentItemText>\n                           
									</CreditorItem>        \n\t\t'
									);
							end if;
							
							SET Counter = Counter + 1;
						END IF;
					
					SET xmlData = CONCAT(xmlData, 
							'</JournalEntry>\n            
										</JournalEntryCreateRequest>\n        
									</sfin:JournalEntryBulkCreateRequest>\n    
								</soapenv:Body>\n
							</soapenv:Envelope>'
							);
							
					SELECT xmlData;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:26
