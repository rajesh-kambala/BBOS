SET NOCOUNT ON

-- First we need to get rid of the duplicate CLs
DELETE FROM PRWebUserListDetail
WHERE prwuld_WebUserListID IN (
	SELECT WebUserListID FROM (
			SELECT prwucl_HQID, MIN(prwucl_WebUserListID) As WebUserListID
			  from PRWebUserList 
			 WHERE prwucl_TypeCode = 'CL'
			GROUP BY prwucl_HQID
			having COUNT(1) > 1) T1
	)

DELETE FROM PRWebUserList
WHERE prwucl_WebUserListID IN (
	SELECT WebUserListID FROM (
			SELECT prwucl_HQID, MIN(prwucl_WebUserListID) As WebUserListID
			  from PRWebUserList 
			 WHERE prwucl_TypeCode = 'CL'
			GROUP BY prwucl_HQID
			having COUNT(1) > 1) T1
	)

--
--  Yes, I meant to do this twice.
--
DELETE FROM PRWebUserListDetail
WHERE prwuld_WebUserListID IN (
	SELECT WebUserListID FROM (
			SELECT prwucl_HQID, MIN(prwucl_WebUserListID) As WebUserListID
			  from PRWebUserList 
			 WHERE prwucl_TypeCode = 'CL'
			GROUP BY prwucl_HQID
			having COUNT(1) > 1) T1
	)

DELETE FROM PRWebUserList
WHERE prwucl_WebUserListID IN (
	SELECT WebUserListID FROM (
			SELECT prwucl_HQID, MIN(prwucl_WebUserListID) As WebUserListID
			  from PRWebUserList 
			 WHERE prwucl_TypeCode = 'CL'
			GROUP BY prwucl_HQID
			having COUNT(1) > 1) T1
	)
	
DELETE FROM PRWebUserListDetail
WHERE prwuld_WebUserListDetailID IN (
	SELECT WebUserListDetailID FROM (
SELECT prwuld_WebUserListID, prwuld_AssociatedID, MAX(prwuld_WebUserListDetailID) As WebUserListDetailID 
  FROM PRWebUserList
       INNER JOIN PRWebUserListDetail ON prwucl_WebUserListID = prwuld_WebUserListID
 WHERE prwucl_TypeCode = 'CL'
GROUP BY prwuld_WebUserListID, prwuld_AssociatedID
having COUNT(1) > 1) T1
)




DECLARE @MyTable table (
	HQID int,
	BBOSCLCount int,
	CRMCLCount int
)	

INSERT INTO @MyTable (HQID, BBOSCLCount)
SELECT prwucl_HQID, COUNT(1)
  FROM PRWebUserList
       INNER JOIN PRWebUserListDetail ON prwucl_WebUserListID = prwuld_WebUserListID
 WHERE prwucl_TypeCode = 'CL'
GROUP BY prwucl_HQID
ORDER BY prwucl_HQID;

UPDATE @MyTable
   SET CRMCLCount = CRMCount
  FROM 
	 (SELECT comp_PRHQId, COUNT(DISTINCT prcr_RightCompanyID) As CRMCount
	   FROM PRCompanyRelationship
			INNER JOIN Company ON comp_PRHQId = prcr_LeftCompanyId
	  WHERE prcr_Type IN ('09', '10', '11', '12', '13', '14', '15', '16')
		AND prcr_Active = 'Y'
	GROUP BY comp_PRHQId) T1
WHERE HQID = comp_PRHQId;

SELECT COUNT(1) 
  FROM @MyTable
 WHERE BBOSCLCount <> CRMCLCount; 

 DECLARE @HQs table (
    ndx int identity(0,1),
	HQID int
)

DECLARE @Count int, @Index int, @HQID int

INSERT INTO @HQs (HQID) 
SELECT HQID 
  FROM @MyTable
 WHERE BBOSCLCount <> CRMCLCount;
 
 
