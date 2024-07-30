ALTER TABLE Person_Link DISABLE TRIGGER ALL
UPDATE Person_Link
   SET peli_PRSequence = Sequence
  FROM (SELECT peli_CompanyID,
			   peli_PersonLinkID, 
			   peli_PRTitleCode, 
			   tcc.capt_order as TitleCodeOrder,
			   ROW_NUMBER() OVER (PARTITION BY peli_CompanyID ORDER BY tcc.capt_order) as Sequence
		  FROM Person_Link WITH (NOLOCK) 
 			   INNER JOIN custom_captions tcc WITH (NOLOCK) ON tcc.capt_family = 'pers_TitleCode' and tcc.capt_code = peli_PRTitleCode 
		 WHERE peli_PRStatus = '1' 
		   AND peli_PREBBPublish = 'Y') T1
WHERE Person_Link.peli_PersonLinkID = T1.peli_PersonLinkID
ALTER TABLE Person_Link ENABLE TRIGGER ALL
Go


UPDATE PRCommodity
   SET prcm_RootParentID = 1
  WHERE prcm_PathNames LIKE 'Flower/Plant/Tree,%'

UPDATE PRCommodity
   SET prcm_RootParentID = 16
  WHERE prcm_PathNames LIKE 'Food (non-produce),%'

UPDATE PRCommodity
   SET prcm_RootParentID = 37
  WHERE prcm_PathNames LIKE 'Fruit,%'

UPDATE PRCommodity
   SET prcm_RootParentID = 248
  WHERE prcm_PathNames LIKE 'Herb,%'

UPDATE PRCommodity
   SET prcm_RootParentID = 271
  WHERE prcm_PathNames LIKE 'Nut,%'

UPDATE PRCommodity
   SET prcm_RootParentID = 287
  WHERE prcm_PathNames LIKE 'Spice,%'
  
UPDATE PRCommodity
   SET prcm_RootParentID = 291
  WHERE prcm_PathNames LIKE 'Vegetable,%'
Go



INSERT INTO PRRegion (prd2_RegionID, prd2_ParentId, prd2_Level, prd2_Name, prd2_Description, prd2_Type, prd2_StateID, prd2_CreatedBy, prd2_CreatedDate, prd2_UpdatedDate, prd2_TimeStamp)
VALUES (82, 6, 3, 'VI', 'VI', 'D', 1017, -1, GETDATE(), GETDATE(), GETDATE());

INSERT INTO PRRegion (prd2_RegionID, prd2_ParentId, prd2_Level, prd2_Name, prd2_Description, prd2_Type, prd2_StateID, prd2_CreatedBy, prd2_CreatedDate, prd2_UpdatedDate, prd2_TimeStamp)
VALUES (83, 6, 3, 'PR', 'PR', 'D', 1015, -1, GETDATE(), GETDATE(), GETDATE());

INSERT INTO PRRegion (prd2_RegionID, prd2_ParentId, prd2_Level, prd2_Name, prd2_Description, prd2_Type, prd2_StateID, prd2_CreatedBy, prd2_CreatedDate, prd2_UpdatedDate, prd2_TimeStamp)
VALUES (84, 3, 3, 'GU', 'GU', 'D', 1016, -1, GETDATE(), GETDATE(), GETDATE());
Go

--INSERT INTO Custom_Captions (Capt_CaptionId, Capt_FamilyType, Capt_Family, Capt_Code, Capt_US, Capt_UK, Capt_FR, Capt_DE, Capt_ES, Capt_Order, Capt_System, Capt_CreatedBy, Capt_CreatedDate, Capt_UpdatedBy, Capt_UpdatedDate, Capt_TimeStamp, Capt_Deleted, Capt_Context, Capt_DU, Capt_JP, Capt_Component, capt_deviceid, capt_integrationid, capt_CS)
--values (((select max(capt_captionid) from Custom_Captions) + 1),'Choices', '1', '1/12/2016', 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 'Lumber BB Last Run Date/Time', 0, NULL, -1, GETDATE(), -1000, GETDATE(), GETDATE(), NULL, NULL, NULL, NULL, 'PRDropdownValues', NULL, NULL, NULL)
--GO
--EXEC usp_AccpacCreateDropdownValue 'prlumber_LastRunDate', '1/12/2016', 1, 'Lumber BB Last Run Date/Time'


