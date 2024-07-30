UPDATE PRARAging
   SET praa_Count = praa_ARAgingDetailCount,
       praa_Total = praad_TotalAmountCurrent  + praad_TotalAmount1to30 + praad_TotalAmount31to60 + praad_TotalAmount61to90 + praad_TotalAmount91Plus +  praad_TotalAmount0to29 + praad_TotalAmount30to44 + praad_TotalAmount45to60 + praad_TotalAmount61Plus,
       praa_TotalCurrent = praad_TotalAmountCurrent,
       praa_Total1to30 = praad_TotalAmount1to30,
       praa_Total31to60 = praad_TotalAmount31to60,
       praa_Total61to90 = praad_TotalAmount61to90,
       praa_Total91Plus = praad_TotalAmount91Plus,
       praa_Total0to29 = praad_TotalAmount0to29,
       praa_Total30to44 = praad_TotalAmount30to44,
       praa_Total45to60 = praad_TotalAmount45to60,
       praa_Total61Plus = praad_TotalAmount61Plus       
  FROM  (
		SELECT praad_ARAgingId, 
			   praa_ARAgingDetailCount = COUNT(1), 
			   praad_TotalAmountCurrent = ISNULL(SUM(praad_AmountCurrent), 0),
			   praad_TotalAmount1to30 = ISNULL(SUM(praad_Amount1to30),  0),
			   praad_TotalAmount31to60 = ISNULL(SUM(praad_Amount31to60), 0),
			   praad_TotalAmount61to90 = ISNULL(SUM(praad_Amount61to90), 0),
			   praad_TotalAmount91Plus = ISNULL(SUM(praad_Amount91Plus), 0),
			   praad_TotalAmount0to29 = ISNULL(SUM(praad_Amount0to29),  0),
			   praad_TotalAmount30to44 = ISNULL(SUM(praad_Amount30to44), 0),
			   praad_TotalAmount45to60 = ISNULL(SUM(praad_Amount45to60), 0),
			   praad_TotalAmount61Plus = ISNULL(SUM(praad_Amount61Plus), 0)
		  FROM PRARAgingDetail WITH (NOLOCK) 
	  GROUP BY praad_ARAgingId) T1
WHERE praa_ARAgingId = T1.praad_ARAgingId
  AND praa_Total IS NULL;
Go

--  SELECT * FROM PRConnectionList
--  DELETE FROM PRConnectionList
--  DELETE FROM PRConnectionListCompany


SET NOCOUNT ON
DECLARE @Start datetime = GETDATE()

DECLARE @CLTable table (
	ndx int identity(1, 1) primary key,
	CompanyID int,
	ConnectionListDate date
)

INSERT INTO @CLTable
SELECT DISTINCT comp_CompanyID, comp_PRConnectionListDate
  FROM Company WITH (NOLOCK)
       INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON comp_CompanyID = prcr_LeftCompanyID
 WHERE comp_PRConnectionListDate IS NOT NULL
   AND comp_PRListingStatus IN ('L', 'LUV', 'H', 'N1', 'N2', 'N4')
   AND prcr_Type IN ('09','10','11','12','13','14','15','16')
   AND prcr_Active = 'Y'
ORDER BY comp_CompanyID

DECLARE @Count int, @Index int, @CompanyID int, @CLDate date
DECLARE @CLRecordID int, @RelatedCount int

SELECT @Count = COUNT(1) FROM @CLTable
SET @Index = 0

WHILE (@Index < @Count) BEGIN

	SET @Index = @Index + 1

	SELECT @CompanyID = CompanyID,
	       @CLDate = ConnectionListDate
	  FROM @CLTable
	 WHERE ndx = @Index


	EXEC usp_getNextId 'PRConnectionList', @CLRecordID Output

	INSERT INTO PRConnectionList (prcl2_ConnectionListID, prcl2_CompanyID, prcl2_ConnectionListDate, prcl2_Source, prcl2_CreatedBy, prcl2_CreatedDate, prcl2_UpdatedBy, prcl2_UpdatedDate, prcl2_Timestamp)
	VALUES (@CLRecordID, @CompanyID, @CLDate, 'Conversion', -1, @Start, -1, @Start, @Start);

	INSERT INTO PRConnectionListCompany (prclc_ConnectionListID, prclc_RelatedCompanyID, prclc_CreatedBy, prclc_CreatedDate, prclc_UpdatedBy, prclc_UpdatedDate, prclc_Timestamp)
	SELECT DISTINCT @CLRecordID, prcr_RightCompanyID, -1, @Start, -1, @Start, @Start
	  FROM PRCompanyRelationship WITH (NOLOCK)
	 WHERE prcr_Type IN ('09','10','11','12','13','14','15','16')
	  AND prcr_LeftCompanyId = @CompanyID
	  AND prcr_Active = 'Y'

	SET @RelatedCount = @@ROWCOUNT


	PRINT 'Processed ' + CAST(@CompanyID as varchar) + ' with a CL date of ' + CAST(@CLDate as varchar(50)) + ' and ' + CAST(@RelatedCount as varchar) + ' related companies.'
