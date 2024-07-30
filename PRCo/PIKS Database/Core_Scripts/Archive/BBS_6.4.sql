EXEC usp_AccpacCreateSelectField       'PRSSFile', 'prss_Meritorious', 'Meritorious', 'prss_Meritorious'
EXEC usp_AccpacCreateDateField         'PRSSFile', 'prss_MeritoriousDate', 'Meritorius Date'
EXEC usp_AccpacCreateCheckboxField     'PRSSFile', 'prss_Publish', 'Publish'
EXEC usp_AccpacCreateDateField	       'PRSSFile', 'prss_CATDataChanged', 'CAT Data Changed'
EXEC usp_AccpacCreateSelectField       'PRSSFile', 'prss_ClaimantIndustryType', 'Claimant Type', 'comp_PRIndustryType'

EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 300, 'prss_Meritorious',          1, 1, 1
EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 310, 'prss_ClaimantIndustryType',	0, 1, 1
EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 315, 'prss_Publish',			    0, 1, 1
EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 320, 'prss_MeritoriousDate',      1, 1, 1
EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 340, 'prss_CATDataChanged',	    0, 1, 1
EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 350, 'prss_PublishedIssueDesc',   1, 1, 3
EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 360, 'prss_StatusDescription',    1, 1, 3
EXEC usp_AddCustom_Screens 'PRSSFileAllInfo', 365, 'prss_PublishedNotes',       1, 1, 3
Go


EXEC usp_AccpacCreateTable @EntityName='PRSSCATHistory', @ColPrefix='prcath', @IDField='prcath_PRSSCATHistoryID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRSSCATHistory', 'prcath_PRSSCATHistoryID', 'SS CAT History ID'
EXEC usp_AccpacCreateIntegerField      'PRSSCATHistory', 'prcath_SSFileID', 'SS File ID'
EXEC usp_AccpacCreateSelectField	   'PRSSCATHistory', 'prcath_Meritorious', 'Meritorious', 'prss_Meritorious'
EXEC usp_AccpacCreateSelectField       'PRSSCATHistory', 'prcath_Status', 'Status', 'prss_Status'
EXEC usp_AccpacCreateCurrencyField	   'PRSSCATHistory', 'prcath_InitialAmountOwed', 'Initial Amount Owed'
EXEC usp_AccpacCreateMultilineField	   'PRSSCATHistory', 'prcath_StatusDescription', 'Status'
EXEC usp_AccpacCreateMultilineField	   'PRSSCATHistory', 'prcath_PublishedNotes', 'Notes'
EXEC usp_AccpacCreateMultilineField	   'PRSSCATHistory', 'prcath_PublishedIssueDesc', 'Issue'


EXEC usp_DeleteCustom_ScreenObject 'PRSSCATHistoryGrid'
EXEC usp_AddCustom_ScreenObjects 'PRSSCATHistoryGrid', 'List', 'PRSSCATHistory', 'N', 0, 'vPRCATHistory'
EXEC usp_AddCustom_Lists 'PRSSCATHistoryGrid', 10, 'prcath_CreatedDate'
EXEC usp_AddCustom_Lists 'PRSSCATHistoryGrid', 20, 'CreatedBy'
EXEC usp_AddCustom_Lists 'PRSSCATHistoryGrid', 30, 'prcath_Meritorious'
EXEC usp_AddCustom_Lists 'PRSSCATHistoryGrid', 40, 'prcath_PublishedIssueDesc'
EXEC usp_AddCustom_Lists 'PRSSCATHistoryGrid', 50, 'prcath_PublishedNotes'
EXEC usp_AddCustom_Lists 'PRSSCATHistoryGrid', 60, 'prcath_StatusDescription'

