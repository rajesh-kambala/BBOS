/*
 * Copyright (c) 2002-2016 Travant Solutions, Inc.
 * Created by Travant Excel SQL MACROs
 * SQL created from PIKS Core Data Dictionary.xls
 * on 4/22/2016 12:14:25 PM
 *
 */

Set NoCount On
Select getdate() as "Start Date/Time";
Begin Transaction;
/*  Begin  */
Select 'Begin ';

-- Begin Address SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Address', N'column', N'addr_PRCityId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Address', N'column', N'addr_PRCityId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Represents the city location of the company.  Notes: The Addr_City column will not be used.  Instead, this column is used to constrain the city to a predetermined list.', N'user', N'dbo', N'table', N'Address', N'column', N'addr_PRCityId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Address', N'column', N'addr_PRCounty')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Address', N'column', N'addr_PRCounty'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The county associated with the address.  Notes: Because cities can span counties, this must be stored in the address.', N'user', N'dbo', N'table', N'Address', N'column', N'addr_PRCounty'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Address', N'column', N'addr_PRZone')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Address', N'column', N'addr_PRZone'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'UPS Zone  Notes: This may be beneficial to store and export back to BBS for services delivery.  Possible Values: Null, 2, 3, 4, 5, 6, 7, 8', N'user', N'dbo', N'table', N'Address', N'column', N'addr_PRZone'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Address', N'column', N'addr_uszipfive')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Address', N'column', N'addr_uszipfive'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Populated by a trigger, used for radius searching in the BBOS.', N'user', N'dbo', N'table', N'Address', N'column', N'addr_uszipfive'
GO


-- Begin Address_Link SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Address_Link', N'column', N'AdLi_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Address_Link', N'column', N'AdLi_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a generic ACCPAC column.  It is depicted here to demonstrate anticipated values.  Notes: Custom captions could potentially be used to provide this constrained list.  Note:  The tax address is used by BBS for tax calculations associated with services.  This may require a separate column.  Possible Values: Bill; Attn; Invoice; Mailing; Other; Physical; PP; Shipping; Tax; UPS; Warehouse', N'user', N'dbo', N'table', N'Address_Link', N'column', N'AdLi_Type'
GO


-- Begin Comm_Link SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Comm_Link', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Comm_Link'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This native Accpac table is archived by BBSI.  Any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'Comm_Link'
GO


-- Begin Communication SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_PRBusinessEventId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_PRBusinessEventId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Business event associated with the communication.', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_PRBusinessEventId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_PRCategory')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_PRCategory'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Categorizes a communication to various BBSI activities.  Notes: Custom captions can be used.', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_PRCategory'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_PRPersonEventId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_PRPersonEventId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Person event associated with the communication.', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_PRPersonEventId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_RequestID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_RequestID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Request ID associated with this communication', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_RequestID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_RequestID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_RequestID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRRequest table.', N'user', N'dbo', N'table', N'Communication', N'column', N'comm_RequestID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Communication', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Communication'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This native Accpac table is archived by BBSI.  Any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'Communication'
GO


-- Begin Company SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company (branch)', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This native ACCPAC column will not be edited, but rather will store equivalent of the book tradestyle.', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRAccountTier')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRAccountTier'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tiered value of account for sales purposes.  Notes: Applies only to BBSI customers.  Custom captions could be used for the constrained list.  Possible Values: A, B, etc', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRAccountTier'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRAdministrativeUsage')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRAdministrativeUsage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This describes any administrative usage of the facilities associated with this company (this location).  Notes: Custom captions could be used for the constrained list.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRAdministrativeUsage'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRBookTradestyle')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRBookTradestyle'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the tradestyle memo field in BBS.  It represents how the company name looks in a Blue Book listing.  Notes: This will be calculated upon any edits to the tradestyle columns (Comp_PRTradestyle1, etc.).  The primary purpose of this is to facilitate system interfaces.  It will not be shown on the user interface.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRBookTradestyle'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRBusinessReport')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRBusinessReport'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a transitional data element that informs the system not to produce the business report using PIKS facilities.  Instead an old, text-based facility will be used.  Notes: Default should probably be the old facilities to ensure that reports are not compromised until migration is complete.  This probably does not need to be on the UI, though it may be practical.  Possible Values: True = "New Facilities"', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRBusinessReport'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRBusinessStatus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRBusinessStatus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of the business status.  Notes: To describe if a company is in business, out of business, etc.  The values need clarification.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRBusinessStatus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRConfidentialFS')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRConfidentialFS'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is now a lookup value.  Notes: Some BBSI employees may also be prevented from seeing this.  Possible Values: comp_PRConfidentialFS', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRConfidentialFS'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRConnectionListDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRConnectionListDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date that the most recent connection list was received from this company.  Notes: This will be stored as a data element in place of attempting to create various rules from relationships that could potentially calculate this.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRConnectionListDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRCorrTradestyle')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRCorrTradestyle'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is equivalent to the BBS Correspondence Tradestyle.  It places the first name first, and has some other rules.  Notes: This will be calculated upon any edits to the tradestyle columns (Comp_PRTradestyle1, etc.).  The primary purpose of this is to facilitate system interfaces.  It will not be shown on the user interface.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRCorrTradestyle'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRCreditWorthCap')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRCreditWorthCap'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) A specified cap on the credit worth rating that can be applied.  This uses the same lookup as the credit worth rating itself.  Notes: The intent is to enforce the rule that the Credit Worth Rating cannot exceed this value.  This applies only to a headquarter company and is otherwise null.  This is subject to the custom captions constraint for credit worth rating.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRCreditWorthCap'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRCreditWorthCapReason')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRCreditWorthCapReason'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the reason behind the rating cap.  Notes: This applies only to headquarter company and is otherwise null.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRCreditWorthCapReason'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDataQualityTier')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDataQualityTier'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Internally used information to represent the relative importance of this company.  Used to assess priority regarding data migration, etc.  Notes: Custom captions could track the choices.  This would likely be pre-populated in some way, but users could make changes via the UI.  Possible Values: Critical, High, Medium, Low', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDataQualityTier'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDelistedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDelistedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the company''s status went from L or H to another value.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDelistedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDelistedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDelistedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Last Date the company''s status went to a non-Listed status', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDelistedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDLCountWhenListed')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDLCountWhenListed'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of DL lines when the company became listed.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRDLCountWhenListed'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PREBBTermsAcceptedBy')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PREBBTermsAcceptedBy'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ID of the user that accepted the membership terms.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PREBBTermsAcceptedBy'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PREBBTermsAcceptedBy')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PREBBTermsAcceptedBy'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'WebUserId', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PREBBTermsAcceptedBy'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PREBBTermsAcceptedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PREBBTermsAcceptedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date a Person with the company accepted the membership terms.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PREBBTermsAcceptedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRExcludeFSRequest')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRExcludeFSRequest'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating that this company should not receive an FS Request (for instance, if the rating is CWR = (150)).  Notes: This field replaces the comp_PRRequestFinancials field.
Original comp_PRRequestFinancials comments: This is set off if the company doesn''t provide them, and we wish to avoid bothering them.  This affects content in the listing report letter.  Possible Values: Null/''Y''  
Default = NULL', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRExcludeFSRequest'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRHandlesInvoicing')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRHandlesInvoicing'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A flag that determines whether or not this branch handles its own invoicing.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRHandlesInvoicing'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRHQId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRHQId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) This specifies the ID of the company that is the headquarters associated with the branch.   Notes: This column is null if the company is a headquarters.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRHQId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_PrimaryUserId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_PrimaryUserId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'ACCPAC Generic Column:  BBSI person assigned to maintaining or growing an account with this company.  Notes: Relates to a user in the User_Contacts table.', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_PrimaryUserId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRInvestigationMethodGroup')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRInvestigationMethodGroup'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Depicts a company as one in which BBSI is or is not seeking pay reports.  In time, classifications will be used to manage this.  Notes: The DBA will populate this field as a result of the migration from BBS.  Periodically, this will be refreshed (based on queries on classification and other factors).  PIKS does not have any rules for populating this field; however, the investigation metho  Possible Values: A (Pay reports sought); B', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRInvestigationMethodGroup'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRIsEligibleForEquifaxData')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRIsEligibleForEquifaxData'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Notes: Indicates this company is eligible to view Equifax data.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRIsEligibleForEquifaxData'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRJeopardyDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRJeopardyDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date upon which the company will be considered in jeopardy.  Notes: This is based on the jeopardy rules and is populated when financial statement information is populated.  This applies only to a headquarter company and is otherwise null.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRJeopardyDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLastPublishedCSDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLastPublishedCSDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date of the most recent published credit sheet.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLastPublishedCSDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLastVisitDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLastVisitDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last date the company was visited by BBSI', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLastVisitDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLastVisitedBy')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLastVisitedBy'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user_UserID of the last BBSI person to visit.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLastVisitedBy'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLegalName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLegalName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Legal name that is separate from the company tradestyle name.  Notes: When not null, the listing will show this as a "dba"', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLegalName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the company''s status was listed.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Last Date the company''s status went to Listed', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListingCityId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListingCityId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Default city for publishing.  This may vary with each company and does not depend on any of its addresses, though it frequently defaults to the city of its physical address.  Notes: This relates to PRCi_ListingCityID.  Companies are listed in publications under this city.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListingCityId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListingStatus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListingStatus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status of whether or not a company is published in the BlueBook and BBOS.  This relates only to those publications.  Possible Values: Listed; Not Listed- Service Only; Not listed- Listing Membership Prospect; Not listed- Previously listed; Not listed- reported closed/not a factor; Not Listed- Previously listed/membership prospect; Deleted before migration (not available after migration)', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRListingStatus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLogo')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLogo'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The company ID that represents the logo used for this company.  Notes: The logo is stored on a BBSI file server in a folder titled with the BBID number.  Accordingly, storing the correct BBID (could be the same company, could be headquarter, or could be an affiliate, etc.) is all that is necessary.  The full path leading to', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRLogo'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRMoralResponsibility')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRMoralResponsibility'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Numeric moral responsibility rating as determined by TES or other means.  Notes: This field is used by rating analysts as a consideration to assign the actual rating.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRMoralResponsibility'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRNAWLAID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRNAWLAID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used for Lumber Companies.  Their NAWLA ID.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRNAWLAID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents a previous name of a company and is used if a name change occurs.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName1Date')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName1Date'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents the date of a previous name change.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName1Date'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents a previous name of a company and is used if a name change occurs.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName2Date')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName2Date'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents the date of a previous name change.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName2Date'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents a previous name of a company and is used if a name change occurs.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName3Date')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName3Date'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents the date of a previous name change.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROldName3Date'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROriginalName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROriginalName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a name that is determined to be the original name of a company.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PROriginalName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRPublishPayIndicator ')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRPublishPayIndicator '
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the Pay Indicator should be published.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRPublishPayIndicator '
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRPublishUnloadHours')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRPublishUnloadHours'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to publish unload hours.  Notes: This determines if the Comp_PRUnloadHours should appear in the listing.  It is a paid line.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRPublishUnloadHours'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRReceiveLRL')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRReceiveLRL'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A flag that determines if this branch should receive listing report letters and verification letters.  Notes: Must be set on if Comp_PRTtype is "H".', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRReceiveLRL'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRReceiveTES')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRReceiveTES'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to determine whether or not a company can receive a TES form to provide trade information on other companies.  Enabling this supersedes the investigation algorithm.  Notes: The default condition should be true.  Like other company content, changing this flag will be tracked in a transaction.  Possible Values: True = "Receive"', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRReceiveTES'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSessionTrackerIDCheckDisabled')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSessionTrackerIDCheckDisabled'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the BBOS session tracking / license tracking is disabled for all users associated with this company.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSessionTrackerIDCheckDisabled'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSpecialHandlingInstruction')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSpecialHandlingInstruction'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Details of handling requirements.  Notes: This will appear at the top of the company screen, if specified.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSpecialHandlingInstruction'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSubordinationAgrDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSubordinationAgrDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the most recent subordination agreement.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSubordinationAgrDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSubordinationAgrProvided')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSubordinationAgrProvided'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicating that a subordination agreement has been provided by the company.  Possible Values: True = "Provided"', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRSubordinationAgrProvided'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTESNonresponder')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTESNonresponder'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to determine whether or not a company responds to TES requests', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTESNonresponder'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMAward')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMAward'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicating the company is awarded trading membership.  Possible Values: True = "Candidate", default is false.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMAward'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMAwardDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMAwardDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Effective date that the trading member status has been updated.  Possible Values: Default to current date.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMAwardDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMCandidate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMCandidate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicating the company is a candidate for trading membership.  Possible Values: True = "Candidate", default is false.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMCandidate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMCandidateDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMCandidateDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the company was designated as a candidate.  Possible Values: Default to current date.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMCandidateDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMComments')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMComments'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Comments regarding why a company is a candidate.  Comments may also be stored regarding why an award is given.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTMFMComments'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradeAssociationLogo')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradeAssociationLogo'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Logo to display for any associated trade association.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradeAssociationLogo'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'First part of company tradestyle name.  Notes: Will be used to populate the Name field.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Second part of company tradestyle name.  Notes: Will be used to populate the Name field.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Third part of company tradestyle name.  Notes: Will be used to populate the Name field.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Fourth part of company tradestyle name.  Notes: Will be used to populate the Name field.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRTradestyle4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Determines whether this is a headquarters or regular branch.  There can only be one headquarters for a company, and other branches are associated to it.  Notes: Headquarter and branch companies are treated as industry company content and are the focus of most rules in PIKs.  Possible Values: H=Headquarter; B=Branch', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnattributedOwnerDesc')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnattributedOwnerDesc'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the description of the nature of the ownership that is known to be associated to people or entities but cannot be specifically delineated.  Notes: This will appear as a category of ownership on product output (the business report, etc.).  It is not the same as "unknown", as that cannot be allocated to anything.  This applies only to a headquarter company and is otherwise null.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnattributedOwnerDesc'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnattributedOwnerPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnattributedOwnerPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This represents a percentage of ownership that is known to be associated to people or entities but cannot be specifically delineated.  Notes: This will appear as a category of ownership on product output (the business report, etc.).  It is not the same as "unknown", as that cannot be allocated to anything.  This applies only to a headquarter company and is otherwise null.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnattributedOwnerPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnconfirmed')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnconfirmed'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to indicate a record entered via the BBOS website has not been confirmed by a BBSI analyst  Notes: Values other than NULL will prevent the associated record from appearing in Search Select dropdowns', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnconfirmed'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnloadHours')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnloadHours'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of times available for trucks to unload materials.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRUnloadHours'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRWebActivated')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRWebActivated'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the company has member access to the web site.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRWebActivated'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRWebActivatedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRWebActivatedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The data the WebActiviated flag was last changed.', N'user', N'dbo', N'table', N'Company', N'column', N'comp_PRWebActivatedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_WebSite')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_WebSite'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Deprecated - Use Email table instead.', N'user', N'dbo', N'table', N'Company', N'column', N'Comp_WebSite'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Company', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Company'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is an existing PIKS table', N'user', N'dbo', N'table', N'Company'
GO


-- Begin Email SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRPreferredInternal')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRPreferredInternal'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this record should be used for internal communciation purposes.', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRPreferredInternal'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRPreferredPublished')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRPreferredPublished'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'In cases where only one record can be displayed, indicates which published record should be selected.', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRPreferredPublished'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRPublish')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRPublish'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this record should be displayed to external users via the listing, BBOS, etc.', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRPublish'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRSequence')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRSequence'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'BBS Slot #', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRSequence'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRWebAddress')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRWebAddress'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'When a web address, this contains the URL.', N'user', N'dbo', N'table', N'Email', N'column', N'emai_PRWebAddress'
GO

-- Begin Library SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Library', N'column', N'libr_PRFileId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Library', N'column', N'libr_PRFileId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) To permit documents associated with trading assistance files.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'Library', N'column', N'libr_PRFileId'
GO


-- Begin NewProduct SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_code')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_code'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Maps to the associated Service Code', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_code'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_IndustryTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_IndustryTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only used for membership related products.', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_IndustryTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_IndustryTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_IndustryTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Comma delimited list of associated industry types.', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_IndustryTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRIsTaxed')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRIsTaxed'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if taxes apply to this product.', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRIsTaxed'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRRecurring')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRRecurring'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the product recurrs, usually annually.', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRRecurring'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRServiceUnits')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRServiceUnits'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of service units that comes with the product.', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRServiceUnits'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRWebAccess')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRWebAccess'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the product comes with BBOS access.', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRWebAccess'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRWebAccessLevel')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRWebAccessLevel'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum level of access that comes with the product.', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRWebAccessLevel'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRWebUsers')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRWebUsers'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of users that comes with the product', N'user', N'dbo', N'table', N'NewProduct', N'column', N'prod_PRWebUsers'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'NewProduct', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'NewProduct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table contains the product information sold online via the BBOS and via BBS CRM.', N'user', N'dbo', N'table', N'NewProduct'
GO


-- Begin Opportunity SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Opportunity', N'column', N'oppo_PRLostReason')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Opportunity', N'column', N'oppo_PRLostReason'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason an opportunity was not successfully closed.  Notes: Custom captions could be used to link reasons with specific codes.  Note:  There may already be a data element within the ACCPAC data model that achieves the purpose of this column.', N'user', N'dbo', N'table', N'Opportunity', N'column', N'oppo_PRLostReason'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Opportunity', N'column', N'Oppo_Source')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Opportunity', N'column', N'Oppo_Source'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'For Blueprint opportunities:  BBSI initiated from ad in another publication; BBSI initiated based upon timing of BP content; BBSI initiated – other; Customer expressed interest; Other
For Member Upgrade opportunities: Customer initiated, former service us  Notes: This will not be altered, except that custom captions will be utilized to constrain it to this list.  Depending upon the opportunity type, the appropriate list will be made available.', N'user', N'dbo', N'table', N'Opportunity', N'column', N'Oppo_Source'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Opportunity', N'column', N'Oppo_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Opportunity', N'column', N'Oppo_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'ACCPAC Column  Notes: Note to Peter:  Potentially used to differentiate types of opportunities based on workflows (new member, member upgrade, Blue Prints, etc.).', N'user', N'dbo', N'table', N'Opportunity', N'column', N'Oppo_Type'
GO


-- Begin Person SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRDeathDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRDeathDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Established date of death for the person.  Notes: If not null, all links to companies are inactivated with the reason code populated as "Deceased"', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRDeathDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRIndustryStartDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRIndustryStartDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date that this person entered the produce industry.  Notes: Question:  Should this really be a year, rather than a full date?', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRIndustryStartDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRLanguageSpoken')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRLanguageSpoken'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A list of languages spoken other than English.', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRLanguageSpoken'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRLinkedInProfile')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRLinkedInProfile'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The URL to the person''s public LinkedIn profile', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRLinkedInProfile'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRMaidenName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRMaidenName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Maiden Name', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRMaidenName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRMaternalLastName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRMaternalLastName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Maternal last name, tracked separately from last name, used with latin names.  Notes: Distinguish on the UI from other fields visually (different color).', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRMaternalLastName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRNickname1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRNickname1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nickname', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRNickname1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRNickname2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRNickname2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nickname', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRNickname2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRNotes')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRNotes'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Miscellaneous information that needs to be viewed quickly on the screen depicting the person (i.e deduping doesn''t handle this properly, and it is not a duplicate Joe Smith).', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRNotes'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRPaternalLastName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRPaternalLastName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Paternal last name, tracked separately from last name, used with latin names.  Notes: Distinguish on the UI from other fields visually (different color).', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRPaternalLastName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRUnconfirmed')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRUnconfirmed'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to indicate a record entered via the BBOS website has not been confirmed by a BBSI analyst  Notes: Values other than NULL will prevent the associated record from appearing in Search Select dropdowns', N'user', N'dbo', N'table', N'Person', N'column', N'pers_PRUnconfirmed'
GO


-- Begin Person_Link SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRAUSChangePreference')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRAUSChangePreference'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates what type of changes trigger an Alerts report  Notes: Custom captions', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRAUSChangePreference'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRAUSReceiveMethod')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRAUSReceiveMethod'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates how this person receives Alerts reports.  Notes: Custom captions', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRAUSReceiveMethod'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRBRPublish')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRBRPublish'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating that this individual has requested not to be published in association with this company in the business report.  Possible Values: True = Publish', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRBRPublish'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRDLTitle')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRDLTitle'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The title as it would appear in paid descriptive lines (Blue Book listing, etc.).', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRDLTitle'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PREBBPublish')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PREBBPublish'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating that this individual has requested not to be published in association with this company in the Electronic Blue Book product.  Possible Values: True = Publish', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PREBBPublish'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PREditListing')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PREditListing'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person is authorized to edit listing data.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PREditListing'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PREndDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PREndDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the person started with the company (in text).', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PREndDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRExitReason')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRExitReason'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'An explanation of why the person left the respective company.  Notes: This column would remain null until a person is removed from a company.  It would then be populated with a code that is translated via custom captions.  Possible Values: D=Deceased;F=Fired;R=Retired;Q=Quit;O=Other/Unknown;T=Transferred;S=Still with company (requested removal from contact list)', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRExitReason'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRPctOwned')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRPctOwned'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The percentage of ownership of a company attributed to a person.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRPctOwned'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRRatingLine')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRRatingLine'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the full rating line of the company, for which the person has been associated.  Notes: This column would remain null until a person is removed from a company.  It would then be populated with the text of the full rating line upon disconnecting the person from the company.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRRatingLine'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRReceivesCreditSheetReport')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRReceivesCreditSheetReport'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person recieves the Credit Sheet report via email.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRReceivesCreditSheetReport'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRReceivesPromoEmail')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRReceivesPromoEmail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Receive Promotional Emails from Blue Book Services', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRReceivesPromoEmail'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRReceivesTrainingEmail')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRReceivesTrainingEmail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Receive Educational Emails about Blue Book Services', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRReceivesTrainingEmail'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRResponsibilities')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRResponsibilities'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of job or key responsibilities that the person does in association with this company.  Notes: The user interface should depict this (via a suitable label) in a manner that indicates it will be published (to ensure proper use of language).', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRResponsibilities'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRStartDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRStartDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the person started with the company (in text).', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRStartDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRStatus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRStatus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This represents the status of the connection between the person and the company.  Possible Values: Active; Inactive; No Longer Connected', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRStatus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRSubmitTES')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRSubmitTES'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the person can submit a TES form.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRSubmitTES'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRTitle')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRTitle'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The freeform text title of the person associated with the company.  Notes: This column was designed by ACCPAC to reside in the Person table.  It is moved to this table to permit a history of titles to be retained.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRTitle'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRTitleCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRTitleCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The categorized title of the person associated with the company.  Notes: This column was designed by ACCPAC to reside in the Person table.  It is moved to this table to permit a history of titles to be retained.  The codes are translated via ACCPAC custom captions.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRTitleCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRUpdateCL')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRUpdateCL'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the person can update the connection list.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRUpdateCL'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRUseServiceUnits')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRUseServiceUnits'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the person can use service units.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRUseServiceUnits'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRWhenVisited')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRWhenVisited'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Text indicating when this person was last visited.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRWhenVisited'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRWillSubmitARAging')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRWillSubmitARAging'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person is willing to submit A/R aging data', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_PRWillSubmitARAging'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'PeLi_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'PeLi_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) This native ACCPAC column will be used to describe the role of a person at a company.  Notes: This will become a key into the PRRoles table.  Question:  Is this alphanumeric.  Should it be converted to an integer field?', N'user', N'dbo', N'table', N'Person_Link', N'column', N'PeLi_Type'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_WebPassword')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_WebPassword'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The password used to access the web site.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_WebPassword'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_WebStatus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_WebStatus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicates this person has access to the web site in the context of this company.', N'user', N'dbo', N'table', N'Person_Link', N'column', N'peli_WebStatus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Person_Link', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Person_Link'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is an existing PIKS table', N'user', N'dbo', N'table', N'Person_Link'
GO


