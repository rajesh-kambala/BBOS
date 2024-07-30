UPDATE PRSSFile
   SET prss_Publish = 'Y',
       prss_Meritorious = 'NA'
 WHERE prss_ClosedDate >= '2013-05-01'
   AND prss_ClosedDate IS NOT NULL;

 UPDATE PRSSFile
   SET prss_Publish = 'Y',
       prss_Meritorious = 'NA'
 WHERE prss_Status IN ('P', 'O');

 UPDATE PRSSFile
    SET prss_ClaimantIndustryType = comp_PRIndustryType
   FROM Company
  WHERE prss_ClaimantCompanyID = comp_CompanyID
    AND prss_ClaimantCompanyID IS NOT NULL;
Go


UPDATE PRCompanySearch
   SET prcse_NameMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_Name)), 
       prcse_LegalNameMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PRLegalName)),
	   prcse_CorrTradestyleMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PRCorrTradestyle)), 
       prcse_OriginalNameMatch = CASE WHEN comp_PROriginalName IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROriginalName)) ELSE NULL END,
       prcse_OldName1Match = CASE WHEN comp_PROldName1 IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROldName1)) ELSE NULL END,
	   prcse_OldName2Match = CASE WHEN comp_PROldName2 IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROldName2)) ELSE NULL END,
	   prcse_OldName3Match = CASE WHEN comp_PROldName3 IS NOT NULL THEN dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(comp_PROldName3)) ELSE NULL END
  FROM Company
 WHERE prcse_CompanyID = comp_CompanyID;
Go 



/*
SELECT comp_CompanyID as [BB ID],
       comp_Name as [Company Name],
	   pers_PersonID [Person ID], 
	   dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) as [Person Name],
	   phon_PRDescription as [Phone Description],
	   dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) as [Phone Number]
  FROM Phone 
       INNER JOIN Company ON phon_CompanyID = comp_CompanyID
	   INNER JOIN Person ON phon_PersonID = pers_PersonID
WHERE pers_PersonID IS NOT NULL
ORDER BY comp_CompanyID
*/

ALTER TABLE Phone DISABLE TRIGGER ALL
UPDATE Phone
   SET phon_PRDescription = dbo.ufn_GetCustomCaptionValue('phon_TypePerson', phon_Type, 'en-us')
 WHERE phon_PRDescription IS NULL
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Cell'
 WHERE phon_PRDescription IN ('Cell Phone', 'Mobile', 'Mobile or Cell')
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Accounting FAX'
 WHERE phon_PRDescription COLLATE Latin1_General_CS_AS = 'Accounting Fax'
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Direct Office Phone'
 WHERE phon_PRDescription IN ('Direct', 'Direct Office', 'Direct Phone', 'Office phone', 'Phone')
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Direct Office FAX'
 WHERE phon_PRDescription = 'Direct FAX'
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'E-FAX'
 WHERE phon_PRDescription COLLATE Latin1_General_CS_AS = 'E-Fax'
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Company Extension'
 WHERE phon_PRDescription = 'Extension'
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Direct Office FAX'
 WHERE phon_PRDescription = 'FAX'
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Nextel Direct Connect'
 WHERE phon_PRDescription IN ('Nextel Connect', 'Nextel ID', 'Nextel ID#')
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Remote FAX'
 WHERE phon_PRDescription COLLATE Latin1_General_CS_AS = 'Remote fax'
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Residence'
 WHERE phon_PRDescription IN ('Res.', 'Res')
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Residence FAX'
 WHERE phon_PRDescription IN ('Res. FAX', 'res. FAX')
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'Residence Toll Free'
 WHERE phon_PRDescription IN ('Res. Toll Free')
   AND phon_PersonID IS NOT NULL;

UPDATE Phone
   SET phon_PRDescription = 'US Cell'
 WHERE phon_PRDescription IN ('USA Cell')
   AND phon_PersonID IS NOT NULL;
ALTER TABLE Phone ENABLE TRIGGER ALL
Go