UPDATE custom_lists SET grip_DefaultOrderBy = 'Y', GriP_OrderByDesc='Y' WHERE grip_GridName = 'PRSSCATHistoryGrid' AND grip_ColName='prcath_CreatedDate';
EXEC usp_DefineCaptions 'PRSSCATHistory', 'SS File CAT History', 'SS File CAT History', 'prcath_CreatedDate', 'prcath_PRSSCATHistoryID', NULL, NULL

UPDATE custom_lists SET grip_DefaultOrderBy = 'Y', GriP_OrderByDesc='Y' WHERE grip_GridName = 'PRSSFileGrid' AND grip_ColName='prss_SSFileID';


UPDATE custom_captions 
   SET capt_us = 'Claimant Issue Description',
       capt_uk = 'Claimant Issue Description',
       capt_fr = 'Claimant Issue Description',
	   capt_de = 'Claimant Issue Description',
	   capt_es = 'Claimant Issue Description'
 WHERE capt_code = 'prss_IssueDescription' 

UPDATE custom_captions 
   SET capt_us = 'Issue',
       capt_uk = 'Issue',
       capt_fr = 'Issue',
	   capt_de = 'Issue',
	   capt_es = 'Issue'
 WHERE capt_code = 'prss_PublishedIssueDesc' 

UPDATE custom_captions 
   SET capt_us = 'Status',
       capt_uk = 'Status',
       capt_fr = 'Status',
	   capt_de = 'Status',
	   capt_es = 'Status'
 WHERE capt_code = 'prss_StatusDescription' 

 UPDATE custom_captions 
   SET capt_us = 'Notes',
       capt_uk = 'Notes',
       capt_fr = 'Notes',
	   capt_de = 'Notes',
	   capt_es = 'Notes'
 WHERE capt_code = 'prss_PublishedNotes' 

/*
UPDATE custom_screens
   SET seap_Colspan=1
 WHERE seap_SearchBoxName = 'PRSSFileAllInfo'
   AND SeaP_Order BETWEEN 410 AND 800

UPDATE custom_screens
   SET seap_Colspan = '2'
 WHERE seap_SearchEntryPropsID IN (6607, 6610, 6611, 6614, 6616, 7559, 7561, 7563, 7565, 	
 6608, 6612, 6617, 6620, 6620, 7562, 7564,
 6609, 6613) 
*/
 UPDATE custom_edits
    SET colp_EntrySize = 100
  WHERE colp_colname in ('prss_PublishedIssueDesc', 'prss_PublishedNotes','prss_StatusDescription')
Go




EXEC usp_AccpacCreateTable @EntityName='PRCourtCases', @ColPrefix='prcc', @IDField='prcc_CourtCaseID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRCourtCases', 'prcc_CourtCaseID', 'Court Case ID'
EXEC usp_AccpacCreateSearchSelectField 'PRCourtCases', 'prcc_CompanyID', 'Company', 'Company', 100 
EXEC usp_AccpacCreateTextField         'PRCourtCases', 'prcc_CaseNumber', 'Case Number', 50, 50
EXEC usp_AccpacCreateTextField         'PRCourtCases', 'prcc_CaseTitle', 'Case Title', 50, 200
EXEC usp_AccpacCreateTextField         'PRCourtCases', 'prcc_SuitType', 'Suit Type', 50, 200
EXEC usp_AccpacCreateDateField         'PRCourtCases', 'prcc_FiledDate', 'Filed Date'
EXEC usp_AccpacCreateDateField         'PRCourtCases', 'prcc_ClosedDate', 'Closed Date'
EXEC usp_AccpacCreateSelectField       'PRCourtCases', 'prcc_CourtCode', 'Court', 'prcc_CourtCode'
EXEC usp_AccpacCreateTextField         'PRCourtCases', 'prcc_CaseOperatingStatus', 'Case Operating Status', 50, 50
EXEC usp_AccpacCreateCurrencyField	   'PRCourtCases', 'prcc_ClaimAmt', 'Claim Amount'

