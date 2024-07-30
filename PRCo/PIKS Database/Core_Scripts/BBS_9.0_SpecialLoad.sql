--9.0 Special Load

--Run 9.0 and 9.0 DataCorrections
--Run full 9.0 Custom_Captions_File
--Then run special SQL below

--DropDownValues.sql

exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-13-01', 144, 'NM/TX/S.W. CO' /* PRCity */
exec usp_TravantCRM_CreateDropdownValue 'prci_SalesTerritory', 'WC-13-02', 145, 'AZ' /* PRCity */

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignType', 'CSEU', 125, 'Credit Sheet/Express Update Ad'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_AdCampaignTypeDigital', 'CSEU', 100, 'Credit Sheet/Express Update Ad'

exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'BD',       148, 'Barn Door'
exec usp_TravantCRM_CreateDropdownValue 'pradc_Placement', 'BTN',  160, 'By the Numbers'

exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'BD',  148, 'Barn Door'
exec usp_TravantCRM_CreateDropdownValue 'pradc_PlacementBP', 'BTN',  160, 'By the Numbers'

EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '309', 4600, 'Broccoli'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '263', 4700, 'Bakersfield'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection', '262', 4800, 'Santa Maria'

DELETE FROM Custom_Captions WHERE capt_family = 'pradc_PlannedSection_Curr'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '200', 10, 'Apples'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '300', 20, 'Avocados'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '286', 30, 'Back Feature'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '263', 40, 'Bakersfield'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '250', 50, 'Berries'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '212', 60, 'Boston'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '309', 70, 'Broccoli'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '307', 80, 'California'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '236', 90, 'Canada'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '270', 100, 'Carolinas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '252', 110, 'Carrots'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '201', 120, 'Cherries'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '213', 130, 'Chicago'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '255', 140, 'Citrus'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '223', 150, 'Dallas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '214', 160, 'Detroit'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '215', 170, 'Florida'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '285', 180, 'Front Feature'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '211', 190, 'Georgia'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '305', 200, 'Global Trade'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '202', 210, 'Grapes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '238', 220, 'Hispanic'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '239', 230, 'Import/Export'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '209', 240, 'KYC - Commodity Basics'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '210', 250, 'KYC Sponsor'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '301', 260, 'Lemons & Limes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '257', 270, 'Lettuce'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '265', 280, 'Los Angeles'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '224', 290, 'Maryland'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '258', 300, 'Melons'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '227', 310, 'Miami'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '228', 320, 'Midwest'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '216', 330, 'Montreal'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '259', 340, 'NA Summer Production'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '220', 350, 'New In Blue'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '231', 360, 'New Jersey'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '306', 370, 'New Product Showcase'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '217', 380, 'New York'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '229', 390, 'Nogales'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '275', 400, 'Ohio'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '221', 410, 'On the Job'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '203', 420, 'Onions & Potatoes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '244', 430, 'Ontario'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '280', 440, 'Oregon'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '260', 450, 'Organics'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '261', 460, 'Peppers'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '218', 470, 'Philly'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '243', 480, 'Rio Grande Valley'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '303', 490, 'Root Vegetables'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '230', 500, 'Salinas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '262', 510, 'Santa Maria'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '290', 520, 'Special Content'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '241', 530, 'Texas'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '308', 540, 'TM Spotlight Advertorial'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '208', 550, 'TM/FM Milestone'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '304', 560, 'Tomatoes'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '242', 570, 'Top Topics'
EXEC usp_TravantCRM_CreateDropdownValue 'pradc_PlannedSection_Curr', '240', 580, 'Transportation'

--DELETE FROM Custom_Captions WHERE capt_Family = 'prcta_TradeAssociationURL'
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'AGEXPORT', 2, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'AMCHAM', 3, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prcta_TradeAssociationURL', 'AMHPAC', 5, ''


DELETE FROM Custom_captions WHERE Capt_Family = 'prcoml_FailedTypeCode'
exec usp_TravantCRM_CreateDropdownValue 'prcoml_FailedTypeCode', 'BLK', 10, 'Blocked'
exec usp_TravantCRM_CreateDropdownValue 'prcoml_FailedTypeCode', 'BNC', 20, 'Bounced'
Go

DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr_StatusCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr_StatusCode', 'P', 10, 'Pending'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr_StatusCode', 'IP', 20, 'In Progress'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr_StatusCode', 'S', 30, 'Sent'

DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr2_SubjectCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_SubjectCode', 'C', 10, 'Company'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_SubjectCode', 'P', 20, 'Person'

-- Master List
DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr2_QuestionCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C01', 10, 'OFAC Listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C02', 20, 'Global Sanctions'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C03', 30, 'Prison Address On Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C04', 40, 'P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C05', 50, 'Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C06', 60, 'Marijuana Related Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C07', 70, 'Business Address Used as Residential Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C08', 80, 'Other Listings Linked to Business Phone Number'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C09', 90, 'Other Businesses Linked to the Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C10', 100, 'Other Businesses Linked to Same FEIN'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C11', 110, 'Key Nature of Suite'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C12', 120, 'Pending Class Action'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C13', 130, 'Going Concern'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'C14', 140, 'MSB listing'

EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P01', 10, 'Real-Time Incarceration & Arrest Records'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P02', 20, 'Associate with OFAC, Global Sanction or PEP listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P03', 30, 'OFAC listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P04', 40, 'Global Sanctions'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P05', 50, 'Residential Address Used as a Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P06', 60, 'Prison Address on Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P07', 70, 'P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P08', 80, 'Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P09', 90, 'Persona Associated with Marijuana Related Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P10', 100, 'Associate or Relative With a Residential Address Used as a Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P11', 110, 'Associate or Relative with a Prison Address on Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P12', 120, 'Associate or Relative with P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P13', 130, 'Criminal Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P14', 140, 'Criminal Record – Low Level Traffic Offense'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P15', 150, 'Sex Offender Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P16', 160, 'Criminal Record – Uncategorized'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P17', 170, 'Multiple SSNs'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P18', 180, 'SSN Matches multiple individuals'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P19', 190, 'Recorded as Deceased'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P20', 200, 'Age Younger than SSN Issue Date'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P21', 210, 'SSN Format is Invalid'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P22', 220, 'SSN is an ITIN'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P23', 230, 'Address First Reported <90 Days'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P24', 240, 'Telephone Number Inconsistent with Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCode', 'P25', 250, 'Arrest Record'


-- Company Quesitons
DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr2_QuestionCodeCompany'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C01', 10, 'OFAC Listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C02', 20, 'Global Sanctions'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C03', 30, 'Prison Address On Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C04', 40, 'P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C05', 50, 'Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C06', 60, 'Marijuana Related Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C07', 70, 'Business Address Used as Residential Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C08', 80, 'Other Listings Linked to Business Phone Number'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C09', 90, 'Other Businesses Linked to the Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C10', 100, 'Other Businesses Linked to Same FEIN'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C11', 110, 'Key Nature of Suite'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C12', 120, 'Pending Class Action'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C13', 130, 'Going Concern'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodeCompany', 'C14', 140, 'MSB listing'

-- Person Questions
DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr2_QuestionCodePerson'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P01', 10, 'Real-Time Incarceration & Arrest Records'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P02', 20, 'Associate with OFAC, Global Sanction or PEP listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P03', 30, 'OFAC listing'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P04', 40, 'Global Sanctions'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P05', 50, 'Residential Address Used as a Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P06', 60, 'Prison Address on Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P07', 70, 'P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P08', 80, 'Bankruptcy'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P09', 90, 'Persona Associated with Marijuana Related Business'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P10', 100, 'Associate or Relative With a Residential Address Used as a Business Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P11', 110, 'Associate or Relative with a Prison Address on Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P12', 120, 'Associate or Relative with P.O. Box listed as Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P13', 130, 'Criminal Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P14', 140, 'Criminal Record – Low Level Traffic Offense'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P15', 150, 'Sex Offender Record'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P16', 160, 'Criminal Record – Uncategorized'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P17', 170, 'Multiple SSNs'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P18', 180, 'SSN Matches multiple individuals'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P19', 190, 'Recorded as Deceased'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P20', 200, 'Age Younger than SSN Issue Date'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P21', 210, 'SSN Format is Invalid'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P22', 220, 'SSN is an ITIN'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P23', 230, 'Address First Reported <90 Days'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P24', 240, 'Telephone Number Inconsistent with Address'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_QuestionCodePerson', 'P25', 250, 'Arrest Record'


DELETE FROM Custom_captions WHERE Capt_Family = 'prbcr2_ResponseCode'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_ResponseCode', '', 0, ''
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_ResponseCode', 'Y', 10, 'Yes'
EXEC usp_TravantCRM_CreateDropdownValue 'prbcr2_ResponseCode', 'N', 20, 'No'
Go


/* PRWebUSER table values */
/* prwu_AccessLevel */
--exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '5', 5, 'Restricted User' 
--exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '7', 7, 'Restricted Access - Plus' 
--exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '10', 10, 'Registered User' 
DELETE FROM custom_captions WHERE capt_familyType='Choices' AND capt_Family = 'prwu_AccessLevel';
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '100', 100, 'Limitado Access' 
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '200', 200, 'Limited Access' 
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '300', 300, 'Basic Access' 
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '350', 350, 'Basic Plus Access' 
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '400', 400, 'Standard Access' 
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '500', 500, 'Advanced Access' 
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '600', 600, 'Advanced Plus Access' 
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '700', 700, 'Premium Access' 
exec usp_TravantCRM_CreateDropdownValue 'prwu_AccessLevel', '999999', 999999, 'System Admin Access' 