-- Begin Phone SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_Default')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_Default'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a native field.  NO LONGER USED BY BBSi.', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_Default'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRDescription')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRDescription'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A text description of the telephone number''s purpose.  Notes: This can be used for publishing (overriding the telephone type), or it can be used for internal purposes as a reminder when considering language for DL.  Refer to the rules for defaults in this document.  Also, a series of predetermined phrases can be sel', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRDescription'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRDisconnected')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRDisconnected'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to set the phone as disconnected.  Possible Values: True = "Disconnected"', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRDisconnected'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRExtension')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRExtension'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The telephone extension number.', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRExtension'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRInternational')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRInternational'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to determine if "011" is required to be dialed from the US or Canada.  Notes: Default = "False"  Possible Values: True = "Required"', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRInternational'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRIsFax')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRIsFax'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a generic fax type.  This is set based on the phon_Type value.', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRIsFax'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRIsPhone')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRIsPhone'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a generic phone type.  This is set based on the phon_Type value.', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRIsPhone'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRPreferredInternal')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRPreferredInternal'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this record should be used for internal communciation purposes.', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRPreferredInternal'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRPreferredPublished')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRPreferredPublished'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'In cases where only one record can be displayed, indicates which published record should be selected.', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRPreferredPublished'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRPublish')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRPublish'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to determine if this telephone number should be published.  Possible Values: True = "Publish"', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRPublish'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRSequence')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRSequence'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order of telephones to display (when published).', N'user', N'dbo', N'table', N'Phone', N'column', N'phon_PRSequence'
GO


-- Begin PRAdCampaign SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdCampaignID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdCampaignID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdCampaignID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdCampaignType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdCampaignType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: pradc_AdCampaignType custom_captions', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdCampaignType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdColor')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdColor'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Custom Caption Lookup', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdColor'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdSize')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdSize'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Custom Caption Lookup', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_AdSize'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_ClickCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_ClickCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times the ad has been clicked.', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_ClickCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_CreativeStatus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_CreativeStatus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Custom Caption Lookup', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_CreativeStatus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_ImpressionCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_ImpressionCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times the ad has been displayed.', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_ImpressionCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the campaign.', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Orientation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Orientation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Custom Caption Lookup', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Orientation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_PeriodClickCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_PeriodClickCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Click Count for the current period.', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_PeriodClickCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_PeriodImpressionCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_PeriodImpressionCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Impression Count for the current period.', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_PeriodImpressionCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Placement')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Placement'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Custom Caption Lookup', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Placement'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_PublicationArticleID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_PublicationArticleID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRPublicationArticle table', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_PublicationArticleID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Section')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Section'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Custom Caption Lookup', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_Section'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_TargetURL')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_TargetURL'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The URL to link the ad to.', N'user', N'dbo', N'table', N'PRAdCampaign', N'column', N'pradc_TargetURL'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaign'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds the definition of a company''s advertising campaign.', N'user', N'dbo', N'table', N'PRAdCampaign'
GO


-- Begin PRAdCampaignAuditTrail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_AdCampaignAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_AdCampaignAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_AdCampaignAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_AdCampaignID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_AdCampaignID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to the PRAdCampaign table.', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_AdCampaignID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_AdEligiblePageID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_AdEligiblePageID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to the PRAdEligiblePage table.', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_AdEligiblePageID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_Clicked')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_Clicked'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the link was clicked.', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_Clicked'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The company ID for the associated PRWebUser', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_Rank')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_Rank'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The rank of where the ad displayed on the parent page.', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_Rank'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_SearchAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_SearchAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If a sponsored link, foreign key to the PRSearchAuditTrail table.', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_SearchAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_SponsoredLinkType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_SponsoredLinkType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If a sponsored link, which type.', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_SponsoredLinkType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to the PRWebUser table.', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', N'column', N'pradcat_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks advertisement impressions and clicks.  This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRAdCampaignAuditTrail'
GO

-- Begin PRARAging SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ARAgingId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ARAgingId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ARAgingId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ARAgingImportFormatID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ARAgingImportFormatID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ID of the A/R Aging Import Format used, if any.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ARAgingImportFormatID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company reporting the accounts receivable.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Count')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Count'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count of PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Count'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Date')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Date'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of aging information.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Date'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_DateSelectionCriteria')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_DateSelectionCriteria'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'How dates are selected.  Notes: Currently 3-character abbreviation in BBS.  Custom Captions could be used to constrain the list.  Possible Values: DUE, INV, SHP, DIS', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_DateSelectionCriteria'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ImportedByUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ImportedByUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user Id who imported the data', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ImportedByUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ImportedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ImportedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date/time the data was imported', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ImportedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ManualEntry')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ManualEntry'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicating the data was manually entered', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_ManualEntry'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_PersonId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_PersonId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) The person that reported the aged AR.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_PersonId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_RunDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_RunDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date report was run by provider.  Notes: Relevant if imported from system.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_RunDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sum of the corresponding field in the PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total0to29')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total0to29'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sum of the corresponding field in the PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total0to29'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total1to30')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total1to30'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sum of the corresponding field in the PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total1to30'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total30to44')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total30to44'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sum of the corresponding field in the PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total30to44'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total31to60')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total31to60'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sum of the corresponding field in the PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total31to60'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total45to60')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total45to60'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sum of the corresponding field in the PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total45to60'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total61Plus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total61Plus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sum of the corresponding field in the PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total61Plus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total61to90')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total61to90'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sum of the corresponding field in the PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total61to90'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total91Plus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total91Plus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sum of the corresponding field in the PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_Total91Plus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_TotalCurrent')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_TotalCurrent'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sum of the corresponding field in the PRARAgingDetails records for this batch.  Denormalized value for performance reasons.', N'user', N'dbo', N'table', N'PRARAging', N'column', N'praa_TotalCurrent'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAging', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAging'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRARAging'
GO


-- Begin PRARAgingDetail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount0to29')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount0to29'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount owned from 0-29 days of the aging date.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount0to29'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount1to30')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount1to30'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount owned from 0-29 days past the due date.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount1to30'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount30to44')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount30to44'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount owned from 30-44 days of the aging date.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount30to44'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount31to60')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount31to60'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount owned from 31-60 days past the due date.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount31to60'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount45to60')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount45to60'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount owned from 45-60 days of the aging date.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount45to60'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount61Plus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount61Plus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount owned 61 or more days after the aging date.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount61Plus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount61to90')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount61to90'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount owned from 61-90 days past the due date.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount61to90'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount91Plus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount91Plus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount owned 91 or more days after the due date.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Amount91Plus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_AmountCurrent')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_AmountCurrent'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount owed that is within due date.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_AmountCurrent'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ARAgingDetailId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ARAgingDetailId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ARAgingDetailId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ARAgingId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ARAgingId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Report of company associated with accounts receivable.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ARAgingId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ARCustomerID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ARCustomerID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Recognized customer number in the reporting company''s AR system.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ARCustomerID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_CreditTerms')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_CreditTerms'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Credit Terms from input file', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_CreditTerms'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Exception ')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Exception '
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record resulted in a PRException record being created.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_Exception '
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileCityName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileCityName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'City name from input file', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileCityName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileCompanyName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileCompanyName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company name from input file', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileCompanyName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileStateName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileStateName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'State name from input file', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileStateName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileZipCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileZipCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zip code from input file.', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_FileZipCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ManualCompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ManualCompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company ID from manual input', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_ManualCompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_PhoneNumber')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_PhoneNumber'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Phone number from the input file', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_PhoneNumber'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_SubjectCompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_SubjectCompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Denormalized from the ARTranslation table', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_SubjectCompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_TimeAged')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_TimeAged'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Time Aged from input file', N'user', N'dbo', N'table', N'PRARAgingDetail', N'column', N'praad_TimeAged'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingDetail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRARAgingDetail'
GO


-- Begin PRARAgingImportFormat SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount0to29ColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount0to29ColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the Amount0To29 data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount0to29ColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount30to44ColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount30to44ColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the Amount30To44 data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount30to44ColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount45to60ColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount45to60ColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the Amount45To60 data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount45to60ColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount61PlusColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount61PlusColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the Amount61Plus data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Amount61PlusColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_AsOfDateColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_AsOfDateColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the AsOfDate data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_AsOfDateColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_AsOfDateRowIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_AsOfDateRowIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the AsOfDate data element.  -1 If it does not exist in the header lines..', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_AsOfDateRowIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CityNameColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CityNameColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the CityName data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CityNameColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CompanyIDColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CompanyIDColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the CompanyID data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CompanyIDColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CompanyNameColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CompanyNameColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the CompanyName data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CompanyNameColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CreditTermsColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CreditTermsColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the CreditTerms data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_CreditTermsColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DateFormat')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DateFormat'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date Format  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DateFormat'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DateSelectionCriteriaColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DateSelectionCriteriaColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the DateSelectCritiera data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DateSelectionCriteriaColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DateSelectionCriteriaRowIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DateSelectionCriteriaRowIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Row index of the DateSelectCritiera data element.  -1 If it does not exist in the header lines.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DateSelectionCriteriaRowIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DefaultDateSelectionCriteria')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DefaultDateSelectionCriteria'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The value to use for the DateSelectionCriteria if it isnot part of the import file.  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DefaultDateSelectionCriteria'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DelimiterChar')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DelimiterChar'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'For file format ''Delimited'', the delimiter character', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_DelimiterChar'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_FileFormat')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_FileFormat'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'File Format  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_FileFormat'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Format Name', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_NumberHeaderLines')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_NumberHeaderLines'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of header lines in the input file', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_NumberHeaderLines'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_PhoneNumberColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_PhoneNumberColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the phone number data element.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_PhoneNumberColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_RunDateColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_RunDateColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the RunDate data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_RunDateColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_RunDateRowIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_RunDateRowIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the RunDate data element.  -1 If it does not exist in the header lines.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_RunDateRowIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_StateNameColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_StateNameColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the StateName data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_StateNameColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_TimeAgedColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_TimeAgedColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the TimeAged data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_TimeAgedColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_ZipCodeColIndex')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_ZipCodeColIndex'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column index of the ZipCode data element.  -1 If it does not exist in the import file.', N'user', N'dbo', N'table', N'PRARAgingImportFormat', N'column', N'praaif_ZipCodeColIndex'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARAgingImportFormat'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the input format for an A/R aging file', N'user', N'dbo', N'table', N'PRARAgingImportFormat'
GO


-- Begin PRARTranslation SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARTranslation', N'column', N'prar_ARTranslationId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARTranslation', N'column', N'prar_ARTranslationId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRARTranslation', N'column', N'prar_ARTranslationId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARTranslation', N'column', N'prar_CustomerNumber')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARTranslation', N'column', N'prar_CustomerNumber'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The customer number of the trading partner reported by the company.', N'user', N'dbo', N'table', N'PRARTranslation', N'column', N'prar_CustomerNumber'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRARTranslation', N'column', N'prar_PRCoCompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRARTranslation', N'column', N'prar_PRCoCompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The company associated with PIKS.  Notes: This corresponds to an instance of Comp_CompanyID.', N'user', N'dbo', N'table', N'PRARTranslation', N'column', N'prar_PRCoCompanyId'
GO


-- Begin PRAttentionLine SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_AddressID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_AddressID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to the Address table.  Mutually exclusive with the EmailID and FaxID values.', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_AddressID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_AttentionLineID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_AttentionLineID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_AttentionLineID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to the Company table', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_CustomLine')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_CustomLine'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Mutually exclusive with the PersonID value.', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_CustomLine'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_Disabled')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_Disabled'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this attention line is enabled.', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_Disabled'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_EmailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_EmailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to the Email table.  Mutually exclusive with the AddressID and FaxID values.', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_EmailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_IncludeWireTransferInstructions')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_IncludeWireTransferInstructions'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'For billing purposes', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_IncludeWireTransferInstructions'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_ItemCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_ItemCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Custom Caption value:', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_ItemCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_PersonID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_PersonID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to the Person table.  Mutually exclusive with the CustomLine value.', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_PersonID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_PhoneID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_PhoneID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to the Phone table.  Mutually exclusive with the EmailID and Address values.', N'user', N'dbo', N'table', N'PRAttentionLine', N'column', N'prattn_PhoneID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttentionLine'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table associates addressees with delivery addresses for the various items that BBSI sends to customer and members.', N'user', N'dbo', N'table', N'PRAttentionLine'
GO


-- Begin PRAttribute SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_AttributeId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_AttributeId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_AttributeId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_IPDFlag')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_IPDFlag'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating that this attribute is associated with an IPD standard description.  Possible Values: True = IPD standard.', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_IPDFlag'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of attribute.  Possible Values: Small, Large', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type or category of the attribute.  Notes: This would be controlled by look-up codes within the application (Custom Captions table).  Possible Values: Codes associated with Growing Method, Style, etc.', N'user', N'dbo', N'table', N'PRAttribute', N'column', N'prat_Type'
GO


-- Begin PRBBScore SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_BBScore')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_BBScore'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value provided by Open Data for Bluebook Score.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_BBScore'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_BBScoreId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_BBScoreId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Notes: A row in this table corresponds to a complete set of data delivered from Open Data for a specific company..  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_BBScoreId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company associated with the rating.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_ConfidenceScore')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_ConfidenceScore'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value provided by Open Data for Confidence Score.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_ConfidenceScore'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Current')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Current'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag depicting this row as the current data for the company.  This is particularly relevant to the Bluebook score, which is widely used.  Notes: This will permit faster queries of current Bluebook scores.  Possible Values: True = "Current"', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Current'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Date')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Date'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date that data is provided.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Date'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Exception')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Exception'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicates an Exception record was created as the result of importing this record.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Exception'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_MinimumTradeReportCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_MinimumTradeReportCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value provided by Open Data for P975surveys.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_MinimumTradeReportCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_NewBBScore')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_NewBBScore'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used when experimenting with new algorithms.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_NewBBScore'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_ObservationPeriodTES')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_ObservationPeriodTES'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value provided by Open Data for Observation Period TES.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_ObservationPeriodTES'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_P80Surveys')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_P80Surveys'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value provided by Open Data for P80surveys.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_P80Surveys'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_P90Surveys')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_P90Surveys'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value provided by Open Data for P90surveys.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_P90Surveys'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_P95Surveys')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_P95Surveys'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value provided by Open Data for P95surveys.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_P95Surveys'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_PRPublish')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_PRPublish'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the BBScores are publishable based on a variety of rules.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_PRPublish'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Recency')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Recency'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value provided by Open Data for Recency.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_Recency'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_RecentTES')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_RecentTES'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value provided by Open Data for Recent TES.', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_RecentTES'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_RequiredReportCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_RequiredReportCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of required Trade Reports', N'user', N'dbo', N'table', N'PRBBScore', N'column', N'prbs_RequiredReportCount'
GO


-- Begin PRBookImageFile SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_BookImageFileID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_BookImageFileID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_BookImageFileID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_CompanyCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_CompanyCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'How many companies were included the last time this file was generated.', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_CompanyCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_Criteria')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_Criteria'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The criteria to apply to the data to generate the file.', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_Criteria'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_FileName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_FileName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the generated file', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_FileName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_FileType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_FileType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file type: Book Image, Product Index, Name Indixex  Possible Values: BI, PI, NI', N'user', N'dbo', N'table', N'PRBookImageFile', N'column', N'prbif_FileType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBookImageFile'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table contains the types of book image files that can be generated.', N'user', N'dbo', N'table', N'PRBookImageFile'
GO


-- Begin PRBRResponse.* SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 1 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 1 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 1 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 1 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QA4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 2 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 2 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 2 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 2 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QB4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 3 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 3 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 3 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 3 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QC4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 4 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 4 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 4 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 4 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QD4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 5 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 5 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 5 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 5 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QE4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 6 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 6 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 6 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 6 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QF4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 7 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 7 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 7 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 7 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QG4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 8 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 8 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 8 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 8 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QH4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 9 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 9 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 9 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 9 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QI4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 10 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 10 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 10 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 10 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QJ4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 11 - Poor', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 11 - Fair', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 11 - Good', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 11 - Excellent', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QK4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QLN')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QLN'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 12 - No', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QLN'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QLY')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QLY'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Question 12 - Yes', N'user', N'dbo', N'table', N'PRBRResponse.*', N'column', N'QLY'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBRResponse.*'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds the responses from the Business Report Survey.  It is populated by both Teleform and this application.', N'user', N'dbo', N'table', N'PRBRResponse.*'
GO


-- Begin PRBusinessEvent SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AgreementCategory')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AgreementCategory'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Category of agreement in principle.  Notes: Custom captions will constrain the list.  Relevant to Agreement in Principle and Letter of Intent.  Possible Values: Buy from; Sell to', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AgreementCategory'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_Amount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_Amount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This will represent a dollar amount of a specific activity.  Notes: This will be used as needed for the specific event type (i.e. lien; judgment; etc.).', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_Amount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssetAmount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssetAmount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total worth of relevant assets to the event.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssetAmount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssigneeTrusteeAddress')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssigneeTrusteeAddress'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Address of assignee for benefit of creditors  Notes: Includes city; state; etc.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssigneeTrusteeAddress'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssigneeTrusteeName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssigneeTrusteeName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of assignee for benefit of creditors  Notes: Trustee name for US Bankruptcy filing will also be stored here.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssigneeTrusteeName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssigneeTrusteePhone')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssigneeTrusteePhone'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Telephone number of assignee for benefit of creditors  Notes: Trustee telephone for US Bankruptcy filing will also be stored here.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AssigneeTrusteePhone'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AttorneyName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AttorneyName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of relevant attorney.  Notes: Detailed analysis or querying on a company''s attorney is not necessary.  Debtor attorney name is stored here for bankruptcy and attorney name for injunction is stored here.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AttorneyName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AttorneyPhone')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AttorneyPhone'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Telephone number of relevant attorney  Notes: Debtor attorney for bankruptcy; attorney for injunction.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_AttorneyPhone'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_BusinessEventId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_BusinessEventId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_BusinessEventId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_BusinessEventTypeId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_BusinessEventTypeId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) The type of business event involved.  Notes: Serves as lookup for list of business event types.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_BusinessEventTypeId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_BusinessOperateUntil')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_BusinessOperateUntil'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date which business must cease operation -  for PACA License Suspended event.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_BusinessOperateUntil'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CaseNumber')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CaseNumber'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Case number associated with court activities.  Notes: Associated with various types; including injunctions and TRO.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CaseNumber'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Headquarter company associated with the business event.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CourtDistrict')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CourtDistrict'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Court district associated with an injunction or TRO.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CourtDistrict'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CreditSheetNote')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CreditSheetNote'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Information designated specifically for the credit sheet to describe this business event.  Notes: This seems to belong here; however; it may be desirable for this to be on a specialized version of the transaction record.  This will be determined as requirements are fully understood.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CreditSheetNote'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CreditSheetPublish')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CreditSheetPublish'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to determine if this business event should appear in the credit sheet.  Possible Values: True = "Publish"', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_CreditSheetPublish'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_DetailedType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_DetailedType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generic type field.  Notes: Custom captions table can be used to constrain the list.  Possible Values: Fire; Flood; Tornado; Hurricane; Freeze; Drought; Other', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_DetailedType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_DisasterImpact')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_DisasterImpact'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of business impact resulting from disaster.  Notes: Custom captions will constrain the list.  Possible Values: Loss; Business Interruption; Loss and Business Interruption', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_DisasterImpact'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_EffectiveDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_EffectiveDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the event occurred or will take effect.  Notes: This is used for sorting events but is not displayed in products.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_EffectiveDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_IndividualBuyerId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_IndividualBuyerId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Individual purchasing a company.  This is used for the "Ownership Sale from One Individual to Another" business event.    Notes: This relates to Pers_PersonID.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_IndividualBuyerId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_IndividualOperateUntil')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_IndividualOperateUntil'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date which individual must cease operation – for PACA License Suspended event.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_IndividualOperateUntil'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_IndividualSellerId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_IndividualSellerId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Individual selling a company.  This is used for the "Ownership Sale from One Individual to Another" business event.    Notes: This relates to Pers_PersonID.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_IndividualSellerId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_InternalAnalysis')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_InternalAnalysis'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Analysis and other comments that will not be depicted in any BBSI products.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_InternalAnalysis'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_LiabilityAmount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_LiabilityAmount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total worth of relevant liabilities to the event.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_LiabilityAmount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_Names')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_Names'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Relevant names to a business event.  The names of the business founder(s).  Notes: Names of founders for Business Started; individuals named in PACA License Suspended event; etc.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_Names'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_NonPromptEnd')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_NonPromptEnd'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'End of non-prompt pay period for PACA License Suspended event.  Notes: Date is entered as text.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_NonPromptEnd'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_NonPromptStart')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_NonPromptStart'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Start of non-prompt pay period for PACA License Suspended event.  Notes: Date is entered as text.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_NonPromptStart'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_NumberSellers')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_NumberSellers'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of sellers involved in PACA License Suspended event.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_NumberSellers'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_OtherDescription')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_OtherDescription'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generic details field.  Notes: Only completed via the UI if "Other" is chosen for PRBe_DisasterType.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_OtherDescription'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_PercentSold')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_PercentSold'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Percentage of a business sold.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_PercentSold'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_PublishedAnalysis')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_PublishedAnalysis'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of BBSI analysis associated with the business event that may be published for external view.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_PublishedAnalysis'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_PublishUntilDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_PublishUntilDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date prior to which this event should be available in the business report (assuming the event is published).  The type of event would determine the time span and calculate this date.  Notes: As an example; a Bankruptcy event would have a date set to 10 years from the effective date.  This can then be edited to serve specific circumstances.  Some business events will be set to the current date (i.e. not to publish).', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_PublishUntilDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_RelatedCompany1Id')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_RelatedCompany1Id'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) This is the company (in the content base) that is associated as a party to the business event.  Notes: Relates to Comp_CompanyID.  This is used for Acquistion; Agreement in Principle; Divestiture.  Also serves as the receiving party for the Receivership Appointed event and the Plaintiff company for a TRO event.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_RelatedCompany1Id'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_RelatedCompany2Id')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_RelatedCompany2Id'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) This is the company (in the content base) that is associated as a second party to the business event.  Notes: Relates to Comp_CompanyID.  This is party company for the Receivership Appointed event.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_RelatedCompany2Id'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_SpecifiedCSNumeral')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_SpecifiedCSNumeral'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Desired numeral that will appear on the credit sheet associated with this business event.  Notes: Custom captions will be used to constrain the list.  This is relevant to US Bankruptcy Filing.  Possible Values: 17; 18; 19', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_SpecifiedCSNumeral'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_StateId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_StateId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The state or province (US or Canada).  Notes: Relates to PRSt_StateID.  Used for Business Entity Change but only if PRBe_NewEntityType is C Corporation; Sub chapter S Corporation; Corporation; or Limited Liability Company.  Also used for PACA License Suspended event.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_StateId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_UpdatedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_UpdatedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Bankruptcy court district.  Notes: Custom captions will be used to constrain the list.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_UpdatedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_USBankruptcyCourt')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_USBankruptcyCourt'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates personal or business.  Notes: Custom captions will be used to constrain the list.  Possible Values: Business (default); Personal', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_USBankruptcyCourt'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_USBankruptcyEntity')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_USBankruptcyEntity'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Notes: Note:  This is considered separate from the Person Event for Bankruptcy.', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_USBankruptcyEntity'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_USBankruptcyVoluntary')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_USBankruptcyVoluntary'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicating voluntary or involuntary bankruptcy.  Possible Values: True = Voluntary', N'user', N'dbo', N'table', N'PRBusinessEvent', N'column', N'prbe_USBankruptcyVoluntary'
GO


