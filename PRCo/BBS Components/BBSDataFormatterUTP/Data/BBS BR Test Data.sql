/*
 * Copyright (c) 2002-2006 Travant Solutions, Inc.
 * Created by Travant Excel SQL Export MACROs
 * SQL Inserts created from BBS BR Test Data.xls
 * on 9/10/2006 11:53:01 AM
 *
 */

Set NoCount On
Select getdate() as "Start Date/Time";
Begin Transaction;
Alter Table PRBusinessEvent disable trigger all
Alter Table PRCompanyAlias disable trigger all
Alter Table PRRating disable trigger all
Alter Table PRRatingNumeralAssigned disable trigger all
Alter Table PRPersonBackground disable trigger all
Alter Table PRPersonEvent disable trigger all
Alter Table PRRegion disable trigger all
Alter Table PRCompanyRegion disable trigger all
Alter Table PRCompanyClassification disable trigger all
Alter Table PRCompanyProfile disable trigger all
Alter Table PRCompanyRelationship disable trigger all
Alter Table PRStockExchange disable trigger all
Alter Table PRCompanyStockExchange disable trigger all
Alter Table PRCompanyCommodity disable trigger all
Alter Table PRCompanyCommodityAttribute disable trigger all
Alter Table Company disable trigger all
Alter Table Address disable trigger all
Alter Table Address_Link disable trigger all
DELETE FROM PRBusinessEvent WHERE prbe_CreatedBy = -100;
DELETE FROM PRCompanyAlias WHERE pral_CreatedBy = -100;
DELETE FROM PRRating WHERE prra_CreatedBy = -100;
DELETE FROM PRRatingNumeralAssigned WHERE pran_CreatedBy = -100;
DELETE FROM PRPersonBackground Where prba_CreatedBy = -100
DELETE FROM PRPersonEvent Where prpe_CreatedBy = -100
DELETE FROM PRRegion Where prd2_CreatedBy = -100
DELETE FROM PRCompanyRegion Where prcd_CreatedBy = -100
DELETE FROM PRCompanyClassification Where prc2_CreatedBy = -100
DELETE FROM PRCompanyProfile Where prcp_CreatedBy = -100
DELETE FROM PRCompanyRelationship Where prcr_CreatedBy = -100
DELETE FROM PRStockExchange Where prex_CreatedBy = -100
DELETE FROM PRCompanyStockExchange Where prc4_CreatedBy = -100
DELETE FROM PRCompanyCommodity Where prcc_CreatedBy = -100
DELETE FROM PRCompanyCommodityAttribute Where prcca_CreatedBy = -100
DELETE FROM Company Where comp_CreatedBy = -100
DELETE FROM Address Where addr_CreatedBy = -100
DELETE FROM Address_LInk Where adli_CreatedBy = -100



/*  Begin Company Inserts */