END

SET NOCOUNT OFF
Go


DECLARE @LastRunDate varchar(25) = CAST(DATEADD(minute, 5, GETDATE()) as varchar(25))
EXEC usp_AccpacCreateDropdownValue 'SupportedRatingLastRunDate', @LastRunDate, 0, 'SupportedRatingLastRunDate'
Go




DECLARE @RemoveText varchar(100) = '---------------------------------<br/>HQ Rating Key Numerals:'
UPDATE PRListing
   SET prlst_Listing = REPLACE(prlst_Listing, @RemoveText, '')
 WHERE prlst_Listing LIKE '%' + @RemoveText
Go


ALTER TABLE Company DISABLE TRIGGER ALL
UPDATE Company
   SET comp_PROriginalServiceStartDate = [OriginalServiceStartDate]
  FROM (
			SELECT prse_CompanyID,
			  CASE WHEN comp_PRTMFMAwardDate <
						CASE WHEN ServiceStartDate <  CodeStartDate 
							THEN ServiceStartDate 
							ELSE CodeStartDate 
						END 
				THEN comp_PRTMFMAwardDate
				ELSE 				
						CASE WHEN ServiceStartDate <  CodeStartDate 
							THEN ServiceStartDate 
							ELSE CodeStartDate 
						END 
				END					
					as [OriginalServiceStartDate]
		  FROM Company WITH (NOLOCK)
		       INNER JOIN (
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
					UNION ALL
					SELECT prse_CompanyID, 
						   prse_ServiceSinceDate, 
						   prse_CodeStartDate, 
						   prse_NextAnniversaryDate,
						   prse_StopServiceDate, 
						   prse_CodeEndDate, 
						   prse_ShipmentDate,
						   ISNULL(prse_Primary, 'Z') as prse_Primary
						FROM PRServiceArchive
                      WHERE prse_ServiceCode <> 'DL'
                      --WHERE prse_ServiceCode IN ('PO','PM','EM','RM','ZA','P3','ME','TO', 'FO','TM','FM','TR','FR','ZC','ZE','T3','F3','PB','RB','ZB','TB','FB', 'T5','F5','ZD','ZF','JB','JM','JZ','JX','OM','OR','OZ','OB','O5','OQ')
					) T10
				GROUP BY prse_CompanyID
				) T1 ON comp_CompanyID = prse_CompanyID
	   ) T2
 WHERE comp_CompanyID = prse_CompanyID

ALTER TABLE Company ENABLE TRIGGER ALL
GO



ALTER TABLE Company DISABLE TRIGGER ALL