SELECT @Count = COUNT(1) FROM @HQs;
SET @Index = 0
WHILE @Index < @Count BEGIN

	SELECT @HQID = HQID  
	  FROM @HQs
	 WHERE ndx = @Index;

	EXEC usp_ResetBBOSUserListConnectionList @HQID;
	
	SET @Index = @Index + 1; 
END 

UPDATE @MyTable
   SET BBOSCLCount = BBOSCount
  FROM 
	 (SELECT prwucl_HQID, COUNT(1) As BBOSCount
  FROM PRWebUserList
       INNER JOIN PRWebUserListDetail ON prwucl_WebUserListID = prwuld_WebUserListID
 WHERE prwucl_TypeCode = 'CL'
GROUP BY prwucl_HQID) T1
WHERE HQID = prwucl_HQID;
Go 


INSERT INTO PRWidgetKey (prwk_CompanyID, prwk_WidgetTypeCode, prwk_LicenseKey, prwk_HostName, prwk_CreatedBy, prwk_CreatedDate, prwk_UpdatedBy, prwk_UpdatedDate, prwk_TimeStamp)
VALUES (204482, 'CompanyAuth', 'LH204482Test', 'localhost', -1, GETDATE(), -1, GETDATE(), GETDATE());

INSERT INTO PRWidgetKey (prwk_CompanyID, prwk_WidgetTypeCode, prwk_LicenseKey, prwk_HostName, prwk_CreatedBy, prwk_CreatedDate, prwk_UpdatedBy, prwk_UpdatedDate, prwk_TimeStamp)
VALUES (204482, 'CompanyAuth', 'QA204482Test', 'qa.apps.bluebookservices.com', -1, GETDATE(), -1, GETDATE(), GETDATE());

INSERT INTO PRWidgetKey (prwk_CompanyID, prwk_WidgetTypeCode, prwk_LicenseKey, prwk_HostName, prwk_CreatedBy, prwk_CreatedDate, prwk_UpdatedBy, prwk_UpdatedDate, prwk_TimeStamp)
VALUES (100002, 'CompanyAuth', 'LH100002Test', 'localhost', -1, GETDATE(), -1, GETDATE(), GETDATE());

INSERT INTO PRWidgetKey (prwk_CompanyID, prwk_WidgetTypeCode, prwk_LicenseKey, prwk_HostName, prwk_CreatedBy, prwk_CreatedDate, prwk_UpdatedBy, prwk_UpdatedDate, prwk_TimeStamp)
VALUES (100002, 'CompanyAuth', 'PRD100002Test', 'apps.bluebookservices.com', -1, GETDATE(), -1, GETDATE(), GETDATE());

INSERT INTO PRWidgetKey (prwk_CompanyID, prwk_WidgetTypeCode, prwk_LicenseKey, prwk_HostName, prwk_CreatedBy, prwk_CreatedDate, prwk_UpdatedBy, prwk_UpdatedDate, prwk_TimeStamp)
VALUES (100002, 'CompanyAuth', 'QA100002Test', 'qa.apps.bluebookservices.com', -1, GETDATE(), -1, GETDATE(), GETDATE());


INSERT INTO PRWidgetKey (prwk_CompanyID, prwk_WidgetTypeCode, prwk_LicenseKey, prwk_HostName, prwk_CreatedBy, prwk_CreatedDate, prwk_UpdatedBy, prwk_UpdatedDate, prwk_TimeStamp)
VALUES (204482, 'QuickFind', '204482Test', 'localhost', -1, GETDATE(), -1, GETDATE(), GETDATE());

INSERT INTO PRWidgetKey (prwk_CompanyID, prwk_WidgetTypeCode, prwk_LicenseKey, prwk_HostName, prwk_CreatedBy, prwk_CreatedDate, prwk_UpdatedBy, prwk_UpdatedDate, prwk_TimeStamp)
VALUES (204482, 'QuickFind', 'QA204482Test', 'qa.apps.bluebookservices.com', -1, GETDATE(), -1, GETDATE(), GETDATE());

