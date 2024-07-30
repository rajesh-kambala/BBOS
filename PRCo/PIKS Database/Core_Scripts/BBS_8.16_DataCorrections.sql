--8.16 Release DataCorrections

-- DEFECT 7173 - L100 out of order
UPDATE NewProduct SET prod_PRSequence = 5 WHERE prod_productid=85 AND prod_PRSequence=30
GO
----------------------------------------------
--CRM Upgrade DataCorrections BEGIN
----------------------------------------------
		-- DEFECT 7213/7243 CRM - remove unwanted + menu items
		UPDATE CRM.dbo.custom_tabs SET Tabs_Deleted=1, Tabs_UpdatedDate=GETDATE(), Tabs_UpdatedBy=-1 WHERE Tabs_Entity='new' AND Tabs_Action IN ('newindividual','newsolution','newcase','newlead','newopportunity','newquote','neworder')
		UPDATE CRM.dbo.custom_tabs SET Tabs_Deleted=1,Tabs_UpdatedDate=GETDATE(), Tabs_UpdatedBy=-1 WHERE Tabs_Entity='newactivity' AND Tabs_Caption IN ('Appointment','Task','E-mail','MergeToWord','MergeToPDF')

		-- DEFECT 7208 - remove Import Newsletter Metrics from menu
		UPDATE CRM.dbo.custom_tabs SET Tabs_Deleted=1, Tabs_UpdatedDate=GETDATE(), Tabs_UpdatedBy=-1 WHERE Tabs_Entity='find' AND Tabs_Caption IN ('Import Newsletter Metrics')

		-- DEFECT 7212 - hide Consent tab in person record
		UPDATE CRM.dbo.custom_tabs SET Tabs_Deleted=1, Tabs_UpdatedDate=GETDATE(), Tabs_UpdatedBy=-1 WHERE Tabs_Entity='person' AND Tabs_Caption IN ('ConsentManagement')

		GO
		
		--Defect 7226 - appointment image missing
		UPDATE Custom_Tabs SET Tabs_Bitmap = 'Appointment.png', Tabs_UpdatedBy=-1, Tabs_UpdatedDate=GETDATE() WHERE Tabs_Bitmap='Appointment.gif' AND Tabs_Caption='Blue Book Images' and Tabs_Entity='find'

		--DEFECT 7216
		UPDATE Custom_Captions SET Capt_Deleted=1, Capt_UpdatedDate=GETDATE(), Capt_UpdatedBy=-1 WHERE capt_Family='comm_Action' AND Capt_code IN ('EMarketingDripEmail','EMarketingEmail')

		GO
		--DEFECT 7194
		EXEC usp_TravantCRM_AddCustom_Tabs 12, 'company', 'Relationships', 'customfile', 'PRCompany/PRCompanyRelationshipListing.asp'

		GO
----------------------------------------------
--CRM Upgrade DataCorrections END
----------------------------------------------

--Defect 7160 - Edit DSIR CRM Page
update custom_edits
	set
		colp_entrytype=21, --was 10 textbox
		colp_defaulttype=0,
		colp_entrysize=1, --was 50
		colp_datatype=4, 
		colp_datasize=50,
		colp_updateddate =getdate(),
		colp_updatedby=-1,
		colp_LookupFamily='prsoat_Pipeline' --was null
	where colp_colname = 'prsoat_Pipeline'

update custom_edits
	set
		colp_entrytype=21, --was 10 textbox
		colp_defaulttype=0,
		colp_entrysize=1, --was 50
		colp_datatype=4,
		colp_datasize=50,
		colp_updateddate =getdate(),
		colp_updatedby=-1,
		colp_LookupFamily='prsoat_Up_Down' --was null
	where colp_colname = 'prsoat_Up_Down'

update custom_edits
	set
		colp_entrytype=21, --was 10 textbox
		colp_defaulttype=0,
		colp_entrysize=1, --was 5
		colp_datatype=4,
		colp_datasize=5,
		colp_updateddate =getdate(),
		colp_updatedby=-1,
		colp_LookupFamily='prsoat_CancelReasonCode' --was null
	where colp_colname = 'prsoat_CancelReasonCode'

