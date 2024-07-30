--CRM Compatability Relase - changes since the March 2021 production deployment of 5.10
USE CRM

--Defect 6981 for PROpportunitySummary.asp
EXEC usp_TravantCRM_AddCustom_Screens 'PROpportunitySummary', 260, 'oppo_PRLostReason',  1, 1, 1, 0
EXEC usp_TravantCRM_AddCustom_Screens 'PROpportunitySummary', 280, 'oppo_Note',  1, 1, 3, 0