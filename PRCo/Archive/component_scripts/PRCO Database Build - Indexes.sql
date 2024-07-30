SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[vPRLocation]') AND name = N'ndx_vPRLocation')
	DROP INDEX [ndx_vPRLocation] ON [dbo].[vPRLocation] WITH ( ONLINE = OFF )
GO
--CREATE UNIQUE CLUSTERED INDEX ndx_vPRLocation ON vPRLocation (prci_cityid)
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[vPRCompanyLocation]') AND name = N'ndx_vPRCompanyLocation')
	DROP INDEX [ndx_vPRCompanyLocation] ON [dbo].[vPRCompanyLocation] WITH ( ONLINE = OFF )
GO
--CREATE UNIQUE CLUSTERED INDEX ndx_vPRCompanyLocation ON vPRCompanyLocation (comp_companyid)
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_addr_PRCityId')
     Create index ndx_addr_PRCityId on Address (addr_PRCityId) WITH DROP_EXISTING
ELSE
     Create index ndx_addr_PRCityId on Address (addr_PRCityId)
GO

/*
-- Aren't these already defined by CRM?  - CHW
IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_AdLi_AddressId')
     Create index ndx_AdLi_AddressId on Address_Link (AdLi_AddressId) WITH DROP_EXISTING
ELSE
     Create index ndx_AdLi_AddressId on Address_Link (AdLi_AddressId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_AdLi_CompanyID')
     Create index ndx_AdLi_CompanyID on Address_Link (AdLi_CompanyID) WITH DROP_EXISTING
ELSE
     Create index ndx_AdLi_CompanyID on Address_Link (AdLi_CompanyID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_AdLi_PersonID')
     Create index ndx_AdLi_PersonID on Address_Link (AdLi_PersonID) WITH DROP_EXISTING
ELSE
     Create index ndx_AdLi_PersonID on Address_Link (AdLi_PersonID)
GO
*/

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_AddressLink_TES')
    CREATE NONCLUSTERED INDEX ndx_AddressLink_TES ON Address_Link ([adli_PRDefaultTES] ASC, [AdLi_Deleted] ASC, [AdLi_AddressId] ASC, [AdLi_CompanyID] ASC) WITH DROP_EXISTING
ELSE
    CREATE NONCLUSTERED INDEX ndx_AddressLink_TES ON Address_Link ([adli_PRDefaultTES] ASC, [AdLi_Deleted] ASC,	[AdLi_AddressId] ASC, [AdLi_CompanyID] ASC)
GO


/*
-- Aren't these already defined by CRM?  - CHW
IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_CmLi_Comm_PersonId')
     Create index ndx_CmLi_Comm_PersonId on Comm_Link (CmLi_Comm_PersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_CmLi_Comm_PersonId on Comm_Link (CmLi_Comm_PersonId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_CmLi_Comm_CompanyId')
     Create index ndx_CmLi_Comm_CompanyId on Comm_Link (CmLi_Comm_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_CmLi_Comm_CompanyId on Comm_Link (CmLi_Comm_CompanyId)
GO
*/

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comm_PRBusinessEventId')
     Create index ndx_comm_PRBusinessEventId on Communication (comm_PRBusinessEventId) WITH DROP_EXISTING