-- Begin PRBusinessEventType SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_BusinessEventTypeId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_BusinessEventTypeId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for business event types.', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_BusinessEventTypeId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_IndustryTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_IndustryTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The industry type code this event can be used for.  This is a multi-select custom caption tied to comp_PRIndustryType', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_IndustryTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the event type.  Possible Values: Acquisition, Agreement in Principle, etc.', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_PublishDefaultTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_PublishDefaultTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of years this type of business event is normally published.  Notes: Fractional amounts are possible.  Possible Values: Set to 1000 to serve as "indefinite".', N'user', N'dbo', N'table', N'PRBusinessEventType', N'column', N'prbt_PublishDefaultTime'
GO


-- Begin PRBusinessReportRequest SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_AddressLine1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_AddressLine1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'First line of address if sending to an address not in PIKS.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_AddressLine1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_AddressLine2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_AddressLine2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Second line of address if sending to an address not in PIKS.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_AddressLine2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_BusinessReportRequestId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_BusinessReportRequestId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_BusinessReportRequestId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_CityStateZip')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_CityStateZip'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'City, State and Zipcode  Notes: Perhaps this should be populated by choosing an existing address at the company.  The assumption here is that it will be entered freeform.  Refer to issue #38.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_CityStateZip'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_CreatedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_CreatedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time of report request.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_CreatedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_DoNotChargeUnits')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_DoNotChargeUnits'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicates the company was not charged any units for this report.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_DoNotChargeUnits'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_EmailAddress')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_EmailAddress'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Email address to send the report.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_EmailAddress'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_Fax')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_Fax'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Fax number to send the report.  Notes: Perhaps this should be populated by choosing an existing fax at the company.  The assumption here is that it will be entered freeform.  Refer to issue #38.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_Fax'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_MethodSent')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_MethodSent'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The manner in which the report was provided to the requestor.  Notes: Custom captions can be used.  Possible Values: Fax; Verbal; Mail; Email', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_MethodSent'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestedCompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestedCompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) The company that was the subject of the business report request.  Notes: This relates to Comp_CompanyID.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestedCompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestingCompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestingCompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Headquarter company associated with the business event.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestingCompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestingPersonId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestingPersonId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Person to whom the report will be sent.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestingPersonId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestorInfo')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestorInfo'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This column is used if the person does not exist in the content base', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_RequestorInfo'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_SurveyIncluded')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_SurveyIncluded'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicates a TES was included with this report.', N'user', N'dbo', N'table', N'PRBusinessReportRequest', N'column', N'prbr_SurveyIncluded'
GO


-- Begin PRChangeDetection SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRChangeDetection', N'column', N'prchngd_AssociatedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRChangeDetection', N'column', N'prchngd_AssociatedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ID of the record that changed.', N'user', N'dbo', N'table', N'PRChangeDetection', N'column', N'prchngd_AssociatedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRChangeDetection', N'column', N'prchngd_AssociatedType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRChangeDetection', N'column', N'prchngd_AssociatedType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of record that changed.', N'user', N'dbo', N'table', N'PRChangeDetection', N'column', N'prchngd_AssociatedType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRChangeDetection', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRChangeDetection'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks changes to various company elements and is used to determine if those changes warrant refreshing the accounting system for the changed company.', N'user', N'dbo', N'table', N'PRChangeDetection'
GO


-- Begin PRCity SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_City')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_City'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the city.', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_City'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_CityId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_CityId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_CityId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_DST')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_DST'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Observes Daylight Savings', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_DST'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_FieldSalesRepId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_FieldSalesRepId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The BBSI field sales rep assigned to accounts with this location.  Notes: This relates to the User_Contacts table.  It is through this mechanism that sales reps will be assigned to companies.', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_FieldSalesRepId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_InsideSalesRepId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_InsideSalesRepId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The BBSI inside sales rep assigned to accounts with this location.  Notes: This relates to the User_Contacts table.  It is through this mechanism that sales reps will be assigned to companies.', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_InsideSalesRepId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_ListingSpecialistId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_ListingSpecialistId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The BBSI listing specialist assigned to companies with this location.  Notes: This relates to the User_Contacts table.  It is through this mechanism that listing specialists will be assigned to companies.', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_ListingSpecialistId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_RatingTerritory')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_RatingTerritory'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A named investigation territory.', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_RatingTerritory'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_RatingUserId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_RatingUserId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The BBSI rating analyst assigned to companies with this location.  Notes: This relates to the User_Contacts table.  It is through this mechanism that rating analysts will be assigned to companies.', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_RatingUserId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_SalesTerritory')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_SalesTerritory'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(Index) A named sales territory.  Notes: This represents a trip code for BBSI field sales representatives.  It is also used for deals.  The codes are maintained by the DBA and change infrequently.', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_SalesTerritory'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_StateId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_StateId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) State or Province', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_StateId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_Timezone')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_Timezone'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Timezone Name', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_Timezone'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_TimezoneOffset')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_TimezoneOffset'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'UTC Timezone Offset', N'user', N'dbo', N'table', N'PRCity', N'column', N'prci_TimezoneOffset'
GO


-- Begin PRClassification SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Abbreviation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Abbreviation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Abbreviation to be used in reports and products.  Notes: Applicable only to classifications (not classification groups).', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Abbreviation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_BookSection')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_BookSection'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This corresponds to the section in the Blue Book that a listing would be printed.  It has no meaning for other publications or reports.  Notes: This column is only pertinent (and will only be populated) for classification groups (i.e PRCL_Level = 1)  Possible Values: 0 (for Produce); 1 (for transportation); 2 (for supply)', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_BookSection'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_ClassificationId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_ClassificationId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_ClassificationId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_CompanyCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_CompanyCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of companies that have this classification.', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_CompanyCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Description')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Description'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'More detail about the description.', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Description'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Description_ES')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Description_ES'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description in Spanish.  This fiedl was formerly prcl_SpanishDescription', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Description_ES'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_DisplayOrder')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_DisplayOrder'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order in which the classifications should be displayed.', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_DisplayOrder'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Level')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Level'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The tier or level in the tree to represent this as either a classification group or a classification.  Notes: The lowest level (2) will be referenced elsewhere in the system and assigned to companies.  Level 1 represents the Classification Group and is for reporting and analysis only (no data entry).', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Level'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only used to populate BBS SuppVal table.', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only used to populate BBS SuppVal table.', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only used to populate BBS SuppVal table.', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line3'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line4')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line4'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only used to populate BBS SuppVal table.', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Line4'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the classification or classification group.  Possible Values: Seller, Broker, Buying Office, Procurement Office', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Name_ES')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Name_ES'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Spanish Name of the classification or classification group.  This field was previously named prcl_SpanishName  Possible Values: Seller, Broker, Buying Office, Procurement Office', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_Name_ES'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_ParentId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_ParentId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The classification group name associated with this classification.  Possible Values: Will be null if this is a classification group.', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_ParentId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_ShortDescription')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_ShortDescription'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short description used primarily by the BBOS Mobile.', N'user', N'dbo', N'table', N'PRClassification', N'column', N'prcl_ShortDescription'
GO


-- Begin PRCommodity SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Alias')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Alias'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Additional name used in the industry or designed by BBSI', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Alias'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_CommodityCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_CommodityCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Abbreviated code used to create listings and potentially other published material.', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_CommodityCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_CommodityId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_CommodityId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_CommodityId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_FullName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_FullName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A combination of commoditly level names to provide a more descriptive name when displaying lower levels in a non-hierarchical format.', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_FullName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_IPDFlag')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_IPDFlag'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Designates if this commodity is associated with the IPD standard.  Possible Values: True = IPD', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_IPDFlag'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Level')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Level'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The tier or level in the tree associated with this commodity.', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Level'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the commodity', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Name_ES')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Name_ES'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Spanish name of the commodity.  Field previously named prcm_SpanishName', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_Name_ES'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_ShortDescription')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_ShortDescription'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short description used primarily by the BBOS Mobile.', N'user', N'dbo', N'table', N'PRCommodity', N'column', N'prcm_ShortDescription'
GO


-- Begin PRCompanyAlias SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyAlias', N'column', N'pral_Alias')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyAlias', N'column', N'pral_Alias'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Alias name.', N'user', N'dbo', N'table', N'PRCompanyAlias', N'column', N'pral_Alias'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyAlias', N'column', N'pral_CompanyAliasId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyAlias', N'column', N'pral_CompanyAliasId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCompanyAlias', N'column', N'pral_CompanyAliasId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyAlias', N'column', N'pral_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyAlias', N'column', N'pral_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company to which alias belongs.', N'user', N'dbo', N'table', N'PRCompanyAlias', N'column', N'pral_CompanyId'
GO


-- Begin PRCompanyBrand SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Brand')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Brand'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of brand.  Possible Values: Dole; Chiquita', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Brand'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_CompanyBrandId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_CompanyBrandId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_CompanyBrandId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company (branch)', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Description')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Description'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Other descriptive material about the brand.', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Description'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_OwningCompany')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_OwningCompany'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the company that is known to own the brand.  Notes: This is not constrained to companies in the content list.', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_OwningCompany'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_PrintableImageLocation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_PrintableImageLocation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A path name to a file containing a printable image of a brand logo.  Notes: The UI will permit browse functionality to choose a file path.', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_PrintableImageLocation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Publish')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Publish'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to determine if this brand information should appear in the Blue Book listing or other publications of the company.  Notes: How should this default?  Possible Values: True = "Publish"', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Publish'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Sequence')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Sequence'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order that the brand should published (if set for publishing).', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_Sequence'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_ViewableImageLocation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_ViewableImageLocation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A path name to a file containing a JPG or equivalent viewable image of a brand logo.  Notes: The UI will permit browse functionality to choose a file path.', N'user', N'dbo', N'table', N'PRCompanyBrand', N'column', N'prc3_ViewableImageLocation'
GO


-- Begin PRCompanyClassification SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_AirFreight')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_AirFreight'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to indicate if freight forwarder uses air freight.  Notes: Applies to Freight Forwarder classification.  Possible Values: True = Yes', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_AirFreight'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ClassificationId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ClassificationId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Classification involved.', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ClassificationId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ComboStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ComboStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating there are combo stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: True = Yes', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ComboStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_CompanyClassificationId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_CompanyClassificationId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_CompanyClassificationId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company involved.', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ConvenienceStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ConvenienceStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating there are convenience stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: True = Yes', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ConvenienceStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_GourmetStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_GourmetStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating there are gourmet supermarket stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: True = Yes', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_GourmetStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_GroundFreight')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_GroundFreight'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to indicate if freight forwarder uses ground freight.  Notes: Applies to Freight Forwarder classification.', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_GroundFreight'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_HealthFoodStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_HealthFoodStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating there are health food stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: True = Yes', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_HealthFoodStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfComboStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfComboStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of combo stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: 1-4; 5-9; 10-19; 20-49; 50-99; 100-249; 250-499; 500-999; 1000-2999; 3000+', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfComboStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfConvenienceStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfConvenienceStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of convenience stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: 1-4; 5-9; 10-19; 20-49; 50-99; 100-249; 250-499; 500-999; 1000-2999; 3000+', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfConvenienceStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfGourmetStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfGourmetStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of gourmet supermarket stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: 1-4; 5-9; 10-19; 20-49; 50-99; 100-249; 250-499; 500-999; 1000-2999; 3000+', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfGourmetStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfHealthFoodStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfHealthFoodStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of health food stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: 1-4; 5-9; 10-19; 20-49; 50-99; 100-249; 250-499; 500-999; 1000-2999; 3000+', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfHealthFoodStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfProduceOnlyStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfProduceOnlyStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of produce-only stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: 1-4; 5-9; 10-19; 20-49; 50-99; 100-249; 250-499; 500-999; 1000-2999; 3000+', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfProduceOnlyStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total number of stores associated with retail classifications (expressed in a range).  Notes: Custom captions could be used to control the choice of ranges.  Possible Values: 1-4; 5-9; 10-19; 20-49; 50-99; 100-249; 250-499; 500-999; 1000-2999; 3000+', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfSupermarketStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfSupermarketStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of supermarket stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: 1-4; 5-9; 10-19; 20-49; 50-99; 100-249; 250-499; 500-999; 1000-2999; 3000+', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfSupermarketStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfSuperStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfSuperStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of super stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: 1-4; 5-9; 10-19; 20-49; 50-99; 100-249; 250-499; 500-999; 1000-2999; 3000+', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfSuperStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfWarehouseStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfWarehouseStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of warehouse stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: 1-4; 5-9; 10-19; 20-49; 50-99; 100-249; 250-499; 500-999; 1000-2999; 3000+', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_NumberOfWarehouseStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_OceanFreight')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_OceanFreight'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to indicate if freight forwarder uses ocean freight.  Notes: Applies to Freight Forwarder classification.  Possible Values: True = Yes', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_OceanFreight'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_Percentage')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_Percentage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The percentage of overall business associated with this classification or group.  Notes: This is entered for a classification but calculated by the system if a classification group.', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_Percentage'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_PercentageSource')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_PercentageSource'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating the percentage that was provided by the company or is a BBSI estimate.  Possible Values: True = Provided from company.  False = PRCo estimate.', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_PercentageSource'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ProduceOnlyStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ProduceOnlyStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating there are produce-only stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: True = Yes', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_ProduceOnlyStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_RailFreight')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_RailFreight'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to indicate if freight forwarder uses rail freight.  Notes: Applies to Freight Forwarder classification.  Possible Values: True = Yes', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_RailFreight'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_SupermarketStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_SupermarketStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating there are supermarket stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: True = Yes', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_SupermarketStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_SuperStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_SuperStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating there are super stores.  Notes: This applies to the Ret classification when assigned to headquarter facilities.  Possible Values: True = Yes', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_SuperStores'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_WarehouseStores')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_WarehouseStores'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This applies to the Ret classification when assigned to headquarter facilities.  Notes: Y', N'user', N'dbo', N'table', N'PRCompanyClassification', N'column', N'prc2_WarehouseStores'
GO


-- Begin PRCompanyExternalNews SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_Code')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_Code'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This company''s code in the external news system.', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_Code'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_CompanyCodeID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_CompanyCodeID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_CompanyCodeID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_Exclude')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_Exclude'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this company should be excluded from the article lookup even though it has a code in the external news system.', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_Exclude'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_LastLookupDateTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_LastLookupDateTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last date/time this company was searched for in the 3rd party system.', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_LastLookupDateTime'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_LastRetrievalDateTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_LastRetrievalDateTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time artciles were retreived for this company and external news system.', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_LastRetrievalDateTime'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_LookupCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_LookupCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'How many times this company has been searched for in the 3rd party system.', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_LookupCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_PrimarySourceCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_PrimarySourceCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The code identifying the external news system.', N'user', N'dbo', N'table', N'PRCompanyExternalNews', N'column', N'prcen_PrimarySourceCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyExternalNews'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds the lookup codes and the last retrievl dates to allow us to query external news providers for articles.', N'user', N'dbo', N'table', N'PRCompanyExternalNews'
GO


-- Begin PRCompanyIndicators SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyIndicators', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyIndicators'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is intended to hold the various business processing flags for a company.  It should not hold any end-user business data.', N'user', N'dbo', N'table', N'PRCompanyIndicators'
GO


-- Begin PRCompanyLicense SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) ID of company branch.', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_CompanyLicenseId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_CompanyLicenseId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_CompanyLicenseId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_Number')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_Number'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'License number', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_Number'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_Publish')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_Publish'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A flag determining if this license should appear in the company''s listing.  Possible Values: True = "Publish"', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_Publish'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the specific industry license that is owned by the company.  Notes: This will be a constrained list that will probably have single letter codes associated with the license names as stated in the values field.  This could be managed with custom captions.  Possible Values: MC, FF, CFIA, DOT', N'user', N'dbo', N'table', N'PRCompanyLicense', N'column', N'prli_Type'
GO


-- Begin PRCompanyMergeAuditLog SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyMergeAuditLog', N'column', N'prcmal_ReasonCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyMergeAuditLog', N'column', N'prcmal_ReasonCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Why the companies where merged.', N'user', N'dbo', N'table', N'PRCompanyMergeAuditLog', N'column', N'prcmal_ReasonCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyMergeAuditLog', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyMergeAuditLog'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is an audit trail table that tracks when company data is merged into a single company.', N'user', N'dbo', N'table', N'PRCompanyMergeAuditLog'
GO


-- Begin PRCompanyPayIndicator SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_ARAgingDetailLongCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_ARAgingDetailLongCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The count of PRARAgingDetails records found for this subject company in the defined long period.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_ARAgingDetailLongCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_ARAgingDetailShortCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_ARAgingDetailShortCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The count of PRARAgingDetails records found for this subject company in the defined short period.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_ARAgingDetailShortCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_ARSubmitterLongCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_ARSubmitterLongCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The count of unique AR Aging Submitters for this subject company found in the defined long period.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_ARSubmitterLongCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CompanyPayIndicatorID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CompanyPayIndicatorID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CompanyPayIndicatorID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_Current')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_Current'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the record is current.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_Current'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CurrentAmount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CurrentAmount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sum total of valid "Current" values found on all of the PRARAgingDetail records that were included in this calculation.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CurrentAmount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CurrentCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CurrentCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The count of valid "Current" values found on all of the PRARAgingDetail records that were included in this calculation.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_CurrentCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_PayIndicator')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_PayIndicator'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The translated name for the Pay Indicator score.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_PayIndicator'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_PayIndicatorScore')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_PayIndicatorScore'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The calculated numeric Pay Indicator score.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_PayIndicatorScore'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_TotalAmount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_TotalAmount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sum total of valid "Current" and "Non-Current" values found on all of the PRARAgingDetail records that were included in this calculation.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_TotalAmount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_TotalCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_TotalCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The count of valid "Current" and "Non-Current" values found on all of the PRARAgingDetail records that were included in this calculation.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', N'column', N'prcpi_TotalCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyPayIndicator'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This tracks the calculated pay ratings for companies.', N'user', N'dbo', N'table', N'PRCompanyPayIndicator'
GO


-- Begin PRCompanyProductProvided SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProductProvided', N'column', N'prcprpr_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProductProvided', N'column', N'prcprpr_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRCompanyProductProvided', N'column', N'prcprpr_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProductProvided', N'column', N'prcprpr_CompanyProductProvidedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProductProvided', N'column', N'prcprpr_CompanyProductProvidedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRCompanyProductProvided', N'column', N'prcprpr_CompanyProductProvidedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProductProvided', N'column', N'prcprpr_ProductProvidedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProductProvided', N'column', N'prcprpr_ProductProvidedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PPRroductProvided table.', N'user', N'dbo', N'table', N'PRCompanyProductProvided', N'column', N'prcprpr_ProductProvidedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProductProvided', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProductProvided'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A bridge table associating products provided to specific companies.', N'user', N'dbo', N'table', N'PRCompanyProductProvided'
GO