UPDATE PRCompanyAlias SET pral_AliasMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(pral_Alias)) 
UPDATE PRPACALicense SET prpa_CompanyNameMatch = dbo.GetLowerAlpha(dbo.ufn_PrepareCompanyName(prpa_CompanyName)) 
Go


DELETE FROM PRLocalSourceRegion;
INSERT INTO PRLocalSourceRegion (prlsr_ServiceCode, prlsr_StateID, prlsr_CreatedBy, prlsr_UpdatedBy)
SELECT 'LSS', prst_StateID, -1, -1
  FROM PRState
 WHERE prst_CountryID IN(1, 2)

INSERT INTO PRLocalSourceRegion (prlsr_ServiceCode, prlsr_StateID, prlsr_CreatedBy, prlsr_UpdatedBy)
SELECT 'LSSLIC', prst_StateID, -1, -1
  FROM PRState
 WHERE prst_CountryID IN(1, 2)
Go

DELETE FROM ProductFamily WHERE prfa_ProductFamilyID = 15;
INSERT INTO ProductFamily
(prfa_ProductFamilyID, prfa_Name, prfa_Description, prfa_CreatedBy, prfa_CreatedDate, prfa_UpdatedBy, prfa_UpdatedDate, prfa_Timestamp)
VALUES (15, 'Local Source Data', 'Access to Local Source Data', -100, GETDATE(), -100, GETDATE(), GETDATE());
Go

--SELECT MAX(prod_ProductID) FROM NewProduct
DELETE FROM NewProduct WHERE prod_ProductID BETWEEN 83 AND 84
INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRRecurring,prod_PRSequence,prod_PRDescription,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (83, 'Y', 6000, 'Local Source Service', 'LSS', 15, ',P,S,T,', 'Y', 10, null,-1,GETDATE(),-1,GETDATE(),GETDATE());

INSERT INTO NewProduct
	   (Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRRecurring,prod_PRSequence,prod_PRDescription,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (84, 'Y', 6000, 'Local Source Service License', 'LSSLIC ', 15, ',P,S,T,', 'Y', 20, null,-1,GETDATE(),-1,GETDATE(),GETDATE());



Go



DELETE FROM PRBBOSPrivilege WHERE Privilege = 'LocalSourceDataAccess'
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('P', 200, 'LocalSourceDataAccess', 'LocalSourceDataAccess');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('T', 200, 'LocalSourceDataAccess', 'LocalSourceDataAccess');
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role) VALUES ('S', 200, 'LocalSourceDataAccess', 'LocalSourceDataAccess');
Go

