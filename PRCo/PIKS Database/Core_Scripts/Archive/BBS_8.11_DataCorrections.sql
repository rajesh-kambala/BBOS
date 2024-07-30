--8.11 Release
USE CRM

--11.4.1 ProductFamily
--	11.4.1.1	Define a new ProductFamily record similar to “Membership” but with a name of “Madison Lumber Membership”.
INSERT INTO ProductFamily (PrFa_ProductFamilyId, PrFa_CreatedBy, PrFa_CreatedDate, PrFa_UpdatedBy, PrFa_UpdatedDate, PrFa_TimeStamp, PrFa_Deleted, prfa_name, prfa_description, prfa_active)
VALUES (17,-100, GETDATE(), -100, GETDATE(), GETDATE(), NULL, 'Madison Lumber Membership', 'Madison Lumber Membership', 'Y' )

--11.4.2.1 Update the descriptions for the L100, L200 and L300 products for the current Product Family ID = 5. 
UPDATE NewProduct SET prod_name='L100: Lumber Blue Book Service', prod_PRDescription='<ul class="Bullets"><li>1 user license</li><li>0 Business Reports</li><li>Access to Madison''s Directory data</li></ul>', prod_PRWebUsers=1, prod_PRServiceUnits=0 
WHERE prod_code='L100' and prod_productfamilyid=5

UPDATE NewProduct SET prod_name='L200: Lumber Blue Book Service', prod_PRDescription='<ul class="Bullets"><li>5 user licenses</li><li>5 Business Reports</li><li>Access to Blue Book credit ratings and scores</li><li>Access to Madison''s Directory data</li></ul>', prod_PRWebUsers=5, prod_PRServiceUnits=5 
WHERE prod_code='L200' and prod_productfamilyid=5

UPDATE NewProduct SET prod_name='L300: Lumber Blue Book Service', prod_PRDescription='<ul class="Bullets"><li>15 user licenses</li><li>60 Business Reports</li><li>Access to Blue Book credit ratings and scores</li><li>Access to Madison''s Directory data</li></ul>', prod_PRWebUsers=15, prod_PRServiceUnits=60 
WHERE prod_code='L300' and prod_productfamilyid=5

ALTER TABLE NewProduct ALTER COLUMN prod_name NVARCHAR (55) NULL;

--11.4.2.2 Insert a new L150 record for the current product familyid = 5 copying the data from L100.  
--Use the following descriptions and set the product record columns appropriately. 
--$989 Annually – L150: Lumber Blue Book Service, 5 user licenses, 0 Business Reports, Access to Madison’s Directory data 
INSERT INTO NewProduct
	(Prod_ProductID, prod_CreatedBy, prod_CreatedDate, prod_updatedby, prod_updateddate, Prod_TimeStamp, prod_Active, prod_UOMCategory, prod_Name, prod_Code, prod_productfamilyid, prod_PRWebAccess, prod_PRWebUsers, prod_PRWebAccessLevel, prod_PRSequence, prod_PRDescription, prod_PRRecurring, prod_PRServiceUnits, prod_IndustryTypeCode, prod_PRIsTaxed, prod_PurchaseInBBOS)
	Values (100,-100, GETDATE(), 1, GETDATE(), GETDATE(), 'Y', 6000, 'L150: Lumber Blue Book Service', 'L150', 5, 'Y', 5, 350, 6, '<ul class="Bullets"><li>5 user licenses</li><li>0 Business Reports</li><li>Access to Madison''s Directory data</li></ul>', 'Y', 0, ',L,', 'Y', 'Y')