--Listing Functions
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingInternetBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingInternetBlock]
GO
CREATE FUNCTION [dbo].[ufn_GetListingInternetBlock] ( 
    @CompanyId int,
    @LineBreakChar nvarchar(50)
)
RETURNS varchar(5000)
AS
BEGIN
/*  DEBUGGING BLOCK
    DECLARE @CompanyId int; SET @CompanyId = 
    DECLARE @LineBreakChar nvarchar(50); SET @LineBreakChar = CHAR(10)
	DECLARE @LogoLineSize int; SET @LogoLineSize= 22
	DECLARE @LineLimit int; SET @LineLimit= 0
*/
	DECLARE @LineSize int; SET @LineSize= 34
    DECLARE @RetVal varchar(5000)
	DECLARE @Line varchar(5000)
    DECLARE @Delimiter varchar(4), @DelimiterIndex int
    IF (@LineBreakChar IS NULL)
        SET @LineBreakChar = '<br/>'
	Declare @EmailCount int
	DECLARE @Emails TABLE (emai_ndx int identity,
			emai_type varchar(100), emai_typecode varchar(40), 
			emai_Description varchar(100), emai_Address varchar(255)
	)
	DECLARE @Ndx int, @Type varchar(100), @TypeCode varchar(40), 
			@Description varchar(100), @Address varchar(255)
	INSERT INTO @Emails
		SELECT Capt_US, RTRIM(elink_Type) AS TypeCode, 
				COALESCE(emai_PRDescription + ': ',''),
				CASE WHEN RTRIM(elink_Type) = 'W' THEN RTRIM(emai_PRWebAddress) ELSE RTRIM(emai_EmailAddress) END
		  FROM vCompanyEmail WITH (NOLOCK) 
		       INNER JOIN Custom_Captions WITH (NOLOCK) on elink_Type = capt_Code and capt_Family='emai_Type'
		 WHERE elink_RecordID = @CompanyId
		   AND emai_PRPublish = 'Y' 
		   AND emai_Deleted IS NULL 
		ORDER BY elink_Type, emai_PRSequence;

	SELECT @EmailCount = count (1) from @Emails
	SET @Ndx = 1
	SET @Line = ''
	DECLARE @Conjunction varchar(5); SET @Conjunction = '';
	DECLARE @ValueToAppend varchar(255); SET @ValueToAppend = '';
	-- GroupTotal is the number of emails in the same type and desc
	-- GroupCount is our counter to tell which rec of the group we are processing
	-- These are most likely going to be 1 but we will leave as is for future flexability
	DECLARE @GroupCount int, @GroupTotal int 
	SET @GroupCount = 1;
	SET @GroupTotal = -1;
	WHILE (@Ndx <= @EmailCount) BEGIN
		-- Get the current record from our temp table
		SELECT @Type = emai_type, @TypeCode = emai_typecode, 
				@Description = emai_Description, @Address = emai_Address
		  FROM @Emails
		 WHERE emai_ndx = @Ndx
		SET @Conjunction = ''
		-- Determine if we need a new group
		IF (@GroupCount > @GroupTotal) BEGIN
			SELECT @GroupTotal = count (1) 
			  FROM @Emails 
			 WHERE emai_Type = @Type AND emai_Description = @Description
			SET @GroupCount = 1 
			SET @Line = ''
		END
		-- if this is the second to last line, use "or"
		-- if this is the last line of a group, use nothing
		-- otherwise, use a comma
		IF (@GroupCount = @GroupTotal -1 )
			SET @Conjunction = ' or '
		ELSE IF (@GroupCount != @GroupTotal)  
			SET @Conjunction = ', '
		SET @ValueToAppend = ''
		IF (@GroupCount != 1) BEGIN
			SET @Description = ''
		END
			IF (LEN(@Description) + LEN(@Address) + 1 + LEN(RTRIM(@Conjunction)) > @LineSize - LEN(@Line) ) BEGIN
				-- for web addresses, we allow the www. to try to exist on the same line
				IF (@Line != '' and @TypeCode = 'E') BEGIN
					SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Line
					SET @Line = ''
				END
				-- we need to break the line
				-- set our delimiter 
				IF (@TypeCode = 'E') BEGIN 
					SET @Delimiter = '@'
					SET @DelimiterIndex = CHARINDEX('@', @Address)
				END ELSE BEGIN
					SET @Delimiter = 'www.'
					SET @DelimiterIndex = 1
				END
				-- we need to see if the address exceeds our line size
				IF (LEN(@Address) + LEN(RTRIM(@Conjunction)) <= @LineSize) BEGIN				
					IF (@Line != '' and @TypeCode = 'W') BEGIN
						SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Line
						SET @Line = ''
					END

					IF (@Description != '') BEGIN
						SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + dbo.ufn_ApplyListingLineBreaks(@Description, @LineBreakChar)
					END

				END ELSE BEGIN
					DECLARE @Value varchar(255)
					DECLARE @PostDelimiter varchar(500)
					IF (@TypeCode = 'E') BEGIN 
						-- determine what exists before the delimiter
						SET @Value = SUBSTRING(@Address, 1, @DelimiterIndex + LEN(@Delimiter) -1)
						SET @PostDelimiter = SUBSTRING(@Address, @DelimiterIndex+1, LEN(@Address) -1)
						IF (LEN(@Description) + Len(@Value) > @LineSize)
						BEGIN
							-- description goes to it's own line and gets cleared
							IF (@Description != '')
								SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Description
							SET @Description = ''
							IF (Len(@PostDelimiter) > @LineSize) BEGIN
								SET @Value = @Value + @PostDelimiter
								SET @PostDelimiter = ''
							END 
						-- description and delimiter go on one line
						END ELSE BEGIN

							SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Description + @Value
							SET @Value = @PostDelimiter
							SET @PostDelimiter = ''
/*
							-- if the @PostDelimiter alone is > linesize, just wrap everything at linesize
							IF (Len(@PostDelimiter) > @LineSize) BEGIN
								SET @Value = @Value + @PostDelimiter
							END ELSE BEGIN
								SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Description + @Value
								SET @Value = @PostDelimiter
							END
							SET @PostDelimiter = ''
*/
						END
						WHILE (Len(@Value) > @LineSize)
						BEGIN
							SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + SUBSTRING(@Value, 1, @LineSize)
							SET @Value = SUBSTRING(@Value, @LineSize+1, LEN(@Value)-1)								
						END
						IF (Len(@Value) + Len(@PostDelimiter) > @LineSize) BEGIN
							SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Value
							SET @Address = @PostDelimiter
						END ELSE BEGIN
							SET @Address = @Value + @PostDelimiter
						END
					END ELSE BEGIN
						-- if there is anything left on line, set it as the descrition
						IF (@Line != '') BEGIN
							SET @Description = @Line + @Description
							SET @Line = ''
						END						
						-- determine what exists after the delimiter
						--SET @Value = SUBSTRING(@Address, @DelimiterIndex+LEN(@Delimiter), LEN(@Address) -1)
						IF (@Address LIKE 'www.%') BEGIN				
							-- determine what exists after the delimiter
							SET @Value = SUBSTRING(@Address, @DelimiterIndex+LEN(@Delimiter), LEN(@Address) -1)
						END ELSE BEGIN
							SET @Value = @Address
						END

						IF (LEN(@Description) + Len(@Address) > @LineSize)
						BEGIN
							-- if just the address after the www. is > linesize, don't split the delimiter out
							IF (Len(@Value) > @LineSize) BEGIN
								SET @Value = @Description + @Address
								SET @Description = ''								
							END ELSE BEGIN
								-- Otherwise, add the description and delimiter
								SET @Description = @Description + @Delimiter
							END
							-- description goes to it's own line and gets cleared
							IF (@Description != '') BEGIN
								SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Description
								SET @Description = ''
							END
							WHILE (Len(@Value) > 34)
							BEGIN
								SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + SUBSTRING(@Value, 1, 34)
								SET @Value = SUBSTRING(@Value, 35, LEN(@Value)-1)								
							END	
							SET @Address = @Value
						END
					END
				END
			END ELSE BEGIN
				SET @Address = @Description + @Address
			END
		IF ( LEN(@Address) + LEN(RTRIM(@Conjunction)) <= 34 )
			SET @Line = @Address + @Conjunction
		ELSE BEGIN
			SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Address
			SET @Line = LTRIM(@Conjunction)
		END	

		SET @GroupCount = @GroupCount +1 
		IF (@GroupCount > @GroupTotal) BEGIN
			SET @RetVal = COALESCE(@RetVal + @LineBreakChar, '') + @Line 
		END
		SET @Ndx = @Ndx + 1
	End
