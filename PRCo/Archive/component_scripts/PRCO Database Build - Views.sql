-- ********************* CREATE CUSTOM VIEWS **********************************
-- we need to refresh the accpac views for the new fields that have been added
exec usp_RefreshAllViews
go


DECLARE @Script varchar(8000);

-- Add the vPRCompanyRating view so this gets removed with component uninstalls
SET @Script = 
'CREATE VIEW dbo.vPRCompanyRating AS ' +
'SELECT *, prra_RatingLine = COALESCE(prcw_Name+'' '','''')+COALESCE(prin_Name,'''')+ COALESCE(prra_AssignedRatingNumerals,'''')+COALESCE('' ''+prpy_Name,'''') '+
'FROM ( ' +
'SELECT comp_Name, prcw_Name, prin_Name, prin_Weight, prpy_Name, prpy_Weight, ' +
'prra.*, ' + 
'prra_AssignedRatingNumerals = dbo.ufn_GetAssignedRatingNumeralList(prra_RatingId, 0) '+
'FROM PRRating prra ' +
'JOIN company ON prra_CompanyId = comp_CompanyId AND comp_Deleted is null ' +
'LEFT OUTER JOIN PRCreditWorthRating ON prra_CreditWorthId = prcw_CreditWorthRatingId ' +
'LEFT OUTER JOIN PRIntegrityRating ON prra_IntegrityId = prin_IntegrityRatingId ' +
'LEFT OUTER JOIN PRPayRating ON prra_PayRatingId = prpy_PayRatingId ' +
'WHERE prra_Deleted is null ) ATABLE'
exec usp_AccpacCreateView 'PRView', 'PRRating', 'vPRCompanyRating', @Script 

-- vPRCompany view performs all the denormalization on Company
SET @Script = 
'CREATE VIEW dbo.vPRCompany ' + 
'AS '+
'SELECT  '+
'company.*, prra_RatingLine, '+
'prci_City, prst_State,'+
'prbs_BBScore, capt_ListingStatusDesc = capt_US '+
'FROM Company   '+
'LEFT OUTER JOIN vPRCompanyRating ON comp_CompanyId = prra_CompanyId And prra_Current = ''Y'' '+
'LEFT OUTER JOIN PRBBScore ON comp_CompanyId = prbs_CompanyId And prbs_Current = ''Y'' '+
'LEFT OUTER JOIN PRCity ON comp_PRListingCityID = prci_CityId '+
'LEFT OUTER JOIN PRState ON prci_StateId = prst_StateId ' +
'JOIN custom_captions ON comp_PRListingStatus = capt_code and capt_family = ''comp_PRListingStatus'' '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRCompany', @Script 


