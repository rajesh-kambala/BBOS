
--
-- BEGIN EMAIL Changes
--
ALTER TABLE Email DISABLE TRIGGER ALL

-- Reset our data
UPDATE Email 
   SET emai_PRPreferredInternal = null,
       emai_PRPreferredPublished = null;
 
-- Handles both company
-- and person levels.       
UPDATE Email
   SET emai_PRPreferredInternal = emai_PRDefault
 WHERE emai_Type = 'E';
 
-- Now find those companies that have a single
-- email address that is not marked "preferred".
DECLARE @MyTable table (
	CompanyID int,
	HasPreferredInternal char(1)
)	

INSERT INTO @MyTable	   
SELECT emai_CompanyID, emai_PRPreferredInternal
     FROM Email
    WHERE emai_PersonID IS NULL
      AND emai_CompanyID IS NOT NULL
      AND emai_Type='E'

UPDATE Email
   SET emai_PRPreferredInternal = 'Y'
 WHERE emai_CompanyID IN  (
		SELECT emai_CompanyID
	      FROM (SELECT emai_CompanyID,  COUNT(1) As EmailCount
				  FROM Email e
					   LEFT OUTER JOIN @MyTable ON e.emai_CompanyID = CompanyID
				 WHERE e.emai_PersonID IS NULL
				   AND e.emai_Type='E'
				   AND e.emai_CompanyID IS NOT NULL
				   AND HasPreferredInternal IS NULL
				GROUP BY emai_CompanyID) T1
	 	 WHERE EmailCount = 1)
  AND emai_Type = 'E'
  AND emai_PRPreferredInternal IS NULL;


-- Now find those companies/persons that have a single
-- email address that is not marked "preferred".
DECLARE @MyTable2 table (
	CompanyID int,
	PersonID int,
	HasPreferredInternal char(1)
)	

INSERT INTO @MyTable2	   
SELECT emai_CompanyID, emai_PersonID, emai_PRPreferredInternal
     FROM Email
    WHERE emai_PersonID IS NOT NULL
      AND emai_CompanyID IS NOT NULL
      AND emai_Type='E';
      
UPDATE Email
   SET emai_PRPreferredInternal = 'Y'
  FROM (SELECT emai_CompanyID As CompanyID, emai_PersonID As PersonID, COUNT(1) As EmailCount
		  FROM Email e
			   LEFT OUTER JOIN @MyTable2 ON e.emai_CompanyID = CompanyID AND e.emai_PersonID = PersonID
		 WHERE e.emai_PersonID IS NOT NULL
		   AND e.emai_Type='E'
		   AND e.emai_CompanyID IS NOT NULL
		   AND HasPreferredInternal IS NULL
	  GROUP By emai_CompanyID, emai_PersonID) T1
 WHERE emai_CompanyID = CompanyID
   AND emai_PersonID = PersonID
   AND EmailCount = 1
   AND emai_Type = 'E'
   AND emai_PRPreferredInternal IS NULL;
 
 
 
UPDATE Email
   SET emai_PRPreferredPublished = 'Y'
 WHERE emai_EmailID IN (
       SELECT EmailID FROM (
		 SELECT emai_CompanyID As CompanyID, emai_EmailID As EmailID, Rank() over (Partition BY emai_CompanyID order by ISNULL(emai_PRDefault, 'Z'), emai_EmailID) as Rank
		   FROM email
		  WHERE emai_PRPublish = 'Y'
			AND emai_Type = 'E'
			AND emai_PersonID IS NULL
			AND emai_CompanyID IS NOT NULL) T1
		WHERE Rank=1);
 
 UPDATE Email
   SET emai_PRPreferredPublished = 'Y'
 WHERE emai_EmailID IN (
		SELECT EmailID FROM (
		 SELECT emai_CompanyID As CompanyID, emai_PersonID as PersonID, emai_PRDefault, emai_PRPublish, emai_EmailID As EmailID, Rank() over (Partition BY emai_CompanyID, emai_PersonID order by ISNULL(emai_PRDefault, 'Z'), emai_EmailID) as Rank
		   FROM email
		  WHERE emai_PRPublish = 'Y'
			AND emai_Type = 'E'
			AND emai_PersonID IS NOT NULL
			AND emai_CompanyID IS NOT NULL) T1
	WHERE Rank=1);
 ALTER TABLE Email ENABLE TRIGGER ALL
 
 
 
 
--
--  BEGIN PHONE Changes
-- 
ALTER TABLE Phone DISABLE TRIGGER ALL

-- Reset our data
UPDATE Phone 
   SET phon_PRPreferredInternal = null,
       phon_PRPreferredPublished = null
 WHERE phon_CompanyID IS NOT NULL
   AND phon_PersonID IS NULL;
 
-- Handles both company
-- and person levels.       
UPDATE Phone
   SET phon_PRPreferredInternal = phon_Default;
 
-- Now find those companies that have a single
-- fax # that is not marked "preferred".
DELETE FROM @MyTable;

INSERT INTO @MyTable	   
SELECT phon_CompanyID, phon_PRPreferredInternal
     FROM Phone
    WHERE phon_PersonID IS NULL
      AND phon_CompanyID IS NOT NULL
      AND phon_Type IN ('F', 'PF', 'SF', 'EFAX')


-- Set the Preferred Internal flag on those company / persons
-- faxes that do not already have a phone with this
-- flag set and that only have a single phone number.  
UPDATE Phone
   SET phon_PRPreferredInternal = 'Y'
 WHERE phon_CompanyID IN  (
		SELECT phon_CompanyID
	      FROM (SELECT phon_CompanyID,  COUNT(1) As PhoneCount
				  FROM Phone
					   LEFT OUTER JOIN @MyTable ON phon_CompanyID = CompanyID
				 WHERE phon_PersonID IS NULL
				   AND phon_Type IN ('F', 'PF', 'SF', 'EFAX')
				   AND phon_CompanyID IS NOT NULL
				   AND HasPreferredInternal IS NULL
				GROUP BY phon_CompanyID) T1
	 	 WHERE PhoneCount = 1)
  AND phon_Type IN ('F', 'PF', 'SF', 'EFAX')
  AND phon_PRPreferredInternal IS NULL;


-- Now find those companies/persons that have a single
-- fax # that is not marked "preferred".
DELETE FROM @MyTable2 

INSERT INTO @MyTable2	   
SELECT phon_CompanyID, phon_PersonID, phon_PRPreferredInternal
     FROM Phone
    WHERE phon_PersonID IS NOT NULL
      AND phon_CompanyID IS NOT NULL
      AND phon_Type IN ('F', 'PF', 'SF', 'EFAX')
      
UPDATE Phone
   SET phon_PRPreferredInternal = 'Y'
  FROM (SELECT phon_CompanyID As CompanyID, phon_PersonID As PersonID, COUNT(1) As PhoneCount
		  FROM Phone
			   LEFT OUTER JOIN @MyTable2 ON phon_CompanyID = CompanyID AND phon_PersonID = PersonID
		 WHERE phon_PersonID IS NOT NULL
		   AND phon_Type IN ('F', 'PF', 'SF', 'EFAX')
		   AND phon_CompanyID IS NOT NULL
		   AND HasPreferredInternal IS NULL
		GROUP By phon_CompanyID, phon_PersonID) T1
 WHERE phon_CompanyID = CompanyID
   AND phon_PersonID = PersonID
   AND PhoneCount = 1
   AND phon_Type IN ('F', 'PF', 'SF', 'EFAX')
   AND phon_PRPreferredInternal IS NULL;
 
 
UPDATE Phone
   SET phon_PRPreferredPublished = 'Y'
 WHERE phon_PhoneID IN (
       SELECT PhoneID FROM (
		 SELECT phon_CompanyID As CompanyID, phon_PhoneID As PhoneID, Rank() over (Partition BY phon_CompanyID order by ISNULL(phon_Default, 'Z'), phon_PhoneID) as Rank
		   FROM Phone
		  WHERE phon_PRPublish = 'Y'
		    AND phon_Type IN ('F', 'PF', 'SF', 'EFAX')
			AND phon_PersonID IS NULL
			AND phon_CompanyID IS NOT NULL) T1
		WHERE Rank=1)
  AND phon_PRPreferredPublished IS NULL;
   
 
UPDATE Phone
   SET phon_PRPreferredPublished = 'Y'
 WHERE phon_PhoneID IN (
       SELECT PhoneID FROM (
		 SELECT phon_CompanyID As CompanyID, phon_PersonID As PersonID, phon_PhoneID As PhoneID, Rank() over (Partition BY phon_CompanyID, phon_PersonID order by ISNULL(phon_Default, 'Z'), phon_PhoneID) as Rank
		   FROM Phone
		  WHERE phon_PRPublish = 'Y'
		    AND phon_Type IN ('F', 'PF', 'SF', 'EFAX')
			AND phon_PersonID IS NOT NULL
			AND phon_CompanyID IS NOT NULL) T1
		WHERE Rank=1)
  AND phon_PRPreferredPublished IS NULL;
 


	
	
	
-- Now find those companies that have a single
-- phone # that is not marked "preferred".
DELETE FROM @MyTable;

INSERT INTO @MyTable	   
SELECT phon_CompanyID, phon_PRPreferredInternal
     FROM Phone
    WHERE phon_PersonID IS NULL
      AND phon_CompanyID IS NOT NULL
      AND phon_Type NOT IN ('F', 'SF', 'EFAX')

-- Set the Preferred Internal flag on those company 
-- regular phones that do not already have a phone with this
-- flag set and that only have a single phone number.  
UPDATE Phone
   SET phon_PRPreferredInternal = 'Y'
 WHERE phon_CompanyID IN  (
		SELECT phon_CompanyID
	      FROM (SELECT phon_CompanyID,  COUNT(1) As PhoneCount
				  FROM Phone
					   LEFT OUTER JOIN @MyTable ON phon_CompanyID = CompanyID
				 WHERE phon_PersonID IS NULL
				   AND phon_Type NOT IN ('F', 'SF', 'EFAX')
				   AND phon_CompanyID IS NOT NULL
				   AND HasPreferredInternal IS NULL
				GROUP BY phon_CompanyID) T1
	 	 WHERE PhoneCount = 1)
  AND phon_Type NOT IN ('F', 'SF', 'EFAX')
  AND phon_PRPreferredInternal IS NULL;


-- Now find those companies/persons that have a single
-- phone # that is not marked "preferred".
DELETE FROM @MyTable2 

INSERT INTO @MyTable2	   
SELECT phon_CompanyID, phon_PersonID, phon_PRPreferredInternal
     FROM Phone
    WHERE phon_PersonID IS NOT NULL
      AND phon_CompanyID IS NOT NULL
      AND phon_Type NOT IN ('F', 'SF', 'EFAX')


-- Set the Preferred Internal flag on those company / persons
-- regular phones that do not already have a phone with this
-- flag set and that only have a single phone number.      
UPDATE Phone
   SET phon_PRPreferredInternal = 'Y'
  FROM (SELECT phon_CompanyID As CompanyID, phon_PersonID As PersonID, COUNT(1) As PhoneCount
		  FROM Phone
			   LEFT OUTER JOIN @MyTable2 ON phon_CompanyID = CompanyID AND phon_PersonID = PersonID
		 WHERE phon_PersonID IS NOT NULL
		   AND phon_Type NOT IN ('F', 'SF', 'EFAX')
		   AND phon_CompanyID IS NOT NULL
		   AND HasPreferredInternal IS NULL
		GROUP By phon_CompanyID, phon_PersonID) T1
 WHERE phon_CompanyID = CompanyID
   AND phon_PersonID = PersonID
   AND PhoneCount = 1
   AND phon_Type NOT IN ('F', 'SF', 'EFAX')
   AND phon_PRPreferredInternal IS NULL;
 
 