-- Begin PRCompanyProfile SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_AtmosphereStorage')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_AtmosphereStorage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag that determines if controlled atmosphere rooms/facilities are available.  Possible Values: True = "Available"; Default=False', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_AtmosphereStorage'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrCollectPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrCollectPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Broker description estimated percentage that broker collects and remits for shippers account.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrCollectPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrConfirmation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrConfirmation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Broker description flag that broker confirmations are issued.  Possible Values: True = "Issues Confirmations"; Default= False', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrConfirmation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrGroundInspections')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrGroundInspections'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Broker description flag that on-ground inspections are conducted or arranged.  Possible Values: True = "Inspections Conducted"; Default= False', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrGroundInspections'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrReceive')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrReceive'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Broker description of types of companies from which brokerage is received.  Notes: Custom captions can be used.  Possible Values: Null; Shipper; Buyer; Both', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrReceive'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrTakeFrieght')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrTakeFrieght'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Broker description flag stating that freight bill is taken.  Possible Values: True = "Take Freight"  Default = False', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrTakeFrieght'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrTakePossessionPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrTakePossessionPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Broker description estimated percentage that physical possession is taken.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrTakePossessionPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrTakeTitlePct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrTakeTitlePct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Broker description estimated percentage that title is taken.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_BkrTakeTitlePct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company associated with the profile information.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_CompanyProfileId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_CompanyProfileId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_CompanyProfileId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_HAACP')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_HAACP'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag that determines if HAACP certified.  Possible Values: True = "Certified"; Default= False', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_HAACP'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_HAACPCertifiedBy')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_HAACPCertifiedBy'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'HAACP certifying authority.  Notes: Freeform text.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_HAACPCertifiedBy'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_HumidityStorage')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_HumidityStorage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag that determines if humidity control rooms/facilities are available.  Possible Values: True = "Available"; Default=False', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_HumidityStorage'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_Organic')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_Organic'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag that determines if Organic certified.  Possible Values: True = "Certified"; Default= False', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_Organic'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_OrganicCertifiedBy')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_OrganicCertifiedBy'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Organic certifying authority.  Notes: Custom captions can potentially be used', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_OrganicCertifiedBy'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_OtherCertification')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_OtherCertification'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Other certification.  Notes: Freeform text.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_OtherCertification'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_QTV')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_QTV'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag that determines if QTV certified.  Possible Values: True = "Certified"; Default= False', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_QTV'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_QTVCertifiedBy')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_QTVCertifiedBy'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'QTV certifying authority.  Notes: Freeform text.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_QTVCertifiedBy'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_RailServiceProvider1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_RailServiceProvider1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'First Rail Service Provider', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_RailServiceProvider1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_RailServiceProvider2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_RailServiceProvider2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Second Rail Service Provider', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_RailServiceProvider2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_RipeningStorage')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_RipeningStorage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag that determines if ripening rooms/facilities are available.  Possible Values: True = "Available"; Default=False', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_RipeningStorage'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellBrokersPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellBrokersPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Selling description estimated percentage of selling to brokers/distributors', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellBrokersPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellBuyOthers')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellBuyOthers'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Selling description estimated percentage of buying that takes place from other growers or shippers.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellBuyOthers'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellCoOpPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellCoOpPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Sold to Co-op/Buying Group', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellCoOpPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellDistributors')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellDistributors'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sells to produce wholesalers/distributors.  Notes: Checkbox on user interface:  Produce Wholesaler/Distributors', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellDistributors'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellDomesticBuyersPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellDomesticBuyersPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Selling description estimated percentage of selling to domestic buyers.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellDomesticBuyersPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellExportersPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellExportersPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Selling description estimated percentage of selling to international exporters.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellExportersPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellFoodWholesaler')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellFoodWholesaler'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sells to food service wholesaler.  Notes: Checkbox on user interface:  Foodservice Wholesaler', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellFoodWholesaler'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellHomeCenterPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellHomeCenterPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Sold to Home Center', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellHomeCenterPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellInstitutions')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellInstitutions'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sells to institutions.  Notes: Checkbox on user interface:  Institutions', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellInstitutions'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellMilitary')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellMilitary'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sells to military.  Notes: Checkbox on user interface:  Military', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellMilitary'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellOfficeWholesalePct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellOfficeWholesalePct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Sold to Office Wholesalers', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellOfficeWholesalePct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellOtherPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellOtherPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Sold to Other', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellOtherPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellProDealerPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellProDealerPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Sold to Professional Dealers', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellProDealerPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellRestaurants')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellRestaurants'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sells to restaurants.  Notes: Checkbox on user interface:  Restaurants', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellRestaurants'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellRetailGrocery')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellRetailGrocery'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sells to retail grocers.  Notes: Checkbox on user interface:  Retail Grocery', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellRetailGrocery'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellRetailYardPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellRetailYardPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Sold to Retail Lumber Yard', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellRetailYardPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellSecManPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellSecManPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Sold to secondary manufacturers', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellSecManPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellStockingWholesalePct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellStockingWholesalePct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Sold to Stocking Wholesalers', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellStockingWholesalePct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellWholesalePct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellWholesalePct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Selling description estimated percentage of selling to local wholesalers.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SellWholesalePct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyBrokersPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyBrokersPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sourcing description estimated percentage of buying from brokers/distributors', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyBrokersPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyExportersPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyExportersPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sourcing description estimated percentage of buying from international exporters.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyExportersPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyMillsPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyMillsPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Purchased from Mills/Producers:', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyMillsPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyOfficeWholesalePct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyOfficeWholesalePct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Purchased from Office Wholesalers', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyOfficeWholesalePct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyOtherPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyOtherPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Purchased from Other', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyOtherPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuySecManPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuySecManPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Purchased from Secondary Manufacturers:', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuySecManPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyShippersPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyShippersPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sourcing description estimated percentage of buying from domestic shippers.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyShippersPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyStockingWholesalePct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyStockingWholesalePct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Purchased from Stocking Wholesalers', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyStockingWholesalePct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyWholesalePct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyWholesalePct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sourcing description estimated percentage of buying from local wholesalers.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcBuyWholesalePct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcTakePhysicalPossessionPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcTakePhysicalPossessionPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Take physical possession of product.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_SrcTakePhysicalPossessionPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageBushel')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageBushel'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total volume in bushels.  Notes: Custom captions can be used to constrain the list.  Possible Values: 1-49,999; 50,000-99,999; 100,000-249,999; 250,000-499,999; 500,000-749,999; 750,000-999,999; 1,000,000 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageBushel'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageCarlots')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageCarlots'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total storage capacity in car lots.  Notes: Custom captions can be used to constrain the list.  Possible Values: 1-24; 25-49; 50-74; 75-99; 100-199; 200-499; 500-999; 1000 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageCarlots'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageCF')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageCF'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total volume in cubic feet.  Notes: Custom captions can be used to constrain the list.  Possible Values: 1-49,999; 50,000-99,999; 100,000-499,999; 500,000-999,999; 1,000,000 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageCF'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageCoveredSF')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageCoveredSF'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Covered Storage in Square Feet', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageCoveredSF'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageSF')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageSF'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total area in square feet.  Notes: Custom captions can be used to constrain the list..  Possible Values: 1-9,999; 10,000-24,999; 25,000-49,999; 50,000-99,999; 100,000-249,999; 250,000 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageSF'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageUncoveredSF')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageUncoveredSF'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Uncovered Storage in Square Feed', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageUncoveredSF'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageWarehouses')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageWarehouses'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of warehouses.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_StorageWarehouses'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrCargoAmount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrCargoAmount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount of cargo insurance coverage.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrCargoAmount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrCargoCarrier')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrCargoCarrier'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name and address of cargo insurance carrier.  Notes: Misc. freeform text.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrCargoCarrier'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrContainer')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrContainer'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of containers.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrContainer'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrDirectHaulsPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrDirectHaulsPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trucking description estimated percentage of directly arranged hauls.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrDirectHaulsPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrDryVan')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrDryVan'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of dry van trailers.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrDryVan'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrFlatbed')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrFlatbed'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of flatbed trailers.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrFlatbed'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrLiabilityAmount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrLiabilityAmount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount of liability insurance coverage.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrLiabilityAmount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrLiabilityCarrier')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrLiabilityCarrier'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name and address of liability carrier.  Notes: Misc. freeform text.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrLiabilityCarrier'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrOther')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrOther'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of other units.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrOther'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrOtherColdPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrOtherColdPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trucking description estimated percentage of volume that is non-produce and refrigerated.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrOtherColdPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrOtherWarmPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrOtherWarmPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trucking description estimated percentage of volume that is non-produce and not refrigerated.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrOtherWarmPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrPiggyback')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrPiggyback'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of piggyback trailers.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrPiggyback'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrPowerUnits')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrPowerUnits'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of power units.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrPowerUnits'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrProducePct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrProducePct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trucking description estimated percentage of volume that is produce.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrProducePct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrReefer')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrReefer'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of reefer trailers.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrReefer'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTanker')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTanker'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of tankers.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTanker'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTeams')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTeams'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trucking description flag that trucker uses driving teams.  Possible Values: True = "Uses Teams"; Default=False', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTeams'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTPHaulsPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTPHaulsPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trucking description estimated percentage of third-party arranged hauls.', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTPHaulsPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrailersLeased')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrailersLeased'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of trailers leased.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrailersLeased'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrailersOwned')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrailersOwned'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of trailers owned.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrailersOwned'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrucksLeased')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrucksLeased'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of trucks leased.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrucksLeased'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrucksOwned')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrucksOwned'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of trucks owned.  Notes: Custom captions will constrain the list.  Possible Values: 1-5; 6-10; 11-24; 25-49; 50-99; 100 or more', N'user', N'dbo', N'table', N'PRCompanyProfile', N'column', N'prcp_TrkrTrucksOwned'
GO


-- Begin PRCompanyRegion SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Associated profile row.', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_CompanyRegionId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_CompanyRegionId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_CompanyRegionId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_RegionId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_RegionId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Region', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_RegionId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Describes the type of service associated with this region.  Notes: This will be automatically assigned based on the fields in the user interface (i.e. the user is assigning source description regions).  Possible Values: 1=Areas Served by Trucker; 2= Domestic Sourcing Region; 3= Domestic Selling Region', N'user', N'dbo', N'table', N'PRCompanyRegion', N'column', N'prcd_Type'
GO


-- Begin PRCompanyRelationship SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_Active')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_Active'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating that the relationship is active.  The company must state the relationship is no longer valid to inactivate it.  Notes: Defaults to True  Possible Values: True = "Active"', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_Active'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_CompanyRelationshipId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_CompanyRelationshipId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_CompanyRelationshipId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_CreatedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_CreatedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the date that the relationship was created in PIKS.  Notes: Every table has columns for create and update dates and users.  This column follows ACCPAC''s standard.', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_CreatedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_LeftCompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_LeftCompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) ID of branch on the left side of the trading relationship.  Notes: Example:  Company "X" in "X is a buyer of Y".', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_LeftCompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_OwnershipPct')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_OwnershipPct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The percentage of ownership the parent company has over the subsidiary in a partial ownership relationship type.  Notes: This only applies to the relationship type of partially owned subsidiary.', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_OwnershipPct'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_RightCompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_RightCompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) ID of branch on the right side of the trading relationship.  Notes: Example:  Company "Y" in "X is a buyer of Y".', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_RightCompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_Source')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_Source'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source of relationship information.  Notes: Custom captions will be used to constrain the source types.  This may still require the PRRelationshipSource lookup table if descriptions are needed.  Possible Values: Phone, email, connection list, trade experience survey.', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_Source'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_TimesReported')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_TimesReported'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a counter that is incremented each time a specific relationship is reported.  Notes: This is only incremented on equivalent relationship types (i.e. a #15 does not result in incrementing the #9 reported a month ago).', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_TimesReported'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_TransactionFrequency')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_TransactionFrequency'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A measurement of the frequency of dealings.  Notes: Custom captions could be used.  Possible Values: Weekly; Monthly; Seasonally', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_TransactionFrequency'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_TransactionVolume')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_TransactionVolume'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A measurement of transaction volume associated with this relationship.  Notes: Custom captions could be used.  Possible Values: High; Medium; Low', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_TransactionVolume'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Relationship type', N'user', N'dbo', N'table', N'PRCompanyRelationship', N'column', N'prcr_Type'
GO


-- Begin PRCompanyServiceProvided SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyServiceProvided', N'column', N'prcserpr_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyServiceProvided', N'column', N'prcserpr_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRCompanyServiceProvided', N'column', N'prcserpr_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyServiceProvided', N'column', N'prcserpr_CompanyServiceProvidedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyServiceProvided', N'column', N'prcserpr_CompanyServiceProvidedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRCompanyServiceProvided', N'column', N'prcserpr_CompanyServiceProvidedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyServiceProvided', N'column', N'prcserpr_ServiceProvidedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyServiceProvided', N'column', N'prcserpr_ServiceProvidedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRServiceProvided table.', N'user', N'dbo', N'table', N'PRCompanyServiceProvided', N'column', N'prcserpr_ServiceProvidedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyServiceProvided', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyServiceProvided'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A bridge table associating services provided to specific companies.', N'user', N'dbo', N'table', N'PRCompanyServiceProvided'
GO


-- Begin PRCompanySpecie SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanySpecie', N'column', N'prcspc_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanySpecie', N'column', N'prcspc_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRCompanySpecie', N'column', N'prcspc_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanySpecie', N'column', N'prcspc_CompanySpecieID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanySpecie', N'column', N'prcspc_CompanySpecieID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRCompanySpecie', N'column', N'prcspc_CompanySpecieID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanySpecie', N'column', N'prcspc_SpecieID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanySpecie', N'column', N'prcspc_SpecieID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRSpecie table.', N'user', N'dbo', N'table', N'PRCompanySpecie', N'column', N'prcspc_SpecieID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanySpecie', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanySpecie'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A bridge table associating products provided to specific companies.', N'user', N'dbo', N'table', N'PRCompanySpecie'
GO


-- Begin PRCompanyStockExchange SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_CompanyStockExchangeId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_CompanyStockExchangeId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_CompanyStockExchangeId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_StockExchangeId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_StockExchangeId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Stock exchange', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_StockExchangeId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_Symbol1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_Symbol1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stock symbol used on the exchange for this company.', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_Symbol1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_Symbol2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_Symbol2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stock symbol used on the exchange for this company.', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_Symbol2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_Symbol3')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_Symbol3'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stock symbol used on the exchange for this company.', N'user', N'dbo', N'table', N'PRCompanyStockExchange', N'column', N'prc4_Symbol3'
GO


-- Begin PRCompanyTerminalMarket SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTerminalMarket', N'column', N'prct_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTerminalMarket', N'column', N'prct_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company', N'user', N'dbo', N'table', N'PRCompanyTerminalMarket', N'column', N'prct_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTerminalMarket', N'column', N'prct_CompanyTerminalMarketId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTerminalMarket', N'column', N'prct_CompanyTerminalMarketId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCompanyTerminalMarket', N'column', N'prct_CompanyTerminalMarketId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTerminalMarket', N'column', N'prct_TerminalMarketId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTerminalMarket', N'column', N'prct_TerminalMarketId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Terminal market', N'user', N'dbo', N'table', N'PRCompanyTerminalMarket', N'column', N'prct_TerminalMarketId'
GO


-- Begin PRCompanyTradeAssociation SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_CompanyTradeAssociationID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_CompanyTradeAssociationID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_CompanyTradeAssociationID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_MemberID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_MemberID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trade assocation member ID.', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_MemberID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_TradeAssociationCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_TradeAssociationCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Notes: Constrained by Custom_Captions', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', N'column', N'prcta_TradeAssociationCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks a company''s trade assocation memberships', N'user', N'dbo', N'table', N'PRCompanyTradeAssociation'
GO


-- Begin PRCompanyTradeShow SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_Booth')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_Booth'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Provided by the trade show', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_Booth'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_City')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_City'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Provided by the trade show', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_City'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_CompanyName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_CompanyName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Provided by the trade show', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_CompanyName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_CompanyTradeShowID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_CompanyTradeShowID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_CompanyTradeShowID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_Phone')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_Phone'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Provided by the trade show', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_Phone'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_State')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_State'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Provided by the trade show', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_State'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_TradeShow')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_TradeShow'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Identifier for the trade show', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_TradeShow'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_Year')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_Year'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Year the trade show took place.', N'user', N'dbo', N'table', N'PRCompanyTradeShow', N'column', N'prcts_Year'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanyTradeShow'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks a company''s trade show attendance as a participant.', N'user', N'dbo', N'table', N'PRCompanyTradeShow'
GO


-- Begin PRCountry SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCountry', N'column', N'prcn_BookOrder')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCountry', N'column', N'prcn_BookOrder'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used to sequence listing by country, however, the countries are not necessarily in alphabetical order.', N'user', N'dbo', N'table', N'PRCountry', N'column', N'prcn_BookOrder'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCountry', N'column', N'prcn_ContinentCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCountry', N'column', N'prcn_ContinentCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The continent of the country.  Possible Values: prcn_ContinentCode custom captions', N'user', N'dbo', N'table', N'PRCountry', N'column', N'prcn_ContinentCode'
GO


-- Begin PRCreditSheet SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_ApproverId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_ApproverId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) The user id that set the PRCS_Status to "Approved."  Notes: Stored automatically when PRCS_Publish is enabled.  Relates to Ucnt_ID.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_ApproverId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_AUSDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_AUSDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the Alerts report is run that utilizes this credit sheet item.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_AUSDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_AuthorId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_AuthorId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) The original author of the credit sheet item.  Notes: This will be populated with the user that created the transaction, business event, or other mechanism that spawned the credit sheet item.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_AuthorId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Change')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Change'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Depiction of information for the "change" section of a credit sheet item.  Notes: Determine by various business rules.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Change'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_ChannelId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_ChannelId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company referenced by credit sheet item.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_ChannelId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_CreditSheetId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_CreditSheetId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Notes: This row is generated by saving a transaction.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_CreditSheetId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_EBBUpdatePubDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_EBBUpdatePubDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date that this is published in EBB.   Notes: System interface updates the table.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_EBBUpdatePubDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_ExpressUpdatePubDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_ExpressUpdatePubDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date that this is published for the Express Update.  Notes: System interface updates the table.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_ExpressUpdatePubDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_KeyFlag')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_KeyFlag'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is set by the user to determine if the item is key.  Notes: The watchdog list would use this to determine if it should be reported.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_KeyFlag'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_NewListing')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_NewListing'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the credit sheet item indicates a new listing.  Used for reporting.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_NewListing'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Notes')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Notes'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Information about the creation of the credit sheet item (perhaps that it has extra information or is combined from other items, etc.).', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Notes'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Numeral')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Numeral'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Depiction of one or more rating numerals that are generated by the transaction or event, to be edited as needed.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Numeral'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Parenthetical')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Parenthetical'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Depiction of information displayed in the parenthetical of a credit sheet item.  Notes: Determined by various business rules.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Parenthetical'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_PreviousRatingValue')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_PreviousRatingValue'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Depiction of the previous rating line that is generated by the transaction or event, to be edited as needed.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_PreviousRatingValue'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_PublishableDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_PublishableDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time that the status is changed to "Publishable".  Notes: This is set by the system and is not edited.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_PublishableDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_RatingValue')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_RatingValue'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Depiction of the full rating line that is generated by the transaction or event, to be edited as needed.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_RatingValue'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Status')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Status'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the credit sheet item.  This affects how it is filtered in the queue and whether or not it is published.  Notes: Editing can only take place when "New" or "Reviewed".  Killing the item would allow only editing of PRCS_KillNotes.  Possible Values: New; Reviewed; Approved; Publishable; Killed', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Status'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Tradestyle')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Tradestyle'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Depiction of the tradestyle (name) on the credit sheet to be edited for format if desired.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_Tradestyle'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_WeeklyCSPubDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_WeeklyCSPubDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the item has been published to the weekly credit sheet.  Notes: System interface updates the table.', N'user', N'dbo', N'table', N'PRCreditSheet', N'column', N'prcs_WeeklyCSPubDate'
GO


-- Begin PRCreditWorthRating SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditWorthRating', N'column', N'prcw_CreditWorthRatingId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditWorthRating', N'column', N'prcw_CreditWorthRatingId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRCreditWorthRating', N'column', N'prcw_CreditWorthRatingId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditWorthRating', N'column', N'prcw_IndustryType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditWorthRating', N'column', N'prcw_IndustryType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Multi-select lookup for associating credit worth rating values with industries.  Possible Values: comp_PRIndustryType', N'user', N'dbo', N'table', N'PRCreditWorthRating', N'column', N'prcw_IndustryType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCreditWorthRating', N'column', N'prcw_Order')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCreditWorthRating', N'column', N'prcw_Order'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Establishes level of rating to determine order.  Notes: This column is used for rating comparisons.  Possible Values: 1; 2; etc.', N'user', N'dbo', N'table', N'PRCreditWorthRating', N'column', N'prcw_Order'
GO


-- Begin PRCSG SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCSG', N'column', N'prcsg_CSGCompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCSG', N'column', N'prcsg_CSGCompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The CSG ID for this company.', N'user', N'dbo', N'table', N'PRCSG', N'column', N'prcsg_CSGCompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCSG', N'column', N'prcsg_CSGID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCSG', N'column', N'prcsg_CSGID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRCSG', N'column', N'prcsg_CSGID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCSG', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCSG'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds data from the Chain Store Guide.  It is periodically populated from an external data source.', N'user', N'dbo', N'table', N'PRCSG'
GO


-- Begin PRCSGData SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCSGData', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCSGData'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This data holds the individual data units for the CSG data.  There are a few groups of data, with each group having several values.', N'user', N'dbo', N'table', N'PRCSGData'
GO


-- Begin PRDescriptiveLine SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDescriptiveLine', N'column', N'prdl_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDescriptiveLine', N'column', N'prdl_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company branch involved.', N'user', N'dbo', N'table', N'PRDescriptiveLine', N'column', N'prdl_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDescriptiveLine', N'column', N'prdl_DescriptiveLineId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDescriptiveLine', N'column', N'prdl_DescriptiveLineId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRDescriptiveLine', N'column', N'prdl_DescriptiveLineId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDescriptiveLine', N'column', N'prdl_LineContent')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDescriptiveLine', N'column', N'prdl_LineContent'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contains freeform text and encoded data elements to be parsed.  Possible Values: Some text [data field]', N'user', N'dbo', N'table', N'PRDescriptiveLine', N'column', N'prdl_LineContent'
GO


-- Begin PRDLMetrics SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDLMetrics', N'column', N'prdlm_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDLMetrics', N'column', N'prdlm_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company Table', N'user', N'dbo', N'table', N'PRDLMetrics', N'column', N'prdlm_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDLMetrics', N'column', N'prdlm_DLMetricsID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDLMetrics', N'column', N'prdlm_DLMetricsID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRDLMetrics', N'column', N'prdlm_DLMetricsID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDLMetrics', N'column', N'prdlm_UserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDLMetrics', N'column', N'prdlm_UserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user making the change.', N'user', N'dbo', N'table', N'PRDLMetrics', N'column', N'prdlm_UserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDLMetrics', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDLMetrics'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used to track the net change to the company''s DL by each user.', N'user', N'dbo', N'table', N'PRDLMetrics'
GO


