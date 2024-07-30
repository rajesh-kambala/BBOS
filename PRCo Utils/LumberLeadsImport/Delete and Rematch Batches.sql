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

	EXEC usp_DeleteAndRematchBatch 2  
	EXEC usp_DeleteAndRematchBatch 385  
	EXEC usp_DeleteAndRematchBatch 23297
	EXEC usp_DeleteAndRematchBatch 34060
	EXEC usp_DeleteAndRematchBatch 45035
	EXEC usp_DeleteAndRematchBatch 50403 

	DECLARE @MatchDate date = GETDATE()
	SELECT @MatchDate

	SELECT DISTINCT Match.*,
	       Lead.*
	  FROM Match
		   INNER JOIN Lead ON Match.LeadID = Lead.LeadID
	 WHERE BatchID IN (SELECT DISTINCT BatchID FROM Match INNER JOIN Lead ON Match.LeadID = Lead.LeadID AND MatchDateTime > @MatchDate)
  ORDER BY BatchID, Lead.LeadID


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


