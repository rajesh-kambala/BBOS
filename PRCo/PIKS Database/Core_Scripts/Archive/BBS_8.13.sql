--8.13 Release
USE CRM

--Defect 7034 - AR file last date/time field
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'prc5_ARLastSubmittedDate'
          AND Object_ID = Object_ID(N'dbo.PRCompanyInfoProfile'))
BEGIN
	EXEC usp_TravantCRM_CreateDateField 'PRCompanyInfoProfile', 'prc5_ARLastSubmittedDate', 'AR Last Submitted Date', @AllowNull_In='Y'
END

-- Defect 7033 - middle name adv person search
EXEC usp_TravantCRM_AddCustom_Screens 'PersonAdvancedSearchBox', 25, 'pers_MiddleName', 0, 1, 1, 0
Go


EXEC usp_TravantCRM_CreateNumericField 'PRBBScore', 'prbs_BlendedScore', 'Blended Score'
Go