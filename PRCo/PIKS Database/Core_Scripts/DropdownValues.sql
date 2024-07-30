SET NOCOUNT ON

-- This file creates all the drop down values for selction items within the system
-- Remove unwanted standard accpac values from comm_action custom captions
DELETE FROM custom_captions WHERE capt_family='Comm_Action' AND capt_Code in ('Demo', 'Meeting', 'Vacation');

-- Remove unwanted standard accpac value from comm_type custom caption
DELETE FROM custom_captions WHERE capt_family='Comm_Type' AND capt_Code = 'Appointment';

-- Remove unwanted accpac value from comm_status
DELETE FROM custom_captions WHERE capt_family='Comm_Status' AND capt_Code='InProgress';
exec usp_TravantCRM_CreateDropdownValue 'Comm_Status', 'Incomplete', 5, 'Incomplete'

-- remove the standard accpac comp_source custom captions
DELETE FROM custom_captions WHERE capt_family = 'comp_source';

-- remove the standard accpac oppo_Type custom captions (Consulting, License, Mix, Service)
DELETE FROM custom_captions WHERE capt_family = 'oppo_Type';

-- remove the standard accpac oppo_source values
DELETE FROM custom_captions WHERE capt_family = 'oppo_Source';

-- change the communications labels that where modified during the CRM6.0 upgrade
update Custom_Captions SET capt_us = 'Interactions' WHERE cast(capt_us as varchar) = 'communications';

-- remove all the current values
-- except a few key ones that must exist
-- from release to release
DELETE
  FROM custom_captions
 WHERE capt_familytype = 'Choices'
   AND capt_component IN ('PRDropdownValues', 'PRCo')
   AND capt_family NOT IN ('CRMBuildNumber', 'prau_LastRunDate', 'prau_LastAlertDateTime', 'prlumber_LastRunDate', 'prlumber_LastRunDate_old', 'AccountingExportLastRunDate', 'CreditSheetReport',
                           'LastBBScoreRunDate', 'LastBBScoreRunDate_Lumber', 'LastMassInvestigationRunDate', 'AutoRemoveRatingNumerals',
						   'MessageCenterMsg', 'MemberMessageCenterMsg', 'NonMemberMessageCenterMsg', 'ITAMessageCenterMsg',
						   'CreditMonitorReportDate', 'SupportedRatingLastRunDate', 'BBScoreImageLastRunDate', 'LastBBScoreExportDate',
						   'LastBBScoreReportDate', 'LastBBScoreReportDate_Lumber', 'ARAnalysisReportLastRunDate',
						   'IndustryAverageRatings_P','IndustryAverageRatings_T',
						   'BBSSuppressAUSandReport', 'BBSUseBothModelsForLineChart', 'DepositBatchNum' )

--EXEC usp_TravantCRM_CreateDropdownValue 'DepositBatchNum', '0', 1, 'The last depost batch number.'

EXEC usp_TravantCRM_AddCustom_Captions 'Choices', 'SQLCLR_BIN_PATH', 'SQLCLR_BIN_PATH', 0, 'D:\Applications\SQLCLR\'
EXEC usp_TravantCRM_CreateDropdownValue 'IntlPhoneFormatFile', 'URL', 1, 'https://crm.bluebookservices.local/CRM/CustomPages/International Phone Formats.xlsx'

--DELETE FROM Custom_Captions WHERE capt_family = 'TravantCRMLogger'
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'FileName', 1, 'D:\Applications\CRM\Logs\TravantCRM_Trace.txt'
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'ErrorFileName', 1, 'D:\Applications\CRM\Logs\TravantCRM_Error.txt'
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'ApplicationName', 1, 'BBSI CRM'
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'EMailSupportEnabled', 1, '1'
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'EMailSMTPServer', 1, 'smtp3.bluebookservices.com'
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'EMailSupportAddress', 1, 'supportbbos@bluebookservices.com'
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'EMailSupportSubject', 1, 'BBSI CRM Exception (QA)'
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'EMailFromAddress', 1, 'qa.bluebookservices@bluebookservices.com'
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'TraceLevel', 1, '1'
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'EmailError', 1, 'Y'  -- Bool
EXEC usp_TravantCRM_CreateDropdownValue 'TravantCRMLogger', 'IsEnabled', 1, 'Y'  -- Bool

-- DELETE FROM Custom_Captions WHERE capt_family IN ('EmailOverride', 'FaxOverride', 'BBSInterfaceOverride')
-- SELECT * FROM Custom_Captions WHERE capt_family IN ('EmailOverride', 'FaxOverride', 'BBSInterfaceOverride')
exec usp_TravantCRM_CreateDropdownValue 'EmailOverride', 'Email', 0, 'qa.bluebookservices@bluebookservices.com' /* Used by usp_CreateEmail to override any specified email address. */
exec usp_TravantCRM_CreateDropdownValue 'FaxOverride', 'Fax', 0, '630-344-0381' /* Used by usp_CreateEmail to override any specified fax. */
exec usp_TravantCRM_CreateDropdownValue 'BBSInterfaceOverride', 'Test', 0, 'Test' /* Used by BBSInterface.usp_PopulatePR* to determine the SBBS data source. */

exec usp_TravantCRM_CreateDropdownValue 'StripeInvoice', 'StripeInvoiceEnabled', 0, 'true'

-- Create the Internal HQID's
exec usp_TravantCRM_CreateDropdownValue 'InternalHQID', '100001', 1, 'Sample Produce Sales, Inc.'
exec usp_TravantCRM_CreateDropdownValue 'InternalHQID', '100002', 2, 'Blue Book Services, Inc.'
exec usp_TravantCRM_CreateDropdownValue 'InternalHQID', '204482', 3, 'Travant Solutions, Inc.'

-- Create the TempReports paths
-- DELETE FROM Custom_Captions WHERE capt_family = 'TempReports'
exec usp_TravantCRM_CreateDropdownValue 'TempReports', 'Share', 1, '\\AZ-NC-SQL-Q1\TempReports'
exec usp_TravantCRM_CreateDropdownValue 'TempReports', 'Local', 2, 'D:\Applications\TempReports'

-- Create the financial statement root path
exec usp_TravantCRM_CreateDropdownValue 'FinancialStatementRoot', '1', 1, '/FinancialStatements'

-- Status_OpenClosed can be used anywhere an open/closed dropdown is needed
exec usp_TravantCRM_CreateDropdownValue 'Status_OpenClosed', 'Open', 1, 'Open'
exec usp_TravantCRM_CreateDropdownValue 'Status_OpenClosed', 'Closed', 2, 'Closed'

exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'A', 1, 'Association'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'C', 2, 'Corporation'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'D', 3, 'Debtor In Possession'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'E', 4, 'Estate'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'I', 5, 'Individual'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'L', 6, 'Limited Partnership'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'M', 7, 'Limited Liability Company'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'P', 8, 'Partnership'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'T', 9, 'Trust'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'U', 10, 'Unlimited Liability Company'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCode', 'N', 11, 'Limited Liability Partnership'

DELETE FROM Custom_captions WHERE Capt_Family = 'ProfCode'
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', '0', 1, 'Food Service'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', 'C', 10, 'Grower-Shipper'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', 'D', 11, 'Shipper'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', 'G', 12, 'Grocery Wholesaler'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', '4', 2, 'Wholesale Dealer'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', '5', 3, 'Commission Merchant'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', '6', 4, 'Broker'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', '7', 5, 'Retailer'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', '8', 6, 'Processor'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', '9', 7, 'Trucker'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', 'A', 8, 'Grower'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', 'B', 9, 'Grower-Agent'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_TravantCRM_CreateDropdownValue 'ProfCode', 'W', 13, 'Wholesaler'

exec usp_TravantCRM_CreateDropdownValue 'TypeFruitVeg', '1', 1, 'Fresh Fruits & Vegs'         /*pril_TypeFruitVeg, prpa_TypeFruitVeg*/
exec usp_TravantCRM_CreateDropdownValue 'TypeFruitVeg', '2', 2, 'Frozen Fruits & Vegs'         /*pril_TypeFruitVeg, prpa_TypeFruitVeg*/
exec usp_TravantCRM_CreateDropdownValue 'TypeFruitVeg', '3', 3, 'Both Fresh & Frozen'         /*pril_TypeFruitVeg, prpa_TypeFruitVeg*/

DELETE FROM Custom_captions WHERE Capt_Family = 'TypeFruitVegRL'
exec usp_TravantCRM_CreateDropdownValue 'TypeFruitVegRL', '1', 1, 'Fresh'
exec usp_TravantCRM_CreateDropdownValue 'TypeFruitVegRL', '2', 2, 'Frozen'
exec usp_TravantCRM_CreateDropdownValue 'TypeFruitVegRL', '3', 3, 'Fresh and Frozen'

DELETE FROM Custom_captions WHERE Capt_Family = 'ProfCodeRL'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', '0', 1, 'Food Service'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', '4', 2, 'Wholesale Dealer'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', '5', 3, 'Commission Merchant'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', '6', 4, 'Broker'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', '7', 5, 'Retailer'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', '8', 6, 'Processor'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', '9', 7, 'Trucker'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', 'A', 8, 'Grower'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', 'B', 9, 'Grower''s Agent'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', 'C', 10, '#N/A'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', 'D', 11, 'Shipper'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', 'G', 12, 'Grocery Wholesaler'
exec usp_TravantCRM_CreateDropdownValue 'ProfCodeRL', 'W', 13, 'Wholesaler'

DELETE FROM Custom_captions WHERE Capt_Family = 'OwnershipTypeCodeRL'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'A', 1, 'Association'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'C', 2, 'Corporation'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'D', 3, 'Debtor In Possession'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'E', 4, 'Estate'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'I', 5, 'Sole Proprietor'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'L', 6, 'Limited Partnership'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'M', 7, 'Limited Liability Company (LLC)'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'P', 8, 'Partnership'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'T', 9, 'Trust'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'U', 10, 'Unlimited Liability Company'
exec usp_TravantCRM_CreateDropdownValue 'OwnershipTypeCodeRL', 'N', 10, 'Limited Liability Partnership'

DELETE FROM Custom_captions WHERE Capt_Family = 'prpa_TerminateCodeRL'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '0', 1, 'Non Licnese'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '1', 1, 'Active'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '4', 4, 'Active With Bond'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '5', 5, 'Early Termination'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '7', 7, 'Early Termination - New Entity'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '10', 10, 'Terminated - No Response'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '11', 11, 'Succeeded'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '12', 12, 'Terminated - Oob'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '13', 13, 'Temporary Out Of Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '14', 14, 'Revoked'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '15', 15, 'Terminated - R & F'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '16', 16, 'Bankrupt'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '17', 17, 'License Cancelled'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '18', 18, 'Active With Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '19', 19, 'Suspension With Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '20', 20, 'Terminated - No Longer Subject'
exec usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '23', 23, 'Revocation with Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '30', 30, 'Administrative License Suspension'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '33', 33, 'Suspended - Unpaid Award(S)'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '34', 34, 'Terminated - Unpaid Award(S)'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '40', 40, 'Terminated Retailer'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '41', 41, 'Suspension With Bankrupt - Terminated'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '42', 42, 'Admin Suspension - Terminated'
exec usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '43', 43, 'Non Licensed'
exec usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '44', 44, 'Non Licensed - Unpaid Award(S)'
exec usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '45', 45, 'Non Licensed - R & F'
exec usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '46', 46, 'Non Licensed - Injunction Imposed'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCodeRL', '47', 47, 'Terminated - Injunction Imposed'

exec usp_TravantCRM_CreateDropdownValue 'addr_PRZone', '1', 1, ''
exec usp_TravantCRM_CreateDropdownValue 'addr_PRZone', '2', 2, '2'
exec usp_TravantCRM_CreateDropdownValue 'addr_PRZone', '3', 3, '3'
exec usp_TravantCRM_CreateDropdownValue 'addr_PRZone', '4', 4, '4'
exec usp_TravantCRM_CreateDropdownValue 'addr_PRZone', '5', 5, '5'
exec usp_TravantCRM_CreateDropdownValue 'addr_PRZone', '6', 6, '6'
exec usp_TravantCRM_CreateDropdownValue 'addr_PRZone', '7', 7, '7'
exec usp_TravantCRM_CreateDropdownValue 'addr_PRZone', '8', 8, '8'

exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompany', 'M', 1, 'Mailing'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompany', 'PH', 2, 'Physical'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompany', 'I', 3, 'Invoice'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompany', 'W', 4, 'Warehouse'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompany', 'S', 5, 'Shipping'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompany', 'T', 6, 'Tax'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompany', 'PS', 7, 'BBSi Ship'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompany', 'PM', 8, 'BBSi Mail'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompany', 'O', 9, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompany', 'MILL', 10, 'Mill'

exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompanyNotL', 'M', 1, 'Mailing'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompanyNotL', 'PH', 2, 'Physical'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompanyNotL', 'I', 3, 'Invoice'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompanyNotL', 'W', 4, 'Warehouse'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompanyNotL', 'S', 5, 'Shipping'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompanyNotL', 'T', 6, 'Tax'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompanyNotL', 'PS', 7, 'BBSi Ship'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompanyNotL', 'PM', 8, 'BBSi Mail'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypeCompanyNotL', 'O', 9, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'adli_TypePerson', 'H', 1, 'Home'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypePerson', 'B', 2, 'Business'
exec usp_TravantCRM_CreateDropdownValue 'adli_TypePerson', 'O', 3, 'Other'

EXEC usp_TravantCRM_DeleteCustom_Caption null, 'case_Priority'
EXEC usp_TravantCRM_CreateDropdownValue 'case_Priority', 'High', 10, 'High'
EXEC usp_TravantCRM_CreateDropdownValue 'case_Priority', 'Medium', 20, 'Medium'
EXEC usp_TravantCRM_CreateDropdownValue 'case_Priority', 'Low', 30, 'Low'

EXEC usp_TravantCRM_DeleteCustom_Caption null, 'Case_Status'
EXEC usp_TravantCRM_CreateDropdownValue 'Case_Status', 'Pending', 10, 'Pending'
EXEC usp_TravantCRM_CreateDropdownValue 'Case_Status', 'Open', 20, 'Open'
EXEC usp_TravantCRM_CreateDropdownValue 'Case_Status', 'Collected', 30, 'Collected'
EXEC usp_TravantCRM_CreateDropdownValue 'Case_Status', 'PartiallyCollected', 35, 'Closed - Partially collected'
EXEC usp_TravantCRM_CreateDropdownValue 'Case_Status', 'NotCollected', 40, 'Closed - Not collected'
EXEC usp_TravantCRM_CreateDropdownValue 'Case_Status', 'MembershipChanges', 50, 'Closed - Membership Changes'
EXEC usp_TravantCRM_CreateDropdownValue 'Case_Status', '3rdParty', 60, 'Sent to 3rd Party'

exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'A', 1, 'Primary'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'X', 10, 'No Sell'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'CC', 11, 'Credit Card Or COD Only'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'B', 2, 'Secondary'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'C', 3, 'Tertiary'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'F', 4, 'New M (First Contact)'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'K', 5, 'Key'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'N', 6, 'Not A Prospect'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'P', 7, 'Prospect (Hq)'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'Q', 8, 'Prospect (Branch)'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRAccountTier', 'T', 9, 'Team'
exec usp_TravantCRM_CreateDropdownValue 'Comp_PRAdministrativeUsage', '1', 1, 'Handles its own administration and buying/ selling/ transporting.'
exec usp_TravantCRM_CreateDropdownValue 'Comp_PRAdministrativeUsage', '2', 2, 'Administrative office only'
exec usp_TravantCRM_CreateDropdownValue 'Comp_PRAdministrativeUsage', '3', 3, 'Does not handle its own administration (only buying/ selling/ transporting.)'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRDataQualityTier', 'C', 1, 'Critical'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRDataQualityTier', 'H', 2, 'High'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRDataQualityTier', 'M', 3, 'Medium'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRDataQualityTier', 'L', 4, 'Low'

-- DELETE FROM Custom_Captions WHERE Capt_Family = 'comp_PRListingStatus'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus', 'L', 10, 'Listed'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus', 'H', 20, 'Hold'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus', 'LUV', 30, 'Listing Verification Pending'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus', 'N1', 100, 'Not Listed - Service Only'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus', 'N2', 110, 'Not Listed - Listing Membership Prospect'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus', 'N3', 120, 'Not Listed - Non-Factor'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus', 'N4', 130, 'Not Listed - Previously Listing/M Prospect'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus', 'N5', 140, 'Not Listed - Recently Out of Business'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus', 'N6', 150, 'Not Listed - Out of Business'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus', 'D', 200, 'Deleted Before Migration'

-- DELETE FROM Custom_Captions WHERE Capt_Family = 'comp_PRListingStatus_MS'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus_MS', 'L,H', 10, 'Listed'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus_MS', 'LUV', 20, 'Listing Verification Pending'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus_MS', 'N1', 30, 'Not Listed - Service Only'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus_MS', 'N2', 40, 'Not Listed - Listing Membership Prospect'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus_MS', 'N3', 50, 'Not Listed - Non-Factor'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus_MS', 'N4', 60, 'Not Listed - Previously Listing/M Prospect'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRListingStatus_MS', 'N5,N6', 70, 'Not Listed - Out of Business'

-- DELETE FROM Custom_Captions WHERE Capt_Family = 'BBOSListingStatusSearch'
exec usp_TravantCRM_CreateDropdownValue 'BBOSListingStatusSearch', 'L,H,LUV', 10, 'Listed'
exec usp_TravantCRM_CreateDropdownValue 'BBOSListingStatusSearch', 'L,H,LUV,N5', 20, 'Listed + Recently Closed'
exec usp_TravantCRM_CreateDropdownValue 'BBOSListingStatusSearch', 'N3,N5,N6', 30, 'Previously Listed'

-- DELETE FROM Custom_Captions WHERE Capt_Family = 'BBOSListingStatusSearchBBSi'
exec usp_TravantCRM_CreateDropdownValue 'BBOSListingStatusSearchBBSi', 'L,H,LUV', 10, 'Listed'
exec usp_TravantCRM_CreateDropdownValue 'BBOSListingStatusSearchBBSI', 'L,H,LUV,N5', 20, 'Listed + Recently Closed'
exec usp_TravantCRM_CreateDropdownValue 'BBOSListingStatusSearchBBSi', 'N3,N5,N6', 30, 'Previously Listed'
exec usp_TravantCRM_CreateDropdownValue 'BBOSListingStatusSearchBBSi', 'L,H,LUV,N2', 40, 'Listed & Prospects'


exec usp_TravantCRM_CreateDropdownValue 'comp_PRType', 'H', 1, 'Headquarter'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRType', 'B', 2, 'Branch'

exec usp_TravantCRM_CreateDropdownValue 'comp_PRType_BBOS', 'H', 1, 'HQ'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRType_BBOS', 'B', 2, 'BR'

exec usp_TravantCRM_CreateDropdownValue 'comp_PRCommunicationLanguage', 'E', 1, 'English'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRCommunicationLanguage', 'S', 2, 'Spanish'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRInvMethodGroup', 'A', 1, 'A'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRInvMethodGroup', 'B', 1, 'B'

exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'P', 1, 'Phone'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'F', 2, 'Fax'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'E', 3, 'E-Mail'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'M', 4, 'Mail'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'W', 5, 'Web'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'PV', 6, 'Personal Visit'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'CV', 7, 'Convention Visit'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'CL', 8, 'Reference List'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'PD', 9, 'PACA Database'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'NAWLA', 10, 'NAWLA'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'NACM-OR', 11, 'NACM-OR'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRMethodSourceReceived', 'O', 12, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'comp_PRIndustryType', 'P', 1, 'Produce'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRIndustryType', 'T', 2, 'Transportation'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRIndustryType', 'S', 3, 'Supply and Service'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRIndustryType', 'L', 4, 'Lumber'

exec usp_TravantCRM_CreateDropdownValue 'BBOSSearchIndustryType', 'P', 1, 'Produce'
exec usp_TravantCRM_CreateDropdownValue 'BBOSSearchIndustryType', 'T', 2, 'Transportation'
exec usp_TravantCRM_CreateDropdownValue 'BBOSSearchIndustryType', 'S', 3, 'Supply'

exec usp_TravantCRM_CreateDropdownValue 'comp_PRIndustryTypeBBOS', 'P', 1, 'Produce'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRIndustryTypeBBOS', 'T', 2, 'Transportation'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRIndustryTypeBBOS', 'S', 3, 'Supply/Service'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRIndustryTypeBBOS', 'L', 4, 'Lumber'

--delete from custom_captions where capt_family='prse_ServiceCode'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BASIC', 1, 'BASIC'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'STANDARD', 2, 'STANDARD'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'PREMIUM', 3, 'PREMIUM'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'ENTERPRISE', 4, 'ENTERPRISE'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BBS100', 1, 'BBS100'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BBS100-E', 2, 'BBS100-E'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BBS150', 3, 'BBS150'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BBS200', 4, 'BBS200'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BBS250', 5, 'BBS250'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BBS300', 6, 'BBS300'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BBS350', 7, 'BBS350'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BBS355', 8, 'BBS355'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BBS75-APR', 9, 'BBS75-APR'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'BBSINTL', 10, 'BBSINTL'

exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'L100', 20, 'L100'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'L150', 21, 'L150'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'L200', 22, 'L200'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'L201', 23, 'L201'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'L300', 24, 'L300'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'L301', 25, 'L301'
exec usp_TravantCRM_CreateDropdownValue 'prse_ServiceCode', 'L99', 26, 'L99'

exec usp_TravantCRM_CreateDropdownValue 'comp_PRIndustryTypeMS', 'L', 1, 'Lumber'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRIndustryTypeMS', 'P,S,T', 2, 'Produce (P/S/T)'

exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'REF', 1, 'Referral/Word-of-Mouth'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'USER',2, 'Current or former BBS User'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'CA',  3, 'Convention/Association'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'AD',  4, 'BBSi Ad'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'N',   5,'Newspaper'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'WEB', 6, 'BBSi Web Site'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'DM',  7, 'BBSi Direct Mail Piece'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'PACA',8, 'PACA Database'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'P',   9, 'Third Party'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'RBCS',10, 'RBCS'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'CL',  11, 'Reference List'
exec usp_TravantCRM_CreateDropdownValue 'comp_Source', 'O',   12,'Other'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '1', 1, 'January'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '2', 2, 'February'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '3', 3, 'March'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '4', 4, 'April'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '5', 5, 'May'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '6', 6, 'June'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '7', 7, 'July'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '8', 8, 'August'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '9', 9, 'September'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '10', 10, 'October'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '11', 11, 'November'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartMonth', '12', 12, 'December'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2010', 2010, '2010'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2011', 2011, '2011'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2012', 2012, '2012'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2013', 2013, '2013'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2014', 2014, '2014'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2015', 2015, '2015'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2016', 2016, '2016'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2017', 2017, '2017'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2018', 2018, '2018'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2019', 2019, '2019'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetStartYear', '2020', 2020, '2020'

--DELETE FROM custom_captions WHERE capt_family = 'oppo_PRAdSize';
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRAdSize', 'Full', 1, 'Full Page'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRAdSize', 'Half', 3, '1/2 Page'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRAdSize', 'Third', 4, '1/3 Page'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRAdSize', 'Sixth', 5, '1/6 Page'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRAdSize', 'Other', 8, 'Other'

--DELETE FROM custom_captions WHERE capt_family = 'oppo_PRPremium';
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPremium', 'IFC',   10, 'Inside Front Cover'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPremium', 'Page1', 20, '1st Page'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPremium', 'Page3', 30, '3rd Page'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPremium', '5thP',  40, '5th Page'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPremium', 'HSL',   50, 'Heavy Stock Front'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPremium', 'HSR',   60, 'Heavy Stock Back'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPremium', 'IBC',   70, 'Inside Back Cover'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPremium', 'OBC',   80, 'Outside Back Cover'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPremium', 'LINS',  90, '2/3 Page Lft Insert'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPremium', 'RINS',  100, '2/3 Page Rt Insert'

--DELETE FROM custom_captions WHERE capt_family = 'oppo_PRPlacement';
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPlacement', 'Ad:BPSL', 1, 'Spotlight'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPlacement', 'Ad:BP', 3, 'Supplement'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPlacement', 'Ad:BPG', 2, 'General'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRPlacement', 'Ad:BPNiB', 4, 'New in Blue'

--DELETE FROM custom_captions WHERE capt_family = 'oppo_PRSponsorship';
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRSponsorship', 'OTJ', 1, 'On the Job'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRSponsorship', 'TT', 2, 'Top Topic'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRSponsorship', 'KYE', 3, 'KYC Exclusive'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRSponsorship', 'Ad:OKYC', 4, 'KYC Basic'

--DELETE FROM custom_captions WHERE capt_family = 'oppo_Type';
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_Type', 'NEWM', 1, 'New Membership'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_Type', 'UPG', 1, 'Membership Upgrade'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_Type', 'BP', 1, 'Blueprints Advertising'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_Type', 'DA', 1, 'Digital Advertising'

--DELETE FROM custom_captions WHERE capt_family = 'oppo_PRDigitalPlacement';
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRDigitalPlacement', 'OVBA',    10, 'Online Vert Banner Ad'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRDigitalPlacement', 'OKYCFPA', 20, 'Online KYC - Full Page Ad'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRDigitalPlacement', 'BPBVBA',  30, 'BP Briefing Vert Banner Ad'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRDigitalPlacement', 'ILA',     40, 'Insider Leaderboard Ad'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRDigitalPlacement', 'BPDMLA',  50, 'BP Digital Mag Ldrboard Ad'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRDigitalPlacement', 'BPDMPA',  60, 'BP Digital Mag Precover Ad'


-- A combination of the Membership, Upgrade, and Ad Lost Reasons
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'NNTA',      1, 'Ad: No Need to Advertise'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'BR',        2, 'Ad: Budget Restrictions'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'NA',        3, 'Ad: Never advertises (with us or anyone)'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'PRRPA',     4, 'Ad: Poor response rate to past ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'RR',        5, 'Ad: Ratings related'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'URDM',      6, 'Ad: Unable to reach decision maker'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'DNWPNC',    7, 'Ad: Do not want to pursue new customers'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'DNRTA',     8, 'Ad: Does not reach target audience'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'AWOP',      9, 'Ad: Advertise with other publishers'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'O',        10, 'Ad: Other'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'C',        21, 'M: Competitive Offerings'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'CB',       23, 'M: Cost/Benefit'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'N',        24, 'M: New Start-Up/Not Ready Yet'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'NTM',      25, 'M: Not Our Target Mkt'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'O',        26, 'M: Other'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'CB',       41, 'Up: Cost/benefit'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'SWCS',     42, 'Up: Satisfied with Current Service'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'NTS',      43, 'Up: Not Tech Savvy'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'O',        44, 'Up: Other'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRLostReason', 'ODDA',     45, 'Ad: Only does digital adertising'

exec usp_TravantCRM_CreateDropdownValue 'oppo_MembershipLostReason', 'C',  1, 'Competitive Offerings'
exec usp_TravantCRM_CreateDropdownValue 'oppo_MembershipLostReason', 'R',  2, 'RBCS'
exec usp_TravantCRM_CreateDropdownValue 'oppo_MembershipLostReason', 'CB', 3, 'Cost/Benefit'
exec usp_TravantCRM_CreateDropdownValue 'oppo_MembershipLostReason', 'N',  4, 'New Start-Up/Not Ready Yet'
exec usp_TravantCRM_CreateDropdownValue 'oppo_MembershipLostReason', 'NTM', 5, 'Not Our Target Mkt'
exec usp_TravantCRM_CreateDropdownValue 'oppo_MembershipLostReason', 'O',  6, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'oppo_UpgradeLostReason', 'CB',    1, 'Cost/benefit'
exec usp_TravantCRM_CreateDropdownValue 'oppo_UpgradeLostReason', 'SWCS', 2, 'Satisfied with Current Service'
exec usp_TravantCRM_CreateDropdownValue 'oppo_UpgradeLostReason', 'NTS',  3, 'Not Tech Savvy'
exec usp_TravantCRM_CreateDropdownValue 'oppo_UpgradeLostReason', 'O',    4, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'oppo_AdLostReason', 'BR',     10, 'Budget Restrictions'
exec usp_TravantCRM_CreateDropdownValue 'oppo_AdLostReason', 'RR',     20, 'Ratings related'
exec usp_TravantCRM_CreateDropdownValue 'oppo_AdLostReason', 'PRRPA',  30, 'Poor response rate to past ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_AdLostReason', 'DNWPNC', 40, 'Do not want to pursue new customers'
exec usp_TravantCRM_CreateDropdownValue 'oppo_AdLostReason', 'AWOP',   50, 'Advertise with other publishers'
exec usp_TravantCRM_CreateDropdownValue 'oppo_AdLostReason', 'DNRTA',  60, 'Does not reach target audience'
exec usp_TravantCRM_CreateDropdownValue 'oppo_AdLostReason', 'ODDA',   70, 'Only does digital adertising'
exec usp_TravantCRM_CreateDropdownValue 'oppo_AdLostReason', 'O',      100, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PersonRole', 'I', 1, 'Influencer'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PersonRole', 'D', 2, 'Decision Maker'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PersonRole', 'G', 3, 'Gatekeeper'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PersonRole', 'O', 4, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdRun', 'A',   1, 'Annual'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdRun', '3Q',  2, '3 Quarters'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdRun', '2Q',  3, '2 Quarters'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdRun', '1Q',  4, '1 Quarter'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdvertiseIn', 'PN',    1, 'Produce News'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdvertiseIn', 'PK',    2, 'The Packer'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdvertiseIn', 'PB',    3, 'Produce Business'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdvertiseIn', 'SN',    4, 'Supermarket News'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdvertiseIn', 'RB',    5, 'Any RBCS publication'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdvertiseIn', 'WG',    6, 'WGA publication'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRAdvertiseIn', 'O',    7, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRStatus', 'Open',		10, 'Open'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRStatus', 'Sold',		20, 'Closed Sold'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRStatus', 'NotSold',	30, 'Closed Not Sold'

--delete from custom_captions where capt_familytype = 'Choices' and capt_family = 'oppo_PRStage'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRStage', 'Lead',			10, 'Lead'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRStage', 'Prospect',		20, 'Prospect'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRStage', 'Opportunity',	30, 'Opportunity'

--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200610', 1, 'October 2006'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200701', 2, 'January 2007'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200704', 3, 'April 2007'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200707', 4, 'July 2007'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200710', 5, 'October 2007'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '2007SE', 6, 'Special Edition 2007'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200801', 7, 'January 2008'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200804', 8, 'April 2008'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200807', 9, 'July 2008'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200810', 10, 'October 2008'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '2008RG', 11, 'Reference Guide 2008'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '2009RG', 12, 'Reference Guide 2009'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200901', 13, 'January 2009'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200904', 14, 'April 2009'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200907', 15, 'July 2009'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '200910', 16, 'October 2009'
--exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '201001', 17, 'January 2010'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '201004', 18, 'April 2010'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '201007', 19, 'July 2010'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '201010', 20, 'October 2010'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '201101', 21, 'January 2011'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '201104', 22, 'April 2011'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '201107', 23, 'July 2011'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTargetIssue', '201110', 24, 'October 2011'

exec usp_TravantCRM_CreateDropdownValue 'oppo_Priority', 'High', 170, 'High'
exec usp_TravantCRM_CreateDropdownValue 'oppo_Priority', 'Medium', 180, 'Medium'
exec usp_TravantCRM_CreateDropdownValue 'oppo_Priority', 'Low', 190, 'Low'


exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTeam', 'ISC',    1, 'ISC'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTeam', 'Field',  1, 'Field'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTeam', 'Team',   1, 'Team'

-- Full list of type values for the view and filtering
-- delete from custom_captions where capt_family='oppo_PRType'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'BASIC', 1, 'BASIC'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'STANDARD', 2, 'STANDARD'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'PREMIUM', 3, 'PREMIUM'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'ENTERPRISE', 4, 'ENTERPRISE'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S50',  10, 'Series 50'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S75',  11, 'Series 75'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S100', 12, 'Series 100'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S135', 13, 'Series 135'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S150', 14, 'Series 150'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S200', 15, 'Series 200'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S250', 16, 'Series 250'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S300', 17, 'Series 300'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S350', 18, 'Series 350'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S355', 19, 'Series 355'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S375', 20, 'Series 375'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'S395', 21, 'Series 395'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'L200', 22, 'Series L200'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'L225', 23, 'Series L225'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'O',    24, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'BB',   25, 'Additional Blue Book(s)'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'UNITS',26, 'Additional Units'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'License', 27, 'Additional License'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'UNK',  28, 'Ad (size unknown)'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'PRM',  29, 'Premium ad placement'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'FULL', 30, 'Full page ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'HALF', 31, 'Half page ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'THIRD',32, 'One third page ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'SIXTH',33, 'One sixth page ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'EB',   34, 'EB ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'LOGO', 35, 'LOGO'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'LP', 36, 'Listing Publicity'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'VB', 37, 'Vertical Banner'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'B', 38, 'Button'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'EBB', 39, 'Additional EBB(s)'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType', 'SPOT', 40, 'EBB Spotlight'



-- delete from custom_captions where capt_family='oppo_PRType_Mem'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'BASIC', 1, 'BASIC'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'STANDARD', 2, 'STANDARD'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'PREMIUM', 3, 'PREMIUM'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'ENTERPRISE', 4, 'ENTERPRISE'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S50',  10, 'Series 50'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S75',  11, 'Series 75'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S100', 12, 'Series 100'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S135', 13, 'Series 135'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S150', 14, 'Series 150'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S200', 15, 'Series 200'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S250', 16, 'Series 250'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S300', 17, 'Series 300'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S350', 18, 'Series 350'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S355', 19, 'Series 355'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S375', 20, 'Series 375'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'S395', 21, 'Series 395'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'L200', 22, 'Series L200'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'L225', 23, 'Series L225'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Mem', 'O',    24, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Upg', 'S100', 1, 'Series 100'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Upg', 'S150', 2, 'Series 150'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Upg', 'S200', 3, 'Series 200'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Upg', 'S250', 4, 'Series 250'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Upg', 'S300', 5, 'Series 300'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Upg', 'S350', 6, 'Series 350'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Upg', 'S355', 7, 'Series 355'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Upg', 'S375', 8, 'Series 375'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Upg', 'S395', 9, 'Series 395'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Upg', 'L225', 10, 'Series L225'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'UNK',  1, 'Ad (size unknown)'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'PRM',  2, 'Premium ad placement'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'FULL', 3, 'Full page ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_Bp', 'HALF', 4, 'Half page ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'THIRD',5, 'One third page ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'SIXTH',6, 'One sixth page ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'EB',   7, 'EB ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'LP',   10, 'Listing Publicity'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'VB',   11, 'Vertical Banner'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'B',    12, 'Button'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'Logo', 15, 'Logo'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRType_BP', 'O',    19, 'Other'


exec usp_TravantCRM_CreateDropdownValue 'oppo_PRCertainty', '0 - 25', 1, '0 - 25'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRCertainty', '26 - 50', 2, '26 - 50'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRCertainty', '51 - 75', 3, '51 - 75'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRCertainty', '76 - 100', 4, '76 - 100'

exec usp_TravantCRM_CreateDropdownValue 'oppo_Source', 'IB',  10, 'Inbound'
exec usp_TravantCRM_CreateDropdownValue 'oppo_Source', 'OB', 20, 'Outbound'

exec usp_TravantCRM_CreateDropdownValue 'oppo_SourceBP', 'AD',  1, 'BBSi initiated from ad in another publication'
exec usp_TravantCRM_CreateDropdownValue 'oppo_SourceBP', 'BP',  2, 'BBSi initiated based upon timing of BP content'
exec usp_TravantCRM_CreateDropdownValue 'oppo_SourceBP', 'PO',  3, 'BBSi initiated -- other'
exec usp_TravantCRM_CreateDropdownValue 'oppo_SourceBP', 'CEI', 4, 'Customer Experience Interest'
exec usp_TravantCRM_CreateDropdownValue 'oppo_SourceBP', 'NIB', 5, 'New in Blue'
exec usp_TravantCRM_CreateDropdownValue 'oppo_SourceBP', 'O',   6, 'Other'



exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:BPD'  , 1, 'Ad: B/P Directory'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:BPG'  , 3, 'Ad: B/P General'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:BPKYC', 4, 'Ad: B/P Know Your Commodity'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:BPNiB', 5, 'Ad: B/P New in Blue'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:BPSL' , 6, 'Ad: B/P Spotlight'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:BPS'  , 7, 'Ad: B/P Supplement'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:L'    , 9, 'Ad: Logo'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:OVB'  , 10, 'Ad: Online Vertical Banner'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:OB'   , 11, 'Ad: Online Button'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:OKYC' , 12, 'Ad: Online Know Your Commodity'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:In'  , 1, 'Ad: Inbound Sale'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:Trade' , 2, 'Ad: Tradeshow '
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'Ad:Up'  , 3, 'Ad: Upsell Outbound'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:BBOS' , 21, 'M: BBOS Inquiry'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:IS'   , 22, 'M: Inbound Sales'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:LNM'  , 23, 'M: Listed Non-M'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:MLP'  , 24, 'M: MLP'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:OL'	, 26, 'M: Online'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:OS'   , 27, 'M: Outbound Sales'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:PACA' , 28, 'M: PACA'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:RBCS' , 29, 'M: RBCS'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:TR'   , 30, 'M: Trade Reference'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:TS'   , 31, 'M: Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'M:UNM'  , 32, 'M: Unlisted Non-M'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'U:IS' , 33, 'Up: Inbound Sales'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'U:TS' , 34, 'Up: Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipeline', 'U:OB' , 35, 'Up: Outbound'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineAd', 'Ad:BPD'  , 1, 'Ad: B/P Directory'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineAd', 'Ad:BPG'  , 3, 'Ad: B/P General'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineAd', 'Ad:BPKYC', 4, 'Ad: B/P Know Your Commodity'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineAd', 'Ad:BPNiB', 5, 'Ad: B/P New in Blue'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineAd', 'Ad:BPSL' , 6, 'Ad: B/P Spotlight'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineAd', 'Ad:BPS'  , 7, 'Ad: B/P Supplement'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineAd', 'Ad:L'    , 9, 'Ad: Logo'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineAd', 'Ad:OVB'  , 10, 'Ad: Online Vertical Banner'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineAd', 'Ad:OB'   , 11, 'Ad: Online Button'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineAd', 'Ad:OKYC' , 12, 'Ad: Online Know Your Commodity'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:BBOS' , 21, 'M: BBOS Inquiry'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:IS'   , 22, 'M: Inbound Sales'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:LNM'  , 23, 'M: Listed Non-M'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:MLP'  , 24, 'M: MLP'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:OL'   , 26, 'M: Online'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:OS'   , 27, 'M: Outbound Sales'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:PACA' , 28, 'M: PACA'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:RBCS' , 29, 'M: RBCS'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:TR'   , 30, 'M: Trade Reference'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:TS'   , 31, 'M: Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineM', 'M:UNM'  , 32, 'M: Unlisted Non-M'

exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineU', 'U:IS' , 33, 'Up: Inbound Sales'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineU', 'U:TS' , 34, 'Up: Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRPipelineU', 'U:OB' , 35, 'Up: Outbound'


exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'BBAd', 1, 'Blue Book Ad'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'CM',   2, 'Current BBS Member'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'DM',   3, 'Direct Mail'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'FV',   4, 'Field Visit'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'PM',   5, 'Former BBS Member'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'IR',   6, 'Member Referral'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'ISC',  7, 'Inside/Field Sales Call'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'REF',  8, 'Internal Referral'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'NT',   9, 'National Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'RT',   10, 'Regional Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'IT',   11, 'Intl Trade Show'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'PIPE',   12, 'On a pipeline'
exec usp_TravantCRM_CreateDropdownValue 'oppo_PRTrigger', 'O',    13, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'peli_PRAUSChangePreference', '1', 1, 'Key'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRAUSChangePreference', '2', 2, 'All'

exec usp_TravantCRM_CreateDropdownValue 'peli_PRAUSReceiveMethod', '1', 1, 'Fax - End of Day'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRAUSReceiveMethod', '4', 2, 'Email - Immediately'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRAUSReceiveMethod', '2', 3, 'Email - End of Day'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRAUSReceiveMethod', '3', 4, 'View Online Only'

exec usp_TravantCRM_CreateDropdownValue 'prei_EmailTypeCode', '1', 1, 'Alerts'
exec usp_TravantCRM_CreateDropdownValue 'prei_EmailTypeCode', '2', 2, 'Invoice'
exec usp_TravantCRM_CreateDropdownValue 'prei_EmailTypeCode', '3', 3, 'TES'
exec usp_TravantCRM_CreateDropdownValue 'prei_EmailTypeCode', '4', 4, 'Surveys'

exec usp_TravantCRM_CreateDropdownValue 'prei_LocationCode', 'T', 1, 'Top of Email'
exec usp_TravantCRM_CreateDropdownValue 'prei_LocationCode', 'B', 2, 'Bottom of Email'

exec usp_TravantCRM_CreateDropdownValue 'prei_Industry', 'PTS', 1, 'Produce/Trans/Supply'
exec usp_TravantCRM_CreateDropdownValue 'prei_Industry', 'L', 2, 'Lumber'
exec usp_TravantCRM_CreateDropdownValue 'prei_Industry', 'B', 3, 'Both'

exec usp_TravantCRM_CreateDropdownValue 'pers_PRLanguageSpoken', 'E', 1, 'English'
exec usp_TravantCRM_CreateDropdownValue 'pers_PRLanguageSpoken', 'S', 2, 'Spanish'
exec usp_TravantCRM_CreateDropdownValue 'pers_PRLanguageSpoken', 'F', 3, 'French'
exec usp_TravantCRM_CreateDropdownValue 'pers_PRLanguageSpoken', 'G', 4, 'German'
exec usp_TravantCRM_CreateDropdownValue 'pers_PRLanguageSpoken', 'P', 5, 'Portuguese'
exec usp_TravantCRM_CreateDropdownValue 'pers_PRLanguageSpoken', 'O', 6, 'Other'

-- remove the accpac native Title codes from the list
Update Custom_Captions SET Capt_Deleted = 1
 where capt_familytype = 'Choices' and capt_family = 'pers_titlecode' and capt_Component is null
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'PROP',	 10, 'Proprietor'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'MM',		 20, 'Managing Member'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'CHR',		 30, 'Chairman'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'CEO',		 40, 'CEO'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'PRES',	 50, 'President'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'PAR',		 60, 'Partner'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'COO',		 70, 'COO'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'CFO',		 80, 'CFO'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'CTO',		 90, 'CTO'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'SVP',		100, 'Sr./Executive VP'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'VP',		110, 'Vice President'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'SEC',		120, 'Secretary'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'TRE',		130, 'Treasurer'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'SHR',		140, 'Shareholder'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'MEM',		150, 'Member'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'MDIR',	160, 'Managing Director'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'DIR',		170, 'Director'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'TRU',		180, 'Trustee'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'OWN',		190, 'Owner'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'GM',		200, 'General Manager'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'MGR',		210, 'Manager'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'OMGR',	220, 'Office Manager'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'SMGR',	230, 'Sales Manager'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'SALE',	240, 'Sales'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'CS',		250, 'Customer Service'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'BUY',		260, 'Buying & Sales'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'BRK',		270, 'Broker'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'BUYR',	280, 'Buyer'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'DIRO',	290, 'Director of Operations'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'OPER',	300, 'Operations'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'QC',		310, 'Quality Control'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'TRN',		320, 'Transportation'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'IT',		330, 'IT'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'DISP',	340, 'Dispatch'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'MRK',		350, 'Marketing'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'CTRL',	360, 'Controller'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'CRED',	370, 'Credit Manager'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'ACC',		380, 'Accounting'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'ADMIN',	390, 'Administration'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'FS',		395, 'Food Safety'         /*Populates the peli_PRTitleCode Field.*/
exec usp_TravantCRM_CreateDropdownValue 'pers_TitleCode', 'OTHR',	400, 'Other'         /*Populates the peli_PRTitleCode Field.*/


exec usp_TravantCRM_CreateDropdownValue 'peli_PRExitReason', 'D', 1, 'Deceased'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRExitReason', 'F', 2, 'Fired'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRExitReason', 'R', 3, 'Retired'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRExitReason', 'Q', 4, 'Quit'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRExitReason', 'O', 5, 'Other/Unknown'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRExitReason', 'T', 6, 'Transferred'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRExitReason', 'S', 7, 'Still With Company (Requested Removal From Contact List)'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'E', 1, 'Executive'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'K', 2, 'Marketing'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'S', 3, 'Sales'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'B', 4, 'Buying/Purchasing'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'C', 5, 'Credit'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'T', 6, 'Transportation/Dispatch'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'O', 7, 'Operations'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'F', 8, 'Finance'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'A', 9, 'Administration'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'M', 10, 'Manager'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'I', 11, 'IT'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'HE', 12, 'Head Executive'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'HM', 13, 'Head of Marketing'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'HS', 14, 'Head of Sales'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'HB', 15, 'Head of Buying'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'HC', 16, 'Head of Credit'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'HT', 17, 'Head of Transportation'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'HO', 18, 'Head of Operations'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'HF', 19, 'Head of Finance'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'HI', 20, 'Head of IT'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRole', 'FS', 21, 'Food Safety'
-- removing these from peli_PRRole to show in their own dropdown
exec usp_TravantCRM_CreateDropdownValue 'peli_PROwnershipRole', 'RCO', 21, 'Owner (Responsibly Connected)'
exec usp_TravantCRM_CreateDropdownValue 'peli_PROwnershipRole', 'RCN', 22, 'Non-owner (Responsibly Connected)'
exec usp_TravantCRM_CreateDropdownValue 'peli_PROwnershipRole', 'RCU', 23, 'Undisclosed (Responsibly Connected)'
exec usp_TravantCRM_CreateDropdownValue 'peli_PROwnershipRole', 'RCR', 24, 'None (Not Responsibly Connected)'
-- removing these from peli_PRRole to show in their own listing
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRecipientRole', 'RCVTES', 25, 'Receives TES Forms'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRecipientRole', 'RCVJEP', 26, 'Receives Jeopardy Letters'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRecipientRole', 'RCVBILL', 27, 'Billing Attention Line'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRRecipientRole', 'RCVLIST', 28, 'Listing Attention Line'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRStatus', '1', 1, 'Active'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRStatus', '2', 2, 'Inactive'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRStatus', '3', 3, 'No Longer Connected'
exec usp_TravantCRM_CreateDropdownValue 'peli_PRStatus', '4', 4, 'Removed by Company'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypeCompany', 'P', 1, 'Phone'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypeCompany', 'F', 2, 'FAX'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypeCompany', 'PF', 3, 'Phone or FAX'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypeCompany', 'PA', 4, 'Pager'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypeCompany', 'S', 5, 'Sales Phone'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypeCompany', 'SF', 6, 'Sales FAX'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypeCompany', 'TF', 7, 'Toll Free'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypeCompany', 'TP', 8, 'Trucker Phone'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypeCompany', 'C', 9, 'Cell'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypeCompany', 'EFAX', 10, 'E-FAX'

exec usp_TravantCRM_CreateDropdownValue 'Phon_TypePerson', 'C', 1, 'Cell'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypePerson', 'G', 2, 'Pager'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypePerson', 'R', 3, 'Residence'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypePerson', 'E', 4, 'Company Extension'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypePerson', 'P', 5, 'Direct Office Phone'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypePerson', 'F', 6, 'Direct Office FAX'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypePerson', 'O', 7, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'Phon_TypePerson', 'EFAX', 8, 'E-FAX'

exec usp_TravantCRM_CreateDropdownValue 'praa_AccountingSystem', '1', 1, 'Kpg (Kirkey)'
exec usp_TravantCRM_CreateDropdownValue 'praa_DateSelectionCriteria', 'DUE', 1, 'Due'
exec usp_TravantCRM_CreateDropdownValue 'praa_DateSelectionCriteria', 'INV', 2, 'Inv'
exec usp_TravantCRM_CreateDropdownValue 'praa_DateSelectionCriteria', 'SHP', 3, 'Shp'
exec usp_TravantCRM_CreateDropdownValue 'praa_DateSelectionCriteria', 'DIS', 4, 'Dis'
exec usp_TravantCRM_CreateDropdownValue 'praa_DateSelectionCriteria', 'PSTDUE', 1, 'Past Due'


exec usp_TravantCRM_CreateDropdownValue 'prat_Type', 'CO', 0, 'Country Of Origin'
exec usp_TravantCRM_CreateDropdownValue 'prat_Type', 'SO', 1, 'State Of Origin'
exec usp_TravantCRM_CreateDropdownValue 'prat_Type', 'SG', 2, 'Size Group'
exec usp_TravantCRM_CreateDropdownValue 'prat_Type', 'TR', 3, 'Treatment'
exec usp_TravantCRM_CreateDropdownValue 'prat_Type', 'GM', 4, 'Growing Method'
exec usp_TravantCRM_CreateDropdownValue 'prat_Type', 'ST', 5, 'Style'
exec usp_TravantCRM_CreateDropdownValue 'prbe_AcquisitionType', '1', 1, 'capital stock'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_AcquisitionType', '2', 2, 'certain assets'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_AcquisitionType', '3', 3, 'certain assets & certain liabilities'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_AcquisitionType', '4', 4, 'all assets'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_AcquisitionType', '5', 5, 'all assets and all liabilities'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_AcquisitionType', '6', 6, 'other'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_AgreementCategory', '1', 1, 'buy'
exec usp_TravantCRM_CreateDropdownValue 'prbe_AgreementCategory', '2', 2, 'sell'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessClosureType', '1', 1, '88'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessClosureType', '2', 2, '108'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessClosureType', '3', 3, '113'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessClosureType', '4', 4, 'inactive'         /*Used to populate prbe_DetailType*/

-- DELETE FROM Custom_captions WHERE Capt_Family = 'prbe_BusinessEventType'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '1', 10, 'acquisition'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '2', 20, 'agreement in principle'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '3', 30, 'Assignment for the benefit of creditors: (8)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '4', 40, 'bankruptcy events'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '42', 50, 'Commenced Operations'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '5', 60, 'U.S. Bankruptcy Filing (17, 18, 19)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '6', 70, 'Canadian Bankruptcy Filing'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '7', 80, 'Business closed: (88, 108, 113, Inactive)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '8', 90, 'Business entity change'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '9', 100, 'Business started: (87)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '10', 110, 'Ownership sale from one individual to another'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '11', 110, 'Divestiture/Sale of business/assets'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '12', 120, 'DRC Issue: (155-158)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '13', 130, 'Extension/Compromise (1, 2, 3, 4, 5, 7)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '14', 140, 'Financial Events'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '15', 150, 'Indictment (11)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '16', 160, 'Indictment Closed (12)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '17', 170, 'Injunctions'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '18', 180, 'Judgment: (13)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '19', 190, 'Letter of Intent'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '20', 200, 'Lien: (13)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '21', 210, 'Location Change'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '22', 220, 'Merger'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '23', 230, 'Natural Disaster: (105)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '24', 240, 'No longer handling fresh produce'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '40', 250, 'No longer handling lumber'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '25', 260, 'Other legal actions'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '26', 270, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '27', 280, 'Other PACA Event'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '28', 290, 'PACA License Suspended (152)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '29', 300, 'PACA License Reinstated (151)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '30', 310, 'PACA Trust Procedure'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '31', 320, 'Partnership Dissolution: (96)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '32', 330, 'Receivership applied for (14)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '33', 340, 'Receivership appointed (15)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '39', 350, 'Release from Bankruptcy'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '41', 360, 'Release from Canadian Reorganization'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '34', 370, 'SEC Actions'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '35', 380, 'Public Stock Event'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '36', 390, 'Treasury Stock'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '37', 400, 'TRO (Temporary Restraining Order): (6)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_BusinessEventType', '38', 410, 'Ownership Change (BBS Migration)'






exec usp_TravantCRM_CreateDropdownValue 'prbe_CanBankruptcyType', '1', 1, 'An assignment In bankruptcy made under the Bankruptcy and Insolvency Act'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_CanBankruptcyType', '2', 2, 'A notice Of intention to make a proposal under the Bankruptcy and Insolvency Act'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_CanBankruptcyType', '3', 3, 'A formal plan Of compromise Or arrangement under the companies Creditors Arrangement Act'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DisasterImpact', '1', 1, 'Loss'
exec usp_TravantCRM_CreateDropdownValue 'prbe_DisasterImpact', '2', 2, 'Business Interruption'
exec usp_TravantCRM_CreateDropdownValue 'prbe_DisasterImpact', '3', 3, 'Loss And Business Interruption'
exec usp_TravantCRM_CreateDropdownValue 'prbe_DisasterType', '1', 1, 'Fire'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DisasterType', '2', 2, 'Flood'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DisasterType', '3', 3, 'Tornado'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DisasterType', '4', 4, 'Hurricane'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DisasterType', '5', 5, 'Freeze'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DisasterType', '6', 6, 'Drought'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DisasterType', '7', 7, 'Other'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DRCType', '2', 2, '(156)'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DRCType', '3', 3, '(157)'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DRCType', '4', 4, '(158)'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_DRCType', '1', 1, '(155)'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_ExtensionType', '1', 1, '1'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_ExtensionType', '2', 2, '2'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_ExtensionType', '3', 3, '3'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_ExtensionType', '4', 4, '4'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_ExtensionType', '5', 5, '5'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_ExtensionType', '6', 6, '6'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_ExtensionType', '7', 7, '7'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_NewEntityType', '1', 1, 'C Corporation'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_NewEntityType', '2', 2, 'Sub Chapter S Corporation'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_NewEntityType', '3', 3, 'Corporation'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_NewEntityType', '4', 4, 'Limited Liability Company'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_NewEntityType', '5', 5, 'Partnership'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_NewEntityType', '6', 6, 'Limited Partnership'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_NewEntityType', '7', 7, 'Limited Liability Partnership'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_NewEntityType', '8', 8, 'Sole Proprietorship'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_NewEntityType', '9', 9, 'Cooperative'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_NewEntityType', '10', 10, 'Unlimited Liability Company'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_OtherPACAType', '1', 1, '(153)'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_OtherPACAType', '2', 2, 'Administrative Action'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_OtherPACAType', '3', 3, 'Bond Posted'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_OtherPACAType', '4', 4, 'Other'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_PACASuspensionType', '1', 1, 'No Barred Until Date'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_PACASuspensionType', '2', 2, 'Has Barred Until Date'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_SaleType', '1', 1, 'Capital Stock'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_SaleType', '2', 2, 'Ownership Interest'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_SaleType', '3', 3, 'Partnership Interest'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_SpecifiedCSNumeral', '1', 1, '17'
exec usp_TravantCRM_CreateDropdownValue 'prbe_SpecifiedCSNumeral', '2', 2, '18'
exec usp_TravantCRM_CreateDropdownValue 'prbe_SpecifiedCSNumeral', '3', 3, '19'
exec usp_TravantCRM_CreateDropdownValue 'prbe_StockEventType', 'O', 1, 'Public Offering'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_StockEventType', 'P', 2, 'Going Private'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_StockEventType', 'D', 3, 'Delisting'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_StockEventType', 'C', 4, 'Symbol Change Or Exchange Change'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '1', 1, 'Alabama Middle Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '2', 2, 'Alabama Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '3', 3, 'Alabama Southern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '4', 4, 'Alaska Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '5', 5, 'Arizona Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '6', 6, 'Arkansas Eastern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '7', 7, 'Arkansas Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '8', 8, 'California Central Bankruptcy - Los Angeles.  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '9', 9, 'California Central Bankruptcy - Northern Div.  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '10', 10, 'California Central Bankruptcy - Riverside  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '11', 11, 'California Central Bankruptcy - San Fernando Valley  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '12', 12, 'California Central Bankruptcy - Santa Ana  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '13', 13, 'California Eastern Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '14', 14, 'California Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '15', 15, 'California Southern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '16', 16, 'Colorado Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '17', 17, 'Connecticut Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '18', 18, 'Delaware Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '19', 19, 'District Of Columbia Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '20', 20, 'Florida Middle Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '21', 21, 'Florida Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '22', 22, 'Florida Southern Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '23', 23, 'Georgia Middle Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '24', 24, 'Georgia Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '25', 25, 'Georgia Southern Bankruptcy Court-Savannah  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '26', 26, 'Guam Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '27', 27, 'Hawaii Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '28', 28, 'Idaho Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '29', 29, 'Illinois Central Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '30', 30, 'Illinois Northern Bankruptcy - Chicago  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '31', 31, 'Illinois Southern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '32', 32, 'Indiana Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '33', 33, 'Indiana Southern Bankruptcy  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '34', 34, 'Iowa Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '35', 35, 'Iowa Southern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '36', 36, 'Kansas Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '37', 37, 'Kentucky Eastern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '38', 38, 'Kentucky Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '39', 39, 'Louisiana Eastern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '40', 40, 'Louisiana Middle Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '41', 41, 'Louisiana Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '42', 42, 'Maine Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '43', 43, 'Maryland Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '44', 44, 'Massachusetts Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '45', 45, 'Michigan Eastern Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '46', 46, 'Michigan Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '100', 50, 'Minnesota Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '47', 60, 'Mississippi Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '48', 70, 'Mississippi Southern Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '49', 80, 'Missouri Eastern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '50', 90, 'Missouri Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '51', 100, 'Montana Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '52', 110, 'Nebraska Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '53', 120, 'Nevada Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '54', 130, 'New Hampshire Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '55', 140, 'New Jersey Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '56', 150, 'New Mexico Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '57', 160, 'New York Eastern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '58', 170, 'New York Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '59', 180, 'New York Southern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '60', 190, 'New York Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '61', 200, 'North Carolina Eastern Bankruptcy  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '62', 210, 'North Carolina Middle Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '63', 220, 'North Carolina Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '64', 230, 'North Dakota Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '65', 240, 'Ohio Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '66', 250, 'Ohio Southern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '67', 260, 'Oklahoma Eastern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '68', 270, 'Oklahoma Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '69', 280, 'Oregon Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '70', 290, 'Pennsylvania Eastern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '71', 300, 'Pennsylvania Middle Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '72', 310, 'Pennsylvania Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '73', 320, 'Puerto Rico Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '74', 330, 'Rhode Island Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '75', 340, 'South Carolina Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '76', 350, 'South Dakota Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '77', 360, 'Tennessee Eastern Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '78', 370, 'Tennessee Middle Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '79', 380, 'Tennessee Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '80', 390, 'Texas Eastern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '81', 400, 'Texas Northern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '82', 410, 'Texas Southern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '83', 420, 'Texas Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '84', 430, 'Utah Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '85', 440, 'Vermont Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '86', 450, 'Virginia Eastern Bankruptcy  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '87', 460, 'Virginia Western Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '88', 470, 'Washington Eastern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '89', 480, 'Washington Western Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '90', 490, 'West Virginia Northern Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '91', 500, 'West Virginia Southern Bankruptcy Court  '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '92', 510, 'Wisconsin Eastern Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '93', 520, 'Wisconsin Western Bankruptcy Court '
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyCourt', '94', 530, 'Wyoming Bankruptcy Court'
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyEntity ', '1', 1, 'Business (Default)'
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyEntity ', '2', 2, 'Personal'
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyType', '1', 1, '7'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyType', '2', 2, '11'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyType', '3', 3, '12'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbe_USBankruptcyType', '4', 4, '13'         /*Used to populate prbe_DetailType*/
exec usp_TravantCRM_CreateDropdownValue 'prbt_Name', '1', 1, 'Acquisition'
exec usp_TravantCRM_CreateDropdownValue 'prbt_Name', '2', 2, 'Agreement In Principle'
exec usp_TravantCRM_CreateDropdownValue 'prbt_Name', '3', 3, 'Etc.'

-- Notice that these codes correspond to the prsuu_UsageType values
--
--DELETE FROM Custom_Captions WHERE capt_family = 'prbr_methodsent'
exec usp_TravantCRM_CreateDropdownValue 'prbr_MethodSent', 'VBR', 4, 'Verbal'
exec usp_TravantCRM_CreateDropdownValue 'prbr_MethodSent', 'OBR', 5, 'Online'

exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '0', 0, '0'
exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '1', 1, '1-4'
exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '10', 10, '3000+'
exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '2', 2, '5-9'
exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '3', 3, '10-19'
exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '4', 4, '20-49'
exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '5', 5, '50-99'
exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '6', 6, '100-249'
exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '7', 7, '250-499'
exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '8', 8, '500-999'
exec usp_TravantCRM_CreateDropdownValue 'prc2_StoreCount', '9', 9, '1000-2999'
exec usp_TravantCRM_CreateDropdownValue 'prc3_Brand', '1', 1, 'Dole'
exec usp_TravantCRM_CreateDropdownValue 'prc3_Brand', '2', 2, 'Chiquita'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '0', 0, 'Accpac'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '1', 1, 'Agware (Franwell Inc.)'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '10', 10, 'Oracle'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '11', 11, 'Peachtree'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '12', 12, 'Peoplesoft'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '13', 13, 'Propack (Integrated Knowledge Group)'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '14', 14, 'Prosun Produce System (Unisun)'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '15', 15, 'Produce Magic'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '16', 16, 'Produce Pro'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '17', 17, 'Prophet Software'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '18', 18, 'Quickbooks'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '19', 19, 'Simplified Software (Shipper Advantage, Broker Advantage, Distributor Advantage)'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '2', 2, 'Cancom'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '20', 20, 'Visual Produce (Silver Creek Software)'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '21', 21, 'Custom-Developed Software'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '3', 3, 'Datatech Software'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '4', 4, 'Dproduceman'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '5', 5, 'Edible Software (Solid Software Solutions)'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '6', 6, 'Famous Software'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '7', 7, 'Great Plains (Microsoft)'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '8', 8, 'Kirkey'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AccountingSoftware', '9', 9, 'Mas90'
exec usp_TravantCRM_CreateDropdownValue 'prc5_AmountSpent', '0', 0, '$0-$500'         /*prc5_BBAmountSpent, prc5_RBCSAmountSpent, prc5_DBAmountSpent, prc5_ExperianAmountSpent, prc5_CompunetAmountSpent*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_AmountSpent', '1', 1, '$501-$1000'         /*prc5_BBAmountSpent, prc5_RBCSAmountSpent, prc5_DBAmountSpent, prc5_ExperianAmountSpent, prc5_CompunetAmountSpent*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_AmountSpent', '2', 2, '$1001-$2500'         /*prc5_BBAmountSpent, prc5_RBCSAmountSpent, prc5_DBAmountSpent, prc5_ExperianAmountSpent, prc5_CompunetAmountSpent*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_AmountSpent', '3', 3, '$2501-$5000'         /*prc5_BBAmountSpent, prc5_RBCSAmountSpent, prc5_DBAmountSpent, prc5_ExperianAmountSpent, prc5_CompunetAmountSpent*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_AmountSpent', '4', 4, '$5001+'         /*prc5_BBAmountSpent, prc5_RBCSAmountSpent, prc5_DBAmountSpent, prc5_ExperianAmountSpent, prc5_CompunetAmountSpent*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_Approver', '0', 0, 'Credit Mgr./Dept.'         /*prc5_NewSaleCreditApprover, prc5_CreditIncreaseApprover, prc5_CreditCutoffApprover, prc5_NoPayApprover*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_Approver', '1', 1, 'Sales Mgr.'         /*prc5_NewSaleCreditApprover, prc5_CreditIncreaseApprover, prc5_CreditCutoffApprover, prc5_NoPayApprover*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_Approver', '2', 2, 'Sales Person'         /*prc5_NewSaleCreditApprover, prc5_CreditIncreaseApprover, prc5_CreditCutoffApprover, prc5_NoPayApprover*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_Approver', '3', 3, 'Owner/Principal'         /*prc5_NewSaleCreditApprover, prc5_CreditIncreaseApprover, prc5_CreditCutoffApprover, prc5_NoPayApprover*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_Approver', '4', 4, 'Other'         /*prc5_NewSaleCreditApprover, prc5_CreditIncreaseApprover, prc5_CreditCutoffApprover, prc5_NoPayApprover*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_BBServiceBenefits', '0', 0, 'Quality Of Ratings'
exec usp_TravantCRM_CreateDropdownValue 'prc5_BBServiceBenefits', '1', 1, 'EBB'
exec usp_TravantCRM_CreateDropdownValue 'prc5_BBServiceBenefits', '2', 2, 'Timeliness Of Updates (Cs)'
exec usp_TravantCRM_CreateDropdownValue 'prc5_BBServiceBenefits', '3', 3, 'Comprehensive Brs'
exec usp_TravantCRM_CreateDropdownValue 'prc5_BBServiceBenefits', '4', 4, 'T/A'
exec usp_TravantCRM_CreateDropdownValue 'prc5_BBServiceBenefits', '5', 5, 'Collection Assistance'
exec usp_TravantCRM_CreateDropdownValue 'prc5_BBServiceBenefits', '6', 6, 'Pocket Bb'
exec usp_TravantCRM_CreateDropdownValue 'prc5_BBServiceBenefits', '7', 7, 'Watchdog Capabilities'
exec usp_TravantCRM_CreateDropdownValue 'prc5_BBServiceBenefits', '8', 8, 'Quantity Of Reported Changes'
exec usp_TravantCRM_CreateDropdownValue 'prc5_BBServiceBenefits', '9', 9, 'Relationship'
exec usp_TravantCRM_CreateDropdownValue 'prc5_CompunetServiceBenefits', '0', 0, 'Quality Of Business Reports'
exec usp_TravantCRM_CreateDropdownValue 'prc5_CompunetServiceBenefits', '1', 1, 'Pricing'
exec usp_TravantCRM_CreateDropdownValue 'prc5_CompunetServiceBenefits', '2', 2, 'Transportation-Focused Services'
exec usp_TravantCRM_CreateDropdownValue 'prc5_CompunetServiceBenefits', '3', 3, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prc5_DBServiceBenefits', '0', 0, 'Predictive Credit Scores'
exec usp_TravantCRM_CreateDropdownValue 'prc5_DBServiceBenefits', '1', 1, 'Paydex #'
exec usp_TravantCRM_CreateDropdownValue 'prc5_DBServiceBenefits', '2', 2, 'Price'
exec usp_TravantCRM_CreateDropdownValue 'prc5_DBServiceBenefits', '3', 3, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prc5_ExperianServiceBenefits', '0', 0, 'Predictive Credit Scores'
exec usp_TravantCRM_CreateDropdownValue 'prc5_ExperianServiceBenefits', '1', 1, 'Commercial And Small Business Intelliscores'
exec usp_TravantCRM_CreateDropdownValue 'prc5_ExperianServiceBenefits', '2', 2, 'Price'
exec usp_TravantCRM_CreateDropdownValue 'prc5_ExperianServiceBenefits', '3', 3, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prc5_RankingUsage', '0', 0, 'First'         /*prc5_BBRankingUsage, prc5_RBCSRankingUsage, prc5_DBRankingUsage, prc5_ExperianRankingUsage, prc5_CompunetRankingUsage*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_RankingUsage', '1', 1, 'Second'         /*prc5_BBRankingUsage, prc5_RBCSRankingUsage, prc5_DBRankingUsage, prc5_ExperianRankingUsage, prc5_CompunetRankingUsage*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_RankingUsage', '2', 2, 'Third'         /*prc5_BBRankingUsage, prc5_RBCSRankingUsage, prc5_DBRankingUsage, prc5_ExperianRankingUsage, prc5_CompunetRankingUsage*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_RankingUsage', '3', 3, 'Fourth'         /*prc5_BBRankingUsage, prc5_RBCSRankingUsage, prc5_DBRankingUsage, prc5_ExperianRankingUsage, prc5_CompunetRankingUsage*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_RankingUsage', '4', 4, 'Fifth'         /*prc5_BBRankingUsage, prc5_RBCSRankingUsage, prc5_DBRankingUsage, prc5_ExperianRankingUsage, prc5_CompunetRankingUsage*/
exec usp_TravantCRM_CreateDropdownValue 'prc5_RBCSServiceBenefits', '0', 0, 'Picc'
exec usp_TravantCRM_CreateDropdownValue 'prc5_RBCSServiceBenefits', '1', 1, 'Online Services'
exec usp_TravantCRM_CreateDropdownValue 'prc5_RBCSServiceBenefits', '2', 2, 'Electronic Submissions Of Aging Reports'
exec usp_TravantCRM_CreateDropdownValue 'prc5_RBCSServiceBenefits', '3', 3, 'Business Reports'
exec usp_TravantCRM_CreateDropdownValue 'prc5_RBCSServiceBenefits', '4', 4, 'Quantity Of Listings'
exec usp_TravantCRM_CreateDropdownValue 'prc5_RBCSServiceBenefits', '5', 5, 'Price'
exec usp_TravantCRM_CreateDropdownValue 'prc5_RBCSServiceBenefits', '6', 6, 'Other Vance Publications'
exec usp_TravantCRM_CreateDropdownValue 'prc5_RBCSServiceBenefits', '7', 7, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'prcl_BookSection', '0', 1, '0 (For Produce)'
exec usp_TravantCRM_CreateDropdownValue 'prcl_BookSection', '1', 2, '1 (For Transportation)'
exec usp_TravantCRM_CreateDropdownValue 'prcl_BookSection', '2', 3, '2 (For Supply)'
exec usp_TravantCRM_CreateDropdownValue 'prcl_BookSection', '3', 3, '3 (For Lumber)'

/* prcn_ContinentCode */
exec usp_TravantCRM_CreateDropdownValue 'prcn_ContinentCode', 'NA', 1, 'North America'
exec usp_TravantCRM_CreateDropdownValue 'prcn_ContinentCode', 'SA', 2, 'South America'
exec usp_TravantCRM_CreateDropdownValue 'prcn_ContinentCode', 'EUR', 3, 'Europe'
exec usp_TravantCRM_CreateDropdownValue 'prcn_ContinentCode', 'ASIA', 4, 'Asia'
exec usp_TravantCRM_CreateDropdownValue 'prcn_ContinentCode', 'AF', 5, 'Africa'
exec usp_TravantCRM_CreateDropdownValue 'prcn_ContinentCode', 'AUS', 6, 'Austrailia'
exec usp_TravantCRM_CreateDropdownValue 'prcn_ContinentCode', 'ANT', 7, 'Antartica'

exec usp_TravantCRM_CreateDropdownValue 'prcp_ArrangesTransportWith', 'T', 1, 'Truck'
exec usp_TravantCRM_CreateDropdownValue 'prcp_ArrangesTransportWith', 'R', 1, 'Rail'
exec usp_TravantCRM_CreateDropdownValue 'prcp_ArrangesTransportWith', 'A', 1, 'Air'
exec usp_TravantCRM_CreateDropdownValue 'prcp_ArrangesTransportWith', 'OC', 1, 'Ocean Carrier'
exec usp_TravantCRM_CreateDropdownValue 'prcp_BkrReceive', '2', 2, 'Shipper'
exec usp_TravantCRM_CreateDropdownValue 'prcp_BkrReceive', '3', 3, 'Buyer'
exec usp_TravantCRM_CreateDropdownValue 'prcp_BkrReceive', '4', 4, 'Shipper and Buyer'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CorporateStructure', 'PROP', 1, 'Sole Proprietorship'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CorporateStructure', 'COOP', 2, 'Cooperative'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CorporateStructure', 'CORP', 3, 'Corporation'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CorporateStructure', 'LLC', 4, 'Limited Liability Company'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CorporateStructure', 'ULC', 5, 'Unlimited Liability Company'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CorporateStructure', 'LLP', 6, 'Limited Liability Partnership'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CorporateStructure', 'LPART', 7, 'Limited Partnership'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CorporateStructure', 'PART', 8, 'Partnership'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '0', 0, 'AFSII American Food Safety Institute (Chippewa Falls, WI)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '1', 1, 'Baystate Organic Certifiers (Winchendon, MA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '2', 2, 'Bio Latina -- U.S. Office (Washington, DC)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '3', 3, 'Canadian Organic Certification Cooperative Ltd. (Canada)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '4', 4, 'CCIA California Crop Improvement Association (Davis, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '5', 5, 'CCOF CCOF Certification Services (Santa Cruz, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '6', 6, 'Certified Organic, Inc. (Keosauqua, IA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '7', 7, 'COFA California Organic Farmers Association (Kerman, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '8', 8, 'Colorado Department of Agriculture (Lakewood, CO)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '9', 9, 'CSI Canadian Seed Institute (Canada)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '10', 10, 'D. Grosser and Associates, Ltd. -- U.S. Office of Consorzio Per II Controllo Dei Prodotti Biologici (New York, NY)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '11', 11, 'Fertilizer and Seed Certification Services (Pendleton, SC)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '12', 12, 'Global Culture (Crescent City, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '13', 13, 'Global Organic Alliance, Inc. (Bellefontaine, OH)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '14', 14, 'GOCA Guaranteed Organic Certification Agency (Fallbrook, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '15', 15, 'HOFA Hawaii Organic Farmers Association (Hilo, HI)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '16', 16, 'ICS International Certification Services, Inc. -- dba, Farm Verified Organic and ICS-US (Medina, ND)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '17', 17, 'Idaho State Department of Agriculture (Boise, ID)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '18', 18, 'Indiana Certified Organic (Clayton, IN)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '19', 19, 'Integrity Certified International (Bellevue, NE)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '20', 20, 'Iowa Department of Agriculture (Des Moines, IA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '21', 21, 'Louisiana Department of Agriculture and Forestry (Baton Rouge, LA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '22', 22, 'Marin County (Novato, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '23', 23, 'Maryland Department of Agriculture (Annapolis, MD)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '24', 24, 'MDAC Mississippi Department of Agriculture and Commerce (Jackson, MS)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '25', 25, 'Missouri Department of Agriculture (Jefferson City, MO)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '26', 26, 'MNCIA Minnesota Crop Improvement Association (St. Paul, MN)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '27', 27, 'MOFGA MOFGA Certification Services, LLC (Unity, ME)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '28', 28, 'Montana Department of Agriculture (Helena, MT)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '29', 29, 'Monterey County Certified Organic (Salinas, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '30', 30, 'MOSA Midwest Organic Services Association (Viroqua, WI)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '31', 31, 'MVOAI Maharishi Vedic Organic Agriculture Institute (Fairfield, IA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '32', 32, 'NATFCERT Natural Food Certifiers (Scarsdale, NY)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '33', 33, 'NCCIA North Carolina Crop Improvement Association (Raleigh, NC)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '34', 34, 'Nevada State Department of Agriculture (Reno, NV)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '35', 35, 'New Hampshire Dept. of Agriculture, Markets, & Food (Concord, NH)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '36', 36, 'New Mexico Organic Commodity Commission (Albuquerque, NM)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '37', 37, 'NOAFVT Vermont Organic Farmers, LLC (Richmond, VT)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '38', 38, 'NOFA -- New Jersey (Pennington, NJ)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '39', 39, 'NOFA -- New York, LLC (Binghamton, NY)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '40', 40, 'OCIA Organic Crop Improvement Association (Lincoln, NE)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '41', 41, 'OCPP OCPP/Pro-Cert Canada, Inc. (Canada)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '42', 42, 'ODA Oklahoma Department of Agriculture (Oklahoma City, OK)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '43', 43, 'OEFFA Ohio Ecological Food and Farm Administration (West Salem, OH)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '44', 44, 'OGM Organic Growers of Michigan (Grand Rapids, MI)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '45', 45, 'OPAM Organic Producers Association of Manitoba Cooperative, Inc. (Canada)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '46', 46, 'Oregon Tilth (Salem, OR)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '47', 47, 'Organic Certifiers, Inc. (Ventura, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '48', 48, 'Organic Forum International (Paynesville, MN)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '49', 49, 'Organic National and International Certifiers (Los Angeles, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '50', 50, 'Pennsylvania Certified Organic (Centre Hall, PA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '51', 51, 'QAI Quality Assurance International (San Diego, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '52', 52, 'QCS Quality Certification Services -- Formerly FOG (Gainesville, FL)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '53', 53, 'QMI QMI Organics, Inc. -- formerly QCB Organic, Inc. (Canada)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '54', 54, 'Rhode Island Department of Environmental Management (Providence, RI)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '55', 55, 'Saskatchewan Organic Certification Association, Inc. (Canada)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '56', 56, 'SCS Nutriclean -- Formerly Scientific Certification Systems (Emeryville, CA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '57', 57, 'Stellar Certification Services, Inc. (Junction City, OR)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '58', 58, 'Texas Department of Agriculture (Austin, TX)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '59', 59, 'Utah Department of Agriculture (Salt Lake City, Utah)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '60', 60, 'VDACS Virginia Department of Agriculture (Richmond, VA)'
exec usp_TravantCRM_CreateDropdownValue 'prcp_OrganicCertifiedBy', '61', 61, 'Washington State Department of Agriculture (Olympia, WA)'

exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypes', 'F', 1, 'Food Wholesalers' /* PRCompanyProfile */
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypes', 'G', 2, 'Retail Grocers'   /* PRCompanyProfile */
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypes', 'I', 3, 'Institutions'     /* PRCompanyProfile */
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypes', 'R', 4, 'Restaurants'      /* PRCompanyProfile */
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypes', 'M', 5, 'Military'         /* PRCompanyProfile */
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypes', 'D', 6, 'Distributors'     /* PRCompanyProfile */

exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypesL', 'Whole', 1, 'Wholesaler'
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypesL', 'SecMan', 2, 'Secondary Manuf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypesL', 'Imp', 3, 'Importer'
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypesL', 'CoOp', 4, 'Co-Op/Buyer Groups'
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypesL', 'Dist', 5, 'Distributor'
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypesL', 'LocYard', 6, 'Local Lumber Yards'
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypesL', 'Ret', 7, 'Retail'
exec usp_TravantCRM_CreateDropdownValue 'prcp_SellDomesticAccountTypesL', 'Other', 8, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageBushel', '1', 1, '1-49,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageBushel', '2', 2, '50,000-99,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageBushel', '3', 3, '100,000-249,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageBushel', '4', 4, '250,000-499,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageBushel', '5', 5, '500,000-749,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageBushel', '6', 6, '750,000-999,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageBushel', '7', 7, '1,000,000 or more'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCarlots', '1', 1, '1-24'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCarlots', '2', 2, '25-49'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCarlots', '3', 3, '50-74'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCarlots', '4', 4, '75-99'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCarlots', '5', 5, '100-199'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCarlots', '6', 6, '200-499'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCarlots', '7', 7, '500-999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCarlots', '8', 8, '1000 or more'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCF', '1', 1, '1-49,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCF', '2', 2, '50,000-99,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCF', '3', 3, '100,000-499,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCF', '4', 4, '500,000-999,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageCF', '5', 5, '1,000,000 or more'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageSF', '1', 1, '1-9,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageSF', '2', 2, '10,000-24,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageSF', '3', 3, '25,000-49,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageSF', '4', 4, '50,000-99,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageSF', '5', 5, '100,000-249,999'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageSF', '6', 6, '250,000 or more'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CollectsFrom', 'S', 1, 'Shipper'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CollectsFrom', 'R', 2, 'Receiver'
exec usp_TravantCRM_CreateDropdownValue 'prcp_CollectsFrom', 'B', 3, 'Both'
exec usp_TravantCRM_CreateDropdownValue 'TruckEquip', '1', 1, '1-5'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_TravantCRM_CreateDropdownValue 'TruckEquip', '2', 2, '6-10'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_TravantCRM_CreateDropdownValue 'TruckEquip', '3', 3, '11-24'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_TravantCRM_CreateDropdownValue 'TruckEquip', '4', 4, '25-49'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_TravantCRM_CreateDropdownValue 'TruckEquip', '5', 5, '50-99'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_TravantCRM_CreateDropdownValue 'TruckEquip', '6', 6, '100 or more'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/

exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '01', 1, '5'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '02', 2, '10'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '03', 3, '15'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '04', 4, '20'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '05', 5, '25'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '06', 6, '40'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '07', 7, '50'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '08', 8, '75'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '09', 9, '100'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '10', 10, '150'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '11', 11, '200'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '12', 12, '250'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '13', 13, '300'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '14', 14, '350'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '15', 15, '400'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '16', 16, '500'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '17', 17, '600'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '18', 18, '700'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '19', 19, '750'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '20', 20, '800'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '21', 21, '900'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '22', 22, '1000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '23', 23, '1250'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '24', 24, '1500'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '25', 25, '1750'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '26', 26, '2000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '27', 27, '2500'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '28', 28, '3000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '29', 29, '4000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '30', 30, '5000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '31', 31, '6000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '32', 32, '7000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '33', 33, '8000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '34', 34, '10000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '35', 35, '15000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '36', 36, '20000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '37', 37, '30000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '38', 38, '40000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '39', 39, '50000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '40', 40, '65000'
exec usp_TravantCRM_CreateDropdownValue 'prcp_Volume', '50', 50, '100000+'


exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '1', 1, 'Less than 1 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '2', 2, '1 - 10 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '3', 3, '11 - 25 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '4', 4, '26 - 50 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '5', 5, '51 - 100 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '6', 6, '101 - 200 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '7', 7, '201 - 300 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '8', 8, '301 - 400 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '9', 9, '401 - 500 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '10', 10, '501 - 600 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '11', 11, '601 - 700 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '12', 12, '701 - 800 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '13', 13, '801 - 900 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '14', 14, '901 - 999 mmbf'
exec usp_TravantCRM_CreateDropdownValue 'prcp_VolumeL', '15', 15, '1 billion bf +'


exec usp_TravantCRM_CreateDropdownValue 'prcr_OwnershipDescription ', '1', 1, 'Parent'
exec usp_TravantCRM_CreateDropdownValue 'prcr_OwnershipDescription ', '2', 2, 'Owner'
exec usp_TravantCRM_CreateDropdownValue 'prcr_OwnershipDescription ', '3', 3, 'Partner'
exec usp_TravantCRM_CreateDropdownValue 'prcr_OwnershipDescription ', '4', 4, 'Limited Partner'
exec usp_TravantCRM_CreateDropdownValue 'prcr_OwnershipDescription ', '5', 5, 'Managing Partner'
exec usp_TravantCRM_CreateDropdownValue 'prcr_OwnershipDescription ', '6', 6, 'General Partner'
exec usp_TravantCRM_CreateDropdownValue 'prcr_Source', 'A', 4, 'A/R Aging'
exec usp_TravantCRM_CreateDropdownValue 'prcr_Source', 'TR', 4, 'Trading Assistance'
exec usp_TravantCRM_CreateDropdownValue 'prcr_Source', 'C', 0, 'Reference List'
exec usp_TravantCRM_CreateDropdownValue 'prcr_Source', 'T', 1, 'Trade Experience Survey'
exec usp_TravantCRM_CreateDropdownValue 'prcr_Source', 'P', 2, 'Phone'
exec usp_TravantCRM_CreateDropdownValue 'prcr_Source', 'E', 3, 'Email'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TransactionFrequency', 'W', 0, 'Weekly'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TransactionFrequency', 'M', 1, 'Monthly'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TransactionFrequency', 'S', 2, 'Seasonally'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TransactionVolume', 'H', 0, 'High'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TransactionVolume', 'M', 1, 'Medium'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TransactionVolume', 'L', 2, 'Low'
exec usp_TravantCRM_CreateDropdownValue 'prcs_Status', 'N', 1, 'New'
exec usp_TravantCRM_CreateDropdownValue 'prcs_Status', 'M', 2, 'Modified'
exec usp_TravantCRM_CreateDropdownValue 'prcs_Status', 'A', 3, 'Approved'
exec usp_TravantCRM_CreateDropdownValue 'prcs_Status', 'D', 4, 'Do Not Publish'
exec usp_TravantCRM_CreateDropdownValue 'prcs_Status', 'P', 5, 'Publishable'
exec usp_TravantCRM_CreateDropdownValue 'prcs_Status', 'K', 6, 'Killed'
exec usp_TravantCRM_CreateDropdownValue 'prcs_SourceType', 'TX', 1, 'Transaction'
exec usp_TravantCRM_CreateDropdownValue 'prcs_SourceType', 'PE', 2, 'Person Event'
exec usp_TravantCRM_CreateDropdownValue 'prcs_SourceType', 'BE', 3, 'Business Event'

exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageOwnLease', 'O', 1, 'Own'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageOwnLease', 'L', 2, 'Lease'
exec usp_TravantCRM_CreateDropdownValue 'prcp_StorageOwnLease', 'B', 3, 'Both'

-- Add PRCreditWorthRating values
-- DELETE FROM Custom_Captions WHERE capt_family = 'prcw_Name'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '(62)', 1, 'Financial information makes it difficult to assign definite credit worth rating - trade practices rating supported by trade reports.', NULL, NULL, NULL, 'La información financiera hace dificil asignar una evaluación de crédito definitiva.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '(68)', 2, 'Financial information submitted, but trade reports prohibit assignment of credit worth rating.', NULL, NULL, NULL, 'Información financiera entregada, los reportes de la industria prohiben una evaluación.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '(78)', 3, 'Financial position under review.', NULL, NULL, NULL, 'Posición financiera bajo revisión.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '(79)', 4, 'Financial Credit Worth rating withdrawn - financial information no longer current.', NULL, NULL, NULL, 'Evaluación financiera suspendida - información financiera no actualizada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '(142)', 5, 'Major portion of net worth represented by intangible assets and/or amounts owing from principals or affiliates.', NULL, NULL, NULL, 'Cuentas por cobrar u otros activos de la matriz y/o afiliada son la porción mayor del capital contable.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '(143)', 6, 'Major portion of net worth represented by fixed assets.', NULL, NULL, NULL, 'Mayor porcentaje de activo neto representado por activo fijo.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '(144)', 7, 'Specific credit worth rating not assigned.', NULL, NULL, NULL, 'Evaluación de crédito específica no asignada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '(145)', 8, 'Latest financial figures reflect a negative working capital and/or a negative net worth position.', NULL, NULL, NULL, 'Las cifras financieras reflejan un capital circulante negativo y/o un capital contable negativo.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '(150)', 9, 'Financial statement this subsidiary not made available. Parent company provides consolidated financial figures including subsidiaries.', NULL, NULL, NULL, 'Estado financiero de filial no fue proporcionado.  La sociedad matriz proporciona las cifras financieras.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '(154)', 10, 'Credit worth reported uncertain.', NULL, NULL, NULL, 'Solvencia reportada incierta.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '-M', 11, 'Credit worth estimated less than $1,000', NULL, NULL, NULL, 'Solvencia estimada en menos de $1,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '5M', 12, '$5,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $5,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '10M', 13, '$10,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $10,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '15M', 14, '$15,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $15,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '20M', 15, '$20,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $20,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '25M', 16, '$25,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $25,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '40M', 17, '$40,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $40,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '50M', 18, '$50,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $50,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '75M', 19, '$75,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $75,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '100M', 20, '$100,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $100,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '150M', 21, '$150,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $150,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '200M', 22, '$200,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $200,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '250M', 23, '$250,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $250,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '300M', 24, '$300,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $300,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '400M', 25, '$400,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $400,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '500M', 26, '$500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '750M', 27, '$750,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $750,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '1000M', 28, '$1,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $1,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '1500M', 29, '$1,500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $1,500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '2000M', 30, '$2,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $2,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '2500M', 31, '$2,500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $2,500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '3000M', 32, '$3,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $3,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '4000M', 33, '$4,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $4,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '5000M', 34, '$5,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $5,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '7500M', 35, '$7,500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $7,500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '10,000M', 36, '$10,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $10,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '15,000M', 37, '$15,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $15,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '20,000M', 38, '$20,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $20,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '25,000M', 39, '$25,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $25,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '30,000M', 40, '$30,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $30,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '40,000M', 41, '$40,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $40,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '50,000M', 42, '$50,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $50,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '75,000M', 43, '$75,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $75,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '100,000M', 44, '$100,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $100,000,000', NULL, NULL, 'PRDropdownValues'
EXEC usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '250,000M', 45, '$250,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $250,000,000', NULL, NULL, 'PRDropdownValues'
EXEC usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '500,000M', 46, '$500,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $500,000,000', NULL, NULL, 'PRDropdownValues'

/*
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '5M', 12, '$5,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $5,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '10M', 13, '$10,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $10,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '15M', 14, '$15,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $15,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '20M', 15, '$20,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $20,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '25M', 16, '$25,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $25,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '40M', 17, '$40,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $40,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '50M', 18, '$50,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $50,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '75M', 19, '$75,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $75,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '100M', 20, '$100,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $100,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '150M', 21, '$150,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $150,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '200M', 22, '$200,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $200,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '250M', 23, '$250,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $250,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '300M', 24, '$300,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $300,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '400M', 25, '$400,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $400,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '500M', 26, '$500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '750M', 27, '$750,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $750,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '1000M', 28, '$1,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $1,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '1500M', 29, '$1,500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $1,500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '2000M', 30, '$2,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $2,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '2500M', 31, '$2,500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $2,500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '3000M', 32, '$3,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $3,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '4000M', 33, '$4,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $4,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '5000M', 34, '$5,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $5,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '7500M', 35, '$7,500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $7,500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '10,000M', 36, '$10,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $10,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '15,000M', 37, '$15,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $15,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '20,000M', 38, '$20,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $20,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '25,000M', 39, '$25,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $25,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '30,000M', 40, '$30,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $30,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '40,000M', 41, '$40,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $40,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '50,000M', 42, '$50,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $50,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '75,000M', 43, '$75,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $50,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '100,000M', 44, '$100,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $50,000,000', NULL, NULL, 'PRDropdownValues'
*/

exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '5K', 12, '$5,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $5,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '10K', 13, '$10,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $10,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '15K', 14, '$15,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $15,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '20K', 15, '$20,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $20,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '25K', 16, '$25,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $25,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '40K', 17, '$40,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $40,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '50K', 18, '$50,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $50,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '75K', 19, '$75,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $75,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '100K', 20, '$100,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $100,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '150K', 21, '$150,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $150,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '200K', 22, '$200,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $200,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '250K', 23, '$250,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $250,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '300K', 24, '$300,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $300,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '400K', 25, '$400,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $400,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '500K', 26, '$500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '750K', 27, '$750,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $750,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '1000K', 28, '$1,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $1,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '1500K', 29, '$1,500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $1,500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '2000K', 30, '$2,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $2,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '2500K', 31, '$2,500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $2,500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '3000K', 32, '$3,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $3,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '4000K', 33, '$4,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $4,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '5000K', 34, '$5,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $5,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '7500K', 35, '$7,500,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $7,500,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '10,000K', 36, '$10,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $10,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '15,000K', 37, '$15,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $15,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '20,000K', 38, '$20,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $20,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '25,000K', 39, '$25,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $25,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '30,000K', 40, '$30,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $30,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '40,000K', 41, '$40,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $40,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '50,000K', 42, '$50,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $50,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '75,000K', 43, '$75,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $50,000,000', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '100,000K', 44, '$100,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $50,000,000', NULL, NULL, 'PRDropdownValues'
EXEC usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '250,000K', 44, '$250,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $250,000,000', NULL, NULL, 'PRDropdownValues'
EXEC usp_TravantCRM_AddCustom_Captions 'Choices', 'prcw_Name', '500,000K', 44, '$500,000,000 estimated credit worth', NULL, NULL, NULL, 'Solvencia estimada en $500,000,000', NULL, NULL, 'PRDropdownValues'



exec usp_TravantCRM_CreateDropdownValue 'prcw_Order', '1', 1, '1'
exec usp_TravantCRM_CreateDropdownValue 'prcw_Order', '2', 2, '2'
exec usp_TravantCRM_CreateDropdownValue 'prcw_Order', '3', 3, '3'
exec usp_TravantCRM_CreateDropdownValue 'prcw_Order', '4', 4, '4'
exec usp_TravantCRM_CreateDropdownValue 'prcw_Order', '5', 5, '5'
exec usp_TravantCRM_CreateDropdownValue 'prcw_Order', '6', 6, '6'
exec usp_TravantCRM_CreateDropdownValue 'prcw_Order', '7', 7, '7'
exec usp_TravantCRM_CreateDropdownValue 'prdr_BusinessType', '1', 1, 'Wholesaler'
exec usp_TravantCRM_CreateDropdownValue 'prdr_BusinessType', '2', 2, 'Grower/Shipper'
exec usp_TravantCRM_CreateDropdownValue 'prdr_LicenseStatus', '1', 1, 'A'
exec usp_TravantCRM_CreateDropdownValue 'prdr_LicenseStatus', '2', 2, 'E'
exec usp_TravantCRM_CreateDropdownValue 'prdr_Salutation', '1', 1, 'Mr.'
exec usp_TravantCRM_CreateDropdownValue 'prdr_Salutation', '2', 2, 'M.'
exec usp_TravantCRM_CreateDropdownValue 'prdr_Salutation', '3', 3, 'Ms.'
exec usp_TravantCRM_CreateDropdownValue 'prdr_Salutation', '4', 4, 'Mme.'
exec usp_TravantCRM_CreateDropdownValue 'prdr_Salutation', '5', 5, 'Sr.'
exec usp_TravantCRM_CreateDropdownValue 'prdr_Salutation', '6', 6, 'Sra.'
exec usp_TravantCRM_CreateDropdownValue 'preq_Status', 'O', 1, 'Open'
exec usp_TravantCRM_CreateDropdownValue 'preq_Status', 'C', 2, 'Closed'
exec usp_TravantCRM_CreateDropdownValue 'preq_Type', 'TES', 1, 'TES'
exec usp_TravantCRM_CreateDropdownValue 'preq_Type', 'AR', 2, 'AR'
exec usp_TravantCRM_CreateDropdownValue 'preq_Type', 'BBScore', 3, 'Bluebook Score'
exec usp_TravantCRM_CreateDropdownValue 'preq_Type_SearchOption', 'TESAR', 1, 'TES + AR'
exec usp_TravantCRM_CreateDropdownValue 'preq_Type_SearchOption', 'TES', 2, 'TES'
exec usp_TravantCRM_CreateDropdownValue 'preq_Type_SearchOption', 'AR', 3, 'AR'
exec usp_TravantCRM_CreateDropdownValue 'preq_Type_SearchOption', 'BBScore', 4, 'BB Score'

exec usp_TravantCRM_CreateDropdownValue 'prfi_AwardClaimantPayer', '1', 1, 'Respondent #1'
exec usp_TravantCRM_CreateDropdownValue 'prfi_AwardClaimantPayer', '2', 2, 'Repondent #2'
exec usp_TravantCRM_CreateDropdownValue 'prfi_AwardRespondentPayer', '1', 1, 'Claimant'
exec usp_TravantCRM_CreateDropdownValue 'prfi_AwardRespondentPayer', '2', 2, 'Respondent #1'
exec usp_TravantCRM_CreateDropdownValue 'prfi_AwardRespondentPayer', '3', 3, 'Repondent #2'
exec usp_TravantCRM_CreateDropdownValue 'prfi_CollectionSubCategory', '1', 1, 'Not contested by debtor'
exec usp_TravantCRM_CreateDropdownValue 'prfi_CollectionSubCategory', '2', 2, 'Contested by debtor'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Company1Role', '1', 1, 'Creditor'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Company1Role', '2', 2, 'Debtor'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Company1Role', '3', 3, 'Claimant'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Company1Role', '4', 4, 'Respondent'
exec usp_TravantCRM_CreateDropdownValue 'prfi_CurrencyType', '1', 1, 'Us Dollars'
exec usp_TravantCRM_CreateDropdownValue 'prfi_CurrencyType', '2', 2, 'Canadian Dollars'
exec usp_TravantCRM_CreateDropdownValue 'prfi_CurrencyType', '3', 3, 'Pesos'
exec usp_TravantCRM_CreateDropdownValue 'prfi_CurrencyType', '4', 4, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prfi_CreditorCollectedReason', 'PF', 1, 'Paid In Full'
exec usp_TravantCRM_CreateDropdownValue 'prfi_CreditorCollectedReason', 'PC', 2, 'Partially Collected'
exec usp_TravantCRM_CreateDropdownValue 'prfi_CreditorCollectedReason', 'C', 3, 'Creditor Mistake/Error'
exec usp_TravantCRM_CreateDropdownValue 'prfi_CreditorCollectedReason', 'O', 4, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prfi_DocArbitratorShipMethod', '1', 1, 'Fedex (Default)'
exec usp_TravantCRM_CreateDropdownValue 'prfi_DocArbitratorShipMethod', '2', 2, 'UPS'
exec usp_TravantCRM_CreateDropdownValue 'prfi_DocArbitratorShipMethod', '3', 3, 'DHL'
exec usp_TravantCRM_CreateDropdownValue 'prfi_DocArbitratorShipMethod', '4', 4, 'Global Priority'
exec usp_TravantCRM_CreateDropdownValue 'prfi_DocArbitratorShipMethod', '5', 5, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prfi_DRCArbitrationType', '1', 1, 'Expedited'
exec usp_TravantCRM_CreateDropdownValue 'prfi_DRCArbitrationType', '2', 2, 'Formal'
exec usp_TravantCRM_CreateDropdownValue 'prfi_DRCArbitrationType', '3', 3, 'Hybrid'
exec usp_TravantCRM_CreateDropdownValue 'prfi_IssueCategory', '1', 1, 'Dispute (Default)'
exec usp_TravantCRM_CreateDropdownValue 'prfi_IssueCategory', '2', 2, 'Non-Payment'
exec usp_TravantCRM_CreateDropdownValue 'prfi_IssueCategory', '3', 3, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Language', '1', 1, 'English (Default)'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Language', '2', 2, 'Spanish Or French'
exec usp_TravantCRM_CreateDropdownValue 'prfi_PaperworkLocation', '1', 1, 'All In System'
exec usp_TravantCRM_CreateDropdownValue 'prfi_PaperworkLocation', '2', 2, 'In Folder'
exec usp_TravantCRM_CreateDropdownValue 'prfi_PaperworkLocation', '3', 3, 'In Suspense'
exec usp_TravantCRM_CreateDropdownValue 'prfi_PLANPartnerUsed', '1', 1, 'American Financial Management'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Subtype', '1', 1, 'M File'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Subtype', '2', 2, 'Opinion Letter'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Subtype', '3', 3, 'Dispute'

exec usp_TravantCRM_CreateDropdownValue 'prfi_Topic', '1', 1, 'Transportation Issue'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Topic', '2', 2, 'Commodity Info'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Topic', '3', 3, 'USDA Inspection Interpretation'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Topic', '4', 4, 'CFIA Inspection Interpretation'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Topic', '5', 5, 'Other Inspection Interpretation'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Topic', '6', 6, 'USDA Interpretation'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Topic', '7', 7, 'Pay Issue'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Topic', '8', 8, 'Contractual Disagreement'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Topic', '9', 9, 'Other Produce Issue/Advice'

exec usp_TravantCRM_CreateDropdownValue 'prfi_Type', 'C', 2, 'Claim'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Type', 'A', 3, 'Advice'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Type', 'M', 4, 'Misc.'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Type', 'O', 4, 'Opinion'
exec usp_TravantCRM_CreateDropdownValue 'prfi_Type', 'D', 4, 'Dispute'

-- These are the ids used for Migration only
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReason', '1', 1, 'Pending (BBS Migration)'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReason', '2', 2, 'Re-opened (BBS Migration)'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReason', '3', 3, 'Collected (in part), referred out (BBS Migration)'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReason', '4', 4, 'Invoiced (BBS Migration)'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReason', '5', 5, 'Not billable (BBS Migration)'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReason', '6', 6, 'Uncollected/unsettled (BBS Migration)'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReason', '7', 7, 'Settled (BBS Migration)'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReason', '8', 8, 'Uncollected, referred out (BBS Migration)'
-- Closing reasons for a claim file.Withdrawn
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonMisc',  'AQ ',  1, 'Answered Question'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonMisc',  'R',    2, 'Resolved'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonMisc',  'W',    3, 'Withdrawn'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonMisc',  'SA',   4, 'Didn''t Sign Authorization'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonMisc',  'O',    5, 'Other'
-- Closing reasons for a claim file.
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'PC',  1, 'BBSi Collected'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'MC',  2, 'Mistake by Creditor'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'CT',  3, 'Went to Court'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'PA',  4, 'Went to PACA'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'CP',  5, 'Creditor Collected Partial / Closed on own'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'CC',  6, 'Creditor Collected in Full on own'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'RP',  7, 'Referred Elsewhere - PACA'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'RD',  8, 'Referred Elsewhere - DRC'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'RA',  9, 'Referred Elsewhere - Attorney'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'RC', 10, 'Referred Elsewhere - Collections'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'RS', 11, 'Referred Elsewhere - Sales'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'NR', 12, 'No Response From Either Party'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', '56', 13, '56/57 Reported'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'PI', 14, 'Impasse - Pursue via outside forum'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'IR', 15, 'Impasse - Refusal to cooperate'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'IL', 16, 'Impasse - Legal considerations'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'PW', 17, 'Parties Resolved w/out BBSi'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'PP', 18, 'Parties Resolved with BBSi'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'W',  19, 'Withdrawn'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'SA', 20, 'Didn''t Sign Authorization'
exec usp_TravantCRM_CreateDropdownValue 'prfi_ClosingReasonClaim', 'O',  21, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySource', 'P', 1, 'Phone'
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySource', 'F', 2, 'Fax'
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySource', 'M', 3, 'Mail'
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySource', 'E', 4, 'E-Mail'
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySource', 'W', 5, 'Web'
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySource', 'O', 5, 'Other'
-- these values are used by prfi_InquirySource for collection files
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySourceCollection', 'AD', 1, 'BBSi Advertisement'
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySourceCollection', 'PROMO', 2, 'BBSi Direct Mail Promo'
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySourceCollection', 'PAST', 3, 'Used Collections in Past'
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySourceCollection', 'BB', 4, 'Referred by BB Member'
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySourceCollection', 'PACA', 5, 'Referred by PACA'
exec usp_TravantCRM_CreateDropdownValue 'prfi_InquirySourceCollection', 'O', 6, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'prfs_Currency', '1', 1, 'US Dollars'
exec usp_TravantCRM_CreateDropdownValue 'prfs_Currency', '2', 2, 'Canadian Dollars'
exec usp_TravantCRM_CreateDropdownValue 'prfs_Currency', '3', 3, 'Pesos'
exec usp_TravantCRM_CreateDropdownValue 'prfs_Currency', '4', 4, 'British Pounds'
exec usp_TravantCRM_CreateDropdownValue 'prfs_Currency', '5', 5, 'Euros'
exec usp_TravantCRM_CreateDropdownValue 'prfs_Currency', '6', 6, 'Hong Kong Dollars'
exec usp_TravantCRM_CreateDropdownValue 'prfs_Currency', '7', 7, 'Japanesse Yen'
exec usp_TravantCRM_CreateDropdownValue 'prfs_Currency', '8', 8, 'Australia Dollars'
exec usp_TravantCRM_CreateDropdownValue 'prfs_Currency', '9', 9, 'New Zealand Dollars'


exec usp_TravantCRM_CreateDropdownValue 'prfs_EntryStatus', 'N', 1, 'None'
exec usp_TravantCRM_CreateDropdownValue 'prfs_EntryStatus', 'P', 2, 'Partial'
exec usp_TravantCRM_CreateDropdownValue 'prfs_EntryStatus', 'F', 3, 'Full'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '1', 1, '1 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '2', 2, '2 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '3', 3, '3 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '4', 4, '4 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '5', 5, '5 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '6', 6, '6 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '7', 7, '7 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '8', 8, '8 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '9', 9, '9 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '10', 10, '10 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_InterimMonth', '11', 11, '11 Month'
exec usp_TravantCRM_CreateDropdownValue 'prfs_PreparationMethod', 'I', 1, 'Internally Prepared'
exec usp_TravantCRM_CreateDropdownValue 'prfs_PreparationMethod', 'A', 2, 'Accountant Audited'
exec usp_TravantCRM_CreateDropdownValue 'prfs_PreparationMethod', 'R', 3, 'Accountant Reviewed'
exec usp_TravantCRM_CreateDropdownValue 'prfs_PreparationMethod', 'C', 4, 'Accountant Compilation'
exec usp_TravantCRM_CreateDropdownValue 'prfs_PreparationMethod', 'S', 5, 'SEC Filing'
exec usp_TravantCRM_CreateDropdownValue 'prfs_PreparationMethod', 'T', 6, 'Income Tax Return'
exec usp_TravantCRM_CreateDropdownValue 'prfs_Type', 'Y', 1, 'Year-End'
exec usp_TravantCRM_CreateDropdownValue 'prfs_Type', 'I', 2, 'Interim'

-- Add PRIntegrityRating values
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prin_Name', 'X', 1, 'Poor', NULL, NULL, NULL, 'Malo', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prin_Name', 'XX', 2, 'Unsatisfactory', NULL, NULL, NULL, 'Mediocre', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prin_Name', 'XX147', 3, 'Have conflicting reports - some report better than XX experience.', NULL, NULL, NULL, 'Menos que satisfactor, pero algunos reportan mejor', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prin_Name', 'XXX148', 4, 'Have conflicting reports - some report less than XXX experience.', NULL, NULL, NULL, 'Bueno, pero algunos reportan mejor', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prin_Name', 'XXX', 5, 'Good', NULL, NULL, NULL, 'Bueno', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prin_Name', 'XXXX', 6, 'Excellent', NULL, NULL, NULL, 'Excelente', NULL, NULL, 'PRDropdownValues'

exec usp_TravantCRM_CreateDropdownValue 'pril_LicenseStatus', '1', 1, 'A'
exec usp_TravantCRM_CreateDropdownValue 'pril_LicenseStatus', '2', 2, 'E'
exec usp_TravantCRM_CreateDropdownValue 'prli_Type', 'MC', 1, 'MC'
exec usp_TravantCRM_CreateDropdownValue 'prli_Type', 'FF', 2, 'FF'
exec usp_TravantCRM_CreateDropdownValue 'prli_Type', 'CFIA', 3, 'CFIA License'
exec usp_TravantCRM_CreateDropdownValue 'prli_Type', 'DOT', 4, 'DOT'
exec usp_TravantCRM_CreateDropdownValue 'prli_Type', 'PACA', 5, 'PACA License'

-- PACA License
exec usp_TravantCRM_CreateDropdownValue 'prpa_LicenseStatus', 'A', 1, 'Active'
exec usp_TravantCRM_CreateDropdownValue 'prpa_LicenseStatus', 'E', 2, 'Expired'

--DELETE FROM Custom_captions WHERE Capt_Family = 'prpa_TerminateCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '1', 1, '1 - Active'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '4', 4, '4 - Active With Bond'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '5', 5, '5 - Early Termination'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '7', 7, '7 - Early Termination-New Entity'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '10', 10, '10 - Terminated-No Response'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '11', 11, '11 - Succeeded'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '12', 12, '12 - Terminated-OOB'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '13', 13, '13 - Temporary Out Of Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '14', 14, '14 - Revoked'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '15', 15, '15 - Terminated- R&F'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '16', 16, '16 - Bankrupt'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '17', 17, '17 - License Cancelled'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '18', 18, '18 - Active With Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '19', 19, '19 - Suspension With Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '20', 20, '20 - Terminated-No Longer Subject'
exec usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '23', 23, '23 - Revocation with Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '30', 30, '30 - Administrative License Suspension'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '33', 33, '33 - Suspended-Unpaid Award(s)'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '34', 34, '34 - Terminated-Unpaid Award(s)'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '40', 40, '40 - Terminated Reatiler'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '41', 41, '41 - Suspension With Bankruptcy-Terminated'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '42', 42, '42 - Admin Suspension-Terminated'
exec usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '43', 43, '43 - Prospect-Application Pending'
exec usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '44', 44, '44 - Non Licensed - Unpaid Award(s)'
exec usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '45', 45, '45 - Non Licensed - R & F'
exec usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '46', 46, '46 - Non Licensed - Injunction Imposed'
EXEC usp_TravantCRM_CreateDropdownValue 'prpa_TerminateCode', '47', 47, '47 - Terminated-Injunction Imposed'





exec usp_TravantCRM_CreateDropdownValue 'prpe_BankruptcyType', '1', 1, 'Chapter 7'
exec usp_TravantCRM_CreateDropdownValue 'prpe_BankruptcyType', '2', 2, 'Chapter 11'
exec usp_TravantCRM_CreateDropdownValue 'prpe_BankruptcyType', '3', 3, 'Chapter 12'
exec usp_TravantCRM_CreateDropdownValue 'prpe_BankruptcyType', '4', 4, 'Chapter 13'
exec usp_TravantCRM_CreateDropdownValue 'prpe_DischargeType', '1', 1, 'Dismissed'
exec usp_TravantCRM_CreateDropdownValue 'prpe_DischargeType', '2', 2, 'Discharged'
exec usp_TravantCRM_CreateDropdownValue 'prpe_DischargeType', '3', 3, 'Closed'
exec usp_TravantCRM_CreateDropdownValue 'prpt_Name', '1', 1, 'Acquisition'
exec usp_TravantCRM_CreateDropdownValue 'prpt_Name', '2', 2, 'Agreement In Principle'
exec usp_TravantCRM_CreateDropdownValue 'prpr_Source', '1', 1, 'Phone'
exec usp_TravantCRM_CreateDropdownValue 'prpr_Source', '2', 2, 'Email'

-- Add PRPayRating values
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prpy_Name', '(81)', 9, 'Pay reported as variable; specific pay description not assignable.', NULL, NULL, NULL, 'Reportado pago variable, descripción específica de pago no asignada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prpy_Name', 'F', 8, '60+ days on average', NULL, NULL, NULL, 'Pagos dentro de 60+ días promedio', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prpy_Name', 'E', 7, '46 - 60 days on average', NULL, NULL, NULL, 'Pagos dentro de 46-60 días promedio', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prpy_Name', 'D', 6, '36 - 45 days on average', NULL, NULL, NULL, 'Pagos dentro de 36-45 días promedio', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prpy_Name', 'C', 5, '29 - 35 days on average', NULL, NULL, NULL, 'Pagos dentro de 29-35  días promedio', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prpy_Name', 'B', 4, '22 - 28 days on average', NULL, NULL, NULL, 'Pagos dentro de 22-28 días promedio', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prpy_Name', 'AB', 3, '15 - 21 days on average', NULL, NULL, NULL, 'Pagos dentro de 15-21 días promedio', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prpy_Name', 'A', 2, '15-21 days on average', NULL, NULL, NULL, 'Pagos dentro de 15-21 días promedio', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prpy_Name', 'AA', 1, '1 - 14 days on average', NULL, NULL, NULL, 'Pagos dentro de 1-14 días promedio', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prpy_Name', '(149)', 10, 'Reports received indicating pay variable and/or beyond terms with vendors, suppliers, and/or transportation firms.', NULL, NULL, NULL, 'Reportes recibidos indican retraso en pagos a proveedores y/o empresas transportistas.', NULL, NULL, 'PRDropdownValues'


-- Add PRRatingNumeral values
-- DELETE FROM custom_Captions WHERE capt_family = 'prrn_Name'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(1)', 10, 'Reported asking general extension.', NULL, NULL, NULL, 'Reportado buscando una extensión general.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(2)', 20, 'Reported granted general extension.', NULL, NULL, NULL, 'Reportado extensión general otorgada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(3)', 30, 'Reported asked one or more creditors for temporary extension.', NULL, NULL, NULL, 'Reportado solicitó a, uno o más acreedores una extensión temporal.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(4)', 40, 'Reported one or more creditors grant temporary extension.', NULL, NULL, NULL, 'Reportado uno o más de los acreedores otorgan extensión temporal.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(5)', 50, 'Reported offering to compromise.', NULL, NULL, NULL, 'Reportado ofreciendo arreglo de pago.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(6)', 60, 'Temporary restraining order or injunction granted.', NULL, NULL, NULL, 'Orden de restricción temporaria y mandato otorgado.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(7)', 70, 'Reported compromised with creditors', NULL, NULL, NULL, 'Reportado ofreciendo arreglo de pago.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(8)', 80, 'Reported assignment made for benefit of creditors.', NULL, NULL, NULL, 'Reportado asignación hecha a beneficio de los acreedores.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(9)', 90, 'Reported meeting of creditors called.', NULL, NULL, NULL, 'Reportado reunión de los acreedores convocada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(10)', 100, 'Reported have held meeting with creditors.', NULL, NULL, NULL, 'Reportado ha sostenido reuniones con acreedores.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(11)', 110, 'Reported indicted.', NULL, NULL, NULL, 'Reportado acusado.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(12)', 120, 'Reported indictment closed.', NULL, NULL, NULL, 'Reportado concluida acusación.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(13)', 130, 'Judgment or lien reported of public record.', NULL, NULL, NULL, 'Reportado demandado.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(14)', 140, 'Reported receiver applied for.', NULL, NULL, NULL, 'Solicitando un síndico o administrador judicial.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(15)', 150, 'Reported receiver appointed.', NULL, NULL, NULL, 'Reportado síndico asignado.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(16)', 160, 'Reported attachment filed.', NULL, NULL, NULL, 'Reportado bienes embargados.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(17)', 170, 'Reported petition in bankruptcy filed.', NULL, NULL, NULL, 'Reportado declaración de bancarrota en archivo.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(18)', 180, 'Reported voluntary petition in bankruptcy filed.', NULL, NULL, NULL, 'Reportado declaración voluntaria de bancarrota.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(19)', 190, 'Reported involuntary petition in bankruptcy filed.', NULL, NULL, NULL, 'Reportado declaración involuntaria de bancarrota.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(20)', 200, 'Reported discharge in bankruptcy approved.', NULL, NULL, NULL, 'Reportado aprobada solicitud de bancarrota.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(21)', 210, 'Reported court has approved re-organization plan.', NULL, NULL, NULL, 'Reportado plan de reorganización aprobada por la corte.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(26)', 220, 'Reported has made or has agreed to make partial or installment payments on a due or past due balance.', NULL, NULL, NULL, 'Reportado ha remitido parcial o a plazo en una deuda pasada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(27)', 5230, 'Reported slower pay.', NULL, NULL, NULL, 'Reportado pago más lento.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(30)', 5240, 'Reported has transportation affiliation(s).', NULL, NULL, NULL, 'Reportado tiene afiliación (es) con empresa (s) de transportación.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(31)', 5250, 'Reported has shipping affiliation(s).', NULL, NULL, NULL, 'Reportado tiene afiliación (es) con empresa (s) de embarcadores.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(32)', 5260, 'Reported has produce brokerage affiliation(s).', NULL, NULL, NULL, 'Reportado tiene afiliación (es) con empresa (s) de agentes intermediarios de perecederos.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(35)', 5270, 'Reported has receiving, jobbing, and/or distributing affiliation(s).', NULL, NULL, NULL, 'Reportado tiene afiliación con recibidores, vendedores locales y/o con distribuidores.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(40)', 5280, 'Reported affiliated with one or more firms or individuals in the same line of business.', NULL, NULL, NULL, 'Reportado está afiliado con una o más empresas o individuos con el mismo tipo de negocios.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(45)', 5290, 'Reported has retail affiliation(s).', NULL, NULL, NULL, 'Reportado está afiliados con vendedores al minoreo.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(46)', 5300, 'Reported has exclusive or restrictive buying or selling relationship with other firm(s).', NULL, NULL, NULL, 'Reportado tiene lazo que compra o vende exclusivo o restrictivo con otra(s) firma(s).', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(49)', 310, 'Reported check, or accepted draft, returned unpaid.', NULL, NULL, NULL, 'Reportado que cheque o medio de pago fue devuelto sin fondos.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(52)', 320, 'Reported have tendered, or issued, one or more postdated checks.', NULL, NULL, NULL, 'Reportado que ha presentado o dado cheques postdatados.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(54)', 330, 'Claim(s) against firm has been placed with us amounting to $___.', NULL, NULL, NULL, 'Hemos recibido demanda contra la empresa por la cantidad de $_____.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(55)', 340, 'Collection or Claim placed with us has been settled.', NULL, NULL, NULL, 'Reclamo o cobro recibido por nosotros ha sido resuelto.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(56)', 350, 'Collection or Claim placed with us against firm in the amount of $ ____.', NULL, NULL, NULL, 'Cobro recibido por nosotros en contra de la empresa esta pendiente por la cantidad de $____.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(57)', 360, 'Reported deduction(s) taken by firm without authorization or proof of claim amount to $_.', NULL, NULL, NULL, 'Reportado deducciones hechas por la empresa sin autorización o prueba de la demanda por la cantidad $____', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(58)', 370, 'Collection or Claim referred to an outside agency.', NULL, NULL, NULL, 'Cobranza/Controversias referida a una agencia externa.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(60)', 380, 'Trade information not sufficient to support a definite rating.', NULL, NULL, NULL, 'Información de la industria insuficiente para apoyar una evaluación definitiva.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(63)', 390, 'Declined to identify and/or furnish background information on principals and/or provide details on the business.', NULL, NULL, NULL, 'Rehusó identificar a los directivos y/o dar sus antecedentes.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(64)', 395, 'Reported has issued a voluntary product recall.', NULL, NULL, NULL, 'Reportado ha publicado retirada voluntaria del producto.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(74)', 400, 'Payment practices under review.', NULL, NULL, NULL, 'Prácticas de pago bajo revisión.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(76)', 410, 'Under investigation; rating under review.', NULL, NULL, NULL, 'Bajo investigación, evaluación bajo revisión.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(80)', 420, 'Rating indicates reported trading confidence or pay this location (also see complete headquarters listing).', NULL, NULL, NULL, 'Indica confianza de la industria reportada en esta ubicación. (Vea el listado de la matriz)', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(82)', 430, 'Trade reports too limited to assign a definite rating, although one or more reports reflect pay running beyond terms.', NULL, NULL, NULL, 'Reportes muy limitados para asignar evaluación definitiva, aunque uno o más indican retraso en pagos.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(83)', 440, 'Information regarding special circumstances available in the Business Report.', NULL, NULL, NULL, 'Información detallada de circunstancias especiales será proporcionada si es solicitada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(84)', 450, 'Reported operating under court supervision as part of bankruptcy/reorganization filing.', NULL, NULL, NULL, 'Reportado operando bajo supervisión de corte por declaración de bancarrota/reorganización.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(85)', 460, 'Detailed Business Report available upon request.', NULL, NULL, NULL, 'Reporte especial disponible si es solicitado.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(86)', 470, 'Financial considerations and/or trade reports prohibit the reporting of a definite rating. Detailed Business Report available upon request.', NULL, NULL, NULL, 'Consideraciones financieras y/o reportes de la industria prohiben una evaluación definitiva.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(87)', 480, 'Reported recently commenced business.', NULL, NULL, NULL, 'Reportado comenzó negocio recientemente.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(88)', 490, 'Reported out of business.', NULL, NULL, NULL, 'Reportado fuera de la industria.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(89)', 500, 'Reported this branch discontinued.', NULL, NULL, NULL, 'Reportado esta sucursal discontinuada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(90)', 505, 'Previously emerged from bankruptcy/reorganization.', NULL, NULL, NULL, 'Previamente surgido de la bancarrota/reorganización.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(96)', 510, 'Reported partnership dissolved.', NULL, NULL, NULL, 'Reportado disolución de sociedad.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(99)', 520, 'Succeeded by _______.', NULL, NULL, NULL, 'Sucesión por_____.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(105)', 530, 'Reported damaged by fire.', NULL, NULL, NULL, 'Reportado dañado por fuego.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(108)', 540, 'Reported liquidating.', NULL, NULL, NULL, 'Reportado en liquidación.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(113)', 550, 'Reported suspended operations; obligations reported not fully liquidated.', NULL, NULL, NULL, 'Reportado que las operaciones fueron suspendidas; sus compromisos no fueron cumplidos totalmente.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(114)', 560, 'Listing deleted. No evidence of continuing operations.', NULL, NULL, NULL, 'Listado suprimido.  Ninguna evidencia de operaciones continúas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(124)', 570, 'Rating suspended pending reinvestigation.', NULL, NULL, NULL, 'Evaluación suspendida nueva investigación pendiente.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(129)', 580, 'Reported corporation dissolved.', NULL, NULL, NULL, 'Reportado corporación disuelta.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(131)', 590, 'Rating withdrawn - trade information too limited to continue support for current rating.', NULL, NULL, NULL, 'Evaluación suspendida.  Información limitada de la industria para respaldar la evaluación actual.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(132)', 600, 'Rating withdrawn.', NULL, NULL, NULL, 'Evaluación suspendida.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(133)', 610, 'Trading Membership or Transportation Membership withdrawn.', NULL, NULL, NULL, 'Membresía de comercialización o de transportación suspendida.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(134)', 620, 'Reported using Trading Membership or Transportation Membership seal and not entitled to do so.', NULL, NULL, NULL, 'Reportado usando sellos de membresía comercial o de transporte sin autorización.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(135)', 630, 'Reported refuses to arbitrate.', NULL, NULL, NULL, 'Reportado rehusó participar en arbitraje.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(136)', 633, 'Capital stock or ownership interest purchased - majority ownership change.  Trade practices rating continues based upon former owner(s) and/or senior executives continuing to run daily operations.', NULL, NULL, NULL, null, NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(137)', 637, 'Assets of a former company purchased - new entity established.  Trade practices rating continues based upon former owner(s) and/or senior executives continuing to run daily operations of the new entity.', NULL, NULL, NULL, null, NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(146)', 640, 'Reported that one or more parties presently associated were responsibly connected with a business that discontinued operations with obligations reported not fully liquidated - rating reflects current trade reports.', NULL, NULL, NULL, 'Reportado que estaban involucrados con un negocio que discontinuó con obligaciones.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(151)', 660, 'Reported PACA or CFIA license reinstated.', NULL, NULL, NULL, 'Reportado licencia de P.A.C.A. o licencia C.F.I.A. reinstalada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(152)', 670, 'Reported PACA or CFIA license suspended or terminated with sanctions imposed against the company.', NULL, NULL, NULL, 'Reportado licencia de P.A.C.A.. o licencia C.F.I.A. suspendida.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(153)', 680, 'Reported PACA or CFIA license revoked.', NULL, NULL, NULL, 'Reportado licencia de . o licencia C.F.I.A. revocada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(155)', 690, 'Reported fine or civil penalty levied by government or regulatory agency.', NULL, NULL, NULL, 'Reportado multa o sanción civil impuesta por el gobierno o agencia reguladora.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(156)', 700, 'Reported Dispute Resolution Corporation (DRC) membership terminated.', NULL, NULL, NULL, 'Reportado que la membresía de Corporación de Solución de DRC está suspendida.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(157)', 710, 'Reported Dispute Resolution Corporation (DRC) member expelled.', NULL, NULL, NULL, 'Reportado que la membresía de Corporación de Solución de DRC está revocada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(158)', 720, 'Reported Dispute Resolution Corporation (DRC) membership reinstated.', NULL, NULL, NULL, 'Reportado que la membresía de Corporación de Solución de DRC ha sido reinstalada.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name', '(159)', 730, 'Reported posted a USDA surety bond or surety agreement.', NULL, NULL, NULL, NULL, NULL, NULL, 'PRDropdownValues'

-- Add PRRatingNumeralInsight values
-- DELETE FROM custom_Captions WHERE capt_family = 'prrn_Name_Insight'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(1)', 10, 'An interim rating numeral reported on a company for requesting additional time to resolve a particular circumstance or obligation, like a payment, from its creditors.', NULL, NULL, NULL, 'Número de calificación provisional que se comunica a una empresa por solicitar un plazo adicional para resolver una determinada circunstancia u obligación, como un pago, de sus acreedores.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(2)', 20, 'An interim rating numeral reported on a company after creditors have granted additional time to resolve a particular circumstance or obligation, like a payment.', NULL, NULL, NULL, 'Número de calificación provisional que se otorga a una empresa después de que los acreedores hayan concedido un plazo adicional para resolver una circunstancia u obligación concreta, como un pago.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(3)', 30, 'An interim rating numeral reported on a company after requesting a temporary extension, or additional time, from one or more creditors to resolve a particular circumstance or obligation.', NULL, NULL, NULL, 'Número provisional de calificación que se comunica a una empresa tras solicitar una prórroga temporal, o un plazo adicional, a uno o varios acreedores para resolver una determinada circunstancia u obligación.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(4)', 40, 'An interim rating numeral reported on a company after one or more creditors have granted a temporary extension, or additional time, to resolve a particular circumstance or obligation.', NULL, NULL, NULL, 'Número de calificación provisional que se otorga a una empresa después de que uno o varios acreedores le hayan concedido una prórroga temporal, o un plazo adicional, para resolver una determinada circunstancia u obligación.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(5)', 50, 'An interim rating numeral reported on a company for offering to compromise with creditors for less than amounts owed.', NULL, NULL, NULL, 'Número de calificación provisional de una empresa por ofrecer a los acreedores un acuerdo por un importe inferior al adeudado.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(6)', 60, 'An interim rating numeral reported on a company reflecting that a court order has been granted against and requires a company or party to maintain a certain status or to cease certain actions until a court has the opportunity to review further evidence.', NULL, NULL, NULL, 'Número de calificación provisional que figura en una empresa y que refleja que se ha dictado una orden judicial contra una empresa o una parte y que exige que mantenga una determinada situación o que cese determinadas acciones hasta que el tribunal tenga la oportunidad de examinar más pruebas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(7)', 70, 'An interim rating numeral reported that identifies an agreement between a debtor and a creditor(s) in which a creditor(s) agrees to accept less than the full amount owed in full satisfaction of an outstanding debt.', NULL, NULL, NULL, 'Número de calificación provisional notificado que identifica un acuerdo entre un deudor y un acreedor o acreedores en el que un acreedor o acreedores acuerdan aceptar menos de la cantidad total adeudada en satisfacción total de una deuda pendiente.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(8)', 80, 'An interim rating numeral reported and used to reference a company voluntarily transferring its assets to a trust or other entity for liquidation and distribution.', NULL, NULL, NULL, 'Número de calificación provisional comunicado y utilizado para hacer referencia a una empresa que transfiere voluntariamente sus activos a un fideicomiso u otra entidad para su liquidación y distribución.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(9)', 90, 'An interim rating numeral reported and denotes a meeting of creditors being called to review and vote on a plan for dividing assets of an insolvent debtor company.', NULL, NULL, NULL, 'Es un número de calificación provisional que se comunica y denota una reunión de acreedores que se convoca para examinar y votar un plan de división de activos de una empresa deudora insolvente.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(10)', 100, 'An interim rating numeral reported to signify a meeting of creditors has been held to review and vote on a plan for dividing assets of an insolvent debtor company.', NULL, NULL, NULL, 'Un número de calificación provisional que se comunica para indicar que se ha celebrado una junta de acreedores para examinar y votar un plan de división de activos de una empresa deudora insolvente.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(11)', 110, 'An interim rating numeral reported to reference a company or person being charged with a crime.', NULL, NULL, NULL, 'Número de calificación provisional que se comunica para hacer referencia a una empresa o persona acusada de un delito.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(12)', 120, 'An interim rating numeral reported referencing a charge against a person or company for a crime, has been closed by a court.', NULL, NULL, NULL, 'Un número de calificación provisional comunicado que hace referencia a una acusación contra una persona o empresa por un delito, ha sido archivado por un tribunal.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(13)', 130, 'An interim rating numeral reported referencing a court order granted against a company in which a company is obligated to pay a debt or handle an obligation as a result of a lawsuit.', NULL, NULL, NULL, 'Número de calificación provisional notificado que hace referencia a una orden judicial dictada contra una empresa en la que ésta se ve obligada a pagar una deuda o a gestionar una obligación como resultado de una demanda.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(14)', 140, 'An interim rating numeral reported referencing a receiver has been applied for through a judicial process to collect and preserve assets for distributions to creditors in accordance with judicial authorization.', NULL, NULL, NULL, 'Se ha solicitado un administrador judicial a través de un proceso judicial para recoger y preservar los activos para distribuirlos a los acreedores de acuerdo con la autorización judicial.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(15)', 150, 'An interim rating numeral reported referencing a receiver has been appointed through a judicial process to collect and preserve assets for distribution to creditors.', NULL, NULL, NULL, 'Se informa de un número de calificación provisional que hace referencia a que se ha nombrado a un administrador judicial a través de un proceso judicial para recaudar y preservar los activos para su distribución a los acreedores.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(16)', 160, 'An interim rating numeral reported on a company to reference a court order seizing certain assets to enforce judgment.', NULL, NULL, NULL, 'Número de calificación provisional notificado a una empresa en referencia a una orden judicial de embargo de determinados activos para ejecutar una sentencia.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(17)', 170, 'An interim rating numeral reported to reference a company has filed a bankruptcy petition in an effort to either reorganize or liquidate its business operations due to financial stresses.', NULL, NULL, NULL, 'Número de calificación provisional que indica que una empresa ha presentado una solicitud de quiebra para reorganizar o liquidar sus operaciones comerciales debido a tensiones financieras.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(18)', 180, 'An interim rating numeral reported to reference a company has voluntarily filed a bankruptcy petition in an effort to either reorganize or liquidate its business operations due to financial stresses.', NULL, NULL, NULL, 'Se trata de un número de calificación provisional que indica que una empresa ha presentado voluntariamente una solicitud de quiebra para reorganizar o liquidar sus operaciones comerciales debido a tensiones financieras.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(19)', 190, 'An interim rating numeral reported to reference an involuntary bankruptcy petition has been filed by a creditor or group of creditors against a debtor company for past due and outstanding obligations.', NULL, NULL, NULL, 'Se trata de un número de calificación provisional que indica que un acreedor o grupo de acreedores ha presentado una solicitud de quiebra involuntaria contra una empresa deudora por obligaciones vencidas y pendientes de pago.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(20)', 200, 'An interim rating numeral reported to reference a company in bankruptcy has been approved by a court to be discharged from all approved obligations.', NULL, NULL, NULL, 'Un número de calificación provisional comunicado para hacer referencia a una empresa en quiebra ha sido aprobado por un tribunal para ser liberado de todas las obligaciones aprobadas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(21)', 210, 'An interim rating numeral reported to reference a company in bankruptcy has had its reorganization plan approved by a bankruptcy court.', NULL, NULL, NULL, 'Se trata de un número de calificación provisional que hace referencia a una empresa en quiebra cuyo plan de reorganización ha sido aprobado por un tribunal de quiebras.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(26)', 220, 'An interim rating numeral reported to reference a debtor company has made or has agreed to make partial or installment payments on past due balances.', NULL, NULL, NULL, 'Número de calificación provisional que se comunica para hacer referencia a que una empresa deudora ha efectuado o ha acordado efectuar pagos parciales o a plazos de saldos vencidos.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(27)', 5230, 'An interim rating numeral reported to reference slow and unsupportive pay data.', NULL, NULL, NULL, 'Un número de calificación intermedio comunicado para hacer referencia a datos salariales lentos y poco favorables.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(30)', 5240, 'A rating numeral assigned to a company to reference its affiliation with a transportation business through common ownership and/or officers.', NULL, NULL, NULL, 'Número de clasificación asignado a una empresa para hacer referencia a su afiliación con una empresa de transporte a través de la propiedad común y/o funcionarios.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(31)', 5250, 'A rating numeral assigned to a company to reference its affiliation with a shipping business through common ownership and/or officers.', NULL, NULL, NULL, 'Número de clasificación asignado a una empresa para hacer referencia a su afiliación con una empresa de transporte marítimo a través de la propiedad común y/o funcionarios.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(32)', 5260, 'A rating numeral assigned to a company to reference its affiliation with a produce brokerage business through common ownership and/or officers.', NULL, NULL, NULL, 'Número de clasificación asignado a una empresa para hacer referencia a su afiliación con una empresa de corretaje de productos agrícolas a través de la propiedad común y / o funcionarios.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(35)', 5270, 'A rating numeral assigned to a company to reference its affiliation with a receiver and/or distributor business through common ownership and/or officers.', NULL, NULL, NULL, 'Número de clasificación asignado a una empresa para hacer referencia a su afiliación con una empresa receptora y/o distribuidora a través de la propiedad y/o los directivos comunes.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(40)', 5280, 'A rating numeral assigned to a company to reference its affiliation with another business in the same line of business through common ownership and/or officers.', NULL, NULL, NULL, 'Número de clasificación que se asigna a una empresa para hacer referencia a su afiliación con otra empresa del mismo sector de actividad a través de la propiedad y/o los directivos comunes.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(45)', 5290, 'A rating numeral assigned to a company to reference its affiliation with a retail business through common ownership and/or officers.', NULL, NULL, NULL, 'Número de clasificación asignado a una empresa para hacer referencia a su afiliación con una empresa minorista a través de la propiedad común y/o directivos.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(46)', 5300, 'A rating numeral assigned to a company to reference a company’s restrictive buying and/or selling relationship with another firm or firms.', NULL, NULL, NULL, 'Número de calificación que se asigna a una empresa para hacer referencia a su relación restrictiva de compra y/o venta con otra empresa o empresas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(49)', 310, 'An interim rating numeral reported to reference a bank confirming insufficient funds available for a company making payment for product or services.', NULL, NULL, NULL, 'Un número de calificación provisional comunicado para hacer referencia a un banco que confirma la insuficiencia de fondos disponibles para una empresa que realiza el pago de un producto o servicio.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(52)', 320, 'An interim rating numeral reported to reference a company issuing one or more postdated checks.', NULL, NULL, NULL, 'Número de calificación provisional que se comunica para hacer referencia a una empresa que emite uno o varios cheques posfechados.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(60)', 380, 'A rating numeral assigned to reference insufficient trade information to support an assignment of a definite rating.', NULL, NULL, NULL, 'Número de calificación asignado para hacer referencia a información comercial insuficiente para respaldar la asignación de una calificación definitiva.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(62)', 380, 'A rating numeral assigned in lieu of a credit worth estimate as a result of certain unsupportive financial positions.', NULL, NULL, NULL, 'Número de calificación asignado en lugar de una estimación del valor del crédito como resultado de determinadas posiciones financieras insostenibles.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(63)', 390, 'A rating numeral assigned to a company when the company declines to share or divulge background information on its principals or business operations.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa cuando ésta se niega a compartir o divulgar información de fondo sobre sus directivos o sus operaciones comerciales.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(64)', 395, 'An interim rating numeral reported to reference a company issuing a voluntary recall.', NULL, NULL, NULL, 'Número de calificación provisional que se comunica para hacer referencia a una empresa que efectúa una retirada voluntaria.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(68)', 396, 'A rating numeral assigned in lieu of a credit worth estimate due to reported mixed, variable and/or slow trading experiences.', NULL, NULL, NULL, 'Número de calificación asignado en lugar de una estimación del valor del crédito debido a experiencias comerciales mixtas, variables y/o lentas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(69)', 400, 'An interim rating numeral reported on a company to reverse a previously reported listing change.', NULL, NULL, NULL, 'Un número de calificación provisional comunicado sobre una empresa para anular un cambio de cotización comunicado anteriormente.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(71)', 400, 'An interim numeral reported on a company to signify a change to its listing detail.', NULL, NULL, NULL, 'Número intermedio que aparece en una empresa para indicar un cambio en los datos de cotización.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(74)', 400, 'An interim rating numeral reported on a company and replaces an existing rating due to unsupportive pay experiences.', NULL, NULL, NULL, 'Es un número de calificación provisional notificado a una empresa y que sustituye a una calificación existente debido a experiencias salariales insatisfactorias.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(76)', 410, 'An interim rating numeral reported on a company and replaces an existing rating due to unsupportive trading and/or pay experiences.', NULL, NULL, NULL, 'Es un número de calificación provisional de una empresa y sustituye a una calificación existente debido a experiencias comerciales y/o salariales insatisfactorias.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(78)', 420, 'An interim rating numeral reported on a company and replaces an existing credit worth estimate due to unsupportive financial conditions or positions.', NULL, NULL, NULL, 'Cifra de calificación provisional de una empresa que sustituye a una estimación de valor crediticio existente debido a condiciones o posiciones financieras insostenibles.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(79)', 420, 'An interim rating numeral reported on a company and replaces an existing credit worth estimate due to outdated financial statements.', NULL, NULL, NULL, 'Se trata de una calificación provisional de una empresa que sustituye a una estimación del valor crediticio existente debido a la desactualización de los estados financieros.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(80)', 420, 'An assigned rating numeral reported on a branch location of a company that handles its own administrative functions and when trade information is supportive of a rating assignment.', NULL, NULL, NULL, 'Número de calificación asignado a una sucursal de una empresa que gestiona sus propias funciones administrativas y cuando la información comercial respalda una asignación de calificación.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(81)', 430, 'An assigned rating numeral reported on a company in lieu of a definite pay description, when reported vendor pay experiences are regarded as variable.', NULL, NULL, NULL, 'Un número de clasificación asignado a una empresa en lugar de una descripción salarial definida, cuando las experiencias salariales de los proveedores se consideran variables.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(82)', 430, 'An assigned rating numeral reported on a company that exhibits limited trade information but trading data reflects slow pay performance.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa que presenta información comercial limitada, pero cuyos datos comerciales reflejan un rendimiento lento de los pagos.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(83)', 440, 'An assigned rating numeral reported on a company to draw attention to special circumstances, such as but not limited to, mixed and variable trading performance, licensing or ownership matters, or a financial or legal concern.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa para llamar la atención sobre circunstancias especiales, como, por ejemplo, resultados comerciales mixtos y variables, asuntos relacionados con licencias o propiedad, o un problema financiero o jurídico.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(84)', 450, 'An assigned rating numeral reported on a company as it continues to operate under court supervision while undergoing bankruptcy proceedings or other reorganization process.', NULL, NULL, NULL, 'Cifra de calificación asignada a una empresa mientras sigue operando bajo supervisión judicial mientras se encuentra inmersa en un procedimiento de quiebra u otro proceso de reorganización.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(85)', 460, 'An interim rating numeral reported on a company that provides insights through Blue Book reports, on developing operational circumstances.', NULL, NULL, NULL, 'Es un número de calificación provisional de una empresa que proporciona información, a través de los informes del Libro Azul, sobre la evolución de las circunstancias operativas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(86)', 470, 'An assigned rating numeral reported on a company to call attention to circumstances or a situation that prohibits the assignment of a definite rating, such as but not limited to, financial concerns, reported mixed and slow trading experiences, an ownership circumstance, or a licensing or legal concern.', NULL, NULL, NULL, 'Un número de calificación asignado a una empresa para llamar la atención sobre las circunstancias o una situación que prohíbe la asignación de una calificación definitiva, como, entre otras, preocupaciones financieras, experiencias comerciales mixtas y lentas notificadas, una circunstancia de propiedad o una preocupación legal o de concesión de licencias.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(87)', 480, 'An interim rating numeral reported on a newly listed company that has operated less than two years.', NULL, NULL, NULL, 'Número de calificación provisional de una empresa que acaba de cotizar en bolsa y que lleva menos de dos años en funcionamiento.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(88)', 490, 'An assigned rating numeral reported on a company after having confirmed to have ceased operations.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa tras confirmarse que ha cesado sus operaciones.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(89)', 500, 'An assigned rating numeral reported on a branch location of a company that has confirmed it has discontinued operations.', NULL, NULL, NULL, 'Número de calificación asignado a una sucursal de una empresa que ha confirmado el cese de sus actividades.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(90)', 505, 'An assigned rating numeral reported on a company that has emerged from bankruptcy or other reorganization proceeding.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa que ha salido de un procedimiento de quiebra u otro procedimiento de reorganización.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(96)', 510, 'An interim rating numeral reported to denote the dissolution of a partnership.', NULL, NULL, NULL, 'Número de calificación provisional que se comunica para indicar la disolución de una sociedad.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(99)', 520, 'An interim rating numeral reported on a company when its operations have been succeeded by another company.', NULL, NULL, NULL, 'Número de calificación provisional de una empresa cuando sus operaciones han sido sucedidas por otra empresa.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(105)', 530, 'An interim rating numeral reported on a company that has experienced a fire.', NULL, NULL, NULL, 'Número de calificación provisional de una empresa que ha sufrido un incendio.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(108)', 540, 'An assigned rating numeral reported on a company that reports liquidating its business operations.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa que informa de la liquidación de sus operaciones comerciales.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(113)', 550, 'An assigned rating numeral reported on a company when operations have been suspended with reported outstanding obligations.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa cuando se han suspendido las operaciones con obligaciones pendientes notificadas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(114)', 560, 'An assigned rating numeral reported on a company when all forms of communications to confirm operating status are unsuccessful.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa cuando todas las formas de comunicación para confirmar el estado operativo son infructuosas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(124)', 570, 'An interim rating numeral reported on a company and replaces an existing rating due to unsupportive trading and/or pay experiences.', NULL, NULL, NULL, 'Es un número de calificación provisional de una empresa y sustituye a una calificación existente debido a experiencias comerciales y/o salariales insatisfactorias.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(129)', 580, 'An interim rating numeral reported on a company to denote the dissolution of its corporation.', NULL, NULL, NULL, 'Número de calificación provisional que se comunica a una empresa para denotar la disolución de su sociedad.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(131)', 590, 'An interim rating numeral reported on a company and replaces an existing rating due to insufficient trade information.', NULL, NULL, NULL, 'Un número de calificación provisional que se comunica sobre una empresa y sustituye a una calificación existente debido a la insuficiencia de información comercial.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(132)', 600, 'An interim rating numeral reported on a company and replaces an existing rating due to unsupportive trading and/or pay experiences.', NULL, NULL, NULL, 'Es un número de calificación provisional de una empresa y sustituye a una calificación existente debido a experiencias comerciales y/o salariales insatisfactorias.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(133)', 610, 'An interim rating numeral reported on a company when the company no longer meets the requirements of Trading/Transportation membership, blue book’s honor designation.', NULL, NULL, NULL, 'Número de calificación provisional que se asigna a una empresa cuando ésta deja de cumplir los requisitos para ser miembro de Comercio/Transporte, la designación de honor de Blue Book.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(134)', 620, 'An interim rating numeral reported on a company when found to be using blue book’s Trading/Transportation Membership logo and does not carry the honor designation.', NULL, NULL, NULL, 'Un número de calificación provisional que aparece en una empresa cuando se descubre que utiliza el logotipo de afiliación de Comercio/Transporte de blue book y no lleva la designación de honor.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(135)', 630, 'An interim rating numeral reported on a company when it refuses to abide by blue book’s Trading/Transportation Membership arbitration agreement.', NULL, NULL, NULL, 'Número de calificación provisional que se asigna a una empresa cuando se niega a cumplir el acuerdo de arbitraje de la Membresía de Comercio/Transporte de Blue Book.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(136)', 633, 'A rating numeral assigned to a company when ownership materially changes; however its Trade Practices rating remains supported due to former owners and leadership continuing to be associated with and managing the day-to-day operations.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa cuando cambia sustancialmente la propiedad; sin embargo, su calificación de Prácticas Comerciales se mantiene debido a que los antiguos propietarios y dirigentes siguen asociados y gestionando las operaciones cotidianas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(137)', 637, 'A rating numeral assigned to a company when it acquires assets of another company; and the assigned Trade Practices rating remains supported due to former owners and leadership continuing to be associated with and managing the day-to-day operations.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa cuando adquiere activos de otra empresa; y la calificación de Prácticas Comerciales asignada se mantiene debido a que los antiguos propietarios y dirigentes siguen asociados y gestionando las operaciones cotidianas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(142)', 640, 'A rating numeral assigned in lieu of a credit worth estimate due to its financial position reflecting intangible assets, such as goodwill or amounts owing from principals or affiliates, as a major portion of net worth.', NULL, NULL, NULL, 'Número de calificación asignado en lugar de una estimación del valor crediticio debido a que su situación financiera refleja activos intangibles, como el fondo de comercio o los importes adeudados por directores o filiales, como una parte importante del patrimonio neto.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(143)', 640, 'A rating numeral assigned in lieu of a credit worth estimate due to a company’s financial position reflecting fixed assets, such as property, plant and equipment, as a major portion of net worth.', NULL, NULL, NULL, 'Número de calificación asignado en lugar de una estimación del valor crediticio debido a que la situación financiera de una empresa refleja activos fijos, como propiedades, planta y equipo, como parte principal del patrimonio neto.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(144)', 640, 'A rating numeral assigned in lieu of a credit worth estimate due to a company’s financial position not allowing for the assignment of a credit worth estimate or the financial condition of a company is unknown and a company exhibits mixed and variable pay practices.', NULL, NULL, NULL, 'Número de calificación asignado en lugar de una estimación del valor crediticio debido a que la situación financiera de una empresa no permite la asignación de una estimación del valor crediticio o se desconoce la situación financiera de una empresa y ésta presenta prácticas de retribución mixta y variable.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(145)', 640, 'A rating numeral assigned in lieu of a credit worth estimate due to a company’s most current financial position reflecting negative net worth or negative working capital.', NULL, NULL, NULL, 'Número de calificación asignado en lugar de una estimación del valor crediticio debido a que la situación financiera más reciente de una empresa refleja un patrimonio neto negativo o un fondo de maniobra negativo.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(146)', 640, 'A rating numeral assigned to a company when one or more responsibly connected principals were associated with a business that ceased operations with outstanding obligations.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa cuando uno o más de sus principales responsables estaban asociados a un negocio que cesó sus operaciones con obligaciones pendientes.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(147)', 660, 'A rating numeral assigned to a company when Trade Practices are reported as mixed, though some trading partners report satisfactory experiences.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa cuando las prácticas comerciales se consideran mixtas, aunque algunos socios comerciales informan de experiencias satisfactorias.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(148)', 660, 'A rating numeral assigned to a company when Trade Practices are generally reported as satisfactory, though some trading partners report less than satisfactory experiences.', NULL, NULL, NULL, 'Número de calificación asignado a una empresa cuando las prácticas comerciales se consideran satisfactorias en general, aunque algunos socios comerciales informan de experiencias menos satisfactorias.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(149)', 660, 'A rating numeral assigned to a company in lieu of a definite pay description when reported vendor and/or service provider pay experiences are generally regarded as variable and beyond terms.', NULL, NULL, NULL, 'Un número de clasificación asignado a una empresa en lugar de una descripción salarial definida cuando las experiencias salariales comunicadas de proveedores y/o prestamistas de servicios se consideran generalmente variables y más allá de los términos.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(150)', 660, 'A rating numeral assigned in lieu of a credit worth estimate when a company’s parent shares consolidated financial statements that include its subsidiaries.', NULL, NULL, NULL, 'Número de calificación asignado en lugar de una estimación del valor crediticio cuando la matriz de una empresa comparte estados financieros consolidados que incluyen a sus filiales.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(151)', 660, 'An interim rating numeral reported on a company when its PACA license has been reinstated after having been previously reported suspended or revoked.', NULL, NULL, NULL, 'Número de calificación provisional que se comunica a una empresa cuando se ha restablecido su licencia PACA tras haber sido suspendida o revocada anteriormente.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(152)', 670, 'An interim rating numeral reported on a company for failure to satisfy trade debt obligations as ruled by the PACA resulting in the suspension of its PACA license.', NULL, NULL, NULL, 'Se trata de un número de calificación provisional de una empresa por incumplimiento de las obligaciones de deuda comercial dictaminadas por PACA que tiene como consecuencia la suspensión de su licencia PACA.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(153)', 680, 'An interim rating numeral reported on a company for failure to satisfy trade debt obligations as ruled by the PACA resulting in the revocation of its PACA license.', NULL, NULL, NULL, 'Un número de calificación provisional notificado a una empresa por incumplimiento de las obligaciones de deuda comercial según lo dictaminado por PACA, lo que da lugar a la revocación de su licencia PACA.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(154)', 685, 'A rating numeral assigned in lieu of a credit worth estimate due to a company’s financial position not allowing for the assignment of a credit worth estimate and/or the financial condition of a company is unknown and exhibits variable and/or slow pay practices.', NULL, NULL, NULL, 'Número de calificación asignado en lugar de una estimación del valor crediticio debido a que la situación financiera de una empresa no permite la asignación de una estimación del valor crediticio y/o se desconoce la situación financiera de una empresa y presenta prácticas de pago variables y/o lentas.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(155)', 690, 'An interim rating numeral reported on a company for a fine or civil penalty levied against it by a government or regulatory agency.', NULL, NULL, NULL, 'Número de calificación provisional de una empresa por una multa o sanción civil que le impone un organismo gubernamental o regulador.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(156)', 700, 'An interim rating numeral reported on a company for the termination of its DRC membership for failure to satisfy trade obligations and/or other violations.', NULL, NULL, NULL, 'Número de calificación provisional que se comunica a una empresa para la finalización de su pertenencia a la DRC por incumplimiento de las obligaciones comerciales y/u otras infracciones.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(157)', 710, 'An interim rating numeral reported on a company for the expulsion of its DRC membership for failure to satisfy trade obligations and/or other violations.', NULL, NULL, NULL, 'Número de calificación provisional notificado a una empresa para la expulsión de su condición de miembro de la DRC por incumplimiento de sus obligaciones comerciales y/u otras infracciones.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(158)', 720, 'An interim rating numeral reported on a company for the reinstatement of its DRC membership after it being reported terminated, suspended or revoked for non-payment of trading obligations and/or other violations.', NULL, NULL, NULL, 'Número provisional de calificación que se comunica a una empresa para el restablecimiento de su condición de miembro de la DRC después de que se haya comunicado su terminación, suspensión o revocación por impago de obligaciones comerciales y/u otras infracciones.', NULL, NULL, 'PRDropdownValues'
exec usp_TravantCRM_AddCustom_Captions 'Choices', 'prrn_Name_Insight', '(159)', 730, 'An interim rating numeral reported on a company for posting a USDA surety bond.', NULL, NULL, NULL, 'Número de calificación provisional de una empresa por haber depositado una fianza del USDA.', NULL, NULL, 'PRDropdownValues'

exec usp_TravantCRM_CreateDropdownValue 'prrn_Type', 'L', 0, 'Legal Status and Payment Practice'
exec usp_TravantCRM_CreateDropdownValue 'prrn_Type', 'A', 1, 'Affliation / Business Relationship'
exec usp_TravantCRM_CreateDropdownValue 'prrn_Type', 'T', 2, 'Trading Experience'
exec usp_TravantCRM_CreateDropdownValue 'prrn_Type', 'R', 3, 'Rating, Listing, Licensing, and Operating Status'
exec usp_TravantCRM_CreateDropdownValue 'prrt_Category', 'CT', 0, 'Confirmed Trading Activity'
exec usp_TravantCRM_CreateDropdownValue 'prrt_Category', 'IT', 1, 'Inferred Trading Activity'
exec usp_TravantCRM_CreateDropdownValue 'prrt_Category', 'CR', 2, 'Company Relationship'
exec usp_TravantCRM_CreateDropdownValue 'prrt_Category', 'PR', 3, 'Person Relationship'
exec usp_TravantCRM_CreateDropdownValue 'prrt_Category', 'SA', 4, 'Strategic Alliance'
exec usp_TravantCRM_CreateDropdownValue 'prrt_Category', 'LI', 5, 'Litigation'
exec usp_TravantCRM_CreateDropdownValue 'prrt_Category', 'UN', 6, 'Unknown'

exec usp_TravantCRM_CreateDropdownValue 'prrt_Name', '1', 1, 'Buyer'
exec usp_TravantCRM_CreateDropdownValue 'prrt_Name', '2', 2, 'Freight Provider'

exec usp_TravantCRM_CreateDropdownValue 'prex_Name', '2', 2, 'NASDAQ'
exec usp_TravantCRM_CreateDropdownValue 'prex_Name', '3', 3, 'TSE'
exec usp_TravantCRM_CreateDropdownValue 'prex_Name', '4', 4, 'AMEX'
exec usp_TravantCRM_CreateDropdownValue 'prex_Name', '5', 5, 'OTCBB'
exec usp_TravantCRM_CreateDropdownValue 'prex_Name', '1', 1, 'NYSE'
exec usp_TravantCRM_CreateDropdownValue 'prex_Name', '6', 6, 'NYSE Euronext'


exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequest', '1', 1, 'Select all companies that have reported a pay description of D, E or F'
exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequest', '2', 2, 'Randomly select companies on reference list '
exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequest', '3', 3, 'Randomly select companies that submitted trade reports'
exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequest', '4', 4, 'Select companies that have not received survey in last 60 days'
exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequest', '5', 5, 'Select specific companies with relationship'
exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequest', '6', 6, 'Select previous sent TES for second requests'

exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequestAge', '30', 30, 'In the Past 30 Days'
exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequestAge', '45', 45, 'In the Past 45 Days'
exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequestAge', '60', 60, 'In the Past 60 Days'
exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequestAge', '90', 90, 'In the Past 90 Days'
exec usp_TravantCRM_CreateDropdownValue 'prte_CustomTESRequestAge', '120', 120, 'In the Past 120 Days'


exec usp_TravantCRM_CreateDropdownValue 'prtr_AmountPastDue', 'A', 1, 'None'
exec usp_TravantCRM_CreateDropdownValue 'prtr_AmountPastDue', 'B', 2, 'Less Than 25M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_AmountPastDue', 'C', 3, '25M To 100M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_AmountPastDue', 'D', 4, 'Over 100M'

exec usp_TravantCRM_CreateDropdownValue 'prtr_CreditTerms', 'A', 1, '10 Days'
exec usp_TravantCRM_CreateDropdownValue 'prtr_CreditTerms', 'B', 2, '21 Days'
exec usp_TravantCRM_CreateDropdownValue 'prtr_CreditTerms', 'C', 3, '30 Days'
exec usp_TravantCRM_CreateDropdownValue 'prtr_CreditTerms', 'D', 4, 'Beyond 30 Days'

exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCredit', 'A', 1, '5-10M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCredit', 'B', 2, '10-50M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCredit', 'C', 3, '50-75M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCredit', 'D', 4, '75-100M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCredit', 'E', 5, '100-250M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCredit', 'F', 6, 'Over 250M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCredit', 'G', 7, '250-500M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCredit', 'H', 8, '500-1000M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCredit', 'I', 9, 'Over 1 million'

exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditL', 'A', 1, '5-10K'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditL', 'B', 2, '10-50K'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditL', 'C', 3, '50-75K'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditL', 'D', 4, '75-100K'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditL', 'E', 5, '100-250K'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditL', 'F', 6, 'Over 250K'

exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditBBOS', 'A', 1, '5-10M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditBBOS', 'B', 2, '10-50M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditBBOS', 'C', 3, '50-75M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditBBOS', 'D', 4, '75-100M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditBBOS', 'E', 5, '100-250M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditBBOS', 'G', 7, '250-500M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditBBOS', 'H', 8, '500-1000M'
exec usp_TravantCRM_CreateDropdownValue 'prtr_HighCreditBBOS', 'I', 9, 'Over 1 million'

exec usp_TravantCRM_CreateDropdownValue 'prtr_LastDealtDate', 'A', 1, '1-6 Months'
exec usp_TravantCRM_CreateDropdownValue 'prtr_LastDealtDate', 'B', 2, '7-12 Months'
exec usp_TravantCRM_CreateDropdownValue 'prtr_LastDealtDate', 'C', 3, 'Over 1 Year'
exec usp_TravantCRM_CreateDropdownValue 'prtr_LastDealtDate', 'D', 4, 'Never'

exec usp_TravantCRM_CreateDropdownValue 'prtr_LoadsPerYear', 'A', 1, '1-24'
exec usp_TravantCRM_CreateDropdownValue 'prtr_LoadsPerYear', 'B', 2, '25-50'
exec usp_TravantCRM_CreateDropdownValue 'prtr_LoadsPerYear', 'C', 3, '50-100'
exec usp_TravantCRM_CreateDropdownValue 'prtr_LoadsPerYear', 'D', 4, 'Over 100'
exec usp_TravantCRM_CreateDropdownValue 'prtr_OverallTrend', 'I', 1, 'Improving'
exec usp_TravantCRM_CreateDropdownValue 'prtr_OverallTrend', 'U', 2, 'Unchanged'
exec usp_TravantCRM_CreateDropdownValue 'prtr_OverallTrend', 'D', 3, 'Declining'
exec usp_TravantCRM_CreateDropdownValue 'prtr_Pack', 'S', 1, 'Superior'
exec usp_TravantCRM_CreateDropdownValue 'prtr_Pack', 'G', 2, 'Good'
exec usp_TravantCRM_CreateDropdownValue 'prtr_Pack', 'A', 3, 'Average'
exec usp_TravantCRM_CreateDropdownValue 'prtr_Pack', 'F', 4, 'Fair'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipLength', 'B', 1, 'Under 1 Year'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipLength', 'C', 2, '1-10 Years'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipLength', 'D', 3, '10+ Years'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipType', 'SH', 1, 'Shipper'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipType', 'BR', 2, 'Broker'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipType', 'DR', 3, 'Distributor/Receiver'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipType', 'CS', 4, 'Chain Store'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipType', 'IM', 5, 'Importer/Exporter'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipType', 'CA', 6, 'Carrier'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipType', 'TB', 7, 'Transporation Broker'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipType', 'FC', 8, 'Freight Contractor'
exec usp_TravantCRM_CreateDropdownValue 'prtr_RelationshipType', 'FF', 9, 'Freight Forwarder'
exec usp_TravantCRM_CreateDropdownValue 'prtr_Terms', '1', 1, 'COD'
exec usp_TravantCRM_CreateDropdownValue 'prtr_Terms', '2', 2, 'Firm Price'
exec usp_TravantCRM_CreateDropdownValue 'prtr_Terms', '3', 3, 'Consignment'
exec usp_TravantCRM_CreateDropdownValue 'prtr_Terms', '4', 4, 'FOB'
exec usp_TravantCRM_CreateDropdownValue 'prtr_Terms', '5', 5, 'Delivered Price'
exec usp_TravantCRM_CreateDropdownValue 'prtr_Terms', '6', 6, 'PAS (Price-after-sale)'

exec usp_TravantCRM_CreateDropdownValue 'prtr_ResponseSource', 'T', 1, 'TES Form'
exec usp_TravantCRM_CreateDropdownValue 'prtr_ResponseSource', 'W', 2, 'Web Site Submission'
exec usp_TravantCRM_CreateDropdownValue 'prtr_ResponseSource', 'E', 3, 'EBB Submission'
exec usp_TravantCRM_CreateDropdownValue 'prtr_ResponseSource', 'A', 4, 'A/R Aging'
exec usp_TravantCRM_CreateDropdownValue 'prtr_ResponseSource', 'R', 5, 'Relationship Entry'
exec usp_TravantCRM_CreateDropdownValue 'prtr_ResponseSource', 'M', 6, 'Manual Entry'
exec usp_TravantCRM_CreateDropdownValue 'prtr_ResponseSource', 'MA', 7, 'BBOS Mobile App'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '0', 0, 'BBSi Initiated'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '1', 1, 'Responded To LRL'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '2', 2, 'Responded To Custom BBSi Communication'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '3', 3, 'Responded To Promotion'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '4', 4, 'Unsolicited'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '5', 5, 'Responded To DL Statement'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '6', 6, 'Responded To BBS Invoice/Statement'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '7', 7, 'Result Of New Sale/Membership'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '9', 8, 'Result of Online Data Update'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '10', 9, 'Returned Mail'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationStimulus', '8', 10, 'Other'


exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationType', 'P', 1, 'Phone'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationType', 'F', 2, 'Fax'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationType', 'E', 3, 'E-Mail'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationType', 'M', 4, 'Mail'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationType', 'PV', 5, 'Personal Visit'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationType', 'CV', 6, 'Convention Visit'
exec usp_TravantCRM_CreateDropdownValue 'prtx_NotificationType', 'O', 7, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prtx_Status', 'O', 0, 'Open'
exec usp_TravantCRM_CreateDropdownValue 'prtx_Status', 'C', 1, 'Closed'
exec usp_TravantCRM_CreateDropdownValue 'prtd_ColumnType', 'T', 1, 'Text'
exec usp_TravantCRM_CreateDropdownValue 'prtd_ColumnType', 'D', 2, 'Date'
exec usp_TravantCRM_CreateDropdownValue 'prtd_ColumnType', 'I', 3, 'Integer'
exec usp_TravantCRM_CreateDropdownValue 'prtd_ColumnType', 'N', 4, 'Numeric'
exec usp_TravantCRM_CreateDropdownValue 'prtd_ColumnType', 'B', 5, 'Boolean'
exec usp_TravantCRM_CreateDropdownValue '_DisputeInvolvedSelect', 'Y', 1, 'Yes'         /*Supports Filtering on Trade Report Screen*/
exec usp_TravantCRM_CreateDropdownValue '_DisputeInvolvedSelect', 'N', 2, 'No'         /*Supports Filtering on Trade Report Screen*/
exec usp_TravantCRM_CreateDropdownValue '_ExceptionSelect', 'Y', 1, 'Yes'         /*Supports Filtering on Trade Report Screen*/
exec usp_TravantCRM_CreateDropdownValue '_ExceptionSelect', 'N', 2, 'No'         /*Supports Filtering on Trade Report Screen*/
exec usp_TravantCRM_CreateDropdownValue 'ExporterRegion', '1', 1, 'Mexico'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_TravantCRM_CreateDropdownValue 'ExporterRegion', '10', 10, 'Caribbean'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_TravantCRM_CreateDropdownValue 'ExporterRegion', '2', 2, 'Central America'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_TravantCRM_CreateDropdownValue 'ExporterRegion', '3', 3, 'South America'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_TravantCRM_CreateDropdownValue 'ExporterRegion', '4', 4, 'Europe'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_TravantCRM_CreateDropdownValue 'ExporterRegion', '5', 5, 'Asia'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_TravantCRM_CreateDropdownValue 'ExporterRegion', '6', 6, 'Middle East'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_TravantCRM_CreateDropdownValue 'ExporterRegion', '7', 7, 'Africa'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_TravantCRM_CreateDropdownValue 'ExporterRegion', '8', 8, 'Australia/ New Zealand'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_TravantCRM_CreateDropdownValue 'ExporterRegion', '9', 9, 'Pacific Rim'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/

exec usp_TravantCRM_CreateDropdownValue 'NumEmployees', '0', 0, '0'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_TravantCRM_CreateDropdownValue 'NumEmployees', '1', 1, '1-4'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_TravantCRM_CreateDropdownValue 'NumEmployees', '2', 2, '5-9'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_TravantCRM_CreateDropdownValue 'NumEmployees', '3', 3, '10-19'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_TravantCRM_CreateDropdownValue 'NumEmployees', '4', 4, '20-49'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_TravantCRM_CreateDropdownValue 'NumEmployees', '5', 5, '50-99'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_TravantCRM_CreateDropdownValue 'NumEmployees', '6', 6, '100-249'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_TravantCRM_CreateDropdownValue 'NumEmployees', '7', 7, '250-499'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_TravantCRM_CreateDropdownValue 'NumEmployees', '8', 8, '500-999'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_TravantCRM_CreateDropdownValue 'NumEmployees', '9', 9, '1000+'         /*prcp_FTEmployees, prcp_PTEmployees*/

-- used to provide a dropdown allowing the user to filter on which side of the relationship is reporting
exec usp_TravantCRM_CreateDropdownValue 'prcr_ReportingCompanyType', '1', 2, 'Subject Company'
exec usp_TravantCRM_CreateDropdownValue 'prcr_ReportingCompanyType', '2', 3, 'Related Company'

--Used in the Company Relationship Summary Filter panel for type
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '01', 1, '01- Trade Experience'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '04', 4, '04- AR Aging Report'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '05', 5, '05- Dispute'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '07', 7, '07- Collection'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '09', 9, '09- Buys Product'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '10', 10, '10- Provides Freight Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '11', 11, '11- Receives Freight Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '12', 12, '12- Buys Supplies'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '13', 13, '13- Sells Product'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '15', 15, '15- Generic Trading'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '23', 23, '23- AUS/Watchdog Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '25', 24, '25- Business Report Request'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '27', 27, '27- Wholly Owned Subsidary'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '28', 28, '28- Partial Ownership'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '29', 29, '29- Affiliate (Shared Individual Ownership)'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '30', 30, '30- Handles Sales'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '31', 31, '31- Handles Buying'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '32', 32, '32- Provides Storage Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '33', 33, '33- PACA Action'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '34', 34, '34- Non-PACA lawsuit'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '35', 35, '35- Unknown'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeFilter', '36', 36, '36- Cross Industry Functions'


-- Used in the New Company Relationship-- Trx Open Screen
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '09', 9, '09- Buys Product'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '10', 10, '10- Provides Freight Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '11', 11, '11- Receives Freight Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '12', 12, '12- Buys Supplies'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '13', 13, '13- Sells Product'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '15', 15, '15- Generic Trading'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '23', 23, '23- AUS/Watchdog Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '25', 25, '25- Business Report Request'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '27', 27, '27- Wholly Owned Subsidary'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '28', 28, '28- Partial Ownership'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '30', 30, '30- Handles Sales'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '31', 31, '31- Handles Buying'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '32', 32, '32- Provides Storage Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '35', 35, '35- Unknown'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeOpenTrans', '36', 36, '36- Cross Industry Functions'


-- Used in the New Company Relationship-- NO OPEN TRANSACTION
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeNoTrans ', '09', 9, '09- Buys Product'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeNoTrans ', '10', 10, '10- Provides Freight Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeNoTrans ', '11', 11, '11- Receives Freight Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeNoTrans ', '12', 12, '12- Buys Supplies'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeNoTrans ', '13', 13, '13- Sells Product'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeNoTrans ', '15', 15, '15- Generic Trading'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeNoTrans ', '30', 30, '30- Handles Sales'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeNoTrans ', '31', 31, '31- Handles Buying'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeNoTrans ', '32', 32, '32- Provides Storage Service'
exec usp_TravantCRM_CreateDropdownValue 'prcr_TypeNoTrans ', '35', 35, '35- Unknown'

exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelType', '09', 10, 'Vendor Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelType', '10', 20, 'Carrier/Truck Broker Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelType', '11', 30, 'Transportation Broker/Produce Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelType', '12', 40, 'Supply/Service Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelType', '13', 50, 'Customer Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelType', '15', 60, 'Generic Trading Relationship'


exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeP', '09', 10, 'Vendor Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeP', '10', 20, 'Carrier/Truck Broker Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeP', '12', 30, 'Supply/Service Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeP', '13', 40, 'Customer Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeP', '15', 50, 'Generic Trading Relationship'

exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeL', '09', 10, 'Vendor Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeL', '13', 20, 'Customer Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeL', '15', 30, 'Generic Trading Relationship'

exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeT', '10', 10, 'Carrier/Truck Broker Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeT', '11', 20, 'Transportation Broker/Produce Reference'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLeftRelTypeT', '15', 30, 'Generic Trading Relationship'


--  Used in the Company Relationship Summary Filter Panel for Category
exec usp_TravantCRM_CreateDropdownValue 'prcr_CategoryType', '1', 1, 'Confirmed Trading Relationship'
exec usp_TravantCRM_CreateDropdownValue 'prcr_CategoryType', '2', 2, 'Reference List'
exec usp_TravantCRM_CreateDropdownValue 'prcr_CategoryType', '3', 3, 'Blue Book Reports'
--exec usp_TravantCRM_CreateDropdownValue 'prcr_CategoryType', '4', 4, 'Ownership'
exec usp_TravantCRM_CreateDropdownValue 'prcr_CategoryType', '5', 5, 'Strategic Alliance'
exec usp_TravantCRM_CreateDropdownValue 'prcr_CategoryType', '6', 6, 'Litigation'



exec usp_TravantCRM_CreateDropdownValue 'prd2_Type', 'D', 1, 'Domestic'         /* PRRegion */
exec usp_TravantCRM_CreateDropdownValue 'prd2_Type', 'I', 2, 'International'    /* PRRegion */

exec usp_TravantCRM_CreateDropdownValue 'emai_Type', 'E', 1, 'E-Mail'    /* Email */
exec usp_TravantCRM_CreateDropdownValue 'emai_Type', 'W', 2, 'Web Site' /* Email */
exec usp_TravantCRM_CreateDropdownValue 'elink_Type', 'E', 1, 'E-Mail'    /* Email */
exec usp_TravantCRM_CreateDropdownValue 'elink_Type', 'W', 2, 'Web Site' /* Email */


exec usp_TravantCRM_CreateDropdownValue 'prsp_Activity', 'A', 1, 'Adjustment' /* PRServicePayment */
exec usp_TravantCRM_CreateDropdownValue 'prsp_Activity', 'C', 2, 'Credit' /* PRServicePayment */
exec usp_TravantCRM_CreateDropdownValue 'prsp_Activity', 'I', 3, 'Invoice' /* PRServicePayment */
exec usp_TravantCRM_CreateDropdownValue 'prsp_Activity', 'P', 4, 'Payment' /* PRServicePayment */
exec usp_TravantCRM_CreateDropdownValue 'prsp_Activity', 'X', 5, 'Prepayment' /* PRServicePayment */

exec usp_TravantCRM_CreateDropdownValue 'prse_DeliveryMethod', 'M', 1, 'Mail' /* PRService */
exec usp_TravantCRM_CreateDropdownValue 'prse_DeliveryMethod', 'S', 2, 'Ship' /* PRService */

exec usp_TravantCRM_CreateDropdownValue 'comm_Action', 'MT', 51, 'Meeting' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_Action', 'OT', 52, 'Other' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_Action', 'Note', 53, 'Internal Note' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_Action', 'M', 54, 'Mail (BBS Migration)' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_Action', 'P', 55, 'Phone (BBS Migration)' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_Action', 'E', 56, 'E-Mail (BBS Migration)' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_Action', 'F', 57, 'Fax (BBS Migration)' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_Action', 'O', 58, 'Other (BBS Migration)' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_Action', 'OnlineIn', 59, 'Online In' /* Communication */


exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'R', 1, 'Rating' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'C', 2, 'Content' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'L', 3, 'Listing' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'P', 4, 'Publishing' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'SM', 5, 'Sales & Marketing' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'FS', 6, 'Field Sales' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'BD', 7, 'Business Development' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'CS', 8, 'Customer Service' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'SS', 9, 'Special Services' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'PACA', 10, 'PACA Import' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'MISC', 11, 'Misc. Connections' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'Acct', 12, 'Accounting' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'BREquifaxSurvey', 13, 'BR Equifax Survey' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'ARSub', 14, 'AR Submission' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory', 'O', 99, 'Other' /* Communication */

exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'R', 1, 'Rating' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'C', 2, 'Content' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'L', 3, 'Listing' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'P', 4, 'Publishing' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'SM', 5, 'Sales & Marketing' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'FS', 6, 'Field Sales' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'BD', 7, 'Business Development' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'CS', 8, 'Customer Service' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'SS', 9, 'Special Services' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'Acct', 12, 'Accounting' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'BREquifaxSurvey', 13, 'BR Equifax Survey' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'ARSub', 14, 'AR Submission' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRCategory_curr', 'O', 99, 'Other' /* Communication */

exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'CI', 10, 'Custom Investigation' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'UF', 20, 'Updated Financials' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'RC', 30, 'Rating Change' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'RR', 40, 'Rating Review' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'ALC', 45, 'Attention Line Changes'
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'TMR', 50, 'Trading Member Review' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'JL1', 60, 'Jeopardy Letter 1' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'JL2', 70, 'Jeopardy Letter 2' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'JL3', 80, 'Jeopardy Letter 3' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'AUS', 90, 'Alerts Report' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'CSS', 100, 'Customer Service Survey' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'SSL', 110, 'Special Services Letter' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'VI', 120, 'Verbal Investigation' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'MEM', 130, 'Membership' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'UP', 140, 'Upgrade'/* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'Down', 145, 'Downgrade'/* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'Complaint', 147, 'Complaint'/* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'Courtesy', 148, 'Courtesy Call'/* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'AD', 150, 'Advertising' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'LG', 160, 'Logo' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'CAN', 170, 'Cancellation' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'LI', 180, 'Listing' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'BI', 190, 'Billing' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'CE', 200, 'Customer Education' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'BBOSSale', 210, 'BBOS Sale' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'BBOSSup', 220, 'BBOS Support' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'BBOSEn', 230, 'BBOS Enhancement Idea' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'BBOSCom', 240, 'BBOS Complaint' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'DL', 245, 'DL Feedback' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'O', 250, 'Other' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'LRL', 260, 'Listing Report Letter' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'SSN', 270, 'Special Services Notes (BBS Migration)' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'RD', 280, 'Recent Developments (BBS Migration)' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'HN', 290, 'Hot Notes (BBS Migration)' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'Long', 300, 'Long' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'Short', 310, 'Short' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'RegDev', 320, 'Registered Developer Program' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'ContSynd', 325, 'Content Syndication Program' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'RetMail', 330, 'Returned Mail' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'Welcome', 340, 'Welcome Call' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'ARSub', 350, 'AR Submission' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'ARF', 360, 'AR File' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'ARI', 370, 'AR Inquiry' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'ARR', 380, 'AR Reminder' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'RFR60', 390, '2 Month Reference List Reminder' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'RFR120', 400, '4 Month Reference List Reminder' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'RFR270', 410, '9 Month Reference List Reminder' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'CC', 420, 'Courtesy Contact' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'BGC', 430, 'Background Check' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory', 'BV', 440, 'Business Valuation' /* Communication */

exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'CI', 10, 'Custom Investigation' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'UF', 20, 'Updated Financials' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'RR', 40, 'Rating Review' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'ALC', 45, 'Attention Line Changes'
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'JL1', 60, 'Jeopardy Letter 1' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'JL2', 70, 'Jeopardy Letter 2' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'JL3', 80, 'Jeopardy Letter 3' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'AUS', 90, 'Alerts Report' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'CSS', 100, 'Customer Service Survey' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'VI', 120, 'Verbal Investigation' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'MEM', 130, 'Membership' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'UP', 140, 'Upgrade'/* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'Down', 145, 'Downgrade'/* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'Courtesy', 148, 'Courtesy Call'/* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'AD', 150, 'Advertising' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'LG', 160, 'Logo' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'CAN', 170, 'Cancellation' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'LI', 180, 'Listing' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'BI', 190, 'Billing' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'CE', 200, 'Customer Education' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'BBOSSup', 220, 'BBOS Support' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'O', 250, 'Other' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'LRL', 260, 'Listing Report Letter' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'ContSynd', 325, 'Content Syndication Program' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'RetMail', 330, 'Returned Mail' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'Welcome', 340, 'Welcome Call' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'ARSub', 350, 'AR Submission' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'ARF', 360, 'AR File' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'ARI', 370, 'AR Inquiry' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'ARR', 380, 'AR Reminder' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'RFR60', 390, '2 Month Reference List Reminder' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'RFR120', 400, '4 Month Reference List Reminder' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'RFR270', 410, '9 Month Reference List Reminder' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'CC', 420, 'Courtesy Contact' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'BGC', 430, 'Background Check' /* Communication */
exec usp_TravantCRM_CreateDropdownValue 'comm_PRSubCategory_curr', 'BV', 440, 'Business Valuation' /* Communication */



exec usp_TravantCRM_CreateDropdownValue 'prun_SourceType', 'C', 1, 'CSR' /* PRServiceUnitAllocation */
exec usp_TravantCRM_CreateDropdownValue 'prun_SourceType', 'O', 2, 'Online' /* PRServiceUnitAllocation */

exec usp_TravantCRM_CreateDropdownValue 'prun_AllocationTypeCode', 'M', 1, 'Membership' /* PRServiceUnitAllocation */
exec usp_TravantCRM_CreateDropdownValue 'prun_AllocationTypeCode', 'A', 2, 'Add''l Bus Report Package' /* PRServiceUnitAllocation */
exec usp_TravantCRM_CreateDropdownValue 'prun_AllocationTypeCode', 'P', 3, 'Promotion' /* PRServiceUnitAllocation */
exec usp_TravantCRM_CreateDropdownValue 'prun_AllocationTypeCode', 'R', 3, 'Renewal' /* PRServiceUnitAllocation */

exec usp_TravantCRM_CreateDropdownValue 'prsuu_SourceCode', 'C', 1, 'CSR' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_SourceCode', 'O', 2, 'Online' /* PRServiceUnitUsage */

exec usp_TravantCRM_CreateDropdownValue 'prsuu_TransactionTypeCode', 'U', 1, 'Usage' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_TransactionTypeCode', 'R', 2, 'Reversal' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_TransactionTypeCode', 'C', 3, 'Cancelled' /* PRServiceUnitUsage */

exec usp_TravantCRM_CreateDropdownValue 'prsuu_ReversalReasonCode', 'D', 1, 'Duplicate' /* prsuu_ReversalReason */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_ReversalReasonCode', 'E', 2, 'Customer Error' /* prsuu_ReversalReason */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_ReversalReasonCode', 'O', 2, 'Other' /* prsuu_ReversalReason */

exec usp_TravantCRM_CreateDropdownValue 'prsuu_UsageTypeCode', 'VBR', 1, 'Verbal Business Report' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_UsageTypeCode', 'FBR', 2, 'Fax Business Report' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_UsageTypeCode', 'EBR', 3, 'E-Mail Business Report' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_UsageTypeCode', 'MBR', 4, 'Mail Business Report' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_UsageTypeCode', 'OBR', 5, 'Online Business Report' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_UsageTypeCode', 'OML', 6, 'Online Marketing List' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_UsageTypeCode', 'OLS', 7, 'Online Search' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_UsageTypeCode', 'C', 8, 'Cancelled' /* PRServiceUnitUsage */

exec usp_TravantCRM_CreateDropdownValue 'prsuu_Units', 'VBR', 1, '30' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_Units', 'FBR', 2, '20' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_Units', 'EBR', 3, '20' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_Units', 'MBR', 4, '20' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_Units', 'OBR', 5, '20' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_Units', 'OML', 6, '0' /* PRServiceUnitUsage */
exec usp_TravantCRM_CreateDropdownValue 'prsuu_Units', 'OS', 7, '0' /* PRServiceUnitUsage */

exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'AB/SK', 1, 'Alberta/Saskatchewan' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'AK', 2, 'Alaska' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'AL', 3, 'Alabama' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'AR', 4, 'Arkansas' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'ATLANTIC', 5, 'New Brunswick/Nova Scotia/PEI/Newfoundland' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'AZ', 6, 'Arizona' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'BC', 7, 'British Columbia' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-H1', 8, 'Stockton, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-H2', 9, 'Sebastopol, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-H3', 10, 'Sacramento/San Francisco, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L1', 11, 'Oxnard, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L10', 12, 'Orange County, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L11', 13, 'Los Angeles, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L2', 14, 'Santa Maria, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L3', 15, 'Imperial Valley, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L4', 16, 'Coachella, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L5', 17, 'Salinas, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L6', 18, 'San Joaquin, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L7', 19, 'Riverside/San Bernardino, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L8', 20, 'Delano, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CA-L9', 21, 'Bakersfield/San Diego, CA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CO', 22, 'Colorado' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'CT', 23, 'Connecticut' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'DC/RI', 24, 'Washington, D.C./Rhode Island' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'DE', 25, 'Delaware' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-1', 26, 'Pompano Beach/Ruskin/Sarasota, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-10', 27, 'Belle Glade/Homestead, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-11', 28, 'Fort Myers/Immokalee, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-2', 29, 'Orlando, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-3', 30, 'Hastings/Jacksonville, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-4', 31, 'Pensacola/Tallahassee, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-5', 32, 'Tampa, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-6', 33, 'Miami, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-7', 34, 'Fort Pierce/Vero Beach, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-8', 35, 'Lake Wales/Ocala, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FL-9', 36, 'Lakeland/Plant City, FL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'FOREIGN', 37, 'Other than US/Canada/Mexico/Puerto Rico' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'GA', 38, 'Georgia' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'HI', 39, 'Hawaii' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'IA', 40, 'Iowa' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'ID', 41, 'Idaho' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'IL', 42, 'Illinois' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'IN', 43, 'Indiana' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'KS', 44, 'Kansas' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'KY', 45, 'Kentucky' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'LA', 46, 'Louisiana' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MA', 47, 'Massachusetts' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MB', 48, 'Manitoba' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MD', 49, 'Maryland' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'ME', 50, 'Maine' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MI', 51, 'Michigan' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MN', 52, 'Minnesota' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MO', 53, 'Missouri' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MS', 54, 'Mississippi' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MT', 55, 'Montana' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MX-1', 56, 'Mexico 1' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MX-2', 57, 'Mexico 2' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MX-3', 58, 'Mexico 3' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MX-4', 59, 'Mexico 4' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'MX-5', 60, 'Mexico 5' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'NC', 61, 'North Carolina' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'ND/SD', 62, 'North Dakota/South Dakota' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'NE', 63, 'Nebraska' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'NH', 64, 'New Hampshire' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'NJ', 65, 'New Jersey' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'NM', 66, 'New Mexico' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'NV', 67, 'Nevada' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'NW TERR', 68, 'Northwest Territory (Canadian Province)' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'NY', 69, 'New York' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'OH', 70, 'Ohio' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'OK', 71, 'Oklahoma' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'ON', 72, 'Ontario' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'OR', 73, 'Oregon' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'PA', 74, 'Pennsylvania' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'PR', 75, 'Puerto Rico' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'QC', 76, 'Quebec' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'SC', 77, 'South Carolina' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'TN', 78, 'Tennessee' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'TX-1', 79, 'Dallas/Fort Worth, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'TX-3', 80, 'San Antonio/Amarillo/El Paso, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'TX-4', 81, 'Laredo/Northeast, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'TX-5', 82, 'Houston, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'TX/RIO-2', 83, 'Rio Grande Valley, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'UT', 84, 'Utah' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'VA', 85, 'Virginia' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'VT', 86, 'Vermont' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'WA', 87, 'Washington state' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'WI', 88, 'Wisconsin' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'WV', 89, 'West Virginia' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_RatingTerritory', 'WY', 90, 'Wyoming' /* PRCity */

-- DELETE FROM custom_captions WHERE capt_family = 'prci_SalesTerritory'
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-51-01', 1, 'NORTH WEST MEXICO' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-51-02', 2, 'NORTH CENTRAL MEXICO' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-51-03', 3, 'CENTRAL MEXICO' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-51-04', 4, 'SOUTH CENTRAL MEXICO' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-51-05', 5, 'SOUTH MEXICO' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-52-01', 6, 'CENTRAL AMERICA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-53-01', 7, 'SOUTH AMERICA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-54-01', 8, 'ENGLAND' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-55-01', 9, 'EUROPE' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-56-01', 10, 'PACIFIC RIM' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-57-01', 11, 'CARRIBEAN' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'IN-58-01', 12, 'AFRICA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-01-01', 13, 'SOUTHWEST ILLINOIS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-02-01', 14, 'N. MO & N.E. KS: ST. LOUIS & KANSAS CITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-03-01', 15, 'N. KY & OH' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-04-01', 16, 'NEBRASKA & IOWA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-05-01', 17, 'S.W. T/MKT; CHICAGO & METRO AREA; GARY & M.W. IN' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-06-01', 18, 'DETROIT RECEIVERS & S.E. MI GROWERS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-07-01', 19, 'W. MI: SHIPPING & LTD. RECEIVING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-08-01', 20, 'CENTRAL WI & U.P., MI - POTATO SHIPP REGION' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-09-01', 21, 'MINNEAPOLIS/ST. PAUL, MN & W. WI' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-10-01', 22, 'NORTHERN ILLINOIS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-11-01', 23, 'RED RIVER ; ND, SD, ID, MB: POTATO SHIP' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-12-01', 24, 'S.E. WI (MILWAUKEE)' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-13-01', 25, 'INDIANA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-14-01', 26, 'KENTUCKY (LOUISVILLE)' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'MW-15-01', 27, 'S.E. ILLINOIS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-01-01', 28, 'NEW YORK - BUFFALO/ROCHESTER AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-02-01', 29, 'BROOKLYN MARKETS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-03-01', 30, 'BOSTON/NEW HAMPSHIRE/RHODE ISLAND/VERMONT' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-04-01', 31, 'NEW JERSEY - MARKETS SOUTH & SHIPPING WEST' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-05-01', 32, 'NEW JERSEY - SOUTH JERSEY SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-06-01', 33, 'ONTARIO - TORONTO AREA/HAMILTON AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-07-01', 34, 'PENNSYLVANIA - WEST #2 (PITTSBURG)' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-08-01', 35, 'NEW YORK - HUDSON VALLEY AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-09-01', 36, 'PENNSYLVANIA - WEST #1 (ERIE)' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-10-01', 37, 'NEW YORK - WESTERN NEW YORK SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-11-01', 38, 'NEW YORK - BINGHAMTON/ELMIRA AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-12-01', 39, 'NEW YORK - POTATO & DRIED BEAN AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-13-01', 40, 'ONTARIO SHIPPING - BRANTFORD AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-14-01', 41, 'ONTARIO SHIPPING - BRADFORD AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-15-01', 42, 'ONTARIO SHIPPING - LONDON AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-16-01', 43, 'ONTARIO SHIPPING - LEAMINGTON AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-17-01', 44, 'NEW YORK CITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-17-02', 45, 'NEW YORK CITY - NY VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-18-01', 46, 'NEW YORK - LONG ISLAND/SUFFOLK CTY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-19-01', 47, 'NEW YORK - ORANGE COUNTY AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-20-01', 48, 'NEW JERSEY - MARKET- NORTH SECTION' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-21-01', 49, 'ONTARIO - OTTAWA AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-22-01', 50, 'PENSYLVANIA - EAST #1 & #2' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-23-01', 51, 'QUEBEC AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-24-01', 52, 'QUEBEC - MONTREAL AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-25-01', 53, 'NEW YORK - SYRACUSE AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-26-01', 54, 'NEW YORK - UTICA AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-27-01', 55, 'CONNECTICUT/WEST MASSACHUSETTS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-28-01', 56, 'NEW YORK - ALBANY AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-29-01', 57, 'MAINE' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-30-01', 58, 'ATLANTIC PROVIDENCES' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-31-01', 59, 'PENNSYLVANIA - EAST #5 & #6' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-32-01', 60, 'NEW YORK CITY VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-33-01', 61, 'PENNSYLVANIA - EAST #3 & #4' /* PRCity */

exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-34-01', 62, 'DC, MD, VA - PRIMARY RECEIVING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-35-01', 63, 'WV & WESTERN VA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-36-01', 64, 'SHENANDOAH APPLE SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-37-01', 65, 'DE SHIPPING & NORFOLK, VA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-38-01', 66, 'WESTERN WV RECEIVING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'NE-39-01', 67, 'EASTERN WV' /* PRCity */

exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'OP-01-01', 68, 'AK' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'OP-07-01', 69, 'CENTRALl & EASTERN TN' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'OP-08-01', 70, 'HI' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'OP-09-01', 71, 'WY' /* PRCity */

exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-01-01', 72, 'BELLE GLADE, FL: SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-02-01', 73, 'HOMESTEAD, FL: VEG SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-03-01', 74, 'MIAMI, FL: RECEIVING, IMPORT/EXPORT' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-04-01', 75, 'VIDALIA/SAVANNAH, GA: ONION SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-05-01', 76, 'RUSKIN/SARASOTA, FL: POM/PIT SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-06-01', 77, 'THOMASVILLE/MACON, GA: VEG SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-07-01', 78, 'ORLANDO, FL: RECEIVING, LTD. SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-08-01', 79, 'JACKSONVILLE, FL: RECEIVING & HASTINGS, FL: SHIP' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-09-01', 80, 'PENSACOLA/TALLAHASSEE, FL & AL' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-10-01', 81, 'SOUTH CAROLINA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-11-01', 82, 'NORTH CAROLINA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-12-01', 83, 'NORTH, GA (ATLANTA): T/MKT. & METRO RECEIVING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-13-01', 84, 'TAMPA, FL: RECEIVING & LTD. SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-14-01', 85, 'VERO BEACH/FT. PIERCE, FL: CITRUS SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-15-01', 86, 'LAKELAND/PLANT CITY, FL: ST & VEG. SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-16-01', 87, 'LAKE WALES, FL: F & V SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-17-01', 88, 'OCALA, FL: RECEIVING & LTD. BERRY SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-18-01', 89, 'POMPANO BEACH, FL: VEG SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-19-01', 90, 'FORT MYERS/IMMOKALEE, FL: TOM & VEG SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SE-20-01', 91, 'PUERTO RICO' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-01-01', 92, 'OKLAHOMA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-02-01', 93, 'MISSISSIPPI' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-03-01', 94, 'LOWER MISSOURI' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-04-01', 95, 'TENNESSEE/KENTUCKY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-05-01', 96, 'ARKANSAS-LITTLE ROCK & VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-05-02', 97, 'ARKANSAS-NORTHWEST REGION' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-05-03', 98, 'ARKANSAS-NORTHEAST REGION' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-05-04', 99, 'ARKANSAS-SOUTHWEST REGION' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-05-05', 100, 'ARKANSAS-SOUTHEAST REGION' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-06-01', 101, 'NEW ORLEANS & VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-06-02', 102, 'LOUISIANA-NORTHERN REGION' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-06-03', 103, 'LOUISIANA-SOUTHERN REGION' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-07-01', 104, 'FORT WORTH, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-08-01', 105, 'DENVER & VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-08-02', 106, 'COLORADO-PUEBLO, COLORADO SP & VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-08-03', 107, 'COLORADO-SAN LUIS VALLEY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-08-04', 108, 'COLORADO-GRAND JUNCTION & VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-09-01', 109, 'AMARILLO/LUBBOCK, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-10-01', 110, 'SAN ANTONIO, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-11-01', 111, 'DALLAS, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-12-01', 112, 'RIO GRANDE VALLEY, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-13-01', 113, 'LAREDO, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-14-01', 114, 'WACO/AUSTIN/TEMPLE, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-15-01', 115, 'NORTHEAST, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-16-01', 116, 'HOUSTON, TX' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'SW-17-01', 117, 'KANSAS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-01', 118, 'L.A. CTY, CA: BEVERLY HILLS AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-02', 119, 'L.A. CTY, CA: BURBANK AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-03', 120, 'L.A. CTY, CA: SHERMAN OAKS AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-04', 121, 'L.A. CTY, CA: LONG BEACH AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-05', 122, 'L.A. CTY, CA: VERNON AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-06', 123, 'L.A. CTY, CA: LAWNDALE AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-07', 124, 'L.A. CTY, CA: COMPTON AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-08', 125, 'L.A. CTY, CA: SOUTH PAZADENA AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-09', 126, 'L.A. CTY, CA: CITY OF INDUSTRY AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-10', 127, 'L.A. CTY, CA: EL MONTE AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-11', 128, 'L.A. CTY, CA: CITY OF COMMERCE AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-12', 129, 'L.A. CTY, CA: NORWALK AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-01-13', 130, 'L. A. REVISION & CALL REPORTS (CITY ONLY)' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-02-01', 131, 'SANTA MARIA & VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-03-01', 132, 'OXNARD & VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-04-01', 133, 'SALINAS & VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-05-01', 134, 'BAKERSFIELD' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-06-01', 135, 'NORTH LOS ANGELES COUNTY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-07-01', 136, 'COACHELLA VALLEY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-08-01', 137, 'DELANO/PORTERVILLE' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-09-01', 138, 'RIVERSIDE & SAN BERNARDINO COUNTIES' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-10-01', 139, 'SAN DIEGO, CA & SOUTHERN VICINITY' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-10-02', 140, 'SAN DIEGO, CA: SHIPPING DISTRICTS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-11-01', 141, 'PHOENIX, AZ & SURROUNDING AREAS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-12-01', 142, 'CA: ORANGE COUNTY - NORTH' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-12-02', 143, 'CA: ORANGE COUNTY - SOUTH' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-13-01', 144, 'NM/TX/S.W. CO' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-13-02', 145, 'AZ' /* PRCity */

exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-14-01', 146, 'CA & YUMA, AZ: IMPERIAL VALLEY: SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-15-01', 147, 'NOGALES & AREA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-01-01', 148, 'MONTANA - ALBERTA & SASKATACHEWAN' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-02-01', 149, 'NORTH CA (SAN FRAN.): 2 T/MKT. & METRO REC' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-03-01', 150, 'SEBASTOPOL, CA: FRUIT SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-03-02', 151, 'COASTAL NORTHERN CALIFORNIA' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-04-01', 152, 'SACRAMENTO, CA & NV: RECEIVING AREA & LTD' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-05-01', 153, 'UT - SOUTHWEST, NV' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-06-01', 154, 'CA: SAN JOAQUIN VALLEY: SHIPPING DISTRICTS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-06-02', 155, 'CA: SAN JOAQUIN VALLEY: SHIPPING DISTRICTS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-06-03', 156, 'CA: SAN JOAQUIN VALLEY: SHIPPING DISTRICTS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-06-04', 157, 'CA: SAN JOAQUIN VALLEY: SHIPPING DISTRICTS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-07-01', 158, 'NW NV/W CENT ID/EASTERN OR' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-08-01', 159, 'STOCKTON, CA: SHIPPING DISTRICTS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-09-01', 160, 'CENT & N CENT, WA/CENT BC' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-10-01', 161, 'WESTERN OR/CENT/N. CENT/N.E., OR: SHIPPING' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-11-01', 162, 'E WA/N-WEST. ID/E BC: SHIPPING DISTRICTS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-12-01', 163, 'NORTH CENTRAL CA: SHIPPING DISTRICTS' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-13-01', 164, 'WESTERN OR/WESTERN WA/WESTERN BC' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WD-14-01', 165, 'SOUTH CENTRAL & EASTERN ID' /* PRCity */

exec usp_TravantCRM_CreateDropdownValue 'SalesTerritorySearch', 'IN', 10, 'IN'
exec usp_TravantCRM_CreateDropdownValue 'SalesTerritorySearch', 'MW', 20, 'MW'
exec usp_TravantCRM_CreateDropdownValue 'SalesTerritorySearch', 'NE', 30, 'NE'
exec usp_TravantCRM_CreateDropdownValue 'SalesTerritorySearch', 'OP', 40, 'OP'
exec usp_TravantCRM_CreateDropdownValue 'SalesTerritorySearch', 'SE', 50, 'SE'
exec usp_TravantCRM_CreateDropdownValue 'SalesTerritorySearch', 'SW', 60, 'SW'
exec usp_TravantCRM_CreateDropdownValue 'SalesTerritorySearch', 'WC', 70, 'WC'
exec usp_TravantCRM_CreateDropdownValue 'SalesTerritorySearch', 'WD', 80, 'WD'

exec usp_TravantCRM_CreateDropdownValue 'MembershipTypeCode', '', 10, 'All Companies'
exec usp_TravantCRM_CreateDropdownValue 'MembershipTypeCode', 'M', 20, 'Member Companies'
exec usp_TravantCRM_CreateDropdownValue 'MembershipTypeCode', 'NM', 30, 'Non-Member Companies'




exec usp_TravantCRM_CreateDropdownValue 'AssignmentUserID', 'Survey', 0, '1' /*  The UserID of the user to send out surveys. Used by BBSInterface */
exec usp_TravantCRM_CreateDropdownValue 'AssignmentUserID', 'UnknownAlaCarteOrder', 0, '49' /* The UserID of the inside sales rep to use when the region is unknown. Used by BBSInterface */
exec usp_TravantCRM_CreateDropdownValue 'AssignmentUserID', 'DataProcessor', 0, '44' /* */
exec usp_TravantCRM_CreateDropdownValue 'AssignmentUserID', 'Editor', 1, '1049'
exec usp_TravantCRM_CreateDropdownValue 'AssignmentUserID', 'PublicationSpecialists', 1, '1'
exec usp_TravantCRM_CreateDropdownValue 'AssignmentUserID', 'SalesAdmin', 1, '1'


exec usp_TravantCRM_CreateDropdownValue 'prtf_FormType', 'SE', 1, 'Single English' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_FormType', 'SS', 3, 'Single Spanish' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_FormType', 'SI', 5, 'Single International' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_FormType', 'ME', 2, 'Multiple English' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_FormType', 'MS', 4, 'Multiple Spanish' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_FormType', 'MI', 6, 'Multiple International' /* PRTESForm */

exec usp_TravantCRM_CreateDropdownValue 'prtf_SentMethod', 'F', 0, 'Fax' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_SentMethod', 'M', 1, 'Mail' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_SentMethod', 'E', 2, 'E-Mail' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_SentMethod', 'VI', 3, 'Verbal'
exec usp_TravantCRM_CreateDropdownValue 'prtf_SentMethod', 'B', 4, 'BBOS'

exec usp_TravantCRM_CreateDropdownValue 'prtf_ReceivedMethod', 'FD', 0, 'Fax through DID line' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_ReceivedMethod', 'M', 1, 'Mail' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_ReceivedMethod', 'W', 2, 'Unknown' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_ReceivedMethod', 'FR', 3, 'Fax through Reception' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_ReceivedMethod', 'OL', 4, 'Online' /* PRTESForm */
exec usp_TravantCRM_CreateDropdownValue 'prtf_ReceivedMethod', 'V', 5, 'Verbal'

-- Dropdown Values For Special Service and Special Service Contact fields
exec usp_TravantCRM_CreateDropdownValue 'prss_AdviceActivity', 'O', 1, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prss_AdviceActivity', 'IC', 2, 'Opinion on inspection certificate'
exec usp_TravantCRM_CreateDropdownValue 'prss_AdviceActivity', 'V0', 3, 'Verbal opinion requiring no research or document review'
exec usp_TravantCRM_CreateDropdownValue 'prss_AdviceActivity', 'W0', 4, 'Written opinion requiring no research or document review'
exec usp_TravantCRM_CreateDropdownValue 'prss_AdviceActivity', 'V1', 5, 'Verbal opinion requiring research or document review'
exec usp_TravantCRM_CreateDropdownValue 'prss_AdviceActivity', 'W1', 6, 'Written opinion requiring basic research or document review'
exec usp_TravantCRM_CreateDropdownValue 'prss_AdviceActivity', 'W2', 7, 'Written opinion requiring extensive research or document review'
exec usp_TravantCRM_CreateDropdownValue 'prss_AdviceActivity', 'W3', 8, 'Written opinion involving multiple parties or transactions'
exec usp_TravantCRM_CreateDropdownValue 'prss_AdviceActivity', 'W4', 9, 'Written opinion including detailed damages calculation'

exec usp_TravantCRM_CreateDropdownValue 'prss_LevelOfEffort', '1', 1, '1'
exec usp_TravantCRM_CreateDropdownValue 'prss_LevelOfEffort', '2', 2, '2'
exec usp_TravantCRM_CreateDropdownValue 'prss_LevelOfEffort', '3', 3, '3'
exec usp_TravantCRM_CreateDropdownValue 'prss_LevelOfEffort', '4', 4, '4'
exec usp_TravantCRM_CreateDropdownValue 'prss_LevelOfEffort', '5', 5, '5'
exec usp_TravantCRM_CreateDropdownValue 'prss_LevelOfEffort', '6', 6, '6'
exec usp_TravantCRM_CreateDropdownValue 'prss_LevelOfEffort', '7', 7, '7'
exec usp_TravantCRM_CreateDropdownValue 'prss_LevelOfEffort', '8', 8, '8'
exec usp_TravantCRM_CreateDropdownValue 'prss_LevelOfEffort', '9', 9, '9'

exec usp_TravantCRM_CreateDropdownValue 'prss_Type', 'C', 1, 'Claim'
exec usp_TravantCRM_CreateDropdownValue 'prss_Type', 'A', 2, 'Question'  -- Used to be advice.
exec usp_TravantCRM_CreateDropdownValue 'prss_Type', 'O', 2, 'Other-BBS Migration'
exec usp_TravantCRM_CreateDropdownValue 'prss_Type', 'ARB', 2, 'Arbitration'
exec usp_TravantCRM_CreateDropdownValue 'prss_Type', 'CC', 2, 'Courtesy Contact'

exec usp_TravantCRM_CreateDropdownValue 'prss_Status', 'P', 1, 'Prospective'
exec usp_TravantCRM_CreateDropdownValue 'prss_Status', 'O', 2, 'Open'
exec usp_TravantCRM_CreateDropdownValue 'prss_Status', 'C', 3, 'Closed'

exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'NAR',	1, 'No Signed Claim Auth Rcvd'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'PIF',	2, 'Paid In Full'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'S',	3, 'Settled/Settlement Paid'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'PC',	4, 'Partially Collected and Sent To PLAN'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'PLAN', 5, 'Sent To PLAN'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'CPC',	6, 'Claim Process Complete/Not Sent to PLAN'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'CC',	7, 'Claimant Closed (may use other forum)'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'UI',	8, 'Unresolved/Impasse'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'U',	9, 'Uncooperative or Unresponsive Claimant'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'O',	10, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'PPP',	11, 'Paid/Partially Paid'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'PPS', 12, 'Partially Paid and Sent to PLAN'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'UNS', 13, 'Unresolved; not sent to PLAN'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason', 'CDU',	14, 'Claim Defective/unclear'

exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason_Edit', 'PPP',	1, 'Paid/Partially Paid'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason_Edit', 'PPS', 2, 'Partially Paid and Sent to PLAN'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason_Edit', 'PLAN', 3, 'Sent To PLAN'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason_Edit', 'UNS', 4, 'Unresolved; not sent to PLAN'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason_Edit', 'CDU',	5, 'Claim Defective/unclear'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClosedReason_Edit', 'O',	6, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'SBP', 1, 'Produce Seller vs. Buyer (PACA Eligible)'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'SB',  2, 'Produce Seller vs. Buyer (Not PACA Eligible)'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'BSP', 3, 'Produce Buyer vs. Seller (PACA Eligible)'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'BS',	 4, 'Produce Buyer vs. Seller (Not PACA Eligible)'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'TV',  5, 'Transportation Intermediary vs. Vendor'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'TC',	 6, 'Transportation Intermediary vs. Carrier'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'CT',	 7, 'Carrier vs. Transportation Intermediary'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'CV',	 8, 'Carrier vs. Vendor'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'VI',	 9,  'Vendor vs. Transportation Intermediary'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'VC',	 10, 'Vendor vs. Carrier'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'SA',	 11, 'Supply/Service vs. Any'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'L',	12,  'Lumber'
exec usp_TravantCRM_CreateDropdownValue 'prss_ClassificationType', 'O',	13,  'Other'

exec usp_TravantCRM_CreateDropdownValue 'prss_PLANPartner', 'AFM', 1, 'AFM'
exec usp_TravantCRM_CreateDropdownValue 'prss_PLANPartner', 'O', 2, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prss_PLANPartner', 'BC', 3, 'B & C'

exec usp_TravantCRM_CreateDropdownValue 'prss_PLANFileResult', 'C', 1, 'Collected'
exec usp_TravantCRM_CreateDropdownValue 'prss_PLANFileResult', 'PC', 2, 'Partially Collected'
exec usp_TravantCRM_CreateDropdownValue 'prss_PLANFileResult', 'U', 3, 'Uncollected'
exec usp_TravantCRM_CreateDropdownValue 'prss_PLANFileResult', 'L', 4, 'Litigation'

exec usp_TravantCRM_CreateDropdownValue 'prssc_CompanyRole', 'C', 1, 'Claimant'
exec usp_TravantCRM_CreateDropdownValue 'prssc_CompanyRole', 'R', 2, 'Respondent'
exec usp_TravantCRM_CreateDropdownValue 'prssc_CompanyRole', '3', 3, '3rd Party'

exec usp_TravantCRM_CreateDropdownValue 'praaif_FileFormat', 'DEL', 0, 'Delimited' /* PRARAgingImportFormat */
--exec usp_TravantCRM_CreateDropdownValue 'praaif_FileFormat', 'XML', 1, 'XML' /* PRARAgingImportFormat */

exec usp_TravantCRM_CreateDropdownValue 'praaif_DateFormat', 'MMDDYY', 0, 'MMDDYY' /* PRARAgingImportFormat */
exec usp_TravantCRM_CreateDropdownValue 'praaif_DateFormat', 'MMDDYYYY', 2, 'MMDDYYYY' /* PRARAgingImportFormat */
exec usp_TravantCRM_CreateDropdownValue 'praaif_DateFormat', 'DDMMYY', 3, 'DDMMYY' /* PRARAgingImportFormat */
exec usp_TravantCRM_CreateDropdownValue 'praaif_DateFormat', 'DDMMYYYY', 4, 'DDMMYYYY' /* PRARAgingImportFormat */
exec usp_TravantCRM_CreateDropdownValue 'praaif_DateFormat', 'YYMMDD', 5, 'YYMMDD' /* PRARAgingImportFormat */
exec usp_TravantCRM_CreateDropdownValue 'praaif_DateFormat', 'YYYYMMDD', 6, 'YYYYMMDD' /* PRARAgingImportFormat */

/* PRWebUSER table values */
/* prwu_AccessLevel */
--exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '5', 5, 'Restricted User'
--exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '7', 7, 'Restricted Access - Plus'
--exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '10', 10, 'Registered User'
--DELETE FROM custom_captions WHERE capt_familyType='Choices' AND capt_Family = 'prwu_AccessLevel';
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '100', 100, 'Limitado Access'
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '200', 200, 'Limited Access'
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '300', 300, 'Basic Access'
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '350', 350, 'Basic Plus Access'
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '400', 400, 'Standard Access'
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '500', 500, 'Advanced Access'
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '600', 600, 'Advanced Plus Access'
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '700', 700, 'Premium Access'
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '999999', 999999, 'System Admin Access'

/* prwu_Culture */
exec usp_TravantCRM_CreateDropdownValue 'prwu_Culture', 'en-us', 1, 'English'
exec usp_TravantCRM_CreateDropdownValue 'prwu_Culture', 'es-mx', 2, 'Spanish'

/* prwu_DefaultCompanySearchPage */
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPage', 'CompanySearch.aspx', 1, 'General'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPage', 'CompanySearchLocation.aspx', 2, 'Location'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPage', 'CompanySearchRating.aspx', 3, 'Ratings'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPage', 'CompanySearchClassification.aspx', 4, 'Classification'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPage', 'CompanySearchCommodity.aspx', 5, 'Commodity'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPage', 'CompanySearchCustom.aspx', 6, 'Custom'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPage', 'CompanySearchProfile.aspx', 7, 'Profile'


/* prwu_DefaultCompanySearchPageL */
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPageL', 'CompanySearch.aspx', 1, 'General'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPageL', 'CompanySearchLocation.aspx', 2, 'Location'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPageL', 'CompanySearchRating.aspx', 3, 'Ratings'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPageL', 'CompanySearchSpecie.aspx', 4, 'Species'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPageL', 'CompanySearchProduct.aspx', 5, 'Products'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPageL', 'CompanySearchService.aspx', 6, 'Services'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPageL', 'CompanySearchClassification.aspx', 7, 'Classification'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPageL', 'CompanySearchProfile.aspx', 8, 'Profile'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCompanySearchPageL', 'CompanySearchCustom.aspx', 9, 'Custom'

exec usp_TravantCRM_CreateDropdownValue 'prwu_CompanyUpdateMessageType', 'All', 1, 'All Updates'
exec usp_TravantCRM_CreateDropdownValue 'prwu_CompanyUpdateMessageType', 'Key', 2, 'Key Updates Only'


/* prwu_HowLearned */
-- delete from custom_captions where capt_familytype = 'Choices' and capt_family = 'prwu_HowLearned'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '1', 10, 'Referred by Another Person/Company in the Industry'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '10', 20, 'Ad in the Produce News'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '11', 30, 'Ad in Produce Business'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '12', 40, 'Ad in Americafruit'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '13', 50, 'Ad in Another Trade Publication'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '14', 60, 'An Online Ad for Blue Book Services'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '15', 70, 'Direct Mail from Blue Book Services'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '2', 80, 'Former Blue Book Member'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '3', 90, 'Currently Listed in the Blue Book'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '4', 100, 'Through a Search Engine/Portal (Google, Yahoo, MSN, Ask)'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '5', 110, 'PACA'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '6', 120, 'Industry Trade Association'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '18', 125, 'International Fresh Produce Association'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '7', 130, 'PMA Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '8', 140, 'United Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '9', 150, 'CPMA Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '17', 160, 'Fruit Logistica Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned', '16', 170, 'Other'

/* prwu_HowLearned_Curr */
-- delete from custom_captions where capt_familytype = 'Choices' and capt_family = 'prwu_HowLearned_Curr'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '1', 10, 'Referred by Another Person/Company in the Industry'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '10', 20, 'Ad in the Produce News'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '11', 30, 'Ad in Produce Business'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '12', 40, 'Ad in Americafruit'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '13', 50, 'Ad in Another Trade Publication'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '14', 60, 'An Online Ad for Blue Book Services'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '15', 70, 'Direct Mail from Blue Book Services'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '2', 80, 'Former Blue Book Member'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '3', 90, 'Currently Listed in the Blue Book'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '4', 100, 'Through a Search Engine/Portal (Google, Yahoo, MSN, Ask)'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '5', 110, 'PACA'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '6', 120, 'Industry Trade Association'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '18', 125, 'International Fresh Produce Association'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '7', 130, 'PMA Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '8', 140, 'United Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '9', 150, 'CPMA Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '17', 160, 'Fruit Logistica Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearned_Curr', '16', 170, 'Other'


-- delete from custom_captions where capt_familytype = 'Choices' and capt_family = 'ProduceHowLearned'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Canadian Produce Marketing Association', 10, 'Canadian Produce Marketing Association'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Freight 360', 15, 'Freight 360'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Fresh Fruit Portal', 20, 'Fresh Fruit Portal'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'FreshProduce.com', 30, 'FreshProduce.com (Int''l Fresh Produce Assoc)'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Freshplaza.com', 40, 'Freshplaza.com'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Fruit Logistica', 50, 'Fruit Logistica'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Fruitnet Daily News', 60, 'Fruitnet Daily News'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'PMA Fresh Summit', 70, 'IFPA Global Produce & Floral Show'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'IFP – E-Newsletter', 80, 'International Fresh Produce Assoc E-newsletter'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Portalfruticola.com', 90, 'Portalfruticola.com'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Produce Business Magazine', 100, 'Produce Business Magazine'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Produce News - E-Newsletter', 110, 'Produce News - E-Newsletter'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Produce News', 120, 'Produce News - Newspaper'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'TheProduceNews.com', 130, 'TheProduceNews.com'
exec usp_TravantCRM_CreateDropdownValue 'ProduceHowLearned', 'Other', 999, 'Other'

-- delete from custom_captions where capt_familytype = 'Choices' and capt_family = 'LumberHowLearned'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'An Online Ad for Lumber Blue Book', 10, 'An Online Ad for Lumber Blue Book'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Through a Search Engine/Portal', 15, 'Through a Search Engine/Portal (Google, Yahoo, MSN, etc.)'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Lumber Blue Book Rep Visited My Office', 20, 'A Lumber Blue Book representative visited my office'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Through a Webinar', 30, 'Through a Webinar'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Through a Press Release', 40, 'Through a Press Release'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Madison''s Lumber Reporter', 50, 'Madison''s Lumber Reporter'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'The NAWLA website/newsletter', 60, 'The NAWLA website/newsletter'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Through NAWLA Trader''s Market', 70, 'Through NAWLA Trader''s Market'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Through IHLA Convention', 80, 'Through IHLA Convention'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Through NHLA Convention', 90, 'Through NHLA Convention'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Other Industry Tradeshow', 100, 'Other Industry Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Dd in BPD / The Merchant Magazine', 110, 'An ad in Building Products Digest / The Merchant Magazine'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Ad in Softwood Forest Products Digest', 120, 'An ad in The Softwood Forest Products Digest'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Other industry publication', 130, 'Other industry publication'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Through Freight 360 Podcast', 140, 'Through Freight 360 Podcast'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Direct Mail Piece from Lumber Blue Book', 150, 'Direct Mail Piece from Lumber Blue Book'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Referred by Another Person/Company', 160, 'Referred by Another Person/Company in the Industry'
exec usp_TravantCRM_CreateDropdownValue 'LumberHowLearned', 'Other', 170, 'Other'




-- delete from custom_captions where capt_familytype = 'Choices' and capt_family = 'TypeofBusiness'
exec usp_TravantCRM_CreateDropdownValue 'TypeofBusiness', 'P', 10, 'Buy and/or Sell and/or Broker fresh produce'
exec usp_TravantCRM_CreateDropdownValue 'TypeofBusiness', 'T', 20, 'Transport and/or facilitate transportation of fresh produce'
exec usp_TravantCRM_CreateDropdownValue 'TypeofBusiness', 'S', 30, 'Provide a service or supply to buyers and/or sellers of fresh produce'

-- delete from custom_captions where capt_familytype = 'Choices' and capt_family = 'prwu_HowLearnedL'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '1', 1, 'Referred by Another Person/Company in the Industry '
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '2', 2, 'Other industry publication'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '3', 3, 'An Online Ad for Lumber Blue Book Services'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '4', 4, 'A Lumber Blue Book representative visited my office'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '5', 5, 'Direct Mail Piece from Lumber Blue Book'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '6', 6, 'Currently Listed in the Blue Book '
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '7', 7, 'Through a Search Engine/Portal (Google, Yahoo, MSN, etc.)'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '8', 8, 'Through a Webinar'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '9', 9, 'Through a Press Release'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '10', 10, 'NAWLA Member'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '11', 11, 'Other Industry Trade Association'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '12', 12, 'Through NAWLA Trader''s Market'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '13', 13, 'Other Industry Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '14', 14, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '15', 15, 'Madison''s Lumber Reporter'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '16', 16, 'The NAWLA website/newsletter'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '17', 17, 'Through IHLA Convention'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '18', 18, 'Through NHLA Convention'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '19', 19, 'An ad in Building Products Digest / The Merchant Magazine'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '20', 20, 'An ad in The Softwood Forest Products Digest'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL', '21', 21, 'Through Freight 360 Podcast'

-- delete from custom_captions where capt_familytype = 'Choices' and capt_family = 'prwu_HowLearnedL_Curr'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '3', 1, 'An Online Ad for Lumber Blue Book'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '7', 2, 'Through a Search Engine/Portal (Google, Yahoo, MSN, etc.)'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '4', 3, 'A Lumber Blue Book representative visited my office'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '8', 4, 'Through a Webinar'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '9', 5, 'Through a Press Release'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '15', 6, 'Madison''s Lumber Reporter'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '16', 7, 'The NAWLA website/newsletter'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '12', 8, 'Through NAWLA Trader''s Market'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '17', 9, 'Through IHLA Convention'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '18', 10, 'Through NHLA Convention'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '13', 11, 'Other Industry Tradeshow'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '19', 12, 'An ad in Building Products Digest / The Merchant Magazine'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '20', 13, 'An ad in The Softwood Forest Products Digest'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '2', 14, 'Other industry publication'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '21', 15, 'Through Freight 360 Podcast'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '5', 16, 'Direct Mail Piece from Lumber Blue Book'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '1', 17, 'Referred by Another Person/Company in the Industry'
exec usp_TravantCRM_CreateDropdownValue 'prwu_HowLearnedL_Curr', '14', 18, 'Other'



exec usp_TravantCRM_CreateDropdownValue 'prcd_Type', 'TrkD', 0, 'Domestic Trucking Region' /* PRCompanyRegion */
exec usp_TravantCRM_CreateDropdownValue 'prcd_Type', 'SrcD', 2, 'Domestic Buying Region' /* PRCompanyRegion */
exec usp_TravantCRM_CreateDropdownValue 'prcd_Type', 'SellD', 3, 'Domestic Selling Region' /* PRCompanyRegion */
exec usp_TravantCRM_CreateDropdownValue 'prcd_Type', 'SrcI', 4, 'International Buying Region' /* PRCompanyRegion */
exec usp_TravantCRM_CreateDropdownValue 'prcd_Type', 'SellI', 5, 'International Selling Region' /* PRCompanyRegion */

/* Master PublicationCode List */
-- DELETE FROM Custom_Captions WHERE capt_family = 'prpbar_PublicationCode'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'BP',  10, 'Blueprints Quarterly Journal '
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'BPO', 20, 'Blueprints Online-Only Articles '
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'BBR', 30, 'Reference Guide'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'BBS', 40, 'Membership Guide'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'BBN', 50, 'News'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'KYC', 60, 'Know Your Commodity'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'KYCG', 70, 'Know Your Commodity Guide'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'KYCGFB', 80, 'Know Your Commodity Guide Flip Book'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'TTGFB', 85, 'Trade/Trans Guide Flip Book'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'TRN', 90, 'Training'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'NHA', 100, 'New Hire Academy'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'BBOSPU', 110, 'BBOS Pop-up'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'BPS', 120, 'Blueprints Quarterly Journal Supplement'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'BPFB', 130, 'Blueprints Quarterly Journal Flip Book'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'BPFBS', 140, 'Blueprints Quarterly Journal Flip Book Supplement'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_PublicationCode', 'WPBA', 150, 'Blueprints Quarterly Journal'

exec usp_TravantCRM_CreateDropdownValue 'BBOSLCSearchPublicationCode', 'BP',  10, 'Blueprints Quarterly Journal '
exec usp_TravantCRM_CreateDropdownValue 'BBOSLCSearchPublicationCode', 'BPS', 20, 'Blueprints Quarterly Journal Supplement'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLCSearchPublicationCode', 'BPO', 30, 'Blueprints Online-Only Articles '
exec usp_TravantCRM_CreateDropdownValue 'BBOSLCSearchPublicationCode', 'BBR', 40, 'Reference Guide'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLCSearchPublicationCode', 'BBS', 50, 'Membership Guide'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLCSearchPublicationCode', 'KYC', 60, 'Know Your Commodity'
exec usp_TravantCRM_CreateDropdownValue 'BBOSLCSearchPublicationCode', 'TRN', 70, 'Training'

--exec usp_TravantCRM_CreateDropdownValue 'BluePrintsPublicationCode', 'BP',  10, 'Blueprints Quarterly Journal '
--exec usp_TravantCRM_CreateDropdownValue 'BluePrintsPublicationCode', 'BPS', 120, 'Blueprints Quarterly Journal Supplement'
exec usp_TravantCRM_CreateDropdownValue 'BluePrintsPublicationCode', 'BPFB', 130, 'Blueprints Quarterly Journal Flip Book'
exec usp_TravantCRM_CreateDropdownValue 'BluePrintsPublicationCode', 'BPFBS', 140, 'Blueprints Quarterly Journal Flip Book Supplement'

exec usp_TravantCRM_CreateDropdownValue 'GeneralPublicationCode', 'BPO', 20, 'Blueprints Online-Only Articles '
exec usp_TravantCRM_CreateDropdownValue 'GeneralPublicationCode', 'BBR', 30, 'Reference Guide'
exec usp_TravantCRM_CreateDropdownValue 'GeneralPublicationCode', 'BBS', 40, 'Membership Guide'
--exec usp_TravantCRM_CreateDropdownValue 'GeneralPublicationCode', 'KYC', 60, 'Know Your Commodity'
--exec usp_TravantCRM_CreateDropdownValue 'GeneralPublicationCode', 'KYCG', 70, 'Know Your Commodity Guide'
exec usp_TravantCRM_CreateDropdownValue 'GeneralPublicationCode', 'KYCGFB', 80, 'Know Your Commodity Guide Flip Book'
exec usp_TravantCRM_CreateDropdownValue 'GeneralPublicationCode', 'TTGFB', 85, 'Trade/Trans Guide Flip Book'

exec usp_TravantCRM_CreateDropdownValue 'pradc_PublicationCode', 'KYC', 60, 'Know Your Commodity'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PublicationCode', 'KYCG', 70, 'Know Your Commodity Guide'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PublicationCode', 'TTG', 70, 'Trading/Transportation Guidelines'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PublicationCode', 'O', 99, 'Other'

exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'MA',      1, 'Merger & Acquisition'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'LE',      2, 'Legal Event'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'CNR',     3, 'Company News Release'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'FR',      4, 'Financial Release'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'USDAFDA', 5, 'USDA/FDA Event'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'MISC',    6, 'Miscellaneous'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'PRCo',   10, 'What''s New at Blue Book Services'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'BBR',    11, 'Reference Guide'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'BBS',    12, 'Blue Book Services'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'BP',     13, 'Blueprints Quarterly Journal'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'BPO',    14, 'Blueprints Online-only Articles '
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'VT',    15, 'Video Tutorials'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'BT',    16, 'BBOS Tips'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'ABI',    17, 'Archived BBOS Insiders'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCode', 'BCE',    18, 'BBOS Consejos en español'

exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCodeTraining', 'VT',    1, 'Video Tutorials'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCodeTraining', 'BT',    2, 'BBOS Tips'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCodeTraining', 'ABI',   3, 'Archived BBOS Insiders'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCodeTraining', 'BCE',   4, 'BBOS Consejos en español'

exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCodeBBS', 'RL',   1, 'Ratings & Listings'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_CategoryCodeBBS', 'M',    2, 'Membership'



exec usp_TravantCRM_CreateDropdownValue 'prpbar_MediaTypeCode', 'Doc',    1, 'Document'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_MediaTypeCode', 'Video',  2, 'Video'
exec usp_TravantCRM_CreateDropdownValue 'prpbar_MediaTypeCode', 'URL',  3, 'Web Page'

EXEC usp_TravantCRM_CreateDropdownValue 'prpbar_Size', 'T', 10, 'Tiny (175 x 100)'
EXEC usp_TravantCRM_CreateDropdownValue 'prpbar_Size', 'S', 20, 'Small (300 x 200)'
EXEC usp_TravantCRM_CreateDropdownValue 'prpbar_Size', 'M', 30, 'Medium (630 x 400)'
EXEC usp_TravantCRM_CreateDropdownValue 'prpbar_Size', 'L', 40, 'Large (900 x 500)'


exec usp_TravantCRM_CreateDropdownValue 'NewsGroupingCode', 'IN', 1, 'What''s New in the Industry'
exec usp_TravantCRM_CreateDropdownValue 'NewsGroupingCode', 'BN', 2, 'What''s New at Blue Book Services'

exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'IN', 1, 'MA'
exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'IN', 1, 'LE'
exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'IN', 1, 'CNR'
exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'IN', 1, 'FR'
exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'IN', 1, 'USDAFDA'
exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'IN', 1, 'MISC'
exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'BN', 1, 'PRCo'
exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'BN', 1, 'BP'
exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'BN', 1, 'BPO'
exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'BN', 1, 'BBR'
exec usp_TravantCRM_CreateDropdownValue 'NewsGrouping', 'BN', 1, 'BBS'

-- DELETE FROM custom_captions WHERE capt_family IN ('PRPublicationUploadDirectory', 'PRCompanyAdUploadDirectory', 'PRCompanyCSImageDirectory')
EXEC usp_TravantCRM_AddCustom_Captions 'Choices', 'PRPublicationUploadDirectory', '/LearningCenter', 0, '\\AZ-NC-BBOS-Q1\LearningCenter'
EXEC usp_TravantCRM_AddCustom_Captions 'Choices', 'PRCompanyAdUploadDirectory', '/Campaigns', 0, '\\AZ-NC-BBOS-Q1\Campaigns'
EXEC usp_TravantCRM_AddCustom_Captions 'Choices', 'PRCompanyCSImageDirectory', '/Campaigns/CS', 0, '\\AZ-NC-BBOS-Q1\Campaigns\CS'

/* pradc_AdCampaignType */
DELETE FROM custom_captions WHERE capt_family = 'pradc_AdCampaignType'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'IA_180x90', 10, 'Button Ad 180x90'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'IA', 20, 'Vertical Banner Ad 180x240'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'IA_960x100', 40, 'Leaderboard Ad 960x100'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'SA', 50, 'Sponsored Advertisement'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'LPA', 60, 'Listing Publicity Advertisement'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'BP', 70, 'Blueprints Advertisement'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PUB', 80, 'Publication Advertisement'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'BBSi', 90, 'BBSi Advertisement'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'BBSiAni', 100, 'BBSi Animated Advertisement'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'BPBDA', 110, 'BP Briefing Digital Advertisement'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'CSG', 120, 'Chain Store Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'CSEU', 125, 'Credit Sheet/Express Update Ad'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'KYCD', 130, 'KYC Digital'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'BBOSSlider', 200, 'BBOS Slider'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PMSHPSQ', 210, 'Square 1 Home Page Ad 300x250'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PMSHPSQ2', 210, 'Square 2 Home Page Ad 300x250'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PMSHPSQ3', 210, 'Square 3 Home Page Ad 300x250'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PMSHPSQ4', 210, 'Square 4 Home Page Ad 300x250'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PMSHPSQ5', 210, 'Square 5 Home Page Ad 300x250'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PMSHPB', 220, 'Leaderboard 1 Home Page Ad 728x90'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PMSHPB2', 220, 'Leaderboard 2 Home Page Ad 728x90'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PMSHPB3', 220, 'Leaderboard 3 Home Page Ad 728x90'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PRNBA_200x167', 230, 'Newsletter Banner Ad 400x334'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PRNBA_580x72', 240, 'Newsletter Leaderboard Ad 1200x144'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'PRNBA_SP', 245, 'Newsletter Sponsored Content'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'BBILA', 250, 'Blue Book Insider Leaderboard Ad'

/* pradc_AdCampaignTypeDigital */
/* NOTE: If any codes are added to this set, make sure that the dbo.ufn_AccountingCodeLookup()
   function handles it from a billing persective.
*/
DELETE FROM custom_captions WHERE capt_family = 'pradc_AdCampaignTypeDigital'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'CSG', 00, 'Chain Store Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'IA', 10, 'Vertical Banner Ad 180x240'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PRNBA_200x167', 30, 'Newsletter Banner Ad 400x334'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PRNBA_580x72', 40, 'Newsletter Leaderboard Ad 1200x144'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PRNBA_SP', 45, 'Newsletter Sponsored Content'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PMSHPB', 50, 'Leaderboard 1 Home Page Ad 728x90'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PMSHPB2', 50, 'Leaderboard 2 Home Page Ad 728x90'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PMSHPB3', 50, 'Leaderboard 3 Home Page Ad 728x90'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PMSHPSQ', 60, 'Square 1 Home Page Ad 300x250'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PMSHPSQ2', 60, 'Square 2 Home Page Ad 300x250'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PMSHPSQ3', 60, 'Square 3 Home Page Ad 300x250'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PMSHPSQ4', 60, 'Square 4 Home Page Ad 300x250'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'PMSHPSQ5', 60, 'Square 5 Home Page Ad 300x250'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'BBILA', 70, 'Blue Book Insider Leaderboard Ad'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'BBOSSlider', 80, 'BBOS Slider'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'BBOSSliderITA', 90, 'BBOS Slider ITA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'CSEU', 100, 'Credit Sheet/Express Update Ad'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'SRLA', 100, 'Search Result Leaderboard Ad'



/* pradcat_SponsoredLinkType */
exec usp_TravantCRM_CreateDropdownValue 'pradcat_SponsoredLinkType', 'SL', 1, 'Sponsored Link'
exec usp_TravantCRM_CreateDropdownValue 'pradcat_SponsoredLinkType', 'RL', 2, 'Related Link'

exec usp_TravantCRM_CreateDropdownValue 'prsuu_UsageTypeCode', 'BP', 9, 'BluePrints Article' /* PRServiceUnitUsage */

/* prebbcd_AssociatedType */

exec usp_TravantCRM_CreateDropdownValue 'prfdbk_FeedbackTypeCode', 'PR', 1, 'Problem Report'
exec usp_TravantCRM_CreateDropdownValue 'prfdbk_FeedbackTypeCode', 'RF', 2, 'Request A New Feature'
exec usp_TravantCRM_CreateDropdownValue 'prfdbk_FeedbackTypeCode', 'CR', 3, 'Change Request'
exec usp_TravantCRM_CreateDropdownValue 'prfdbk_FeedbackTypeCode', 'Q', 4, 'Question'
exec usp_TravantCRM_CreateDropdownValue 'prfdbk_FeedbackTypeCode', 'RULC', 5, 'Suggest Company to Research'
exec usp_TravantCRM_CreateDropdownValue 'prfdbk_FeedbackTypeCode', 'SM', 6, 'Seal Misuse'
exec usp_TravantCRM_CreateDropdownValue 'prfdbk_FeedbackTypeCode', 'GC', 7, 'General Comment'


/* prebbcd_AssociatedType */
exec usp_TravantCRM_CreateDropdownValue 'prebbcd_AssociatedType', 'UL', 1, 'User List'
exec usp_TravantCRM_CreateDropdownValue 'prebbcd_AssociatedType', 'N', 2, 'Note'

/* prelat_AssociatedType */
exec usp_TravantCRM_CreateDropdownValue 'prelat_AssociatedType', 'C', 1, 'Company'
exec usp_TravantCRM_CreateDropdownValue 'prelat_AssociatedType', 'PA', 2, 'Publication Article'

/* prmp_DeliveryCode */
exec usp_TravantCRM_CreateDropdownValue 'prmp_DeliveryCode', 'E', 1, 'Email'
exec usp_TravantCRM_CreateDropdownValue 'prmp_DeliveryCode', 'F', 2, 'Fax'
exec usp_TravantCRM_CreateDropdownValue 'prmp_DeliveryCode', 'AO', 3, 'April/October'
exec usp_TravantCRM_CreateDropdownValue 'prmp_DeliveryCode', 'A', 4, 'April'
exec usp_TravantCRM_CreateDropdownValue 'prmp_DeliveryCode', 'O', 5, 'October'

/* prpay_CreditCardType */
exec usp_TravantCRM_CreateDropdownValue 'prpay_CreditCardType', 'VISA', 1, 'Visa'
exec usp_TravantCRM_CreateDropdownValue 'prpay_CreditCardType', 'MC', 2, 'MasterCard'
exec usp_TravantCRM_CreateDropdownValue 'prpay_CreditCardType', 'AE', 3, 'American Express'
exec usp_TravantCRM_CreateDropdownValue 'prpay_CreditCardType', 'DC', 4, 'Discover Card'

/* prreq_RequestTypeCode */
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'BR1', 1, 'Business Report - Level 1'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'BR2', 1, 'Business Report - Level 2'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'BR3', 1, 'Business Report - Level 3'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'BR4', 1, 'Business Report - Level 4'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'BR5', 1, 'Business Report - Level 5'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'MLE1', 1, 'Marketing List Export - Level 1'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'MLE2', 1, 'Marketing List Export - Level 2'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'MLR1', 1, 'Marketing List Report - Level 1'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'MLR2', 1, 'Marketing List Report - Level 2'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CA', 1, 'Company Analysis'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CAR', 1, 'Company Analysis Report'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CAE', 1, 'Company Analysis Export'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CEC', 1, 'Contact Export - Company Only'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CEH', 1, 'Contact Export - Head Contacts Only'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CEA', 1, 'Contact Export - All Contacts'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CLR', 1, 'Company Listing'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CLRNM', 1, 'Company Listing - Non Member'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'FBBLR', 1, 'Full Blue Book Listing Report'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'MLR', 1, 'Mailing Labels Report'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'QLR', 1, 'Quick List Report'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CDE', 1, 'Company Data Export'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'TES', 1, 'Trade Experience Survey'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'BP', 1, 'Blueprints Article'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'BPO', 1, 'Blueprints Online Article'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'QR', 1, 'Quick List Report'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'QRL', 1, 'Lumber Quick List Report'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CCE', 1, 'Company Contacts Export'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CDEL', 1, 'Lumber Company Data Export'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'CE', 1, 'Contact Export'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'FLR', 1, 'Full Listing Report'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'NR', 1, 'Notes Report'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'RCR', 1, 'Ratings Comparison Report'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'PR', 1, 'Person Report'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'PE', 1, 'Person Export'
exec usp_TravantCRM_CreateDropdownValue 'prreq_RequestTypeCode', 'BBSR', 1, 'Blue Book Score Report'




/* prrc_AssociatedType */
exec usp_TravantCRM_CreateDropdownValue 'prrc_AssociatedType', 'C', 1, 'Company'
exec usp_TravantCRM_CreateDropdownValue 'prrc_AssociatedType', 'PA', 1, 'PRPublicationArticle'
exec usp_TravantCRM_CreateDropdownValue 'prrc_AssociatedType', 'P', 1, 'Person'

/* prsc_SearchType */
exec usp_TravantCRM_CreateDropdownValue 'prsc_SearchType', 'Company', 1, 'Company'
exec usp_TravantCRM_CreateDropdownValue 'prsc_SearchType', 'Person', 1, 'Person'
exec usp_TravantCRM_CreateDropdownValue 'prsc_SearchType', 'Learning', 1, 'Learning Center'
exec usp_TravantCRM_CreateDropdownValue 'prsc_SearchType', 'CompanyUpdate', 1, 'Company Update'
exec usp_TravantCRM_CreateDropdownValue 'prsc_SearchType', 'ClaimActivity', 1, 'Claim Activity'

/* prsat_UserType */
exec usp_TravantCRM_CreateDropdownValue 'prsat_UserType', 'R', 1, 'Registered User'
exec usp_TravantCRM_CreateDropdownValue 'prsat_UserType', 'M', 1, 'Member User'

/* prsatc_CriteriaTypeCode */
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaTypeCode', 'L', 1, 'Location'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaTypeCode', 'CM', 1, 'Commodity'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaTypeCode', 'CL', 1, 'Classification'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaTypeCode', 'P', 1, 'Profile'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaTypeCode', 'LC', 1, 'Learning Center'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaTypeCode', 'H', 1, 'Header'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaTypeCode', 'PP', 1, 'Product Provided'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaTypeCode', 'SP', 1, 'Service Provided'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaTypeCode', 'S', 1, 'Specie'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaTypeCode', 'LSS', 1, 'Local Source'

/* prsatc_CriteriaSubtypeCode */
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'LCN', 1, 'Listing Country'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'LS', 1, 'Listing State'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'LCI', 1, 'Listing City'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'PC', 1, 'Listing Postal Code'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'TM', 1, 'Terminal Market'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'RS', 1, 'Radius Search'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'IT', 1, 'Industry Type'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'CM', 1, 'Commodity'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'CMA', 1, 'Commodity Attribute'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'CL', 1, 'Classification'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'VO', 1, 'Volume'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'BR', 1, 'Brand'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'KW', 1, 'Kew Words'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'PP', 1, 'Product Provided'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'SP', 1, 'Service Provided'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'S', 1, 'Specie'

exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'IEB', 1, 'Include/Exclude/Both'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'TA', 1, 'Total Acres'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'AO', 1, 'Also Operates'
exec usp_TravantCRM_CreateDropdownValue 'prsatc_CriteriaSubtypeCode', 'CO', 1, 'Certified Organic'


/* RelativeDateRange */
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange', '', 1, 'Custom'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange', 'Today', 2, 'Today'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange', 'Yesterday', 3, 'Yesterday'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange', 'This Week', 4, 'This Week'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange', 'Last Week', 5, 'Last Week'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange', 'This Month', 6, 'This Month'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange', 'Last Month', 7, 'Last Month'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange', 'This Quarter', 8, 'This Quarter'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange', 'Last Quarter', 9, 'Last Quarter'


/* RelativeDateRange */
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange2', '', 1, 'Custom'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange2', 'All', 2, 'All'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange2', 'This Week', 4, 'This Week'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange2', 'Last Week', 5, 'Last Week'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange2', 'This Month', 6, 'This Month'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange2', 'Last Month', 7, 'Last Month'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange2', 'This Quarter', 8, 'This Quarter'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange2', 'Last Quarter', 9, 'Last Quarter'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange2', 'This Year', 10, 'This Year'
exec usp_TravantCRM_CreateDropdownValue 'RelativeDateRange2', 'Last Year', 11, 'Last Year'

/* prssatd_CategoryCode */
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'A', 1, 'Address'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'PH', 2, 'Phone'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'WE', 3, 'Email/Web'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'PE', 4, 'Personnel'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'CO', 5, 'Commodity'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'CL', 6, 'Classification'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'BR', 7, 'Brand'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'OT', 8, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'CN', 9, 'Reference List'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'FS', 10, 'Finanacial Statement'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'S', 11, 'Speies'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'SP', 12, 'Services Provided'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'PP', 13, 'Product Provided'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'AR', 14, 'AR Submission'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'LOGO', 15, 'Logo File'
exec usp_TravantCRM_CreateDropdownValue 'prssatd_CategoryCode', 'V', 16, 'Volume'


/* prwsat_AssociatedType */
exec usp_TravantCRM_CreateDropdownValue 'prwsat_AssociatedType', 'C', 1, 'Company'
exec usp_TravantCRM_CreateDropdownValue 'prwsat_AssociatedType', 'P', 1, 'Person'
exec usp_TravantCRM_CreateDropdownValue 'prwsat_AssociatedType', 'PA', 1, 'PublicationArticle'
exec usp_TravantCRM_CreateDropdownValue 'prwsat_AssociatedType', 'UL', 1, 'UserList'

/* prwucd_LabelCode */
exec usp_TravantCRM_CreateDropdownValue 'prwucd_LabelCode', '1', 1, 'Custom Identifier'

/* prwucd_TypeCode */
exec usp_TravantCRM_CreateDropdownValue 'prwucd_AssociatedType', 'C', 1, 'Company'
exec usp_TravantCRM_CreateDropdownValue 'prwucd_AssociatedType', 'P', 2, 'Person'

/* prwucl_TypeCode */
exec usp_TravantCRM_CreateDropdownValue 'prwucl_TypeCode', 'AUS', 1, 'AUS'
exec usp_TravantCRM_CreateDropdownValue 'prwucl_TypeCode', 'CL', 2, 'Reference List'
exec usp_TravantCRM_CreateDropdownValue 'prwucl_TypeCode', 'CU', 3, 'Custom'

/* These are used to control the default names of system created lists */
-- DELETE FROM Custom_Captions WHERE capt_family = 'PRWebUserListName'
exec usp_TravantCRM_CreateDropdownValue 'PRWebUserListName', 'Name_CL', 1, 'Reference List', 'Lista de Referencias'
exec usp_TravantCRM_CreateDropdownValue 'PRWebUserListName', 'Description_CL', 1, 'The enterprise reference list.', 'Lista de Referencias Empresarial'
exec usp_TravantCRM_CreateDropdownValue 'PRWebUserListName', 'Name_AUS', 1, 'Alerts List', 'Lista De Alertas'
exec usp_TravantCRM_CreateDropdownValue 'PRWebUserListName', 'Description_AUS', 1, 'Companies that are automatically monitored.', 'Empresas automaticamente monitoreadas'

/* prwuld_AssociatedType */
exec usp_TravantCRM_CreateDropdownValue 'prwuld_AssociatedType', 'C', 1, 'Company'

/* prwun_AssociatedType */
exec usp_TravantCRM_CreateDropdownValue 'prwun_AssociatedType', 'C', 1, 'Company'
exec usp_TravantCRM_CreateDropdownValue 'prwun_AssociatedType', 'P', 2, 'Person'
exec usp_TravantCRM_CreateDropdownValue 'prwun_AssociatedType', 'PC', 3, 'Personal Contact'

/* prsc_SearchType  */
exec usp_TravantCRM_CreateDropdownValue 'prsc_SearchType', 'Company', 1, 'Company'
exec usp_TravantCRM_CreateDropdownValue 'prsc_SearchType', 'Person', 2, 'Person'
exec usp_TravantCRM_CreateDropdownValue 'prsc_SearchType', 'Learning', 3, 'LearningCenter'
exec usp_TravantCRM_CreateDropdownValue 'prsc_SearchType', 'CreditSheet', 4, 'CreditSheet'

exec usp_TravantCRM_CreateDropdownValue 'LastUnsavedSearch', '1', 1, 'Last Unsaved {0} Search' /* PRWebUserSearchCriteria */


/* Company Search - New Listing Days Old Range Codes */
exec usp_TravantCRM_CreateDropdownValue 'NewListingDaysOld', '1', 1, '1 day'
exec usp_TravantCRM_CreateDropdownValue 'NewListingDaysOld', '7', 2, '1 week'
exec usp_TravantCRM_CreateDropdownValue 'NewListingDaysOld', '14', 3, '2 weeks'
exec usp_TravantCRM_CreateDropdownValue 'NewListingDaysOld', '30', 4, '1 month'
exec usp_TravantCRM_CreateDropdownValue 'NewListingDaysOld', '60', 5, '2 months'
exec usp_TravantCRM_CreateDropdownValue 'NewListingDaysOld', '90', 6, '3 months'
exec usp_TravantCRM_CreateDropdownValue 'NewListingDaysOld', '180', 7, '6 months'
exec usp_TravantCRM_CreateDropdownValue 'NewListingDaysOld', '270', 8, '9 months'
exec usp_TravantCRM_CreateDropdownValue 'NewListingDaysOld', '365', 9, '12 months'

/* Contact Export
	Values must be unique between the contact
	export and company data export.  Use the
	prreq_RequestTypeCode codes to achieve this.
*/

exec usp_TravantCRM_CreateDropdownValue 'ContactExportType', 'CO', 1, 'Contact Export - Company Only'
exec usp_TravantCRM_CreateDropdownValue 'ContactExportType', 'HCO', 2, 'Contact Export - Company and Head Executive'
exec usp_TravantCRM_CreateDropdownValue 'ContactExportType', 'AC', 3, 'Contact Export - All Contacts'

/* Company Data Export
	Values must be unique between the contact
	export and company data export.  Use the
	prreq_RequestTypeCode codes to achieve this.
*/
exec usp_TravantCRM_CreateDropdownValue 'CompanyDataExport', 'CDE', 1, 'Company Data Export'

/* Contact Export Format */
exec usp_TravantCRM_CreateDropdownValue 'ContactExportFormat', 'CSV', 1, 'CSV'
exec usp_TravantCRM_CreateDropdownValue 'ContactExportFormat', 'MSO', 2, 'MS Outlook'

/* Business Report Survey Answers */
exec usp_TravantCRM_CreateDropdownValue 'BRSurveyAnswers', '4', 1, 'Excellent'
exec usp_TravantCRM_CreateDropdownValue 'BRSurveyAnswers', '3', 2, 'Good'
exec usp_TravantCRM_CreateDropdownValue 'BRSurveyAnswers', '2', 3, 'Fair'
exec usp_TravantCRM_CreateDropdownValue 'BRSurveyAnswers', '1', 4, 'Poor'

exec usp_TravantCRM_CreateDropdownValue 'BRSurveyAnswers2', '4', 1, 'Saved Money'
exec usp_TravantCRM_CreateDropdownValue 'BRSurveyAnswers2', '3', 2, 'Saved Time'
exec usp_TravantCRM_CreateDropdownValue 'BRSurveyAnswers2', '2', 3, 'Continued the relationship'
exec usp_TravantCRM_CreateDropdownValue 'BRSurveyAnswers2', '1', 4, 'Discontinued the relationship'

exec usp_TravantCRM_CreateDropdownValue 'BRSurveyAnswers3', 'Y', 1, 'Yes'
exec usp_TravantCRM_CreateDropdownValue 'BRSurveyAnswers3', 'N', 2, 'No'


exec usp_TravantCRM_CreateDropdownValue 'SearchTemplateName', '-100', 1, 'Chilean Produce Handlers' /* PRWebUserSearchCriteria */
exec usp_TravantCRM_CreateDropdownValue 'SearchTemplateName', '-101', 1, 'Chinese Produce Handlers' /* PRWebUserSearchCriteria */
exec usp_TravantCRM_CreateDropdownValue 'SearchTemplateName', '-102', 1, 'E-mail Directory' /* PRWebUserSearchCriteria */
exec usp_TravantCRM_CreateDropdownValue 'SearchTemplateName', '-103', 1, 'Frozen Produce Handlers' /* PRWebUserSearchCriteria */
exec usp_TravantCRM_CreateDropdownValue 'SearchTemplateName', '-104', 1, 'Organic Produce Buyers' /* PRWebUserSearchCriteria */
exec usp_TravantCRM_CreateDropdownValue 'SearchTemplateName', '-105', 1, 'Organic Produce Sellers' /* PRWebUserSearchCriteria */
exec usp_TravantCRM_CreateDropdownValue 'SearchTemplateName', '-106', 1, 'Asian Produce Handlers' /* PRWebUserSearchCriteria */
exec usp_TravantCRM_CreateDropdownValue 'SearchTemplateName', '-107', 1, 'Specialty Produce Handlers' /* PRWebUserSearchCriteria */


EXEC usp_TravantCRM_CreateDropdownValue 'PIKSUtils', 'EncryptionKey', 1, '0O0jql1$'
EXEC usp_TravantCRM_CreateDropdownValue 'PIKSUtils', 'LogoURL', 1, 'https://qaapps.bluebookservices.com/BBSUtils/GetLogo.aspx?LogoFile='

exec usp_TravantCRM_CreateDropdownValue 'BBOS', 'URL', 1, 'https://qaapps.bluebookservices.com/bbos/', 'https://qaapps.bluebookservices.com/bbos/'
exec usp_TravantCRM_CreateDropdownValue 'WebSite', 'URL', 1, 'https://qabbsi.bluebookservices.com/', 'https://qabbsi.bluebookservices.com/'
exec usp_TravantCRM_CreateDropdownValue 'LumberWebSite', 'URL', 1, 'https://qalumber.bluebookservices.com/', 'https://qalumber.bluebookservices.com/'
exec usp_TravantCRM_CreateDropdownValue 'ProduceWebSite', 'URL', 1, 'https://qaproduce.bluebookservices.com/', 'https://qaproduce.bluebookservices.com/'

exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmail', 'Subject', 1, 'Welcome to Blue Book Online Services'
exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmail', 'Communication', 1, 'BBOS Welcome Email, including the user password, has been sent to {0}.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmail', 'Body', 1,
'
<div align="center">
<b>*** CONFIDENTIAL ***</b>
</div>
<p>
Here is your username and password to login to BBOS:<br/>
<b>Username:</b> {1}<br/>
<b>Password:</b> {2}<br/>
</p>

<p align="center"><a href="{0}" target="_blank" style="color:blue;text-decoration:underline;font-weight:bold;">Login to BBOS</a></p>

<b>Popular Membership Features:</b>
<ul>
<li>Use <em><b>Quick Find</b></em> (in the upper-right hand corner of every screen) to search for specific companies.</li>
<li>Use <em><b>Search Companies</b></em> to create prospecting lists. (Ex: Find all buyers or suppliers, with a specific rating, in a geographic area that handle specific products.)</li>
<li><em><b>Search People</b></em> to view industry personnel.</li>
<li>Create <em><b>Watchdog Lists</b></em> to monitor key accounts.</li>
<li>Use <em><b>My Notes</b></em> to record important customer information.</li>
<li>For tips about how to use BBOS, and to learn about important features of your membership, go to Education > <a href="{0}Training.aspx">BBOS Training</a>.
</ul>


<p><b>Further Assistance: </b><br/>
Our Service Associates are available from 7:30 AM - 5:00 PM central time, Monday thru Friday to provide you with assistance. A free webinar is also available for you and your coworkers.</p>


<p><div align=center>
<b>BBOS TERMS & AGREEMENT:</b>
</div></p>
<p>Blue Book Online Services is provided under the terms set forth in the Blue Book Membership and License Agreement.  The login information provided is for your exclusive and confidential use; it is only to be used by the person it was intended for, and should not be given to any other person or organization.</p>
'

UPDATE Custom_Captions SET capt_ES='
<div align="center">
<b>*** CONFIDENCIAL  ***</b>
</div>
<p>
Aquí está su nombre de usuario y contraseña para iniciar sesión en BBOS:<br/>
<b>Nombre de usuario:</b> {1}<br/>
<b>Contraseña:</b> {2}<br/>
</p>
<p align="center"><a href="{0}" target="_blank" style="color:blue;text-decoration:underline;font-weight:bold;">Inicie sesión en BBOS</a></p>
<b>Característica de la membresía popular:</b>
<ul>
<li>Utilice <em><b>Búsqueda rápida</b></em> (en la esquina superior derecha de cada pantalla) para buscar las compañías específicas.</li>
<li>Utilice <em><b>Buscar compañías</b></em> para crear listas de prospectos. (Por ejemplo: Buscar todos los compradores o proveedores, con una clasificación específica, en un área geográfica que maneje productos específicos).</li>
<li><em><b>Buscar personas</b></em> para ver el personal de la industria.</li>
<li>Cree <em><b>Listas de vigilancia</b></em> para supervisar las cuentas clave.</li>
<li>Utilice <em><b>Mis notas</b></em> para registrar información importante del cliente.</li>
<li>ara obtener sugerencias sobre cómo utilizar BBOS, y aprender sobre características importantes de su membresía, vaya a Educación > <a href="{0}Training.aspx">Capacitación de BBOS</a>.
</ul>
<p><b>Asistencia adicional: </b><br/>
Nuestros asociados de servicio están disponibles de 7:30 a. m. a 5:00 p. m. hora central, de lunes a viernes para brindarle asistencia. También contamos con un seminario web gratuito disponible para usted y sus compañeros de trabajo.</p>
<p><div align=center>
<b>TÉRMINOS Y ACUERDO DE BBOS:</b>
</div></p>
<p>Los Servicios en línea de Blue Book se proporcionan para los términos establecidos en el Acuerdo de licencia y membresía de Blue Book. La información de inicio de sesión que se proporciona es para uso exclusivo y confidencial; solamente lo puede utilizar la persona para quien se hizo y no debe otorgarse a ninguna otra persona u organización.</p>'
WHERE Capt_FamilyType='Choices' AND capt_family='BBOSWelcomeEmail' AND capt_Code = 'Body'

UPDATE Custom_Captions SET capt_ES='Bienvenido a los Servicios en línea de Blue Book' WHERE Capt_FamilyType='Choices' AND capt_family='BBOSWelcomeEmail' AND capt_Code = 'Subject'

exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmailTrialNonMember', 'Subject', 1, 'Welcome to Your Blue Book Online Services Trial'
exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmailTrialNonMember', 'Communication', 1, 'BBOS Welcome Email, including the user password, has been sent to {0}.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmailTrialNonMember', 'Body', 1,
'
<div align="center">
<b>*** CONFIDENTIAL ***</b>
</div>
<p>
Here is your username and password to login to BBOS:<br/>
<b>Username:</b> {1}<br/>
<b>Password:</b> {2}<br/>
</p>

<p align="center"><a href="{0}" target="_blank" style="color:blue;text-decoration:underline;font-weight:bold;">Login to BBOS</a></p>


<div align="center">
<b>WELCOME TO TRIAL BBOS:</b>
</div>
<p>Thank you for your interest in Blue Book Services. Your trial membership will allow you to explore the various features of Blue Book membership. With this gratis limited-time offer, you will be provided with the industry''s most accurate, reliable, and timely credit and marketing information.</p>

<b>Popular Membership Features:</b>
<ul>
<li>Use <em><b>Quick Find</b></em> (in the upper-right hand corner of every screen) to search for specific companies.</li>
<li>Use <em><b>Search Companies</b></em> to create prospecting lists. (Ex: Find all buyers or suppliers, with a specific rating, in a geographic area that handle specific products.)</li>
<li><em><b>Search People</b></em> to view industry personnel.</li>
<li>Create <em><b>Watchdog Lists</b></em> to monitor key accounts.</li>
<li>Use <em><b>My Notes</b></em> to record important customer information.</li>
<li>For tips about how to use BBOS, and to learn about important features of your membership, go to Education > <a href="{0}Training.aspx">BBOS Training</a>.
</ul>


<p><b>Further Assistance: </b><br/>
Our Service Associates are available from 7:30 AM - 5:00 PM central time, Monday thru Friday to provide you with assistance. A free webinar is also available for you and your coworkers.</p>


<p><div align=center>
<b>BBOS TERMS & AGREEMENT:</b>
</div></p>
<p>Blue Book Online Services is provided under the terms set forth in the Blue Book Membership and License Agreement.  The login information provided is for your exclusive and confidential use; it is only to be used by the person it was intended for, and should not be given to any other person or organization.</p>
'

delete from Custom_Captions where capt_family = 'BBOSWelcomeEmailTrialMember'
exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmailTrialMember', 'Subject', 1, 'Welcome to Your Blue Book Online Services Trial'
exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmailTrialMember', 'Communication', 1, 'BBOS Welcome Email, including the user password, has been sent to {0}.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmailTrialMember', 'Body', 1,
'
<div align="center">
<b>*** CONFIDENTIAL ***</b>
</div>
<p>
Here is your username and password to login to BBOS:<br/>
<b>Username:</b> {1}<br/>
<b>Password:</b> {2}<br/>
</p>

<p align="center"><a href="{0}" target="_blank" style="color:blue;text-decoration:underline;font-weight:bold;">Login to BBOS</a></p>


<div align="center">
<b>WELCOME TO TRIAL BBOS:</b>
</div>
<p>Upgrading your Blue Book membership will provide you with more features to help you make safe and confident business decisions.  During this trial period we encourage you to explore the more advanced features of BBOS.</p>

<b>Popular Membership Features:</b>
<ul>
<li>Use <em><b>Quick Find</b></em> (in the upper-right hand corner of every screen) to search for specific companies.</li>
<li>Use <em><b>Search Companies</b></em> to create a prospecting lists. (Ex: Find all buyers or suppliers, with a specific rating, in a geographic area that handle specific products.)</li>
<li><em><b>Search People</b></em> to view industry personnel.</li>
<li>Create <em><b>Watchdog Lists</b></em> to monitor key accounts.</li>
<li>Use <em><b>My Notes</b></em> to record important customer information.</li>
<li>For tips about how to use BBOS, and to learn about important features of your membership, go to Education > <a href="{0}Training.aspx">BBOS Training</a>.
</ul>


<p><b>Further Assistance: </b><br/>
Our Service Associates are available from 7:30 AM - 5:00 PM central time, Monday thru Friday to provide you with assistance. A free webinar is also available for you and your coworkers.</p>


<p><div align=center>
<b>BBOS TERMS & AGREEMENT:</b>
</div></p>
<p>Blue Book Online Services is provided under the terms set forth in the Blue Book Membership and License Agreement.  The login information provided is for your exclusive and confidential use; it is only to be used by the person it was intended for, and should not be given to any other person or organization.</p>
'

UPDATE Custom_Captions SET capt_ES='
<div align="center">
<b>*** CONFIDENCIAL  ***</b>
</div>
<p>
Aquí está su nombre de usuario y contraseña para iniciar sesión en BBOS:<br/>
<b>Nombre de usuario:</b> {1}<br/>
<b>Contraseña:</b> {2}<br/>
</p>
<p align="center"><a href="{0}" target="_blank" style="color:blue;text-decoration:underline;font-weight:bold;">Inicie sesión en BBOS</a></p>

<p>
<b>BIENVENIDO A LA PRUEBA DE BBOS:</b><br/>
La actualización de su membresía de Blue Book le proporcionará más características que le ayudarán a tomar decisiones comerciales más seguras y confiables. Durante este período de prueba le motivamos a que explore las características más avanzadas de BBOS.
</p>

<b>Característica de la membresía popular:</b>
<ul>
<li>Utilice <em><b>Búsqueda rápida</b></em> (en la esquina superior derecha de cada pantalla) para buscar las compañías específicas.</li>
<li>Utilice <em><b>Buscar compañías</b></em> para crear listas de prospectos. (Por ejemplo: Buscar todos los compradores o proveedores, con una clasificación específica, en un área geográfica que maneje productos específicos).</li>
<li><em><b>Buscar personas</b></em> para ver el personal de la industria.</li>
<li>Cree <em><b>Listas de vigilancia</b></em> para supervisar las cuentas clave.</li>
<li>Utilice <em><b>Mis notas</b></em> para registrar información importante del cliente.</li>
<li>ara obtener sugerencias sobre cómo utilizar BBOS, y aprender sobre características importantes de su membresía, vaya a Educación > <a href="{0}Training.aspx">Capacitación de BBOS</a>.
</ul>
<p><b>Asistencia adicional: </b><br/>
Nuestros asociados de servicio están disponibles de 7:30 a. m. a 5:00 p. m. hora central, de lunes a viernes para brindarle asistencia. También contamos con un seminario web gratuito disponible para usted y sus compañeros de trabajo.</p>
<p><div align=center>
<b>TÉRMINOS Y ACUERDO DE BBOS:</b>
</div></p>
<p>Los Servicios en línea de Blue Book se proporcionan para los términos establecidos en el Acuerdo de licencia y membresía de Blue Book. La información de inicio de sesión que se proporciona es para uso exclusivo y confidencial; solamente lo puede utilizar la persona para quien se hizo y no debe otorgarse a ninguna otra persona u organización.</p>'
WHERE Capt_FamilyType='Choices' AND capt_family='BBOSWelcomeEmailTrialMember' AND capt_Code = 'Body'

UPDATE Custom_Captions SET capt_ES='Bienvenido a la Prueba de Servicios en línea de Blue Book' WHERE Capt_FamilyType='Choices' AND capt_family='BBOSWelcomeEmailTrialMember' AND capt_Code = 'Subject'


delete from Custom_Captions where capt_family = 'BBOSWelcomeEmailITA'
exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmailITA', 'Subject', 1, 'Welcome to Your Blue Book Online Services Limitado!'
exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmailITA', 'Communication', 1, 'BBOS Welcome Email, including the user password, has been sent to {0}.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSWelcomeEmailITA', 'Body', 1,
'<p>
	<b>Welcome to Blue Book Limitado!</b> A searchable online database of importers of fresh fruit and vegetables in the United States and Canada available exclusively to members of trade associations with agreements in place with Blue Book Services, Inc.
</p>
<p>
	<b>Search for importers by:</b>
	<ul>
		<li>Company name</li>
		<li>Geographic location</li>
		<li>Products handled</li>
	</ul>

<p><b>Here is your username and password to <a href=''{0}'' target=''_blank'' style=''color:blue;text-decoration:underline;font-weight:bold;''>login</a>.</b></p>

<p>
	<b>Username:</b> {1}<br/>
	<b>Password:</b> {2}
</p>

<p>
	<b>Want access to Blue Book Online Services complete database of credit rating and marketing information?</b>  Become a Blue Book Member and find thousands of businesses in all segments of the global produce industry.
</p>

<p>
	<b>Search by:</b>
	<ul>
		<li>Geographic location</li>
		<li>Company Ratings: credit worth, trade practices, & how quickly a company pays</li>
		<li>Claims & lawsuits</li>
		<li>Business classifications:  importers, distributors, wholesalers, etc.</li>
		<li>Industry personnel </li>
		<li>Fruits & vegetables handled & more!</li>
	</ul>
<p>
	<b>To Start Membership, Contact Us:</b> sales@bluebookservices.com or 630.668.3500. Learn more. https://www.producebluebook.com/about-us/espanol/
</p>

<p>
	<b>Need Assistance Navigating Our Web Site?</b>   A free webinar is available to help you.  To schedule it, send an e-mail to customerservice@bluebookservices.com.
</p>

<p>
	<b>Blue Book Online Services Terms & Agreement:</b>   Blue Book Online Services is provided under the terms set forth in the Blue Book Services, Inc. Limited Access Agreement for Trade Associations. The login information provided is for your exclusive and confidential use; it is only to be used by the person it was intended for and should not be given to any other person or organization.
</p>'

UPDATE Custom_Captions SET capt_ES='<p>
	<b>Bienvenido a Blue Book Limitado!</b> Una base de datos en línea de búsqueda de importadores de frutas y hortalizas frescas en los EE. UU. y Canadá, disponible exclusivamente para miembros de asociaciones comerciales que tienen un acuerdo con Blue Book Services, Inc.
</p>
<p>
	<b>Búsqueda de Importadores por: </b>
	<ul>
		<li>Nombre de empresa</li>
		<li>Ubicación geográfica</li>
		<li>Productos que manejan</li>
	</ul>

<p><b>Aquí está su nombre de usuario y contraseña para <a href=''{0}'' target=''_blank'' style=''color:blue;text-decoration:underline;font-weight:bold;''>activar</a>.</b></p>

<p>
	<b>Nombre de Usuario:</b> {1}<br/>
	<b>Contraseña:</b> {2}
</p>

<p>
	<b>¿Desea acceder a la base de datos completa de calificación crediticia y marketing de Blue Book Online Services?</b>  Conviértase en miembro de Blue Book y encuentre información de empresas en todos los segmentos de la industria, a nivel global.
</p>

<p>
	<b>Búsquedas por:</b>
	<ul>
		<li>Ubicación geográfica</li>
		<li>Calificaciones de empresas: capacidad crediticia, ética, y rapidez al pagar</li>
		<li>Actividad de reclamos y demandas</li>
		<li>Clasificaciones de empresas: Importadores, distribuidores, minoristas, etc. </li>
		<li>Personal de la industria</li>
		<li>Producto que manejan y más!</li>
	</ul>
<p>
	<b>Para comenzar su membresía, contáctenos:</b> sales@bluebookservices.com o 630.668.3500. Ver para más detalles: <a href="https://www.producebluebook.com/about-us/espanol/">https://www.producebluebook.com/about-us/espanol/</a>
</p>

<p>
	<b>¿Necesita asistencia para navegar nuestra página?</b> Un seminario webinar gratuito disponible para ayudarle.  Para planificarlo envíe un correo a customerservice@bluebookservices.com
</p>

<p>
	<b>Términos y acuerdo de Blue Book Online Services:</b> Servicios en línea de Blue Book, es proveído bajo los términos establecidos en el Acuerdo de Acceso Limitado de Blue Book Services, Inc., para Asociaciones Comerciales. Su información de usuario es proporcionada para su uso exclusivo y confidencial y solo debe ser utilizado por la persona para la que fue asignada y no debe ser entregado a ninguna otra persona u organización.
</p>' WHERE Capt_FamilyType='Choices' AND capt_family='BBOSWelcomeEmailITA' AND capt_Code = 'Body'


UPDATE Custom_Captions SET capt_ES='Bienvenido a Blue Book Limitado!' WHERE Capt_FamilyType='Choices' AND capt_family='BBOSWelcomeEmailITA' AND capt_Code = 'Subject'


exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKey', 'MaxRequestsForRegDv1', 1, '1'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKey', 'MaxRequestsForRegDv2', 1, '5'

exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'WebSvc', 1, 'GetListingDataForAllCompanies'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'WebSvc', 1, 'GetListingDataForCompanyList'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'WebSvc', 1, 'GetListingDataForWatchdogList'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'WebSvc', 1, 'GetListingDataForCompany'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'RegDv1', 1, 'GetGeneralCompanyData'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'RegDv2', 1, 'GetRatingCompanyData'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'WSEval', 1, 'GetListingDataForAllCompanies'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'WSEval', 1, 'GetListingDataForCompanyList'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'WSEval', 1, 'GetListingDataForWatchdogList'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'WSEval', 1, 'GetListingDataForCompany'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'WSEval', 1, 'GetGeneralCompanyData'
exec usp_TravantCRM_CreateDropdownValue 'PRWebServiceLicenseKeyWM', 'WSEval', 1, 'GetRatingCompanyData'

exec usp_TravantCRM_CreateDropdownValue 'CreditSheetNumerals', '(69)', 1, 'Reported previous report should be revised to read-'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetNumerals', '(71)', 1, 'Following is change in, or addition to, listing information-'

exec usp_TravantCRM_CreateDropdownValue 'prt2_Source', 'MI', 1, 'Manual Investigation'
exec usp_TravantCRM_CreateDropdownValue 'prt2_Source', 'BBScore', 2, 'BBScore Import'
exec usp_TravantCRM_CreateDropdownValue 'prt2_Source', 'NC', 3, 'New Reference'
exec usp_TravantCRM_CreateDropdownValue 'prt2_Source', 'VI', 4, 'Verbal Investigation'
exec usp_TravantCRM_CreateDropdownValue 'prt2_Source', 'Goal', 5, 'Division Goal Related'


exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileIntegrity', '6', 2, 'XXXX'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileIntegrity', '5,6', 3, 'XXX or higher'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileIntegrity', '5', 4, 'XXX'

exec usp_TravantCRM_CreateDropdownValue 'BBOSMobilePay', '8,9', 2, 'A or higher'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobilePay', '6,8,9', 3, 'B or higher'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobilePay', '5,6,8,9', 4, 'C or higher'

-- For the Credit Worth lookups, the capt_us and capt_code are reversed because our value
-- is larger than the capt_code allows.
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileCreditWorth', '500M or higher', 2, '26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileCreditWorth', '100M or higher', 3, '20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileCreditWorth', '5M or higher', 4, '12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42'

exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileCreditWorthL', '500K or higher', 2, '60,61,62,63,65,65,66,67,68,69,70,71,72,73,74,75,76,77,78'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileCreditWorthL', '100K or higher', 3, '54,55,56,57,58,59,60,61,62,63,65,65,66,67,68,69,70,71,72,73,74,75,76,77,78'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileCreditWorthL', '5K or higher', 4, '46,47,48,49,50,51,52,52,54,55,56,57,58,59,60,61,62,63,65,65,66,67,68,69,70,71,72,73,74,75,76,77,78'


exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileNumCurPayReports', '1', 2, 'Greater than 1'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileNumCurPayReports', '2', 3, 'Greater than 2'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileNumCurPayReports', '3', 4, 'Greater than 3'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileNumCurPayReports', '4', 5, 'Greater than 4'

exec usp_TravantCRM_CreateDropdownValue 'BBOSMobilePayIndicator', 'A', 2, 'A'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobilePayIndicator', 'A,B', 3, 'B or higher'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobilePayIndicator', 'A,B,C', 4, 'C or higher'

exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileBBScore', '975', 2, '975 or higher'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileBBScore', '950', 3, '950 or higher'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileBBScore', '900', 4, '900 or higher'
exec usp_TravantCRM_CreateDropdownValue 'BBOSMobileBBScore', '850', 5, '850 or higher'


exec usp_TravantCRM_CreateDropdownValue 'ReferenceURL', 'ReadEvalListings', 1, 'GetPublicationFile.aspx?PublicationArticleID=6215'
exec usp_TravantCRM_CreateDropdownValue 'ReferenceURL', 'ReadEvalListingsL', 1, 'GetPublicationFile.aspx?PublicationArticleID=7733'
exec usp_TravantCRM_CreateDropdownValue 'ReferenceURL', 'RatioDefinitions', 2, 'ratio-definitions/'
exec usp_TravantCRM_CreateDropdownValue 'ReferenceURL', 'MembershipComparison', 3, 'Downloads/Blue Book Services Membership Packages.pdf'
exec usp_TravantCRM_CreateDropdownValue 'ReferenceURL', 'BBScores', 3, 'LearningCenter/BBS/BB Scores.pdf'
exec usp_TravantCRM_CreateDropdownValue 'ReferenceURL', 'EquifaxTerms', 4, '/wp-content/uploads/sites/3/2014/07/Equifax_Definitions.pdf'
exec usp_TravantCRM_CreateDropdownValue 'ReferenceURL', 'Training', 5, 'Training.aspx'


exec usp_TravantCRM_CreateDropdownValue 'EquifaxIntegration', 'Enabled', 0, '1'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxIntegration', 'CacheExpiration', 0, '72'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxIntegration', 'UserID', 0, '13895'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxIntegration', 'Password', 0, 'ApcHnTdxu25ye6p4Wy'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxIntegration', 'CustomerNumber', 0, '276XM00018'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxIntegration', 'SecurityCode', 0, '3EN'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxIntegration', 'ExquifaxURL', 0, 'https://transport5.ec.equifax.com/ists/stspost'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxIntegration', 'ServiceName', 0, 'dptest'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxIntegration', 'EquifaxLogEnabled', 0, '1'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxIntegration', 'LogFilePath', 0, 'D:\Temp\'

exec usp_TravantCRM_CreateDropdownValue 'EquifaxStatusCode', 'R', 0, 'Data Returned'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxStatusCode', 'N', 1, 'No Data Returned'
exec usp_TravantCRM_CreateDropdownValue 'EquifaxStatusCode', 'E', 2, 'Error'


/*
-- PROD
-- The answer to all security questions is "Blue Book Services".
--
DELETE FROM Custom_Captions WHERE capt_Family = 'ExperianIntegration'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'Client_id', 0, '85KiM6w9Oiqy1o9ebSde8bvv93IbNWzT'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'Client_secret', 0, 'AL5tv0WPGSZwLljH'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'username', 0, 'cwallsbluebook'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'password', 0, 'BlueProduce2023!' -- 'ILikwOr@nges'  -- 'H0rseR@dishRules'  -- 'An@ppleADay' --'V3ggiesB@by' --'Blu3Bo0k'  --'Jk78@gfJio' --
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'Authorization', 0, 'not_set'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'subcode', 0, '519618'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'CacheExpiration', 0, '72'

exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_auth', 0, 'https://us-api.experian.com/oauth2/v1/token'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_bankruptcies', 0, 'https://us-api.experian.com/businessinformation/businesses/v1/bankruptcies'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_business_facts', 0, 'https://us-api.experian.com/businessinformation/businesses/v1/facts'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_judgements', 0, 'https://us-api.experian.com/businessinformation/businesses/v1/judgments'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_liens', 0, 'https://us-api.experian.com/businessinformation/businesses/v1/liens'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_trades', 0, 'https://us-api.experian.com/businessinformation/businesses/v1/trades'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_collections', 0, 'https://us-api.experian.com/businessinformation/businesses/v1/collections'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_search', 0, 'https://us-api.experian.com//businessinformation/businesses/v1/search'
*/


-- QA
DELETE FROM Custom_Captions WHERE capt_Family = 'ExperianIntegration'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'Client_id', 0, 't0ld1NvdBzU687kBFifL7YjubDqERxPG'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'Client_secret', 0, 'o5tO1zoCTGShGgn2'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'username', 0, 'cwalls@travant.com'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'password', 0, 'Blu3BookQA2021!'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'Authorization', 0, 'not_set'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'subcode', 0, '0563736'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'CacheExpiration', 0, '72'

exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_auth', 0, 'https://sandbox-us-api.experian.com/oauth2/v1/token'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_bankruptcies', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/bankruptcies'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_business_facts', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_judgements', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/judgments'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_liens', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/liens'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_trades', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/trades'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_collections', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/collections'
exec usp_TravantCRM_CreateDropdownValue 'ExperianIntegration', 'web_endpoint_search', 0, 'https://us-api.experian.com//businessinformation/businesses/v1/search'




exec usp_TravantCRM_CreateDropdownValue 'preqfald_Type', 'A', 2, 'Alert'
exec usp_TravantCRM_CreateDropdownValue 'preqfald_Type', 'E', 2, 'Application Error'

exec usp_TravantCRM_CreateDropdownValue 'BusinessReportSurvey', 'Enabled', 0, '1'
exec usp_TravantCRM_CreateDropdownValue 'BusinessReportSurvey', 'DayInterval', 0, '30'
exec usp_TravantCRM_CreateDropdownValue 'BusinessReportSurvey', 'SurveySubjectLine', 0, 'We Need Your Feedback'

exec usp_TravantCRM_CreateDropdownValue 'BusinessReportSurvey', 'SurveyURL', 0, 'https://www.surveymonkey.com/r/busreportsurvey'
exec usp_TravantCRM_CreateDropdownValue 'BusinessReportSurvey', 'SurveyURL_Lumber', 0, 'https://www.surveymonkey.com/r/Lumber_BRsurvey'

exec usp_TravantCRM_CreateDropdownValue 'BusinessReportSurvey', 'SurveyText', 0,
'<p>Blue Book Services strives to continually provide you with the best resources for your success.  We would like to learn more about your usage of Business Reports, and  specifically the report that you most recently received.  Could you please take a few minutes to complete a satisfaction survey?</p>
<p>Your answers will be held in confidence by Blue Book Services. Please click on the following link to participate:</p>
<p><a href="{0}">{0}</a></p>';

exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '1', 1, 'Company is involved in an acquisition.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '2', 2, 'An agreement in principle has been reached.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '3', 3, 'Company reported assignment of all/certain assets made for the benefit of creditors.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '4', 4, 'A bankruptcy event has occurred.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '5', 5, 'A bankruptcy has been filed with the U.S. Courts. '
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '6', 6, 'A bankruptcy has been filed with the Canadian Courts.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '7', 7, 'This business has closed.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '8', 8, 'The legal structure of this company has changed.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '9', 9, 'This business was recently established.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '10', 10, 'Company (or a portion of the company) has been sold to another individual(s).'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '11', 11, 'Business assets have been sold.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '13', 13, 'Company is offering to compromise or has requested an extension on its current obligations.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '14', 14, 'A significant financial event has occurred.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '15', 15, 'Company was reported indicted.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '16', 16, 'Indictment on company was reported closed.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '17', 17, 'An injunction was issued against company.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '18', 18, 'A judgment was reported on company.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '19', 19, 'A letter of intent involving this company was signed.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '20', 20, 'A lien of public record was entered against company.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '21', 21, 'Company changed its location.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '22', 22, 'A merger involving this company has occurred.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '23', 23, 'A natural disaster has occurred, affecting the operations of this company.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '25', 25, 'A legal action has been taken against this company and/or the principal(s) within this company.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '31', 31, 'Partnership has been dissolved.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '32', 32, 'Reported receiver applied for.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '33', 33, 'Reported receiver appointed.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '37', 37, 'A temporary restraining order was granted against the company.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '39', 39, 'The company has emerged from bankruptcy.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '40', 40, 'Company reportedly discontinued involvement in the lumber industry.'
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetBusinessEventText', '41', 41, 'The company has been released from Canadian Court reorganization.'


exec usp_TravantCRM_CreateDropdownValue 'LumberBizEventCSThreshold', 'Days', 1, '120'
--exec usp_TravantCRM_CreateDropdownValue 'CreditSheetReport', 'LastRunDate', 1, '2009-03-01'

exec usp_TravantCRM_CreateDropdownValue 'prcmal_ReasonCode', 'UE', 1,'User Error'
exec usp_TravantCRM_CreateDropdownValue 'prcmal_ReasonCode', 'PACA', 2, 'PACA'
exec usp_TravantCRM_CreateDropdownValue 'prcmal_ReasonCode', 'DupBBOS', 3, 'Duplicate from BBOS'

exec usp_TravantCRM_CreateDropdownValue 'prlrlb_BatchType', 'L', 1, 'Listing Report'
exec usp_TravantCRM_CreateDropdownValue 'prlrlb_BatchType', 'T', 2, 'Listing Report - Test'

delete from custom_captions where capt_family = 'prlrl_Verbiage'
-- Max line length: 31  Max Line Count: 5
exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'HeaderMsg', 1, 'PLEASE ACT NOW!
REVIEW AND FAX TO 630 344-0388
 '
exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'DeadlineMsg', 1, 'UPCOMING PUBLICATION DEADLINE:
PRINT BLUE BOOK - {0}'

exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'LetterIntro', 1, 'Blue Book Services lists your firm in our credit and marketing guide,
"The Blue Book."  Please FAX, E-MAIL, or MAIL changes to your company''s
listing/personnel, which appear in our print publications and
Blue Book Online Services.  The company information in this letter is
as of {0}.'

exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'NoConnectionListMsg', 1, 'WE HAVE NOT RECEIVED A LIST OF YOUR TRADE REFERENCES.  Please send
us a current list.'
exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'OldConnectionListMsg', 1, 'YOUR TRADE REFERENCE LIST IS DATED {0} -- AN UPDATED LIST IS NECESSARY.'

exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'VolumeMsg', 1, 'Increase your marketing possibilities by providing your Volume Figure.
 Estimated total annual truckloads handled company-wide: _________'

exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'DLPaymentDueMsg', 1, 'DESCRIPTIVE LISTING FACTS, published in the print and electronic Blue Books,
are identified by the hyphen (-) in your listing(s) below. Our records show
payment due on this year''s descriptive listing lines. To insure the continuation
of these important operating facts, PLEASE REMIT: ${0}.  Thank you.'

exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'DLPromotionMsg', 1, 'Customize your listing(s) by adding Descriptive Listing lines at the current
nominal rate of $18.75 per line, billed in February, to be included in the next
two print Blue Books and Blue Book Online Services (BBOS). These lines are
indicated by a hyphen (-) below. Hold payment until you are billed.'

exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'ChangeAuthorizationMsg', 1, 'These changes authorized by (PLEASE PRINT name & e-mail address)
_________________________  _____________________________________

Credit references authorized by (PLEASE PRINT name & e-mail address)
_________________________  _____________________________________'


exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'PersonnelAnnouncementMsg', 1, '            Please Review your Current PERSONNEL DATA!

The "Blue Book Personnel Database" is a comprehensive industry wide
database of personnel, SEPARATE from your listing.

Make any changes, additions or corrections in the tables below; and return
via phone, FAX, E-Mail or mail.  Thank you for including as much detail as
possible, SUCH as start date, title, previous employer''s name.

CHANGES TO PERSONNEL AUTHORIZED BY (PLEASE PRINT)

____________________________.'

exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'AddPrimaryPersonnelHdr', 1, '                        ADDING PRIMARY PERSONNEL'

exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'AddPrimaryPersonnelMsg', 1, 'List below any additional primary personnel including full name, title,
start date and previous employer if known.  Use the reverse side of
this form if necessary.  PLEASE PRINT.

NAMES INCLUDED IN YOUR PERSONNEL DATA ARE NOT AUTOMATICALLY INCLUDED IN
YOUR LISTING. TO ADD PERSONNEL IN YOUR LISTING CIRCLE "Y" BELOW OR SPECIFY
ON THE COPY OF YOUR LISTING INCLUDED IN THIS MAILING.'


exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'ReasonLeftCodes', 1, 'REASON LEFT Codes: R=Retired D=Deceased T=Terminated Q=Quit O=Other/Unknown'

exec usp_TravantCRM_CreateDropdownValue 'prlrl_Verbiage', 'AddPrimaryPersonnelTbl', 1,
'NAME AND TITLE                     DATE STARTED  PREVIOUS EMPLOYER  ADD TO
                                                                    LISTING
_________________________________  ____________  __________________  Y / N

_________________________________  ____________  __________________  Y / N'


--
-- Some of these settings are hard-coded in PRInteraction.js.
--
--exec usp_TravantCRM_CreateDropdownValue 'SSRS', 'URL', 1, 'http://mas1/ReportServer?'
exec usp_TravantCRM_CreateDropdownValue 'SSRS', 'URL', 1, 'http://qareports.bluebookservices.local/ReportServer?'
exec usp_TravantCRM_CreateDropdownValue 'SSRS', 'TESSummaryReport', 2, '/Rating Metrics/TESRequestSummary&CompanyID='
exec usp_TravantCRM_CreateDropdownValue 'SSRS', 'ArchiveInteractionSummary', 2, '/CRMArchive/InteractionsSummary'
exec usp_TravantCRM_CreateDropdownValue 'SSRS', 'ArchiveARAging', 2, '/CRMArchive/ARAgingArchive'



exec usp_TravantCRM_CreateDropdownValue 'PersonTrxExplanation', 'CI', 1, 'Updating contact information.'
exec usp_TravantCRM_CreateDropdownValue 'PersonTrxExplanation', 'NLC', 1, 'This person is no longer connected to BB #'
exec usp_TravantCRM_CreateDropdownValue 'PersonTrxExplanation', 'TC', 1, 'Changing Title.'


exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'Communication', 0, '24'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRAdCampaignAuditTrail', 0, '12'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRAdCampaignAuditTrailSummary', 0, '12'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRARAging', 0, '24'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PREquifaxAuditLog', 0, '12'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRExternalLinkAuditTrail', 0, '12'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRRequest', 0, '12'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRSearchAuditTrail', 0, '12'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRSearchWizardAuditTrail', 0, '12'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRTES', 0, '18'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRTransaction', 0, '24'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRWebAuditTrail', 0, '12'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRWebServiceAuditTrail', 0, '12'
exec usp_TravantCRM_CreateDropdownValue 'ArchiveDataThreshold', 'PRCommunicationLog', 0, '12'

exec usp_TravantCRM_CreateDropdownValue 'CRMLibararyShare', 'CRMLibararyShare', 1, 'https://crm.bluebookservices.local/Library/'


exec usp_TravantCRM_CreateDropdownValue 'MobileDeviceExcludeKeywords', 'iPhone', 1, 'iPhone'
exec usp_TravantCRM_CreateDropdownValue 'MobileDeviceExcludeKeywords', 'iPod', 1, 'iPod'
exec usp_TravantCRM_CreateDropdownValue 'MobileDeviceExcludeKeywords', 'Windows Phone 6.5', 1, 'Windows Phone 6.5'
exec usp_TravantCRM_CreateDropdownValue 'MobileDeviceExcludeKeywords', 'Android', 1, 'Android'
exec usp_TravantCRM_CreateDropdownValue 'MobileDeviceExcludeKeywords', 'iPad', 1, 'iPad'
exec usp_TravantCRM_CreateDropdownValue 'MobileDeviceExcludeKeywords', 'BlackBerry9700', 1, 'BlackBerry9700'
exec usp_TravantCRM_CreateDropdownValue 'MobileDeviceExcludeKeywords', 'BlackBerry 9700', 1, 'BlackBerry 9700'

exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCmdSearchLayout', 'A', 1, 'Alphabetical'
exec usp_TravantCRM_CreateDropdownValue 'prwu_DefaultCmdSearchLayout', 'H', 2, 'Hierarchical'

--DELETE FROM custom_captions WHERE capt_family = 'prattn_ItemCode'; 
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'LRL', 1, 'Listing Report Letter'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'JEP-M', 2, 'Mail Jeopardy Letter'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'JEP-E', 3, 'Electronic Jeopardy Letter'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'BILL', 4,'Billing'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'CSUPD', 5, 'Credit Sheet Update'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'EXUPD', 6, 'Credit Sheet Express Update'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'BOOK-APR', 7, 'Blue Book - April'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'BOOK-UNV', 8, 'Blue Book - University'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'BOOK-F', 9, 'Blue Book - Free'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'BPRINT', 10, 'Blueprints'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'ARD', 11,'AR Aging Data'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'KYCG', 12, 'KYC Guide'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'TES-E', 9, 'Electronic TES Request'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'TES-M', 10, 'Mail TES Request'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'TES-V', 11, 'Verbal TES Request'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'BBSICC', 12, 'BBSI Christmas Card'
exec usp_TravantCRM_CreateDropdownValue 'prattn_ItemCode', 'ADVBILL', 13, 'Advertising Billing' --Defect 7036

exec usp_TravantCRM_CreateDropdownValue 'LRLLetterType', 'Summer', 1, 'Summer'
exec usp_TravantCRM_CreateDropdownValue 'LRLLetterType', 'Winter', 2, 'Winter'

exec usp_TravantCRM_CreateDropdownValue 'BookAddressListType', 'BOOK-APR', 1, 'Blue Book - April'
exec usp_TravantCRM_CreateDropdownValue 'BookAddressListType', 'BOOK-F', 2, 'Blue Book - FREE'
exec usp_TravantCRM_CreateDropdownValue 'BookAddressListType', 'BOOK-UNV', 3, 'Blue Book - University'

exec usp_TravantCRM_CreateDropdownValue 'CreditSheetMarketing', 'PHeader', 1, ''
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetMarketing', 'PMsg', 2, ''
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetMarketing', 'LHeader', 3, ''
exec usp_TravantCRM_CreateDropdownValue 'CreditSheetMarketing', 'LMsg', 4, ''

exec usp_TravantCRM_CreateDropdownValue 'comp_PRReceiveTESCode', 'ARS', 10, 'AR Submitter'

exec usp_TravantCRM_CreateDropdownValue 'comp_PRReceiveTESCode', 'ASKED', 10, 'Company explicitly asked not to receive TES requests'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRReceiveTESCode', 'IRI', 20, 'Known to intentionally respond inaccurately'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRReceiveTESCode', 'NA', 30, 'TES requests not applicable for this firm'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRReceiveTESCode', 'NR', 40, 'Never responds to TES requests'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRReceiveTESCode', 'RL', 50, 'RL Investigation Only'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRReceiveTESCode', 'PNR', 55, 'Partial Non-Responder'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRReceiveTESCode', 'PSS', 60, 'Postal Service Suspended'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRReceiveTESCode', 'NEF', 65, 'TES Conversion - No Email Found'
exec usp_TravantCRM_CreateDropdownValue 'comp_PRReceiveTESCode', 'OTHER', 70, 'Other'


exec usp_TravantCRM_CreateDropdownValue 'TESEmail', 'ResponseURL', 1, 'TradeExperienceSurvey.aspx?Key={0}'
exec usp_TravantCRM_CreateDropdownValue 'TESEmail', 'Subject', 2, 'Trade Survey - We Need Your Feedback'
exec usp_TravantCRM_CreateDropdownValue 'TESEmail', 'Body', 3, '
<p>Your feedback on your trading partners is important. Please provide information on your trade experiences by rating the companies below.</p>
<p style="margin-top: 2.5em; margin-bottom: 0em;" ></p>
<table align="center" style="display:{4}" >
    <tr>
        <td style="background-color: #68AE00; border: none; color: white; padding: 10px 24px; text-align: center;  font-size: 14px; border-radius: 4px; min-width:100px;">
            <a href="{1}" target="_blank" style="color:white;text-decoration: none;font-weight:bold; vertical-align:central;" >{3}</a>
        </td>
    </tr>
</table>
{2}
<table align="center">
    <tr>
        <td style="background-color: #68AE00; border: none; color: white; padding: 10px 24px; text-align: center;  font-size: 14px; border-radius: 4px; min-width:100px;">
            <a href="{1}" target="_blank" style="color:white;text-decoration: none;font-weight:bold; vertical-align:central;" >{3}</a>
        </td>
    </tr>
</table>
<p style="margin-top: 0em; margin-bottom: 2.5em;" ></p>
<p>Your feedback is always confidential and your participation is vital.  Your responses keep Blue Book ratings up-to-date and reliable.</p>
<p>If these survey(s) should be filled out by a coworker, please forward this e-mail to the appropriate person within your organization. Please do NOT forward this e-mail to an industry colleague.</p>
'

exec usp_TravantCRM_CreateDropdownValue 'TESEmail', 'Subject_Long', 4, 'Rate {0} and {1} other {2}.  Response needed.'
exec usp_TravantCRM_CreateDropdownValue 'TESEmail', 'Subject_Short', 5, 'Rate {0}.  Response needed.'


exec usp_TravantCRM_CreateDropdownValue 'prvict_CallDisposition', 'NA', 1, 'No Answer'
exec usp_TravantCRM_CreateDropdownValue 'prvict_CallDisposition', 'WN', 2, 'Wrong Number'
exec usp_TravantCRM_CreateDropdownValue 'prvict_CallDisposition', 'CB', 3, 'Call Back'
exec usp_TravantCRM_CreateDropdownValue 'prvict_CallDisposition', 'LM', 4, 'Left Message'
exec usp_TravantCRM_CreateDropdownValue 'prvict_CallDisposition', 'SF', 5, 'Sent TES Form'
exec usp_TravantCRM_CreateDropdownValue 'prvict_CallDisposition', 'WR', 6, 'Does Not Want To Respond.'
exec usp_TravantCRM_CreateDropdownValue 'prvict_CallDisposition', 'NE', 7, 'Not Eligible for Verbal Investigation'

exec usp_TravantCRM_CreateDropdownValue 'prci_Timezone', 'EST', 1, 'EST'
exec usp_TravantCRM_CreateDropdownValue 'prci_Timezone', 'CST', 2, 'CST'
exec usp_TravantCRM_CreateDropdownValue 'prci_Timezone', 'MST', 3, 'MST'
exec usp_TravantCRM_CreateDropdownValue 'prci_Timezone', 'PST', 4, 'PST'
exec usp_TravantCRM_CreateDropdownValue 'prci_Timezone', 'PST+1', 5, 'PST+1'
exec usp_TravantCRM_CreateDropdownValue 'prci_Timezone', 'PST+2', 6, 'PST+2'


exec usp_TravantCRM_CreateDropdownValue 'prcr_InvestigationType', 'M', 1, 'Manual'
exec usp_TravantCRM_CreateDropdownValue 'prcr_InvestigationType', 'V', 2, 'Verbal'

exec usp_TravantCRM_CreateDropdownValue 'prvi_Status', 'O', 1, 'Open'
exec usp_TravantCRM_CreateDropdownValue 'prvi_Status', 'C', 2, 'Closed'


exec usp_TravantCRM_CreateDropdownValue 'ExpiredVIEmail', 'Subject', 1, 'Verbal Investigation Expired'
exec usp_TravantCRM_CreateDropdownValue 'ExpiredVIEmail', 'Body', 2, '
<html><body>
The {1} verbal investigation on company {0} has been closed because the target completion date has passed.
</body></html>'

exec usp_TravantCRM_CreateDropdownValue 'TargetReachedVIEmail', 'Subject', 1, 'Verbal Investigation Targets Reached'
exec usp_TravantCRM_CreateDropdownValue 'TargetReachedVIEmail', 'Body', 2, '
<html><body>
The {1} verbal investigation on company {0} has been closed because the target responses have been reached.
</body></html>'

exec usp_TravantCRM_CreateDropdownValue 'ClosedVIEmail', 'Subject', 1, 'Verbal Investigation Closed'
exec usp_TravantCRM_CreateDropdownValue 'ClosedVIEmail', 'Body', 2, '
<html><body>
The {1} verbal investigation on company {0} has been closed.
</body></html>'


--DELETE FROM custom_captions WHERE capt_family = 'pradc_AdSize';
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize', 'Full', 1, 'Full Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize', 'TwoThirds', 2, '2/3 Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize', 'Half', 3, '1/2 Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize', 'Third', 4, '1/3 Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize', 'Sixth', 5, '1/6 Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize', 'Ninth', 6, '1/9 Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize', 'HalfSpread', 7, '1/2 Page Spread'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize', 'FullSpread', 8, 'Full Page Spread'
--SELECT * FROM custom_captions WHERE capt_family = 'pradc_AdSize' ORDER BY capt_order;

--DELETE FROM custom_captions WHERE capt_family = 'pradc_AdSize_Curr';
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize_Curr', 'Full', 1, 'Full Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize_Curr', 'TwoThirds', 2, '2/3 Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize_Curr', 'Half', 3, '1/2 Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize_Curr', 'Third', 4, '1/3 Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize_Curr', 'Sixth', 5, '1/6 Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize_Curr', 'HalfSpread', 7, '1/2 Page Spread'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize_Curr', 'FullSpread', 8, 'Full Page Spread'
--SELECT * FROM custom_captions WHERE capt_family = 'pradc_AdSize_Curr' ORDER BY capt_order;

--DELETE FROM custom_captions WHERE capt_family = 'pradc_AdSize_KYC';
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize_KYC', 'Full', 1, 'Full Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize_KYC', 'TwoThirds', 2, '2/3 Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdSize_KYC', 'Third', 4, '1/3 Page'
--SELECT * FROM custom_captions WHERE capt_family = 'pradc_AdSize_KYC' ORDER BY capt_order;

exec usp_TravantCRM_CreateDropdownValue 'pradc_AdColor', 'One', 1, 'Black/White'
exec usp_TravantCRM_CreateDropdownValue 'pradc_AdColor', 'Four', 2, 'Four Color'

--DELETE FROM custom_captions WHERE capt_family = 'pradc_Placement';
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'IFC',       10, 'Inside Front Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'Page1',     20, '1st Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'Page3',     30, '3rd Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'PT5',		35, '5th Page'  -- Renamed from "5th Pub Title"
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'INTRO7',	37, '7th Page'  -- Renamed from "7th Intro"
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'Page9',		39, '9th Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', '5thP',      40, '5th Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'CEOP',      45, 'CEO Perspective'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'FG',        47, 'First Glance'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'CSL1',      46, 'Certificate Sec Location 1'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'CSL2',      47, 'Certificate Sec Location 2'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'CSL3',      48, 'Certificate Sec Location 3'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'IF',		55, 'Insert Front'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'IB',		56, 'Insert Back'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'LCS',       50, 'Center Left'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'RCS',       60, 'Center Right'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'CS',        70, 'Center Spread'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'CR',        80, 'Content Related'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'Any',       90, 'General'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'HSL',      120, 'Insert Front'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'HSR',      130, 'Insert Back'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'LHS',      135, 'Left of Insert'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'RHS',      136, 'Right of Insert'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'IBC',      150, 'Inside Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'OBC',      160, 'Outside Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'Spec',     170, 'Special'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'PamelaPick',  175, 'Pamela''s Picks'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'FoodForThought',  180, 'Food For Thought'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'BD',       148, 'Barn Door'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'KYCPage1', 300, 'KYC Page 1'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'KYCPage2', 310, 'KYC Page 2'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'KYCPage3', 315, 'KYC Page 3'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'BC',       330, 'Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'INTRO',    331, 'Introduction'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'TP',       332, 'Title Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'O',        340, 'Other'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'VBA',      190, 'Vertical Banner Ad'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'TRADG',    191, '9th Rt of Trade Guidelines TOC'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'TRANSG',   192, 'Rt of Trans Guidelines TOC'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'SELR',     193, 'Select References'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'SD1',	   194, 'Rejected Ship Dir #1'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'SD2',	   195, 'Rejected Ship Dir #2'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'SD3',	   196, 'Rejected Ship Dir #3'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'SD4',	   197, 'Rejected Ship Dir #4'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'SD5',	   198, 'Rejected Ship Dir #5'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'RTMFMTP',  200, 'Rt of TM/FM Dir title page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'RSRTOC',   210, 'Rt of Select References TOC'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'BTN',  160, 'By the Numbers'

--DELETE FROM custom_captions WHERE capt_family = 'pradc_PlacementBP';
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'Any',    10, 'General'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'CR',     20, 'Content Related'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'Page1',  30, '1st Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'Page3',  40, '3rd Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', '5thP',   50, '5th Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'CEOP',   60, 'CEO Perspective'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'FG',	  70, 'First Glance'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'HSL',   100, 'Insert Front'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'HSR',   110, 'Insert Back'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'LHS',      135, 'Left of Insert'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'RHS',      136, 'Right of Insert'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'IFC',   120, 'Inside Front Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'IBC',   130, 'Inside Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'OBC',   140, 'Outside Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'PamelaPick',  145, 'Pamela''s Picks'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'FoodForThought',  147, 'Food For Thought'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'BD',  148, 'Barn Door'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'Spec',  150, 'Special'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'BTN',  160, 'By the Numbers'



--DELETE FROM custom_captions WHERE capt_family = 'pradc_PlacementPub'; 
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'KYCPage1', 10, 'KYC Page 1'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'KYCPage2', 20, 'KYC Page 2'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'IFC',      30, 'Inside Front Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'Page1',    40, '1st Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'Page3',    45, '3rd Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'CSL1',    46, 'Certificate Sec Location 1'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'CSL2',    47, 'Certificate Sec Location 2'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'CSL3',    48, 'Certificate Sec Location 3'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'IBC',      50, 'Inside Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'BC',       60, 'Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'VBA',        70, 'Vertical Banner Ad'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementPub', 'O',        999, 'Other'

--DELETE FROM custom_captions WHERE capt_family = 'pradc_PlacementKYC';
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'KYCPage1', 10, 'KYC Page 1'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'KYCPage2', 20, 'KYC Page 2'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'KYCPage3', 25, 'KYC Page 3'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'IFC',      30, 'Inside Front Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'Page1',    40, '1st Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'Page3',    45, '3rd Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'CSL1',    46, 'Certificate Sec Location 1'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'CSL2',    47, 'Certificate Sec Location 2'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'CSL3',    48, 'Certificate Sec Location 3'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'IF',    60, 'Insert Front'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'IB',    70, 'Insert Back'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'LHS',      80, 'Left of Insert'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'RHS',      90, 'Right of Insert'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'IBC',   150, 'Inside Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'OBC',   160, 'Outside Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'INTRO',    170, 'Introduction'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'TP',       180, 'Title Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementKYC', 'O',        340, 'Other'


--DELETE FROM custom_captions WHERE capt_family = 'pradc_PlacementTT';
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'IFC',			10, 'Inside Front Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'Page1',		20, '1st Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'Page3',		30, '3rd Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'PT5',			35, '5th Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'INTRO7',		37, '7th Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'Page9',		39, '9th Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'TRADG',		40, '9th Rt of Trade Guidelines TOC'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'TRANSG',		50, 'Rt of Trans Guidelines TOC'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'SD1',			60, 'Rejected Ship Dir #1'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'SD2',			61, 'Rejected Ship Dir #2'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'SD3',			62, 'Rejected Ship Dir #3'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'SD4',			63, 'Rejected Ship Dir #4'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'SD5',			64, 'Rejected Ship Dir #5'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'RTMFMTP',		66, 'Rt of TM/FM Dir title page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'RSRTOC',		68, 'Rt of Select References TOC'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'IBC',			70, 'Inside Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'OBC',			80, 'Outside Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementTT', 'Any',			90, 'General'


--DELETE FROM custom_captions WHERE capt_family = 'pradc_PremiumPlacement';
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', 'IFC',    10, 'Inside Front Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', 'Page1',  20, '1st Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', 'Page3',  30, '3rd Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', '5thP',   40, '5th Page'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', 'LHS',   100, 'Left of Heavy Stock'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', 'RHS',   110, 'Right of Heavy Stock'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', 'HSL',   120, 'Heavy Stock Front'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', 'HSR',   130, 'Heavy Stock Back'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', 'HS',    140, 'Heavy Stock'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', 'IBC',   150, 'Inside Back Cover'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PremiumPlacement', 'OBC',   160, 'Outside Back Cover'

--DELETE FROM custom_captions WHERE capt_family = 'pradc_Orientation';
exec usp_TravantCRM_CreateDropdownValue 'pradc_Orientation', 'H', 10, 'Horizontal'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Orientation', 'HS', 20, 'Horizontal Square'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Orientation', 'V', 30, 'Vertical'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Orientation', 'VT', 40, 'Vertical Tower'

--DELETE FROM custom_captions WHERE capt_family = 'pradc_GraphicArtists';
exec usp_TravantCRM_CreateDropdownValue 'pradc_GraphicArtists', 'psd', 1, 'Paul Davis'
exec usp_TravantCRM_CreateDropdownValue 'pradc_GraphicArtists', 'meg', 2, 'Marsha Garceau'
exec usp_TravantCRM_CreateDropdownValue 'pradc_GraphicArtists', 'outside', 2, 'Outside'
exec usp_TravantCRM_CreateDropdownValue 'pradc_GraphicArtists', 'freelancer', 2, 'Freelancer'

exec usp_TravantCRM_CreateDropdownValue 'pradc_CreativeStatus', 'PIC', 1, 'Pending In-house Creation'
exec usp_TravantCRM_CreateDropdownValue 'pradc_CreativeStatus', 'POC', 2, 'Pending Outside Creative'
exec usp_TravantCRM_CreateDropdownValue 'pradc_CreativeStatus', 'PPSI', 3, 'Pending In House Edits'
exec usp_TravantCRM_CreateDropdownValue 'pradc_CreativeStatus', 'PCA', 4, 'Pending Customer Approval'
exec usp_TravantCRM_CreateDropdownValue 'pradc_CreativeStatus', 'NACM', 5, 'Pending Ad Copy/Materials '
exec usp_TravantCRM_CreateDropdownValue 'pradc_CreativeStatus', 'A', 6, 'Approved By Customer'

-- DELETE FROM custom_captions WHERE capt_family = 'pradc_BlueprintsEdition';
-- SELECT * FROM  custom_captions WHERE capt_family = 'pradc_BlueprintsEdition' ORDER BY capt_order
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202501', 852, '2025 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202503', 853, '2025 March';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202505', 854, '2025 May';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202507', 855, '2025 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202509', 856, '2025 September';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202511', 857, '2025 November';


EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202401', 858, '2024 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202403', 859, '2024 March';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202405', 860, '2024 May';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202407', 861, '2024 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202409', 862, '2024 September';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202411', 863, '2024 November';

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202301', 864, '2023 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202303', 865, '2023 March';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202305', 866, '2023 May';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202307', 867, '2023 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202309', 868, '2023 September';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202311', 869, '2023 November';

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202201', 870, '2022 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202203', 871, '2022 March';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202205', 872, '2022 May';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202207', 873, '2022 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202209', 874, '2022 September';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202211', 875, '2022 November';

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202101', 878, '2021 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202103', 879, '2021 March';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202105', 880, '2021 May';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202107', 881, '2021 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202109', 882, '2021 September';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202111', 883, '2021 November';

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202001', 885, '2020 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202003', 886, '2020 March';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202005', 887, '2020 May';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202007', 888, '2020 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202009', 889, '2020 September';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '202011', 890, '2020 November';

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201901', 892, '2019 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201904', 894, '2019 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201907', 896, '2019 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201910', 898, '2019 October';

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201801', 901, '2018 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201804', 902, '2018 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201807', 903, '2018 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201810', 904, '2018 October';

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201701', 905, '2017 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201704', 906, '2017 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201707', 907, '2017 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201710', 908, '2017 October';

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201601', 909, '2016 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201604', 910, '2016 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201607', 911, '2016 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201610', 912, '2016 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201501', 913, '2015 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201504', 914, '2015 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201507', 915, '2015 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201510', 916, '2015 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201401', 917, '2014 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201404', 918, '2014 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201407', 919, '2014 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201410', 920, '2014 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201301', 921, '2013 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201304', 922, '2013 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201307', 923, '2013 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201310', 924, '2013 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201201', 925, '2012 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201204', 926, '2012 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201207', 927, '2012 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201210', 928, '2012 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201101', 929, '2011 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201104', 930, '2011 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201107', 931, '2011 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201110', 932, '2011 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201001', 933, '2010 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201004', 934, '2010 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201007', 935, '2010 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '201010', 936, '2010 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200901', 937, '2009 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200904', 938, '2009 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200907', 939, '2009 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200910', 940, '2009 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200801', 941, '2008 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200804', 942, '2008 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200807', 943, '2008 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200810', 944, '2008 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200701', 945, '2007 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200704', 946, '2007 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200707', 947, '2007 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200710', 948, '2007 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200601', 949, '2006 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200604', 950, '2006 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200607', 951, '2006 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200610', 952, '2006 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200501', 953, '2005 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200504', 954, '2005 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200507', 955, '2005 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200510', 956, '2005 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200401', 957, '2004 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200404', 958, '2004 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200407', 959, '2004 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200410', 960, '2004 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200301', 961, '2003 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200304', 962, '2003 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200307', 963, '2003 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200310', 964, '2003 October';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200201', 965, '2002 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200204', 966, '2002 April';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200207', 967, '2002 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition', '200210', 968, '2002 October';

-- DELETE FROM custom_captions WHERE capt_family = 'pradc_BlueprintsEdition_Curr';
-- SELECT * FROM  custom_captions WHERE capt_family = 'pradc_BlueprintsEdition_Curr' ORDER BY capt_order
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202501', 852, '2025 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202503', 853, '2025 March';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202505', 854, '2025 May';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202507', 855, '2025 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202509', 856, '2025 September';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202511', 857, '2025 November';


EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202401', 858, '2024 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202403', 859, '2024 March';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202405', 860, '2024 May';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202407', 861, '2024 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202409', 862, '2024 September';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202411', 863, '2024 November';

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202301', 864, '2023 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202303', 865, '2023 March';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202305', 866, '2023 May';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202307', 867, '2023 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202309', 868, '2023 September';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202311', 869, '2023 November';

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202201', 878, '2022 January';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202203', 879, '2022 March';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202205', 880, '2022 May';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202207', 881, '2022 July';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202209', 882, '2022 September';
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_BlueprintsEdition_Curr', '202211', 883, '2022 November';




exec usp_TravantCRM_CreateDropdownValue 'pradc_Section', 'SL', 1, 'Spotlight'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Section', 'I', 2, 'Journal'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Section', 'S', 3, 'Supplement'
--exec usp_TravantCRM_CreateDropdownValue 'pradc_Section', 'NIB', 4, 'New in Blue'
--exec usp_TravantCRM_CreateDropdownValue 'pradc_Section', 'Dir', 5, 'Directory'
--exec usp_TravantCRM_CreateDropdownValue 'pradc_Section', 'EB', 6, 'Exchange Bulletin'
--exec usp_TravantCRM_CreateDropdownValue 'pradc_Section', 'KYC', 7, 'Know Your Commodity'

exec usp_TravantCRM_CreateDropdownValue 'BBOSTESRequestGridPageSize', '5', 1, '5 per page'
exec usp_TravantCRM_CreateDropdownValue 'BBOSTESRequestGridPageSize', '10', 2, '10 per page'
exec usp_TravantCRM_CreateDropdownValue 'BBOSTESRequestGridPageSize', '25', 3, '25 per page'
exec usp_TravantCRM_CreateDropdownValue 'BBOSTESRequestGridPageSize', '9999999', 4, 'All'

exec usp_TravantCRM_CreateDropdownValue 'PayIndicatorDescription', 'A', 1, 'Pay Reported Mostly Within Terms'
exec usp_TravantCRM_CreateDropdownValue 'PayIndicatorDescription', 'B', 2, 'Pay Reported Generally Within Terms'
exec usp_TravantCRM_CreateDropdownValue 'PayIndicatorDescription', 'C', 3, 'Pay Reported Variable'
exec usp_TravantCRM_CreateDropdownValue 'PayIndicatorDescription', 'D', 4, 'Pay Reported Generally Beyond Terms'
exec usp_TravantCRM_CreateDropdownValue 'PayIndicatorDescription', 'E', 5, 'Pay Reported Mostly Beyond Terms'
exec usp_TravantCRM_CreateDropdownValue 'PayIndicatorDescription', 'None', 99, 'No Pay Indicator Reported'

/*
--DELETE FROM Custom_Captions WHERE capt_family = 'pradc_PlannedSectionAll'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '100', 50, 'Atlanta Spotlight'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '1', 100, 'Boston Terminal Market & Area'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '101', 150, 'CA/OR/WA Cherries Spotlight'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '2', 200, 'California Grapes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '3', 300, 'Canada'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '4', 400, 'Chicago Market & Area'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '5', 500, 'Detroit Market & Area'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '50', 550, 'Directory: Figs'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '6', 600, 'Directory: Orange/GF/Mand/Tangerines/Tangelos'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '7', 700, 'Directory: Peppers (Bell)'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '8', 800, 'Directory: Strawberries'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '9', 900, 'Directory: Tomatoes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '10', 1000, 'Hunts Point (New York) Terminal Market'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', 'KYCS', 1010, 'KYC Sponsor'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', 'KYCB', 1020, 'KYC - Commodity Basics'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '30', 1050, 'KYC: Apples'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '31', 1075, 'KYC: Avocados'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '13', 1100, 'KYC: Carrots'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '55', 1125, 'KYC: Kiwi'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '11', 1150, 'KYC: Melons'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '14', 1200, 'KYC: Mushrooms'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '103', 1225, 'KYC: Okra'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '36', 1250, 'KYC: Onions'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '102', 1275, 'KYC: Snow Peas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '12', 1300, 'KYC: Sweet Potato'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '38', 1400, 'KYC: Tomatoes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '104', 1425, 'Louisiana Spotlight'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '33', 1450, 'Montreal'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '15', 1500, 'New in Blue'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '16', 1600, 'Nogales, AZ'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '17', 1700, 'Northwest Potatoes & Onions'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '37', 1750, 'Potatoes Shippers (WA, OR, CO, ID, ND, WI, MN, ME)'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '18', 1800, 'Philadelphia Terminal Market'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '34', 1850, 'Process/Packaging/Fresh Cut/Suppliers'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '56', 1860, 'Produce Showcase: Winter/Spring'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '57', 1870, 'Produce Showcase: Spring/Summer'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '58', 1880, 'Produce Showcase: Summer/Fall'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '59', 1890, 'Produce Showcase: Fall/Winter'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '19', 1900, 'Salinas, CA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '20', 2000, 'South Jersey'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '106', 2012, 'Southern California'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '35', 2025, 'St. Louis/Cinnci/Indy Receivers Spotlight'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '29', 2050, 'Supplement CA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '21', 2100, 'Supplement: GA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '22', 2200, 'Supplement: Hispanic'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '32', 2250, 'Supplement: TX'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '23', 2300, 'Supplement: Transportation'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '24', 2400, 'Supplement: Import/Export'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '25', 2500, 'Suppliers Directory/Supplement'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '26', 2600, 'TM/FM Milestone Anniversary Page'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '27', 2700, 'Toronto Terminal Market & Area'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '105', 2750, 'WA/OR/ID/MI Apples Spotlight'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '28', 2800, 'Washington DC/Maryland'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '200', 100, 'Commodity: Apples'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '201', 200, 'Commodity: Cherries'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '202', 300, 'Commodity: Grapes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '203', 400, 'Commodity: Onions & Potatoes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '204', 500, 'Exchange Bulletin'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '205', 600, 'Function: Packagers / Processors / Fresh Cut / Suppliers'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '206', 700, 'Function: Potato Shippers'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '207', 800, 'Function: Receivers'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '208', 900, 'Function: TM/FM Milestone'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '209', 1000, 'KYC - Commodity Basics'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '210', 1100, 'KYC Sponsor'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '211', 1200, 'Market & Area: Atlanta, GA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '212', 1300, 'Market & Area: Boston, MA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '213', 1400, 'Market & Area: Chicago, IL'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '214', 1500, 'Market & Area: Detroit, MI'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '215', 1600, 'Market & Area: Florida Wholesale Markets'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '216', 1700, 'Market & Area: Montreal, QC'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '217', 1800, 'Market & Area: New York, NY'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '218', 1900, 'Market & Area: Philadelphia, PA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '219', 2000, 'Market & Area: Toronto, ON'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '220', 2100, 'New In Blue'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '221', 2150, 'On the Job'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '222', 2200, 'Region: Canada'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '223', 2300, 'Region: Dallas, TX'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '224', 1250, 'Market & Area: Baltimore, MD'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '225', 2500, 'Region: Jacksonville, FL'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '226', 2600, 'Region: Louisiana'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '227', 2700, 'Region: Miami, FL'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '228', 2800, 'Region: Midwest'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '229', 2900, 'Region: Nogales, AZ'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '230', 3000, 'Region: Salinas, CA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '231', 3100, 'Region: South Jersey'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '232', 3200, 'Region: Southern CA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '233', 3300, 'Spotlight Focus'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '234', 3400, 'Supplement Focus'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '235', 3500, 'Supplement: CA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '236', 3600, 'Supplement: Canada'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '237', 3700, 'Supplement: GA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '238', 3800, 'Supplement: Hispanic'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '239', 3900, 'Supplement: Import/Export'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '240', 4000, 'Supplement: Transportation'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '241', 4100, 'Supplement: TX'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '242', 4200, 'Top Topics' -- was Top Topics Sponsor (Spread)
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '243', 2950, 'Region: Rio Grande Valley, TX'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSectionAll', '244', 3950, 'Supplement: Ontario, Canada'
*/


/*261
  This is the master list used to display on view and list pages.  Update this list and
  also the pradc_PlannedSection_Curr list
*/
--DELETE FROM Custom_Captions WHERE capt_family = 'pradc_PlannedSection'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '200', 100, 'Apples'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '300', 120, 'Avocados'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '250', 200, 'Berries'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '252', 35, 'Carrots'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '201', 200, 'Cherries'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '255', 400, 'Citrus'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '202', 300, 'Grapes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '301', 70, 'Lemons & Limes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '257', 75, 'Lettuce'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '258', 77, 'Melons'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '203', 400, 'Onions & Potatoes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '260', 700, 'Organics'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '261', 95, 'Peppers'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '303', 710, 'Root Vegetables'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '304', 720, 'Tomatoes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '204', 500, 'Exchange Bulletin'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '205', 600, 'Packagers / Processors / Fresh Cut / Suppliers'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '206', 700, 'Potato Shippers'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '207', 800, 'Receivers'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '208', 900, 'TM/FM Milestone'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '308', 950, 'TM Spotlight Advertorial'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '209', 1000, 'KYC - Commodity Basics'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '210', 1100, 'KYC Sponsor'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '211', 1200, 'Georgia'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '212', 1300, 'Boston'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '307', 1350, 'California'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '213', 1400, 'Chicago'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '214', 1500, 'Detroit'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '215', 1600, 'Florida'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '265', 1700, 'Los Angeles'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '216', 1700, 'Montreal'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '217', 1800, 'New York'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '218', 1900, 'Philly'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '219', 2000, 'Toronto, ON'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '220', 2100, 'New In Blue'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '221', 2150, 'On the Job'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '222', 2200, 'Canada'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '223', 2300, 'Dallas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '224', 1250, 'Maryland' --Was Baltimore
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '225', 2500, 'Jacksonville'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '226', 2600, 'Louisiana'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '227', 2700, 'Miami'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '228', 2800, 'Midwest'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '229', 2900, 'Nogales'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '230', 3000, 'Salinas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '231', 3100, 'New Jersey'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '232', 3200, 'Southern CA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '233', 3300, 'Spotlight Focus'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '234', 3400, 'Supplement Focus'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '235', 3500, 'CA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '236', 3600, 'Canada'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '270', 1000, 'Carolinas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '237', 3700, 'GA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '238', 3800, 'Hispanic'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '239', 3900, 'Import/Export'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '240', 4000, 'Transportation'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '241', 4100, 'TX'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '242', 4200, 'Top Topics' -- was Top Topics Sponsor (Spread)
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '243', 2950, 'Rio Grande Valley'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '244', 3950, 'Ontario'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '275', 2500, 'Ohio'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '280', 2800, 'Oregon'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '285', 3500, 'Front Feature' -- Was Feature
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '286', 3505, 'Back Feature'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '290', 4300, 'Special Content'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '306', 4400, 'New Product Showcase'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '305', 4500, 'Global Trade'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '259', 405, 'NA Summer Production'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '309', 4600, 'Broccoli'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '263', 4700, 'Bakersfield'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '262', 4800, 'Santa Maria'

/*
  This is the list of current values used on the edit page.  Update this list and
  also the pradc_PlannedSection list
*/

--DELETE FROM Custom_Captions WHERE capt_family = 'pradc_PlannedSection_Curr'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '200', 10, 'Apples'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '300', 20, 'Avocados'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '286', 30, 'Back Feature'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '263', 40, 'Bakersfield'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '250', 50, 'Berries'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '212', 60, 'Boston'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '309', 70, 'Broccoli'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '307', 80, 'California'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '236', 90, 'Canada'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '270', 100, 'Carolinas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '252', 110, 'Carrots'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '201', 120, 'Cherries'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '213', 130, 'Chicago'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '255', 140, 'Citrus'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '223', 150, 'Dallas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '214', 160, 'Detroit'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '215', 170, 'Florida'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '285', 180, 'Front Feature'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '211', 190, 'Georgia'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '305', 200, 'Global Trade'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '202', 210, 'Grapes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '238', 220, 'Hispanic'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '239', 230, 'Import/Export'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '209', 240, 'KYC - Commodity Basics'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '210', 250, 'KYC Sponsor'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '301', 260, 'Lemons & Limes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '257', 270, 'Lettuce'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '265', 280, 'Los Angeles'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '224', 290, 'Maryland'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '258', 300, 'Melons'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '227', 310, 'Miami'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '228', 320, 'Midwest'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '216', 330, 'Montreal'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '259', 340, 'NA Summer Production'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '220', 350, 'New In Blue'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '231', 360, 'New Jersey'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '306', 370, 'New Product Showcase'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '217', 380, 'New York'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '229', 390, 'Nogales'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '275', 400, 'Ohio'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '221', 410, 'On the Job'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '203', 420, 'Onions & Potatoes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '244', 430, 'Ontario'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '280', 440, 'Oregon'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '260', 450, 'Organics'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '261', 460, 'Peppers'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '218', 470, 'Philly'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '243', 480, 'Rio Grande Valley'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '303', 490, 'Root Vegetables'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '230', 500, 'Salinas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '262', 510, 'Santa Maria'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '290', 520, 'Special Content'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '241', 530, 'Texas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '308', 540, 'TM Spotlight Advertorial'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '208', 550, 'TM/FM Milestone'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '304', 560, 'Tomatoes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '242', 570, 'Top Topics'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '240', 580, 'Transportation'



--DELETE FROM Custom_Captions WHERE capt_family = 'pradc_SectionDetailsCode'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode', 'AT', 10, 'AT'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode', 'C&F', 20, 'C & F'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode', 'EOC', 25, 'EOC'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode', 'GV', 30, 'GV'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode', 'LE', 40, 'LE'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode', 'OTJ', 50, 'OTJ'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode', 'Retail', 55, 'Retail'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode', 'SCS', 60, 'SCS'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode', 'TA', 70, 'TA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode', 'Other', 80, 'Other'

--DELETE FROM Custom_Captions WHERE capt_family = 'pradc_SectionDetailsCode_Curr'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode_Curr', 'AT', 10, 'AT'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode_Curr', 'C&F', 20, 'C & F'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode_Curr', 'EOC', 25, 'EOC'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode_Curr', 'GV', 30, 'GV'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode_Curr', 'LE', 40, 'LE'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode_Curr', 'Retail', 55, 'Retail'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode_Curr', 'SCS', 60, 'SCS'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode_Curr', 'TA', 70, 'TA'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_SectionDetailsCode_Curr', 'Other', 80, 'Other'



exec usp_TravantCRM_CreateDropdownValue 'LRLMarketingMessage', 'ProduceNoDL', 1, 'Increase business opportunities by adding descriptive information to your listing, such as personnel names and E-mails, ship and unload hours or business specialization. Add your information in the space provided.'
exec usp_TravantCRM_CreateDropdownValue 'LRLMarketingMessage', 'ProduceDLNotMember', 2, 'To learn how Blue Book membership will help you make safe, informed and profitable business decisions, please call a Sales Representative at 630-668-3500.'
exec usp_TravantCRM_CreateDropdownValue 'LRLMarketingMessage', 'ProduceDLMemberNoLogo', 3, 'Enhance your listing by including your business logo.  Call a Customer Service Representative at 630-668-3500 for more information.'
exec usp_TravantCRM_CreateDropdownValue 'LRLMarketingMessage', 'ProduceDLMemberLogo', 4, 'Learn how to use Blue Book Online Services to help you make safe, informed and profitable decisions; call a Customer Service Associate at 630-668-3500 for a free webinar.'
exec usp_TravantCRM_CreateDropdownValue 'LRLMarketingMessage', 'LumberNotMember', 5, 'To learn how Blue Book membership will help you make safe, informed and profitable business decisions, please call a Sales Representative at 630-668-3500.'
exec usp_TravantCRM_CreateDropdownValue 'LRLMarketingMessage', 'LumberMember', 6, 'Learn how to use Blue Book Online Services to help you make safe, informed and profitable decisions; call a Customer Service Associate at 630-668-3500 for a free webinar.'


EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRDisposition', '01', 1, 'Disposition 1'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRDisposition', '02', 2, 'Disposition 2'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRDisposition', '03', 3, 'Disposition 3'
EXEC usp_TravantCRM_CreateDropdownValue 'oppo_PRDisposition', '04', 4, 'Disposition 4'

--DELETE FROM Custom_Captions WHERE capt_Family = 'prsm_SocialMediaTypeCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prsm_SocialMediaTypeCode', 'linkedin', 1, 'LinkedIn Company Page'
EXEC usp_TravantCRM_CreateDropdownValue 'prsm_SocialMediaTypeCode', 'facebook', 2, 'Facebook Fan Page'
EXEC usp_TravantCRM_CreateDropdownValue 'prsm_SocialMediaTypeCode', 'youtube', 3, 'YouTube Channel'
EXEC usp_TravantCRM_CreateDropdownValue 'prsm_SocialMediaTypeCode', 'twitter', 4, 'Twitter'
EXEC usp_TravantCRM_CreateDropdownValue 'prsm_SocialMediaTypeCode', 'instagram', 5, 'Instagram'

EXEC usp_TravantCRM_CreateDropdownValue 'prsm_SocialMediaDomain', 'linkedin', 1, 'linkedin.com'
EXEC usp_TravantCRM_CreateDropdownValue 'prsm_SocialMediaDomain', 'facebook', 2, 'facebook.com'
EXEC usp_TravantCRM_CreateDropdownValue 'prsm_SocialMediaDomain', 'youtube', 3, 'youtube.com'
EXEC usp_TravantCRM_CreateDropdownValue 'prsm_SocialMediaDomain', 'twitter', 4, 'twitter.com'
EXEC usp_TravantCRM_CreateDropdownValue 'prsm_SocialMediaDomain', 'instagram', 5, 'instagram.com'

--DELETE FROM Custom_Captions WHERE capt_Family = 'comp_PRConfidentialFS'
EXEC usp_TravantCRM_CreateDropdownValue 'comp_PRConfidentialFS', '1', 1, 'Only disclose Financial Ratios'
EXEC usp_TravantCRM_CreateDropdownValue 'comp_PRConfidentialFS', '2', 2, 'Financial Figures are confidential and only for Rating Purposes (no disclosure)'
EXEC usp_TravantCRM_CreateDropdownValue 'comp_PRConfidentialFS', '3', 3, 'Allowed to disclose financial figures'

EXEC usp_TravantCRM_CreateDropdownValue 'pren_PrimarySourceCode', 'DowJones', 1, 'Dow Jones'
EXEC usp_TravantCRM_CreateDropdownValue 'pren_PrimarySourceCode', 'MMW', 2, 'Meister Media Worldwide'
EXEC usp_TravantCRM_CreateDropdownValue 'pren_PrimarySourceCode', 'PN', 3, 'Produce News'
EXEC usp_TravantCRM_CreateDropdownValue 'pren_PrimarySourceCode', 'ANUK', 4, 'And Now U Know'
EXEC usp_TravantCRM_CreateDropdownValue 'pren_PrimarySourceCode', 'PRBL', 5, 'Perishable News'
EXEC usp_TravantCRM_CreateDropdownValue 'pren_PrimarySourceCode', 'FP', 6, 'FreshPlaza'

--DELETE FROM Custom_Captions WHERE capt_Family = 'prcta_TradeAssociationCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'AGEXPORT',2, 'Asociación de Exportadores de Guatemala'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'AMCHAM', 3, 'AMCHAM Guatemala'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'AMHPAC', 5, 'Asociación Mexicana de Horticultura Protegida, A.C.'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'CPMA', 10, 'Canadian Produce Marketing Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'FPAA', 15, 'Fresh Produce Association of the Americas'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'FPFC', 17, 'Fresh Produce & Floral Council'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'FFVA', 20, 'Florida Fruit & Vegetable Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'IFPA', 24, 'International Fresh Produce Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'JAD', 25, 'Junta Agroempresarial Dominicana, Inc.'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'LGMA', 27, 'California Leafy Green Marketing Agreement'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'NAWLA', 30, 'North American Wholesale Lumber Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'NGA', 40, 'National Grocers Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'NWA', 45, 'National Watermelon Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'OPMA', 47, 'Ontario Produce Marketing Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'PBH', 50, 'Produce for Better Health'
--EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'PMA', 60, 'Produce Marketing Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'QPMA', 70, 'Quebec Produce Marketing Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'SEPC', 80, 'Southeast Produce Council'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'TIA', 84, 'Transportation Intermediaries Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'TIPA', 85, 'Texas International Produce Association'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'TPA', 90, 'Texas Produce Association'
--EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'UF', 100, 'United Fresh'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationCode', 'WGA', 120, 'Western Growers Association'


--DELETE FROM Custom_Captions WHERE capt_Family = 'prcta_TradeAssociationURL'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'AGEXPORT', 2, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'AMCHAM', 3, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'AMHPAC', 5, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'CPMA', 10, 'http://cpma.ca'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'FFVA', 20, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'JAD', 25, 'http://www.jad.org.do'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'NAWLA', 30, 'http://www.nawla.org'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'NGA', 40, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'NWA', 45, 'https://watermelon.ag'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'OPMA', 140, 'http://theopma.ca'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'PBH', 50, 'http://www.pbhfoundation.org'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'PMA', 60, 'http://www.pma.com'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'QPMA', 70, 'http://www.aqdfl.ca'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'SEPC', 80, 'http://seproducecouncil.com/'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'TIPA', 85, 'http://www.texasproduceassociation.com'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'TIA', 90, 'http://www.tianet.org'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'TPA', 90, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'UF', 100, 'http://www.unitedfresh.org'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'WGA', 120, 'http://www.wga.com'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'FPAA', 130, 'http://www.freshfrommexico.com'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'AMHPAC', 5, 'http://www.amhpac.org'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'LGMA', 27, 'https://lgma.ca.gov'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'IFPA', 24, 'http://www.freshproduce.com'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'FPFC', 17, 'https://www.fpfc.org/'


EXEC usp_TravantCRM_CreateDropdownValue 'prshplg_CarrierCode', 'FedEx', 1, 'FedEx'
EXEC usp_TravantCRM_CreateDropdownValue 'prshplg_CarrierCode', 'USPS', 2, 'US Postal Service'

--DELETE FROM Custom_Captions WHERE capt_Family = 'prshplgd_ItemCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prshplgd_ItemCode', 'BOOK', 1, 'Book'
EXEC usp_TravantCRM_CreateDropdownValue 'prshplgd_ItemCode', 'BOOK-APR', 3, 'Book-APR'
EXEC usp_TravantCRM_CreateDropdownValue 'prshplgd_ItemCode', 'BPRINT', 4, 'Blueprints'
EXEC usp_TravantCRM_CreateDropdownValue 'prshplgd_ItemCode', 'MBRPLAQUE', 5, 'Membership Plaque'
EXEC usp_TravantCRM_CreateDropdownValue 'prshplgd_ItemCode', 'KYCG', 6, 'KYC Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'prshplgd_ItemCode', 'TTG', 7, 'TT Guide'

EXEC usp_TravantCRM_CreateDropdownValue 'TransactionType', 'I', 1, 'Invoice'
EXEC usp_TravantCRM_CreateDropdownValue 'TransactionType', 'C', 2, 'Credit Memo'
EXEC usp_TravantCRM_CreateDropdownValue 'TransactionType', 'D', 3, 'Debit Memo'
EXEC usp_TravantCRM_CreateDropdownValue 'TransactionType', 'P', 4, 'Payment'
EXEC usp_TravantCRM_CreateDropdownValue 'TransactionType', 'A', 5, 'Adjustment'
EXEC usp_TravantCRM_CreateDropdownValue 'TransactionType', 'F', 6, 'Finance Charge'
EXEC usp_TravantCRM_CreateDropdownValue 'TransactionType', 'X', 7, 'PrePayment'
EXEC usp_TravantCRM_CreateDropdownValue 'TransactionType', 'B', 8, 'Balance Forward'
EXEC usp_TravantCRM_CreateDropdownValue 'TransactionType', 'E', 9, 'Balance Forward Other'

--EXEC usp_TravantCRM_CreateDropdownValue 'EmailTemplate', 'MarketingMessageP', 0, ''
--EXEC usp_TravantCRM_CreateDropdownValue 'EmailTemplate', 'MarketingMessageL', 0, ''

EXEC usp_TravantCRM_CreateDropdownValue 'EmailTemplate', 'LeftBarHeader', 0, 'We''re Here to Answer<br />Your Questions!'
UPDATE Custom_Captions SET capt_ES = '&iexcl;Estamos aqu&iacute; para<br/>responder sus<br/>preguntas!' WHERE capt_family = 'EmailTemplate' AND capt_code = 'LeftBarHeader'

EXEC usp_TravantCRM_CreateDropdownValue 'EmailTemplate', 'AccountSummary', 0, 'Account Summary'
UPDATE Custom_Captions SET capt_ES = 'Resumen de la cuenta' WHERE capt_family = 'EmailTemplate' AND capt_code = 'AccountSummary'

EXEC usp_TravantCRM_CreateDropdownValue 'EmailTemplate', 'ThankYou', 0, 'Thank you for the ongoing opportunity to serve you!'
UPDATE Custom_Captions SET capt_ES = '&iexcl;Gracias por la oportunidad de servirle!' WHERE capt_family = 'EmailTemplate' AND capt_code = 'ThankYou'

EXEC usp_TravantCRM_CreateDropdownValue 'EmailTemplate', 'Phone', 0, 'phone'
UPDATE Custom_Captions SET capt_ES = 'tel&eacute;fono' WHERE capt_family = 'EmailTemplate' AND capt_code = 'Phone'

EXEC usp_TravantCRM_CreateDropdownValue 'EmailTemplate', 'Login', 0, 'Login to BBOS'
UPDATE Custom_Captions SET capt_ES = 'Inicie sesi&oacute;n en BBOS' WHERE capt_family = 'EmailTemplate' AND capt_code = 'Login'

EXEC usp_TravantCRM_CreateDropdownValue 'EmailTemplate', 'Disclaimer', 0, 'The information contained herein is submitted in good faith as reported to us without prejudice, with no guarantee of its correctness in strict confidence to members for their exclusive use and benefit and is subject to the provisions of the membership agreement. It is not to be disclosed and members will be held strictly liable for the expenses, loss or damage to this Company from any such disclosure. Interested members should ask for details before arriving at final conclusions.'
UPDATE Custom_Captions SET capt_ES = 'La informaci&oacute;n incluida aquí se present&oacute; de buena fe seg&uacute;n lo que se nos inform&oacute; sin prejuicio, sin garantía de su precisi&oacute;n en estricta confidencialidad a los miembros para su beneficio y uso exclusivo, y est&aacute; sujeta a las disposiciones del acuerdo de membresía. No debe divulgarse y los miembros ser&aacute;n estrictamente responsables por los gastos, p&eacute;rdidas y da&ntilde;os a esta Compa&ntilde;ía por cualquier tipo de divulgaci&oacute;n. Los miembros interesados deben preguntar sobre los detalles antes de llegar a las conclusiones finales.' WHERE capt_family = 'EmailTemplate' AND capt_code = 'Disclaimer'




EXEC usp_TravantCRM_CreateDropdownValue 'CompanyAdvSearchNameOption', '', 10, 'All Names'
EXEC usp_TravantCRM_CreateDropdownValue 'CompanyAdvSearchNameOption', 'Y', 20, 'Legal Name Only'


EXEC usp_TravantCRM_CreateDropdownValue 'prssfs_StatusNote', 'Default', 10, 'Blue Book review pending.'

EXEC usp_TravantCRM_CreateDropdownValue 'prss_Meritorious', 'Y', 10, 'Yes'
EXEC usp_TravantCRM_CreateDropdownValue 'prss_Meritorious', 'UR', 20, 'Under Review'
EXEC usp_TravantCRM_CreateDropdownValue 'prss_Meritorious', 'NC', 30, 'Not Clear'
EXEC usp_TravantCRM_CreateDropdownValue 'prss_Meritorious', 'N', 40, 'No'
EXEC usp_TravantCRM_CreateDropdownValue 'prss_Meritorious', 'NA', 50, 'Not Applicable'


-- DELETE FROM Custom_captions WHERE Capt_Family = 'prcc_CourtCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'almdce', 10, 'Alabama Middle District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'alndce', 20, 'Alabama Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'alsdce', 30, 'Alabama Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'akdce', 40, 'Alaska District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'azdce', 50, 'Arizona District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'aredce', 60, 'Arkansas Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'arwdce', 70, 'Arkansas Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'cacdce', 80, 'California Central District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'caedce', 90, 'California Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'candce', 100, 'California Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'casdce', 110, 'California Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'codce', 120, 'Colorado District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ctdce', 130, 'Connecticut District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'dedce', 140, 'Delaware District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'dcdce', 150, 'District Of Columbia District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'flmdce', 160, 'Florida Middle District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'flndce', 170, 'Florida Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'flsdce', 180, 'Florida Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'gamdce', 190, 'Georgia Middle District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'gandce', 200, 'Georgia Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'gasdce', 210, 'Georgia Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'gudce', 220, 'Guam District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'hidce', 230, 'Hawaii District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'iddce', 240, 'Idaho District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ilcdce', 250, 'Illinois Central District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ilndce', 260, 'Illinois Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ilsdce', 270, 'Illinois Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'inndce', 280, 'Indiana Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'insdce', 290, 'Indiana Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'iandce', 300, 'Iowa Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'iasdce', 310, 'Iowa Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ksdce', 320, 'Kansas District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'kyedce', 330, 'Kentucky Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'kywdce', 340, 'Kentucky Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'laedce', 350, 'Louisiana Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'lamdce', 360, 'Louisiana Middle District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'lawdce', 370, 'Louisiana Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'medce', 380, 'Maine District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'mddce', 390, 'Maryland District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'madce', 400, 'Massachusetts District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'miedce', 410, 'Michigan Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'miwdce', 420, 'Michigan Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'mndce', 430, 'Minnesota District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'msndce', 440, 'Mississippi Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'mssdce', 450, 'Mississippi Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'moedce', 460, 'Missouri Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'mowdce', 470, 'Missouri Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'mtdce', 480, 'Montana District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nedce', 490, 'Nebraska District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nvdce', 500, 'Nevada District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nhdce', 510, 'New Hampshire District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'njdce', 520, 'New Jersey District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nmdce', 530, 'New Mexico District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nyedce', 540, 'New York Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nyndce', 550, 'New York Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nysdce', 560, 'New York Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nywdce', 570, 'New York Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ncedce', 580, 'North Carolina Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ncmdce', 590, 'North Carolina Middle District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ncwdce', 600, 'North Carolina Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nddce', 610, 'North Dakota District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nmidce', 620, 'Northern Mariana Islands District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ohndce', 630, 'Ohio Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ohsdce', 640, 'Ohio Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'okedce', 650, 'Oklahoma Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'okndce', 660, 'Oklahoma Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'okwdce', 670, 'Oklahoma Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ordce', 680, 'Oregon District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'paedce', 690, 'Pennsylvania Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'pamdce', 700, 'Pennsylvania Middle District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'pawdce', 710, 'Pennsylvania Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'prdce', 720, 'Puerto Rico District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ridce', 730, 'Rhode Island District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'scdce', 740, 'South Carolina District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'sddce', 750, 'South Dakota District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'tnedce', 760, 'Tennessee Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'tnmdce', 770, 'Tennessee Middle District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'tnwdce', 780, 'Tennessee Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'txedce', 790, 'Texas Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'txndce', 800, 'Texas Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'txsdce', 810, 'Texas Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'txwdce', 820, 'Texas Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'cofce', 830, 'United States Federal Claims Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'utdce', 840, 'Utah District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'vtdce', 850, 'Vermont District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'vidce', 860, 'Virgin Islands'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'vaedce', 870, 'Virginia Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'vawdce', 880, 'Virginia Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'waedce', 890, 'Washington Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'wawdce', 900, 'Washington Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'wvndce', 910, 'West Virginia Northern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'wvsdce', 920, 'West Virginia Southern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'wiedce', 930, 'Wisconsin Eastern District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'wiwdce', 940, 'Wisconsin Western District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'wydce', 950, 'Wyoming District Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'flhccc', 5000, 'Hillsborough County Circuit Court (Florida)'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'papccc', 5001, 'Polk County Circuit Court (Pennsylvania)'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'onscj', 5002, 'Ontario Superior Court of Justice'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'CPCCCO', 5003, 'Common Pleas Court Clermont County Ohio'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'DCUTJDWJD', 5004, 'District Court of Utah Third Judicial District, West Jordan Department'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'flpccc', 5005, 'Polk County Circuit Court (Florida)'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'qcccny', 5006, 'Queens County Civil Court for the State of New York'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ccmdcf', 5007, 'Circuit Court of Miami-Dade County Florida'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'scnjldmc', 5008, 'Superior Court of New Jersey, Law Division, Morris County'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'tcscga', 5009, 'Tellfair County Superior Court, Georgia'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'scnjpscp', 5010, 'Superior Court of New Jersey Passaic Special Civil Part'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ccccsi', 5011, 'Cook County Circuit Court of the State of Illinois'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'nyccc', 5012, 'New York County Civil Court'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'kbsccd', 5013, 'Kings Borough Supreme Court - Civil Division'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'epccep', 5014, 'El Paso County Court - El Paso'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ccpcco', 5014, 'Court of Common Pleas Clermont County, Ohio.'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'scccs', 5015, 'Superior Court of California, County of Sutter'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'scccla', 5016, 'SUPERIOR COURT OF THE STATE OF CALIFORNIA COUNTY OF LOS ANGELES'
EXEC usp_TravantCRM_CreateDropdownValue 'prcc_CourtCode', 'ccfcsh', 5017, 'The Circuit Court of the Firth Circuit State of Hawaii'

-- DELETE FROM Custom_captions WHERE Capt_Family = 'MembershipCancelCode'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C01', 1, 'C01 - Out of Business'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C02', 2, 'Unknown'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C03', 3, 'C03 - Value: Cost vs. Benefit'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C04', 4, 'C04 - Reduced Volume '
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C05', 5, 'C05 - No Longer Handling / Hauling '
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C06', 6, 'C06 - Lost to Completion: Product or Price'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C07', 7, 'Lost to Competition: Price'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C08', 8, 'C08 - Customer Dissatisfied with Ratings Services, Customer Dissatisfied with Trade Dispute Concern, with BBOS Data Quality'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C09', 9, 'Rating / Trade Assistance Dispute'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C10', 10, 'C10 - Other'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C11', 12, 'C11 - Subscription at Affiliate (M/S already exists at an affiliate business)'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C12', 13, 'M at Affiliate (M already exists at an affiliate business)'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C23', 14, 'C23 - Cancelled Due to Non-Payment'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C24', 15, 'C24 - Blue Book Level Upgrade'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C27', 16, 'Cancelled Due to Price Increase'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C30', 17, 'C30 - Downgrade to Lower Level'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C31', 18, 'C31 - Remove Gratis Subscription or Trial License'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C32', 19, 'Trial License/M Purchased'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C33', 20, 'Location Closed'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'C34', 21, 'C34 - Customer is Unresponsive'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'D40', 100, 'D40 - Downgrade due to price'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'D41', 101, 'D41 - Downgrade because lower tier meeting the customer need'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipCancelCode', 'D42', 102, 'D42 - Customer would not say why they wanted the downgrade'

EXEC usp_TravantCRM_CreateDropdownValue 'prcl2_Source', 'CLR', 1, 'Reference List Report'
EXEC usp_TravantCRM_CreateDropdownValue 'prcl2_Source', 'CS', 2, 'Customer Submission'
EXEC usp_TravantCRM_CreateDropdownValue 'prcl2_Source', 'BBOS', 3, 'BBOS'


EXEC usp_TravantCRM_CreateDropdownValue 'prglr_PrimaryFunction', 'PB', 10, 'Produce Buyer'
EXEC usp_TravantCRM_CreateDropdownValue 'prglr_PrimaryFunction', 'PS', 20, 'Produce Seller'
EXEC usp_TravantCRM_CreateDropdownValue 'prglr_PrimaryFunction', 'T',  30, 'Transportation'
EXEC usp_TravantCRM_CreateDropdownValue 'prglr_PrimaryFunction', 'S',  40, 'Industry Supply/Service'
EXEC usp_TravantCRM_CreateDropdownValue 'prglr_PrimaryFunction', 'O',  50, 'Other'

EXEC usp_TravantCRM_CreateDropdownValue 'prglr_PrimaryFunctionL', 'PB', 10, 'Lumber Buyer'
EXEC usp_TravantCRM_CreateDropdownValue 'prglr_PrimaryFunctionL', 'PS', 20, 'Lumber Seller'
EXEC usp_TravantCRM_CreateDropdownValue 'prglr_PrimaryFunctionL', 'S',  30, 'Lumber Supply Chain Services'
EXEC usp_TravantCRM_CreateDropdownValue 'prglr_PrimaryFunctionL', 'T',  40, 'Transportation'
EXEC usp_TravantCRM_CreateDropdownValue 'prglr_PrimaryFunctionL', 'O',  50, 'Other'


EXEC usp_TravantCRM_CreateDropdownValue 'GetListedEmail', 'Subject', 1, 'Your information has been submitted'
EXEC usp_TravantCRM_CreateDropdownValue 'GetListedEmail', 'Body', 1,
'<p style="margin-top:10px;">A <em>Blue Book Services</em> representative will contact you to verify and finalize your listing information prior to publication. </p>

<p style="margin-top:10px;">Thank You! Businesses throughout the produce supply chain rely on Blue Book information to make profitable business decisions. Your listing provides valuable exposure for your company.</p>

<p style="margin-top:10px;"><strong>How can you benefit from a Membership to Blue Book Services?</strong>
<ul style="list-style-type:disc;margin-left:25px;">
    <li style="margin-top:5px;"><strong>Blue Book Ratings & Scores:</strong> Make confident decisions to increase your profitability.</li>
    <li style="margin-top:5px;"><strong>Dynamic Search Tools:</strong> Identify new trading partners using a powerful search engine.</li>
    <li style="margin-top:5px;"><strong>Real-Time Data:</strong> Monitor trading partners with in-depth data and comprehensive tools.</li>
    <li style="margin-top:5px;"><strong>Trading Assistance:</strong> Let our experienced team assist you with disputes & collections.</li>
    <li style="margin-top:5px;"><strong>Marketing Power:</strong> Unleash your companys potential with exclusive marketing resources.</li>
    <li style="margin-top:5px;"><strong>Education:</strong> Stay informed with practical information to successfully run your business.</li>
</ul>
</p>

<p style="margin-top:10px;">For more information about how a Blue Book Membership can help you manage risk and grow sales, review the membership information on our site, or call a representative today at 630 668-3500.</p>
'

EXEC usp_TravantCRM_CreateDropdownValue 'GetListedEmailL', 'Subject', 1, 'Your information has been submitted'
EXEC usp_TravantCRM_CreateDropdownValue 'GetListedEmailL', 'Body', 1,
'<p style="margin-top:10px;">A <em>Blue Book Services</em> representative will contact you to verify and finalize your listing information prior to publication. </p>

<p style="margin-top:10px;">Thank You! Businesses throughout the lumber supply chain rely on Blue Book information to make profitable business decisions. Your listing provides valuable exposure for your company.</p>

<p style="margin-top:10px;"><strong>How can you benefit from a Membership to Blue Book Services?</strong>
<ul style="list-style-type:disc;margin-left:25px;">
    <li style="margin-top:5px;"><strong>Ratings & Business Reports:</strong> Make confident decisions to increase your profitability.</li>
    <li style="margin-top:5px;"><strong>Dynamic Search Tools:</strong> Identify new trading partners using a powerful search engine.</li>
    <li style="margin-top:5px;"><strong>Real-Time Data:</strong> Monitor trading partners with in-depth data and comprehensive tools.</li>
</ul>
</p>

<p style="margin-top:10px;">For more information about how a Blue Book Membership can help you manage risk and grow sales, review the membership information on our site, or call a representative today at 630 668-3500.</p>
'

EXEC usp_TravantCRM_CreateDropdownValue 'PurchaseBR', 'Subject', 1, 'Your Blue Book Business Report Attached'
EXEC usp_TravantCRM_CreateDropdownValue 'PurchaseBR', 'Body', 1,
'<p>Thank you for purchasing a Blue Book Business Report. Businesses throughout the produce supply chain rely on business reports when evaluating existing and new accounts. We hope you find the information valuable!</p>

<p style="margin-top:10px;">Start your Blue Book Membership today and begin utilizing these membership services: </strong>
<ul style="list-style-type:disc;margin-left:25px;">
    <li style="margin-top:5px;"><strong>Blue Book Ratings & Scores:</strong> Make confident decisions to increase your profitability.</li>
    <li style="margin-top:5px;"><strong>Dynamic Search Tools:</strong> Identify new trading partners using a powerful search engine.</li>
    <li style="margin-top:5px;"><strong>Real-Time Data:</strong> Monitor trading partners with in-depth data and comprehensive tools.</li>
    <li style="margin-top:5px;"><strong>Trading Assistance:</strong> Let our experienced team assist you with disputes & collections.</li>
    <li style="margin-top:5px;"><strong>Marketing Power:</strong> Unleash your companys potential with exclusive marketing resources.</li>
    <li style="margin-top:5px;"><strong>Education:</strong> Stay informed with practical information to successfully run your business.</li>
</ul>
</p>

<p><strong><u>SPECIAL OFFER</u>: Think you''ll need more Business Reports or credit and sales tools? In the next 10 days,  call and reference this promotion and we will deduct the cost of today''s business report purchase, from your first year''s membership fee!</strong></p>

<p>For more information about how a Blue Book Membership can help you manage risk and grow sales, review the membership information on our site, or call a representative today at 630 668-3500. </p>
'

EXEC usp_TravantCRM_CreateDropdownValue 'PurchaseBR', 'Body2', 1,
'<p>This email contains the Blue Book Business Report you purchased from ProduceBlueBook.com.</p>
<p>If you have any questions please contact us at <a href="mailto:customerservice@bluebookservices.com">customerservice@bluebookservices.com</a> or phone 630-668-3500.</p>
'

EXEC usp_TravantCRM_CreateDropdownValue 'SendBR', 'Subject', 1, 'Your Blue Book Business Report Attached'
EXEC usp_TravantCRM_CreateDropdownValue 'SendBR', 'Body', 1,
'<p>Thank you for your Blue Book Business Report request  Your Report is attached to this message. Businesses throughout the produce supply chain rely on business reports when evaluating existing and new accounts. We hope you find the information valuable!</p>

<p>If you have any questions about this report please contact Customer Service at 630 668-3500 or <a href="mailto:customerservice@bluebookservices.com">customerservice@bluebookservices.com</a>.</p>

<p><i>The information contained herein is submitted in good faith as reported to us without prejudice, with no guarantee of its correctness in strict confidence to members for their exclusive use and benefit and is subject to the provisions of the membership agreement. It is not to be disclosed and members will be held strictly liable for the expenses, loss or damage to this Company from any such disclosure. Interested members should ask for details before arriving at final conclusions. </i></p>
'

EXEC usp_TravantCRM_CreateDropdownValue 'MembershipPurchaseEmail', 'Subject', 1, 'Thank you for your membership purchase!'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipPurchaseEmail', 'Body', 1,
'<p style="margin-top:10px;"><em>Your password(s) to Blue Book Online Services (BBOS) will be following in a separate email shortly. </em></p>

<p style="margin-top:10px;">As a Blue Book Member you will benefit from real-time credit rating and marketing information that enables you to confidently and profitably grow your business.</p>

<p style="margin-top:10px;"><strong>Your membership suite of services includes: </strong>
<ul style="list-style-type:disc;margin-left:25px;">
    <li style="margin-top:5px;"><strong>Blue Book Ratings & Scores:</strong> Make confident decisions to increase your profitability.</li>
    <li style="margin-top:5px;"><strong>Dynamic Search Tools:</strong> Identify new trading partners using a powerful search engine.</li>
    <li style="margin-top:5px;"><strong>Real-Time Data:</strong> Monitor trading partners with in-depth data and comprehensive tools.</li>
    <li style="margin-top:5px;"><strong>Trading Assistance:</strong> Let our experienced team assist you with disputes & collections.</li>
    <li style="margin-top:5px;"><strong>Marketing Power:</strong> Unleash your companys potential with exclusive marketing resources.</li>
    <li style="margin-top:5px;"><strong>Education:</strong> Stay informed with practical information to successfully run your business.</li>
</ul>
</p>
'


EXEC usp_TravantCRM_CreateDropdownValue 'MembershipPurchaseEmailL', 'Subject', 1, 'Thank you for your membership purchase!'
EXEC usp_TravantCRM_CreateDropdownValue 'MembershipPurchaseEmailL', 'Body', 1,
'<p style="margin-top:10px;"><em>Your password(s) to Blue Book Online Services (BBOS) will be following in a separate email shortly. </em></p>

<p style="margin-top:10px;">As a Blue Book Member you will benefit from real-time credit rating and marketing information that enables you to confidently and profitably grow your business.</p>

<p style="margin-top:10px;"><strong>Your membership suite of services includes: </strong>
<ul style="list-style-type:disc;margin-left:25px;">
    <li style="margin-top:5px;"><strong>Ratings & Business Reports:</strong> Make confident decisions to increase your profitability.</li>
    <li style="margin-top:5px;"><strong>Dynamic Search Tools:</strong> Identify new trading partners using a powerful search engine.</li>
    <li style="margin-top:5px;"><strong>Real-Time Data:</strong> Monitor trading partners with in-depth data and comprehensive tools.</li>
</ul>
</p>
'

--DELETE FROM Custom_Captions WHERE Capt_FamilyType='Choices' AND capt_Family='SendValuationReport'
EXEC usp_TravantCRM_CreateDropdownValue 'SendValuationReport', 'Subject', 1, 'Your Blue Book Business Valuation is complete'
EXEC usp_TravantCRM_CreateDropdownValue 'SendValuationReport', 'Body', 1,
'<p>Your Blue Book Business Valuation is complete. <a href="{0}">Log in</a> to review your report.</p>
<p>Please note this valuation is not an appraisal, and is not meant to replace the need for a 409A valuation, financial
statement audit, or other professional opinion on the value or standing of your business. Blue Book does not
express any opinion on the validity of the financials used in this valuation, and results were not created in
accordance with the guidance of the American Institute of Certified Public Accountants ("AICPA") . Other parties
and valuation approaches may conclude in a different value.</p>
<p>If you have any questions, please contact us at <a href="mailto:customerservice@bluebookservices.com">customerservice@bluebookservices.com</a> or 630-668-3500 option 0.</p>
'


--DELETE FROM Custom_Captions WHERE capt_family = 'prwu_Timezone'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Dateline Standard Time', 1, '(UTC-12:00) International Date Line West'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'UTC-11', 2, '(UTC-11:00) Coordinated Universal Time-11'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Hawaiian Standard Time', 3, '(UTC-10:00) Hawaii'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Alaskan Standard Time', 4, '(UTC-09:00) Alaska'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Pacific Standard Time (Mexico)', 5, '(UTC-08:00) Baja California'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Pacific Standard Time', 6, '(UTC-08:00) Pacific Time (US & Canada)'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'US Mountain Standard Time', 7, '(UTC-07:00) Arizona'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Mountain Standard Time (Mexico)', 8, '(UTC-07:00) Chihuahua, La Paz, Mazatlan'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Mountain Standard Time', 9, '(UTC-07:00) Mountain Time (US & Canada)'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Central America Standard Time', 10, '(UTC-06:00) Central America'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Central Standard Time', 11, '(UTC-06:00) Central Time (US & Canada)'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Central Standard Time (Mexico)', 12, '(UTC-06:00) Guadalajara, Mexico City, Monterrey'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Canada Central Standard Time', 13, '(UTC-06:00) Saskatchewan'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'SA Pacific Standard Time', 14, '(UTC-05:00) Bogota, Lima, Quito, Rio Branco'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Eastern Standard Time', 15, '(UTC-05:00) Eastern Time (US & Canada)'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'US Eastern Standard Time', 16, '(UTC-05:00) Indiana (East)'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Venezuela Standard Time', 17, '(UTC-04:30) Caracas'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Paraguay Standard Time', 18, '(UTC-04:00) Asuncion'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Atlantic Standard Time', 19, '(UTC-04:00) Atlantic Time (Canada)'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Central Brazilian Standard Time', 20, '(UTC-04:00) Cuiaba'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'SA Western Standard Time', 21, '(UTC-04:00) Georgetown, La Paz, Manaus, San Juan'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Pacific SA Standard Time', 22, '(UTC-04:00) Santiago'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Newfoundland Standard Time', 23, '(UTC-03:30) Newfoundland'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'E. South America Standard Time', 24, '(UTC-03:00) Brasilia'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Argentina Standard Time', 25, '(UTC-03:00) Buenos Aires'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'SA Eastern Standard Time', 26, '(UTC-03:00) Cayenne, Fortaleza'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Greenland Standard Time', 27, '(UTC-03:00) Greenland'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Montevideo Standard Time', 28, '(UTC-03:00) Montevideo'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Bahia Standard Time', 29, '(UTC-03:00) Salvador'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'UTC-02', 30, '(UTC-02:00) Coordinated Universal Time-02'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Mid-Atlantic Standard Time', 31, '(UTC-02:00) Mid-Atlantic - Old'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Azores Standard Time', 32, '(UTC-01:00) Azores'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Cape Verde Standard Time', 33, '(UTC-01:00) Cape Verde Is.'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Morocco Standard Time', 34, '(UTC) Casablanca'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'UTC', 35, '(UTC) Coordinated Universal Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'GMT Standard Time', 36, '(UTC) Dublin, Edinburgh, Lisbon, London'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Greenwich Standard Time', 37, '(UTC) Monrovia, Reykjavik'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'W. Europe Standard Time', 38, '(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Central Europe Standard Time', 39, '(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Romance Standard Time', 40, '(UTC+01:00) Brussels, Copenhagen, Madrid, Paris'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Central European Standard Time', 41, '(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'W. Central Africa Standard Time', 42, '(UTC+01:00) West Central Africa'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Namibia Standard Time', 43, '(UTC+01:00) Windhoek'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Jordan Standard Time', 44, '(UTC+02:00) Amman'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'GTB Standard Time', 45, '(UTC+02:00) Athens, Bucharest'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Middle East Standard Time', 46, '(UTC+02:00) Beirut'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Egypt Standard Time', 47, '(UTC+02:00) Cairo'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Syria Standard Time', 48, '(UTC+02:00) Damascus'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'E. Europe Standard Time', 49, '(UTC+02:00) E. Europe'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'South Africa Standard Time', 50, '(UTC+02:00) Harare, Pretoria'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'FLE Standard Time', 51, '(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Turkey Standard Time', 52, '(UTC+02:00) Istanbul'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Israel Standard Time', 53, '(UTC+02:00) Jerusalem'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Libya Standard Time', 54, '(UTC+02:00) Tripoli'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Arabic Standard Time', 55, '(UTC+03:00) Baghdad'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Kaliningrad Standard Time', 56, '(UTC+03:00) Kaliningrad, Minsk'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Arab Standard Time', 57, '(UTC+03:00) Kuwait, Riyadh'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'E. Africa Standard Time', 58, '(UTC+03:00) Nairobi'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Iran Standard Time', 59, '(UTC+03:30) Tehran'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Arabian Standard Time', 60, '(UTC+04:00) Abu Dhabi, Muscat'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Azerbaijan Standard Time', 61, '(UTC+04:00) Baku'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Russian Standard Time', 62, '(UTC+04:00) Moscow, St. Petersburg, Volgograd'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Mauritius Standard Time', 63, '(UTC+04:00) Port Louis'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Georgian Standard Time', 64, '(UTC+04:00) Tbilisi'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Caucasus Standard Time', 65, '(UTC+04:00) Yerevan'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Afghanistan Standard Time', 66, '(UTC+04:30) Kabul'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'West Asia Standard Time', 67, '(UTC+05:00) Ashgabat, Tashkent'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Pakistan Standard Time', 68, '(UTC+05:00) Islamabad, Karachi'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'India Standard Time', 69, '(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Sri Lanka Standard Time', 70, '(UTC+05:30) Sri Jayawardenepura'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Nepal Standard Time', 71, '(UTC+05:45) Kathmandu'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Central Asia Standard Time', 72, '(UTC+06:00) Astana'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Bangladesh Standard Time', 73, '(UTC+06:00) Dhaka'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Ekaterinburg Standard Time', 74, '(UTC+06:00) Ekaterinburg'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Myanmar Standard Time', 75, '(UTC+06:30) Yangon (Rangoon)'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'SE Asia Standard Time', 76, '(UTC+07:00) Bangkok, Hanoi, Jakarta'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'N. Central Asia Standard Time', 77, '(UTC+07:00) Novosibirsk'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'China Standard Time', 78, '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'North Asia Standard Time', 79, '(UTC+08:00) Krasnoyarsk'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Singapore Standard Time', 80, '(UTC+08:00) Kuala Lumpur, Singapore'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'W. Australia Standard Time', 81, '(UTC+08:00) Perth'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Taipei Standard Time', 82, '(UTC+08:00) Taipei'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Ulaanbaatar Standard Time', 83, '(UTC+08:00) Ulaanbaatar'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'North Asia East Standard Time', 84, '(UTC+09:00) Irkutsk'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Tokyo Standard Time', 85, '(UTC+09:00) Osaka, Sapporo, Tokyo'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Korea Standard Time', 86, '(UTC+09:00) Seoul'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Cen. Australia Standard Time', 87, '(UTC+09:30) Adelaide'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'AUS Central Standard Time', 88, '(UTC+09:30) Darwin'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'E. Australia Standard Time', 89, '(UTC+10:00) Brisbane'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'AUS Eastern Standard Time', 90, '(UTC+10:00) Canberra, Melbourne, Sydney'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'West Pacific Standard Time', 91, '(UTC+10:00) Guam, Port Moresby'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Tasmania Standard Time', 92, '(UTC+10:00) Hobart'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Yakutsk Standard Time', 93, '(UTC+10:00) Yakutsk'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Central Pacific Standard Time', 94, '(UTC+11:00) Solomon Is., New Caledonia'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Vladivostok Standard Time', 95, '(UTC+11:00) Vladivostok'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'New Zealand Standard Time', 96, '(UTC+12:00) Auckland, Wellington'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'UTC+12', 97, '(UTC+12:00) Coordinated Universal Time+12'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Fiji Standard Time', 98, '(UTC+12:00) Fiji'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Magadan Standard Time', 99, '(UTC+12:00) Magadan'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Kamchatka Standard Time', 100, '(UTC+12:00) Petropavlovsk-Kamchatsky - Old'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Tonga Standard Time', 101, '(UTC+13:00) Nuku''alofa'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Samoa Standard Time', 102, '(UTC+13:00) Samoa'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_Timezone', 'Line Islands Standard Time', 103, '(UTC+14:00) Kiritimati Island'


--DELETE FROM Custom_Captions WHERE capt_family = 'prwu_TimezoneDisplay'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Dateline Standard Time', 1, 'Dateline Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'UTC-11', 2, 'UTC-11'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Hawaiian Standard Time', 3, 'Hawaiian Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Alaskan Standard Time', 4, 'Alaskan Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Pacific Standard Time (Mexico)', 5, 'Pacific Standard Time (Mexico)'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Pacific Standard Time', 6, 'Pacific Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'US Mountain Standard Time', 7, 'US Mountain Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Mountain Standard Time (Mexico)', 8, 'Mountain Standard Time (Mexico)'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Mountain Standard Time', 9, 'Mountain Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Central America Standard Time', 10, 'Central America Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Central Standard Time', 11, 'Central Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Central Standard Time (Mexico)', 12, 'Central Standard Time (Mexico)'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Canada Central Standard Time', 13, 'Canada Central Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'SA Pacific Standard Time', 14, 'SA Pacific Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Eastern Standard Time', 15, 'Eastern Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'US Eastern Standard Time', 16, 'US Eastern Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Venezuela Standard Time', 17, 'Venezuela Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Paraguay Standard Time', 18, 'Paraguay Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Atlantic Standard Time', 19, 'Atlantic Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Central Brazilian Standard Time', 20, 'Central Brazilian Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'SA Western Standard Time', 21, 'SA Western Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Pacific SA Standard Time', 22, 'Pacific SA Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Newfoundland Standard Time', 23, 'Newfoundland Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'E. South America Standard Time', 24, 'E. South America Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Argentina Standard Time', 25, 'Argentina Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'SA Eastern Standard Time', 26, 'SA Eastern Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Greenland Standard Time', 27, 'Greenland Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Montevideo Standard Time', 28, 'Montevideo Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Bahia Standard Time', 29, 'Bahia Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'UTC-02', 30, 'UTC-02'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Mid-Atlantic Standard Time', 31, 'Mid-Atlantic Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Azores Standard Time', 32, 'Azores Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Cape Verde Standard Time', 33, 'Cape Verde Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Morocco Standard Time', 34, 'Morocco Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'UTC', 35, 'UTC'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'GMT Standard Time', 36, 'GMT Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Greenwich Standard Time', 37, 'Greenwich Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'W. Europe Standard Time', 38, 'W. Europe Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Central Europe Standard Time', 39, 'Central Europe Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Romance Standard Time', 40, 'Romance Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Central European Standard Time', 41, 'Central European Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'W. Central Africa Standard Time', 42, 'W. Central Africa Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Namibia Standard Time', 43, 'Namibia Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Jordan Standard Time', 44, 'Jordan Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'GTB Standard Time', 45, 'GTB Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Middle East Standard Time', 46, 'Middle East Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Egypt Standard Time', 47, 'Egypt Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Syria Standard Time', 48, 'Syria Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'E. Europe Standard Time', 49, 'E. Europe Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'South Africa Standard Time', 50, 'South Africa Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'FLE Standard Time', 51, 'FLE Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Turkey Standard Time', 52, 'Turkey Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Israel Standard Time', 53, 'Israel Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Libya Standard Time', 54, 'Libya Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Arabic Standard Time', 55, 'Arabic Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Kaliningrad Standard Time', 56, 'Kaliningrad Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Arab Standard Time', 57, 'Arab Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'E. Africa Standard Time', 58, 'E. Africa Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Iran Standard Time', 59, 'Iran Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Arabian Standard Time', 60, 'Arabian Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Azerbaijan Standard Time', 61, 'Azerbaijan Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Russian Standard Time', 62, 'Russian Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Mauritius Standard Time', 63, 'Mauritius Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Georgian Standard Time', 64, 'Georgian Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Caucasus Standard Time', 65, 'Caucasus Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Afghanistan Standard Time', 66, 'Afghanistan Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'West Asia Standard Time', 67, 'West Asia Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Pakistan Standard Time', 68, 'Pakistan Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'India Standard Time', 69, 'India Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Sri Lanka Standard Time', 70, 'Sri Lanka Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Nepal Standard Time', 71, 'Nepal Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Central Asia Standard Time', 72, 'Central Asia Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Bangladesh Standard Time', 73, 'Bangladesh Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Ekaterinburg Standard Time', 74, 'Ekaterinburg Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Myanmar Standard Time', 75, 'Myanmar Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'SE Asia Standard Time', 76, 'SE Asia Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'N. Central Asia Standard Time', 77, 'N. Central Asia Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'China Standard Time', 78, 'China Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'North Asia Standard Time', 79, 'North Asia Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Singapore Standard Time', 80, 'Singapore Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'W. Australia Standard Time', 81, 'W. Australia Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Taipei Standard Time', 82, 'Taipei Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Ulaanbaatar Standard Time', 83, 'Ulaanbaatar Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'North Asia East Standard Time', 84, 'North Asia East Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Tokyo Standard Time', 85, 'Tokyo Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Korea Standard Time', 86, 'Korea Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Cen. Australia Standard Time', 87, 'Cen. Australia Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'AUS Central Standard Time', 88, 'AUS Central Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'E. Australia Standard Time', 89, 'E. Australia Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'AUS Eastern Standard Time', 90, 'AUS Eastern Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'West Pacific Standard Time', 91, 'West Pacific Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Tasmania Standard Time', 92, 'Tasmania Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Yakutsk Standard Time', 93, 'Yakutsk Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Central Pacific Standard Time', 94, 'Central Pacific Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Vladivostok Standard Time', 95, 'Vladivostok Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'New Zealand Standard Time', 96, 'New Zealand Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'UTC+12', 97, 'UTC+12'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Fiji Standard Time', 98, 'Fiji Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Magadan Standard Time', 99, 'Magadan Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Kamchatka Standard Time', 100, 'Kamchatka Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Tonga Standard Time', 101, 'Tonga Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Samoa Standard Time', 102, 'Samoa Standard Time'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_TimezoneDisplay', 'Line Islands Standard Time', 103, 'Line Islands Standard Time'


EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '1', 10, '1'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '2', 20, '2'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '3', 30, '3'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '4', 40, '4'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '5', 50, '5'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '6', 60, '6'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '7', 70, '7'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '8', 80, '8'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '9', 90, '9'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '10', 100, '10'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '11', 110, '11'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Hour', '12', 120, '12'

EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Minute', '00', 10, '00'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Minute', '15', 20, '15'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Minute', '30', 30, '30'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_Minute', '45', 40, '45'

EXEC usp_TravantCRM_CreateDropdownValue 'prwun_AMPM', 'AM', 10, 'AM'
EXEC usp_TravantCRM_CreateDropdownValue 'prwun_AMPM', 'PM', 20, 'PM'

EXEC usp_TravantCRM_CreateDropdownValue 'prwucf_FieldTypeCode', 'Text', 10, 'Text Field'
EXEC usp_TravantCRM_CreateDropdownValue 'prwucf_FieldTypeCode', 'DDL', 20, 'Drop Down List'

EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Type', 'BBOS', 10, 'BBOS'
EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Type', 'Email', 20, 'Email'
EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Type', 'Text', 30, 'Text'

EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Threshold', '15', 10, '15 Minutes Before'
EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Threshold', '30', 20, '30 Minutes Before'
EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Threshold', '60', 30, '1 Hour Before'
EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Threshold', '120', 40, '2 Hours Before'
EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Threshold', '240', 50, '4 Hours Before'
EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Threshold', '480', 60, '8 Hours Before'
EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Threshold', '720', 70, '12 Hours Before'
EXEC usp_TravantCRM_CreateDropdownValue 'prwunr_Threshold', '1440', 80, '1 Day Before'

--DELETE FROM Custom_captions WHERE Capt_Family = 'prwucl_CategoryIcon'
EXEC usp_TravantCRM_CreateDropdownValue 'prwucl_CategoryIcon', 'Category Black.png', 10, 'Category Black'
EXEC usp_TravantCRM_CreateDropdownValue 'prwucl_CategoryIcon', 'Category Blue.png', 20, 'Category Blue'
EXEC usp_TravantCRM_CreateDropdownValue 'prwucl_CategoryIcon', 'Category Green.png', 30, 'Category Green'
EXEC usp_TravantCRM_CreateDropdownValue 'prwucl_CategoryIcon', 'Category Red.png', 40, 'Category Red'
EXEC usp_TravantCRM_CreateDropdownValue 'prwucl_CategoryIcon', 'Category Yellow.png', 50, 'Category Yellow'

-- DELETE FROM custom_captions WHERE capt_family = 'NoteReminderEmail'
EXEC usp_TravantCRM_CreateDropdownValue 'NoteReminderEmail', 'Subject', 1, 'BBOS Note Reminder for BB# {0} {1}'
EXEC usp_TravantCRM_CreateDropdownValue 'NoteReminderEmail', 'Body', 1,
'<p>This is a reminder for the BBOS note below.</p>

<table width="100%">
<tr><td><strong>Subject:</strong></td><td width="100%">{0}</td></tr>
<tr><td><strong>Date/Time:</strong></td><td>{1}</td></tr>
<tr><td colspan="2">{2}</td></tr>
</table>'



--DELETE FROM Custom_captions WHERE Capt_Family = 'peli_PRCSReceiveMethod'
EXEC usp_TravantCRM_CreateDropdownValue 'peli_PRCSReceiveMethod', '1', 1, 'Fax'
EXEC usp_TravantCRM_CreateDropdownValue 'peli_PRCSReceiveMethod', '2', 2, 'Email'
EXEC usp_TravantCRM_CreateDropdownValue 'peli_PRCSReceiveMethod', '3', 3, 'Web Only'

--DELETE FROM Custom_captions WHERE Capt_Family = 'peli_PRCSSortOption'
EXEC usp_TravantCRM_CreateDropdownValue 'peli_PRCSSortOption', 'I', 10, 'by Industry'
EXEC usp_TravantCRM_CreateDropdownValue 'peli_PRCSSortOption', 'L', 20, 'by Location'
EXEC usp_TravantCRM_CreateDropdownValue 'peli_PRCSSortOption', 'K-L', 30, 'by Key Changes'
EXEC usp_TravantCRM_CreateDropdownValue 'peli_PRCSSortOption', 'K-I', 40, 'by Key Changes, then by Industry'
EXEC usp_TravantCRM_CreateDropdownValue 'peli_PRCSSortOption', 'I-K', 50, 'by Industry, then by Key Changes'

--DELETE FROM Custom_captions WHERE Capt_Family = 'prcsb_TypeCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prcsb_TypeCode', 'CSUPD', 10, 'Credit Sheet'
EXEC usp_TravantCRM_CreateDropdownValue 'prcsb_TypeCode', 'EXUPD', 20, 'Express Update'

--DELETE FROM Custom_captions WHERE Capt_Family = 'prcsb_TypeCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prcsb_StatusCode', 'P', 10, 'Pending'
EXEC usp_TravantCRM_CreateDropdownValue 'prcsb_StatusCode', 'IP', 20, 'In Progress'
EXEC usp_TravantCRM_CreateDropdownValue 'prcsb_StatusCode', 'C', 30, 'Completed'
EXEC usp_TravantCRM_CreateDropdownValue 'prcsb_StatusCode', 'A', 40, 'Aborted'

EXEC usp_TravantCRM_CreateDropdownValue 'prcsb_TestLogons', '1', 10, 'sab, mfn, lel'

EXEC usp_TravantCRM_CreateDropdownValue 'prcoml_FailedCategory', 'Email Address Not Found', 10, 'Check for misspellings in the email address and confirm this person is still with the organization.'
EXEC usp_TravantCRM_CreateDropdownValue 'prcoml_FailedCategory', 'Unable to Find Email Server', 20, 'Check for misspellings in the email address and confirm the company still exists.'
EXEC usp_TravantCRM_CreateDropdownValue 'prcoml_FailedCategory', 'Email Address Rejecting Email', 30, 'Confirm this person is still with the organization'
EXEC usp_TravantCRM_CreateDropdownValue 'prcoml_FailedCategory', 'Rejected as Spam/Junk', 40, 'Contact company and ask to add bluebookservices.com to white list.'
EXEC usp_TravantCRM_CreateDropdownValue 'prcoml_FailedCategory', 'Technical Issue', 50, 'Contact BBSI IT to research further.'

--DELETE FROM Custom_captions WHERE Capt_Family = 'prcn_Region'
EXEC usp_TravantCRM_CreateDropdownValue 'prcn_Region', 'NA', 0, 'North America'
EXEC usp_TravantCRM_CreateDropdownValue 'prcn_Region', 'CA', 10, 'Central America'
EXEC usp_TravantCRM_CreateDropdownValue 'prcn_Region', 'CR', 20, 'Caribbean'
EXEC usp_TravantCRM_CreateDropdownValue 'prcn_Region', 'SA', 30, 'South America'
EXEC usp_TravantCRM_CreateDropdownValue 'prcn_Region', 'EU', 40, 'Europe'
EXEC usp_TravantCRM_CreateDropdownValue 'prcn_Region', 'CSAME', 50, 'Central/South Asia and Middle East'
EXEC usp_TravantCRM_CreateDropdownValue 'prcn_Region', 'EAP', 60, 'Eastern Asia and Pacific'
EXEC usp_TravantCRM_CreateDropdownValue 'prcn_Region', 'AF', 70, 'Africa'

EXEC usp_TravantCRM_CreateDropdownValue 'CustomerServiceSurvey', 'SurveySubjectLine', 0, 'We Need Your Feedback'
EXEC usp_TravantCRM_CreateDropdownValue 'CustomerServiceSurvey', 'SurveyURL', 0, 'https://www.surveymonkey.com/s/BlueBookServiceSurvey'
EXEC usp_TravantCRM_CreateDropdownValue 'CustomerServiceSurvey', 'SurveyText', 0,
'<p>Blue Book Services strives to continually provide you with the best resources for your success.  We would like to learn more about your recent interaction with Blue Book Services.  Could you please take a few minutes to complete a satisfaction survey?</p>
<p>Your answers will be held in confidence by Blue Book Services. Please click on the following link to participate:</p>
<p><a href="{0}">{0}</a></p>';

--DELETE FROM Custom_Captions WHERE capt_family='SpecialServiceSurvey'
EXEC usp_TravantCRM_CreateDropdownValue 'SpecialServiceSurvey', 'SurveySubjectLine', 0, 'We Need Your Feedback on Special Services'
EXEC usp_TravantCRM_CreateDropdownValue 'SpecialServiceSurvey', 'SurveyURL', 0, 'https://www.surveymonkey.com/r/P6RR99T'
EXEC usp_TravantCRM_CreateDropdownValue 'SpecialServiceSurvey', 'SurveyText', 0,
'<p>Blue Book Services strives to continually provide you with the best resources for your success.  We would like to learn more regarding the Collection Assistance recently provided by Blue Book''s Trading Assistance team.  Could you please take a few minutes to complete a brief satisfaction survey?</p>
<p>Your answers will be held in confidence by Blue Book Services. Please click on the following link to participate:</p>
<p><a href="{0}">{0}</a></p>';

EXEC usp_TravantCRM_CreateDropdownValue 'BBOSSearchLocalSoruce', 'ILS', 10, 'Include Local Source'
EXEC usp_TravantCRM_CreateDropdownValue 'BBOSSearchLocalSoruce', 'ELS', 20, 'Exclude Local Source'
EXEC usp_TravantCRM_CreateDropdownValue 'BBOSSearchLocalSoruce', 'LSO', 30, 'Limit to Local Source'

EXEC usp_TravantCRM_CreateDropdownValue 'prls_AlsoOperates', 'Roadside Market', 10, 'Roadside Market'
EXEC usp_TravantCRM_CreateDropdownValue 'prls_AlsoOperates', 'Packing Facility', 20, 'Packing Facility'
EXEC usp_TravantCRM_CreateDropdownValue 'prls_AlsoOperates', 'Greenhouse', 30, 'Greenhouse'

EXEC usp_TravantCRM_CreateDropdownValue 'prls_TotalAcres', '25 - 99 acres', 10, '25 - 99 acres'
EXEC usp_TravantCRM_CreateDropdownValue 'prls_TotalAcres', '100 - 499 acres', 20, '100 - 499 acres'
EXEC usp_TravantCRM_CreateDropdownValue 'prls_TotalAcres', '500 - 999 acres', 30, '500 - 999 acres'
EXEC usp_TravantCRM_CreateDropdownValue 'prls_TotalAcres', '1000 - 2499 acres', 40, '1000 - 2499 acres'
EXEC usp_TravantCRM_CreateDropdownValue 'prls_TotalAcres', '2500 + acres', 50, '2500 + acres'

EXEC usp_TravantCRM_CreateDropdownValue 'prra_UpgradeDowngrade', 'N', 10, 'Neither'
EXEC usp_TravantCRM_CreateDropdownValue 'prra_UpgradeDowngrade', 'RU', 20, 'Rating Upgrade'
EXEC usp_TravantCRM_CreateDropdownValue 'prra_UpgradeDowngrade', 'RD', 30, 'Rating Downgrade'
EXEC usp_TravantCRM_CreateDropdownValue 'prra_UpgradeDowngrade', 'NE', 40, 'Negative Event'
EXEC usp_TravantCRM_CreateDropdownValue 'prra_UpgradeDowngrade', 'PE', 50, 'Positive Event'

EXEC usp_TravantCRM_CreateDropdownValue 'prwu_ARReportsThrehold', '12', 1, '12 Months'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_ARReportsThrehold', '18', 2, '18 Months'
EXEC usp_TravantCRM_CreateDropdownValue 'prwu_ARReportsThrehold', '24', 3, '24 Months'

EXEC usp_TravantCRM_CreateDropdownValue 'comp_PROnlineOnlyReasonCode', 'R', 1, 'Retail'
EXEC usp_TravantCRM_CreateDropdownValue 'comp_PROnlineOnlyReasonCode', 'M', 2, 'Mexico'

--Defect 4421-TradeShow and 6772 and 7082
--DELETE FROM custom_captions WHERE capt_family = 'prctsc_TradeShowCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'AGGU', 10, 'Agritrade - Guatemala'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'AGDR', 20, 'Agroalimentaria - DR'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'AMPHAC', 30, 'AMPHAC'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'CPMA', 40, 'CPMA'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'EXPE', 50, 'Expoalimentaria - Peru'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'EXBE', 60, 'Fruit Logistica - Berlin'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'EXSP', 70, 'Fruit Attraction - Spain'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'FTC', 75, 'Fruitrade - Chile'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'NYPS', 80, 'NY Produce Show'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'PFCM', 90, 'IFPA - Mexico Conference'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'PFS', 100, 'IFPA Global Produce Show'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'SE', 110, 'Southern Exposure'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'UF', 120, 'United Fresh'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'VF', 130, 'Viva Fresh'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'ITS', 140, 'Int''l Trade Show'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode', 'DTS', 150, 'Domestic Trade Show'

--DELETE FROM custom_captions WHERE capt_family = 'prctsc_TradeShowCode_PTS'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'AGGU', 10, 'Agritrade - Guatemala'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'CPMA', 20, 'CPMA'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'EXPE', 30, 'Expoalimentaria - Peru'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'FTC', 40, 'Fruitrade - Chile'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'EXBE', 50, 'Fruit Logistica - Berlin'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'EXSP', 60, 'Fruit Attraction - Spain'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'NYPS', 70, 'NY Produce Show'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'PFCM', 80, 'IFPA - Mexico Conference'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'PFS', 90, 'IFPA Global Produce Show'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'ITS', 110, 'Int''l Trade Show'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_PTS', 'DTS', 120, 'Domestic Trade Show'

EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_L', 'NHLA', 10, 'NHLA'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_L', 'NAWLATM', 20, 'NAWLA Traders Market'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_L', 'NAWLARM', 30, 'NAWLA Regional Meeting'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_L', 'NAWLALS', 40, 'NAWLA Leadership Summit'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_L', 'IHLA', 50, 'IHLA'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_TradeShowCode_L', 'OTHER', 60, 'Other'

EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_Year', '2018', 1, '2018'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_Year', '2019', 1, '2019'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_Year', '2020', 1, '2020'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_Year', '2021', 1, '2021'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_Year', '2022', 1, '2022'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_Year', '2023', 1, '2023'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_Year', '2024', 1, '2024'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_Year', '2025', 1, '2025'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_Year', '2026', 1, '2026'
EXEC usp_TravantCRM_CreateDropdownValue 'prctsc_Year', '2027', 1, '2027'
Go

DELETE FROM custom_captions WHERE capt_family = 'pradch_TypeCode'
EXEC usp_TravantCRM_CreateDropdownValue 'pradch_TypeCode', 'BP', 10, 'Blueprints'
EXEC usp_TravantCRM_CreateDropdownValue 'pradch_TypeCode', 'D', 20, 'Digital'
EXEC usp_TravantCRM_CreateDropdownValue 'pradch_TypeCode', 'KYC', 30, 'Know Your Commodity Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradch_TypeCode', 'TT', 40, 'Trading & Transportation'
Go

DELETE FROM custom_captions WHERE capt_family = 'prcaf_FileTypeCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prcaf_FileTypeCode', 'DI', 10, 'Digital Image'
EXEC usp_TravantCRM_CreateDropdownValue 'prcaf_FileTypeCode', 'PI', 20, 'Print Image'
EXEC usp_TravantCRM_CreateDropdownValue 'prcaf_FileTypeCode', 'V', 30, 'Video'

DELETE FROM custom_captions WHERE capt_family = 'pradc_TTEdition'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_TTEdition', '2025', 594, '2025 Trading & Transportation Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_TTEdition', '2024', 595, '2024 Trading & Transportation Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_TTEdition', '2023', 596, '2023 Trading & Transportation Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_TTEdition', '2022', 597, '2022 Trading & Transportation Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_TTEdition', '2021', 598, '2021 Trading & Transportation Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_TTEdition', '2020', 599, '2020 Trading & Transportation Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_TTEdition', '2019', 600, '2019 Trading & Transportation Guide'
--select * from custom_captions where capt_code='pradc_TTEdition'
--select * from custom_captions where capt_family='pradc_TTEdition'

DELETE FROM custom_captions WHERE capt_family = 'pradc_KYCEdition'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_KYCEdition', '2025', 594, '2025 KYC Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_KYCEdition', '2024', 595, '2024 KYC Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_KYCEdition', '2023', 596, '2023 KYC Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_KYCEdition', '2022', 597, '2022 KYC Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_KYCEdition', '2021', 598, '2021 KYC Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_KYCEdition', '2020', 599, '2020 KYC Guide'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_KYCEdition', '2019', 600, '2019 KYC Guide'
--select * from custom_captions where capt_code='pradc_TTEdition'
--select * from custom_captions where capt_family='pradc_TTEdition'

DELETE FROM custom_captions WHERE capt_family = 'BOR_TypeofEntity'
exec usp_TravantCRM_CreateDropdownValue 'BOR_TypeofEntity', '1', 1, 'Proprietorship'
exec usp_TravantCRM_CreateDropdownValue 'BOR_TypeofEntity', '2', 2, 'General Partnership'
exec usp_TravantCRM_CreateDropdownValue 'BOR_TypeofEntity', '3', 3, 'Limited Partnership'
exec usp_TravantCRM_CreateDropdownValue 'BOR_TypeofEntity', '4', 4, 'Limited Liability Company'
exec usp_TravantCRM_CreateDropdownValue 'BOR_TypeofEntity', '5', 5, 'Regular C. Corporation'
exec usp_TravantCRM_CreateDropdownValue 'BOR_TypeofEntity', '6', 6, 'Subchapter S Corporation'
exec usp_TravantCRM_CreateDropdownValue 'BOR_TypeofEntity', '7', 7, 'Co-Op.'
exec usp_TravantCRM_CreateDropdownValue 'BOR_TypeofEntity', '8', 8, 'Other'

--Defect 7160
DELETE FROM custom_captions WHERE capt_family = 'prsoat_ActionCode'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_ActionCode', 'C', 10, 'Cancel'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_ActionCode', 'I', 20, 'Insert'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_ActionCode', 'U', 30, 'Update'

DELETE FROM custom_captions WHERE capt_family = 'prsoat_Pipeline'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', '', 5, ''
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'AGRITRADE - GUATEMALA', 10, 'AGRITRADE - GUATEMALA'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'ANABERRIES 2022 - MEXICO', 20, 'ANABERRIES 2022 - MEXICO'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'BBOS INQUIRY', 30, 'BBOS INQUIRY'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'BBOS Visitor', 40, 'BBOS Visitor'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'DOMESTIC TRADE SHOW', 50, 'DOMESTIC TRADE SHOW'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'FREE UPGRADE', 60, 'FREE UPGRADE'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'FRUIT LOGISTICA - BERLIN', 70, 'FRUIT LOGISTICA - BERLIN'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'GLOBAL FRESH PRODUCE & FLORAL SHOW', 80, 'GLOBAL FRESH PRODUCE & FLORAL SHOW'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'IFPA FRESH CONNECTIONS - MEXICO', 90, 'IFPA FRESH CONNECTIONS - MEXICO'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'INBOUND', 100, 'INBOUND'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'INT''L TRADE SHOW', 110, 'INT''L TRADE SHOW'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'INTERNAL LEAD', 120, 'INTERNAL LEAD'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'NY PRODUCE SHOW', 130, 'NY PRODUCE SHOW'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'ONLINE', 140, 'ONLINE'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'OUTBOUND', 150, 'OUTBOUND'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'PACA', 160, 'PACA'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'PMA FRESH CONNECTIONS - MEXICO', 170, 'PMA FRESH CONNECTIONS - MEXICO'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'PMA FRESH SUMMIT', 180, 'PMA FRESH SUMMIT'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'REINSTATEMENT', 190, 'REINSTATEMENT'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'TRADESHOW', 200, 'TRADESHOW'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Pipeline', 'TRANSFER', 210, 'TRANSFER'

DELETE FROM custom_captions WHERE capt_family = 'prsoat_Up_Down'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Up_Down', '', 5, ''
--exec usp_TravantCRM_CreateDropdownValue 'prsoat_Up_Down', '+', 10, '+'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Up_Down', 'DOWNGRADE', 10, 'DOWNGRADE'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Up_Down', 'NEW', 10, 'NEW'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Up_Down', 'OTHER', 10, 'OTHER'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Up_Down', 'TRANSFER', 10, 'TRANSFER'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_Up_Down', 'UPGRADE', 10, 'UPGRADE'

DELETE FROM custom_captions WHERE capt_family = 'prsoat_CancelReasonCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', '', 0, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C01', 1, 'C01 - Location Closed or Out of Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C02', 2, 'C02 - Unknown'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C03', 3, 'C03 - Value: Cost vs. Benefit'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C04', 4, 'C04 - Reduced Handling/Hauling Produce'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C05', 5, 'C05 - No Longer Handle / Haul Produce'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C06', 6, 'C06 - Lost to Competition: Product'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C07', 7, 'C07 - Lost to Competition: Price'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C08', 8, 'C08 - Customer Dissatisfied'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C09', 9, 'C09 - Rating / Trade Assistance Dispute'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C10', 10, 'C10 - Other'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C11', 12, 'C11 - M Transfer/Consolidation/Acquisition'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C12', 13, 'C12 - M at Affiliate (M already exists at an affiliate business)'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C23', 14, 'C23 - Cancelled Due to Non-Payment'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C24', 15, 'C24 - BB Svc Lvl Upgrade'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C27', 16, 'C27 - Cancelled Due to Price Increase'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C30', 17, 'C30 - Downgrade to Lower Service Level'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C31', 18, 'C31 - Trial License/No M Purchased'
EXEC usp_TravantCRM_CreateDropdownValue 'prsoat_CancelReasonCode', 'C32', 19, 'C32 - Trial License/M Purchased'

--Defect 7160
DELETE FROM custom_captions WHERE capt_family = 'prsoat_ActionCode'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_ActionCode', 'C', 10, 'C'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_ActionCode', 'I', 20, 'I'
exec usp_TravantCRM_CreateDropdownValue 'prsoat_ActionCode', 'U', 30, 'U'

--Defect 4651
exec usp_TravantCRM_CreateDropdownValue 'BBOSPasswordChangeLink', 'Subject', 1, 'Password Change Request'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPasswordChangeLink', 'Communication', 1, 'BBOS Password Change Email has been sent to {0}.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPasswordChangeLink', 'Body', 1,
'<br/><br/>To change your password to Blue Book Online Services (BBOS), please click <a href=''{0}''>here</a>.  This is a one-time use link that will expire in {1} hours. <br/><br/>
If you need additional assistance, please contact our Customer Service Group at 630-668-3500 or <a href=''mailto:customerservice@bluebookservices.com''>customerservice@bluebookservices.com</a>. <br/><br/>

Sincerely, <br/>
Blue Book Services, Inc. <br/>
Ph: 630-668-3500 <br/>
845 E. Geneva Rd., Carol Stream, IL 60188 <br/>
'

UPDATE Custom_Captions SET capt_ES='<br/><br/>Para cambiar su contraseña a Blue Book Online Services (BBOS), haga clic <a href=''{0}''>aquí</a>. Este es un enlace de uso único que caducará en 24 horas.<br/> <br/>
Si necesita asistencia adicional, comuníquese con nuestro Grupo de Atención al Cliente al 630-668-3500 o <a href=''mailto:customerservice@bluebookservices.com''>customerservice@bluebookservices.com</a>. <br/>
<br/><br/>

Atentamente, <br/>
Blue Book Services, Inc. <br/>
Ph: 630-668-3500 <br/>
845 E. Geneva Rd., Carol Stream, IL 60188<br/>'
WHERE Capt_FamilyType='Choices' AND capt_family='BBOSPasswordChangeLink' AND capt_Code = 'Body'

UPDATE Custom_Captions SET capt_ES='Solicitud de cambio de contraseña' WHERE Capt_FamilyType='Choices' AND capt_family='BBOSPasswordChangeLink' AND capt_Code = 'Subject'

--BBOS 9.0

--SELECT * FROM custom_captions WHERE capt_family = 'BBOSPerformanceIndicators'
DELETE FROM custom_captions WHERE capt_family = 'BBOSPerformanceIndicators'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_HighRisk_Text', 10, 'High Risk',
																										'Alto Riesgo'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_HighRisk_Min', 20, '500'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_HighRisk_Max', 30, '599'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_HighRisk_Insight', 40, 'The company is considered “high" risk of experiencing a negative credit event within the next 12 months based upon the company&apos;s reported trading performance.<br><br>- High risk ranges from 500-599',
																										'Se considera que la empresa tiene un riesgo "alto" de experimentar un evento crediticio negativo en los próximos 12 meses según el desempeño comercial informado de la empresa.<br><br>- El riesgo alto oscila entre 500 y 599'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateHighRisk_Text', 50, 'Moderate High Risk',
																									'Riesgo moderado alto'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateHighRisk_Min', 60, '600'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateHighRisk_Max', 70, '699'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateHighRisk_Insight', 80, 'The company is considered “moderate high” risk of experiencing a negative credit event within the next 12 months based upon the company&apos;s reported trading performance.<br><br>- Moderate high risk ranges from 600-699',
																	'Se considera que la empresa tiene un riesgo "moderado alto" de experimentar un evento crediticio negativo en los próximos 12 meses según el desempeño comercial informado de la empresa.<br><br>- El riesgo moderado alto oscila entre 600 y 699'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateRisk_Text', 90, 'Moderate Risk',
																	'Riesgo moderado'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateRisk_Min', 100, '700'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateRisk_Max', 110, '749'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateRisk_Insight', 120, 'The company is considered "moderate" risk of experiencing a negative credit event within the next 12 months based upon the company&apos;s reported trading performance.<br><br>- Moderate risk ranges from 700-749',
																											'Se considera que la empresa tiene un riesgo "moderado" de experimentar un evento crediticio negativo en los próximos 12 meses según el desempeño comercial informado de la empresa.<br><br>- El riesgo moderado oscila entre 700 y 749'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateLowRisk_Text', 130, 'Moderate Low Risk',
																					'Riesgo moderado bajo'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateLowRisk_Min', 140, '750'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateLowRisk_Max', 150, '799'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_ModerateLowRisk_Insight', 160, 'The company is considered "moderate low" risk of experiencing a negative credit event within the next 12 months based upon the company&apos;s reported trading performance.<br><br>- Moderate low risk ranges from 750-799',
																								'Se considera que la empresa tiene un riesgo "moderado bajo" de experimentar un evento crediticio negativo en los próximos 12 meses según el desempeño comercial informado de la empresa.<br><br>- El riesgo moderado bajo oscila entre 750 y 799'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_LowRisk_Text', 170, 'Low Risk',
																										'Bajo Riesgo'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_LowRisk_Min', 180, '800'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_LowRisk_Max', 190, '1000'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Credit_Score_LowRisk_Insight', 200, 'The company is considered "low" risk of experiencing a negative credit event within the next 12 months based upon the company&apos;s reported trading performance.<br><br>- Low risk ranges from 800- 999',
																									'Se considera que la empresa tiene un riesgo "bajo" de experimentar un evento crediticio negativo en los próximos 12 meses según el desempeño comercial informado de la empresa.<br><br>- El riesgo bajo oscila entre 800 y 999'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_X_Text', 210, 'Poor',
																						'Pobre'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_X_Meaning', 215, '',
																						''
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_X_Insight', 220, 'Trading experiences are reported as poor on average.',
																						'Las experiencias comerciales se consideran malas en promedio.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XX_Text', 230, 'Unsatisfactory',
																						'Insatisfactoria/Insatisfactorio'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XX_Meaning', 235, '',
																							''
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XX_Insight', 240, 'Trading experiences are reported as unsatisfactory on average.',
																							'Las experiencias comerciales se consideran, en promedio, insatisfactorias.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XXX_Text', 250, 'Good',
																						'Bueno'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XXX_Meaning', 255, '',
																							''
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XXX_Insight', 260, 'Trading experiences are reported as good on average.',
																						'Las experiencias comerciales se consideran buenas en promedio.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XXXX_Text', 270, 'Excellent',
																						'Excelente'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XXXX_Meaning', 275, '',
																								''
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XXXX_Insight', 280, 'Trading experiences are reported as excellent on average.',
																							'Las experiencias comerciales se consideran excelentes en promedio.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XX147_Text', 290, 'Unsatisfactory',
																							'Insatisfactorio'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XX147_Meaning', 295, 'Have conflicting reports – some report better than XX experience.',
																							'Hay informes contradictorios - algunos informan de una experiencia mejor que XX.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XX147_Insight', 300, '<span class="tw-font-semibold">XX147</span> - A rating numeral assigned to a company when Trade Practices are reported as mixed, though some trading partners report satisfactory experiences.',
																							'<span class="tw-font-semibold">XX147</span> - Número de clasificación asignado a una empresa cuando las Prácticas Comerciales se consideran mixtas, aunque algunos socios comerciales informan de experiencias satisfactorias.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XXX148_Text', 310, 'Satisfactory',
																							'Satisfactorio'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XXX148_Meaning', 315, 'Have conflicting reports – some report less than XXX experience.',
																							'Hay informes contradictorios - algunos informan de una experiencia inferior a XXX.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'Rating_XXX148_Insight', 320, '<span class="tw-font-semibold">XXX148</span> - A rating numeral assigned to a company when Trade Practices are generally reported as satisfactory, though some trading partners report less than satisfactory experiences.',
																							'<span class="tw-font-semibold">XXX148</span> - Número de clasificación asignado a una empresa cuando las Prácticas Comerciales se consideran en general satisfactorias, aunque algunos socios comerciales informan de experiencias menos satisfactorias.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Poor_Text', 290, 'Poor',
																								'Pobre'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Poor_Min', 300, '1.0'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Poor_Max', 310, '1.999'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Poor_Insight', 320, 'Trading experiences are reported trending poor over the last 6 months.',
																								'Se informa que las experiencias comerciales han tenido una tendencia pobre durante los últimos 6 meses.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Unsat_Text', 330, 'Unsatisfactory',
																										'Insatisfactoria/Insatisfactorio'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Unsat_Min', 340, '2.0'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Unsat_Max', 350, '2.50'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Unsat_Insight', 360, 'Trading experiences are reported trending unsatisfactorily over the last 6 months.',
																										'Se informa que las experiencias comerciales han tenido una tendencia insatisfactoria durante los últimos 6 meses.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Fair_Text', 370, 'Fair',
																								'Justa/Justo'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Fair_Min', 380, '2.501'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Fair_Max', 390, '2.899'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Fair_Insight', 400, 'Trading experiences are reported trending fair over the last 6 months.',
																									'Se informa que las experiencias comerciales tienen una tendencia justa durante los últimos 6 meses.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Good_Text', 410, 'Good',
																								'Bueno'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Good_Min', 420, '2.90'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Good_Max', 430, '3.499'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Good_Insight', 440, 'Trading experiences are reported trending good over the last 6 months.',
																										'Se informa que las experiencias comerciales han tenido una buena tendencia durante los últimos 6 meses.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Excellent_Text', 450, 'Excellent',
																								'Excelente'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Excellent_Min', 460, '3.50'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Excellent_Max', 470, '4.0'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'TradeActivity_Score_Excellent_Insight', 480, 'Trading experiences are reported trending excellent over the last 6 months.',
																							'Se informa que las experiencias comerciales han tenido una tendencia excelente durante los últimos 6 meses.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_AA_Text', 490, '14 days',
																								'14 DIAS'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_AA_Insight', 500, 'Sellers and service providers report payment received on average between 1-14 days.',
																										'Los vendedores y proveedores de servicios informan que los pagos se reciben en promedio entre 1 y 14 días.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_A_Text', 510, '21 days',
																							'BBOSPerformanceIndicators'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_A_Insight', 520, 'Sellers and service providers report payment received on average between 15-21 days.',
																							'Los vendedores y proveedores de servicios informan que los pagos se reciben en promedio entre 15 y 21 días.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_B_Text', 530, '28 days',
																							'28 DÍAS'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_B_Insight', 540, 'Sellers and service providers report payment received on average between 22-28 days.',
																								'Los vendedores y proveedores de servicios informan que los pagos se reciben en promedio entre 22 y 28 días.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_C_Text', 550, '35 days',
																								'35 DÍAS'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_C_Insight', 560, 'Sellers and service providers report payment received on average between 29-35 days.',
																									'Los vendedores y proveedores de servicios informan que los pagos se reciben en promedio entre 29 y 35 días.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_D_Text', 570, '45 days',
																									'45 DÍAS'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_D_Insight', 580, 'Sellers and service providers report payment received on average between 36-45 days.',
																							'Los vendedores y proveedores de servicios informan que los pagos se reciben en promedio entre 36 y 45 días.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_E_Text', 590, '60 days',
																							'60 DÍAS'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_E_Insight', 600, 'Sellers and service providers report payment received on average between 46-60 days.',
																						'Los vendedores y proveedores de servicios informan que los pagos se reciben en promedio entre 46 y 60 días.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_F_Text', 610, 'Over 60 days',
																							'Más de 60 DÍAS'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_F_Insight', 620, 'Sellers and service providers report payment received on average beyond 60 days.',
																		'Los vendedores y proveedores de servicios informan que los pagos se reciben en promedio más allá de los 60 días.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_149_Text', 630, 'Variable',
																		'Variable'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_149_Meaning', 635, 'Reports received indicating pay variable and/or beyond terms with vendors, suppliers, and/or transportation firms.',
																		'Reportes recibidos indican retraso en pagos a proveedores y/o empresas transportistas.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_149_Insight', 640, '<span class="tw-font-semibold">(149)</span> - An assigned rating numeral to a company when reported vendor pay experiences are generally regarded as variable and beyond terms.',
																		'<span class="tw-font-semibold">(149)</span> - Un número de calificación asignado a una empresa cuando las experiencias de pago a proveedores comunicadas se consideran generalmente variables y más allá de los términos.'

exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_81_Text', 650, 'Variable',
																		'Variable'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_81_Meaning', 655, 'Pay reported as variable; specific pay description not assignable.',
																		'Reportado pago variable, descripción específica de pago no asignada.'
exec usp_TravantCRM_CreateDropdownValue 'BBOSPerformanceIndicators', 'PayDescription_81_Insight', 660, '<span class="tw-font-semibold">(81)</span> - An assigned rating numeral to reference reported variable pay experiences of a company by credit extenders.',
																		'<span class="tw-font-semibold">(81)</span> - Número de calificación asignado para hacer referencia a las experiencias de retribución variable de una empresa comunicadas por los ampliadores de crédito.'


--Other (Spanish) translations
UPDATE Custom_Captions SET Capt_Es = Capt_US WHERE capt_family = 'BBOSPerformanceIndicators' AND (capt_code NOT LIKE '%_Text' AND capt_code NOT LIKE '%_Insight' AND capt_code NOT LIKE '%_Meaning')


SET NOCOUNT OFF

EXEC usp_DTSPostExecute 'Custom_Captions', 'capt_CaptionID'

--Stripe Invoice Integration
DELETE FROM Custom_captions WHERE Capt_Family = 'prinv_SentMethodCode'
exec usp_TravantCRM_CreateDropdownValue 'prinv_SentMethodCode', 'E', 10, 'Email'
exec usp_TravantCRM_CreateDropdownValue 'prinv_SentMethodCode', 'F', 20, 'Fax'
exec usp_TravantCRM_CreateDropdownValue 'prinv_SentMethodCode', 'M', 30, 'Mail'

DELETE FROM Custom_captions WHERE Capt_Family = 'prinv_PaymentMethodCode'
exec usp_TravantCRM_CreateDropdownValue 'prinv_PaymentMethodCode', 'C', 10, 'Check'
exec usp_TravantCRM_CreateDropdownValue 'prinv_PaymentMethodCode', 'SCC', 20, 'Credit Card via Stripe'
exec usp_TravantCRM_CreateDropdownValue 'prinv_PaymentMethodCode', 'SACH', 30, 'ACH via Stripe'
exec usp_TravantCRM_CreateDropdownValue 'prinv_PaymentMethodCode', 'BBSCC', 40, 'Credit Card'


DELETE FROM Custom_captions WHERE Capt_Family = 'prcoml_FailedTypeCode'
exec usp_TravantCRM_CreateDropdownValue 'prcoml_FailedTypeCode', 'BLK', 10, 'Blocked'
exec usp_TravantCRM_CreateDropdownValue 'prcoml_FailedTypeCode', 'BNC', 20, 'Bounced'
Go


DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr_StatusCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr_StatusCode', 'P', 10, 'Pending'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr_StatusCode', 'IP', 20, 'In Progress'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr_StatusCode', 'S', 30, 'Sent'

DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr2_SubjectCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_SubjectCode', 'C', 10, 'Company'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_SubjectCode', 'P', 20, 'Person'

-- Master List
DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr2_QuestionCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C01', 10, 'OFAC Listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C02', 20, 'Global Sanctions'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C03', 30, 'Prison Address On Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C04', 40, 'P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C05', 50, 'Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C06', 60, 'Marijuana Related Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C07', 70, 'Business Address Used as Residential Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C08', 80, 'Other Listings Linked to Business Phone Number'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C09', 90, 'Other Businesses Linked to the Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C10', 100, 'Other Businesses Linked to Same FEIN'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C11', 110, 'Key Nature of Suite'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C12', 120, 'Pending Class Action'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C13', 130, 'Going Concern'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C14', 140, 'MSB listing'

EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P01', 10, 'Real-Time Incarceration & Arrest Records'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P02', 20, 'Associate with OFAC, Global Sanction or PEP listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P03', 30, 'OFAC listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P04', 40, 'Global Sanctions'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P05', 50, 'Residential Address Used as a Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P06', 60, 'Prison Address on Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P07', 70, 'P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P08', 80, 'Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P09', 90, 'Persona Associated with Marijuana Related Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P10', 100, 'Associate or Relative With a Residential Address Used as a Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P11', 110, 'Associate or Relative with a Prison Address on Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P12', 120, 'Associate or Relative with P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P13', 130, 'Criminal Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P14', 140, 'Criminal Record – Low Level Traffic Offense'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P15', 150, 'Sex Offender Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P16', 160, 'Criminal Record – Uncategorized'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P17', 170, 'Multiple SSNs'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P18', 180, 'SSN Matches multiple individuals'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P19', 190, 'Recorded as Deceased'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P20', 200, 'Age Younger than SSN Issue Date'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P21', 210, 'SSN Format is Invalid'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P22', 220, 'SSN is an ITIN'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P23', 230, 'Address First Reported <90 Days'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P24', 240, 'Telephone Number Inconsistent with Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P25', 250, 'Arrest Record'


-- Company Quesitons
DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr2_QuestionCodeCompany'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C01', 10, 'OFAC Listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C02', 20, 'Global Sanctions'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C03', 30, 'Prison Address On Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C04', 40, 'P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C05', 50, 'Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C06', 60, 'Marijuana Related Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C07', 70, 'Business Address Used as Residential Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C08', 80, 'Other Listings Linked to Business Phone Number'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C09', 90, 'Other Businesses Linked to the Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C10', 100, 'Other Businesses Linked to Same FEIN'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C11', 110, 'Key Nature of Suite'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C12', 120, 'Pending Class Action'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C13', 130, 'Going Concern'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C14', 140, 'MSB listing'

-- Person Questions
DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr2_QuestionCodePerson'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P01', 10, 'Real-Time Incarceration & Arrest Records'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P02', 20, 'Associate with OFAC, Global Sanction or PEP listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P03', 30, 'OFAC listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P04', 40, 'Global Sanctions'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P05', 50, 'Residential Address Used as a Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P06', 60, 'Prison Address on Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P07', 70, 'P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P08', 80, 'Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P09', 90, 'Persona Associated with Marijuana Related Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P10', 100, 'Associate or Relative With a Residential Address Used as a Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P11', 110, 'Associate or Relative with a Prison Address on Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P12', 120, 'Associate or Relative with P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P13', 130, 'Criminal Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P14', 140, 'Criminal Record – Low Level Traffic Offense'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P15', 150, 'Sex Offender Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P16', 160, 'Criminal Record – Uncategorized'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P17', 170, 'Multiple SSNs'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P18', 180, 'SSN Matches multiple individuals'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P19', 190, 'Recorded as Deceased'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P20', 200, 'Age Younger than SSN Issue Date'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P21', 210, 'SSN Format is Invalid'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P22', 220, 'SSN is an ITIN'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P23', 230, 'Address First Reported <90 Days'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P24', 240, 'Telephone Number Inconsistent with Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P25', 250, 'Arrest Record'


DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr2_ResponseCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_ResponseCode', '', 0, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_ResponseCode', 'Y', 10, 'Yes'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_ResponseCode', 'N', 20, 'No'
Go

DELETE FROM Custom_captions WHERE Capt_Family = 'NewMembershipCallRotation'
EXEC usp_TravantCRM_CreateDropdownValue 'NewMembershipCallRotation', 'krs', 1, 'Kirk Soule'
EXEC usp_TravantCRM_CreateDropdownValue 'NewMembershipCallRotation', 'lms', 2, 'Lacey Scotthennen'
EXEC usp_TravantCRM_CreateDropdownValue 'NewMembershipCallRotation', 'djw', 3, 'Dan Wywrot'
EXEC usp_TravantCRM_CreateDropdownValue 'NewMembershipCallRotation', 'mde', 4, 'Mark Erickson'
EXEC usp_TravantCRM_CreateDropdownValue 'NewMembershipCallRotation', 'cmb', 5, 'Charles Boicey'
EXEC usp_TravantCRM_CreateDropdownValue 'NewMembershipCallRotation', 'jpa', 6, 'John Abkes'
EXEC usp_TravantCRM_CreateDropdownValue 'NewMembershipCallRotation', 'dcn', 7, 'Doug Nelson'
EXEC usp_TravantCRM_CreateDropdownValue 'NewMembershipCallRotation', 'bmz', 8, 'Bill Zentner'
EXEC usp_TravantCRM_CreateDropdownValue 'NewMembershipCallRotation', 'fjb', 9, 'Paco Banuelos'
Go

DELETE FROM Custom_captions WHERE Capt_Family = 'prbv_StatusCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prbv_StatusCode', 'P', 10, 'Pending'
EXEC usp_TravantCRM_CreateDropdownValue 'prbv_StatusCode', 'IP', 20, 'In Progress'
EXEC usp_TravantCRM_CreateDropdownValue 'prbv_StatusCode', 'S', 30, 'Sent'
Go

DELETE FROM Custom_captions WHERE Capt_Family = 'prmr_TypeCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prmr_TypeCode', 'NEW', 10, 'New Membership'
Go