UPDATE PRState SET prst_FIPSCode='01' WHERE prst_Abbreviation='AL'
UPDATE PRState SET prst_FIPSCode='02' WHERE prst_Abbreviation='AK'
UPDATE PRState SET prst_FIPSCode='04' WHERE prst_Abbreviation='AZ'
UPDATE PRState SET prst_FIPSCode='05' WHERE prst_Abbreviation='AR'
UPDATE PRState SET prst_FIPSCode='06' WHERE prst_Abbreviation='CA'
UPDATE PRState SET prst_FIPSCode='08' WHERE prst_Abbreviation='CO'
UPDATE PRState SET prst_FIPSCode='09' WHERE prst_Abbreviation='CT'
UPDATE PRState SET prst_FIPSCode='10' WHERE prst_Abbreviation='DE'
UPDATE PRState SET prst_FIPSCode='11' WHERE prst_Abbreviation='DC'
UPDATE PRState SET prst_FIPSCode='12' WHERE prst_Abbreviation='FL'
UPDATE PRState SET prst_FIPSCode='13' WHERE prst_Abbreviation='GA'
UPDATE PRState SET prst_FIPSCode='15' WHERE prst_Abbreviation='HI'
UPDATE PRState SET prst_FIPSCode='16' WHERE prst_Abbreviation='ID'
UPDATE PRState SET prst_FIPSCode='17' WHERE prst_Abbreviation='IL'
UPDATE PRState SET prst_FIPSCode='18' WHERE prst_Abbreviation='IN'
UPDATE PRState SET prst_FIPSCode='19' WHERE prst_Abbreviation='IA'
UPDATE PRState SET prst_FIPSCode='20' WHERE prst_Abbreviation='KS'
UPDATE PRState SET prst_FIPSCode='21' WHERE prst_Abbreviation='KY'
UPDATE PRState SET prst_FIPSCode='22' WHERE prst_Abbreviation='LA'
UPDATE PRState SET prst_FIPSCode='23' WHERE prst_Abbreviation='ME'
UPDATE PRState SET prst_FIPSCode='24' WHERE prst_Abbreviation='MD'
UPDATE PRState SET prst_FIPSCode='25' WHERE prst_Abbreviation='MA'
UPDATE PRState SET prst_FIPSCode='26' WHERE prst_Abbreviation='MI'
UPDATE PRState SET prst_FIPSCode='27' WHERE prst_Abbreviation='MN'
UPDATE PRState SET prst_FIPSCode='28' WHERE prst_Abbreviation='MS'
UPDATE PRState SET prst_FIPSCode='29' WHERE prst_Abbreviation='MO'
UPDATE PRState SET prst_FIPSCode='30' WHERE prst_Abbreviation='MT'
UPDATE PRState SET prst_FIPSCode='31' WHERE prst_Abbreviation='NE'
UPDATE PRState SET prst_FIPSCode='32' WHERE prst_Abbreviation='NV'
UPDATE PRState SET prst_FIPSCode='33' WHERE prst_Abbreviation='NH'
UPDATE PRState SET prst_FIPSCode='34' WHERE prst_Abbreviation='NJ'
UPDATE PRState SET prst_FIPSCode='35' WHERE prst_Abbreviation='NM'
UPDATE PRState SET prst_FIPSCode='36' WHERE prst_Abbreviation='NY'
UPDATE PRState SET prst_FIPSCode='37' WHERE prst_Abbreviation='NC'
UPDATE PRState SET prst_FIPSCode='38' WHERE prst_Abbreviation='ND'
UPDATE PRState SET prst_FIPSCode='39' WHERE prst_Abbreviation='OH'
UPDATE PRState SET prst_FIPSCode='40' WHERE prst_Abbreviation='OK'
UPDATE PRState SET prst_FIPSCode='41' WHERE prst_Abbreviation='OR'
UPDATE PRState SET prst_FIPSCode='42' WHERE prst_Abbreviation='PA'
UPDATE PRState SET prst_FIPSCode='44' WHERE prst_Abbreviation='RI'
UPDATE PRState SET prst_FIPSCode='45' WHERE prst_Abbreviation='SC'
UPDATE PRState SET prst_FIPSCode='46' WHERE prst_Abbreviation='SD'
UPDATE PRState SET prst_FIPSCode='47' WHERE prst_Abbreviation='TN'
UPDATE PRState SET prst_FIPSCode='48' WHERE prst_Abbreviation='TX'
UPDATE PRState SET prst_FIPSCode='49' WHERE prst_Abbreviation='UT'
UPDATE PRState SET prst_FIPSCode='50' WHERE prst_Abbreviation='VT'
UPDATE PRState SET prst_FIPSCode='51' WHERE prst_Abbreviation='VA'
UPDATE PRState SET prst_FIPSCode='53' WHERE prst_Abbreviation='WA'
UPDATE PRState SET prst_FIPSCode='54' WHERE prst_Abbreviation='WV'
UPDATE PRState SET prst_FIPSCode='55' WHERE prst_Abbreviation='WI'
UPDATE PRState SET prst_FIPSCode='56' WHERE prst_Abbreviation='WY'
UPDATE PRState SET prst_FIPSCode='66' WHERE prst_Abbreviation='GU'
UPDATE PRState SET prst_FIPSCode='72' WHERE prst_Abbreviation='PR'
UPDATE PRState SET prst_FIPSCode='78' WHERE prst_Abbreviation='VI'
Go

