--8.8 Release
USE CRM

--DELETE ALL ZERO PACA COMPLAINT DATA
DELETE FROM PRPACAComplaint WHERE prpac_PACALicenseID IN
(
	SELECT prpac_PACALicenseID FROM PRPACAComplaint 
	WHERE
		ISNULL(prpac_InfRepComplaintCount,0) = 0
			AND ISNULL(prpac_DisInfRepComplaintCount,0) = 0
			AND ISNULL(prpac_ForRepComplaintCount,0) = 0
			AND ISNULL(prpac_DisForRepCompaintCount,0) = 0
			AND ISNULL(prpac_TotalFormalClaimAmt,0.0) = 0.0
)
Go

--Defect 6836
--Updated existing PREmailImages record with new field data
UPDATE PREmailImages SET prei_Industry='B' WHERE prei_Industry IS NULL
Go

DECLARE @Start DateTime = GETDATE()
ALTER TABLE Company DISABLE TRIGGER ALL        
UPDATE Company 
	SET comp_PRReceivesBBScoreReport='Y', 
		Comp_UpdatedDate=@Start, 
		comp_updatedby=-1 
	WHERE comp_PRIndustryType = 'L'
	AND comp_PRReceivesBBScoreReport IS NULL
	ALTER TABLE Company ENABLE TRIGGER ALL         

ALTER TABLE Person_Link DISABLE TRIGGER ALL          
UPDATE Person_Link 
	SET peli_PRReceivesBBScoreReport = 'Y',
		PeLi_UpdatedDate = @Start,
		PeLi_UpdatedBy = -1
	FROM Company
	WHERE peli_CompanyID = comp_CompanyID
	AND comp_PRIndustryType='L'
	AND peli_PRReceivesBBScoreReport IS NULL
ALTER TABLE Person_Link ENABLE TRIGGER ALL   
Go