UPDATE Company
   SET comp_PRServiceStartDate = CodeStartDate,
       comp_PRServiceEndDate = CodeEndDate
  FROM (
		SELECT prse_CompanyID,
			   CASE WHEN ServiceStartDate <  CodeStartDate THEN ServiceStartDate ELSE CodeStartDate END as CodeStartDate,
			   CASE 
				 WHEN [Primary] = 'Y' THEN NULL
				 ELSE CASE WHEN StopServiceDate >  CodeEndDate THEN StopServiceDate ELSE CodeEndDate END END as CodeEndDate_Old,
               CASE WHEN StopServiceDate >  CodeEndDate THEN StopServiceDate ELSE CodeEndDate END as CodeEndDate,
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
                      WHERE prse_ServiceCode <> 'DL'
                      --WHERE prse_ServiceCode IN ('PO','PM','EM','RM','ZA','P3','ME','TO', 'FO','TM','FM','TR','FR','ZC','ZE','T3','F3','PB','RB','ZB','TB','FB', 'T5','F5','ZD','ZF','JB','JM','JZ','JX','OM','OR','OZ','OB','O5','OQ')
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
UPDATE Company
   SET comp_PRServiceEndDate = NULL
  FROM PRService 
 WHERE comp_CompanyID = prse_CompanyID
   AND prse_Primary = 'Y'
   AND comp_PRServiceEndDate IS NOT NULL


--  No end dates should be in the future
UPDATE Company
   SET comp_PRServiceEndDate = NULL
  FROM PRService 
 WHERE comp_PRServiceEndDate > GETDATE()





-- ="UPDATE Company SET comp_PRServiceStartDate = '" & H2 & "', comp_PROriginalServiceStartDate = '" & H2 & "' WHERE comp_CompanyID = " & A2
UPDATE Company SET comp_PRServiceStartDate = '10/7/2013', comp_PROriginalServiceStartDate = '10/7/2013' WHERE comp_CompanyID = 112897
UPDATE Company SET comp_PRServiceStartDate = '3/15/2013', comp_PROriginalServiceStartDate = '3/15/2013' WHERE comp_CompanyID = 113205
UPDATE Company SET comp_PRServiceStartDate = '3/31/2004', comp_PROriginalServiceStartDate = '3/31/2004' WHERE comp_CompanyID = 171232
UPDATE Company SET comp_PRServiceStartDate = '11/15/2000', comp_PROriginalServiceStartDate = '11/15/2000' WHERE comp_CompanyID = 165941
UPDATE Company SET comp_PRServiceStartDate = '1/25/2000', comp_PROriginalServiceStartDate = '1/25/2000' WHERE comp_CompanyID = 164105
UPDATE Company SET comp_PRServiceStartDate = '5/9/1996', comp_PROriginalServiceStartDate = '5/9/1996' WHERE comp_CompanyID = 149211
UPDATE Company SET comp_PRServiceStartDate = '10/31/1980', comp_PROriginalServiceStartDate = '10/31/1980' WHERE comp_CompanyID = 127928
UPDATE Company SET comp_PRServiceStartDate = '7/6/1979', comp_PROriginalServiceStartDate = '7/6/1979' WHERE comp_CompanyID = 138436
UPDATE Company SET comp_PRServiceStartDate = '10/23/1978', comp_PROriginalServiceStartDate = '10/23/1978' WHERE comp_CompanyID = 145726
UPDATE Company SET comp_PRServiceStartDate = '6/4/1974', comp_PROriginalServiceStartDate = '6/4/1974' WHERE comp_CompanyID = 154008

ALTER TABLE Company ENABLE TRIGGER ALL
Go


UPDATE PRCompanyExternalNews
   SET prcen_LastRetrievalDateTime = DATEADD(day, -1, prcen_LastRetrievalDateTime)
 WHERE prcen_LastRetrievalDateTime > DATEADD(day, -1, GETDATE());
 Go

 
 
 UPDATE PRCompanyRelationship
    SET prcr_Type = '15'
  WHERE prcr_Type IN ('14', '16')

 UPDATE PRCompanyRelationship
    SET prcr_Type = '15'
   FROM Company
  WHERE prcr_Type IN ('11')
    AND prcr_LeftCompanyID = comp_CompanyID
	AND comp_PRIndustryType = 'P'

 UPDATE PRCompanyRelationship
    SET prcr_Type = '15'
   FROM Company
  WHERE prcr_Type IN ('09', '12', '13')
    AND prcr_LeftCompanyID = comp_CompanyID
	AND comp_PRIndustryType = 'T'

 UPDATE PRCompanyRelationship
    SET prcr_Type = '15'
   FROM Company
  WHERE prcr_Type IN ('10', '11', '12')
    AND prcr_LeftCompanyID = comp_CompanyID
	AND comp_PRIndustryType = 'L'

Go


ALTER TABLE PRWebUser DISABLE TRIGGER ALL
UPDATE PRWebUser
   SET prwu_CompanyUpdateMessageType = 'A'
ALTER TABLE PRWebUser ENABLE TRIGGER ALL
Go


 DELETE Channel_Link
 OUTPUT DELETED.* 
   FROM Users 
  WHERE user_userID = chli_user_ID
    AND user_logon IN ('rda', 'vjb', 'zmc', 'jmc', 'nlg', 'jdh', 'taj', 'amn', 'dcn', 'kws', 'bmz')
	AND ChLi_Channel_Id = 10;

Go

--
--  Create AUS lists for those users that are missing an AUS list.
--
INSERT INTO PRWebUserList (prwucl_WebUserID, prwucl_CompanyID, prwucl_HQID, prwucl_TypeCode, prwucl_Name, prwucl_Description, prwucl_IsPrivate, prwucl_CreatedBy, prwucl_CreatedDate, prwucl_UpdatedBy, prwucl_UpdatedDate, prwucl_Timestamp)
 SELECT prwu_WebUserID, prwu_BBID, prwu_HQID, 'AUS', 'Automatic Update Service List', 'Companies that are automatically monitored.', 'Y', prwu_WebUserID, GETDATE(), prwu_WebUserID, GETDATE(), GETDATE()
    FROM PRWebUser
         LEFT OUTER JOIN PRWebUserList a ON prwu_WebUserID = a.prwucl_WebUserID AND a.prwucl_TypeCode = 'AUS'
 WHERE prwu_AccessLevel >= 200
   AND a.prwucl_WebUserListID IS NULL;
Go



INSERT INTO PRProductProvided (prprpr_ProductProvidedID, prprpr_Level, prprpr_DisplayOrder, prprpr_Name, prprpr_CreatedBy, prprpr_CreatedDate, prprpr_UpdatedBy, prprpr_UpdatedDate, prprpr_TimeStamp)
VALUES (63, 1, 1775, 'Logs', -1, GETDATE(), -1, GETDATE(), GETDATE());
Go


ALTER TABLE Person DISABLE TRIGGER ALL
UPDATE Person 
   SET pers_FirstNameAlphaOnly = dbo.GetLowerAlpha(Pers_FirstName),
       pers_LastNameAlphaOnly = dbo.GetLowerAlpha(Pers_LastName)
ALTER TABLE Person ENABLE TRIGGER ALL
Go


UPDATE PRCompanyIndicators
   SET prci2_BillingException = NULL
  FROM Company
 WHERE comp_PRIndustryType = 'L'
   AND prci2_BillingException IS NOT NULL
   AND comp_CompanyID = prci2_CompanyID;
Go