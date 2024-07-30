--8.9 Release
USE CRM

UPDATE custom_tabs SET Tabs_CustomFileName='PRGeneral/ImportInteractionsRedirect.asp', tabs_action='customfile' WHERE tabs_TabID=10880
-- SELECT * FROM Custom_Tabs WHERE tabs_Entity = 'find'

--Defect 6824 - CRM: add street address search
EXEC usp_TravantCRM_AddCustom_Screens 'CompanyAdvancedSearchBox', 700, 'Addr_address1',  1, 1, 1, 'N'
GO

--Defect 6877
EXEC usp_TravantCRM_AddCustom_Screens 'PRBillingInfo', 60, 'prci2_Suspended ', 0, 1, 1, 0
Go

-- Defect 6882
UPDATE Custom_Captions SET capt_us = 'Financial Figures Disclosure Options' WHERE capt_code = 'comp_PRConfidentialFS'
Go