INSERT INTO PRWidgetKey (prwk_CompanyID, prwk_WidgetTypeCode, prwk_LicenseKey, prwk_HostName, prwk_CreatedBy, prwk_CreatedDate, prwk_UpdatedBy, prwk_UpdatedDate, prwk_TimeStamp)
VALUES (100002, 'QuickFind', 'PRD100002Test', 'apps.bluebookservices.com', -1, GETDATE(), -1, GETDATE(), GETDATE());

INSERT INTO PRWidgetKey (prwk_CompanyID, prwk_WidgetTypeCode, prwk_LicenseKey, prwk_HostName, prwk_CreatedBy, prwk_CreatedDate, prwk_UpdatedBy, prwk_UpdatedDate, prwk_TimeStamp)
VALUES (100002, 'QuickFind', 'QA100002Test', 'qa.apps.bluebookservices.com', -1, GETDATE(), -1, GETDATE(), GETDATE());
Go


UPDATE PRCountry 
   SET prcn_CountryId = prcn_CountryID - 912
 WHERE prcn_CountryId > 100;   

UPDATE PRState
   SET prst_CountryId = prst_CountryId - 912
WHERE prst_CountryId > 100;      

EXEC usp_DTSPostExecute  'PRCountry', 'prcn_CountryID'
Go


UPDATE PRShipmentLog
   SET prshplg_Type = 'Mass';

INSERT INTO PRShipmentLogDetail (prshplgd_ShipmentLogID, prshplgd_ItemCode, prshplgd_CreatedBy, prshplgd_CreatedDate, prshplgd_UpdatedBy, prshplgd_UpdatedDate, prshplgd_Timestamp)
SELECT prshplg_ShipmentLogID, prshplg_ItemCode, prshplg_CreatedBy, prshplg_CreatedDate, prshplg_UpdatedBy, prshplg_UpdatedDate, prshplg_Timestamp
  FROM PRShipmentLog;
Go




UPDATE PRAttentionLine
   SET prattn_ItemCode = CASE prse_ServiceSubCode WHEN 'BKOCT' THEN 'BOOK-OCT' WHEN 'BKAPR' THEN 'BOOK-APR' WHEN 'BKUNV' THEN 'BOOK-UNV' END,
       prattn_UpdatedBy = -1,
       prattn_UpdatedDate = GETDATE(),
       prattn_TimeStamp = GETDATE()
  FROM PRAttentionLine
       INNER JOIN PRService_Backup ON prattn_ServiceID = prse_ServiceID
 WHERE prattn_ItemCode = 'BOOK'
   AND prse_ServiceSubCode <> 'BKALL';

INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_PersonID, prattn_AddressID, prattn_CustomLine, prattn_ItemCode, prattn_CreatedBy, prattn_CreatedDate, prattn_UpdatedBy, prattn_UpdatedDate, prattn_TimeStamp)
SELECT prattn_CompanyID, prattn_PersonID, prattn_AddressID, prattn_CustomLine, 'BOOK-APR', -1, GETDATE(), -1, GETDATE(), GETDATE()
  FROM PRAttentionLine
       INNER JOIN PRService_Backup ON prattn_ServiceID = prse_ServiceID
 WHERE prattn_ItemCode = 'BOOK'
   AND prse_ServiceSubCode = 'BKALL';
   
UPDATE PRAttentionLine
   SET prattn_ItemCode = 'BOOK-OCT',
       prattn_UpdatedBy = -1,
       prattn_UpdatedDate = GETDATE(),
       prattn_TimeStamp = GETDATE()
  FROM PRAttentionLine
       INNER JOIN PRService_Backup ON prattn_ServiceID = prse_ServiceID
 WHERE prattn_ItemCode = 'BOOK'
   AND prse_ServiceSubCode = 'BKALL';