Select 'Begin Company Inserts';
Insert Into Company
(Comp_CompanyId,Comp_ChannelID,Comp_CreatedBy,Comp_CreatedDate,Comp_Deleted,Comp_EmailAddress,Comp_Employees,Comp_FaxAreaCode,Comp_FaxCountryCode,Comp_FaxNumber,Comp_IndCode,Comp_LibraryDir,Comp_MailRestriction,Comp_Name,Comp_PhoneAreaCode,Comp_PhoneCountryCode,Comp_PhoneNumber,comp_PRAccountTier,comp_PRAdministrativeUsage,comp_PRBookTradestyle,comp_PRBusinessReport,comp_PRBusinessStatus,comp_PRConfidentialFS,comp_PRConnectionListDate,comp_PRCorrTradestyle,comp_PRCreditWorthCap,comp_PRCreditWorthCapReason,comp_PRCustomerServiceUserId,comp_PRDataQualityTier,comp_PRDaysPastDue,comp_PRHQId,Comp_PrimaryAddressId,Comp_PrimaryPersonId,Comp_PrimaryUserId,comp_PRInvestigationMethodGroup,comp_PRJeopardyDate,comp_PRLegalName,comp_PRListingCityId,comp_PRListingStatus,comp_PRListingUserId,comp_PRLogo,comp_PRMarketingUserId,comp_PRMoralResponsibility,comp_PROldName1,comp_PROldName1Date,comp_PROldName2,comp_PROldName2Date,comp_PROldName3,comp_PROldName3Date,comp_PROriginalName,comp_PRPublishUnloadHours,comp_PRRatingUserId,comp_PRReceiveLRL,comp_PRReceiveTES,comp_PRRequestFinancials,comp_PRSpecialHandlingInstruction,comp_PRSpecialInstruction,comp_PRSpotlight,comp_PRSubordinationAgrDate,comp_PRSubordinationAgrProvided,comp_PRSuspendedService,comp_PRTESNonresponder,comp_PRTMFMAward,comp_PRTMFMAwardDate,comp_PRTMFMCandidate,comp_PRTMFMCandidateDate,comp_PRTMFMComments,comp_PRTradestyle1,comp_PRTradestyle2,comp_PRTradestyle3,comp_PRTradestyle4,comp_PRType,comp_PRUnattributedOwnerDesc,comp_PRUnattributedOwnerPct,comp_PRUnloadHours,Comp_Revenue,Comp_SecTerr,Comp_Sector,Comp_SegmentID,comp_SLAId,Comp_Source,Comp_Status,Comp_Territory,Comp_TimeStamp,Comp_Type,Comp_UpdatedBy,Comp_UpdatedDate,Comp_UploadDate,Comp_WorkflowId,comp_PRPrincipalsBackgroundText)
Values (500000,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Walls Company',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,29516,'L',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'X',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,GETDATE(),NULL,-100,GETDATE(),NULL,NULL,NULL);


/*  1 Company Insert Statements Created */


/*  Begin Address Inserts */

Select 'Begin Address Inserts';
Insert Into Address
(Addr_AddressId,Addr_Address1,Addr_Address2,Addr_Address3,Addr_Address4,Addr_Address5,Addr_PostCode,addr_PRCityId,addr_PRSequence,addr_PRPublish,addr_PRDescription,Addr_CreatedBy,Addr_CreatedDate,Addr_UpdatedBy,Addr_UpdatedDate)
Values (800000,'Address Line 1','Address Line 2','Address Line 3','Address Line 4','1234 North George Washington Avenue','11111-1111',25261,1,'Y','Address 1:',-100,GetDate(),-100,GetDate());

Insert Into Address
(Addr_AddressId,Addr_Address1,Addr_Address2,Addr_Address3,Addr_Address4,Addr_Address5,Addr_PostCode,addr_PRCityId,addr_PRSequence,addr_PRPublish,addr_PRDescription,Addr_CreatedBy,Addr_CreatedDate,Addr_UpdatedBy,Addr_UpdatedDate)
Values (800001,'143 Annapolis Drive',NULL,NULL,NULL,NULL,60061,29516,2,'Y','Send Stuff:',-100,GetDate(),-100,GetDate());

Insert Into Address
(Addr_AddressId,Addr_Address1,Addr_Address2,Addr_Address3,Addr_Address4,Addr_Address5,Addr_PostCode,addr_PRCityId,addr_PRSequence,addr_PRPublish,addr_PRDescription,Addr_CreatedBy,Addr_CreatedDate,Addr_UpdatedBy,Addr_UpdatedDate)
Values (800002,'100 N. Michigan Ave','Suite 200',NULL,NULL,NULL,60001,5166,3,'Y',NULL,-100,GetDate(),-100,GetDate());


/*  3 Address Insert Statements Created */


/*  Begin Address_Link Inserts */

Select 'Begin Address_Link Inserts';
Insert Into Address_Link
(AdLi_AddressLinkId,AdLi_AddressId,AdLi_CompanyID,AdLi_Type,AdLi_CreatedBy,AdLi_CreatedDate,AdLi_UpdatedBy,AdLi_UpdatedDate)
Values (800000,800000,500000,'PH',-100,GetDate(),-100,GetDate());

Insert Into Address_Link
(AdLi_AddressLinkId,AdLi_AddressId,AdLi_CompanyID,AdLi_Type,AdLi_CreatedBy,AdLi_CreatedDate,AdLi_UpdatedBy,AdLi_UpdatedDate)
Values (800001,800001,500000,'M',-100,GetDate(),-100,GetDate());

Insert Into Address_Link
(AdLi_AddressLinkId,AdLi_AddressId,AdLi_CompanyID,AdLi_Type,AdLi_CreatedBy,AdLi_CreatedDate,AdLi_UpdatedBy,AdLi_UpdatedDate)
Values (800002,800002,500000,'I',-100,GetDate(),-100,GetDate());


/*  3 Address_Link Insert Statements Created */


/*  Begin PRBusinessEvent Inserts */

Select 'Begin PRBusinessEvent Inserts';
Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,1,'1/1/2000 00:00','1/1/2000 00:00',0,NULL,NULL,'Extra published analysis.',NULL,'1/1/2008 00:00',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,105437,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,1,'1/2/2000 00:00','1/2/2000 00:00',0,NULL,NULL,'Extra published analysis.',NULL,'1/2/2008 00:00',6,'Some Other Acquisition',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,156332,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50003,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,2,'1/3/2000 00:00','1/3/2000 00:00',0,NULL,NULL,'Extra published analysis.',NULL,'1/3/2008 00:00',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,105437,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50004,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,2,'1/4/2000 00:00','1/4/2000 00:00',0,NULL,NULL,'Extra published analysis.',NULL,'1/4/2008 00:00',6,'Some Other Acquisition',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,156332,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50005,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,3,'1/5/2000 00:00','1/5/2000 00:00',0,NULL,NULL,'Extra published analysis.',NULL,'1/5/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Bugs Bunny','Toon Town','555-555-5555',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50006,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,4,'1/6/2000 00:00','1/6/2000 00:00',0,NULL,NULL,'Yo Yo Yo, here is some published analysis.',NULL,'1/6/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50007,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,5,'1/7/2000 00:00','1/7/2000 00:00',0,NULL,NULL,NULL,NULL,'1/7/2008 00:00',11,NULL,NULL,NULL,'Daffy Duck','555-111-2222',549102953,NULL,1234567.89,9876543.21,NULL,NULL,NULL,NULL,NULL,'Bugs Bunny',NULL,'555-555-5555',NULL,'Y',NULL,1,NULL,NULL,NULL,'15th curcuit court',NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50008,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,6,'1/8/2000 00:00','1/8/2000 00:00',0,NULL,NULL,NULL,NULL,'1/8/2008 00:00',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50009,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,7,'1/9/2000 00:00','1/9/2000 00:00',0,NULL,NULL,NULL,NULL,'1/9/2008 00:00',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50010,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,7,'1/10/2000 00:00','1/10/2000 00:00',0,NULL,NULL,NULL,NULL,'1/10/2008 00:00',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50011,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,7,'1/11/2000 00:00','1/11/2000 00:00',0,NULL,NULL,NULL,NULL,'1/11/2008 00:00',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50012,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,7,'1/12/2000 00:00','1/12/2000 00:00',0,NULL,NULL,NULL,NULL,'1/12/2008 00:00',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50013,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,8,'1/13/2000 00:00','1/13/2000 00:00',0,NULL,NULL,NULL,NULL,'1/13/2008 00:00',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,19,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50014,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,8,'1/14/2000 00:00','1/14/2000 00:00',0,NULL,NULL,NULL,NULL,'1/14/2008 00:00',8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50015,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,9,'1/15/2000 00:00','1/15/2000 00:00',0,NULL,NULL,NULL,NULL,'1/15/2008 00:00',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,19,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50016,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,9,'1/16/2000 00:00','1/16/2000 00:00',0,NULL,NULL,NULL,NULL,'1/16/2008 00:00',8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50017,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,10,'1/17/2000 00:00','1/17/2000 00:00',0,NULL,NULL,NULL,NULL,'1/17/2008 00:00',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50051,29129,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,75,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50018,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,11,'1/18/2000 00:00','1/18/2000 00:00',0,NULL,NULL,NULL,NULL,'1/18/2008 00:00',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,105437,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50019,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,12,'1/19/2000 00:00','1/19/2000 00:00',0,NULL,NULL,NULL,NULL,'1/19/2008 00:00',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50020,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,12,'1/20/2000 00:00','1/20/2000 00:00',0,NULL,NULL,NULL,NULL,'1/20/2008 00:00',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50021,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,12,'1/21/2000 00:00','1/21/2000 00:00',0,NULL,NULL,NULL,NULL,'1/21/2008 00:00',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50022,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,12,'1/22/2000 00:00','1/22/2000 00:00',0,NULL,NULL,NULL,NULL,'1/22/2008 00:00',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50023,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'1/23/2000 00:00','1/23/2000 00:00',0,NULL,NULL,NULL,NULL,'1/23/2008 00:00',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50024,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'1/24/2000 00:00','1/24/2000 00:00',0,NULL,NULL,NULL,NULL,'1/24/2008 00:00',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50025,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'1/25/2000 00:00','1/25/2000 00:00',0,NULL,NULL,NULL,NULL,'1/25/2008 00:00',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50026,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'1/26/2000 00:00','1/26/2000 00:00',0,NULL,NULL,NULL,NULL,'1/26/2008 00:00',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50027,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'1/27/2000 00:00','1/27/2000 00:00',0,NULL,NULL,NULL,NULL,'1/27/2008 00:00',5,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50028,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'1/28/2000 00:00','1/28/2000 00:00',0,NULL,NULL,NULL,NULL,'1/28/2008 00:00',7,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50029,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,14,'1/29/2000 00:00','1/29/2000 00:00',0,NULL,NULL,'This is a financial event.',NULL,'1/29/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50030,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,15,'1/30/2000 00:00','1/30/2000 00:00',0,NULL,NULL,NULL,NULL,'1/30/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50031,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,16,'1/31/2000 00:00','1/31/2000 00:00',0,NULL,NULL,NULL,NULL,'1/31/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50032,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,17,'2/1/2000 00:00','2/1/2000 00:00',0,NULL,NULL,NULL,NULL,'2/1/2008 00:00',NULL,NULL,NULL,NULL,'Daffy Duck','555-111-2222',549102953,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'15th curcuit court',NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50033,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,18,'2/2/2000 00:00','2/2/2000 00:00',0,NULL,NULL,NULL,NULL,'2/2/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,27500,NULL,NULL,NULL,NULL,105437,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50034,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,19,'2/3/2000 00:00','2/3/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,105437,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50035,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,19,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',6,'Some other text',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,105437,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50036,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,20,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,58392.31,NULL,NULL,NULL,NULL,105437,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50037,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,21,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,'The location changed.  To where we don''t know, but we''re are looking!',NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50038,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,22,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,'A merger happened.  Strube has aquired Canada.  Yes, the entire country of Canada has merged with Strube.',NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50039,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,23,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',1,NULL,NULL,2,NULL,NULL,NULL,487219,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50040,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,23,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',7,'Ran out of pop-tarts',NULL,3,NULL,NULL,NULL,3938,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50041,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,24,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50042,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,25,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,'In other legal action, Frank fell and skinned his knee.  Now he''s suing.',NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50043,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,26,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,'Other?!?  What other?!?',NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50044,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,27,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,'Some other not-so-way-cool PACA event.',NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50045,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',1,NULL,NULL,NULL,NULL,NULL,NULL,57.12,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,10,'Scott Sax, Richard Otruba',NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50046,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',2,NULL,NULL,NULL,NULL,NULL,NULL,257.12,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Scott Sax, Richard Otruba',NULL,NULL,3,'5/1/2004','10/31/2004','9/15/2004 00:00','11/15/2004 00:00');

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50047,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,29,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50048,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,30,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,87564.1,NULL,NULL,NULL,NULL,105437,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50049,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,31,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,'The partnership desolved is like sugar in water.',NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50050,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,32,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,105437,102030,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50051,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,33,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,102030,105437,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50052,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,34,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,'SEC is investigating!!!!  Quick, fire up the shredders…',NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50053,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,35,'2/4/2000 00:00','2/4/2000 00:00',0,NULL,NULL,'Some public stock event.  Hopefully a split and not a reverse split.',NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50054,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,36,'2/4/2006 00:00','2/4/2006 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50055,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,36,'2/4/2006 00:00','2/4/2006 00:00',0,NULL,NULL,NULL,NULL,'2/3/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,47219,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (50056,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,37,'2/4/2006 00:00','2/4/2006 00:00',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'AB303',582048,NULL,NULL,NULL,NULL,105437,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'12th District',NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,1,'11/1/2003 00:00','11/1/2003 00:00',0,NULL,NULL,NULL,NULL,'2/17/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,1,'10/1/2000 00:00','10/1/2000 00:00',0,NULL,NULL,NULL,NULL,'3/5/2006 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60003,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,2,'9/5/2002 00:00','9/5/2002 00:00',0,NULL,NULL,NULL,NULL,'4/4/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60004,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,2,'3/1/2006 00:00','3/1/2006 00:00',0,NULL,NULL,NULL,NULL,'3/5/2006 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60005,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,3,'10/29/2004 00:00','10/9/2004 00:00',0,NULL,NULL,NULL,NULL,'4/4/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60006,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,4,'4/4/2004 00:00','4/4/2004 00:00',0,NULL,NULL,NULL,NULL,'2/10/2009 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60007,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,5,'6/1/1999 00:00','6/1/1999 00:00',0,NULL,NULL,NULL,NULL,'2/15/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60008,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,6,'7/2/2000 00:00','7/2/2000 00:00',0,NULL,NULL,NULL,NULL,'2/16/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60009,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,7,'7/2/2000 00:00','7/2/2000 00:00',0,NULL,NULL,NULL,NULL,'2/17/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60010,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,7,'7/2/2000 00:00','7/2/2000 00:00',0,NULL,NULL,NULL,NULL,'3/5/2006 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60011,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,7,'7/2/2000 00:00','7/2/2000 00:00',0,NULL,NULL,NULL,NULL,'4/4/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60012,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,7,'7/2/2000 00:00','7/2/2000 00:00',0,NULL,NULL,NULL,NULL,'2/15/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60013,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,8,'8/5/1997 00:00','8/5/1997 00:00',0,NULL,NULL,NULL,NULL,'2/16/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60014,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,8,'8/5/1997 00:00','8/5/1997 00:00',0,NULL,NULL,NULL,NULL,'2/17/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60015,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,9,'8/12/1997 00:00','8/12/1997 00:00',0,NULL,NULL,NULL,NULL,'3/5/2006 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60016,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,9,'8/12/1997 00:00','8/12/1997 00:00',0,NULL,NULL,NULL,NULL,'4/4/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60017,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,10,'3/4/1970 00:00','3/4/1970 00:00',0,NULL,NULL,NULL,NULL,'2/15/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60018,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,11,'2/29/2000 00:00','2/29/2000 00:00',0,NULL,NULL,NULL,NULL,'2/16/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60019,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,12,'3/1/2000 00:00','3/1/2000 00:00',0,NULL,NULL,NULL,NULL,'2/17/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60020,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,12,'3/2/2000 00:00','3/2/2000 00:00',0,NULL,NULL,NULL,NULL,'3/5/2006 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60021,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,12,'3/3/2000 00:00','3/3/2000 00:00',0,NULL,NULL,NULL,NULL,'4/4/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60022,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,12,'3/4/2000 00:00','3/4/2000 00:00',0,NULL,NULL,NULL,NULL,'3/5/2006 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60023,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'7/2/2000 00:00','7/2/2000 00:00',0,NULL,NULL,NULL,NULL,'4/4/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60024,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'7/2/2000 00:00','7/2/2000 00:00',0,NULL,NULL,NULL,NULL,'2/10/2009 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60025,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'8/5/1997 00:00','8/5/1997 00:00',0,NULL,NULL,NULL,NULL,'2/15/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60026,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'8/5/1997 00:00','8/5/1997 00:00',0,NULL,NULL,NULL,NULL,'2/16/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60027,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'8/12/1997 00:00','8/12/1997 00:00',0,NULL,NULL,NULL,NULL,'2/17/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60028,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,13,'8/12/1997 00:00','8/12/1997 00:00',0,NULL,NULL,NULL,NULL,'3/5/2006 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60029,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,14,'3/3/2000 00:00','3/3/2000 00:00',0,NULL,NULL,NULL,NULL,'4/4/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60030,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,15,'3/4/2000 00:00','3/4/2000 00:00',0,NULL,NULL,NULL,NULL,'2/15/2007 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRBusinessEvent
(prbe_BusinessEventId,prbe_Deleted,prbe_WorkflowId,prbe_Secterr,prbe_CreatedBy,prbe_CreatedDate,prbe_UpdatedBy,prbe_UpdatedDate,prbe_TimeStamp,prbe_CompanyId,prbe_BusinessEventTypeId,prbe_EffectiveDate,prbe_DisplayedEffectiveDate,prbe_DisplayedEffectiveDateStyle,prbe_CreditSheetPublish,prbe_CreditSheetNote,prbe_PublishedAnalysis,prbe_InternalAnalysis,prbe_PublishUntilDate,prbe_DetailedType,prbe_OtherDescription,prbe_AnticipatedCompletionDate,prbe_DisasterImpact,prbe_AttorneyName,prbe_AttorneyPhone,prbe_CaseNumber,prbe_Amount,prbe_AssetAmount,prbe_LiabilityAmount,prbe_IndividualBuyerId,prbe_IndividualSellerId,prbe_RelatedCompany1Id,prbe_RelatedCompany2Id,prbe_AgreementCategory,prbe_AssigneeTrusteeName,prbe_AssigneeTrusteeAddress,prbe_AssigneeTrusteePhone,prbe_SpecifiedCSNumeral,prbe_USBankruptcyVoluntary,prbe_USBankruptcyEntity,prbe_USBankruptcyCourt,prbe_StateId,prbe_Names,prbe_PercentSold,prbe_CourtDistrict,prbe_NumberSellers,prbe_NonPromptStart,prbe_NonPromptEnd,prbe_BusinessOperateUntil,prbe_IndividualOperateUntil)
Values (60031,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,16,'7/2/2000 00:00','7/2/2000 00:00',0,NULL,NULL,NULL,NULL,'2/16/2008 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


/*  87 PRBusinessEvent Insert Statements Created */


/*  Begin PRCompanyAlias Inserts */

Select 'Begin PRCompanyAlias Inserts';
Insert Into PRCompanyAlias
(pral_CompanyAliasId,pral_Deleted,pral_WorkflowId,pral_Secterr,pral_CreatedBy,pral_CreatedDate,pral_UpdatedBy,pral_UpdatedDate,pral_TimeStamp,pral_CompanyId,pral_Alias)
Values (1,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'Our way cool alias');

Insert Into PRCompanyAlias
(pral_CompanyAliasId,pral_Deleted,pral_WorkflowId,pral_Secterr,pral_CreatedBy,pral_CreatedDate,pral_UpdatedBy,pral_UpdatedDate,pral_TimeStamp,pral_CompanyId,pral_Alias)
Values (2,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'Super Secret Alias');


/*  2 PRCompanyAlias Insert Statements Created */


/*  Begin PRRating Inserts */

Select 'Begin PRRating Inserts';
Insert Into PRRating
(prra_RatingId,prra_Deleted,prra_WorkflowId,prra_Secterr,prra_CreatedBy,prra_CreatedDate,prra_UpdatedBy,prra_UpdatedDate,prra_TimeStamp,prra_CompanyId,prra_Date,prra_Current,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId,prra_InternalAnalysis,prra_PublishedAnalysis)
Values (500000,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'3/4/2006 00:00',NULL,NULL,NULL,NULL,NULL,'Rating stuff 50000.');

Insert Into PRRating
(prra_RatingId,prra_Deleted,prra_WorkflowId,prra_Secterr,prra_CreatedBy,prra_CreatedDate,prra_UpdatedBy,prra_UpdatedDate,prra_TimeStamp,prra_CompanyId,prra_Date,prra_Current,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId,prra_InternalAnalysis,prra_PublishedAnalysis)
Values (500001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'3/4/2006 00:00',NULL,NULL,NULL,NULL,NULL,'Rating stuff 50001.');

Insert Into PRRating
(prra_RatingId,prra_Deleted,prra_WorkflowId,prra_Secterr,prra_CreatedBy,prra_CreatedDate,prra_UpdatedBy,prra_UpdatedDate,prra_TimeStamp,prra_CompanyId,prra_Date,prra_Current,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId,prra_InternalAnalysis,prra_PublishedAnalysis)
Values (500002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'3/4/2006 00:00',NULL,NULL,NULL,NULL,NULL,'Rating stuff 50002.');

Insert Into PRRating
(prra_RatingId,prra_Deleted,prra_WorkflowId,prra_Secterr,prra_CreatedBy,prra_CreatedDate,prra_UpdatedBy,prra_UpdatedDate,prra_TimeStamp,prra_CompanyId,prra_Date,prra_Current,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId,prra_InternalAnalysis,prra_PublishedAnalysis)
Values (500003,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'3/4/2006 00:00',NULL,NULL,NULL,NULL,NULL,'Rating stuff 50003.');

Insert Into PRRating
(prra_RatingId,prra_Deleted,prra_WorkflowId,prra_Secterr,prra_CreatedBy,prra_CreatedDate,prra_UpdatedBy,prra_UpdatedDate,prra_TimeStamp,prra_CompanyId,prra_Date,prra_Current,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId,prra_InternalAnalysis,prra_PublishedAnalysis)
Values (500004,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'3/4/2006 00:00',NULL,NULL,NULL,NULL,NULL,'Rating stuff 50004.');

Insert Into PRRating
(prra_RatingId,prra_Deleted,prra_WorkflowId,prra_Secterr,prra_CreatedBy,prra_CreatedDate,prra_UpdatedBy,prra_UpdatedDate,prra_TimeStamp,prra_CompanyId,prra_Date,prra_Current,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId,prra_InternalAnalysis,prra_PublishedAnalysis)
Values (500005,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'3/4/2006 00:00',NULL,NULL,NULL,NULL,NULL,'Rating stuff 50005.');

Insert Into PRRating
(prra_RatingId,prra_Deleted,prra_WorkflowId,prra_Secterr,prra_CreatedBy,prra_CreatedDate,prra_UpdatedBy,prra_UpdatedDate,prra_TimeStamp,prra_CompanyId,prra_Date,prra_Current,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId,prra_InternalAnalysis,prra_PublishedAnalysis)
Values (500006,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'3/4/2006 00:00',NULL,NULL,NULL,NULL,NULL,'Rating stuff 50006.');

Insert Into PRRating
(prra_RatingId,prra_Deleted,prra_WorkflowId,prra_Secterr,prra_CreatedBy,prra_CreatedDate,prra_UpdatedBy,prra_UpdatedDate,prra_TimeStamp,prra_CompanyId,prra_Date,prra_Current,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId,prra_InternalAnalysis,prra_PublishedAnalysis)
Values (500007,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'3/4/2006 00:00',NULL,NULL,NULL,NULL,NULL,'Rating stuff 50007.');

Insert Into PRRating
(prra_RatingId,prra_Deleted,prra_WorkflowId,prra_Secterr,prra_CreatedBy,prra_CreatedDate,prra_UpdatedBy,prra_UpdatedDate,prra_TimeStamp,prra_CompanyId,prra_Date,prra_Current,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId,prra_InternalAnalysis,prra_PublishedAnalysis)
Values (500008,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'3/4/2006 00:00',NULL,NULL,NULL,NULL,NULL,'Rating stuff 50008.');

Insert Into PRRating
(prra_RatingId,prra_Deleted,prra_WorkflowId,prra_Secterr,prra_CreatedBy,prra_CreatedDate,prra_UpdatedBy,prra_UpdatedDate,prra_TimeStamp,prra_CompanyId,prra_Date,prra_Current,prra_CreditWorthId,prra_IntegrityId,prra_PayRatingId,prra_InternalAnalysis,prra_PublishedAnalysis)
Values (500009,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,'3/4/2006 00:00',NULL,NULL,NULL,NULL,NULL,'Rating stuff 50009.');


/*  10 PRRating Insert Statements Created */


/*  Begin PRRatingNumeralAssigned Inserts */

Select 'Begin PRRatingNumeralAssigned Inserts';
Insert Into PRRatingNumeralAssigned
(pran_RatingNumeralAssignedId,pran_Deleted,pran_WorkflowId,pran_Secterr,pran_CreatedBy,pran_CreatedDate,pran_UpdatedBy,pran_UpdatedDate,pran_TimeStamp,pran_RatingId,pran_RatingNumeralId)
Values (500000,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500000,23);

Insert Into PRRatingNumeralAssigned
(pran_RatingNumeralAssignedId,pran_Deleted,pran_WorkflowId,pran_Secterr,pran_CreatedBy,pran_CreatedDate,pran_UpdatedBy,pran_UpdatedDate,pran_TimeStamp,pran_RatingId,pran_RatingNumeralId)
Values (500001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500001,31);

Insert Into PRRatingNumeralAssigned
(pran_RatingNumeralAssignedId,pran_Deleted,pran_WorkflowId,pran_Secterr,pran_CreatedBy,pran_CreatedDate,pran_UpdatedBy,pran_UpdatedDate,pran_TimeStamp,pran_RatingId,pran_RatingNumeralId)
Values (500002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500002,40);

Insert Into PRRatingNumeralAssigned
(pran_RatingNumeralAssignedId,pran_Deleted,pran_WorkflowId,pran_Secterr,pran_CreatedBy,pran_CreatedDate,pran_UpdatedBy,pran_UpdatedDate,pran_TimeStamp,pran_RatingId,pran_RatingNumeralId)
Values (500003,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500003,41);

Insert Into PRRatingNumeralAssigned
(pran_RatingNumeralAssignedId,pran_Deleted,pran_WorkflowId,pran_Secterr,pran_CreatedBy,pran_CreatedDate,pran_UpdatedBy,pran_UpdatedDate,pran_TimeStamp,pran_RatingId,pran_RatingNumeralId)
Values (500004,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500004,46);

Insert Into PRRatingNumeralAssigned
(pran_RatingNumeralAssignedId,pran_Deleted,pran_WorkflowId,pran_Secterr,pran_CreatedBy,pran_CreatedDate,pran_UpdatedBy,pran_UpdatedDate,pran_TimeStamp,pran_RatingId,pran_RatingNumeralId)
Values (500005,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500005,57);

Insert Into PRRatingNumeralAssigned
(pran_RatingNumeralAssignedId,pran_Deleted,pran_WorkflowId,pran_Secterr,pran_CreatedBy,pran_CreatedDate,pran_UpdatedBy,pran_UpdatedDate,pran_TimeStamp,pran_RatingId,pran_RatingNumeralId)
Values (500006,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500006,59);

Insert Into PRRatingNumeralAssigned
(pran_RatingNumeralAssignedId,pran_Deleted,pran_WorkflowId,pran_Secterr,pran_CreatedBy,pran_CreatedDate,pran_UpdatedBy,pran_UpdatedDate,pran_TimeStamp,pran_RatingId,pran_RatingNumeralId)
Values (500007,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500007,60);

Insert Into PRRatingNumeralAssigned
(pran_RatingNumeralAssignedId,pran_Deleted,pran_WorkflowId,pran_Secterr,pran_CreatedBy,pran_CreatedDate,pran_UpdatedBy,pran_UpdatedDate,pran_TimeStamp,pran_RatingId,pran_RatingNumeralId)
Values (500008,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500008,61);

Insert Into PRRatingNumeralAssigned
(pran_RatingNumeralAssignedId,pran_Deleted,pran_WorkflowId,pran_Secterr,pran_CreatedBy,pran_CreatedDate,pran_UpdatedBy,pran_UpdatedDate,pran_TimeStamp,pran_RatingId,pran_RatingNumeralId)
Values (500009,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500009,1);


/*  10 PRRatingNumeralAssigned Insert Statements Created */


/*  Begin PRPersonBackground Inserts */

Select 'Begin PRPersonBackground Inserts';
Insert Into PRPersonBackground
(prba_PersonBackgroundId,prba_Deleted,prba_WorkflowId,prba_Secterr,prba_CreatedBy,prba_CreatedDate,prba_UpdatedBy,prba_UpdatedDate,prba_TimeStamp,prba_PersonId,prba_StartDate,prba_EndDate,prba_Company,prba_Title)
Values (50000,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7752,NULL,NULL,'Travant Solutions','Coder Extraordinaire');


/*  1 PRPersonBackground Insert Statements Created */


/*  Begin PRPersonEvent Inserts */

Select 'Begin PRPersonEvent Inserts';
Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50000,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7752,1,'3/1/2004 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Some not-so-good DRC violation.',NULL,'5/5/2007 00:00',NULL);

Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7752,2,'3/2/2004 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'What, another PACA violation?!?!?',NULL,'5/5/2007 00:00',NULL);

Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7752,3,'2/2/2004 00:00',NULL,'Northern Illinois University','Bachelor of Science',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'5/5/2007 00:00',NULL);

Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50003,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7752,4,'3/1/2004 00:00',NULL,NULL,NULL,2,'Y','14th Circuit','DA03D39',NULL,NULL,NULL,'5/5/2007 00:00',NULL);

Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50004,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7752,5,'3/2/2004 00:00',NULL,NULL,NULL,3,NULL,NULL,NULL,2,NULL,NULL,'5/5/2007 00:00',NULL);

Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50005,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7752,6,'2/2/2004 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Some other, unknown, legal thingy happened to this here person.',NULL,'5/5/2007 00:00',NULL);

Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50006,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7752,7,'5/3/2004 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Some other event, though not legal, not necessarily known.',NULL,'5/5/2007 00:00',NULL);

Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50007,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,37353,2,'3/2/2004 00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'What, another PACA violation?!?!?',NULL,'5/5/2007 00:00',NULL);

Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50008,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,37353,3,'2/2/2004 00:00',NULL,'Southern Illinois University','Bachelor of Science',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'5/5/2007 00:00',NULL);

Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50009,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,37353,4,'3/1/2004 00:00',NULL,NULL,NULL,4,'N','9th Circuit','SIERHA',NULL,NULL,NULL,'5/5/2007 00:00',NULL);

