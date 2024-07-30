DELETE FROM Pricing WHERE pric_ProductID=83
INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
VALUES (72, 83, 350, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE());

DELETE FROM Pricing WHERE pric_ProductID=84
INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
VALUES (73, 84, 100, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE());
Go


DELETE FROM PRBBOSPrivilege WHERE Privilege = 'CompanyDetailsARReportsPage'
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('P', 200, 'CompanyDetailsARReportsPage', 'ARReportAccess', 1, 0);
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('S', 200, 'CompanyDetailsARReportsPage', 'ARReportAccess', 1, 0);
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Role, Visible, Enabled) VALUES ('T', 200, 'CompanyDetailsARReportsPage', 'ARReportAccess', 1, 0);
GO

DELETE FROM PRBBOSPrivilege WHERE Privilege = 'PersonDataExport'
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('P', 500, 'PersonDataExport', 1, 0);
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('S', 500, 'PersonDataExport', 1, 0);
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('T', 500, 'PersonDataExport', 1, 0);
GO

ALTER TABLE Person_Link DISABLE TRIGGER ALL
UPDATE Person_Link
   SET peli_PRSequence = TitleCodeOrder
  FROM (SELECT peli_CompanyID,
			   peli_PersonLinkID, 
			   peli_PRTitleCode, 
			   tcc.capt_order as TitleCodeOrder,
			   ROW_NUMBER() OVER (PARTITION BY peli_CompanyID ORDER BY tcc.capt_order) as Sequence
		  FROM Person_Link WITH (NOLOCK) 
 			   INNER JOIN custom_captions tcc WITH (NOLOCK) ON tcc.capt_family = 'pers_TitleCode' and tcc.capt_code = peli_PRTitleCode 
		 WHERE peli_CompanyID NOT IN (189555, 152652, 170030, 104366, 156704)) T1
WHERE Person_Link.peli_PersonLinkID = T1.peli_PersonLinkID
ALTER TABLE Person_Link ENABLE TRIGGER ALL

UPDATE Company SET comp_PRHasCustomPersonSort = 'Y' WHERE comp_CompanyID IN (189555, 152652, 170030, 104366, 156704);
Go

UPDATE PRCountry SET prcn_ContinentCode='SA', prcn_Region='SA' WHERE prcn_CountryID=40

UPDATE PRClassification
                SET prcl_CompanyCountIncludeLocalSource = T1.CompanyCount 
                    FROM (SELECT prcl_ClassificationID, COUNT(comp_CompanyID) AS CompanyCount 
                            FROM PRClassification
                                 LEFT OUTER JOIN PRCompanyClassification ON prcl_ClassificationID = prc2_ClassificationID
                                 LEFT OUTER JOIN Company WITH (NOLOCK) ON prc2_CompanyID = comp_CompanyID AND comp_PRListingStatus IN ('L', 'H', 'LUV') 
                        GROUP BY prcl_ClassificationID) T1 
                  WHERE PRClassification.prcl_ClassificationID = T1.prcl_ClassificationID;
Go


ALTER TABLE Company DISABLE TRIGGER ALL
UPDATE Company SET comp_PRARReportAccess = 'Y' WHERE comp_CompanyID IN (100002, 204482)
ALTER TABLE Company ENABLE TRIGGER ALL
Go

ALTER TABLE PRCompanyInfoProfile DISABLE TRIGGER ALL
UPDATE PRCompanyInfoProfile SET prc5_ReceiveARReminder = 'Y' WHERE prc5_CompanyID IN (264405,263253,290549,233403,263419,258937,259128,211361)
ALTER TABLE PRCompanyInfoProfile ENABLE TRIGGER ALL

DELETE FROM PRAttribute WHERE prat_AttributeId = 1002
INSERT INTO PRAttribute (prat_AttributeId, prat_Name, prat_Type, prat_Abbreviation, prat_PlacementAfter, prat_CreatedBy, prat_CreatedDate, prat_UpdatedBy, prat_UpdatedDate, prat_Timestamp)
VALUES (1002, 'Puree', 'ST', 'puree', 'Y', 3, GETDATE(), 3, GETDATE(), GETDATE());
Go
