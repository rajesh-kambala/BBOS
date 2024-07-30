IF (NOT EXISTS (SELECT 'x' FROM PRWebUser WHERE prwu_Email = 'support300@travant.com')) BEGIN
	DECLARE @Password varchar(100), @EncryptedPassword varchar(100)

	SET @Password = 'GoCubs!!2016'
	SET @EncryptedPassword = dbo.ufnclr_EncryptText(@Password)

	ALTER TABLE Person DISABLE TRIGGER ALL
	UPDATE Person
	   SET pers_FirstName = 'Travant',
		   pers_LastName = 'User'
	 WHERE pers_PersonID=118441
	ALTER TABLE Person ENABLE TRIGGER ALL

	UPDATE PRWebUser
	   SET prwu_FirstName = 'Travant',
		   prwu_LastName = 'User',
		   prwu_Password = @EncryptedPassword,
		   prwu_Email = 'support@travant.com'
	 WHERE prwu_WebUserID = 38813

	DECLARE @WebUserID int = 100000
	DECLARE @BBID int = 204482
	DECLARE @AccessLevel varchar(10) = '300'


	INSERT INTO PRWebUser (prwu_WebUserID,prwu_Email,prwu_AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode)
	SELECT @WebUserID,'support' + @AccessLevel + '@travant.com',@AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,@BBID,@BBID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode 
	 FROM PRWebUser WHERE prwu_Email = 'support@travant.com'

	SET @WebUserID = @WebUserID + 1
	SET @AccessLevel = '400'
	INSERT INTO PRWebUser (prwu_WebUserID,prwu_Email,prwu_AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode)
	SELECT @WebUserID,'support' + @AccessLevel + '@travant.com',@AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,@BBID,@BBID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode 
	 FROM PRWebUser WHERE prwu_Email = 'support@travant.com'

/*
	SET @WebUserID = @WebUserID + 1
	SET @AccessLevel = '500'
	INSERT INTO PRWebUser (prwu_WebUserID,prwu_Email,prwu_AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode)
	SELECT @WebUserID,'support' + @AccessLevel + '@travant.com',@AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,@BBID,@BBID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode 
	 FROM PRWebUser WHERE prwu_Email = 'support@travant.com'

	SET @WebUserID = @WebUserID + 1
	SET @AccessLevel = '600'
	INSERT INTO PRWebUser (prwu_WebUserID,prwu_Email,prwu_AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode)
	SELECT @WebUserID,'support' + @AccessLevel + '@travant.com',@AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,@BBID,@BBID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode 
	 FROM PRWebUser WHERE prwu_Email = 'support@travant.com'
*/
	SET @WebUserID = @WebUserID + 1
	SET @AccessLevel = '700'
	INSERT INTO PRWebUser (prwu_WebUserID,prwu_Email,prwu_AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode)
	SELECT @WebUserID,'support' + @AccessLevel + '@travant.com',@AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,@BBID,@BBID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode 
	 FROM PRWebUser WHERE prwu_Email = 'support@travant.com'





	SET @WebUserID = @WebUserID + 1
	SET @AccessLevel = '400'
	SET @BBID = 164849

	INSERT INTO PRWebUser (prwu_WebUserID,prwu_Email,prwu_AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,prwu_IndustryTypeCode,prwu_ServiceCode)
	SELECT @WebUserID,'support' + @AccessLevel + 'L@travant.com',@AccessLevel,prwu_Password,prwu_FirstName,prwu_LastName,@BBID,@BBID,prwu_CompanyName,prwu_PersonLinkID,prwu_Culture,prwu_UICulture,'L',prwu_ServiceCode 
	 FROM PRWebUser WHERE prwu_Email = 'support@travant.com'


	UPDATE PRWebUser
	   SET prwu_TimeZone = 'Central Standard Time',
		   prwu_AcceptedTerms = NULL
	WHERE prwu_Email LIKE 'support%@travant.com'
END