Insert Into PRPersonEvent
(prpe_PersonEventId,prpe_Deleted,prpe_WorkflowId,prpe_Secterr,prpe_CreatedBy,prpe_CreatedDate,prpe_UpdatedBy,prpe_UpdatedDate,prpe_TimeStamp,prpe_PersonId,prpe_PersonEventTypeId,prpe_Date,prpe_Description,prpe_EducationalInstitution,prpe_EducationalDegree,prpe_BankruptcyType,prpe_USBankruptcyVoluntary,prpe_USBankruptcyCourt,prpe_CaseNumber,prpe_DischargeType,prpe_PublishedAnalysis,prpe_InternalAnalysis,prpe_PublishUntilDate,prpe_PublishCreditSheet)
Values (50010,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,37353,5,'3/2/2004 00:00',NULL,NULL,NULL,1,NULL,NULL,NULL,1,NULL,NULL,'5/5/2007 00:00',NULL);


/*  11 PRPersonEvent Insert Statements Created */


/*  Begin PRCompanyRegion Inserts */

Select 'Begin PRCompanyRegion Inserts';
Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (1,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,8,2);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (2,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,21,2);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (3,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,15,2);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (4,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,2,2);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (5,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,23,2);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (6,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,33,3);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (7,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,19,3);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (8,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,4,3);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (9,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,45,3);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (10,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,39,3);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (11,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,1);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (12,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,41,1);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (13,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,32,1);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (14,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,10,1);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (15,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,71,4);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (16,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,72,4);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (17,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,73,4);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (18,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,74,5);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (19,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,75,5);