Go     

DELETE FROM PRCompanyIndicators;
INSERT INTO PRCompanyIndicators (prci2_CompanyIndicatorID, prci2_CompanyID, prci2_CreatedBy, prci2_CreatedDate, prci2_UpdatedBy, prci2_UpdatedDate, prci2_Timestamp)
SELECT (ROW_NUMBER() OVER(ORDER BY comp_CompanyID) + 5999) AS 'Row Number', comp_CompanyID , -1, GETDATE(), -1, GETDATE(), GETDATE()
  FROM Company
 WHERE comp_PRListingStatus NOT IN ('N3', 'D')
ORDER BY comp_CompanyID;
  
EXEC usp_DTSPostExecute  'PRCompanyIndicators', 'prci2_CompanyIndicatorID'  
Go     

  
  
UPDATE PRWebUser
   SET prwu_ServiceCode =  CASE prse_ServiceCode 
						WHEN 'BBS100' THEN 'LTDLIC'
						WHEN 'BBS150' THEN 'INTLIC'
						WHEN 'BBS200' THEN 'ADVLIC'
						WHEN 'BBS135' THEN 'INTLIC'
						WHEN 'BBS300' THEN 'PRMLIC'
						WHEN 'BBS350' THEN 'PRMLIC'
						WHEN 'BBS75'  THEN 'LTDLIC'
						WHEN 'L200'   THEN 'LMBLIC'
						WHEN 'L225'   THEN 'LMBLIC'
						ELSE prse_ServiceCode
						END
  FROM PRWebUser
       INNER JOIN PRService_Backup ON prwu_HQID = prse_HQID AND prse_ServiceID = prwu_ServiceID;

SELECT * FROM NewProduct       
  WHERE prod_productfamilyid = 5 

UPDATE NewProduct SET prod_code = 'TRLLIC' WHERE Prod_ProductID=68;
DELETE FROM NewProduct WHERE Prod_ProductID IN (69, 70);
Go       

UPDATE NewProduct 
   SET prod_PRSequence = (prod_PRSequence * 10)
WHERE prod_productfamilyid=6   