--
--  Fix AUS Settings
--
	DECLARE @Now datetime = GETDATE();
	DECLARE @UpdateById int = -1;


	DECLARE @RecordCount int;
	DECLARE @ndx int;
	DECLARE @TrxID int;
	DECLARE @RecordID int, @PersonLinkID int, @PersonID int
	DECLARE @TransactionNote varchar(1000);

	DECLARE @Records table (
		ndx int identity(1,1), 
		PersonLinkID int,
		PersonID int)

	--And enter the transaction note
	SET @TransactionNote = 'AUS send method was set to deliver by email, via data correction.'

	INSERT INTO @Records
	SELECT peli_PersonLinkID, peli_PersonID
	  FROM PRWebUser
		   INNER JOIN Person_Link ON prwu_PersonLinkID = peli_PersonLinkID
		   INNER JOIN PRWebUserList ON prwu_WebUserID = prwucl_WebUserID AND prwucl_TypeCode = 'AUS'
	 WHERE peli_PRStatus = '1'
	   AND ISNULL(peli_PRAUSReceiveMethod, '')  = ''
	   AND prwu_AccessLevel >= 200
	   AND peli_PRStatus = '1'
	ORDER BY peli_PersonLinkID, peli_PersonID;

	SELECT @RecordCount = COUNT(1) FROM @Records;
	SET @ndx = 0

	WHILE (@ndx < @RecordCount) BEGIN

		SELECT @ndx = @ndx + 1;
		SELECT @RecordID = NULL;
		SELECT @TrxId = NULL;
	
		SELECT @PersonLinkID = PersonLinkID,
			   @PersonID = PersonID
		  FROM @Records 
		 WHERE ndx = @ndx
			
		--Open a transaction
		IF (NOT EXISTS (SELECT 1 FROM PRTransaction WHERE prtx_Status = 'O' AND prtx_PersonId = @PersonID)) BEGIN
				EXEC @TrxId = usp_CreateTransaction 
				@UserId = @UpdateById,
				@prtx_PersonId = @PersonID,
				@prtx_Explanation = @TransactionNote
		END
				
		-- Perform appropriate updates here
		UPDATE Person_Link
			SET peli_PRAUSReceiveMethod = '2',  -- Email
				peli_PRAUSChangePreference =  '2',  -- All Changes
				peli_UpdatedBy = @UpdateById,
				peli_UpdatedDate = @Now,
				peli_TimeStamp = @Now
			WHERE peli_PersonLinkID = @PersonLinkID
			
			
		--Close the transaction
		IF (@TrxId IS NOT NULL)
			UPDATE PRTransaction SET prtx_Status = 'C' WHERE prtx_TransactionId = @TrxId

	END
Go



INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT comp_CompanyID, 'LRL', -1, -1
  FROM Company
	   LEFT OUTER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'LRL'
 WHERE prattn_AttentionLineID IS NULL
  AND comp_PRListingStatus NOT IN ('D', 'N3');

INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT comp_CompanyID, 'JEP-M', -1, -1
  FROM Company
	   LEFT OUTER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'JEP-M'
 WHERE prattn_AttentionLineID IS NULL
  AND comp_PRListingStatus NOT IN ('D', 'N3');

INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT comp_CompanyID, 'JEP-E', -1, -1
  FROM Company
	   LEFT OUTER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'JEP-E'
 WHERE prattn_AttentionLineID IS NULL
  AND comp_PRListingStatus NOT IN ('D', 'N3');

INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT comp_CompanyID, 'TES-E', -1, -1
  FROM Company
	   LEFT OUTER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'TES-E'
 WHERE prattn_AttentionLineID IS NULL
  AND comp_PRListingStatus NOT IN ('D', 'N3');

INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT comp_CompanyID, 'TES-M', -1, -1
  FROM Company
	   LEFT OUTER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'TES-M'
 WHERE prattn_AttentionLineID IS NULL
  AND comp_PRListingStatus NOT IN ('D', 'N3');

INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT comp_CompanyID, 'TES-V', -1, -1
  FROM Company
	   LEFT OUTER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'TES-V'
 WHERE prattn_AttentionLineID IS NULL
  AND comp_PRListingStatus NOT IN ('D', 'N3');

INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT comp_CompanyID, 'LRL', -1, -1
  FROM Company
	   LEFT OUTER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'LRL'
 WHERE prattn_AttentionLineID IS NULL
  AND comp_PRListingStatus NOT IN ('D', 'N3');

INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT comp_CompanyID, 'BILL', -1, -1
  FROM Company
	   LEFT OUTER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'BILL'
 WHERE prattn_AttentionLineID IS NULL
  AND comp_PRListingStatus NOT IN ('D', 'N3');

INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT comp_CompanyID, 'ARD', -1, -1
  FROM Company
	   LEFT OUTER JOIN PRAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'ARD'
 WHERE prattn_AttentionLineID IS NULL
  AND comp_PRListingStatus NOT IN ('D', 'N3');