--	SELECT @RetVal
    RETURN @RetVal
END
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingBankBlock]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingBankBlock]
GO
CREATE FUNCTION dbo.ufn_GetListingBankBlock ( 
    @CompanyId int,
    @LineBreakChar nvarchar(50)
)
RETURNS varchar(5000)
AS
BEGIN
	RETURN dbo.ufn_GetListingBankBlock2(@CompanyId, @LineBreakChar, 0)
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingBankBlock2]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingBankBlock2]
GO
CREATE FUNCTION dbo.ufn_GetListingBankBlock2 ( 
    @CompanyId int,
    @LineBreakChar nvarchar(50),
	@IncludePrefix bit = 0
)
RETURNS varchar(5000)
AS
BEGIN
	IF (@LineBreakChar is null)
		SET @LineBreakChar = '<br/>'

	DECLARE @RetVal varchar(5000)
    DECLARE @Count int 

	SELECT @RetVal = COALESCE(@RetVal + ', ', '') + prcb_Name
	FROM (SELECT prcb_Name
            FROM PRCompanyBank WITH (NOLOCK)
           WHERE prcb_CompanyID =  @CompanyID
             AND prcb_Publish = 'Y'
             AND prcb_Deleted IS NULL
         ) TABLE1
    SET @Count = @@ROWCOUNT
	-- Now add our prefix
	IF(@IncludePrefix > 0)
	BEGIN
		IF (@Count > 1) 
		BEGIN
			SET @RetVal = 'Banks: ' + @RetVal
		END ELSE BEGIN
			SET @RetVal = 'Bank: ' + @RetVal
		END
	END

	RETURN dbo.ufn_ApplyListingLineBreaks(@RetVal, @LineBreakChar)
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingBodyLineCount]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingBodyLineCount]
GO
CREATE FUNCTION dbo.ufn_GetListingBodyLineCount(@CompanyID int)
RETURNS int AS  
BEGIN
	DECLARE @LineCount int
	DECLARE @LineBreakChar varchar(5)
	DECLARE @Block varchar(max)
	DECLARE @IndustryType varchar(40)
	DECLARE @PublishLogo char(1)

	SET @LineBreakChar = '<br/>'
	SET @LineCount = 0

	SELECT @IndustryType = comp_PRIndustryType,
	       @PublishLogo = comp_PRPublishLogo
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;
	

	DECLARE @LineLimit int = 0
	IF (@PublishLogo = 'Y') BEGIN
		SET @LineLimit = 4
	END


	SET @Block = dbo.ufn_GetListingParentheticalBlock2(@CompanyID, @LineBreakChar, DEFAULT, DEFAULT, @LineLimit)
	IF (@Block IS NOT NULL) BEGIN
		IF (@LineLimit > 0) BEGIN
			SET @LineLimit = @LineLimit - ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
		END
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingAddressBlock2(@CompanyID, @LineBreakChar, DEFAULT, DEFAULT, @LineLimit)
	--SET @Block = dbo.ufn_GetListingAddressBlock2(@CompanyID, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
	IF (@Block IS NOT NULL) BEGIN
		IF (@LineLimit > 0) BEGIN
			SET @LineLimit = @LineLimit - ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
		END
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingPhoneBlock2(@CompanyID, @LineBreakChar, DEFAULT, DEFAULT, @LineLimit)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingInternetBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingDLBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingBrandBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingUnloadHoursBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingStockExchangeBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingBankBlock2(@CompanyID, @LineBreakChar, 1)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingChainStoresBlock(@CompanyID, @IndustryType, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	SET @Block = dbo.ufn_GetListingLicenseBlock(@CompanyID, @LineBreakChar)
	IF (@Block IS NOT NULL) BEGIN
		SET @LineCount = @LineCount + ((LEN(@Block) - LEN(REPLACE(@Block, @LineBreakChar, ''))) / LEN(@LineBreakChar)) + 1
	END

	RETURN @LineCount

END
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetListingFromCompany2]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetListingFromCompany2]
GO
CREATE FUNCTION [dbo].[ufn_GetListingFromCompany2] ( 
    @CompanyId int,
    @FormattingStyle tinyint = 0, -- 0: <br/> 1: CHR(10) 2: CHR(10 & 13) 3: Tab
    @ShowPaidLines bit = 0,
    @IncludeHeader bit = 1
)
RETURNS varchar(max)
AS
BEGIN
    DECLARE @RetValue varchar(max)
	DECLARE @Logo varchar(50)
    DECLARE @comp_PRBookTradestyle varchar(420)
    DECLARE @comp_PRListingStatus varchar(40)
    DECLARE @comp_PRIndustryType varchar(40)
    DECLARE @prcp_VolumeDesc varchar(50)
    DECLARE @prra_RatingLine varchar(100)
    DECLARE @ParentheticalBlock varchar(1000)
    DECLARE @AddressBlock varchar(1000)
    DECLARE @PhoneBlock varchar(1000)
    DECLARE @InternetBlock varchar(1000)
    DECLARE @DLBlock varchar(max)
    DECLARE @BrandBlock varchar(1000)
    DECLARE @UnloadHoursBlock varchar(1000)
    DECLARE @ClassificationBlock varchar(5000)
    DECLARE @CommodityBlock varchar(5000)
    DECLARE @StockExchangeBlock varchar(500)
    DECLARE @RatingBlock varchar(500)
    DECLARE @BankBlock varchar(500)
    DECLARE @LicenseBlock varchar(500)
    DECLARE @MemberSince varchar(10)
    DECLARE @LineBreakChar varchar(50)
    IF (@FormattingStyle = 0) BEGIN
        SET @LineBreakChar = '<br/>'
    END ELSE IF (@FormattingStyle = 1) BEGIN
        SET @LineBreakChar = CHAR(10)
    END ELSE IF (@FormattingStyle = 2) BEGIN
        SET @LineBreakChar = CHAR(13)+CHAR(10)
    END ELSE IF (@FormattingStyle = 3) BEGIN
        SET @LineBreakChar = CHAR(9)
    END ELSE IF (@FormattingStyle = 4) BEGIN
        SET @LineBreakChar = CHAR(9)

    END
	-- LineLimit represents the number of lines taken up by a logo and therefore need special formatting
	Declare @LineLimit int, @LineCount int
	Declare @LogoLineSize int; SET @LogoLineSize = 22
	Declare @LineSize int; SET @LineSize = 34
	DECLARE @PartA varchar(400), @PartB varchar(400), @PartALineBreak int
	SELECT @comp_PRBookTradestyle = comp_PRBookTradestyle,
           @Logo = comp_PRPublishLogo
	  FROM Company WITH (NOLOCK)
	 WHERE comp_companyid = @CompanyId;
	-- first determine if this company has a logo to display
	IF (@Logo IS NOT NULL) BEGIN
		-- LineLimit starts at 5 when a logo is present; however line 1 is the BBId so start at 4
		set @LineLimit = 4
		SET @comp_PRBookTradestyle = dbo.ufn_GetListingTradestyle(@comp_PRBookTradestyle, @Logo, @LineBreakChar, @LineSize)
		SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @comp_PRBookTradestyle)+1)
		SELECT @ParentheticalBlock = dbo.ufn_GetListingParentheticalBlock2(@CompanyId, @LineBreakChar, 
												@LogoLineSize, @LineSize, @LineLimit)
		If (@ParentheticalBlock is not null and @ParentheticalBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @ParentheticalBlock)+1)
		SELECT @AddressBlock = dbo.ufn_GetListingAddressBlock2(@CompanyId, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		If (@AddressBlock is not null and @AddressBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @AddressBlock)+1)
		SELECT @PhoneBlock = dbo.ufn_GetListingPhoneBlock2(@CompanyId, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		If (@PhoneBlock is not null and @PhoneBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @PhoneBlock)+1)
		SELECT @comp_PRIndustryType = comp_PRIndustryType,
			   @prcp_VolumeDesc = CaptVol.capt_US,
			   @InternetBlock = dbo.ufn_GetListingInternetBlock(@CompanyId, @LineBreakChar),
			   @DLBlock = dbo.ufn_GetListingDLBlock(@CompanyId, @LineBreakChar),
			   @BankBlock = dbo.ufn_GetListingBankBlock2(@CompanyId, @LineBreakChar, 1),
			   @BrandBlock = dbo.ufn_GetListingBrandBlock(@CompanyId, @LineBreakChar),
			   @UnloadHoursBlock = dbo.ufn_GetListingUnloadHoursBlock(@CompanyId, @LineBreakChar),
			   @StockExchangeBlock = dbo.ufn_GetListingStockExchangeBlock(@CompanyId, @LineBreakChar),
			   @RatingBlock = dbo.ufn_GetListingRatingBlock(@CompanyId, comp_PRIndustryType, 1, @LineBreakChar),
			   @LicenseBlock = dbo.ufn_GetListingLicenseBlock(@CompanyId, @LineBreakChar),
			   @ClassificationBlock = dbo.ufn_GetListingClassificationBlock(ABS(@CompanyId), comp_PRIndustryType, @LineBreakChar),
			   @CommodityBlock = dbo.ufn_GetListingCommodityBlock(@CompanyId, comp_PRIndustryType, @LineBreakChar),
			   @MemberSince = case 
					when comp_PRTMFMAward = 'Y' then DATEPART(YEAR, comp_PRTMFMAwardDate)
					else NULL
			   end
		FROM Company WITH (NOLOCK)
		     LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyId = ABS(prcp_CompanyId)
		     LEFT OUTER JOIN Custom_Captions CaptVol WITH (NOLOCK) ON capt_code = prcp_Volume AND capt_family = 'prcp_Volume'
		WHERE comp_companyid = ABS(@CompanyId)
	END ELSE BEGIN
		SET @LineLimit = 0
		SET @comp_PRBookTradestyle = dbo.ufn_GetListingTradestyle(@comp_PRBookTradestyle, @Logo, @LineBreakChar, @LineSize)
		SELECT @comp_PRIndustryType = comp_PRIndustryType,
			   @prcp_VolumeDesc = CaptVol.capt_US,
			   @ParentheticalBlock = dbo.ufn_GetListingParentheticalBlock(@CompanyId, @LineBreakChar),
			   @AddressBlock = dbo.ufn_GetListingAddressBlock(@CompanyId, @LineBreakChar),
			   @PhoneBlock = dbo.ufn_GetListingPhoneBlock(@CompanyId, @LineBreakChar),
			   @InternetBlock = dbo.ufn_GetListingInternetBlock(@CompanyId, @LineBreakChar),
			   @DLBlock = dbo.ufn_GetListingDLBlock(@CompanyId, @LineBreakChar),
			   @BankBlock = dbo.ufn_GetListingBankBlock2(@CompanyId, @LineBreakChar,1),
			   @BrandBlock = dbo.ufn_GetListingBrandBlock(@CompanyId, @LineBreakChar),
			   @UnloadHoursBlock = dbo.ufn_GetListingUnloadHoursBlock(@CompanyId, @LineBreakChar),
			   @StockExchangeBlock = dbo.ufn_GetListingStockExchangeBlock(@CompanyId, @LineBreakChar),
			   @RatingBlock = dbo.ufn_GetListingRatingBlock(@CompanyId, comp_PRIndustryType, 1, @LineBreakChar),
			   @LicenseBlock = dbo.ufn_GetListingLicenseBlock(@CompanyId, @LineBreakChar),
			   @ClassificationBlock = dbo.ufn_GetListingClassificationBlock(ABS(@CompanyId), comp_PRIndustryType, @LineBreakChar),
			   @CommodityBlock = dbo.ufn_GetListingCommodityBlock(@CompanyId, comp_PRIndustryType, @LineBreakChar),
			   @MemberSince = case 
					when comp_PRTMFMAward = 'Y' then DATEPART(YEAR, comp_PRTMFMAwardDate)
					else NULL
			   end
		FROM Company WITH (NOLOCK)
		     LEFT OUTER JOIN PRCompanyProfile WITH (NOLOCK) ON comp_CompanyId = ABS(prcp_CompanyId)
		     LEFT OUTER JOIN Custom_Captions CaptVol WITH (NOLOCK) ON capt_code = prcp_Volume AND capt_family = 'prcp_Volume'
	   WHERE comp_companyid = ABS(@CompanyId)
	END
	SET @RetValue = dbo.ufn_GetListing(@CompanyId,
										@FormattingStyle,
                                        @ShowPaidLines,
                                        @IncludeHeader,
                                        @comp_PRBookTradestyle,
                                        @comp_PRListingStatus,
                                        @comp_PRIndustryType,
                                        @prcp_VolumeDesc,
                                        @prra_RatingLine,
                                        @ParentheticalBlock,
                                        @AddressBlock,
                                        @PhoneBlock,
                                        @InternetBlock,
                                        @DLBlock,
                                        @BrandBlock,
                                        @UnloadHoursBlock,
                                        @ClassificationBlock,
                                        @CommodityBlock,
                                        @StockExchangeBlock,
                                        @RatingBlock,
                                        @BankBlock,
                                        @LicenseBlock,
                                        @MemberSince);
	RETURN @RetValue
