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

	SET NOCOUNT ON


	DECLARE @tblBatch TABLE (
		BatchID int 
	)

	DECLARE @MyTable TABLE (
		ndx int identity(1,1),
		LeadID int 
	)

	INSERT INTO @MyTable
	SELECT Lead.LeadID
		FROM LumberLeads.dbo.Lead
			INNER JOIN LumberLeads.dbo.Match ON LumberLeads.dbo.Lead.LeadID = LumberLeads.dbo.Match.LeadID
	WHERE MatchType = 'Phone'
	  AND (PhoneMatch IS NULL 
		   OR PhoneMatch = '')
     ORDER BY Lead.LeadID

	DECLARE @Index int, @Count int, @LeadID int, @BatchID int, @MatchedLeadID int
	DECLARE @CompanyName varchar(200), @City varchar(50), @State varchar(50), @Phone varchar(25)
	DECLARE @MatchType varchar(10)

	SELECT @Count = COUNT(1) FROM @MyTable
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN

		SET @Index = @Index + 1
		SET @BatchID = NULL
		SET @MatchedLeadID = NULL
		SET @MatchType = NULL

		SELECT @LeadID = Lead.LeadID,
		       @CompanyName = Lead.CompanyNameMatch,
			   @City = ISNULL(Lead.FirstCity, '<unknown>'),
			   @State = ISNULL(Lead.FirstState, '<unknown>'),
			   @Phone = LOWER(Lead.PhoneMatch)
		  FROM @MyTable mt
		       INNER JOIN Lead ON mt.LeadID = Lead.LeadID
		 WHERE ndx = @Index;
		 

		 DELETE FROM Match WHERE LeadID=@LeadID;

		-- Any leads matched to this lead should also
		-- be remated.
		INSERT INTO @MyTable
		SELECT Match.LeadID
		  FROM LumberLeads.dbo.Match 
		 WHERE MatchedLeadID = @LeadID
		 
		 DELETE FROM Match WHERE MatchedLeadID=@LeadID;

		 IF ((@Phone IS NOT NULL) AND
		     (@Phone <> '') AND
			 (@Phone <> 'unknown') AND
			 (@Phone NOT LIKE '0000000%') AND
			 (@Phone <> 'disconnected') AND
			 (@Phone <> 'noinfo') AND
			 (@Phone <> 'none') AND
			 (@Phone <> 'nona') AND
			 (@Phone <> '0')) BEGIN
		     
			 SET @MatchType = 'Phone'

			SELECT @BatchID = BatchID,
				   @MatchedLeadID = LeadID
			  FROM (
					SELECT Match.BatchID,
						   Lead.LeadID,
						   ROW_NUMBER() OVER (ORDER BY Match.BatchID) as Rnk
					  FROM Lead 
						   INNER JOIN Match ON Lead.LeadID = Match.LeadID 
					 WHERE Lead.PhoneMatch = @Phone
					   AND Lead.LeadID <> @LeadID) T1
			 WHERE Rnk=1

		END
		
		IF (@BatchID IS NULL) BEGIN
			SET @MatchType = 'Name'

			SELECT @BatchID = BatchID,
				   @MatchedLeadID = LeadID
			  FROM (
					SELECT Match.BatchID,
						   Lead.LeadID,
						   ROW_NUMBER() OVER (ORDER BY Match.BatchID) as Rnk
					  FROM Lead 
						   INNER JOIN Match ON Lead.LeadID = Match.LeadID 
					 WHERE Lead.CompanyNameMatch = @CompanyName
					   --AND ISNULL(Lead.FirstCity, '<unknown>') = @City
					   --AND ISNULL(Lead.FirstState, '<unknown>') = @State
					   AND Lead.LeadID <> @LeadID) T1
			 WHERE Rnk=1


		END

		IF (@BatchID IS NULL) BEGIN
			SELECT @BatchID = ISNULL(MAX(BatchID), 0) + 1 FROM Match
			SET @MatchType = NULL;
		END 

		INSERT INTO @tblBatch VALUES (@BatchID)

		INSERT INTO Match (BatchID, MatchedLeadID, LeadID, MatchType) 
                VALUES (@BatchID, @MatchedLeadID, @LeadID, @MatchType);

	END

	SET NOCOUNT OFF

	SELECT DISTINCT Match.*,
	       Lead.*
	  FROM @tblBatch b
	       INNER JOIN Match ON Match.BatchID = b.BatchID
		   INNER JOIN Lead ON Match.LeadID = Lead.LeadID
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


