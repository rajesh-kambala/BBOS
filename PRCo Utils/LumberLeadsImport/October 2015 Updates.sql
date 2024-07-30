ALTER TRIGGER [dbo].[trg_Lead_ins]
   ON  [dbo].[Lead]
   AFTER INSERT, UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	UPDATE Lead
       SET CompanyNameMatch = CRM.dbo.ufn_GetLowerAlpha(CRM.dbo.ufn_PrepareCompanyName(i.CompanyName)),
           PhoneMatch = CRM.dbo.ufn_GetLowerAlpha(i.PhoneNumber),
           FaxMatch = CRM.dbo.ufn_GetLowerAlpha(i.FaxNumber)
      FROM inserted i
     WHERE Lead.LeadID = i.LeadID;

END
Go

IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_DeleteAndRematchBatch]') 
            and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteAndRematchBatch]
GO

CREATE PROCEDURE [dbo].[usp_DeleteAndRematchBatch]
	@BadBatchID int
AS 
BEGIN

	SET NOCOUNT ON

	DECLARE @Start DateTime
	SET @Start = GETDATE()
	PRINT 'Execution Start: ' + CONVERT(VARCHAR(20), @Start, 100) + ' on server ' + @@SERVERNAME
	PRINT ''

	DECLARE @tblBatch TABLE (
		BatchID int 
	)

	DECLARE @MyTable TABLE (
		ndx int identity(1,1),
		LeadID int 
	)

	INSERT INTO @MyTable
	SELECT Lead.LeadID
	 FROM Lead
		  INNER JOIN Match ON Lead.LeadID = Match.LeadID
	WHERE BatchID = @BadBatchID;


	DELETE FROM Match WHERE BatchID=@BadBatchID;

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
  ORDER BY BatchID, MatchDateTime
		 


	PRINT '';PRINT ''

PRINT ''
PRINT 'Execution End: ' + CONVERT(VARCHAR(20), GETDATE(), 100)
PRINT 'Execution Time: ' +   CONVERT(varchar(25), CONVERT(TIME, GETDATE() - @Start))

END
Go


ALTER TABLE Lead DISABLE TRIGGER ALL
UPDATE Lead
    SET CompanyNameMatch = CRM.dbo.ufn_GetLowerAlpha(CRM.dbo.ufn_PrepareCompanyName(CompanyName)) 
ALTER TABLE Lead ENABLE TRIGGER ALL