END 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetBookImageListingBody]') 
		and xtype in (N'FN', N'IF', N'TF')) 
	drop function [dbo].[ufn_GetBookImageListingBody]
GO

CREATE FUNCTION dbo.ufn_GetBookImageListingBody ( 
    @CompanyID int
)
RETURNS varchar(8000)
AS
BEGIN

    DECLARE @RetValue varchar(8000)
    
	DECLARE @Logo varchar(50)
    DECLARE @comp_PRBookTradestyle varchar(120)
    DECLARE @comp_PRListingStatus varchar(40)
    DECLARE @comp_PRIndustryType varchar(40)
    DECLARE @ParentheticalBlock varchar(1000)
    DECLARE @AddressBlock varchar(1000)
    DECLARE @PhoneBlock varchar(1000)
    DECLARE @InternetBlock varchar(1000)
    DECLARE @DLBlock varchar(max)
    DECLARE @BrandBlock varchar(1000)
    DECLARE @UnloadHoursBlock varchar(1000)
    DECLARE @StockExchangeBlock varchar(500)
    DECLARE @BankBlock varchar(500)
    DECLARE @LicenseBlock varchar(500)

    DECLARE @LineBreakChar varchar(50)
    SET @LineBreakChar = CHAR(9)
	
	-- LineLimit represents the number of lines taken up by a logo and therefore need special formatting
	Declare @LineLimit int, @LineCount int
	Declare @LogoLineSize int; SET @LogoLineSize = 22
	Declare @LineSize int; SET @LineSize = 34

	DECLARE @PartA varchar(400), @PartB varchar(400), @PartALineBreak int

	SELECT @comp_PRBookTradestyle = comp_PRBookTradestyle,
           @Logo = comp_PRPublishLogo
	  FROM Company WITH (NOLOCK)
	 WHERE comp_companyid = @CompanyId;

	--SELECT 'Logo' + ISNULL(@Logo, '');

	-- first determine if this company has a logo to display
	IF (@Logo IS NOT NULL) BEGIN

		-- LineLimit starts at 5 when a logo is present; however line 1 is the BBId so start at 4
		SET @LineLimit = 4
		SET @comp_PRBookTradestyle = dbo.ufn_GetListingTradestyle(@comp_PRBookTradestyle, @Logo, @LineBreakChar, @LineSize)
		SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @comp_PRBookTradestyle)+1)

		SELECT @ParentheticalBlock = dbo.ufn_GetListingParentheticalBlock2(@CompanyId, @LineBreakChar, 
												@LogoLineSize, @LineSize, @LineLimit)
		If (@ParentheticalBlock is not null and @ParentheticalBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @ParentheticalBlock)+1)

		SELECT @AddressBlock = dbo.ufn_GetListingAddressBlock2(@CompanyId, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		If (@AddressBlock is not null and @AddressBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @AddressBlock)+1)

		SELECT @PhoneBlock = dbo.ufn_GetListingPhoneBlock2(@CompanyId, @LineBreakChar, @LogoLineSize, @LineSize, @LineLimit)
		If (@PhoneBlock is not null and @PhoneBlock != '')
			SET @LineLimit = @LineLimit - (dbo.ufn_CountOccurrences(@LineBreakChar, @PhoneBlock)+1)

		SELECT @comp_PRIndustryType = comp_PRIndustryType,
			   @InternetBlock = dbo.ufn_GetListingInternetBlock(@CompanyId, @LineBreakChar),
			   @DLBlock = dbo.ufn_GetListingDLBlock(@CompanyId, @LineBreakChar),
			   @BankBlock = dbo.ufn_GetListingBankBlock2(@CompanyId, @LineBreakChar,1),
			   @BrandBlock = dbo.ufn_GetListingBrandBlock(@CompanyId, @LineBreakChar),
			   @UnloadHoursBlock = dbo.ufn_GetListingUnloadHoursBlock(@CompanyId, @LineBreakChar),
			   @StockExchangeBlock = dbo.ufn_GetListingStockExchangeBlock(@CompanyId, @LineBreakChar),
			   @LicenseBlock = dbo.ufn_GetListingLicenseBlock(@CompanyId, @LineBreakChar)
 		  FROM Company WITH (NOLOCK)
		 WHERE comp_companyid = @CompanyId


	END ELSE BEGIN
		SET @LineLimit = 0
		SET @comp_PRBookTradestyle = dbo.ufn_GetListingTradestyle(@comp_PRBookTradestyle, @Logo, @LineBreakChar, @LineSize)
		
		SELECT @comp_PRIndustryType = comp_PRIndustryType,
			   @ParentheticalBlock = dbo.ufn_GetListingParentheticalBlock(@CompanyId, @LineBreakChar),
			   @AddressBlock = dbo.ufn_GetListingAddressBlock(@CompanyId, @LineBreakChar),
			   @PhoneBlock = dbo.ufn_GetListingPhoneBlock(@CompanyId, @LineBreakChar),
			   @InternetBlock = dbo.ufn_GetListingInternetBlock(@CompanyId, @LineBreakChar),
			   @DLBlock = dbo.ufn_GetListingDLBlock(@CompanyId, @LineBreakChar),
			   @BankBlock = dbo.ufn_GetListingBankBlock2(@CompanyId, @LineBreakChar,1),
			   @BrandBlock = dbo.ufn_GetListingBrandBlock(@CompanyId, @LineBreakChar),
			   @UnloadHoursBlock = dbo.ufn_GetListingUnloadHoursBlock(@CompanyId, @LineBreakChar),
			   @StockExchangeBlock = dbo.ufn_GetListingStockExchangeBlock(@CompanyId, @LineBreakChar),
			   @LicenseBlock = dbo.ufn_GetListingLicenseBlock(@CompanyId, @LineBreakChar)
		FROM Company WITH (NOLOCK)
		WHERE comp_companyid = @CompanyId
	END

	SET @RetValue = dbo.ufn_GetListing(@CompanyId,
										3,
                                        0,
                                        0,
                                        @comp_PRBookTradestyle,
                                        @comp_PRListingStatus,
                                        @comp_PRIndustryType,
                                        null,
                                        null,
                                        @ParentheticalBlock,
                                        @AddressBlock,
                                        @PhoneBlock,
                                        @InternetBlock,
                                        @DLBlock,
                                        @BrandBlock,
                                        @UnloadHoursBlock,
                                        null,
                                        null,
                                        @StockExchangeBlock,
                                        null,
                                        @BankBlock,
                                        @LicenseBlock,
                                        null);

	RETURN @RetValue
