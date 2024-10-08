USE [CRMExperian]
GO
/****** Object:  StoredProcedure [dbo].[usp_BRPopulateEquifaxData]    Script Date: 11/21/2017 4:56:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create or alter PROCEDURE [dbo].[usp_BRPopulateExperianData]
    @RequestID int, 
    @SubjectCompanyID int
AS
BEGIN
	DECLARE @CacheExpiration int, @GetData int, @DeleteData int, @ExperianDataID int
	DECLARE @DataCreatedDate datetime
	DECLARE @StatusCode varchar(40)
	SET @GetData = 0
	SET @DeleteData =0
	SET @CacheExpiration = dbo.ufn_GetCustomCaptionValue('ExperianIntegration', 'CacheExpiration', DEFAULT)
	SELECT @ExperianDataID = prexd_ExperianData,
           @DataCreatedDate = prexd_CreatedDate, 
           @StatusCode = prexd_StatusCode 
      FROM PRExperianData 
     WHERE prexd_RequestID = @RequestID
       AND prexd_CompanyID = @SubjectCompanyID;
	-- If we don't have a record, we need to 
    -- go get one.
	IF (@DataCreatedDate IS NULL) BEGIN
		--Print 'No Cache Record Found.'
		SET @GetData = 1
		
	END ELSE BEGIN
		--Print 'Cache Record Found.'
		IF (@DataCreatedDate <= DATEADD(hh, 0 - @CacheExpiration, GetDate())) BEGIN
			--Print 'Old Cache Record Found. Deleting It.'
			SET @DeleteData = 1
			SET @GetData = 1
		END ELSE BEGIN
			--Print 'Valid Cache Record Found.'
			-- If there was an error the first time, try again
			IF @StatusCode = 'E' BEGIN	
				--Print 'Cache Record has Status = "E".  Deleting It.'
				SET @DeleteData = 1
				SET @GetData = 1
			END
		END
	END
	IF (@DeleteData = 1) BEGIN

		delete from PRExperianBusinessCode where prexbc_CompanyID = @SubjectCompanyID and prexbc_RequestID = @RequestID
		delete from PRExperianData where prexd_CompanyID = @SubjectCompanyID and prexd_RequestID = @RequestID
		delete from PRExperianLegalFiling where prexlf_CompanyID = @SubjectCompanyID and prexlf_RequestID = @RequestID
		delete from PRExperianTradePaymentSummary where prextps_CompanyID = @SubjectCompanyID and prextps_RequestID = @RequestID
		delete from PRExperianTradePaymentDetail where prextpd_CompanyID = @SubjectCompanyID and prextpd_RequestID = @RequestID

--		DELETE FROM PREquifaxData WHERE preqf_EquifaxDataID = @EquifaxDataID;
--		DELETE FROM PREquifaxDataTradeInfo WHERE preqfti_EquifaxDataID = @EquifaxDataID;
	END
	IF (@GetData = 1) BEGIN
		EXEC dbo.usp_PopulateExperianData @RequestID, @SubjectCompanyID, null
	END
END



