UPDATE UserSettings
   SET uset_value = 'color1',
       USet_UpdatedDate = GETDATE()
 WHERE uset_key = 'PreferredCssTheme'
   AND uset_value <> 'color1'


UPDATE UserSettings
   SET uset_value = uset_value + '"Self Service",',
       USet_UpdatedDate = GETDATE()
 WHERE uset_key = 'CustomTabGroup-Company'
   AND uset_value NOT LIKE  '%"Self Service"%'

Go


INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('P', 200, 'PersonSearchByRole', 1, 0);
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('T', 200, 'PersonSearchByRole', 1, 0);
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('S', 200, 'PersonSearchByRole', 1, 0);
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('L', 400, 'PersonSearchByRole', 1, 0);

INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('P', 200, 'CompanyListingDownload', 1, 0);
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('T', 200, 'CompanyListingDownload', 1, 0);
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('S', 200, 'CompanyListingDownload', 1, 0);
INSERT INTO PRBBOSPrivilege (IndustryType, AccessLevel, Privilege, Visible, Enabled) VALUES ('L', 400, 'CompanyListingDownload', 1, 0);
Go


-- Produce Spring
INSERT INTO PRLRLCycle (prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount)
VALUES ('P', 'B', '2016-01-19', '2016-07-18', 26);

-- Produce Fall
INSERT INTO PRLRLCycle (prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount)
VALUES ('P', 'B', '2016-07-19', '2017-01-16', 26);

-- Lumber All Year Non-Members
INSERT INTO PRLRLCycle (prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount)
VALUES ('L', 'N', '2016-01-19', '2017-01-16', 52);

-- Lumber Spring Members
INSERT INTO PRLRLCycle (prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount)
VALUES ('L', 'M', '2016-03-15', '2016-03-21', 1);

-- Lumber Fall Members
INSERT INTO PRLRLCycle (prlrlc_IndustryTypeCode, prlrlc_ServiceTypeCode, prlrlc_CycleStartDate, prlrlc_CycleEndDate, prlrlc_CycleCount)
VALUES ('L', 'M', '2016-09-13', '2016-09-19', 1);

Go

--SELECT DATEADD(w, 52, '2016-01-19')


UPDATE Communication
   SET Comm_Subject = CASE WHEN CHARINDEX('.', Comm_Note) > 0 
						THEN CASE WHEN CHARINDEX('.', Comm_Note) <= 50 
								THEN SUBSTRING(Comm_Note, 1, CHARINDEX('.', Comm_Note))
								ELSE SUBSTRING(Comm_Note, 1, CHARINDEX(' ', Comm_Note, 50)) + '...'	
							 END
						ELSE CASE WHEN LEN(CAST(Comm_Note as varchar(max))) <= 50
								THEN Comm_Note
								ELSE SUBSTRING(Comm_Note, 1, CHARINDEX(' ', Comm_Note, 50)) + '...'	
							 END
						END
Go