-- Begin PRDRCLicense SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Address')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Address'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The street address of the company according to DRC.  Notes: Not associated with the Address table.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Address'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Address2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Address2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A second street address of the company according to DRC.  Notes: Not associated with the Address table.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Address2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_BusinessType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_BusinessType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'General classification of the business according to DRC.  Possible Values: Wholesaler, Grower/shipper, etc.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_BusinessType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_City')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_City'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city of the company according to DRC.  Notes: Not constrained to the City table.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_City'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_City2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_City2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A second city of the company according to DRC.  Notes: Not constrained to the City table.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_City2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company  Notes: May be null if the DRC information is unknown and not associated with any company (an exception).', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_ContactFirstAndMiddleName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_ContactFirstAndMiddleName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'First and/or middle name of relevant individual with the company known to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_ContactFirstAndMiddleName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_ContactJobTitle')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_ContactJobTitle'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Job title of the relevant individual with the company known to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_ContactJobTitle'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_ContactLastName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_ContactLastName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Last name of relevant individual with the company known to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_ContactLastName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Country')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Country'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country of the company according to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Country'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Country2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Country2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A second country of the company according to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Country2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_CoverageDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_CoverageDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the license became effective.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_CoverageDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_DRCLicenseId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_DRCLicenseId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_DRCLicenseId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Fax')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Fax'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The fax number of the company according to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Fax'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_LicenseNumber')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_LicenseNumber'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The license number provided by DRC for this company (branch).  DRC refers to this as the member number.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_LicenseNumber'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_LicenseStatus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_LicenseStatus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Describes whether a license is active or expired.  Possible Values: A, E', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_LicenseStatus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_MemberName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_MemberName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company name as recognized by DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_MemberName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_PaidToDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_PaidToDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date, through which the license has been paid.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_PaidToDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Phone')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Phone'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The telephone number of the company according to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Phone'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_PostalCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_PostalCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The postal or zip code of the company according to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_PostalCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_PostalCode2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_PostalCode2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A second postal or zip code of the company according to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_PostalCode2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Salutation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Salutation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Prefix to name, known as "Contact Status" to DRC.  Possible Values: Mr., M., Ms., Mme., Sr. Sra.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_Salutation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_State')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_State'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The state or province of the company according to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_State'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_State2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_State2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A second state or province of the company according to DRC.', N'user', N'dbo', N'table', N'PRDRCLicense', N'column', N'prdr_State2'
GO



-- Begin PRExceptionQueue SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ARAgingId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ARAgingId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Reference to reporting company''s aged accounts receivable entry that launched the exception.  Notes: May be null if not this type of exception.', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ARAgingId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_AssignedUserId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_AssignedUserId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user ID of the person assigned to the exception.  This will default to the user ID assigned to the territory associated with the company''s location.  Notes: The intent is that this could be edited to change assignment if desired.  It will relate to Ucnt_ID.', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_AssignedUserId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ClosedById')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ClosedById'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user ID of the person that closed the exception.  Notes: This may not be the same person that was assigned to the exception.  It will relate to Ucnt_ID.', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ClosedById'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Reference to the headquarter company associated with the exceptions launched by the monthly analysis of headquarter companies.  Notes: May be null if not this type of exception.', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_CreatedDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_CreatedDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the exception was generated.', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_CreatedDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_DateClosed')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_DateClosed'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time an exception was closed.', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_DateClosed'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ExceptionQueueId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ExceptionQueueId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ExceptionQueueId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_NumTradeReports12Months')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_NumTradeReports12Months'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents the number of trade reports received in the past 12 months on the company that is the subject of the exception.  Notes: This is not relevant to all exception types.  It is also somewhat duplicative, as it can be derived from other sources.  Including it here represents the value at the time of the exception, and it may improve system performance to include it here (denorma', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_NumTradeReports12Months'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_NumTradeReports3Months')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_NumTradeReports3Months'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents the number of trade reports received in the past 3 months on the company that is the subject of the exception.  Notes: This is not relevant to all exception types.  It is also somewhat duplicative, as it can be derived from other sources.  Including it here represents the value at the time of the exception, and it may improve system performance to include it here (denorma', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_NumTradeReports3Months'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_NumTradeReports6Months')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_NumTradeReports6Months'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents the number of trade reports received in the past 6 months on the company that is the subject of the exception.  Notes: This is not relevant to all exception types.  It is also somewhat duplicative, as it can be derived from other sources.  Including it here represents the value at the time of the exception, and it may improve system performance to include it here (denorma', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_NumTradeReports6Months'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_RatingLine')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_RatingLine'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the full rating line, combining all aspects of the rating, of the company that is the subject of the exception.  Notes: This is duplicated information; however, it is located here in case the rating changes after the exception is generated.  It may also improve system performance to include it here (denormalization).  The rating line may be null if no rating is specified f', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_RatingLine'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_Status')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_Status'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status of the exception.  Possible Values: Open; Closed', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_Status'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ThreeMonthIntegrityRating')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ThreeMonthIntegrityRating'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the average reported integrity rating on a company from TES reports over the recent 3-month period.  Notes: This remains null unless the exception is generated from the monthly legal entity rating analysis.', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ThreeMonthIntegrityRating'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ThreeMonthPayRating')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ThreeMonthPayRating'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the average reported pay description rating on a company from TES reports over the recent 3-month period.  Notes: This remains null unless the exception is generated from the monthly legal entity rating analysis.', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_ThreeMonthPayRating'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_TradeReportId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_TradeReportId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Reference to the trade report that launched the exception.  Notes: May be null if not this type of exception.', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_TradeReportId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type/source of exception.  Notes: The list will be constrained to these values automatically by the system.  This will not be editable in the user interface.  Possible Values: TES; AR; Bluebook Score; LegalEntityMonthly', N'user', N'dbo', N'table', N'PRExceptionQueue', N'column', N'preq_Type'
GO


-- Begin PRExternalLinkAuditTrail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_AssociatedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_AssociatedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ID of the entity that contained the URL. i.e PRPublicationArticle, Company.', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_AssociatedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user''s company', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_ExternalLinkAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_ExternalLinkAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_ExternalLinkAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_TriggerPage')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_TriggerPage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The page the URL was displayed on.', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_TriggerPage'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_URL')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_URL'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The URL the user is going to.', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_URL'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'User that that clicked the link.', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', N'column', N'prelat_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks which users are clicking on what URLs to external web sites. This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRExternalLinkAuditTrail'
GO


-- Begin PRExternalNews SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_Description')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_Description'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description or abstract of the article.', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_Description'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_ExternalID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_ExternalID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'ID in the external news system.', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_ExternalID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_ExternalNewsID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_ExternalNewsID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_ExternalNewsID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Article Name', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_PrimarySourceCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_PrimarySourceCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary feed the article came from.', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_PrimarySourceCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_PublishDateTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_PublishDateTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Article Published Date', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_PublishDateTime'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_SecondarySourceCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_SecondarySourceCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The secondary source where the article came from.  This is used by news aggregators to identify the ultimate source.', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_SecondarySourceCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_SecondarySourceName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_SecondarySourceName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Display name for the secondary source code', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_SecondarySourceName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_SubjectCompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_SubjectCompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_SubjectCompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_URL')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_URL'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'URL to the full article text', N'user', N'dbo', N'table', N'PRExternalNews', N'column', N'pren_URL'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNews'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds the news articles for the current company and external news system.  This is an article cache.', N'user', N'dbo', N'table', N'PRExternalNews'
GO


-- Begin PRExternalNewsAuditTrail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_ExternalNewsAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_ExternalNewsAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_ExternalNewsAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Article Name', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_PrimarySource')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_PrimarySource'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary feed the article came from.', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_PrimarySource'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_SecondarySource')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_SecondarySource'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The secondary source where the article came from.  This is used by news aggregators to identify the ultimate source.', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_SecondarySource'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_SubjectCompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_SubjectCompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_SubjectCompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_TriggerPage')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_TriggerPage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The page the user was on when they clicked the link,.', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_TriggerPage'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_URL')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_URL'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'URL to the full article text', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_URL'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Web User table.', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', N'column', N'prenat_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to audit when a user clicks on an external news article.  Because we only cache external news articles, some of those same elements are recorded here for reporting purposes.', N'user', N'dbo', N'table', N'PRExternalNewsAuditTrail'
GO


-- Begin PRFeedback SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFeedback', N'column', N'prfdbk_FeedbackID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFeedback', N'column', N'prfdbk_FeedbackID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRFeedback', N'column', N'prfdbk_FeedbackID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFeedback', N'column', N'prfdbk_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFeedback', N'column', N'prfdbk_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRWebUser table.', N'user', N'dbo', N'table', N'PRFeedback', N'column', N'prfdbk_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFeedback', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFeedback'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'BBOS table that records feedback submitted by users.', N'user', N'dbo', N'table', N'PRFeedback'
GO


-- Begin PRFinancial SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_AccountsPayable')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_AccountsPayable'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Accounts Payable  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_AccountsPayable'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_AccumulatedDepreciation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_AccumulatedDepreciation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Less:  Accumulated Depreciation  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_AccumulatedDepreciation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Amortization')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Amortization'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Amortization', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Amortization'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Analysis')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Analysis'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of analysis and opinions regarding the financial statement.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Analysis'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_ARTrade')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_ARTrade'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A/R – Trade  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_ARTrade'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CashEquivalents')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CashEquivalents'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cash and Equivalents  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CashEquivalents'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company associated with the financial statement.  Notes: Must be a headquarter company.  Must be null for a branch company.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CostGoodsSold')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CostGoodsSold'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Cost of good sold.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CostGoodsSold'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CreditLine')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CreditLine'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Notes Payable/Line of Credit  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CreditLine'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Currency')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Currency'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type of currency used on financial statement.  Possible Values: US Dollars, Canadian Dollars, Pesos', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Currency'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CurrentLoanPayableShldr')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CurrentLoanPayableShldr'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current Loan/Payable – Shareholder  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CurrentLoanPayableShldr'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CurrentMaturity')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CurrentMaturity'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current Maturity of Long Term Debt  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_CurrentMaturity'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Depreciation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Depreciation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Depreciation', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Depreciation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_DueFromRelatedParties')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_DueFromRelatedParties'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Due from Related Parties  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_DueFromRelatedParties'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_EntryStatus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_EntryStatus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Completeness of the financial statement information.  Notes: Custom captions could constrain the list.  Possible Values: None; Partial; Full', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_EntryStatus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_ExtraordinaryGainLoss')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_ExtraordinaryGainLoss'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Extraordinary Gain/Loss', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_ExtraordinaryGainLoss'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_FinancialId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_FinancialId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_FinancialId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Goodwill')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Goodwill'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Goodwill  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Goodwill'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_GrossProfitMargin')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_GrossProfitMargin'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Gross Profit Margin', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_GrossProfitMargin'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_InterestExpense')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_InterestExpense'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Interest Expense', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_InterestExpense'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_InterestIncome')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_InterestIncome'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Interest Income', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_InterestIncome'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Inventory')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Inventory'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Inventory  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Inventory'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LeaseholdImprovements')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LeaseholdImprovements'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Leasehold Improvements  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LeaseholdImprovements'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LibraryId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LibraryId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK)  Pointer to the scanned financial statement document.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LibraryId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LoansNotesPayableShldr')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LoansNotesPayableShldr'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Loans/Notes Payable – Shareholder  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LoansNotesPayableShldr'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LoansNotesReceivable')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LoansNotesReceivable'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Loans/Notes Receivable  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LoansNotesReceivable'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LongTermDebt')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LongTermDebt'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Long Term Debt  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_LongTermDebt'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_MarketableSecurities')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_MarketableSecurities'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Marketable Securities  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_MarketableSecurities'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_NetFixedAssets')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_NetFixedAssets'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Net Fixed Assets', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_NetFixedAssets'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_NetIncome')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_NetIncome'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Net Income', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_NetIncome'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OperatingExpenses')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OperatingExpenses'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Operating Expenses', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OperatingExpenses'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OperatingIncome')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OperatingIncome'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Operating Income', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OperatingIncome'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherExpenses')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherExpenses'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Other Expenses', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherExpenses'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherFixedAssets')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherFixedAssets'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Other/Uncategorized Fixed Assets  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherFixedAssets'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherIncome')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherIncome'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Other Income', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherIncome'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherLoansNotesReceivable')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherLoansNotesReceivable'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Loans/Notes Receivable  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherLoansNotesReceivable'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherLongLiabilities')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherLongLiabilities'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Other/Uncategorized Long Term Liabilities  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherLongLiabilities'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherMiscAssets')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherMiscAssets'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Other/Uncategorized Other Assets  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherMiscAssets'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherMiscLiabilities')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherMiscLiabilities'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Other Liabilities  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_OtherMiscLiabilities'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_PreparationMethod')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_PreparationMethod'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'How the financial statement was prepared.  Notes: Custom captions could constrain the list.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_PreparationMethod'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Property')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Property'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Property & Equipment  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Property'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Publish')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Publish'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to make available for publishing in business reports and other products.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Publish'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_RetainedEarnings')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_RetainedEarnings'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retained Earnings  Notes: A number can be entered via the UI, or the field can be calculated from sub-detail.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_RetainedEarnings'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Sales')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Sales'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Sales', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Sales'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_StatementDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_StatementDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the financial statement.', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_StatementDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_StatementImageFile')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_StatementImageFile'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Path & filename of the statement file relative to the financial statement virtual directory', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_StatementImageFile'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TaxProvision')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TaxProvision'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'P&L Provision for Income Taxes', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TaxProvision'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalAssets')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalAssets'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Assets', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalAssets'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalCurrentAssets')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalCurrentAssets'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Current Assets', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalCurrentAssets'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalCurrentLiabilities')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalCurrentLiabilities'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Current Liabilities', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalCurrentLiabilities'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalEquity')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalEquity'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Equity', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalEquity'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalLongLiabilities')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalLongLiabilities'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Long Term Liabilities', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalLongLiabilities'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalOtherAssets')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalOtherAssets'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Other Assets', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_TotalOtherAssets'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Describes if this financial statement is for a fiscal year-end or is for an interim period.  Possible Values: Y; I', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_Type'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_WorkingCapital')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_WorkingCapital'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Working Capital', N'user', N'dbo', N'table', N'PRFinancial', N'column', N'prfs_WorkingCapital'
GO


-- Begin PRFinancialDetail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_Amount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_Amount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount of the sub-detail, to be used in summing the value for the financial statement field.', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_Amount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_Description')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_Description'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of sub-detail entry.', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_Description'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_FieldName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_FieldName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the financial statement field.  Notes: This could be tied to a lookup table; however, it is also feasible that the application could constrain the field names.  The intent it to query using the FieldName in the where clause and some the amounts (or list the descriptions and amounts).', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_FieldName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_FinancialDetailId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_FinancialDetailId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_FinancialDetailId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_FinancialId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_FinancialId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Financial statement containing the detail.', N'user', N'dbo', N'table', N'PRFinancialDetail', N'column', N'prfd_FinancialId'
GO


-- Begin Pricing SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'Pricing', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'Pricing'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contains the prices for the NewProduct and PricingList.  If no entry is found for the given product and pricing list, query for the "default" pricing list.', N'user', N'dbo', N'table', N'Pricing'
GO


-- Begin PricingList SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PricingList', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PricingList'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used for the delivery mechanism.  Each type of delivery, email, fax, custom, etc. has a pricing list ID.', N'user', N'dbo', N'table', N'PricingList'
GO


-- Begin PRImportPACALicense SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_Address1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_Address1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'First line of address provided by PACA.  Notes: Once associated with a company, a PACA address type is also created in the Address and Address_Link tables.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_Address1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_Address2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_Address2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Second line of address provided by PACA.  Notes: Once associated with a company, a PACA address type is also created in the Address and Address_Link tables.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_Address2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_City')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_City'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'City provided by PACA.  Notes: This field is not constrained to the PRCity table.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_City'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_CompanyName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_CompanyName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company name, as registered with PACA.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_CompanyName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_Country')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_Country'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Country provided by PACA.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_Country'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_FileName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_FileName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the file providing this record from the PACA FTP site.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_FileName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_ImportDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_ImportDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the associated file was imported from the FTP site.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_ImportDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_ImportPACALicenseId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_ImportPACALicenseId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_ImportPACALicenseId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_LicenseNumber')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_LicenseNumber'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The license number provided by PACA for this company (branch).', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_LicenseNumber'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailAddress1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailAddress1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'First line of mailing address provided by PACA.  Notes: Once associated with a company, a PACA address type is also created in the Address and Address_Link tables.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailAddress1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailAddress2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailAddress2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Second line of mailing address provided by PACA.  Notes: Once associated with a company, a PACA address type is also created in the Address and Address_Link tables.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailAddress2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailCity')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailCity'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'City provided by PACA.  Notes: This field is not constrained to the PRCity table.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailCity'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailCountry')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailCountry'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Country provided by PACA.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailCountry'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailPostCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailPostCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Postal code provided by PACA.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailPostCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailState')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailState'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'State provided by PACA.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_MailState'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_OwnCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_OwnCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Notes: This corresponds to a lookup table delivered by PACA, but those values could probably be managed by custom captions.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_OwnCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_PostCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_PostCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Postal code provided by PACA.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_PostCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_State')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_State'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'State provided by PACA.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_State'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_TerminateCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_TerminateCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Notes: This corresponds to a lookup table delivered by PACA, but those values could probably be managed by custom captions.', N'user', N'dbo', N'table', N'PRImportPACALicense', N'column', N'pril_TerminateCode'
GO


-- Begin PRImportPACAPrincipal SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_City')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_City'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'City name', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_City'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_FirstName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_FirstName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'First name', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_FirstName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_ImportPACALicenseId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_ImportPACALicenseId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) The PACA license record associated with this company.', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_ImportPACALicenseId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_ImportPACAPrincipalId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_ImportPACAPrincipalId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_ImportPACAPrincipalId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_LastName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_LastName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Last name', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_LastName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_MiddleInitial')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_MiddleInitial'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Middle initial', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_MiddleInitial'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_Sequence')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_Sequence'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Principal sequence', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_Sequence'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_State')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_State'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'State name', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_State'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_Title')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_Title'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Title', N'user', N'dbo', N'table', N'PRImportPACAPrincipal', N'column', N'prip_Title'
GO


-- Begin PRIntegrityRating SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRIntegrityRating', N'column', N'prin_IntegrityRatingId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRIntegrityRating', N'column', N'prin_IntegrityRatingId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRIntegrityRating', N'column', N'prin_IntegrityRatingId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRIntegrityRating', N'column', N'prin_Weight')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRIntegrityRating', N'column', N'prin_Weight'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Numeric weighting or value of the rating code.  Possible Values: Example:  "X" = 1', N'user', N'dbo', N'table', N'PRIntegrityRating', N'column', N'prin_Weight'
GO


-- Begin PRLinkedInAuditTrail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_APIMethod')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_APIMethod'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Which API method was ececuted.', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_APIMethod'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_ExceededThreshold')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_ExceededThreshold'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the search caused the user to exceed the LinkedIn daily search threshold.', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_ExceededThreshold'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_LinkedInAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_LinkedInAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_LinkedInAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_PrivateCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_PrivateCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of results found that were marked Private.', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_PrivateCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_SearchCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_SearchCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of API searches executed to populate the page.', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_SearchCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_SubjectCompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_SubjectCompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_SubjectCompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_TotalResultCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_TotalResultCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of results found for the subject company.', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_TotalResultCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_UserResultCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_UserResultCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of results viewable by the user.', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_UserResultCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRWebUser table.', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', N'column', N'prliat_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to track how often LinkedIn is queried for a given user.', N'user', N'dbo', N'table', N'PRLinkedInAuditTrail'
GO


-- Begin PRListing SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRListing', N'column', N'prlst_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRListing', N'column', N'prlst_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRListing', N'column', N'prlst_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRListing', N'column', N'prlst_Listing')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRListing', N'column', N'prlst_Listing'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The computed listing.', N'user', N'dbo', N'table', N'PRListing', N'column', N'prlst_Listing'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRListing', N'column', N'prlst_ListingID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRListing', N'column', N'prlst_ListingID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRListing', N'column', N'prlst_ListingID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRListing', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRListing'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table caches the "Listing" so we don''t have to compute it each time.  This was primarily implemented for the BBOS where a company''s listing may be viewed numerous times a day, but is utilized across all systems so that the displayed listing is consistent.', N'user', N'dbo', N'table', N'PRListing'
GO


-- Begin PRLRLBatch SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_BatchName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_BatchName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the batch', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_BatchName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_BatchType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_BatchType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type (test vs prod)', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_BatchType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_Criteria')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_Criteria'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Criteria used to select the companies included in the batch.', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_Criteria'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_LRLBatchID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_LRLBatchID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRLRLBatch', N'column', N'prlrlb_LRLBatchID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRLRLBatch', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRLRLBatch'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is an audit trail table for Listing Report Letter batches.', N'user', N'dbo', N'table', N'PRLRLBatch'
GO


-- Begin PRMembershipPurchase SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_DeliveryCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_DeliveryCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prpp_DeliveryCode custom captions', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_DeliveryCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_DeliveryDestination')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_DeliveryDestination'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'For the appropriate product fax number, email address, etc.', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_DeliveryDestination'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_PaymentID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_PaymentID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRPayment table.', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_PaymentID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_ProductID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_ProductID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the NewProduct table.', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_ProductID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_ProductPurchaseID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_ProductPurchaseID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_ProductPurchaseID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_Quantity')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_Quantity'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity purchased.', N'user', N'dbo', N'table', N'PRMembershipPurchase', N'column', N'prmp_Quantity'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRMembershipPurchase'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds online membership purchase transactions.  Each membership product, primary service, additonal user, etc. has its own row.', N'user', N'dbo', N'table', N'PRMembershipPurchase'
GO


-- Begin ProductFamily SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'ProductFamily', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'ProductFamily'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used to group the products.  The BBOS will query for the "Membership" family to obtain all products pertaining to primary memberships.', N'user', N'dbo', N'table', N'ProductFamily'
GO


-- Begin PRPACALicense SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_Address1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_Address1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'PRPa_AddrAddress1  Notes: First line of address provided by PACA.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_Address1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_Address2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_Address2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'PRPa_AddrAddress2  Notes: Second line of address provided by PACA.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_Address2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_City')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_City'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'PRPa_City  Notes: City provided by PACA.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_City'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Comp_CompanyID  Notes: (FK) Company involved.  Possible Values: N', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_CompanyName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_CompanyName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'PRPa_CompanyName  Notes: Company name, as registered with PACA.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_CompanyName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_Current')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_Current'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to set this record as being the current PACA information for a company (all records are kept for history).  Notes: This flag would be set upon association with a company in the content base.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_Current'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_LicenseNumber')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_LicenseNumber'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The license number provided by PACA for this company (branch).', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_LicenseNumber'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailAddress1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailAddress1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'First line of mailing address provided by PACA.  Notes: Once associated with a company, a PACA address type is also created in the Address and Address_Link tables.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailAddress1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailAddress2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailAddress2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Second line of mailing address provided by PACA.  Notes: Once associated with a company, a PACA address type is also created in the Address and Address_Link tables.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailAddress2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailCity')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailCity'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'City provided by PACA.  Notes: This field is not constrained to the PRCity table.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailCity'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailPostCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailPostCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Postal code provided by PACA.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailPostCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailState')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailState'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'State provided by PACA.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_MailState'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_OwnCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_OwnCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Notes: This corresponds to a lookup table delivered by PACA, but those values could probably be managed by custom captions.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_OwnCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_PACALicenseId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_PACALicenseId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_PACALicenseId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_PostCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_PostCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Postal code provided by PACA.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_PostCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_State')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_State'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'State provided by PACA.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_State'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_TerminateCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_TerminateCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Notes: This corresponds to a lookup table delivered by PACA, but those values could probably be managed by custom captions.', N'user', N'dbo', N'table', N'PRPACALicense', N'column', N'prpa_TerminateCode'
GO