INSERT INTO NewProduct
(Prod_ProductID,prod_Active,prod_IndustryTypeCode,prod_UOMCategory,prod_name,prod_code,prod_productfamilyid,prod_PRServiceUnits,prod_PRRecurring,prod_PRWebAccess,prod_PRWebUsers,prod_PRWebAccessLevel,prod_PRSequence,prod_PRDescription,prod_PRNameES,prod_PRDescriptionES,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
Values (69,'Y', ',P,T,S,', 6000, 'Basic BBOS License','BSCLIC',6, 0, 'Y', 'Y', 1, 250, 15, '', 'Basic BBOS License (es)', '', -100,GETDATE(),-100,GETDATE(),GETDATE());
GO

UPDATE CRM.dbo.NewProduct
   SET prod_name = ItemCodeDesc
  FROM MAS_PRC.dbo.CI_Item 
 WHERE prod_code = ItemCode
   AND prod_name <> ItemCodeDesc;

UPDATE NewProduct
   SET prod_name = 'Lumber Blue Book Service: 225'
 WHERE prod_name = 'Lumbe Blue Book Service: 225';  
 
UPDATE NewProduct
   SET prod_name = 'Lumber Blue Book Service: 200'
 WHERE prod_name = 'Lumbe Blue Book Service: 200';             
Go
  
UPDATE Opportunity
   SET oppo_Source = 'IB'
 WHERE oppo_Source = 'InBound';
Go
  
DROP INDEX IDX_prshplg_ServiceID ON PRShipmentLog;
GO
  
ALTER TABLE Address DISABLE TRIGGER ALL
UPDATE Address
   SET Addr_City = NULL,
       Addr_State = NULL,
       Addr_Country = NULL;
ALTER TABLE Address ENABLE TRIGGER ALL     
Go  


INSERT INTO Users (user_UserID, User_Logon, user_FirstName, user_LastName, user_Disabled) VALUES (-2, 'CRMDataImport', 'CRM', 'DataImport', 'Y');           
Go
  
EXEC usp_AccpacDropField 'Email', 'emai_PRSlot'
EXEC usp_AccpacDropField 'Phone', 'phon_PRSlot'
EXEC usp_AccpacDropField 'Address_Link', 'adli_PRSlot'  
EXEC usp_AccpacDropField 'Company', 'comp_PRDaysPastDue'
EXEC usp_AccpacDropField 'Company', 'comp_PRDLDaysPastDue'
EXEC usp_AccpacDropField 'PRShipmentLog', 'prshplg_ItemCode'
EXEC usp_AccpacDropField 'PRShipmentLog', 'prshplg_ServiceID'

/*
EXEC usp_AccpacDropField 'PRWebUser', 'prwu_PRServiceID'
EXEC usp_AccpacDropField 'PRWebUser', 'prwu_PreviousServiceID'
EXEC usp_AccpacDropField 'PRAdCampaign', 'pradc_ServiceID'
EXEC usp_AccpacDropField 'PRServiceUnitAllocation', 'prun_ServiceID'
EXEC usp_AccpacDropField 'PRAttentionLine', 'prattn_ServiceID'
*/


--
--  Exclude Travant from the Session IP tracking
--
UPDATE Company 
   SET comp_PRSessionTrackerIDCheckDisabled = 'Y'
 WHERE comp_CompanyID=204482;
 
DELETE
  FROM PRWebUserSearchCriteria
 WHERE prsc_HQID = 204482
   AND prsc_WebUserID = 22394
   AND prsc_ExecutionCount = 0;
Go 


DELETE FROM PRHoliday;
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2013-01-01','New Year''s Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2012-12-31','New Year''s Eve','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2012-12-25','Christmas Holiday','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2012-12-24','Christmas Eve','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2012-11-23','Thanksgiving Friday','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2012-11-22','Thanksgiving Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2012-09-03','Labor Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2012-07-04','Independence Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2012-05-28','Memorial Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2012-01-02','New Year''s Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2011-12-26','Christmas Holiday','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2011-11-25','Thanksgiving Friday','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2011-11-24','Thanksgiving Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2011-09-05','Labor Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2011-07-04','Independence Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2011-05-30','Memorial Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2010-12-31','New Year''s Eve','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2010-12-24','Christmas Eve','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2010-11-26','Thanksgiving Friday','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2010-11-25','Thanksgiving Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2010-09-06','Labor Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2010-07-05','Independence Day','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2010-05-31','Memorial Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2010-01-01','New Year''s Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2009-12-31','New Year''s Eve','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2009-12-25','Christmas Holiday','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2009-12-24','Christmas Eve','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2009-11-27','Thanksgiving Friday','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2009-11-26','Thanksgiving Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2009-09-07','Labor Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2009-07-03','Independence Day','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2009-05-25','Memorial Day','Full', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2009-01-02','New Year''s Holiday','Skeleton', -1, -1)
INSERT INTO PRHoliday (prhldy_Date, prhldy_Description, prhldy_TypeCode, prhldy_CreatedBy, prhldy_UpdatedBy) VALUES ('2009-01-01','New Year''s Day','Full', -1, -1)
Go


DELETE FROM PRPublicationArticle WHERE prpbar_PublicationCode = 'TRN'
DECLARE @NextID int
SELECT @NextID = MAX(prpbar_PublicationArticleID) FROM PRPublicationArticle;


SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_Abstract, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_Length, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Quick Find', 'Find Customers by name', ',P,T,S,', 1, '1 min : 20 sec', 'Video', 'TRN/BBOS_Quick_Find', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_Abstract, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_Length, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Search Companies', 'Find particular groupings of customers', ',P,T,S,', 2, '1 min : 53 sec', 'Video', 'TRN/BBOS_Search_Companies', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_Abstract, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_Length, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Search Results', 'Using your Search Results', ',P,T,S,', 3, '2 min : 00 sec', 'Video', 'TRN/BBOS_Search_Results',  -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Navigating BBOS', ',P,T,S,', 1, 'Doc', 'TRN/BBOS_Tip_01_Navigating BBOS.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Quick Find', ',P,T,S,', 2, 'Doc', 'TRN/BBOS_Tip_02_Quick_Find.PDF', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Search Companies', ',P,T,S,', 3, 'Doc', 'TRN/BBOS_Tip_03_Search Companies.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Search Results', ',P,T,S,', 4, 'Doc', 'TRN/BBOS_Tip_04_Search Results.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Business Report', ',P,T,S,', 5, 'Doc', 'TRN/BBOS_Tip_05_Business Report.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Watchdog Lists', ',P,T,S,', 6, 'Doc', 'TRN/BBOS_Tip_06_Watchdog Lists.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Notes', ',P,T,S,', 7, 'Doc', 'TRN/BBOS_Tip_07_Notes.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Print/Download Results', ',P,T,S,', 8, 'Doc', 'TRN/BBOS_Tip_08_Print_Download_Results.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Search Updates', ',P,T,S,', 9, 'Doc', 'TRN/BBOS_Tip_09_Search Updates.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Downloads & Uploads', ',P,T,S,', 10, 'Doc', 'TRN/BBOS_Tip_10_Downloads_Uploads.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Trade Experience Surveys ', ',P,T,S,', 11, 'Doc', 'TRN/BBOS_Tip_11_Trade Experience Survey.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'BBOS Mobile', ',P,T,S,', 12, 'Doc', 'TRN/BBOS_Tip_12_BBOS Mobile.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Learning Center', ',P,T,S,', 13, 'Doc', 'TRN/BBOS_Tip_13_Education.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Saving Search Criteria ', ',P,T,S,', 14, 'Doc', 'BBOS_Tip_14_Saving Search Criteria.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Submit a Claim Online ', ',P,T,S,', 15, 'Doc', 'TRN/BBOS_Tip_15_Submit Claim Online.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Exporting Data', ',P,T,S,', 16, 'Doc', 'TRN/BBOS_Tip_16_Exporting Data.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Connection List Updates ', ',P,T,S,', 17, 'Doc', 'TRN/BBOS_Tip_17_Connection List Update.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Analyze Companies', ',P,T,S,', 18, 'Doc', 'TRN/BBOS_Tip_18_Analyze Companies.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Search People', ',P,T,S,', 19, 'Doc', 'TRN/BBOS_Tip_19_Search People.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'A Review', ',P,T,S,', 20, 'Doc', 'TRN/BBOS_Tip_20_A Review.pdf', -1, -1);


SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Navigating BBOS', ',L,', 1, 'Doc', 'TRN/BBOSL_Tip_01_Navigating.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Quick Find', ',L,', 2, 'Doc', 'TRN/BBOSL_Tip_02_Quick_Find.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Search Companies', ',L,', 3, 'Doc', 'TRN/BBOSL_Tip_03_Search Companies.pdf', -1, -1);

SET @NextID = @NextID + 1
INSERT INTO PRPublicationArticle (prpbar_PublicationArticleID, prpbar_PublicationCode, prpbar_PublishDate, prpbar_Name, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_MediaTypeCode, prpbar_FileName, prpbar_CreatedBy, prpbar_UpdatedBy)
VALUES (@NextID, 'TRN', '2011-01-01', 'Business Report', ',L,', 4, 'Doc', 'TRN/BBOSL_Tip_04_Business Report.pdf', -1, -1);