GO
 

 --
 --  Create any missing AUS type 23 company relationship records.
 --
	DECLARE @MyTable table (
		ndx int identity(1,1) primary key,
		LeftCompanyID int,
		RightCompanyID int
	)

	INSERT INTO @MyTable (LeftCompanyID, RightCompanyID)
	SELECT prwucl_CompanyID as LeftCompanyID, prwuld_AssociatedID as RightCompanyID
	  FROM PRWebUserList
		   INNER JOIN PRWebUserListDetail ON prwucl_WebUserListID = prwuld_WebUserListID
		   INNER JOIN Company lc ON prwucl_CompanyID = lc.comp_CompanyID
		   INNER JOIN Company rc ON prwuld_AssociatedID = rc.comp_CompanyID
		   LEFT OUTER JOIN PRCompanyRelationship ON prcr_LeftCompanyId = prwucl_CompanyID
												AND prcr_RightCompanyId = prwuld_AssociatedID
												AND prcr_Type = '23'
	 WHERE prwucl_TypeCode = 'AUS'
	   AND prcr_CompanyRelationshipId IS NULL
	   AND prwucl_CompanyID <> prwuld_AssociatedID
	   AND lc.comp_CompanyID <> rc.comp_CompanyID
	ORDER BY LeftCompanyID, RightCompanyID;


	DECLARE @Count int, @Index int, @LeftCompanyID int, @RightCompanyID int

	SELECT @Count = COUNT(1) FROM @MyTable;
	SET @Index = 0

	WHILE (@Index < @Count) BEGIN

		SET @Index = @Index + 1

		SELECT @LeftCompanyID = LeftCompanyID,
			   @RightCompanyID = RightCompanyID
		  FROM @MyTable
		 WHERE ndx = @Index;

		 PRINT '- Creating Type 23 Company Relationship Record for ' + CAST(@LeftCompanyID as varchar) + ': ' + CAST(@RightCompanyID as varchar)
		 EXEC usp_UpdateCompanyRelationship @LeftCompanyID, @RightCompanyID, '23'
	END
Go	 


UPDATE Custom_Captions 
   SET capt_us = 'Use Quick Find, in the upper right hand corner of the screen, to search by company name or Blue Book #. Learn more about Quick Find in the <a href="Training.aspx">Training Center</a>.'
 WHERE capt_Family = 'MessageCenterMsg'
   AND capt_Code = 'Message'
Go



ALTER TABLE Company DISABLE TRIGGER ALL

UPDATE Company
   SET comp_PRServiceStartDate = CodeStartDate,
       comp_PRServiceEndDate = CodeEndDate
  FROM (
		SELECT prse_CompanyID,
			   CASE WHEN ServiceStartDate <  CodeStartDate THEN ServiceStartDate ELSE CodeStartDate END as CodeStartDate,
			   CASE 
				 WHEN [Primary] = 'Y' THEN NULL
				 ELSE CASE WHEN StopServiceDate >  CodeEndDate THEN StopServiceDate ELSE CodeEndDate END END as CodeEndDate,
			   [Primary]
		  FROM (
				SELECT prse_CompanyID, 
						MIN(prse_ServiceSinceDate) as ServiceStartDate, 
						MIN(ISNULL(prse_CodeStartDate, ISNULL(prse_ShipmentDate, DATEADD(Year, -1, prse_NextAnniversaryDate)))) as CodeStartDate, 
						MAX(prse_StopServiceDate) as StopServiceDate, 
						MAX(prse_CodeEndDate) as CodeEndDate, 
						MIN(ISNULL(prse_Primary, 'Z')) as [Primary]
				  FROM (
					SELECT prse_CompanyID, 
						   prse_ServiceSinceDate, 
						   prse_CodeStartDate, 
						   prse_NextAnniversaryDate,
						   prse_StopServiceDate, 
						   prse_CodeEndDate, 
						   prse_ShipmentDate,
						   ISNULL(prse_Primary, 'Z') as prse_Primary
						FROM PRService_Backup 
					   WHERE prse_ServiceCode LIKE 'BBS%' 
					UNION
					SELECT prse_CompanyID, 
						   prse_ServiceSinceDate, 
						   prse_CodeStartDate, 
						   prse_NextAnniversaryDate,
						   prse_StopServiceDate, 
						   prse_CodeEndDate, 
						   prse_ShipmentDate,
						   ISNULL(prse_Primary, 'Z') as prse_Primary
						FROM PRServiceArchive
                       WHERE prse_ServiceCode IN (
							'PO','PM','EM','RM','ZA','P3','ME','TO', 
							'FO','TM','FM','TR','FR','ZC','ZE','T3','F3','PB','RB','ZB','TB','FB', 
							'T5','F5','ZD','ZF','JB','JM','JZ','JX','OM','OR','OZ','OB','O5','OQ')
					) T10
				GROUP BY prse_CompanyID
				) T1
	   ) T2
 WHERE comp_CompanyID = prse_CompanyID

--  If a current member does not have a start date
--  assume they started after the MAS conversion
UPDATE Company
   SET comp_PRServiceStartDate = prse_CreatedDate,
       comp_PRServiceEndDate = NULL
  FROM PRService 
 WHERE comp_CompanyID = prse_CompanyID
   AND prse_Primary = 'Y'
   AND prse_CreatedDate <> '2012-10-01'


--  A current member should not have an end date
/*UPDATE Company
   SET comp_PRServiceEndDate = NULL
  FROM PRService 
 WHERE comp_CompanyID = prse_CompanyID
   AND prse_Primary = 'Y'
*/

--  No end dates should be in the future
UPDATE Company
   SET comp_PRServiceEndDate = NULL
  FROM PRService 
 WHERE comp_PRServiceEndDate > GETDATE()

ALTER TABLE Company ENABLE TRIGGER ALL
Go