--11.4.2.3 Insert records for the new Madison Lumber Membership product family coping the data from L100, L200, and L300 Instead using codes L100, L201, and L301. 
--The names and descriptions are below.  Note: even though internally some of the codes are L201 and L301, instead the public sees L200 and L300. 
INSERT INTO NewProduct
	(Prod_ProductID, prod_CreatedBy, prod_CreatedDate, prod_updatedby, prod_updateddate, Prod_TimeStamp, prod_Active, prod_UOMCategory, prod_Name, prod_Code, prod_productfamilyid, prod_PRWebAccess, prod_PRWebUsers, prod_PRWebAccessLevel, prod_PRSequence, prod_PRDescription, prod_PRRecurring, prod_PRServiceUnits, prod_IndustryTypeCode, prod_PRIsTaxed, prod_PurchaseInBBOS)
	Values (101,-100, GETDATE(), 1, GETDATE(), GETDATE(), 'Y', 6000, 'L100: Madison''s Directory/Lumber Blue Book Service', 'L100', 17, 'Y', 1, 300, 5, '<ul class="Bullets"><li>1 user licenses</li><li>Access to Madison''s Directory data</li><li>0 Business Reports</li></ul>', 'Y', 0, ',L,', 'Y', 'Y')
INSERT INTO NewProduct
	(Prod_ProductID, prod_CreatedBy, prod_CreatedDate, prod_updatedby, prod_updateddate, Prod_TimeStamp, prod_Active, prod_UOMCategory, prod_Name, prod_Code, prod_productfamilyid, prod_PRWebAccess, prod_PRWebUsers, prod_PRWebAccessLevel, prod_PRSequence, prod_PRDescription, prod_PRRecurring, prod_PRServiceUnits, prod_IndustryTypeCode, prod_PRIsTaxed, prod_PurchaseInBBOS)
	Values (102,-100, GETDATE(), 1, GETDATE(), GETDATE(), 'Y', 6000, 'L200: Madison''s Directory/Lumber Blue Book Service', 'L201', 17, 'Y', 5, 400, 10, '<ul class="Bullets"><li>5 user licenses</li><li>Access to Madison''s Directory data</li><li>Access to Blue Book credit ratings and scores</li><li>5 Business Reports</li></ul>', 'Y', 5, ',L,', 'Y', 'Y')
INSERT INTO NewProduct
	(Prod_ProductID, prod_CreatedBy, prod_CreatedDate, prod_updatedby, prod_updateddate, Prod_TimeStamp, prod_Active, prod_UOMCategory, prod_Name, prod_Code, prod_productfamilyid, prod_PRWebAccess, prod_PRWebUsers, prod_PRWebAccessLevel, prod_PRSequence, prod_PRDescription, prod_PRRecurring, prod_PRServiceUnits, prod_IndustryTypeCode, prod_PRIsTaxed, prod_PurchaseInBBOS)
	Values (103,-100, GETDATE(), 1, GETDATE(), GETDATE(), 'Y', 6000, 'L300: Madison''s Directory/Lumber Blue Book Service', 'L301', 17, 'Y', 15, 500, 20, '<ul class="Bullets"><li>15 user licenses</li><li>Access to Madison''s Directory data</li><li>Access to Blue Book credit ratings and scores</li><li>60 Business Reports</li></ul>', 'Y', 60, ',L,', 'Y', 'Y')

--11.4.2.4 Insert a new L150 record for the new Madison Lumber Membership product family copying the data from L100.  
--Use the following descriptions and set the product record columns appropriately. 
--$989 Annually – L150: Lumber Blue Book Service, 5 user licenses , 0 Business Reports , Access to Madison’s Directory data 
INSERT INTO NewProduct
	(Prod_ProductID, prod_CreatedBy, prod_CreatedDate, prod_updatedby, prod_updateddate, Prod_TimeStamp, prod_Active, prod_UOMCategory, prod_Name, prod_Code, prod_productfamilyid, prod_PRWebAccess, prod_PRWebUsers, prod_PRWebAccessLevel, prod_PRSequence, prod_PRDescription, prod_PRRecurring, prod_PRServiceUnits, prod_IndustryTypeCode, prod_PRIsTaxed, prod_PurchaseInBBOS)
	Values (104,-100, GETDATE(), 1, GETDATE(), GETDATE(), 'Y', 6000, 'L150: Madison''s Directory/Lumber Blue Book Service', 'L150', 17, 'Y', 5, 350, 7, '<ul class="Bullets"><li>5 user licenses</li><li>Access to Madison''s Directory data</li><li>0 Business Reports</li></ul>', 'Y', 0, ',L,', 'Y', 'Y')