END
Go


--Translations_ES.sql
UPDATE NewProduct SET prod_name_ES='Informe Comercial', prod_PRDescription_ES='<div style="font-weight:bold">Blue Book Business Report excluding Equifax Credit Information</div><p style="margin-top:0em">Creditors—such as sellers, transporters and suppliers—use this report type for performing a high-level connection/prospect evaluation, where there is typically a specific interest in current and trend facts such as pay and trade experiences. Tabular and graphic presentation of the company''s rating information makes it quick & easy to reach informed decisions.</p><p>The Business Report includes: basic company contact information such as Blue Book ID#, company name, listing location, addresses, phones, faxes, e-mails, web URLs, ownership, and alternate trade names. Also included - if available/applicable - are current headquarter rating & rating definition, affiliated businesses, branch locations, headquarter rating trend, recent company developments, bankruptcy events, business background, people background, business profile, financial information, and year-to-date trade report summary. Select credit information such as public record information will be included with your Business Report, as available/applicable. (Spanish) (Spanish on whole line)</p>' WHERE prod_ProductID=108
UPDATE Custom_Captions SET capt_ES='Limitar Fuente Local' WHERE capt_family='BBOSSearchLocalSoruce         ' AND capt_Code = 'LSO'
UPDATE Custom_Captions SET capt_ES='Seguridad Alimentaria' WHERE capt_family='peli_PRRole' AND capt_Code = 'FS'
UPDATE PRClassification SET prcl_Name_ES='Productos de Alambre para Agricultura', prcl_Description_ES=NULL WHERE prcl_ClassificationID=640
UPDATE Custom_Captions SET Capt_ES=Capt_US WHERE Capt_FamilyType='Choices' AND Capt_Family IN ('prwun_Hour', 'prwun_Minute', 'prwun_AMPM')
UPDATE NewProduct SET prod_Name_ES='Servicio de Actualizaciones Exprés', prod_PRDescription_ES=NULL WHERE prod_ProductID=21
UPDATE PRAttribute SET prat_Name_ES ='Ecuador' WHERE prat_AttributeID=1004
UPDATE Custom_Captions SET Capt_US = 'Asociación de Exportadores de Guatemala' WHERE Capt_Family='prcta_TradeAssociationCode' AND Capt_Code='AGEXPORT'


