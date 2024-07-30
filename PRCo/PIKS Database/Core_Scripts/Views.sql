-- ********************* CREATE CUSTOM VIEWS **********************************
-- we need to refresh the accpac views for the new fields that have been added
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRCompanyID]'))
	DROP VIEW [dbo].[vPRCompanyID]
GO

CREATE VIEW [dbo].[vPRCompanyID] AS 
SELECT comp_CompanyID as CompanyID
  FROM Company WITH (NOLOCK)
Go

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRPersonPhone]'))
	DROP VIEW [dbo].[vPRPersonPhone]
GO
CREATE VIEW [dbo].[vPRPersonPhone] AS 
SELECT PhoneLink.*,
	   Phone.*,
       ISNULL(RTRIM(phon_countrycode)+ ' ','') + ISNULL('('+RTRIM(phon_areacode)+ ') ','') + ISNULL(RTRIM(phon_number),'') as phon_FullNumber,
	   ISNULL(CAST(Custom_captions.Capt_US as varchar(25)), '') as phon_TypeDisplay 
  FROM PhoneLink WITH (NOLOCK)
       INNER JOIN Phone WITH (NOLOCK) ON PLink_PhoneId = phon_PhoneId 
	   LEFT OUTER JOIN Custom_Captions ON plink_Type = Capt_Code
	                                   AND Capt_Family = 'Phon_TypePerson'
 WHERE PLink_EntityId = 13 
   AND phon_Deleted IS NULL 
   AND PLink_Deleted IS NULL
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRCompanyPhone]'))
	DROP VIEW [dbo].[vPRCompanyPhone]
GO
CREATE VIEW [dbo].[vPRCompanyPhone] AS 
SELECT PhoneLink.*,
	   Phone.*,
       ISNULL(RTRIM(phon_countrycode)+ ' ','') + ISNULL('('+RTRIM(phon_areacode)+ ') ','') + ISNULL(RTRIM(phon_number),'') as phon_FullNumber,
	   ISNULL(CAST(Custom_captions.Capt_US as varchar(25)), '') as phon_TypeDisplay  
  FROM PhoneLink WITH (NOLOCK) 
       INNER JOIN Phone WITH (NOLOCK) ON PLink_PhoneId = phon_PhoneId 
	   LEFT OUTER JOIN Custom_Captions ON plink_Type = Capt_Code
	                                   AND Capt_Family = 'Phon_TypeCompany'
 WHERE PLink_EntityId = 5 
   AND phon_Deleted IS NULL 
   AND PLink_Deleted IS NULL
Go

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRPersonEmail]'))
	DROP VIEW [dbo].[vPRPersonEmail]
GO
CREATE VIEW [dbo].[vPRPersonEmail] AS 
SELECT *
  FROM EmailLink WITH (NOLOCK)
       INNER JOIN Email WITH (NOLOCK) ON elink_emailID = emai_EmailID
 WHERE eLink_EntityId = 13 
   AND emai_Deleted IS NULL 
   AND elink_Deleted IS NULL

GO


DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPREmail AS 
SELECT *
  FROM EmailLink 
       INNER JOIN Email ON elink_emailID = emai_EmailID
 WHERE emai_Deleted IS NULL 
   AND elink_Deleted IS NULL'
exec usp_TravantCRM_CreateView 'vPREmail', @Script, null, 0, null, null, null, 'Email'
Go

DECLARE @Script varchar(max);

-- Add the vPRCompanyRating view so this gets removed with component uninstalls
SET @Script = 
'CREATE VIEW vPRCompanyRating AS 
SELECT *, prra_RatingLine = COALESCE(prcw_Name+'' '','''')+COALESCE(prin_Name,'''')+ COALESCE(prra_AssignedRatingNumerals,'''')+COALESCE('' ''+prpy_Name,'''') 
  FROM ( 
        SELECT comp_Name, prcw_Name, prin_Name, prin_Weight, prpy_Name, prpy_Weight, 
               prra.*, 
               ISNULL(prra_AssignedRatingNumerals, '''') prra_AssignedRatingNumerals
          FROM PRRating prra WITH (NOLOCK) 
               INNER JOIN Company WITH (NOLOCK) ON prra_CompanyId = comp_CompanyId AND comp_Deleted is null 
               LEFT OUTER JOIN PRCreditWorthRating WITH (NOLOCK) ON prra_CreditWorthId = prcw_CreditWorthRatingId 
               LEFT OUTER JOIN PRIntegrityRating WITH (NOLOCK) ON prra_IntegrityId = prin_IntegrityRatingId 
               LEFT OUTER JOIN PRPayRating WITH (NOLOCK) ON prra_PayRatingId = prpy_PayRatingId 
               LEFT OUTER JOIN (
					SELECT DISTINCT ST2.prra_RatingId, 
							(
								SELECT prrn_name  AS [text()]
									FROM PRRatingNumeralAssigned WITH (NOLOCK) 
										INNER JOIN PRRatingNumeral WITH (NOLOCK) ON pran_RatingNumeralId = prrn_RatingNumeralId
								WHERE ST2.prra_RatingId = pran_RatingId
								ORDER BY prrn_Order
								FOR XML PATH (''''), TYPE
							).value(''text()[1]'',''nvarchar(200)'') [prra_AssignedRatingNumerals]
					FROM PRRating ST2
					)	tblRatingNumbers ON prra.prra_RatingId = tblRatingNumbers.prra_RatingId
         WHERE prra_Deleted is null ) ATABLE'
exec usp_TravantCRM_CreateView 'vPRCompanyRating', @Script 

-- vPRCompanyExceptionQueue: returns the company-based Exception Queue recs
--'CREATE VIEW dbo.vPRCompanvSearchListCompanyyExceptionQueue AS 
SET @Script = 
'CREATE VIEW vPRCompanyExceptionQueue AS 
SELECT preq_ExceptionQueueId, preq_Date, preq_CompanyId, preq_Type, preq_DateClosed, preq_ClosedById,
       ResponderName = case 
			when prtr_TradeReportId is not null then ct.comp_Name 
			when praa_ARAgingId is not null then ca.comp_Name 
			else '''' end, 
	   prtr_TradeReportId, prtr_ResponderId, praa_ARAgingId, praa_CompanyId 
  FROM PRExceptionQueue WITH (NOLOCK)  
       LEFT OUTER JOIN PRTradeReport prtr WITH (NOLOCK) ON preq_TradeReportId = prtr_TradeReportId and preq_Type = ''TES'' 
       LEFT OUTER JOIN PRARAgingDetail praad WITH (NOLOCK) ON preq_TradeReportId = praad_ARAgingDetailId and preq_Type = ''AR'' 
       LEFT OUTER JOIN PRARAging praa WITH (NOLOCK) ON praa_ARAgingId  = praad_ARAgingId 
       LEFT OUTER JOIN Company ca WITH (NOLOCK) ON ca.comp_CompanyId = praa_CompanyId and ca.comp_Deleted is null 
       LEFT OUTER JOIN Company ct WITH (NOLOCK) ON ct.comp_CompanyId = prtr_ResponderId and ct.comp_Deleted is null '
exec usp_TravantCRM_CreateView 'vPRCompanyExceptionQueue', @Script, null, 0, null, null, null, 'PRExceptionQueue'  

--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW PRService AS 
SELECT soh.SalesOrderNo,
       sod.LineKey,
       sod.LineSeqNo,
       prse_HQID = comp_PRHQId,
       prse_CompanyID = CAST(soh.CustomerNo AS INT),
       prse_BillToCompanyID = CAST(CASE WHEN soh.BillToCustomerNo = '''' THEN soh.CustomerNo ELSE soh.BillToCustomerNo END AS INT),
       prse_Primary =  CASE WHEN cii.Category2 = ''Primary'' THEN ''Y'' ELSE NULL END,
       prse_ServiceCode = sod.ItemCode,
	   sod.ItemCodeDesc,
       cii.ProductLine,	
       cii.Category2,   
       prse_NextAnniversaryDate = CAST(CAST(CASE WHEN MONTH(GETDATE()) >  CAST(soh.CycleCode AS INT) THEN YEAR(GETDATE())+1 ELSE YEAR(GETDATE()) END AS VARCHAR(4)) + ''-'' + soh.CycleCode + ''-01'' As DateTime),
       BillingMonth = soh.CycleCode, 
       prse_DiscountPct = sod.LineDiscountPercent,
       sod.QuantityOrdered,
	   sod.ExtensionAmt,
	   CASE WHEN sod.SalesKitLineKey <> '''' AND ExtensionAmt = 0 AND cii.Category2 <> ''Primary'' THEN ''Y'' ELSE ''N'' END As SalesKitItem,
	   CASE WHEN sod.SalesKitLineKey <> '''' AND ExtensionAmt = 0 AND cii.Category2 <> ''Primary'' THEN '' - '' + sod.ItemCodeDesc ELSE sod.ItemCodeDesc END As ItemCodeDescExt,
       prse_CreatedDate = soh.OrderDate,
       prse_CreatedBy = c_c_usr.User_UserId,
       prse_UpdatedDate = soh.DateUpdated,
       prse_UpdatedBy = c_u_usr.User_UserId,
	   soh.TaxSchedule, 
	   sod.TaxClass, 
	   stcd.TaxRate
  FROM MAS_PRC.dbo.SO_SalesOrderDetail sod WITH (NOLOCK)
       INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader soh WITH (NOLOCK) ON soh.SalesOrderNo = sod.SalesOrderNo
       INNER JOIN MAS_PRC.dbo.CI_Item cii ON sod.ItemCode = cii.ItemCode
       INNER JOIN Company WITH (NOLOCK) ON comp_CompanyId = CAST(soh.CustomerNo AS INT)
       LEFT OUTER JOIN MAS_SYSTEM.dbo.SY_User m_c_usr WITH (NOLOCK) ON soh.UserCreatedKey = m_c_usr.UserKey
       LEFT OUTER JOIN Users c_c_usr WITH (NOLOCK) ON m_c_usr.UserLogon = c_c_usr.User_Logon
       LEFT OUTER JOIN MAS_SYSTEM.dbo.SY_User m_u_usr WITH (NOLOCK) ON soh.UserCreatedKey = m_u_usr.UserKey
       LEFT OUTER JOIN Users c_u_usr WITH (NOLOCK) ON m_U_usr.UserLogon = c_u_usr.User_Logon
	   INNER JOIN MAS_System.dbo.SY_SalesTaxCodeDetail stcd ON soh.TaxSchedule = stcd.TaxCode
	                                                    AND sod.TaxClass = stcd.TaxClass
 WHERE soh.OrderType = ''R''
   AND CycleCode <> ''99'''
EXEC usp_TravantCRM_CreateView 'PRService', @Script


--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW vPRPrimaryServiceFast AS 
SELECT soh.SalesOrderNo,
       prse_CompanyID = CAST(soh.CustomerNo AS INT),
       prse_ServiceCode = sod.ItemCode,
	   sod.ItemCodeDesc
  FROM MAS_PRC.dbo.SO_SalesOrderDetail sod WITH (NOLOCK)
       INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader soh WITH (NOLOCK) ON soh.SalesOrderNo = sod.SalesOrderNo
       INNER JOIN MAS_PRC.dbo.CI_Item cii ON sod.ItemCode = cii.ItemCode
 WHERE soh.OrderType = ''R''
   AND CycleCode <> ''99''
   AND cii.Category2 =''Primary'''
EXEC usp_TravantCRM_CreateView 'vPRPrimaryServiceFast', @Script

-- vPRCompany view performs all the denormalization on Company
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRCompany AS 
SELECT company.*, prra_RatingLine, prcse_FullName,
       prci_City, prst_State,
       prbs_BBScore, capt_ListingStatusDesc = cast(capt_US as varchar(100))
  FROM Company WITH (NOLOCK)   
       INNER JOIN PRCompanySearch WITH (NOLOCK) ON comp_CompanyID = prcse_CompanyID
       LEFT OUTER JOIN vPRCurrentRating ON comp_CompanyId = prra_CompanyId 
       LEFT OUTER JOIN PRBBScore WITH (NOLOCK) ON comp_CompanyId = prbs_CompanyId And prbs_Current = ''Y'' 
       LEFT OUTER JOIN PRCity WITH (NOLOCK) ON comp_PRListingCityID = prci_CityId 
       LEFT OUTER JOIN PRState WITH (NOLOCK) ON prci_StateId = prst_StateId 
       JOIN custom_captions WITH (NOLOCK) ON comp_PRListingStatus = capt_code and capt_family = ''comp_PRListingStatus'' '
exec usp_TravantCRM_CreateView 'vPRCompany', @Script, null, 0, null, null, null, 'Company'          


-- Add the vPRLocation view so this gets removed with component uninstalls
--
-- NOTE:  The original view referenced foriegn keys instead of primary keys
--        (i.e. prci_StateID instead of prst_StateID).  This causes problems
--        so the primary keys were added as well.  We should remove the
--        foriegn keys at some point (I'm too busy at the moment). 
--        - CHW  10/25/06
--   - 11/10/2006- RAO Completely "remastered" for using the indedxed view
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRLocation WITH SCHEMABINDING 
AS 
SELECT prci_CityId, prci_StateId, prci_City, prci_Deleted, prci_RatingTerritory, 
        prci_RatingUserId, prci_SalesTerritory, prci_InsideSalesRepId, 
        prci_FieldSalesRepId, prci_ListingSpecialistId, prci_CustomerServiceId, 
        prst_StateId, prst_CountryId, prst_State, prst_Abbreviation, prst_Deleted, prst_BookOrder, 
        prcn_CountryId, prcn_Country, prcn_IATACode, prcn_Deleted, prcn_BookOrder, 
        prci_TimezoneOffset, prci_Timezone, prci_DST, 
        prci_City + '', '' + 
			case when prst_CountryId in (1, 2, 3) then prst_Abbreviation + '', '' + prcn_Country 
				else prcn_Country 
			end as CityStateCountry, 
		prci_City + '', '' +  
			case when prst_CountryId in (1, 2) then prst_Abbreviation 
				when prst_CountryId = 3 then prst_Abbreviation + '', '' + prcn_Country 
				else prcn_Country 
			end as CityStateCountryShort, 
		prcn_Country + '' '' + prst_Abbreviation + '' '' + prci_City AS CountryStAbbrCity,
		prcn_CountryCode,
		prci_LumberRatingUserId, prci_LumberInsideSalesRepId, prci_LumberFieldSalesRepId, 
		prci_LumberListingSpecialistId, prci_LumberCustomerServiceId
   FROM dbo.PRCity WITH (NOLOCK) 
        INNER JOIN dbo.PRState WITH (NOLOCK) ON prst_StateId = prci_StateId 
        INNER JOIN dbo.PRCountry WITH (NOLOCK) ON prcn_CountryId = prst_CountryId '
EXEC usp_TravantCRM_CreateView 'vPRLocation', @Script, null, 0, 'prci_CityId', 'CityStateCountry', null, 'PRCity'           
                                                

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRCompanyLocation WITH SCHEMABINDING AS  ' +
'Select ' +
	'Comp_CompanyId, Comp_Name, Comp_PRType, comp_PRListingStatus, comp_PRIndustryType, ' + 
	'prci_CityId, prci_StateId, prci_City, prci_Deleted, prci_RatingTerritory, ' +
	'prci_RatingUserId, prci_SalesTerritory, prci_InsideSalesRepId, ' +
	'prci_FieldSalesRepId, prci_ListingSpecialistId, prci_CustomerServiceId, ' +
	'prst_StateId, prst_CountryId, prst_State, prst_Abbreviation, prst_Deleted, ' +
	'prcn_CountryId, prcn_Country, prcn_IATACode, prcn_Deleted, ' +
	'prci_City + '', '' + ' +  
	'case when prst_CountryId in (1, 2, 3) then prst_Abbreviation + '', '' + prcn_Country ' +
		 ' else prcn_Country ' +
	'end as CityStateCountry, ' +   
	'prci_City + '', '' + ' +  
	'case when prst_CountryId in (1, 2) then prst_Abbreviation ' +
		 'when prst_CountryId = 3 then prst_Abbreviation + '', '' + prcn_Country ' +
		 'else prcn_Country ' +
	'end as CityStateCountryShort, ' + 
    'prci_Timezone, prci_DST, prci_TimezoneOffset ' +
'from dbo.Company WITH (NOLOCK) ' +
'INNER JOIN dbo.PRCity WITH (NOLOCK) ON prci_CityId = comp_PRListingCityId ' +
'INNER JOIN dbo.PRState WITH (NOLOCK) ON prst_StateId = prci_StateId ' +
'INNER JOIN dbo.PRCountry WITH (NOLOCK) ON prcn_CountryId = prst_CountryId'
exec usp_TravantCRM_CreateView 'vPRCompanyLocation', @Script, null, 0, null, null, null, 'Company'           

-- ***** PRPerson
-- ------> UPDATE VIEWS
--vListPerson
SET @Script = 
'CREATE VIEW vPRListPerson AS 
SELECT dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix)  AS Pers_FullName, 
	   Coalesce(RTRIM(pers_PhoneCountryCode) + '' '', '''') + Coalesce(RTRIM(pers_PhoneAreaCode)+ '' '', '''') + ISNULL(RTRIM(Pers_PhoneNumber), '''') AS Pers_PhoneFullNumber, 
	   Pers_CompanyId = peli_CompanyId, 
	   Pers_PersonId,Pers_CreatedDate,Pers_UpdatedBy,Pers_UpdatedDate,Pers_TimeStamp,Pers_Deleted, 
	   Pers_LibraryDir,Pers_SegmentID,Pers_ChannelID,Pers_UploadDate,pers_SecTerr,Pers_WorkflowId,pers_PRYearBorn, 
	   pers_PRDeathDate,pers_PRLanguageSpoken,pers_PRPaternalLastName,pers_PRMaternalLastName,pers_PRNickname1, 
	   pers_PRNickname2,pers_PRMaidenName,pers_PRIndustryStartDate,pers_PRNotes, 
	   peli_PRAUSReceiveMethod,peli_PRAUSChangePreference,Pers_PrimaryAddressId, 
	   Pers_PrimaryUserId,Pers_Salutation,Pers_FirstName,Pers_LastName,Pers_MiddleName,Pers_Suffix,Pers_Gender, 
	   Pers_Title,Pers_TitleCode,Pers_Department,Pers_Status,Pers_Source,Pers_Territory,Pers_WebSite,Pers_MailRestriction, 
	   Pers_PhoneCountryCode,Pers_PhoneAreaCode,Pers_PhoneNumber,Pers_EmailAddress,Pers_FaxCountryCode,Pers_FaxAreaCode, 
	   Pers_FaxNumber,Pers_CreatedBy,
	   peli_PersonLinkId, peli_PRTitleCode, peli_PRStartDate, peli_PREndDate, peli_PRStatus, peli_PRRole, 
	   peli_Companyid, 
	   peli_personid, 
	   peli_WebStatus, 
	   peli_PRBRPublish, 
	   peli_PREBBPublish, peli_PRUseServiceUnits, 
	   comp_CompanyId, comp_PRListingStatus,
	   comp_name 
  FROM vPersonPE WITH (NOLOCK) 
	   LEFT OUTER JOIN Person_Link WITH (NOLOCK) ON Pers_PersonId = PeLi_PersonId 
	   LEFT OUTER JOIN Company WITH (NOLOCK) ON peli_CompanyId = Company.Comp_CompanyId 
 WHERE Pers_Deleted IS NULL
   AND PeLi_Deleted IS NULL'
exec usp_TravantCRM_CreateView 'vPRListPerson', @Script 


/*  ** This view overrides a native accpac view 
    This view is used specifically for the searching and result set of companies.
    The returned rows are specific to what needs to be filtered and displayed;

    This view is the original vSearchListCompany view;
*/
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vSearchListCompany2 AS 
SELECT comp_companyid, comp_PRHQId,  comp_PRIndustryType, comp_CompanyIdDisplay = cast(comp_companyid as varchar(10)), 
       comp_name, prcse_namealphaonly, comp_PRUnconfirmed, 
       comp_PRServicesThroughCompanyId, comp_prtype, comp_PRListingStatus, prci_CityId, prst_StateId, prcn_CountryId, comp_PRListingCityId, 
       comp_ListingCityStateCountry = CityStateCountry, 
       comp_StatusDisplay = dbo.ufn_GetCustomCaptionValue(''comp_PRListingStatus'', comp_PRListingStatus, ''en-us''), 
       comp_TypeDisplay = comp_PRtype, comp_UpdatedDate,
	   Comp_Secterr, Comp_CreatedBy, Comp_PrimaryUserId, Comp_ChannelId, Comp_PrimaryPersonId, NULL as Comp_PhoneFullNumber,
	   Acc_AccountId, Acc_CreatedBy, Acc_ChannelId, Acc_PrimaryUserId, Acc_Secterr,
	   Pers_FirstName, Pers_LastName, Pers_Secterr, Pers_CreatedBy, Pers_PrimaryUserId, Pers_ChannelId,
	   comp_PRLocalSource,
	   prse_ServiceCode
  FROM Company WITH (NOLOCK) 
       INNER JOIN PRCompanySearch WITH (NOLOCK) ON comp_companyid = prcse_CompanyId 
       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
	   LEFT JOIN Account WITH (NOLOCK)  ON Comp_PrimaryAccountId = Acc_AccountId 
	   LEFT JOIN Person WITH (NOLOCK)  ON Comp_PrimaryPersonId = Pers_PersonId 
	   LEFT OUTER JOIN PRService WITH(NOLOCK) ON prse_CompanyID = comp_Companyid AND prse_Primary=''Y''
  WHERE comp_Deleted IS NULL '
exec usp_TravantCRM_CreateView 'vSearchListCompany2', @Script, null, 0, null, null, null, 'Company'

/*  ** This view overrides a native accpac view 
    This view is used specifically for the searching and result set of companies.
    The returned rows are specific to what needs to be filtered and displayed;
*/
SET @Script = 
'CREATE VIEW vSearchListCompany AS 
SELECT * 
  FROM vSearchListCompany2 
 WHERE comp_PRUnconfirmed IS NULL 
   AND comp_PRLocalSource IS NULL'
exec usp_TravantCRM_CreateView 'vSearchListCompany', @Script, null, 0, null, null, null, 'Company'

/*  ** This view overrides a native accpac view 
    This change may affect core accpac functionality but is required for linking multiple companies
    to a person. This does not return all the fields returned by the original view
*/
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vSearchListPerson AS 
SELECT dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix, 1)  AS Pers_FullName,  
       dbo.ufn_FormatPhone(pphone.phon_CountryCode, pphone.phon_AreaCode, pphone.phon_Number, pphone.phon_PRExtension) AS Pers_PhoneFullNumber, 
       dbo.ufn_FormatPhone(pfax.phon_CountryCode, pfax.phon_AreaCode, pfax.phon_Number, pfax.phon_PRExtension) AS Pers_FaxFullNumber, 
       comp_Name, comp_companyid, peli_CompanyId AS pers_companyid, 
       Pers_PersonId,Pers_PrimaryAddressId,Pers_PrimaryUserId,Pers_Salutation,
	   Pers_FirstName,Pers_LastName,
	   pers_FirstNameAlphaOnly,
       pers_LastNameAlphaOnly, 
	   Pers_MiddleName,Pers_Suffix,Pers_Gender,Pers_Title,Pers_TitleCode,Pers_Department,Pers_Status,
       Pers_Source,Pers_Territory,Pers_WebSite,Pers_MailRestriction, pers_PRUnconfirmed, 
       RTRIM(Emai_EmailAddress) AS Pers_EmailAddress, 
       Pers_CreatedBy,
       Pers_CreatedDate,Pers_UpdatedBy,Pers_UpdatedDate,Pers_TimeStamp,Pers_Deleted,Pers_LibraryDir,Pers_SegmentID,
       Pers_ChannelID,Pers_UploadDate,pers_SecTerr,Pers_WorkflowId,pers_PRYearBorn,pers_PRDeathDate,
       pers_PRLanguageSpoken,pers_PRPaternalLastName,pers_PRMaternalLastName,pers_PRNickname1,pers_PRNickname2,
       pers_PRMaidenName,pers_PRIndustryStartDate,pers_PRNotes,
       peli_PRAUSReceiveMethod,peli_PRAUSChangePreference,peli_PRUseServiceUnits, Pers_AccountId,
	   comp_PRIndustryType, CityStateCountryShort,
	   Comp_SecTerr, Comp_CreatedBy, Comp_ChannelId, Comp_PrimaryUserId,
	   pphone.phon_CountryCode as pers_PhoneCountryCode,
	   pphone.phon_AreaCode as pers_PhoneAreaCode,
	   pphone.phon_Number as pers_PhoneNumber,
	   peli_PRStatus
  FROM Person WITH (NOLOCK) 
       LEFT OUTER JOIN person_link WITH (NOLOCK) ON Peli_PersonId = Pers_PersonId 
       LEFT OUTER JOIN company WITH (NOLOCK) ON Peli_CompanyId = comp_CompanyId 
	   LEFT OUTER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	   LEFT OUTER JOIN vPRPersonEmail WITH (NOLOCK) ON peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID  AND ELink_Type = ''E'' AND emai_PRPreferredPublished=''Y'' 
	   LEFT OUTER JOIN vPRPersonPhone pfax WITH (NOLOCK) ON peli_PersonID = pfax.plink_RecordID AND peli_CompanyID = pfax.phon_CompanyID AND pfax.phon_PRIsFax = ''Y'' AND pfax.phon_PRPreferredPublished = ''Y''
	   LEFT OUTER JOIN vPRPersonPhone pphone WITH (NOLOCK) ON peli_PersonID = pphone.plink_RecordID AND peli_CompanyID = pphone.phon_CompanyID AND pphone.phon_PRIsPhone = ''Y'' AND pphone.phon_PRPreferredPublished = ''Y''
 WHERE Pers_Deleted IS NULL 
   AND pers_PRLocalSource IS NULL'
exec usp_TravantCRM_CreateView 'vSearchListPerson', @Script, null, 0, null, null, null, 'Person' 

/*
SET @Script = 
'CREATE VIEW dbo.vPRPersonDefaultInfo AS 
SELECT pers_personid, Addr_Address1, CityStateZip = RTRIM(addr_City) + RTRIM(Coalesce('', '' + addr_State,'''')) + RTRIM(Coalesce('' ''+addr_PostCode, '''')), 
       emai_emailaddress, phone = dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) 
  FROM Person WITH (NOLOCK) 
       LEFT OUTER JOIN Address_Link adli WITH (NOLOCK) on pers_PersonId = adli_PersonId and adli_PRDefaultMailing = ''Y'' 
       LEFT OUTER JOIN Address addr WITH (NOLOCK) on adli_AddressId = Addr_AddressId 
       LEFT OUTER JOIN Email WITH (NOLOCK) on pers_PersonId = emai_PersonId and emai_Type = ''E'' and emai_PRPreferredInternal = ''Y'' 
       LEFT OUTER JOIN Phone WITH (NOLOCK) on pers_PersonId = phon_PersonId and phon_Type != ''F'' and phon_Default = ''Y'''
exec usp_TravantCRM_CreateView 'vPRPersonDefaultInfo ', @Script 
*/

-- Create a view exclusively for the Company branches in the accpac listing
SET @Script = 
'CREATE VIEW vPRCompanyBranchForListing ' + 
'AS '+
'SELECT * FROM vSearchListCompany '+
'WHERE comp_PRType = ''B'' ';
exec usp_TravantCRM_CreateView 'vPRCompanyBranchForListing', @Script, null, 0, null, null, null, 'Company'  

-- Create a view to retrieve the required information to search for and list Credit Sheet information
-- on any of the listing pages
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRCreditSheet ' + 
'AS '+
'SELECT prcs.*, '+
'       comp_Name, comp_CompanyId, comp_PRType, comp_PRListingStatus, comp_PRIndustryType, '+
'       prci_City, prst_State, dbo.ufn_GetPRCoSpecialistUserId(comp_CompanyId, 3) As prci_ListingSpecialistId, '+
'       appover.user_logon as ApprovedBy, ls.user_logon as ListingSpecialist ' +
'  FROM PRCreditSheet prcs WITH (NOLOCK) '+
'       INNER JOIN vPRCompanyLocation ON comp_CompanyId = prcs_CompanyId ' +
'       LEFT OUTER JOIN Users appover WITH (NOLOCK) on prcs_ApproverID = appover.user_UserID ' +
'       LEFT OUTER JOIN Users ls WITH (NOLOCK) on dbo.ufn_GetPRCoSpecialistUserId(comp_CompanyId, 3) = ls.user_UserID'
exec usp_TravantCRM_CreateView 'vPRCreditSheet', @Script, null, 0, null, null, null, 'PRCreditSheet'  

-- ***** PRGeneral Views
-- Add the vPRPhone view
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRPhone AS 
SELECT ISNULL(rtrim(phon_countrycode)+ '' '','''') + ISNULL(''(''+rtrim(phon_areacode)+ '') '','''') + ISNULL(rtrim(phon_number),'''') as phon_FullNumber, 
       Phon_PhoneId,Phon_CountryCode,Phon_AreaCode,Phon_Number,phon_Default,phon_PRDescription,phon_PRExtension,phon_PRInternational,phon_PRCityCode,phon_PRPublish,phon_PRDisconnected,phon_PRSequence,phon_PRReplicatedFromId,phon_PhoneMatch,phon_PRPreferredPublished,phon_PRPreferredInternal,phon_PRIsPhone,phon_PRIsFax,  
	   CASE PLink_EntityId WHEN 5 THEN comp_CompanyId ELSE phon_CompanyID END as phon_CompanyID,
	   CASE PLink_EntityId WHEN 13 THEN pers_PersonId ELSE NULL END as phon_PersonID,
	   pLink_Type as phon_Type,
	   pLink_Type,
	   plink_RecordID,
	   plink_EntityID,
       ISNULL(CAST(Custom_captions.Capt_US as varchar), '''') as phon_TypeDisplay 
  FROM PhoneLink WITH (NOLOCK)
       INNER JOIN Phone WITH (NOLOCK) ON PLink_PhoneId = phon_PhoneId 
       LEFT OUTER JOIN Company WITH (NOLOCK) ON plink_RecordID = comp_CompanyId AND PLink_EntityId = 5 
       LEFT OUTER JOIN Person WITH (NOLOCK) ON plink_RecordID = pers_PersonId  AND PLink_EntityId = 13 
       LEFT OUTER JOIN Custom_Captions ON PLink_Type = Capt_Code 
                                      AND Capt_Family IN ( 
												CASE PLink_EntityId
												  WHEN 13 THEN ''Phon_TypePerson'' 
												  WHEN 5 THEN ''Phon_TypeCompany'' 
												  ELSE ''Phon_TypeCompany'' + '','' +  ''Phon_TypePerson''
												END) 
 WHERE Phon_Deleted IS NULL '      
exec usp_TravantCRM_CreateView 'vPRPhone', @Script, null, 0, null, null, null, 'Phone'  

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRAddress AS 
SELECT ISNULL(RTrim(Addr_Address1)+''<br/>'', '''') + ISNULL(RTrim(Addr_Address2)+''<br/>'', '''') + ISNULL(RTrim(Addr_Address3)+''<br/>'', '''') + ISNULL(RTrim(Addr_Address4)+''<br/>'', '''')  + ISNULL(RTrim(Addr_Address5), '''') AS Addr_Street,
       address.*, prci_City, prci_CityId, prst_State, prst_StateId, prst_Abbreviation, prcn_CountryId, prcn_Country, 
       adli_AddressLinkId, adli_CompanyId, adli_PersonId, adli_Type, 
       adli_PRDefaultMailing, adli_PRDefaultTax,
       ISNULL(cast(Custom_captions.Capt_US as varchar), '''') as adli_TypeDisplay, 
       CityStateCountryShort,
	   Adli_AccountID
  FROM Address WITH (NOLOCK) 
       INNER JOIN Address_Link WITH (NOLOCK) ON addr_AddressId = adli_AddressId  
       LEFT OUTER JOIN vPRLocation ON addr_PRCityId = prci_CityId 
       LEFT OUTER JOIN Company WITH (NOLOCK) ON adli_CompanyId = comp_CompanyId  
       LEFT OUTER JOIN Person WITH (NOLOCK) ON adli_PersonId = pers_PersonId  
       LEFT OUTER JOIN Custom_Captions ON adli_Type = Capt_Code  
					   AND Capt_Family = 
					   CASE 
						 WHEN adli_CompanyId is not null THEN ''adli_TypeCompany'' 
						 WHEN adli_PersonId is not null THEN ''adli_TypePerson'' 
						 ELSE ''adli_Type'' 
					   END '
EXEC usp_TravantCRM_CreateView 'vPRAddress', @Script 

SET @Script = 
'CREATE VIEW vListingAddress AS 
SELECT adli.adli_CompanyId,adli.adli_PersonId,addr_Address1,addr_Address2,addr_Address3,addr_Address4 as Address4, 
       addr_PRCityId, prci_City,prst_State,addr_PostCode,adli.adli_Type 
  FROM Address_Link adli WITH (NOLOCK)
       INNER JOIN vPRAddress ON AdLi_AddressId = Addr_AddressId'
exec usp_TravantCRM_CreateView 'vListingAddress', @Script 


SET @Script = 
'CREATE VIEW dbo.vListingPhone AS 
SELECT phon_CompanyId, phon_PersonId, phon_PRPublish, phon_type, phon_FullNumber, phon_TypeDisplay, 
       ISNULL(rtrim(phon_countrycode),'''') + ISNULL('' ''+rtrim(phon_areacode),'''') + ISNULL('' ''+rtrim(phon_number),'''') as PhoneValue 
  FROM vPRPhone'
EXEC usp_TravantCRM_CreateView 'vListingPhone', @Script 


-- Add the vAddressPerson view so this gets removed with component uninstalls
SET @Script = 
'CREATE VIEW vAddressPerson ' + 
'AS '+
'SELECT  DISTINCT '+
'vPRAddress.* '+
'FROM vPRAddress   '+
'WHERE  '+
'adli_PersonId is not null  '+ 
'and adli_CompanyId is null   '+
'and addr_Deleted IS NULL   '

exec usp_TravantCRM_CreateView 'vAddressPerson', @Script 



-- vPRWebUserAUSCompanyList replaces vPRAUSCompanyList
-- vPRWebUserAUSCompanyList - retrieves the companies (and city, state) associated with PRAUS records
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRWebUserAUSCompanyList
AS 
SELECT [PeLi_PersonID] 
      ,[prwu_WebUserID] 
      ,[prwucl_WebUserListID] 
      ,[prwuld_WebUserListDetailID] 
      ,[prwucl_CompanyID] 
      ,[prwucl_TypeCode] 
      ,[prwuld_AssociatedID] As AUSMonitoredCompanyId 
	  ,[prwuld_AssociatedID] As comp_CompanyID 
      ,[prwuld_AssociatedType] 
      ,[comp_Name] As "AUSMonitoredCompanyName" 
      ,[prci_City] AS "AUSMonitoredCity" 
      ,[prst_State] AS "AUSMonitoredState" 
      ,[prcn_Country] AS "AUSMonitoredCountry" 
  FROM Person_Link WITH (NOLOCK) 
       INNER JOIN PRWebUser WITH (NOLOCK) On (prwu_PersonLinkID = PeLi_PersonLinkID) 
       INNER JOIN PRWebUserList WITH (NOLOCK) On (prwucl_WebUserID = prwu_WebUserID) 
       INNER JOIN PRWebUserListDetail WITH (NOLOCK) On (prwuld_WebUserListID = prwucl_WebUserListID) 
       INNER JOIN Company WITH (NOLOCK) On comp_CompanyID = prwuld_AssociatedID 
       LEFT OUTER JOIN PRCity WITH (NOLOCK) On comp_PRListingCityId = prci_CityId 
       LEFT OUTER JOIN PRState WITH (NOLOCK) On prci_StateId = prst_StateId 
       LEFT OUTER JOIN PRCountry WITH (NOLOCK) On prst_CountryId = prcn_CountryId 
 WHERE prwucl_TypeCode = ''AUS'' 
   AND prwuld_AssociatedType = ''C'' '
exec usp_TravantCRM_CreateView 'vPRWebUserAUSCompanyList', @Script 

/* 
    This view is specific to the fields needed for the company personnel listing.
*/
-- DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRPersonnelListing AS 
SELECT dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix, 1) AS Pers_FullName, 
       pers_personid, Pers_CompanyId = peli_CompanyId, Pers_FirstName,Pers_LastName, pers_PRLanguageSpoken, 
       peli_PersonLinkId, peli_PRTitle, peli_PRTitleCode, peli_PRStartDate, peli_PREndDate, peli_PRStatus, 
       peli_PRRole, peli_PROwnershipRole, 
       peli_Companyid, 
       peli_personid, 
       peli_WebStatus, 
       peli_PRBRPublish, 
       peli_PREBBPublish, 
       RTRIM(emai_EmailAddress) as emai_EmailAddress, 
       emai_PRPublish, 
       peli_PRPctOwned, 
       CASE WHEN CAST(ISNULL(prwu_AccessLevel, 0) as int) >= 100 THEN CASE prod_ProductFamilyID WHEN 14 THEN ''Y - Trial'' ELSE ''Y'' END ELSE ''N'' END As HasLicense, 
       prwu_LastLoginDateTime,
	   prwu_WebUserID,
       dbo.ufn_GetLocalSourceAccessList(prwu_WebUserID, 0) as LocalSourceDataAccess,
	   dbo.ufn_FormatPhone(pp.phon_CountryCode, pp.phon_AreaCode, pp.phon_Number, null) As [Cell]
  FROM Person WITH (NOLOCK) 
       INNER JOIN Person_Link WITH (NOLOCK) ON Pers_PersonId = PeLi_PersonId 
	   INNER JOIN Company WITH (NOLOCK) ON PeLi_CompanyID = comp_CompanyID
	   LEFT OUTER JOIN vPRPersonEmail WITH (NOLOCK) ON peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID AND ELink_Type = ''E''
       LEFT OUTER JOIN PRWebUser WITH (NOLOCK)  ON peli_PersonLinkID = prwu_PersonLinkID
       LEFT OUTER JOIN NewProduct ON prod_code = prwu_ServiceCode AND prod_Productfamilyid IN (6,14)
	   LEFT OUTER JOIN vPRPersonPhone AS pp WITH (NOLOCK) ON peli_PersonID = pp.PLink_RecordID  AND pp.plink_Type=''C'' AND PeLi_CompanyID = phon_CompanyID AND pp.phon_PRPreferredPublished=''Y'''
exec usp_TravantCRM_CreateView 'vPRPersonnelListing', @Script, null, 0, null, null, null, 'Person'


-- ***** PRCompany
SET @Script = 
'CREATE VIEW vPRCompanyTerminalMarket AS '+
'SELECT prct.*, prtm.* '+
' FROM PRCompanyTerminalMarket prct '+
' LEFT OUTER JOIN PRTerminalMarket prtm WITH (NOLOCK) '+
' ON prct_TerminalMarketId = prtm_TerminalMarketId '+
' WHERE prct_Deleted is null and prtm_Deleted is null';
exec usp_TravantCRM_CreateView 'vPRCompanyTerminalMarket', @Script 


SET @Script = 
'CREATE VIEW vListingPRCompanyCommodity AS ' + 
'select OuterTable.*, ' +
'    prcca_ListingCol1 = Coalesce(sCommodity, sGroup, sCategory, ''''), ' +
'    prcca_ListingCol2 = Coalesce(sRefinement + '' '', '''') + Coalesce(sVariety + '' '', '''') + Coalesce(sVarietyGroup + '' '', ''''), ' +
'    prcx_Description, ' +
'    prcx_Description_ES ' +
'FROM (' +
'	select sCommodity = dbo.ufn_GetCommodityPathElement(prcm_PathNames, 3),' +
'		sCategory = dbo.ufn_GetCommodityPathElement(prcm_PathNames, 1),' +
'		sGroup = dbo.ufn_GetCommodityPathElement(prcm_PathNames, 2),' +
'		sVariety = dbo.ufn_GetCommodityPathElement(prcm_PathNames, 5),' +
'		sVarietyGroup = dbo.ufn_GetCommodityPathElement(prcm_PathNames, 4),' +
'		sRefinement = dbo.ufn_GetCommodityPathElement(prcm_PathNames, 6),' +
'		*' +
'	from ' +
'		(' +
'		Select prcca_CompanyCommodityAttributeId, prcca_CompanyId, prcca_CommodityId, prcca_Sequence,  ' +
'			prcca_Publish = case ' +
'			when prcca_Publish = ''Y'' then ''Y'' ' +
'			when prcca_PublishWithGM = ''Y'' then ''Y'' ' +
'			else '''' ' +
'			end, prcca_Deleted, prcca_PublishedDisplay, prcm_PathNames, ' +
'           prcca.prcca_AttributeID, attrb.prat_Name As AttributeName, prcca.prcca_GrowingMethodID, gm.prat_Name As GrowingMethod ' +
'		from PRCompanyCommodityAttribute prcca WITH (NOLOCK)  ' +
'		INNER JOIN PRCommodity prcm WITH (NOLOCK) ON prcca_CommodityId = prcm_CommodityId  ' +
'       LEFT OUTER JOIN PRAttribute AS attrb WITH (NOLOCK) ON prcca.prcca_AttributeID = attrb.prat_AttributeID ' +
'       LEFT OUTER JOIN PRAttribute AS gm WITH (NOLOCK) ON prcca.prcca_GrowingMethodID = gm.prat_AttributeID ' +
' ) ATable ' +
') OuterTable ' +
' LEFT OUTER JOIN PRCommodityTranslation ON prcca_PublishedDisplay = prcx_Abbreviation '
exec usp_TravantCRM_CreateView 'vListingPRCompanyCommodity', @Script 



-- Add the vCompanyAddress view so this gets removed with component uninstalls
SET @Script = 
'CREATE VIEW vAddressCompany AS 
SELECT AdLi_CompanyID, AdLi_PersonId, Adli_AccountID, 
       adli_TypeDisplay = dbo.ufn_GetAddressTypeList(adli_AddressId, ''adli_TypeCompany'') ,
       Address.* 
  FROM Address WITH (NOLOCK)
       INNER JOIN (SELECT DISTINCT AdLi_CompanyID, AdLi_AddressId, AdLi_PersonID, Adli_AccountID 
	                 FROM Address_Link WITH (NOLOCK) 
				    WHERE AdLi_CompanyID IS NOT NULL 
					  AND AdLi_PersonID IS NULL 
					  AND AdLi_AccountID IS NULL 
  				      AND AdLi_Deleted IS NULL ) A ON Addr_AddressId = AdLi_AddressId'
exec usp_TravantCRM_CreateView 'vAddressCompany', @Script 

-- vPRCompanyClassification
SET @Script = 
'CREATE VIEW vPRCompanyClassification AS ' + 
'select cls.prcl_Abbreviation, CC.* ' + 
' from PRCompanyClassification CC ' + 
' JOIN PRClassification cls on prc2_ClassificationId = prcl_ClassificationId';
exec usp_TravantCRM_CreateView 'vPRCompanyClassification', @Script 

-- vCompanyInvestigationMethod
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vCompanyInvestigationMethod AS SELECT comp_companyId, 
       comp_PRInvestigationMethodGroup,  
       newGroup = CASE
                  WHEN comp_PRType != ''H'' THEN NULL
                  WHEN companyId IS NOT NULL THEN ''A'' 
                  ELSE ''B'' 
                  END
FROM Company WITH (NOLOCK)
	LEFT OUTER JOIN  
	( 
		SELECT companyId = prc2_CompanyId 
		  FROM PRCompanyClassification WITH (NOLOCK)
		 WHERE prc2_ClassificationId in (180,230,300,330,340,350,590) --Dstr, Exp, J, R, Ret, Rg, Wg, TruckBkr
		UNION
		SELECT companyId = prtr_SubjectId
		  FROM PRTradeReport WITH (NOLOCK)
		 WHERE prtr_PayRatingId IS NOT NULL
		   AND prtr_PayRatingId > 0 
		   AND prtr_Date > DATEADD(MONTH, -24, GETDATE()) 
	  GROUP BY prtr_SubjectId 
		HAVING COUNT(1) >= 10
	) GROUPA_TABLE ON comp_companyId = companyid'
exec usp_TravantCRM_CreateView 'vCompanyInvestigationMethod', @Script 



SET @Script = 
'create view vPRCompanyRelationship as ' + 
'select '+
'prcr_Tier = case  '+
'    when (prcr_LastReportedDate > DateAdd(Month, -24, getDate()) '+
'          and convert(tinyint, prcr_Type) IN (1,2,4,9,10,11,12,13,14,15,16,17,18,19,20,21,22)) then  1 '+
'    when (prcr_LastReportedDate > DateAdd(Month, -60, getDate()) '+
'          and convert(tinyint, prcr_Type) IN (1,2,4,9,10,11,12,13,14,15,16,17,18,19,20,21,22)) then 2 '+
'    when (prcr_LastReportedDate < DateAdd(Month, -60, getDate()) '+ 
'          and convert(tinyint, prcr_Type) IN (1,2,4,9,10,11,12,13,14,15,16,17,18,19,20,21,22)) '+
'         OR '+
'         (prcr_LastReportedDate > DateAdd(Month, -36, getDate()) '+ 
'          and convert(tinyint, prcr_Type) IN (23, 24, 25, 26)) then 3 '+
'    else NULL '+
'end, '+
'* '+ 
'FROM PRCompanyRelationship WITH (NOLOCK) '
exec usp_TravantCRM_CreateView 'vPRCompanyRelationship', @Script 


-- Add the vPROwnershipByPerson view so this gets removed with component uninstalls
SET @Script = 
'CREATE VIEW vPROwnershipByPerson AS ' +
'SELECT pers_PersonId, peli_CompanyId, peli_PRPctOwned, peli_PRStatus, dbo.ufn_FormatPerson2(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickname1, pers_Suffix, 1) As PersonName, peli_PRTitle  ' +
'  FROM Person_Link WITH (NOLOCK) ' +
'       INNER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID ' +
' WHERE peli_PROwnershipRole NOT IN (''RCR'', ''RCN'')  ' +
'   AND peli_prstatus != 3 ';

exec usp_TravantCRM_CreateView 'vPROwnershipByPerson', @Script 

-- *****  PRRating VIEWS

-- This view is used by usp_AutoRemoveRatingNumerals to get a distinct list of 
-- companies that have rating numerals to remove.  This includes the CreditWorth 
-- value of (79)
SET @Script = 
'CREATE VIEW vPRCompaniesWithAutoRemoveNums AS 
  SELECT DISTINCT ''RN'' AS RemoveType, comp_CompanyId, comp_PRListingStatus 
     FROM PRRatingNumeralAssigned WITH (NOLOCK) 
          INNER JOIN PRRating WITH (NOLOCK) ON prra_ratingid = pran_ratingid and prra_Current = ''Y'' 
          INNER JOIN Company WITH (NOLOCK) ON prra_companyid = comp_companyid 
    WHERE comp_PRIndustryType <> ''L''
	  AND pran_RatingNumeralId in (SELECT prrn_RatingNumeralId FROM PRRatingNumeral where prrn_AutoRemove = ''Y'') 
	UNION 
  SELECT DISTINCT ''(79)'' AS RemoveType, comp_CompanyId, comp_PRListingStatus  
    FROM PRRating WITH (NOLOCK) 
         INNER JOIN Company WITH (NOLOCK) ON prra_companyid = comp_companyid 
   WHERE comp_PRIndustryType <> ''L''
     AND prra_Current = ''Y''
	 AND prra_CreditWorthId = 4'
EXEC usp_TravantCRM_CreateView 'vPRCompaniesWithAutoRemoveNums', @Script 


-- PRTradeReport Views
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRTradeReportOn AS 
SELECT prpy_TradeReportDescription, prin_TradeReportDescription,
       prtr_TradeReportId, prtr_Date, prtr_ResponderId, prtr_SubjectId, subject.comp_PRHQID, prtr_CreditTerms, prtr_Terms, 
       prtr_HighCredit, prtr_HighCredit as prtr_HighCreditL, prtr_Exception, prtr_DisputeInvolved, prtr_Duplicate, responder.comp_PRIndustryType,
	   CASE WHEN prtr_Comments IS NOT NULL THEN ''Y'' ELSE '''' END as HasComments,
	   responder.comp_PRIgnoreTES, prtr_ExcludeFromAnalysis
  FROM PRTradeReport prtr WITH (NOLOCK) 
       INNER JOIN Company subject WITH (NOLOCK) ON prtr_subjectid = subject.comp_CompanyID 
       INNER JOIN Company responder WITH (NOLOCK) ON prtr_responderid = responder.comp_CompanyID 
       LEFT OUTER JOIN PRIntegrityRating (NOLOCK) ON prtr_IntegrityId = prin_IntegrityRatingId 
       LEFT OUTER JOIN PRPayRating (NOLOCK) ON prtr_PayRatingId = prpy_PayRatingId ' 
exec usp_TravantCRM_CreateView 'vPRTradeReportOn', @Script 

SET @Script = 
'CREATE VIEW dbo.vPRTradeReportBy AS ' +
'SELECT prtr_Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(prtr_SubjectId,1), ' +
'prpy_TradeReportDescription, prin_TradeReportDescription, ' +
'prtr_TradeReportId, prtr_Date, prtr_ResponderId, prtr_SubjectId, prtr_CreditTerms, prtr_Terms, ' +
'prtr_HighCredit, prtr_HighCredit as prtr_HighCreditL, prtr_Exception, prtr_DisputeInvolved, prtr_Duplicate, prtr_ExcludeFromAnalysis  ' +
'from PRTradeReport prtr ' + 
'LEFT OUTER JOIN PRIntegrityRating ON prtr_IntegrityId = prin_IntegrityRatingId ' +
'LEFT OUTER JOIN PRPayRating ON prtr_PayRatingId = prpy_PayRatingId ' 
exec usp_TravantCRM_CreateView 'vPRTradeReportBy', @Script 


-- vPRARAgingDetailOn
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRARAgingDetailOn AS ' +
'select NULL AS _StartDate, NULL AS _EndDate, NULL AS _Exception, ' +
    'praa_ARAgingId, praad_ARAgingDetailId, praa_RunDate, praa_Date, ' +
    'praad_ReportingCompanyId, ' +
    'praad_ReportingCompanyName, ' +
    'praad_SubjectCompanyId, ' +
    'praad_CompanyName = subjCompany.comp_Name, ' +
    'praad_State = praad_FileStateName, ' +
    'praad_Amount0to29, ' +
    'praad_Amount30to44, ' +
    'praad_Amount45to60, ' +
    'praad_Amount61Plus, ' +
    'praad_TotalAmount = (praad_Amount0to29+praad_Amount30to44+praad_Amount45to60+praad_Amount61Plus), ' +
    'praad_Amount0to29Percent = case ' +
    'when praad_TotalAmount > 0 AND praad_Amount0to29 > 0 THEN 100*(praad_Amount0to29/praad_TotalAmount) ' +
        'else 0 ' +
      'end, ' +
    'praad_Amount30to44Percent = case ' +
    'when praad_TotalAmount > 0 AND praad_Amount30to44 > 0 THEN 100*(praad_Amount30to44/praad_TotalAmount) ' +
        'else 0 ' +
      'end, ' +
    'praad_Amount45to60Percent = case ' +
    'when praad_TotalAmount > 0 AND praad_Amount45to60 > 0 THEN 100*(praad_Amount45to60/praad_TotalAmount) ' +
        'else 0 ' +
      'end, ' +
    'praad_Amount61PlusPercent = case ' +
    'when praad_TotalAmount > 0 AND praad_Amount61Plus > 0 THEN 100*(praad_Amount61Plus/praad_TotalAmount) ' +
        'else 0 ' +
      'end, ' +
    'praad_AmountCurrent, ' +
    'praad_Amount1to30, ' +
    'praad_Amount31to60, ' +
    'praad_Amount61to90, ' +
    'praad_Amount91Plus, ' +
    'praad_TotalAmount2 = (praad_AmountCurrent + praad_Amount1to30+praad_Amount31to60+praad_Amount61to90+praad_Amount91Plus), ' +
    'praad_AmountCurrentPercent = case ' +
    'when praad_TotalAmount2 > 0 AND praad_AmountCurrent > 0 THEN 100*(praad_AmountCurrent/praad_TotalAmount2) ' +
        'else 0 ' +
      'end, ' +
    'praad_Amount1to30Percent = case ' +
    'when praad_TotalAmount2 > 0 AND praad_Amount1to30 > 0 THEN 100*(praad_Amount1to30/praad_TotalAmount2) ' +
        'else 0 ' +
      'end, ' +
    'praad_Amount31to60Percent = case ' +
    'when praad_TotalAmount2 > 0 AND praad_Amount31to60 > 0 THEN 100*(praad_Amount31to60/praad_TotalAmount2) ' +
        'else 0 ' +
      'end, ' +
    'praad_Amount61to90Percent = case ' +
    'when praad_TotalAmount2 > 0 AND praad_Amount61to90 > 0 THEN 100*(praad_Amount61to90/praad_TotalAmount2) ' +
        'else 0 ' +
      'end, ' +
    'praad_Amount91PlusPercent = case ' +
    'when praad_TotalAmount2 > 0 AND praad_Amount91Plus > 0 THEN 100*(praad_Amount91Plus/praad_TotalAmount2) ' +
        'else 0 ' +
      'end, ' +
    'Level1ClassificationValues = case ' +
          'when praad_ReportingCompanyId is not null then dbo.ufn_GetLevel1Classifications(praad_ReportingCompanyId,1) ' +
          'else '''' ' +
        'end, ' +
    'praad_Exception ' +
'FROM ' +
'(select praad_FileCompanyName, praad_FileStateName, praad_ARAgingDetailId, praad_exception, praa_ARAgingId, praa_RunDate, praa_Date, ' + 
           'praad_Amount0to29 = ISNULL(praad_Amount0to29,  0),' +
           'praad_Amount30to44 = ISNULL(praad_Amount30to44, 0),' +
           'praad_Amount45to60 = ISNULL(praad_Amount45to60, 0),' +
           'praad_Amount61Plus = ISNULL(praad_Amount61Plus, 0),' +

           'praad_AmountCurrent = ISNULL(praad_AmountCurrent,  0),' +
           'praad_Amount1to30 = ISNULL(praad_Amount1to30,  0),' +
           'praad_Amount31to60 = ISNULL(praad_Amount31to60, 0),' +
           'praad_Amount61to90 = ISNULL(praad_Amount61to90, 0),' +
           'praad_Amount91Plus = ISNULL(praad_Amount91Plus, 0),' +


           'praad_ReportingCompanyId = praa_CompanyId, ' +
           'praad_ReportingCompanyName = comp.comp_Name, ' +
           'praad_SubjectCompanyId = ' +
             'case ' + 
                'when praad_ManualCompanyId is not null then praad_ManualCompanyId ' +
                'else prar_PRCoCompanyId ' +
             'end, ' +
           'praad_TotalAmount = ISNULL(praad_Amount0to29, 0) ' +
                            ' + ISNULL(praad_Amount30to44, 0) ' +
                            ' + ISNULL(praad_Amount45to60, 0) ' +
                            ' + ISNULL(praad_Amount61Plus, 0), ' +
           'praad_TotalAmount2 = ISNULL(praad_AmountCurrent, 0) ' +
                            ' + ISNULL(praad_Amount1to30, 0) ' +
                            ' + ISNULL(praad_Amount31to60, 0) ' +
                            ' + ISNULL(praad_Amount61to90, 0) ' +
						    ' + ISNULL(praad_Amount91Plus, 0) ' +
   'from PRARAgingDetail praad ' +
   'JOIN PRARAging praa ON praa_ARAgingId = praad_ARAgingId ' +
   'JOIN Company comp ON praa_CompanyId = comp.comp_CompanyId ' +
   'LEFT OUTER JOIN prartranslation ON praad_ARCustomerId = prar_CustomerNumber ' +
            	'AND prar_CompanyId = praa_CompanyId ' +
') ATable ' +
'LEFT OUTER JOIN company subjCompany ON praad_SubjectCompanyId = subjCompany.comp_CompanyId ' 
exec usp_TravantCRM_CreateView 'vPRARAgingDetailOn', @Script 


-- vPRARAgingDetailBy
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetailBy AS
SELECT 
       praa_ARAgingId, praa_RunDate, praa_Date, praa_ImportedDate, praa_ImportedByUserId, 
       praa_CompanyId = comp.comp_CompanyId,
       prar_PRCoCompanyId, prar_CustomerNumber, 
       praad_CompanyName = CASE 
         WHEN praad_ManualCompanyId IS NOT NULL THEN manual.comp_Name 
         WHEN prar_PRCoCompanyId IS NULL THEN praad_FileCompanyName 
         ELSE trancompany.comp_Name  
       END, 
       Level1ClassificationValues = CASE  
         WHEN praad_ManualCompanyId IS NOT NULL THEN dbo.ufn_GetLevel1Classifications(praad_ManualCompanyId,1) 
         WHEN prar_PRCoCompanyId IS NOT NULL THEN dbo.ufn_GetLevel1Classifications(prar_PRCoCompanyId,1)  
         ELSE ''''  
       END, 
       praad_LineTotal = (praad_Amount0to29 + praad_Amount30to44 + praad_Amount45to60 + praad_Amount61Plus), 
       praad_LinePercent = (praad_Amount0to29Percent + praad_Amount30to44Percent + praad_Amount45to60Percent + praad_Amount61PlusPercent), 
       praad_LineTotal2 = (praad_AmountCurrent + praad_Amount1to30 + praad_Amount31to60 + praad_Amount61to90 + praad_Amount91Plus), 
       praad_LinePercent2 = (praad_AmountCurrentPercent + praad_Amount1to30Percent + praad_Amount31to60Percent + praad_Amount61to90Percent + praad_Amount91PlusPercent), 
       BTable.* 
FROM  
( 
SELECT  
    praad_TotalAmount0to29Percent = case when praad_TotalAmount = 0 then 0 else 100*(praad_TotalAmount0to29/praad_TotalAmount) end, 
    praad_TotalAmount30to44Percent = case when praad_TotalAmount = 0 then 0 else 100*(praad_TotalAmount30to44/praad_TotalAmount) end, 
    praad_TotalAmount45to60Percent = case when praad_TotalAmount = 0 then 0 else 100*(praad_TotalAmount45to60/praad_TotalAmount) end, 
    praad_TotalAmount61PlusPercent = case when praad_TotalAmount = 0 then 0 else 100*(praad_TotalAmount61Plus/praad_TotalAmount) end, 
    praad_Amount0to29Percent = case when praad_TotalAmount = 0 then 0 else 100*(praad_Amount0to29/praad_TotalAmount) end, 
    praad_Amount30to44Percent = case when praad_TotalAmount = 0 then 0 else 100*(praad_Amount30to44/praad_TotalAmount) end, 
    praad_Amount45to60Percent = case when praad_TotalAmount = 0 then 0 else 100*(praad_Amount45to60/praad_TotalAmount) end, 
    praad_Amount61PlusPercent = case when praad_TotalAmount = 0 then 0 else 100*(praad_Amount61Plus/praad_TotalAmount) end, 
    praad_TotalAmountCurrentPercent = case when praad_TotalAmount2 = 0 then 0 else 100*(praad_TotalAmountCurrent/praad_TotalAmount2) end, 
    praad_TotalAmount1to30Percent = case when praad_TotalAmount2 = 0 then 0 else 100*(praad_TotalAmount1to30/praad_TotalAmount2) end, 
    praad_TotalAmount31to60Percent = case when praad_TotalAmount2 = 0 then 0 else 100*(praad_TotalAmount31to60/praad_TotalAmount2) end, 
    praad_TotalAmount61to90Percent = case when praad_TotalAmount2 = 0 then 0 else 100*(praad_TotalAmount61to90/praad_TotalAmount2) end, 
    praad_TotalAmount91PlusPercent = case when praad_TotalAmount2 = 0 then 0 else 100*(praad_TotalAmount91Plus/praad_TotalAmount2) end, 
    praad_AmountCurrentPercent = case when praad_TotalAmount2 = 0 then 0 else 100*(praad_AmountCurrent/praad_TotalAmount2) end, 
    praad_Amount1to30Percent = case when praad_TotalAmount2 = 0 then 0 else 100*(praad_Amount1to30/praad_TotalAmount2) end, 
    praad_Amount31to60Percent = case when praad_TotalAmount2 = 0 then 0 else 100*(praad_Amount31to60/praad_TotalAmount2) end, 
    praad_Amount61to90Percent = case when praad_TotalAmount2 = 0 then 0 else 100*(praad_Amount61to90/praad_TotalAmount2) end, 
    praad_Amount91PlusPercent = case when praad_TotalAmount2 = 0 then 0 else 100*(praad_Amount91Plus/praad_TotalAmount2) end, 
    *  
FROM  
  (SELECT  
		praad_TotalAmount = praad_TotalAmount0to29  
						  + praad_TotalAmount30to44 
						  + praad_TotalAmount45to60 
						  + praad_TotalAmount61Plus, 
		praad_TotalAmount0to29, praad_TotalAmount30to44, praad_TotalAmount45to60, praad_TotalAmount61Plus, 
		praad_ARAgingDetailId, praa_ARAgingDetailCount, praad.praad_ARAgingId, praad_ARCustomerId,  
		praad_FileCompanyName, praad_FileCityName, praad_FileStateName, praad_FileZipCode, 
		praad_Exception, praad_CreditTerms, praad_Deleted, praad_ManualCompanyId, 
		praad_Amount0to29 = ISNULL(praad_Amount0to29,0),  
		praad_Amount30to44 = ISNULL(praad_Amount30to44,0),  
		praad_Amount45to60 = ISNULL(praad_Amount45to60,0),  
		praad_Amount61Plus = ISNULL(praad_Amount61Plus,0),  
		praad_TotalAmount2 = praad_TotalAmountCurrent  
				  + praad_TotalAmount1to30 
				  + praad_TotalAmount31to60 
				  + praad_TotalAmount61to90 
				  + praad_TotalAmount91Plus, 
		praad_TotalAmountCurrent, praad_TotalAmount1to30, praad_TotalAmount31to60, praad_TotalAmount61to90, praad_TotalAmount91Plus, 
		praad_AmountCurrent = ISNULL(praad_AmountCurrent,  0),
		praad_Amount1to30 = ISNULL(praad_Amount1to30,  0),
		praad_Amount31to60 = ISNULL(praad_Amount31to60, 0),
		praad_Amount61to90 = ISNULL(praad_Amount61to90, 0),
		praad_Amount91Plus = ISNULL(praad_Amount91Plus, 0)
   FROM PRARAgingDetail praad WITH (NOLOCK)
		INNER JOIN ( 
			SELECT praad_ARAgingId, 
				   praa_ARAgingDetailCount = COUNT(1), 
				   praad_TotalAmount0to29 = ISNULL(SUM(praad_Amount0to29),0),  
				   praad_TotalAmount30to44 = ISNULL(SUM(praad_Amount30to44),0),  
				   praad_TotalAmount45to60 = ISNULL(SUM(praad_Amount45to60),0),  
				   praad_TotalAmount61Plus = ISNULL(SUM(praad_Amount61Plus),0), 
				   praad_TotalAmountCurrent = ISNULL(SUM(praad_AmountCurrent), 0),
				   praad_TotalAmount1to30 = ISNULL(SUM(praad_Amount1to30),  0),
				   praad_TotalAmount31to60 = ISNULL(SUM(praad_Amount31to60), 0),
				   praad_TotalAmount61to90 = ISNULL(SUM(praad_Amount61to90), 0),
				   praad_TotalAmount91Plus = ISNULL(SUM(praad_Amount91Plus), 0)
			  FROM PRARAgingDetail 
		  GROUP BY praad_ARAgingId 
				   ) sums ON praad.praad_ARAgingId = sums.praad_ARAgingId 
	) ATable 
) BTable 
 LEFT OUTER JOIN PRARAging praa WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
 LEFT OUTER JOIN Company comp WITH (NOLOCK) ON praa_CompanyId = comp.comp_CompanyId 
 LEFT OUTER JOIN Company manual WITH (NOLOCK) ON praad_ManualCompanyId = manual.comp_CompanyId 
 LEFT OUTER JOIN PRARTranslation trans WITH (NOLOCK) ON prar_CustomerNumber = praad_ARCustomerId AND prar_CompanyID = praa_CompanyId 
 LEFT OUTER JOIN Company tranCompany WITH (NOLOCK) ON tranCompany.comp_CompanyId = trans.prar_PRCoCompanyId '
exec usp_TravantCRM_CreateView 'vPRARAgingDetailBy', @Script 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRTES AS 
SELECT prtesr_TESRequestID, prtesr_Deleted, prtesr_ResponderCompanyID, prtesr_CreatedDate, CASE WHEN prtesr_SecondRequest = ''Y'' THEN ''Second Request'' ELSE prtesr_Source END as prtesr_Source, prtesr_ReceivedMethod, 
       prtesr_SentMethod, ISNULL(prtesr_SentDateTime, prtesr_ReceivedDateTime) as prtesr_SentDateTime,
	   prtesr_ReceivedDateTime, prtesr_SubjectCompanyID, prtesr_Received, CASE WHEN prtr_TESRequestID > 0 THEN ''Y'' ELSE '''' END As ResponseReceived, CONVERT(varchar(10), prtr_Date, 101) As ResponseDate, prtr_TradeReportId
  FROM PRTESRequest WITH (NOLOCK)  
	   LEFT OUTER JOIN PRTradeReport WITH (NOLOCK) ON prtr_TESRequestID = prtesr_TESRequestID AND prtr_Duplicate IS NULL AND prtr_SubjectID=prtesr_SubjectCompanyID ';
EXEC usp_TravantCRM_CreateView 'vPRTES', @Script 


-- vPRARTranslation
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRARTranslation AS 
SELECT prar_ARTranslationId, prar_CompanyId, prar_CustomerNumber, prar_PRCoCompanyId,
       prar_PRCoCompanyName = ISNULL(comp_Name, ''''),
	   FirstLeadID,
	   cc1.capt_us AS ListingStatus,
	   cc2.Capt_US [Type]
  FROM PRARTranslation WITH (NOLOCK)
       LEFT OUTER JOIN Company WITH (NOLOCK) ON comp_CompanyId = prar_PRCoCompanyId
	   LEFT OUTER JOIN Custom_Captions cc1 WITH (NOLOCK) ON comp_PRListingStatus = capt_code AND capt_family = ''comp_PRListingStatus''
	   LEFT OUTER JOIN Custom_Captions cc2 WITH (NOLOCK) ON cc2.capt_code = comp_PRType AND cc2.Capt_Family = ''comp_PRType''
	   LEFT OUTER JOIN (SELECT AssociatedCompanyID, CustomerNumber, MIN(LeadID) as FirstLeadID
						  FROM LumberLeads.dbo.Lead 
						 WHERE Status = ''Closed: Non-Factor''
						   AND Source = ''Unmatched AR''
					  GROUP BY AssociatedCompanyID, CustomerNumber) T1 ON prar_CompanyId = AssociatedCompanyID
						                                                AND prar_CustomerNumber = CustomerNumber'
EXEC usp_TravantCRM_CreateView 'vPRARTranslation', @Script


--DECLARE @script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetail AS 
SELECT distinct praa_CompanyId, 
    SubjectCompanyId = case 
      when praad_ManualCompanyId IS NOT NULL then praad_ManualCompanyId 
      when prar_PRCoCompanyId IS NOT NULL then prar_PRCoCompanyId 
      else NULL 
    end, 
    praa_Date,
    praad.* 
FROM PRARAgingDetail praad WITH (NOLOCK)
     INNER JOIN PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
     LEFT OUTER JOIN PRARTranslation WITH (NOLOCK) ON praa_CompanyId = prar_CompanyId 
                                                      AND praad_ARCustomerId = prar_CustomerNumber '
exec usp_TravantCRM_CreateView 'vPRARAgingDetail', @Script 

-- **** vExceptionQueue
SET @Script = 
'CREATE VIEW dbo.vExceptionQueue AS ' +
'SELECT comp_Name, prci_City, preq_TypeName = cast(capt_US as varchar), '+
'preq_StatusName = case when preq_status = ''C'' then ''Closed'' else ''Open'' end, ' + 
'preq_BBScoreDisplay = case when preq_BlueBookScore is null then '''' else convert(varchar,preq_BlueBookScore) end, ' + 
' preq_AssignedUser = COALESCE(RTRIM(user_FirstName) + '' '', '''') + RTRIM(user_LastName), preq.* ' +
'FROM PRExceptionQueue preq WITH (NOLOCK) '+ 
'JOIN Custom_Captions ON capt_FamilyType = ''Choices'' and capt_Family = ''preq_Type'' and capt_Code = preq_Type '+
'JOIN Company WITH (NOLOCK) ON preq_CompanyId = comp_CompanyId '+
'LEFT OUTER JOIN PRCity WITH (NOLOCK) ON comp_PRListingCityId = prci_CityId ' +
'LEFT OUTER JOIN Users WITH (NOLOCK) ON preq_AssignedUserId = user_UserId '
exec usp_TravantCRM_CreateView 'vExceptionQueue', @Script 

-- vPRTransaction
SET @Script = 
'CREATE VIEW dbo.vPRTransaction ' + 
'AS ' +
'SELECT prtx.*, prbe_BusinessEventTypeId ' +
  'FROM PRTransaction prtx WITH (NOLOCK) ' +
       'LEFT OUTER JOIN PRBusinessEvent WITH (NOLOCK) ON prtx_BusinessEventId = prbe_BusinessEventId ' 
exec usp_TravantCRM_CreateView 'vPRTransaction', @Script 


--
-- Added HQID
-- Changed the definition of prun_AllocationTypeCode to return the actual value
-- instead of the US_Capt translated value.  File searching indicates only the 
-- current prod web site references this view.  Removed the join to the custom
-- captions table.  Leaving the view just in case...
--
-- DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRServiceUnitAllocHistory AS 
SELECT prun_CompanyID, 
       prun_PersonID, 
       prun_AllocationTypeCode,
       prun_UnitsAllocated as prun_UnitsAllocated, 
	   prun_UnitsAllocated / 30 as prun_UnitsAllocated_New, 
       prun_UnitsRemaining as prun_UnitsRemaining, 
	   prun_UnitsRemaining / 30 as prun_UnitsRemaining_New,
       prun_UnitsAllocated-prun_UnitsRemaining as UnitsUsed, 
	   (prun_UnitsAllocated / 30) - (prun_UnitsRemaining / 30) as UnitsUsed_New, 
       prun_ExpirationDate, 
       prun_CreatedDate, 
       prun_HQID 
  FROM PRServiceUnitAllocation WITH (NOLOCK)  
 WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate'
exec usp_TravantCRM_CreateView 'vPRServiceUnitAllocHistory', @Script 


-- Similar view to vPRServiceUnitAllocHistory, but does not limit by date and units remaining.
-- Used by PRCompanyServiceUnitAllocationListing.asp
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRServiceUnitAllocation AS 
SELECT prun_CompanyID, 
       prun_ServiceUnitAllocationID, 
       prun_PersonID, 
       cast(a.Capt_US as varchar) as prun_AllocationTypeCode, 
       prun_UnitsAllocated as prun_UnitsAllocated, 
	   prun_UnitsAllocated / 30 as prun_UnitsAllocated_New, 
       prun_UnitsRemaining as prun_UnitsRemaining, 
	   prun_UnitsRemaining / 30 as prun_UnitsRemaining_New,
       prun_UnitsAllocated-prun_UnitsRemaining as UnitsUsed, 
	   (prun_UnitsAllocated / 30) - (prun_UnitsRemaining / 30) as UnitsUsed_New, 
       prun_StartDate, 
       prun_ExpirationDate, 
       prun_CreatedDate 
  FROM PRServiceUnitAllocation WITH (NOLOCK)  
       INNER JOIN Custom_Captions a WITH (NOLOCK) ON prun_AllocationTypeCode = a.capt_Code AND RTRIM(a.capt_Family)=''prun_AllocationTypeCode'' '
exec usp_TravantCRM_CreateView 'vPRServiceUnitAllocation', @Script 

-- Added HQID
-- Added FullName
--declare @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRServiceUnitUsageHistory  AS '+
'SELECT RTRIM(pers_FirstName) AS pers_FirstName,  '+
'	   RTRIM(pers_LastName) AS pers_LastName, '+
'      dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) As FullName, ' +
'	   prsuu_CompanyID, '+
'      a.comp_PRBookTradestyle, '+
'	   prsuu_CreatedDate, '+
'      prsuu_SearchCriteria, '+
'	   prsuu_UsageTypeCode, '+
'      prsuu_RegardingObjectID, '+
'      prbr_RequestedCompanyID, '+
'      b.comp_PRBookTradestyle As RequestedCompanyName, '+
'	   prsuu_Units, '+
'	   prsuu_HQID, '+
'      prsuu_PersonID, ' +
'      prcse_FullName ' +
'  FROM PRServiceUnitUsage WITH (NOLOCK)  '+
'       INNER JOIN Company a WITH (NOLOCK) ON prsuu_CompanyID = a.comp_CompanyID ' +
'       LEFT OUTER JOIN Person WITH (NOLOCK) ON prsuu_PersonID = pers_PersonID '+
'       LEFT OUTER JOIN PRBusinessReportRequest WITH (NOLOCK) ON prsuu_RegardingObjectID = prbr_BusinessReportRequestID AND prsuu_UsageTypeCode IN (''VBR'', ''FBR'', ''MBR'', ''EBR'',''OBR'') '+
'       LEFT OUTER JOIN Company b WITH (NOLOCK) ON prbr_RequestedCompanyID = b.comp_CompanyID' +
'       LEFT OUTER JOIN PRCompanySearch WITH (NOLOCK) ON prbr_RequestedCompanyID = prcse_CompanyId'
exec usp_TravantCRM_CreateView 'vPRServiceUnitUsageHistory', @Script 

--declare @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRServiceUnitUsageHistoryCRM  AS 
SELECT prsuu_ServiceUnitUsageId, 
       prsuu_PersonID, 
       dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) As FullName, 
	   prsuu_CompanyID, 
       a.prcse_FullName RequestingCompany, 
	   prsuu_CreatedDate, 
	   prsuu_UsageTypeCode, 
	   prsuu_TransactionTypeCode,
	   prsuu_Units,
	   prsuu_HQID, 
       prsuu_RegardingObjectID, 
       CASE prsuu_UsageTypeCode WHEN ''BP'' THEN  prpbar_Name ELSE b.prcse_FullName END As AdditionalInfo
  FROM PRServiceUnitUsage WITH (NOLOCK) 
       INNER JOIN PRCompanySearch a WITH (NOLOCK) ON prsuu_CompanyID = a.prcse_CompanyId 
       LEFT OUTER JOIN Person WITH (NOLOCK) ON prsuu_PersonID = pers_PersonID 
       LEFT OUTER JOIN PRBusinessReportRequest WITH (NOLOCK) ON prsuu_RegardingObjectID = prbr_BusinessReportRequestID AND prsuu_UsageTypeCode IN (''VBR'', ''FBR'', ''MBR'', ''EBR'',''OBR'') 
       LEFT OUTER JOIN PRCompanySearch b WITH (NOLOCK) ON prbr_RequestedCompanyID = b.prcse_CompanyId 
       LEFT OUTER JOIN PRPublicationArticle WITH (NOLOCK) ON prsuu_RegardingObjectID = prpbar_PublicationArticleID'
exec usp_TravantCRM_CreateView 'vPRServiceUnitUsageHistoryCRM', @Script 


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRCommunication AS 
SELECT communication.*, 
       comm_link.*, 
       comm_Attn = RTRIM(person.pers_firstname) + '' '' + RTRIM(person.pers_lastname), 
       comm_CompanyName = comp_name, 
       comm_AddressLine1 = vPRAddr.addr_address1, 
       comm_CityStateZip = vPRAddr.prci_City + '', '' + vPRAddr.prst_State + '' '' + COALESCE(vPRAddr.addr_PostCode, ''''), 
       comm_EmailFax = emai_EmailAddress 
  FROM comm_link WITH (NOLOCK)
       INNER JOIN communication WITH (NOLOCK) on cmli_comm_CommunicationId = comm_CommunicationId 
       LEFT OUTER JOIN vPRAddress vPRAddr on cmli_comm_CompanyId = adli_CompanyId AND adli_PRDefaultMailing = ''Y''
       LEFT OUTER JOIN Company WITH (NOLOCK) on cmli_comm_CompanyId = comp_CompanyId 
       LEFT OUTER JOIN Person WITH (NOLOCK) on cmli_comm_PersonId = pers_PersonId 
       LEFT OUTER JOIN vPRPersonEmail WITH (NOLOCK) on cmli_comm_PersonId = elink_RecordID AND cmli_comm_CompanyID = emai_CompanyID
 WHERE communication.comm_Deleted is null and comm_link.cmli_Deleted is null '
exec usp_TravantCRM_CreateView 'vPRCommunication', @Script 

-- RAO: also adding comp_companyid = prbr.prbr_RequestedCompanyId for the benefit of the listing grid
-- so that the company can be hyperlinked very easily; could do it off the other requestedCompanyId
-- but then the CompanySummary would have to handle this ID specifically.
SET @Script = 
'CREATE VIEW dbo.vPRServiceUnitUsage AS '+
'SELECT prsuu.*, '+
'    prbr.*, '+
'    prsuu_IsReversal = case when prsuu_ReversalServiceUnitUsageId is not null then ''Y'' else null end, '+
'    prsuu_RequestedBBID = prbr.prbr_RequestedCompanyId, '+
'    comp_CompanyId = prbr.prbr_RequestedCompanyId '+
'  FROM PRServiceUnitUsage prsuu WITH (NOLOCK) ' +
'       LEFT OUTER JOIN PRBusinessReportRequest prbr WITH (NOLOCK) ON prsuu_RegardingObjectId = prbr_BusinessReportRequestId '+
' WHERE prsuu.prsuu_Deleted is null and prbr.prbr_Deleted is null '
exec usp_TravantCRM_CreateView 'vPRServiceUnitUsage', @Script 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRTESFormExtract AS 
SELECT prtf_TESFormBatchID, 
       prtf_FormType, 
	   prtf_SerialNumber, 
	   prtf_CompanyID,  
	   prattn_PersonID,  
       dbo.ufn_GetAttentionLineByID(prattn_AttentionLineID) AS AttentionLine, 
       Responder.comp_PRCorrTradestyle AS ResponderCorrTradeStyle, 
       addr_Address1, 
       addr_Address2, 
       addr_Address3, 
       addr_Address4, 
       addr_Address5, 
       ResponderLocation.prci_City AS Responderprci_City, 
       ResponderLocation.prst_Abbreviation AS Responderprst_Abbreviation, 
	   ResponderLocation.prcn_Country AS Responderprcn_Country, 
       addr_PostCode, 
	   prtesr_SubjectCompanyID, 
	   Subject.comp_PRBookTradestyle AS SubjectBookTradeStyle, 
       SubjectLocation.prci_City AS Subjectprci_City, 
       SubjectLocation.prst_Abbreviation AS Subjectprst_Abbreviation, 
	   SubjectLocation.prcn_Country AS Subjectprcn_Country 
  FROM PRTESForm WITH (NOLOCK) 
       INNER JOIN PRTESRequest WITH (NOLOCK) ON prtf_TESFormID = prtesr_TESFormID 
	   INNER JOIN Company Responder WITH (NOLOCK) ON prtf_CompanyID = Responder.comp_CompanyID 
       INNER JOIN Company Subject WITH (NOLOCK) ON prtesr_SubjectCompanyID = Subject.comp_CompanyID 
       INNER JOIN PRAttentionLine WITH (NOLOCK) ON prtf_CompanyID = prattn_CompanyID AND prattn_ItemCode =''TES-M'' AND prattn_Disabled IS NULL 
       INNER JOIN Address WITH (NOLOCK) ON prattn_AddressID = addr_AddressID 
       INNER JOIN vPRLocation ResponderLocation on addr_PRCityID = ResponderLocation.prci_CityID 
	   INNER JOIN vPRLocation SubjectLocation on Subject.comp_PRListingCityID = SubjectLocation.prci_CityID 
 WHERE addr_deleted IS NULL '
exec usp_TravantCRM_CreateView 'vPRTESFormExtract', @Script


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRTESReport AS 
SELECT prtf_TESFormBatchID, 
       prtf_FormType, 
	   prtf_SerialNumber, 
	   prtf_CompanyID,  
	   prattn_PersonID,  
       dbo.ufn_GetAttentionLineByID(prattn_AttentionLineID) AS AttentionLine, 
       prtesr_ResponderCompanyID,
       Responder.comp_PRCorrTradestyle AS ResponderCorrTradeStyle, 
       ResponderLocation.prci_City AS Responderprci_City, 
       ResponderLocation.prst_Abbreviation AS Responderprst_Abbreviation, 
	   ResponderLocation.prcn_Country AS Responderprcn_Country, 
	   prtesr_SubjectCompanyID, 
	   Subject.comp_PRBookTradestyle AS SubjectBookTradeStyle, 
       SubjectLocation.prci_City AS Subjectprci_City, 
       SubjectLocation.prst_Abbreviation AS Subjectprst_Abbreviation, 
	   SubjectLocation.prcn_Country AS Subjectprcn_Country,
	   prtesr_SecondRequest
  FROM PRTESForm WITH (NOLOCK) 
       INNER JOIN PRTESRequest WITH (NOLOCK) ON prtf_TESFormID = prtesr_TESFormID 
	   INNER JOIN Company Responder WITH (NOLOCK) ON prtf_CompanyID = Responder.comp_CompanyID 
       INNER JOIN Company Subject WITH (NOLOCK) ON prtesr_SubjectCompanyID = Subject.comp_CompanyID 
       INNER JOIN PRAttentionLine WITH (NOLOCK) ON prtf_CompanyID = prattn_CompanyID AND prattn_ItemCode = CASE prtesr_SentMethod WHEN ''M'' THEN ''TES-M'' ELSE ''TES-E'' END AND prattn_Disabled IS NULL 
       INNER JOIN vPRLocation ResponderLocation on Responder.comp_PRListingCityID = ResponderLocation.prci_CityID 
	   INNER JOIN vPRLocation SubjectLocation on Subject.comp_PRListingCityID = SubjectLocation.prci_CityID'
exec usp_TravantCRM_CreateView 'vPRTESReport', @Script



--DECLARE @Script varchar(max)
-- create views that display records that have workflows started
SET @Script = 
'CREATE VIEW dbo.vPROpportunityWorkflowListing AS 
SELECT WS.*, WI.*, OPP.*, oppo_stage as OppoStage, comp_companyid = oppo_primarycompanyid, comp_PRIndustryType, CityStateCountryShort, comp_PRListingCityID 
  FROM WorkflowInstance WI  WITH (NOLOCK)
       INNER JOIN Opportunity OPP WITH (NOLOCK) ON wkin_CurrentrecordId = oppo_OpportunityId 
       INNER JOIN Company WITH (NOLOCK) ON oppo_PrimaryCompanyID = comp_CompanyID 
       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
       INNER JOIN WorkflowState WS WITH (NOLOCK) ON wkin_CurrentStateId = wkst_StateId 
 WHERE wkin_CurrentEntityId = 10 ' 
exec usp_TravantCRM_CreateView 'vPROpportunityWorkflowListing', @Script 


-- create views that display records that have workflows started
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPROpportunityListing AS 
SELECT OPP.*, oppo_stage as OppoStage, comp_companyid = oppo_primarycompanyid, comp_PRIndustryType, CityStateCountryShort, comp_PRListingCityID, prst_StateID as ListingStateID
  FROM Opportunity OPP WITH (NOLOCK) 
       LEFT OUTER JOIN Company WITH (NOLOCK) ON oppo_PrimaryCompanyID = comp_CompanyID 
       LEFT OUTER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID '
exec usp_TravantCRM_CreateView 'vPROpportunityListing', @Script 


-- handles the retrieval of the new ssfile structures
SET @Script = 
'CREATE VIEW dbo.vPRSSFileListing AS ' +
'Select PRSSFile.*, ssfileid = convert(varchar(10), prss_ssfileid), Claimant = prcse1.prcse_FullName, ClaimantCompanyId = prcse1.prcse_CompanyId, '+
'Respondent = prcse2.prcse_FullName, RespondentCompanyId = prcse2.prcse_CompanyId '+
'from PRSSFile WITH (NOLOCK) '+
'LEFT OUTER JOIN PRCompanySearch prcse1 WITH (NOLOCK) ON prcse1.prcse_CompanyId = prss_ClaimantCompanyId  '+
'LEFT OUTER JOIN PRCompanySearch prcse2 WITH (NOLOCK) ON prcse2.prcse_CompanyId = prss_RespondentCompanyId  '
--'LEFT OUTER JOIN PRCompanySearch prcse3 ON prcse3.prcse_CompanyId = prss_3rdPartyCompanyId  '
exec usp_TravantCRM_CreateView 'vPRSSFileListing', @Script 

SET @Script = 
'CREATE VIEW dbo.vCustomerCareWorkflowListing AS ' +
'Select WS.*, WI.*, Cases.*, comp_companyid = case_primarycompanyid from WorkflowInstance WI ' +
'inner join cases ON wkin_CurrentrecordId = case_caseId ' +
'inner join WorkflowState WS ON wkin_CurrentStateId = wkst_StateId ' +
'Where wkin_CurrentEntityId = 3 ' 
exec usp_TravantCRM_CreateView 'vCustomerCareWorkflowListing', @Script 

SET @Script = 
'CREATE VIEW dbo.vPRSearchListState AS ' +
'SELECT prst_StateID, prst_State, prst_Abbreviation, prcn_CountryId, prcn_Country, prcn_CountryCode ' +
'  FROM PRState ' +
'       LEFT OUTER JOIN PRCountry ON prst_CountryID = prcn_CountryId ' +
' WHERE prst_State IS NOT NULL;'
exec usp_TravantCRM_CreateView 'vPRSearchListState', @Script 



--  vSummaryCompany is the Sage native view that is used in the company recent list, 
--  advanced search select, etc.  Overriding this must be done with caution.
--  We remove many of the original fields to thin the results set.  Some are required to 
--  stay because they are used in native Sage action (urls with act=<value> for company).
--  Also note that comp_Name returns the prcse_FullName value from PRCompanySearch.
--
-- This changes the display in the Recent List and the company AdvancedSearchSelect fields.
--
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vSummaryCompany AS 
SELECT comp_deleted, comp_slaid, comp_status, comp_sector, comp_employees, comp_revenue, comp_source, comp_mailrestriction,
       prcse_FullName AS Comp_Name, comp_PRUnconfirmed, 
       null as Addr_AddressId, null as Addr_Street, null as Addr_Address1, null as Addr_Address2, null as Addr_Address3, 
       null as Addr_Address4, null as Addr_Address5, null as Addr_City, null as Addr_State, null as Addr_Country, null as Addr_PostCode, 
       null as Pers_PersonId, null as Pers_Salutation, 
       null as Pers_PrimaryUserId, 
       null as Pers_FirstName, null as Pers_LastName, null as pers_title, null as pers_department, 
       null as Pers_PhoneAreaCode, null as Pers_PhoneNumber, null as Pers_EmailAddress, 
       null as pers_SecTerr,
       Comp_CompanyId, null as Comp_PrimaryPersonId, null as Comp_PrimaryAddressId, null as Comp_PrimaryUserId, 
       null as comp_Type, null as comp_Website, 
       null as Comp_CreatedBy, null as Comp_ChannelID, null as Comp_SecTerr,
	   null as Comp_EmailAddress, 
	   Phon_CountryCode as Comp_PhoneCountryCode, Phon_AreaCode as Comp_PhoneAreaCode, Phon_Number as Comp_PhoneNumber, 
	   null as Comp_FaxCountryCode, null as Comp_FaxAreaCode, null as Comp_FaxNumber,
	   comp_optout, Comp_IntegratedSystems
  FROM Company WITH (NOLOCK) 
       INNER JOIN PRCompanySearch WITH (NOLOCK) on comp_CompanyId = prcse_CompanyId 
	   LEFT OUTER JOIN vPRCompanyPhone ON comp_CompanyID = plink_RecordID AND plink_EntityID=5 AND phon_PRIsPhone = ''Y'' AND phon_PRPreferredInternal = ''Y''
 WHERE Comp_Deleted IS NULL '
EXEC usp_TravantCRM_CreateView 'vSummaryCompany', @Script 

-- , Comp_IntegratedSystems

--
--  Overriding an Accpac native view.  Also had to dump several
--  user field references to trim down the SQL size to fit into
--  the @Script variable.  They don't appear to be used anywhere.
--
-- This view returns dbo.ufn_FormatName as comp_Name in order to get a differet
-- value to appear in the Recent List  fields.
--
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vSummaryPerson AS 
SELECT dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix, 1) AS Pers_FullName,  
       ISNULL(Users.User_FirstName, '' '') + '' '' + ISNULL(Users.User_LastName, '' '') AS User_Name, RTRIM(ISNULL(Addr_Address1, '' '')) + ''~'' + RTRIM(ISNULL(Addr_Address2, '' '')) + ''~'' + RTRIM(ISNULL(Addr_Address3, '' '')) + ''~'' + RTRIM(ISNULL(Addr_Address4, '' '')) + ''~'' + RTRIM(ISNULL(Addr_Address5, '' '')) AS Addresses,  
		Addr_Street, Addr_AddressId, Addr_Address1, Addr_Address2, Addr_Address3,  
		Addr_Address4, Addr_Address5, Addr_City, Addr_State, Addr_Country,  
		Addr_PostCode, Addr_CreatedBy, Addr_CreatedDate, Addr_UpdatedBy,  
		Addr_UpdatedDate, Addr_TimeStamp, Addr_Deleted, Addr_SegmentID,  
		Addr_ChannelID, addr_uszipplusfour, addr_PRCityId, addr_PRCounty, 
		addr_PRZone, addr_PRPublish, addr_PRDescription, 
		addr_PRReplicatedFromId, 
		User_UserId, 
		Users.User_PrimaryChannelId, User_Logon, User_LastName, User_FirstName, User_Language, 
		Users.User_Department, User_Phone, User_Extension, User_Pager, User_Homephone, 
		Pers_PersonId, Pers_CompanyId, Pers_PrimaryAddressId, Pers_PrimaryUserId, 
		Pers_Salutation, 
		Pers_FirstName, 
		Pers_LastName, 
		Pers_MiddleName, Pers_Suffix, 
		Pers_Gender, Pers_Title, Pers_TitleCode, Pers_Department, Pers_Status,  
		Pers_Source, Pers_Territory, Pers_WebSite, Pers_MailRestriction,  
		Pers_PhoneCountryCode, Pers_PhoneAreaCode, Pers_PhoneNumber, Pers_EmailAddress, 
		Pers_FaxCountryCode, Pers_FaxAreaCode, Pers_FaxNumber, Pers_CreatedBy, 
		Pers_CreatedDate, Pers_UpdatedBy, Pers_UpdatedDate, Pers_TimeStamp, Pers_Deleted, 
		Pers_LibraryDir, Pers_SegmentID, Pers_ChannelID, Pers_UploadDate, pers_SecTerr,  
		Pers_WorkflowId, pers_PRYearBorn, pers_PRDeathDate, pers_PRLanguageSpoken, pers_PRUnconfirmed, 
		pers_PRPaternalLastName, pers_PRMaternalLastName, pers_PRNickname1, pers_PRNickname2, 
		pers_PRMaidenName, pers_PRIndustryStartDate, pers_PRNotes, pers_PRDefaultEmailId, 
		Comp_CompanyId, Comp_PrimaryPersonId, Comp_PrimaryAddressId, 
		Comp_PrimaryUserId, Comp_Name, Comp_Type, Comp_Status, Comp_Source, 
		Comp_Territory, Comp_Revenue, Comp_Employees, Comp_Sector,  
		Comp_IndCode, Comp_WebSite, Comp_MailRestriction, Comp_PhoneCountryCode,  
		Comp_PhoneAreaCode, Comp_PhoneNumber, Comp_FaxCountryCode, Comp_FaxAreaCode, 
		Comp_FaxNumber, Comp_EmailAddress, Comp_CreatedBy, Comp_CreatedDate, 
		Comp_UpdatedBy, Comp_UpdatedDate, Comp_TimeStamp, Comp_Deleted, 
		Comp_LibraryDir, Comp_SegmentID, Comp_ChannelID, Comp_SecTerr, 
		Comp_WorkflowId, Comp_UploadDate, comp_SLAId, comp_PRHQId,  
		comp_PRCorrTradestyle, comp_PRBookTradestyle, comp_PRSubordinationAgrProvided,  
		comp_PRSubordinationAgrDate, comp_PRExcludeFSRequest, comp_PRSpecialInstruction, 
		comp_PRDataQualityTier, comp_PRListingCityId, comp_PRListingStatus, 
		comp_PRAccountTier, comp_PRBusinessStatus, 
		comp_PRTradestyle1, comp_PRTradestyle2, 
		comp_PRTradestyle3, comp_PRTradestyle4, comp_PRLegalName, comp_PROriginalName, 
		comp_PROldName1, comp_PROldName1Date, comp_PROldName2, comp_PROldName2Date, 
		comp_PROldName3, comp_PROldName3Date, comp_PRType,  
		comp_PRPublishUnloadHours, comp_PRMoralResponsibility, comp_PRSpecialHandlingInstruction, 
		comp_PRHandlesInvoicing, comp_PRReceiveLRL, comp_PRTMFMAward,  
		comp_PRTMFMAwardDate, comp_PRTMFMCandidate, comp_PRTMFMCandidateDate, 
		comp_PRTMFMComments, comp_PRAdministrativeUsage,  
		comp_PRInvestigationMethodGroup, comp_PRReceiveTES, 
		comp_PRTESNonresponder, comp_PRCreditWorthCap, comp_PRCreditWorthCapReason,  
		comp_PRConfidentialFS, comp_PRJeopardyDate, comp_PRLogo, 
		comp_PRUnattributedOwnerPct, comp_PRUnattributedOwnerDesc, comp_PRConnectionListDate, 
		comp_PRFinancialStatementDate, comp_PRBusinessReport, comp_PRPrincipalsBackgroundText, 
		comp_PRMethodSourceReceived, comp_PRIndustryType, comp_PRCommunicationLanguage,  
		comp_PRTradestyleFlag, comp_PRPublishDL, comp_DLBillFlag,  
		comp_PRWebActivated, comp_PRWebActivatedDate, comp_PRReceivesBBScoreReport,  
		comp_PRServicesThroughCompanyId, comp_PRLastVisitDate, comp_PRLastVisitedBy,
		pers_optout, Pers_IntegratedSystems
   FROM vPersonPE WITH (NOLOCK) 
        LEFT OUTER JOIN vAddress ON Pers_PrimaryAddressId = Addr_AddressId 
		LEFT OUTER JOIN vCompanyPE WITH (NOLOCK) ON Pers_CompanyId = Comp_CompanyId 
		LEFT OUTER JOIN Users WITH (NOLOCK) ON Pers_PrimaryUserId = User_UserId 
  WHERE (Pers_Deleted IS NULL)'
exec usp_TravantCRM_CreateView 'vSummaryPerson', @Script 
-- , Pers_IntegratedSystems


-- Publishing screens
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBluePrintEdition AS
SELECT prpbed_PublicationEditionID, prpbed_Name, prpbed_PublishDate
  FROM PRPublicationEdition WITH (NOLOCK)';
exec usp_TravantCRM_CreateView 'vPRBluePrintEdition', @Script 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBluePrintEditionArticle AS 
SELECT prpbar_PublicationArticleID, prpbar_Name, prpbar_PublicationCode, prpbar_CategoryCode, prpbar_IndustryTypeCode, prpbar_Sequence, prpbar_PublicationEditionID as prpbed_PublicationEditionID
  FROM PRPublicationArticle WITH (NOLOCK) 
       INNER JOIN Custom_Captions WITH (NOLOCK) On prpbar_PublicationCode = Capt_Code AND capt_family = ''BluePrintsPublicationCode'' ' 
exec usp_TravantCRM_CreateView 'vPRBluePrintEditionArticle', @Script 


-- DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRPublicationArticle AS 
SELECT prpbar_PublicationArticleID, prpbar_Name, prpbar_PublicationCode, prpbar_CategoryCode, prpbar_IndustryTypeCode, prpbar_Sequence 
  FROM PRPublicationArticle WITH (NOLOCK) 
       INNER JOIN Custom_Captions WITH (NOLOCK) On prpbar_PublicationCode = Capt_Code AND capt_family = ''GeneralPublicationCode'' ' 
exec usp_TravantCRM_CreateView 'vPRPublicationArticle', @Script 

-- Advertising screens
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRAdCampaignList AS 
SELECT pradch_CompanyID, pradc_AdCampaignID, pradc_Name, pradc_AdCampaignType, 
       CASE pradc_AdCampaignType WHEN ''BP'' THEN NULL ELSE pradc_StartDate END AS StartDate,
       CASE pradc_AdCampaignType WHEN ''BP'' THEN NULL ELSE pradc_EndDate END AS EndDate,
       dbo.ufn_GetCustomCaptionValueList(''pradc_BluePrintsEdition'', pradc_BluePrintsEdition) As BlueprintsEdition 
FROM PRAdCampaignHeader WITH (NOLOCK)
	INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID ' 
exec usp_TravantCRM_CreateView 'vPRAdCampaignList', @Script 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW [dbo].[vPRAdCampaignImage] AS 
	SELECT pradc_AdCampaignID,
	       pradc_StartDate,
		   pradc_EndDate,
           pradc_TargetURL,
		   pradc_IndustryType,
	       pracf_FileName_Disk,
		   pradc_AdCampaignTypeDigital, 
		   pracf_FileTypeCode,
		   pradc_CreativeStatus,
		   pradc_CommodityId,
		   pradc_Language
      FROM PRAdCampaignHeader WITH (NOLOCK)
           INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
	       INNER JOIN PRAdCampaignFile WITH (NOLOCK) ON pradc_AdCampaignID = pracf_AdCampaignID'
exec usp_TravantCRM_CreateView 'vPRAdCampaignImage', @Script 
GO


-- Need to join PRAdCampaign because accpac will filter on pradc_AdCampaignID (we don't use it for this view)
DECLARE @Script varchar(max)
SET @Script =
'CREATE VIEW dbo.vPRAdCampaignPageDetailList AS ' +
'SELECT pradcats_AdCampaignID , pradcats_AdCampaignID pradc_AdCampaignID, SUM(pradcats_ImpressionCount) ImpressionCount, SUM(pradcats_ClickCount) ClickCount ' +
  ' FROM PRAdCampaignAuditTrailSummary WITH (NOLOCK) ' +
' GROUP BY pradcats_AdCampaignID'
exec usp_TravantCRM_CreateView 'vPRAdCampaignPageDetailList', @Script

--DECLARE @Script varchar(max)
SET @Script =
'CREATE VIEW dbo.vPRAdCampaignSummary AS 
 SELECT pradc_AdCampaignID, 
        pradc_ImpressionCount, 
		pradc_ClickCount 
   FROM PRAdCampaign WITH (NOLOCK)'
  
EXEC usp_TravantCRM_CreateView 'vPRAdCampaignSummary', @Script

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRMarketingList AS 
SELECT comp_CompanyId, 
       comp_CompanyId AS [BB ID #], 
       comp_PRCorrTradestyle AS [Company Name], 
	   RTRIM(MailAddr.Addr_Address1) AS [Mailing Address Line 1], 
	   RTRIM(MailAddr.Addr_Address2) AS [Mailing Address Line 2], 
	   RTRIM(MailAddr.Addr_Address3) AS [Mailing Address Line 3], 
	   RTRIM(MailAddr.Addr_Address4) AS [Mailing Address Line 4], 
	   RTRIM(MailAddr.Addr_Address5) AS [Mailing Address Line 5], 
       MailLocation.prci_City AS [Mailing City], 
       ISNULL(MailLocation.prst_Abbreviation ,MailLocation.prst_State) AS [Mailing State], 
	   MailAddr.Addr_PostCode AS [Mailing Postal Code], 
       MailLocation.prcn_Country AS [Mailing Country], 
	   RTRIM(PhysicalAddr.Addr_Address1) AS [Physical Address Line 1], 
	   RTRIM(PhysicalAddr.Addr_Address2) AS [Physical Address Line 2], 
	   RTRIM(PhysicalAddr.Addr_Address3) AS [Physical Address Line 3], 
	   RTRIM(PhysicalAddr.Addr_Address4) AS [Physical Address Line 4], 
	   RTRIM(PhysicalAddr.Addr_Address5) AS [Physical Address Line 5], 
       PhysicalLocation.prci_City AS [Physical City], 
       ISNULL(PhysicalLocation.prst_Abbreviation ,PhysicalLocation.prst_State) AS [Physical State], 
	   PhysicalAddr.Addr_PostCode AS [Physical Postal Code], 
       PhysicalLocation.prcn_Country AS [Physical Country], 
	   dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) As [Phone Number],  
       dbo.ufn_FormatPhone(fax.phon_CountryCode, fax.phon_AreaCode, fax.phon_Number, fax.phon_PRExtension) As [Fax Number], 
       RTRIM(EM.Emai_EmailAddress) AS [E-mail Address], 
	   RTRIM(WS.emai_PRWebAddress) AS [Web Site URL], 
       dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, null, pers_Suffix) As [Executive Contact Name], 
       dbo.ufn_GetClassificationsForList(comp_CompanyID) AS [Classifications], 
       dbo.ufn_GetCommoditiesForList(comp_CompanyID) AS [Commodities], 
	   prcp_Volume AS [Annual Volume Figure] 
  FROM Company WITH (NOLOCK) 
       LEFT OUTER JOIN Address_Link MailAddrLink WITH (NOLOCK) ON comp_CompanyID = MailAddrLink.adli_CompanyID AND MailAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, ''M'')  
       LEFT OUTER JOIN Address MailAddr WITH (NOLOCK) ON MailAddrLink.adli_AddressID = MailAddr.addr_AddressID 
       LEFT OUTER JOIN vPRLocation MailLocation WITH (NOLOCK) ON MailAddr.addr_PRCityID = MailLocation.prci_CityID 
       LEFT OUTER JOIN Address_Link PhysicalAddrLink WITH (NOLOCK) ON comp_CompanyID = PhysicalAddrLink.adli_CompanyID AND PhysicalAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, ''PH'')  
       LEFT OUTER JOIN Address PhysicalAddr WITH (NOLOCK) ON PhysicalAddrLink.adli_AddressID = PhysicalAddr.addr_AddressID 
       LEFT OUTER JOIN vPRLocation PhysicalLocation WITH (NOLOCK) ON PhysicalAddr.addr_PRCityID = PhysicalLocation.prci_CityID 
       LEFT OUTER JOIN vCompanyEmail as WS WITH (NOLOCK) ON comp_CompanyID = WS.elink_RecordID AND WS.ELink_Type = ''W'' AND WS.emai_PRPreferredPublished=''Y'' 
       LEFT OUTER JOIN vCompanyEmail as EM WITH (NOLOCK) ON comp_CompanyID = EM.elink_RecordID AND EM.ELink_Type = ''E'' AND EM.emai_PRPreferredPublished=''Y'' 
	   LEFT OUTER JOIN vPRCompanyPhone fax WITH (NOLOCK) ON comp_CompanyID = fax.plink_RecordID AND  fax.phon_PRIsFax = ''Y'' AND fax.phon_PRPreferredPublished = ''Y''
       LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.plink_RecordID AND  phone.phon_PRIsPhone = ''Y'' AND phone.phon_PRPreferredPublished = ''Y''
       LEFT OUTER JOIN Person_Link WITH (NOLOCK) on comp_CompanyID = peli_CompanyID AND peli_PRRole LIKE ''%,HE,%'' AND peli_PRStatus = ''1'' and peli_PREBBPublish = ''Y'' 
       LEFT OUTER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
       LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) on comp_CompanyID = prcp_CompanyID '
exec usp_TravantCRM_CreateView 'vPRMarketingList', @Script


SET @Script = 
'CREATE VIEW dbo.vPRWebUserSummary AS ' +
'SELECT prwucl_HQID, prwucl_WebUserListID, prwucl_Name, prwucl_IsPrivate, MAX(prwucl_UpdatedDate) AS prucl_UpdatedDate, COUNT(prwuld_WebUserListID) as CompanyCount ' +
'  FROM PRWebUserList ' +
'       LEFT OUTER JOIN PRWebUserListDetail ON prwucl_WebUserListID = prwuld_WebUserListID ' +
' WHERE prwucl_TypeCode <> ''CL'' ' +
' GROUP BY prwucl_HQID, prwucl_WebUserListID, prwucl_Name, prwucl_IsPrivate ' +
'UNION ' +
'SELECT prwucl_HQID, prwucl_WebUserListID, prwucl_Name, prwucl_IsPrivate,  MAX(prcr_UpdatedDate), COUNT(1) as CompanyCount ' +
'  FROM PRWebUserList WITH (NOLOCK) ' +
'       INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON prwucl_HQID = prcr_RightCompanyID ' +
'       INNER JOIN Company WITH (NOLOCK) on prcr_LeftCompanyID = comp_CompanyID ' +
' WHERE prwucl_TypeCode = ''CL'' ' +
'   AND prcr_Active = ''Y'' ' +
'   AND prcr_Type IN (''04'', ''09'', ''10'', ''11'', ''12'', ''13'', ''14'', ''15'', ''16'') ' +
'   AND comp_PRListingStatus IN (''L'', ''H'', ''LUV'') ' +
'GROUP BY prwucl_HQID, prwucl_WebUserListID, prwucl_Name, prwucl_IsPrivate '
exec usp_TravantCRM_CreateView 'vPRWebUserSummary', @Script 


-- DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRWebUserNote AS 
SELECT prwun_WebUserNoteID, prwun_HQID, prwun_WebUserID, prwun_AssociatedID, prwun_AssociatedType, 
       CASE prwun_AssociatedType WHEN ''C'' THEN ''BB# '' + CAST(prwun_AssociatedID as varchar(20)) + '' '' + comp_PRBookTradeStyle WHEN ''P'' THEN dbo.ufn_FormatPerson(p.pers_FirstName, p.pers_LastName, p.pers_MiddleName, p.pers_PRNickname1, p.pers_Suffix) WHEN ''PC'' THEN prwuc_FirstName + '' '' + prwuc_LastName END As Subject, 
	   prwun_IsPrivate, prwun_UpdatedDate, prwun_UpdatedBy, prwun_NoteUpdatedDateTime, prwun_NoteUpdatedBy, 
	   dbo.ufn_FormatPerson(u.pers_FirstName, u.pers_LastName, u.pers_MiddleName, u.pers_PRNickname1, u.pers_Suffix) As UpdatedBy, 
	   dbo.ufn_GetWebUserLocation(prwun_NoteUpdatedBy) As UpdatedByLocation, 
	   prwun_Note,
	   prwun_Key, prwun_Date, prwun_DateUTC,
	   prwun_Hour, prwun_Minute, prwun_AMPM, prwun_Timezone,
	   CASE prwun_AssociatedType WHEN ''C'' THEN comp_PRBookTradeStyle WHEN ''P'' THEN dbo.ufn_FormatPerson(p.pers_FirstName, p.pers_LastName, p.pers_MiddleName, p.pers_PRNickname1, p.pers_Suffix) WHEN ''PC'' THEN prwuc_FirstName + '' '' + prwuc_LastName END As Subject2,
	   prwun_CreatedBy, prwun_CreatedDate
  FROM PRWebUserNote WITH (NOLOCK) 
       INNER JOIN PRWebUser WITH (NOLOCK) on prwun_NoteUpdatedBy = prwu_WebUserID 
       INNER JOIN Person_Link WITH (NOLOCK) ON prwu_PersonLinkID = peli_PersonLinkID 
       INNER JOIN Person u WITH (NOLOCK) ON peli_PersonID = u.pers_PersonID 
       LEFT OUTER JOIN Company WITH (NOLOCK) ON prwun_AssociatedID = comp_CompanyID and prwun_AssociatedType = ''C'' 
       LEFT OUTER JOIN Person p WITH (NOLOCK) ON prwun_AssociatedID = p.pers_PersonID and prwun_AssociatedType = ''P'' 
       LEFT OUTER JOIN PRWebUserContact WITH (NOLOCK) ON prwun_AssociatedID = prwuc_WebUserContactID and prwun_AssociatedType = ''PC'''
exec usp_TravantCRM_CreateView 'vPRWebUserNote', @Script 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBBOSCompanyList AS 
	SELECT comp_CompanyID,  
           comp_PRHQID,
           comp_PRBookTradestyle,  
		   comp_PRCorrTradestyle,
           CityStateCountryShort,  
           comp_PRIndustryType, 
           comp_PRType, 
		   comp_PRListedDate,  
           comp_PRLastPublishedCSDate, 
           comp_PRListingStatus, 
           CountryStAbbrCity,
           ISNULL(comp_PRLegalName, '''') comp_PRLegalName,
           dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) As Phone,
           comp_PRListingCityID,
		   comp_PRLocalSource,
		   prst_StateID,
		   CASE comp_PRLocalSource WHEN ''Y'' THEN prst_StateID ELSE NULL END as LocalSourceStateID,
		   comp_PRDelistedDate,
		   comp_PRImporter,
           comp_PRPublishBBScore,
		   comp_PRIsIntlTradeAssociation,
		   comp_PRReceivePromoEmails,
		   comp_PRReceivePromoFaxes
     FROM Company WITH (NOLOCK) 
          INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
          LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.PLink_RecordID AND phone.phon_PRIsPhone=''Y'' AND phone.phon_PRPreferredPublished=''Y'' 
	 WHERE comp_PRListingStatus IN (''L'', ''H'', ''N3'', ''N5'', ''N6'', ''LUV'');';
EXEC usp_TravantCRM_CreateView 'vPRBBOSCompanyList', @Script, null, 0, null, null, null, 'Company'   

SET @Script = 
'CREATE VIEW dbo.vPRBBOSCompanyList_ALL AS 
	SELECT comp_CompanyID,  
	       comp_Name,
           comp_PRHQID, 
	       comp_PRBookTradestyle,  
           CityStateCountryShort,  
           comp_PRIndustryType, 
           comp_PRType, 
		   comp_PRListedDate,  
           comp_PRLastPublishedCSDate, 
           comp_PRListingStatus, 
           CountryStAbbrCity,
           ISNULL(comp_PRLegalName, '''') comp_PRLegalName,
           dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) As Phone,
           comp_PRListingCityID,
		   comp_PRLocalSource,
		   prst_StateID,
		   CASE comp_PRLocalSource WHEN ''Y'' THEN prst_StateID ELSE NULL END as LocalSourceStateID,
		   comp_PRDelistedDate, comp_PRPublishPayIndicator, comp_PRTMFMAward, comp_PRTMFMAwardDate,
		   comp_PRImporter,
           comp_PRPublishBBScore,
		   comp_PRIsIntlTradeAssociation,
		   comp_PRReceivePromoEmails,
		   comp_PRReceivePromoFaxes
      FROM Company WITH (NOLOCK) 
           INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
           LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.PLink_RecordID AND phone.phon_PRIsPhone=''Y'' AND phone.phon_PRPreferredPublished=''Y'''; 
EXEC usp_TravantCRM_CreateView 'vPRBBOSCompanyList_ALL', @Script, null, 0, null, null, null, 'Company' 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRBBOSCompany AS 
SELECT comp_CompanyID, comp_PRCorrTradestyle, CityStateCountryShort,
        dbo.ufn_GetCustomCaptionValue(''comp_PRListingStatus'', comp_PRListingStatus, ''en-us'') As ListingStatus, comp_PRTMFMAward, 
        comp_PRTMFMAwardDate, comp_PRIndustryType, dbo.ufn_GetCustomCaptionValue(''comp_PRIndustryType'', comp_PRIndustryType, ''en-us'') As IndustryType, 
        dbo.ufn_GetCustomCaptionValue(''comp_PRType_BBOS'', comp_PRType, ''en-us'') As PRType, 
        comp_PRPublishPayIndicator, prcpi_PayIndicator, prcpi_CompanyPayIndicatorID, 
        CASE WHEN comp_PRType = ''B'' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN ''N'' ELSE ''Y'' END ELSE ''N'' END AS IsHQRating,
        CASE WHEN comp_PRType = ''B'' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END AS prra_RatingID,
        CASE WHEN comp_PRType = ''B'' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine,
        prbs_BBScore, prbs_PRPublish, 
        dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) As Phone, 
        dbo.ufn_FormatPhone(fax.phon_CountryCode, fax.phon_AreaCode, fax.phon_Number, fax.phon_PRExtension) As Fax, 
        dbo.ufn_FormatPhone(tf.phon_CountryCode, tf.phon_AreaCode, tf.phon_Number, tf.phon_PRExtension) As TollFree, 
        RTRIM(em.emai_EmailAddress) As Email, ws.emai_PRWebAddress, comp_PRLogo, comp_PRPublishLogo, comp_PRListingStatus, 
        compRating.prcw_Name, compRating.prra_AssignedRatingNumerals, dbo.ufn_GetPayReportCount(comp_CompanyID) As PayReportCount, 
        dbo.ufn_PrepareCompanyName(comp_PRCorrTradestyle) as PreparedName, comp_PRType, comp_PRHideLinkedInWidget, comp_PRHQID,
		comp_PRLegalName,
		comp_PRLocalSource,
		prst_StateID,
		CASE comp_PRLocalSource WHEN ''Y'' THEN prst_StateID ELSE NULL END as LocalSourceStateID,
        comp_PRPublishBBScore
FROM Company WITH (NOLOCK) 
        INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
        LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
        LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
        LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON comp_CompanyID = prcpi_CompanyID AND prcpi_Current=''Y'' 
        LEFT OUTER JOIN PRBBScore WITH (NOLOCK) ON comp_CompanyID = prbs_CompanyID AND prbs_Current=''Y'' 
        LEFT OUTER JOIN vCompanyEmail ws WITH (NOLOCK) ON comp_CompanyID = ws.ELink_RecordID AND ws.ELink_Type=''W'' AND ws.emai_PRPreferredPublished=''Y'' 
        LEFT OUTER JOIN vCompanyEmail em WITH (NOLOCK) ON comp_CompanyID = em.ELink_RecordID AND em.ELink_Type=''E'' AND em.emai_PRPreferredPublished=''Y'' 
        LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.PLink_RecordID AND phone.phon_PRIsPhone=''Y'' AND phone.phon_PRPreferredPublished=''Y'' 
        LEFT OUTER JOIN vPRCompanyPhone fax WITH (NOLOCK) ON comp_CompanyID = fax.PLink_RecordID AND fax.phon_PRIsFax=''Y'' AND fax.phon_PRPreferredPublished=''Y'' 
        LEFT OUTER JOIN vPRCompanyPhone tf WITH (NOLOCK) ON comp_CompanyID = tf.PLink_RecordID AND tf.PLink_Type=''TF'' AND tf.phon_PRPublish=''Y'''
EXEC usp_TravantCRM_CreateView 'vPRBBOSCompany', @Script, null, 0, null, null, null, 'Company' 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRBBOSCompanyLocalized AS 
SELECT comp_CompanyID, comp_PRCorrTradestyle, CityStateCountryShort,
        dbo.ufn_GetCustomCaptionValue(''comp_PRListingStatus'', comp_PRListingStatus, ISNULL(wu.prwu_Culture, ''en-us'')) As ListingStatus, comp_PRTMFMAward, 
        comp_PRTMFMAwardDate, comp_PRIndustryType, dbo.ufn_GetCustomCaptionValue(''comp_PRIndustryType'', comp_PRIndustryType, ISNULL(wu.prwu_Culture, ''en-us'')) As IndustryType, 
        dbo.ufn_GetCustomCaptionValue(''comp_PRType_BBOS'', comp_PRType, ISNULL(wu.prwu_Culture, ''en-us'')) As PRType, 
        comp_PRPublishPayIndicator, prcpi_PayIndicator, prcpi_CompanyPayIndicatorID, 
        CASE WHEN comp_PRType = ''B'' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN ''N'' ELSE ''Y'' END ELSE ''N'' END AS IsHQRating,
        CASE WHEN comp_PRType = ''B'' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingID ELSE hqRating.prra_RatingID END ELSE hqRating.prra_RatingID END AS prra_RatingID,
        CASE WHEN comp_PRType = ''B'' THEN CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_RatingLine ELSE hqRating.prra_RatingLine END ELSE hqRating.prra_RatingLine END AS prra_RatingLine,
        prbs_BBScore, prbs_PRPublish, 
        dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) As Phone, 
        dbo.ufn_FormatPhone(fax.phon_CountryCode, fax.phon_AreaCode, fax.phon_Number, fax.phon_PRExtension) As Fax, 
        dbo.ufn_FormatPhone(tf.phon_CountryCode, tf.phon_AreaCode, tf.phon_Number, tf.phon_PRExtension) As TollFree, 
        RTRIM(em.emai_EmailAddress) As Email, ws.emai_PRWebAddress, comp_PRLogo, comp_PRPublishLogo, comp_PRListingStatus, 
        compRating.prcw_Name, compRating.prra_AssignedRatingNumerals, dbo.ufn_GetPayReportCount(comp_CompanyID) As PayReportCount, 
        dbo.ufn_PrepareCompanyName(comp_PRCorrTradestyle) as PreparedName, comp_PRType, comp_PRHideLinkedInWidget, comp_PRHQID,
		comp_PRLegalName,
		comp_PRLocalSource,
		prst_StateID,
		CASE comp_PRLocalSource WHEN ''Y'' THEN prst_StateID ELSE NULL END as LocalSourceStateID,
		ISNULL(wu.prwu_Culture, ''en-us'') prwu_Culture,
		wu.prwu_WebUserID,
        comp_PRPublishBBScore
FROM Company WITH (NOLOCK) 
        INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
        LEFT OUTER JOIN vPRCurrentRating compRating ON comp_CompanyID = compRating.prra_CompanyID 
        LEFT OUTER JOIN vPRCurrentRating hqRating ON comp_PRHQID = hqRating.prra_CompanyID 
        LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON comp_CompanyID = prcpi_CompanyID AND prcpi_Current=''Y'' 
        LEFT OUTER JOIN PRBBScore WITH (NOLOCK) ON comp_CompanyID = prbs_CompanyID AND prbs_Current=''Y'' 
        LEFT OUTER JOIN vCompanyEmail ws WITH (NOLOCK) ON comp_CompanyID = ws.ELink_RecordID AND ws.ELink_Type=''W'' AND ws.emai_PRPreferredPublished=''Y'' 
        LEFT OUTER JOIN vCompanyEmail em WITH (NOLOCK) ON comp_CompanyID = em.ELink_RecordID AND em.ELink_Type=''E'' AND em.emai_PRPreferredPublished=''Y'' 
        LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.PLink_RecordID AND phone.phon_PRIsPhone=''Y'' AND phone.phon_PRPreferredPublished=''Y'' 
        LEFT OUTER JOIN vPRCompanyPhone fax WITH (NOLOCK) ON comp_CompanyID = fax.PLink_RecordID AND fax.phon_PRIsFax=''Y'' AND fax.phon_PRPreferredPublished=''Y'' 
        LEFT OUTER JOIN vPRCompanyPhone tf WITH (NOLOCK) ON comp_CompanyID = tf.PLink_RecordID AND tf.PLink_Type=''TF'' AND tf.phon_PRPublish=''Y''
		CROSS JOIN PRWebUser wu WITH (NOLOCK)'
		
EXEC usp_TravantCRM_CreateView 'vPRBBOSCompanyLocalized', @Script, null, 0, null, null, null, 'Company' 



--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBBOSPersonList AS 
SELECT peli_CompanyID, pers_PersonID, peli_PersonLinkID, RTRIM(pers_FirstName) As pers_FirstName, RTRIM(pers_LastName) as pers_LastName, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickname1, pers_Suffix) as PersonName, peli_PRTitle, RTRIM(emai_EmailAddress) As Email, 
    peli_PRTitleCode, tcc.capt_order as TitleCodeOrder,
	tcc.capt_us as GenericTitle,
	peli_PRSequence,
	ISNULL(ISNULL(pphone.phon_PRDescription, pcc.capt_us) + '': '' + dbo.ufn_FormatPhone(pphone.phon_CountryCode, pphone.phon_AreaCode, pphone.phon_Number, pphone.phon_PRExtension), ''Company: '' + dbo.ufn_FormatPhone(cphone.phon_CountryCode, cphone.phon_AreaCode, cphone.phon_Number, cphone.phon_PRExtension)) As Phone, 
	ISNULL(ISNULL(pfax.phon_PRDescription, fcc.capt_us) + '': '' + dbo.ufn_FormatPhone(pfax.phon_CountryCode, pfax.phon_AreaCode, pfax.phon_Number, pfax.phon_PRExtension), dbo.ufn_FormatPhone(cfax.phon_CountryCode, cfax.phon_AreaCode, cfax.phon_Number, cfax.phon_PRExtension)) As Fax,
	ROW_NUMBER() OVER (PARTITION BY peli_CompanyID ORDER BY peli_PRSequence) as DefaultSequence,
	peli_PRRole
FROM Person WITH (NOLOCK) 
	INNER JOIN Person_Link WITH (NOLOCK) on pers_PersonID = peli_PersonID 
	INNER JOIN custom_captions tcc WITH (NOLOCK) ON tcc.capt_family = ''pers_TitleCode'' and tcc.capt_code = peli_PRTitleCode 
	LEFT OUTER JOIN vPRPersonEmail em WITH (NOLOCK) ON peli_PersonID = em.ELink_RecordID AND peli_CompanyID = emai_CompanyID AND em.ELink_Type=''E'' AND em.emai_PRPreferredPublished=''Y'' 
	LEFT OUTER JOIN vPRCompanyPhone cfax WITH (NOLOCK) ON peli_CompanyID = cfax.PLink_RecordID AND cfax.phon_PRIsFax = ''Y'' AND cfax.phon_PRPreferredPublished = ''Y''  
	LEFT OUTER JOIN vPRCompanyPhone cphone WITH (NOLOCK) ON peli_CompanyID = cphone.PLink_RecordID AND cphone.phon_PRIsPhone = ''Y'' AND cphone.phon_PRPreferredPublished = ''Y''  
	LEFT OUTER JOIN vPRPersonPhone pfax WITH (NOLOCK) ON peli_PersonID = pfax.PLink_RecordID AND peli_CompanyID = pfax.phon_CompanyID AND pfax.phon_PRIsFax = ''Y'' AND pfax.phon_PRPreferredPublished = ''Y''  
	LEFT OUTER JOIN Custom_Captions fcc WITH (NOLOCK) ON fcc.capt_family = ''Phon_TypePerson'' and fcc.capt_code = pfax.PLink_Type 
	LEFT OUTER JOIN vPRPersonPhone pphone WITH (NOLOCK) ON  peli_PersonID = pphone.PLink_RecordID AND peli_CompanyID = pphone.phon_CompanyID AND pphone.phon_PRIsPhone = ''Y'' AND pphone.phon_PRPreferredPublished = ''Y''  
	LEFT OUTER JOIN Custom_Captions pcc WITH (NOLOCK)  ON pcc.capt_family = ''Phon_TypePerson'' and pcc.capt_code = pphone.PLink_Type 
WHERE peli_PRStatus = ''1'' 
AND peli_PREBBPublish = ''Y'''
exec usp_TravantCRM_CreateView 'vPRBBOSPersonList', @Script, null, 0, null, null, null, 'Person' 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRWebUser AS 
SELECT prwu_WebUserID,
       prwu_LastName + '', '' + prwu_FirstName as PersonName, 
       prwu_LastName, prwu_FirstName, prwu_CompanyName, prwu_Email,
       prwu_LastLoginDateTime, prwu_LoginCount,      prwu_Disabled,
       prwu_IndustryTypeCode, prwu_gender,
       IsMember = CASE WHEN (prwu_AccessLevel > 100) THEN ''Y'' ELSE ''N'' END,
       IsTrial = CASE WHEN prwu_TrialExpirationDate IS NULL THEN ''N'' ELSE ''Y'' END, 
       prwu_TrialExpirationDate,
       prwu_Culture, prwu_TitleCode, prwu_IndustryClassification, prwu_CompanySize,                        
       prwu_AccessLevel, prwu_PersonLinkID, prwu_MembershipInterest, prwu_Website,         
       prwu_PhoneAreaCode,  prwu_PhoneNumber, prwu_FaxAreaCode, prwu_FaxNumber,          
       prwu_Address1, prwu_Address2, prwu_City, prwu_StateID, prwu_PostalCode,
       prwu_CountryID, prwu_howlearned, 
	   prwu_SecurityDisabled,
	   prwu_SecurityDisabledDate,
	   prwu_SecurityDisabledReason
  FROM PRWebUser WITH (NOLOCK) 
 WHERE prwu_AccessLevel is not null' 
exec usp_TravantCRM_CreateView 'vPRWebUser', @Script 


exec usp_TravantCRM_AddCustom_Captions 'Tags', 'ColNames', 'PurchaseAmount_2Year', 0, 'Total Purchased in Past 2 Years'
exec usp_TravantCRM_AddCustom_Captions 'Tags', 'ColNames', 'PurchaseAmount_Total', 0, 'Total Purchased'



-- PRWebUser Purchases
SET @Script = 
'CREATE VIEW dbo.vPRWebUserPurchase AS ' +
'select prreq_RequestId, prreq_CreatedDate, prreq_Price, prreq_CompanyId, prreq_HQID, prreq_WebUserId, ' +
'(select count(1) from PRRequestDetail WHERE prrc_RequestId = prreq.prreq_RequestId) AS CompanyCount, ' +
'cast(cc1.capt_US as varchar(100) ) AS RequestTypeDesc ' +
'from PRRequest prreq WITH (NOLOCK) ' +
'JOIN custom_captions cc1 WITH (NOLOCK) ON capt_family = ''prreq_RequestTypeCode'' and capt_code = prreq_RequestTypeCode ' 
exec usp_TravantCRM_CreateView 'vPRWebUserPurchase', @Script 
exec usp_TravantCRM_DefineCaptions  'vPRWebUserPurchase', 'Purchase', 'Purchases', NULL, NULL, NULL, NULL
exec usp_TravantCRM_AddCustom_Captions 'Tags', 'ColNames', 'RequestTypeDesc', 0, 'Request Type'
exec usp_TravantCRM_AddCustom_Captions 'Tags', 'ColNames', 'CompanyCount', 0, 'Number of Companies'

--DECLARE @Script VARCHAR(MAX)
SET @Script = 
'CREATE VIEW dbo.vPRWebSiteUsersListing AS 
SELECT DISTINCT comp_PRHQId,  
       dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix, 0) AS Pers_FullName,  
       PeLi_PersonLinkId, PeLi_PersonId, peli_PRTitle, dbo.ufn_GetCustomCaptionValue(''pers_TitleCode'', peli_PRTitleCode, ''en-us'') AS peli_Title,  
       prwu_WebUserID, prwu_AccessLevel, prwu_LastLoginDateTime, dbo.ufn_GetCustomCaptionValue(''prwu_AccessLevel'', prwu_AccessLevel, ''en-us'') AS AccessLevelDesc,  
       Emai_EmailAddress, CityStateCountryShort AS location, prwu_ServiceCode,
       ISNULL(prod_PRWebAccessLevel, 0) As MaxAccessLevel,
       (SELECT COUNT(1) FROM PRWebUser prwu2 WITH (NOLOCK) WHERE prwu2.prwu_Disabled IS NULL AND prwu2.prwu_Email = emai_EmailAddress AND prwu2.prwu_PersonLinkID <> peli_PersonLinkID
	                AND prwu_BBID NOT IN (SELECT prcr_LeftCompanyId FROM PRCompanyRelationship WHERE prcr_Type = ''36'' AND prcr_Active = ''Y'') AND prwu_BBID NOT IN (SELECT prcr_RightCompanyId FROM PRCompanyRelationship WHERE prcr_Type = ''36'' AND prcr_Active = ''Y'')
	          ) As ExistingEmailAddressCount,
       prod_ProductFamilyID, prwu_TrialExpirationDate,
	   AUSSubjectCount, AUSSentCount, AUSLastReportDate
FROM Person_Link WITH (NOLOCK)  
     INNER JOIN Person WITH (NOLOCK) ON Pers_PersonId = PeLi_PersonId  
     INNER JOIN Company WITH (NOLOCK) ON PeLi_CompanyID = Company.Comp_CompanyId  
     INNER JOIN vPRCompanyLocation ON vPRCompanyLocation.Comp_CompanyId = Company.Comp_CompanyId   
     LEFT OUTER JOIN PRWebUser WITH (NOLOCK) ON PeLi_PersonLinkId = PRWebUser.prwu_PersonLinkID  
	 LEFT OUTER JOIN vPRPersonEmail as EM WITH (NOLOCK) ON Pers_PersonId = EM.elink_RecordID AND EM.Emai_CompanyID = PeLi_CompanyID AND EM.ELink_Type = ''E'' 
     LEFT OUTER JOIN NewProduct ON prod_code = prwu_ServiceCode AND prod_Productfamilyid IN (6,14)
     LEFT OUTER JOIN (SELECT prwucl_WebUserID, COUNT(DISTINCT prwuld_AssociatedID) As AUSSubjectCount
					  FROM PRWebUserList WITH (NOLOCK)
						   INNER JOIN PRWebUserListDetail ON prwucl_WebUserListID = prwuld_WebUserListID
					 WHERE prwucl_TypeCode = ''AUS''
					GROUP BY prwucl_WebUserID) T1 ON T1.prwucl_WebUserID = prwu_WebUserID
	 LEFT OUTER JOIN (SELECT prcoml_PersonID, COUNT(1) AUSSentCount, MAX(prcoml_CreatedDate) as AUSLastReportDate
					  FROM PRCommunicationLog 
					 WHERE prcoml_Source = ''AUS Report Event''
					   AND prcoml_CreatedDate >= DATEADD(month, -12, GETDATE())
					GROUP BY prcoml_PersonID)  T2 ON T2.prcoml_PersonID = peli_PersonID
WHERE Pers_Deleted IS NULL 
  AND PeLi_Deleted IS NULL 
  AND peli_PRStatus IN (1,2);'
exec usp_TravantCRM_CreateView 'vPRWebSiteUsersListing', @Script 

--DECLARE @Script VARCHAR(MAX)
SET @Script = 
'CREATE VIEW dbo.vPRCompanyContactExportMSO AS 
SELECT DISTINCT comp_CompanyId AS [OrganizationalIDNumber], 
 	   comp_PRCorrTradestyle AS [Company], 
 	   RTRIM(MailAddr.Addr_Address1) AS [BusinessStreet], 
 	   RTRIM(MailAddr.Addr_Address2) AS [BusinessStreet2],  	   
 	   MailLocation.prci_City AS [BusinessCity],   
 	   ISNULL(MailLocation.prst_Abbreviation, MailLocation.prst_State) AS [BusinessState], 
 	   MailAddr.Addr_PostCode AS [BusinessPostalCode], 
 	   MailLocation.prcn_Country AS [BusinessCountry], 
 	   RTRIM(PhysicalAddr.Addr_Address1) AS [OtherStreet], 
 	   RTRIM(PhysicalAddr.Addr_Address2) AS [OtherStreet2], 
 	   PhysicalLocation.prci_City AS [OtherCity], 
 	   ISNULL(PhysicalLocation.prst_Abbreviation, PhysicalLocation.prst_State) AS [OtherState], 
 	   PhysicalAddr.Addr_PostCode AS [OtherPostalCode], 
 	   PhysicalLocation.prcn_Country AS [OtherCountry], 
 	   dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension) As [CompanyMainPhone], 
 	   dbo.ufn_FormatPhone(fax.phon_CountryCode, fax.phon_AreaCode, fax.phon_Number, fax.phon_PRExtension) As [BusinessFax], 
 	   RTRIM(EM.Emai_EmailAddress) AS [E-mailAddress], 
 	   RTRIM(WS.emai_PRWebAddress) AS [WebPage] 
 FROM Company WITH (NOLOCK) 
      LEFT OUTER JOIN Address_Link MailAddrLink WITH (NOLOCK) ON comp_CompanyID = MailAddrLink.adli_CompanyID AND MailAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, ''M'') 
 	  LEFT OUTER JOIN Address MailAddr WITH (NOLOCK) ON MailAddrLink.adli_AddressID = MailAddr.addr_AddressID 
 	  LEFT OUTER JOIN vPRLocation MailLocation WITH (NOLOCK) ON MailAddr.addr_PRCityID = MailLocation.prci_CityID 
 	  LEFT OUTER JOIN Address_Link PhysicalAddrLink WITH (NOLOCK) ON comp_CompanyID = PhysicalAddrLink.adli_CompanyID AND PhysicalAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, ''PH'') 
 	  LEFT OUTER JOIN Address PhysicalAddr WITH (NOLOCK) ON PhysicalAddrLink.adli_AddressID = PhysicalAddr.addr_AddressID 
 	  LEFT OUTER JOIN vPRLocation PhysicalLocation ON PhysicalAddr.addr_PRCityID = PhysicalLocation.prci_CityID 
	  LEFT OUTER JOIN vCompanyEmail as WS WITH (NOLOCK) ON comp_CompanyID = WS.elink_RecordID AND WS.ELink_Type = ''W'' AND WS.emai_PRPreferredPublished=''Y'' 
	  LEFT OUTER JOIN vCompanyEmail as EM WITH (NOLOCK) ON comp_CompanyID = EM.elink_RecordID AND EM.ELink_Type = ''E'' AND EM.emai_PRPreferredPublished=''Y'' 
 	  LEFT OUTER JOIN vPRCompanyPhone fax WITH (NOLOCK) ON comp_CompanyID = fax.plink_RecordID AND  fax.phon_PRIsFax = ''Y'' AND fax.phon_PRPreferredPublished = ''Y''
	  LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON comp_CompanyID = phone.plink_RecordID AND  phone.phon_PRIsPhone = ''Y'' AND phone.phon_PRPreferredPublished = ''Y'''
exec usp_TravantCRM_CreateView 'vPRCompanyContactExportMSO', @Script 

-- DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRContactExportAllMSO AS 
SELECT distinct comp_CompanyId AS [OrganizationalIDNumber], 
	comp_PRCorrTradestyle AS [Company], 
	RTRIM(pers_FirstName) AS [FirstName], 
	RTRIM(pers_MiddleName) AS [MiddleName], 
	RTRIM(pers_LastName) AS [LastName], 
	RTRIM(pers_Suffix) AS [Suffix], 
	peli_PRTitle AS [Title], 
	RTRIM(MailAddr.Addr_Address1) AS [BusinessStreet], 
    RTRIM(MailAddr.Addr_Address2) AS [BusinessStreet2], 
	RTRIM(MailLocation.prci_City) AS [BusinessCity], 
	RTRIM(ISNULL(MailLocation.prst_Abbreviation, MailLocation.prst_State)) AS [BusinessState], 
	RTRIM(MailAddr.Addr_PostCode) AS [BusinessPostalCode], 
	RTRIM(MailLocation.prcn_Country) AS [BusinessCountry], 
	RTRIM(PhysicalAddr.Addr_Address1) AS [OtherStreet], 	   
	RTRIM(PhysicalAddr.Addr_Address2) AS [OtherStreet2], 
	RTRIM(PhysicalLocation.prci_City) AS [OtherCity],        
	RTRIM(ISNULL(PhysicalLocation.prst_Abbreviation, PhysicalLocation.prst_State)) AS [OtherState], 
	RTRIM(PhysicalAddr.Addr_PostCode) AS [OtherPostalCode], 
	RTRIM(PhysicalLocation.prcn_Country) AS [OtherCountry], 
    dbo.ufn_FormatPhone(cphone.phon_CountryCode, cphone.phon_AreaCode, cphone.phon_Number, cphone.phon_PRExtension) AS [CompanyMainPhone],  
    dbo.ufn_FormatPhone(cfax.phon_CountryCode, cfax.phon_AreaCode, cfax.phon_Number, cfax.phon_PRExtension) AS [CompanyFax],  
    dbo.ufn_FormatPhone(pphone.phon_CountryCode, pphone.phon_AreaCode, pphone.phon_Number, pphone.phon_PRExtension) AS [BusinessPhone],  
    dbo.ufn_FormatPhone(pfax.phon_CountryCode, pfax.phon_AreaCode, pfax.phon_Number, pfax.phon_PRExtension) AS [BusinessFax],  
	RTRIM(emai_EmailAddress) AS [E-mailAddress]
FROM Company WITH (NOLOCK) 
	LEFT OUTER JOIN Address_Link MailAddrLink WITH (NOLOCK) ON comp_CompanyID = MailAddrLink.adli_CompanyID  AND MailAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, ''M'') 
	LEFT OUTER JOIN Address MailAddr WITH (NOLOCK) ON MailAddrLink.adli_AddressID = MailAddr.addr_AddressID  
	LEFT OUTER JOIN vPRLocation MailLocation WITH (NOLOCK) ON MailAddr.addr_PRCityID = MailLocation.prci_CityID 
	LEFT OUTER JOIN Address_Link PhysicalAddrLink WITH (NOLOCK) ON comp_CompanyID = PhysicalAddrLink.adli_CompanyID  AND PhysicalAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, ''PH'') 
	LEFT OUTER JOIN Address PhysicalAddr WITH (NOLOCK) ON PhysicalAddrLink.adli_AddressID = PhysicalAddr.addr_AddressID  
	LEFT OUTER JOIN vPRLocation PhysicalLocation ON PhysicalAddr.addr_PRCityID = PhysicalLocation.prci_CityID 
	LEFT OUTER JOIN Person_Link WITH (NOLOCK) on comp_CompanyID = peli_CompanyID AND peli_PRStatus = ''1'' AND peli_PREBBPublish = ''Y''  
	LEFT OUTER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
	LEFT OUTER JOIN vPRPersonEmail WITH (NOLOCK) ON peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID AND ELink_Type = ''E'' AND emai_PRPreferredPublished=''Y'' 
	LEFT OUTER JOIN vPRCompanyPhone cfax WITH (NOLOCK) ON peli_CompanyID = cfax.plink_RecordID AND  cfax.phon_PRIsFax = ''Y'' AND cfax.phon_PRPreferredPublished = ''Y''
    LEFT OUTER JOIN vPRCompanyPhone cphone WITH (NOLOCK) ON peli_CompanyID = cphone.plink_RecordID AND  cphone.phon_PRIsPhone = ''Y'' AND cphone.phon_PRPreferredPublished = ''Y''
    LEFT OUTER JOIN vPRPersonPhone pfax WITH (NOLOCK) ON peli_PersonID = pfax.plink_RecordID AND peli_CompanyID = pfax.phon_CompanyID AND pfax.phon_PRIsFax = ''Y'' AND pfax.phon_PRPreferredPublished = ''Y''
    LEFT OUTER JOIN vPRPersonPhone pphone WITH (NOLOCK) ON peli_PersonID = pphone.plink_RecordID AND peli_CompanyID = pphone.phon_CompanyID AND pphone.phon_PRIsPhone = ''Y'' AND pphone.phon_PRPreferredPublished = ''Y'''
exec usp_TravantCRM_CreateView 'vPRContactExportAllMSO', @Script 

-- DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRContactExportHEMSO AS 
SELECT distinct comp_CompanyId AS [OrganizationalIDNumber], 
	comp_PRCorrTradestyle AS [Company], 
	RTRIM(pers_FirstName) AS [FirstName], 
	RTRIM(pers_MiddleName) AS [MiddleName], 
	RTRIM(pers_LastName) AS [LastName], 
	RTRIM(pers_Suffix) AS [Suffix], 
	peli_PRTitle AS [Title], 
	RTRIM(MailAddr.Addr_Address1) AS [BusinessStreet], 
    RTRIM(MailAddr.Addr_Address2) AS [BusinessStreet2], 
	RTRIM(MailLocation.prci_City) AS [BusinessCity], 
	RTRIM(ISNULL(MailLocation.prst_Abbreviation, MailLocation.prst_State)) AS [BusinessState], 
	RTRIM(MailAddr.Addr_PostCode) AS [BusinessPostalCode], 
	RTRIM(MailLocation.prcn_Country) AS [BusinessCountry], 
	RTRIM(PhysicalAddr.Addr_Address1) AS [OtherStreet], 	   
	RTRIM(PhysicalAddr.Addr_Address2) AS [OtherStreet2], 
	RTRIM(PhysicalLocation.prci_City) AS [OtherCity],        
	RTRIM(ISNULL(PhysicalLocation.prst_Abbreviation, PhysicalLocation.prst_State)) AS [OtherState], 
	RTRIM(PhysicalAddr.Addr_PostCode) AS [OtherPostalCode], 
	RTRIM(PhysicalLocation.prcn_Country) AS [OtherCountry], 
    dbo.ufn_FormatPhone(cphone.phon_CountryCode, cphone.phon_AreaCode, cphone.phon_Number, cphone.phon_PRExtension) AS [CompanyMainPhone],  
    dbo.ufn_FormatPhone(cfax.phon_CountryCode, cfax.phon_AreaCode, cfax.phon_Number, cfax.phon_PRExtension) AS [CompanyFax],  
    dbo.ufn_FormatPhone(pphone.phon_CountryCode, pphone.phon_AreaCode, pphone.phon_Number, pphone.phon_PRExtension) AS [BusinessPhone],  
    dbo.ufn_FormatPhone(pfax.phon_CountryCode, pfax.phon_AreaCode, pfax.phon_Number, pfax.phon_PRExtension) AS [BusinessFax],  
	RTRIM(emai_EmailAddress) AS [E-mailAddress]
FROM Company WITH (NOLOCK) 
	LEFT OUTER JOIN Address_Link MailAddrLink WITH (NOLOCK) ON comp_CompanyID = MailAddrLink.adli_CompanyID  AND MailAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, ''M'')
	LEFT OUTER JOIN Address MailAddr WITH (NOLOCK) ON MailAddrLink.adli_AddressID = MailAddr.addr_AddressID  
	LEFT OUTER JOIN vPRLocation MailLocation WITH (NOLOCK) ON MailAddr.addr_PRCityID = MailLocation.prci_CityID 
	LEFT OUTER JOIN Address_Link PhysicalAddrLink WITH (NOLOCK) ON comp_CompanyID = PhysicalAddrLink.adli_CompanyID  AND PhysicalAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, ''PH'') 
	LEFT OUTER JOIN Address PhysicalAddr WITH (NOLOCK) ON PhysicalAddrLink.adli_AddressID = PhysicalAddr.addr_AddressID  
	LEFT OUTER JOIN vPRLocation PhysicalLocation ON PhysicalAddr.addr_PRCityID = PhysicalLocation.prci_CityID 
	LEFT OUTER JOIN Person_Link WITH (NOLOCK) on comp_CompanyID = peli_CompanyID AND peli_PRStatus = ''1'' AND peli_PREBBPublish = ''Y''  AND peli_PRRole LIKE ''%,HE,%''    
	LEFT OUTER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID 
	LEFT OUTER JOIN vPRPersonEmail WITH (NOLOCK) ON  peli_PersonID = elink_RecordID AND peli_CompanyID = emai_CompanyID AND ELink_Type = ''E'' AND emai_PRPreferredPublished=''Y'' 
	LEFT OUTER JOIN vPRCompanyPhone cfax WITH (NOLOCK) ON peli_CompanyID = cfax.plink_RecordID AND  cfax.phon_PRIsFax = ''Y'' AND cfax.phon_PRPreferredPublished = ''Y''
    LEFT OUTER JOIN vPRCompanyPhone cphone WITH (NOLOCK) ON peli_CompanyID = cphone.plink_RecordID AND  cphone.phon_PRIsPhone = ''Y'' AND cphone.phon_PRPreferredPublished = ''Y''
    LEFT OUTER JOIN vPRPersonPhone pfax WITH (NOLOCK) ON peli_PersonID = pfax.plink_RecordID AND peli_CompanyID = pfax.phon_CompanyID AND pfax.phon_PRIsFax = ''Y'' AND pfax.phon_PRPreferredPublished = ''Y''
    LEFT OUTER JOIN vPRPersonPhone pphone WITH (NOLOCK) ON peli_PersonID = pphone.plink_RecordID AND peli_CompanyID = pphone.phon_CompanyID AND pphone.phon_PRIsPhone = ''Y'' AND pphone.phon_PRPreferredPublished = ''Y'''
exec usp_TravantCRM_CreateView 'vPRContactExportHEMSO', @Script 


-- vPRCompanyProductProvided 
SET @Script = 
'CREATE VIEW dbo.vPRCompanyProductProvided ' + 
'AS '+
'SELECT PRProductProvided.*, prcprpr_CompanyID ' + 
'  FROM PRCompanyProductProvided  ' + 
'       INNER JOIN PRProductProvided ON prcprpr_ProductProvidedID = prprpr_ProductProvidedID;';
exec usp_TravantCRM_CreateView 'vPRCompanyProductProvided', @Script 

-- vPRCompanyServiceProvided  
SET @Script = 
'CREATE VIEW dbo.vPRCompanyServiceProvided ' + 
'AS '+
'SELECT PRServiceProvided.*, prcserpr_CompanyID '+
  'FROM PRServiceProvided '+
'       INNER JOIN PRCompanyServiceProvided ON prserpr_ServiceProvidedID = prcserpr_ServiceProvidedID;';
exec usp_TravantCRM_CreateView 'vPRCompanyServiceProvided', @Script 


-- vPRCompanySpecie   
SET @Script = 
'CREATE VIEW dbo.vPRCompanySpecie ' + 
'AS '+
'SELECT PRSpecie.*, prcspc_CompanyID '+
'  FROM PRCompanySpecie '+ 
'       INNER JOIN PRSpecie ON prcspc_SpecieID = prspc_SpecieID;';
exec usp_TravantCRM_CreateView 'vPRCompanySpecie', @Script 


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRCompanyAttentionLine AS  
SELECT prattn_AttentionLineID,  
       prattn_CompanyID, 
       prattn_ItemCode, 
       capt_us As Item,  
       capt_order As ItemOrder,  
       prattn_AddressID, 
       prattn_PhoneID, 
	   prattn_EmailID, 
       prattn_BBOSOnly, 
       prattn_PersonID, 
       prattn_Disabled, 
       ISNULL(ISNULL(prattn_CustomLine, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, null, pers_Suffix)), '''') As Addressee, 
       CASE WHEN prattn_BBOSOnly = ''Y'' THEN ''BBOS'' ELSE  ISNULL(ISNULL(emai_EmailAddress, dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension)), dbo.ufn_FormatAddress2('' '', addr_Address1,addr_Address2,addr_Address3,addr_Address4,addr_Address5,prci_City,ISNULL(prst_Abbreviation, prst_State), prcn_Country, addr_PostCode)) END As DeliveryAddress,
	   prattn_IncludeWireTransferInstructions
  FROM PRAttentionLine WITH (NOLOCK) 
       INNER JOIN Custom_Captions WITH (NOLOCK) on prattn_ItemCode = capt_code and capt_family = ''prattn_ItemCode'' 
       LEFT OUTER JOIN Person WITH (NOLOCK) ON prattn_PersonID = pers_PersonID 
       LEFT OUTER JOIN Address_Link WITH (NOLOCK) ON prattn_CompanyID = adli_CompanyID AND prattn_AddressID = adli_AddressID 
       LEFT OUTER JOIN Address WITH (NOLOCK) on prattn_AddressID = addr_AddressID 
       LEFT OUTER JOIN vPRLocation ON addr_PRCityID = prci_CityID 
       LEFT OUTER JOIN Email WITH (NOLOCK) ON prattn_EmailID = emai_EmailID 
       LEFT OUTER JOIN Phone WITH (NOLOCK) ON prattn_PhoneID = phon_PhoneID'
exec usp_TravantCRM_CreateView 'vPRCompanyAttentionLine', @Script 




-- vPRTradeReportLastResponse  
SET @Script = 
'CREATE VIEW dbo.vPRTradeReportLastResponse  ' + 
'AS '+
'SELECT prtr_SubjectID, '+
'       prtr_ResponderID, '+
'       MAX(prtr_Date) as [LastFormResponse] '+
'  FROM PRTradeReport '+
'GROUP BY prtr_SubjectID, prtr_ResponderID;';
exec usp_TravantCRM_CreateView 'vPRTradeReportLastResponse ', @Script 

-- vPRTESLastFormSent  
SET @Script = 
'CREATE VIEW dbo.vPRTESLastFormSent ' + 
'AS '+
'SELECT prtesr_ResponderCompanyID, '+
'       prtesr_SubjectCompanyID, '+
'       MAX(prtesr_CreatedDate) as [LastFormSent] '+
'  FROM PRTESRequest '+
'GROUP BY prtesr_ResponderCompanyID, prtesr_SubjectCompanyID;';
exec usp_TravantCRM_CreateView 'vPRTESLastFormSent', @Script 


-- vPRCompanyRelationshipRCR  
--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRCompanyRelationshipRCR 
AS 
SELECT prcr_CompanyRelationshipId, 
       prcr_RightCompanyID, 
       prcr_LeftCompanyID, 
       prcse_FullName as CompanyName, 
       LastFormSent, 
       LastFormResponse, 
       prcr_LastReportedDate, 
       prcr_Active, 
       prcr_Type, 
       dbo.ufn_GetCustomCaptionValue(''prcr_TypeFilter'', prcr_Type, DEFAULT) As  TypeDisplay, 
       comp_PRListingStatus, 
       comp_PRIndustryType, 
       CASE WHEN (prcr_Type IN (1, 4, 5, 7)) THEN 1  
            WHEN (prcr_Type IN (9, 10, 11, 12, 13, 14, 15, 16)) THEN 2  
            WHEN (prcr_Type IN (23, 24)) THEN 3  
            WHEN (prcr_Type IN (27, 28, 29)) THEN 4  
            WHEN (prcr_Type IN (30, 31, 32)) THEN 5  
            WHEN (prcr_Type IN (33, 34)) THEN 6  
            ELSE NULL END AS prcr_CategoryType, 
       tes_e.DeliveryAddress as TES_E_DeliveryAddress, 
	   tes_v.DeliveryAddress as TES_V_DeliveryAddress, 
       comp_PRReceiveTES, 
       dbo.ufn_IsEligibleForManualTES(prcr_LeftCompanyID, prcr_RightCompanyID) As EligibleForTES, 
       comp_PRTESNonresponder,
	   comp_PRReceiveTESCode
  FROM PRCompanyRelationship WITH (NOLOCK) 
       INNER JOIN Company WITH (NOLOCK) on comp_CompanyID = prcr_LeftCompanyID 
       INNER JOIN PRCompanySearch WITH (NOLOCK) on prcse_CompanyID = prcr_LeftCompanyID 
       LEFT OUTER JOIN vPRCompanyAttentionLine tes_e ON tes_e.prattn_CompanyID = prcr_LeftCompanyID 
	                                          AND tes_e.prattn_ItemCode = ''TES-E'' 
											  AND tes_e.prattn_Disabled IS NULL
       LEFT OUTER JOIN vPRCompanyAttentionLine tes_v ON tes_v.prattn_CompanyID = prcr_LeftCompanyID 
	                                          AND tes_v.prattn_ItemCode = ''TES-V'' 
											  AND tes_v.prattn_Disabled IS NULL

       LEFT OUTER JOIN vPRTESLastFormSent ON prtesr_ResponderCompanyID = prcr_LeftCompanyID  
                                         AND prtesr_SubjectCompanyID = prcr_RightCompanyID 
       LEFT OUTER JOIN vPRTradeReportLastResponse ON prtr_ResponderID = prcr_LeftCompanyID  
                                                 AND prtr_SubjectID = prcr_RightCompanyID 
 WHERE prcr_Type NOT IN (27, 28, 29);';
exec usp_TravantCRM_CreateView 'vPRCompanyRelationshipRCR', @Script 



-- vPRCompanyRelationshipSCR
--DECLARE @Script varchar(max)   
SET @Script = 
'CREATE VIEW dbo.vPRCompanyRelationshipSCR 
AS 
SELECT prcr_CompanyRelationshipId, 
       prcr_LeftCompanyID, 
       prcr_RightCompanyID, 
       prcse_FullName as CompanyName, 
       LastFormSent, 
       LastFormResponse, 
       prcr_LastReportedDate, 
       prcr_Active, 
       prcr_Type,  
       dbo.ufn_GetCustomCaptionValue(''prcr_TypeFilter'', prcr_Type, DEFAULT) As  TypeDisplay, 
       comp_PRListingStatus, 
       comp_PRIndustryType, 
       CASE WHEN (prcr_Type IN (1, 4, 5, 7)) THEN 1  
            WHEN (prcr_Type IN (9, 10, 11, 12, 13, 14, 15, 16)) THEN 2  
            WHEN (prcr_Type IN (23, 24)) THEN 3  
            WHEN (prcr_Type IN (27, 28, 29)) THEN 4  
            WHEN (prcr_Type IN (30, 31, 32)) THEN 5  
            WHEN (prcr_Type IN (33, 34)) THEN 6  
            ELSE NULL END AS prcr_CategoryType, 
       tes_e.DeliveryAddress as TES_E_DeliveryAddress, 
	   tes_v.DeliveryAddress as TES_V_DeliveryAddress, 
       comp_PRReceiveTES, 
       dbo.ufn_IsEligibleForManualTES(prcr_RightCompanyID, prcr_LeftCompanyID) As EligibleForTES, 
       comp_PRTESNonresponder,
	   comp_PRReceiveTESCode
  FROM PRCompanyRelationship WITH (NOLOCK) 
       INNER JOIN Company WITH (NOLOCK) on comp_CompanyID = prcr_RightCompanyID 
       INNER JOIN PRCompanySearch WITH (NOLOCK) on prcse_CompanyID = prcr_RightCompanyID 
       LEFT OUTER JOIN vPRCompanyAttentionLine tes_e ON tes_e.prattn_CompanyID = prcr_RightCompanyID 
	                                          AND tes_e.prattn_ItemCode = ''TES-E'' 
											  AND tes_e.prattn_Disabled IS NULL
       LEFT OUTER JOIN vPRCompanyAttentionLine tes_v ON tes_v.prattn_CompanyID = prcr_RightCompanyID 
	                                          AND tes_v.prattn_ItemCode = ''TES-V'' 
											  AND tes_v.prattn_Disabled IS NULL
       LEFT OUTER JOIN vPRTESLastFormSent ON prtesr_ResponderCompanyID = prcr_RightCompanyID  
                                         AND prtesr_SubjectCompanyID = prcr_LeftCompanyID 
       LEFT OUTER JOIN vPRTradeReportLastResponse ON prtr_ResponderID = prcr_RightCompanyID  
                                                 AND prtr_SubjectID = prcr_LeftCompanyID 
WHERE prcr_Type NOT IN (27, 28, 29);';
exec usp_TravantCRM_CreateView 'vPRCompanyRelationshipSCR', @Script 



SET @Script = 
'CREATE VIEW dbo.vPRCompanyRelationshipInfo ' + 
'AS ' +
'SELECT comp_CompanyID, comp_PRConnectionListDate, COUNT(DISTINCT CompanyID) As UniqueRelationshipCount ' +
'  FROM Company WITH (NOLOCK) ' +
'       CROSS APPLY dbo.ufn_GetCompanyRelationships(comp_CompanyID) ' +
'GROUP BY comp_CompanyID, comp_PRConnectionListDate;';
exec usp_TravantCRM_CreateView 'vPRCompanyRelationshipInfo', @Script 

--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRCompanyOwnership
AS 
SELECT prcr_CompanyRelationshipId, 
       prcr_LeftCompanyID, b.prcse_FullName As LeftCompanyName, bls.capt_us as LeftListingStatus, br.prra_RatingLine as LeftRating,
       prcr_RightCompanyID, a.prcse_FullName As RightCompanyName, als.capt_us as RightListingStatus, ar.prra_RatingLine as RightRating,
	   prcr_Type, prcr_OwnershipPct, prcr_Active 
  FROM PRCompanyRelationship WITH (NOLOCK) 
       INNER JOIN PRCompanySearch a WITH (NOLOCK) ON prcr_RightCompanyID = a.prcse_CompanyID
	   INNER JOIN Company ac WITH (NOLOCK) ON prcr_RightCompanyID = ac.comp_CompanyID
	   INNER JOIN Custom_Captions als ON ac.comp_PRListingStatus = als.capt_code AND als.capt_family = ''comp_PRListingStatus''
	   LEFT OUTER JOIN vPRCompanyRating ar ON prcr_RightCompanyID = ar.prra_CompanyID AND ar.prra_Current = ''Y''
       INNER JOIN PRCompanySearch b WITH (NOLOCK) ON prcr_LeftCompanyID = b.prcse_CompanyID 
	   INNER JOIN Company bc WITH (NOLOCK) ON prcr_LeftCompanyID = bc.comp_CompanyID
	   INNER JOIN Custom_Captions bls ON bc.comp_PRListingStatus = bls.capt_code AND bls.capt_family = ''comp_PRListingStatus''
	   LEFT OUTER JOIN vPRCompanyRating br ON prcr_LeftCompanyID = br.prra_CompanyID AND br.prra_Current = ''Y''
WHERE prcr_Type IN (''27'', ''28'')';
EXEC usp_TravantCRM_CreateView 'vPRCompanyOwnership', @Script 

--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRCompanyAffiliations 
AS 
SELECT a.*, Company.comp_CompanyID, capt_us as comp_PRListingStatus, prra_RatingLine
  FROM Company WITH (NOLOCK) 
       CROSS APPLY dbo.ufn_GetCompanyAffiliations(comp_CompanyID) a
	   INNER JOIN Company affiliate WITH (NOLOCK) ON CompanyID = affiliate.comp_CompanyID
	   INNER JOIN Custom_Captions ON affiliate.comp_PRListingStatus = capt_code AND capt_family = ''comp_PRListingStatus''
	   LEFT OUTER JOIN vPRCompanyRating ON CompanyID = prra_CompanyID AND prra_Current = ''Y'';';
EXEC usp_TravantCRM_CreateView 'vPRCompanyAffiliations', @Script

SET @Script = 
'CREATE VIEW dbo.vPRCoAccountTeam As ' +
'Select Comp_CompanyId ' +
'       , Comp_PRIndustryType ' +
'       , Case Comp_PRIndustryType When ''L'' Then prci_LumberListingSpecialistId Else prci_ListingSpecialistId End As prci_ListingSpecialistId ' +
'       , Case Comp_PRIndustryType When ''L'' Then prci_LumberRatingUserId Else prci_RatingUserId End As prci_RatingUserId ' +
'       , Case Comp_PRIndustryType When ''L'' Then prci_LumberCustomerServiceId Else prci_CustomerServiceId End As prci_CustomerServiceId ' +
'       , Case Comp_PRIndustryType When ''L'' Then prci_LumberInsideSalesRepId Else prci_InsideSalesRepId End As prci_InsideSalesRepId ' +
'       , Case Comp_PRIndustryType When ''L'' Then prci_LumberFieldSalesRepId Else prci_FieldSalesRepId End As prci_FieldSalesRepId ' +
'       , prci_SalesTerritory ' +
'  From PRCity WITH (NOLOCK) Inner Join Company WITH (NOLOCK) On (Comp_PRListingCityID = prci_CityID);';
exec usp_TravantCRM_CreateView 'vPRCoAccountTeam', @Script;



SET @Script = 
'CREATE VIEW dbo.vPRLRLVerbiage AS ' +
'SELECT ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''HeaderMsg'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'')  AS prlrlv_HeaderMsg, ' +
    'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''DeadlineMsg'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'')  AS prlrlv_DeadlineMsg, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''LetterIntro'', ''en-us'') , Char(13) + Char(10), ''_NEWLINE_'')AS prlrlv_LetterIntro, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''NoConnectionListMsg'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_NoConnectionListMsg, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''OldConnectionListMsg'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_OldConnectionListMsg, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''VolumeMsg'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_VolumeMsg, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''DLPaymentDueMsg'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_DLPaymentDueMsg, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''DLPromotionMsg'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_DLPromotionMsg, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''ChangeAuthorizationMsg'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_ChangeAuthorizationMsg, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''ReasonLeftCodes'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_ReasonLeftCodes, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''PersonnelAnnouncementMsg'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_PersonnelAnnouncementMsg, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''AddPrimaryPersonnelHdr'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_AddPrimaryPersonnelHdr, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''AddPrimaryPersonnelMsg'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_AddPrimaryPersonnelMsg, ' +
	'REPLACE(dbo.ufn_GetCustomCaptionValue(''prlrl_Verbiage'', ''AddPrimaryPersonnelTbl'', ''en-us''), Char(13) + Char(10), ''_NEWLINE_'') AS prlrlv_AddPrimaryPersonnelTbl ';
exec usp_TravantCRM_CreateView 'vPRLRLVerbiage', @Script 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRCompanyARAgingReportCount AS  ' +
	'SELECT CASE WHEN praad_ManualCompanyId IS NOT NULL THEN praad_ManualCompanyId ELSE prar_PRCoCompanyId END As CompanyID, COUNT(DISTINCT praa_CompanyId) As PayReportCount ' +
 		 'FROM  Company WITH (NOLOCK) ' +
			   'INNER JOIN PRARAging WITH (NOLOCK) ON Comp_CompanyId = praa_CompanyId ' +
			   'INNER JOIN PRARAgingDetail WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId  ' +
			   'LEFT OUTER JOIN PRARTranslation WITH (NOLOCK) ON praad_ARCustomerId = prar_CustomerNumber AND prar_CompanyId = praa_CompanyId ' +
		 'WHERE comp_PRListingStatus IN (''L'', ''H'', ''LUV'', ''N2'') ' +
		   'AND praa_Date >= DATEADD(day, -91, GETDATE()) ' +
	  'GROUP BY praad_ManualCompanyId, prar_PRCoCompanyId'
exec usp_TravantCRM_CreateView 'vPRCompanyARAgingReportCount', @Script 


--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vListCommunication  AS 
SELECT RTRIM(ISNULL(Person.Pers_FirstName, '''')) + '' '' + RTRIM(ISNULL(Person.Pers_LastName, '''')) AS Pers_FullName, 
       epd_pers.epd_PhoneFullNumber AS Pers_PhoneFullNumber, epd_comp.epd_EmailAddress as Comp_EmailAddress, epd_comp.epd_PhoneCountryCode as Comp_PhoneCountryCode, 
	   epd_comp.epd_PhoneAreaCode as Comp_PhoneAreaCode, epd_comp.epd_PhoneNumber as Comp_PhoneNumber, epd_comp.epd_PhoneFullNumber AS Comp_PhoneFullNumber, 
	   epd_comp.epd_FaxCountryCode as Comp_FaxCountryCode, epd_comp.epd_FaxAreaCode as Comp_FaxAreaCode, epd_comp.epd_FaxNumber as Comp_FaxNumber, 
	   Account.*, Company.*, Communication.*, Lead.*, Comm_Link.*, 
	   Person.Pers_PersonId, Person.Pers_CreatedBy, Person.Pers_SecTerr, Person.Pers_PrimaryUserId, Person.Pers_ChannelId, 
	   Chan_ChannelId, Chan_Description, Attendee.Pers_CompanyId as CmLi_ExternalCompanyID, Attendee.Pers_AccountId as CmLi_ExternalAccountID,
	   CASE WHEN comm_createdby > 0 THEN ''Y'' ELSE '''' END As comm_NonSystemGenerated,
     CityStateCountryShort,
		 prci_TimeZone
  FROM Communication 
       LEFT JOIN Comm_Link ON Comm_CommunicationId = CmLi_Comm_CommunicationId 
	   LEFT JOIN Person ON Pers_PersonId = CmLi_Comm_PersonId AND Person.Pers_Deleted IS NULL 
	   LEFT JOIN CRMEmailPhoneData epd_pers ON epd_pers.epd_EntityID = 13 AND epd_pers.epd_RecordID = Pers_PersonID 
	   LEFT JOIN Lead ON Lead_LeadId = Comm_LeadId LEFT JOIN Company ON CmLi_Comm_CompanyId = Comp_CompanyId AND Comp_Deleted IS NULL 
	   LEFT JOIN CRMEmailPhoneData epd_comp ON epd_comp.epd_EntityID = 5 AND epd_comp.epd_RecordID = Comp_CompanyID 
	   LEFT JOIN Channel ON Comm_ChannelId = Chan_ChannelId LEFT JOIN Account ON Acc_AccountID = CmLi_Comm_AccountId 
	   LEFT JOIN Person Attendee ON CmLi_ExternalPersonID = Attendee.Pers_PersonId AND Attendee.Pers_Deleted IS NULL 
	   LEFT OUTER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
WHERE Comm_Deleted IS NULL AND CmLi_Deleted IS NULL'
EXEC usp_TravantCRM_CreateView 'vListCommunication', @Script 

--vListCommunication2 to optimize speed
--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW [dbo].[vListCommunication2]  AS 
 SELECT RTRIM(ISNULL(Person.Pers_FirstName, '''')) + '' '' + RTRIM(ISNULL(Person.Pers_LastName, '''')) AS Pers_FullName, 
		Person.Pers_PersonId,
		Comm_Link.CmLi_Comm_CompanyId AS comp_CompanyId,
		comp_Name,
		prci_City,
		ISNULL(prst_Abbreviation, prst_State) as State,
		prcn_Country,
		comm_communicationid,
		comm_hasattachments,
		comm_datetime,
		comm_action,
		ccAction.Capt_US [Action],
		comm_subject,
		LEFT(ISNULL(comm_note,''''),100) comm_note,
		cmli_comm_userid,
		User_FirstName + '' '' + User_LastName UserName,
		comm_prcategory,
		ccCategory.Capt_US [Category],
		comm_prsubcategory,
		ccSubcategory.Capt_US [Subcategory],
		comm_status,
		ccStatus.Capt_US [Staus],
	    CASE WHEN comm_createdby > 0 THEN ''Y'' ELSE '''' END As comm_NonSystemGenerated,
		Libr_FilePath, 
		Libr_FileName,
		 Comm_OpportunityId
  FROM Communication WITH (NOLOCK)
       INNER JOIN Comm_Link WITH (NOLOCK) ON Comm_CommunicationId = CmLi_Comm_CommunicationId 
	   LEFT OUTER JOIN Company WITH (NOLOCK) ON comp_CompanyID = CmLi_Comm_CompanyId AND Company.comp_Deleted IS NULL 
	   LEFT OUTER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	   LEFT OUTER JOIN Person WITH (NOLOCK) ON Pers_PersonId = CmLi_Comm_PersonId AND Person.Pers_Deleted IS NULL 
	   LEFT OUTER JOIN Users WITH (NOLOCK) ON cmli_comm_userid = User_UserId
	   LEFT OUTER JOIN Library WITH (NOLOCK) ON comm_communicationid = libr_communicationId
	   LEFT OUTER JOIN Custom_Captions ccAction WITH (NOLOCK) ON comm_action = ccAction.Capt_Code AND ccAction.Capt_Family = ''comm_action''
	   LEFT OUTER JOIN Custom_Captions ccCategory WITH (NOLOCK) ON comm_prcategory = ccCategory.Capt_Code AND ccCategory.Capt_Family = ''comm_PRCategory''
	   LEFT OUTER JOIN Custom_Captions ccSubcategory WITH (NOLOCK) ON comm_prsubcategory = ccSubcategory.Capt_Code AND ccSubcategory.Capt_Family = ''comm_PRSubCategory''
	   LEFT OUTER JOIN Custom_Captions ccStatus WITH (NOLOCK) ON comm_status = ccStatus.Capt_Code AND ccStatus.Capt_Family = ''comm_status''
WHERE comm_Deleted IS NULL AND cmli_Deleted IS NULL'
EXEC usp_TravantCRM_CreateView 'vListCommunication2', @Script 


--declare @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRVerbalInvestigationResponse  AS 
SELECT prtesr_VerbalInvestigationID, SUM(CASE WHEN prtr_PayRatingId > 0 THEN 1 ELSE 0 END) As PayRatingResponseCount, SUM(CASE WHEN prtr_IntegrityId > 0 THEN 1 ELSE 0 END) As IntegrityResponseCount 
  FROM PRTradeReport WITH (NOLOCK) 
       INNER JOIN PRTESRequest WITH (NOLOCK) ON prtr_TESRequestID = prtesr_TESRequestID 
 WHERE prtesr_VerbalInvestigationID > 0
 GROUP BY prtesr_VerbalInvestigationID'
exec usp_TravantCRM_CreateView 'vPRVerbalInvestigationResponse', @Script 

--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRVerbalInvestigations  AS 
SELECT prvi_VerbalInvestigationID, prvi_InvestigationName, prvi_CompanyID, comp_Name, prvi_CreatedDate, prvi_TargetCompletionDate, prvi_TargetNumberOfPayReports, prvi_TargetNumberOfIntegrityReports, prvi_Status, PayRatingResponseCount, IntegrityResponseCount, prvi_MaxNumberOfAttempts, prvi_CreatedBy 
  FROM PRVerbalInvestigation WITH (NOLOCK) 
       INNER JOIN Company WITH (NOLOCK) ON prvi_CompanyID = comp_CompanyID 
       LEFT OUTER JOIN vPRVerbalInvestigationResponse ON  prvi_VerbalInvestigationID = prtesr_VerbalInvestigationID'
exec usp_TravantCRM_CreateView 'vPRVerbalInvestigations', @Script 

--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRVISelectedCompanies AS
SELECT prtesr_VerbalInvestigationID, prtesr_TESRequestID, comp_CompanyID, CityStateCountryShort, prtesr_CreatedDate 
  FROM PRTESRequest WITH (NOLOCK) 
       INNER JOIN vPRCompanyLocation WITH (NOLOCK) ON prtesr_ResponderCompanyID = comp_CompanyID 
       INNER JOIN PRVerbalInvestigation ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID';
exec usp_TravantCRM_CreateView 'vPRVISelectedCompanies', @Script 

--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRTESVICompanies AS 
SELECT prtesr_TESRequestID, prtesr_VerbalInvestigationID, prtesr_ResponderCompanyID, CityStateCountryShort, prtesr_CreatedDate, COUNT(prvict_VerbalInvestigationCAID) As CallAttempts, MAX(prvict_CreatedDate) As LastCallAttemptDateTime, CASE WHEN prtr_TESRequestID IS NULL THEN NULL ELSE ''Y'' END as Responded
 FROM  PRTESRequest WITH (NOLOCK) 
       INNER JOIN vPRCompanyLocation ON prtesr_ResponderCompanyID = comp_CompanyID
       INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID
       LEFT OUTER JOIN PRVerbalInvestigationCAVI WITH (NOLOCK) ON prtesr_TESRequestID = prvictvi_TESRequestID AND prtesr_VerbalInvestigationID = prvictvi_VerbalInvestigationID
       LEFT OUTER JOIN PRVerbalInvestigationCA WITH (NOLOCK) ON prvictvi_VerbalInvestigationCAID = prvict_VerbalInvestigationCAID
       LEFT OUTER JOIN PRTradeReport WITH (NOLOCK) ON prtesr_TESRequestID = prtr_TESRequestID
GROUP BY prtesr_TESRequestID, prtesr_VerbalInvestigationID, prtesr_ResponderCompanyID, CityStateCountryShort, prtesr_CreatedDate, prtr_TESRequestID';
exec usp_TravantCRM_CreateView 'vPRTESVICompanies', @Script 


--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRTESVISubjectCompanies AS 
SELECT prtesr_TESRequestID, prtesr_VerbalInvestigationID, prtesr_ResponderCompanyID, prtesr_SubjectCompanyID, prtesr_SubjectCompanyID As comp_CompanyID, 
       CityStateCountryShort, prvi_CompletionDate, prvi_MaxNumberOfAttempts, COUNT(prvict_VerbalInvestigationCAID) As CallAttempts, MAX(prvict_CreatedDate) As LastCallAttemptDateTime, 
	   ''Submit TES'' AS [Submit TES], prvi_Notes, dbo.ufn_GetLastTradeReportDate(prtesr_ResponderCompanyID, prtesr_SubjectCompanyID) As LastTradeReportDate,
	   dbo.ufn_GetRelationshipList(prtesr_ResponderCompanyID, prtesr_SubjectCompanyID) as RelationshipList
 FROM  PRTESRequest WITH (NOLOCK) 
       INNER JOIN vPRCompanyLocation ON prtesr_SubjectCompanyID = comp_CompanyID
       INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID
       LEFT OUTER JOIN PRVerbalInvestigationCAVI WITH (NOLOCK) ON prtesr_TESRequestID = prvictvi_TESRequestID AND prtesr_VerbalInvestigationID = prvictvi_VerbalInvestigationID
       LEFT OUTER JOIN PRVerbalInvestigationCA WITH (NOLOCK) ON prvictvi_VerbalInvestigationCAID = prvict_VerbalInvestigationCAID
       LEFT OUTER JOIN PRTradeReport WITH (NOLOCK) ON prtesr_TESRequestID = prtr_TESRequestID
 WHERE prtesr_Received IS NULL
   AND prtesr_SentMethod = ''VI''
   AND prvi_Status = ''O''
GROUP BY prtesr_TESRequestID, prtesr_VerbalInvestigationID, prtesr_ResponderCompanyID, prtesr_SubjectCompanyID, CityStateCountryShort, prvi_CompletionDate, prvi_MaxNumberOfAttempts, prvi_Notes';
exec usp_TravantCRM_CreateView 'vPRTESVISubjectCompanies', @Script 

--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRVICallQueue AS 
SELECT prtesr_ResponderCompanyID as comp_CompanyIdDisplay,
       prtesr_ResponderCompanyID, 
	   comp_PRListingCityID,
       prci_CityID,
	   prst_StateID,
	   CityStateCountryShort, 
	   prci_TimeZone, dbo.ufn_GetLocalTime(prci_TimezoneOffset, prci_DST) As LocalTime, COUNT(prtesr_TESRequestID) As PendingTESRequests, COUNT(prvictvi_VerbalInvestigationCAVIID) As CallAttempts, MAX(prvictvi_CreatedDate) As LastCallAttemptDateTime, user_logon As LockedBy, MIN(prvi_TargetCompletionDate) As EarliestDueDate,
	   comp_PRLocalSource
  FROM PRTESRequest WITH (NOLOCK) 
       INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID
       INNER JOIN Company WITH (NOLOCK) ON prtesr_ResponderCompanyID = comp_CompanyID
       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	   LEFT OUTER JOIN PRVerbalInvestigationCAVI WITH (NOLOCK) ON prtesr_TESRequestID = prvictvi_TESRequestID
       LEFT OUTER JOIN users ON prtesr_ProcessedByUserID = user_userid
 WHERE prvi_Status = ''O''
   AND prtesr_SentMethod = ''VI''
   AND prtesr_Received IS NULL
GROUP BY prtesr_ResponderCompanyID, comp_PRListingCityID, prci_CityID, prst_StateID, CityStateCountryShort, prci_TimeZone, prci_TimezoneOffset, prci_DST, user_logon, comp_PRLocalSource'
exec usp_TravantCRM_CreateView 'vPRVICallQueue', @Script




--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRVIResponder AS 
SELECT prattn_CompanyID, comp_CompanyID, CityStateCountryShort,  Addressee, DeliveryAddress, prci_TimeZone, dbo.ufn_GetLocalTime(prci_TimezoneOffset, prci_DST) As LocalTime, comp_PRSpecialInstruction, comp_PRLocalSource
  FROM Company WITH (NOLOCK)
       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
       INNER JOIN vPRCompanyAttentionLine ON comp_CompanyID = prattn_CompanyID
 WHERE prattn_ItemCode = ''TES-V'' '
exec usp_TravantCRM_CreateView 'vPRVIResponder', @Script

--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRVICallAttempts AS 
SELECT DISTINCT prtesr_ResponderCompanyID, prvict_CreatedDate, prvict_CallDisposition, prvict_Notes
  FROM PRTESRequest WITH (NOLOCK)
       INNER JOIN PRVerbalInvestigationCAVI WITH (NOLOCK) ON prtesr_TESRequestID = prvictvi_TESRequestID
       INNER JOIN PRVerbalInvestigationCA WITH (NOLOCK) ON prvictvi_VerbalInvestigationCAID = prvict_VerbalInvestigationCAID '
exec usp_TravantCRM_CreateView 'vPRVICallAttempts', @Script

--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRVIDetailCallAttempts AS 
SELECT prtesr_TESRequestID, prvict_CreatedDate, prvict_CallDisposition, prvict_Notes
  FROM PRTESRequest WITH (NOLOCK)
       INNER JOIN PRVerbalInvestigationCAVI WITH (NOLOCK) ON prtesr_TESRequestID = prvictvi_TESRequestID
       INNER JOIN PRVerbalInvestigationCA WITH (NOLOCK) ON prvictvi_VerbalInvestigationCAID = prvict_VerbalInvestigationCAID '
exec usp_TravantCRM_CreateView 'vPRVIDetailCallAttempts', @Script


--Declare @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRVICallAttemptNoResponse AS 
SELECT DISTINCT prtesr_ResponderCompanyID, CityStateCountryShort, NULL As prvict_CallDisposition, NULL As prvict_Notes
 FROM  PRTESRequest WITH (NOLOCK) 
       INNER JOIN vPRCompanyLocation ON prtesr_ResponderCompanyID = comp_CompanyID'
exec usp_TravantCRM_CreateView 'vPRVICallAttemptNoResponse', @Script


--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW vPRPayIndicatorEligibleCompany AS 
 SELECT DISTINCT praad_SubjectCompanyID as SubjectCompanyId,
        prcpi_PayIndicatorScore,
        prcpi_PayIndicator,
	    COUNT(DISTINCT praa_CompanyID) As SubmitterCount,
	    COUNT(praad_ARAgingDetailID) As ARDetailCount,
	    MAX(praa_Date) As MostRecentARDate
   FROM PRARAgingDetail praad WITH (NOLOCK)
        INNER JOIN PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
        INNER JOIN Company WITH (NOLOCK) ON praad_SubjectCompanyID = comp_CompanyID
        LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON praad_SubjectCompanyID =  prcpi_CompanyID AND prcpi_Current = ''Y''
  WHERE comp_PRIndustryType = ''L'' 
    AND comp_PRType = ''H''
	AND praad_SubjectCompanyID IS NOT NULL
GROUP BY praad_SubjectCompanyID, prcpi_PayIndicatorScore, prcpi_PayIndicator'
exec usp_TravantCRM_CreateView 'vPRPayIndicatorEligibleCompany', @Script 

--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW vPRPayIndicatorCompanyDetail AS 
 SELECT praa_CompanyID,
        praad_SubjectCompanyID as SubjectCompanyId,
        praa_Date, 
        praad_AmountCurrent, praad_Amount1to30, praad_Amount31to60, praad_Amount61to90, praad_Amount91Plus
   FROM PRARAgingDetail praad WITH (NOLOCK)
        INNER JOIN PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
  WHERE praad_SubjectCompanyID IS NOT NULL'
exec usp_TravantCRM_CreateView 'vPRPayIndicatorCompanyDetail', @Script 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW vPRPublicationArticleCompany AS 
 SELECT prpbarc_PRPublicationArticleCompanyID, prpbarc_PublicationArticleID, comp_CompanyID, comp_Name, CityStateCountryShort
  FROM PRPublicationArticleCompany WITH (NOLOCK)
       INNER JOIN Company WITH (NOLOCK) ON prpbarc_CompanyID = comp_CompanyID
       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID'
exec usp_TravantCRM_CreateView 'vPRPublicationArticleCompany', @Script 

--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRNewsArticles AS 
SELECT *, dbo.ufn_GetCustomCaptionValueList(''comp_PRIndustryType'', prpbar_IndustryTypeCode) As comp_PRIndustryType 
  FROM PRPublicationArticle WITH (NOLOCK) 
 WHERE prpbar_News = ''Y''';
exec usp_TravantCRM_CreateView 'vPRNewsArticles', @Script 


--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRTESExtract AS 
SELECT
    prtfb_TESFormBatchID, 
    FormType = Case prtf_FormType 
        When ''MI'' then ''ME'' 
        When ''SI'' then ''SE'' 
        else prtf_FormType end 
    ,prtf_SerialNumber 
    ,ResponderBBID = prtf_CompanyID 
    ,Attention = dbo.ufn_GetAttentionLineByID (prattn_AttentionLineID) 
    ,ResponderName = r.comp_PRCorrTradestyle 
    ,[Addr1] = rtrim(ra.Addr_Address1) 
    ,[Addr2] = rtrim(ra.Addr_Address2) 
    ,[Addr3] = rtrim(ra.Addr_Address3) 
    ,[Addr4] = rtrim(ra.Addr_Address4) 
    ,[City] = ra.prci_City 
    ,[State] = ra.prst_Abbreviation 
    ,[Country] = ra.prcn_Country 
    ,[Zip] = ra.addr_PostCode,
    [SubjectBBID] = prtesr_SubjectCompanyID,
    [SubjectCompanyName] = s.comp_PRCorrTradestyle, 
    [SubjectListingLocation] = sl.CityStateCountryShort     
FROM PRTESFormBatch WITH (NOLOCK) 
     INNER JOIN PRTESForm WITH (NOLOCK) on prtf_TESFormBatchID = prtfb_TESFormBatchID 
     INNER JOIN PRTESRequest WITH (NOLOCK) ON prtf_TESFormID = prtesr_TESFormID
     INNER JOIN PRAttentionLine WITH (NOLOCK) on prattn_CompanyId = prtf_CompanyID 
			AND prattn_ItemCode = ''TES-M'' 
			AND prattn_Disabled is null 
	 INNER JOIN Company r WITH (NOLOCK) on r.comp_CompanyID = prtf_CompanyID 
			AND r.comp_PRListingStatus not in (''D'',''N3'',''N5'',''N6'') 
	 INNER JOIN Company s WITH (NOLOCK) on s.comp_CompanyID = prtesr_SubjectCompanyID
			AND s.comp_PRListingStatus not in (''D'',''N3'',''N5'',''N6'') 
	 INNER JOIN vPRAddress ra WITH (NOLOCK) on ra.addr_AddressID = prattn_AddressID 
	 INNER JOIN vPRLocation sl ON s.comp_PRListingCityID = sl.prci_CityId
WHERE prtesr_Source != ''VI'''
exec usp_TravantCRM_CreateView 'vPRTESExtract', @Script 


--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRCurrentRating AS   
SELECT *,
	   prra_RatingLine = COALESCE(prcw_Name + '' '', '''') + 
                         COALESCE(prin_Name, '''') + 
                         COALESCE(dbo.ufn_GetAssignedRatingNumeralList(prra_RatingId, 0),'''') + 
                         COALESCE('' '' + prpy_Name, '''') 
 FROM (SELECT prra_CompanyID, prra_RatingID, prra_Current, prra_Rated, prra_Date,
		   prra_CreditWorthId, prcw_Name,
		   prra_IntegrityId, prin_Name,
		   prra_PayRatingId, prpy_Name,
		   dbo.ufn_GetAssignedRatingNumeralList(prra_RatingId, 0) As prra_AssignedRatingNumerals
	  FROM PRRating WITH (NOLOCK) 
		   LEFT OUTER JOIN PRCreditWorthRating WITH (NOLOCK) ON prra_CreditWorthId = prcw_CreditWorthRatingId 
		   LEFT OUTER JOIN PRIntegrityRating WITH (NOLOCK) ON prra_IntegrityId = prin_IntegrityRatingId 
		   LEFT OUTER JOIN PRPayRating WITH (NOLOCK) ON prra_PayRatingId = prpy_PayRatingId
	 WHERE prra_Current = ''Y''
	   AND prra_Rated = ''Y'' ) T1'
exec usp_TravantCRM_CreateView 'vPRCurrentRating', @Script 
   
   
--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRBranchRating AS 
SELECT comp_CompanyID As prra_CompanyID, 
       CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_CreditWorthId ELSE hqRating.prra_CreditWorthId END As prra_CreditWorthId,
       CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_IntegrityId ELSE hqRating.prra_IntegrityId END As prra_IntegrityId,
       CASE WHEN compRating.prra_RatingID IS NOT NULL THEN compRating.prra_PayRatingId ELSE hqRating.prra_PayRatingId END As prra_PayRatingId
  FROM Company WITH (NOLOCK)
       LEFT OUTER JOIN vPRCurrentRating compRating WITH (NOLOCK) ON compRating.prra_CompanyID = comp_CompanyID
       LEFT OUTER JOIN vPRCurrentRating hqRating WITH (NOLOCK) ON hqRating.prra_CompanyID = comp_PRHQID
 WHERE ISNULL(compRating.prra_RatingID, hqRating.prra_RatingID) IS NOT NULL'
exec usp_TravantCRM_CreateView 'vPRBranchRating', @Script 



--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRLumberARAgingDetailBy_PERC AS 
SELECT praa_ARAgingId, praa_RunDate, praa_Date, praa_ImportedDate, praa_ImportedByUserId, 
       praad_CompanyName = CASE WHEN comp_Name IS NOT NULL THEN comp_Name ELSE praad_FileCompanyName END, 
       praad_LineTotal2 = (praad_AmountCurrent + praad_Amount1to30 + praad_Amount31to60 + praad_Amount61to90 + praad_Amount91Plus), 
	   praad_TotalAmountCurrentPercent = dbo.ufn_Divide(praa_TotalCurrent, praa_Total), 
       praad_TotalAmount1to30Percent   = dbo.ufn_Divide(praa_Total1to30, praa_Total), 
       praad_TotalAmount31to60Percent  = dbo.ufn_Divide(praa_Total31to60, praa_Total), 
       praad_TotalAmount61to90Percent  = dbo.ufn_Divide(praa_Total61to90, praa_Total), 
       praad_TotalAmount91PlusPercent  = dbo.ufn_Divide(praa_Total91Plus, praa_Total), 
       praad_LinePercent2 = (dbo.ufn_Divide(praa_TotalCurrent, praa_Total) + dbo.ufn_Divide(praa_Total1to30, praa_Total) + dbo.ufn_Divide(praa_Total31to60, praa_Total) + dbo.ufn_Divide(praa_Total61to90, praa_Total) + dbo.ufn_Divide(praa_Total91Plus, praa_Total)), 
	   praad_AmountCurrentPercent = dbo.ufn_Divide(praad_AmountCurrent, praa_Total), 
	   praad_Amount1to30Percent   = dbo.ufn_Divide(praad_Amount1to30, praa_Total), 
	   praad_Amount31to60Percent  = dbo.ufn_Divide(praad_Amount31to60, praa_Total), 
	   praad_Amount61to90Percent  = dbo.ufn_Divide(praad_Amount61to90, praa_Total), 
	   praad_Amount91PlusPercent  = dbo.ufn_Divide(praad_Amount91Plus, praa_Total), 
	   praad_ARAgingDetailId, praad_ARCustomerId, praad_Exception,  
	   praad_FileCompanyName, praad_ManualCompanyId, 
	   praa_Count, praa_Total, 
	   praa_TotalCurrent, praa_Total1to30, praa_Total31to60, praa_Total61to90, praa_Total91Plus, 
	   praad_AmountCurrent, praad_Amount1to30, praad_Amount31to60, praad_Amount61to90, praad_Amount91Plus,
	   praad_SubjectCompanyID,
	   CityStateCountryShort,
	   CAST(capt_us as varchar) As ListingStatus,
	   Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(praad_SubjectCompanyID, 2) 
  FROM PRARAgingDetail WITH (NOLOCK) 
       INNER JOIN PRARAging praa WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
       LEFT OUTER JOIN Company WITH (NOLOCK) ON praad_SubjectCompanyId = comp_CompanyId
	   LEFT OUTER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	   LEFT OUTER JOIN Custom_Captions ON comp_PRListingStatus = capt_code and capt_Family = ''comp_PRListingStatus''';
 exec usp_TravantCRM_CreateView 'vPRLumberARAgingDetailBy_PERC', @Script
  
 
--
--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRLumberARAgingDetailBy_DOLL AS 
SELECT praa_ARAgingId, praa_RunDate, praa_Date, praa_ImportedDate, praa_ImportedByUserId, 
       praad_CompanyName = CASE WHEN comp_Name IS NOT NULL THEN comp_Name ELSE praad_FileCompanyName END, 
       praad_LineTotal2 = (praad_AmountCurrent + praad_Amount1to30 + praad_Amount31to60 + praad_Amount61to90 + praad_Amount91Plus), 
       praad_ARAgingDetailId, praad_ARCustomerId, praad_Exception,
	   praad_FileCompanyName, 
	   praad_ManualCompanyId, 
	   praa_Count, praa_Total, 
	   praa_TotalCurrent, praa_Total1to30, praa_Total31to60, praa_Total61to90, praa_Total91Plus, 
	   praad_AmountCurrent, praad_Amount1to30, praad_Amount31to60, praad_Amount61to90, praad_Amount91Plus,
	   praad_SubjectCompanyID,
	   CityStateCountryShort,
	   CAST(capt_us as varchar) As ListingStatus,
	   Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(praad_SubjectCompanyID, 2) 
  FROM PRARAgingDetail WITH (NOLOCK)  
       INNER JOIN PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
       LEFT OUTER JOIN Company WITH (NOLOCK) ON praad_SubjectCompanyId = comp_CompanyId
	   LEFT OUTER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	   LEFT OUTER JOIN Custom_Captions ON comp_PRListingStatus = capt_code and capt_Family = ''comp_PRListingStatus''';
 exec usp_TravantCRM_CreateView 'vPRLumberARAgingDetailBy_DOLL', @Script
  

--
--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRProduceARAgingDetailBy_PERC AS 
SELECT praa_ARAgingId, praa_RunDate, praa_Date, praa_ImportedDate, praa_ImportedByUserId, 
       praad_CompanyName = CASE WHEN comp_Name IS NOT NULL THEN comp_Name ELSE praad_FileCompanyName END,
       praad_LineTotal = (praad_Amount0to29 + praad_Amount30to44 + praad_Amount45to60 + praad_Amount61Plus), 
       praad_LinePercent = (dbo.ufn_Divide(praad_Amount0to29, praa_Total) + dbo.ufn_Divide(praad_Amount30to44, praa_Total) + dbo.ufn_Divide(praad_Amount45to60, praa_Total) + dbo.ufn_Divide(praad_Amount61Plus, praa_Total)), 
	   praad_TotalAmount0to29Percent  = dbo.ufn_Divide(praa_Total0to29, praa_Total), 
       praad_TotalAmount30to44Percent = dbo.ufn_Divide(praa_Total30to44, praa_Total), 
       praad_TotalAmount45to60Percent = dbo.ufn_Divide(praa_Total45to60, praa_Total), 
       praad_TotalAmount61PlusPercent = dbo.ufn_Divide(praa_Total61Plus, praa_Total), 
	   praad_Amount0to29Percent  = dbo.ufn_Divide(praad_Amount0to29, praa_Total), 
	   praad_Amount30to44Percent = dbo.ufn_Divide(praad_Amount30to44, praa_Total), 
	   praad_Amount45to60Percent = dbo.ufn_Divide(praad_Amount45to60, praa_Total), 
	   praad_Amount61PlusPercent = dbo.ufn_Divide(praad_Amount61Plus, praa_Total), 
	   praad_ARAgingDetailId, praad_ARCustomerId, praad_Exception,  
	   praad_FileCompanyName, praad_ManualCompanyId, 
	   praa_Count, praa_Total, 
	   praa_Total0to29, praa_Total30to44, praa_Total45to60, praa_Total61Plus, 
	   praad_Amount0to29, praad_Amount30to44, praad_Amount45to60, praad_Amount61Plus,
	   praad_SubjectCompanyID,
	   CityStateCountryShort,
	   CAST(capt_us as varchar) As ListingStatus
  FROM PRARAgingDetail WITH (NOLOCK)
       INNER JOIN PRARAging praa WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
       LEFT OUTER JOIN Company WITH (NOLOCK) ON praad_SubjectCompanyId = comp_CompanyId
	   LEFT OUTER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	   LEFT OUTER JOIN Custom_Captions ON comp_PRListingStatus = capt_code and capt_Family = ''comp_PRListingStatus''';
 exec usp_TravantCRM_CreateView 'vPRProduceARAgingDetailBy_PERC', @Script
 
 
--
--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRProduceARAgingDetailBy_DOLL AS 
SELECT praa_ARAgingId, praa_RunDate, praa_Date, praa_ImportedDate, praa_ImportedByUserId, 
       praad_CompanyName = CASE WHEN comp_Name IS NOT NULL THEN comp_Name ELSE praad_FileCompanyName END,
       praad_LineTotal = (praad_Amount0to29 + praad_Amount30to44 + praad_Amount45to60 + praad_Amount61Plus), 
       praad_ARAgingDetailId, praad_ARCustomerId, praad_Exception,
	   praad_FileCompanyName, praad_ManualCompanyId, 
	   praa_Count, praa_Total, 
	   praa_Total0to29, praa_Total30to44, praa_Total45to60, praa_Total61Plus, 
	   praad_Amount0to29, praad_Amount30to44, praad_Amount45to60, praad_Amount61Plus,
	   praad_SubjectCompanyID,
	   CityStateCountryShort,
	   CAST(capt_us as varchar) As ListingStatus
  FROM PRARAgingDetail  WITH (NOLOCK)
       INNER JOIN PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
       LEFT OUTER JOIN Company WITH (NOLOCK) ON praad_SubjectCompanyId = comp_CompanyId 
       LEFT OUTER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	   LEFT OUTER JOIN Custom_Captions ON comp_PRListingStatus = capt_code and capt_Family = ''comp_PRListingStatus''';
 exec usp_TravantCRM_CreateView 'vPRProduceARAgingDetailBy_DOLL', @Script
  


--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRCaseListing AS 
SELECT case_caseID, case_AssignedUserId, case_ChannelId, comp_CompanyID, comp_Name, 
       prci_City, prst_Abbreviation, case_PRMasterInvoiceNumber, MAX(ihh.InvoiceDate) AS prsp_InvoiceDate, 
	   SUM(Balance) As TotalDue, case_Priority, LastContactDate, case_Status, 
	   CASE WHEN prra_IntegrityID >= 5 THEN ''Y'' ELSE NULL END As XXXorBetterRated, prra_RatingLine,
	   case_PrimaryPersonId
  FROM CRM.dbo.Cases WITH (NOLOCK)
       INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON case_PrimaryCompanyID = comp_CompanyID
       INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
	   INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh ON case_PRMasterInvoiceNumber = ihh.UDF_MASTER_INVOICE
	   INNER JOIN MAS_PRC.dbo.AR_OpenInvoice oi  ON oi.InvoiceNo = ihh.InvoiceNo
       LEFT OUTER JOIN (SELECT comm_CaseID, MAX(Comm_DateTime) As LastContactDate
                          FROM CRM.dbo.Communication WITH (NOLOCK)
                         WHERE comm_CaseID IS NOT NULL                          
                      GROUP BY Comm_CaseId) TableA  ON case_CaseID = comm_CaseID
       LEFT OUTER JOIN CRM.dbo.vPRCurrentRating ON case_PrimaryCompanyID = prra_CompanyID
GROUP BY case_caseID, case_AssignedUserId, case_ChannelId, comp_CompanyID, comp_Name, prci_City, prst_Abbreviation, case_PRMasterInvoiceNumber, case_Priority, LastContactDate, case_Status, prra_IntegrityID, prra_RatingLine, case_PrimaryPersonId'
EXEC usp_TravantCRM_CreateView 'vPRCaseListing', @Script 


--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRCaseCompanyInfo AS 
SELECT case_caseID, case_PrimaryCompanyID, Case_PrimaryPersonId, prcse_FullName, case_PRAltContactName, prra_RatingLine, case_AssignedUserId, case_Status, case_Priority
  FROM Cases WITH (NOLOCK)
       INNER JOIN PRCompanySearch WITH (NOLOCK) ON case_PrimaryCompanyID = prcse_CompanyID
       LEFT OUTER JOIN vPRCurrentRating ON case_PrimaryCompanyID = prra_CompanyID'
EXEC usp_TravantCRM_CreateView 'vPRCaseCompanyInfo', @Script 



--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRCaseInvoiceInfo AS 
SELECT case_caseID, case_PRMasterInvoiceNumber, BBOSUserCount, LastBBOSUse, MAX(ihh.InvoiceDate) AS prsp_InvoiceDate, SUM(Balance) As TotalDue, LastContactDate, DATEDIFF(day, MAX(ihh.InvoiceDate), GETDATE()) as DaysSinceInvoice
  FROM CRM.dbo.Cases WITH (NOLOCK)
	   INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh ON case_PRMasterInvoiceNumber = ihh.UDF_MASTER_INVOICE
	   INNER JOIN MAS_PRC.dbo.AR_OpenInvoice oi  ON oi.InvoiceNo = ihh.InvoiceNo

       LEFT OUTER JOIN (SELECT comm_CaseID, MAX(Comm_DateTime) As LastContactDate
                          FROM CRM.dbo.Communication WITH (NOLOCK)
                         WHERE comm_CaseID IS NOT NULL                          
                      GROUP BY Comm_CaseId) TableA  ON case_CaseID = comm_CaseID
       LEFT OUTER JOIN (SELECT prwu_HQID, 
                               BBOSUserCount = COUNT(prwu_WebUserID),
		                       LastBBOSUse = MAX(prwu_LastLoginDateTime)
		                  FROM CRM.dbo.PRWebUser WITH (NOLOCK)
		              GROUP BY prwu_HQID) TableB on prwu_HQID = case_PrimaryCompanyId
GROUP BY case_caseID, case_PRMasterInvoiceNumber, BBOSUserCount, LastBBOSUse, LastContactDate'
EXEC usp_TravantCRM_CreateView 'vPRCaseInvoiceInfo', @Script





--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRRepeatOrders AS 
SELECT soh.SalesOrderNo,
	   EnteredCompanyID = ec.prcse_CompanyID,
	   EnteredCompanyName = ec.prcse_FullName,
	   BillToCompanyID = CAST(CASE WHEN soh.BillToCustomerNo = '''' THEN soh.CustomerNo ELSE soh.BillToCustomerNo END AS INT),
	   BillToCompanyName = bc.prcse_FullName,
	   comp_PRHQId,
	   soh.LastInvoiceOrderNo,
	   soh.CycleCode,
	   soh.TermsCode,
	   inv.InvoiceNo,
	   inv.InvoiceDate,
	   inv.InvoiceDueDate,
	   AmtInvoiced = (inv.TaxableSalesAmt + inv.NonTaxableSalesAmt + inv.SalesTaxAmt - inv.DiscountAmt),
	   AmtDue = Balance,
	   BilledAddress = ISNULL(ISNULL(emai_EmailAddress, dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension)), dbo.ufn_FormatAddress2(''<br/>'', addr_Address1,addr_Address2,addr_Address3,addr_Address4,addr_Address5,prci_City,ISNULL(prst_Abbreviation, prst_State), prcn_Country, addr_PostCode))
  FROM MAS_PRC.dbo.SO_SalesOrderHeader soh WITH (NOLOCK)
       INNER JOIN Company WITH (NOLOCK) ON comp_CompanyId = MAS_PRC.dbo.ufn_GetBillTo(soh.BillToCustomerNo, soh.CustomerNo)
	   INNER JOIN PRCompanySearch ec WITH (NOLOCK) ON ec.prcse_CompanyID = soh.CustomerNo
	   INNER JOIN PRCompanySearch bc WITH (NOLOCK) ON bc.prcse_CompanyID = comp_CompanyId
       INNER JOIN PRAttentionLine WITH (NOLOCK) ON Comp_CompanyId = prattn_CompanyID AND prattn_ItemCode=''BILL''
	   LEFT OUTER JOIN vPRAddress ON prattn_AddressID = Addr_AddressId
       LEFT OUTER JOIN Email WITH (NOLOCK) ON prattn_EmailID = emai_EmailID 
       LEFT OUTER JOIN Phone WITH (NOLOCK) ON prattn_PhoneID = phon_PhoneID
       LEFT OUTER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader inv WITH (NOLOCK) ON soh.LastInvoiceOrderNo = inv.SalesOrderNo AND soh.LastInvoiceOrderNo != ''''
       LEFT OUTER JOIN MAS_PRC.dbo.AR_OpenInvoice bal WITH (NOLOCK) ON bal.InvoiceNo = inv.InvoiceNo AND inv.HeaderSeqNo = bal.InvoiceHistoryHeaderSeqNo
 WHERE soh.OrderType = ''R''
   AND CycleCode <> ''99'''
EXEC usp_TravantCRM_CreateView 'vPRRepeatOrders', @Script

--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRStandardOrders  AS 
SELECT soh.SalesOrderNo,
	   EnteredCompanyID = CAST(soh.CustomerNo AS INT),
	   BillToCompanyID = CAST(CASE WHEN soh.BillToCustomerNo = '''' THEN soh.CustomerNo ELSE soh.BillToCustomerNo END AS INT),
       soh.LastInvoiceNo,
	   inv.InvoiceDate,
	   AmtInvoiced = (inv.TaxableSalesAmt + inv.NonTaxableSalesAmt + inv.SalesTaxAmt - inv.DiscountAmt),
	   AmtDue = Balance,
	   ServiceCode = sod.ItemCode,
	   Service = sod.ItemCodeDesc,	   
       cii.ProductLine,	
       cii.Category2,
       QuantityOrderedOriginal,
	   UserLogon,
	   LastExtensionAmt
  FROM MAS_PRC.dbo.SO_SalesOrderHistoryHeader soh
       INNER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryDetail sod ON sod.SalesOrderNo = soh.SalesOrderNo
       INNER JOIN MAS_PRC.dbo.CI_Item cii ON sod.ItemCode = cii.ItemCode
	   INNER JOIN MAS_SYSTEM.dbo.SY_User ON soh.UserUpdatedKey = UserKey
       LEFT OUTER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader inv ON soh.SalesOrderNo = inv.SalesOrderNo
       LEFT OUTER JOIN MAS_PRC.dbo.AR_OpenInvoice bal ON bal.InvoiceNo = inv.InvoiceNo
 WHERE soh.OrderStatus = ''C''
   AND soh.MasterRepeatingOrderNo = '''''
EXEC usp_TravantCRM_CreateView 'vPRStandardOrders', @Script

--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRCompanyAccounting   AS 
SELECT comp_PRHQID,
		comp_CompanyID,
		comp_PRCorrTradestyle,
		CASE WHEN prattn_AddressID IS NULL THEN Addr_CRMDefault.Addr_Address1 ELSE Addr_Attn.Addr_Address1 END AS Addr_Address1,
		CASE WHEN prattn_AddressID IS NULL THEN Addr_CRMDefault.Addr_Address2 ELSE Addr_Attn.Addr_Address2 END AS Addr_Address2,
		CASE WHEN prattn_AddressID IS NULL THEN Addr_CRMDefault.Addr_Address3 ELSE Addr_Attn.Addr_Address3 END AS Addr_Address3,
		
		CASE WHEN prattn_AddressID IS NULL
			THEN LTRIM(RTRIM(CASE Addr_CRMDefault.prcn_CountryID WHEN 1 THEN Addr_CRMDefault.Addr_USZipFive ELSE RTRIM(Addr_CRMDefault.addr_PostCode) END))
			ELSE LTRIM(RTRIM(CASE Addr_Attn.prcn_CountryID WHEN 1 THEN Addr_Attn.Addr_USZipFive ELSE RTRIM(Addr_Attn.addr_PostCode) END))
		END AS PostCode,

		CASE WHEN prattn_AddressID IS NULL THEN Addr_CRMDefault.prci_City ELSE Addr_Attn.prci_City END AS prci_City,
		
		CASE WHEN prattn_AddressID IS NULL
			THEN ISNULL(Addr_CRMDefault.prst_Abbreviation, Addr_CRMDefault.prst_State) 
			ELSE ISNULL(Addr_Attn.prst_Abbreviation, Addr_Attn.prst_State) 
		END AS State,
		
		CASE WHEN prattn_AddressID IS NULL
			THEN RIGHT(''00''+ CONVERT(VARCHAR,Addr_CRMDefault.prcn_CountryId),3)
			ELSE RIGHT(''00''+ CONVERT(VARCHAR,Addr_Attn.prcn_CountryId),3)
		END AS prcn_CountryID,

		CASE WHEN prattn_AddressID IS NULL THEN Addr_CRMDefault.prcn_Country ELSE Addr_Attn.prcn_Country END AS prcn_Country,
		
       RTRIM(Emai_EmailAddress) As EmailAddress,
       dbo.ufn_FormatPhone(Phon_CountryCode, Phon_AreaCode, Phon_Number, phon_PRExtension) As Fax,
       prci2_TaxCode,
       prci2_TaxExempt,
       prci2_CustomerCategory,
       Addressee,
       comp_PRType,
	   prattn_IncludeWireTransferInstructions,
	   prattn_AddressID
  FROM Company WITH (NOLOCK)
       INNER JOIN vPRCompanyAttentionLine WITH (NOLOCK) ON Comp_CompanyId = prattn_CompanyID AND prattn_ItemCode=''BILL''
       LEFT OUTER JOIN vPRAddress Addr_Attn ON prattn_AddressID = Addr_Attn.Addr_AddressId
       LEFT OUTER JOIN Email WITH (NOLOCK) ON prattn_EmailID = Emai_EmailId
       LEFT OUTER JOIN Phone WITH (NOLOCK) ON prattn_PhoneID = Phon_PhoneId
       LEFT OUTER JOIN PRCompanyIndicators WITH (NOLOCK) ON Comp_CompanyId = prci2_CompanyID
	   LEFT OUTER JOIN vPRAddress Addr_CRMDefault ON Addr_CRMDefault.adli_CompanyId=Comp_CompanyId AND Addr_CRMDefault.adli_PRDefaultMailing=''Y''
 WHERE comp_PRListingStatus <> ''D''
   AND comp_PRLocalSource IS NULL '
EXEC usp_TravantCRM_CreateView 'vPRCompanyAccounting', @Script

--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRServicePayment   AS 
SELECT tph.CustomerNo,
       ihh.SalesOrderNo,
       soh.MasterRepeatingOrderNo,
       UDF_MASTER_INVOICE,
       ihh.InvoiceDate,
       tph.InvoiceNo ,
       AmtInvoiced = (ihh.TaxableSalesAmt + ihh.NonTaxableSalesAmt + ihh.SalesTaxAmt - ihh.DiscountAmt),
       tph.TransactionDate,
       TransactionType,
       TransactionAmt 
  FROM MAS_PRC.dbo.AR_TransactionPaymentHistory tph
       INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh ON tph.InvoiceNo = ihh.InvoiceNo
       INNER JOIN MAS_PRC.dbo.SO_SalesOrderHistoryHeader soh ON ihh.SalesOrderNo = soh.SalesOrderNo '
--EXEC usp_TravantCRM_CreateView 'vPRServicePayment', @Script


--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRShipmentLogDetails   AS 
SELECT *, 
       dbo.ufn_GetShipmentLogItemsForList(prshplg_ShipmentLogID) As ItemList,
	   User_Logon as CreatedBy
  FROM PRShipmentLog WITH (NOLOCK)
       INNER JOIN Users on prshplg_CreatedBy = user_userID'
EXEC usp_TravantCRM_CreateView 'vPRShipmentLogDetails', @Script
 
--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRShipmentLogQueue AS 
SELECT prshplg_ShipmentLogID, 
       CAST(prshplg_ShipmentLogID as varchar(25)) As ShipmentLogID,
       prshplg_CreatedDate,
       dbo.ufn_GetShipmentLogItemsForList(prshplg_ShipmentLogID) As ItemList,
       prshplg_Addressee As Addressee, 
       dbo.ufn_FormatAddress2('' '', addr_Address1,addr_Address2,addr_Address3,addr_Address4,addr_Address5,prci_City,ISNULL(prst_Abbreviation, prst_State), prcn_Country, addr_PostCode) As DeliveryAddress,
       ISNULL(prattn_CustomLine, pers_FirstName) As Name, 
       CASE WHEN prshplg_Addressee IS NULL THEN pers_LastName ELSE NULL END As LastName,
	   Comp_CompanyId,
       comp_PRCorrTradestyle,
       addr_Address1, 
       addr_Address2, 
       addr_Address3, 
       addr_Address4, 
       prci_City,
       prst_Abbreviation,
       Addr_PostCode,
       prcn_Country,
       prshplg_CarrierCode,
       prshplg_TrackingNumber,
       prshplg_MailRoomComments, 
	   prshplg_CreatedBy
  FROM PRShipmentLog WITH (NOLOCK)
       INNER JOIN Company WITH (NOLOCK) ON prshplg_CompanyID = Comp_CompanyId
       INNER JOIN Address WITH (NOLOCK) ON prshplg_AddressID = Addr_AddressId
       INNER JOIN vPRLocation ON addr_PRCityId = prci_CityID
       LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON prshplg_AttentionLineID = prattn_AttentionLineID       
       LEFT OUTER JOIN Person WITH (NOLOCK) ON prattn_PersonID = Pers_PersonId
WHERE prshplg_TrackingNumber IS NULL
  AND prshplg_Type = ''Manual'''
EXEC usp_TravantCRM_CreateView 'vPRShipmentLogQueue', @Script 

 
--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRPrimaryService   AS 
SELECT soh.SalesOrderNo,
       CAST(soh.CustomerNo AS INT) As EnteredCompanyID,
	   CAST(CASE WHEN soh.BillToCustomerNo = '''' THEN soh.CustomerNo ELSE soh.BillToCustomerNo END AS INT) As BillToCompanyID,
       ehq.comp_PRHQId As EnteredHQID,
	   ISNULL(bhq.comp_PRHQID, ehq.comp_PRHQId) As BilledToHQID,
	   sod.ItemCode,
	   sod.ItemCodeDesc,
	   soh.CycleCode,
	   soh.TermsCode,
	   inv.InvoiceNo,
	   inv.InvoiceDate,
	   Balance,
	   inv.InvoiceDueDate,
	   UDF_MASTER_INVOICE,
	   cii.Category3
  FROM MAS_PRC.dbo.SO_SalesOrderDetail sod
       INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader soh ON soh.SalesOrderNo = sod.SalesOrderNo
       INNER JOIN MAS_PRC.dbo.CI_Item cii ON sod.ItemCode = cii.ItemCode
       INNER JOIN Company ehq ON ehq.Comp_CompanyId = CAST(soh.CustomerNo AS INT)
       LEFT OUTER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader inv ON soh.LastInvoiceOrderNo = inv.SalesOrderNo AND soh.LastInvoiceOrderNo != ''''
       LEFT OUTER JOIN MAS_PRC.dbo.AR_OpenInvoice bal ON bal.InvoiceNo = inv.InvoiceNo
       LEFT OUTER JOIN Company bhq ON bhq.Comp_CompanyId = CAST(soh.BillToCustomerNo AS INT)       
 WHERE soh.OrderType = ''R''
   AND CycleCode <> ''99''
   AND cii.Category2 =''Primary'''
EXEC usp_TravantCRM_CreateView 'vPRPrimaryService', @Script 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPROpportunityListingBBOSInq AS 
SELECT Oppo_OpportunityId, Oppo_Opened, oppo_stage as OppoStage, Oppo_PRType, oppo_PRCertainty,
       Oppo_Status, oppo_assigneduserid, oppo_ChannelId
       , prwu_Email, prwu_CompanyName, prwu_LastName + '', '' + prwu_FirstName As PersonName
       , CASE WHEN prwu_City IS NULL THEN '' WHEN RTRIM(prwu_City) = '''' THEN '' ELSE prwu_City + '', '' END + ISNULL(prst_Abbreviation, prst_State) + CASE WHEN prcn_CountryId IN (1,2) THEN '''' ELSE '' '' +  prcn_Country END As CityStateCountryShort,
       oppo_PrimaryCompanyId
  FROM Opportunity OPP WITH (NOLOCK) 
       INNER JOIN PRWebUser ON oppo_PRWebUserID = prwu_WebUserID
       LEFT OUTER JOIN PRState ON prwu_StateID = prst_StateID AND prwu_StateID IS NOT NULL
       LEFT OUTER JOIN PRCountry ON prst_CountryId = prcn_CountryID'
EXEC usp_TravantCRM_CreateView 'vPROpportunityListingBBOSInq', @Script 

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRSalesOrderAuditTrailListing AS 
	SELECT 
		prsoat_SalesOrderAuditTrailID,
		prsoat_CreatedDate,
		Comp_CompanyId,
		prsoat_ItemCode,
		prsoat_Pipeline, 
		prsoat_Up_Down,
		prsoat_ActionCode,
		prsoat_CancelReasonCode,
		prsoat_UserLogon,
		prsoat_SoldBy,
		prsoat_SalesOrderNo,
		prsoat_ExtensionAmt,
		[prsoat_ExtensionAmt_CID]=1,
		prsoat_CycleCode,
		prsoat_QuantityChange
	FROM CRM.dbo.PRSalesOrderAuditTrail rpt WITH (NOLOCK) 
		INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON prsoat_SoldToCompany = comp_CompanyID 
		INNER JOIN MAS_PRC.dbo.CI_Item WITH (NOLOCK) ON prsoat_ItemCode = ItemCode 
	WHERE 
		CI_Item.ItemCode != ''DL'' AND
		ProductLine IN (SELECT DISTINCT ProductLine FROM MAS_PRC.dbo.CI_Item)'
EXEC usp_TravantCRM_CreateView 'vPRSalesOrderAuditTrailListing', @Script 


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetailByProduce AS
SELECT praa_ARAgingId, praa_RunDate, praa_Date, praa_ImportedDate, praa_ImportedByUserId, 
	   praa_CompanyId, 
	   --prar_PRCoCompanyId, prar_CustomerNumber, 
	   praad_CompanyName = sc.Comp_Name,
       Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(praad_SubjectCompanyID,1), 
       praad_LineTotal = (praad_Amount0to29 + praad_Amount30to44 + praad_Amount45to60 + praad_Amount61Plus), 
       praad_LinePercent = (praad_Amount0to29Percent + praad_Amount30to44Percent + praad_Amount45to60Percent + praad_Amount61PlusPercent),
	   praad_TotalAmount0to29Percent, praad_TotalAmount30to44Percent, praad_TotalAmount45to60Percent, praad_TotalAmount61PlusPercent, 
	   praad_Amount0to29Percent,  praad_Amount30to44Percent, praad_Amount45to60Percent, praad_Amount61PlusPercent, 
	   praa_Total, praa_Total0to29, praa_Total30to44, praa_Total45to60, praa_Total61Plus, 
	   praad_ARAgingDetailId, praa_ARAgingDetailCount, praad_ARAgingId, praad_ARCustomerId, praad_FileCompanyName
  FROM ( 
		SELECT  praa_ARAgingId, praa_CompanyId,
				praa_RunDate, praa_Date, praa_ImportedDate, praa_ImportedByUserId, 
				praa_Total, 
				praa_Total0to29, praa_Total30to44, praa_Total45to60, praa_Total61Plus, 
				praad_ARAgingDetailId, praad_ARAgingId, praad_ARCustomerId,  
				praad_FileCompanyName, praad_FileCityName, praad_FileStateName, praad_FileZipCode, 
				praad_Exception, praad_CreditTerms, praad_Deleted, praad_SubjectCompanyID, 
				praad_Amount0to29 = ISNULL(praad_Amount0to29,0),  
				praad_Amount30to44 = ISNULL(praad_Amount30to44,0),  
				praad_Amount45to60 = ISNULL(praad_Amount45to60,0),  
				praad_Amount61Plus = ISNULL(praad_Amount61Plus,0),
				praa_Count AS praa_ARAgingDetailCount,
				praad_TotalAmount0to29Percent = 100 * dbo.ufn_Divide(praa_Total0to29, praa_Total), 
				praad_TotalAmount30to44Percent = 100 * dbo.ufn_Divide(praa_Total30to44, praa_Total), 
				praad_TotalAmount45to60Percent = 100 * dbo.ufn_Divide(praa_Total45to60, praa_Total), 
				praad_TotalAmount61PlusPercent = 100 * dbo.ufn_Divide(praa_Total61Plus, praa_Total), 
				praad_Amount0to29Percent = 100 * dbo.ufn_Divide(praad_Amount0to29, praa_Total), 
				praad_Amount30to44Percent = 100 * dbo.ufn_Divide(praad_Amount30to44, praa_Total), 
				praad_Amount45to60Percent = 100 * dbo.ufn_Divide(praad_Amount45to60, praa_Total), 
				praad_Amount61PlusPercent = 100 * dbo.ufn_Divide(praad_Amount61Plus, praa_Total)
		   FROM PRARAging WITH (NOLOCK)
				LEFT OUTER JOIN PRARAgingDetail WITH (NOLOCK) ON praa_ARAgingID = praad_ARAgingId 
		) BTable 
		 INNER JOIN Company comp WITH (NOLOCK) ON praa_CompanyId = comp.comp_CompanyId 
		 LEFT OUTER JOIN Company sc WITH (NOLOCK) ON praad_SubjectCompanyId = sc.comp_CompanyId'
EXEC usp_TravantCRM_CreateView 'vPRARAgingDetailByProduce', @Script 
 





 -- LUMBER
 --DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetailByLumber AS
SELECT praa_ARAgingId, praa_RunDate, praa_Date, praa_ImportedDate, praa_ImportedByUserId, 
	   praa_CompanyId, 
	   --prar_PRCoCompanyId, prar_CustomerNumber, 
	   praad_CompanyName = sc.Comp_Name,
       Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(praad_SubjectCompanyID,1), 
       praad_LineTotal2 = (praad_AmountCurrent + praad_Amount1to30 + praad_Amount31to60 + praad_Amount61to90 + praad_Amount91Plus), 
       praad_LinePercent2 = (praad_AmountCurrentPercent + praad_Amount1to30Percent + praad_Amount31to60Percent + praad_Amount61to90Percent + praad_Amount91PlusPercent), 
	   praad_TotalAmountCurrentPercent, praad_TotalAmount1to30Percent, praad_TotalAmount31to60Percent, praad_TotalAmount61to90Percent, praad_TotalAmount91PlusPercent, 
	   praad_AmountCurrentPercent,  praad_Amount1to30Percent, praad_Amount31to60Percent, praad_Amount61to90Percent, praad_Amount91PlusPercent,
	   praa_Total, praa_TotalCurrent, praa_Total1to30, praa_Total31to60, praa_Total61to90, praa_Total91Plus, 
	   praad_ARAgingDetailId, praa_ARAgingDetailCount, praad_ARAgingId, praad_ARCustomerId, praad_FileCompanyName
  FROM ( 
		SELECT  praa_ARAgingId, praa_CompanyId,
				praa_RunDate, praa_Date, praa_ImportedDate, praa_ImportedByUserId, 
				praa_Total, 
				praa_TotalCurrent, praa_Total1to30, praa_Total31to60, praa_Total61to90, praa_Total91Plus, 
				praad_ARAgingDetailId, praad_ARAgingId, praad_ARCustomerId,  
				praad_FileCompanyName, praad_FileCityName, praad_FileStateName, praad_FileZipCode, 
				praad_Exception, praad_CreditTerms, praad_Deleted, praad_SubjectCompanyID, 
				praad_AmountCurrent = ISNULL(praad_AmountCurrent, 0),
				praad_Amount1to30 = ISNULL(praad_Amount1to30,  0),
				praad_Amount31to60 = ISNULL(praad_Amount31to60, 0),
				praad_Amount61to90 = ISNULL(praad_Amount61to90, 0),
				praad_Amount91Plus = ISNULL(praad_Amount91Plus, 0),
				praa_Count AS praa_ARAgingDetailCount,
				praad_TotalAmountCurrentPercent = 100 * dbo.ufn_Divide(praa_TotalCurrent, praa_Total), 
				praad_TotalAmount1to30Percent = 100 * dbo.ufn_Divide(praa_Total1to30, praa_Total), 
				praad_TotalAmount31to60Percent = 100 * dbo.ufn_Divide(praa_Total31to60, praa_Total), 
				praad_TotalAmount61to90Percent = 100 * dbo.ufn_Divide(praa_Total61to90, praa_Total), 
				praad_TotalAmount91PlusPercent = 100 * dbo.ufn_Divide(praa_Total91Plus, praa_Total), 
				praad_AmountCurrentPercent = 100 * dbo.ufn_Divide(praad_AmountCurrent, praa_Total), 
				praad_Amount1to30Percent = 100 * dbo.ufn_Divide(praad_Amount1to30, praa_Total), 
				praad_Amount31to60Percent = 100 * dbo.ufn_Divide(praad_Amount31to60, praa_Total), 
				praad_Amount61to90Percent = 100 * dbo.ufn_Divide(praad_Amount61to90, praa_Total), 
				praad_Amount91PlusPercent = 100 * dbo.ufn_Divide(praad_Amount91Plus, praa_Total) 
		   FROM PRARAging WITH (NOLOCK)
				LEFT OUTER JOIN PRARAgingDetail WITH (NOLOCK) ON praa_ARAgingID = praad_ARAgingId 
		) BTable 
		 INNER JOIN Company comp WITH (NOLOCK) ON praa_CompanyId = comp.comp_CompanyId 
		 LEFT OUTER JOIN Company sc WITH (NOLOCK) ON praad_SubjectCompanyId = sc.comp_CompanyId'
EXEC usp_TravantCRM_CreateView 'vPRARAgingDetailByLumber', @Script 




--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetailOnProduce AS
SELECT NULL AS _StartDate, NULL AS _EndDate, NULL AS _Exception, 
    praa_ARAgingId, praad_ARAgingDetailId, praa_RunDate, praa_Date, 
    praad_ReportingCompanyId, 
    praad_ReportingCompanyName, 
    praad_SubjectCompanyId, 
    praad_CompanyName = comp_Name, 
    praad_State = praad_FileStateName, 
    praad_Amount0to29, 
    praad_Amount30to44, 
    praad_Amount45to60, 
    praad_Amount61Plus, 
    praad_TotalAmount, 
	praad_Amount0to29Percent = 100 * dbo.ufn_Divide(praad_Amount0to29, praad_TotalAmount),
	praad_Amount30to44Percent = 100 * dbo.ufn_Divide(praad_Amount30to44, praad_TotalAmount),
	praad_Amount45to60Percent = 100 * dbo.ufn_Divide(praad_Amount45to60, praad_TotalAmount),
	praad_Amount61PlusPercent = 100 * dbo.ufn_Divide(praad_Amount61Plus, praad_TotalAmount),
    Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(praad_ReportingCompanyId,1), 
    praad_Exception 
FROM 
(SELECT praad_FileCompanyName, praad_FileStateName, praad_ARAgingDetailId, praad_exception, praa_ARAgingId, praa_RunDate, praa_Date,  
        praad_Amount0to29 = ISNULL(praad_Amount0to29,  0),
        praad_Amount30to44 = ISNULL(praad_Amount30to44, 0),
        praad_Amount45to60 = ISNULL(praad_Amount45to60, 0),
        praad_Amount61Plus = ISNULL(praad_Amount61Plus, 0),
		praad_TotalAmount = ISNULL(praad_Amount0to29, 0) + ISNULL(praad_Amount30to44, 0) + ISNULL(praad_Amount45to60, 0) + ISNULL(praad_Amount61Plus, 0),
        praad_ReportingCompanyId = praa_CompanyId, 
        praad_ReportingCompanyName = comp_Name, 
        praad_SubjectCompanyId, 
        praa_Total
   FROM PRARAgingDetail WITH (NOLOCK)
        INNER JOIN PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
        INNER JOIN Company WITH (NOLOCK) ON praa_CompanyId = comp_CompanyId 
) ATable 
LEFT OUTER JOIN Company WITH (NOLOCK) ON praad_SubjectCompanyId = comp_CompanyId'
EXEC usp_TravantCRM_CreateView 'vPRARAgingDetailOnProduce', @Script   

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetailOnProduce_WArch AS
SELECT NULL AS _StartDate, NULL AS _EndDate, NULL AS _Exception, 
    praa_ARAgingId, praad_ARAgingDetailId, praa_RunDate, praa_Date, 
    praad_ReportingCompanyId, 
    praad_ReportingCompanyName, 
    praad_SubjectCompanyId, 
    praad_CompanyName = comp_Name, 
    praad_State = praad_FileStateName, 
    praad_Amount0to29, 
    praad_Amount30to44, 
    praad_Amount45to60, 
    praad_Amount61Plus, 
    praad_TotalAmount, 
	praad_Amount0to29Percent = 100 * dbo.ufn_Divide(praad_Amount0to29, praad_TotalAmount),
	praad_Amount30to44Percent = 100 * dbo.ufn_Divide(praad_Amount30to44, praad_TotalAmount),
	praad_Amount45to60Percent = 100 * dbo.ufn_Divide(praad_Amount45to60, praad_TotalAmount),
	praad_Amount61PlusPercent = 100 * dbo.ufn_Divide(praad_Amount61Plus, praad_TotalAmount),
    Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(praad_ReportingCompanyId,1), 
    praad_Exception 
FROM 
(SELECT praad_FileCompanyName, praad_FileStateName, praad_ARAgingDetailId, praad_exception, praa_ARAgingId, praa_RunDate, praa_Date,  
        praad_Amount0to29 = ISNULL(praad_Amount0to29,  0),
        praad_Amount30to44 = ISNULL(praad_Amount30to44, 0),
        praad_Amount45to60 = ISNULL(praad_Amount45to60, 0),
        praad_Amount61Plus = ISNULL(praad_Amount61Plus, 0),
		praad_TotalAmount = ISNULL(praad_Amount0to29, 0) + ISNULL(praad_Amount30to44, 0) + ISNULL(praad_Amount45to60, 0) + ISNULL(praad_Amount61Plus, 0),
        praad_ReportingCompanyId = praa_CompanyId, 
        praad_ReportingCompanyName = comp_Name, 
        praad_SubjectCompanyId, 
        praa_Total
   FROM PRARAgingDetail WITH (NOLOCK)
        INNER JOIN PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
        INNER JOIN Company WITH (NOLOCK) ON praa_CompanyId = comp_CompanyId 
	UNION
	SELECT praad_FileCompanyName, praad_FileStateName, praad_ARAgingDetailId, praad_exception, praa_ARAgingId, praa_RunDate, praa_Date,  
			praad_Amount0to29 = ISNULL(praad_Amount0to29,  0),
			praad_Amount30to44 = ISNULL(praad_Amount30to44, 0),
			praad_Amount45to60 = ISNULL(praad_Amount45to60, 0),
			praad_Amount61Plus = ISNULL(praad_Amount61Plus, 0),
			praad_TotalAmount = ISNULL(praad_Amount0to29, 0) + ISNULL(praad_Amount30to44, 0) + ISNULL(praad_Amount45to60, 0) + ISNULL(praad_Amount61Plus, 0),
			praad_ReportingCompanyId = praa_CompanyId, 
			praad_ReportingCompanyName = comp_Name, 
			praad_SubjectCompanyId, 
			praa_Total
		FROM CRMArchive.dbo.PRARAgingDetail WITH (NOLOCK)
			INNER JOIN CRMArchive.dbo.PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
			INNER JOIN Company WITH (NOLOCK) ON praa_CompanyId = comp_CompanyId 
) ATable 
LEFT OUTER JOIN Company WITH (NOLOCK) ON praad_SubjectCompanyId = comp_CompanyId'
EXEC usp_TravantCRM_CreateView 'vPRARAgingDetailOnProduce_WArch', @Script   

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetailOnLumber AS
SELECT NULL AS _StartDate, NULL AS _EndDate, NULL AS _Exception, 
    praa_ARAgingId, praad_ARAgingDetailId, praa_RunDate, praa_Date, 
    praad_ReportingCompanyId, 
	praad_ReportingCompanyId as comp_CompanyID, 
    praad_ReportingCompanyName, 
    praad_SubjectCompanyId, 
    praad_CompanyName = comp_Name, 
    praad_State = praad_FileStateName, 
    praad_AmountCurrent, 
    praad_Amount1to30, 
    praad_Amount31to60, 
    praad_Amount61to90, 
	praad_Amount91Plus, 
    praad_TotalAmount, 
	praad_AmountCurrentPercent = 100 * dbo.ufn_Divide(praad_AmountCurrent, praad_TotalAmount),
	praad_Amount1to30Percent = 100 * dbo.ufn_Divide(praad_Amount1to30, praad_TotalAmount),  
	praad_Amount31to60Percent = 100 * dbo.ufn_Divide(praad_Amount31to60, praad_TotalAmount), 
	praad_Amount61to90Percent = 100 * dbo.ufn_Divide(praad_Amount61to90, praad_TotalAmount), 
	praad_Amount91PlusPercent = 100 * dbo.ufn_Divide(praad_Amount91Plus, praad_TotalAmount), 
    Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(praad_ReportingCompanyId,1), 
    praad_Exception 
FROM 
(SELECT praad_FileCompanyName, praad_FileStateName, praad_ARAgingDetailId, praad_exception, praa_ARAgingId, praa_RunDate, praa_Date,  
        praad_AmountCurrent = ISNULL(praad_AmountCurrent,  0),
        praad_Amount1to30 = ISNULL(praad_Amount1to30, 0),
        praad_Amount31to60 = ISNULL(praad_Amount31to60, 0),
        praad_Amount61to90 = ISNULL(praad_Amount61to90, 0),
		praad_Amount91Plus = ISNULL(praad_Amount91Plus, 0),
		praad_TotalAmount = ISNULL(praad_AmountCurrent, 0) + ISNULL(praad_Amount1to30, 0) + ISNULL(praad_Amount31to60, 0) + ISNULL(praad_Amount61to90, 0) + ISNULL(praad_Amount91Plus, 0),
        praad_ReportingCompanyId = praa_CompanyId, 
        praad_ReportingCompanyName = comp_Name, 
        praad_SubjectCompanyId, 
        praa_Total
   FROM PRARAgingDetail WITH (NOLOCK)
        INNER JOIN PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
        INNER JOIN Company WITH (NOLOCK) ON praa_CompanyId = comp_CompanyId 
) ATable 
LEFT OUTER JOIN Company WITH (NOLOCK) ON praad_SubjectCompanyId = comp_CompanyId'
EXEC usp_TravantCRM_CreateView 'vPRARAgingDetailOnLumber', @Script  

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetailOnLumber_WArch AS
SELECT NULL AS _StartDate, NULL AS _EndDate, NULL AS _Exception, 
    praa_ARAgingId, praad_ARAgingDetailId, praa_RunDate, praa_Date, 
    praad_ReportingCompanyId, 
	praad_ReportingCompanyId as comp_CompanyID, 
    praad_ReportingCompanyName, 
    praad_SubjectCompanyId, 
    praad_CompanyName = comp_Name, 
    praad_State = praad_FileStateName, 
    praad_AmountCurrent, 
    praad_Amount1to30, 
    praad_Amount31to60, 
    praad_Amount61to90, 
	praad_Amount91Plus, 
    praad_TotalAmount, 
	praad_AmountCurrentPercent = 100 * dbo.ufn_Divide(praad_AmountCurrent, praad_TotalAmount),
	praad_Amount1to30Percent = 100 * dbo.ufn_Divide(praad_Amount1to30, praad_TotalAmount),  
	praad_Amount31to60Percent = 100 * dbo.ufn_Divide(praad_Amount31to60, praad_TotalAmount), 
	praad_Amount61to90Percent = 100 * dbo.ufn_Divide(praad_Amount61to90, praad_TotalAmount), 
	praad_Amount91PlusPercent = 100 * dbo.ufn_Divide(praad_Amount91Plus, praad_TotalAmount), 
    Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(praad_ReportingCompanyId,1), 
    praad_Exception 
FROM 
(SELECT praad_FileCompanyName, praad_FileStateName, praad_ARAgingDetailId, praad_exception, praa_ARAgingId, praa_RunDate, praa_Date,  
        praad_AmountCurrent = ISNULL(praad_AmountCurrent,  0),
        praad_Amount1to30 = ISNULL(praad_Amount1to30, 0),
        praad_Amount31to60 = ISNULL(praad_Amount31to60, 0),
        praad_Amount61to90 = ISNULL(praad_Amount61to90, 0),
		praad_Amount91Plus = ISNULL(praad_Amount91Plus, 0),
		praad_TotalAmount = ISNULL(praad_AmountCurrent, 0) + ISNULL(praad_Amount1to30, 0) + ISNULL(praad_Amount31to60, 0) + ISNULL(praad_Amount61to90, 0) + ISNULL(praad_Amount91Plus, 0),
        praad_ReportingCompanyId = praa_CompanyId, 
        praad_ReportingCompanyName = comp_Name, 
        praad_SubjectCompanyId, 
        praa_Total
   FROM PRARAgingDetail WITH (NOLOCK)
        INNER JOIN PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
        INNER JOIN Company WITH (NOLOCK) ON praa_CompanyId = comp_CompanyId 
	UNION

	SELECT praad_FileCompanyName, praad_FileStateName, praad_ARAgingDetailId, praad_exception, praa_ARAgingId, praa_RunDate, praa_Date,  
			praad_AmountCurrent = ISNULL(praad_AmountCurrent,  0),
			praad_Amount1to30 = ISNULL(praad_Amount1to30, 0),
			praad_Amount31to60 = ISNULL(praad_Amount31to60, 0),
			praad_Amount61to90 = ISNULL(praad_Amount61to90, 0),
			praad_Amount91Plus = ISNULL(praad_Amount91Plus, 0),
			praad_TotalAmount = ISNULL(praad_AmountCurrent, 0) + ISNULL(praad_Amount1to30, 0) + ISNULL(praad_Amount31to60, 0) + ISNULL(praad_Amount61to90, 0) + ISNULL(praad_Amount91Plus, 0),
			praad_ReportingCompanyId = praa_CompanyId, 
			praad_ReportingCompanyName = comp_Name, 
			praad_SubjectCompanyId, 
			praa_Total
	   FROM CRMArchive.dbo.PRARAgingDetail WITH (NOLOCK)
			INNER JOIN CRMArchive.dbo.PRARAging WITH (NOLOCK) ON praa_ARAgingId = praad_ARAgingId 
			INNER JOIN Company WITH (NOLOCK) ON praa_CompanyId = comp_CompanyId 
) ATable 
LEFT OUTER JOIN Company WITH (NOLOCK) ON praad_SubjectCompanyId = comp_CompanyId'
EXEC usp_TravantCRM_CreateView 'vPRARAgingDetailOnLumber_WArch', @Script  


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBBOSInternalExport AS
SELECT comp_CompanyID as [Company ID],
       comp_PRCorrTradestyle as [Correspondence Tradestyle],
	   comp_PRLegalName as [Legal Tradestyle],
	   comp_PRBookTradestyle as [Book Tradestyle],
	   prci_SalesTerritory as [Sales Territory],
	   prse_Primary as [Is Member],
	   ItemCodeDesc as [Primary Service],
	   comp_PRReceivePromoEmails as [Receive Promo Emails],
	   comp_PRReceivePromoFaxes as [Receive Promo Faxes],
	   AvailLicenses as [Available Licenses],
	   ActiveLicenses as [Active Licenses],
	   AdvertisingRevenue as [Advertising Revenue],
	   MembershipRevenue as [Membership Revenue],
	   AvailableUnits as [Available Units],
	   UsedUnits as [Used Units]
  FROM Company WITH (NOLOCK)
       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	   LEFT OUTER JOIN PRService on comp_CompanyID = prse_CompanyID AND prse_Primary = ''Y''
	   LEFT OUTER JOIN (SELECT prse_CompanyID, SUM(QuantityOrdered) As AvailLicenses 
	                      FROM PRService
						 WHERE Category2 = ''License''
                      GROUP BY prse_CompanyID) As T1 ON comp_CompanyID = T1.prse_CompanyID  
	   LEFT OUTER JOIN (SELECT prwsat_CompanyID, COUNT(DISTINCT prwsat_WebUserID) As ActiveLicenses 
	                      FROM PRWebAuditTrail WITH (NOLOCK)
                         WHERE prwsat_CreatedDate >= DATEADD(month, -6, GETDATE())
                      GROUP BY prwsat_CompanyID) As T2 ON comp_CompanyID = T2.prwsat_CompanyID  
	   LEFT OUTER JOIN (SELECT CAST(CustomerNo as Int) CompanyID, SUM(ExtensionAmt) As AdvertisingRevenue
	                      FROM MAS_PRC.dbo.vBBSiInvoiceDetails WITH (NOLOCK)
                         WHERE InvoiceDate >= DATEADD(month, -12, GETDATE())
						   AND Category2 = ''Adverts''
                      GROUP BY CustomerNo) As T3 ON comp_CompanyID = T3.CompanyID  
	   LEFT OUTER JOIN (SELECT CAST(CustomerNo as Int) CompanyID, SUM(DiscountAmt + TaxableAmt + NonTaxableAmt+ SalesTaxAmt) As MembershipRevenue
	                      FROM MAS_PRC.dbo.SO_SalesOrderHeader WITH (NOLOCK)
                         WHERE OrderType = ''R''
						   AND CycleCode <> ''99''
                      GROUP BY CustomerNo) As T4 ON comp_CompanyID = T4.CompanyID  
	   LEFT OUTER JOIN (SELECT prun_CompanyID, SUM(prun_UnitsRemaining) As AvailableUnits
	                      FROM PRServiceUnitAllocation WITH (NOLOCK)
                         WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
                      GROUP BY prun_CompanyID) As T5 ON comp_CompanyID = T5.prun_CompanyID  	
	   LEFT OUTER JOIN (SELECT prsuu_CompanyID, SUM(prsuu_Units) As UsedUnits
	                      FROM PRServiceUnitUsage WITH (NOLOCK)
                         WHERE prsuu_CreatedDate >= DATEADD(YEAR,DATEDIFF(YEAR,0,GETDATE()),0)
                      GROUP BY prsuu_CompanyID) As T6 ON comp_CompanyID = T6.prsuu_CompanyID'
--EXEC usp_TravantCRM_CreateView 'vPRBBOSInternalExport', @Script  
--
--  Temporarily moved to MAS Implementation.sql
--


	--DECLARE @Script varchar(max)
	SET @Script = 
	'CREATE VIEW dbo.vPRCourtCases AS
	SELECT prcc_CourtCaseID,
		   prcc_CompanyID,
		   prcc_CaseNumber,
		   prcc_SuitType,
		   prcc_CaseTitle,
		   prcc_FiledDate,
		   prcc_ClosedDate,
		   prcc_CourtCode,
		   ISNULL(CAST(capt_us as varchar(100)), prcc_CourtCode) as Court,
		   prcc_CaseOperatingStatus,
		   prcc_ClaimAmt,
		   prcc_ClaimAmt_CID,
		   CASE WHEN prcc_ClosedDate IS NULL THEN ''Tracking'' ELSE ''Not Tracking'' END as Tracking,
		   prcc_Notes
	  FROM PRCourtCases WITH (NOLOCK)
		   LEFT OUTER JOIN custom_captions court WITH (NOLOCK) ON prcc_CourtCode = court.capt_code AND court.Capt_Family = ''prcc_CourtCode'''
	EXEC usp_TravantCRM_CreateView 'vPRCourtCases', @Script

	--DECLARE @Script varchar(max)
	SET @Script = 
	'CREATE VIEW dbo.vPRPACAComplaints AS
		SELECT prpa_CompanyID,
			 prpac_PACAComplaintID,
		   prpac_PACALicenseID,
			 prpac_InfRepComplaintCount,
			 prpac_DisInfRepComplaintCount,
			 prpac_ForRepComplaintCount,
			 prpac_DisForRepCompaintCount,
			 prpac_TotalFormalClaimAmt,
			 prpac_TotalFormalClaimAmt_CID
	  FROM PRPACAComplaint WITH (NOLOCK)
			INNER JOIN PRPACALicense ON prpa_PACALicenseId =  prpac_PACALicenseID'

	EXEC usp_TravantCRM_CreateView 'vPRPACAComplaints', @Script


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBBSiClaims AS
SELECT prss_SSFileID,
       prss_RespondentCompanyId,
       prss_CreatedDate,
       prss_Status,
	   prss_OpenedDate,
	   prss_ClosedDate,
	   prss_Meritorious,
	   prss_MeritoriousDate,
	   prss_InitialAmountOwed,
	   prss_PublishedNotes,
	   prss_PublishedIssueDesc,
	   prss_CATDataChanged,
	   CAST(claimantIndustryType.capt_US as varchar(100)) as ClaimantIndustry,
	   CAST(statusType.capt_US as varchar(100)) as [Status],
	   CAST(meritoriousType.capt_US as varchar(100)) as Meritorious,
	   prss_StatusDescription,
	   prss_Publish
  FROM PRSSFile WITH (NOLOCK)
       INNER JOIN Company claimant WITH (NOLOCK) on prss_ClaimantCompanyID = claimant.comp_CompanyID
	   LEFT OUTER JOIN custom_captions claimantIndustryType ON prss_ClaimantIndustryType = claimantIndustryType.capt_code and claimantIndustryType.capt_family = ''comp_PRIndustryType''
	   LEFT OUTER JOIN custom_captions statusType ON prss_Status = statusType.capt_code and statusType.capt_family = ''prss_Status''
	   LEFT OUTER JOIN custom_captions meritoriousType ON prss_Meritorious = meritoriousType.capt_code and meritoriousType.capt_family = ''prss_Meritorious''
 WHERE prss_Type = ''C'' '
EXEC usp_TravantCRM_CreateView 'vPRBBSiClaims', @Script


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBBOSClaimActivitySearch AS
SELECT * FROM (
SELECT ''BBS Claim'' as ClaimType, 
        prss_OpenedDate as FiledDate, 
		cast(prss_SSFileID as varchar(50)) as ClaimID, 
		prss_InitialAmountOwed as ClaimAmount,
        prss_RespondentCompanyId as CompanyID,  
		prss_OpenedDate as BBSiClaimThresholdDate,
		GETDATE() as FederalCivilCaseThresholdDate,
		prss_Status as Status
  FROM PRSSFile
 WHERE prss_Publish = ''Y''
   AND prss_Status IN (''O'', ''C'')
UNION
SELECT ''Lawsuit'' as ClaimType, 
       prcc_FiledDate as FiledDate, 
	   prcc_CaseNumber as ClaimID, 
	   prcc_ClaimAmt as ClaimAmount,
       prcc_CompanyID as CompanyID,
	   GETDATE(),
	   prcc_CreatedDate,
	   ''O'' as Status
  FROM PRCourtCases
UNION
SELECT ''PACA Claim'' as ClaimType, 
       prpac_CreatedDate as FiledDate, 
	   cast(prpac_PACALicenseID as varchar(50)) as ClaimID, 
	   prpac_TotalFormalClaimAmt as ClaimAmount,
       prpa_CompanyId CompanyID,
	   GETDATE(),
	   prpac_CreatedDate,
	   ''O'' as Status
  FROM PRPACAComplaint
  INNER JOIN PRPACALicense WITH (NOLOCK) ON prpac_PACALicenseID = prpa_PACALicenseID AND 
	(
		prpac_InfRepComplaintCount>0 
		OR prpac_DisInfRepComplaintCount>0 
		OR prpac_ForRepComplaintCount>0
		OR prpac_DisForRepCompaintCount>0
	)
) T1'
EXEC usp_TravantCRM_CreateView 'vPRBBOSClaimActivitySearch', @Script


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRCATHistory AS
SELECT prcath_PRSSCATHistoryID,
       prcath_SSFileID,
       prcath_Meritorious,
       prcath_Status,
       prcath_InitialAmountOwed,
       prcath_StatusDescription,
       prcath_PublishedNotes,
       prcath_PublishedIssueDesc,
	   prcath_CreatedDate,
	   prcath_CreatedBy,
       ISNULL(dbo.ufn_FormatUserName(prcath_CreatedBy), RTrim(prwu_FirstName) + '' '' + RTrim(prwu_LastName) + '' (via BBOS)'') as CreatedBy
  FROM PRSSCATHistory
       LEFT OUTER JOIN PRWebUser ON prcath_CreatedBy = prwu_WebUserID'
EXEC usp_TravantCRM_CreateView 'vPRCATHistory', @Script



--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRConnectionList AS
SELECT prcl2_ConnectionListID,
       prcl2_CompanyID,
       prcl2_ConnectionListDate, 
       prcl2_PersonID,
	   prcl2_Source,
	   prcl2_CreatedDate,
	   prcl2_Current,
	   COUNT(prclc_RelatedCompanyID) as CLCount
  FROM PRConnectionList WITH (NOLOCK)
       LEFT OUTER JOIN PRConnectionListCompany WITH (NOLOCK) ON prcl2_ConnectionListID = prclc_ConnectionListID
GROUP BY prcl2_ConnectionListID,
         prcl2_CompanyID,
         prcl2_ConnectionListDate, 
         prcl2_PersonID,
	     prcl2_Source,
	     prcl2_CreatedDate,
		 prcl2_Current'
EXEC usp_TravantCRM_CreateView 'vPRConnectionList', @Script

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRConnectionListDetails AS
SELECT prcl2_ConnectionListID, 
       prclc_ConnectionListCompanyID, 
	   comp_CompanyID as CompanyID, 
	   comp_Name as CompanyName, 
	   comp_PRListingStatus,
	   CityStateCountryShort, 
	   CAST(capt_us as varchar(40)) As IndustryType,
	   tese.prattn_Disabled [TESEDisabled],
	   tesv.prattn_Disabled [TESVDisabled],
	   LastFormSent, 
       LastFormResponse 
   FROM PRConnectionList WITH (NOLOCK)
        INNER JOIN PRConnectionListCompany WITH (NOLOCK) ON prcl2_ConnectionListID = prclc_ConnectionListID
		INNER JOIN Company WITH (NOLOCK) ON prclc_RelatedCompanyID = comp_CompanyID
		INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
		INNER JOIN Custom_Captions ON comp_PRIndustryType = capt_code AND capt_family = ''comp_PRIndustryType''
		LEFT OUTER JOIN PRAttentionLine tese WITH (NOLOCK) ON comp_CompanyID = tese.prattn_CompanyID AND tese.prattn_ItemCode = ''TES-E''
		LEFT OUTER JOIN PRAttentionLine tesv WITH (NOLOCK) ON comp_CompanyID = tesv.prattn_CompanyID AND tesv.prattn_ItemCode = ''TES-V''
		LEFT OUTER JOIN vPRTESLastFormSent ON prtesr_ResponderCompanyID = comp_CompanyID  
                                          AND prtesr_SubjectCompanyID = prcl2_CompanyID 
        LEFT OUTER JOIN vPRTradeReportLastResponse ON prtr_ResponderID = comp_CompanyID  
                                                  AND prtr_SubjectID = prcl2_CompanyID'
EXEC usp_TravantCRM_CreateView 'vPRConnectionListDetails', @Script

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRConnectionListDetailsType AS
SELECT prcl2_ConnectionListID, 
       prclc_ConnectionListCompanyID, 
	   comp_CompanyID as CompanyID, 
	   comp_Name as CompanyName, 
	   CityStateCountryShort, 
	   CAST(capt_us as varchar(40)) As IndustryType, 
	   prcr_Type
   FROM PRConnectionList WITH (NOLOCK)
        INNER JOIN PRConnectionListCompany WITH (NOLOCK) ON prcl2_ConnectionListID = prclc_ConnectionListID
		INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON prcl2_CompanyID = prcr_LeftCompanyID AND prclc_RelatedCompanyID = prcr_RightCompanyID AND prcr_Type IN (''09'',''10'',''11'',''12'',''13'',''14'',''15'',''16'')
		INNER JOIN Company WITH (NOLOCK) ON prclc_RelatedCompanyID = comp_CompanyID
		INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
		INNER JOIN Custom_Captions ON comp_PRIndustryType = capt_code AND capt_family = ''comp_PRIndustryType'''
EXEC usp_TravantCRM_CreateView 'vPRConnectionListDetailsType', @Script


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRPersonExport AS
SELECT DISTINCT 
        pers_PersonID,
        RTRIM(pers_FirstName) as [FirstName],
    	RTRIM(pers_MiddleName) as [MiddleName],
        RTRIM(pers_LastName) as [LastName],
        RTRIM(pers_Suffix) as [Suffix],
        RTRIM(peli_PRTitle) as [Title],
        comp_PRCorrTradestyle AS [Company], 	   
        RTRIM(MailAddr.Addr_Address1) AS [MailingStreet1], 	   
        RTRIM(MailAddr.Addr_Address2) AS [MailingStreet2], 	   
        RTRIM(MailAddr.Addr_Address3) AS [MailingStreet3], 	   
        RTRIM(MailAddr.Addr_Address4) AS [MailingStreet4], 	   
        MailLocation.prci_City AS [MailingCity],      
        ISNULL(MailLocation.prst_Abbreviation, MailLocation.prst_State) AS [MailingState], 	   
        MailAddr.Addr_PostCode AS [MailingPostalCode],        
        MailLocation.prcn_Country AS [MailingCountry], 	   
        RTRIM(PhysicalAddr.Addr_Address1) AS [PhysicalStreet1], 	   
        RTRIM(PhysicalAddr.Addr_Address2) AS [PhysicalStreet2], 	   
        RTRIM(PhysicalAddr.Addr_Address3) AS [PhysicalStreet3], 	   
        RTRIM(PhysicalAddr.Addr_Address4) AS [PhysicalStreet4], 	   
        PhysicalLocation.prci_City AS [PhysicalCity],        
        ISNULL(PhysicalLocation.prst_Abbreviation, PhysicalLocation.prst_State) AS [PhysicalState], 	   
        PhysicalAddr.Addr_PostCode AS [PhysicalPostalCode],        
        PhysicalLocation.prcn_Country AS [PhysicalCountry], 	 
        dbo.ufn_FormatPhone(cphone.phon_CountryCode, cphone.phon_AreaCode, cphone.phon_Number, cphone.phon_PRExtension) As [CompanyPhone], 
        dbo.ufn_FormatPhone(pphone.phon_CountryCode, pphone.phon_AreaCode, pphone.phon_Number, pphone.phon_PRExtension) As [BusinessPhone], 
        dbo.ufn_FormatPhone(pfax.phon_CountryCode, pfax.phon_AreaCode, pfax.phon_Number, pfax.phon_PRExtension) As [BusinessFax],
        RTRIM(emai_EmailAddress) AS [Email],
        comp_CompanyId AS [BBID],
		CAST(capt_us as varchar(40)) As IndustryType 	   
   FROM Person WITH (NOLOCK)
        INNER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID
	    INNER JOIN Company WITH (NOLOCK) ON peli_CompanyID = comp_CompanyID    
		INNER JOIN Custom_Captions ON comp_PRIndustryType = capt_code AND capt_family = ''comp_PRIndustryType''   
        LEFT OUTER JOIN Address_Link MailAddrLink WITH (NOLOCK) ON comp_CompanyID = MailAddrLink.adli_CompanyID  AND MailAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, ''M'')        
        LEFT OUTER JOIN Address MailAddr WITH (NOLOCK) ON MailAddrLink.adli_AddressID = MailAddr.addr_AddressID 
        LEFT OUTER JOIN vPRLocation MailLocation ON MailAddr.addr_PRCityID = MailLocation.prci_CityID        
        LEFT OUTER JOIN Address_Link PhysicalAddrLink WITH (NOLOCK) ON comp_CompanyID = PhysicalAddrLink.adli_CompanyID    AND PhysicalAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, ''PH'')        
        LEFT OUTER JOIN Address PhysicalAddr WITH (NOLOCK) ON PhysicalAddrLink.adli_AddressID = PhysicalAddr.addr_AddressID 
        LEFT OUTER JOIN vPRLocation PhysicalLocation ON PhysicalAddr.addr_PRCityID = PhysicalLocation.prci_CityID 	  
        LEFT OUTER JOIN vPRPersonEmail WITH (NOLOCK) ON pers_PersonID = elink_RecordID AND comp_CompanyID = emai_CompanyID AND ELink_Type = ''E'' AND emai_PRPreferredPublished=''Y'' 
		LEFT OUTER JOIN vPRCompanyPhone cphone WITH (NOLOCK) ON peli_CompanyID = cphone.plink_RecordID AND  cphone.phon_PRIsPhone = ''Y'' AND cphone.phon_PRPreferredPublished = ''Y''
		LEFT OUTER JOIN vPRPersonPhone pphone WITH (NOLOCK) ON peli_PersonID = pphone.plink_RecordID AND  pphone.phon_PRIsPhone = ''Y'' AND pphone.phon_PRPreferredPublished = ''Y''
        LEFT OUTER JOIN vPRPersonPhone pfax WITH (NOLOCK) ON peli_PersonID = pfax.plink_RecordID AND  pfax.phon_PRIsFax = ''Y'' AND pfax.phon_PRPreferredPublished = ''Y''
  WHERE comp_PRListingStatus IN (''L'', ''H'', ''N3'', ''N5'', ''N6'', ''LUV'')
    AND peli_PRStatus = ''1''';
EXEC usp_TravantCRM_CreateView 'vPRPersonExport', @Script


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBusinessReportPurchase AS
SELECT prbrp_BusinessReportPurchaseID, prbrp_CreatedDate, prpay_NameOnCard, prbrp_SubmitterEmail, prod_Name, prpay_Amount, prbrp_CompanyID, comp_Name,
       prbrp_RequestsMembershipInfo, prbrp_IndustryType, prpay_CreditCardType, prpay_CreditCardNumber, prpay_ExpirationMonth, prpay_ExpirationYear,
	   prpay_AuthorizationCode, prpay_Street1, prpay_Street2, prpay_City, prpay_StateID, prpay_CountryID, prpay_PostalCode, prod_Code
 FROM PRBusinessReportPurchase WITH (NOLOCK)
      INNER JOIN PRPayment WITH (NOLOCK) ON prpay_PaymentID = prbrp_PaymentID
      INNER JOIN Company WITH (NOLOCK) ON prbrp_CompanyID = comp_CompanyID
	  INNER JOIN NewProduct WITH (NOLOCK) ON prbrp_ProductID = prod_ProductID';
EXEC usp_TravantCRM_CreateView 'vPRBusinessReportPurchase', @Script


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRPACALicense AS
SELECT prpa_PACALicenseId,
       prpa_EffectiveDate,
       prpa_ExpirationDate,
       prpa_Current,
       prpa_Publish,
       prpa_LicenseNumber,
       prpa_CompanyId,
	   comp_PRListingStatus,
       prpa_TypeFruitVeg,
       prpa_ProfCode,
	   prpa_Address1,
	   prpa_Address2,
	   prpa_City,
	   prpa_State,
	   prpa_PostCode
  FROM PRPACALicense WITH (NOLOCK)                         
       LEFT OUTER JOIN Company WITH (NOLOCK) ON prpa_CompanyID = comp_CompanyID'
EXEC usp_TravantCRM_CreateView 'vPRPACALicense', @Script


--DECLARE @Script varchar(max);
SET @Script = 'CREATE VIEW vPRMapAddresses AS 
SELECT comp_CompanyID,
       addr_AddressID,
	   comp_PRCorrTradestyle as Title,
       ''<strong>''+ comp_PRCorrTradestyle + ''</strong><br/>'' + CASE WHEN prra_RatingLine IS NULL THEN '''' ELSE ''Rating: '' + prra_RatingLine + ''<br/>'' END + RTRIM(addr_Address1) + ''<br/>'' +  RTRIM(prci_City) + '' '' + RTRIM(prst_Abbreviation) + '', '' + ISNULL(RTRIM(Addr_PostCode), '''') as Display,
		''blue'' as Icon,
	    RTRIM(addr_Address1) + '','' + RTRIM(prci_City) + '','' + RTRIM(prst_Abbreviation) + '','' +ISNULL(RTRIM(Addr_PostCode), '''') as Address,
		addr_PRLatitude,
		addr_PRLongitude
 FROM Company WITH (NOLOCK)
      INNER JOIN vPRAddress ON comp_CompanyID = adli_CompanyID
	  LEFT OUTER JOIN vPRCompanyRating ON comp_CompanyID = prra_CompanyID AND prra_Current = ''Y''
WHERE prcn_CountryId IN (1, 2, 3)
  AND (addr_PRLatitude IS NULL OR addr_PRLatitude < 9999) -- Magic number meaning the address cannot be geocoded
  AND addr_AddressID IN (
		SELECT addr_AddressID 
		 FROM (
		SELECT addr_AddressID, adli_CompanyID, adli_Type,
				ROW_NUMBER() OVER (PARTITION BY adli_CompanyID ORDER BY CASE AdLi_Type
				WHEN ''PH'' THEN 1
				WHEN ''M'' THEN 2    
				WHEN ''W'' THEN 3         
				WHEN ''I'' THEN 4
				WHEN ''O'' THEN 5 END) as RowNum
		  FROM vPRAddress
		WHERE addr_PRPublish = ''Y''
		  AND addr_Address1 NOT LIKE ''PO Box%''
		  AND addr_Address1 NOT LIKE ''P.O. Box%''
		) T1
		WHERE RowNum = 1)'
EXEC usp_TravantCRM_CreateView 'vPRMapAddresses', @Script 

--DECLARE @Script varchar(max);
SET @Script = 'CREATE VIEW vPRWatchDogMapAddresses AS 
SELECT comp_CompanyID,
       addr_AddressID,
	   comp_PRCorrTradestyle + '' - '' + prwucl_Name as Title,
       ''<strong>''+ comp_PRCorrTradestyle + ''</strong><br/><em>'' + prwucl_Name + ''</em><br/>'' + CASE WHEN prra_RatingLine IS NULL THEN '''' ELSE ''Rating: '' + prra_RatingLine + ''<br/>'' END + RTRIM(addr_Address1) + ''<br/>'' +  RTRIM(prci_City) + '' '' + RTRIM(prst_Abbreviation) + '', '' + ISNULL(RTRIM(Addr_PostCode), '''') as Display,
		prwucl_WebUserListID,
		prwucl_Name as WDCategoryName,
		prwucl_CategoryIcon,
		CASE WHEN prwucl_CategoryIcon LIKE ''%blue%'' THEN ''blue''
		     WHEN prwucl_CategoryIcon LIKE ''%red%'' THEN ''red''
		     WHEN prwucl_CategoryIcon LIKE ''%black%'' THEN ''black''
			 WHEN prwucl_CategoryIcon LIKE ''%green%'' THEN ''green''
			 WHEN prwucl_CategoryIcon LIKE ''%yellow%'' THEN ''yellow''
			END Icon,
	    RTRIM(addr_Address1) + '','' + RTRIM(prci_City) + '','' + RTRIM(prst_Abbreviation) + '','' +ISNULL(RTRIM(Addr_PostCode), '''') as Address,
		addr_PRLatitude,
		addr_PRLongitude
 FROM PRWebUserList
      INNER JOIN PRWebUserListDetail ON prwucl_WebUserListID = prwuld_WebUserListID
	  INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prwuld_AssociatedID 
	  INNER JOIN vPRAddress ON comp_CompanyID = adli_CompanyID
	  LEFT OUTER JOIN vPRCompanyRating ON comp_CompanyID = prra_CompanyID AND prra_Current = ''Y''
WHERE prcn_CountryId IN (1, 2, 3)
  AND (addr_PRLatitude IS NULL OR addr_PRLatitude < 9999) -- Magic number meaning the address cannot be geocoded
  AND addr_AddressID IN (
		SELECT addr_AddressID 
		 FROM (
		SELECT addr_AddressID, adli_CompanyID, adli_Type,
				ROW_NUMBER() OVER (PARTITION BY adli_CompanyID ORDER BY CASE AdLi_Type
				WHEN ''PH'' THEN 1
				WHEN ''M'' THEN 2    
				WHEN ''W'' THEN 3         
				WHEN ''I'' THEN 4
				WHEN ''O'' THEN 5 END) as RowNum
		  FROM vPRAddress
		WHERE addr_PRPublish = ''Y''
		  AND addr_Address1 NOT LIKE ''PO Box%''
		  AND addr_Address1 NOT LIKE ''P.O. Box%''
		) T1
		WHERE RowNum = 1)'
EXEC usp_TravantCRM_CreateView 'vPRWatchDogMapAddresses', @Script 

--DECLARE @Script varchar(max);
SET @Script = 
'CREATE VIEW dbo.vPRExternalNews AS 
SELECT pren_ExternalNewsID,
       pren_SubjectCompanyID,
	   comp_Name,
       pren_Name,
       pren_URL,
       pren_Description,
       pren_PrimarySourceCode,
       pren_SecondarySourceCode,
       pren_SecondarySourceName,
       pren_PublishDateTime
  FROM PRExternalNews WITH (NOLOCK)
       INNER JOIN Company WITH (NOLOCK) ON pren_SubjectCompanyID = comp_CompanyID'
exec usp_TravantCRM_CreateView 'vPRExternalNews', @Script 


--DECLARE @Script varchar(max);
SET @Script = '
CREATE VIEW vPersonEmailCaption AS 
SELECT * 
 FROM vPersonEmail 
      LEFT JOIN Custom_Captions ON UPPER(ELink_Type) = UPPER(Capt_Code) AND UPPER(Capt_Family)=''ELINK_TYPE'''
EXEC usp_TravantCRM_CreateView 'vPersonEmailCaption', @Script, null, 0, null, null, null, 'Email'          

--DECLARE @Script VARCHAR(MAX)
SET @Script = 
'CREATE VIEW dbo.vPRWebUserLocalSourceAccess AS 
SELECT DISTINCT comp_PRHQId,  
       dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix, 0) AS Pers_FullName,  
       PeLi_PersonLinkId, PeLi_PersonId, peli_PRTitle, dbo.ufn_GetCustomCaptionValue(''pers_TitleCode'', peli_PRTitleCode, ''en-us'') AS peli_Title,  
       prwu_WebUserID, prwu_AccessLevel, prwu_LastLoginDateTime, dbo.ufn_GetCustomCaptionValue(''prwu_AccessLevel'', prwu_AccessLevel, ''en-us'') AS AccessLevelDesc,  
       Emai_EmailAddress, CityStateCountryShort AS location, prwu_ServiceCode,
       ISNULL(prod_PRWebAccessLevel, 0) As MaxAccessLevel,
       dbo.ufn_GetLocalSourceAccessList(prwu_WebUserID, 0) as LocalSourceDataAccess
FROM Person_Link WITH (NOLOCK)  
     INNER JOIN Person WITH (NOLOCK) ON Pers_PersonId = PeLi_PersonId  
     INNER JOIN Company WITH (NOLOCK) ON PeLi_CompanyID = Company.Comp_CompanyId  
     INNER JOIN vPRCompanyLocation ON vPRCompanyLocation.Comp_CompanyId = Company.Comp_CompanyId   
     INNER JOIN PRWebUser WITH (NOLOCK) ON PeLi_PersonLinkId = PRWebUser.prwu_PersonLinkID  
	 LEFT OUTER JOIN vPRPersonEmail as EM WITH (NOLOCK) ON Pers_PersonId = EM.elink_RecordID AND EM.Emai_CompanyID = PeLi_CompanyID AND EM.ELink_Type = ''E'' 
     LEFT OUTER JOIN NewProduct ON prod_code = prwu_ServiceCode
WHERE prwu_AccessLevel > 0'
EXEC usp_TravantCRM_CreateView 'vPRWebUserLocalSourceAccess', @Script 


--DECLARE @Script VARCHAR(MAX)
SET @Script = 
'CREATE VIEW dbo.vPRLocalSource AS 
SELECT prls_LocalSourceID, prls_CompanyID, prls_RegionStateID, prst_Abbreviation, prst_State, prls_AlsoOperates, prls_Organic, prls_TotalAcres
 FROM PRLocalSource
      INNER JOIN PRState ON prls_RegionStateID = prst_StateID'
EXEC usp_TravantCRM_CreateView 'vPRLocalSource', @Script 


--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBBScoreLumber AS 
	SELECT prbs_BBScoreId,
	       prbs_CompanyID,  
           prbs_Date,
		   prbs_BBScore as Model1Score,  
		   prbs_NewBBScore as Model2score  
     FROM PRBBScore WITH (NOLOCK) ';
EXEC usp_TravantCRM_CreateView 'vPRBBScoreLumber', @Script, null, 0, null, null, null, 'PRBBScore'   

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBBScoreSearch AS 
	SELECT prbs_BBScoreId,
	       prbs_CompanyID,  
           prbs_Date,
		   prbs_BBScore,
		   comp_PRIndustryType
     FROM PRBBScore WITH (NOLOCK) 
	      INNER JOIN Company ON prbs_CompanyID = comp_CompanyID
  WHERE prbs_Current=''Y''
    AND prbs_PRPublish=''Y''
    AND comp_PRPublishBBScore=''Y''';
EXEC usp_TravantCRM_CreateView 'vPRBBScoreSearch', @Script, null, 0, null, null, null, 'PRBBScore'   

--DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBBScoreChange AS 
SELECT PRBBScore.prbs_CompanyID,
       PRBBScore.prbs_BBScore,
	   PRBBScore.prbs_CreatedDate,
	   PRBBScore.prbs_Current,
	   T2.prbs_BBScore as [PreviousScore],
	   T2.prbs_CreatedDate as [PreviousDate]
  FROM PRBBScore
       INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = PRBBScore.prbs_CompanyID
       LEFT OUTER JOIN (SELECT * FROM (
							SELECT prbs_CompanyID,
								   prbs_BBScore,
								   prbs_CreatedDate,
								   ROW_NUMBER() OVER (PARTITION BY prbs_CompanyID ORDER BY prbs_CreatedDate DESC) as RowNum
							  FROM PRBBScore
							 WHERE prbs_Current IS NULL
							   AND prbs_PRPublish=''Y'') T1 WHERE RowNum = 1  
	                   ) T2 ON PRBBScore.prbs_CompanyID = T2.prbs_CompanyID
 WHERE prbs_Current=''Y''
   AND prbs_PRPublish=''Y''
   AND comp_PRPublishBBScore=''Y''';
EXEC usp_TravantCRM_CreateView 'vPRBBScoreChange', @Script, null, 0, null, null, null, 'PRBBScore'   

Go



-- notice this view is not registered with accpac; this view is not used directly by any accpac components
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vTESEligibleCompany]') )
    drop View [dbo].[vTESEligibleCompany]
GO
-- adding a restriction to prevent NULL prcr_Tier from returning
CREATE VIEW dbo.vTESEligibleCompany 
AS
Select RelatedCompanyId, SubjectCompanyId, prcr_Tier, RelatedCompanyName = comp_Name
from 
(Select * from 
    (
     Select 
        SubjectCompanyId = prcr_RightCompanyId,  
        RelatedCompanyId = prcr_LeftCompanyId,
        prcr_Tier
     from vPRCompanyRelationship
     where prcr_Tier is not null
     UNION 
     Select 
        SubjectCompanyId = prcr_LeftCompanyId,  
        RelatedCompanyId = prcr_RightCompanyId,
        prcr_Tier
     from vPRCompanyRelationship
     where prcr_Tier is not null
    ) AJoin
)vCR
Join Company On RelatedCompanyId = comp_companyid
            AND comp_PRReceiveTES = 'Y'
            AND comp_PRListingStatus in ('L','H','N1','N2','LUV') 
LEFT OUTER JOIN 
  (
    Select prtesr_ResponderCompanyID, request_count = count(1) from PRTESRequest 
    Where prtesr_CreatedDate >= DateAdd(Day, -90, getDate())
    Group By prtesr_ResponderCompanyID
  ) TESRequests ON prtesr_ResponderCompanyID = RelatedCompanyId 

WHERE (request_count is null or request_count < 50)
  AND Not Exists (Select 1 from PRARAging 
                          where praa_CompanyId = RelatedCompanyId 
                            AND praa_Date >= DateAdd(Day, -90, getDate()) )
  AND Not Exists (select 1 from PRTESRequest
                  WHERE prtesr_SubjectCompanyID = SubjectCompanyId
					AND prtesr_CreatedDate >= DateAdd(Day, -27, getDate()) )
  AND Not Exists (Select 1 from PRTradeReport 
                          where prtr_ResponderId = RelatedCompanyId 
                            AND prtr_SubjectId = SubjectCompanyId
                            AND prtr_Date >= DateAdd(Day, -45, getDate())
                 )
GO
               


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRSalesRetrievals]'))
	DROP VIEW [dbo].[vPRSalesRetrievals]
GO

CREATE VIEW [dbo].[vPRSalesRetrievals] AS 
SELECT DISTINCT
    [BBID] = comp_CompanyID,
    [Company Name] = c.comp_Name,
    [Listing Status] = CAST(stat.capt_US as varchar(40)),
    [Book Section] = comp_PRIndustryType,
    [Type] = comp_PRType,
    [Listing City] = l.prci_City,
    [Listing State] = ISNULL(l.prst_State, ''),
    [Listing Country] = l.prcn_Country,
    [Sales Terr] = LEFT(CRM.dbo.ufn_GetCompanySalesTerritory(comp_CompanyId), 2),
    [TM Status] = ISNULL(comp_PRTMFMAward, ''),
    [TM Award Date] =CASE WHEN comp_PRTMFMAward IS NOT NULL THEN CONVERT(nvarchar(30), comp_PRTMFMAwardDate, 101) ELSE '' END,
    [TM Age] = CASE WHEN comp_PRTMFMAward IS NOT NULL THEN YEAR(GETDATE()) - YEAR(comp_PRTMFMAwardDate) ELSE '' END,
    [Business Start] = ISNULL(CONVERT(nvarchar(30), dbo.ufn_GetBusinessEventDate(comp_CompanyID, 9, 0, 0, NULL),101),''),
    [Years in Business] = ISNULL(2009 - YEAR(dbo.ufn_GetBusinessEventDate(comp_CompanyID, 9, 0, 0, NULL)),''),
    [Attn Line] = dbo.ufn_GetAttentionLine (comp_CompanyId, 'BILL'),
    [Addr Line 1] = addr_Address1,
    [Addr Line 2] = ISNULL(addr_Address2,''),
    [Addr Line 3] = ISNULL(addr_Address3,''),
    [City] = a.prci_City,
    [Abbr] = a.prst_Abbreviation,
    [Zip] = a.addr_uszipfive,
    [Phone] = ISNULL(dbo.ufn_FormatPhone(cphone.phon_CountryCode, cphone.phon_AreaCode, cphone.phon_Number, cphone.phon_PRExtension),''),
    [Fax] = ISNULL(dbo.ufn_FormatPhone(cfax.phon_CountryCode, cfax.phon_AreaCode, cfax.phon_Number, cfax.phon_PRExtension),''),
    [Email] = RTRIM(Emai_EmailAddress),
    [Website] = ISNULL((SELECT TOP 1 emai_PRWebAddress
	                      FROM vCompanyEmail WITH (NOLOCK)
	                     WHERE elink_RecordID = comp_CompanyID 
	                       AND ELink_Type = 'W'
	                  ORDER BY emai_PRPreferredInternal desc), ''),
    [Prime Service] = ISNULL(dbo.ufn_GetPrimaryService(comp_CompanyID),''),
    [CWE] = ISNULL(prcw_Name,''),
    [Int Rating] = ISNULL(prin_Name,''),
    [Pay Rating] = ISNULL(prpy_Name,''),
    [Current Numerals] = ISNULL(prra_AssignedRatingNumerals,''),
    [Rating Line] = ISNULL(prra_RatingLine,''),
    [Classification Line] = ISNULL([dbo].[ufn_GetListingClassificationBlock] (c.comp_CompanyID, c.comp_PRIndustryType, char(10)),''),
    [Level 1 Classification] = ISNULL([dbo].[ufn_GetLevel1Classifications](c.comp_CompanyID,2),''),
    [Commodity Line] = ISNULL(dbo.ufn_GetListingCommodityBlock(c.comp_CompanyID, c.comp_PRIndustryType, char(10)),''),
    [DL Line Count] = ISNULL(dbo.ufn_GetListingDLLineCount(c.comp_CompanyID),''),
    [Has Logo] = ISNULL(comp_PRPublishLogo, 'N'),
    [Advertiser] = CASE WHEN TableB.prse_ServiceCode is not null then 'Y' else 'N' end ,
    [Promo Opt Out] =  case when comp_PRReceivePromoFaxes is null then 'Y' when comp_PRReceivePromoEmails is null then 'Y' else 'N' end
FROM Company C with (NOLOCK)
	INNER JOIN vPRLocation l WITH (NOLOCK) on l.prci_CityID = comp_PRListingCityID
	LEFT OUTER JOIN vPRAddress a WITH (NOLOCK) on adli_CompanyID = Comp_CompanyId AND adli_PRDefaultMailing = 'Y'
	LEFT OUTER JOIN vPRCurrentRating r WITH (NOLOCK) on comp_CompanyID = prra_CompanyID
	LEFT OUTER JOIN (SELECT prse_HQID as HQID, prse_ServiceCode
                       FROM PRService WITH (NOLOCK)
                      WHERE prse_ServiceCode in ('BPAD','RGAD','IADBUT','IASPON', 'LP', 'IADVB'))TableB on TableB.HQID = comp_PRHQID
	LEFT OUTER JOIN Custom_Captions stat with (nolock) on capt_Family = 'comp_PRListingStatus' AND capt_Code =  Comp_PRListingStatus
	LEFT OUTER JOIN vCompanyEmail EM WITH (NOLOCK) ON comp_CompanyID = elink_RecordID AND ELink_Type = 'E' AND emai_PRPreferredPublished='Y' 
	--LEFT OUTER JOIN Email as EM WITH (NOLOCK) ON comp_CompanyID = EM.emai_CompanyID AND EM.emai_PersonID IS NULL AND EM.Emai_Type='E' AND EM.emai_PRPreferredInternal='Y'
	LEFT OUTER JOIN vPRCompanyPhone cfax WITH (NOLOCK) ON comp_CompanyID = cfax.plink_RecordID AND  cfax.phon_PRIsFax = 'Y' AND cfax.phon_PRPreferredPublished = 'Y'
	--LEFT OUTER JOIN Phone fax WITH (NOLOCK) ON comp_CompanyID = fax.phon_CompanyID AND fax.phon_PersonID IS NULL AND fax.phon_PRIsFax = 'Y' AND fax.phon_PRPreferredInternal = 'Y' 
	LEFT OUTER JOIN vPRCompanyPhone cphone WITH (NOLOCK) ON comp_CompanyID = cphone.plink_RecordID AND  cphone.phon_PRIsPhone = 'Y' AND cphone.phon_PRPreferredPublished = 'Y'
	--LEFT OUTER JOIN Phone phone WITH (NOLOCK) ON comp_CompanyID = phone.phon_CompanyID AND phone.phon_PersonID IS NULL AND phone.phon_PRIsPhone = 'Y' AND phone.phon_PRPreferredInternal = 'Y';

--Where 
--   comp_PRListingStatus in ('L','H') 
--   and   comp_PRType = 'H';
GO


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vLRLCompany]'))
	DROP VIEW [dbo].[vLRLCompany]
GO
CREATE VIEW [dbo].[vLRLCompany] AS 
SELECT BBID = comp_CompanyID, 
	   HQID = comp_PRHQID, 
	   [Company Name] = comp_PRCorrTradestyle, 
	   [Type] = comp_PRType, 
       [Listing City] = l.prci_City, 
       [Listing State] = ISNULL(l.prst_Abbreviation, l.prst_State), 
       [Listing Country] = l.prcn_Country, 
       Industry = comp_PRIndustryType, 
       [CL Message] = case comp_PRType 
						when 'H' then 
							case 
								when comp_PRIndustryType in ('P','T') then 
									case 
										when comp_PRConnectionListDate < dateadd(m,-24,getdate()) then 'Request Update' 
                                        when comp_PRConnectionListDate is null then 'Request First Time' 
                                        else null 
                                    end 
								else null 
							end 
                        else null end, 
		[Last CL Date] = convert(nvarchar(20),comp_PRConnectionListDate,107), 
        [Volume Message] = case comp_PRType 
							when 'H' then 
								case 
									when comp_PRIndustryType in ('P','T') then 
										case 
											when prcp_Volume is null then 'Request Volume' 
											when prcp_Volume = '' then 'Request Volume' 
											else null 
										end 
									else null 
								end 
							Else null end, 
         [Logo] = comp_PRLogo, 
         [PublishLogo] = comp_PRPublishLogo,
         [Has DL] = CASE WHEN DLBBID IS NOT NULL AND comp_PRIndustryType != 'L' THEN 'Y' END, 
         [Attention Line] =  Addressee, 
         [Address 1] = [Addr1], 
         [Address 2] = [Addr2], 
         [Address 3] = [Addr3], 
         [Address 4] = [Addr4], 
         [Mailing City] = MCity, 
         [Mailing State] = [MState], 
         [Mailing Country] = [MCountry], 
         [Mailing Zip] = [MZip] , 
         [Member] = case 
						when dbo.ufn_GetPrimaryService(comp_PRHQID) is not null then 'Y' 
                        else null end, 
		 [Marketing Message] = CASE comp_PRType 
								WHEN 'H' THEN 
									CASE 
										WHEN comp_PRIndustryType in ('P','T','S') THEN 
											CASE 
												WHEN DLBBID is null THEN 
													(SELECT capt_us FROM Custom_Captions WHERE capt_family = 'LRLMarketingMessage' and capt_code = 'ProduceNoDL') 
												WHEN dbo.ufn_GetPrimaryService(comp_PRHQID) is null THEN 
													(SELECT capt_us FROM Custom_Captions WHERE capt_family = 'LRLMarketingMessage' and capt_code = 'ProduceDLNotMember') 
												WHEN comp_PRLogo is null THEN 
													(SELECT capt_us FROM Custom_Captions WHERE capt_family = 'LRLMarketingMessage' and capt_code = 'ProduceDLMemberNoLogo') 
												ELSE 
													(SELECT capt_us FROM Custom_Captions WHERE capt_family = 'LRLMarketingMessage' and capt_code = 'ProduceDLMemberLogo') 
			                                END 
		                                ELSE 
			                                CASE 
											    WHEN dbo.ufn_GetPrimaryService(comp_PRHQID) is null THEN 
												    (SELECT capt_us FROM Custom_Captions WHERE capt_family = 'LRLMarketingMessage' and capt_code = 'LumberNotMember') 
												ELSE 
													(SELECT capt_us FROM Custom_Captions WHERE capt_family = 'LRLMarketingMessage' and capt_code = 'LumberMember') 
												END 
											END 
										ELSE null END, 
        null as TESM_Email, 
        TESM_Title, 
        TESM_Addressee, 
        TESM_Disabled, 
        TESE_Email, 
        TESE_Title, 
        TESE_Addressee, 
        TESE_Disabled,
        dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, 'en-us') as IndustryTypeMeaning,
        dbo.ufn_GetCustomCaptionValue('comp_PRType', comp_PRType, 'en-us') as TypeMeaning,
        [AttnEmail],
		dbo.ufn_GetLevel1Classifications(comp_CompanyID, 0) as Level1ClassificationIDs
   FROM Company with (nolock) 
        INNER JOIN vPRLocation l with (nolock) on prci_CityID = comp_PRListingCityID 
        LEFT OUTER JOIN PRCompanyProfile with (nolock) on comp_CompanyID = prcp_CompanyID 
        LEFT OUTER JOIN (SELECT DISTINCT comp_PRHQID as DLBBID 
                           FROM Company WITH (NOLOCK) 
                          WHERE dbo.ufn_GetListingDLLineCount (comp_CompanyID)>0) DL on comp_CompanyID = DLBBID 
		LEFT OUTER JOIN (SELECT prattn_CompanyID as AttnBBID,
								[Addressee] = dbo.ufn_GetAttentionLine (prattn_CompanyID, 'LRL'), 
                                [Addr1] = Addr_Address1,
                                [Addr2] = Addr_Address2,
                                [Addr3] = Addr_Address3,
                                [Addr4] = Addr_Address4, 
                                [MCity] = prci_City, 
                                [MState] = prst_Abbreviation, 
                                [MCountry] = prcn_Country, 
                                [MZip] = addr_PostCode,
                                [AttnEmail] = rtrim(emai_EmailAddress)
                           FROM PRAttentionLine with (nolock) 
                                INNER JOIN company with (nolock) on comp_CompanyID = prattn_CompanyID 
															and comp_PRType = 'H' 
                                LEFT OUTER JOIN vPRAddress with (nolock) on addr_addressID = prattn_AddressID 
                                LEFT OUTER JOIN Email on emai_EmailID = prattn_EmailID 
                          WHERE prattn_ItemCode = 'LRL') Attn on AttnBBID = comp_CompanyID 
            LEFT OUTER JOIN (SELECT prattn_CompanyID as TESM_BBID,
							        [TESM_Addressee] = dbo.ufn_GetAttentionLine (prattn_CompanyID, 'TES-M'), 
							        [TESM_Title] = peli_PRTitle, 
							        [TESM_Disabled] = prattn_Disabled 
                               FROM PRAttentionLine with (nolock) 
                                    INNER JOIN company with (nolock) on comp_CompanyID = prattn_CompanyID 
														and comp_PRType = 'H' 
                                    LEFT OUTER JOIN Person_Link on peli_PersonID = prattn_PersonID 
														and peli_CompanyID = prattn_CompanyID 
														and peli_PRStatus in (1,2) 
                              WHERE prattn_ItemCode = 'TES-M') TESM on TESM_BBID = comp_CompanyID 
            LEFT OUTER JOIN (SELECT prattn_CompanyID as TESE_BBID,
                                    [TESE_Addressee] = dbo.ufn_GetAttentionLine (prattn_CompanyID, 'TES-E'), 
                                    [TESE_Email] = rtrim(emai_EmailAddress), 
                                    [TESE_Title] = peli_PRTitle, 
                                    [TESE_Disabled] = prattn_Disabled 
                               FROM PRAttentionLine with (nolock) 
                                    INNER JOIN company with (nolock) on comp_CompanyID = prattn_CompanyID 
														and comp_PRType = 'H' 
                                    LEFT OUTER JOIN Email on prattn_EmailID = Emai_EmailId 
                                    LEFT OUTER JOIN Person_Link on peli_PersonID = prattn_PersonID 
														and peli_CompanyID = prattn_CompanyID 
														and peli_PRStatus in (1,2) 
                              WHERE prattn_ItemCode = 'TES-E') TESE on TESE_BBID = comp_CompanyID
Go


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vLRLPerson]'))
	DROP VIEW [dbo].[vLRLPerson]
GO
CREATE VIEW [dbo].[vLRLPerson] AS 
SELECT [PersonID] = peli_PersonID, 
	   [BBID] = peli_CompanyID, 
	   [Formatted Name] = dbo.ufn_FormatPersonByID (peli_PersonID), 
	   [First Name] = rtrim(pers_FirstName), 
	   [Last Name] = rtrim(pers_LastName), 
	   [Title] = peli_PRTitle, 
	   [Start Date] = peli_PRStartDate, 
	   [E-Mail Address] = rtrim(emai_EmailAddress), 
	   [Pub in BBOS] = peli_PREBBPublish, 
	   peli_PRPctOwned, 
       [Order] = RANK() OVER (PARTITION BY peli_CompanyID ORDER BY capt_Order, pers_FullName asc),
	   HasLicense
  FROM vPRPersonnelListing 
       LEFT OUTER JOIN Custom_Captions on capt_Code = peli_PRTitleCode 
									AND capt_Family = 'pers_TitleCode' 
 WHERE peli_PRStatus in (1,2)
Go


CREATE OR ALTER VIEW [dbo].vPRPrimaryMembers AS 
SELECT CompanyID = ent.Comp_CompanyId,
	   HQID = ent.comp_PRHQId,
	   ServiceType = it.ItemCode
  FROM MAS_PRC.dbo.SO_SalesOrderDetail sod WITH (NOLOCK)
       INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader soh WITH (NOLOCK) ON soh.SalesOrderNo = sod.SalesOrderNo
       INNER JOIN MAS_PRC.dbo.CI_Item it WITH (NOLOCK) ON it.ItemCode = sod.ItemCode
									AND it.ItemType = 1
									AND it.Category2 = 'PRIMARY'
       INNER JOIN Company m WITH (NOLOCK) ON m.comp_CompanyID = CAST(soh.CustomerNo AS INT)
       INNER JOIN Company ent WITH (NOLOCK) ON ent.comp_PRHQId = m.comp_PRHQId
WHERE CycleCode <> '99'
Go



IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRRetailersOnlineOnly]'))
	DROP VIEW [dbo].vPRRetailersOnlineOnly
GO
CREATE VIEW [dbo].vPRRetailersOnlineOnly AS 
SELECT comp_PRHQID, comp_CompanyID, comp_Name, comp_PRType, capt_us as ListingStatus 
 FROM (
	SELECT comp_PRHQID, comp_CompanyID, Company.comp_Name, comp_PRType, comp_PRListingStatus
	  FROM Company WITH (NOLOCK)
		   INNER JOIN PRCompanyClassification WITH (NOLOCK) ON comp_CompanyID = prc2_CompanyID AND prc2_ClassificationID = 330
		   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
		   LEFT OUTER JOIN vPRCompanyRating ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
	 WHERE comp_CompanyID IN (SELECT prc2_CompanyID FROM PRCompanyClassification WITH (NOLOCK) GROUP BY prc2_CompanyID HAVING COUNT(1) = 1)
	   AND comp_PRListingStatus IN ('L', 'H')
	   AND prcn_CountryID IN (1,2,3)
	   AND comp_PRIndustryType <> 'L'
	   AND comp_PRHQID NOT IN (SELECT DISTINCT comp_PRHQID FROM Company WITH (NOLOCK) INNER JOIN PRDescriptiveLine WITH (NOLOCK) ON comp_CompanyID = prdl_CompanyID AND comp_PRPublishDL='Y')
	   AND comp_PRHQID NOT IN (SELECT DISTINCT prse_HQID FROM PRService WITH (NOLOCK) WHERE prse_Primary = 'Y')
	   AND prra_CreditWorthID IS NULL
	   AND prra_IntegrityID IS NULL
	   AND prra_PayRatingID IS NULL
	   AND (prra_AssignedRatingNumerals IS NULL OR
			(prra_AssignedRatingNumerals NOT LIKE '%(60)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(62)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(63)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(68)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(80)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(81)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(82)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(83)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(84)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(86)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(90)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(136)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(137)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(142)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(143)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(144)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(145)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(146)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(147)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(148)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(149)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(150)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(154)%')
			)
	   AND (prc2_NumberOfStores IS NULL
			OR prc2_NumberOfStores IN ('0', '1', '2', '3', '4','5'))
	UNION
	SELECT comp_PRHQID, comp_CompanyID, Company.comp_Name, comp_PRType, comp_PRListingStatus
	  FROM Company WITH (NOLOCK)
		   INNER JOIN PRCompanyClassification WITH (NOLOCK) ON comp_CompanyID = prc2_CompanyID AND prc2_ClassificationID = 330
		   INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
		   LEFT OUTER JOIN PRRating ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
	 WHERE comp_CompanyID IN (SELECT prc2_CompanyID FROM PRCompanyClassification WITH (NOLOCK) GROUP BY prc2_CompanyID HAVING COUNT(1) = 1)
	   AND comp_PRListingStatus IN ('L', 'H')
	   AND prcn_CountryID IN (1,2,3)
	   AND comp_PRIndustryType <> 'L'
	   AND comp_PRHQID NOT IN (SELECT DISTINCT comp_PRHQID FROM Company WITH (NOLOCK) INNER JOIN PRDescriptiveLine ON comp_CompanyID = prdl_CompanyID AND comp_PRPublishDL='Y')
	   AND comp_PRHQID NOT IN (SELECT DISTINCT prse_HQID FROM PRService WITH (NOLOCK) WHERE prse_Primary = 'Y')
	   AND prra_CreditWorthID IS NULL
	   AND prra_IntegrityID IS NULL
	   AND prra_PayRatingID IS NULL
	   AND comp_CompanyID NOT IN (SELECT DISTINCT prra_CompanyID
									FROM PRRating
										 JOIN PRRatingNumeralAssigned ON prra_RatingID = pran_RatingID
								   WHERE prra_Current = 'Y'
									 AND pran_RatingNumeralID NOT IN (30, 31, 32, 35, 40, 45, 46))
	   AND (prc2_NumberOfStores IS NULL
			OR prc2_NumberOfStores IN ('0', '1', '2', '3', '4','5'))
) T1
  INNER JOIN Custom_Captions WITH (NOLOCK) ON comp_PRListingStatus = capt_code AND capt_Family = 'comp_PRListingStatus'
Go

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRMexicanOnlineOnly]'))
	DROP VIEW [dbo].vPRMexicanOnlineOnly
GO
CREATE VIEW [dbo].vPRMexicanOnlineOnly AS 
	SELECT comp_PRHQID, comp_CompanyID, Company.comp_Name, comp_PRType, comp_PRListingStatus
	FROM Company WITH (NOLOCK)
			INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
			INNER JOIN Custom_Captions WITH (NOLOCK) ON comp_PRListingStatus = capt_code AND capt_Family = 'comp_PRListingStatus'
			LEFT OUTER JOIN vPRCompanyRating ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
	 WHERE comp_PRListingStatus IN ('L', 'H')
	   AND prcn_CountryID = 3 
	   AND comp_PRIndustryType <> 'L'
	   AND comp_PRHQID NOT IN (SELECT DISTINCT comp_PRHQID FROM Company WITH (NOLOCK) INNER JOIN PRDescriptiveLine WITH (NOLOCK) ON comp_CompanyID = prdl_CompanyID AND comp_PRPublishDL='Y')
	   AND comp_PRHQID NOT IN (SELECT DISTINCT prse_HQID FROM PRService WITH (NOLOCK) WHERE prse_Primary = 'Y')
	   AND prra_CreditWorthID IS NULL
	   AND prra_IntegrityID IS NULL
	   AND prra_PayRatingID IS NULL
	   AND 
		 (prra_AssignedRatingNumerals IS NULL OR
				(prra_AssignedRatingNumerals NOT LIKE '%(60)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(62)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(63)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(68)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(80)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(81)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(82)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(83)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(84)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(86)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(90)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(136)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(137)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(142)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(143)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(144)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(145)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(146)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(147)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(148)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(149)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(150)%'
			   AND prra_AssignedRatingNumerals NOT LIKE '%(154)%')
			)

GO
	


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRUnratedCompanies]'))
	DROP VIEW [dbo].vPRUnratedCompanies
GO
CREATE VIEW [dbo].vPRUnratedCompanies AS 

SELECT comp_CompanyId
	FROM Company WITH (NOLOCK)
		LEFT OUTER JOIN PRRating WITH (NOLOCK) ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
		LEFT OUTER JOIN (SELECT pran_RatingId, 
					            COUNT(pran_ratingnumeralID) as RatingNumeralCount,
					            COUNT(CASE WHEN pran_ratingnumeralID IN (30, 31, 32, 35, 40, 45, 46, 49, 52, 60, 64, 79, 87, 90, 131, 132) THEN 'x' ELSE NULL END) as NonRatedNumeralCount
				            FROM PRRating WITH (NOLOCK)
					            INNER JOIN PRRatingNumeralAssigned WITH (NOLOCK) ON prra_RatingID = pran_RatingId
				            WHERE prra_Current = 'Y'
				        GROUP BY pran_RatingId) T1 ON prra_RatingID = pran_RatingID
    WHERE prra_CreditWorthID IS NULL
    AND prra_IntegrityId IS NULL
    AND prra_PayRatingId IS NULL
    AND CASE WHEN ISNULL(RatingNumeralCount, 0) = 0 THEN 'X'
				WHEN ISNULL(RatingNumeralCount, 0) > ISNULL(NonRatedNumeralCount, 0) THEN 'Z'
				ELSE 'X' END = 'X'

Go

DECLARE @Script varchar(max);
SET @Script = '
CREATE VIEW vPRAdCampaign AS 
SELECT pradch_AdCampaignHeaderID,
        pradch_HQID,
        pradch_CompanyID,
        pradch_Name,
        pradch_TypeCode,
        pradc_AdCampaignID,
        pradc_AdCampaignType,
		pradc_AdCampaignTypeDigital,
        pradc_TargetURL,
        pradc_StartDate,
        pradc_EndDate,
		pradc_CreatedDate,
		pradc_CreatedBy,
		pradc_AdFileCreatedBy,
		pradc_AdFileUpdatedBy,
		pradc_UpdatedDate,
		pradc_UpdatedBy,
        pradc_ImpressionCount,
        pradc_PeriodImpressionCount,
        pradc_AlwaysDisplay,
        pradc_IndustryType,
        pradc_Language,
		pradc_Deleted,
		pradc_CreativeStatus,
		pradc_CreativeStatusPrint,
		pradc_KYCEdition,
		pradc_KYCCommodityID,
		pradc_TopSpotCount,
		pradc_Placement,
		pradc_Cost,
		pracf_AdCampaignID,
		pracf_FileTypeCode,
		pracf_FileName,
		pradc_AdCampaignTypeDigitalAMEdition,
		pradc_AdCampaignTypeDigitalPMEdition,
		pracf_FileName_Disk
  FROM PRAdCampaignHeader WITH (NOLOCK)
      INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
	  INNER JOIN PRAdCampaignFile WITH (NOLOCK) ON pradc_AdCampaignID = pracf_AdCampaignID
WHERE pradch_TypeCode IN (''D'',''KYC'',''BP'',''TT'')
  AND pracf_FileTypeCode IN (''DI'',''PI'',''V'')'

EXEC usp_TravantCRM_CreateView 'vPRAdCampaign', @Script, null, 0, null, null, null, 'PRAdCampaign'          
Go

DECLARE @Script varchar(max);
SET @Script = '
CREATE VIEW vPRAdCampaignKYC AS 
SELECT pradch_AdCampaignHeaderID,
        pradch_HQID,
        pradch_CompanyID,
        pradch_Name,
        pradch_TypeCode,
        pradc_AdCampaignID,
        pradc_AdCampaignType,
        pradc_TargetURL,
        pradc_StartDate,
        pradc_EndDate,
				pradc_CreatedDate,
				pradc_CreatedBy,
				pradc_AdFileCreatedBy,
				pradc_AdFileUpdatedBy,
				pradc_UpdatedDate,
				pradc_UpdatedBy,
        pradc_ImpressionCount,
        pradc_PeriodImpressionCount,
        pradc_AlwaysDisplay,
        pradc_IndustryType,
        pradc_Language,
				pradc_Deleted,
				pradc_CreativeStatus,
				pradc_CreativeStatusPrint,
				pradc_KYCEdition,
				pradc_KYCCommodityID,
				pradc_TopSpotCount,
				pradc_Placement,
				pradc_Cost,

				pracf_AdCampaignID,
				pracf_FileTypeCode,
				pracf_FileName,

				prkycc_KYCCommodityID,
				prkycc_ArticleID,
				prkycc_PostName,
				prkycc_CommodityID,
				prkycc_AttributeID,
				prkycc_GrowingMethodID,
				prkycc_HasAd,
				pracf_FileName_Disk

	FROM PRAdCampaignHeader WITH (NOLOCK)
		INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
		INNER JOIN PRAdCampaignFile WITH (NOLOCK) ON pradc_AdCampaignID = pracf_AdCampaignID
		INNER JOIN PRKYCCommodity WITH (NOLOCK) ON pradc_KYCCommodityID = prkycc_KYCCommodityID
	WHERE pradch_TypeCode = ''KYC''
		AND pracf_FileTypeCode = ''DI'''

EXEC usp_TravantCRM_CreateView 'vPRAdCampaignKYC', @Script, null, 0, null, null, null, 'PRAdCampaign'
Go


DECLARE @Script varchar(max);
SET @Script = '
CREATE VIEW vPRAdCampaignKYCList AS 
	SELECT DISTINCT 
		ccedition.Capt_US [pradc_KYCEdition],
		CASE 
				WHEN pradc_CreativeStatusPrint IS NOT NULL AND pradc_CreativeStatus IS NOT NULL THEN ccprint.Capt_US + '' (print)<br>'' + ccdigital.Capt_US + '' (digital)''  
				WHEN pradc_CreativeStatusPrint IS NOT NULL AND pradc_CreativeStatus IS NULL THEN ccprint.Capt_US + '' (print)''
				WHEN pradc_CreativeStatusPrint IS NULL AND pradc_CreativeStatus IS NOT NULL THEN ccdigital.Capt_US + '' (digital)''
				ELSE ''''
		END [pradc_CreativeStatus],
		PRKYCCommodity.prkycc_PostName [pradc_PostName],
		pradc_StartDate,
		pradc_EndDate,
		pradc_KYCCommodityID,
		pradch_AdCampaignHeaderID, pradch_CompanyID, pradch_Name, pradch_TypeCode, pradc_AdCampaignID,
		pradc_Cost 
	FROM PRAdCampaignHeader WITH (NOLOCK)
		INNER JOIN PRAdCampaign WITH (NOLOCK) ON pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID
		LEFT JOIN Custom_Captions ccdigital WITH (NOLOCK) ON ccdigital.capt_Code = pradc_CreativeStatus AND ccdigital.capt_family = ''pradc_CreativeStatus''
		LEFT JOIN Custom_Captions ccprint WITH (NOLOCK) ON ccprint.capt_Code = pradc_CreativeStatusPrint AND ccprint.capt_family = ''pradc_CreativeStatus''
		LEFT JOIN Custom_Captions ccedition WITH (NOLOCK) ON ccedition.capt_Code = pradc_KYCEdition AND ccedition.capt_family = ''pradc_KYCEdition''
		LEFT JOIN PRKYCCommodity WITH (NOLOCK) ON prkycc_KYCCommodityID = pradc_KYCCommodityID
	WHERE
		pradch_TypeCode = ''KYC'''

	EXEC usp_TravantCRM_CreateView 'vPRAdCampaignKYCList', @Script, null, 0, null, null, null, 'PRAdCampaign'

Go

DECLARE @Script varchar(max);
SET @Script = '
CREATE VIEW vPRAdCampaignHeaderGrid AS 
		SELECT DISTINCT	pradch_AdCampaignHeaderID,
						pradch_CompanyID,
						pradch_CreatedDate, 
						pradch_SoldDate, 
						pradch_Name, 
						pradch_TypeCode, 
						pradch_SoldBy
		FROM PRAdCampaignHeader WITH (NOLOCK) 
		     INNER JOIN PRAdcampaign WITH (NOLOCK) ON pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID'

	EXEC usp_TravantCRM_CreateView 'vPRAdCampaignHeaderGrid', @Script, null, 0, null, null, null, 'PRAdCampaignHeader'
Go

DECLARE @Script varchar(max);
SET @Script = '
CREATE VIEW vPRBackgroundCheck AS 
	SELECT prbc_BackgroundCheckID, prbc_SubjectCompanyID, prbc_BackgroundCheckDate, prbc_CheckCreatedBy,
       comp_Name, CityStateCountryShort, Pers_PersonId, dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix, 1) AS Pers_FullName,
	   RTRIM(user_firstName) + '' '' + RTRIM(user_LastName) UserName
  FROM PRBackgroundCheck
       INNER JOIN Company ON prbc_SubjectCompanyID = comp_CompanyID
	   INNER JOIN vPRLocation ON comp_PRListingCityId = prci_CityId
	   LEFT OUTER JOIN Person ON prbc_SubjectPersonID = pers_PersonID
	   LEFT OUTER JOIN Users ON prbc_CheckCreatedBy = user_userID'
	EXEC usp_TravantCRM_CreateView 'vPRBackgroundCheck', @Script, null, 0, null, null, null, 'PRBackgroundCheck'
Go

DECLARE @Script varchar(max);
SET @Script = '
CREATE VIEW vPRBackgroundCheckResponse AS 
SELECT prbcr2_BackgroundCheckResponseID, prbcr2_BackgroundCheckID, prbcr2_ResponseCode, prbcr2_QuestionCode, prbcr2_SubjectCode, Capt_Order
  FROM PRBackgroundCheckResponse
       INNER JOIN Custom_Captions ON prbcr2_QuestionCode = capt_code AND capt_Family = ''prbcr2_QuestionCode'''

EXEC usp_TravantCRM_CreateView 'vPRBackgroundCheckResponse', @Script, null, 0, null, null, null, 'vPRBackgroundCheckResponse'
Go


--  These views needs to be registered with CRM
DECLARE @Script varchar(max);
SET @Script = 
'CREATE OR ALTER VIEW vPRChangeQueue  
AS 
SELECT prchrq_ChangeQueueID, 
       prchrq_CreatedDate,
       prchrq_CompanyID, 
	   prchrq_PersonID, 
	   prchrq_WebUserID,
       prwu_FirstName + '' '' + prwu_LastName as BBOSUserFullName,
	   prchrq_ActionCode,
	   prchrq_Notes
  FROM PRChangeQueue WITH (NOLOCK)
	   INNER JOIN PRWebUser WITH (NOLOCK) ON prchrq_WebUserID = prwu_WebUserID'
EXEC usp_TravantCRM_CreateView 'vPRChangeQueue', @Script 
Go


DECLARE @Script varchar(max);
SET @Script = 
'CREATE OR ALTER VIEW vPRChangeQueueDetail  
AS
SELECT prchrqd_ChangeQueueDetailID, prchrqd_ChangeQueueID, prchrqd_CreatedBy, prchrq_CompanyID, prchrq_PersonID, prchrqd_EntityID, prchrqd_RecordID, prchrqd_FieldID, prchrqd_FieldName, prchrqd_OldValue, prchrqd_NewValue, prchrqd_Type, Bord_TableId, Bord_Name, ColP_Entity, ColP_ColName, ColP_CustomTableIDFK, capt_us [FieldCaption], prchrqd_CreatedDate
  FROM PRChangeQueueDetail WITH (NOLOCK)
       INNER JOIN PRChangeQueue WITH (NOLOCK) ON prchrqd_ChangeQueueID = prchrq_ChangeQueueID
       INNER JOIN Custom_Tables ON prchrqd_EntityID = Bord_TableId
       INNER JOIN Custom_Edits ON prchrqd_FieldName = ColP_ColName
       INNER JOIN Custom_Captions ON colp_ColName = capt_code
 WHERE Capt_Family = ''ColNames'''
 EXEC usp_TravantCRM_CreateView 'vPRChangeQueueDetail', @Script 
 Go


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRAdSalesOrdersPending]'))
	DROP VIEW [dbo].vPRAdSalesOrdersPending
GO
CREATE VIEW [dbo].vPRAdSalesOrdersPending AS 
	SELECT pract_TermsAmount,
		pract_BillingDate,
		pract_AdCampaignTermsID,
		pract_InvoiceDescription,
		pradc_AdCampaignID,
		pradch_HQID,
		pradc_AdCampaignType,
		pradch_Name,
		pradc_BluePrintsEdition,
		cc3.capt_US AS pradc_BluePrintsEdition_Capt,
		pradc_PlannedSection,
		cc4.capt_US AS pradc_PlannedSection_Capt,
		pradc_Cost,
		pradc_Discount,
		pradc_CreativeStatus,
		pradc_CreativeStatusPrint,
		pradc_Premium,
		pradc_AdCampaignHeaderID,
		pradc_AdCampaignTypeDigital,
		cc1.capt_US AS pradc_AdCampaignTypeDigital_Capt,
		pradc_TTEdition,
		cc2.capt_US AS pradc_TTEdition_Capt,
		pradc_KYCEdition,
		cc5.capt_US AS pradc_KYCEdition_Capt,
		pradc_KYCCommodityID,
		kycc.prkycc_PostName AS pradc_KYCCommodityID_Capt,
		pradch_CompanyID,
		pradch_Typecode,
		pradch_Cost,
		pradch_Discount
	FROM PRAdCampaignTerms WITH (NOLOCK) 
		INNER JOIN PRAdCampaign WITH (NOLOCK) ON pract_AdCampaignID = pradc_AdCampaignID 
		INNER JOIN PRAdCampaignHeader ON pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID
		LEFT JOIN Custom_Captions cc1 ON cc1.capt_code = pradc_AdCampaignTypeDigital AND cc1.capt_family = 'pradc_AdCampaignTypeDigital'
		LEFT JOIN Custom_Captions cc2 ON cc2.capt_code = pradc_TTEdition AND cc2.capt_family = 'pradc_TTEdition'
		LEFT JOIN Custom_Captions cc3 ON cc3.capt_code = pradc_BluePrintsEdition AND cc3.capt_family = 'pradc_BlueprintsEdition'
		LEFT JOIN Custom_Captions cc4 ON cc4.capt_code = pradc_PlannedSection AND cc4.capt_family = 'pradc_PlannedSection'
		LEFT JOIN Custom_Captions cc5 ON cc5.capt_code = pradc_KYCEdition AND cc5.capt_family = 'pradc_KYCEdition'
		LEFT JOIN PRKYCCommodity kycc ON kycc.prkycc_KYCCommodityID = pradc_KYCCommodityID
	WHERE
		pract_TermsAmount > 0
		AND pract_BillingDate IS NOT NULL
		AND pract_BillingDate < GETDATE()
		AND ISNULL(pract_Processed,'N') = 'N'
		AND ISNULL(pradc_AdCampaignTypeDigital,'') NOT IN ('BBOSSlider','CSG')
GO

--Defect 5696
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRGetCompanyContactDataExportCSV]'))
	DROP VIEW [dbo].vPRGetCompanyContactDataExportCSV
GO
CREATE VIEW [dbo].vPRGetCompanyContactDataExportCSV AS

SELECT DISTINCT comp_CompanyId AS [BBID],      
    comp_PRCorrTradestyle AS [Company],        
    RTRIM(MailAddr.Addr_Address1) AS [MailingStreet1],     
    RTRIM(MailAddr.Addr_Address2) AS [MailingStreet2],     
    RTRIM(MailAddr.Addr_Address3) AS [MailingStreet3],     
    RTRIM(MailAddr.Addr_Address4) AS [MailingStreet4],     
    MailLocation.prci_City AS [MailingCity],      
    ISNULL(MailLocation.prst_Abbreviation, MailLocation.prst_State) AS [MailingState],     
    MailAddr.Addr_PostCode AS [MailingPostalCode],        
    MailLocation.prcn_Country AS [MailingCountry],     
    RTRIM(PhysicalAddr.Addr_Address1) AS [PhysicalStreet1],        
    RTRIM(PhysicalAddr.Addr_Address2) AS [PhysicalStreet2],        
    RTRIM(PhysicalAddr.Addr_Address3) AS [PhysicalStreet3],        
    RTRIM(PhysicalAddr.Addr_Address4) AS [PhysicalStreet4],        
    PhysicalLocation.prci_City AS [PhysicalCity],        
    ISNULL(PhysicalLocation.prst_Abbreviation, PhysicalLocation.prst_State) AS [PhysicalState],        
    PhysicalAddr.Addr_PostCode AS [PhysicalPostalCode],        
    PhysicalLocation.prcn_Country AS [PhysicalCountry],      
    dbo.ufn_FormatPhone(p.phon_CountryCode, p.phon_AreaCode, p.phon_Number, p.phon_PRExtension) As [Phone], 
    dbo.ufn_FormatPhone(f.phon_CountryCode, f.phon_AreaCode, f.phon_Number, f.phon_PRExtension) As [Fax],
    RTRIM(Eml.emai_EmailAddress) AS [Email],    
    RTRIM(WS.emai_PRWebAddress) AS [WebPage],           
    dbo.ufn_GetClassificationsForList(comp_CompanyID) AS [Classifications],
    dbo.ufn_GetCommoditiesForList(comp_CompanyID) AS [Commodities],
    smli.prsm_URL as LinkedInURL,
    smfb.prsm_URL as FacebookURL,
    smyt.prsm_URL as YouTubeURL,
    smtw.prsm_URL as TwitterURL
FROM Company WITH (NOLOCK)
    LEFT OUTER JOIN Address_Link MailAddrLink WITH (NOLOCK) ON comp_CompanyID = MailAddrLink.adli_CompanyID  AND MailAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, 'M')        
    LEFT OUTER JOIN Address MailAddr WITH (NOLOCK) ON MailAddrLink.adli_AddressID = MailAddr.addr_AddressID 
    LEFT OUTER JOIN vPRLocation MailLocation ON MailAddr.addr_PRCityID = MailLocation.prci_CityID        
    LEFT OUTER JOIN Address_Link PhysicalAddrLink WITH (NOLOCK) ON comp_CompanyID = PhysicalAddrLink.adli_CompanyID    AND PhysicalAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, 'PH')        
    LEFT OUTER JOIN Address PhysicalAddr WITH (NOLOCK) ON PhysicalAddrLink.adli_AddressID = PhysicalAddr.addr_AddressID 
    LEFT OUTER JOIN vPRLocation PhysicalLocation ON PhysicalAddr.addr_PRCityID = PhysicalLocation.prci_CityID     
    LEFT OUTER JOIN vCompanyEmail AS Eml WITH (NOLOCK) ON comp_CompanyID = Eml.ELink_RecordID AND Eml.elink_Type='E' AND Eml.emai_PRPreferredPublished='Y'      
    LEFT OUTER JOIN vCompanyEmail AS WS WITH (NOLOCK) ON comp_CompanyID = WS.ELink_RecordID  AND WS.elink_Type='W' AND WS.emai_PRPreferredPublished='Y'   
    LEFT OUTER JOIN vPRCompanyPhone AS p WITH (NOLOCK) ON comp_CompanyID = p.plink_RecordID AND p.Phon_PRPreferredPublished = 'Y' AND p.phon_PRIsPhone = 'Y'      
    LEFT OUTER JOIN vPRCompanyPhone AS f WITH (NOLOCK) ON comp_CompanyID = f.plink_RecordID  AND f.Phon_PRPreferredPublished = 'Y' AND f.Phon_PRIsFax = 'Y'
    LEFT OUTER JOIN PRSocialMedia smli WITH (NOLOCK) ON comp_CompanyID = smli.prsm_CompanyID AND smli.prsm_SocialMediaTypeCode = 'linkedin'
    LEFT OUTER JOIN PRSocialMedia smfb WITH (NOLOCK) ON comp_CompanyID = smfb.prsm_CompanyID AND smfb.prsm_SocialMediaTypeCode = 'facebook'
    LEFT OUTER JOIN PRSocialMedia smyt WITH (NOLOCK) ON comp_CompanyID = smyt.prsm_CompanyID AND smyt.prsm_SocialMediaTypeCode = 'youtube'
    LEFT OUTER JOIN PRSocialMedia smtw WITH (NOLOCK) ON comp_CompanyID = smtw.prsm_CompanyID AND smtw.prsm_SocialMediaTypeCode = 'twitter'
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRGetCompanyDataExportReportCSV]'))
	DROP VIEW [dbo].vPRGetCompanyDataExportReportCSV
GO

CREATE VIEW [dbo].vPRGetCompanyDataExportReportCSV AS
SELECT distinct
    comp_CompanyId AS [BBID],
    RTRIM(comp_PRCorrTradestyle) AS [CompanyName],
    RTRIM(MailAddr.Addr_Address1) AS [MailingAddressLine1],
    RTRIM(MailAddr.Addr_Address2) AS [MailingAddressLine2],
    RTRIM(MailAddr.Addr_Address3) AS [MailingAddressLine3],
    RTRIM(MailAddr.Addr_Address4) AS [MailingAddressLine4],
    RTRIM(MailAddr.Addr_Address5) AS [MailingAddressLine5],
    RTRIM(MailLocation.prci_City) AS [MailingCity],
    RTRIM(COALESCE(MailLocation.prst_Abbreviation, MailLocation.prst_State)) AS [MailingState],
    RTRIM(MailAddr.Addr_PostCode) AS [MailingPostalCode],
    RTRIM(MailLocation.prcn_Country) AS [MailingCountry],
    RTRIM(PhysicalAddr.Addr_Address1) AS [PhysicalAddressLine1],
    RTRIM(PhysicalAddr.Addr_Address2) AS [PhysicalAddressLine2],
    RTRIM(PhysicalAddr.Addr_Address3) AS [PhysicalAddressLine3],
    RTRIM(PhysicalAddr.Addr_Address4) AS [PhysicalAddressLine4],
    RTRIM(PhysicalAddr.Addr_Address5) AS [PhysicalAddressLine5],
    RTRIM(PhysicalLocation.prci_City) AS [PhysicalCity],
    RTRIM(COALESCE(PhysicalLocation.prst_Abbreviation, PhysicalLocation.prst_State)) AS [PhysicalState],
    RTRIM(PhysicalAddr.Addr_PostCode) AS [PhysicalPostalCode],
    RTRIM(PhysicalLocation.prcn_Country) AS [PhysicalCountry],
    dbo.ufn_FormatPhone(phne.phon_CountryCode, phne.phon_AreaCode, phne.phon_Number, null) As [PhoneNumber],
    dbo.ufn_FormatPhone(Fax.phon_CountryCode, Fax.phon_AreaCode, Fax.phon_Number, null) As [FaxNumber],
    RTRIM(Eml.emai_EmailAddress) AS [EmailAddress],
    dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, pers_PRNickname1, pers_Suffix) As [ExecutiveContactName],
    RTRIM(peli_PRTitle) AS [ExecutiveContactTitle],
    RTRIM(WS.emai_PRWebAddress) AS [WebSiteURL],
    dbo.ufn_GetClassificationsForList(comp_CompanyID) AS [Classifications],
    dbo.ufn_GetCommoditiesForList(comp_CompanyID) AS [Commodities],
    --dbo.ufn_GetCustomCaptionValue('prcp_Volume', prcp_Volume, @Culture) AS [AnnualVolumeFigure],
    --dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, @Culture) AS [Industry],
    RTRIM(ListingInfo.prci_City) AS [ListingCity],
    RTRIM(ListingInfo.prst_State) AS [ListingState],
    RTRIM(ListingInfo.prcn_Country) AS [ListingCountry],
    RTRIM(prcw_Name) AS [CreditWorthRating],
    RTRIM(prin_Name) AS [TradePractices],
    RTRIM(prpy_Name) AS [PayRating],
    RTRIM(prra_AssignedRatingNumerals) AS [RatingNumerals],
	Round(dbo.ufn_GetCurrentBBScore(comp_CompanyID),0) AS [BBScore],

    dbo.ufn_FormatPhone(TFP.phon_CountryCode, TFP.phon_AreaCode, TFP.phon_Number, null) AS [TollFreePhoneNumber],
    RTRIM(prpa_LicenseNumber) AS [PACALicense],
    RTRIM(prdr_LicenseNumber) AS [DRCLicense],

	RTRIM(licCFIA.prli_Number) AS [CFIALicense],
	RTRIM(licDOT.prli_Number) AS [DOTLicense],
	RTRIM(licFF.prli_Number) AS [FFLicense],
	RTRIM(licMC.prli_Number) AS [MCLicense],

    --dbo.ufn_GetCustomCaptionValue('comp_PRType', comp_PRType, @Culture) AS [Type],
    comp_PRHQID AS [HQBBID],
    dbo.ufn_GetBrandsList(comp_CompanyID) AS [Brands],
    --dbo.ufn_GetCustomCaptionValue('prc2_StoreCount', prc2_NumberOfStores, @Culture) AS [NumberOfStores],

	smli.prsm_URL as LinkedInURL,
	smfb.prsm_URL as FacebookURL,
	smyt.prsm_URL as YouTubeURL,
	smtw.prsm_URL as TwitterURL,

	prcp_Volume prcp_Volume,
	comp_PRIndustryType comp_PRIndustryType,
	comp_PRType comp_PRType,
	prc2_NumberOfStores prc2_NumberOfStores,
	dbo.ufn_GetCertificationsForList(comp_CompanyID) AS [Certifications]
FROM Company WITH (NOLOCK)
    LEFT OUTER JOIN Address_Link MailAddrLink WITH (NOLOCK) ON comp_CompanyID = MailAddrLink.adli_CompanyID AND MailAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, 'M')
    LEFT OUTER JOIN Address MailAddr WITH (NOLOCK) ON MailAddrLink.adli_AddressID = MailAddr.addr_AddressID
    LEFT OUTER JOIN vPRLocation MailLocation WITH (NOLOCK) ON MailAddr.addr_PRCityID = MailLocation.prci_CityID
    LEFT OUTER JOIN Address_Link PhysicalAddrLink WITH (NOLOCK) ON comp_CompanyID = PhysicalAddrLink.adli_CompanyID      AND PhysicalAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, 'PH')
    LEFT OUTER JOIN Address PhysicalAddr WITH (NOLOCK) ON PhysicalAddrLink.adli_AddressID = PhysicalAddr.addr_AddressID
    LEFT OUTER JOIN vPRLocation PhysicalLocation ON PhysicalAddr.addr_PRCityID = PhysicalLocation.prci_CityID
    LEFT OUTER JOIN vPRLocation ListingInfo ON comp_PRListingCityID = ListingInfo.prci_CityID
    LEFT OUTER JOIN vPRCompanyPhone AS Phne WITH (NOLOCK) ON comp_CompanyID = Phne.plink_RecordID AND Phne.Phon_PRPreferredPublished = 'Y' AND Phne.plink_Type IN ('P','PF','S','TP')      
    LEFT OUTER JOIN vPRCompanyPhone AS Fax WITH (NOLOCK) ON comp_CompanyID = Fax.plink_RecordID  AND Fax.Phon_PRPreferredPublished = 'Y' AND Fax.Phon_PRIsFax = 'Y'
	LEFT OUTER JOIN vPRCompanyPhone AS TFP WITH (NOLOCK) ON comp_CompanyID = TFP.plink_RecordID  AND TFP.Phon_PRPublish = 'Y' AND TFP.plink_Type = 'TF'
    LEFT OUTER JOIN vCompanyEmail AS Eml WITH (NOLOCK) ON comp_CompanyID = Eml.ELink_RecordID AND Eml.elink_Type='E' AND Eml.emai_PRPreferredPublished='Y'      
    LEFT OUTER JOIN vCompanyEmail AS WS WITH (NOLOCK) ON comp_CompanyID = WS.ELink_RecordID  AND WS.elink_Type='W' AND WS.emai_PRPreferredPublished='Y'   
    LEFT OUTER JOIN Person_Link WITH (NOLOCK) on comp_CompanyID = peli_CompanyID AND peli_PRRole LIKE '%,HE,%' AND peli_PRStatus = '1' 	and peli_PREBBPublish = 'Y'
    LEFT OUTER JOIN Person WITH (NOLOCK) ON peli_PersonID = pers_PersonID
    LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyID = prcp_CompanyID
    LEFT OUTER JOIN vPRCompanyRating WITH (NOLOCK) ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
    LEFT OUTER JOIN PRPACALicense WITH (NOLOCK) ON comp_CompanyID = prpa_CompanyID AND prpa_Current = 'Y' AND prpa_Publish = 'Y'
    LEFT OUTER JOIN PRDRCLicense WITH (NOLOCK) ON comp_CompanyID = prdr_CompanyID AND prdr_Publish = 'Y'
	
	LEFT OUTER JOIN PRCompanyLicense licCFIA WITH(NOLOCK) ON licCFIA.prli_Type='CFIA' AND comp_CompanyID = licCFIA.prli_CompanyId AND licCFIA.prli_Publish = 'Y'
	LEFT OUTER JOIN PRCompanyLicense licDOT WITH(NOLOCK) ON licDOT.prli_Type='DOT' AND comp_CompanyID = licDOT.prli_CompanyId AND licDOT.prli_Publish = 'Y'
	LEFT OUTER JOIN PRCompanyLicense licFF WITH(NOLOCK) ON licFF.prli_Type='FF' AND comp_CompanyID = licFF.prli_CompanyId AND licFF.prli_Publish = 'Y'
	LEFT OUTER JOIN PRCompanyLicense licMC WITH(NOLOCK) ON licMC.prli_Type='MC' AND comp_CompanyID = licMC.prli_CompanyId AND licMC.prli_Publish = 'Y'

    LEFT OUTER JOIN PRCompanyClassification WITH (NOLOCK) ON comp_CompanyID = prc2_CompanyID AND prc2_ClassificationID = 330
	LEFT OUTER JOIN PRSocialMedia smli WITH (NOLOCK) ON comp_CompanyID = smli.prsm_CompanyID AND smli.prsm_SocialMediaTypeCode = 'linkedin'
	LEFT OUTER JOIN PRSocialMedia smfb WITH (NOLOCK) ON comp_CompanyID = smfb.prsm_CompanyID AND smfb.prsm_SocialMediaTypeCode = 'facebook'
	LEFT OUTER JOIN PRSocialMedia smyt WITH (NOLOCK) ON comp_CompanyID = smyt.prsm_CompanyID AND smyt.prsm_SocialMediaTypeCode = 'youtube'
	LEFT OUTER JOIN PRSocialMedia smtw WITH (NOLOCK) ON comp_CompanyID = smtw.prsm_CompanyID AND smtw.prsm_SocialMediaTypeCode = 'twitter'
GO


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vPRGetCompanyDataExportReportLumberCSV]'))
	DROP VIEW [dbo].vPRGetCompanyDataExportReportLumberCSV
GO

CREATE VIEW [dbo].vPRGetCompanyDataExportReportLumberCSV AS
SELECT DISTINCT
    comp_CompanyId AS [BBID],
    RTRIM(comp_PRCorrTradestyle) AS [CompanyName],

    RTRIM(MailAddr.Addr_Address1) AS [MailingAddressLine1],
    RTRIM(MailAddr.Addr_Address2) AS [MailingAddressLine2],
    RTRIM(MailAddr.Addr_Address3) AS [MailingAddressLine3],
    RTRIM(MailAddr.Addr_Address4) AS [MailingAddressLine4],
    RTRIM(MailAddr.Addr_Address5) AS [MailingAddressLine5],
    RTRIM(MailLocation.prci_City) AS [MailingCity],
    RTRIM(COALESCE(MailLocation.prst_Abbreviation, MailLocation.prst_State)) AS [MailingState],
    RTRIM(MailAddr.Addr_PostCode) AS [MailingPostalCode],
    RTRIM(MailLocation.prcn_Country) AS [MailingCountry],

    RTRIM(PhysicalAddr.Addr_Address1) AS [PhysicalAddressLine1],
    RTRIM(PhysicalAddr.Addr_Address2) AS [PhysicalAddressLine2],
    RTRIM(PhysicalAddr.Addr_Address3) AS [PhysicalAddressLine3],
    RTRIM(PhysicalAddr.Addr_Address4) AS [PhysicalAddressLine4],
    RTRIM(PhysicalAddr.Addr_Address5) AS [PhysicalAddressLine5],
    RTRIM(PhysicalLocation.prci_City) AS [PhysicalCity],
    RTRIM(COALESCE(PhysicalLocation.prst_Abbreviation, PhysicalLocation.prst_State)) AS [PhysicalState],
    RTRIM(PhysicalAddr.Addr_PostCode) AS [PhysicalPostalCode],
    RTRIM(PhysicalLocation.prcn_Country) AS [PhysicalCountry],

    dbo.ufn_FormatPhone(phne.phon_CountryCode, phne.phon_AreaCode, phne.phon_Number, null) As [PhoneNumber],
    dbo.ufn_FormatPhone(Fax.phon_CountryCode, Fax.phon_AreaCode, Fax.phon_Number, null) As [FaxNumber],
    RTRIM(Eml.emai_EmailAddress) AS [EmailAddress],
    RTRIM(WS.emai_PRWebAddress) AS [WebSiteURL],
    dbo.ufn_GetClassificationsForList(comp_CompanyID) AS [Classifications],
    dbo.ufn_GetProductsProvidedForList(comp_CompanyID) AS [Products],
    dbo.ufn_GetServicesProvidedForList(comp_CompanyID) AS [Services],
    dbo.ufn_GetSpeciesForList(comp_CompanyID) AS [Species],
	CAST(ccl.capt_US as varchar(max)) as [Volume],
    --dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, @Culture) AS [Industry],

    RTRIM(ListingInfo.prci_City) AS [ListingCity],
    RTRIM(ListingInfo.prst_State) AS [ListingState],
    RTRIM(ListingInfo.prcn_Country) AS [ListingCountry],

    RTRIM(prcw_Name) AS [CreditWorthRating],

    RTRIM(prra_AssignedRatingNumerals) AS [RatingNumerals],
	prbs_BBScore BBScore,

    prcpi_PayIndicator As PayIndicator,

    dbo.ufn_FormatPhone(TFP.phon_CountryCode, TFP.phon_AreaCode, TFP.phon_Number, null) AS [TollFreePhoneNumber],
    --dbo.ufn_GetCustomCaptionValue('comp_PRType', comp_PRType, @Culture) AS [Type],
    comp_PRHQID AS [HQBBID],
	smli.prsm_URL as LinkedInURL,
	smfb.prsm_URL as FacebookURL,
	smyt.prsm_URL as YouTubeURL,
	smtw.prsm_URL as TwitterURL,
	
	
	comp_PRIndustryType comp_PRIndustryType,
	comp_PRType comp_PRType
FROM Company WITH (NOLOCK)
    LEFT OUTER JOIN Address_Link MailAddrLink WITH (NOLOCK) ON comp_CompanyID = MailAddrLink.adli_CompanyID  AND MailAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, 'M')
    LEFT OUTER JOIN Address MailAddr WITH (NOLOCK) ON MailAddrLink.adli_AddressID = MailAddr.addr_AddressID
    LEFT OUTER JOIN vPRLocation MailLocation ON MailAddr.addr_PRCityID = MailLocation.prci_CityID

    LEFT OUTER JOIN Address_Link PhysicalAddrLink WITH (NOLOCK) ON comp_CompanyID = PhysicalAddrLink.adli_CompanyID  AND PhysicalAddrLink.adli_AddressID = dbo.ufn_GetAddressIDForList(comp_CompanyID, 'PH')
    LEFT OUTER JOIN Address PhysicalAddr WITH (NOLOCK) ON PhysicalAddrLink.adli_AddressID = PhysicalAddr.addr_AddressID
    LEFT OUTER JOIN vPRLocation PhysicalLocation ON PhysicalAddr.addr_PRCityID = PhysicalLocation.prci_CityID
    LEFT OUTER JOIN vPRLocation ListingInfo ON comp_PRListingCityID = ListingInfo.prci_CityID

    LEFT OUTER JOIN vPRCompanyPhone AS Phne WITH (NOLOCK) ON comp_CompanyID = Phne.plink_RecordID AND Phne.Phon_PRPreferredPublished = 'Y' AND Phne.plink_Type IN ('P','PF','S','TP')      
    LEFT OUTER JOIN vPRCompanyPhone AS Fax WITH (NOLOCK) ON comp_CompanyID = Fax.plink_RecordID  AND Fax.Phon_PRPreferredPublished = 'Y' AND Fax.Phon_PRIsFax = 'Y'
	LEFT OUTER JOIN vPRCompanyPhone AS TFP WITH (NOLOCK) ON comp_CompanyID = TFP.plink_RecordID  AND TFP.Phon_PRPublish = 'Y' AND TFP.plink_Type = 'TF'
    LEFT OUTER JOIN vCompanyEmail AS Eml WITH (NOLOCK) ON comp_CompanyID = Eml.ELink_RecordID AND Eml.elink_Type='E' AND Eml.emai_PRPreferredPublished='Y'      
    LEFT OUTER JOIN vCompanyEmail AS WS WITH (NOLOCK) ON comp_CompanyID = WS.ELink_RecordID  AND WS.elink_Type='W' AND WS.emai_PRPreferredPublished='Y'   

    LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyID = prcp_CompanyID
	LEFT OUTER JOIN Custom_Captions ccl WITH (NOLOCK) ON prcp_Volume = ccl.capt_code AND ccl.capt_family = 'prcp_VolumeL'
    LEFT OUTER JOIN vPRCompanyRating WITH (NOLOCK) ON comp_CompanyID = prra_CompanyID AND prra_Current = 'Y'
    LEFT OUTER JOIN PRCompanyPayIndicator WITH (NOLOCK) ON comp_CompanyID = prcpi_CompanyID AND prcpi_Current = 'Y' AND comp_PRPublishPayIndicator = 'Y'

	LEFT OUTER JOIN PRSocialMedia smli WITH (NOLOCK) ON comp_CompanyID = smli.prsm_CompanyID AND smli.prsm_SocialMediaTypeCode = 'linkedin'
	LEFT OUTER JOIN PRSocialMedia smfb WITH (NOLOCK) ON comp_CompanyID = smfb.prsm_CompanyID AND smfb.prsm_SocialMediaTypeCode = 'facebook'
	LEFT OUTER JOIN PRSocialMedia smyt WITH (NOLOCK) ON comp_CompanyID = smyt.prsm_CompanyID AND smyt.prsm_SocialMediaTypeCode = 'youtube'
	LEFT OUTER JOIN PRSocialMedia smtw WITH (NOLOCK) ON comp_CompanyID = smtw.prsm_CompanyID AND smtw.prsm_SocialMediaTypeCode = 'twitter'
	LEFT OUTER JOIN PRBBScore WITH (NOLOCK) ON comp_CompanyID = prbs_CompanyID AND prbs_Current='Y' 
GO


CREATE OR ALTER VIEW [dbo].vPRModelOpARAging AS
	SELECT praad_ARAGingDetailID as KeyField, 
	       praa_CreatedDate,
		   praa_CompanyID as ProvBBID,
		   Convert(nvarchar(30),praa_Date, 101) as AgingDate,
		   praad_Amount0to29 as AMT_0_29,
		   praad_Amount30to44 as AMT_30_44,
		   praad_Amount45to60 as AMT_45_60,
		   praad_Amount61Plus as AMT_61_PLUS,
		   praad_SubjectCompanyID as CUSTBBID,
		   praad_CreditTerms as Credit_Terms,
		   praad_TimeAged as AVG_DAYS_OUTSTANDING
	  FROM CRM.dbo.PRARAging WITH (NOLOCK)
		   INNER JOIN CRM.dbo.PRARAgingDetail WITH (NOLOCK) on praad_ARAgingID = praa_ARAgingID
		   INNER JOIN CRM.dbo.Company s with (nolock) ON praad_SubjectCompanyID = s.comp_CompanyID
	 WHERE praad_SubjectCompanyID is not null
	   AND s.comp_PRLocalSource IS NULL
	   AND s.comp_PRIndustryType IN ('P', 'T')
	UNION
	SELECT praad_ARAGingDetailID as KeyField, 
	       praa_CreatedDate,
		   praa_CompanyID as ProvBBID,
		   Convert(nvarchar(30),praa_Date, 101) as AgingDate,
		   praad_Amount0to29 as AMT_0_29,
		   praad_Amount30to44 as AMT_30_44,
		   praad_Amount45to60 as AMT_45_60,
		   praad_Amount61Plus as AMT_61_PLUS,
		   praad_SubjectCompanyID as CUSTBBID,
		   praad_CreditTerms as Credit_Terms,
		   praad_TimeAged as AVG_DAYS_OUTSTANDING
	  FROM CRMArchive.dbo.PRARAging WITH (NOLOCK)
		   INNER JOIN CRMArchive.dbo.PRARAgingDetail WITH (NOLOCK) on praad_ARAgingID = praa_ARAgingID
		   INNER JOIN CRM.dbo.Company s with (nolock) ON praad_SubjectCompanyID = s.comp_CompanyID
	 WHERE praad_SubjectCompanyID is not null
	   AND s.comp_PRLocalSource IS NULL
	   AND s.comp_PRIndustryType IN ('P', 'T')
GO




--EXEC sp_refreshview 'vPersonEmail' 
EXEC sp_refreshview 'vNotificationQuotes' 
--EXEC sp_refreshview 'vCompany' 
EXEC usp_RefreshAllViews
Go

-- ********************* END CUSTOM VIEW CREATION *****************************