ALTER TABLE PRCompanyProfile DISABLE TRIGGER ALL
UPDATE PRCompanyProfile SET prcp_Organic=NULL WHERE prcp_Organic='Y'
ALTER TABLE PRCompanyProfile ENABLE TRIGGER ALL
Go



DECLARE @MyTable table (
    ndx int identity(1,1),
	CompanyID int,
	FoodSafety char(1),
	Organic char(1))


INSERT INTO @MyTable VALUES(100563, NULL, 'Y');
INSERT INTO @MyTable VALUES(100586, 'Y', 'Y');
INSERT INTO @MyTable VALUES(100664, NULL, 'Y');
INSERT INTO @MyTable VALUES(100699, NULL, 'Y');
INSERT INTO @MyTable VALUES(101211, 'Y', NULL);
INSERT INTO @MyTable VALUES(101654, NULL, 'Y');
INSERT INTO @MyTable VALUES(101974, NULL, 'Y');
INSERT INTO @MyTable VALUES(102313, 'Y', NULL);
INSERT INTO @MyTable VALUES(102585, 'Y', 'Y');
INSERT INTO @MyTable VALUES(102627, 'Y', NULL);
INSERT INTO @MyTable VALUES(102948, 'Y', NULL);
INSERT INTO @MyTable VALUES(103466, 'Y', NULL);
INSERT INTO @MyTable VALUES(103590, 'Y', NULL);
INSERT INTO @MyTable VALUES(104059, 'Y', NULL);
INSERT INTO @MyTable VALUES(104166, 'Y', NULL);
INSERT INTO @MyTable VALUES(105318, 'Y', NULL);
INSERT INTO @MyTable VALUES(105381, 'Y', NULL);
INSERT INTO @MyTable VALUES(105855, NULL, 'Y');
INSERT INTO @MyTable VALUES(106111, 'Y', NULL);
INSERT INTO @MyTable VALUES(106346, 'Y', NULL);
INSERT INTO @MyTable VALUES(106821, 'Y', NULL);
INSERT INTO @MyTable VALUES(107378, 'Y', NULL);
INSERT INTO @MyTable VALUES(108483, 'Y', NULL);
INSERT INTO @MyTable VALUES(108533, 'Y', NULL);
INSERT INTO @MyTable VALUES(108919, NULL, 'Y');
INSERT INTO @MyTable VALUES(108922, 'Y', 'Y');
INSERT INTO @MyTable VALUES(108926, 'Y', NULL);
INSERT INTO @MyTable VALUES(109239, 'Y', NULL);
INSERT INTO @MyTable VALUES(111322, NULL, 'Y');
INSERT INTO @MyTable VALUES(111582, 'Y', NULL);
INSERT INTO @MyTable VALUES(111667, 'Y', NULL);
INSERT INTO @MyTable VALUES(111825, 'Y', NULL);
INSERT INTO @MyTable VALUES(111920, 'Y', NULL);
INSERT INTO @MyTable VALUES(112311, 'Y', NULL);
INSERT INTO @MyTable VALUES(112357, 'Y', 'Y');
INSERT INTO @MyTable VALUES(112624, 'Y', NULL);
INSERT INTO @MyTable VALUES(113025, NULL, 'Y');
INSERT INTO @MyTable VALUES(113032, 'Y', 'Y');
INSERT INTO @MyTable VALUES(113983, 'Y', NULL);
INSERT INTO @MyTable VALUES(114146, 'Y', NULL);
INSERT INTO @MyTable VALUES(115608, 'Y', NULL);
INSERT INTO @MyTable VALUES(115759, 'Y', NULL);
INSERT INTO @MyTable VALUES(116171, 'Y', NULL);
INSERT INTO @MyTable VALUES(117058, 'Y', NULL);
INSERT INTO @MyTable VALUES(117489, 'Y', NULL);
INSERT INTO @MyTable VALUES(119672, 'Y', NULL);
INSERT INTO @MyTable VALUES(119688, 'Y', NULL);
INSERT INTO @MyTable VALUES(122214, 'Y', NULL);
INSERT INTO @MyTable VALUES(123615, 'Y', NULL);
INSERT INTO @MyTable VALUES(123960, 'Y', NULL);
INSERT INTO @MyTable VALUES(123997, 'Y', NULL);
INSERT INTO @MyTable VALUES(124213, 'Y', NULL);
INSERT INTO @MyTable VALUES(124467, 'Y', NULL);
INSERT INTO @MyTable VALUES(125105, 'Y', NULL);
INSERT INTO @MyTable VALUES(125199, 'Y', NULL);
INSERT INTO @MyTable VALUES(125542, 'Y', NULL);
INSERT INTO @MyTable VALUES(126045, 'Y', 'Y');
INSERT INTO @MyTable VALUES(126523, 'Y', NULL);
INSERT INTO @MyTable VALUES(129226, 'Y', NULL);
INSERT INTO @MyTable VALUES(129812, 'Y', NULL);
INSERT INTO @MyTable VALUES(130476, 'Y', NULL);
INSERT INTO @MyTable VALUES(131769, 'Y', NULL);
INSERT INTO @MyTable VALUES(132688, 'Y', NULL);
INSERT INTO @MyTable VALUES(132995, 'Y', NULL);
INSERT INTO @MyTable VALUES(135856, NULL, 'Y');
INSERT INTO @MyTable VALUES(135894, 'Y', NULL);
INSERT INTO @MyTable VALUES(136024, 'Y', NULL);
INSERT INTO @MyTable VALUES(138315, 'Y', NULL);
INSERT INTO @MyTable VALUES(138730, 'Y', NULL);
INSERT INTO @MyTable VALUES(139230, 'Y', NULL);
INSERT INTO @MyTable VALUES(145898, 'Y', NULL);
INSERT INTO @MyTable VALUES(146007, 'Y', NULL);
INSERT INTO @MyTable VALUES(148144, 'Y', NULL);
INSERT INTO @MyTable VALUES(148871, 'Y', NULL);
INSERT INTO @MyTable VALUES(149314, 'Y', NULL);
INSERT INTO @MyTable VALUES(150037, 'Y', NULL);
INSERT INTO @MyTable VALUES(150946, 'Y', NULL);
INSERT INTO @MyTable VALUES(151227, 'Y', NULL);
INSERT INTO @MyTable VALUES(151958, 'Y', NULL);
INSERT INTO @MyTable VALUES(152300, 'Y', NULL);
INSERT INTO @MyTable VALUES(152422, 'Y', NULL);
INSERT INTO @MyTable VALUES(153854, NULL, 'Y');
INSERT INTO @MyTable VALUES(154121, 'Y', NULL);
INSERT INTO @MyTable VALUES(154315, 'Y', NULL);
INSERT INTO @MyTable VALUES(154589, 'Y', 'Y');
INSERT INTO @MyTable VALUES(154645, 'Y', NULL);
INSERT INTO @MyTable VALUES(154811, NULL, 'Y');
INSERT INTO @MyTable VALUES(156421, 'Y', NULL);
INSERT INTO @MyTable VALUES(156638, 'Y', NULL);
INSERT INTO @MyTable VALUES(157367, 'Y', NULL);
INSERT INTO @MyTable VALUES(157519, 'Y', NULL);
INSERT INTO @MyTable VALUES(158129, 'Y', NULL);
INSERT INTO @MyTable VALUES(158288, 'Y', NULL);
INSERT INTO @MyTable VALUES(158417, NULL, 'Y');
INSERT INTO @MyTable VALUES(158727, 'Y', NULL);
INSERT INTO @MyTable VALUES(158898, NULL, 'Y');
INSERT INTO @MyTable VALUES(159253, 'Y', NULL);
INSERT INTO @MyTable VALUES(159354, 'Y', NULL);
INSERT INTO @MyTable VALUES(159451, 'Y', NULL);
INSERT INTO @MyTable VALUES(159478, 'Y', NULL);
INSERT INTO @MyTable VALUES(159813, 'Y', NULL);
INSERT INTO @MyTable VALUES(159941, 'Y', NULL);
INSERT INTO @MyTable VALUES(160181, 'Y', 'Y');
INSERT INTO @MyTable VALUES(160553, 'Y', NULL);
INSERT INTO @MyTable VALUES(161231, 'Y', NULL);
INSERT INTO @MyTable VALUES(162268, 'Y', NULL);
INSERT INTO @MyTable VALUES(163623, 'Y', NULL);
INSERT INTO @MyTable VALUES(164466, 'Y', NULL);
INSERT INTO @MyTable VALUES(164545, 'Y', NULL);
INSERT INTO @MyTable VALUES(165483, 'Y', NULL);
INSERT INTO @MyTable VALUES(166070, 'Y', NULL);
INSERT INTO @MyTable VALUES(166109, 'Y', NULL);
INSERT INTO @MyTable VALUES(166121, 'Y', NULL);
INSERT INTO @MyTable VALUES(166167, NULL, 'Y');
INSERT INTO @MyTable VALUES(166527, 'Y', NULL);
INSERT INTO @MyTable VALUES(167021, 'Y', NULL);
INSERT INTO @MyTable VALUES(167342, 'Y', 'Y');
INSERT INTO @MyTable VALUES(167592, 'Y', 'Y');
INSERT INTO @MyTable VALUES(167640, 'Y', NULL);
INSERT INTO @MyTable VALUES(168261, 'Y', NULL);
INSERT INTO @MyTable VALUES(168576, NULL, 'Y');
INSERT INTO @MyTable VALUES(168634, 'Y', NULL);
INSERT INTO @MyTable VALUES(169094, 'Y', NULL);
INSERT INTO @MyTable VALUES(169520, 'Y', NULL);
INSERT INTO @MyTable VALUES(169863, NULL, 'Y');
INSERT INTO @MyTable VALUES(169987, 'Y', NULL);
INSERT INTO @MyTable VALUES(170470, 'Y', NULL);
INSERT INTO @MyTable VALUES(170802, 'Y', NULL);
INSERT INTO @MyTable VALUES(171219, 'Y', NULL);
INSERT INTO @MyTable VALUES(171238, 'Y', NULL);
INSERT INTO @MyTable VALUES(171271, 'Y', NULL);
INSERT INTO @MyTable VALUES(171501, 'Y', NULL);
INSERT INTO @MyTable VALUES(171776, 'Y', NULL);
INSERT INTO @MyTable VALUES(172128, 'Y', NULL);
INSERT INTO @MyTable VALUES(172265, 'Y', NULL);
INSERT INTO @MyTable VALUES(172545, 'Y', NULL);
INSERT INTO @MyTable VALUES(172576, 'Y', NULL);
INSERT INTO @MyTable VALUES(173326, 'Y', NULL);
INSERT INTO @MyTable VALUES(174782, 'Y', NULL);
INSERT INTO @MyTable VALUES(175539, 'Y', NULL);
INSERT INTO @MyTable VALUES(186849, 'Y', NULL);
INSERT INTO @MyTable VALUES(186877, 'Y', NULL);
INSERT INTO @MyTable VALUES(187284, 'Y', NULL);
INSERT INTO @MyTable VALUES(187336, 'Y', NULL);
INSERT INTO @MyTable VALUES(189555, NULL, 'Y');
INSERT INTO @MyTable VALUES(189630, 'Y', NULL);
INSERT INTO @MyTable VALUES(190775, 'Y', NULL);
INSERT INTO @MyTable VALUES(191838, 'Y', 'Y');
INSERT INTO @MyTable VALUES(193327, NULL, 'Y');
INSERT INTO @MyTable VALUES(194064, 'Y', NULL);
INSERT INTO @MyTable VALUES(194141, 'Y', NULL);
INSERT INTO @MyTable VALUES(194319, NULL, 'Y');
INSERT INTO @MyTable VALUES(196583, 'Y', NULL);
INSERT INTO @MyTable VALUES(197424, 'Y', NULL);
INSERT INTO @MyTable VALUES(205699, 'Y', NULL);
INSERT INTO @MyTable VALUES(206204, 'Y', NULL);
INSERT INTO @MyTable VALUES(207113, NULL, 'Y');
INSERT INTO @MyTable VALUES(207232, 'Y', 'Y');
INSERT INTO @MyTable VALUES(207768, NULL, 'Y');
INSERT INTO @MyTable VALUES(208569, 'Y', NULL);
INSERT INTO @MyTable VALUES(209447, 'Y', NULL);
INSERT INTO @MyTable VALUES(209564, 'Y', NULL);
INSERT INTO @MyTable VALUES(254788, 'Y', NULL);
INSERT INTO @MyTable VALUES(260145, 'Y', NULL);
INSERT INTO @MyTable VALUES(260172, 'Y', NULL);
INSERT INTO @MyTable VALUES(260549, 'Y', NULL);
INSERT INTO @MyTable VALUES(263415, 'Y', NULL);
INSERT INTO @MyTable VALUES(269730, 'Y', NULL);
INSERT INTO @MyTable VALUES(270484, 'Y', 'Y');
INSERT INTO @MyTable VALUES(270697, NULL, 'Y');
INSERT INTO @MyTable VALUES(277905, 'Y', NULL);
INSERT INTO @MyTable VALUES(277972, 'Y', NULL);
INSERT INTO @MyTable VALUES(281607, 'Y', NULL);
INSERT INTO @MyTable VALUES(283980, 'Y', NULL);
INSERT INTO @MyTable VALUES(284562, 'Y', 'Y');
INSERT INTO @MyTable VALUES(285258, 'Y', NULL);
INSERT INTO @MyTable VALUES(292616, 'Y', NULL);
INSERT INTO @MyTable VALUES(292825, 'Y', 'Y');
INSERT INTO @MyTable VALUES(294028, 'Y', NULL);
INSERT INTO @MyTable VALUES(295338, 'Y', NULL);
INSERT INTO @MyTable VALUES(296302, 'Y', NULL);
INSERT INTO @MyTable VALUES(297479, 'Y', NULL);
INSERT INTO @MyTable VALUES(298063, 'Y', NULL);
INSERT INTO @MyTable VALUES(298718, 'Y', 'Y');
INSERT INTO @MyTable VALUES(298977, 'Y', NULL);
INSERT INTO @MyTable VALUES(301173, 'Y', NULL);



