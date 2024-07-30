EXEC usp_DefineCaptions 'vPRTES', 'TES Request', 'TES Requests', null, null, null, null
Go

UPDATE Custom_ScreenObjects 
   SET cobj_EntityName = 'vPRTES'
 WHERE cobj_tableID IN (10821, 10738);
 Go

UPDATE Custom_Lists
   SET grip_colname = 'praad_TotalAmount'
 WHERE GriP_GridPropsId=13215
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRAdCampaign_upd]'))
	drop trigger [dbo].[trg_PRAdCampaign_upd]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_PRCourtCases_ins]') 
    and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	DROP TRIGGER [dbo].[trg_PRCourtCases_ins]
GO


--
-- Defect 3356
EXEC usp_AccpacDropField 'PRTESRequest', '_RequestAge'

EXEC usp_DeleteCustom_ScreenObject 'CustomTESOption6FilterBox'
EXEC usp_AddCustom_ScreenObjects 'CustomTESOption6FilterBox', 'SearchScreen', 'PRTESRequest', 'N', 0, 'PRTESRequest'
EXEC usp_AddCustom_Screens 'CustomTESOption6FilterBox', 10, 'prtesr_SentDateTime', 1, 1, 1
EXEC usp_AddCustom_Screens 'CustomTESOption6FilterBox', 20, '_ConnectionListOnly', 0, 1, 1
EXEC usp_AddCustom_Screens 'CustomTESOption6FilterBox', 30, 'prcr_Type', 1, 1, 1
EXEC usp_AddCustom_Screens 'CustomTESOption6FilterBox', 40, 'comp_PRListingStatus', 0, 1, 1
Go

--
-- Defect 3355
UPDATE Custom_Lists
   SET grip_DefaultOrderBy = 'Y',
       grip_OrderByDesc = 'Y',
	   grip_AllowOrderBy = 'Y'
 WHERE grip_GridName = 'PRBusinessEventGrid'
   AND grip_ColName = 'prbe_EffectiveDate';
Go


EXEC usp_AccpacDropTable 'PROwnershipHistory'
EXEC usp_AccpacCreateTable @EntityName='PROwnershipHistory', @ColPrefix='proh', @IDField='proh_OwnershipHistoryID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PROwnershipHistory', 'proh_OwnershipHistoryID', 'Ownership History ID'
EXEC usp_AccpacCreateSearchSelectField 'PROwnershipHistory', 'proh_CompanyID', 'Company', 'Company', 50 
EXEC usp_AccpacCreateSearchSelectField 'PROwnershipHistory', 'proh_PersonID', 'Person', 'Person', 50 
EXEC usp_AccpacCreateTextField         'PROwnershipHistory', 'proh_Title', 'Title', 50, 50
EXEC usp_AccpacCreateNumericField      'PROwnershipHistory', 'proh_Percentage', 'Percentage'
EXEC usp_AccpacCreateTextField         'PROwnershipHistory', 'proh_SortField', 'Sort Field', 50, 500
Go


EXEC usp_AccpacDropTable 'PRInvoiceTaxRate'
EXEC usp_AccpacCreateTable @EntityName='PRInvoiceTaxRate', @ColPrefix='pritr', @IDField='pritr_InvoiceTaxRateID', @UseIdentityForKey='Y'
EXEC usp_AccpacCreateKeyField          'PRInvoiceTaxRate', 'pritr_InvoiceTaxRateID', 'Invoice Tax Rate ID'
EXEC usp_AccpacCreateTextField         'PRInvoiceTaxRate', 'pritr_MasterInvoiceNo', 'Master Invoice No', 20, 20
EXEC usp_AccpacCreateTextField         'PRInvoiceTaxRate', 'pritr_InvoiceNo', 'Invoice No', 7, 7
EXEC usp_AccpacCreateTextField         'PRInvoiceTaxRate', 'pritr_TaxClass', 'Tax Class', 9, 9
EXEC usp_AccpacCreateTextField         'PRInvoiceTaxRate', 'pritr_Group', 'Group', 50, 50
EXEC usp_AccpacCreateTextField         'PRInvoiceTaxRate', 'pritr_ProductLine', 'ProductLine', 50, 50
EXEC usp_AccpacCreateNumericField      'PRInvoiceTaxRate', 'pritr_InvoiceAmt', 'Invoice Amt'
EXEC usp_AccpacCreateNumericField      'PRInvoiceTaxRate', 'pritr_TaxRate', 'Tax Rate'
EXEC usp_AccpacCreateNumericField      'PRInvoiceTaxRate', 'pritr_TaxAmt', 'Tax Amt'
EXEC usp_AccpacCreateTextField         'PRInvoiceTaxRate', 'pritr_County', 'County', 30, 30
EXEC usp_AccpacCreateTextField         'PRInvoiceTaxRate', 'pritr_City', 'City', 50, 50
EXEC usp_AccpacCreateTextField         'PRInvoiceTaxRate', 'pritr_State', 'State', 50, 50
Go

EXEC usp_AccpacCreateCheckboxField     'PRCompanyInfoProfile', 'prc5_CLSubmitter', 'CL Submitter'
EXEC usp_AddCustom_Screens 'PRCompanyInfoProfileFlags', 10, 'prc5_CLSubmitter', 0, 1, 1
Go

EXEC usp_DeleteCustom_Screen 'PRARAgingDetailNewEntry', 'praad_ManualCompanyId'
EXEC usp_AddCustom_Screens 'PRARAgingDetailNewEntry', 2, 'praad_SubjectCompanyId', 1, 1, 1
Go



UPDATE Custom_Lists
  SET grip_Order = grip_Order * 10
WHERE grip_GridName = 'PRPACALicenseGrid'
  

UPDATE Custom_Lists
  SET grip_OrderByDesc='Y',
      grip_DefaultOrderBy = 'Y',
	  grip_Order = 1,
      grip_Alignment='CENTER'
WHERE grip_GridName = 'PRPACALicenseGrid'
  AND grip_ColName = 'prpa_EffectiveDate'

UPDATE Custom_Lists
  SET grip_Order = 5,
      grip_Alignment='CENTER'
WHERE grip_GridName = 'PRPACALicenseGrid'
  AND grip_ColName = 'prpa_ExpirationDate'


UPDATE Custom_Lists
  SET grip_OrderByDesc=NULL,
      grip_Alignment='CENTER'
WHERE grip_GridName = 'PRPACALicenseGrid'
  AND grip_ColName = 'prpa_Publish'

UPDATE Custom_Lists
  SET grip_OrderByDesc=NULL,
      grip_Alignment='CENTER'
WHERE grip_GridName = 'PRPACALicenseGrid'
  AND grip_ColName = 'prpa_Current'
Go