ELSE
     Create index ndx_comm_PRBusinessEventId on Communication (comm_PRBusinessEventId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comm_PRPersonEventId')
     Create index ndx_comm_PRPersonEventId on Communication (comm_PRPersonEventId) WITH DROP_EXISTING
ELSE
     Create index ndx_comm_PRPersonEventId on Communication (comm_PRPersonEventId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comm_PRTESId')
     Create index ndx_comm_PRTESId on Communication (comm_PRTESId) WITH DROP_EXISTING
ELSE
     Create index ndx_comm_PRTESId on Communication (comm_PRTESId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comm_PRCreditSheetId')
     Create index ndx_comm_PRCreditSheetId on Communication (comm_PRCreditSheetId) WITH DROP_EXISTING
ELSE
     Create index ndx_comm_PRCreditSheetId on Communication (comm_PRCreditSheetId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comm_PRFileId')
     Create index ndx_comm_PRFileId on Communication (comm_PRFileId) WITH DROP_EXISTING
ELSE
     Create index ndx_comm_PRFileId on Communication (comm_PRFileId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comp_PRListingCityId')
     Create index ndx_comp_PRListingCityId on Company (comp_PRListingCityId) WITH DROP_EXISTING
ELSE
     Create index ndx_comp_PRListingCityId on Company (comp_PRListingCityId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comp_PRType')
     Create index ndx_comp_PRType on Company (comp_PRType) WITH DROP_EXISTING
ELSE
     Create index ndx_comp_PRType on Company (comp_PRType)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comp_PRHQID')
     Create index ndx_comp_PRHQID on Company (comp_PRHQID) WITH DROP_EXISTING
ELSE
     Create index ndx_comp_PRHQID on Company (comp_PRHQID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comp_PRServicesThroughCompanyId')
     Create index ndx_comp_PRServicesThroughCompanyId on Company (comp_PRServicesThroughCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_comp_PRServicesThroughCompanyId on Company (comp_PRServicesThroughCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_ListingSpecialistId')
     Create index ndx_prci_ListingSpecialistId on PRCity (prci_ListingSpecialistId) WITH DROP_EXISTING
ELSE
     Create index ndx_prci_ListingSpecialistId on PRCity (prci_ListingSpecialistId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_RatingUserId')
     Create index ndx_prci_RatingUserId on PRCity (prci_RatingUserId) WITH DROP_EXISTING
ELSE
     Create index ndx_prci_RatingUserId on PRCity (prci_RatingUserId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_CustomerServiceId')
     Create index ndx_prci_CustomerServiceId on PRCity (prci_CustomerServiceId) WITH DROP_EXISTING
ELSE
     Create index ndx_prci_CustomerServiceId on PRCity (prci_CustomerServiceId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_InsideSalesRepId')
     Create index ndx_prci_InsideSalesRepId on PRCity (prci_InsideSalesRepId) WITH DROP_EXISTING
ELSE
     Create index ndx_prci_InsideSalesRepId on PRCity (prci_InsideSalesRepId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_FieldSalesRepId')
     Create index ndx_prci_FieldSalesRepId on PRCity (prci_FieldSalesRepId) WITH DROP_EXISTING
ELSE
     Create index ndx_prci_FieldSalesRepId on PRCity (prci_FieldSalesRepId)
GO


-- specific indexc for vSearchListPerson queries
IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_pers_NameId')
     Create index ndx_pers_NameId on Person (pers_LastName, pers_FirstName, pers_PersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_pers_NameId on Person (pers_LastName, pers_FirstName, pers_PersonId)
GO

/*
-- Aren't these already defined by CRM?  - CHW
IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_Pers_CompanyId')
     Create index ndx_Pers_CompanyId on Person (Pers_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_Pers_CompanyId on Person (Pers_CompanyId)
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_PeLi_PersonId')
     Create index ndx_PeLi_PersonId on Person_Link (PeLi_PersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_PeLi_PersonId on Person_Link (PeLi_PersonId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_PeLi_CompanyID')
     Create index ndx_PeLi_CompanyID on Person_Link (PeLi_CompanyID) WITH DROP_EXISTING
ELSE
     Create index ndx_PeLi_CompanyID on Person_Link (PeLi_CompanyID)
GO
*/

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_peli_PRCompanyId')
     Create index ndx_peli_PRCompanyId on Person_Link (peli_PRCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_peli_PRCompanyId on Person_Link (peli_PRCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_peli_PRCompanyId')
     Create index ndx_peli_PRCompanyId on Person_Link (peli_PRCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_peli_PRCompanyId on Person_Link (peli_PRCompanyId)
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_peli_PRStatus_peli_PRRole')
     CREATE NONCLUSTERED INDEX ndx_peli_PRStatus_peli_PRRole ON [dbo].[Person_Link] ([peli_PRStatus] ASC, [peli_PRRole] ASC) WITH DROP_EXISTING
ELSE
     CREATE NONCLUSTERED INDEX ndx_peli_PRStatus_peli_PRRole ON [dbo].[Person_Link] ([peli_PRStatus] ASC, [peli_PRRole] ASC)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_peli_PRStatus_peli_PROwnershipRole')
     CREATE NONCLUSTERED INDEX ndx_peli_PRStatus_peli_PROwnershipRole ON [dbo].[Person_Link] ([peli_PRStatus] ASC, [peli_PROwnershipRole] ASC) WITH DROP_EXISTING
ELSE
     CREATE NONCLUSTERED INDEX ndx_peli_PRStatus_peli_PROwnershipRole ON [dbo].[Person_Link] ([peli_PRStatus] ASC, [peli_PROwnershipRole] ASC)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_peli_PRStatus_peli_PRRecipientRole')
     CREATE NONCLUSTERED INDEX ndx_peli_PRStatus_peli_PRRecipientRole ON [dbo].[Person_Link] ([peli_PRStatus] ASC, [peli_PRRecipientRole] ASC) WITH DROP_EXISTING
ELSE
     CREATE NONCLUSTERED INDEX ndx_peli_PRStatus_peli_PRRecipientRole ON [dbo].[Person_Link] ([peli_PRStatus] ASC, [peli_PRRecipientRole] ASC)
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_Phon_CompanyID')
     Create index ndx_Phon_CompanyID on Phone (Phon_CompanyID) WITH DROP_EXISTING
ELSE
     Create index ndx_Phon_CompanyID on Phone (Phon_CompanyID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_Phon_PersonID')
     Create index ndx_Phon_PersonID on Phone (Phon_PersonID) WITH DROP_EXISTING
ELSE
     Create index ndx_Phon_PersonID on Phone (Phon_PersonID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_praa_CompanyId')
     Create index ndx_praa_CompanyId on PRARAging (praa_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_praa_CompanyId on PRARAging (praa_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_praa_PersonId')
     Create index ndx_praa_PersonId on PRARAging (praa_PersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_praa_PersonId on PRARAging (praa_PersonId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_praad_ARAgingId')
     Create index ndx_praad_ARAgingId on PRARAgingDetail (praad_ARAgingId) WITH DROP_EXISTING
ELSE
     Create index ndx_praad_ARAgingId on PRARAgingDetail (praad_ARAgingId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_praad_ARCustomerId')
     Create index ndx_praad_ARCustomerId on PRARAgingDetail (praad_ARCustomerId) WITH DROP_EXISTING
ELSE
     Create index ndx_praad_ARCustomerId on PRARAgingDetail (praad_ARCustomerId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_praad_ManualCompanyId')
     Create index ndx_praad_ManualCompanyId on PRARAgingDetail (praad_ManualCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_praad_ManualCompanyId on PRARAgingDetail (praad_ManualCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prar_CompanyId')
     Create index ndx_prar_CompanyId on PRARTranslation (prar_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prar_CompanyId on PRARTranslation (prar_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prar_PRCoCompanyId')
     Create index ndx_prar_PRCoCompanyId on PRARTranslation (prar_PRCoCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prar_PRCoCompanyId on PRARTranslation (prar_PRCoCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prau_PersonId')
     Create index ndx_prau_PersonId on PRAUS (prau_PersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_prau_PersonId on PRAUS (prau_PersonId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prau_CompanyId')
     Create index ndx_prau_CompanyId on PRAUS (prau_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prau_CompanyId on PRAUS (prau_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbs_CompanyId')
     Create index ndx_prbs_CompanyId on PRBBScore (prbs_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prbs_CompanyId on PRBBScore (prbs_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbe_CompanyId')
     Create index ndx_prbe_CompanyId on PRBusinessEvent (prbe_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prbe_CompanyId on PRBusinessEvent (prbe_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbe_BusinessEventTypeId')
     Create index ndx_prbe_BusinessEventTypeId on PRBusinessEvent (prbe_BusinessEventTypeId) WITH DROP_EXISTING
ELSE
     Create index ndx_prbe_BusinessEventTypeId on PRBusinessEvent (prbe_BusinessEventTypeId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbe_IndividualBuyerId')
     Create index ndx_prbe_IndividualBuyerId on PRBusinessEvent (prbe_IndividualBuyerId) WITH DROP_EXISTING
ELSE
     Create index ndx_prbe_IndividualBuyerId on PRBusinessEvent (prbe_IndividualBuyerId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbe_IndividualSellerId')
     Create index ndx_prbe_IndividualSellerId on PRBusinessEvent (prbe_IndividualSellerId) WITH DROP_EXISTING
ELSE
     Create index ndx_prbe_IndividualSellerId on PRBusinessEvent (prbe_IndividualSellerId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbe_RelatedCompany1Id')
     Create index ndx_prbe_RelatedCompany1Id on PRBusinessEvent (prbe_RelatedCompany1Id) WITH DROP_EXISTING
ELSE
     Create index ndx_prbe_RelatedCompany1Id on PRBusinessEvent (prbe_RelatedCompany1Id)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbe_RelatedCompany2Id')
     Create index ndx_prbe_RelatedCompany2Id on PRBusinessEvent (prbe_RelatedCompany2Id) WITH DROP_EXISTING
ELSE
     Create index ndx_prbe_RelatedCompany2Id on PRBusinessEvent (prbe_RelatedCompany2Id)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbe_StateId')
     Create index ndx_prbe_StateId on PRBusinessEvent (prbe_StateId) WITH DROP_EXISTING
ELSE
     Create index ndx_prbe_StateId on PRBusinessEvent (prbe_StateId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbr_RequestingCompanyId')
     Create index ndx_prbr_RequestingCompanyId on PRBusinessReportRequest (prbr_RequestingCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prbr_RequestingCompanyId on PRBusinessReportRequest (prbr_RequestingCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbr_RequestingPersonId')
     Create index ndx_prbr_RequestingPersonId on PRBusinessReportRequest (prbr_RequestingPersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_prbr_RequestingPersonId on PRBusinessReportRequest (prbr_RequestingPersonId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prbr_RequestedCompanyId')
     Create index ndx_prbr_RequestedCompanyId on PRBusinessReportRequest (prbr_RequestedCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prbr_RequestedCompanyId on PRBusinessReportRequest (prbr_RequestedCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_StateId')
     Create index ndx_prci_StateId on PRCity (prci_StateId) WITH DROP_EXISTING
ELSE
     Create index ndx_prci_StateId on PRCity (prci_StateId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_RatingUserId')
     Create index ndx_prci_RatingUserId on PRCity (prci_RatingUserId) WITH DROP_EXISTING
ELSE
     Create index ndx_prci_RatingUserId on PRCity (prci_RatingUserId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_InsideSalesRepId')
     Create index ndx_prci_InsideSalesRepId on PRCity (prci_InsideSalesRepId) WITH DROP_EXISTING
ELSE
     Create index ndx_prci_InsideSalesRepId on PRCity (prci_InsideSalesRepId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_FieldSalesRepId')
     Create index ndx_prci_FieldSalesRepId on PRCity (prci_FieldSalesRepId) WITH DROP_EXISTING
ELSE
     Create index ndx_prci_FieldSalesRepId on PRCity (prci_FieldSalesRepId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_ListingSpecialistId')
     Create index ndx_prci_ListingSpecialistId on PRCity (prci_ListingSpecialistId) WITH DROP_EXISTING
ELSE
     Create index ndx_prci_ListingSpecialistId on PRCity (prci_ListingSpecialistId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prci_CityId_prci_StateId')
     CREATE NONCLUSTERED INDEX ndx_prci_CityId_prci_StateId ON PRCity ([prci_CityId] ASC, [prci_StateId] ASC) INCLUDE ([prci_City])  WITH DROP_EXISTING
ELSE
     CREATE NONCLUSTERED INDEX ndx_prci_CityId_prci_StateId ON PRCity ([prci_CityId] ASC, [prci_StateId] ASC) INCLUDE ([prci_City]) 
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcl_ParentId')
     Create index ndx_prcl_ParentId on PRClassification (prcl_ParentId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcl_ParentId on PRClassification (prcl_ParentId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcm_ParentId')
     Create index ndx_prcm_ParentId on PRCommodity (prcm_ParentId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcm_ParentId on PRCommodity (prcm_ParentId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_pral_CompanyId')
     Create index ndx_pral_CompanyId on PRCompanyAlias (pral_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_pral_CompanyId on PRCompanyAlias (pral_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcb_CompanyId')
     Create index ndx_prcb_CompanyId on PRCompanyBank (prcb_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcb_CompanyId on PRCompanyBank (prcb_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prc3_CompanyId')
     Create index ndx_prc3_CompanyId on PRCompanyBrand (prc3_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prc3_CompanyId on PRCompanyBrand (prc3_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prc2_CompanyId')
     Create index ndx_prc2_CompanyId on PRCompanyClassification (prc2_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prc2_CompanyId on PRCompanyClassification (prc2_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prc2_ClassificationId')
     Create index ndx_prc2_ClassificationId on PRCompanyClassification (prc2_ClassificationId) WITH DROP_EXISTING
ELSE
     Create index ndx_prc2_ClassificationId on PRCompanyClassification (prc2_ClassificationId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcc_CompanyId')
     Create index ndx_prcc_CompanyId on PRCompanyCommodity (prcc_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcc_CompanyId on PRCompanyCommodity (prcc_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcc_CommodityId')
     Create index ndx_prcc_CommodityId on PRCompanyCommodity (prcc_CommodityId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcc_CommodityId on PRCompanyCommodity (prcc_CommodityId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcca_CompanyId')
     Create index ndx_prcca_CompanyId on PRCompanyCommodityAttribute (prcca_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcca_CompanyId on PRCompanyCommodityAttribute (prcca_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcca_CommodityId')
     Create index ndx_prcca_CommodityId on PRCompanyCommodityAttribute (prcca_CommodityId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcca_CommodityId on PRCompanyCommodityAttribute (prcca_CommodityId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcca_AttributeId')
     Create index ndx_prcca_AttributeId on PRCompanyCommodityAttribute (prcca_AttributeId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcca_AttributeId on PRCompanyCommodityAttribute (prcca_AttributeId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcd_CompanyId')
     Create index ndx_prcd_CompanyId on PRCompanyRegion (prcd_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcd_CompanyId on PRCompanyRegion (prcd_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcd_RegionId')
     Create index ndx_prcd_RegionId on PRCompanyRegion (prcd_RegionId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcd_RegionId on PRCompanyRegion (prcd_RegionId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prc5_CompanyId')
     Create index ndx_prc5_CompanyId on PRCompanyInfoProfile (prc5_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prc5_CompanyId on PRCompanyInfoProfile (prc5_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prc5_InformationProfileUserId')
     Create index ndx_prc5_InformationProfileUserId on PRCompanyInfoProfile (prc5_InformationProfileUserId) WITH DROP_EXISTING
ELSE
     Create index ndx_prc5_InformationProfileUserId on PRCompanyInfoProfile (prc5_InformationProfileUserId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prli_CompanyId')
     Create index ndx_prli_CompanyId on PRCompanyLicense (prli_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prli_CompanyId on PRCompanyLicense (prli_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcp_CompanyId')
     Create index ndx_prcp_CompanyId on PRCompanyProfile (prcp_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcp_CompanyId on PRCompanyProfile (prcp_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcr_LeftCompanyId')
     Create index ndx_prcr_LeftCompanyId on PRCompanyRelationship (prcr_LeftCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcr_LeftCompanyId on PRCompanyRelationship (prcr_LeftCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcr_RightCompanyId')
     Create index ndx_prcr_RightCompanyId on PRCompanyRelationship (prcr_RightCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcr_RightCompanyId on PRCompanyRelationship (prcr_RightCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prc4_CompanyId')
     Create index ndx_prc4_CompanyId on PRCompanyStockExchange (prc4_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prc4_CompanyId on PRCompanyStockExchange (prc4_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prc4_StockExchangeId')
     Create index ndx_prc4_StockExchangeId on PRCompanyStockExchange (prc4_StockExchangeId) WITH DROP_EXISTING
ELSE
     Create index ndx_prc4_StockExchangeId on PRCompanyStockExchange (prc4_StockExchangeId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prct_CompanyId')
     Create index ndx_prct_CompanyId on PRCompanyTerminalMarket (prct_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prct_CompanyId on PRCompanyTerminalMarket (prct_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prct_TerminalMarketId')
     Create index ndx_prct_TerminalMarketId on PRCompanyTerminalMarket (prct_TerminalMarketId) WITH DROP_EXISTING
ELSE
     Create index ndx_prct_TerminalMarketId on PRCompanyTerminalMarket (prct_TerminalMarketId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcs_CompanyId')
     Create index ndx_prcs_CompanyId on PRCreditSheet (prcs_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcs_CompanyId on PRCreditSheet (prcs_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcs_AuthorId')
     Create index ndx_prcs_AuthorId on PRCreditSheet (prcs_AuthorId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcs_AuthorId on PRCreditSheet (prcs_AuthorId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcs_ApproverId')
     Create index ndx_prcs_ApproverId on PRCreditSheet (prcs_ApproverId) WITH DROP_EXISTING
ELSE
     Create index ndx_prcs_ApproverId on PRCreditSheet (prcs_ApproverId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prdc_DealId')
     Create index ndx_prdc_DealId on PRDealCommodity (prdc_DealId) WITH DROP_EXISTING
ELSE
     Create index ndx_prdc_DealId on PRDealCommodity (prdc_DealId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prdt_DealId')
     Create index ndx_prdt_DealId on PRDealTerritory (prdt_DealId) WITH DROP_EXISTING
ELSE
     Create index ndx_prdt_DealId on PRDealTerritory (prdt_DealId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prdl_CompanyId')
     Create index ndx_prdl_CompanyId on PRDescriptiveLine (prdl_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prdl_CompanyId on PRDescriptiveLine (prdl_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prd2_ParentId')
     Create index ndx_prd2_ParentId on PRRegion (prd2_ParentId) WITH DROP_EXISTING
ELSE
     Create index ndx_prd2_ParentId on PRRegion (prd2_ParentId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prdr_CompanyId')
     Create index ndx_prdr_CompanyId on PRDRCLicense (prdr_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prdr_CompanyId on PRDRCLicense (prdr_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_preq_TradeReportId')
     Create index ndx_preq_TradeReportId on PRExceptionQueue (preq_TradeReportId) WITH DROP_EXISTING
ELSE
     Create index ndx_preq_TradeReportId on PRExceptionQueue (preq_TradeReportId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_preq_ARAgingId')
     Create index ndx_preq_ARAgingId on PRExceptionQueue (preq_ARAgingId) WITH DROP_EXISTING
ELSE
     Create index ndx_preq_ARAgingId on PRExceptionQueue (preq_ARAgingId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_preq_CompanyId')
     Create index ndx_preq_CompanyId on PRExceptionQueue (preq_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_preq_CompanyId on PRExceptionQueue (preq_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_preq_AssignedUserId')
     Create index ndx_preq_AssignedUserId on PRExceptionQueue (preq_AssignedUserId) WITH DROP_EXISTING
ELSE
     Create index ndx_preq_AssignedUserId on PRExceptionQueue (preq_AssignedUserId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_preq_ClosedById')
     Create index ndx_preq_ClosedById on PRExceptionQueue (preq_ClosedById) WITH DROP_EXISTING
ELSE
     Create index ndx_preq_ClosedById on PRExceptionQueue (preq_ClosedById)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prfp_FileId')
     Create index ndx_prfp_FileId on PRFilePayment (prfp_FileId) WITH DROP_EXISTING
ELSE
     Create index ndx_prfp_FileId on PRFilePayment (prfp_FileId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prfs_CompanyId')
     Create index ndx_prfs_CompanyId on PRFinancial (prfs_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prfs_CompanyId on PRFinancial (prfs_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prfs_LibraryId')
     Create index ndx_prfs_LibraryId on PRFinancial (prfs_LibraryId) WITH DROP_EXISTING
ELSE
     Create index ndx_prfs_LibraryId on PRFinancial (prfs_LibraryId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prfd_FinancialId')
     Create index ndx_prfd_FinancialId on PRFinancialDetail (prfd_FinancialId) WITH DROP_EXISTING
ELSE
     Create index ndx_prfd_FinancialId on PRFinancialDetail (prfd_FinancialId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_pric_UOMID')
     Create index ndx_pric_UOMID on Pricing (pric_UOMID) WITH DROP_EXISTING
ELSE
     Create index ndx_pric_UOMID on Pricing (pric_UOMID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_pric_ProductID')
     Create index ndx_pric_ProductID on Pricing (pric_ProductID) WITH DROP_EXISTING
ELSE
     Create index ndx_pric_ProductID on Pricing (pric_ProductID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_pric_price_CID')
     Create index ndx_pric_price_CID on Pricing (pric_price_CID) WITH DROP_EXISTING
ELSE
     Create index ndx_pric_price_CID on Pricing (pric_price_CID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_pric_PricingListID')
     Create index ndx_pric_PricingListID on Pricing (pric_PricingListID) WITH DROP_EXISTING
ELSE
     Create index ndx_pric_PricingListID on Pricing (pric_PricingListID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prip_ImportPACALicenseId')
     Create index ndx_prip_ImportPACALicenseId on PRImportPACAPrincipal (prip_ImportPACALicenseId) WITH DROP_EXISTING
ELSE
     Create index ndx_prip_ImportPACALicenseId on PRImportPACAPrincipal (prip_ImportPACALicenseId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prit_ImportPACALicenseId')
     Create index ndx_prit_ImportPACALicenseId on PRImportPACATrade (prit_ImportPACALicenseId) WITH DROP_EXISTING
ELSE
     Create index ndx_prit_ImportPACALicenseId on PRImportPACATrade (prit_ImportPACALicenseId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_Prod_ListPrice_CID')
     Create index ndx_Prod_ListPrice_CID on Products (Prod_ListPrice_CID) WITH DROP_EXISTING
ELSE
     Create index ndx_Prod_ListPrice_CID on Products (Prod_ListPrice_CID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prow_CompanyId')
     Create index ndx_prow_CompanyId on PROwnership (prow_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prow_CompanyId on PROwnership (prow_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prpa_CompanyId')
     Create index ndx_prpa_CompanyId on PRPACALicense (prpa_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prpa_CompanyId on PRPACALicense (prpa_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prpp_PACALicenseId')
     Create index ndx_prpp_PACALicenseId on PRPACAPrincipal (prpp_PACALicenseId) WITH DROP_EXISTING
ELSE
     Create index ndx_prpp_PACALicenseId on PRPACAPrincipal (prpp_PACALicenseId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_ptrd_PACALicenseId')
     Create index ndx_ptrd_PACALicenseId on PRPACATrade (ptrd_PACALicenseId) WITH DROP_EXISTING
ELSE
     Create index ndx_ptrd_PACALicenseId on PRPACATrade (ptrd_PACALicenseId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prba_PersonId')
     Create index ndx_prba_PersonId on PRPersonBackground (prba_PersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_prba_PersonId on PRPersonBackground (prba_PersonId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prpe_PersonId')
     Create index ndx_prpe_PersonId on PRPersonEvent (prpe_PersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_prpe_PersonId on PRPersonEvent (prpe_PersonId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prpe_PersonEventTypeId')
     Create index ndx_prpe_PersonEventTypeId on PRPersonEvent (prpe_PersonEventTypeId) WITH DROP_EXISTING
ELSE
     Create index ndx_prpe_PersonEventTypeId on PRPersonEvent (prpe_PersonEventTypeId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prpr_LeftPersonId')
     Create index ndx_prpr_LeftPersonId on PRPersonRelationship (prpr_LeftPersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_prpr_LeftPersonId on PRPersonRelationship (prpr_LeftPersonId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prpr_RightPersonId')
     Create index ndx_prpr_RightPersonId on PRPersonRelationship (prpr_RightPersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_prpr_RightPersonId on PRPersonRelationship (prpr_RightPersonId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prra_CompanyId')
     Create index ndx_prra_CompanyId on PRRating (prra_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prra_CompanyId on PRRating (prra_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prra_CreditWorthId')
     Create index ndx_prra_CreditWorthId on PRRating (prra_CreditWorthId) WITH DROP_EXISTING
ELSE
     Create index ndx_prra_CreditWorthId on PRRating (prra_CreditWorthId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prra_IntegrityId')
     Create index ndx_prra_IntegrityId on PRRating (prra_IntegrityId) WITH DROP_EXISTING
ELSE
     Create index ndx_prra_IntegrityId on PRRating (prra_IntegrityId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prra_PayRatingId')
     Create index ndx_prra_PayRatingId on PRRating (prra_PayRatingId) WITH DROP_EXISTING
ELSE
     Create index ndx_prra_PayRatingId on PRRating (prra_PayRatingId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_pran_RatingId')
     Create index ndx_pran_RatingId on PRRatingNumeralAssigned (pran_RatingId) WITH DROP_EXISTING
ELSE
     Create index ndx_pran_RatingId on PRRatingNumeralAssigned (pran_RatingId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_pran_RatingNumeralId')
     Create index ndx_pran_RatingNumeralId on PRRatingNumeralAssigned (pran_RatingNumeralId) WITH DROP_EXISTING
ELSE
     Create index ndx_pran_RatingNumeralId on PRRatingNumeralAssigned (pran_RatingNumeralId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prse_CompanyId')
     Create index ndx_prse_CompanyId on PRService (prse_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prse_CompanyId on PRService (prse_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prse_BillToCompanyId')
     Create index ndx_prse_BillToCompanyId on PRService (prse_BillToCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prse_BillToCompanyId on PRService (prse_BillToCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prse_HoldShipmentId')
     Create index ndx_prse_HoldShipmentId on PRService (prse_HoldShipmentId) WITH DROP_EXISTING
ELSE
     Create index ndx_prse_HoldShipmentId on PRService (prse_HoldShipmentId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prse_HoldMailId')
     Create index ndx_prse_HoldMailId on PRService (prse_HoldMailId) WITH DROP_EXISTING
ELSE
     Create index ndx_prse_HoldMailId on PRService (prse_HoldMailId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prsp_ServiceId')
     Create index ndx_prsp_ServiceId on PRServicePayment (prsp_ServiceId) WITH DROP_EXISTING
ELSE
     Create index ndx_prsp_ServiceId on PRServicePayment (prsp_ServiceId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prst_CountryId')
     Create index ndx_prst_CountryId on PRState (prst_CountryId) WITH DROP_EXISTING
ELSE
     Create index ndx_prst_CountryId on PRState (prst_CountryId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prte_ResponderCompanyId')
     Create index ndx_prte_ResponderCompanyId on PRTES (prte_ResponderCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prte_ResponderCompanyId on PRTES (prte_ResponderCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prt2_TESId')
     Create index ndx_prt2_TESId on PRTESDetail (prt2_TESId) WITH DROP_EXISTING
ELSE
     Create index ndx_prt2_TESId on PRTESDetail (prt2_TESId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prt2_SubjectCompanyId')
     Create index ndx_prt2_SubjectCompanyId on PRTESDetail (prt2_SubjectCompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prt2_SubjectCompanyId on PRTESDetail (prt2_SubjectCompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtr_ResponderId')
     Create index ndx_prtr_ResponderId on PRTradeReport (prtr_ResponderId) WITH DROP_EXISTING
ELSE
     Create index ndx_prtr_ResponderId on PRTradeReport (prtr_ResponderId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtr_SubjectId')
     Create index ndx_prtr_SubjectId on PRTradeReport (prtr_SubjectId) WITH DROP_EXISTING
ELSE
     Create index ndx_prtr_SubjectId on PRTradeReport (prtr_SubjectId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtf_TeleformId')
     Create index ndx_prtf_TeleformId on PRTESForm (prtf_TeleformId) WITH DROP_EXISTING
ELSE
     Create index ndx_prtf_TeleformId on PRTESForm (prtf_TeleformId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_TESFormID_Company')
    CREATE NONCLUSTERED INDEX ndx_TESFormID_Company ON PRTESForm (prtf_TESFormId ASC, prtf_CompanyId ASC) INCLUDE ( [prtf_TESFormBatchId], [prtf_SerialNumber], [prtf_FormType]) WITH DROP_EXISTING
ELSE
	CREATE NONCLUSTERED INDEX ndx_TESFormID_Company ON PRTESForm (prtf_TESFormId ASC, prtf_CompanyId ASC) INCLUDE ( [prtf_TESFormBatchId], [prtf_SerialNumber], [prtf_FormType])
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtx_CompanyId')
     Create index ndx_prtx_CompanyId on PRTransaction (prtx_CompanyId) WITH DROP_EXISTING
ELSE
     Create index ndx_prtx_CompanyId on PRTransaction (prtx_CompanyId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtx_PersonId')
     Create index ndx_prtx_PersonId on PRTransaction (prtx_PersonId) WITH DROP_EXISTING
ELSE
     Create index ndx_prtx_PersonId on PRTransaction (prtx_PersonId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtx_BusinessEventId')
     Create index ndx_prtx_BusinessEventId on PRTransaction (prtx_BusinessEventId) WITH DROP_EXISTING
ELSE
     Create index ndx_prtx_BusinessEventId on PRTransaction (prtx_BusinessEventId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtx_PersonEventId')
     Create index ndx_prtx_PersonEventId on PRTransaction (prtx_PersonEventId) WITH DROP_EXISTING
ELSE
     Create index ndx_prtx_PersonEventId on PRTransaction (prtx_PersonEventId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtx_AuthorizedById')
     Create index ndx_prtx_AuthorizedById on PRTransaction (prtx_AuthorizedById) WITH DROP_EXISTING
ELSE
     Create index ndx_prtx_AuthorizedById on PRTransaction (prtx_AuthorizedById)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtx_CreditSheetId')
     Create index ndx_prtx_CreditSheetId on PRTransaction (prtx_CreditSheetId) WITH DROP_EXISTING
ELSE
     Create index ndx_prtx_CreditSheetId on PRTransaction (prtx_CreditSheetId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtx_CreatedDate')
     Create index ndx_prtx_CreatedDate on PRTransaction (prtx_CreatedDate) WITH DROP_EXISTING
ELSE
     Create index ndx_prtx_CreatedDate on PRTransaction (prtx_CreatedDate)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtx_CreatedBy')
     Create index ndx_prtx_CreatedBy on PRTransaction (prtx_CreatedBy) WITH DROP_EXISTING
ELSE
     Create index ndx_prtx_CreatedBy on PRTransaction (prtx_CreatedBy)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtd_TransactionId')
     Create index ndx_prtd_TransactionId on PRTransactionDetail (prtd_TransactionId) WITH DROP_EXISTING
ELSE
     Create index ndx_prtd_TransactionId on PRTransactionDetail (prtd_TransactionId)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prar_CustomerNumber')
     Create index ndx_prar_CustomerNumber on PRARTranslation (prar_CustomerNumber) WITH DROP_EXISTING
ELSE
     Create index ndx_prar_CustomerNumber on PRARTranslation (prar_CustomerNumber)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prcr_Type')
     Create index ndx_prcr_Type on PRCompanyRelationship (prcr_Type) WITH DROP_EXISTING
ELSE
     Create index ndx_prcr_Type on PRCompanyRelationship (prcr_Type)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prsuu_CompanyID')
     Create index ndx_prcr_Type on PRServiceUnitUsage (prsuu_CompanyID) WITH DROP_EXISTING
ELSE
     Create index ndx_prcr_Type on PRServiceUnitUsage (prsuu_CompanyID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prsuu_CompanyID')
     Create index ndx_prsuu_CompanyID on PRServiceUnitUsage (prsuu_CompanyID) WITH DROP_EXISTING
ELSE
     Create index ndx_prsuu_CompanyID on PRServiceUnitUsage (prsuu_CompanyID)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prt2_FormCompany')
	CREATE INDEX ndx_prt2_FormCompany ON PRTESDetail ([prt2_TESFormID],	[prt2_SubjectCompanyId]) WITH DROP_EXISTING
ELSE
    CREATE INDEX ndx_prt2_FormCompany ON PRTESDetail ([prt2_TESFormID],	[prt2_SubjectCompanyId])
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prt2_FormCompany')
	CREATE INDEX ndx_prt2_FormCompany ON PRTESDetail ([prt2_TESFormID],	[prt2_SubjectCompanyId]) WITH DROP_EXISTING
ELSE
    CREATE INDEX ndx_prt2_FormCompany ON PRTESDetail ([prt2_TESFormID],	[prt2_SubjectCompanyId])
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtf_CompanyForm')
	CREATE INDEX [ndx_prtf_CompanyForm] ON PRTESForm ([prtf_CompanyId], [prtf_TESFormId]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_prtf_CompanyForm] ON PRTESForm ([prtf_CompanyId], [prtf_TESFormId])
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_PRCompanyRelationshipTypeCheck')
	CREATE INDEX [ndx_PRCompanyRelationshipTypeCheck] ON [dbo].[PRCompanyRelationship] ([prcr_RightCompanyId] ASC,[prcr_LeftCompanyId] ASC,[prcr_Type] ASC,[prcr_CompanyRelationshipId] ASC) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_PRCompanyRelationshipTypeCheck] ON [dbo].[PRCompanyRelationship] ([prcr_RightCompanyId] ASC,[prcr_LeftCompanyId] ASC,[prcr_Type] ASC,[prcr_CompanyRelationshipId] ASC)
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prfs_CreatedDate')
	CREATE INDEX [ndx_prfs_CreatedDate] ON [dbo].[PRFinancial] ([prfs_CreatedDate]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_prfs_CreatedDate] ON [dbo].[PRFinancial] ([prfs_CreatedDate])
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prra_Date')
	CREATE INDEX [ndx_prra_Date] ON [dbo].[PRRating] ([prra_Date]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_prra_Date] ON [dbo].[PRRating] ([prra_Date])
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtr_IntegrityID')
	CREATE INDEX [ndx_prtr_IntegrityID] ON [dbo].[PRTradeReport] ([prtr_IntegrityID]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_prtr_IntegrityID] ON [dbo].[PRTradeReport] ([prtr_IntegrityID])
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prtr_PayRatingID')
	CREATE INDEX [ndx_prtr_PayRatingID] ON [dbo].[PRTradeReport] ([prtr_PayRatingID]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_prtr_PayRatingID] ON [dbo].[PRTradeReport] ([prtr_PayRatingID])
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comp_PRListingStatus')
	CREATE INDEX [ndx_comp_PRListingStatus] ON [dbo].[Company] ([comp_PRListingStatus]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_comp_PRListingStatus] ON [dbo].[Company] ([comp_PRListingStatus])
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prpa_CompanyName')
	CREATE INDEX [ndx_prpa_CompanyName] ON [dbo].[PRPACALicense] ([prpa_CompanyName]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_prpa_CompanyName] ON [dbo].[PRPACALicense] ([prpa_CompanyName])
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_pral_Alias')
	CREATE INDEX [ndx_pral_Alias] ON [dbo].[PRCompanyAlias] ([pral_Alias]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_pral_Alias] ON [dbo].[PRCompanyAlias] ([pral_Alias])
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_phon_AreaCodeNumber')
	CREATE INDEX [ndx_phon_AreaCodeNumber] ON [dbo].[Phone] ([phon_AreaCode], [phon_Number]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_phon_AreaCodeNumber] ON [dbo].[Phone] ([phon_AreaCode], [phon_Number])
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prdr_LicenseNumber')
	CREATE INDEX [ndx_prdr_LicenseNumber] ON [dbo].[PRDRCLicense] ([prdr_LicenseNumber]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_prdr_LicenseNumber] ON [dbo].[PRDRCLicense] ([prdr_LicenseNumber])
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_emai_EmailAddress')
	CREATE INDEX [ndx_emai_EmailAddress] ON [dbo].[Email] ([emai_EmailAddress]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_emai_EmailAddress] ON [dbo].[Email] ([emai_EmailAddress])
GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_prc3_Brand')
	CREATE INDEX [ndx_prc3_Brand] ON [dbo].[PRCompanyBrand] ([prc3_Brand]) WITH DROP_EXISTING
ELSE
    CREATE INDEX [ndx_prc3_Brand] ON [dbo].[PRCompanyBrand] ([prc3_Brand])
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comm_PRCategory')
     Create index ndx_comm_PRCategory on Communication (comm_PRCategory, comm_PRSubcategory, comm_CreatedDate) WITH DROP_EXISTING
ELSE
     Create index ndx_comm_PRCategory on Communication (comm_PRCategory, comm_PRSubcategory, comm_CreatedDate)
GO


IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'ndx_comp_PRJeopardyDate')
     Create index ndx_comp_PRJeopardyDate on Company (comp_PRJeopardyDate) WITH DROP_EXISTING
ELSE
     Create index ndx_comp_PRJeopardyDate on Company (comp_PRJeopardyDate)
GO
