-- Stored Procedure Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DELIMITER ;;
DROP PROCEDURE IF EXISTS `USP_AdminTradingMaterialIssueSAP_Get` ;;
CREATE DEFINER=`appuser`@`%` PROCEDURE `USP_AdminTradingMaterialIssueSAP_Get`(
	var_Method_Name varchar(255),
	var_Org_Id varchar(255),
    var_Product_Id varchar(255),
	var_Order_Id varchar(255)
)
BEGIN
	if(var_Method_Name = 'Get_SalesOrder') then
		begin
        
			/*
			select         
			'OR' as  SalesOrderType ,
			'1000' as  SalesOrganization ,
			'08' as  DistributionChannel ,
			'05' as  OrganizationDivision ,
			'SS1' as  SalesGroup ,
			'1000' as  SalesOffice ,
			'' as  SalesDistrict ,
			m005.MCC_Code as  SoldToParty ,
			CONCAT('/Date(',YEAR(NOW()),LPAD(MONTH(NOW()), 2, '0'),LPAD(DAY(NOW()), 2, '0'),HOUR(NOW()),MINUTE(NOW()),SECOND(NOW()),')/') as  CreationDate ,
			'CB9980000016' as  CreatedByUser ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  LastChangeDate ,
			'' as  SenderBusinessSystemName ,
			'' as  ExternalDocumentID ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),'+0000)/') as  LastChangeDateTime ,
			'' as  PurchaseOrderByCustomer ,
			'' as  PurchaseOrderByShipToParty ,
			'' as  CustomerPurchaseOrderType ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  SalesOrderDate ,
			'0' as  TotalNetAmount ,
			'C' as  OverallDeliveryStatus ,
			'' as  TotalBlockStatus ,
			'' as  OverallOrdReltdBillgStatus ,
			'' as  OverallSDDocReferenceStatus ,
			'INR' as  TransactionCurrency ,
			'' as  SDDocumentReason ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  PricingDate ,
			'1.00000' as  PriceDetnExchangeRate ,
			'' as  BillingPlan ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  RequestedDeliveryDate ,
			'01' as  ShippingCondition ,
			false as  CompleteDeliveryIsDefined ,
			'' as  ShippingType ,
			'' as  HeaderBillingBlockReason ,
			'' as  DeliveryBlockReason ,
			'' as  DeliveryDateTypeRule ,
			'CFR' as  IncotermsClassification ,
			'' as  IncotermsTransferLocation ,
			'NA' as  IncotermsLocation1 ,
			'' as  IncotermsLocation2 ,
			'' as  IncotermsVersion ,
			'' as  CustomerPriceGroup ,
			'' as  PriceListType ,
			'0001' as  CustomerPaymentTerms ,
			'' as  PaymentMethod ,
			'' as  AssignmentReference ,
			'' as  ReferenceSDDocument ,
			'' as  ReferenceSDDocumentCategory ,
			'' as  AccountingDocExternalReference ,
			'01' as  CustomerAccountAssignmentGroup ,
			'0.00000' as  AccountingExchangeRate ,
			'' as  CustomerGroup ,
			'' as  AdditionalCustomerGroup1 ,
			'' as  AdditionalCustomerGroup2 ,
			'' as  AdditionalCustomerGroup3 ,
			'' as  AdditionalCustomerGroup4 ,
			'' as  AdditionalCustomerGroup5 ,
			false as  SlsDocIsRlvtForProofOfDeliv ,
			'' as  CustomerTaxClassification1 ,
			'' as  CustomerTaxClassification2 ,
			'' as  CustomerTaxClassification3 ,
			'' as  CustomerTaxClassification4 ,
			'' as  CustomerTaxClassification5 ,
			'' as  CustomerTaxClassification6 ,
			'' as  CustomerTaxClassification7 ,
			'' as  CustomerTaxClassification8 ,
			'' as  CustomerTaxClassification9 ,
			'' as  TaxDepartureCountry ,
			'' as  VATRegistrationCountry ,
			'' as  SalesOrderApprovalReason ,
			'' as  SalesDocApprovalStatus ,
			'C' as  OverallSDProcessStatus ,
			'D' as  TotalCreditCheckStatus ,
			'C' as  OverallTotalDeliveryStatus ,
			'a' as  OverallSDDocumentRejectionSts ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  BillingDocumentDate ,
			'' as  ContractAccount ,
			'0' as  AdditionalValueDays ,
			'' as  CustomerPurchaseOrderSuplmnt 
			from t023_order_item t0231
			inner join t023_order_header t023 on
			t023.Org_Id = t0231.Org_Id
			and t023.Order_Id = t0231.Order_Id
			and t023.Is_Approved = 1
			inner join m005_mcc m005 on
			t023.Org_Id = m005.Org_Id
			and t023.MCC_Id = m005.MCC_Id
			where t0231.Org_Id = var_Org_Id
			and t0231.Product_Id = var_Product_Id
			and t0231.Order_Id = var_Order_Id;
            
            */
            
            select         
			'OR' as  SalesOrderType ,
			'1000' as  SalesOrganization ,
			'08' as  DistributionChannel ,
			'05' as  OrganizationDivision ,
			'SS1' as  SalesGroup ,
			'1000' as  SalesOffice ,
			'' as  SalesDistrict ,
			m005.MCC_Code as  SoldToParty ,
			CONCAT('/Date(',YEAR(NOW()),LPAD(MONTH(NOW()), 2, '0'),LPAD(DAY(NOW()), 2, '0'),HOUR(NOW()),MINUTE(NOW()),SECOND(NOW()),')/') as  CreationDate ,
			'CB9980000016' as  CreatedByUser ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  LastChangeDate ,
			'' as  SenderBusinessSystemName ,
			'' as  ExternalDocumentID ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),'+0000)/') as  LastChangeDateTime ,
			'' as  PurchaseOrderByCustomer ,
			'' as  PurchaseOrderByShipToParty ,
			'' as  CustomerPurchaseOrderType ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  SalesOrderDate ,
			'0' as  TotalNetAmount ,
			'C' as  OverallDeliveryStatus ,
			'' as  TotalBlockStatus ,
			'' as  OverallOrdReltdBillgStatus ,
			'' as  OverallSDDocReferenceStatus ,
			'INR' as  TransactionCurrency ,
			'' as  SDDocumentReason ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  PricingDate ,
			'1.00000' as  PriceDetnExchangeRate ,
			'' as  BillingPlan ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  RequestedDeliveryDate ,
			'01' as  ShippingCondition ,
			false as  CompleteDeliveryIsDefined ,
			'' as  ShippingType ,
			'' as  HeaderBillingBlockReason ,
			'' as  DeliveryBlockReason ,
			'' as  DeliveryDateTypeRule ,
			'CFR' as  IncotermsClassification ,
			'' as  IncotermsTransferLocation ,
			'NA' as  IncotermsLocation1 ,
			'' as  IncotermsLocation2 ,
			'' as  IncotermsVersion ,
			'' as  CustomerPriceGroup ,
			'' as  PriceListType ,
			'0001' as  CustomerPaymentTerms ,
			'' as  PaymentMethod ,
			'' as  AssignmentReference ,
			'' as  ReferenceSDDocument ,
			'' as  ReferenceSDDocumentCategory ,
			'' as  AccountingDocExternalReference ,
			'01' as  CustomerAccountAssignmentGroup ,
			'0.00000' as  AccountingExchangeRate ,
			'' as  CustomerGroup ,
			'' as  AdditionalCustomerGroup1 ,
			'' as  AdditionalCustomerGroup2 ,
			'' as  AdditionalCustomerGroup3 ,
			'' as  AdditionalCustomerGroup4 ,
			'' as  AdditionalCustomerGroup5 ,
			false as  SlsDocIsRlvtForProofOfDeliv ,
			'' as  CustomerTaxClassification1 ,
			'' as  CustomerTaxClassification2 ,
			'' as  CustomerTaxClassification3 ,
			'' as  CustomerTaxClassification4 ,
			'' as  CustomerTaxClassification5 ,
			'' as  CustomerTaxClassification6 ,
			'' as  CustomerTaxClassification7 ,
			'' as  CustomerTaxClassification8 ,
			'' as  CustomerTaxClassification9 ,
			'' as  TaxDepartureCountry ,
			'' as  VATRegistrationCountry ,
			'' as  SalesOrderApprovalReason ,
			'' as  SalesDocApprovalStatus ,
			'C' as  OverallSDProcessStatus ,
			'D' as  TotalCreditCheckStatus ,
			'C' as  OverallTotalDeliveryStatus ,
			'a' as  OverallSDDocumentRejectionSts ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  BillingDocumentDate ,
			'' as  ContractAccount ,
			'0' as  AdditionalValueDays ,
			'' as  CustomerPurchaseOrderSuplmnt 
			from t023_order_item t0231
			inner join t023_order_header t023 on
			t023.Org_Id = t0231.Org_Id
			and t023.Order_Id = t0231.Order_Id
			and t023.Is_Approved = 1
            and t023.Order_For ='agent'
            and t023.Order_By ='agent'
			inner join m005_mcc m005 on
			t023.Org_Id = m005.Org_Id
			and t023.MCC_Id = m005.MCC_Id
			where t0231.Org_Id = var_Org_Id
			and t0231.Product_Id = var_Product_Id
			and t0231.Order_Id = var_Order_Id
            
            union all
            
            select         
			'OR' as  SalesOrderType ,
			'1000' as  SalesOrganization ,
			'08' as  DistributionChannel ,
			'05' as  OrganizationDivision ,
			'SS1' as  SalesGroup ,
			'1000' as  SalesOffice ,
			'' as  SalesDistrict ,
			mu04.Farmer_Code as  SoldToParty ,
			CONCAT('/Date(',YEAR(NOW()),LPAD(MONTH(NOW()), 2, '0'),LPAD(DAY(NOW()), 2, '0'),HOUR(NOW()),MINUTE(NOW()),SECOND(NOW()),')/') as  CreationDate ,
			'CB9980000016' as  CreatedByUser ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  LastChangeDate ,
			'' as  SenderBusinessSystemName ,
			'' as  ExternalDocumentID ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),'+0000)/') as  LastChangeDateTime ,
			'' as  PurchaseOrderByCustomer ,
			'' as  PurchaseOrderByShipToParty ,
			'' as  CustomerPurchaseOrderType ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  SalesOrderDate ,
			'0' as  TotalNetAmount ,
			'C' as  OverallDeliveryStatus ,
			'' as  TotalBlockStatus ,
			'' as  OverallOrdReltdBillgStatus ,
			'' as  OverallSDDocReferenceStatus ,
			'INR' as  TransactionCurrency ,
			'' as  SDDocumentReason ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  PricingDate ,
			'1.00000' as  PriceDetnExchangeRate ,
			'' as  BillingPlan ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  RequestedDeliveryDate ,
			'01' as  ShippingCondition ,
			false as  CompleteDeliveryIsDefined ,
			'' as  ShippingType ,
			'' as  HeaderBillingBlockReason ,
			'' as  DeliveryBlockReason ,
			'' as  DeliveryDateTypeRule ,
			'CFR' as  IncotermsClassification ,
			'' as  IncotermsTransferLocation ,
			'NA' as  IncotermsLocation1 ,
			'' as  IncotermsLocation2 ,
			'' as  IncotermsVersion ,
			'' as  CustomerPriceGroup ,
			'' as  PriceListType ,
			'0001' as  CustomerPaymentTerms ,
			'' as  PaymentMethod ,
			'' as  AssignmentReference ,
			'' as  ReferenceSDDocument ,
			'' as  ReferenceSDDocumentCategory ,
			'' as  AccountingDocExternalReference ,
			'01' as  CustomerAccountAssignmentGroup ,
			'0.00000' as  AccountingExchangeRate ,
			'' as  CustomerGroup ,
			'' as  AdditionalCustomerGroup1 ,
			'' as  AdditionalCustomerGroup2 ,
			'' as  AdditionalCustomerGroup3 ,
			'' as  AdditionalCustomerGroup4 ,
			'' as  AdditionalCustomerGroup5 ,
			false as  SlsDocIsRlvtForProofOfDeliv ,
			'' as  CustomerTaxClassification1 ,
			'' as  CustomerTaxClassification2 ,
			'' as  CustomerTaxClassification3 ,
			'' as  CustomerTaxClassification4 ,
			'' as  CustomerTaxClassification5 ,
			'' as  CustomerTaxClassification6 ,
			'' as  CustomerTaxClassification7 ,
			'' as  CustomerTaxClassification8 ,
			'' as  CustomerTaxClassification9 ,
			'' as  TaxDepartureCountry ,
			'' as  VATRegistrationCountry ,
			'' as  SalesOrderApprovalReason ,
			'' as  SalesDocApprovalStatus ,
			'C' as  OverallSDProcessStatus ,
			'D' as  TotalCreditCheckStatus ,
			'C' as  OverallTotalDeliveryStatus ,
			'a' as  OverallSDDocumentRejectionSts ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  BillingDocumentDate ,
			'' as  ContractAccount ,
			'0' as  AdditionalValueDays ,
			'' as  CustomerPurchaseOrderSuplmnt 
			from t023_order_item t0231
			inner join t023_order_header t023 on
			t023.Org_Id = t0231.Org_Id
			and t023.Order_Id = t0231.Order_Id
			and t023.Is_Approved = 1
            and t023.Order_For ='farmer'
            and t023.Order_By ='farmer'
			inner join m005_mcc m005 on
			t023.Org_Id = m005.Org_Id
			and t023.MCC_Id = m005.MCC_Id
            inner join mu04_farmer mu04 on
			t023.Org_Id = mu04.Org_Id
			and t023.Order_For_User_Id = mu04.Farmer_Id
            and t023.Order_By_User_Id = mu04.Farmer_Id
			where t0231.Org_Id = var_Org_Id
			and t0231.Product_Id = var_Product_Id
			and t0231.Order_Id = var_Order_Id;
            
            /*
            union all
            
            
            select         
			'OR' as  SalesOrderType ,
			'1000' as  SalesOrganization ,
			'08' as  DistributionChannel ,
			'05' as  OrganizationDivision ,
			'SS1' as  SalesGroup ,
			'1000' as  SalesOffice ,
			'' as  SalesDistrict ,
			mu04.Farmer_Code as  SoldToParty ,
			CONCAT('/Date(',YEAR(NOW()),LPAD(MONTH(NOW()), 2, '0'),LPAD(DAY(NOW()), 2, '0'),HOUR(NOW()),MINUTE(NOW()),SECOND(NOW()),')/') as  CreationDate ,
			'CB9980000016' as  CreatedByUser ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  LastChangeDate ,
			'' as  SenderBusinessSystemName ,
			'' as  ExternalDocumentID ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),'+0000)/') as  LastChangeDateTime ,
			'' as  PurchaseOrderByCustomer ,
			'' as  PurchaseOrderByShipToParty ,
			'' as  CustomerPurchaseOrderType ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  SalesOrderDate ,
			'0' as  TotalNetAmount ,
			'C' as  OverallDeliveryStatus ,
			'' as  TotalBlockStatus ,
			'' as  OverallOrdReltdBillgStatus ,
			'' as  OverallSDDocReferenceStatus ,
			'INR' as  TransactionCurrency ,
			'' as  SDDocumentReason ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  PricingDate ,
			'1.00000' as  PriceDetnExchangeRate ,
			'' as  BillingPlan ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  RequestedDeliveryDate ,
			'01' as  ShippingCondition ,
			false as  CompleteDeliveryIsDefined ,
			'' as  ShippingType ,
			'' as  HeaderBillingBlockReason ,
			'' as  DeliveryBlockReason ,
			'' as  DeliveryDateTypeRule ,
			'CFR' as  IncotermsClassification ,
			'' as  IncotermsTransferLocation ,
			'NA' as  IncotermsLocation1 ,
			'' as  IncotermsLocation2 ,
			'' as  IncotermsVersion ,
			'' as  CustomerPriceGroup ,
			'' as  PriceListType ,
			'0001' as  CustomerPaymentTerms ,
			'' as  PaymentMethod ,
			'' as  AssignmentReference ,
			'' as  ReferenceSDDocument ,
			'' as  ReferenceSDDocumentCategory ,
			'' as  AccountingDocExternalReference ,
			'01' as  CustomerAccountAssignmentGroup ,
			'0.00000' as  AccountingExchangeRate ,
			'' as  CustomerGroup ,
			'' as  AdditionalCustomerGroup1 ,
			'' as  AdditionalCustomerGroup2 ,
			'' as  AdditionalCustomerGroup3 ,
			'' as  AdditionalCustomerGroup4 ,
			'' as  AdditionalCustomerGroup5 ,
			false as  SlsDocIsRlvtForProofOfDeliv ,
			'' as  CustomerTaxClassification1 ,
			'' as  CustomerTaxClassification2 ,
			'' as  CustomerTaxClassification3 ,
			'' as  CustomerTaxClassification4 ,
			'' as  CustomerTaxClassification5 ,
			'' as  CustomerTaxClassification6 ,
			'' as  CustomerTaxClassification7 ,
			'' as  CustomerTaxClassification8 ,
			'' as  CustomerTaxClassification9 ,
			'' as  TaxDepartureCountry ,
			'' as  VATRegistrationCountry ,
			'' as  SalesOrderApprovalReason ,
			'' as  SalesDocApprovalStatus ,
			'C' as  OverallSDProcessStatus ,
			'D' as  TotalCreditCheckStatus ,
			'C' as  OverallTotalDeliveryStatus ,
			'a' as  OverallSDDocumentRejectionSts ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  BillingDocumentDate ,
			'' as  ContractAccount ,
			'0' as  AdditionalValueDays ,
			'' as  CustomerPurchaseOrderSuplmnt 
			from t023_order_item t0231
			inner join t023_order_header t023 on
			t023.Org_Id = t0231.Org_Id
			and t023.Order_Id = t0231.Order_Id
			and t023.Is_Approved = 1
            and t023.Order_For ='farmer'
            and t023.Order_By ='agent'
			inner join m005_mcc m005 on
			t023.Org_Id = m005.Org_Id
			and t023.MCC_Id = m005.MCC_Id
            inner join mu04_farmer mu04 on
			t023.Org_Id = mu04.Org_Id
			and t023.Order_For_User_Id = mu04.Farmer_Id
            and t023.Order_By_User_Id = mu04.Farmer_Id
			where t0231.Org_Id = var_Org_Id
			and t0231.Product_Id = var_Product_Id
			and t0231.Order_Id = var_Order_Id;
            
            */
        end;
	elseif(var_Method_Name = 'Get_To_Item') then
		begin
			select        
			'10' as  SalesOrderItem ,
			m010.Material_Code as  Material ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  PricingDate ,
			t0231.Quantity as  RequestedQuantity ,
			t0231.Quantity as  ConfdDelivQtyInOrderQtyUnit ,
			concat('/Date(',(UNIX_TIMESTAMP(CONVERT_TZ(now(), '+00:00', '+05:30')) * 1000),')/') as  BillingDocumentDate ,
			false as  DeliveryDateQuantityIsFixed ,
			false as  SlsDocIsRlvtForProofOfDeliv 
			from t023_order_item t0231
			inner join t023_order_header t023 on
			t023.Org_Id = t0231.Org_Id
			and t023.Order_Id = t0231.Order_Id
			and t023.Is_Approved = 1
			inner join m010_material m010 on
			m010.Org_Id = t0231.Org_Id
			and m010.Material_Id = t0231.Product_Id
			where t0231.Org_Id = var_Org_Id
			and t0231.Product_Id = var_Product_Id
			and t0231.Order_Id = var_Order_Id;
        end;
	elseif(var_Method_Name = 'Get_To_Pricingelement') then
		begin
			select         
			'10' as  SalesOrderItem ,
            'PPR0' as  ConditionType ,
            '0' as  ConditionRateValue
			from t023_order_item t0231
			inner join t023_order_header t023 on
			t023.Org_Id = t0231.Org_Id
			and t023.Order_Id = t0231.Order_Id
			and t023.Is_Approved = 1
			where t0231.Org_Id = var_Org_Id
			and t0231.Product_Id = var_Product_Id
			and t0231.Order_Id = var_Order_Id;
        end;
	end if;
END ;;
DELIMITER ;

-- Dump completed on 2026-05-12 17:16:27