-- Set the Preferred Published flag for regular phones
-- based on the first old published flag found, giving
-- priority to those also set as default.
-- COMPANY
UPDATE Phone
   SET phon_PRPreferredPublished = 'Y'
 WHERE phon_PhoneID IN (
       SELECT PhoneID FROM (
		 SELECT phon_CompanyID As CompanyID, phon_PhoneID As PhoneID, Rank() over (Partition BY phon_CompanyID order by ISNULL(phon_Default, 'Z'), phon_PhoneID) as Rank
		   FROM Phone
		  WHERE phon_PRPublish = 'Y'
		    AND phon_Type NOT IN ('F', 'SF', 'EFAX')
			AND phon_PersonID IS NULL
			AND phon_CompanyID IS NOT NULL) T1
		WHERE Rank=1)
  AND phon_PRPreferredPublished IS NULL;

-- Set the Preferred Published flag for regular phones
-- based on the first old published flag found, giving
-- priority to those also set as default.
-- COMPANY/PERSON
UPDATE Phone
   SET phon_PRPreferredPublished = 'Y'
 WHERE phon_PhoneID IN (
       SELECT PhoneID FROM (
		 SELECT phon_CompanyID As CompanyID, phon_PersonID As PersonID, phon_PhoneID As PhoneID, Rank() over (Partition BY phon_CompanyID, phon_PersonID order by ISNULL(phon_Default, 'Z'), phon_PhoneID) as Rank
		   FROM Phone
		  WHERE phon_PRPublish = 'Y'
		    AND phon_Type NOT IN ('F', 'SF', 'EFAX')
			AND phon_PersonID IS NOT NULL
			AND phon_CompanyID IS NOT NULL) T1
		WHERE Rank=1)
  AND phon_PRPreferredPublished IS NULL;

UPDATE Phone
   SET phon_PRIsPhone = 'Y'
 WHERE phon_Type NOT IN ('F', 'SF', 'EFAX');		

UPDATE Phone
   SET phon_PRIsFax = 'Y'
 WHERE phon_Type  IN ('F', 'PF', 'SF', 'EFAX');		
		
ALTER TABLE Phone ENABLE TRIGGER ALL
 
 
 
 
 
 
 
 --
 -- Handle the web sites
 -- 
ALTER TABLE Email DISABLE TRIGGER ALL
UPDATE Email
   SET emai_PRPreferredPublished = 'Y'
 WHERE emai_Type = 'W'
   AND emai_PRDefault = 'Y'
   AND emai_PRPublish = 'Y'


UPDATE Email
   SET emai_PRPreferredPublished = 'Y'
  FROM (
		SELECT emai_CompanyID As CompanyID, MIN(emai_EmailID) As EmailID
		  from Email 
		where emai_Type = 'W'
		  AND emai_PRPublish = 'Y'
		  AND emai_CompanyID NOT IN (SELECT emai_CompanyID FROM  Email where emai_Type = 'W' and emai_PRPreferredPublished = 'Y' AND emai_CompanyID IS NOT NULL)
		  AND emai_CompanyID IS NOT NULL
		GROUP BY emai_CompanyID) T1 
WHERE emai_EmailID = EmailID;		
ALTER TABLE Email ENABLE TRIGGER ALL  
Go

--
-- Begin Pay Rating Changes
--
INSERT INTO CRMArchive.dbo.PRPayRatingPreABConversion SELECT * FROM CRM.dbo.PRPayRating;
INSERT INTO CRMArchive.dbo.PRRatingPreABConversion SELECT * FROM CRM.dbo.PRRating;
INSERT INTO CRMArchive.dbo.PRTradeReportPreABConversion SELECT * FROM CRM.dbo.PRTradeReport;

UPDATE PRPayRating
   SET prpy_Deleted = 1
 WHERE prpy_PayRatingID = 7;
 
UPDATE PRPayRating
   SET prpy_TradeReportDescription = '15-21 (A)',
       prpy_Weight = 6
 WHERE prpy_PayRatingID = 8;
 
UPDATE PRPayRating
   SET prpy_TradeReportDescription = '1-14 (AA)',
       prpy_Weight = 7
 WHERE prpy_PayRatingID = 9;
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ConvertPayRating]'))
    drop procedure [dbo].[usp_ConvertPayRating]
GO

CREATE PROCEDURE dbo.usp_ConvertPayRating
    @OldPayRatingID int,
    @NewPayRatingID int
as
BEGIN

    SET NOCOUNT ON
	DECLARE @Msg varchar(2000)
    DECLARE @comp_companyid int
    DECLARE @TrxId int
    DECLARE @CompanyCount int
    DECLARE @ndx int
    DECLARE @OldRatingId int, @NewRatingId int

	DECLARE @NOW datetime
	SET @NOW = getDate()

    DECLARE @UserId int
    SET @UserID = -1


    -- Create a local table for the companies with rating numerals to be removed
    DECLARE @tblCompanies TABLE (
		ndx int identity, 
		comp_companyid int,
		old_rating_id int
	)

	-- get a list of all the companies that have rating numerals to remove
	INSERT INTO @tblCompanies
        SELECT prra_companyid, prra_RatingID
          FROM PRRating 
         WHERE prra_PayRatingID = @OldPayRatingID
           AND prra_Current = 'Y'
      ORDER BY prra_companyid

	SET @CompanyCount = @@ROWCOUNT
	SET @ndx = 1

    -- Start making our updates
	BEGIN TRY	
		WHILE (@ndx <= @CompanyCount)
		BEGIN
			SET @comp_companyid = null
			SET @NewRatingId = NULL
			SET @TrxId = NULL

			-- get the company we are operating on
			SELECT @comp_companyid = comp_companyid,
			       @OldRatingId = old_rating_id
			  FROM @tblCompanies 
			 WHERE ndx = @ndx


			BEGIN TRANSACTION

			-- Open a transaction if one is not open
			IF (Not Exists (SELECT 'x' 
			                  FROM PRTransaction 
						     WHERE prtx_Status = 'O' 
						       AND prtx_companyid = @comp_companyid))
			BEGIN
			  exec @TrxId = usp_CreateTransaction 
							 @UserId = @UserId,
							 @prtx_CompanyId = @comp_companyid,
							 @prtx_Explanation = 'Transaction created by ''AB'' Pay Rating conversion process.'
			END

			EXEC usp_GetNextId 'PRRating', @NewRatingId output

			INSERT INTO PRRating
			   (prra_RatingId, prra_Deleted, prra_WorkflowId, prra_Secterr, prra_CreatedBy,
				prra_CreatedDate, prra_UpdatedBy, prra_UpdatedDate, prra_TimeStamp,
				prra_CompanyId, prra_Date, prra_Current, prra_CreditWorthId, prra_IntegrityId,
				prra_PayRatingId, prra_InternalAnalysis, prra_PublishedAnalysis)
			SELECT @NewRatingId, null, prra_WorkflowId, prra_Secterr, @UserId, 
				   @NOW, @UserId, @NOW, @NOW, 
				   @comp_companyid, @NOW, 'Y', prra_CreditWorthId, prra_IntegrityId,
				   @NewPayRatingID, prra_InternalAnalysis, prra_PublishedAnalysis
			  FROM PRRating 
			 WHERE prra_RatingID = @OldRatingId;

			-- Now copy rating numerals
			INSERT INTO PRRatingNumeralAssigned
				(pran_RatingNumeralAssignedId, pran_Deleted, pran_WorkflowId, pran_Secterr,
						 pran_CreatedBy, pran_CreatedDate, pran_UpdatedBy, pran_UpdatedDate, pran_TimeStamp,
						 pran_RatingId, pran_RatingNumeralId)
			SELECT NULL, NULL, pran_WorkflowId, pran_Secterr,  
			  	   @UserId, @NOW, @UserId, @NOW, @NOW,
				   @NewRatingId, pran_RatingNumeralId
			  FROM PRRatingNumeralAssigned
			 WHERE pran_RatingId = @OldRatingId;
	

 		    IF (@TrxId IS NOT NULL) BEGIN
				UPDATE PRTransaction 
 		          SET prtx_Status = 'C' 
 		        WHERE prtx_TransactionId = @TrxId;
 		    END
			
		    -- if we made it here, commit our work
			COMMIT
			SET @ndx = @ndx+1
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		EXEC usp_RethrowError;
	END CATCH;

    return @CompanyCount
    SET NOCOUNT OFF
END
GO




SELECT prra_PayRatingId, COUNT(1)
  FROM PRRating
 WHERE prra_PayRatingId IN (7, 8, 9)
   AND prra_Current = 'Y'  
GROUP BY prra_PayRatingId       
   

SELECT prra_CompanyID, prra_PayRatingID, prra_RatingLine
  FROM vPRCompanyRating
 WHERE prra_PayRatingId IN (7, 8, 9)
   AND prra_Current = 'Y';  

   
EXEC usp_ConvertPayRating 8, 9
EXEC usp_ConvertPayRating 7, 8

    
SELECT prra_PayRatingId, COUNT(1)
  FROM PRRating
 WHERE prra_PayRatingId IN (7, 8, 9)
   AND prra_Current = 'Y'  
GROUP BY prra_PayRatingId; 

SELECT prra_CompanyID, prra_PayRatingID, prra_RatingLine
  FROM vPRCompanyRating
 WHERE prra_PayRatingId IN (7, 8, 9)
   AND prra_Current = 'Y';  
Go   

 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usp_ConvertPayRating]'))
    drop procedure [dbo].[usp_ConvertPayRating]
GO


DECLARE @Threshold datetime
SET @Threshold = DATEADD(month, -18, DATEADD(day, 1, CAST(FLOOR( CAST( GETDATE() AS FLOAT ) )AS DATETIME)))

SELECT prtr_PayRatingId, COUNT(1)
  FROM PRTradeReport
 WHERE prtr_PayRatingId IN (7, 8, 9)
   AND prtr_Date >= @Threshold
GROUP BY prtr_PayRatingId; 

UPDATE PRTradeReport
   SET prtr_PayRatingId = 9
 WHERE prtr_PayRatingId = 8
   AND prtr_Date >= @Threshold;
   
UPDATE PRTradeReport
   SET prtr_PayRatingId = 8
 WHERE prtr_PayRatingId = 7
   AND prtr_Date >= @Threshold;   
   
SELECT prtr_PayRatingId, COUNT(1)
  FROM PRTradeReport
 WHERE prtr_PayRatingId IN (7, 8, 9)
   AND prtr_Date >= @Threshold
GROUP BY prtr_PayRatingId;    
Go



DELETE PRExternalNews
  FROM PRExternalNews
	   INNER JOIN 
		   (SELECT pren_ExternalID As ExternalID, pren_SubjectCompanyID As SubjectCompanyID, MIN(pren_ExternalNewsID) As ExternalNewsID, COUNT(1) As Cnt
			  FROM PRExternalNews
			 WHERE pren_ExternalID IS NOT NULL
			GROUP BY  pren_ExternalID, pren_SubjectCompanyID
			HAVING COUNT(1) > 1) T1 ON ExternalID = pren_ExternalID AND SubjectCompanyID = pren_SubjectCompanyID
WHERE ExternalNewsID <> pren_ExternalNewsID;
Go


-- Update the VI response code for those VIs that we actually
-- have a Trade Report for.
UPDATE PRTESRequest
   SET prtesr_UpdatedDate = GETDATE(),
	   prtesr_UpdatedBy = -1,
	   prtesr_ReceivedMethod = 'V'
  FROM PRTESRequest
       INNER JOIN PRTradeReport ON prtesr_TESRequestID = prtr_TESRequestID
 WHERE prtesr_Received IS NOT NULL
   AND prtesr_ReceivedDateTime IS NOT NULL 
   AND prtesr_ReceivedMethod IS NULL
   AND prtesr_SentMethod = 'VI';

-- Update the VI response code for those requests that have call dispositions
-- that are considered responses.
UPDATE PRTESRequest
   SET prtesr_UpdatedDate = GETDATE(),
	   prtesr_UpdatedBy = -1,
	   prtesr_ReceivedMethod = 'V'
  FROM PRTESRequest
       INNER JOIN PRVerbalInvestigationCAVI ON prtesr_TESRequestID = prvictvi_TESRequestID
       INNER JOIN PRVerbalInvestigationCA ON prvictvi_VerbalInvestigationCAID = prvict_VerbalInvestigationCAID
 WHERE prtesr_Received IS NOT NULL
   AND prtesr_ReceivedDateTime IS NOT NULL 
   AND prtesr_ReceivedMethod IS NULL
   AND prtesr_SentMethod = 'VI'
   AND prvict_CallDisposition IN ('WR', 'NE');