--User Defined Functions.sql
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetRecentCompanies]') 
            and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop Function [dbo].[ufn_GetRecentCompanies]
GO

CREATE FUNCTION dbo.ufn_GetRecentCompanies
(
    @WebUserID int,
    @Top int
)
RETURNS @Recent table (
    ndx int identity(1,1) ,
    CompanyID int
)
AS BEGIN

	INSERT INTO @Recent (CompanyID)
	SELECT TOP(@Top) prwsat_AssociatedID
	  FROM PRWebAuditTrail         
	  WHERE (prwsat_PageName LIKE '%CompanyDetailsSummary.aspx'
			 OR prwsat_PageName LIKE '%Company.aspx'
			 OR prwsat_PageName LIKE '%CompanyView.aspx'
	         OR prwsat_PageName LIKE '%getcompany')
		AND prwsat_WebUserID = @WebUserID 
		AND prwsat_AssociatedType = 'C'  
	GROUP BY  prwsat_AssociatedID   
	ORDER BY MAX(prwsat_CreatedDate) DESC;

    RETURN
END
Go

--Views.SQL
DECLARE @Script varchar(max)
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


--Stored Procedures.sql


If Exists (Select name from sysobjects where name = 'usp_ConsumeBackgroundCheckUnits' and type='P') Drop Procedure dbo.usp_ConsumeBackgroundCheckUnits
Go