-- Add the Additional License record for the new Basic Plus license.	
INSERT INTO NewProduct
	(Prod_ProductID, prod_CreatedBy, prod_CreatedDate, prod_updatedby, prod_updateddate, Prod_TimeStamp, prod_Active, prod_UOMCategory, prod_Name, prod_Code, prod_productfamilyid, prod_PRWebAccess, prod_PRWebUsers, prod_PRWebAccessLevel, prod_PRSequence, prod_PRDescription, prod_PRRecurring, prod_PRServiceUnits, prod_IndustryTypeCode)
	Values (106,-100, GETDATE(), 1, GETDATE(), GETDATE(), 'Y', 6000, 'Basic Plus Lumber BBOS License', 'LBSCPLIC', 6, 'Y', 1, '350', 32, '', 'Y', 0, ',L,')



--11.4.3 PRBBOSPrivilege
--Copy the privileges from IndustryType=L and AccessLevel=300 to IndustryType=L and AccessLevel=350.  Then add a new record for this access level for MadisonLumberPagePrint. 
INSERT INTO PRBBOSPrivilege(IndustryType,AccessLevel,Privilege,Role,Visible,Enabled)
	VALUES('L', '350', 'MadisonLumberPagePrint', NULL, 1, 0)

UPDATE PRBBOSPrivilege SET AccessLevel=350 WHERE Privilege = 'CompanyDetailsCustomPage' AND IndustryType='L' AND AccessLevel=400

--11.4.3 Add a record to allow company notes
UPDATE PRBBOSPrivilege SET AccessLevel=350 WHERE IndustryType='L' and AccessLevel=400 AND Privilege='Notes'

--Feedback Doc Issue #12 - L99
--CHW: Let’s add it to NewProduct and see what happens.  It should be in product family 5.  
--CHW: I believe there is a flag on that table indicating if that membership is available for purchase.  It should be set to false.
INSERT INTO NewProduct
	(Prod_ProductID, prod_CreatedBy, prod_CreatedDate, prod_updatedby, prod_updateddate, Prod_TimeStamp, prod_Active, prod_UOMCategory, prod_Name, prod_Code, prod_productfamilyid, prod_PRWebAccess, prod_PRWebUsers, prod_PRWebAccessLevel, prod_PRSequence, prod_PRDescription, prod_PRRecurring, prod_PRServiceUnits, prod_IndustryTypeCode, prod_PRIsTaxed, prod_PurchaseInBBOS)
	Values (105,-100, GETDATE(), 1, GETDATE(), GETDATE(), 'Y', 6000, 'L99: Lumber Blue Book Service', 'L99', 5, 'Y', 1, 300, 3, '<ul class="Bullets"><li>1 user license</li><li>0 Business Reports</li><li>Access to Madison''s Directory data</li></ul>', 'Y', 0, ',L,', 'Y', 'N')

