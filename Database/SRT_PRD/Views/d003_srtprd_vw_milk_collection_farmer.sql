-- View Structure

-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP VIEW IF EXISTS `vw_milk_collection_farmer`;
CREATE ALGORITHM=UNDEFINED DEFINER=`appuser`@`%` SQL SECURITY DEFINER VIEW `vw_milk_collection_farmer` AS select `mu04`.`Farmer_Code` AS `Farmer_Code`,`mu04`.`Farmer_Name` AS `Farmer_Name`,`m005`.`MCC_Code` AS `MCC_Code`,`m005`.`MCC_Name` AS `MCC_Name`,`c014`.`MCCType_Name` AS `MCCType_Name`,`c023`.`MCCWorkType_Name` AS `MCCWorkType_Name`,`c015`.`CollectionShift_Name` AS `CollectionShift_Name`,`t005`.`MilkType_Id` AS `MilkType_Id`,`t005`.`MilkStatus_Id` AS `MilkStatus_Id`,`t005`.`Quantity_Ltr` AS `Quantity_Ltr`,`t005`.`Quantity_Kg` AS `Quantity_Kg`,`t005`.`Fat` AS `Fat`,`t005`.`SNF` AS `SNF`,`t005`.`Protein` AS `Protein`,`t005`.`ApplicableRate` AS `ApplicableRate`,`t005`.`Amount` AS `Amount`,`t005`.`MusterCycle_StartDate` AS `MusterCycle_StartDate`,`t005`.`MusterCycle_EndDate` AS `MusterCycle_EndDate`,cast(`t005`.`Created_On` as date) AS `Created_On` from ((((((`t005_milkcollectionfarmer` `t005` join `t004_mcccollectionshift` `t004` on(((`t004`.`Org_Id` = `t005`.`Org_Id`) and (`t004`.`MCCCollectionShift_Id` = `t005`.`MCCCollectionShift_Id`)))) join `c015_collectionshift` `c015` on((`c015`.`CollectionShift_Id` = `t004`.`CollectionShift_Id`))) join `m005_mcc` `m005` on(((`m005`.`Org_Id` = `t005`.`Org_Id`) and (`m005`.`MCC_Id` = `t005`.`MCC_Id`)))) join `c014_mcctype` `c014` on((`c014`.`MCCType_Id` = `m005`.`MCCType_Id`))) join `c023_mccworktype` `c023` on((`c023`.`MCCWorkType_Id` = `m005`.`MCCWorkType_Id`))) join `mu04_farmer` `mu04` on(((`t005`.`Org_Id` = `mu04`.`Org_Id`) and (`mu04`.`Farmer_Id` = `t005`.`Farmer_Id`))));

-- Dump completed on 2026-05-12 17:16:23