/**
Creates the appropriate records to consume background check service units
**/
CREATE PROCEDURE dbo.usp_ConsumeBackgroundCheckUnits
	@CompanyID int,
    @CRMUserID int,
    @HQID int = null
AS 

SET NOCOUNT ON

-- If we don't have a CRM User, go get the
-- default website user
IF @CRMUserID = 0 BEGIN
	SET @CRMUserID = dbo.ufn_GetSystemUserId(1)
END

IF (@HQID IS NULL) BEGIN
	SELECT @HQID = comp_PRHQID
      FROM Company WITH (NOLOCK)
     WHERE comp_CompanyID = @CompanyID;
END

BEGIN TRANSACTION;
BEGIN TRY

-- Now we need to figure out which allocations
-- to associate this usage with.  Those allocations need
--
DECLARE @Count int, @Ndx int, 
	@BackgroundCheckAllocationID int,
	@BackgroundCheckAllocationUnitsRemaining int, 
	@CurrentRemaining int

DECLARE @BackgroundCheckAllocations table (
	ndx smallint identity, 
	BackgroundCheckAllocationID int,
    UnitsRemaining int)

INSERT INTO @BackgroundCheckAllocations (BackgroundCheckAllocationID, UnitsRemaining)
SELECT prbca_BackgroundCheckAllocationID, prbca_Remaining
  FROM PRBackgroundCheckAllocation
 WHERE GETDATE() BETWEEN prbca_StartDate AND prbca_ExpirationDate
   AND prbca_HQID = @HQID
   AND prbca_Remaining > 0
 ORDER BY prbca_ExpirationDate, prbca_CreatedDate;

SET @Count = @@ROWCOUNT
SET @ndx = 1	
SET @CurrentRemaining = 1

WHILE (@Ndx <= @Count) BEGIN
	SELECT @BackgroundCheckAllocationID = BackgroundCheckAllocationID,
	       @BackgroundCheckAllocationUnitsRemaining = UnitsRemaining
      FROM @BackgroundCheckAllocations WHERE ndx = @Ndx;

	SET @Ndx = @Ndx + 1

	IF (@CurrentRemaining <= @BackgroundCheckAllocationUnitsRemaining) BEGIN
		UPDATE PRBackgroundCheckAllocation
           SET prbca_Remaining = prbca_Remaining - @CurrentRemaining,
			   prbca_UpdatedBy = @CRMUserID,
		       prbca_UpdatedDate = GETDATE(),
			   prbca_TimeStamp = GETDATE()
         WHERE prbca_BackgroundCheckAllocationID = @BackgroundCheckAllocationID;

		-- We're done so make sure we don't loop 
		-- any further.
		SET @Ndx = @Count + 1
	
	END ELSE BEGIN
		-- Decrement by how many this allocation has remaining, then zero out the allocation.
		SET @CurrentRemaining = @CurrentRemaining - @BackgroundCheckAllocationUnitsRemaining	

		UPDATE PRBackgroundCheckAllocation
           SET prbca_Remaining = 0,
			   prbca_UpdatedBy = @CRMUserID,
		       prbca_UpdatedDate = GETDATE(),
			   prbca_TimeStamp = GETDATE()
         WHERE prbca_BackgroundCheckAllocationID = @BackgroundCheckAllocationID;
	END
END

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

	EXEC usp_RethrowError;
END CATCH;

SET NOCOUNT ON
GO