--3.2.1.1.3
--UPDATE WordPress.dbo.wp_2_posts SET post_content='Lumber Blue Book Services is a business-to-business application. Gaining access to Lumber Blue Book Services is quick and easy.  We offer four service levels, distinguished by how many people you need to have access to the database, the types of features and credit data you need and how many in-depth business reports are needed during the calendar year.  Once you have selected the service level that meets your needs, simply click the Purchase Membership Now link to get started. We appreciate your business and look forward to supporting your company in any way we can.    <a class="button" href="buy-membership/">Purchase Membership Now</a>  <table class="jointodaytable" width="51%">  <thead>  <tr>  <td></td>  <td colspan="3" align="center">Membership Levels</td>  </tr>  <tr>  <td width="40%"></td>  <td width="20%">L-100</td>  <td width="20%">L-200</td>  <td width="20%">L-300</td>  </tr>  </thead>  <tbody>  <tr>  <td>Number of access licenses to Blue Book Online Services (BBOS)</td>  <td>1</td>  <td>5</td>  <td>15</td>  </tr>  <tr>  <td>Business Reports Included*</td>  <td>N/A</td>  <td>5</td>  <td>60</td>  </tr>  <tr>  <td>Annual Membership Fee before discounts</td>  <td>$675</td>  <td>$1200</td>  <td>$2000</td>  </tr>  <tr>  <td><strong>AR Aging Discount Opportunity  </strong>• Confidentially provide monthly Accounts Receivable Aging files (per specifications)</td>  <td>N/A</td>  <td>-$360</td>  <td>-$800</td>  </tr>  <tr>  <td height="20"><em>BONUS Business Reports included for AR providers</em></td>  <td>N/A</td>  <td>15</td>  <td>60</td>  </tr>  <tr>  <td>Business Report total after bonus</td>  <td>N/A</td>  <td>20</td>  <td>120</td>  </tr>  <tr>  <td height="10"><strong>Membership Fee after discount</strong></td>  <td><strong>$675</strong></td>  <td><strong>$840</strong></td>  <td><strong>$1200</strong></td>  </tr>  <tr>  <td style="background-color: #fff;" height="10"></td>  <td style="background-color: #fff;"></td>  <td style="background-color: #fff;"></td>  <td style="background-color: #fff;"></td>  </tr>  <tr>  <td colspan="4">*Additional Business Reports are available for $25 per report. Other package options are available upon request. On 12/31/2020, unused Business Reports will expire and a new allocation of Business Reports will be issued 1/1/2021.</td>  </tr>  <tr>  <td style="background-color: #fff;" height="10"></td>  <td style="background-color: #fff;"></td>  <td style="background-color: #fff;"></td>  <td style="background-color: #fff;"></td>  </tr>  <tr>  <td class="tsubhead" colspan="4">Blue Book Online Services Features and Functionality</td>  </tr>  <tr>  <td>  <ul>    <li>Search database by over 40 different criteria</li>    <li>Receive Weekly Credit Sheet update report</li>    <li>Access BBOS Mobile App</li>    <li>View/Print company listings</li>    <li>View company contacts</li>    <li>Save vCards on contacts to Microsoft Outlook</li>  </ul>  </td>  <td style="vertical-align: middle;" colspan="3" valign="middle">  <h3 style="text-align: center;">Included in all Membership Levels</h3>  <img class="size-full wp-image-2223 aligncenter" src="/wp-content/uploads/sites/2/2017/02/yes_48.png" alt="yes_48" width="48" height="48" /></td>  </tr>  <tr>  <td>  <ul>    <li>Create, save, edit, print and search notes on companies</li>  </ul>  </td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://azqa.lumber.bluebookservices.com/wp-content/uploads/sites/2/2020/02/no_24.png"><img class="size-full wp-image-3665 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/no_24.png" alt="" width="24" height="24" /></a></span></td>  <td style="vertical-align: middle; text-align: center;"><span style="text-align: center;"> <strong>up to 75</strong></span></td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png"><img class="size-full wp-image-3664 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png" alt="" width="24" height="24" /></a></span></td>  </tr>  <tr>  <td>  <ul>    <li>Export search results as a .CSV file</li>  </ul>  </td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/no_24.png"><img class="size-full wp-image-3665 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/no_24.png" alt="" width="24" height="24" /></a></span></td>  <td style="vertical-align: middle; text-align: center;"><span style="text-align: center;"> <strong>500/month</strong></span></td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://azqa.lumber.bluebookservices.com/wp-content/uploads/sites/2/2020/02/yes_24.png"><img class="size-full wp-image-3664 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png" alt="" width="24" height="24" /></a></span></td>  </tr>  <tr>  <td>  <ul>    <li> Create <em style="font-family: inherit; font-size: inherit;">Watchdog Groups</em><span style="font-family: inherit; font-size: inherit;"> to monitor key accounts</span></li>  </ul>  </td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/no_24.png"><img class="size-full wp-image-3665 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/no_24.png" alt="" width="24" height="24" /></a></span></td>  <td style="vertical-align: middle; text-align: center;"><strong><span style="text-align: center;"> up to 5</span></strong></td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.pnghttps://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png"><img class="size-full wp-image-3664 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png" alt="" width="24" height="24" /></a></span></td>  </tr>  <tr>  <td>  <ul>    <li>View/Search/Print/Export by Pay Indicators</li>  </ul>  </td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/no_24.png"><img class="size-full wp-image-3665 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/no_24.png" alt="" width="24" height="24" /></a></span></td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png"><img class="size-full wp-image-3664 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png" alt="" width="24" height="24" /></a></span></td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png"><img class="size-full wp-image-3664 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png" alt="" width="24" height="24" /></a></span></td>  </tr>  <tr>  <td>  <ul>    <li>View/Search/Print/Export Blue Book Scores</li>  </ul>  </td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/no_24.png"><img class="size-full wp-image-3665 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/no_24.png" alt="" width="24" height="24" /></a></span></td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png"><img class="size-full wp-image-3664 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png" alt="" width="24" height="24" /></a></span></td>  <td style="vertical-align: middle;"><span style="text-align: center;"><a href="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png"><img class="size-full wp-image-3664 aligncenter" src="https://qalumber.bluebookservices.com/wp-content/uploads/sites/2/2021/07/yes_24.png" alt="" width="24" height="24" /></a></span></td>  </tr>  </tbody>  </table>  <a class="button" href="buy-membership/">Purchase Membership Now</a>    <a class="button" href="https://www.lumberbluebook.com/wp-content/uploads/sites/2/2020/03/Lumber-Membership-Options-Summary-2020.pdf" target="_blank" rel="noopener">Printer-Friendly Membership Package Matrix (.pdf)</a>' 
--WHERE post_title='Join Today' and post_status='publish' and post_name='join-today'