-- Add the vPRLocation view so this gets removed with component uninstalls
--
-- NOTE:  The original view referenced foriegn keys instead of primary keys
--        (i.e. prci_StateID instead of prst_StateID).  This causes problems
--        so the primary keys were added as well.  We should remove the
--        foriegn keys at some point (I'm too busy at the moment). 
--        - CHW  10/25/06
--   - 11/10/2006- RAO Completely "remastered" for using the indedxed view
SET @Script = 
'CREATE VIEW dbo.vPRLocation WITH SCHEMABINDING ' + 
'AS ' +
'SELECT prci_CityId, prci_StateId, prci_City, prci_Deleted, prci_RatingTerritory, ' +
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
'end as CityStateCountryShort ' + 
'from dbo.PRCity ' +
'INNER JOIN dbo.PRState ON prst_StateId = prci_StateId ' +
'INNER JOIN dbo.PRCountry ON prcn_CountryId = prst_CountryId '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRLocation', @Script, null, 0, 'prci_CityId', 'CityStateCountry' 

SET @Script = 
'CREATE VIEW vPRCompanyLocation WITH SCHEMABINDING AS  ' +
'Select ' +
	'Comp_CompanyId, Comp_Name, Comp_PRType, comp_PRListingStatus, ' + 
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
	'end as CityStateCountryShort ' + 
'from dbo.Company ' +
'INNER JOIN dbo.PRCity ON prci_CityId = comp_PRListingCityId ' +
'INNER JOIN dbo.PRState ON prst_StateId = prci_StateId ' +
'INNER JOIN dbo.PRCountry ON prcn_CountryId = prst_CountryId'
exec usp_AccpacCreateView 'PRView', NULL, 'vPRCompanyLocation', @Script 

-- ***** PRPerson
-- ------> UPDATE VIEWS
--vListPerson
SET @Script = 
'CREATE VIEW dbo.vPRListPerson AS '+
'SELECT '+
'dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix)  AS Pers_FullName,  '+
'Coalesce(RTRIM(pers_PhoneCountryCode) + '' '', '''') + Coalesce(RTRIM(pers_PhoneAreaCode)+ '' '', '''') + '+
'ISNULL(RTRIM(Pers_PhoneNumber), '''') AS Pers_PhoneFullNumber, '+
'Pers_CompanyId = peli_CompanyId, '+
'Pers_PersonId,Pers_CreatedDate,Pers_UpdatedBy,Pers_UpdatedDate,Pers_TimeStamp,Pers_Deleted, ' +
'Pers_LibraryDir,Pers_SegmentID,Pers_ChannelID,Pers_UploadDate,pers_SecTerr,Pers_WorkflowId,pers_PRYearBorn, '+
'pers_PRDeathDate,pers_PRLanguageSpoken,pers_PRPaternalLastName,pers_PRMaternalLastName,pers_PRNickname1, '+
'pers_PRNickname2,pers_PRMaidenName,pers_PRIndustryStartDate,pers_PRNotes, '+
'peli_PRAUSReceiveMethod,peli_PRAUSChangePreference,Pers_PrimaryAddressId, ' +
'Pers_PrimaryUserId,Pers_Salutation,Pers_FirstName,Pers_LastName,Pers_MiddleName,Pers_Suffix,Pers_Gender, '+
'Pers_Title,Pers_TitleCode,Pers_Department,Pers_Status,Pers_Source,Pers_Territory,Pers_WebSite,Pers_MailRestriction, '+
'Pers_PhoneCountryCode,Pers_PhoneAreaCode,Pers_PhoneNumber,Pers_EmailAddress,Pers_FaxCountryCode,Pers_FaxAreaCode, '+
'Pers_FaxNumber,Pers_CreatedBy,'+
'peli_PersonLinkId, peli_PRTitleCode, peli_PRStartDate, peli_PREndDate, peli_PRStatus, peli_PRRole, '+
'peli_Companyid, '+
'peli_personid, '+
'peli_WebStatus, ' +
'peli_PRBRPublish, ' +
'peli_PREBBPublish, ' +
'comp_CompanyId, '+
'comp_name '+
'FROM dbo.Person '+
'Left OUTER JOIN dbo.Person_Link ON Pers_PersonId = PeLi_PersonId '+
'LEFT OUTER JOIN dbo.Company ON peli_CompanyId = dbo.Company.Comp_CompanyId '+
'WHERE  (Pers_Deleted IS NULL) AND (PeLi_Deleted IS NULL) '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRListPerson', @Script 


/*  ** This view overrides a native accpac view 
    This view is used specifically for the searching and result set of companies.
    The returned rows are specific to what needs to be filtered and displayed;
*/
SET @Script = 
'CREATE VIEW dbo.vSearchListCompany AS SELECT ' +
'comp_companyid, comp_PRHQId, comp_CompanyIdDisplay = cast(comp_companyid as varchar(10)), comp_name, comp_PRIndustryType, '+ 
'comp_PRServicesThroughCompanyId, comp_prtype, comp_PRListingStatus, prci_CityId, prst_StateId, prcn_CountryId, comp_PRListingCityId, '+
'comp_ListingCityStateCountry = CityStateCountry, '+ 
'comp_StatusDisplay = case '+ 
'    when comp_PRListingStatus = ''L'' then ''Y'' '+
'    else '''' '+
'end, '+
'comp_TypeDisplay = comp_PRtype '+ 
'from Company '+
'     INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID '+
'WHERE comp_Deleted IS null '
exec usp_AccpacCreateView 'PRView', NULL, 'vSearchListCompany', @Script, null, 0

/*  ** This view overrides a native accpac view 
    This change may affect core accpac functionality but is required for linking multiple companies
    to a person. This does not return all the fields returned by the original view
*/
SET @Script = 
'CREATE VIEW dbo.vSearchListPerson AS SELECT ' +
'dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix, 1)  AS Pers_FullName,  '+
'dbo.ufn_GetPersonDefaultPhone(pers_PersonID) AS Pers_PhoneFullNumber, ' +
'dbo.ufn_GetPersonDefaultFax(pers_PersonID) AS Pers_FaxFullNumber, ' +
'comp_Name, comp_companyid, peli_CompanyId AS pers_companyid, '+
'Pers_PersonId,Pers_PrimaryAddressId,Pers_PrimaryUserId,Pers_Salutation,Pers_FirstName,'+
'Pers_LastName,Pers_MiddleName,Pers_Suffix,Pers_Gender,Pers_Title,Pers_TitleCode,Pers_Department,Pers_Status,'+
'Pers_Source,Pers_Territory,Pers_WebSite,Pers_MailRestriction,Pers_PhoneCountryCode,Pers_PhoneAreaCode,'+
'Pers_PhoneNumber, ' + 
'dbo.ufn_GetPersonDefaultEmail(pers_PersonID) AS  Pers_EmailAddress, ' + 
'pers_FaxCountryCode,Pers_FaxAreaCode,Pers_FaxNumber,Pers_CreatedBy,'+
'Pers_CreatedDate,Pers_UpdatedBy,Pers_UpdatedDate,Pers_TimeStamp,Pers_Deleted,Pers_LibraryDir,Pers_SegmentID,'+
'Pers_ChannelID,Pers_UploadDate,pers_SecTerr,Pers_WorkflowId,pers_PRYearBorn,pers_PRDeathDate,'+
'pers_PRLanguageSpoken,pers_PRPaternalLastName,pers_PRMaternalLastName,pers_PRNickname1,pers_PRNickname2,'+
'pers_PRMaidenName,pers_PRIndustryStartDate,pers_PRNotes,'+
'peli_PRAUSReceiveMethod,peli_PRAUSChangePreference '+
'FROM Person '+
'LEFT OUTER JOIN person_link ON Peli_PersonId = Pers_PersonId '+
'LEFT OUTER JOIN company ON Peli_CompanyId = comp_CompanyId '+
'WHERE Pers_Deleted IS NULL '
exec usp_AccpacCreateView 'PRView', NULL, 'vSearchListPerson', @Script 

SET @Script = 
'CREATE VIEW dbo.vPRPersonDefaultInfo AS ' +
'select  pers_personid, Addr_Address1, CityStateZip = RTRIM(addr_City) + RTRIM(Coalesce('', '' + addr_State,'''')) + RTRIM(Coalesce('' ''+addr_PostCode, '''')), '+
'emai_emailaddress, phone = dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) '+
'from Person '+
'left outer join Address_Link adli on pers_PersonId = adli_PersonId and adli_PRDefaultMailing = ''Y'' '+
'left outer join Address addr on adli_AddressId = Addr_AddressId '+
'left outer join Email on pers_PersonId = emai_PersonId and emai_Type = ''E'' and emai_PRDefault = ''Y'' '+
'left outer join Phone on pers_PersonId = phon_PersonId and phon_Type != ''F'' and phon_Default = ''Y'' '
exec usp_AccpacCreateView 'PRView', 'PRGeneral', 'vPRPersonDefaultInfo ', @Script 

-- Create a view exclusively for the Company branches in the accpac listing
SET @Script = 
'CREATE VIEW dbo.vPRCompanyBranchForListing ' + 
'AS '+
'SELECT * FROM vSearchListCompany '+
'WHERE comp_PRType = ''B'' ';
exec usp_AccpacCreateView 'PRView', NULL, 'vPRCompanyBranchForListing', @Script 

-- Create a view to retrieve the required information to search for and list Credit Sheet information
-- on any of the listing pages
SET @Script = 
'CREATE VIEW dbo.vPRCreditSheet ' + 
'AS '+
'SELECT prcs.*, '+
'comp_Name, comp_CompanyId, comp_PRType, comp_PRListingStatus, '+
'prci_City, prst_State, prci_ListingSpecialistId '+
'FROM PRCreditSheet prcs '+
'INNER JOIN vPRCompanyLocation ON comp_CompanyId = prcs_CompanyId '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRCreditSheet', @Script 

-- ***** PRGeneral Views
-- Add the vPRPhone view 
SET @Script = 
'CREATE VIEW dbo.vPRPhone ' + 
'AS '+
'SELECT '+
'    COALESCE(rtrim(phon_countrycode)+ '' '','''') +       '+
'    COALESCE(''(''+rtrim(phon_areacode)+ '') '','''') +   '+
'    COALESCE(rtrim(phon_number),'''') as phon_FullNumber, '+
'    Phone.*,  '+
'    Coalesce(Custom_captions.Capt_US, '''') as phon_TypeDisplay '+
'    FROM Phone  '+
'    LEFT OUTER JOIN Company ON Phon_CompanyId = comp_CompanyId  '+
'    LEFT OUTER JOIN Person ON Phon_PersonId = pers_PersonId  '+
'    LEFT OUTER JOIN Custom_Captions ON Phon_Type = Capt_Code  '+
'      AND Capt_Family in ( '+
'        CASE '+
'          WHEN phon_CompanyId is not null THEN ''Phon_TypeCompany'' '+
'          WHEN phon_PersonId is not null THEN ''Phon_TypePerson'' '+
'          ELSE ''Phon_TypeCompany'' + '','' +  ''Phon_TypePerson'' '+
'        END '+
'      ) '+
'    WHERE Phon_Deleted IS NULL '+      
'    --Order By phon_Sequence '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRPhone', @Script 

SET @Script = 
'CREATE VIEW dbo.vPRAddress AS '+
'SELECT  ISNULL(RTrim(Addr_Address1)+''<BR>'', '''') + ISNULL(RTrim(Addr_Address2)+''<BR>'', '''') + ISNULL(RTrim(Addr_Address3)+''<BR>'', '''') + ISNULL(RTrim(Addr_Address4)+''<BR>'', '''')  + ISNULL(RTrim(Addr_Address5), '''') AS Addr_Street,'+
' address.*,prci_City,prci_CityId,prst_State,prst_StateId,prcn_CountryId,prcn_Country, ' +
' adli_AddressLinkId, adli_CompanyId, adli_PersonId, adli_Type, ' + 
' adli_PRDefaultMailing, adli_PRDefaultShipping, adli_PRDefaultListing, adli_PRDefaultBilling, ' +
' adli_PRDefaultTax, adli_PRDefaultTES, adli_PRDefaultJeopardy,' + 
' Coalesce(Custom_captions.Capt_US, '''') as adli_TypeDisplay, '+
' adli_PRSlot '+
' FROM Address '+
' JOIN Address_Link ON addr_AddressId = adli_AddressId  '+
' LEFT OUTER JOIN PRCity ON addr_PRCityId = prci_CityId '+
' LEFT OUTER JOIN PRState ON prci_StateId = prst_StateId '+
' LEFT OUTER JOIN PRCountry ON prst_CountryId = prcn_CountryId ' +
' LEFT OUTER JOIN Company ON adli_CompanyId = comp_CompanyId  '+
' LEFT OUTER JOIN Person ON adli_PersonId = pers_PersonId  '+
' LEFT OUTER JOIN Custom_Captions ON adli_Type = Capt_Code  '+
'   AND Capt_Family = '+
'   CASE '+
'     WHEN adli_CompanyId is not null THEN ''adli_TypeCompany'' '+
'     WHEN adli_PersonId is not null THEN ''adli_TypePerson'' '+
'     ELSE ''adli_Type'' '+
'   END '+
'  '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRAddress', @Script 

SET @Script = 
'CREATE VIEW dbo.vListingAddress AS ' +
'SELECT  adli.adli_CompanyId,adli.adli_PersonId,addr_Address1,addr_Address2,addr_Address3,addr_Address4 as Address4, '+
' addr_PRCityId, prci_City,prst_State,addr_PostCode,adli.adli_Type '+
'FROM    Address_Link adli' +
'    INNER JOIN vPRAddress ON AdLi_AddressId = Addr_AddressId '
exec usp_AccpacCreateView 'PRView', NULL, 'vListingAddress', @Script 


SET @Script = 
'CREATE VIEW dbo.vListingPhone AS ' +
'SELECT  phon_CompanyId, phon_PersonId,phon_PRPublish,phon_type,phon_FullNumber, phon_TypeDisplay, '+ 
'    COALESCE(rtrim(phon_countrycode),'''')+ '+
'    COALESCE('' ''+rtrim(phon_areacode),'''')+ '+
'    COALESCE('' ''+rtrim(phon_number),'''') as PhoneValue ' +
'FROM vPRPhone '
exec usp_AccpacCreateView 'PRView', NULL, 'vListingPhone', @Script 


-- Add the vAddressPerson view so this gets removed with component uninstalls
SET @Script = 
'CREATE VIEW dbo.vAddressPerson ' + 
'AS '+
'SELECT  DISTINCT '+
'vPRAddress.* '+
'FROM vPRAddress   '+
'WHERE  '+
'adli_PersonId is not null  '+ 
'and adli_CompanyId is null   '+
'and addr_Deleted IS NULL   '

exec usp_AccpacCreateView 'PRView', NULL, 'vAddressPerson', @Script 

-- vPRAUSCompanyList - retrieves the companies (and city, state) associated with PRAUS records
SET @Script = 
'CREATE VIEW dbo.vPRAUSCompanyList ' + 
'AS '+
'SELECT prau.*, comp_Name, prci_City, prst_State '+
'FROM PRAUS prau  '+
'JOIN Company ON prau_MonitoredCompanyId = comp_CompanyId '+
'LEFT OUTER JOIN PRCity ON comp_PRListingCityId = prci_CityId '+
'LEFT OUTER JOIN PRState ON prci_StateId = prst_StateId '+
'LEFT OUTER JOIN PRCountry ON prst_CountryId = prcn_CountryId '+
'WHERE prau_Deleted IS NULL '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRAUSCompanyList', @Script 


/* 
    This view is specific to the fields needed for teh company personnel listing.
*/
SET @Script = 
'CREATE VIEW dbo.vPRPersonnelListing AS '+
'SELECT '+
'dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, pers_PRNickname1, Pers_Suffix, 1) AS Pers_FullName, '+
'pers_personid, Pers_CompanyId = peli_CompanyId, Pers_FirstName,Pers_LastName, pers_PRLanguageSpoken, '+
'peli_PersonLinkId, peli_PRTitle, peli_PRTitleCode, peli_PRStartDate, peli_PREndDate, peli_PRStatus, '+
'peli_PRRole, peli_PRRecipientRole, peli_PROwnershipRole, '+
'peli_Companyid, '+
'peli_personid, '+
'peli_WebStatus, ' +
'peli_PRBRPublish, ' +
'peli_PREBBPublish ' +
'FROM dbo.Person '+
'INNER JOIN dbo.Person_Link ON Pers_PersonId = PeLi_PersonId '+
'WHERE  (Pers_Deleted IS NULL) AND (PeLi_Deleted IS NULL) '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRPersonnelListing', @Script 


-- ***** PRCompany

-- optimized view for selecting people or companies that have the ability to use AUS services
SET @Script = 
'CREATE VIEW dbo.vAUSSubscriber AS '+
'select comp_CompanyId, comp_Name, peli_PersonId, prci_City, prst_State  '+
'from Company  '+
'JOIN Person_Link on comp_CompanyId = peli_PRCompanyId '+
'LEFT OUTER JOIN PRCity on comp_PRListingCityId = prci_CityId '+
'LEFT OUTER JOIN PRState on prci_StateId = prst_StateId '+
'where comp_companyid in '+
'(select distinct prse_CompanyId from PRService '+
'where prse_ServiceCode in (''AF'',''AG'',''AH'',''AI'',''AJ'',''AK'',''AL'',''EM'',''EP'',''ET'',''F3'',''F5'',''FB'',''FE'',''FM'',''FR'',''JB'',''JM'',''JR'',''JS'',''JX'',''JZ'',''ME'',''MG'',''NC'',''O5'',''OB'',''OM'',''OP'',''OQ'',''OR'',''OZ'',''P3'',''PB'',''PM'',''RB'',''RM'',''T3'',''T5'',''TB'',''TE'',''TM'',''TR'',''ZA'',''ZB'',''ZC'',''ZD'',''ZE'',''ZF'',''ZG'')) '
exec usp_AccpacCreateView 'PRView', NULL, 'vAUSSubscriber', @Script 


SET @Script = 
'CREATE VIEW dbo.vPRCompanyTerminalMarket AS '+
'SELECT prct.*, prtm.* '+
' FROM PRCompanyTerminalMarket prct '+
' LEFT OUTER JOIN PRTerminalMarket prtm '+
' ON prct_TerminalMarketId = prtm_TerminalMarketId '+
' WHERE prct_Deleted is null and prtm_Deleted is null';
exec usp_AccpacCreateView 'PRView', NULL, 'vPRCompanyTerminalMarket', @Script 


SET @Script = 
'CREATE VIEW dbo.vListingPRCompanyCommodity AS ' + 
'select *, ' +
'    prcca_ListingCol1 =  ' +
'		Coalesce(sCommodity + ''/'' + sCategory + ''/'' + sGroup,' +
'				 sCommodity + ''/'' + sCategory,' +
'				 sCommodity + ''/'' + sGroup,' +
'				 sCategory + ''/'' + sGroup,' +
'				 sCommodity, sCategory, sGroup, ''''),' +
'    prcca_ListingCol2 =  case ' +
'		when sRefinement IS NOT NULL then ISNULL(sVariety + ''/'', '''') + sRefinement ' +
'		when sVarietyGroup IS NOT NULL then sVarietyGroup ' +
'		when sVariety IS NOT NULL then sVariety' +
'		else ''''' +
'	end ' +
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
'		from PRCompanyCommodityAttribute prcca  ' +
'		INNER JOIN PRCommodity prcm ON prcca_CommodityId = prcm_CommodityId  ' +
'       LEFT OUTER JOIN PRAttribute AS attrb ON prcca.prcca_AttributeID = attrb.prat_AttributeID ' +
'       LEFT OUTER JOIN PRAttribute AS gm ON prcca.prcca_GrowingMethodID = gm.prat_AttributeID ' +
' ) ATable ' +
') OuterTable '
exec usp_AccpacCreateView 'PRView', NULL, 'vListingPRCompanyCommodity', @Script 



-- Add the vCompanyAddress view so this gets removed with component uninstalls
SET @Script = 
'CREATE VIEW dbo.vAddressCompany ' + 
'AS '+
'SELECT  DISTINCT '+
'adli_TypeDisplay = dbo.ufn_GetAddressTypeList(adli_AddressId, ''adli_TypeCompany'') ,'+
'addr_City,'+
'addr_State,'+
'addr_PostCode,'+
'addr_Country,'+
'adli_CompanyId, '+
'addr_AddressId, addr_Address1, addr_address2, addr_PRCityId, addr_PRCounty  '+
'FROM Address   '+
'LEFT OUTER JOIN Address_Link ON adli_AddressId = addr_AddressId  '+
'WHERE  '+
'adli_CompanyId is  not null  '+ 
'and adLi_PersonId is null   '+
'and adli_Deleted IS NULL    '+
'and addr_Deleted IS NULL   '
exec usp_AccpacCreateView 'PRView', NULL, 'vAddressCompany', @Script 

-- vPRCompanyClassification
SET @Script = 
'CREATE VIEW dbo.vPRCompanyClassification AS ' + 
'select cls.prcl_Abbreviation, CC.* ' + 
' from PRCompanyClassification CC ' + 
' JOIN PRClassification cls on prc2_ClassificationId = prcl_ClassificationId';
exec usp_AccpacCreateView 'PRView', NULL, 'vPRCompanyClassification', @Script 

-- vCompanyInvestigationMethod
SET @Script = 
'CREATE VIEW dbo.vCompanyInvestigationMethod AS ' + 
'select comp_companyId, comp_PRInvestigationMethodGroup, '+ 
'newGroup = case '+ 
'    when comp_PRType != ''H'' then null '+
'    when companyId is not null then ''A'' '+
'    else ''B'' '+
'end '+
'from company '+
'LEFT OUTER JOIN  '+
'( '+
'    select distinct(companyid) from ( '+
'    select companyId = prc2_CompanyId '+
'        from PRCompanyClassification '+
'        WHERE prc2_ClassificationId in '+
'        ( select prcl_ClassificationId from PRClassification '+
'            where prcl_Abbreviation in (''Dstr'', ''Exp'', ''J'', ''R'', ''Ret'', ''Rg'', ''Wg'', ''TruckBkr'') '+
'        ) '+
'    union '+
'    select companyId  '+
'        from ( '+
'        select companyId = prtr_SubjectId, cnt_PayReports = count(1) from PRTradeReport  '+
'        where prtr_PayRatingId is not null '+
'            AND prtr_Date > DateAdd(Month, -24, getDate()) '+
'        group by prtr_SubjectId '+
'        ) ATable  '+
'        where cnt_PayReports >= 10 '+
'    ) UNION_TABLE '+
') GROUPA_TABLE ON comp_companyId = companyid '
exec usp_AccpacCreateView 'PRView', NULL, 'vCompanyInvestigationMethod', @Script 


-- Add the vPRCompanyRelationshipFull view; this is used by the CompanyRelationship Grid
/* note that this view returns a variable named prcr_RightCompanyId equal to prcr_RelatedCompanyId;
	this is to allow accpac to automatically link the field name to an advanced search select
	field in grids and display blocks; This field should be construed as the Related Company to
	this subject company
*/
SET @Script = 
'create view dbo.vPRCompanyRelationshipListing as ' + 
'SELECT prcr_CompanyRelationshipId, prcr_SubjectCompanyID, prcr_RelatedCompanyID, prcr_RightCompanyId = prcr_RelatedCompanyID, '+
	'prcr_UpdatedDate, prcr_LastReportedDate, prcr_Type, prcr_Deleted, CityStateCountry, prcr_Active, '+
	'prcr_ReportingCompanyType = case '+
		'when (prcr_SubjectCompanyID = prcr_LeftCompanyId) then 1 '+
		'else 2 '+
	'end, '+
	'prcr_TypeDescription = case '+
		'when (prcr_SubjectCompanyID = prcr_LeftCompanyId) then REPLACE(REPLACE(capt_us, ''Company X'', ''Subject Company''), ''Company Y'', ''Related Company'') '+
		'else REPLACE(REPLACE(capt_us, ''Company Y'', ''Subject Company''), ''Company X'', ''Related Company'') '+
	'end, '+
	'prcr_CategoryType = case  '+
		'when (prcr_Type in (1,4,5,7)) then 1 '+
		'when (prcr_Type in (9,10,11,12,13,14,15,16)) then 2 '+
		'when (prcr_Type in (23,24)) then 3 '+
		'when (prcr_Type in (27,28,29)) then 4 '+
		'when (prcr_Type in (30,31,32)) then 5 '+
		'when (prcr_Type in (33,34)) then 6 '+
		'else NULL '+
	'end,  '+
	'comp_PRListingStatus, comp_PRIndustryType, '+
	'prcr_RelatedCompanyId AS comp_CompanyID ' + -- This is to enable a link to the Company Summary screen.
'FROM ( '+
	'select prcr_CompanyRelationshipId, prcr_LeftCompanyId, prcr_RightCompanyId, '+
		'prcr_SubjectCompanyID = prcr_LeftCompanyId, prcr_RelatedCompanyID = prcr_RightCompanyId, '+ 
		'prcr_UpdatedDate, prcr_LastReportedDate, prcr_Type, prcr_Deleted, prcr_Active '+
	 'from PRCompanyRelationship '+ 
	'union '+
	'select prcr_CompanyRelationshipId, prcr_LeftCompanyId, prcr_RightCompanyId, '+ 
		'prcr_SubjectCompanyID = prcr_RightCompanyId, prcr_RelatedCompanyID = prcr_LeftCompanyId, '+ 
		'prcr_UpdatedDate, prcr_LastReportedDate, prcr_Type, prcr_Deleted, prcr_Active '+ 
	 'from PRCompanyRelationship '+ 
') BTABLE '+ 
 'inner join company on comp_companyid = prcr_RelatedCompanyID '+
 'inner join vPRLocation on comp_prlistingcityid = prci_cityid '+
 'inner join Custom_Captions ON capt_family = ''prcr_TypeFilter'' and capt_familytype = ''Choices'' and capt_code = prcr_Type '+
'where prcr_Deleted is null'
exec usp_AccpacCreateView 'PRView', NULL, 'vPRCompanyRelationshipListing', @Script 

SET @Script = 
'create view dbo.vPRCompanyRelationship as ' + 
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
'from PRCompanyRelationship '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRCompanyRelationship', @Script 

-- Add the vPROwnershipByCompany view so this gets removed with component uninstalls
SET @Script = 
'create view dbo.vPROwnershipByCompany ' +
'as ' +
'select prcr_CompanyRelationshipId, prcr_LeftCompanyId, prcr_LeftCompanyId as prcr_RelatedBBID, prcr_RightCompanyId, prcr_OwnershipPct, prcr_UpdatedDate,  prci_City, prst_Abbreviation, prcn_Country, prcr_Type ' +
'FROM PRCompanyRelationship ' +
'INNER JOIN company on comp_companyid = prcr_rightcompanyid ' +
'INNER JOIN vPRLocation on comp_prlistingcityid = prci_cityid ' +
'where prcr_Deleted is null ' +
'AND (prcr_Type = ''27'' or prcr_Type = ''28'')'
exec usp_AccpacCreateView 'PRView', NULL, 'vPROwnershipByCompany', @Script 
exec usp_AccpacCreateDropdownValue 'ColNames', 'prcr_relatedbbid', 0, 'Related BBID', 'PRCompany'


-- Add the vPROwnershipByPerson view so this gets removed with component uninstalls
SET @Script = 
'create view dbo.vPROwnershipByPerson as ' +
'select pers_PersonId, peli_CompanyId, peli_PRPctOwned, pers_FirstName, pers_LastName, peli_PRTitle from Person_Link, Person ' +
'where peli_PersonId = pers_PersonId ' +
'and peli_PROwnershipRole <> ''RCR'' '
exec usp_AccpacCreateView 'PRView', NULL, 'vPROwnershipByPerson', @Script 

-- *****  PRRating VIEWS

-- Add the vPRRatingNumeralsToAutoRemove view so this gets removed with component uninstalls
SET @Script = 
'CREATE VIEW dbo.vPRRatingNumeralsToAutoRemove AS ' +
'SELECT DISTINCT pran_RatingNumeralAssignedId, comp_CompanyId, comp_Name, prci_City, comp_PRListingCityId, prtx_transactionId, prtx_status, ' + 
'prtx_CreatedBy, prra_AssignedRatingNumerals = dbo.ufn_getAssignedRatingNumerallIST(prra_RatingId, 1), '+
'prtx_LockedBy = case '+ 
'   when prtx_status = ''O'' then RTrim(user_firstname) + '' '' + RTrim(user_lastname) '+ 
'   else  '''' '+
'end '+
'FROM PRRatingNumeralAssigned '+
'JOIN PRRating ON prra_ratingid = pran_ratingid and prra_Current = ''Y'' '+
'JOIN PRtransaction ON prra_companyid = prtx_companyid '+
'JOIN Users ON prtx_CreatedBy = user_userid '+
'JOIN Company ON prra_companyid = comp_companyid '+
'JOIN PRCity ON comp_PRListingCityId = prci_Cityid '+
'WHERE pran_ratingNumeralId in '+
'   (select prrn_ratingNumeralId from PRRatingNumeral where prrn_AutoRemove = ''Y'') '
exec usp_AccpacCreateView 'PRView', 'PRRating', 'vPRRatingNumeralsToAutoRemove', @Script 

-- PRTradeReport Views
SET @Script = 
'CREATE VIEW dbo.vPRTradeReportOn AS ' +
'SELECT  NULL AS prtr_StartDate, NULL AS prtr_EndDate, ' +
'prtr_Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(prtr_ResponderId,1), ' +
'prpy_TradeReportDescription, prin_TradeReportDescription, ' +
'prtr_TradeReportId, prtr_Date, prtr_ResponderId, prtr_SubjectId, prtr_CreditTerms, prtr_Terms, ' +
'prtr_HighCredit, prtr_Exception, prtr_DisputeInvolved  ' +
'from PRTradeReport prtr ' + 
'LEFT OUTER JOIN PRIntegrityRating ON prtr_IntegrityId = prin_IntegrityRatingId ' +
'LEFT OUTER JOIN PRPayRating ON prtr_PayRatingId = prpy_PayRatingId ' 
exec usp_AccpacCreateView 'PRView', NULL, 'vPRTradeReportOn', @Script 

SET @Script = 
'CREATE VIEW dbo.vPRTradeReportBy AS ' +
'SELECT  NULL AS prtr_StartDate, NULL AS prtr_EndDate, ' +
'prtr_Level1ClassificationValues = dbo.ufn_GetLevel1Classifications(prtr_SubjectId,1), ' +
'prpy_TradeReportDescription, prin_TradeReportDescription, ' +
'prtr_TradeReportId, prtr_Date, prtr_ResponderId, prtr_SubjectId, prtr_CreditTerms, prtr_Terms, ' +
'prtr_HighCredit, prtr_Exception, prtr_DisputeInvolved  ' +
'from PRTradeReport prtr ' + 
'LEFT OUTER JOIN PRIntegrityRating ON prtr_IntegrityId = prin_IntegrityRatingId ' +
'LEFT OUTER JOIN PRPayRating ON prtr_PayRatingId = prpy_PayRatingId ' 
exec usp_AccpacCreateView 'PRView', NULL, 'vPRTradeReportBy', @Script 


-- vPRARAgingDetailOn
SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetailOn AS ' +
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
                            ' + ISNULL(praad_Amount61Plus, 0) ' +
   'from PRARAgingDetail praad ' +
   'JOIN PRARAging praa ON praa_ARAgingId = praad_ARAgingId ' +
   'JOIN Company comp ON praa_CompanyId = comp.comp_CompanyId ' +
   'LEFT OUTER JOIN prartranslation ON praad_ARCustomerId = prar_CustomerNumber ' +
            	'AND prar_CompanyId = praa_CompanyId ' +
') ATable ' +
'LEFT OUTER JOIN company subjCompany ON praad_SubjectCompanyId = subjCompany.comp_CompanyId ' 
exec usp_AccpacCreateView 'PRView', NULL, 'vPRARAgingDetailOn', @Script 

-- vPRARAgingDetailBy
SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetailBy AS ' + 
'select ' +
'       praa_ARAgingId, praa_RunDate, praa_Date, praa_ImportedDate, praa_ImportedByUserId, ' +
'       praa_CompanyId = comp.comp_CompanyId,' +
'       prar_PRCoCompanyId, prar_CustomerNumber, praad_CompanyName = case '+
'         when praad_ManualCompanyId IS NOT NULL THEN manual.comp_Name '+
'         when prar_PRCoCompanyId IS NULL THEN praad_FileCompanyName '+
'         else trancompany.comp_Name  '+
'       end, '+
'       Level1ClassificationValues = case  '+
'         when praad_ManualCompanyId is not null then dbo.ufn_GetLevel1Classifications(praad_ManualCompanyId,1) '+
'         when prar_PRCoCompanyId is not null then dbo.ufn_GetLevel1Classifications(prar_PRCoCompanyId,1)  '+
'         else ''''  '+
'       end, '+
'       praad_LineTotal = (praad_Amount0to29 + praad_Amount30to44 '+
'              + praad_Amount45to60 + praad_Amount61Plus), '+
'       praad_LinePercent = (praad_Amount0to29Percent + praad_Amount30to44Percent '+
'              + praad_Amount45to60Percent + praad_Amount61PlusPercent), '+
'       BTable.* '+
'from  '+
'( '+
'select  '+
'    praad_TotalAmount0to29Percent = 100*(praad_TotalAmount0to29/praad_TotalAmount), '+
'    praad_TotalAmount30to44Percent = 100*(praad_TotalAmount30to44/praad_TotalAmount), '+
'    praad_TotalAmount45to60Percent = 100*(praad_TotalAmount45to60/praad_TotalAmount), '+
'    praad_TotalAmount61PlusPercent = 100*(praad_TotalAmount61Plus/praad_TotalAmount), '+
'    praad_Amount0to29Percent = 100*(praad_Amount0to29/praad_TotalAmount), '+
'    praad_Amount30to44Percent = 100*(praad_Amount30to44/praad_TotalAmount), '+
'    praad_Amount45to60Percent = 100*(praad_Amount45to60/praad_TotalAmount), '+
'    praad_Amount61PlusPercent = 100*(praad_Amount61Plus/praad_TotalAmount), '+
'    *  '+
'from  '+
'  (select  '+
'    praad_TotalAmount = praad_TotalAmount0to29  '+
'              + praad_TotalAmount30to44 '+
'              + praad_TotalAmount45to60 '+
'              + praad_TotalAmount61Plus, '+
'    praad_TotalAmount0to29, praad_TotalAmount30to44, praad_TotalAmount45to60, praad_TotalAmount61Plus, '+
'    praad_ARAgingDetailId, praa_ARAgingDetailCount, praad.praad_ARAgingId, praad_ARCustomerId, '+ 
'    praad_FileCompanyName, praad_FileCityName, praad_FileStateName, praad_FileZipCode, '+
'    praad_Exception, praad_CreditTerms, praad_Deleted, praad_ManualCompanyId, '+
'    praad_Amount0to29 = ISNULL(praad_Amount0to29,0), '+ 
'    praad_Amount30to44 = ISNULL(praad_Amount30to44,0), '+ 
'    praad_Amount45to60 = ISNULL(praad_Amount45to60,0),  '+
'    praad_Amount61Plus = ISNULL(praad_Amount61Plus,0)  '+
'  from PRARAgingDetail praad '+
'  JOIN ( '+
'    select praad_ARAgingId, '+
'      praa_ARAgingDetailCount = count(1), ' +
'      praad_TotalAmount0to29 = ISNULL(sum(praad_Amount0to29),0), '+ 
'      praad_TotalAmount30to44 = ISNULL(sum(praad_Amount30to44),0),  '+
'      praad_TotalAmount45to60 = ISNULL(sum(praad_Amount45to60),0),  '+
'      praad_TotalAmount61Plus = ISNULL(sum(praad_Amount61Plus),0) '+
'      from PRARAgingDetail '+
'      group by praad_ARAgingId '+
'    ) sums ON praad.praad_ARAgingId = sums.praad_ARAgingId '+
'  ) ATable '+
') BTable '+
' LEFT OUTER JOIN PRARAging praa ON praa_ARAgingId = praad_ARAgingId ' +
' LEFT OUTER      JOIN Company comp ON praa_CompanyId = comp.comp_CompanyId ' +
' LEFT OUTER      JOIN Company manual ON praad_ManualCompanyId = manual.comp_CompanyId ' +
' LEFT OUTER JOIN PRARTranslation trans ON prar_CustomerNumber = praad_ARCustomerId '+ 
' LEFT OUTER JOIN Company tranCompany ON tranCompany.comp_CompanyId = trans.prar_PRCoCompanyId '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRARAgingDetailBy', @Script 

-- vPRTES
SET @Script = 
'CREATE VIEW dbo.vPRTES AS ' + 
'select prte_TESId, prte_Deleted, prte_ResponderCompanyId, prte_Date, ' + 
' prte_HowSent, prte_ResponseDate, prt2_TESDetailId, prt2_SubjectCompanyId ' + 
' from PRTES ' + 
' LEFT OUTER JOIN PRTESDetail ON prte_TESId = prt2_TESId';
exec usp_AccpacCreateView 'PRView', NULL, 'vPRTES', @Script 

-- vPRARTranslation
SET @Script = 
'CREATE VIEW dbo.vPRARTranslation AS '+
'select prar_ARTranslationId, prar_CompanyId, prar_CustomerNumber, prar_PRCoCompanyId,'+
' prar_PRCoCompanyName = case '+
'     when tranCompany.comp_Name IS NULL THEN '''' '+            
'     ELSE tranCompany.comp_Name '+
'     end '+ 
'from  PRARTranslation  ' +
'LEFT OUTER JOIN Company tranCompany ON tranCompany.comp_CompanyId = prar_PRCoCompanyId'
exec usp_AccpacCreateView 'PRView', NULL, 'vPRARTranslation', @Script 

SET @Script = 
'CREATE VIEW dbo.vPRARAgingDetail AS '+
'SELECT distinct praa_CompanyId, '+
    'SubjectCompanyId = case '+
      'when praad_ManualCompanyId IS NOT NULL then praad_ManualCompanyId '+
      'when prar_PRCoCompanyId IS NOT NULL then prar_PRCoCompanyId '+
      'else NULL '+
    'end, '+
    'praad.* '+
'FROM PRARAgingDetail praad '+
'JOIN PRARAging ON praa_ARAgingId = praad_ARAgingId '+
'LEFT OUTER JOIN PRARTranslation ON praa_CompanyId = prar_CompanyId '+
                               'AND praad_ARCustomerId = prar_CustomerNumber '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRARAgingDetail', @Script 

-- **** vExceptionQueue
SET @Script = 
'CREATE VIEW dbo.vExceptionQueue AS ' +
'SELECT comp_Name, prci_City, preq_TypeName = capt_US, '+
'preq_StatusName = case when preq_status = ''C'' then ''Closed'' else ''Open'' end, ' + 
'preq_BBScoreDisplay = case when preq_BlueBookScore is null then '''' else convert(varchar,preq_BlueBookScore) end, ' + 
' preq_AssignedUser = COALESCE(RTRIM(user_FirstName) + '' '', '''') + RTRIM(user_LastName), preq.* ' +
'FROM PRExceptionQueue preq '+ 
'JOIN Custom_Captions ON capt_FamilyType = ''Choices'' and capt_Family = ''preq_Type'' and capt_Code = preq_Type '+
'JOIN Company ON preq_CompanyId = comp_CompanyId '+
'LEFT OUTER JOIN PRCity ON comp_PRListingCityId = prci_CityId ' +
'LEFT OUTER JOIN Users ON preq_AssignedUserId = user_UserId '
exec usp_AccpacCreateView 'PRView', NULL, 'vExceptionQueue', @Script 

-- vPRTransaction
SET @Script = 
'CREATE VIEW dbo.vPRTransaction ' + 
'AS ' +
'SELECT prtx.*, prbe_BusinessEventTypeId ' +
'from PRTransaction prtx ' +
'LEFT OUTER JOIN PRBusinessEvent ON prtx_BusinessEventId = prbe_BusinessEventId ' 
exec usp_AccpacCreateView 'PRView', NULL, 'vPRTransaction', @Script 



SET @Script = 
'CREATE VIEW dbo.vPRServiceUnitAllocHistory AS '+
'SELECT prun_CompanyID, '+
'       prun_PersonID, '+
'       a.Capt_US as prun_AllocationTypeCode, '+ 
'       prun_UnitsAllocated, '+
'       prun_UnitsRemaining, '+
'       prun_UnitsAllocated-prun_UnitsRemaining as UnitsUsed, '+
'       prun_ExpirationDate, '+
'       prun_CreatedDate '+
'  FROM PRServiceUnitAllocation  '+
'       INNER JOIN Custom_Captions a ON prun_AllocationTypeCode = a.capt_Code AND RTRIM(a.capt_Family)=''prun_AllocationType'' '+
' WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
    AND prun_UnitsRemaining > 0'
exec usp_AccpacCreateView 'PRView', NULL, 'vPRServiceUnitAllocHistory', @Script 

SET @Script = 
'CREATE VIEW dbo.vPRServiceUnitUsageHistory  AS '+
'SELECT RTRIM(pers_FirstName) AS pers_FirstName,  '+
'	   RTRIM(pers_LastName) AS pers_LastName, '+
'	   prsuu_CompanyID, '+
'	   prsuu_CreatedDate, '+
'      prsuu_SearchCriteria, '+
'	   prsuu_UsageTypeCode, '+
'      prbr_RequestedCompanyID, '+
'      comp_PRTradestyle1, '+
'      comp_PRCorrTradestyle, '+
'	   prsuu_Units '+
'  FROM PRServiceUnitUsage  '+
'       LEFT OUTER JOIN Person ON prsuu_PersonID = pers_PersonID '+
'       LEFT OUTER JOIN PRBusinessReportRequest ON prsuu_RegardingObjectID = prbr_BusinessReportRequestID '+
'       INNER JOIN Company ON prbr_RequestedCompanyID = comp_CompanyID'
exec usp_AccpacCreateView 'PRView', NULL, 'vPRServiceUnitUsageHistory', @Script 


SET @Script = 
'CREATE VIEW dbo.vPRCommunication AS '+
'SELECT communication.*, '+
'       comm_link.*, '+
'       comm_Attn = person.pers_lastname + '' '' + person.pers_lastname, '+ 
'       comm_CompanyName = comp_name, '+
'       comm_AddressLine1 = vPRAddr.addr_address1, '+
'       comm_CityStateZip = vPRAddr.prci_City + '', '' + vPRAddr.prst_State + '' '' + COALESCE(vPRAddr.addr_PostCode, ''''), '+
'       comm_EmailFax = emai_EmailAddress '+
'  FROM comm_link  ' +
'       INNER JOIN communication on cmli_comm_CommunicationId = comm_CommunicationId '+
'       LEFT OUTER JOIN vPRAddress vPRAddr on cmli_comm_CompanyId = adli_CompanyId '+
'       LEFT OUTER JOIN Company on cmli_comm_CompanyId = comp_CompanyId '+
'       LEFT OUTER JOIN Person on cmli_comm_PersonId = pers_PersonId '+
'       LEFT OUTER JOIN Email on cmli_comm_PersonId = emai_PersonId '+
' WHERE communication.comm_Deleted is null and comm_link.cmli_Deleted is null '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRCommunication', @Script 

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
'  FROM PRServiceUnitUsage prsuu  ' +
'       LEFT OUTER JOIN PRBusinessReportRequest prbr ON prsuu_RegardingObjectId = prbr_BusinessReportRequestId '+
' WHERE prsuu.prsuu_Deleted is null and prbr.prbr_Deleted is null '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRServiceUnitUsage', @Script 


SET @Script = 
'CREATE VIEW vPRTESFormExtract AS '+
'SELECT prtf_TESFormBatchID, '+
'       prtf_FormType, '+
'	   prtf_SerialNumber, '+ 
'	   prtf_CompanyID,  '+
'	   pers_PersonID,  '+ 
'      ISNULL(''Attn: '' + dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix), dbo.ufn_GetAddressAttentionLine(addr_AddressID)) AS AttentionLine, ' +
'       Responder.comp_PRCorrTradestyle AS ResponderCorrTradeStyle, '+
'       addr_Address1, '+
'       addr_Address2, '+
'       addr_Address3, '+
'       addr_Address4, '+
'       addr_Address5, '+
'       ResponderLocation.prci_City AS Responderprci_City, '+
'       ResponderLocation.prst_Abbreviation AS Responderprst_Abbreviation, '+
'	   ResponderLocation.prcn_Country AS Responderprcn_Country, '+
'       addr_PostCode, '+
'	   prt2_SubjectCompanyID,  '+
'	   Subject.comp_PRBookTradestyle AS SubjectBookTradeStyle, '+
'       SubjectLocation.prci_City AS Subjectprci_City, '+
'       SubjectLocation.prst_Abbreviation AS Subjectprst_Abbreviation, '+
'	   SubjectLocation.prcn_Country AS Subjectprcn_Country '+
'  FROM dbo.Person  '+
'       INNER JOIN dbo.Person_Link ON dbo.Person.Pers_PersonId = dbo.Person_Link.PeLi_PersonId AND peli_PRStatus IN (1,2)  '+
'		RIGHT OUTER JOIN PRTESForm '+
'       INNER JOIN PRTESDetail ON prtf_TESFormID = prt2_TESFormID '+
'	   INNER JOIN Company Responder ON prtf_CompanyID = Responder.comp_CompanyID '+
'       INNER JOIN Company Subject ON prt2_SubjectCompanyID = Subject.comp_CompanyID '+
'       INNER JOIN Address_Link ON prtf_CompanyID = adli_CompanyID '+
'       INNER JOIN Address ON adli_AddressID = addr_AddressID '+
'       INNER JOIN vPRLocation ResponderLocation on addr_PRCityID = ResponderLocation.prci_CityID '+
'	   INNER JOIN vPRLocation SubjectLocation on Subject.comp_PRListingCityID = SubjectLocation.prci_CityID '+
'	   ON dbo.Person_Link.PeLi_CompanyID = Responder.Comp_CompanyId AND Peli_PRRecipientRole LIKE ''%,RCVTES,%'' '+
' WHERE adli_deleted IS NULL '+
'   AND addr_deleted IS NULL '+
'   AND adli_PRDefaultTES = ''Y'' '
exec usp_AccpacCreateView 'PRView', NULL, 'vPRTESFormExtract', @Script 

-- create views that display records that have workflows started
SET @Script = 
'CREATE VIEW dbo.vPROpportunityWorkflowListing AS ' +
'Select WS.*, WI.*, OPP.*, comp_companyid = oppo_primarycompanyid from WorkflowInstance WI ' +
'inner join Opportunity OPP ON wkin_CurrentrecordId = oppo_OpportunityId ' +
'inner join WorkflowState WS ON wkin_CurrentStateId = wkst_StateId ' +
'Where wkin_CurrentEntityId = 10 ' 
exec usp_AccpacCreateView 'PRView', NULL, 'vPROpportunityWorkflowListing', @Script 

SET @Script = 
'CREATE VIEW dbo.vPRFileWorkflowListing AS ' +
'Select WS.*, WI.*, PRFile.* from WorkflowInstance WI '+
'inner join PRFile ON wkin_CurrentrecordId = prfi_FileId '+
'inner join WorkflowState WS ON wkin_CurrentStateId = wkst_StateId' 
exec usp_AccpacCreateView 'PRView', NULL, 'vPRFileWorkflowListing', @Script 

SET @Script = 
'CREATE VIEW dbo.vCustomerCareWorkflowListing AS ' +
'Select WS.*, WI.*, Cases.*, comp_companyid = case_primarycompanyid from WorkflowInstance WI ' +
'inner join cases ON wkin_CurrentrecordId = case_caseId ' +
'inner join WorkflowState WS ON wkin_CurrentStateId = wkst_StateId ' +
'Where wkin_CurrentEntityId = 3 ' 
exec usp_AccpacCreateView 'PRView', NULL, 'vCustomerCareWorkflowListing', @Script 

SET @Script = 
'CREATE VIEW dbo.vPRSearchListState AS ' +
'SELECT prst_StateID, prst_State, prst_Abbreviation, prcn_CountryId, prcn_Country, prcn_CountryCode ' +
'  FROM PRState ' +
'       LEFT OUTER JOIN PRCountry ON prst_CountryID = prcn_CountryId ' +
' WHERE prst_State IS NOT NULL;'
exec usp_AccpacCreateView 'PRView', NULL, 'vPRSearchListState', @Script 



--
--  Overriding an Accpac native view.  Also had to dump several
--  user field references to trim down the SQL size to fit into
--  the @Script variable.  They don't appear to be used anywhere.
--
-- This view returns dbo.ufn_GetCompanyFullName as comp_Name in order to get a differet
-- value to appear in the Recent List and the company AdvancedSearchSelect fields.
--
SET @Script = 'CREATE VIEW dbo.vSummaryCompany AS ' +
'SELECT dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix, 1) AS Pers_FullName,' + 
'RTRIM(ISNULL(dbo.Users.User_FirstName, '' '')) + '' '' + RTRIM(ISNULL(dbo.Users.User_LastName, '' '')) AS User_Name, dbo.vAddress.Addr_Street, ' +
'dbo.vAddress.Addr_AddressId, dbo.vAddress.Addr_Address1, dbo.vAddress.Addr_Address2, dbo.vAddress.Addr_Address3, ' +
'dbo.vAddress.Addr_Address4, dbo.vAddress.Addr_Address5, dbo.vAddress.Addr_City, dbo.vAddress.Addr_State, dbo.vAddress.Addr_Country, ' +
'dbo.vAddress.Addr_PostCode, dbo.vAddress.Addr_CreatedBy, dbo.vAddress.Addr_CreatedDate, dbo.vAddress.Addr_UpdatedBy, ' +
'dbo.vAddress.Addr_UpdatedDate, dbo.vAddress.Addr_TimeStamp, dbo.vAddress.Addr_Deleted, dbo.vAddress.Addr_SegmentID, ' +
'dbo.vAddress.Addr_ChannelID, dbo.vAddress.addr_uszipplusfour, dbo.vAddress.addr_PRCityId, dbo.vAddress.addr_PRCounty, ' +
'dbo.vAddress.addr_PRZone, dbo.vAddress.addr_PRPublish, dbo.vAddress.addr_PRDescription, ' +
'dbo.vAddress.addr_PRReplicatedFromId, dbo.vAddress.addr_PRAttentionLineType, dbo.vAddress.addr_PRAttentionLineCustom, ' +
'dbo.vAddress.addr_PRAttentionLinePersonId, dbo.Person.Pers_PersonId, ' +
'dbo.Person.Pers_CompanyId, dbo.Person.Pers_PrimaryAddressId, dbo.Person.Pers_PrimaryUserId, dbo.Person.Pers_Salutation, ' +
'dbo.Person.Pers_FirstName, dbo.Person.Pers_LastName, dbo.Person.Pers_MiddleName, dbo.Person.Pers_Suffix, dbo.Person.Pers_Gender, ' +
'dbo.Person.Pers_Title, dbo.Person.Pers_TitleCode, dbo.Person.Pers_Department, dbo.Person.Pers_Status, dbo.Person.Pers_Source, ' +
'dbo.Person.Pers_Territory, dbo.Person.Pers_WebSite, dbo.Person.Pers_MailRestriction, dbo.Person.Pers_PhoneCountryCode, ' +
'dbo.Person.Pers_PhoneAreaCode, dbo.Person.Pers_PhoneNumber, dbo.Person.Pers_EmailAddress, dbo.Person.Pers_FaxCountryCode, ' +
'dbo.Person.Pers_FaxAreaCode, dbo.Person.Pers_FaxNumber, dbo.Person.Pers_CreatedBy, dbo.Person.Pers_CreatedDate, ' +
'dbo.Person.Pers_UpdatedBy, dbo.Person.Pers_UpdatedDate, dbo.Person.Pers_TimeStamp, dbo.Person.Pers_Deleted, dbo.Person.Pers_LibraryDir, ' +
'dbo.Person.Pers_SegmentID, dbo.Person.Pers_ChannelID, dbo.Person.Pers_UploadDate, dbo.Person.pers_SecTerr, dbo.Person.Pers_WorkflowId, ' +
'dbo.Person.pers_PRYearBorn, dbo.Person.pers_PRDeathDate, dbo.Person.pers_PRLanguageSpoken, dbo.Person.pers_PRPaternalLastName, ' +
'dbo.Person.pers_PRMaternalLastName, dbo.Person.pers_PRNickname1, dbo.Person.pers_PRNickname2, dbo.Person.pers_PRMaidenName, ' +
'dbo.Person.pers_PRIndustryStartDate, dbo.Person.pers_PRNotes, dbo.Person.pers_PRDefaultEmailId,  ' +
'dbo.Company.Comp_CompanyId, dbo.Company.Comp_PrimaryPersonId, dbo.Company.Comp_PrimaryAddressId, dbo.Company.Comp_PrimaryUserId, ' +
'dbo.Company.Comp_Name AS CompanyName, dbo.Company.Comp_Type, dbo.Company.Comp_Status, dbo.Company.Comp_Source, ' +
'dbo.Company.Comp_Territory, dbo.Company.Comp_Revenue, dbo.Company.Comp_Employees, dbo.Company.Comp_Sector, ' +
'dbo.Company.Comp_IndCode, dbo.Company.Comp_WebSite, dbo.Company.Comp_MailRestriction, dbo.Company.Comp_PhoneCountryCode, ' +
'dbo.Company.Comp_PhoneAreaCode, dbo.Company.Comp_PhoneNumber, dbo.Company.Comp_FaxCountryCode, dbo.Company.Comp_FaxAreaCode, ' +
'dbo.Company.Comp_FaxNumber, dbo.Company.Comp_EmailAddress, dbo.Company.Comp_CreatedBy, dbo.Company.Comp_CreatedDate, ' +
'dbo.Company.Comp_UpdatedBy, dbo.Company.Comp_UpdatedDate, dbo.Company.Comp_TimeStamp, dbo.Company.Comp_Deleted, ' +
'dbo.Company.Comp_LibraryDir, dbo.Company.Comp_SegmentID, dbo.Company.Comp_ChannelID, dbo.Company.Comp_SecTerr, ' +
'dbo.Company.Comp_WorkflowId, dbo.Company.Comp_UploadDate, dbo.Company.comp_SLAId, dbo.Company.comp_PRHQId, ' +
'dbo.Company.comp_PRCorrTradestyle, dbo.Company.comp_PRBookTradestyle, dbo.Company.comp_PRSubordinationAgrProvided, ' +
'dbo.Company.comp_PRSubordinationAgrDate, dbo.Company.comp_PRRequestFinancials, dbo.Company.comp_PRSpecialInstruction, ' +
'dbo.Company.comp_PRDataQualityTier, dbo.Company.comp_PRListingCityId, dbo.Company.comp_PRListingStatus, ' +
'dbo.Company.comp_PRAccountTier, dbo.Company.comp_PRBusinessStatus, dbo.Company.comp_PRDaysPastDue, ' +
'dbo.Company.comp_PRSuspendedService, dbo.Company.comp_PRTradestyle1, dbo.Company.comp_PRTradestyle2, ' +
'dbo.Company.comp_PRTradestyle3, dbo.Company.comp_PRTradestyle4, dbo.Company.comp_PRLegalName, dbo.Company.comp_PROriginalName, ' +
'dbo.Company.comp_PROldName1, dbo.Company.comp_PROldName1Date, dbo.Company.comp_PROldName2, dbo.Company.comp_PROldName2Date, ' +
'dbo.Company.comp_PROldName3, dbo.Company.comp_PROldName3Date, dbo.Company.comp_PRType, dbo.Company.comp_PRUnloadHours, ' +
'dbo.Company.comp_PRPublishUnloadHours, dbo.Company.comp_PRMoralResponsibility, dbo.Company.comp_PRSpecialHandlingInstruction, ' +
'dbo.Company.comp_PRHandlesInvoicing, dbo.Company.comp_PRReceiveLRL, dbo.Company.comp_PRTMFMAward, ' +
'dbo.Company.comp_PRTMFMAwardDate, dbo.Company.comp_PRTMFMCandidate, dbo.Company.comp_PRTMFMCandidateDate, ' +
'dbo.Company.comp_PRTMFMComments, dbo.Company.comp_PRAdministrativeUsage, dbo.Company.comp_PRListingUserId, ' +
'dbo.Company.comp_PRRatingUserId, dbo.Company.comp_PRCustomerServiceUserId, dbo.Company.comp_PRMarketingUserId, ' +
'dbo.Company.comp_PRFieldRepUserId, dbo.Company.comp_PRInvestigationMethodGroup, dbo.Company.comp_PRReceiveTES, ' +
'dbo.Company.comp_PRTESNonresponder, dbo.Company.comp_PRCreditWorthCap, dbo.Company.comp_PRCreditWorthCapReason, ' +
'dbo.Company.comp_PRConfidentialFS, dbo.Company.comp_PRJeopardyDate, dbo.Company.comp_PRSpotlight, dbo.Company.comp_PRLogo, ' +
'dbo.Company.comp_PRUnattributedOwnerPct, dbo.Company.comp_PRUnattributedOwnerDesc, dbo.Company.comp_PRConnectionListDate, ' +
'dbo.Company.comp_PRFinancialStatementDate, dbo.Company.comp_PRBusinessReport, dbo.Company.comp_PRPrincipalsBackgroundText, ' +
'dbo.Company.comp_PRMethodSourceReceived, dbo.Company.comp_PRIndustryType, dbo.Company.comp_PRCommunicationLanguage, ' +
'dbo.Company.comp_PRTradestyleFlag, dbo.Company.comp_PRPublishDL, dbo.Company.comp_DLBillFlag, dbo.Company.comp_PRDLDaysPastDue, ' +
'dbo.Company.comp_PRWebActivated, dbo.Company.comp_PRWebActivatedDate, dbo.Company.comp_PRReceivesBBScoreReport, ' +
'dbo.Company.comp_PRServicesThroughCompanyId, dbo.Company.comp_PRLastVisitDate, dbo.Company.comp_PRLastVisitedBy, ' +
'dbo.ufn_GetCompanyFullName(comp_CompanyId) AS Comp_Name, dbo.Users.User_UserId, dbo.Users.User_PrimaryChannelId, ' +
'dbo.Users.User_Logon, dbo.Users.User_LastName, dbo.Users.User_FirstName, dbo.Users.User_Language, dbo.Users.User_Department, ' +
'dbo.Users.User_Phone, dbo.Users.User_Extension, dbo.Users.User_Pager, dbo.Users.User_Homephone, dbo.Users.User_MobilePhone, ' +
'dbo.Users.User_Fax, dbo.Users.User_EmailAddress, dbo.Users.User_LastLogin, dbo.Users.User_User1, dbo.Users.User_Password ' +
'FROM         dbo.Company LEFT OUTER JOIN ' +
'dbo.vAddress ON dbo.Company.Comp_PrimaryAddressId = dbo.vAddress.Addr_AddressId LEFT OUTER JOIN ' +
'dbo.Person ON dbo.Company.Comp_PrimaryPersonId = dbo.Person.Pers_PersonId AND dbo.Person.Pers_Deleted IS NULL LEFT OUTER JOIN ' +
'dbo.Users ON dbo.Company.Comp_PrimaryUserId = dbo.Users.User_UserId ' +
'WHERE     (dbo.Company.Comp_Deleted IS NULL) '
exec usp_AccpacCreateView 'PRView', NULL, 'vSummaryCompany', @Script 


--
--  Overriding an Accpac native view.  Also had to dump several
--  user field references to trim down the SQL size to fit into
--  the @Script variable.  They don't appear to be used anywhere.
--
-- This view returns dbo.ufn_FormatName as comp_Name in order to get a differet
-- value to appear in the Recent List  fields.
--
SET @Script = 'CREATE VIEW dbo.vSummaryPerson AS ' +
'SELECT dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix, 1) AS Pers_FullName,  ' +
'ISNULL(dbo.Users.User_FirstName, '' '') + '' '' + ISNULL(dbo.Users.User_LastName, '' '') AS User_Name, RTRIM(ISNULL(dbo.vAddress.Addr_Address1, '' ''))  ' +
'+ ''~'' + RTRIM(ISNULL(dbo.vAddress.Addr_Address2, '' '')) + ''~'' + RTRIM(ISNULL(dbo.vAddress.Addr_Address3, '' ''))  ' +
'+ ''~'' + RTRIM(ISNULL(dbo.vAddress.Addr_Address4, '' '')) + ''~'' + RTRIM(ISNULL(dbo.vAddress.Addr_Address5, '' '')) AS Addresses,  ' +
'dbo.vAddress.Addr_Street, dbo.vAddress.Addr_AddressId, dbo.vAddress.Addr_Address1, dbo.vAddress.Addr_Address2, dbo.vAddress.Addr_Address3,  ' +
'dbo.vAddress.Addr_Address4, dbo.vAddress.Addr_Address5, dbo.vAddress.Addr_City, dbo.vAddress.Addr_State, dbo.vAddress.Addr_Country,  ' +
'vAddress.Addr_PostCode, dbo.vAddress.Addr_CreatedBy, dbo.vAddress.Addr_CreatedDate, dbo.vAddress.Addr_UpdatedBy,  ' +
'vAddress.Addr_UpdatedDate, dbo.vAddress.Addr_TimeStamp, dbo.vAddress.Addr_Deleted, dbo.vAddress.Addr_SegmentID,  ' +
'vAddress.Addr_ChannelID, dbo.vAddress.addr_uszipplusfour, dbo.vAddress.addr_PRCityId, dbo.vAddress.addr_PRCounty, ' + 
'vAddress.addr_PRZone, dbo.vAddress.addr_PRPublish, dbo.vAddress.addr_PRDescription, ' +
'vAddress.addr_PRReplicatedFromId, dbo.vAddress.addr_PRAttentionLineType, dbo.vAddress.addr_PRAttentionLineCustom, ' + 
'vAddress.addr_PRAttentionLinePersonId, dbo.Users.User_UserId, ' + 
'Users.User_PrimaryChannelId, dbo.Users.User_Logon, dbo.Users.User_LastName, dbo.Users.User_FirstName, dbo.Users.User_Language, ' + 
'Users.User_Department, dbo.Users.User_Phone, dbo.Users.User_Extension, dbo.Users.User_Pager, dbo.Users.User_Homephone, ' + 
'Person.Pers_PersonId, dbo.Person.Pers_CompanyId, dbo.Person.Pers_PrimaryAddressId, dbo.Person.Pers_PrimaryUserId, ' + 
'Person.Pers_Salutation, dbo.Person.Pers_FirstName, dbo.Person.Pers_LastName, dbo.Person.Pers_MiddleName, dbo.Person.Pers_Suffix, ' +
'Person.Pers_Gender, dbo.Person.Pers_Title, dbo.Person.Pers_TitleCode, dbo.Person.Pers_Department, dbo.Person.Pers_Status,  ' +
'Person.Pers_Source, dbo.Person.Pers_Territory, dbo.Person.Pers_WebSite, dbo.Person.Pers_MailRestriction,  ' +
'Person.Pers_PhoneCountryCode, dbo.Person.Pers_PhoneAreaCode, dbo.Person.Pers_PhoneNumber, dbo.Person.Pers_EmailAddress, ' + 
'Person.Pers_FaxCountryCode, dbo.Person.Pers_FaxAreaCode, dbo.Person.Pers_FaxNumber, dbo.Person.Pers_CreatedBy, ' + 
'Person.Pers_CreatedDate, dbo.Person.Pers_UpdatedBy, dbo.Person.Pers_UpdatedDate, dbo.Person.Pers_TimeStamp, dbo.Person.Pers_Deleted, ' + 
'Person.Pers_LibraryDir, dbo.Person.Pers_SegmentID, dbo.Person.Pers_ChannelID, dbo.Person.Pers_UploadDate, dbo.Person.pers_SecTerr,  ' +
'Person.Pers_WorkflowId, dbo.Person.pers_PRYearBorn, dbo.Person.pers_PRDeathDate, dbo.Person.pers_PRLanguageSpoken, ' + 
'Person.pers_PRPaternalLastName, dbo.Person.pers_PRMaternalLastName, dbo.Person.pers_PRNickname1, dbo.Person.pers_PRNickname2, ' + 
'Person.pers_PRMaidenName, dbo.Person.pers_PRIndustryStartDate, dbo.Person.pers_PRNotes, dbo.Person.pers_PRDefaultEmailId, ' + 
'dbo.Company.Comp_CompanyId, dbo.Company.Comp_PrimaryPersonId, dbo.Company.Comp_PrimaryAddressId, ' + 
'Company.Comp_PrimaryUserId, dbo.Company.Comp_Name, dbo.Company.Comp_Type, dbo.Company.Comp_Status, dbo.Company.Comp_Source, ' + 
'Company.Comp_Territory, dbo.Company.Comp_Revenue, dbo.Company.Comp_Employees, dbo.Company.Comp_Sector,  ' +
'Company.Comp_IndCode, dbo.Company.Comp_WebSite, dbo.Company.Comp_MailRestriction, dbo.Company.Comp_PhoneCountryCode,  ' +
'Company.Comp_PhoneAreaCode, dbo.Company.Comp_PhoneNumber, dbo.Company.Comp_FaxCountryCode, dbo.Company.Comp_FaxAreaCode, ' + 
'Company.Comp_FaxNumber, dbo.Company.Comp_EmailAddress, dbo.Company.Comp_CreatedBy, dbo.Company.Comp_CreatedDate, ' + 
'Company.Comp_UpdatedBy, dbo.Company.Comp_UpdatedDate, dbo.Company.Comp_TimeStamp, dbo.Company.Comp_Deleted, ' + 
'Company.Comp_LibraryDir, dbo.Company.Comp_SegmentID, dbo.Company.Comp_ChannelID, dbo.Company.Comp_SecTerr, ' + 
'Company.Comp_WorkflowId, dbo.Company.Comp_UploadDate, dbo.Company.comp_SLAId, dbo.Company.comp_PRHQId,  ' +
'Company.comp_PRCorrTradestyle, dbo.Company.comp_PRBookTradestyle, dbo.Company.comp_PRSubordinationAgrProvided,  ' +
'Company.comp_PRSubordinationAgrDate, dbo.Company.comp_PRRequestFinancials, dbo.Company.comp_PRSpecialInstruction, ' + 
'Company.comp_PRDataQualityTier, dbo.Company.comp_PRListingCityId, dbo.Company.comp_PRListingStatus, ' + 
'Company.comp_PRAccountTier, dbo.Company.comp_PRBusinessStatus, dbo.Company.comp_PRDaysPastDue,  ' +
'Company.comp_PRSuspendedService, dbo.Company.comp_PRTradestyle1, dbo.Company.comp_PRTradestyle2, ' + 
'Company.comp_PRTradestyle3, dbo.Company.comp_PRTradestyle4, dbo.Company.comp_PRLegalName, dbo.Company.comp_PROriginalName, ' + 
'Company.comp_PROldName1, dbo.Company.comp_PROldName1Date, dbo.Company.comp_PROldName2, dbo.Company.comp_PROldName2Date, ' + 
'Company.comp_PROldName3, dbo.Company.comp_PROldName3Date, dbo.Company.comp_PRType, dbo.Company.comp_PRUnloadHours, ' + 
'Company.comp_PRPublishUnloadHours, dbo.Company.comp_PRMoralResponsibility, dbo.Company.comp_PRSpecialHandlingInstruction, ' + 
'Company.comp_PRHandlesInvoicing, dbo.Company.comp_PRReceiveLRL, dbo.Company.comp_PRTMFMAward,  ' +
'Company.comp_PRTMFMAwardDate, dbo.Company.comp_PRTMFMCandidate, dbo.Company.comp_PRTMFMCandidateDate, ' + 
'Company.comp_PRTMFMComments, dbo.Company.comp_PRAdministrativeUsage, dbo.Company.comp_PRListingUserId,  ' +
'Company.comp_PRRatingUserId, dbo.Company.comp_PRCustomerServiceUserId, dbo.Company.comp_PRMarketingUserId, ' + 
'Company.comp_PRFieldRepUserId, dbo.Company.comp_PRInvestigationMethodGroup, dbo.Company.comp_PRReceiveTES, ' + 
'Company.comp_PRTESNonresponder, dbo.Company.comp_PRCreditWorthCap, dbo.Company.comp_PRCreditWorthCapReason,  ' +
'Company.comp_PRConfidentialFS, dbo.Company.comp_PRJeopardyDate, dbo.Company.comp_PRSpotlight, dbo.Company.comp_PRLogo, ' + 
'Company.comp_PRUnattributedOwnerPct, dbo.Company.comp_PRUnattributedOwnerDesc, dbo.Company.comp_PRConnectionListDate, ' + 
'Company.comp_PRFinancialStatementDate, dbo.Company.comp_PRBusinessReport, dbo.Company.comp_PRPrincipalsBackgroundText, ' + 
'Company.comp_PRMethodSourceReceived, dbo.Company.comp_PRIndustryType, dbo.Company.comp_PRCommunicationLanguage,  ' +
'Company.comp_PRTradestyleFlag, dbo.Company.comp_PRPublishDL, dbo.Company.comp_DLBillFlag, dbo.Company.comp_PRDLDaysPastDue, ' + 
'Company.comp_PRWebActivated, dbo.Company.comp_PRWebActivatedDate, dbo.Company.comp_PRReceivesBBScoreReport,  ' +
'Company.comp_PRServicesThroughCompanyId, dbo.Company.comp_PRLastVisitDate, dbo.Company.comp_PRLastVisitedBy ' + 
' ' +
'FROM         dbo.Person LEFT OUTER JOIN ' +
'vAddress ON dbo.Person.Pers_PrimaryAddressId = dbo.vAddress.Addr_AddressId LEFT OUTER JOIN ' +
'Company ON dbo.Person.Pers_CompanyId = dbo.Company.Comp_CompanyId LEFT OUTER JOIN ' +
'Users ON dbo.Person.Pers_PrimaryUserId = dbo.Users.User_UserId ' +
'WHERE     (dbo.Person.Pers_Deleted IS NULL)'
exec usp_AccpacCreateView 'PRView', NULL, 'vSummaryPerson', @Script 



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
            AND comp_PRListingStatus in ('L','H','N1','N2') 
LEFT OUTER JOIN 
  (
    select prte_ResponderCompanyId, request_count = count(1) from PRTESDetail 
    JOIN PRTES ON prt2_TESId = prte_TESId
          AND prte_Date >= DateAdd(Day, -90, getDate())
    Group By prte_ResponderCompanyId
  ) TESRequests ON prte_ResponderCompanyId = RelatedCompanyId 

WHERE (request_count is null or request_count < 50)
  AND Not Exists (Select 1 from PRARAging 
                          where praa_CompanyId = RelatedCompanyId 
                            AND praa_Date >= DateAdd(Day, -90, getDate()) )
  AND Not Exists (select 1 from PRTES
                  JOIN PRTESDetail ON prte_TESId = prt2_TESId 
                  WHERE prt2_SubjectCompanyId = SubjectCompanyId
					AND prte_date >= DateAdd(Day, -27, getDate()) )
  AND Not Exists (Select 1 from PRTradeReport 
                          where prtr_ResponderId = RelatedCompanyId 
                            AND prtr_SubjectId = SubjectCompanyId
                            AND prtr_Date >= DateAdd(Day, -45, getDate())
                 )
GO

	exec usp_RefreshAllViews
go

-- ********************* END CUSTOM VIEW CREATION *****************************