DECLARE @Count int, @Index int
DECLARE @CompanyID int, @FoodSafety char(1), @Organic char(1)
DECLARE @RecordID int

SELECT @Count = COUNT(1) FROM @MyTable
SET @Index = 1

WHILE (@Index <= @Count) BEGIN

	SELECT @CompanyID = CompanyID,
	       @FoodSafety = FoodSafety,
		   @Organic = Organic
	  FROM @MyTable
	 WHERE ndx = @Index;

	 Print 'Processing CompanyID ' + CAST(@CompanyID as varchar(10))

	 IF EXISTS(SELECT 'x' FROM PRCompanyProfile WHERE prcp_CompanyID = @CompanyID) BEGIN

		Print '- Updating'
		ALTER TABLE PRCompanyProfile DISABLE TRIGGER ALL
		UPDATE PRCompanyProfile
		   SET prcp_FoodSafetyCertified = @FoodSafety,
			   prcp_Organic = @Organic,
			   prcp_UpdatedBy = 1,
			   prcp_UpdatedDate = GETDATE(),
			   prcp_Timestamp = GETDATE()
		 WHERE prcp_CompanyID = @CompanyID
		ALTER TABLE PRCompanyProfile ENABLE TRIGGER ALL

	 END ELSE BEGIN
	    Print '- Inserting'
		EXEC usp_GetNextId 'PRCompanyProfile', @RecordID output

		ALTER TABLE PRCompanyProfile DISABLE TRIGGER ALL
		INSERT INTO PRCompanyProfile (prcp_CompanyProfileId, prcp_CompanyID, prcp_FoodSafetyCertified, prcp_Organic, prcp_CreatedBy, prcp_CreatedDate, prcp_UpdatedBy, prcp_UpdatedDate, prcp_Timestamp)
         VALUES (@RecordID, @CompanyID, @FoodSafety, @Organic, 1, GETDATE(), 1, GETDATE(), GETDATE());
		ALTER TABLE PRCompanyProfile ENABLE TRIGGER ALL
	 END 

	 SET @Index = @Index + 1
END
Go