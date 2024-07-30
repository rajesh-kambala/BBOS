/*
Data Correction Script #2
Copy prbs_NewBBScore -> prbs_BBScore
PTS records only
Can take 3-4 mins to run
*/

USE CRM;
GO

--SET NOCOUNT ON

DECLARE @ForCommit bit
-- SET this variable to 1 to commit changes

SET @ForCommit = 0;

if (@ForCommit = 0) begin
	PRINT '*************************************************************'
	PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
	PRINT '*************************************************************'
	PRINT ''
end

DECLARE @Start DateTime
SET @Start = GETDATE()
PRINT 'Execution Start: ' + CONVERT(VARCHAR(20), @Start, 100) + ' on server ' + @@SERVERNAME
PRINT ''

BEGIN TRANSACTION
BEGIN TRY

	PRINT '1. Select the possibly bad data to work with'
	PRINT '-----------------------------------------------------'
	SELECT COUNT(*) PTSCountBefore FROM PRBBScore PRBBScore WITH(NOLOCK)
		INNER JOIN Company WITH(NOLOCK) ON Comp_CompanyId = prbs_CompanyId
	WHERE
		comp_PRIndustryType IN ('P','T','S')
    AND prbs_BlendedScore IS NOT NULL

	PRINT '2. Make database changes'
	PRINT '-----------------------------------------------------'
	UPDATE PRBBScore
	SET prbs_BBScore = prbs_BlendedScore,
		prbs_UpdatedDate = @Start,
		prbs_UpdatedBy = -1
	FROM PRBBScore 
		INNER JOIN Company ON Comp_CompanyId = prbs_CompanyId
	WHERE
		comp_PRIndustryType IN ('P','T','S')
	 AND prbs_BlendedScore IS NOT NULL

	PRINT '3. New data after updates'
	PRINT '-----------------------------------------------------'
	SELECT COUNT(*) PTSCountUpdated FROM PRBBScore WITH(NOLOCK) WHERE prbs_UpdatedDate = @Start

	SET NOCOUNT OFF

	PRINT '';PRINT ''

	if (@ForCommit = 1) begin
		PRINT 'COMMITTING CHANGES'
		COMMIT
	end else begin
		PRINT 'ROLLING BACK ALL CHANGES'
		ROLLBACK TRANSACTION
	end

	END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	EXEC usp_RethrowError;
END CATCH;

PRINT ''
PRINT 'Execution End: ' + CONVERT(VARCHAR(20), GETDATE(), 100)
PRINT 'Execution Time: ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE())) + ' ms'

