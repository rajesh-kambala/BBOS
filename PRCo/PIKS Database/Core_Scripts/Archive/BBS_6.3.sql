UPDATE Custom_ScreenObjects SET cobj_TargetTable = 'vPRARAgingDetailOnLumber' WHERE cobj_Name='PRARAgingOnLumberGrid'
UPDATE Custom_ScreenObjects SET cobj_TargetTable = 'vPRARAgingDetailOnProduce' WHERE cobj_Name='PRARAgingOnGrid'


EXEC usp_AddCustom_Lists 'PRSSFileGrid', 40, 'prss_ClaimantCompanyId', '', 'Y', '', '', 'Custom', '', '', 'PRSSFile/PRSSFileRedirect.asp', 'prss_ClaimantCompanyId'
EXEC usp_AddCustom_Lists 'PRSSFileGrid', 50, 'prss_RespondentCompanyId', '', 'Y', '', '', 'Custom', '', '', 'PRSSFile/PRSSFileRedirect.asp', 'prss_RespondentCompanyId'
EXEC usp_AddCustom_Lists 'PRSSFileGrid', 55, 'prss_3rdPartyCompanyId', '', 'Y', '', '', 'Custom', '', '', 'PRSSFile/PRSSFileRedirect.asp', 'prss_3rdPartyCompanyId'



EXEC usp_AccpacCreateNumericField 'PRCompanyPayIndicator', 'prcpi_CurrentCount', 'Current Count'
EXEC usp_AccpacCreateNumericField 'PRCompanyPayIndicator', 'prcpi_TotalCount', 'Total Count'


EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 77, 'prcs_NewListing', 1, 1, 1
EXEC usp_AddCustom_Screens 'PRCreditSheetHeader', 78, 'prcs_CreatedDate', 0, 1, 1, 'N', NULL, NULL, NULL, 'ReadOnly=true;'


EXEC usp_AddCustom_Screens 'PRTradeReportNewEntry', 300, 'prtr_ResponseSource', 0, 1, 1
EXEC usp_AddCustom_Screens 'PRTradeReportNewEntry', 310, 'prtr_Comments', 1, 1, 4



EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 5, 'praa_Date', '', 'Y', '', 'center';
EXEC usp_AddCustom_Lists 'PRARAgingOnLumberGrid', 10, 'praad_ReportingCompanyId', '', 'Y', '', 'center', 'Custom', '', '', 'PRCompany/PRCompanySummary.asp', 'comp_CompanyID'
Go


EXEC usp_AccpacCreateSelectField @EntityName_In = 'Company', 
                           @FieldName_In = 'LegalNameOnly', 
                           @Caption_In = 'Legal Name Only',
                           @LookupFamily_In = 'CompanyAdvSearchNameOption', 
                           @SkipColumnCreation_In = 'Y';



                           
EXEC usp_AddCustom_Screens 'CompanyAdvancedSearchBox', 5, 'LegalNameOnly', 1, 1, 1;
Go


EXEC usp_AccpacCreateCheckboxField 'PRFinancial', 'prfs_SubordinationAgreements', 'Subordination Agreements'
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 160, 'prfs_StatementImageFile', 1, 1, 2, 'N', NULL, NULL, NULL, NULL
EXEC usp_AddCustom_Screens 'PRFinancialHeader', 170, 'prfs_SubordinationAgreements', 0, 1, 1, 'N', NULL, NULL, NULL, NULL


UPDATE Custom_Lists
  SET GriP_CustomAction = null,
      GriP_CustomIDField = null,
	  GriP_Jump = null
WHERE grip_GridName = 'PRCRMCSListing'
  AND GriP_ColName = 'prci_ListingSpecialistId';
Go


UPDATE Custom_Captions
   SET Capt_US = 'BBSi Company'
 WHERE capt_code = 'prar_PRCoCompanyId'
   AND Capt_FamilyType = 'Tags'

UPDATE Custom_Captions
   SET Capt_US = 'BBSi Active Account Flag'
 WHERE capt_code = 'preqfti_PRCoActiveAccount'
   AND Capt_FamilyType = 'Tags'

UPDATE Custom_Captions
   SET Capt_US = 'Amount BBSi Collected'
 WHERE capt_code = 'prss_AmountPRCoCollected'
   AND Capt_FamilyType = 'Tags'

UPDATE Custom_Captions
   SET Capt_US = 'Amount BBSi Invoiced'
 WHERE capt_code = 'prss_AmountPRCoInvoiced'
   AND Capt_FamilyType = 'Tags'

UPDATE Custom_Captions
   SET Capt_US = 'AR Aging Import Format'
 WHERE capt_code = 'prc5_ARAgingImportFormatID'
   AND Capt_FamilyType = 'Tags'

UPDATE Custom_Captions
   SET Capt_US = 'AR Aging Import Format'
 WHERE capt_code = 'praa_ARAgingImportFormatID'
   AND Capt_FamilyType = 'Tags'

Go