-- Begin PRPACAPrincipal SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_City')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_City'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'City name', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_City'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_FirstName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_FirstName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'First name', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_FirstName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_LastName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_LastName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Last name', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_LastName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_MiddleInitial')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_MiddleInitial'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Middle initial', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_MiddleInitial'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_PACALicenseId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_PACALicenseId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) The PACA license record associated with this company.', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_PACALicenseId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_PACAPrincipalId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_PACAPrincipalId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_PACAPrincipalId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_State')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_State'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'State name', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_State'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_Title')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_Title'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Title', N'user', N'dbo', N'table', N'PRPACAPrincipal', N'column', N'prpp_Title'
GO


-- Begin PRPasswordGenerator SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'Ndx')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'Ndx'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Must be numbered from 1 to N without any gaps.  Random numbers are used to select the words and replacements so it is important there are no gaps.', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'Ndx'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'TranslateFrom')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'TranslateFrom'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source string to replace.  Notes: The TranslateFrom and TranslateTo are not required for all records.  These are separate from the Word column and are here for convienience.', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'TranslateFrom'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'TranslateTo')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'TranslateTo'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Target string to replace with.', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'TranslateTo'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'Word')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'Word'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Words to be used in the password.', N'user', N'dbo', N'table', N'PRPasswordGenerator', N'column', N'Word'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPasswordGenerator', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPasswordGenerator'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contains both the random words and possible special character replacements to use when generating a password.  The word column has no relation what-so-ever to the translate columns.  They are queries separaetly using a random number generator to determine the index.', N'user', N'dbo', N'table', N'PRPasswordGenerator'
GO


-- Begin PRPayment SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_Amount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_Amount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The amount charged to the credit card.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_Amount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_AuthorizationCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_AuthorizationCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The authorization code from Verisign.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_AuthorizationCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_AVSAddr')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_AVSAddr'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The address verification code from Verisign.  Possible Values: Y, N', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_AVSAddr'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_AVSPostal')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_AVSPostal'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The postal verification code from Verisign  Possible Values: Y, N', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_AVSPostal'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_City')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_City'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Billing address', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_City'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_CountryID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_CountryID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Billing address', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_CountryID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_CreditCardNumber')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_CreditCardNumber'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last four digits of the specified credit card number.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_CreditCardNumber'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_CreditCardType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_CreditCardType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of credit card used,  Only those types of cards supported by both Verisign and the BBSI merchant account should be allowed.  Possible Values: prpay_CreditCardType custom captions', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_CreditCardType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_IPAddress')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_IPAddress'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The IP address of the client machine making the payment.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_IPAddress'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_ItemCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_ItemCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of items being purchased.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_ItemCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_MembershipPurchaseID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_MembershipPurchaseID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRMembershipPurchase table.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_MembershipPurchaseID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_PaymentID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_PaymentID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_PaymentID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_PostalCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_PostalCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Billing address', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_PostalCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_RequestID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_RequestID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRRequest table.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_RequestID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_ServiceUnitAllocationID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_ServiceUnitAllocationID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRServiceUnitAllocation table.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_ServiceUnitAllocationID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_StateID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_StateID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Billing address', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_StateID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_Street1')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_Street1'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Billing address', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_Street1'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_Street2')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_Street2'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Billing address', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_Street2'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_TaxAmount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_TaxAmount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The amount of tax charged.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_TaxAmount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_TaxAuthorityID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_TaxAuthorityID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRTaxAuthority table.', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_TaxAuthorityID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_TaxedAmount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_TaxedAmount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The amount taxed (not the tax value).', N'user', N'dbo', N'table', N'PRPayment', N'column', N'prpay_TaxedAmount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayment', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayment'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks credit card payments and is always associated with a PRRequest record.', N'user', N'dbo', N'table', N'PRPayment'
GO


-- Begin PRPaymentProduct SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_PaymentID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_PaymentID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRPayment table.', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_PaymentID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_PaymentProductID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_PaymentProductID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_PaymentProductID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_Price')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_Price'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit price charged', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_Price'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_ProductID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_ProductID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the NewProduct table.', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_ProductID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_Quantity')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_Quantity'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity purchased.', N'user', N'dbo', N'table', N'PRPaymentProduct', N'column', N'prpayprod_Quantity'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPaymentProduct'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a bridge table between PRPayment and NewProduct.', N'user', N'dbo', N'table', N'PRPaymentProduct'
GO


-- Begin PRPayRating SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPayRating', N'column', N'prpy_PayRatingId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPayRating', N'column', N'prpy_PayRatingId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRPayRating', N'column', N'prpy_PayRatingId'
GO


-- Begin PRPersonBackground SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_Company')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_Company'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This represents the company the person was associated with.  This company is not part of the content base (considered prior to known history for this person).', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_Company'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_EndDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_EndDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the individual left a position with a company.', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_EndDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_PersonBackgroundId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_PersonBackgroundId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_PersonBackgroundId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_PersonId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_PersonId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) The person associated with the event.', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_PersonId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_StartDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_StartDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the individual started a position with a company.', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_StartDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_Title')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_Title'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The title associated with the position at the company.', N'user', N'dbo', N'table', N'PRPersonBackground', N'column', N'prba_Title'
GO


-- Begin PRPersonEvent SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_BankruptcyType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_BankruptcyType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type on bankruptcy filed.  Notes: Custom captions will be used to constrain the list.  Possible Values: Chapter 7; Chapter 11; Chapter 12; Chapter 13', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_BankruptcyType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_CaseNumber')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_CaseNumber'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Case number for bankruptcy or discharge.', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_CaseNumber'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_Date')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_Date'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The meaning of this date field varies with the type of event.  Notes: This may result in a business event if this person is an owner of a sole proprietorship or a partner in a partnership for certain event types (i.e. bankruptcy, bankruptcy discharge, etc.).', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_Date'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_Description')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_Description'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A text field to describe the event.  The meaning of this text varies with the type of event.  Notes: May include descriptions of legal actions, transfers, DRC violations, etc., depending on the type.', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_Description'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_DischargeType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_DischargeType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type of bankruptcy discharge/dismissal.  Notes: Custom captions will be used to constrain the list.  Possible Values: Dismissed; Discharged; Closed', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_DischargeType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_EducationalDegree')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_EducationalDegree'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Degree associated with educational institution.', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_EducationalDegree'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_EducationalInstitution')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_EducationalInstitution'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of college associated with earned degree.', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_EducationalInstitution'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_InternalAnalysis')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_InternalAnalysis'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Analysis and other comments that will not be depicted in any BBSI products.', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_InternalAnalysis'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PersonEventId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PersonEventId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PersonEventId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PersonEventTypeId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PersonEventTypeId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) The type of person event.  Notes: This serves as the lookup table for a dropdown list.', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PersonEventTypeId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PersonId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PersonId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) The person associated with the event.', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PersonId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PublishCreditSheet')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PublishCreditSheet'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This flag will determine if a credit sheet item is created from the event.  Possible Values: True = "Publish"', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PublishCreditSheet'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PublishedAnalysis')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PublishedAnalysis'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of BBSI analysis associated with the person event that may be published for external view.', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PublishedAnalysis'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PublishUntilDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PublishUntilDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date prior to which this event should be available in the business report (assuming the event is published).', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_PublishUntilDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_USBankruptcyCourt')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_USBankruptcyCourt'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Bankruptcy court district.  Notes: Custom captions will be used to constrain the list.', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_USBankruptcyCourt'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_USBankruptcyVoluntary')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_USBankruptcyVoluntary'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicating voluntary or involuntary bankruptcy (or discharge).  Possible Values: True = Voluntary', N'user', N'dbo', N'table', N'PRPersonEvent', N'column', N'prpe_USBankruptcyVoluntary'
GO


-- Begin PRPersonEventType SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEventType', N'column', N'prpt_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEventType', N'column', N'prpt_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the event type.  Possible Values: Acquisition; Agreement in Principle; etc.', N'user', N'dbo', N'table', N'PRPersonEventType', N'column', N'prpt_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEventType', N'column', N'prpt_PersonEventTypeId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEventType', N'column', N'prpt_PersonEventTypeId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for business event types.', N'user', N'dbo', N'table', N'PRPersonEventType', N'column', N'prpt_PersonEventTypeId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEventType', N'column', N'prpt_PublishDefaultTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonEventType', N'column', N'prpt_PublishDefaultTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of years this type of business event is normally published.  Notes: Fractional amounts are possible.  Possible Values: Set to 1000 to serve as "indefinite".', N'user', N'dbo', N'table', N'PRPersonEventType', N'column', N'prpt_PublishDefaultTime'
GO


-- Begin PRPersonRelationship SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_Description')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_Description'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of familial relationship.  Notes: If it is determined that specific types will be used, then this description would not exist.  Instead the PRRelationshipType table would provide the name of the type.', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_Description'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_LeftPersonId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_LeftPersonId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) ID of person on the left side of a relationship.  Notes: Example:  "John" in "John is related to Joe".', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_LeftPersonId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_PersonRelationshipId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_PersonRelationshipId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_PersonRelationshipId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_RightPersonId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_RightPersonId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) ID of person on the right side of a relationship  Notes: Example:  "Joe" in "John is related to Joe".', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_RightPersonId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_Source')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_Source'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source of relationship information.  Notes: Custom captions will be used to constrain the source types.  The PRRelationshipSource table may be necessary if descriptions are required.  Possible Values: Phone, email, etc.', N'user', N'dbo', N'table', N'PRPersonRelationship', N'column', N'prpr_Source'
GO


-- Begin PRPostalCode SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_City')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_City'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Official city name associated with the postal code', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_City'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_Class')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_Class'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type of postal code  Possible Values: Normal, PO Box', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_Class'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_Latitude')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_Latitude'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Coordinate of the center of the postal code area', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_Latitude'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_Longitude')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_Longitude'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Coordinate of the center of the postal code area', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_Longitude'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_PostalCodeID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_PostalCodeID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRPostalCode', N'column', N'prpc_PostalCodeID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPostalCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds postal codes and their associated latitude and longitude geocodes.', N'user', N'dbo', N'table', N'PRPostalCode'
GO


-- Begin PRProductProvided SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRProductProvided', N'column', N'prprpr_DisplayOrder')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRProductProvided', N'column', N'prprpr_DisplayOrder'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order, within the a parent, to display these.', N'user', N'dbo', N'table', N'PRProductProvided', N'column', N'prprpr_DisplayOrder'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRProductProvided', N'column', N'prprpr_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRProductProvided', N'column', N'prprpr_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the product provided', N'user', N'dbo', N'table', N'PRProductProvided', N'column', N'prprpr_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRProductProvided', N'column', N'prprpr_ProductProvidedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRProductProvided', N'column', N'prprpr_ProductProvidedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRProductProvided', N'column', N'prprpr_ProductProvidedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRProductProvided', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRProductProvided'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A list of products provided by companies to their customers.', N'user', N'dbo', N'table', N'PRProductProvided'
GO


-- Begin PRPubAddr SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPubAddr', N'column', N'puba_addrid')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPubAddr', N'column', N'puba_addrid'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'"Slot #"  corresponds to addr_PRSequence', N'user', N'dbo', N'table', N'PRPubAddr', N'column', N'puba_addrid'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPubAddr', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPubAddr'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used by PIKS as a reference when maintaining addresses.  The data is not maintained by PIKS but by BBS only.', N'user', N'dbo', N'table', N'PRPubAddr'
GO


-- Begin PRPublicationArticle SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Abstract')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Abstract'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The text that will appear under the headline in the news listing component.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Abstract'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Body')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Body'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name/headline of the article.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Body'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Body')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Body'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The text that appears in the news article template.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Body'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_CategoryCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_CategoryCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The news category the news item should be displayed in  Possible Values: prpbar_CategoryCode custom_captions', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_CategoryCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_CoverArtFileName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_CoverArtFileName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file name of the cover art image file.  File name only, no path.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_CoverArtFileName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_ExpirationDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_ExpirationDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'End date of when the article should be displayed.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_ExpirationDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_FileName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_FileName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file name of the associated PDF.  File name only, no path.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_FileName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_IndustryTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_IndustryTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only used for news articles, controls which articles are displayed for which industry users.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_IndustryTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Level')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Level'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'For each level > 1, indicates the depth of indentation', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Level'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_MembersOnly')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_MembersOnly'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the news item is viewable by members only.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_MembersOnly'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_News')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_News'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this article should be published in the News mechansim.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_News'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_NewsSequence')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_NewsSequence'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sequence used for displaying news articles.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_NewsSequence'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_NoChargeExpiration')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_NoChargeExpiration'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'For Blueprints Online articles, determines when the no charge period expires.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_NoChargeExpiration'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_ProductID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_ProductID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the New Product table.  For those articles that users are charged to download.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_ProductID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublicationArticleID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublicationArticleID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublicationArticleID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublicationCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublicationCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Among other things, determines what pages display the articles.  Possible Values: prpbar_PublicationCode custom_captions', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublicationCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublicationEditionID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublicationEditionID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRPublicationEdition table.  Only for Blueprints articles.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublicationEditionID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublishDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublishDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Start date of when the article should be displayed.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_PublishDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_RSS')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_RSS'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this article should be published in the RSS feed.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_RSS'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Sequence')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Sequence'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The unique integer sequence value used for ordering the articles.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_Sequence'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_ViewCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_ViewCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times the body was viewed or an external link was clicked from the blurb.', N'user', N'dbo', N'table', N'PRPublicationArticle', N'column', N'prpbar_ViewCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticle'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds various BBSI articles for publishing via BBOS', N'user', N'dbo', N'table', N'PRPublicationArticle'
GO


-- Begin PRPublicationArticleCompany SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleCompany', N'column', N'prpbarc_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleCompany', N'column', N'prpbarc_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.', N'user', N'dbo', N'table', N'PRPublicationArticleCompany', N'column', N'prpbarc_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleCompany', N'column', N'prpbarc_PRPublicationArticleCompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleCompany', N'column', N'prpbarc_PRPublicationArticleCompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRPublicationArticleCompany', N'column', N'prpbarc_PRPublicationArticleCompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleCompany', N'column', N'prpbarc_PublicationArticleID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleCompany', N'column', N'prpbarc_PublicationArticleID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRPublicationArticle table.', N'user', N'dbo', N'table', N'PRPublicationArticleCompany', N'column', N'prpbarc_PublicationArticleID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleCompany', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleCompany'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a bridge table that associates companies with publication articles.', N'user', N'dbo', N'table', N'PRPublicationArticleCompany'
GO


-- Begin PRPublicationArticleRead SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleRead', N'column', N'prpar_SourceID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleRead', N'column', N'prpar_SourceID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ID of the entity where the user was when they decided to read the article.', N'user', N'dbo', N'table', N'PRPublicationArticleRead', N'column', N'prpar_SourceID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleRead', N'column', N'prpar_TriggerPage')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleRead', N'column', N'prpar_TriggerPage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The page that triggered the user to read the article.', N'user', N'dbo', N'table', N'PRPublicationArticleRead', N'column', N'prpar_TriggerPage'
GO


-- Begin PRPublicationArticleTopic SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleTopic', N'column', N'prpbart_PublicationArticleID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleTopic', N'column', N'prpbart_PublicationArticleID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRPublicationArticle table.', N'user', N'dbo', N'table', N'PRPublicationArticleTopic', N'column', N'prpbart_PublicationArticleID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleTopic', N'column', N'prpbart_PublicationArticleTopicID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleTopic', N'column', N'prpbart_PublicationArticleTopicID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRPublicationArticleTopic', N'column', N'prpbart_PublicationArticleTopicID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleTopic', N'column', N'prpbart_PublicationTopicID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleTopic', N'column', N'prpbart_PublicationTopicID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRPublicationTopic table.', N'user', N'dbo', N'table', N'PRPublicationArticleTopic', N'column', N'prpbart_PublicationTopicID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleTopic', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationArticleTopic'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Bridge table to associate a PRPublicationArticle record with multiple PRPublicationTopic records.', N'user', N'dbo', N'table', N'PRPublicationArticleTopic'
GO


-- Begin PRPublicationEdition SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_CoverArtFileName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_CoverArtFileName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The image of the edition cover.  Filename only, no path.', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_CoverArtFileName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the edition', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_PublicationCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_PublicationCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prpbar_PublicationCode custom_captions', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_PublicationCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_PublicationEditionID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_PublicationEditionID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_PublicationEditionID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_PublishDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_PublishDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the edition is made available.', N'user', N'dbo', N'table', N'PRPublicationEdition', N'column', N'prpbed_PublishDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationEdition'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table contains the definition of a publication edition, which is related to multipel PRPublicationArticles.', N'user', N'dbo', N'table', N'PRPublicationEdition'
GO


-- Begin PRPublicationTopic SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_Level')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_Level'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Hierarchy Level', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_Level'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Topic name.', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_ParentID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_ParentID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'prpbt_PublicationTopicID value of the parent of this record.', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_ParentID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_PublicationTopicID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_PublicationTopicID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRPublicationTopic', N'column', N'prpbt_PublicationTopicID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationTopic', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRPublicationTopic'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds a hierarchy of publication topics that are assoicated with publication articles.', N'user', N'dbo', N'table', N'PRPublicationTopic'
GO


-- Begin PRRating SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company associated with the rating.', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_CreditWorthId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_CreditWorthId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Financial Credit Worth Rating  Notes: Although the financial credit worth rating is associated only with a headquarter company, it is assumed to apply to all branches.  This rating will exist on the headquarters and all branches, though it can only be edited on the headquarters.  Some rating   Possible Values: 100M, etc.', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_CreditWorthId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_Current')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_Current'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag depicting this rating row as the current rating of the company.  Notes: This will permit faster queries of current ratings.  Possible Values: True = "Current"', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_Current'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_Date')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_Date'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date that the rating is assigned.  Notes: Rating history can be viewed by listing all rows, ordered by this column.', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_Date'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_IntegrityId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_IntegrityId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Integrity (moral responsibility) rating.', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_IntegrityId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_InternalAnalysis')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_InternalAnalysis'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Explanation of why rating elements were changed – not for external use.  Notes: May be left null if all material is worthy of publishing.', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_InternalAnalysis'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_PayRatingId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_PayRatingId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Pay description rating', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_PayRatingId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_PublishedAnalysis')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_PublishedAnalysis'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Explanation of why rating elements were changed – to be published in the business report.  Notes: The user interface (via a label, etc.) should remind the user that this is published.', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_PublishedAnalysis'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_Rated')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_Rated'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this rating is actually comprised of rating elements and not just descriptive numerals.', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_Rated'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_RatingId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_RatingId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Notes: A row in this table corresponds to a full rating (all segments).  If one segment is changed, a new row is created.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRRating', N'column', N'prra_RatingId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRating', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRating'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is an existing PIKS table', N'user', N'dbo', N'table', N'PRRating'
GO


-- Begin PRRatingNumeral SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_IndustryType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_IndustryType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Multi-select lookup for associating credit worth rating values with industries.  Possible Values: comp_PRIndustryType', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_IndustryType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_RatingNumeralId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_RatingNumeralId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_RatingNumeralId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_SuppressIntegrityRating')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_SuppressIntegrityRating'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag that indicates the assignment of this numeral suppresses the integrity rating.  Notes: This requires the nullification of the integrity rating – not just suppressing it on the rating line.  Possible Values: True = "Suppress"', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_SuppressIntegrityRating'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_SuppressPayRating')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_SuppressPayRating'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag that indicates the assignment of this numeral suppresses the pay description rating.  Notes: This requires the nullification of the pay description rating – not just suppressing it on the rating line.  Possible Values: True = "Suppress"', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_SuppressPayRating'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Categorizes the numeral.  Notes: This allows the separate constrained lists of rating numerals to reside in this table.  Possible Values: Affiliation; Credit Sheet; Rating', N'user', N'dbo', N'table', N'PRRatingNumeral', N'column', N'prrn_Type'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRatingNumeral'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is an existing PIKS table', N'user', N'dbo', N'table', N'PRRatingNumeral'
GO


-- Begin PRRegion SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_Level')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_Level'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Level in the 3-level tree.', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_Level'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the region.', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_ParentId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_ParentId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'ID of parent region in the three-level tree.', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_ParentId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_RegionId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_RegionId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'DoRe_ID (PK)  Notes: Sequential primary key for the table.  Possible Values: Y', N'user', N'dbo', N'table', N'PRRegion', N'column', N'prd2_RegionId'
GO


-- Begin PRRelationshipType SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRelationshipType', N'column', N'prrt_Category')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRelationshipType', N'column', N'prrt_Category'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents the general category of a relationship and how the relationship can be applied.  Possible Values: Confirmed trading, litigation, etc.', N'user', N'dbo', N'table', N'PRRelationshipType', N'column', N'prrt_Category'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRelationshipType', N'column', N'prrt_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRelationshipType', N'column', N'prrt_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of relationship type.  Notes: Each name corresponds to a phrase, such as "freight provider for"  Possible Values: Buyer, Freight Provider', N'user', N'dbo', N'table', N'PRRelationshipType', N'column', N'prrt_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRelationshipType', N'column', N'prrt_RelationshipTypeId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRelationshipType', N'column', N'prrt_RelationshipTypeId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRRelationshipType', N'column', N'prrt_RelationshipTypeId'
GO


-- Begin PRRequest SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user''s company', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_HQID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_HQID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.  Used to identify the enterprise.', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_HQID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the request.', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_Price')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_Price'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The price of the request.  Could be in money or units.', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_Price'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_RequestID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_RequestID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_RequestID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_RequestTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_RequestTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of request  Possible Values: prreq_RequestTypeCode custom captions', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_RequestTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_SourceID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_SourceID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ID of the entity where the user was when they decided to make this request', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_SourceID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'ID of the user who made the request', N'user', N'dbo', N'table', N'PRRequest', N'column', N'prreq_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequest', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequest'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks all BBOS data requests.  This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRRequest'
GO


