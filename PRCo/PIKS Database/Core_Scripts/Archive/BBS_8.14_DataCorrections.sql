--8.14 Release DataCorrections

BEGIN
	PRINT 'BEGIN COMMENTED OUT SECTION - we added FEATURE Marketing Site Advertising Refactoring as a post 8.14 release'
	PRINT 'BEGIN COMMENTED OUT SECTION - Since most of this SQL file was already run in production on 10/20/2022, we do not want it to run a 2nd time when we deploy 8.14 for the 2nd time'
	PRINT 'BEGIN COMMENTED OUT SECTION - Things below this commented out section are the only things to be run this 2nd time'

	/*
	--DEFECT 7036 - new ADVBILL attention line
	--DELETE FROM PRAttentionLine WHERE prattn_ItemCode='ADVBILL'
	DECLARE @AdvBillCount int
	SELECT @AdvBillCount=COUNT(*) FROM PRAttentionLine WHERE prattn_ItemCode='ADVBILL'
	IF @AdvBillCount = 0
	BEGIN
		INSERT INTO PRAttentionLine (prattn_CompanyID, prattn_ItemCode, prattn_PersonID, prattn_CustomLine,  prattn_AddressID, prattn_EmailID, prattn_PhoneID, prattn_BBOSOnly, prattn_IncludeWireTransferInstructions, prattn_CreatedBy, prattn_UpdatedBy)
		SELECT comp_CompanyID, 'ADVBILL', bill.prattn_PersonID, bill.prattn_CustomLine, bill.prattn_AddressID, bill.prattn_EmailID, bill.prattn_PhoneID, bill.prattn_BBOSOnly, bill.prattn_IncludeWireTransferInstructions, -1, -1
			FROM Company
				LEFT OUTER JOIN PRAttentionLine bill  WITH(NOLOCK) ON comp_CompanyID = bill.prattn_CompanyID AND bill.prattn_ItemCode = 'BILL'
				LEFT OUTER JOIN PRAttentionLine prat WITH(NOLOCK) ON comp_CompanyID = prat.prattn_CompanyID AND prat.prattn_ItemCode = 'ADVBILL'
		WHERE prat.prattn_AttentionLineID IS NULL
			AND comp_PRListingStatus NOT IN ('D', 'N3');
	END
	
	--DEFECT 7052
	UPDATE PRBBOSPrivilege SET AccessLevel=350 WHERE Privilege='WatchdogListsPage' AND IndustryType='L'  --L150 has access
	UPDATE PRBBOSPrivilege SET AccessLevel=350 WHERE Privilege='CompanySearchByWatchdogList' AND IndustryType='L'  --L150 has access
	UPDATE PRBBOSPrivilege SET AccessLevel=350 WHERE Privilege='WatchdogListAdd' AND IndustryType='L'  --L150 has access

	DECLARE @WatchdogListNewCount int
	SELECT @WatchdogListNewCount=COUNT(*) FROM PRBBOSPrivilege WHERE Privilege='WatchdogListNew'
	IF @WatchdogListNewCount = 0
	BEGIN
		INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('P',400,'WatchdogListNew',NULL, 1, 0)
		INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('T',400,'WatchdogListNew',NULL, 1, 0)
		INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('S',400,'WatchdogListNew',NULL, 1, 0)
		INSERT INTO PRBBOSPrivilege(IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('L',400,'WatchdogListNew',NULL, 1, 0)
	END

	--Defect 7077 - PRLocalSourceMatchExclusion
	DECLARE @MatchExclusionCount int
	SELECT @MatchExclusionCount=COUNT(*) FROM PRLocalSourceMatchExclusion
	IF @MatchExclusionCount=0
	BEGIN
		--TRUNCATE TABLE PRLocalSourceMatchExclusion
		INSERT INTO PRLocalSourceMatchExclusion(prlse_Key, prlse_CompanyID) VALUES ('1101534993', 172490)
		INSERT INTO PRLocalSourceMatchExclusion(prlse_Key, prlse_CompanyID) VALUES ('1101540404', 122923)
		INSERT INTO PRLocalSourceMatchExclusion(prlse_Key, prlse_CompanyID) VALUES ('1101541982', 166234)
		INSERT INTO PRLocalSourceMatchExclusion(prlse_Key, prlse_CompanyID) VALUES ('1101103501', 163242)
		INSERT INTO PRLocalSourceMatchExclusion(prlse_Key, prlse_CompanyID) VALUES ('1101447407', 307541)
		INSERT INTO PRLocalSourceMatchExclusion(prlse_Key, prlse_CompanyID) VALUES ('1101547891', 108839)

		INSERT INTO PRLocalSourceMatchExclusion(prlse_Key, prlse_CompanyID) VALUES ('1101534993', 277437);
		INSERT INTO PRLocalSourceMatchExclusion(prlse_Key, prlse_CompanyID) VALUES ('1101540404', 260888);
		INSERT INTO PRLocalSourceMatchExclusion(prlse_Key, prlse_CompanyID) VALUES ('1101541982', 349929);
		INSERT INTO PRLocalSourceMatchExclusion(prlse_Key, prlse_CompanyID) VALUES ('1101447407', 313868);
	END

	--Defect 7068 - lumber public profiles
	UPDATE NewProduct SET prod_PRSequence=30, prod_PRDescription='<ul class="Bullets"><li>1 user license</li><li>0 Business Reports</li><li>Does not include Blue Book credit ratings and scores</li></ul>' WHERE prod_productfamilyid=5 AND prod_IndustryTypeCode LIKE '%,L,%' AND prod_code = 'L100'
	UPDATE NewProduct SET prod_PRSequence=10, prod_PRDescription='<ul class="Bullets"><li>5 user licenses</li><li>5 Business Reports</li><li>Access to Blue Book credit ratings and scores</li></ul>' WHERE prod_productfamilyid=5 AND prod_IndustryTypeCode LIKE '%,L,%' AND prod_code = 'L200'
	UPDATE NewProduct SET prod_PRSequence=20, prod_PRDescription='<ul class="Bullets"><li>15 user licenses</li><li>60 Business Reports</li><li>Access to Blue Book credit ratings and scores</li></ul>' WHERE prod_productfamilyid=5 AND prod_IndustryTypeCode LIKE '%,L,%' AND prod_code = 'L300'

	--Defect 7059 - default new field PRCompanyClassification.prc2_Sequence
	ALTER TABLE PRCompanyClassification DISABLE TRIGGER ALL

	UPDATE T1
	SET T1.prc2_Sequence = T2.ROW_SEQUENCE
	FROM PRCompanyClassification T1
	INNER JOIN (
		SELECT prc2_CompanyClassificationId, prc2_CompanyID, ROW_NUMBER() OVER (PARTITION BY prc2_CompanyId order by prc2_CompanyClassificationId) as ROW_SEQUENCE
		FROM PRCompanyClassification
	) T2 ON T1.prc2_CompanyClassificationId = T2.prc2_CompanyClassificationId

	ALTER TABLE PRCompanyClassification ENABLE TRIGGER ALL



	--ILLINOIS TAX RATE FIX
	UPDATE PRCompanyIndicators SET prci2_TaxCode='TAX-IL', prci2_UpdatedDate=GETDATE(), prci2_UpdatedBy=-1 WHERE prci2_CompanyID IN
	(
		SELECT DISTINCT Comp_CompanyId FROM PRCompanyIndicators
		INNER JOIN Company ON Comp_CompanyId = prci2_CompanyID
		INNER JOIN vPRAddress tx WITH (NOLOCK) ON tx.adli_CompanyId = Comp_CompanyId AND tx.adli_PRDefaultTax = 'Y' AND prst_Abbreviation='IL'
	) 

	--2022-08-22 TES Partial Responder DC #1 v3
	DECLARE @Start DateTime
	SET @Start = GETDATE()

		DECLARE @T TABLE
		(
			BBID int,
			ReceiveTESCodeToUse varchar(50)
		)

		INSERT INTO @T
		SELECT DISTINCT comp_CompanyID [BBID],
			CASE
				WHEN ISNULL(prcip.prc5_ARSubmitter,'N')='Y'  THEN 'NR'
				WHEN c.comp_PRListingStatus NOT IN ('L', 'H', 'LUV') THEN 'NR'
				ELSE 'PNR'
			END [ReceiveTESCodeToUse]
		FROM Company c WITH(NOLOCK)
		INNER JOIN vPRLocation loc ON comp_PRListingCityID = prci_CityID
		INNER JOIN Custom_Captions cc1 WITH(NOLOCK) ON cc1.Capt_Family='comp_PRListingStatus' AND cc1.Capt_Code=comp_PRListingStatus
		LEFT OUTER JOIN PRCompanyInfoProfile prcip WITH(NOLOCK) ON prcip.prc5_CompanyId = c.Comp_CompanyId
		LEFT OUTER JOIN (SELECT prtesr_ResponderCompanyID, COUNT(1) AS TESFormsSent12Mo
							FROM PRTESRequest  WITH(NOLOCK)
							WHERE prtesr_SentDateTime >= DATEADD(month, -12, GETDATE()) 
							GROUP BY prtesr_ResponderCompanyID
							) TESSent ON TESSent.prtesr_ResponderCompanyID = c.Comp_CompanyId
	
		LEFT OUTER JOIN (SELECT prtesr_ResponderCompanyID, COUNT(1) TESFormsReceived12Mo
							FROM PRTESRequest  WITH(NOLOCK)
							WHERE prtesr_SentDateTime >= DATEADD(month, -12, GETDATE()) AND prtesr_Received='Y'
							GROUP BY prtesr_ResponderCompanyID
							) TESReceived ON TESReceived.prtesr_ResponderCompanyID = c.Comp_CompanyId
	WHERE
		c.comp_PRIndustryType IN ('P', 'T', 'S')
		AND c.comp_PRType = 'H'
		AND ISNULL(TESFormsSent12Mo, 0) > 0
		AND ISNULL(TESFormsReceived12Mo, 0) = 0
		AND comp_PRReceiveTESCode='PNR'

	ALTER TABLE Company DISABLE TRIGGER trg_Company_ioupd

	UPDATE Company SET comp_PRReceiveTESCode=T1.ReceiveTESCodeToUse, Comp_UpdatedBy=-1, Comp_UpdatedDate=@Start
	FROM Company T2
	JOIN @T T1 ON T1.BBID = t2.Comp_CompanyId

	ALTER TABLE Company ENABLE TRIGGER trg_Company_ioupd

	--2022-08-10 TES Partial Responder DC #2
		DECLARE @T2 TABLE
		(
			ndx int identity, 
			comp_CompanyID int,
			TopRankEmailAddress varchar(100),
			Skipped int
		)
		INSERT INTO @T2 (comp_CompanyID)
			SELECT DISTINCT comp_CompanyID [BBID]
			FROM Company c WITH(NOLOCK)
				INNER JOIN vPRLocation loc ON comp_PRListingCityID = prci_CityID
				INNER JOIN Custom_Captions cc1 WITH(NOLOCK) ON cc1.Capt_Family='comp_PRListingStatus' AND cc1.Capt_Code=comp_PRListingStatus
				LEFT OUTER JOIN Custom_Captions cc2 WITH(NOLOCK) ON cc2.Capt_Family='comp_PRReceiveTESCode' AND cc2.Capt_Code=comp_PRReceiveTESCode
	
				LEFT OUTER JOIN PRCompanyInfoProfile prcip WITH(NOLOCK) ON prcip.prc5_CompanyId = c.Comp_CompanyId
				LEFT OUTER JOIN (SELECT prtesr_ResponderCompanyID, COUNT(1) AS TESFormsSent12Mo
									FROM PRTESRequest  WITH(NOLOCK)
									WHERE prtesr_SentDateTime >= DATEADD(month, -12, GETDATE()) 
									GROUP BY prtesr_ResponderCompanyID
									) TESSent ON TESSent.prtesr_ResponderCompanyID = c.Comp_CompanyId
	
				LEFT OUTER JOIN (SELECT prtesr_ResponderCompanyID, COUNT(1) TESFormsReceived12Mo
									FROM PRTESRequest  WITH(NOLOCK)
									WHERE prtesr_SentDateTime >= DATEADD(month, -12, GETDATE()) AND prtesr_Received='Y'
									GROUP BY prtesr_ResponderCompanyID
									) TESReceived ON TESReceived.prtesr_ResponderCompanyID = c.Comp_CompanyId

				LEFT OUTER JOIN PRAttentionLine prattM WITH(NOLOCK) ON prattM.prattn_CompanyID = c.Comp_CompanyId AND prattM.prattn_ItemCode='TES-M'
				LEFT OUTER JOIN PRAttentionLine prattE WITH(NOLOCK) ON prattE.prattn_CompanyID = c.Comp_CompanyId AND prattE.prattn_ItemCode='TES-E'
				LEFT OUTER JOIN vPRPersonEmail prpeE WITH(NOLOCK) ON prpeE.ELink_RecordId = prattE.prattn_PersonID AND prpeE.emai_PRPreferredInternal='Y'
				LEFT OUTER JOIN vPRPersonEmail prpeM WITH(NOLOCK) ON prpeM.ELink_RecordId = prattM.prattn_PersonID AND prpeM.emai_PRPreferredInternal='Y'
				LEFT OUTER JOIN vCompanyEmail ce WITH(NOLOCK) ON ce.ELink_RecordID = c.comp_CompanyID AND ce.Elink_Type = 'E' AND ce.emai_PRPublish = 'Y'
				LEFT OUTER JOIN vPRCompanyPhone prcphone WITH(NOLOCK) ON prattE.prattn_PhoneID = prcphone.PLink_PhoneId AND prcphone.phon_PRIsFax = 'Y' AND prcphone.phon_PRPublish = 'Y'
				LEFT OUTER JOIN vPRAddress prapc ON prapc.adli_CompanyId = c.Comp_CompanyId AND adli_PRDefaultMailing='Y'
			WHERE
				c.comp_PRIndustryType IN ('P', 'T', 'S')
				AND c.comp_PRType = 'H'
				AND ISNULL(TESFormsSent12Mo, 0) > 0
				AND ISNULL(TESFormsReceived12Mo, 0) = 0
				AND 
				(
					(prattM.prattn_ItemCode IS NOT NULL AND prattM.prattn_Disabled IS NULL) --Mail
					OR
					(prattE.prattn_ItemCode IS NOT NULL AND prattE.prattn_Disabled IS NULL AND prattE.prattn_PhoneID IS NOT NULL) --Fax
				)

		DECLARE @RCount int = (SELECT COUNT(*) FROM @T2)
		DECLARE @ndx INT; SET @ndx = 1 
		DECLARE @comp_CompanyID int
		DECLARE @TopRankPersonID int
		DECLARE @TopRankPersonName varchar(500)
		DECLARE @TopRankEmailAddress varchar(500)
		DECLARE @EmailID int
		DECLARE @DeletedCount int = 0
		WHILE (@ndx <= @RCount) BEGIN 
			SET @TopRankPersonID = NULL
			SET @TopRankPersonName = NULL
			SET @TopRankEmailAddress = NULL
			SET @EmailID= NULL

			SELECT @comp_CompanyID=comp_CompanyID FROM @T2 WHERE ndx = @ndx 

			SELECT @TopRankPersonID = pers_personid, @TopRankPersonName=Pers_FullName FROM
			(
				SELECT TOP 1 Pers_FullName, pers_personid, peli_PersonLinkId, peli_prtitle, peli_prtitlecode, peli_prstatus, peli_prrole, emai_emailaddress, emai_prpublish,
					CASE WHEN peli_PRTitleCode = 'CRED' THEN 1
						WHEN peli_prrole LIKE '%,HC,%' THEN 2
						WHEN peli_prrole LIKE '%,C,%' THEN 3
						WHEN peli_PRTitleCode = 'CTRL' THEN 4
						WHEN peli_PRTitleCode = 'ACC' THEN 5
						WHEN peli_PRTitleCode = 'OMGR' THEN 6
						WHEN peli_prrole LIKE '%,HF,%' THEN 7
						WHEN peli_prrole LIKE '%,F,%' THEN 8
						WHEN peli_PRTitleCode = 'CFO' THEN 9
						WHEN peli_PRTitleCode = 'PRES' THEN 10
						WHEN peli_PRTitleCode = 'VP' THEN 11
						WHEN peli_PRTitleCode = 'GM' THEN 12
						WHEN peli_prrole LIKE '%,HO,%' THEN 13
						WHEN peli_prrole LIKE '%,HE,%' THEN 14
						ELSE 99
					END AS [Rank],
					NEWID() AS [Random]
				FROM vPRPersonnelListing WHERE Pers_CompanyId = @comp_CompanyID 
						AND emai_emailaddress IS NOT NULL 
						AND peli_PRStatus = 1
				ORDER BY [Rank], Random, Pers_FullName
			) T1

		
			IF @TopRankPersonID IS NOT NULL
			BEGIN
				SELECT	@EmailID = emai_EmailId, 
						@TopRankEmailAddress = emai_emailaddress 
				FROM vpersonemail where emai_CompanyID=@comp_CompanyID AND ELink_RecordID=@TopRankPersonID 

				--Update the TES-E record (and make sure it's enabled)
				UPDATE PRAttentionLine SET prattn_Disabled=NULL, prattn_UpdatedBy=-1, prattn_UpdatedDate=@Start, prattn_PersonID=@TopRankPersonID, prattn_CustomLine=NULL, prattn_AddressID=NULL, prattn_EmailID=@EmailID, prattn_PhoneID=NULL
				WHERE prattn_CompanyID=@comp_CompanyID AND prattn_ItemCode='TES-E'

				--Update the TES-M record (just disable it)
				UPDATE PRAttentionLine SET prattn_Disabled='Y', prattn_UpdatedBy=-1, prattn_UpdatedDate=@Start
				WHERE prattn_CompanyID=@comp_CompanyID AND prattn_ItemCode='TES-M'

				UPDATE @T2 SET TopRankEmailAddress = @TopRankEmailAddress WHERE ndx=@ndx
			END
			ELSE
			BEGIN
				UPDATE @T2 SET Skipped=1 WHERE ndx=@ndx
			END
		
			SET @ndx = @ndx + 1 
		END

	--2022-08-22 Disable TES-M Attention Lines when they have TES-E
		DECLARE @T3 TABLE
		(
			comp_companyID int,
			comp_name varchar(100),
			comp_PRReceiveTES varchar(1),
			comp_PRReceiveTESCode varchar(100),
			comp_PRListingStatus varchar(100), 
			comp_PRType varchar(100), 
			comp_PRIndustryType varchar(100)
		)

		INSERT INTO @T3
		SELECT DISTINCT comp_companyid, comp_name, comp_PRReceiveTES, comp_PRReceiveTESCode, comp_PRListingStatus, comp_PRType, comp_PRIndustryType
			FROM Company c WITH(NOLOCK)
			INNER JOIN PRAttentionLine prattM WITH(NOLOCK) ON prattM.prattn_CompanyID = c.Comp_CompanyId AND prattM.prattn_ItemCode='TES-M' AND prattM.prattn_Disabled IS NULL AND prattM.prattn_AddressID IS NOT NULL
			INNER JOIN PRAttentionLine prattE WITH(NOLOCK) ON prattE.prattn_CompanyID = c.Comp_CompanyId AND prattE.prattn_ItemCode='TES-E' AND prattE.prattn_Disabled IS NULL AND (prattE.prattn_EmailID IS NOT NULL OR prattE.prattn_PhoneID IS NOT NULL OR prattE.prattn_BBOSOnly IS NOT NULL) 
		WHERE
			comp_PRListingStatus not in ('D', 'N5', 'N6')
			AND c.comp_PRReceiveTES IS NOT NULL
			--AND comp_PRReceiveTESCode = 'PNR'

		SELECT comp_companyID, comp_name, ISNULL(cc1.Capt_US,'') [Receive TES Code], ISNULL(cc2.Capt_US,'') [Listing Status], cc3.Capt_US [Type], cc4.capt_us [Industry] FROM @T3
			LEFT OUTER JOIN Custom_Captions cc1 WITH(NOLOCK) ON cc1.Capt_Family='comp_PRReceiveTESCode' AND cc1.Capt_Code=comp_PRReceiveTESCode
			LEFT OUTER JOIN Custom_Captions cc2 WITH(NOLOCK) ON cc2.Capt_Family='comp_PRListingStatus' AND cc2.Capt_Code=comp_PRListingStatus
			LEFT OUTER JOIN Custom_Captions cc3 WITH(NOLOCK) ON cc3.Capt_Family='comp_PRType' AND cc3.Capt_Code=comp_PRType
			LEFT OUTER JOIN Custom_Captions cc4 WITH(NOLOCK) ON cc4.Capt_Family='comp_PRIndustryType' AND cc4.Capt_Code=comp_PRIndustryType
		ORDER BY comp_name

		--Disable TES-M records
		UPDATE PRAttentionLine SET prattn_Disabled = 'Y', prattn_UpdatedBy=-1, prattn_UpdatedDate=@Start WHERE prattn_CompanyID IN (SELECT comp_companyid FROM @T3) AND prattn_ItemCode='TES-M'
	*/ 
	
	PRINT 'END COMMENTED OUT SECTION'