EXEC usp_DTSPostExecute 'PRPublicationArticle', 'prpbar_PublicationArticleID'
Go


UPDATE PRPersonEvent
   SET prpe_DisplayedEffectiveDate = DATENAME(MM, prpe_Date) + ' ' + CAST(DAY(prpe_Date) AS VARCHAR(2)) + ', ' + CAST(YEAR(prpe_Date) AS VARCHAR(4)),
       prpe_DisplayedEffectiveDateStyle = '0'
 WHERE prpe_Date IS NOT NULL;     
Go  


--
--  Update the listing cache with those listings
--  that may not be accurate due to person changes for 
--  PROP companies and subsidiary changes.
--
SET NOCOUNT ON
DECLARE @tblCompanies table (
	ndx int primary key identity(0,1),
	CompanyID int
)

INSERT INTO @tblCompanies (CompanyID)
 SELECT DISTINCT prcp_companyid
   FROM Company WITH (NOLOCK)
        INNER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyID = prcp_companyid
        INNER JOIN Person_Link WITH (NOLOCK) on comp_CompanyID = peli_CompanyID
  WHERE prcp_CorporateStructure = 'PROP'
    AND comp_PRListingStatus IN ('L', 'H', 'LUV')
    AND peli_PROwnershipRole = 'RCO' 
    AND peli_PRStatus = '1';
    
INSERT INTO @tblCompanies (CompanyID)
SELECT DISTINCT prcr_RightCompanyId
  FROM Company WITH (NOLOCK)
       INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON comp_CompanyID = prcr_RightCompanyId
 WHERE comp_PRListingStatus IN ('L', 'H', 'LUV')
   AND prcr_Type IN ('27', '28');
   
   
DECLARE @Count int, @Index int, @CompanyID int 
SELECT @Count = COUNT(1) FROM @tblCompanies;
SET @Index = 0
WHILE @Index < @Count BEGIN

	SELECT @CompanyID = CompanyID  
	  FROM @tblCompanies
	 WHERE ndx = @Index;

    EXEC usp_UpdateListing @CompanyID;
    EXEC usp_UpdateBranchListings @CompanyID;
	
	SET @Index = @Index + 1; 
END 
SET NOCOUNT OFF
Go


--
--  Create attention lines for the listed companies that are missing them
--
INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT Comp_CompanyId, 'LRL', -1, -1
  FROM Company
       LEFT OUTER JOIN PRAttentionLine ON Comp_CompanyId = prattn_CompanyID AND prattn_ItemCode = 'LRL'
 WHERE comp_PRListingStatus in ('L', 'H', 'LUV', 'N1')
   AND prattn_AttentionLineID IS NULL
   
INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT Comp_CompanyId, 'JEP-M', -1, -1
  FROM Company
       LEFT OUTER JOIN PRAttentionLine ON Comp_CompanyId = prattn_CompanyID AND prattn_ItemCode = 'JEP-M'
 WHERE comp_PRListingStatus in ('L', 'H', 'LUV', 'N1')
   AND prattn_AttentionLineID IS NULL
      
INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT Comp_CompanyId, 'JEP-E', -1, -1
  FROM Company
       LEFT OUTER JOIN PRAttentionLine ON Comp_CompanyId = prattn_CompanyID AND prattn_ItemCode = 'JEP-E'
 WHERE comp_PRListingStatus in ('L', 'H', 'LUV', 'N1')
   AND prattn_AttentionLineID IS NULL   
      
INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT Comp_CompanyId, 'TES-E', -1, -1
  FROM Company
       LEFT OUTER JOIN PRAttentionLine ON Comp_CompanyId = prattn_CompanyID AND prattn_ItemCode = 'TES-E'
 WHERE comp_PRListingStatus in ('L', 'H', 'LUV', 'N1')
   AND prattn_AttentionLineID IS NULL   
      
INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT Comp_CompanyId, 'TES-M', -1, -1
  FROM Company
       LEFT OUTER JOIN PRAttentionLine ON Comp_CompanyId = prattn_CompanyID AND prattn_ItemCode = 'TES-M'
 WHERE comp_PRListingStatus in ('L', 'H', 'LUV', 'N1')
   AND comp_PRListingStatus <> 'L'
   AND prattn_AttentionLineID IS NULL   
      
INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT Comp_CompanyId, 'TES-V', -1, -1
  FROM Company
       LEFT OUTER JOIN PRAttentionLine ON Comp_CompanyId = prattn_CompanyID AND prattn_ItemCode = 'TES-V'
 WHERE comp_PRListingStatus in ('L', 'H', 'LUV', 'N1')
   AND prattn_AttentionLineID IS NULL   
      
INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_CreatedBy, prattn_UpdatedBy)
SELECT Comp_CompanyId, 'BILL', -1, -1
  FROM Company
       LEFT OUTER JOIN PRAttentionLine ON Comp_CompanyId = prattn_CompanyID AND prattn_ItemCode = 'BILL'
 WHERE comp_PRListingStatus in ('L', 'H', 'LUV', 'N1')
   AND prattn_AttentionLineID IS NULL   
Go


USE [CRM]
GO


IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PRServiceArchive]') AND name = N'PK__PRServiceArchive__7A099D64')
	ALTER TABLE [dbo].[PRServiceArchive] DROP CONSTRAINT [PK__PRServiceArchive__7A099D64]
GO


INSERT INTO PRServiceArchive
SELECT prse_ServiceId, prse_Deleted, prse_WorkflowId, prse_Secterr, prse_CreatedBy, prse_CreatedDate, prse_UpdatedBy, prse_UpdatedDate, prse_TimeStamp, prse_CompanyId, prse_ServiceCode, prse_ServiceSubCode, prse_Primary, prse_CodeStartDate, prse_NextAnniversaryDate, prse_CodeEndDate, prse_StopServiceDate, prse_CancelCode, prse_ServiceSinceDate, prse_InitiatedBy, prse_BillToCompanyId, prse_Terms, prse_HoldShipmentId, prse_HoldMailId, prse_EBBSerialNumber, prse_ContractOnHand, prse_DeliveryMethod, prse_ReferenceNumber, prse_ShipmentDate, prse_ShipmentDescription, prse_Description, prse_ServicePrice, prse_UnitsPackaged
  FROM PRService_Backup;
Go 


--
--  Set the Pay Indicator to NULL for those companies that used
--  to have AR data but no longer do.
--
DECLARE @PayIndicatorCompanies table (
	CompanyPayIndicatorID int
)

INSERT INTO @PayIndicatorCompanies
SELECT prcpi_CompanyPayIndicatorID
  FROM PRCompanyPayIndicator
       LEFT OUTER JOIN vPRPayIndicatorEligibleCompany ON prcpi_CompanyID = SubjectCompanyId
 WHERE prcpi_Current = 'Y'
   AND SubjectCompanyId IS NULL
   AND PRCompanyPayIndicator.prcpi_PayIndicator IS NOT NULL;

INSERT INTO PRCompanyPayIndicator (prcpi_CompanyID, prcpi_Current)
SELECT prcpi_CompanyID, 'Y'
  FROM PRCompanyPayIndicator
       LEFT OUTER JOIN vPRPayIndicatorEligibleCompany ON prcpi_CompanyID = SubjectCompanyId
 WHERE prcpi_Current = 'Y'
   AND SubjectCompanyId IS NULL
   AND PRCompanyPayIndicator.prcpi_PayIndicator IS NOT NULL;

UPDATE PRCompanyPayIndicator
   SET prcpi_Current = NULL
 WHERE prcpi_CompanyPayIndicatorID IN (SELECT CompanyPayIndicatorID FROM @PayIndicatorCompanies);
 Go