-- Begin PRRequestDetail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_AssociatedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_AssociatedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ID pertaining to the request.', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_AssociatedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_AssociatedType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_AssociatedType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the table the associdated ID is a PK for.  Possible Values: prrc_AssociatedIDType custom captions', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_AssociatedType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_RequestDetailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_RequestDetailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_RequestDetailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_RequestID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_RequestID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRRequest table.', N'user', N'dbo', N'table', N'PRRequestDetail', N'column', N'prrc_RequestID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRRequestDetail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRRequestDetail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Bridge table to associate a PRRequest record with multiple entity records.  This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRRequestDetail'
GO


-- Begin PRSearchAuditTrail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user''s company', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsClassification')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsClassification'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates classification critiera was specified.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsClassification'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCommodity')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCommodity'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates commodity critiera was specified.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCommodity'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCompanyGeneral')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCompanyGeneral'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates general critiera was specified.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCompanyGeneral'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCompanyLocation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCompanyLocation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates location critiera was specified.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCompanyLocation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCustom')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCustom'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates custom critiera was specified.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsCustom'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsHeader')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsHeader'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates header critiera was specified.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsHeader'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsProfile')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsProfile'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates profile critiera was specified.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsProfile'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsQuickFind')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsQuickFind'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the search was a quick find.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsQuickFind'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsRating')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsRating'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates rating critiera was specified.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_IsRating'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_ResultCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_ResultCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of records found by this search.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_ResultCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_SearchAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_SearchAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_SearchAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_SearchType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_SearchType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prsc_SearchType custom_captions', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_SearchType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_SearchWizardAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_SearchWizardAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRSearchWizardAuditTrail table.  Indicates this search was the result of a search wizard.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_SearchWizardAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_UserType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_UserType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prsat_UserType custom_captions', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_UserType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'User that executed the search.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_WebUserSearchCritieraID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_WebUserSearchCritieraID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only populated for saved searches.  Not "Last unsaved searches", that though are saved, are not saved by the user.', N'user', N'dbo', N'table', N'PRSearchAuditTrail', N'column', N'prsat_WebUserSearchCritieraID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks BBOS search usage.  This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRSearchAuditTrail'
GO


-- Begin PRSearchAuditTrailCriteria SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_CriteriaSubtypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_CriteriaSubtypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prsatc_CriteriaSubtypeCode custom_captions', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_CriteriaSubtypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_CriteriaTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_CriteriaTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prsatc_CriteriaTypeCode custom_captions', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_CriteriaTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_IntValue')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_IntValue'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If the critiera is a key into a lookup table, the value is stored here.  If a value is multi-select, create one record per selected value.', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_IntValue'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_SearchAuditTrailCriteriaID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_SearchAuditTrailCriteriaID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_SearchAuditTrailCriteriaID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_SearchAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_SearchAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRSearchAuditTrail table', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_SearchAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_StringValue')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_StringValue'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If the critiera is user specified, the value is stored here.', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', N'column', N'prsatc_StringValue'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks some of the criteria used for searching.  This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRSearchAuditTrailCriteria'
GO


-- Begin PRSearchWizard SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizard', N'column', N'prsw_Description')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizard', N'column', N'prsw_Description'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of the wizard.', N'user', N'dbo', N'table', N'PRSearchWizard', N'column', N'prsw_Description'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizard', N'column', N'prsw_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizard', N'column', N'prsw_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the wizard', N'user', N'dbo', N'table', N'PRSearchWizard', N'column', N'prsw_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizard', N'column', N'prsw_SearchWizardID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizard', N'column', N'prsw_SearchWizardID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRSearchWizard', N'column', N'prsw_SearchWizardID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizard', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizard'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table contains the search wizards.  The definitions are hard-coded in the appropriate pages.', N'user', N'dbo', N'table', N'PRSearchWizard'
GO


-- Begin PRSearchWizardAuditTrail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The company ID for the associated PRWebUser', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_SearchWizardAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_SearchWizardAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_SearchWizardAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_SearchWizardID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_SearchWizardID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRSearchWizard table.', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_SearchWizardID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRWebUser table.', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', N'column', N'prswau_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks search wizard usage.  This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrail'
GO


-- Begin PRSearchWizardAuditTrailDetail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_Answer')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_Answer'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The selected/specified answer to the wizard.', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_Answer'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_Question')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_Question'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The question number for the wizard.', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_Question'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_SearchWizardAuditTrailDetailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_SearchWizardAuditTrailDetailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_SearchWizardAuditTrailDetailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_SearchWizardAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_SearchWizardAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRSearchWizardAuditTrail table.', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', N'column', N'prswaud_SearchWizardAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds the details for the search wizard audit.  One record per wizard question.  Since the PRSearchWizardAuditTrail table is linked to the PRSearchAuditTrail table, there is no need to track specific search critiera.  This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRSearchWizardAuditTrailDetail'
GO


-- Begin PRSelfServiceAuditTrail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail', N'column', N'prssat_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail', N'column', N'prssat_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The CompanyID for the PRWebUser', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail', N'column', N'prssat_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail', N'column', N'prssat_SelfServiceAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail', N'column', N'prssat_SelfServiceAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail', N'column', N'prssat_SelfServiceAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail', N'column', N'prssat_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail', N'column', N'prssat_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRWebUser table.', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail', N'column', N'prssat_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks how self-service is used.', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrail'
GO


-- Begin PRSelfServiceAuditTrailDetail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail', N'column', N'prssatd_CategoryCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail', N'column', N'prssatd_CategoryCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prssatd_CategoryCode custom_captions', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail', N'column', N'prssatd_CategoryCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail', N'column', N'prssatd_SelfServiceAuditTrailDetailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail', N'column', N'prssatd_SelfServiceAuditTrailDetailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail', N'column', N'prssatd_SelfServiceAuditTrailDetailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail', N'column', N'prssatd_SelfServiceAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail', N'column', N'prssatd_SelfServiceAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRSelfServiceAuditTrail', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail', N'column', N'prssatd_SelfServiceAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks the details for self-service usage.  What data was updated.', N'user', N'dbo', N'table', N'PRSelfServiceAuditTrailDetail'
GO


-- Begin PRServiceProvided SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_CompanyCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_CompanyCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of companies assigned to this service.', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_CompanyCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_CompanyCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_CompanyCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of companies assigned to this specie.', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_CompanyCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_DisplayOrder')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_DisplayOrder'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order, within the a parent, to display these.', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_DisplayOrder'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_Level')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_Level'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Level in the hierarchy', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_Level'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the service provided', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_ParentID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_ParentID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'NULL if highest level', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_ParentID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_ServiceProvidedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_ServiceProvidedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRServiceProvided', N'column', N'prserpr_ServiceProvidedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceProvided'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A list of service provided by companies to their customers.', N'user', N'dbo', N'table', N'PRServiceProvided'
GO


-- Begin PRServiceUnitAllocation SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_AllocationTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_AllocationTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type of allocation  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_AllocationTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company the units are for', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_ExpirationDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_ExpirationDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Expiration date of the allocation', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_ExpirationDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_HQID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_HQID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.  Used to identify the enterprise.', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_HQID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_PersonId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_PersonId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Person from the company requesting the units', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_PersonId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_SourceCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_SourceCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source of the allocation  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_SourceCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_StartDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_StartDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Start date of the allocation', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_StartDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_UnitsAllocated')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_UnitsAllocated'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of units allocation', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_UnitsAllocated'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_UnitsRemaining')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_UnitsRemaining'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of units remaining.  Is decremeted with each usage.', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', N'column', N'prun_UnitsRemaining'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is an existing PIKS table', N'user', N'dbo', N'table', N'PRServiceUnitAllocation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records each service unit purchase', N'user', N'dbo', N'table', N'PRServiceUnitAllocation'
GO


-- Begin PRServiceUnitAllocationUsage SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocationUsage', N'column', N'prsua_ServiceUnitAllocationId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocationUsage', N'column', N'prsua_ServiceUnitAllocationId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'ServiceUnitAllocation record', N'user', N'dbo', N'table', N'PRServiceUnitAllocationUsage', N'column', N'prsua_ServiceUnitAllocationId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocationUsage', N'column', N'prsua_ServiceUnitUsageId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocationUsage', N'column', N'prsua_ServiceUnitUsageId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'ServiceUnitUsage record', N'user', N'dbo', N'table', N'PRServiceUnitAllocationUsage', N'column', N'prsua_ServiceUnitUsageId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocationUsage', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitAllocationUsage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Bridge table assocating PRServiceUnitUsage records with the PRServiceUnitAllocation records.', N'user', N'dbo', N'table', N'PRServiceUnitAllocationUsage'
GO


-- Begin PRServiceUnitUsage SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company using the units.', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_HQID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_HQID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.  Used to identify the enterprise.', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_HQID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_PersonId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_PersonId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Person using the units.', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_PersonId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_ProductID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_ProductID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to the NewProduct table.  This effectively replaces prsuu_UsageType, though this field doesn''t necessarily need to be removed.', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_ProductID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_RegardingObjectID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_RegardingObjectID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Associated object, such as PRBusinessReportRequest', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_RegardingObjectID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_ReversalReasonCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_ReversalReasonCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If a type = reversal, the reason for the reversal  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_ReversalReasonCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_ReversalServiceUnitUsageID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_ReversalServiceUnitUsageID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If a type = reversal, the PRServiceUnitUsage record being reversed.', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_ReversalServiceUnitUsageID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_SearchCriteria')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_SearchCriteria'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Metadata about the request from the web site.', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_SearchCriteria'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_SourceCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_SourceCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source of the usage  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_SourceCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_TransactionTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_TransactionTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Transaction type  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_TransactionTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_Units')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_Units'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of units used.', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_Units'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_UsageTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_UsageTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Usage Type  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRServiceUnitUsage', N'column', N'prsuu_UsageTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is an existing PIKS table', N'user', N'dbo', N'table', N'PRServiceUnitUsage'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRServiceUnitUsage'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records each service unit usage by a company/person', N'user', N'dbo', N'table', N'PRServiceUnitUsage'
GO


-- Begin PRShipmentLog SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLog', N'column', N'prshplg_CarrierCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLog', N'column', N'prshplg_CarrierCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If null, this has not shipped yet.', N'user', N'dbo', N'table', N'PRShipmentLog', N'column', N'prshplg_CarrierCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLog', N'column', N'prshplg_Type')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLog', N'column', N'prshplg_Type'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: Mass, Manual', N'user', N'dbo', N'table', N'PRShipmentLog', N'column', N'prshplg_Type'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLog', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLog'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks shipments sent to customers.  It tracks the attention line values used as of the time of the shipment.', N'user', N'dbo', N'table', N'PRShipmentLog'
GO


-- Begin PRShipmentLogDetail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLogDetail', N'column', N'prshplgd_ItemCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLogDetail', N'column', N'prshplgd_ItemCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The item that is part of the shipment.', N'user', N'dbo', N'table', N'PRShipmentLogDetail', N'column', N'prshplgd_ItemCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLogDetail', N'column', N'prshplgd_ShipmentLogID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLogDetail', N'column', N'prshplgd_ShipmentLogID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRShipmentLog table.', N'user', N'dbo', N'table', N'PRShipmentLogDetail', N'column', N'prshplgd_ShipmentLogID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLogDetail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipmentLogDetail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tracks the items that are part of the shipment.', N'user', N'dbo', N'table', N'PRShipmentLogDetail'
GO


-- Begin PRShipping SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_CountryID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_CountryID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRCountry table.', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_CountryID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_ProductID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_ProductID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the NewProduct table.', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_ProductID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_ShippingID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_ShippingID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_ShippingID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_ShippingRate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_ShippingRate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The rate charged to ship books to the country.', N'user', N'dbo', N'table', N'PRShipping', N'column', N'prship_ShippingRate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRShipping', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRShipping'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds the shipping charges for products and destination countries.', N'user', N'dbo', N'table', N'PRShipping'
GO


-- Begin PRSocialMedia SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company Table', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_SocialMediaID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_SocialMediaID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_SocialMediaID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_SocialMediaTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_SocialMediaTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type code, i.e. Facebook, Twitter, etc.  Possible Values: prsm_SocialMediaTypeCode', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_SocialMediaTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_URL')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_URL'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'URL to the social media site for this company', N'user', N'dbo', N'table', N'PRSocialMedia', N'column', N'prsm_URL'
GO


-- Begin PRSpecie SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_CompanyCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_CompanyCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of companies that have this specie.', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_CompanyCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_DisplayOrder')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_DisplayOrder'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order, within the a parent, to display these.', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_DisplayOrder'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_Level')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_Level'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Level in the hierarchy', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_Level'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the specie', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_ParentID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_ParentID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'NULL if highest level', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_ParentID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_SpecieID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_SpecieID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRSpecie', N'column', N'prspc_SpecieID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSpecie'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A list of species', N'user', N'dbo', N'table', N'PRSpecie'
GO


-- Begin PRState SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRState', N'column', N'prst_Abbreviation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRState', N'column', N'prst_Abbreviation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Abbreviation used for correspondence, etc.  Notes: Includes foreign states and provinces.  Possible Values: IL, S.L.P., etc.', N'user', N'dbo', N'table', N'PRState', N'column', N'prst_Abbreviation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRState', N'column', N'prst_State')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRState', N'column', N'prst_State'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of state or province', N'user', N'dbo', N'table', N'PRState', N'column', N'prst_State'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRState', N'column', N'prst_StateId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRState', N'column', N'prst_StateId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values: Sequence', N'user', N'dbo', N'table', N'PRState', N'column', N'prst_StateId'
GO


-- Begin PRStockExchange SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the stock exchange  Possible Values: NYSE, NASDAQ, TSE', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_Order')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_Order'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order of priority that the stock exchange should be shown in published listings.  Notes: Required if the PRLS_Publish is set on.', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_Order'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_Publish')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_Publish'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to determine if the exchange should be published in primary products.', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_Publish'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_StockExchangeId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_StockExchangeId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRStockExchange', N'column', N'prex_StockExchangeId'
GO


-- Begin PRTaxRate SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTaxRate', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTaxRate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is loaded periodically from external data', N'user', N'dbo', N'table', N'PRTaxRate'
GO


-- Begin PRTerminalMarket SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTerminalMarket', N'column', N'prtm_ShortMarketName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTerminalMarket', N'column', N'prtm_ShortMarketName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short name used primarily by the BBOS Mobile.', N'user', N'dbo', N'table', N'PRTerminalMarket', N'column', N'prtm_ShortMarketName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTerminalMarket', N'column', N'prtm_TerminalMarketId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTerminalMarket', N'column', N'prtm_TerminalMarketId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRTerminalMarket', N'column', N'prtm_TerminalMarketId'
GO


-- Begin PRTESForm SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company ID', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_ExpirationDateTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_ExpirationDateTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date/time this form expires.  If NULL, then never.', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_ExpirationDateTime'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_FaxFileName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_FaxFileName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Teleform Fax Image File name', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_FaxFileName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_FormType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_FormType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type of form  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_FormType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_Key')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_Key'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Non sequential key used for emails', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_Key'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_ReceivedDateTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_ReceivedDateTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date Received', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_ReceivedDateTime'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_ReceivedMethod')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_ReceivedMethod'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Method Receieved  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_ReceivedMethod'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_SentDateTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_SentDateTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date Sent', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_SentDateTime'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_SentMethod')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_SentMethod'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Method Sent  Notes: Custom_Captions', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_SentMethod'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_SerialNumber')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_SerialNumber'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique Serial Number printed on form', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_SerialNumber'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_TeleformId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_TeleformId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Teleform form ID.', N'user', N'dbo', N'table', N'PRTESForm', N'column', N'prtf_TeleformId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESForm'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represents a physical TES form sent to a responder.  Associated with PRTESDetail records independent of the PRTES records.', N'user', N'dbo', N'table', N'PRTESForm'
GO


-- Begin PRTESFormBatch SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESFormBatch', N'column', N'prtfb_LastFileCreation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESFormBatch', N'column', N'prtfb_LastFileCreation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last date/time the Documant files were created.', N'user', N'dbo', N'table', N'PRTESFormBatch', N'column', N'prtfb_LastFileCreation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESFormBatch', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESFormBatch'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Represnts a group of PRTESForm records.  Essentially the date/time the PRTESDetail records were grouped into the appropriate PRTESForm records.', N'user', N'dbo', N'table', N'PRTESFormBatch'
GO


-- Begin PRTESRequest SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_OverrideAddress')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_OverrideAddress'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If a fax or email address not in the system is used.', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_OverrideAddress'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_OverrideCustomAttention')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_OverrideCustomAttention'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If the user specifies custom text.', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_OverrideCustomAttention'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_OverridePersonID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_OverridePersonID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If sending it to someone other than the configured attention line person.', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_OverridePersonID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ProcessedByUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ProcessedByUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used by VIs, indicates this responder is being processed by this user ID.', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ProcessedByUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_Received')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_Received'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if a response was recevied.', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_Received'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ReceivedDateTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ReceivedDateTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'When repsonded to.  Not all responses are saved in the PRTradeReport table.', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ReceivedDateTime'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ReceivedMethod')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ReceivedMethod'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'How responded.  Not all responses are saved in the PRTradeReport table.', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ReceivedMethod'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ResponderCompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ResponderCompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Responder Company', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_ResponderCompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_SentMethod')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_SentMethod'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'How sent', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_SentMethod'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_Source')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_Source'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'What triggered this TES?', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_Source'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_TESFormID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_TESFormID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If associated with a paper form.', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_TESFormID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_TESRequestID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_TESRequestID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_TESRequestID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_VerbalInvestigationID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_VerbalInvestigationID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRVerbalInvestigation table.  Indicates this TES Request is part of a VI.', N'user', N'dbo', N'table', N'PRTESRequest', N'column', N'prtesr_VerbalInvestigationID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESRequest'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A Trade Experience Survey Request sent to a responder company about a subject company.', N'user', N'dbo', N'table', N'PRTESRequest'
GO


-- Begin PRTESResponseME.* SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESResponseME.*', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESResponseME.*'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Teleform table for multiple english forms.  The data never actually lands in the table.  A triggers processes the data creating PRTradeReport records.', N'user', N'dbo', N'table', N'PRTESResponseME.*'
GO


-- Begin PRTESResponseMS.* SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESResponseMS.*', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESResponseMS.*'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Teleform table for multiple spanish forms.  The data never actually lands in the table.  A triggers processes the data creating PRTradeReport records.', N'user', N'dbo', N'table', N'PRTESResponseMS.*'
GO


-- Begin PRTESResponseSE.* SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESResponseSE.*', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESResponseSE.*'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Teleform table for single english forms.  The data never actually lands in the table.  A triggers processes the data creating PRTradeReport records.', N'user', N'dbo', N'table', N'PRTESResponseSE.*'
GO


-- Begin PRTESResponseSS.* SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTESResponseSS.*', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTESResponseSS.*'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Teleform table for single spanish forms.  The data never actually lands in the table.  A triggers processes the data creating PRTradeReport records.', N'user', N'dbo', N'table', N'PRTESResponseSS.*'
GO


-- Begin PRTradeReport SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_AmountPastDue')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_AmountPastDue'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of any past due amounts.  Notes: Custom captions will be used to constrain the list.  Possible Values: None; Less than 25M; 25M to 100M; Over 100M', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_AmountPastDue'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_CollectRemit')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_CollectRemit'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company indicates they collect and remit with this company.  Possible Values: True = Collect and Remit', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_CollectRemit'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Comments')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Comments'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Various comments associated with the reported trade activity.', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Comments'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_CreditTerms')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_CreditTerms'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of credit terms with subject company.  Notes: The list of values will be constrained to those depicted here.  Perhaps custom captions could be used.  Possible Values: 10 days; 21 days; 30 days; Beyond 30 days', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_CreditTerms'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Date')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Date'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of completion of the trade report.  Notes: This is the date the trade report was completed.  It intends to represent that trade activity did occur within the previous 6 months of this date.', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Date'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_DisputeInvolved')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_DisputeInvolved'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicating disputes are involved if the subject company pays beyond terms.  Possible Values: True = Disputes Involved', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_DisputeInvolved'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_DoubtfulAccounts')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_DoubtfulAccounts'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company indicates encouragement of doubtful accounts.  Possible Values: True = "Encourage Doubtful Accounts"', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_DoubtfulAccounts'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_HighCredit')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_HighCredit'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reporting company''s statement of the level of credit extended to the trading partner.  Notes: The list of values will be constrained to those depicted here.  Perhaps custom captions could be used.  Possible Values: 5-10M; 10-50M; 50-75M; 75-100M; 100-250M; Over 250M', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_HighCredit'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_IntegrityID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_IntegrityID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reporting company''s perception of the trading partner in terms of BBSI''s moral responsibility rating.  Notes: This will be constrained to these 4 values.  Perhaps custom captions could be used.  Possible Values: XXXX; XXX; XX; X', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_IntegrityID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_InvoiceOnDayShipped')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_InvoiceOnDayShipped'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicating the company being surveyed invoices the same day as product is shipped.  Possible Values: True = Invoice Same Day', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_InvoiceOnDayShipped'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_LastDealtDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_LastDealtDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the last occurrence of business or activity with the relationship.  Notes: This would be based on a constrained list of ranges included in the Custom Captions table.  Possible Values: 1-6 Months; 7-12 Months; Over 1 Year', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_LastDealtDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_LoadsPerYear')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_LoadsPerYear'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of reported loads per year.  Notes: Custom captions will be used to constrain the list.  Possible Values: 1-24;25-50; 50-100; Over 100', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_LoadsPerYear'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_NoTrade')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_NoTrade'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating that trade experience no longer occurs with the company in question.', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_NoTrade'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_OutOfBusiness')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_OutOfBusiness'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating that the reporting company perceives this trading partner to be out of business.', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_OutOfBusiness'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Pack')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Pack'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicated quality of pack.  Notes: Custom captions will be used to constrain the list.  Possible Values: Superior, Average, Good, Fair', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Pack'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PayFreight')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PayFreight'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company indicates that company pays freight as agreed.  Possible Values: True = "Pay Freight as Agreed"', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PayFreight'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PaymentTrend')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PaymentTrend'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Describes the overall payment performance trend of the subject company as perceived by the surveyed company.  Notes: Custom captions will be used to constrain the list.  Possible Values: Improving; Unchanged; Declining', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PaymentTrend'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PayRatingID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PayRatingID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reporting company''s perception of the trading partner in terms of BBSI''s pay description rating.  Notes: The list of values will be constrained to those depicted here.  Perhaps custom captions could be used.  Possible Values: 10 days (AA); 11-15 (A); 15-21 (AB); 22-28 (B); 29-35 (''C); 36-45 (D); 46-60 (E); 60+ (F)', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PayRatingID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_ProductKickers')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_ProductKickers'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company indicates product kickers with this company.  Possible Values: True = Product Kickers', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_ProductKickers'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PromptHandling')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PromptHandling'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company indicates claims or adjustments are handled promptly.  Possible Values: True = Prompt Handling', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_PromptHandling'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_ProperEquipment')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_ProperEquipment'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company indicates the company secures proper equipment for each load.  Possible Values: True = "Secures Proper Equipment"', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_ProperEquipment'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Regularity')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Regularity'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag indicating that the company deals with this company on a regular basis.  Possible Values: True = Regularly', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Regularity'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_RelationshipLength')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_RelationshipLength'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'How long the company has dealt with the subject company.  Notes: This would be based on a constrained list of ranges included in the Custom Captions table.  Possible Values: Under 1 Year; 1-10 Years; 10+ years', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_RelationshipLength'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_RelationshipType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_RelationshipType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of the most significant way the company does business with the subject company.  Notes: This would be based on a constrained list of ranges included in the Custom Captions table.  Possible Values: Shipper; Broker; Distributor/Receiver; Chain Store; Importer/Exporter; Carrier; Transporation Broker; Freight Contractor; Freight Forwarder', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_RelationshipType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_ResponderId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_ResponderId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company/branch that has provided the trade report.', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_ResponderId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Seasonal')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Seasonal'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag stating that the relationship is only during a specific season.  Possible Values: True = Seasonal', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_Seasonal'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_SubjectId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_SubjectId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company/branch for which trade experience is being reported.', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_SubjectId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_TESRequestID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_TESRequestID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRTESRequest table.', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_TESRequestID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_TimelyArrivals')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_TimelyArrivals'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Company indicates company provides timely arrivals.  Possible Values: True = "Timely Arrivals"', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_TimelyArrivals'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_TradeReportId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_TradeReportId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRTradeReport', N'column', N'prtr_TradeReportId'
GO