UPDATE PRTESRequest
   SET prtesr_UpdatedDate = GETDATE(),
	   prtesr_UpdatedBy = -1,
	   prtesr_ReceivedDateTime = prtf_ReceivedDateTime,
	   prtesr_ReceivedMethod = prtf_ReceivedMethod
  FROM PRTESRequest
	   INNER JOIN PRTESForm ON prtesr_TESFormID = prtf_TESFormID  
 WHERE prtesr_Received IS NOT NULL
   AND (prtesr_ReceivedDateTime IS NULL 
		OR prtesr_ReceivedMethod IS NULL)
   AND prtf_ReceivedDateTime IS NOT NULL
   AND prtf_ReceivedMethod IS NOT NULL;
Go	  


--
-- Update the PRProductsProvided table
--
DECLARE @NextID int
SELECT @NextID = MAX(prprpr_ProductProvidedID) + 1 FROM PRProductProvided;

INSERT INTO PRProductProvided
(prprpr_ProductProvidedID,prprpr_DisplayOrder,prprpr_ParentID,prprpr_Level,prprpr_Name,prprpr_Abbreviation,prprpr_CreatedBy,prprpr_CreatedDate,prprpr_UpdatedBy,prprpr_UpdatedDate,prprpr_TimeStamp)
VALUES (@NextID,375,NULL,1,'Ceilings',NULL,NULL,GetDate(),NULL,GetDate(),GetDate());

UPDATE PRProductProvided
   SET prprpr_Name = 'Crates/Boxes',
       prprpr_UpdatedDate = GETDATE()
 WHERE prprpr_ProductProvidedID = 41;

UPDATE PRProductProvided
   SET prprpr_Name = 'Decking/Deck Components',
       prprpr_UpdatedDate = GETDATE()
 WHERE prprpr_ProductProvidedID = 6;
 
UPDATE PRProductProvided
   SET prprpr_Name = 'Furniture/Furniture Components',
       prprpr_UpdatedDate = GETDATE()
 WHERE prprpr_ProductProvidedID = 43;
 
UPDATE PRProductProvided
   SET prprpr_Name = 'Laminated Veneer Lumber (LVL)',
       prprpr_UpdatedDate = GETDATE()
 WHERE prprpr_ProductProvidedID = 17;
 
UPDATE PRProductProvided
   SET prprpr_Name = 'Medium Density Fiberboard (MDF)',
       prprpr_UpdatedDate = GETDATE()
 WHERE prprpr_ProductProvidedID = 18; 
 
SET @NextID = @NextID + 1 
INSERT INTO PRProductProvided
(prprpr_ProductProvidedID,prprpr_DisplayOrder,prprpr_ParentID,prprpr_Level,prprpr_Name,prprpr_Abbreviation,prprpr_CreatedBy,prprpr_CreatedDate,prprpr_UpdatedBy,prprpr_UpdatedDate,prprpr_TimeStamp)
VALUES (@NextID,2550,NULL,1,'Pellets',NULL,NULL,GetDate(),NULL,GetDate(),GetDate());
 
SET @NextID = @NextID + 1 
INSERT INTO PRProductProvided
(prprpr_ProductProvidedID,prprpr_DisplayOrder,prprpr_ParentID,prprpr_Level,prprpr_Name,prprpr_Abbreviation,prprpr_CreatedBy,prprpr_CreatedDate,prprpr_UpdatedBy,prprpr_UpdatedDate,prprpr_TimeStamp)
VALUES (@NextID,2650,NULL,1,'Poles/Pilings',NULL,NULL,GetDate(),NULL,GetDate(),GetDate());

SET @NextID = @NextID + 1 
INSERT INTO PRProductProvided
(prprpr_ProductProvidedID,prprpr_DisplayOrder,prprpr_ParentID,prprpr_Level,prprpr_Name,prprpr_Abbreviation,prprpr_CreatedBy,prprpr_CreatedDate,prprpr_UpdatedBy,prprpr_UpdatedDate,prprpr_TimeStamp)
VALUES (@NextID,2950,NULL,1,'Railroad Ties/Cross Ties',NULL,NULL,GetDate(),NULL,GetDate(),GetDate());

SET @NextID = @NextID + 1 
INSERT INTO PRProductProvided
(prprpr_ProductProvidedID,prprpr_DisplayOrder,prprpr_ParentID,prprpr_Level,prprpr_Name,prprpr_Abbreviation,prprpr_CreatedBy,prprpr_CreatedDate,prprpr_UpdatedBy,prprpr_UpdatedDate,prprpr_TimeStamp)
VALUES (@NextID,2975,NULL,1,'Rough Lumber',NULL,NULL,GetDate(),NULL,GetDate(),GetDate());

 SET @NextID = @NextID + 1 
INSERT INTO PRProductProvided
(prprpr_ProductProvidedID,prprpr_DisplayOrder,prprpr_ParentID,prprpr_Level,prprpr_Name,prprpr_Abbreviation,prprpr_CreatedBy,prprpr_CreatedDate,prprpr_UpdatedBy,prprpr_UpdatedDate,prprpr_TimeStamp)
VALUES (@NextID,3050,NULL,1,'Shutters',NULL,NULL,GetDate(),NULL,GetDate(),GetDate());

UPDATE PRProductProvided
   SET prprpr_Name = 'Stairs/Stair Components',
       prprpr_UpdatedDate = GETDATE()
 WHERE prprpr_ProductProvidedID = 47; 

SET @NextID = @NextID + 1 
INSERT INTO PRProductProvided
(prprpr_ProductProvidedID,prprpr_DisplayOrder,prprpr_ParentID,prprpr_Level,prprpr_Name,prprpr_Abbreviation,prprpr_CreatedBy,prprpr_CreatedDate,prprpr_UpdatedBy,prprpr_UpdatedDate,prprpr_TimeStamp)
VALUES (@NextID,3650,NULL,1,'Walls',NULL,NULL,GetDate(),NULL,GetDate(),GetDate());

UPDATE PRProductProvided
   SET prprpr_Name = 'Windows/Window Components',
       prprpr_UpdatedDate = GETDATE()
 WHERE prprpr_ProductProvidedID = 49; 
 
 --
 --  Delete 'Packaging Material'
 --
DELETE 
  FROM PRCompanyProductProvided
 WHERE prcprpr_ProductProvidedID = 45   

DELETE 
  FROM PRProductProvided
 WHERE prprpr_ProductProvidedID = 45   
 
Go



--
-- Update the PRSpecie table
--
DECLARE @NextID int
SELECT @NextID = MAX(prspc_SpecieID) + 1 FROM PRSpecie;

UPDATE PRSpecie
   SET prspc_Name = 'Agathis/Kauri',
       prspc_UpdatedDate = GETDATE()
 WHERE prspc_SpecieID = 2;

Insert Into PRSpecie
(prspc_SpecieID,prspc_ParentID,prspc_Level,prspc_Name,prspc_Alias,prspc_Abbreviation,prspc_DisplayOrder,prspc_CreatedBy,prspc_CreatedDate,prspc_UpdatedBy,prspc_UpdatedDate,prspc_TimeStamp)
Values (@NextID,75,2,'Amapa',NULL,NULL,10650,NULL,GetDate(),NULL,GetDate(),GetDate());

UPDATE PRSpecie
   SET prspc_Name = 'Baltic Birch/Russian Birchi',
       prspc_UpdatedDate = GETDATE()
 WHERE prspc_SpecieID = 94;

SET @NextID = @NextID + 1
Insert Into PRSpecie
(prspc_SpecieID,prspc_ParentID,prspc_Level,prspc_Name,prspc_Alias,prspc_Abbreviation,prspc_DisplayOrder,prspc_CreatedBy,prspc_CreatedDate,prspc_UpdatedBy,prspc_UpdatedDate,prspc_TimeStamp)
Values (@NextID,75,2,'Chestnut',NULL,NULL,13550,NULL,GetDate(),NULL,GetDate(),GetDate());
Go

--
-- Update the PRServiceProvided table
--
UPDATE PRServiceProvided
   SET prserpr_Name = 'Machine Stress Rated (MSR) Equipment',
       prserpr_UpdatedDate = GETDATE()
 WHERE prserpr_ServiceProvidedID = 32;
Go 



UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Jefferson Cty Farm Mkt AL' WHERE prtm_TerminalMarketId=1
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='L.A. Whlsl Prod Mkt CA' WHERE prtm_TerminalMarketId=2
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Seventh Street City Mkt CA' WHERE prtm_TerminalMarketId=3
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Oakland Prod Mkt CA' WHERE prtm_TerminalMarketId=7
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='San Fran Whlsl Prod Mkt CA' WHERE prtm_TerminalMarketId=5
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Golden Gate Prod Term CA' WHERE prtm_TerminalMarketId=6
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='St of Connecticut Reg Mkt CT' WHERE prtm_TerminalMarketId=6007
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Florida City St Farm Mkt FL' WHERE prtm_TerminalMarketId=6000
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Fort Myers St Farm Mkt FL' WHERE prtm_TerminalMarketId=6001
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Immokalee St Farm Mkt FL' WHERE prtm_TerminalMarketId=8
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Jacksonville Farm Mkt FL' WHERE prtm_TerminalMarketId=6008
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='The Miami Prod Center FL' WHERE prtm_TerminalMarketId=6010
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Plant City St Farm Mkt FL' WHERE prtm_TerminalMarketId=9
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Pompano St Farm Mkt FL' WHERE prtm_TerminalMarketId=10
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Sanford St Farm Mkt FL' WHERE prtm_TerminalMarketId=6011
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Tampa Whlsl Prod Mkt FL' WHERE prtm_TerminalMarketId=11
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Augusta St Farm Mkt GA' WHERE prtm_TerminalMarketId=12
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Columbus St Farm Mkt GA' WHERE prtm_TerminalMarketId=13
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Cordele St Farm Mkt GA' WHERE prtm_TerminalMarketId=14
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Atlanta St Farm Mkt GA' WHERE prtm_TerminalMarketId=15
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Moultrie St Farm Mkt GA' WHERE prtm_TerminalMarketId=16
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Savannah St Farm Mkt GA' WHERE prtm_TerminalMarketId=17
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Thomasville St Farm Mkt GA' WHERE prtm_TerminalMarketId=18
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Chicago Intl Prod Mkt IL' WHERE prtm_TerminalMarketId=19
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Louisville Prod Term KY' WHERE prtm_TerminalMarketId=6021
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='New England Prod Center MA' WHERE prtm_TerminalMarketId=20
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Boston Mkt Term MA' WHERE prtm_TerminalMarketId=21
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Maryland Whlsl Prod Mkt MD' WHERE prtm_TerminalMarketId=22
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Benton Harbor Fruit Mkt MI' WHERE prtm_TerminalMarketId=6012
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Detroit Eastern Mkt MI' WHERE prtm_TerminalMarketId=6023
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Detroit Prod Term MI' WHERE prtm_TerminalMarketId=23
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='St. Louis Prod Mkt MO' WHERE prtm_TerminalMarketId=24
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Chihuahua Whlsl Prod Mkt MX' WHERE prtm_TerminalMarketId=6002
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Culiacan Whlsl Prod Mkt MX' WHERE prtm_TerminalMarketId=6004
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Guadalajara Whlsl Prod Mkt MX' WHERE prtm_TerminalMarketId=6005
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Mexico City Whlsl Prod Mkt MX' WHERE prtm_TerminalMarketId=25
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Westerm NC Farm Mkt NC' WHERE prtm_TerminalMarketId=6017
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Raleigh Farm Mkt NC' WHERE prtm_TerminalMarketId=6022
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='NY City Term Prod Mkt NY' WHERE prtm_TerminalMarketId=26
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Brooklyn Term Mkt NY' WHERE prtm_TerminalMarketId=27
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Niagara Frontier Food Term NY' WHERE prtm_TerminalMarketId=6014
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Capital District Regional Mkt NY' WHERE prtm_TerminalMarketId=6013
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Genesee Valley Reg Mkt Auth NY' WHERE prtm_TerminalMarketId=6015
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Central NY Reg Mkt Auth NY' WHERE prtm_TerminalMarketId=6016
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Northern Ohio Food Term OH' WHERE prtm_TerminalMarketId=28
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Prod Term Co OH' WHERE prtm_TerminalMarketId=6018
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Ontario Food Term ON' WHERE prtm_TerminalMarketId=29
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Philadelphia Reg Prod Mkt PA' WHERE prtm_TerminalMarketId=30
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Whlsl Mkt Pittsburgh PA' WHERE prtm_TerminalMarketId=31
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Greenville St Farm Mkt SC' WHERE prtm_TerminalMarketId=6019
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='SC St Farm Mkt SC' WHERE prtm_TerminalMarketId=6024
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='McAllen Prod Term Mkt TX' WHERE prtm_TerminalMarketId=33
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='San Antonio Prod Term Mkt TX' WHERE prtm_TerminalMarketId=34
UPDATE PRTerminalMarket SET  prtm_ShortMarketName='Eastern Shore Farm Mkt VA' WHERE prtm_TerminalMarketId=6020
Go

