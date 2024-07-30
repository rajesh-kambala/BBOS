--8.9 Release
USE CRM

DECLARE @CurrentCapt_Code varchar(100)
DECLARE @CurrentCapt_US varchar(100)
DECLARE @IsDate bit
SELECT	@CurrentCapt_Code = Capt_Code, 
		@CurrentCapt_US=Capt_US
FROM Custom_Captions WHERE Capt_Family='LastBBScoreRunDate'
SET @IsDate = (SELECT ISDATE(@CurrentCapt_US))
IF @IsDate=1 BEGIN
	UPDATE Custom_Captions SET Capt_Code=@CurrentCapt_US, Capt_US='LastBBScoreRunDate', Capt_UK='LastBBScoreRunDate', Capt_FR='LastBBScoreRunDate', Capt_DE='LastBBScoreRunDate', Capt_ES='LastBBScoreRunDate'
	WHERE Capt_Family='LastBBScoreRunDate'
END
GO

DECLARE @CurrentCapt_Code varchar(100)
DECLARE @CurrentCapt_US varchar(100)
DECLARE @IsDate bit
SELECT	@CurrentCapt_Code = Capt_Code, 
		@CurrentCapt_US=Capt_US
FROM Custom_Captions WHERE Capt_Family='LastBBScoreRunDate_Lumber'
SET @IsDate = (SELECT ISDATE(@CurrentCapt_US))
IF @IsDate=1 BEGIN
	UPDATE Custom_Captions SET Capt_Code=@CurrentCapt_US, Capt_US='LastBBScoreRunDate_Lumber', Capt_UK='LastBBScoreRunDate_Lumber', Capt_FR='LastBBScoreRunDate_Lumber', Capt_DE='LastBBScoreRunDate_Lumber', Capt_ES='LastBBScoreRunDate_Lumber'
	WHERE Capt_Family='LastBBScoreRunDate_Lumber'
END
GO

--Defect 6785
ALTER TABLE PRCountry DISABLE TRIGGER ALL
UPDATE PRCountry SET prcn_Region = 'CSAME' WHERE prcn_Region IN ('AS','ME') -- first merge into new regsion 'Central/South Asia and Middle East' in bulk
--select * from prcountry where prcn_Region IN ('AS','ME')
UPDATE PRCountry SET prcn_Region = 'EAP' WHERE prcn_Region IN ('ANZ','PR') -- first merge into new regsion 'Eastern Asia Pacific' in bulk

UPDATE PRCountry SET prcn_Region = 'CSAME' WHERE prcn_Country IN (
		'Bangladesh',
		'India',
		'Israel',
		'Jordan',
		'Kuwait',
		'Pakistan',
		'Russia',
		'Saudi Arabia, Kingdom of',
		'United Arab Emirates'
	)

UPDATE PRCountry SET prcn_Region = 'EAP' WHERE prcn_Country IN (
		'Australia',
		'China',
		'Hong Kong',
		'Indonesia',
		'Japan',
		'Korea, Repub. of',
		'Malaysia',
		'New Zealand',
		'Philippines',
		'Singapore, Repub. Of',
		'Taiwan',
		'Thailand',
		'Vietnam'
	)

UPDATE PRCountry SET prcn_Country_ES ='Costa de Marfil, República de' WHERE prcn_CountryID=109
UPDATE PRCountry SET prcn_Country_ES ='Burkina Faso' WHERE prcn_CountryID=110
UPDATE PRCountry SET prcn_Country_ES ='Qatar' WHERE prcn_CountryID=111
UPDATE PRCountry SET prcn_Country_ES ='Luxemburgo' WHERE prcn_CountryID=112
UPDATE PRCountry SET prcn_Country_ES ='República de Guinea Ecuatorial' WHERE prcn_CountryID=113

ALTER TABLE PRCountry ENABLE TRIGGER ALL
GO

UPDATE Custom_Captions SET capt_ES='Central/South Asia and Middle East (es)' WHERE capt_family='prcn_Region' AND capt_Code = 'CSAME' --TODO:JMT need translation
UPDATE Custom_Captions SET capt_ES='Eastern Asia and Pacific (es)' WHERE capt_family='prcn_Region' AND capt_Code = 'EAP' --TODO:JMT need translation
GO

--Defect 6786 - for invoice, description is cut off after 30 chars -- reduce size of offending digital ad types
UPDATE Custom_Captions SET capt_us='PR News Banner Ad 200x167' WHERE capt_family='pradc_adcampaigntypedigital' AND capt_us='PR Newsletter Banner Ad 200x167'
UPDATE Custom_Captions SET capt_us='Lderboard Home Pg Ad 728x90' WHERE capt_family='pradc_adcampaigntypedigital' AND capt_us='Leaderboard Home Page Ad 728x90'
UPDATE Custom_Captions SET capt_us='Insider Leaderboard Ad' WHERE capt_family='pradc_adcampaigntypedigital' AND capt_us='Blue Book Insider Leaderboard Ad'
UPDATE Custom_Captions SET capt_us='PR News LderboardAd 580x72' WHERE capt_family='pradc_adcampaigntypedigital' AND capt_us='PR Newsletter Leaderboard Ad 580x72'

UPDATE PRAdCampaignTerms SET pract_InvoiceDescription='PR News Banner Ad 200x167'	WHERE pract_InvoiceDescription='PR Newsletter Banner Ad 200x16'
UPDATE PRAdCampaignTerms SET pract_InvoiceDescription='Lderboard Home Pg Ad 728x90'	WHERE pract_InvoiceDescription='Leaderboard Home Page Ad 728x9'
UPDATE PRAdCampaignTerms SET pract_InvoiceDescription='Insider Leaderboard Ad'		WHERE pract_InvoiceDescription='Blue Book Insider Leaderboard ' OR pract_InvoiceDescription='BB Insider Leaderboard Ad'
UPDATE PRAdCampaignTerms SET pract_InvoiceDescription='PR News LderboardAd 580x72'	WHERE pract_InvoiceDescription='PR Newsletter Leaderboard Ad 5'
GO

--
-- Defect 6882
ALTER TABLE Company DISABLE TRIGGER ALL
UPDATE Company SET comp_PRConfidentialFS = '1' WHERE comp_PRConfidentialFS IS NULL
UPDATE Company SET comp_PRConfidentialFS = '3' WHERE comp_CompanyID IN (SELECT prc4_CompanyId FROM PRCompanyStockExchange)
ALTER TABLE Company ENABLE TRIGGER ALL
Go