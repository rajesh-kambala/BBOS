/***********************************************************************
***********************************************************************
 Copyright Produce Report Co. 2006-2009

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
If Exists (Select name from sysobjects where name = 'usp_PopulateRating' and type='P') Drop Procedure dbo.usp_PopulateRating
Go

/**
Populates the Rating table from PIKS
**/
CREATE PROCEDURE dbo.usp_PopulateRating
as 

Declare @Start datetime
SET @Start = GETDATE()

PRINT 'Deleting From Rating Table'
DELETE FROM Rating;

-- 81 is a Rating Numeral in BBS, but a Pay Rating in PIKS.  To facilitate this
-- translation, we added a BBSInterface specific 81 flag. It is used in a subsequent
-- query below.

PRINT 'Populating Rating Data'
INSERT INTO Rating (
       BBID,
       MORALID,
       PAYID,
       WORTHID,
       RTGNUMS,
       AFLNUMS,
       RATING,
       [81Flag])
SELECT prra_CompanyID, -- BBID
       ISNULL(prra_IntegrityId, 0),
       CASE prra_PayRatingID
	        WHEN '1' THEN 0
	        WHEN '2' THEN 8
	        WHEN '3' THEN 7
	        WHEN '4' THEN 6
	        WHEN '5' THEN 5
	        WHEN '6' THEN 4
	        WHEN '7' THEN 3
	        WHEN '8' THEN 2
	        WHEN '9' THEN 1
            ELSE 0
            END, -- MORALID
       CASE prra_CreditWorthId
            WHEN '1' THEN 1
            WHEN '2' THEN 2
            WHEN '3' THEN 3
            WHEN '4' THEN 4
	        WHEN '5' THEN 4.5
	        WHEN '6' THEN 5
	        WHEN '7' THEN 6
	        WHEN '8' THEN 6.5
	        WHEN '9' THEN 7
            WHEN '10' THEN 8
            WHEN '11' THEN 9
            WHEN '12' THEN 10
            WHEN '13' THEN 11
            WHEN '14' THEN 12
            WHEN '15' THEN 13
            WHEN '16' THEN 14
            WHEN '17' THEN 15
            WHEN '18' THEN 16
            WHEN '19' THEN 17
            WHEN '20' THEN 18
            WHEN '21' THEN 19
            WHEN '22' THEN 20
            WHEN '23' THEN 21
            WHEN '24' THEN 22
            WHEN '25' THEN 23
            WHEN '26' THEN 24
            WHEN '27' THEN 25
            WHEN '28' THEN 26
            WHEN '29' THEN 27
            WHEN '30' THEN 28
            WHEN '31' THEN 29
            WHEN '32' THEN 29.25
            WHEN '33' THEN 29.5
            WHEN '34' THEN 30
            WHEN '35' THEN 32
            WHEN '36' THEN 32
            WHEN '37' THEN 33
            WHEN '38' THEN 34
            WHEN '39' THEN 35
            WHEN '40' THEN 35.5
			WHEN '41' THEN 35.75
            WHEN '42' THEN 36
            ELSE 0
            END, -- PAYID
       dbo.ufn_GetRTGNums(prra_RatingId), -- WORTHID
       dbo.ufn_GetAFLNums(prra_RatingId), -- RTGNUMS
       CASE WHEN LEN(prra_RatingLine) = 0 THEN NULL ELSE prra_RatingLine END, -- AFLNUMS
       CASE prra_PayRatingID WHEN '1' THEN 1 END -- RATING
  FROM CRM.dbo.vPRCompanyRating
       INNER JOIN CRM.dbo.Company WITH (NOLOCK) on prra_CompanyID = comp_CompanyID
 WHERE prra_Current = 'Y'
   AND comp_PRIndustryType <> 'L'
   AND prra_Deleted IS NULL
   AND prra_CompanyID IN (SELECT BBID FROM CompanyFilter)
ORDER BY prra_CompanyID;

UPDATE Rating 
   SET RTGNUMS = NULL
 WHERE LEN(RTGNUMS) = 0;

-- 81 is a Rating Numeral in BBS, but a Pay Rating in PIKS.  This sets the
-- BBS data appropriately.
UPDATE RATING
   SET AFLNUMS = AFLNUMS + '(81)'
 WHERE [81Flag] = 1;


PRINT 'Execution time (milliseconds): ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE()))
Go


If Exists (Select name from sysobjects where name = 'ufn_GetAFLNums' and type='FN') Drop Function dbo.ufn_GetAFLNums
Go

/*
 *  Returns a list of non-Affilate rating numerals
 */
CREATE FUNCTION dbo.ufn_GetAFLNums(@ratingid int)  
RETURNS varchar(1024)
AS
BEGIN

  DECLARE @RetValue varchar(1024)

   SELECT @RetValue = Coalesce(@RetValue, '') + prrn_name
     FROM CRM.dbo.PRRatingNumeralAssigned WITH (NOLOCK)
          JOIN CRM.dbo.PRRatingNumeral WITH (NOLOCK) ON pran_RatingNumeralId = prrn_RatingNumeralId
    WHERE pran_ratingid = @ratingid
      AND prrn_type = 'A'
 ORDER BY prrn_Order


  RETURN @RetValue
END
Go


If Exists (Select name from sysobjects where name = 'ufn_GetRTGNums' and type='FN') Drop Function dbo.ufn_GetRTGNums
Go

/*
 *  Returns a list of non-Affilate rating numerals
 */
CREATE FUNCTION dbo.ufn_GetRTGNums(@ratingid int)  
RETURNS varchar(1024)
AS
BEGIN

  DECLARE @RetValue varchar(1024)

   SELECT @RetValue = Coalesce(@RetValue, '') + prrn_name
     FROM CRM.dbo.PRRatingNumeralAssigned WITH (NOLOCK)
          JOIN CRM.dbo.PRRatingNumeral WITH (NOLOCK) ON pran_RatingNumeralId = prrn_RatingNumeralId
    WHERE pran_ratingid = @ratingid
      AND prrn_type <> 'A'
 ORDER BY prrn_Order


  RETURN @RetValue
END