/*
Add "Food Safety" as a Generic Title in the drop down menu and also add it as a Company Role, so that it is searchable in BBOS here: PersonSearch.aspx
Searching manually for this title found 303 persons with the title Food Safety.
We would also need a data correction to check the box for Food Safety company role, and to enter that title in the Generic Drop down.
*/

USE CRM;
GO

SET NOCOUNT OFF

DECLARE @ForCommit bit
-- SET this variable to 1 to commit changes

SET @ForCommit = 1

if (@ForCommit = 0) begin
	PRINT '*************************************************************'
	PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
	PRINT '*************************************************************'
	PRINT ''
end

DECLARE @Start DateTime
SET @Start = GETDATE()
PRINT 'Execution Start: ' + CONVERT(VARCHAR(20), @Start, 100) + ' on server ' + @@SERVERNAME
PRINT ''

BEGIN TRANSACTION
BEGIN TRY
						
	PRINT '1. Select the possibly bad data to work with'
	PRINT '-----------------------------------------------------'
	
	DECLARE @Param1 varchar(50) = '%food safety%'
	DECLARE @Param2 varchar(50) = '%food safety%'

	SELECT * FROM (SELECT DISTINCT Pers_FirstName AS FirstName, Pers_LastName AS LastName, 'Person' AS SourceTable, Pers_PersonId AS PersonId, 
                               dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) As PersonName, 
                               peli_PRTitle, peli_PRTitleCode, peli_PRRole, peli_companyid  FROM Person WITH (NOLOCK)
                     INNER JOIN Person_Link WITH (NOLOCK) ON Pers_PersonId = peli_PersonID 
                     INNER JOIN vPRBBOSCompanyList ON peli_CompanyID = comp_CompanyID --AND comp_PRListingStatus <> 'N3'
                WHERE peli_PRTitle LIKE @Param1 
					AND peli_PRStatus = '1' 
					AND peli_PREBBPublish = 'Y' 
					AND comp_PRLocalSource IS NULL 
					) T1 ORDER BY LastName, FirstName;

	PRINT '2. Update the records.'
	PRINT '-----------------------------------------------------'
	DECLARE @RunDate datetime = GETDATE()

	DECLARE @T TABLE
	(
		ndx int identity,
		PersonName varchar(500),
		PersonId int,
		CompanyId int,
		peli_PRTitle varchar(5000),
		peli_PRTitleCode varchar(500),
		peli_PRRole varchar(5000)
	)

	INSERT INTO @T
			SELECT PersonName, PersonId, PeLi_CompanyID, peli_PRTitle, peli_PRTitleCode, peli_PRRole FROM (SELECT DISTINCT Pers_FirstName AS FirstName, Pers_LastName AS LastName, 'Person' AS SourceTable, Pers_PersonId AS PersonId, 
                               dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) As PersonName, 
                               peli_PRTitle, peli_PRRole, peli_companyid, peli_PRTitleCode  FROM Person WITH (NOLOCK)
                     INNER JOIN Person_Link WITH (NOLOCK) ON Pers_PersonId = peli_PersonID 
                     INNER JOIN vPRBBOSCompanyList ON peli_CompanyID = comp_CompanyID --AND comp_PRListingStatus <> 'N3'
                     
                WHERE peli_PRTitle LIKE @Param1 
					AND peli_PRStatus = '1' 
					AND peli_PREBBPublish = 'Y' 
					AND comp_PRLocalSource IS NULL 
					) T1 ORDER BY LastName, FirstName;

	DECLARE @count int
	SELECT @count = COUNT(*) FROM @T
	DECLARE @Ndx int = 0
	DECLARE @CompanyID int
	DECLARE @PersonID int;

	DISABLE TRIGGER ALL ON Person_Link

	WHILE (@Ndx < @Count) BEGIN
		SET @Ndx = @Ndx + 1
		SELECT @CompanyID = CompanyId FROM @T WHERE ndx=@Ndx;
		SELECT @PersonID = PersonId FROM @T WHERE ndx=@Ndx;

		UPDATE Person_Link SET
			peli_PRTitleCode='FS',
			peli_PRRole = CASE WHEN peli_PRRole IS NULL THEN ',FS,' ELSE peli_PRRole + 'FS,' END
		WHERE PeLi_PersonId = @PersonID 
			AND peli_companyid = @CompanyID
	END;

	ENABLE TRIGGER ALL ON Person_Link
	
	
	PRINT '3. Results of Changed Records'
	PRINT '-----------------------------------------------------'
			SELECT * FROM (SELECT DISTINCT Pers_FirstName AS FirstName, Pers_LastName AS LastName, 'Person' AS SourceTable, Pers_PersonId AS PersonId, 
							dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix) As PersonName, 
							peli_PRTitle, peli_PRTitleCode, peli_PRRole, peli_companyid  FROM Person WITH (NOLOCK)
					INNER JOIN Person_Link WITH (NOLOCK) ON Pers_PersonId = peli_PersonID 
					INNER JOIN vPRBBOSCompanyList ON peli_CompanyID = comp_CompanyID --AND comp_PRListingStatus <> 'N3'
			WHERE peli_PRTitle LIKE @Param1 
				AND peli_PRStatus = '1' 
				AND peli_PREBBPublish = 'Y' 
				AND comp_PRLocalSource IS NULL 
				) T1 ORDER BY LastName, FirstName;
	
	if (@ForCommit = 1) begin
	PRINT 'COMMITTING CHANGES'
		COMMIT
	end else begin
		PRINT 'ROLLING BACK ALL CHANGES'
		ROLLBACK TRANSACTION
	end

	END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	EXEC usp_RethrowError;
END CATCH;

PRINT ''
PRINT 'Execution End: ' + CONVERT(VARCHAR(20), GETDATE(), 100)
PRINT 'Execution Time: ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE())) + ' ms'