UPDATE PRClassification SET prcl_ShortDescription='Produce Buyer' WHERE prcl_ClassificationId=1
UPDATE PRClassification SET prcl_ShortDescription='Produce Seller' WHERE prcl_ClassificationId=2
UPDATE PRClassification SET prcl_ShortDescription='Produce Broker' WHERE prcl_ClassificationId=3
UPDATE PRClassification SET prcl_ShortDescription='SupplyChainServices' WHERE prcl_ClassificationId=4
UPDATE PRClassification SET prcl_ShortDescription='Transportation' WHERE prcl_ClassificationId=5
UPDATE PRClassification SET prcl_ShortDescription='Buying Broker' WHERE prcl_ClassificationId=110
UPDATE PRClassification SET prcl_ShortDescription='Seller Broker' WHERE prcl_ClassificationId=120
UPDATE PRClassification SET prcl_ShortDescription='Buying Office' WHERE prcl_ClassificationId=130
UPDATE PRClassification SET prcl_ShortDescription='Canner' WHERE prcl_ClassificationId=140
UPDATE PRClassification SET prcl_ShortDescription='Chipper' WHERE prcl_ClassificationId=150
UPDATE PRClassification SET prcl_ShortDescription='Commission Merchant' WHERE prcl_ClassificationId=160
UPDATE PRClassification SET prcl_ShortDescription='Dehydrator' WHERE prcl_ClassificationId=170
UPDATE PRClassification SET prcl_ShortDescription='Distributor' WHERE prcl_ClassificationId=180
UPDATE PRClassification SET prcl_ShortDescription='Foodservice' WHERE prcl_ClassificationId=190
UPDATE PRClassification SET prcl_ShortDescription='Freezer' WHERE prcl_ClassificationId=200
UPDATE PRClassification SET prcl_ShortDescription='Fresh Cut Processor' WHERE prcl_ClassificationId=210
UPDATE PRClassification SET prcl_ShortDescription='Importer' WHERE prcl_ClassificationId=220
UPDATE PRClassification SET prcl_ShortDescription='Jobber' WHERE prcl_ClassificationId=230
UPDATE PRClassification SET prcl_ShortDescription='Juicer' WHERE prcl_ClassificationId=240
UPDATE PRClassification SET prcl_ShortDescription='Packer' WHERE prcl_ClassificationId=250
UPDATE PRClassification SET prcl_ShortDescription='Peeler' WHERE prcl_ClassificationId=260
UPDATE PRClassification SET prcl_ShortDescription='Pickler' WHERE prcl_ClassificationId=270
UPDATE PRClassification SET prcl_ShortDescription='Preserver' WHERE prcl_ClassificationId=280
UPDATE PRClassification SET prcl_ShortDescription='Processor' WHERE prcl_ClassificationId=290
UPDATE PRClassification SET prcl_ShortDescription='Receiver' WHERE prcl_ClassificationId=300
UPDATE PRClassification SET prcl_ShortDescription='Repacker' WHERE prcl_ClassificationId=310
UPDATE PRClassification SET prcl_ShortDescription='Restaurant' WHERE prcl_ClassificationId=320
UPDATE PRClassification SET prcl_ShortDescription='Retail' WHERE prcl_ClassificationId=330
UPDATE PRClassification SET prcl_ShortDescription='Wholesale Grocer' WHERE prcl_ClassificationId=340
UPDATE PRClassification SET prcl_ShortDescription='Short Haul Trucker' WHERE prcl_ClassificationId=345
UPDATE PRClassification SET prcl_ShortDescription='Exporter' WHERE prcl_ClassificationId=350
UPDATE PRClassification SET prcl_ShortDescription='Grower' WHERE prcl_ClassificationId=360
UPDATE PRClassification SET prcl_ShortDescription='Produce Auction' WHERE prcl_ClassificationId=370
UPDATE PRClassification SET prcl_ShortDescription='Sales Office' WHERE prcl_ClassificationId=380
UPDATE PRClassification SET prcl_ShortDescription='Shipper' WHERE prcl_ClassificationId=390
UPDATE PRClassification SET prcl_ShortDescription='Cold Storage' WHERE prcl_ClassificationId=400
UPDATE PRClassification SET prcl_ShortDescription='Freezer Storage' WHERE prcl_ClassificationId=410
UPDATE PRClassification SET prcl_ShortDescription='Inspection Office' WHERE prcl_ClassificationId=420
UPDATE PRClassification SET prcl_ShortDescription='Load Consolidator' WHERE prcl_ClassificationId=430
UPDATE PRClassification SET prcl_ShortDescription='Loading Point' WHERE prcl_ClassificationId=440
UPDATE PRClassification SET prcl_ShortDescription='Precooler' WHERE prcl_ClassificationId=450
UPDATE PRClassification SET prcl_ShortDescription='Produce Warehouse' WHERE prcl_ClassificationId=460
UPDATE PRClassification SET prcl_ShortDescription='Ripening Room Svc' WHERE prcl_ClassificationId=470
UPDATE PRClassification SET prcl_ShortDescription='Storage' WHERE prcl_ClassificationId=480
UPDATE PRClassification SET prcl_ShortDescription='Truck Load/Unload Svc' WHERE prcl_ClassificationId=490
UPDATE PRClassification SET prcl_ShortDescription='Air Carrier' WHERE prcl_ClassificationId=500
UPDATE PRClassification SET prcl_ShortDescription='Freight Contractor' WHERE prcl_ClassificationId=510
UPDATE PRClassification SET prcl_ShortDescription='Freight Forwarder' WHERE prcl_ClassificationId=520
UPDATE PRClassification SET prcl_ShortDescription='Intermodal' WHERE prcl_ClassificationId=530
UPDATE PRClassification SET prcl_ShortDescription='Ocean Carrier' WHERE prcl_ClassificationId=540
UPDATE PRClassification SET prcl_ShortDescription='Rail Ca	rrier' WHERE prcl_ClassificationId=550
UPDATE PRClassification SET prcl_ShortDescription='TrailerRail(Piggybk)' WHERE prcl_ClassificationId=560
UPDATE PRClassification SET prcl_ShortDescription='TransportationBrkr' WHERE prcl_ClassificationId=570
UPDATE PRClassification SET prcl_ShortDescription='TransportationLogistics' WHERE prcl_ClassificationId=580
UPDATE PRClassification SET prcl_ShortDescription='Truck Broker' WHERE prcl_ClassificationId=590
UPDATE PRClassification SET prcl_ShortDescription='Truck Stop' WHERE prcl_ClassificationId=600
UPDATE PRClassification SET prcl_ShortDescription='Trucker' WHERE prcl_ClassificationId=610

UPDATE PRClassification SET prcl_ShortDescription='Lumber Seller' WHERE prcl_ClassificationId=2181
UPDATE PRClassification SET prcl_ShortDescription='Mill' WHERE prcl_ClassificationId=2182
UPDATE PRClassification SET prcl_ShortDescription='Exporter' WHERE prcl_ClassificationId=2183
UPDATE PRClassification SET prcl_ShortDescription='Lumber Buyer' WHERE prcl_ClassificationId=2184
UPDATE PRClassification SET prcl_ShortDescription='Office Wholesaler' WHERE prcl_ClassificationId=2185
UPDATE PRClassification SET prcl_ShortDescription='Secondary Manufacturer' WHERE prcl_ClassificationId=2186
UPDATE PRClassification SET prcl_ShortDescription='Importer' WHERE prcl_ClassificationId=2187
UPDATE PRClassification SET prcl_ShortDescription='Co-Op' WHERE prcl_ClassificationId=2188
UPDATE PRClassification SET prcl_ShortDescription='Stocking Wholesaler/Dist' WHERE prcl_ClassificationId=2189
UPDATE PRClassification SET prcl_ShortDescription='Retail Lumber Yard' WHERE prcl_ClassificationId=2190
UPDATE PRClassification SET prcl_ShortDescription='Home Center' WHERE prcl_ClassificationId=2191
UPDATE PRClassification SET prcl_ShortDescription='Pro Dealer' WHERE prcl_ClassificationId=2192
UPDATE PRClassification SET prcl_ShortDescription='Lumber Supply Chain Svc' WHERE prcl_ClassificationId=2193
UPDATE PRClassification SET prcl_ShortDescription='Transload/Reload Center' WHERE prcl_ClassificationId=2194
UPDATE PRClassification SET prcl_ShortDescription='Supply/Service Provider' WHERE prcl_ClassificationId=2195
UPDATE PRClassification SET prcl_ShortDescription='Transportation' WHERE prcl_ClassificationId=2196

