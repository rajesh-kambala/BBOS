UPDATE users SET user_FaxUserID='mbx14561904', user_FaxPassword='696097' WHERE user_EmailAddress='merickson@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14562087', user_FaxPassword='938849' WHERE user_EmailAddress='korlowski@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14561867', user_FaxPassword='418852' WHERE user_EmailAddress='amacdonald@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14564193', user_FaxPassword='413839' WHERE user_EmailAddress='bzentner@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14562262', user_FaxPassword='349278' WHERE user_EmailAddress='jcarr@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14562565', user_FaxPassword='173803' WHERE user_EmailAddress='cmcgoldrick@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14563328', user_FaxPassword='8782' WHERE user_EmailAddress='dmartin@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14564568', user_FaxPassword='212852' WHERE user_EmailAddress='nmcnear@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14565051', user_FaxPassword='931558' WHERE user_EmailAddress='gfeltz@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14564690', user_FaxPassword='983151' WHERE user_EmailAddress='JLair@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14562174', user_FaxPassword='105579' WHERE user_EmailAddress='jbrown@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14564092', user_FaxPassword='819400' WHERE user_EmailAddress='jcrowley@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14563512', user_FaxPassword='993869' WHERE user_EmailAddress='kschultz@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14565868', user_FaxPassword='430391' WHERE user_EmailAddress='llima@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14562668', user_FaxPassword='316451' WHERE user_EmailAddress='lrayos@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14561764', user_FaxPassword='135597' WHERE user_EmailAddress='lbrown@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14563640', user_FaxPassword='280074' WHERE user_EmailAddress='lmcdaniel@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14565964', user_FaxPassword='927522' WHERE user_EmailAddress='mniemiec@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14565762', user_FaxPassword='4946' WHERE user_EmailAddress='sjacobs@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14562493', user_FaxPassword='876156' WHERE user_EmailAddress='tpfaff@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14563898', user_FaxPassword='996074' WHERE user_EmailAddress='vbetancourt@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14564942', user_FaxPassword='866059' WHERE user_EmailAddress='dnelson@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14566176', user_FaxPassword='842616' WHERE user_EmailAddress='fsanchez@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14564790', user_FaxPassword='291670' WHERE user_EmailAddress='csieloff@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14564892', user_FaxPassword='333134' WHERE user_EmailAddress='jmangini@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14565129', user_FaxPassword='993752' WHERE user_EmailAddress='ngilliland@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14562310', user_FaxPassword='751726' WHERE user_EmailAddress='imuniz@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14563720', user_FaxPassword='780017' WHERE user_EmailAddress='dsteeve@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14562720', user_FaxPassword='913000' WHERE user_EmailAddress='tjohnson@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14565271', user_FaxPassword='7859' WHERE user_EmailAddress='taugello@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14564421', user_FaxPassword='943362' WHERE user_EmailAddress='rdunham@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14563134', user_FaxPassword='550570' WHERE user_EmailAddress='mjorgensen@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14563246', user_FaxPassword='600794' WHERE user_EmailAddress='tpfalzgraf@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14565609', user_FaxPassword='798221' WHERE user_EmailAddress='jwinckowski@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14565317', user_FaxPassword='645449' WHERE user_EmailAddress='sbach@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14564220', user_FaxPassword='860444' WHERE user_EmailAddress='treardon@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14562820', user_FaxPassword='395164' WHERE user_EmailAddress='srempert@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14562982', user_FaxPassword='684788' WHERE user_EmailAddress='jhodur@bluebookservices.com';
UPDATE users SET user_FaxUserID='mbx14564392', user_FaxPassword='289415' WHERE user_EmailAddress='ecortes@bluebookservices.com';
Go



UPDATE PRClassification SET prcl_Name = 'Other Transportation/Logistics Services' WHERE prcl_ClassificationID=580;
UPDATE PRClassification SET prcl_Name = 'Truck/Transportation Broker', prcl_Abbreviation='TrucktransBkr', prcl_Description='Individual or entity that arranges and/or contracts for transportation of goods as a service to its customers.' WHERE prcl_ClassificationID=590;

DELETE FROM PRClassification WHERE prcl_ClassificationId = 600 --Truck Stop
DELETE FROM PRClassification WHERE prcl_ClassificationId = 510 --Freight Contractor
DELETE FROM PRClassification WHERE prcl_ClassificationId = 570 --Transportation Broker

ALTER TABLE PRCompanyClassification DISABLE TRIGGER ALL
DELETE FROM PRCompanyClassification WHERE prc2_ClassificationID = 600

/*
SELECT DISTINCT prc2_CompanyID
  FROM PRCompanyClassification
 WHERE prc2_ClassificationID IN (510, 590)
ORDER BY prc2_CompanyID
*/
DECLARE @MyTable table (
    ndx int identity(1,1),
	CompanyID int
)

INSERT INTO @MyTable 
SELECT prc2_CompanyID
  FROM PRCompanyClassification
 WHERE prc2_ClassificationID IN (510, 570)
   AND prc2_CompanyID NOT IN (SELECT prc2_CompanyID
							    FROM PRCompanyClassification
							   WHERE prc2_ClassificationID = 590)


DECLARE @Count int = 0, @Index int = 0, @CompanyID int, @RecordID int
DECLARE @Now datetime = GETDATE()
SELECT @Count = COUNT(1) FROM @MyTable

