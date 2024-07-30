use BBSInterface
/***********************************************************************
***********************************************************************
 Copyright Produce Report Co. 2006-2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Report Co. is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Report Co.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 Notes:	

***********************************************************************
***********************************************************************/
If Exists (Select name from sysobjects where name = 'usp_PopulateAddress' and type='P') Drop Procedure dbo.usp_PopulateAddress
Go

/**
Populates the Address table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateAddress
as 

Declare @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From Address Table'
DELETE FROM Address;

PRINT 'Populating Address Data'
INSERT INTO Address (
       BBID,
       ADDRSEQ,
       DEFSHIP,
       DEFMAIL,
       DEFATTN,
       STREETADDR,
       CITY,
       STATEABBREV,
       COUNTRY,
       POSTALCODE,
       ADDRTYPE,
       LIST,
       LISTSEQ,
       COUNTY,
       TAXADDR,
       BILLADDR,
       LISTADDR)
SELECT comp_CompanyID, -- BBID
       adli_PRSlot, -- ADDRSEQ 
       NULL, --CASE WHEN adli_PRDefaultShipping = 'Y' THEN 'X' ELSE adli_PRDefaultShipping END, -- DEFSHIP
	   CASE WHEN adli_PRDefaultMailing = 'Y' THEN 'X' ELSE adli_PRDefaultMailing END, -- DEFMAIL
       NULL, --CRM.dbo.ufn_GetAddressAttentionLine(addr_AddressID), -- DEFATTN
       CASE WHEN Addr_Address1 IS NULL THEN '' ELSE RTRIM(Addr_Address1) END 
          + CASE WHEN Addr_Address2 IS NULL THEN '' ELSE CHAR(10) + RTRIM(Addr_Address2) END
          + CASE WHEN Addr_Address3 IS NULL THEN '' ELSE CHAR(10) + RTRIM(Addr_Address3) END
          + CASE WHEN Addr_Address4 IS NULL THEN '' ELSE CHAR(10) + RTRIM(Addr_Address4) END
          + CASE WHEN Addr_Address5 IS NULL THEN '' ELSE CHAR(10) + RTRIM(Addr_Address5) END, -- STREETADDR
       CASE WHEN prcn_CountryID=3 THEN CASE WHEN LEN(prci_City + ', ' + prst_Abbreviation) <=34 THEN prci_City + ', ' + prst_Abbreviation ELSE prci_City END ELSE prci_City END, -- CITY
	   CASE prcn_CountryID WHEN  1 THEN RTRIM(prst_Abbreviation) WHEN 2 THEN RTRIM(prst_Abbreviation) END, -- STATEABBREV
	   dbo.ufn_GetCountry(prcn_CountryID, prcn_Country), -- COUNTRY
       RTRIM(Addr_PostCode), -- POSTALCODE
       RTRIM(UPPER(SUBSTRING(RTRIM(cast(Capt_US as varchar)), 1, 9))), -- ADDRTYPE
       ISNULL(addr_PRPublish, 'N'),  -- LIST
       CRM.dbo.ufn_GetAddressListSeq(AdLi_Type), -- LISTSEQ
       RTRIM(UPPER(Addr_PRCounty)), -- COUNTY
       CASE WHEN adli_PRDefaultTax = 'Y' THEN 'X' ELSE adli_PRDefaultTax END,  -- TAXADDR
       CASE WHEN prattn_AddressID is not null THEN 'X' ELSE NULL END, -- BILLADDR
	   NULL --CASE WHEN adli_PRDefaultListing = 'Y' THEN 'X' ELSE adli_PRDefaultListing END -- LISTADDR
  FROM CRM.dbo.PRState WITH (NOLOCK) INNER JOIN
       CRM.dbo.PRCity WITH (NOLOCK) ON prst_StateId = prci_StateId INNER JOIN
       CRM.dbo.PRCountry WITH (NOLOCK) ON prst_CountryId = prcn_CountryId RIGHT OUTER JOIN
       CRM.dbo.Address_Link WITH (NOLOCK) INNER JOIN
	   CRM.dbo.Custom_Captions WITH (NOLOCK) ON AdLi_Type = Capt_Code AND Capt_Family = 'adli_TypeCompany' INNER JOIN
       CRM.dbo.Company WITH (NOLOCK) ON AdLi_CompanyID = Comp_CompanyId INNER JOIN
       CRM.dbo.Address WITH (NOLOCK) ON AdLi_AddressId = Addr_AddressId ON prci_CityId = addr_PRCityId LEFT OUTER JOIN
	   CRM.dbo.PRAttentionLine WITH (NOLOCK) ON addr_AddressID = prattn_AddressID
		AND prattn_ItemCode = 'BILL' 
 WHERE addr_Deleted IS NULL
   AND adli_Deleted IS NULL
   AND comp_Deleted IS NULL
   AND comp_CompanyID IN (SELECT BBID FROM CompanyFilter);

PRINT 'usp_PopulateAddress Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))

Go



If Exists (Select name from sysobjects where name = 'ufn_GetCountry' and type='FN') Drop Function dbo.ufn_GetCountry
Go

CREATE FUNCTION dbo.ufn_GetCountry(@prcn_CountryID int, @prcn_Country varchar(50))  
RETURNS varchar(50) AS  
BEGIN 

	DECLARE @Country varchar(50)
	SELECT @Country = CASE @prcn_CountryID 
            WHEN 1 THEN '  ' + RTRIM(@prcn_Country) 
            WHEN 2 THEN ' ' + RTRIM(@prcn_Country) 
            ELSE RTRIM(@prcn_Country) END
-- Removed these two lines from the case above to move Mexico and Puerto Rico to International
--            WHEN 3 THEN ' ' + RTRIM(@prcn_Country)  
--            WHEN 4 THEN ' ' + RTRIM(@prcn_Country)  


	RETURN @Country
END