--Reorder Tabs_Entity='find' for main search menu in CRM
UPDATE Custom_Tabs SET TABS_ORDER=20, Tabs_UpdatedDate=GETDATE(), Tabs_UpdatedBy=-1 WHERE Tabs_TabId=149 AND Tabs_Entity='find' AND Tabs_Caption='Company' --company was 1
UPDATE Custom_Tabs SET TABS_ORDER=40, Tabs_UpdatedDate=GETDATE(), Tabs_UpdatedBy=-1 WHERE Tabs_TabId=150 AND Tabs_Entity='find' AND Tabs_Caption='Person' --was 2
UPDATE Custom_Tabs SET Tabs_Deleted=1, Tabs_UpdatedDate=GETDATE(), Tabs_UpdatedBy=-1 WHERE Tabs_TabID IN (151,152,153,10707,10750,10753,10754,10777)
GO

--***** BEGIN Defect 7227 data correction ***********************
	DECLARE @ForCommit bit
	-- SET this variable to 1 to commit changes

	SET @ForCommit = 1;

	--if (@ForCommit = 0) begin
		--PRINT '*************************************************************'
		--PRINT 'NOTE: COMMIT CHANGES IS TURNED OFF. NO CHANGES WILL BE SAVED!'
		--PRINT '*************************************************************'
		--PRINT ''
	--end

	DECLARE @Start DateTime
	SET @Start = GETDATE()
	--PRINT 'Execution Start: ' + CONVERT(VARCHAR(20), @Start, 100) + ' on server ' + @@SERVERNAME
	--PRINT ''

	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @T TABLE (
			[ndx] int IDENTITY(1,1),
			[userid] int
		)

		INSERT INTO @T
		SELECT user_userid FROM Users WHERE user_userid>0

		--PRINT '1. Select the possibly bad data to work with'
		--PRINT '-----------------------------------------------------'

		--SELECT * FROM userSettingsdefault WHERE USetDef_Key='CustomTabGroup-Company'

		--SELECT * FROM UserSettings 
			--INNER JOIN @T T ON T.userid = USet_UserId
		--WHERE uset_key='CustomTabGroup-Company' 
		--ORDER BY USet_UserId

		--PRINT '2. Make database changes'
		--PRINT '-----------------------------------------------------'
		IF NOT EXISTS(SELECT * FROM userSettingsdefault where USetDef_Key='CustomTabGroup-Company') 
		BEGIN
			DECLARE @ID int
			EXEC CRM.dbo.usp_GetNextID 'userSettingsdefault', @Return = @ID OUTPUT
			INSERT INTO CRM.dbo.userSettingsdefault (USetDef_ID, USetDef_CreatedBy, USetDef_CreatedDate, USetDef_UpdatedBy, USetDef_UpdatedDate, USetDef_TimeStamp, USetDef_Deleted, USetDef_Key, USetDef_Value)
			VALUES
			(@ID, -1, GetDate(), -1, GetDate(), GetDate(), NULL, 'CustomTabGroup-Company', '"QuickLook","Narrative","CompanyDashboard","Notes","Communications","People","Addresses","Phone/Email","Team","Library",')
		END

		DECLARE @RowCount int
		DECLARE @Ndx int
		DECLARE @UserID int
		DECLARE @HasCustomTabGroupCompany bit

		SET @RowCount = (SELECT COUNT(*) FROM @T)
		SET @Ndx = 0
		WHILE (@Ndx < @RowCount) BEGIN
			SET @Ndx = @Ndx + 1

			SET @HasCustomTabGroupCompany = 0

			SELECT	@UserID=userid FROM @T WHERE ndx=@Ndx
			IF EXISTS(SELECT * FROM UserSettings WHERE USet_Key='CustomTabGroup-Company' AND USet_UserId=@UserID) BEGIN SET @HasCustomTabGroupCompany = 1 END
		
			--SELECT @HasCustomTabGroupCompany HasCustomTabGroupCompany
			IF(@HasCustomTabGroupCompany = 1)
			BEGIN
				-- update record
				UPDATE UserSettings SET USet_Value = USet_Value + '"QuickLook",', USet_UpdatedBy=-1, USet_UpdatedDate=@Start
				WHERE USet_Key='CustomTabGroup-Company' AND USet_Value NOT LIKE '%"QuickLook"%' AND USet_UserId = @UserID

				UPDATE UserSettings SET USet_Value = USet_Value + '"Narrative",', USet_UpdatedBy=-1, USet_UpdatedDate=@Start
				WHERE USet_Key='CustomTabGroup-Company' AND USet_Value NOT LIKE '%"Narrative"%' AND USet_UserId = @UserID

				UPDATE UserSettings SET USet_Value = USet_Value + '"CompanyDashboard",', USet_UpdatedBy=-1, USet_UpdatedDate=@Start
				WHERE USet_Key='CustomTabGroup-Company' AND USet_Value NOT LIKE '%"CompanyDashboard"%' AND USet_UserId = @UserID

				UPDATE UserSettings SET USet_Value = USet_Value + '"Notes",', USet_UpdatedBy=-1, USet_UpdatedDate=@Start
				WHERE USet_Key='CustomTabGroup-Company' AND USet_Value NOT LIKE '%"Notes"%' AND USet_UserId = @UserID
			
				UPDATE UserSettings SET USet_Value = USet_Value + '"Communications",' , USet_UpdatedBy=-1, USet_UpdatedDate=@Start
				WHERE USet_Key='CustomTabGroup-Company' AND USet_Value NOT LIKE '%"Communications"%' AND USet_UserId = @UserID

				UPDATE UserSettings SET USet_Value = USet_Value + '"People",' , USet_UpdatedBy=-1, USet_UpdatedDate=@Start
				WHERE USet_Key='CustomTabGroup-Company' AND USet_Value NOT LIKE '%"People"%' AND USet_UserId = @UserID

				UPDATE UserSettings SET USet_Value = USet_Value + '"Addresses",' , USet_UpdatedBy=-1, USet_UpdatedDate=@Start
				WHERE USet_Key='CustomTabGroup-Company' AND USet_Value NOT LIKE '%"Addresses"%' AND USet_UserId = @UserID

				UPDATE UserSettings SET USet_Value = USet_Value + '"Phone/Email",' , USet_UpdatedBy=-1, USet_UpdatedDate=@Start
				WHERE USet_Key='CustomTabGroup-Company' AND USet_Value NOT LIKE '%"Phone/Email"%' AND USet_UserId = @UserID

				UPDATE UserSettings SET USet_Value = USet_Value + '"Team",' , USet_UpdatedBy=-1, USet_UpdatedDate=@Start
				WHERE USet_Key='CustomTabGroup-Company' AND USet_Value NOT LIKE '%"Team"%' AND USet_UserId = @UserID

				UPDATE UserSettings SET USet_Value = USet_Value + '"Library",' , USet_UpdatedBy=-1, USet_UpdatedDate=@Start
				WHERE USet_Key='CustomTabGroup-Company' AND USet_Value NOT LIKE '%"Library"%' AND USet_UserId = @UserID
			END
			ELSE
			BEGIN
				-- insert record
				DECLARE @nextid int
				exec usp_getNextId 'UserSettings', @nextid output
				INSERT INTO UserSettings (USet_SettingId, USet_UserID, USet_Key, USet_Value, USet_CreatedBy, USet_CreatedDate, USet_UpdatedBy, USet_UpdatedDate)
				VALUES(@nextid, @UserID, 'CustomTabGroup-Company', '"QuickLook","Narrative","CompanyDashboard","Notes","Communications","People","Addresses","Phone/Email","Team","Library",', -1, @Start, -1, @Start)
			
			END
		END

		--PRINT '3. New data after updates'
		--SELECT * FROM userSettingsdefault WHERE USetDef_Key='CustomTabGroup-Company'

		--SELECT * FROM UserSettings WHERE USet_Value LIKE '%"Narrative"%' OR USet_Value LIKE '%"Communications"%'
		--ORDER BY USet_UserId

		--SET NOCOUNT OFF

		--PRINT '';PRINT ''

		if (@ForCommit = 1) begin
			--PRINT 'COMMITTING CHANGES'
			COMMIT
		end else begin
			--PRINT 'ROLLING BACK ALL CHANGES'
			ROLLBACK TRANSACTION
		end

		END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		EXEC usp_RethrowError;
	END CATCH;

	--PRINT ''
	--PRINT 'Execution End: ' + CONVERT(VARCHAR(20), GETDATE(), 100)
	--PRINT 'Execution Time: ' +  CONVERT(varchar(10), DATEDIFF(millisecond, @Start, GETDATE())) + ' ms'
--***** END Defect 7227 data correction ***********************