Insert Into PRCompanyRegion
(prcd_CompanyRegionId,prcd_Deleted,prcd_WorkflowId,prcd_Secterr,prcd_CreatedBy,prcd_CreatedDate,prcd_UpdatedBy,prcd_UpdatedDate,prcd_TimeStamp,prcd_CompanyId,prcd_RegionId,prcd_Type)
Values (20,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,76,5);


/*  20 PRCompanyRegion Insert Statements Created */


/*  Begin PRRegion Inserts */

Select 'Begin PRRegion Inserts';
Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (1,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'All','Throughout the United States and Canada','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (2,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,1,2,'NWUS','Northwestern United States','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (3,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,1,2,'WSWUS','Western/Southwestern United States','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (4,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,1,2,'MWUS','Midwestern United States','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (5,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,1,2,'SUS','Southern United States','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (6,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,1,2,'SEUS','Southeastern United States','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (7,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,1,2,'NEUS','Northeastern United States','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (8,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,1,2,'Canada','Canada','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (9,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,2,3,'WA','WA','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (10,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,2,3,'OR','OR','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (11,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,2,3,'ID','ID','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (12,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,2,3,'MT','MT','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (13,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,2,3,'WY','WY','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (14,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,2,3,'AK','AK','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (15,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,3,3,'CA','CA','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (16,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,3,3,'NV','NV','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (17,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,3,3,'UT','UT','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (18,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,3,3,'CO','CO','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (19,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,3,3,'AZ','AZ','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (20,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,3,3,'NM','NM','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (21,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,3,3,'HI','HI','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (22,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'ND','ND','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (23,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'SD','SD','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (24,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'NE','NE','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (25,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'KS','KS','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (26,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'MN','MN','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (27,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'IA','IA','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (28,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'MO','MO','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (29,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'WI','WI','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (30,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'IL','IL','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (31,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'MI','MI','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (32,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'IN','IN','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (33,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'KY','KY','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (34,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,4,3,'OH','OH','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (35,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,5,3,'OK','OK','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (36,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,5,3,'TX','TX','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (37,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,5,3,'AR','AR','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (38,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,5,3,'LA','LA','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (39,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,5,3,'MS','MS','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (40,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,6,3,'TN','TN','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (41,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,6,3,'NC','NC','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (42,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,6,3,'SC','SC','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (43,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,6,3,'AL','AL','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (44,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,6,3,'GA','GA','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (45,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,6,3,'FL','FL','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (46,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'ME','ME','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (47,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'VT','VT','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (48,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'NH','NH','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (49,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'NY','NY','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (50,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'MA','MA','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (51,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'CT','CT','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (52,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'PA','PA','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (53,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'WV','WV','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (54,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'VA','VA','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (55,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'MD','MD','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (56,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'NJ','NJ','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (57,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'DE','DE','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (58,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'DC','DC','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (59,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,7,3,'RI','RI','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (60,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'AB','AB','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (61,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'BC','BC','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (62,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'MB','MB','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (63,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'NB','NB','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (64,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'NF','NF','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (65,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'NS','NS','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (66,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'NT','NT','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (67,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'ON','ON','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (68,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'PE','PE','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (69,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'QC','QC','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (70,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,8,3,'SK','SK','D');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (71,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'MEX','Mexico','I');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (72,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'CA','Central America','I');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (73,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'SA','South America','I');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (74,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'EU','Europe','I');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (75,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'ASIA','Asia','I');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (76,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'ME','Middle East','I');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (77,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'AFR','Africa','I');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (78,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'AUSNZ','Australia / New Zealand','I');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (79,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'PR','Pacific Rim','I');

Insert Into PRRegion
(prd2_RegionId,prd2_Deleted,prd2_WorkflowId,prd2_Secterr,prd2_CreatedBy,prd2_CreatedDate,prd2_UpdatedBy,prd2_UpdatedDate,prd2_TimeStamp,prd2_ParentId,prd2_Level,prd2_Name,prd2_Description,prd2_Type)
Values (80,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,NULL,1,'CARIB','Caribbean','I');


/*  80 PRRegion Insert Statements Created */


/*  Begin PRCompanyClassification Inserts */

Select 'Begin PRCompanyClassification Inserts';
Insert Into PRCompanyClassification
(prc2_CompanyClassificationId,prc2_Deleted,prc2_WorkflowId,prc2_Secterr,prc2_CreatedBy,prc2_CreatedDate,prc2_UpdatedBy,prc2_UpdatedDate,prc2_TimeStamp,prc2_CompanyId,prc2_ClassificationId,prc2_Percentage,prc2_PercentageSource,prc2_NumberOfStores,prc2_ComboStores,prc2_NumberOfComboStores,prc2_ConvenienceStores,prc2_NumberOfConvenienceStores,prc2_GourmetStores,prc2_NumberOfGourmetStores,prc2_HealthFoodStores,prc2_NumberOfHealthFoodStores,prc2_ProduceOnlyStores,prc2_NumberOfProduceOnlyStores,prc2_SupermarketStores,prc2_NumberOfSupermarketStores,prc2_SuperStores,prc2_NumberOfSuperStores,prc2_WarehouseStores,prc2_NumberOfWarehouseStores,prc2_AirFreight,prc2_OceanFreight,prc2_GroundFreight,prc2_RailFreight)
Values (150000,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,33,NULL,NULL,1,'Y',6,'Y',3,'Y',2,'Y',9,'Y',10,'Y',2,'Y',1,'Y',4,'Y','Y','Y','Y');

Insert Into PRCompanyClassification
(prc2_CompanyClassificationId,prc2_Deleted,prc2_WorkflowId,prc2_Secterr,prc2_CreatedBy,prc2_CreatedDate,prc2_UpdatedBy,prc2_UpdatedDate,prc2_TimeStamp,prc2_CompanyId,prc2_ClassificationId,prc2_Percentage,prc2_PercentageSource,prc2_NumberOfStores,prc2_ComboStores,prc2_NumberOfComboStores,prc2_ConvenienceStores,prc2_NumberOfConvenienceStores,prc2_GourmetStores,prc2_NumberOfGourmetStores,prc2_HealthFoodStores,prc2_NumberOfHealthFoodStores,prc2_ProduceOnlyStores,prc2_NumberOfProduceOnlyStores,prc2_SupermarketStores,prc2_NumberOfSupermarketStores,prc2_SuperStores,prc2_NumberOfSuperStores,prc2_WarehouseStores,prc2_NumberOfWarehouseStores,prc2_AirFreight,prc2_OceanFreight,prc2_GroundFreight,prc2_RailFreight)
Values (150001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500000,33,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

Insert Into PRCompanyClassification
(prc2_CompanyClassificationId,prc2_Deleted,prc2_WorkflowId,prc2_Secterr,prc2_CreatedBy,prc2_CreatedDate,prc2_UpdatedBy,prc2_UpdatedDate,prc2_TimeStamp,prc2_CompanyId,prc2_ClassificationId,prc2_Percentage,prc2_PercentageSource,prc2_NumberOfStores,prc2_ComboStores,prc2_NumberOfComboStores,prc2_ConvenienceStores,prc2_NumberOfConvenienceStores,prc2_GourmetStores,prc2_NumberOfGourmetStores,prc2_HealthFoodStores,prc2_NumberOfHealthFoodStores,prc2_ProduceOnlyStores,prc2_NumberOfProduceOnlyStores,prc2_SupermarketStores,prc2_NumberOfSupermarketStores,prc2_SuperStores,prc2_NumberOfSuperStores,prc2_WarehouseStores,prc2_NumberOfWarehouseStores,prc2_AirFreight,prc2_OceanFreight,prc2_GroundFreight,prc2_RailFreight)
Values (150002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,500000,32,NULL,NULL,2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


/*  3 PRCompanyClassification Insert Statements Created */



/*  Begin PRCompanyRelationship Inserts */

Select 'Begin PRCompanyRelationship Inserts';
Insert Into PRCompanyRelationship
(prcr_CompanyRelationshipId,prcr_Deleted,prcr_WorkflowId,prcr_Secterr,prcr_CreatedBy,prcr_CreatedDate,prcr_UpdatedBy,prcr_UpdatedDate,prcr_TimeStamp,prcr_LeftCompanyId,prcr_RightCompanyId,prcr_Type,prcr_Source,prcr_EnteredDate,prcr_LastReportedDate,prcr_TimesReported,prcr_TransactionVolume,prcr_TransactionFrequency,prcr_OwnershipPct,prcr_Active)
Values (510000,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,105437,102030,30,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Y');

Insert Into PRCompanyRelationship
(prcr_CompanyRelationshipId,prcr_Deleted,prcr_WorkflowId,prcr_Secterr,prcr_CreatedBy,prcr_CreatedDate,prcr_UpdatedBy,prcr_UpdatedDate,prcr_TimeStamp,prcr_LeftCompanyId,prcr_RightCompanyId,prcr_Type,prcr_Source,prcr_EnteredDate,prcr_LastReportedDate,prcr_TimesReported,prcr_TransactionVolume,prcr_TransactionFrequency,prcr_OwnershipPct,prcr_Active)
Values (510001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,156332,102030,30,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Y');

Insert Into PRCompanyRelationship
(prcr_CompanyRelationshipId,prcr_Deleted,prcr_WorkflowId,prcr_Secterr,prcr_CreatedBy,prcr_CreatedDate,prcr_UpdatedBy,prcr_UpdatedDate,prcr_TimeStamp,prcr_LeftCompanyId,prcr_RightCompanyId,prcr_Type,prcr_Source,prcr_EnteredDate,prcr_LastReportedDate,prcr_TimesReported,prcr_TransactionVolume,prcr_TransactionFrequency,prcr_OwnershipPct,prcr_Active)
Values (510002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,150616,30,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Y');

Insert Into PRCompanyRelationship
(prcr_CompanyRelationshipId,prcr_Deleted,prcr_WorkflowId,prcr_Secterr,prcr_CreatedBy,prcr_CreatedDate,prcr_UpdatedBy,prcr_UpdatedDate,prcr_TimeStamp,prcr_LeftCompanyId,prcr_RightCompanyId,prcr_Type,prcr_Source,prcr_EnteredDate,prcr_LastReportedDate,prcr_TimesReported,prcr_TransactionVolume,prcr_TransactionFrequency,prcr_OwnershipPct,prcr_Active)
Values (510003,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,160134,30,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Y');


/*  4 PRCompanyRelationship Insert Statements Created */


/*  Begin PRStockExchange Inserts */

Select 'Begin PRStockExchange Inserts';
Insert Into PRStockExchange
(prex_StockExchangeId,prex_Deleted,prex_WorkflowId,prex_Secterr,prex_CreatedBy,prex_CreatedDate,prex_UpdatedBy,prex_UpdatedDate,prex_TimeStamp,prex_Name,prex_Publish,prex_Order)
Values (100000,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,'NYSE','Y',4);

Insert Into PRStockExchange
(prex_StockExchangeId,prex_Deleted,prex_WorkflowId,prex_Secterr,prex_CreatedBy,prex_CreatedDate,prex_UpdatedBy,prex_UpdatedDate,prex_TimeStamp,prex_Name,prex_Publish,prex_Order)
Values (100001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,'NASDAQ','Y',1);

Insert Into PRStockExchange
(prex_StockExchangeId,prex_Deleted,prex_WorkflowId,prex_Secterr,prex_CreatedBy,prex_CreatedDate,prex_UpdatedBy,prex_UpdatedDate,prex_TimeStamp,prex_Name,prex_Publish,prex_Order)
Values (100002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,'TSE','Y',2);

Insert Into PRStockExchange
(prex_StockExchangeId,prex_Deleted,prex_WorkflowId,prex_Secterr,prex_CreatedBy,prex_CreatedDate,prex_UpdatedBy,prex_UpdatedDate,prex_TimeStamp,prex_Name,prex_Publish,prex_Order)
Values (100003,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,'CBOT','Y',3);


/*  4 PRStockExchange Insert Statements Created */


/*  Begin PRCompanyStockExchange Inserts */

Select 'Begin PRCompanyStockExchange Inserts';
Insert Into PRCompanyStockExchange
(prc4_CompanyStockExchangeId,prc4_Deleted,prc4_WorkflowId,prc4_Secterr,prc4_CreatedBy,prc4_CreatedDate,prc4_UpdatedBy,prc4_UpdatedDate,prc4_TimeStamp,prc4_CompanyId,prc4_StockExchangeId,prc4_Symbol1,prc4_Symbol2,prc4_Symbol3)
Values (100000,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,100000,1,'AAA','AAA2','AAA3');

Insert Into PRCompanyStockExchange
(prc4_CompanyStockExchangeId,prc4_Deleted,prc4_WorkflowId,prc4_Secterr,prc4_CreatedBy,prc4_CreatedDate,prc4_UpdatedBy,prc4_UpdatedDate,prc4_TimeStamp,prc4_CompanyId,prc4_StockExchangeId,prc4_Symbol1,prc4_Symbol2,prc4_Symbol3)
Values (100001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,100001,2,'YoYoYo','Yo','YoYo');

Insert Into PRCompanyStockExchange
(prc4_CompanyStockExchangeId,prc4_Deleted,prc4_WorkflowId,prc4_Secterr,prc4_CreatedBy,prc4_CreatedDate,prc4_UpdatedBy,prc4_UpdatedDate,prc4_TimeStamp,prc4_CompanyId,prc4_StockExchangeId,prc4_Symbol1,prc4_Symbol2,prc4_Symbol3)
Values (100002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,100002,3,'Homer','Likes','Donuts');

Insert Into PRCompanyStockExchange
(prc4_CompanyStockExchangeId,prc4_Deleted,prc4_WorkflowId,prc4_Secterr,prc4_CreatedBy,prc4_CreatedDate,prc4_UpdatedBy,prc4_UpdatedDate,prc4_TimeStamp,prc4_CompanyId,prc4_StockExchangeId,prc4_Symbol1,prc4_Symbol2,prc4_Symbol3)
Values (100003,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,100003,4,'2B','OR','!2B');


/*  4 PRCompanyStockExchange Insert Statements Created */


/*  Begin PRCompanyCommodity Inserts */

Select 'Begin PRCompanyCommodity Inserts';
Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500000,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,29,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,30,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500003,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,31,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500004,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,32,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500005,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,33,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500006,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,34,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500007,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,35,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500008,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,36,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500009,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,37,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500010,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,138079,28,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500011,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,138079,29,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500012,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,138079,30,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500013,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,138079,31,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500014,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,138079,32,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500015,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,138079,33,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500016,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,138079,34,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500017,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,138079,35,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500018,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,138079,36,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500019,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,138079,37,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500020,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,141187,28,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500021,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,141187,29,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500022,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,141187,30,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500023,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,141187,31,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500024,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,141187,32,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500025,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,141187,33,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500026,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,141187,34,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500027,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,141187,35,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500028,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,141187,36,NULL,'Y');

Insert Into PRCompanyCommodity
(prcc_CompanyCommodityId,prcc_Deleted,prcc_WorkflowId,prcc_Secterr,prcc_CreatedBy,prcc_CreatedDate,prcc_UpdatedBy,prcc_UpdatedDate,prcc_TimeStamp,prcc_CompanyId,prcc_CommodityId,prcc_Sequence,prcc_Publish)
Values (500029,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,141187,37,NULL,'Y');


/*  30 PRCompanyCommodity Insert Statements Created */


/*  Begin PRCompanyCommodityAttribute Inserts */

Select 'Begin PRCompanyCommodityAttribute Inserts';
Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500000,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,17,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500001,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,18,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500002,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,21,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500003,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,26,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500004,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,27,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500005,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,28,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500006,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,28,29,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500007,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,29,19,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500008,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,29,27,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500009,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,29,28,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500010,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,29,29,NULL,'Y');

Insert Into PRCompanyCommodityAttribute
(prcca_CompanyCommodityAttributeId,prcca_Deleted,prcca_WorkflowId,prcca_Secterr,prcca_CreatedBy,prcca_CreatedDate,prcca_UpdatedBy,prcca_UpdatedDate,prcca_TimeStamp,prcca_CompanyId,prcca_CommodityId,prcca_AttributeId,prcca_Sequence,prcca_Publish)
Values (500011,NULL,NULL,NULL,-100,GetDate(),NULL,NULL,NULL,102030,29,25,NULL,'Y');


/*  12 PRCompanyCommodityAttribute Insert Statements Created */


/*  Begin Phone Inserts */

Select 'Begin Phone Inserts';
Insert Into Phone
(Phon_PhoneId,Phon_CompanyID,Phon_Type,Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_CreatedBy,Phon_CreatedDate,phon_PRDescription,phon_PRExtension,phon_PRInternational,phon_PRCityCode,phon_PRPublish,phon_PRSequence)
Values (500000,50000,'P',1,847,'680-4700',-100,GetDate(),'My Phone',NULL,NULL,NULL,'Y',1);

Insert Into Phone
(Phon_PhoneId,Phon_CompanyID,Phon_Type,Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_CreatedBy,Phon_CreatedDate,phon_PRDescription,phon_PRExtension,phon_PRInternational,phon_PRCityCode,phon_PRPublish,phon_PRSequence)
Values (500001,50000,'P',1,847,'680-4701',-100,GetDate(),'My Phone',NULL,NULL,NULL,'Y',2);

Insert Into Phone
(Phon_PhoneId,Phon_CompanyID,Phon_Type,Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_CreatedBy,Phon_CreatedDate,phon_PRDescription,phon_PRExtension,phon_PRInternational,phon_PRCityCode,phon_PRPublish,phon_PRSequence)
Values (500002,50000,'P',1,847,'680-4702',-100,GetDate(),'My Phone',NULL,NULL,NULL,'Y',3);

Insert Into Phone
(Phon_PhoneId,Phon_CompanyID,Phon_Type,Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_CreatedBy,Phon_CreatedDate,phon_PRDescription,phon_PRExtension,phon_PRInternational,phon_PRCityCode,phon_PRPublish,phon_PRSequence)
Values (500003,50000,'P',1,847,'680-4703',-100,GetDate(),'A Phone',NULL,NULL,NULL,'Y',4);

Insert Into Phone
(Phon_PhoneId,Phon_CompanyID,Phon_Type,Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_CreatedBy,Phon_CreatedDate,phon_PRDescription,phon_PRExtension,phon_PRInternational,phon_PRCityCode,phon_PRPublish,phon_PRSequence)
Values (500004,50000,'F',1,847,'680-4704',-100,GetDate(),'Fax 1',NULL,NULL,NULL,'Y',5);

Insert Into Phone
(Phon_PhoneId,Phon_CompanyID,Phon_Type,Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_CreatedBy,Phon_CreatedDate,phon_PRDescription,phon_PRExtension,phon_PRInternational,phon_PRCityCode,phon_PRPublish,phon_PRSequence)
Values (500005,50000,'F',1,847,'680-4705',-100,GetDate(),'Fax 1',NULL,NULL,NULL,'Y',6);

Insert Into Phone
(Phon_PhoneId,Phon_CompanyID,Phon_Type,Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_CreatedBy,Phon_CreatedDate,phon_PRDescription,phon_PRExtension,phon_PRInternational,phon_PRCityCode,phon_PRPublish,phon_PRSequence)
Values (500006,50000,'F',1,847,'680-4706',-100,GetDate(),'Sales Fax',NULL,NULL,NULL,'Y',7);

Insert Into Phone
(Phon_PhoneId,Phon_CompanyID,Phon_Type,Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_CreatedBy,Phon_CreatedDate,phon_PRDescription,phon_PRExtension,phon_PRInternational,phon_PRCityCode,phon_PRPublish,phon_PRSequence)
Values (500007,50000,'F',1,847,'680-4707',-100,GetDate(),'Sales Fax',NULL,NULL,NULL,'Y',8);

Insert Into Phone
(Phon_PhoneId,Phon_CompanyID,Phon_Type,Phon_CountryCode,Phon_AreaCode,Phon_Number,Phon_CreatedBy,Phon_CreatedDate,phon_PRDescription,phon_PRExtension,phon_PRInternational,phon_PRCityCode,phon_PRPublish,phon_PRSequence)
Values (500008,50000,'PF',1,847,'680-4708',-100,GetDate(),'Phone or Fax',NULL,NULL,NULL,'Y',9);


/*  9 Phone Insert Statements Created */


SELECT COUNT(1) FROM PRBusinessEvent WHERE prbe_CreatedBy = -100;
SELECT COUNT(1) FROM PRCompanyAlias WHERE pral_CreatedBy = -100;
SELECT COUNT(1) FROM PRRating WHERE prra_CreatedBy = -100;
SELECT COUNT(1) FROM PRRatingNumeralAssigned WHERE pran_CreatedBy = -100;
SELECT COUNT(1) FROM PRPersonBackground WHERE prba_CreatedBy = -100;
SELECT COUNT(1) FROM PRPersonEvent WHERE prpe_CreatedBy = -100;
SELECT COUNT(1) FROM PRRegion WHERE prd2_CreatedBy = -100;
SELECT COUNT(1) FROM PRCompanyRegion Where prcd_CreatedBy = -100
SELECT COUNT(1) FROM PRCompanyClassification Where prc2_CreatedBy = -100
SELECT COUNT(1) FROM PRCompanyProfile Where prcp_CreatedBy = -100
SELECT COUNT(1) FROM PRCompanyRelationship Where prcr_CreatedBy = -100
SELECT COUNT(1) FROM PRStockExchange Where prex_CreatedBy = -100
SELECT COUNT(1) FROM PRCompanyStockExchange Where prc4_CreatedBy = -100
SELECT COUNT(1) FROM PRCompanyCommodity Where prcc_CreatedBy = -100
SELECT COUNT(1) FROM PRCompanyCommodityAttribute Where prcca_CreatedBy = -100
SELECT COUNT(1) FROM Company Where comp_CreatedBy = -100
Alter Table PRBusinessEvent enable trigger all
Alter Table PRCompanyAlias enable trigger all
Alter Table PRRating enable trigger all
Alter Table PRRatingNumeralAssigned enable trigger all
Alter Table PRPersonBackground enable trigger all
Alter Table PRPersonEvent enable trigger all
Alter Table PRRegion enable trigger all
Alter Table PRCompanyRegion enable trigger all
Alter Table PRCompanyClassification enable trigger all
Alter Table PRCompanyProfile enable trigger all
Alter Table PRCompanyRelationship enable trigger all
Alter Table PRStockExchange enable trigger all
Alter Table PRCompanyStockExchange enable trigger all
Alter Table PRCompanyCommodity enable trigger all
Alter Table PRCompanyCommodityAttribute enable trigger all
Alter Table Company enable trigger all
Alter Table Address enable trigger all
Alter Table Address_Link enable trigger all


/* 294 Insert Statements Created. */
Commit Transaction;
Select getdate() as "End Date/Time";
Set NoCount Off