WHILE (@Index < @Count) BEGIN
	
	SET @Index = @Index + 1
	SELECT @CompanyID = CompanyID
	  FROM @MyTable
	 WHERE ndx = @Index;

	EXEC usp_GetNextId 'PRCompanyClassification', @RecordID output

	INSERT INTO PRCompanyClassification
	(prc2_CompanyClassificationId, prc2_CompanyId, prc2_ClassificationId,
	  prc2_CreatedBy,prc2_createdDate,prc2_UpdatedBy,prc2_UpdatedDate,prc2_TimeStamp)  
	VALUES (@RecordID, @CompanyID, 590, -1, @Now, -1, @Now, @Now)
	
END


DELETE FROM PRCompanyClassification WHERE prc2_ClassificationID IN (510, 570, 600)
ALTER TABLE PRCompanyClassification ENABLE TRIGGER ALL

UPDATE PRListing
   SET prlst_Listing = dbo.ufn_GetListingFromCompany(prlst_CompanyID, 0, 0),
	   prlst_UpdatedDate = GETDATE(),
	   prlst_Timestamp = GETDATE()
 WHERE prlst_CompanyID IN (
				SELECT DISTINCT prc2_CompanyID
				  FROM PRCompanyClassification
				 WHERE prc2_ClassificationID IN (510, 580, 590, 600, 570));


Go


ALTER TABLE PRCompanyProfile DISABLE TRIGGER ALL
--UPDATE PRCompanyProfile SET prcp_TrnBkrArrangesTransportation = NULL WHERE prcp_CompanyID IN (194553,205620,205971,210509,210795,210861,269687,286617,293538)

UPDATE PRCompanyProfile
   SET prcp_TrnBkrArrangesTransportation = ISNULL(prcp_TrnBkrArrangesTransportation, '') + CASE WHEN prcp_TrnBkrArrangesTransportation IS NULL THEN ',A,' ELSE 'A,' END
  FROM PRCompanyClassification 
 WHERE prc2_CompanyID = prcp_CompanyID
   AND prc2_AirFreight = 'Y'
   AND (prcp_TrnBkrArrangesTransportation IS NULL
        OR prcp_TrnBkrArrangesTransportation NOT LIKE '%,A,%')

UPDATE PRCompanyProfile
   SET prcp_TrnBkrArrangesTransportation = ISNULL(prcp_TrnBkrArrangesTransportation, '') + CASE WHEN prcp_TrnBkrArrangesTransportation IS NULL THEN ',T,' ELSE 'T,' END
  FROM PRCompanyClassification 
 WHERE prc2_CompanyID = prcp_CompanyID
   AND prc2_GroundFreight = 'Y'
   AND (prcp_TrnBkrArrangesTransportation IS NULL
        OR  prcp_TrnBkrArrangesTransportation NOT LIKE '%,T,%')

UPDATE PRCompanyProfile
   SET prcp_TrnBkrArrangesTransportation = ISNULL(prcp_TrnBkrArrangesTransportation, '') + CASE WHEN prcp_TrnBkrArrangesTransportation IS NULL THEN ',R,' ELSE 'R,' END
  FROM PRCompanyClassification 
 WHERE prc2_CompanyID = prcp_CompanyID
   AND prc2_RailFreight = 'Y'
   AND (prcp_TrnBkrArrangesTransportation IS NULL
        OR  prcp_TrnBkrArrangesTransportation NOT LIKE '%,R,%')

UPDATE PRCompanyProfile
   SET prcp_TrnBkrArrangesTransportation = ISNULL(prcp_TrnBkrArrangesTransportation, '') + CASE WHEN prcp_TrnBkrArrangesTransportation IS NULL THEN ',OC,' ELSE 'OC,' END
  FROM PRCompanyClassification 
 WHERE prc2_CompanyID = prcp_CompanyID
   AND prc2_OceanFreight = 'Y'
   AND (prcp_TrnBkrArrangesTransportation IS NULL
        OR  prcp_TrnBkrArrangesTransportation NOT LIKE '%,OC,%')
ALTER TABLE PRCompanyProfile ENABLE TRIGGER ALL 
Go 


ALTER TABLE Company DISABLE TRIGGER ALL
UPDATE Company
	SET comp_PRBusinessReport = NULL
	WHERE comp_PRBusinessReport = 'Y'
ALTER TABLE Company ENABLE TRIGGER ALL
Go


UPDATE PRPublicationArticle SET prpbar_CommunicationLanguage = 'E' WHERE prpbar_PublicationCode = 'BBS'
UPDATE PRPublicationArticle SET prpbar_CommunicationLanguage = 'S' WHERE prpbar_PublicationCode = 'BBS' AND prpbar_PublicationArticleID IN (8735,8736)
Go


UPDATE PRPublicationArticle
   SET prpbar_CategoryCode = 'M'
 WHERE prpbar_PublicationArticleID IN (7728, 7729, 7731, 6203, 11290, 6894, 6205, 6895, 6209)

UPDATE PRPublicationArticle
   SET prpbar_CategoryCode = 'RL'
WHERE prpbar_PublicationArticleID IN (8184, 7730, 7732, 7733, 8735, 8736, 6214, 6215, 11279, 6206, 6216, 7734, 6204)
Go