-- Begin PRTransaction SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_AuthorizedById')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_AuthorizedById'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Individual that authorized the content update.  This relates to the Pers_PersonID in the Person table.  Notes: Relates to Pers_PersonID', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_AuthorizedById'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_AuthorizedInfo')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_AuthorizedInfo'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This field is text that explains the authorization if PRTx_AuthorizedBy is empty.  Notes: Required if AuthorizedBy is empty.', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_AuthorizedInfo'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_BusinessEventId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_BusinessEventId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Business event involved.  Notes: The transaction may not always be associated to a business event.  This is one of 5 foreign keys that could be populated.  The rest would remain null.', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_BusinessEventId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_CompanyId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_CompanyId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Company branch involved.  Notes: The transaction may not always be associated to a company.  This is one of 5 foreign keys that could be populated.  The rest would remain null.', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_CompanyId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_CreatedBy')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_CreatedBy'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) BBSI user that created the transaction', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_CreatedBy'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_EffectiveDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_EffectiveDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'When the change is intended to take effect', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_EffectiveDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_Explanation')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_Explanation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Detailed explanation for content change.  Notes: This is particularly important for changes to ratings.  The application may force this to be required on certain types of transactions.', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_Explanation'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_Listing')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_Listing'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The listing as it was when the transaction was closed.', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_Listing'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_NotificationStimulus')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_NotificationStimulus'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reason this information was received by BBSI  Notes: Custom captions can be utilized.  Possible Values: PRCo Initiated; Responded to LRL; Responded to custom PRCo Communication; Responded to promotion; unsolicited; Responded to DL Statement; Responded to BBS invoice/statement; Result of New Sale/Membership; Other', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_NotificationStimulus'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_NotificationType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_NotificationType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Manner in which BBSI learned of content update.  Notes: Custom captions can be utilized.  Possible Values: Phone, Fax, E-mail, Mail, Personal Visit, Convention Visit, Other', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_NotificationType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_ParentTransactionID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_ParentTransactionID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Allows multiple transactions to be associated.  Generally used when person transactions are opened as a result of opening a company transaction.', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_ParentTransactionID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_PersonEventId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_PersonEventId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Person event involved.  Notes: The transaction may not always be associated to a person event.  This is one of 5 foreign keys that could be populated.  The rest would remain null.', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_PersonEventId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_PersonId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_PersonId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'(FK) Person involved.  Notes: The transaction may not always be associated to a person.  This is one of 5 foreign keys that could be populated.  The rest would remain null.', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_PersonId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_RedbookDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_RedbookDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date that this change is observed in the Redbook publication.  Notes: This may be added after the transaction is finalized.  This may be the only editable field on the screen at that time.  Note:  This implies the ability to edit at least this field in the transaction remains available ongoing.', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_RedbookDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_Status')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_Status'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the transaction.  Notes: This is set by the system and is not edited by the user.  Possible Values: Open, Closed', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_Status'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_TransactionId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_TransactionId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRTransaction', N'column', N'prtx_TransactionId'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRTransaction'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransaction'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRTransaction'
GO


-- Begin PRTransactionDetail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_ColumnName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_ColumnName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of field changing', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_ColumnName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_ColumnType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_ColumnType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type of data associated with the field.  Possible Values: T:  Text, D:  Date, I:  Integer, N:  Numeric, B:  Boolean', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_ColumnType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_EntityName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_EntityName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The specific entity (type of data) that is affected.  Notes: This will be inserted automatically as a result of the transaction activity.  Possible Values: Company, Commodity, Classification, etc.', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_EntityName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_NewValue')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_NewValue'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This represents the new value converted to text for display on the user interface.', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_NewValue'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_OldValue')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_OldValue'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This represents the old value converted to text for display on the user interface.', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_OldValue'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_TransactionDetailId')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_TransactionDetailId'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.  Possible Values:  Sequence', N'user', N'dbo', N'table', N'PRTransactionDetail', N'column', N'prtd_TransactionDetailId'
GO


-- Begin PRVerbalInvestigation SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigation', N'column', N'prvi_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigation', N'column', N'prvi_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Subject Company ID', N'user', N'dbo', N'table', N'PRVerbalInvestigation', N'column', N'prvi_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigation', N'column', N'prvi_VerbalInvestigationID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigation', N'column', N'prvi_VerbalInvestigationID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRVerbalInvestigation', N'column', N'prvi_VerbalInvestigationID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigation', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigation'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the TESRequests that comprise a verbal investigation', N'user', N'dbo', N'table', N'PRVerbalInvestigation'
GO


-- Begin PRVerbalInvestigationCA SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCA', N'column', N'prvict_CallDisposition')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCA', N'column', N'prvict_CallDisposition'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The resuls of the call', N'user', N'dbo', N'table', N'PRVerbalInvestigationCA', N'column', N'prvict_CallDisposition'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCA', N'column', N'prvict_VerbalInvestigationCAID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCA', N'column', N'prvict_VerbalInvestigationCAID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRVerbalInvestigationCA', N'column', N'prvict_VerbalInvestigationCAID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCA', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCA'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tracks the failed call attemps for a verbal investigation.', N'user', N'dbo', N'table', N'PRVerbalInvestigationCA'
GO


-- Begin PRVerbalInvestigationCAVI SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_TESRequestID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_TESRequestID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRTESRequest table.', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_TESRequestID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_VerbalInvestigationCAID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_VerbalInvestigationCAID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRVerbalInvestigationCA table.', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_VerbalInvestigationCAID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_VerbalInvestigationCAVIID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_VerbalInvestigationCAVIID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_VerbalInvestigationCAVIID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_VerbalInvestigationID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_VerbalInvestigationID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRVerbalInvestigation table.', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', N'column', N'prvictvi_VerbalInvestigationID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a bridge table between the PRVerbalInvestigation, PRVerbalInvestigaitonCA, and PRTESRequest tables.', N'user', N'dbo', N'table', N'PRVerbalInvestigationCAVI'
GO


-- Begin PRWebAuditTrail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_AssociatedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_AssociatedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If applicable, the ID of the main entity of the page.', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_AssociatedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_AssociatedType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_AssociatedType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prwsat_AssociatedType custom_captions', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_AssociatedType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user''s company', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_IsTrial')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_IsTrial'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the user was using a Trail Access license when performing this activity.', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_IsTrial'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_PageName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_PageName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'ASPX page name.', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_PageName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_WebSiteAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_WebSiteAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_WebSiteAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'User that executed the search.', N'user', N'dbo', N'table', N'PRWebAuditTrail', N'column', N'prwsat_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebAuditTrail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks the ASPX pages executed by the user.  This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRWebAuditTrail'
GO


-- Begin PRWebServiceAuditTrail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_BBIDRequestCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_BBIDRequestCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of BBIDs requested.', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_BBIDRequestCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebMethodName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebMethodName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Web Method Name.', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebMethodName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebServiceAuditTrailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebServiceAuditTrailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebServiceAuditTrailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebServiceLicenseKeyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebServiceLicenseKeyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to PRWebServiceLicenseKey table.', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebServiceLicenseKeyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to PRWebUser table.', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', N'column', N'prwsat2_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks web service web method usage.  This table is archived so any changes to this data structure must also be made to the same structure in the CRMArchive database.', N'user', N'dbo', N'table', N'PRWebServiceAuditTrail'
GO


-- Begin PRWebServiceLicenseKey SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_AccessLevel')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_AccessLevel'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The access level for this key.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_AccessLevel'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_CustomExpirationDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_CustomExpirationDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates a custom expiration date is used and should not be updated based on the associated service.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_CustomExpirationDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_ExpirationDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_ExpirationDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Determines when the key expires.   Normally set to the associated PRService''s next anniversary date.  Notes: Useful for when an enterprise is switching keys.  The new key is associated with the current service, but this allows the old key to remain active a while longer.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_ExpirationDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_HQID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_HQID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The enterprise the key is associated with.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_HQID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_LicenseKey')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_LicenseKey'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'A GUID, typically generated in SQL via NEWID.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_LicenseKey'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_MaxRequestsPerMethod')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_MaxRequestsPerMethod'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Determines the maximum number of BBIDs that can be specified for a web method.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_MaxRequestsPerMethod'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_Password')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_Password'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Encrypted value used in conjunction with the license key to authenticate the calling software.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_Password'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_UserAssociatedWithCompanyRequired')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_UserAssociatedWithCompanyRequired'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that user credentials are required and the user must be associated with enterprise the key is associated with.  Notes: For use with enterpises that are members using the web service internally.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_UserAssociatedWithCompanyRequired'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_UserAuthRequired')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_UserAuthRequired'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that in addition to the license key authentication, user credentials are required to be authenticated too.  Notes: For use with applications that pass-through BBOS user credentials', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_UserAuthRequired'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_WebServiceLicenseID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_WebServiceLicenseID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', N'column', N'prwslk_WebServiceLicenseID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds the license keys used by enterprises to access the BBSI web service.  The values in this table define what the enterprise is allowed to do.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKey'
GO


-- Begin PRWebServiceLicenseKeyWM SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKeyWM', N'column', N'prwslkwm_WebMethodName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKeyWM', N'column', N'prwslkwm_WebMethodName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unqualified name of the web method.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKeyWM', N'column', N'prwslkwm_WebMethodName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKeyWM', N'column', N'prwslkwm_WebServiceLicenseID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKeyWM', N'column', N'prwslkwm_WebServiceLicenseID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to PRWebServiceLicenseKey table.', N'user', N'dbo', N'table', N'PRWebServiceLicenseKeyWM', N'column', N'prwslkwm_WebServiceLicenseID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKeyWM', N'column', N'prwslkwm_WebServiceLicenseWebMethodID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebServiceLicenseKeyWM', N'column', N'prwslkwm_WebServiceLicenseWebMethodID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Key', N'user', N'dbo', N'table', N'PRWebServiceLicenseKeyWM', N'column', N'prwslkwm_WebServiceLicenseWebMethodID'
GO


-- Begin PRWebUser SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_AcceptedTerms')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_AcceptedTerms'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the user has accepted the BBOS terms and conditions.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_AcceptedTerms'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_AccessLevel')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_AccessLevel'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: TBD', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_AccessLevel'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_BBID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_BBID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'May be specified by the user if they know it.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_BBID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_CompanyData')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_CompanyData'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contains XML data for the last Company Data Submission wizard.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_CompanyData'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_CompanyUpdateDaysOld')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_CompanyUpdateDaysOld'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'User setting for company update search', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_CompanyUpdateDaysOld'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_Culture')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_Culture'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used for localization.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_Culture'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_Email')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_Email'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The login ID of the user.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_Email'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_FailedAttemptCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_FailedAttemptCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times this record''s email address was used to attempt to login and an incorrect password was specified.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_FailedAttemptCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_FirstName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_FirstName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Populated if the web user is not in PIKS.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_FirstName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_HQID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_HQID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.  Used to identify the enterprise.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_HQID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_IndustryTypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_IndustryTypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only used by registered users.  Members will instead use comp_PRIndustryType.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_IndustryTypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_IsNewUser')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_IsNewUser'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the user is in a temporary state while a recent membership purchase is being processed.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_IsNewUser'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastCompanySearchID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastCompanySearchID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ID of the last company search executed', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastCompanySearchID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastCreditSheetSearchID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastCreditSheetSearchID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ID of the last person search executed', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastCreditSheetSearchID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastLoginDateTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastLoginDateTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last date/time the user logged in.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastLoginDateTime'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastName')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastName'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Populated if the web user is not in PIKS.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastName'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastPasswordChange')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastPasswordChange'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date/time of the last password change.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastPasswordChange'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastPersonSearchID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastPersonSearchID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ID of the last person search executed', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LastPersonSearchID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LinkedInToken')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LinkedInToken'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Token used to access this user''s LinkedIn account.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LinkedInToken'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LinkedInTokenSecret')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LinkedInTokenSecret'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Token Secret used to access this user''s LinkedIn account.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LinkedInTokenSecret'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LoginCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LoginCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times the user logged in.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_LoginCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_NAWLANumber')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_NAWLANumber'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used by the Lumber industry.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_NAWLANumber'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_Password')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_Password'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The password for the user.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_Password'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_PersonLinkID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_PersonLinkID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Populated if the web user is in PIKS.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_PersonLinkID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_PreviousAccessLevel')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_PreviousAccessLevel'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'When a trial license is assigned, the current access level value is moved to this value.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_PreviousAccessLevel'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_PreviousServiceCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_PreviousServiceCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'When a trial license is assigned, the current service code value is moved to this value.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_PreviousServiceCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_ServiceCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_ServiceCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The service code assigned to this user.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_ServiceCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_SessionTrackerIDCheckDisabled')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_SessionTrackerIDCheckDisabled'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the BBOS session tracking / license tracking is disabled for rthis user.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_SessionTrackerIDCheckDisabled'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_TrialExpirationDate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_TrialExpirationDate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'If the prwu_AccessLevel = Trial, the date the user''s access expires.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_TrialExpirationDate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_UICulture')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_UICulture'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used for localization.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_UICulture'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRWebUser', N'column', N'prwu_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUser'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds all web users.  If the user is in PIKS, most fields will be NULL but the PersonID will be populated.  Otherwise the PersonID will be NULL and the other fields populated.', N'user', N'dbo', N'table', N'PRWebUser'
GO


-- Begin PRWebUserContact SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_AssociatedCompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_AssociatedCompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The company the contact is associated with.', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_AssociatedCompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user''s company', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_HQID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_HQID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.  Used to identify the enterprise.', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_HQID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_IsPrivate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_IsPrivate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Determines if others in the user''s company can view/edit the contact.', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_IsPrivate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_WebUserContactID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_WebUserContactID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_WebUserContactID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user that created the contact', N'user', N'dbo', N'table', N'PRWebUserContact', N'column', N'prwuc_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserContact'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks custom contacts', N'user', N'dbo', N'table', N'PRWebUserContact'
GO


-- Begin PRWebUserCustomData SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_AssociatedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_AssociatedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'ID of the associated object', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_AssociatedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_AssociatedType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_AssociatedType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prwucd_AssociatedTypecustom_captions', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_AssociatedType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Denormalized Company ID for the user.', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_CustomDataID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_CustomDataID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_CustomDataID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_LabelCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_LabelCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prwucd_LabelCode custom_captions', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_LabelCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_sequence')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_sequence'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sequence the values should be display in.', N'user', N'dbo', N'table', N'PRWebUserCustomData', N'column', N'prwucd_sequence'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserCustomData'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores user custom data attributes for PIKS entities.', N'user', N'dbo', N'table', N'PRWebUserCustomData'
GO


-- Begin PRWebUserList SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Denormalized Company ID for the user.', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_HQID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_HQID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.  Used to identify the enterprise.', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_HQID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the list.', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_TypeCode')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_TypeCode'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prwucl_TypeCode custom_captions', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_TypeCode'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_WebUserListID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_WebUserListID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRWebUserList', N'column', N'prwucl_WebUserListID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserList'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table defines a user specified list of entities', N'user', N'dbo', N'table', N'PRWebUserList'
GO


-- Begin PRWebUserListDetail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_AssociatedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_AssociatedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the entity table', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_AssociatedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_AssociatedType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_AssociatedType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prwuld_AssociatedType custom_captions', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_AssociatedType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_WebUserListDetailID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_WebUserListDetailID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_WebUserListDetailID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_WebUserListID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_WebUserListID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the PRWebUserList table', N'user', N'dbo', N'table', N'PRWebUserListDetail', N'column', N'prwuld_WebUserListID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserListDetail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserListDetail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a bridge table associating entities with user lists.', N'user', N'dbo', N'table', N'PRWebUserListDetail'
GO


-- Begin PRWebUserNote SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_AssociatedID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_AssociatedID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The companyID or personID the note is associated with.', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_AssociatedID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_AssociatedType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_AssociatedType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of object the note is associated with.  Possible Values: prwun_AssociatedType custom_captions', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_AssociatedType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user''s company', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_HQID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_HQID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.  Used to identify the enterprise.', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_HQID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_IsPrivate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_IsPrivate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Determines if others in the user''s company can view/edit the note.', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_IsPrivate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_Subject')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_Subject'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only populated for type = Generic', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_Subject'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_WebUserID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_WebUserID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user that created the note', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_WebUserID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_WebUserNoteID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_WebUserNoteID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRWebUserNote', N'column', N'prwun_WebUserNoteID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserNote'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks custom notes.', N'user', N'dbo', N'table', N'PRWebUserNote'
GO


-- Begin PRWebUserSearchCriteria SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prcs_ProductProvidedListType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prcs_ProductProvidedListType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Determines if the displayed list is an alphabetical list or a hierarchy.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prcs_ProductProvidedListType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_CommodityListType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_CommodityListType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Determines if the displayed list is an alphabetical list or a hierarchy.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_CommodityListType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_CompanyID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_CompanyID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Denormalized Company ID for the user.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_CompanyID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_Criteria')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_Criteria'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The search criteria stored as XML.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_Criteria'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_ExecutionCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_ExecutionCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times the search was executed.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_ExecutionCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_HQID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_HQID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign Key to the Company table.  Used to identify the enterprise.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_HQID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_IsLastUnsavedSearch')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_IsLastUnsavedSearch'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a "System" search - last unsaved.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_IsLastUnsavedSearch'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_IsPrivate')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_IsPrivate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Determines if other users in the same company can see the search.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_IsPrivate'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_LastExecutionDateTime')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_LastExecutionDateTime'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last date/time the search was executed', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_LastExecutionDateTime'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_LastExecutionResultCount')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_LastExecutionResultCount'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The result count from the last execution.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_LastExecutionResultCount'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_Name')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_Name'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the saved search.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_Name'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_SearchCriteriaID')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_SearchCriteriaID'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique record ID.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_SearchCriteriaID'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_SearchType')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_SearchType'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Possible Values: prsc_SearchType custom_captions', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_SearchType'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_SelectedIDs')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_SelectedIDs'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'The IDs of the items selected in the last search.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', N'column', N'prsc_SelectedIDs'
GO

IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table holds the criteria for saved searches.', N'user', N'dbo', N'table', N'PRWebUserSearchCriteria'
GO


-- Begin PRWidgetAuditTrail SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWidgetAuditTrail', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWidgetAuditTrail'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks usage of the varous BBOS Widgets', N'user', N'dbo', N'table', N'PRWidgetAuditTrail'
GO


-- Begin UserContacts SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'UserContacts', N'column', N'UCnt_Id')) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'UserContacts', N'column', N'UCnt_Id'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sequential primary key for the table.', N'user', N'dbo', N'table', N'UserContacts', N'column', N'UCnt_Id'
GO


-- Begin PRSSFile SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSSFile', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSSFile'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used by special services for claims.', N'user', N'dbo', N'table', N'PRSSFile'
GO


-- Begin PRSSCATHistory SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRSSCATHistory', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRSSCATHistory'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tracks changes to a SSFile record.', N'user', N'dbo', N'table', N'PRSSCATHistory'
GO


-- Begin PRCourtCases SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCourtCases', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCourtCases'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Holds data from court cases, federal and state level.', N'user', N'dbo', N'table', N'PRCourtCases'
GO


-- Begin PRCompanySearch SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRCompanySearch', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRCompanySearch'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'One record per company, holds the various company names preformatted for searching.', N'user', N'dbo', N'table', N'PRCompanySearch'
GO


-- Begin PRInvoiceTaxRate SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRInvoiceTaxRate', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRInvoiceTaxRate'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trackes the tax information on a per invoice basis as it was at the time of the invoice.  Used for historical reporting.', N'user', N'dbo', N'table', N'PRInvoiceTaxRate'
GO


-- Begin PRGetListedRequest SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRGetListedRequest', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRGetListedRequest'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trackes "Get Listed" requests from the marketing web sites.', N'user', N'dbo', N'table', N'PRGetListedRequest'
GO


-- Begin PRWebSiteVisitor SQL Statements 
IF EXISTS (SELECT 'X' FROM fn_listextendedproperty(N'MS_Description', N'user', N'dbo', N'table', N'PRWebSiteVisitor', default, default)) BEGIN 
     EXEC sp_dropextendedproperty N'MS_Description', N'user', N'dbo', N'table', N'PRWebSiteVisitor'
END
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tracks visitors that view company info on the marketing web sites.', N'user', N'dbo', N'table', N'PRWebSiteVisitor'
GO

/*  1499 SQL Statements Created */


/* 1499 Alter Statements Created. */
Commit Transaction;
Select getdate() as "End Date/Time";
Set NoCount Off
