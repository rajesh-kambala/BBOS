--8.5 Release
USE CRM

EXEC usp_AccpacCreateTextField      'Pricing', 'pric_PriceCode', 'Price Code', 500, 500
GO

--4.1.1.1	PRImportPACAComplaint
EXEC usp_AccpacDropTable							'PRImportPACAComplaint'
EXEC usp_AccpacCreateTable						'PRImportPACAComplaint', 'pripc', 'pripc_ImportPACAComplaintID'
EXEC usp_AccpacCreateKeyIdentityField		'PRImportPACAComplaint', 'pripc_ImportPACAComplaintID', 'Import PACA Complaint ID', 20, NULL, 'Y', NULL, 'Y'
EXEC usp_AccpacCreateIntegerField			'PRImportPACAComplaint', 'pripc_ImportPACALicenseID', 'Import PACA License ID', 10, 'Y', 'Y' --	NOT NULL required
EXEC usp_AccpacCreateTextField				'PRImportPACAComplaint', 'pripc_FileName', 'FileName', 50, 50, 'N', 'Y' --	NOT NULL required
EXEC usp_AccpacCreateDateField				'PRImportPACAComplaint', 'pripc_ImportDate', 'Import Date', 'N', 'Y' --	NOT NULL required
EXEC usp_AccpacCreateTextField				'PRImportPACAComplaint', 'pripc_LicenseNumber', 'License Number', 8, 8, 'N', 'Y' --	NOT NULL required
EXEC usp_AccpacCreateTextField				'PRImportPACAComplaint', 'pripc_BusinessName', 'Business Name', 125, 125
EXEC usp_AccpacCreateIntegerField			'PRImportPACAComplaint', 'pripc_InfRepComplaintCount', 'Informal Reparations Complaint Count'
EXEC usp_AccpacCreateIntegerField			'PRImportPACAComplaint', 'pripc_DisInfRepComplaintCount', 'Disputed Informal Reparations Complaint Count'
EXEC usp_AccpacCreateIntegerField			'PRImportPACAComplaint', 'pripc_ForRepComplaintCount', 'Formal Reparations Complaint Count'
EXEC usp_AccpacCreateIntegerField			'PRImportPACAComplaint', 'pripc_DisForRepCompaintCount', 'Disputed Formal Reparations Complaint Count'
EXEC usp_AccpacCreateCurrencyField			'PRImportPACAComplaint', 'pripc_TotalFormalClaimAmt', 'Total Formal Claim Amount'

GO

--4.1.1.2	PRPACAComplaint
EXEC usp_AccpacDropTable					'PRPACAComplaint'
EXEC usp_AccpacCreateTable					'PRPACAComplaint', 'prpac', 'prpac_PACAComplaintID'
EXEC usp_AccpacCreateKeyField				'PRPACAComplaint', 'prpac_PACAComplaintID', 'PACA Complaint ID'
EXEC usp_AccpacCreateIntegerField		    'PRPACAComplaint', 'prpac_PACALicenseID', 'PACA License ID', 10, 'N', 'Y' --	NOT NULL required
EXEC usp_AccpacCreateIntegerField		    'PRPACAComplaint', 'prpac_InfRepComplaintCount', 'Informal Reparations Complaint Count'
EXEC usp_AccpacCreateIntegerField		    'PRPACAComplaint', 'prpac_DisInfRepComplaintCount', 'Disputed Informal Reparations Complaint Count'
EXEC usp_AccpacCreateIntegerField		    'PRPACAComplaint', 'prpac_ForRepComplaintCount', 'Formal Reparations Complaint Count'
EXEC usp_AccpacCreateIntegerField		    'PRPACAComplaint', 'prpac_DisForRepCompaintCount', 'Disputed Formal Reparations Complaint Count'
EXEC usp_AccpacCreateCurrencyField		    'PRPACAComplaint', 'prpac_TotalFormalClaimAmt', 'Total Formal Claim Amount'



GO

EXEC usp_AccpacCreateSelectField       'PRCompanyExperian', 'prcex_Employees', 'Employees', 'NumEmployees'
Go

-- Defect 5731 - PACA Import - Complaint Data requiring screen changes
EXEC usp_DeleteCustom_ScreenObject 'PPRPACAComplaintsGrid'
EXEC usp_AddCustom_ScreenObjects 'PPRPACAComplaintsGrid', 'List', 'vPRPACAComplaints', 'N', 0, 'vPRPACAComplaints'
EXEC usp_AddCustom_Lists 'PPRPACAComplaintsGrid', 20, 'prpac_InfRepComplaintCount', null, 'Y'
EXEC usp_AddCustom_Lists 'PPRPACAComplaintsGrid', 30, 'prpac_DisInfRepComplaintCount', null, 'Y'
EXEC usp_AddCustom_Lists 'PPRPACAComplaintsGrid', 40, 'prpac_ForRepComplaintCount', null, 'Y' 
EXEC usp_AddCustom_Lists 'PPRPACAComplaintsGrid', 50, 'prpac_DisForRepCompaintCount', null, 'Y'
EXEC usp_AddCustom_Lists 'PPRPACAComplaintsGrid', 60, 'prpac_TotalFormalClaimAmt', null, 'Y', 'Right'

EXEC usp_DefineCaptions 'vPRPACAComplaints', 'PACA Complaint', 'PACA Complaints', null, null, null, null

GO
                   
                   