END
Go

--Everything below here is new SQL to be run as the 2nd deployment on 8.14

UPDATE NewProduct SET prod_PRDescription_ES = '<ul class="Bullets"><li>10 Licencias de Usuario de Blue Book Premium</li><li>85 Reportes de Negocio</li></ul>' WHERE prod_ProductID=6
Go

--Populate new field pracf_FileName_Disk
DECLARE @UpdateDate datetime = GETDATE()
UPDATE PRAdCampaignFile 
	SET PRAdCampaignFile.pracf_FileName_Disk=CAST(pradch_CompanyID AS varchar(50))  
		+ '\BBSI_' 
		+ CAST(pradc_AdCampaignID AS VARCHAR(50))
		+ CASE WHEN pracf_FileTypeCode = 'DIM' THEN '_M' ELSE '' END
		+ CASE WHEN pracf_FileName like '%.%'
            THEN '.' + reverse(left(reverse(pracf_FileName), charindex('.', reverse(pracf_FileName)) - 1))
            else ''
        end,

		pracf_UpdatedDate=@UpdateDate
	FROM PRAdCampaignHeader
		INNER JOIN PRAdCampaign on pradc_AdCampaignHeaderID = pradch_AdCampaignHeaderID
		INNER JOIN PRAdCampaignFile ON pracf_AdCampaignID = pradc_AdCampaignID AND pracf_FileTypeCode <> 'PI'
	WHERE PRAdCampaignFile.pracf_FileName_Disk IS NULL
Go