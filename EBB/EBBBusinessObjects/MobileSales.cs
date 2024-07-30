/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: MobileSales.cs
 Description:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web;
using TSI.DataAccess;

namespace PRCo.EBB.BusinessObjects
{
    public class MobileSales
    {
        static public IDataReader HeaderContent(string szCompanyID)
        {
            // 3  = Industry
            // 4  = Listing Status
            // 5  = Current Rating
            // 6  = Current M Level
            // 6a = Member Since
            // 7  = Trip Code
            // 8 = TM/FM Award
            // 9 = Business Start Date

            string SQL = @"
				DECLARE @Header TABLE (Sect1 NVARCHAR(MAX), Sect2 NVARCHAR(MAX), Sect3 NVARCHAR(MAX), Sect4 NVARCHAR(MAX), Sect5 NVARCHAR(MAX), Sect6 NVARCHAR(MAX), Sect6a NVARCHAR(MAX), Sect7 NVARCHAR(MAX), Sect8 NVARCHAR(MAX), Sect9 NVARCHAR(MAX) );
				DECLARE @Sect1 nvarchar(MAX), @Sect2 nvarchar(MAX), @Sect3 nvarchar(MAX), @Sect4 nvarchar(MAX), @Sect5 nvarchar(MAX), @Sect6 nvarchar(MAX), @Sect6a nvarchar(MAX), @Sect7 nvarchar(MAX), @Sect8 nvarchar(MAX), @Sect9 nvarchar(MAX);

				DECLARE @MemLevel NVARCHAR(100)
				SELECT @MemLevel = dbo.ufn_GetPrimaryService(@CompanyID)

				SELECT @Sect1 = prcse_FullName
					FROM PRCompanySearch WITH (NOLOCK)
					WHERE prcse_CompanyId = @CompanyID;

				SELECT @Sect2 = CASE WHEN comp_PRListingStatus NOT IN ('L','H') THEN 'Listing Prospect'
							WHEN @MemLevel IS NULL THEN 'Membership Prospect'
							WHEN comp_PRIndustryType = 'S' THEN 'Ad Prospect'
							WHEN prpy_Name IS NULL AND prin_Name IN ('XXX','XXXX') THEN 'Ad Prospect'
							WHEN prpy_Name IN ('AA','A','B', 'C') AND prin_Name IN ('XXX','XXXX') THEN 'Ad Prospect'
							ELSE 'Upgrade Prospect' END	
					FROM Company WITH (NOLOCK)
					LEFT OUTER JOIN vPRCurrentRating WITH (NOLOCK) ON prra_CompanyId = comp_CompanyID
					WHERE comp_CompanyID = @CompanyID	

				SELECT @Sect3 = CONVERT(NVARCHAR(100),Capt_US)
					FROM Company WITH (NOLOCK)
					INNER JOIN Custom_Captions ind WITH (NOLOCK) ON ind.Capt_Family = 'Comp_PRIndustryType'
						AND ind.Capt_Code = comp_PRIndustryType
					WHERE comp_CompanyID = @CompanyID

				SELECT @Sect4 = CASE comp_PRListingStatus
									WHEN 'L' THEN 'Listed'
									WHEN 'H' THEN 'Listed'
									WHEN 'LUV' THEN 'LVP'
									WHEN 'N1' THEN 'Service Only'
									ELSE 'Unlisted' END
					FROM Company WITH (NOLOCK)
					INNER JOIN Custom_Captions ind WITH (NOLOCK) ON ind.Capt_Family = 'Comp_PRIndustryType'
						AND ind.Capt_Code = comp_PRIndustryType
					WHERE comp_CompanyID = @CompanyID

				SELECT @Sect5 =	CASE WHEN ISNULL(prra_RatingLine,'') = '' THEN 'Unrated' ELSE prra_RatingLine + ' (' + LTRIM(STR(MONTH(prra_Date))) + '/' + LTRIM(STR(DAY(prra_Date))) + '/' + STR(YEAR(prra_Date), 4) + ')' END
					FROM Company WITH (NOLOCK)
					LEFT OUTER JOIN vPRCurrentRating WITH (NOLOCK) ON prra_CompanyId = comp_CompanyID
					WHERE comp_CompanyID = @CompanyID

				SELECT @Sect8 =	
						CASE comp_PRTMFMAward WHEN 'Y' THEN CAST(YEAR(comp_PRTMFMAwardDate) as varchar(4)) ELSE '' END
					FROM Company WITH (NOLOCK)
					LEFT OUTER JOIN vPRCurrentRating WITH (NOLOCK) ON prra_CompanyId = comp_CompanyID
					WHERE comp_CompanyID = @CompanyID

				DECLARE @CurrentMLevelStartDate datetime
				SELECT @CurrentMLevelStartDate = prse_CreatedDate FROM PRService WHERE prse_Primary='Y' AND prse_CompanyID=@CompanyID
				DECLARE @MLevelSince varchar(100) = ''
				IF @CurrentMLevelStartDate IS NOT NULL BEGIN SET @MLevelSince = ' Since ' + CAST(YEAR(@CurrentMLevelStartDate) AS varchar(100)) END 
				SELECT @Sect6 = ISNULL(@MemLevel,'Non Member') + @MLevelSince
					FROM Company WITH (NOLOCK)
					LEFT OUTER JOIN vPRCurrentRating WITH (NOLOCK) ON prra_CompanyId = comp_CompanyID
					WHERE comp_CompanyID = @CompanyID

				SELECT @Sect6a = CASE WHEN @MemLevel IS NOT NULL THEN CAST(YEAR(comp_PROriginalServiceStartDate) as varchar(4)) ELSE '' END
					FROM Company WITH (NOLOCK)
					LEFT OUTER JOIN vPRCurrentRating WITH (NOLOCK) ON prra_CompanyId = comp_CompanyID
					WHERE comp_CompanyID = @CompanyID

				DECLARE @BusinessStartDate varchar(20)
				DECLARE @BusinessStartState varchar(20)

				DECLARE @StartDateTable TABLE (BusinessStartDate varchar(100), BusinessStartState varchar(100), prbe_EffectiveDate datetime, Priority int)
				INSERT INTO @StartDateTable
					SELECT TOP 1 
								--prbe_CompanyID, 
								--prbe_BusinessEventTypeId, 
								prbe_DisplayedEffectiveDate AS BusinessStartDate,
								prst_State AS BusinessStartState,
								MIN(prbe_EffectiveDate) prbe_EffectiveDate,
								[Priority]= CASE WHEN prbe_BusinessEventTypeId=9 THEN 1 
												WHEN prbe_BusinessEventTypeId=42 THEN 2 
												WHEN prbe_BusinessEventTypeId=8 THEN 3
											END
							FROM PRBusinessEvent WITH(NOLOCK)
								LEFT OUTER JOIN PRState WITH (NOLOCK) ON prbe_StateID = prst_StateID
							WHERE prbe_BusinessEventTypeId IN (9, 42, 8)
								AND prbe_CompanyId=@CompanyID
							GROUP BY prbe_CompanyID, prbe_BusinessEventTypeId, prbe_EffectiveDate, prbe_DisplayedEffectiveDate, prst_State, prbe_DetailedType
							ORDER BY prbe_CompanyID, Priority ASC, prbe_EffectiveDate ASC

				SELECT	@BusinessStartDate = BusinessStartDate,
						@BusinessStartState = ISNULL(BusinessStartState, '')
				FROM @StartDateTable

				SELECT @Sect7 = prci_SalesTerritory
					FROM Company WITH (NOLOCK)
					INNER JOIN vPRLocation WITH (NOLOCK) ON prci_CityID = comp_PRListingCityID
					WHERE comp_CompanyID = @CompanyID

				SELECT @Sect9 = CASE WHEN @BusinessStartDate IS NOT NULL THEN @BusinessStartDate + ' ' + @BusinessStartState ELSE '' END
				INSERT INTO @Header SELECT @Sect1, @Sect2, @Sect3, @Sect4, @Sect5, @Sect6, @Sect6a, @Sect7, @Sect8, @Sect9
				SELECT * FROM @Header";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader HeaderContentBasic(string szCompanyID)
        {
            string SQL = @"
				SELECT comp_CompanyID, comp_PRBookTradestyle, CityStateCountryShort,
					dbo.ufn_GetCustomCaptionValue('comp_prindustrytype', comp_PRIndustryType, 'en-us') As comp_prindustrytype,
                    dbo.ufn_GetCustomCaptionValue('comp_PRListingStatus', comp_PRListingStatus, 'en-us') As comp_prlistingstatus,
	                comp_prType,
	                comp_PRLocalSource, comp_PRIsIntlTradeAssociation
                FROM vPRBBOSCompanyList
                WHERE
					comp_PRLocalSource IS NULL 
	                AND comp_PRIsIntlTradeAssociation IS NULL
                    AND comp_CompanyID = @CompanyID";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader Phones(string szCompanyID)
        {
            string SQL = @"
				SELECT phon_PRDescription, 'Num' = dbo.ufn_FormatPhone(Phon_CountryCode, Phon_AreaCode, Phon_Number, phon_PRExtension)
				FROM vPRCompanyPhone WITH(NOLOCK)
				WHERE plink_RecordID = @CompanyID
					AND phon_PRPreferredInternal = 'Y'
				Order BY phon_PRSequence";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader Addresses(string szCompanyID)
        {
            string SQL = @"
				SELECT Addr_Address1, Addr_Address2, Addr_Address3, Addr_Address4, Addr_Address5, CityStateCountryShort, Addr_PostCode, 'AddressType' = RTRIM(CONVERT(NVARCHAR(30),Capt_US))
				FROM vPRAddress WITH (NOLOCK)
				INNER JOIN Custom_Captions WITH (NOLOCK) ON Capt_Family = 'adli_TypeCompany'
						AND Capt_Code = AdLi_Type
				WHERE AdLi_CompanyID = @CompanyID";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader RatingFacts(string szCompanyID)
        {
            string SQL = @"
				DECLARE @RatingData TABLE (ndx INT IDENTITY, FactName NVARCHAR(1000), FactValue NVARCHAR(1000))
				INSERT INTO @RatingData(FactName, FactValue)
					SELECT 'Current Rating',CONVERT(NVARCHAR(30),prra_Date,101) + ' - ' + prra_RatingLine
					FROM vPRCurrentRating WITH (NOLOCK) 
					WHERE prra_CompanyId = @CompanyID

				INSERT INTO @RatingData(FactName, FactValue)
					SELECT TOP 1 'Previous Rating',CONVERT(NVARCHAR(30),prra_Date,101) + ' - ' + prra_RatingLine
					FROM vPRCompanyRating WITH (NOLOCK) 
					WHERE prra_CompanyId = @CompanyID
						AND prra_Current IS NULL
					Order BY prra_Date DESC
	
				DECLARE @CurrentScore int
				DECLARE @CurrentScoreDate datetime
				DECLARE @PreviousScore int
				DECLARE @PreviousScoreDate datetime

				SELECT	@CurrentScore=prbs_BBScore,
						@CurrentScoreDate=prbs_Date 
					FROM PRBBScore WITH (NOLOCK)
					LEFT OUTER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prbs_CompanyID
					WHERE prbs_CompanyId = @CompanyID
					AND prbs_PRPublish = 'Y'
					AND comp_PRPublishBBScore='Y' 
					AND prbs_Current = 'Y'
					Order BY prbs_Date DESC

				SELECT	@PreviousScore=prbs_BBScore,
						@PreviousScoreDate=prbs_Date 
				FROM
				(SELECT TOP 1 prbs_Date,prbs_BBScore
					FROM PRBBScore WITH (NOLOCK)
					LEFT OUTER JOIN Company WITH(NOLOCK) ON comp_CompanyID = prbs_CompanyID
					WHERE prbs_CompanyId = @CompanyID
					AND prbs_PRPublish = 'Y'
					AND comp_PRPublishBBScore='Y' 
					AND prbs_Current IS NULL
					Order BY prbs_Date DESC) T1
	
				INSERT INTO @RatingData(FactName, FactValue)
					SELECT 'Current Score',CONVERT(NVARCHAR(30),@CurrentScoreDate,101) + ' - ' + CONVERT(NVARCHAR(30),CONVERT(INT,@CurrentScore)) + ' ' +
					CASE
						WHEN @PreviousScore IS NOT NULL AND @CurrentScore > @PreviousScore THEN '(Increase)'
						WHEN @PreviousScore IS NOT NULL AND @CurrentScore < @PreviousScore THEN '(Decrease)'
						ELSE ''
					END

				IF @PreviousScore IS NOT NULL BEGIN
					INSERT INTO @RatingData(FactName, FactValue)
						SELECT 'Previous Score',CONVERT(NVARCHAR(30),@PreviousScoreDate,101) + ' - ' + CONVERT(NVARCHAR(30),CONVERT(INT,@PreviousScore))
				END

				INSERT INTO @RatingData(FactName, FactValue)
					SELECT 'Financial Date', CONVERT(NVARCHAR(30),comp_PRFinancialStatementDate,101)
					FROM Company WITH (NOLOCK)
					WHERE comp_CompanyID = @CompanyID

				INSERT INTO @RatingData(FactName, FactValue)
					SELECT 'RL Date', CONVERT(NVARCHAR(30),comp_PRConnectionListDate,101)
					FROM Company WITH (NOLOCK)
					WHERE comp_CompanyID = @CompanyID

				INSERT INTO @RatingData (FactName, FactValue)
					SELECT 'RL Size', CASE 
						WHEN COUNT(DISTINCT prcr_RightCompanyID) > 0 
							THEN CONVERT(NVARCHAR(30),COUNT(DISTINCT prcr_RightCompanyID)) + ' companies' 
						END
					FROM PRCompanyRelationship WITH (NOLOCK)
					WHERE prcr_LeftCompanyID = @CompanyID
					AND prcr_Active = 'Y'
					AND prcr_Type IN ('09','10','11','12','13','14','15','16')

				INSERT INTO @RatingData (FactName, FactValue)
					SELECT TOP 1 'MAE', FORMAT(ISNULL(prfs_MarketingAdvertisingExpense, 0),'#0.00')
					  FROM Company WITH (NOLOCK)
						   INNER JOIN PRFinancial ON comp_CompanyID = prfs_CompanyID
					 WHERE Company.Comp_CompanyId = @CompanyID
					ORDER BY prfs_StatementDate DESC

				DECLARE @States TABLE (StateName NVARCHAR(1000), COUNTRY NVARCHAR(100), OrderState NVARCHAR(100), StateAbbreviation NVARCHAR(1000))
				DECLARE @StatesList VARCHAR(MAX);

				INSERT INTO @States
				SELECT DISTINCT 
					St = CASE 
						WHEN prcn_CountryId = 1 THEN prst_State
						ELSE 
							CASE WHEN prst_State IS NULL THEN prcn_Country
							ELSE prst_State + ', ' + prcn_Country
							END
						END
					, prcn_CountryId
					, prst_State
					, prst_Abbreviation
					FROM PRCompanyRelationship WITH (NOLOCK)
					INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prcr_RightCompanyID
					INNER JOIN vPRLocation WITH (NOLOCK) ON prci_CityID = comp_PRListingCityID
					WHERE prcr_LeftCompanyID = @CompanyID
					AND prcr_Active = 'Y'
					AND prcr_Type IN ('09','10','11','12','13','14','15','16')
					Order BY prcn_CountryId, prst_State

				SELECT @StatesList = COALESCE(@StatesList + ', ', '') + StateAbbreviation
				FROM @States

				--INSERT INTO @RatingData(FactName, FactValue)
				--SELECT 'RL States', @StatesList

				DELETE FROM @States
				SET @StatesList = NULL

				INSERT INTO @States
				SELECT DISTINCT 
					St = CASE 
						WHEN prcn_CountryId = 1 THEN prst_State
						ELSE 
							CASE WHEN prst_State IS NULL THEN prcn_Country
							ELSE prst_State + ', ' + prcn_Country
							END
						END
					, prcn_CountryId
					, prst_State
					, prst_Abbreviation
					FROM PRCompanyRelationship WITH (NOLOCK)
					INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prcr_RightCompanyID
					INNER JOIN vPRLocation WITH (NOLOCK) ON prci_CityID = comp_PRListingCityID
					WHERE prcr_LeftCompanyID = @CompanyID
					AND prcr_Active = 'Y'
					AND prcr_Type IN ('09')
					Order BY prcn_CountryId, prst_State

				SELECT @StatesList = COALESCE(@StatesList + ', ', '') + StateAbbreviation
				FROM @States

				INSERT INTO @RatingData(FactName, FactValue)
				SELECT 'Buys From', @StatesList

				DELETE FROM @States
				SET @StatesList = NULL

				INSERT INTO @States
				SELECT DISTINCT 
					St = CASE 
						WHEN prcn_CountryId = 1 THEN prst_State
						ELSE 
							CASE WHEN prst_State IS NULL THEN prcn_Country
							ELSE prst_State + ', ' + prcn_Country
							END
						END
					, prcn_CountryId
					, prst_State
					, prst_Abbreviation
					FROM PRCompanyRelationship WITH (NOLOCK)
					INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prcr_RightCompanyID
					INNER JOIN vPRLocation WITH (NOLOCK) ON prci_CityID = comp_PRListingCityID
					WHERE prcr_LeftCompanyID = @CompanyID
					AND prcr_Active = 'Y'
					AND prcr_Type IN ('13')
					Order BY prcn_CountryId, prst_State

				SELECT @StatesList = COALESCE(@StatesList + ', ', '') + StateAbbreviation
				FROM @States

				INSERT INTO @RatingData(FactName, FactValue)
				SELECT 'Sells To', @StatesList



				SELECT * FROM @RatingData Order BY ndx";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader Services(string szCompanyID)
        {
            string SQL = @"SELECT prse_ServiceCode, ItemCodeDescExt, QuantityOrdered, ExtensionAmt, prse_NextAnniversaryDate, LineKey, T1.OutstandingBalance
							FROM PRService WITH (NOLOCK)
								CROSS JOIN (SELECT ISNULL(SUM(o.Balance), 0) As OutstandingBalance FROM MAS_PRC.dbo.AR_OpenInvoice o INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryHeader h ON h.InvoiceNo = o.InvoiceNo AND h.HeaderSeqNo = o.InvoiceHistoryHeaderSeqNo WHERE o.Balance > 0 AND CAST(o.CustomerNo AS INT) = @CompanyID) T1 
							WHERE prse_CompanyID = @CompanyID
							AND SalesKitItem = 'N'
							ORDER BY LineKey";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader SalesInfo(string szCompanyID)
        {
            string SQL = @"DECLARE @SalesData TABLE (ndx INT IDENTITY, FactName NVARCHAR(1000), FactValue NVARCHAR(1000))

			INSERT INTO @SalesData (FactName, FactValue)
				SELECT 'BRs Available', Cnt = dbo.ufn_GetAvailableUnits(@CompanyID)	

			INSERT INTO @SalesData (FactName, FactValue)
				SELECT '# of BRs Used', COUNT(1)
				FROM PRBusinessReportRequest WITH (NOLOCK)
				WHERE prbr_CreatedDate > DATEADD(m,-12, GETDATE())
				AND dbo.ufn_BRGetHQID(prbr_RequestingCompanyId) = dbo.ufn_BRGetHQID(@CompanyID)

			-- Trading Assistance Claim, i.e. Special Services.  This would be the PRSSFile where the company is the claimant or respondent.
			INSERT INTO @SalesData (FactName, FactValue)
				SELECT '# TA Claims', COUNT(1) FROM PRSSFile
				WHERE 
					(prss_ClaimantCompanyId = @CompanyID OR prss_RespondentCompanyId = @CompanyID)
					AND prss_CreatedDate > DATEADD(m,-12, GETDATE())

			-- This would be the PRARAging table.  If they are a AR Aging submitter, then I think this would be Y.
			INSERT INTO @SalesData(FactName, FactValue)
				SELECT 'AR Aging Participation', CASE WHEN COUNT(1) > 0 THEN 'Y' ELSE 'N' END
				FROM PRARAging WHERE praa_CompanyId = @CompanyID
				AND praa_CreatedDate > DATEADD(m, -12, GETDATE())

			INSERT INTO @SalesData(FactName, FactValue)
				SELECT 'BBOS Lic. Purchased', cnt = dbo.ufn_GetEnterpriseAvailableLicenseCount(@CompanyID)

			INSERT INTO @SalesData(FactName, FactValue)
				SELECT 'BBOS Lic. Assigned', COUNT(1)
				FROM PRWebUser WITH(NOLOCK)
				WHERE prwu_HQID = dbo.ufn_BRGetHQID(@CompanyID)
				AND CAST(prwu_AccessLevel as INT) > 10

			-- query the PRWebAuditTrail table for distinct web user IDs for this company ID and the page name like '%/api/%'
			INSERT INTO @SalesData(FactName, FactValue)
				SELECT '# BBOS Mobile Users', COUNT(1) FROM(
				SELECT DISTINCT(prwsat_WebUserID) FROM PRWebAuditTrail WHERE prwsat_PageName LIKE '%api/%'
					AND prwsat_CompanyID = @CompanyID
					AND prwsat_CreatedDate > DATEADD(m, -12, GETDATE())
			) T1

			-- Query max praa_Date from the PRARAging file.
			--SELECT MAX(praa_Date) LastFileDate FROM PRARAging WHERE praa_CompanyId = @CompanyID
			DECLARE @LastFileDate datetime
			SELECT @LastFileDate = MAX(praa_Date) FROM PRARAging WHERE praa_CompanyId = @CompanyID
			AND praa_CreatedDate > DATEADD(m, -12, GETDATE())

			INSERT INTO @SalesData(FactName, FactValue)
				SELECT 'Date of last file', CASE WHEN @LastFileDate IS NULL THEN '' ELSE CONVERT(NVARCHAR(30), @LastFileDate, 101) END

			SELECT * FROM @SalesData Order BY ndx ASC";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader Person(string szCompanyID)
        {
            string SQL = @"SELECT  'Name' = dbo.ufn_FormatPersonById(peli_personid)
			, 'Title' = peli_PRTitle
			, 'Lic Level' = dbo.ufn_GetCapt_US('choices','prwu_AccessLevel',prwu_AccessLevel)
			, 'Last Access' = CONVERT(NVARCHAR(30),LastAccess,101)
			, 'BBOS Page Cnt' = PageCnt
			, 'Email' = ISNULL(RTRIM(prwu_Email),RTRIM(Emai_EmailAddress))
			, 'Rec BP' = CASE WHEN prattn_AttentionLineID IS NOT NULL THEN 'Y' END
		FROM Person_Link WITH (NOLOCK)
			 LEFT OUTER JOIN Custom_Captions WITH (NOLOCK) ON Capt_Family = 'pers_TitleCode'
														  AND Capt_Code = peli_PRTitleCode
			 LEFT OUTER JOIN PRWebUser WITH (NOLOCK) ON peli_PersonLinkID = prwu_PersonLinkID
													AND prwu_AccessLevel > 10
			 LEFT OUTER JOIN (SELECT prwsat_CreatedBy, 'LastAccess' = MAX(prwsat_CreatedDate), 'PageCnt' = COUNT(1)
								FROM PRWebAuditTrail WITH (NOLOCK)
							   WHERE prwsat_CreatedDate >= DATEADD(m,-6,GETDATE())
								 AND prwsat_CompanyID = @CompanyID
							GROUP BY prwsat_CreatedBy)TableA ON prwu_WebUserID = prwsat_CreatedBy
			 LEFT OUTER JOIN vPersonEmail WITH (NOLOCK) ON Emai_CompanyID = peli_Companyid 
													   AND elink_RecordID = peli_personid
			 LEFT OUTER JOIN PRAttentionLine WITH (NOLOCK) ON prattn_CompanyID = peli_Companyid
														  AND prattn_PersonID = peli_personid
														  AND prattn_ItemCode = 'BPrint'
			AND prattn_Disabled IS NULL
		WHERE peli_PRStatus IN (1,2)
		AND peli_Companyid = @CompanyID
		Order BY Capt_Order ASC";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader AttentionLines(string szCompanyID)
        {
            string SQL = @"SELECT 
							Item
							, Addressee
							, DeliveryAddress = RTRIM(DeliveryAddress)
							, prattn_Disabled
						FROM vPRCompanyAttentionLine WITH (NOLOCK)
						WHERE prattn_CompanyID = @CompanyID
						   AND (prattn_ItemCode IN ('CSUPD', 'EXUPD', 'BPRINT','LRL')
								 OR prattn_ItemCode LIKE 'BOOK-%')
						Order BY prattn_Disabled, CONVERT(NVARCHAR(MAX),Item)";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader AdRevenue(string szCompanyID)
        {
            string SQL = @"SELECT * FROM
							(SELECT CASE WHEN pradc_AdCampaignTypeDigital  LIKE 'IA%' THEN 'Image Ad' ELSE CAST(capt_us as varchar(100)) END as CampaignType,
								   SUM(pradc_Cost) as Cost
								FROM PRAdCampaign WITH (NOLOCK)
									INNER JOIN PRAdCampaignHeader ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
									INNER JOIN custom_captions ON capt_code = pradch_TypeCode AND capt_family = 'pradch_TypeCode'
								WHERE pradc_CompanyID = @CompanyID
									AND CASE WHEN pradc_StartDate IS NOT NULL THEN pradc_StartDate
										WHEN pradc_BluePrintsEdition IS NOT NULL THEN CAST(SUBSTRING(pradc_BluePrintsEdition, 5,2) + '/01/' + SUBSTRING(pradc_BluePrintsEdition, 1,4) AS DATETIME) 
									END < GETDATE()
									AND CASE WHEN pradc_StartDate IS NOT NULL THEN pradc_StartDate
											WHEN pradc_BluePrintsEdition IS NOT NULL THEN CAST(SUBSTRING(pradc_BluePrintsEdition, 5,2) + '/01/' + SUBSTRING(pradc_BluePrintsEdition, 1,4) AS DATETIME) 
									END >= CAST(DATEADD(year, -1, GETDATE()) as Date)
								GROUP BY CASE WHEN pradc_AdCampaignTypeDigital  LIKE 'IA%' THEN 'Image Ad' ELSE CAST(capt_us as varchar(100)) END) T1 WHERE Cost > 0";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader ImageAd(string szCompanyID)
        {
            string SQL = @"SELECT	PRAdCampaign.pradc_AdCampaignID AS pradc_AdCampaignID, 
								pradc_StartDate, 
								pradc_EndDate, 
								pradc_Name,
								capt_us as CampaignType,
								list.ImpressionCount, list.ClickCount, 
								pradc_AdCampaignTypeDigital
						 FROM vPRAdCampaignPageDetailList list            
							  INNER JOIN PRAdCampaign WITH (NOLOCK) ON list.pradcats_AdCampaignID = PRAdCampaign.pradc_AdCampaignID   
							  INNER JOIN PRAdCampaignHeader WITH(NOLOCK) ON pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
							  INNER JOIN custom_captions ON pradch_TypeCode = capt_code and capt_family = 'pradch_TypeCode'
						WHERE list.pradcats_AdCampaignID IN (
								SELECT pradc_AdCampaignID
								  FROM PRAdCampaign 
								 WHERE pradc_CompanyID = @CompanyID
								   AND pradc_StartDate < GETDATE()
								   AND pradc_EndDate >= CAST(DATEADD(year, -1, GETDATE()) as Date)
								)
		
								AND pradc_AdCampaignTypeDigital LIKE 'IA%'
						ORDER BY pradc_StartDate DESC";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader Advertising(string szCompanyID)
        {
            string SQL = @"SELECT	
							pradch_adcampaignheaderid,
							pradc_cost,
							pradch_TypeCode,
							pradc_AdCampaignID,
								CASE 
									WHEN pradch_TypeCode = 'BP' THEN 'Blueprints Advertisement'
									WHEN pradch_TypeCode = 'KYC' AND pradc_AdCampaignType = 'PUB' THEN 'Publication Advertisement'
									WHEN pradch_TypeCode = 'KYC' AND pradc_AdCampaignType = 'KYCD' THEN 'KYC Digital'
																	   WHEN pradch_TypeCode = 'D' THEN 'Digital'
									WHEN pradch_TypeCode = 'KYC' THEN 'Know Your Commodity Guide'
								END AS pradc_AdCampaignType,
								pradch_Name,
  								CASE pradch_TypeCode WHEN 'BP' THEN NULL ELSE pradc_StartDate END AS StartDate,
								CASE pradch_TypeCode WHEN 'BP' THEN NULL ELSE pradc_EndDate END AS EndDate,
								dbo.ufn_GetCustomCaptionValueList('pradc_BluePrintsEdition', pradc_BluePrintsEdition) As BlueprintsEdition,
								pradc_AdSize, 
								pradch_Cost,
								pradc_BluePrintsEdition,
								ISNULL(cc2.Capt_US,'') [PlannedSection]
						 FROM PRAdCampaign WITH (NOLOCK)
							INNER JOIN PRAdCampaignHeader On pradch_AdCampaignHeaderID = pradc_AdCampaignHeaderID
							INNER JOIN custom_captions ON capt_code = pradch_TypeCode AND capt_family = 'pradch_TypeCode'
							LEFT OUTER JOIN custom_captions cc2 ON cc2.capt_code = pradc_PlannedSection AND cc2.capt_family = 'pradc_PlannedSection'
						WHERE pradch_CompanyID = @CompanyID
						ORDER BY ISNULL(pradc_BluePrintsEdition, FORMAT(pradc_StartDate,'yyyyMM')) DESC";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader Interactions(string szCompanyID)
        {
            string SQL = @"SELECT Comm_DateTime, 
								Comm_Note, 
								'user' = Upper(RTRIM(User_Logon)), 
								Comm_ChannelId, comm_type, comm_action, comm_PRCategory, comm_PRSubcategory,  comm_subject 
							FROM vCommunication WITH (NOLOCK)
								LEFT OUTER JOIN Users WITH (NOLOCK) ON User_UserId = CmLi_Comm_UserID
								LEFT OUTER JOIN (SELECT chan = Comm_ChannelID, 
														dt = MAX(Comm_DateTime)
													FROM vCommunication WITH (NOLOCK)
													WHERE Comm_ChannelID IS NOT NULL
													AND CmLi_Comm_CompanyID = @CompanyID
													AND comm_DateTime<=getdate()
													AND comm_ChannelID IN (7, 2, 6, 1)
													AND Comm_CreatedBy > 1
												GROUP BY Comm_ChannelID)TableA ON dt = Comm_DateTime
																			AND chan = Comm_ChannelID
							WHERE CmLi_Comm_CompanyID = @CompanyID
							AND Comm_CreatedBy > 1
							AND dt IS NOT NULL
						ORDER BY vCommunication.Comm_DateTime DESC";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader Claims(string szCompanyID)
        {
            string SQL = @"SELECT prss_CreatedDate, prss_OpenedDate, prss_ClosedDate, prss_PublishedIssueDesc, prss_InitialAmountOwed, Status
							FROM vPRBBSiClaims 
							WHERE prss_RespondentCompanyId = @CompanyID
								AND prss_Status IN ('O', 'C')
								AND prss_Publish = 'Y'
							ORDER BY prss_OpenedDate DESC";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader Opportunities(string szCompanyID)
        {
            string SQL = @"SELECT 'Type' = dbo.ufn_GetCapt_US ('Choices','Oppo_Type',Oppo_Type),
							   'User' = RTRIM(User_Logon),
							   DateCreated = CONVERT(NVARCHAR(30),Oppo_CreatedDate,101),
							   Stat = dbo.ufn_GetCapt_US ('Choices','Oppo_PRStatus',Oppo_Status),
							   Forecast = Oppo_Forecast,
							   Subtype = ISNULL(dbo.ufn_GetCapt_US ('Choices','Oppo_PRType',oppo_PRType),''),
							   TargetDate = CASE WHEN oppo_PRTargetStartYear IS NOT NULL AND oppo_PRTargetStartMonth IS NOT NULL 
												 THEN dbo.ufn_GetCapt_US ('Choices','Oppo_PRTargetStartMonth',oppo_PRTargetStartMonth) + ' ' + oppo_PRTargetStartYear
											END,
							   Campaign = ISNULL(RTRIM(WaIt_Name),'')
						  FROM Opportunity WITH (NOLOCK)
							   INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = Oppo_PrimaryCompanyId
							   INNER JOIN vPRLocation WITH (NOLOCK) ON prci_CityID = comp_PRListingCityID
							   LEFT OUTER JOIN Users WITH (NOLOCK) ON User_UserId = Oppo_AssignedUserId
							   LEFT OUTER JOIN WaveItems WITH (NOLOCK) ON WaIt_WaveItemId = Oppo_WaveItemId
						 WHERE Oppo_PrimaryCompanyId = @CompanyID
						   AND Oppo_CreatedDate >= DATEADD(month, -12, CAST(GETDATE() as Date))
						ORDER BY DateCreated DESC";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader Listing(string szCompanyID)
        {
            string SQL = @"SELECT dbo.ufn_GetListingFromCompany(@CompanyID, 0, 0) Listing";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("CompanyID", szCompanyID));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
        static public IDataReader RecentlyViewedCompanies(string WebUserID, int TopCount)
        {
            string SQL = @"SELECT comp_CompanyID, comp_PRBookTradestyle, CityStateCountryShort,
								dbo.ufn_GetCustomCaptionValue('comp_prindustrytype', comp_PRIndustryType, 'en-us') As comp_prindustrytype,
								comp_prType,
								comp_PRLocalSource, comp_PRIsIntlTradeAssociation
							FROM dbo.ufn_GetRecentCompanies(@WebUserID, @TopCount)
							INNER JOIN vPRBBOSCompanyList ON CompanyID = comp_CompanyID
							WHERE
								comp_PRLocalSource IS NULL 
								AND comp_PRIsIntlTradeAssociation IS NULL";

            IList oParms = new ArrayList();
            oParms.Add(new DBParameter("WebUserID", WebUserID));
            oParms.Add(new DBParameter("TopCount", TopCount));

            IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
            IDataReader oReader = oDBAccess.ExecuteReader(SQL, oParms, CommandBehavior.CloseConnection, null);
            return oReader;
        }
		static string SQL_COMPANY_SEARCH = @"SELECT comp_CompanyID, comp_PRBookTradestyle, CityStateCountryShort,
										dbo.ufn_GetCustomCaptionValue('comp_prindustrytype', comp_PRIndustryType, 'en-us') As comp_prindustrytype,
										dbo.ufn_GetCustomCaptionValue('comp_PRListingStatus', comp_PRListingStatus, 'en-us') As comp_prlistingstatus,
										comp_prType,
										comp_PRLocalSource, comp_PRIsIntlTradeAssociation
									FROM vPRBBOSCompanyList
									WHERE
										comp_PRLocalSource IS NULL 
										AND comp_PRIsIntlTradeAssociation IS NULL
										AND comp_CompanyID IN ({0})
									ORDER BY comp_PRBookTradestyle
									OFFSET {1} ROWS FETCH NEXT {2} ROWS ONLY";
		static public DataSet CompanySearch(string BBNum, string CompanyName, string ListingStatus, string Industry, string State, string SalesTerritory, int Page, int ItemsPerPage)
		{
			CompanySearchCriteria criteria = new CompanySearchCriteria();

			criteria.WebUser = (IPRWebUser)HttpContext.Current.Session["oUser"];

			if (!string.IsNullOrEmpty(BBNum))
				criteria.BBID = Convert.ToInt32(BBNum);
			if (!string.IsNullOrEmpty(CompanyName))
				criteria.CompanyName = CompanyName;
			if (!string.IsNullOrEmpty(ListingStatus))
				criteria.ListingStatus = ListingStatus;

			if (!string.IsNullOrEmpty(Industry))
			{
				criteria.IndustryType = "L";
				if (Industry != "L")
					criteria.IndustryTypeNotEqual = true;
			}
			else
				criteria.IndustryTypeSkip = true;

			if (!string.IsNullOrEmpty(State))
				criteria.ListingStateIDs = State;
			if (!string.IsNullOrEmpty(SalesTerritory))
				criteria.TerritoryCode = SalesTerritory;

			ArrayList oParameters;
			string szSQLInner = criteria.GetSearchSQL(out oParameters);
			string szSQLCompanySearch = string.Format(SQL_COMPANY_SEARCH, szSQLInner, (Page - 1) * ItemsPerPage, ItemsPerPage);

			IDBAccess oDBAccess = DBAccessFactory.getDBAccessProvider();
			DataSet ds = oDBAccess.ExecuteSelect(szSQLCompanySearch, oParameters);

			return ds;
		}
	}
}