UPDATE PRClassification SET prcl_ShortDescription='Supply/Service Provider' WHERE prcl_ClassificationId=6;
UPDATE PRClassification SET prcl_ShortDescription='Advertising Material' WHERE prcl_ClassificationId=620;
UPDATE PRClassification SET prcl_ShortDescription='Ag Properties' WHERE prcl_ClassificationId=630;
UPDATE PRClassification SET prcl_ShortDescription='Ag Wire Products' WHERE prcl_ClassificationId=640;
UPDATE PRClassification SET prcl_ShortDescription='AtmosphereCntrl Equip & Serv' WHERE prcl_ClassificationId=650;
UPDATE PRClassification SET prcl_ShortDescription='Attorneys' WHERE prcl_ClassificationId=660;
UPDATE PRClassification SET prcl_ShortDescription='Bag Holders' WHERE prcl_ClassificationId=670;
UPDATE PRClassification SET prcl_ShortDescription='Baggers' WHERE prcl_ClassificationId=680;
UPDATE PRClassification SET prcl_ShortDescription='Bags' WHERE prcl_ClassificationId=690;
UPDATE PRClassification SET prcl_ShortDescription='Bar Coding Systems' WHERE prcl_ClassificationId=700;
UPDATE PRClassification SET prcl_ShortDescription='Baskets' WHERE prcl_ClassificationId=710;
UPDATE PRClassification SET prcl_ShortDescription='Belting' WHERE prcl_ClassificationId=720;
UPDATE PRClassification SET prcl_ShortDescription='Boxes & Cartons' WHERE prcl_ClassificationId=730;
UPDATE PRClassification SET prcl_ShortDescription='Brushes' WHERE prcl_ClassificationId=740;
UPDATE PRClassification SET prcl_ShortDescription='Burlap' WHERE prcl_ClassificationId=750;
UPDATE PRClassification SET prcl_ShortDescription='Car Lining Paper' WHERE prcl_ClassificationId=760;
UPDATE PRClassification SET prcl_ShortDescription='Car Strips' WHERE prcl_ClassificationId=770;
UPDATE PRClassification SET prcl_ShortDescription='Cargo Containers' WHERE prcl_ClassificationId=780;
UPDATE PRClassification SET prcl_ShortDescription='Case Erectors' WHERE prcl_ClassificationId=790;
UPDATE PRClassification SET prcl_ShortDescription='Case Sealers' WHERE prcl_ClassificationId=800;
UPDATE PRClassification SET prcl_ShortDescription='Chemicals' WHERE prcl_ClassificationId=810;
UPDATE PRClassification SET prcl_ShortDescription='Claims Service' WHERE prcl_ClassificationId=820;
UPDATE PRClassification SET prcl_ShortDescription='Coder Inks' WHERE prcl_ClassificationId=830;
UPDATE PRClassification SET prcl_ShortDescription='Cold Storage Doors' WHERE prcl_ClassificationId=840;
UPDATE PRClassification SET prcl_ShortDescription='Collection Assistance' WHERE prcl_ClassificationId=850;
UPDATE PRClassification SET prcl_ShortDescription='Commercial Harvesting & Pkng' WHERE prcl_ClassificationId=860;
UPDATE PRClassification SET prcl_ShortDescription='Comp Software/Systems/Equip' WHERE prcl_ClassificationId=870;
UPDATE PRClassification SET prcl_ShortDescription='Computer Services' WHERE prcl_ClassificationId=880;
UPDATE PRClassification SET prcl_ShortDescription='Construction' WHERE prcl_ClassificationId=885;
UPDATE PRClassification SET prcl_ShortDescription='Consultants' WHERE prcl_ClassificationId=890;
UPDATE PRClassification SET prcl_ShortDescription='Consumer Packages' WHERE prcl_ClassificationId=900;
UPDATE PRClassification SET prcl_ShortDescription='Controlled Atmosphere Equip' WHERE prcl_ClassificationId=910;
UPDATE PRClassification SET prcl_ShortDescription='Conveyors' WHERE prcl_ClassificationId=920;
UPDATE PRClassification SET prcl_ShortDescription='Cornerboard & Edgeboard Supplies' WHERE prcl_ClassificationId=930;
UPDATE PRClassification SET prcl_ShortDescription='Crates & Crate Material' WHERE prcl_ClassificationId=940;
UPDATE PRClassification SET prcl_ShortDescription='Customs Broker' WHERE prcl_ClassificationId=950;
UPDATE PRClassification SET prcl_ShortDescription='Cutters & Dryers' WHERE prcl_ClassificationId=960;
UPDATE PRClassification SET prcl_ShortDescription='Decals' WHERE prcl_ClassificationId=970;
UPDATE PRClassification SET prcl_ShortDescription='Digital Imaging & Service' WHERE prcl_ClassificationId=980;
UPDATE PRClassification SET prcl_ShortDescription='Dispute Resolution' WHERE prcl_ClassificationId=990;
UPDATE PRClassification SET prcl_ShortDescription='Dock Equip' WHERE prcl_ClassificationId=1000;
UPDATE PRClassification SET prcl_ShortDescription='Dumping Machines' WHERE prcl_ClassificationId=1010;
UPDATE PRClassification SET prcl_ShortDescription='Education' WHERE prcl_ClassificationId=1020;
UPDATE PRClassification SET prcl_ShortDescription='Employee Relations' WHERE prcl_ClassificationId=1030;
UPDATE PRClassification SET prcl_ShortDescription='Engineering Services' WHERE prcl_ClassificationId=1040;
UPDATE PRClassification SET prcl_ShortDescription='Environmental Services' WHERE prcl_ClassificationId=1050;
UPDATE PRClassification SET prcl_ShortDescription='Equip Auction Service' WHERE prcl_ClassificationId=1060;
UPDATE PRClassification SET prcl_ShortDescription='Erosion Control' WHERE prcl_ClassificationId=1070;
UPDATE PRClassification SET prcl_ShortDescription='Ethylene-Producing Equip' WHERE prcl_ClassificationId=1080;
UPDATE PRClassification SET prcl_ShortDescription='Ethylene Removal Equip' WHERE prcl_ClassificationId=1090;
UPDATE PRClassification SET prcl_ShortDescription='Export Promotion' WHERE prcl_ClassificationId=1100;
UPDATE PRClassification SET prcl_ShortDescription='Export Service' WHERE prcl_ClassificationId=1110;
UPDATE PRClassification SET prcl_ShortDescription='Factoring' WHERE prcl_ClassificationId=1120;
UPDATE PRClassification SET prcl_ShortDescription='Farm Machinery & Equip' WHERE prcl_ClassificationId=1130;
UPDATE PRClassification SET prcl_ShortDescription='Fasteners' WHERE prcl_ClassificationId=1140;
UPDATE PRClassification SET prcl_ShortDescription='Fertilizer' WHERE prcl_ClassificationId=1150;
UPDATE PRClassification SET prcl_ShortDescription='Fillers' WHERE prcl_ClassificationId=1160;
UPDATE PRClassification SET prcl_ShortDescription='Financial Consultants & Services' WHERE prcl_ClassificationId=1170;
UPDATE PRClassification SET prcl_ShortDescription='Financial Institutions' WHERE prcl_ClassificationId=1180;
UPDATE PRClassification SET prcl_ShortDescription='Foam Containers' WHERE prcl_ClassificationId=1190;
UPDATE PRClassification SET prcl_ShortDescription='Food Safety' WHERE prcl_ClassificationId=1200;
UPDATE PRClassification SET prcl_ShortDescription='Fresh-Cut Processing Equip' WHERE prcl_ClassificationId=1210;
UPDATE PRClassification SET prcl_ShortDescription='Fumigation/Pest Control' WHERE prcl_ClassificationId=1220;
UPDATE PRClassification SET prcl_ShortDescription='Fungicide/Herbicide/Insecticide' WHERE prcl_ClassificationId=1230;
UPDATE PRClassification SET prcl_ShortDescription='Glue & Paste' WHERE prcl_ClassificationId=1240;
UPDATE PRClassification SET prcl_ShortDescription='Graders/Sizers/Sorters' WHERE prcl_ClassificationId=1250;
UPDATE PRClassification SET prcl_ShortDescription='Ground Cover' WHERE prcl_ClassificationId=1260;
UPDATE PRClassification SET prcl_ShortDescription='Hydrocoolers' WHERE prcl_ClassificationId=1270;
UPDATE PRClassification SET prcl_ShortDescription='Ice Crushers' WHERE prcl_ClassificationId=1280;
UPDATE PRClassification SET prcl_ShortDescription='Ice Manufact & Suppliers' WHERE prcl_ClassificationId=1290;
UPDATE PRClassification SET prcl_ShortDescription='Ink Coatings' WHERE prcl_ClassificationId=1300;
UPDATE PRClassification SET prcl_ShortDescription='Ink Jet Systems' WHERE prcl_ClassificationId=1310;
UPDATE PRClassification SET prcl_ShortDescription='Insect & Rodent Cntrl Poisons' WHERE prcl_ClassificationId=1320;
UPDATE PRClassification SET prcl_ShortDescription='Inspection Service (Commercial)' WHERE prcl_ClassificationId=1330;
UPDATE PRClassification SET prcl_ShortDescription='Insulation' WHERE prcl_ClassificationId=1340;
UPDATE PRClassification SET prcl_ShortDescription='Insurance' WHERE prcl_ClassificationId=1350;
UPDATE PRClassification SET prcl_ShortDescription='Internet Consulting Services' WHERE prcl_ClassificationId=1360;
UPDATE PRClassification SET prcl_ShortDescription='Internet Services' WHERE prcl_ClassificationId=1370;
UPDATE PRClassification SET prcl_ShortDescription='Investment Promotion' WHERE prcl_ClassificationId=1380;
UPDATE PRClassification SET prcl_ShortDescription='Irrigation Equip' WHERE prcl_ClassificationId=1390;
UPDATE PRClassification SET prcl_ShortDescription='Knives' WHERE prcl_ClassificationId=1400;
UPDATE PRClassification SET prcl_ShortDescription='Labels & Labeling Devices' WHERE prcl_ClassificationId=1410;
UPDATE PRClassification SET prcl_ShortDescription='Leasing' WHERE prcl_ClassificationId=1415;
UPDATE PRClassification SET prcl_ShortDescription='Liners' WHERE prcl_ClassificationId=1420;
UPDATE PRClassification SET prcl_ShortDescription='Loaders' WHERE prcl_ClassificationId=1430;
UPDATE PRClassification SET prcl_ShortDescription='Machines' WHERE prcl_ClassificationId=1440;
UPDATE PRClassification SET prcl_ShortDescription='Management/Marketing Consultants' WHERE prcl_ClassificationId=1450;
UPDATE PRClassification SET prcl_ShortDescription='Material-Handling Equip' WHERE prcl_ClassificationId=1460;
UPDATE PRClassification SET prcl_ShortDescription='Merchandising' WHERE prcl_ClassificationId=1470;
UPDATE PRClassification SET prcl_ShortDescription='Motors' WHERE prcl_ClassificationId=1480;
UPDATE PRClassification SET prcl_ShortDescription='Nails & Nailing Machines' WHERE prcl_ClassificationId=1490;
UPDATE PRClassification SET prcl_ShortDescription='Packaging Equip' WHERE prcl_ClassificationId=1500;
UPDATE PRClassification SET prcl_ShortDescription='Packaging Protection' WHERE prcl_ClassificationId=1510;
UPDATE PRClassification SET prcl_ShortDescription='Packaging Supplies' WHERE prcl_ClassificationId=1520;
UPDATE PRClassification SET prcl_ShortDescription='Packing Cups' WHERE prcl_ClassificationId=1530;
UPDATE PRClassification SET prcl_ShortDescription='Pads' WHERE prcl_ClassificationId=1540;
UPDATE PRClassification SET prcl_ShortDescription='Pallet Stretch Film' WHERE prcl_ClassificationId=1550;
UPDATE PRClassification SET prcl_ShortDescription='Pallets & Bins' WHERE prcl_ClassificationId=1560;
UPDATE PRClassification SET prcl_ShortDescription='Paper & Paper Products' WHERE prcl_ClassificationId=1570;
UPDATE PRClassification SET prcl_ShortDescription='Personnel Services' WHERE prcl_ClassificationId=1580;
UPDATE PRClassification SET prcl_ShortDescription='Plant Covers' WHERE prcl_ClassificationId=1590;
UPDATE PRClassification SET prcl_ShortDescription='Plastic Bag Closures' WHERE prcl_ClassificationId=1600;
UPDATE PRClassification SET prcl_ShortDescription='Plastic Containers' WHERE prcl_ClassificationId=1610;
UPDATE PRClassification SET prcl_ShortDescription='Plastic Mulch Film' WHERE prcl_ClassificationId=1620;
UPDATE PRClassification SET prcl_ShortDescription='Plastic Netting' WHERE prcl_ClassificationId=1630;
UPDATE PRClassification SET prcl_ShortDescription='Precooling Equip' WHERE prcl_ClassificationId=1640;
UPDATE PRClassification SET prcl_ShortDescription='Printers/Forms/Lithographers' WHERE prcl_ClassificationId=1650;
UPDATE PRClassification SET prcl_ShortDescription='Produce Wash' WHERE prcl_ClassificationId=1660;
UPDATE PRClassification SET prcl_ShortDescription='Product Testing' WHERE prcl_ClassificationId=1670;
UPDATE PRClassification SET prcl_ShortDescription='Public Relations' WHERE prcl_ClassificationId=1680;
UPDATE PRClassification SET prcl_ShortDescription='Quality Control' WHERE prcl_ClassificationId=1690;
UPDATE PRClassification SET prcl_ShortDescription='Recycling Equip' WHERE prcl_ClassificationId=1700;
UPDATE PRClassification SET prcl_ShortDescription='Refrig Systms & Repair' WHERE prcl_ClassificationId=1710;
UPDATE PRClassification SET prcl_ShortDescription='Research & Marketing' WHERE prcl_ClassificationId=1720;
UPDATE PRClassification SET prcl_ShortDescription='Returnable Containers & Pkg' WHERE prcl_ClassificationId=1730;
UPDATE PRClassification SET prcl_ShortDescription='Ripening Equip & Supplies' WHERE prcl_ClassificationId=1740;
UPDATE PRClassification SET prcl_ShortDescription='Rubber Bands' WHERE prcl_ClassificationId=1750;
UPDATE PRClassification SET prcl_ShortDescription='Rubber Stamps' WHERE prcl_ClassificationId=1760;
UPDATE PRClassification SET prcl_ShortDescription='Sanitation Service' WHERE prcl_ClassificationId=1765;
UPDATE PRClassification SET prcl_ShortDescription='Scales' WHERE prcl_ClassificationId=1770;
UPDATE PRClassification SET prcl_ShortDescription='Sewing Machines-Bag' WHERE prcl_ClassificationId=1780;
UPDATE PRClassification SET prcl_ShortDescription='Shade Cloth' WHERE prcl_ClassificationId=1790;
UPDATE PRClassification SET prcl_ShortDescription='Shelf Life Extender' WHERE prcl_ClassificationId=1800;
UPDATE PRClassification SET prcl_ShortDescription='Shipper/Grower Supplies' WHERE prcl_ClassificationId=1810;
UPDATE PRClassification SET prcl_ShortDescription='Shrink Film' WHERE prcl_ClassificationId=1820;
UPDATE PRClassification SET prcl_ShortDescription='Spray Equip & Supplies' WHERE prcl_ClassificationId=1830;
UPDATE PRClassification SET prcl_ShortDescription='Staples' WHERE prcl_ClassificationId=1840;
UPDATE PRClassification SET prcl_ShortDescription='Storage Equip' WHERE prcl_ClassificationId=1850;
UPDATE PRClassification SET prcl_ShortDescription='Strapping' WHERE prcl_ClassificationId=1860;
UPDATE PRClassification SET prcl_ShortDescription='Stretch Wrap & Equip' WHERE prcl_ClassificationId=1870;
UPDATE PRClassification SET prcl_ShortDescription='Strip Doors' WHERE prcl_ClassificationId=1880;
UPDATE PRClassification SET prcl_ShortDescription='Sustainable Packaging' WHERE prcl_ClassificationId=1885;
UPDATE PRClassification SET prcl_ShortDescription='Tags' WHERE prcl_ClassificationId=1890;
UPDATE PRClassification SET prcl_ShortDescription='Tape & Taping Machines' WHERE prcl_ClassificationId=1900;
UPDATE PRClassification SET prcl_ShortDescription='Tarpaulins' WHERE prcl_ClassificationId=1910;
UPDATE PRClassification SET prcl_ShortDescription='Temperature/Humidity Monitoring' WHERE prcl_ClassificationId=1920;
UPDATE PRClassification SET prcl_ShortDescription='Trade Associations' WHERE prcl_ClassificationId=1930;
UPDATE PRClassification SET prcl_ShortDescription='Trade Development' WHERE prcl_ClassificationId=1940;
UPDATE PRClassification SET prcl_ShortDescription='Trade Publications' WHERE prcl_ClassificationId=1950;
UPDATE PRClassification SET prcl_ShortDescription='Trade Shows & Exhibitions' WHERE prcl_ClassificationId=1960;
UPDATE PRClassification SET prcl_ShortDescription='Trailers' WHERE prcl_ClassificationId=1970;
UPDATE PRClassification SET prcl_ShortDescription='Trays' WHERE prcl_ClassificationId=1980;
UPDATE PRClassification SET prcl_ShortDescription='Tubs' WHERE prcl_ClassificationId=1990;
UPDATE PRClassification SET prcl_ShortDescription='Twine & Cordage' WHERE prcl_ClassificationId=2000;
UPDATE PRClassification SET prcl_ShortDescription='Washers & Cleaners' WHERE prcl_ClassificationId=2020;
UPDATE PRClassification SET prcl_ShortDescription='Wax Coatings' WHERE prcl_ClassificationId=2030;
UPDATE PRClassification SET prcl_ShortDescription='Weather Information' WHERE prcl_ClassificationId=2040;
UPDATE PRClassification SET prcl_ShortDescription='Wiping Cloths' WHERE prcl_ClassificationId=2050;
UPDATE PRClassification SET prcl_ShortDescription='Wood Products' WHERE prcl_ClassificationId=2060;
UPDATE PRClassification SET prcl_ShortDescription='Wrappers' WHERE prcl_ClassificationId=2070;
Go

