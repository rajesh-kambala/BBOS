
-- this statement will be run during table.es execution
-- Due to the amount of data in the cmli table, the script run through
-- the Sage es engine will fail due to timeout.
-- we are attempting to change it here to avoid the script timeout
ALTER TABLE Comm_Link ALTER COLUMN cmli_recipient NCHAR(255)
GO

-- Errors occur during the execution of Views.es 
-- We have customized several Sage native views.  The upgrade script
-- will have issues with this because it cannot merge our custom changes.
-- Therefore, we will remove our version of the views allowing Sage
-- to simply recreate their versions.  Then our build script will 
-- reapply the necessary chanegs for BBS functionality.
exec usp_AccpacDropView 'vSearchListCompany'
exec usp_AccpacDropView 'vSummaryPerson'
exec usp_AccpacDropView 'vAddressPerson'
exec usp_AccpacDropView 'vAddressCompany'
exec usp_AccpacDropView 'vReportCompany'

dump tran CRM with no_log