EXEC usp_AddCustom_Tabs 60, 'find', 'Import Court Cases', 'customfile', 'PRGeneral/ImportFederalCivilFilingsRedirect.asp', null, 'Quote.gif'
Go



EXEC usp_DeleteCustom_ScreenObject 'PRCityInternational'
EXEC usp_AddCustom_ScreenObjects 'PRCityInternational', 'Screen', 'vPRLocation', 'N', 0, 'vPRLocation'
EXEC usp_AddCustom_Screens 'PRCityInternational', 10,  'prci_City',  1, 1, 1
EXEC usp_AddCustom_Screens 'PRCityInternational', 20,  'prcn_CountryID',  0, 1, 1
EXEC usp_AddCustom_Screens 'PRCityInternational', 100,  'prci_RatingTerritory',  1, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 110,  'prci_RatingUserId',  0, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 120,  'prci_SalesTerritory',  1, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 130,  'prci_InsideSalesRepId',  0, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 140,  'prci_FieldSalesRepId',  1, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 150,  'prci_ListingSpecialistId',  0, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 160,  'prci_CustomerServiceId',  0, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 170,  'prci_LumberRatingUserId',  1, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 180,  'prci_LumberInsideSalesRepId',  0, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 190,  'prci_LumberFieldSalesRepId',  0, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 200,  'prci_LumberListingSpecialistId',  1, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
EXEC usp_AddCustom_Screens 'PRCityInternational', 210,  'prci_LumberCustomerServiceId',  0, 1, 1, 0, NULL, NULL, NULL, 'ReadOnly=true;'
Go


--select * from custom_tabs where Tabs_Entity = 'find' and Tabs_DeviceID is null order by tabs_order



EXEC usp_AccpacCreateIntegerField      'PRWebUser', 'prwu_LastClaimsActivitySearchID', 'Last Claims Activity Search'
Go


EXEC usp_AccpacCreateTextField 'PRCompanySearch', 'prcse_OriginalNameMatch', 'Company Original Name Match', 104, 104
EXEC usp_AccpacCreateTextField 'PRCompanySearch', 'prcse_OldName1Match', 'Company Old Name 1 Match', 104, 104
EXEC usp_AccpacCreateTextField 'PRCompanySearch', 'prcse_OldName2Match', 'Company Old Name 2 Match', 104, 104
EXEC usp_AccpacCreateTextField 'PRCompanySearch', 'prcse_OldName3Match', 'Company Old Name 3 Match', 104, 104
Go


EXEC usp_AddCustom_Screens 'PROpportunitySearchBoxBBOSInquiry', 90, 'oppo_Status', 1, 1, 1, 0
Go

EXEC usp_AccpacCreateMultiselectField 'PRCompanyProfile', 'prcp_TrnBkrArrangesTransportation', 'Arranges transportation with', 'prcp_ArrangesTransportWith', 4
Go

UPDATE custom_captions
   SET capt_us = 'Phone',
       capt_uk = 'Phone',
	   capt_fr = 'Phone',
	   capt_de = 'Phone',
	   capt_es = 'Phone'
 WHERE capt_code = 'prssc_telephone'
Go

EXEC usp_AddCustom_Lists 'PRWebUserAUSGrid', 15, 'comp_CompanyID', null, 'Y', 'Y', '', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_CompanyID'
EXEC usp_AddCustom_Lists 'PRShipmentLogGrid', 15, 'CreatedBy', null, 'Y'
Go

DELETE
  FROM custom_tabs
 WHERE tabs_entity = 'find'
   AND tabs_caption = 'Convert Company To Branch'
   AND Tabs_DeviceID IS NULL;
Go


--UPDATE Custom_Screens
--   SET seap_CreateScript = 'DefaultValue=''Checked'''
-- WHERE seap_SearchBoxName = 'CommunicationFilterBox'
--   AND seap_ColName = 'comm_NonSystemGenerated';
--Go


DROP INDEX ndx_prtr_SubjectId ON PRTradeReport;
