	DECLARE @CreatedByID int
	SET @CreatedByID = -7

	DECLARE @DLEmail table (
		CompanyID int,
		Email varchar(255)
	)

	-- Get the Email addresses 
	-- from the DL table.
	INSERT INTO @DLEmail (CompanyID, EMail)
	SELECT DISTINCT prdl_CompanyID,
		   LOWER(CASE when CHARINDEX (' ',prdl_LineContent) > 0 then reverse(substring(reverse(prdl_LineContent),0, CHARINDEX (' ',reverse(prdl_LineContent)))) else prdl_LineContent end)
	  FROM PRDescriptiveLine
           INNER JOIN Company on prdl_CompanyID = comp_CompanyID
	 WHERE prdl_LineContent like '%@%'
       AND comp_PRListingStatus IN ('L', 'H', 'N1');


	DECLARE @EmailUpdate table (
		ndx int identity(1,1) primary key,
		PersonID int,
        EmailID int
	)

	INSERT INTO @EmailUpdate(PersonID, EmailID)
	SELECT emai_PersonID, emai_EmailID
      FROM Email
           INNER JOIN @DLEmail ON Email = emai_EmailAddress AND emai_CompanyID = CompanyID AND emai_PersonID IS NOT NULL
     WHERE emai_Type = 'E'
       AND emai_PRPublish IS NULL
	ORDER BY emai_PersonID;

	DECLARE @PersonEmailCount int, @Index int, @PersonTrxId int
	DECLARE @PersonID int, @EmailID int

	SELECT @PersonEmailCount = COUNT(1) FROM @EmailUpdate;
	SET @Index = 0


	WHILE @Index < @PersonEmailCount BEGIN
		SET @Index = @Index + 1

		SELECT @PersonID = PersonID,
               @EmailID = EmailID
		  FROM @EmailUpdate
		 WHERE ndx = @Index;


		EXEC @PersonTrxId = usp_CreateTransaction 
			 @UserId = @CreatedByID,
             @prtx_PersonID = @PersonID,
			 @prtx_Explanation = 'BBOS Conversion: Marking all person emails found in DL as publishable.';

		UPDATE EMail
           SET emai_PRPublish='Y',
               emai_UpdatedBy = @CreatedByID,
               emai_UpdatedDate = GETDATE(),
               emai_Timestamp = GETDATE()
         WHERE emai_EMailID = @EmailID;

		UPDATE PRTransaction 
		   SET prtx_Status = 'C',
			   prtx_CloseDate = GETDATE()
		 WHERE prtx_TransactionID = @PersonTrxId;
	END

	SELECT pers_PersonID,
           dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_PRNickname1, NULL, pers_Suffix) As PersonName,
           comp_CompanyID,
           comp_Name,
           RTRIM(emai_EmailAddress) As emai_EmailAddress
      FROM EMail
           INNER JOIN Person on emai_PersonID = pers_PersonID
           INNER JOIN Company on emai_CompanyID = comp_CompanyID
     WHERE emai_UpdatedBy=-7;