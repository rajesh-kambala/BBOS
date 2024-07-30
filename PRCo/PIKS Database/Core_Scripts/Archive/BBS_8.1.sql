--8.1 Release
EXEC usp_AccpacCreateIntegerField      'PRAdCampaign', 'pradc_CommodityID', 'Commodity'
EXEC usp_AccpacCreateIntegerField      'PRAdCampaign', 'pradc_AttributeID', 'Commodity Attribute'
EXEC usp_AccpacCreateTextField         'PRAdCampaign', 'pradc_AdCampaignCode', 'Ad Campaign Code', 20, 20
EXEC usp_AccpacCreateSelectField 'Company', 'comp_PROnlineOnlyReasonCode', 'Online Only Reason Code', 'comp_PROnlineOnlyReasonCode'
Go

EXEC usp_DeleteCustom_ScreenObject 'PRAdCampaignKYCD'
EXEC usp_AddCustom_ScreenObjects 'PRAdCampaignKYCD', 'Screen', 'PRAdCampaign', 'N', 0, 'PRAdCampaign'
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 1, 'pradc_CompanyID', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 2, 'pradc_HQID', 0, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 10, 'pradc_Name', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 20, 'pradc_StartDate', 0, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 30, 'pradc_AdCampaignType', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 40, 'pradc_EndDate', 0, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 50, 'pradc_TargetURL', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 60, 'pradc_AdCampaignCode', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 70, 'pradc_Sequence', 0, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 80, 'pradc_AdImageName', 1, 1, 2;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 90, 'pradc_AdFileCreatedBy', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 100, 'pradc_AdFileUpdatedBy', 0, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 110, 'pradc_SoldBy', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 120, 'pradc_SoldDate', 0, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 130, 'pradc_ApprovedByPersonID', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 140, 'pradc_Cost', 0, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 150, 'pradc_Notes', 1, 3, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 160, 'pradc_Discount', 0, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 170, 'pradc_Terms', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 180, 'pradc_Renewal', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 200, 'pradc_CreatedDate', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 210, 'pradc_WaitList', 0, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 220, 'pradc_UpdatedDate', 1, 1, 1;
EXEC usp_AddCustom_Screens 'PRAdCampaignKYCD', 230, 'pradc_UpdatedBy', 0, 1, 1;
GO


--
--  Changes to the Limatado Access
--
EXEC usp_AccpacCreateCheckboxField     'Company', 'comp_PRHasITAAccess', 'Has Limitado Access'
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 82, 'comp_PRHasITAAccess', 0, 1, 1, 0
EXEC usp_AddCustom_Screens 'PRCompanyInfo', 89, 'comp_PRExcludeFromIntlTA', 0, 1, 1, 0
GO

--Defect 4324 - CRM: Move Allow AR Report Access checkbox to Info Profile pg
EXEC usp_AccpacCreateCheckboxField 'PRCompanyInfoProfile', 'prc5_PRARReportAccess', 'Allow AR Report Access'
GO


--exec usp_AccpacGetBlockInfo 'PRCompanyInfo'
--exec usp_AccpacGetBlockInfo 'PRCompanyInfoProfileFlags'
EXEC usp_DeleteCustom_Screen 'PRCompanyInfo', 'comp_PRARReportAccess'
EXEC usp_AddCustom_Screens 'PRCompanyInfoProfileFlags',  25, 'prc5_PRARReportAccess', 0, 1,  1, 'N'
GO

--defect 4351
--exec usp_AccpacGetBlockInfo 'PRPersonList'
EXEC usp_AddCustom_Lists 'PRPersonList',  90, 'peli_PRPctOwned', NULL, 'Y'
GO