UPDATE PRCommodity SET prcm_ShortDescription='Alfalfa' WHERE prcm_CommodityId=582
UPDATE PRCommodity SET prcm_ShortDescription='Almond' WHERE prcm_CommodityId=272
UPDATE PRCommodity SET prcm_ShortDescription='Aloe Vera' WHERE prcm_CommodityId=4
UPDATE PRCommodity SET prcm_ShortDescription='Anise' WHERE prcm_CommodityId=288
UPDATE PRCommodity SET prcm_ShortDescription='Apple' WHERE prcm_CommodityId=110
UPDATE PRCommodity SET prcm_ShortDescription='Apricot' WHERE prcm_CommodityId=91
UPDATE PRCommodity SET prcm_ShortDescription='Arrow Root' WHERE prcm_CommodityId=435
UPDATE PRCommodity SET prcm_ShortDescription='Artichoke' WHERE prcm_CommodityId=343
UPDATE PRCommodity SET prcm_ShortDescription='Arugula' WHERE prcm_CommodityId=350
UPDATE PRCommodity SET prcm_ShortDescription='Asian Fruit' WHERE prcm_CommodityId=38
UPDATE PRCommodity SET prcm_ShortDescription='Asian Vegetable' WHERE prcm_CommodityId=292
UPDATE PRCommodity SET prcm_ShortDescription='Asparagus' WHERE prcm_CommodityId=474
UPDATE PRCommodity SET prcm_ShortDescription='Atemoya' WHERE prcm_CommodityId=183
UPDATE PRCommodity SET prcm_ShortDescription='Avocado' WHERE prcm_CommodityId=93
UPDATE PRCommodity SET prcm_ShortDescription='Bac Ha' WHERE prcm_CommodityId=293
UPDATE PRCommodity SET prcm_ShortDescription='Bamboo Shoot' WHERE prcm_CommodityId=294
UPDATE PRCommodity SET prcm_ShortDescription='Banana' WHERE prcm_CommodityId=116
UPDATE PRCommodity SET prcm_ShortDescription='Basil' WHERE prcm_CommodityId=249
UPDATE PRCommodity SET prcm_ShortDescription='Bay Leaf' WHERE prcm_CommodityId=250
UPDATE PRCommodity SET prcm_ShortDescription='Bean' WHERE prcm_CommodityId=404
UPDATE PRCommodity SET prcm_ShortDescription='Bedding Plant' WHERE prcm_CommodityId=5
UPDATE PRCommodity SET prcm_ShortDescription='Beet' WHERE prcm_CommodityId=436
UPDATE PRCommodity SET prcm_ShortDescription='Berries' WHERE prcm_CommodityId=47
UPDATE PRCommodity SET prcm_ShortDescription='Berry' WHERE prcm_CommodityId=48
UPDATE PRCommodity SET prcm_ShortDescription='Blackberry' WHERE prcm_CommodityId=51
UPDATE PRCommodity SET prcm_ShortDescription='Blueberry' WHERE prcm_CommodityId=53
UPDATE PRCommodity SET prcm_ShortDescription='Bok Choy' WHERE prcm_CommodityId=295
UPDATE PRCommodity SET prcm_ShortDescription='Boniato' WHERE prcm_CommodityId=437
UPDATE PRCommodity SET prcm_ShortDescription='Brazil Nut' WHERE prcm_CommodityId=273
UPDATE PRCommodity SET prcm_ShortDescription='Breadfruit' WHERE prcm_CommodityId=124
UPDATE PRCommodity SET prcm_ShortDescription='Broccoflower' WHERE prcm_CommodityId=344
UPDATE PRCommodity SET prcm_ShortDescription='Broccoli' WHERE prcm_CommodityId=345
UPDATE PRCommodity SET prcm_ShortDescription='Brussel Sprout' WHERE prcm_CommodityId=475
UPDATE PRCommodity SET prcm_ShortDescription='Buddha Hand' WHERE prcm_CommodityId=60
UPDATE PRCommodity SET prcm_ShortDescription='Bulb' WHERE prcm_CommodityId=301
UPDATE PRCommodity SET prcm_ShortDescription='Butternut Squash' WHERE prcm_CommodityId=321
UPDATE PRCommodity SET prcm_ShortDescription='Cabbage' WHERE prcm_CommodityId=352
UPDATE PRCommodity SET prcm_ShortDescription='Cacti' WHERE prcm_CommodityId=6
UPDATE PRCommodity SET prcm_ShortDescription='Calaloo' WHERE prcm_CommodityId=358
UPDATE PRCommodity SET prcm_ShortDescription='Candy' WHERE prcm_CommodityId=17
UPDATE PRCommodity SET prcm_ShortDescription='Cantaloupe' WHERE prcm_CommodityId=222
UPDATE PRCommodity SET prcm_ShortDescription='Carambola' WHERE prcm_CommodityId=86
UPDATE PRCommodity SET prcm_ShortDescription='Cardoon' WHERE prcm_CommodityId=476
UPDATE PRCommodity SET prcm_ShortDescription='Carrot' WHERE prcm_CommodityId=438
UPDATE PRCommodity SET prcm_ShortDescription='Cashew' WHERE prcm_CommodityId=274
UPDATE PRCommodity SET prcm_ShortDescription='Cassava' WHERE prcm_CommodityId=439
UPDATE PRCommodity SET prcm_ShortDescription='Cauliflower' WHERE prcm_CommodityId=348
UPDATE PRCommodity SET prcm_ShortDescription='Celery' WHERE prcm_CommodityId=477
UPDATE PRCommodity SET prcm_ShortDescription='Celery Root' WHERE prcm_CommodityId=440
UPDATE PRCommodity SET prcm_ShortDescription='Chard' WHERE prcm_CommodityId=359
UPDATE PRCommodity SET prcm_ShortDescription='Chayote' WHERE prcm_CommodityId=322
UPDATE PRCommodity SET prcm_ShortDescription='Cheese' WHERE prcm_CommodityId=18
UPDATE PRCommodity SET prcm_ShortDescription='Cherimoya' WHERE prcm_CommodityId=87
UPDATE PRCommodity SET prcm_ShortDescription='Cherry' WHERE prcm_CommodityId=94
UPDATE PRCommodity SET prcm_ShortDescription='Chervil' WHERE prcm_CommodityId=251
UPDATE PRCommodity SET prcm_ShortDescription='Chestnut' WHERE prcm_CommodityId=275
UPDATE PRCommodity SET prcm_ShortDescription='Chico Sapote' WHERE prcm_CommodityId=195
UPDATE PRCommodity SET prcm_ShortDescription='Chicory' WHERE prcm_CommodityId=360
UPDATE PRCommodity SET prcm_ShortDescription='Chili Dry Beans' WHERE prcm_CommodityId=424
UPDATE PRCommodity SET prcm_ShortDescription='Chinese Dry Beans' WHERE prcm_CommodityId=425
UPDATE PRCommodity SET prcm_ShortDescription='Chive' WHERE prcm_CommodityId=252
UPDATE PRCommodity SET prcm_ShortDescription='Chocolate' WHERE prcm_CommodityId=19
UPDATE PRCommodity SET prcm_ShortDescription='Christmas Greens' WHERE prcm_CommodityId=7
UPDATE PRCommodity SET prcm_ShortDescription='Christmas Trees' WHERE prcm_CommodityId=8
UPDATE PRCommodity SET prcm_ShortDescription='Cilantro' WHERE prcm_CommodityId=253
UPDATE PRCommodity SET prcm_ShortDescription='Citrus' WHERE prcm_CommodityId=59
UPDATE PRCommodity SET prcm_ShortDescription='Citrus Budwood' WHERE prcm_CommodityId=557
UPDATE PRCommodity SET prcm_ShortDescription='Cocoa' WHERE prcm_CommodityId=20
UPDATE PRCommodity SET prcm_ShortDescription='Coconut' WHERE prcm_CommodityId=196
UPDATE PRCommodity SET prcm_ShortDescription='Coffee' WHERE prcm_CommodityId=21
UPDATE PRCommodity SET prcm_ShortDescription='Cole Slaw' WHERE prcm_CommodityId=22
UPDATE PRCommodity SET prcm_ShortDescription='Corn' WHERE prcm_CommodityId=484
UPDATE PRCommodity SET prcm_ShortDescription='Couscous' WHERE prcm_CommodityId=24
UPDATE PRCommodity SET prcm_ShortDescription='Cranberry' WHERE prcm_CommodityId=54
UPDATE PRCommodity SET prcm_ShortDescription='Cucumber' WHERE prcm_CommodityId=491
UPDATE PRCommodity SET prcm_ShortDescription='Culantro' WHERE prcm_CommodityId=254
UPDATE PRCommodity SET prcm_ShortDescription='Currant' WHERE prcm_CommodityId=55
UPDATE PRCommodity SET prcm_ShortDescription='Daffodil' WHERE prcm_CommodityId=9
UPDATE PRCommodity SET prcm_ShortDescription='Daikon' WHERE prcm_CommodityId=296
UPDATE PRCommodity SET prcm_ShortDescription='Date' WHERE prcm_CommodityId=128
UPDATE PRCommodity SET prcm_ShortDescription='Deciduous Fruit' WHERE prcm_CommodityId=559
UPDATE PRCommodity SET prcm_ShortDescription='Diep Ca' WHERE prcm_CommodityId=255
UPDATE PRCommodity SET prcm_ShortDescription='Dill' WHERE prcm_CommodityId=256
UPDATE PRCommodity SET prcm_ShortDescription='Dominicos' WHERE prcm_CommodityId=198
UPDATE PRCommodity SET prcm_ShortDescription='Dragon Fruit' WHERE prcm_CommodityId=88
UPDATE PRCommodity SET prcm_ShortDescription='Durian' WHERE prcm_CommodityId=40
UPDATE PRCommodity SET prcm_ShortDescription='Edamame' WHERE prcm_CommodityId=426
UPDATE PRCommodity SET prcm_ShortDescription='Edible Flower' WHERE prcm_CommodityId=2
UPDATE PRCommodity SET prcm_ShortDescription='Egg' WHERE prcm_CommodityId=25
UPDATE PRCommodity SET prcm_ShortDescription='Eggplant' WHERE prcm_CommodityId=544
UPDATE PRCommodity SET prcm_ShortDescription='Endigia Lettuce' WHERE prcm_CommodityId=361
UPDATE PRCommodity SET prcm_ShortDescription='Endive' WHERE prcm_CommodityId=362
UPDATE PRCommodity SET prcm_ShortDescription='Epazote' WHERE prcm_CommodityId=257
UPDATE PRCommodity SET prcm_ShortDescription='Escarole' WHERE prcm_CommodityId=365
UPDATE PRCommodity SET prcm_ShortDescription='Etrog' WHERE prcm_CommodityId=61
UPDATE PRCommodity SET prcm_ShortDescription='Feijoa' WHERE prcm_CommodityId=199
UPDATE PRCommodity SET prcm_ShortDescription='Fennel' WHERE prcm_CommodityId=258
UPDATE PRCommodity SET prcm_ShortDescription='Fenugreek Seeds' WHERE prcm_CommodityId=289
UPDATE PRCommodity SET prcm_ShortDescription='Fiddlehead Fern' WHERE prcm_CommodityId=366
UPDATE PRCommodity SET prcm_ShortDescription='Fig' WHERE prcm_CommodityId=200
UPDATE PRCommodity SET prcm_ShortDescription='Filbert' WHERE prcm_CommodityId=277
UPDATE PRCommodity SET prcm_ShortDescription='Flower' WHERE prcm_CommodityId=14
UPDATE PRCommodity SET prcm_ShortDescription='Flower/Plant/Tree' WHERE prcm_CommodityId=1
UPDATE PRCommodity SET prcm_ShortDescription='Food (non-produce)' WHERE prcm_CommodityId=16
UPDATE PRCommodity SET prcm_ShortDescription='Frisee' WHERE prcm_CommodityId=368
UPDATE PRCommodity SET prcm_ShortDescription='Fruit' WHERE prcm_CommodityId=37
UPDATE PRCommodity SET prcm_ShortDescription='Gai Choy' WHERE prcm_CommodityId=297
UPDATE PRCommodity SET prcm_ShortDescription='Garlic' WHERE prcm_CommodityId=302
UPDATE PRCommodity SET prcm_ShortDescription='Genip' WHERE prcm_CommodityId=563
UPDATE PRCommodity SET prcm_ShortDescription='Gift Basket' WHERE prcm_CommodityId=246
UPDATE PRCommodity SET prcm_ShortDescription='Ginger' WHERE prcm_CommodityId=442
UPDATE PRCommodity SET prcm_ShortDescription='Gourd' WHERE prcm_CommodityId=320
UPDATE PRCommodity SET prcm_ShortDescription='Gourd' WHERE prcm_CommodityId=338
UPDATE PRCommodity SET prcm_ShortDescription='Grape' WHERE prcm_CommodityId=223
UPDATE PRCommodity SET prcm_ShortDescription='Grapefruit' WHERE prcm_CommodityId=62
UPDATE PRCommodity SET prcm_ShortDescription='Green Onion' WHERE prcm_CommodityId=305
UPDATE PRCommodity SET prcm_ShortDescription='Greens' WHERE prcm_CommodityId=370
UPDATE PRCommodity SET prcm_ShortDescription='Guacamole' WHERE prcm_CommodityId=26
UPDATE PRCommodity SET prcm_ShortDescription='Guaje' WHERE prcm_CommodityId=568
UPDATE PRCommodity SET prcm_ShortDescription='Guava' WHERE prcm_CommodityId=201
UPDATE PRCommodity SET prcm_ShortDescription='Hazelnut' WHERE prcm_CommodityId=278
UPDATE PRCommodity SET prcm_ShortDescription='Herb' WHERE prcm_CommodityId=248
UPDATE PRCommodity SET prcm_ShortDescription='Hispanic Fruit' WHERE prcm_CommodityId=247
UPDATE PRCommodity SET prcm_ShortDescription='Hispanic Vegetable' WHERE prcm_CommodityId=340
UPDATE PRCommodity SET prcm_ShortDescription='Honey' WHERE prcm_CommodityId=27
UPDATE PRCommodity SET prcm_ShortDescription='Honeydew' WHERE prcm_CommodityId=226
UPDATE PRCommodity SET prcm_ShortDescription='Inflorescent' WHERE prcm_CommodityId=342
UPDATE PRCommodity SET prcm_ShortDescription='Jack Fruit' WHERE prcm_CommodityId=89
UPDATE PRCommodity SET prcm_ShortDescription='Jamaica' WHERE prcm_CommodityId=3
UPDATE PRCommodity SET prcm_ShortDescription='Jelly' WHERE prcm_CommodityId=28
UPDATE PRCommodity SET prcm_ShortDescription='Jicama' WHERE prcm_CommodityId=341
UPDATE PRCommodity SET prcm_ShortDescription='Juice Grape' WHERE prcm_CommodityId=227
UPDATE PRCommodity SET prcm_ShortDescription='Jujube' WHERE prcm_CommodityId=202
UPDATE PRCommodity SET prcm_ShortDescription='Kale' WHERE prcm_CommodityId=384
UPDATE PRCommodity SET prcm_ShortDescription='Kiwano' WHERE prcm_CommodityId=228
UPDATE PRCommodity SET prcm_ShortDescription='Kiwifruit' WHERE prcm_CommodityId=203
UPDATE PRCommodity SET prcm_ShortDescription='Kohlrabi' WHERE prcm_CommodityId=307
UPDATE PRCommodity SET prcm_ShortDescription='Kumquat' WHERE prcm_CommodityId=63
UPDATE PRCommodity SET prcm_ShortDescription='Leafy Vegetable' WHERE prcm_CommodityId=349
UPDATE PRCommodity SET prcm_ShortDescription='Leek' WHERE prcm_CommodityId=308
UPDATE PRCommodity SET prcm_ShortDescription='Legume' WHERE prcm_CommodityId=403
UPDATE PRCommodity SET prcm_ShortDescription='Lemon' WHERE prcm_CommodityId=64
UPDATE PRCommodity SET prcm_ShortDescription='Lemon Grass' WHERE prcm_CommodityId=259
UPDATE PRCommodity SET prcm_ShortDescription='Lettuce' WHERE prcm_CommodityId=385
UPDATE PRCommodity SET prcm_ShortDescription='Lime' WHERE prcm_CommodityId=65
UPDATE PRCommodity SET prcm_ShortDescription='Longan' WHERE prcm_CommodityId=42
UPDATE PRCommodity SET prcm_ShortDescription='Loquat' WHERE prcm_CommodityId=43
UPDATE PRCommodity SET prcm_ShortDescription='Lotus Root' WHERE prcm_CommodityId=447
UPDATE PRCommodity SET prcm_ShortDescription='Lychee' WHERE prcm_CommodityId=44
UPDATE PRCommodity SET prcm_ShortDescription='Macadamia' WHERE prcm_CommodityId=279
UPDATE PRCommodity SET prcm_ShortDescription='Malanga' WHERE prcm_CommodityId=448
UPDATE PRCommodity SET prcm_ShortDescription='Mamey' WHERE prcm_CommodityId=205
UPDATE PRCommodity SET prcm_ShortDescription='Mandarin' WHERE prcm_CommodityId=70
UPDATE PRCommodity SET prcm_ShortDescription='Mango' WHERE prcm_CommodityId=98
UPDATE PRCommodity SET prcm_ShortDescription='Mangosteen' WHERE prcm_CommodityId=207
UPDATE PRCommodity SET prcm_ShortDescription='Marjoram' WHERE prcm_CommodityId=260
UPDATE PRCommodity SET prcm_ShortDescription='Melon' WHERE prcm_CommodityId=229
UPDATE PRCommodity SET prcm_ShortDescription='Mexican ChiliPepper' WHERE prcm_CommodityId=500
UPDATE PRCommodity SET prcm_ShortDescription='Mint' WHERE prcm_CommodityId=261
UPDATE PRCommodity SET prcm_ShortDescription='Mushroom' WHERE prcm_CommodityId=501
UPDATE PRCommodity SET prcm_ShortDescription='Nectarine' WHERE prcm_CommodityId=99
UPDATE PRCommodity SET prcm_ShortDescription='Nopales' WHERE prcm_CommodityId=10
UPDATE PRCommodity SET prcm_ShortDescription='Nut' WHERE prcm_CommodityId=271
UPDATE PRCommodity SET prcm_ShortDescription='Okra' WHERE prcm_CommodityId=504
UPDATE PRCommodity SET prcm_ShortDescription='Olive' WHERE prcm_CommodityId=101
UPDATE PRCommodity SET prcm_ShortDescription='On choy' WHERE prcm_CommodityId=580
UPDATE PRCommodity SET prcm_ShortDescription='Onion' WHERE prcm_CommodityId=309
UPDATE PRCommodity SET prcm_ShortDescription='Orange' WHERE prcm_CommodityId=71
UPDATE PRCommodity SET prcm_ShortDescription='Orchid' WHERE prcm_CommodityId=11
UPDATE PRCommodity SET prcm_ShortDescription='Oregano' WHERE prcm_CommodityId=263
UPDATE PRCommodity SET prcm_ShortDescription='Oyster Plant' WHERE prcm_CommodityId=449
UPDATE PRCommodity SET prcm_ShortDescription='Palm Heart' WHERE prcm_CommodityId=482
UPDATE PRCommodity SET prcm_ShortDescription='Papaya' WHERE prcm_CommodityId=208
UPDATE PRCommodity SET prcm_ShortDescription='Parsley' WHERE prcm_CommodityId=264
UPDATE PRCommodity SET prcm_ShortDescription='Parsnip' WHERE prcm_CommodityId=450
UPDATE PRCommodity SET prcm_ShortDescription='Passionfruit' WHERE prcm_CommodityId=211
UPDATE PRCommodity SET prcm_ShortDescription='Pasta' WHERE prcm_CommodityId=29
UPDATE PRCommodity SET prcm_ShortDescription='Pea' WHERE prcm_CommodityId=427
UPDATE PRCommodity SET prcm_ShortDescription='Peach' WHERE prcm_CommodityId=102
UPDATE PRCommodity SET prcm_ShortDescription='Peanut' WHERE prcm_CommodityId=280
UPDATE PRCommodity SET prcm_ShortDescription='Pear' WHERE prcm_CommodityId=161
UPDATE PRCommodity SET prcm_ShortDescription='Pecan' WHERE prcm_CommodityId=282
UPDATE PRCommodity SET prcm_ShortDescription='Pepper' WHERE prcm_CommodityId=505
UPDATE PRCommodity SET prcm_ShortDescription='Persimmon' WHERE prcm_CommodityId=45
UPDATE PRCommodity SET prcm_ShortDescription='Pimento' WHERE prcm_CommodityId=530
UPDATE PRCommodity SET prcm_ShortDescription='Pine Nut' WHERE prcm_CommodityId=283
UPDATE PRCommodity SET prcm_ShortDescription='Pineapple' WHERE prcm_CommodityId=213
UPDATE PRCommodity SET prcm_ShortDescription='Pistachio' WHERE prcm_CommodityId=284
UPDATE PRCommodity SET prcm_ShortDescription='Pitahaya' WHERE prcm_CommodityId=214
UPDATE PRCommodity SET prcm_ShortDescription='Plant' WHERE prcm_CommodityId=15
UPDATE PRCommodity SET prcm_ShortDescription='Plum' WHERE prcm_CommodityId=104
UPDATE PRCommodity SET prcm_ShortDescription='Plumcot' WHERE prcm_CommodityId=583
UPDATE PRCommodity SET prcm_ShortDescription='Pluot' WHERE prcm_CommodityId=105
UPDATE PRCommodity SET prcm_ShortDescription='Pomegranate' WHERE prcm_CommodityId=215
UPDATE PRCommodity SET prcm_ShortDescription='Potato' WHERE prcm_CommodityId=451
UPDATE PRCommodity SET prcm_ShortDescription='Potato Salad' WHERE prcm_CommodityId=30
UPDATE PRCommodity SET prcm_ShortDescription='Preserves' WHERE prcm_CommodityId=31
UPDATE PRCommodity SET prcm_ShortDescription='Prune' WHERE prcm_CommodityId=106
UPDATE PRCommodity SET prcm_ShortDescription='Pummelo' WHERE prcm_CommodityId=80
UPDATE PRCommodity SET prcm_ShortDescription='Pumpkin' WHERE prcm_CommodityId=323
UPDATE PRCommodity SET prcm_ShortDescription='Quince' WHERE prcm_CommodityId=46
UPDATE PRCommodity SET prcm_ShortDescription='Radicchio' WHERE prcm_CommodityId=393
UPDATE PRCommodity SET prcm_ShortDescription='Radish' WHERE prcm_CommodityId=455
UPDATE PRCommodity SET prcm_ShortDescription='Raisin' WHERE prcm_CommodityId=241
UPDATE PRCommodity SET prcm_ShortDescription='Rambutan' WHERE prcm_CommodityId=108
UPDATE PRCommodity SET prcm_ShortDescription='Rapini' WHERE prcm_CommodityId=394
UPDATE PRCommodity SET prcm_ShortDescription='Raspberry' WHERE prcm_CommodityId=57
UPDATE PRCommodity SET prcm_ShortDescription='Rau Day' WHERE prcm_CommodityId=298
UPDATE PRCommodity SET prcm_ShortDescription='Rau Ram' WHERE prcm_CommodityId=265
UPDATE PRCommodity SET prcm_ShortDescription='Relish' WHERE prcm_CommodityId=32
UPDATE PRCommodity SET prcm_ShortDescription='Rhubarb' WHERE prcm_CommodityId=480
UPDATE PRCommodity SET prcm_ShortDescription='Rice' WHERE prcm_CommodityId=33
UPDATE PRCommodity SET prcm_ShortDescription='Root' WHERE prcm_CommodityId=457
UPDATE PRCommodity SET prcm_ShortDescription='Root Vegetable' WHERE prcm_CommodityId=434
UPDATE PRCommodity SET prcm_ShortDescription='Rosemary' WHERE prcm_CommodityId=266
UPDATE PRCommodity SET prcm_ShortDescription='Rutabaga' WHERE prcm_CommodityId=462
UPDATE PRCommodity SET prcm_ShortDescription='Sage' WHERE prcm_CommodityId=267
UPDATE PRCommodity SET prcm_ShortDescription='Salad' WHERE prcm_CommodityId=396
UPDATE PRCommodity SET prcm_ShortDescription='Sapodillo' WHERE prcm_CommodityId=217
UPDATE PRCommodity SET prcm_ShortDescription='Sapote' WHERE prcm_CommodityId=218
UPDATE PRCommodity SET prcm_ShortDescription='Savory' WHERE prcm_CommodityId=268
UPDATE PRCommodity SET prcm_ShortDescription='Seed Garlic' WHERE prcm_CommodityId=318
UPDATE PRCommodity SET prcm_ShortDescription='Seed Potatoes' WHERE prcm_CommodityId=463
UPDATE PRCommodity SET prcm_ShortDescription='Sesame Seeds' WHERE prcm_CommodityId=34
UPDATE PRCommodity SET prcm_ShortDescription='Shallot' WHERE prcm_CommodityId=319
UPDATE PRCommodity SET prcm_ShortDescription='Soft Fruit' WHERE prcm_CommodityId=83
UPDATE PRCommodity SET prcm_ShortDescription='Sorghum' WHERE prcm_CommodityId=12
UPDATE PRCommodity SET prcm_ShortDescription='Sorrel' WHERE prcm_CommodityId=397
UPDATE PRCommodity SET prcm_ShortDescription='Specialty Fruit' WHERE prcm_CommodityId=85
UPDATE PRCommodity SET prcm_ShortDescription='Specialty Vegetable' WHERE prcm_CommodityId=550
UPDATE PRCommodity SET prcm_ShortDescription='Spice' WHERE prcm_CommodityId=287
UPDATE PRCommodity SET prcm_ShortDescription='Spinach' WHERE prcm_CommodityId=398
UPDATE PRCommodity SET prcm_ShortDescription='Spring Mix' WHERE prcm_CommodityId=400
UPDATE PRCommodity SET prcm_ShortDescription='Sprout' WHERE prcm_CommodityId=531
UPDATE PRCommodity SET prcm_ShortDescription='Squash' WHERE prcm_CommodityId=324
UPDATE PRCommodity SET prcm_ShortDescription='Stalk Vegetables' WHERE prcm_CommodityId=473
UPDATE PRCommodity SET prcm_ShortDescription='Stone Fruit' WHERE prcm_CommodityId=90
UPDATE PRCommodity SET prcm_ShortDescription='Strawberry' WHERE prcm_CommodityId=84
UPDATE PRCommodity SET prcm_ShortDescription='Sugar Cane' WHERE prcm_CommodityId=13
UPDATE PRCommodity SET prcm_ShortDescription='Sunchokes' WHERE prcm_CommodityId=464
UPDATE PRCommodity SET prcm_ShortDescription='Sunflower Seed' WHERE prcm_CommodityId=35
UPDATE PRCommodity SET prcm_ShortDescription='Sweet Potato' WHERE prcm_CommodityId=465
UPDATE PRCommodity SET prcm_ShortDescription='Tamarillo' WHERE prcm_CommodityId=219
UPDATE PRCommodity SET prcm_ShortDescription='Tamarind' WHERE prcm_CommodityId=220
UPDATE PRCommodity SET prcm_ShortDescription='Tangelo' WHERE prcm_CommodityId=81
UPDATE PRCommodity SET prcm_ShortDescription='Tangerine' WHERE prcm_CommodityId=82
UPDATE PRCommodity SET prcm_ShortDescription='Taro Root' WHERE prcm_CommodityId=466
UPDATE PRCommodity SET prcm_ShortDescription='Tarragon' WHERE prcm_CommodityId=269
UPDATE PRCommodity SET prcm_ShortDescription='Thyme' WHERE prcm_CommodityId=270
UPDATE PRCommodity SET prcm_ShortDescription='Tindora' WHERE prcm_CommodityId=299
UPDATE PRCommodity SET prcm_ShortDescription='Tofu' WHERE prcm_CommodityId=36
UPDATE PRCommodity SET prcm_ShortDescription='Tomato' WHERE prcm_CommodityId=535
UPDATE PRCommodity SET prcm_ShortDescription='Tree Fruit' WHERE prcm_CommodityId=109
UPDATE PRCommodity SET prcm_ShortDescription='Tropical Fruit' WHERE prcm_CommodityId=182
UPDATE PRCommodity SET prcm_ShortDescription='Tropical Vegetable' WHERE prcm_CommodityId=481
UPDATE PRCommodity SET prcm_ShortDescription='Tuber' WHERE prcm_CommodityId=579
UPDATE PRCommodity SET prcm_ShortDescription='Turnip' WHERE prcm_CommodityId=467
UPDATE PRCommodity SET prcm_ShortDescription='Vegetable' WHERE prcm_CommodityId=291
UPDATE PRCommodity SET prcm_ShortDescription='Vine Fruit' WHERE prcm_CommodityId=221
UPDATE PRCommodity SET prcm_ShortDescription='Walnut' WHERE prcm_CommodityId=285
UPDATE PRCommodity SET prcm_ShortDescription='Waterchestnut' WHERE prcm_CommodityId=468
UPDATE PRCommodity SET prcm_ShortDescription='Watercress' WHERE prcm_CommodityId=401
UPDATE PRCommodity SET prcm_ShortDescription='Watermelon' WHERE prcm_CommodityId=243
UPDATE PRCommodity SET prcm_ShortDescription='Yam' WHERE prcm_CommodityId=469
UPDATE PRCommodity SET prcm_ShortDescription='Yu Choy Sum' WHERE prcm_CommodityId=300
UPDATE PRCommodity SET prcm_ShortDescription='Yuca Root' WHERE prcm_CommodityId=472
Go


INSERT INTO PRAttentionLine
(prattn_CompanyID, prattn_PersonID, prattn_ItemCode, prattn_PhoneID, prattn_CreatedBy, prattn_CreatedDate, prattn_UpdatedBy, prattn_UpdatedDate, prattn_TimeStamp)
SELECT prattn_CompanyID, prattn_PersonID, 'JEP-E', phon_PhoneID, -1, GETDATE(), -1, GETDATE(), GETDATE()
  FROM PRAttentionLine
       LEFT OUTER JOIN Phone ON prattn_CompanyID = phon_CompanyID AND phon_PersonID IS NULL and phon_PRIsFax = 'Y' AND phon_PRPreferredInternal = 'Y'
 WHERE prattn_ItemCode = 'JEP'

UPDATE PRAttentionLine
   SET prattn_ItemCode = 'JEP-M'
 WHERE prattn_ItemCode = 'JEP';
Go 


UPDATE PRCommodity
   SET prcm_FullName = PublishableName
  FROM (SELECT c.prcm_CommodityId,
        c.prcm_Name,
       Case When c.prcm_Level < 4 Then c.prcm_Name
           Else Case When c2.prcm_Name Is Not Null Then
                        Case When c2.prcm_Name <> c1.prcm_Name And c1.prcm_Name <> c.prcm_Name And c2.prcm_Name <> c.prcm_Name Then c.prcm_Name + ' ' + c1.prcm_Name + ' ' + c2.prcm_Name
                             When c2.prcm_Name <> c1.prcm_Name And c1.prcm_Name <> c.prcm_Name Then c1.prcm_Name + ' ' + c2.prcm_Name
                             When c2.prcm_Name <> c1.prcm_Name And c2.prcm_Name <> c.prcm_Name Then c.prcm_Name + ' ' + c2.prcm_Name
                             When c1.prcm_Name <>  c.prcm_Name And c2.prcm_Name <> c.prcm_Name Then c.prcm_Name + ' ' + c2.prcm_Name
                        End
                     Else
                        Case When c.prcm_Name <> c1.prcm_Name Then c.prcm_Name + ' ' + c1.prcm_Name
                             Else c.prcm_Name
                             End
                End
       End As [PublishableName]
  FROM PRCommodity c
       Left Outer Join PRCommodity c1 On (c1.prcm_CommodityID = c.prcm_ParentID)
       Left Outer Join PRCommodity c2 On (c2.prcm_CommodityID = c1.prcm_ParentID And c1.prcm_Level > 3)) T1
WHERE PRCommodity.prcm_CommodityId = T1.prcm_CommodityId;
Go


UPDATE PRWebUser
   SET prwu_CompanySize = null;
   
EXEC usp_AccpacCreateSelectField 'PRWebUser', 'prwu_CompanySize', 'Company Size', 'NumEmployees'    
Go
