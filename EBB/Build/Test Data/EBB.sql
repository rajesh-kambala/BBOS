/*
 * Copyright (c) 2002-2008 Travant Solutions, Inc.
 * Created by Travant Excel SQL Export MACROs
 * SQL Inserts created from EBB.xls
 * on 2/26/2008 5:57:33 AM
 *
 */

Set NoCount On
Select getdate() as "Start Date/Time";
Begin Transaction;
DELETE FROM PRWebUser where prwu_CreatedBy = -100;
DELETE FROM PRWebUserList where prwucl_CreatedBy = -100;
DELETE FROM PRWebUserListDetail WHERE prwuld_CreatedBy = -100;
DELETE FROM PRWebUserContact WHERE prwuc_CreatedBy = -100
DELETE FROM PRWebUserNote where prwun_CreatedBy = -100;
DELETE FROM PRWebServiceLicenseKey WHERE prwslk_CreatedBy=-100
DELETE FROM PRWebServiceLicenseKeyWM WHERE prwslkwm_CreatedBy=-100



/*  Begin PRWebUser Inserts */

Select 'Begin PRWebUser Inserts';
Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100001,'cwalls@travant.com','bWIDG2It488=','Christopher','Walls',116115,204482,204482,'Travant Solutions, Inc.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100002,'scole@travant.com','bWIDG2It488=','Sharon','Cole',116117,204482,204482,'Travant Solutions, Inc.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100003,'jbartelson@bluebookprco.com','bWIDG2It488=','Jim','Bartelson',116661,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100004,'jearley@bluebookprco.com','bWIDG2It488=','Judit','Earley',116665,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100005,'vbetancourt@bluebookprco.com','bWIDG2It488=','Vicky','Betancourt',116662,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100006,'ccarr@bluebookprco.com','bWIDG2It488=','C','Carr',116663,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100007,'merickson@bluebookprco.com','bWIDG2It488=','Mark','Erickson',116667,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100008,'bzentner@bluebookprco.com','bWIDG2It488=','Bill','Zentner',116677,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100009,'jbrown@bluebookprco.com','bWIDG2It488=','Julie','Brown',116679,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100010,'jcrowley@bluebookprco.com','bWIDG2It488=','Jason','Crowley',116664,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100011,'jlair@bluebookprco.com','bWIDG2It488=','Jeff','Lair',116668,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100012,'mnasby@bluebookprco.com','bWIDG2It488=','Marsha','Nasby',116669,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100013,'mrempert@bluebookprco.com','bWIDG2It488=','Maureen','Rempert',116674,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100014,'wbaker@bluebookprco.com','bWIDG2It488=','Whitney','Baker',116660,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100015,'teness@bluebookprco.com','bWIDG2It488=','Tad','Eness',116666,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100016,'cthoms@bluebookprco.com','bWIDG2It488=','Christopher','Thoms',116676,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100017,'korlowski@bluebookprco.com','bWIDG2It488=','Kathi','Orlowski',116671,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100018,'eperez@bluebookprco.com','bWIDG2It488=','Edith','Perez',116672,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100019,'dszwed@bluebookprco.com','bWIDG2It488=','Dan','Szwed',116675,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100020,'lbrown@bluebookprco.com','bWIDG2It488=','Laura','Brown',116678,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100021,'ssax@travant.com','bWIDG2It488=','Scott','Sax',114067,204482,204482,'Travant Solutions, Inc.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100022,'rotruba@travant.com','bWIDG2It488=','Richard','Otruba',116116,204482,204482,'Travant Solutions, Inc.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100023,'csieloff@bluebookprco.com','bWIDG2It488=','Cliff','Sieloff',117544,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100024,'bmagers@bluebookprco.com','bWIDG2It488=','Bob','Magers',117662,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100025,'chuck.weise@bluebookprco.com','bWIDG2It488=','Chuck','Weise',117664,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100026,'efromhold@bluebookprco.com','bWIDG2It488=','Erika','Fromhold',117666,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100027,'fsanchez@bluebookprco.com','bWIDG2It488=','Frank','Sanchez',117667,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100028,'wmelo@bluebookprco.com','bWIDG2It488=','Willam','Melo',117727,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100029,'sjacobs@bluebookprco.com  ','bWIDG2It488=','Steve','Jacobs',117726,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100030,'chardy@bluebookprco.com','bWIDG2It488=','Christopher','Hardy',119404,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100031,'jmangini@bluebookprco.com','bWIDG2It488=','Judy','Mangini',119407,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100032,'amacdonald@bluebookprco.com','bWIDG2It488=','Anne','MacDonald',119406,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUser
(prwu_WebUserID,prwu_Email,prwu_Password,prwu_FirstName,prwu_LastName,prwu_PersonLinkID,prwu_BBID,prwu_HQID,prwu_CompanyName,prwu_Culture,prwu_UICulture,prwu_AccessLevel,prwu_LastLoginDateTime,prwu_LoginCount,prwu_FailedAttemptCount,prwu_LastPasswordChange,prwu_TitleCode,prwu_Address1,prwu_Address2,prwu_City,prwu_StateID,prwu_CountryID,prwu_PostalCode,prwu_PhoneAreaCode,prwu_PhoneNumber,prwu_FaxAreaCode,prwu_FaxNumber,prwu_WebSite,prwu_HowLearned,prwu_MailListOptIn,prwu_MembershipInterest,prwu_Gender,prwu_IndustryClassification,prwu_CompanySize,prwu_TrialExpirationDate,prwu_ServiceID,prwu_AcceptedTerms,prwu_IsNewUser,prwu_LastCompanySearchID,prwu_LastPersonSearchID,prwu_LastCreditSheetSearchID,prwu_DefaultCompanySearchPage,prwu_CompanyData,prwu_CreatedBy,prwu_CreatedDate,prwu_UpdatedBy,prwu_UpdatedDate,prwu_TimeStamp)
Values (100033,'nmcnear@bluebookprco.com','bWIDG2It488=','Nadine','McNear',119405,100002,100002,'Produce Reporter Co.','en-us','en-us',999999,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());


/*  33 PRWebUser Insert Statements Created */


















alter table Company disable trigger all
Update company set comp_PRConnectionListDate = '2006-01-01', comp_PRJeopardyDate = '2007-11-01' where comp_CompanyID IN (204482, 100002);
alter table Company enable trigger all
UPDATE PRTES Set prte_ResponderCompanyID=100002 where prte_TESID IN (select prt2_TESID from PRTESDetail WHERE prt2_TESFormID IN (Select top 20 prtf_TESFormID from PRTESForm where prtf_SentDateTime > DATEADD(day, -30, GETDATE()) AND prtf_ReceivedMethod IS NULL));
UPDATE PRTES Set prte_ResponderCompanyID=204482 where prte_TESID IN (select prt2_TESID from PRTESDetail WHERE prt2_TESFormID IN (Select top 20 prtf_TESFormID from PRTESForm where prtf_SentDateTime > DATEADD(day, -30, GETDATE()) AND prtf_ReceivedMethod IS NULL));
EXEC usp_ProcessNewMembeshipUser 100001
EXEC usp_ProcessNewMembeshipUser 100002
EXEC usp_ProcessNewMembeshipUser 100003
EXEC usp_ProcessNewMembeshipUser 100004
EXEC usp_ProcessNewMembeshipUser 100005
EXEC usp_ProcessNewMembeshipUser 100006
EXEC usp_ProcessNewMembeshipUser 100007
EXEC usp_ProcessNewMembeshipUser 100008
EXEC usp_ProcessNewMembeshipUser 100009
EXEC usp_ProcessNewMembeshipUser 100010
EXEC usp_ProcessNewMembeshipUser 100011
EXEC usp_ProcessNewMembeshipUser 100012
EXEC usp_ProcessNewMembeshipUser 100013
EXEC usp_ProcessNewMembeshipUser 100014
EXEC usp_ProcessNewMembeshipUser 100015
EXEC usp_ProcessNewMembeshipUser 100016
EXEC usp_ProcessNewMembeshipUser 100017
EXEC usp_ProcessNewMembeshipUser 100018
EXEC usp_ProcessNewMembeshipUser 100019
EXEC usp_ProcessNewMembeshipUser 100020
EXEC usp_ProcessNewMembeshipUser 100021
EXEC usp_ProcessNewMembeshipUser 100022
EXEC usp_ProcessNewMembeshipUser 100023
EXEC usp_ProcessNewMembeshipUser 100024
EXEC usp_ProcessNewMembeshipUser 100025
EXEC usp_ProcessNewMembeshipUser 100026
EXEC usp_ProcessNewMembeshipUser 100027
EXEC usp_ProcessNewMembeshipUser 100028
EXEC usp_ProcessNewMembeshipUser 100029
EXEC usp_ProcessNewMembeshipUser 100030
EXEC usp_ProcessNewMembeshipUser 100031
EXEC usp_ProcessNewMembeshipUser 100032
EXEC usp_ProcessNewMembeshipUser 100033
exec usp_AllocateServiceUnits 100002, 88606, 100, 'O', null, 'A', '11-5-2006', -200, 100002
exec usp_AllocateServiceUnits 100002, 88606, 100, 'O', null, 'A', '1-3-2007', -200, 100002
exec usp_AllocateServiceUnits 100002, 88606, 100, 'O', null, 'A', '4-15-2007', -200, 100002
exec usp_AllocateServiceUnits 100002, 88606, 100, 'O', null, 'A', '6-25-2007', -200, 100002
exec usp_AllocateServiceUnits 204482, 88606, 100, 'O', null, 'A', '11-5-2006', -200, 204482
exec usp_AllocateServiceUnits 204482, 88606, 100, 'O', null, 'A', '1-3-2007', -200, 204482
exec usp_AllocateServiceUnits 204482, 88606, 100, 'O', null, 'A', '4-15-2007', -200, 204482
exec usp_AllocateServiceUnits 204482, 88606, 100, 'O', null, 'A', '6-25-2007', -200, 204482
exec usp_UpdateSQLIdentity 'PRWebUser', 'prwu_WebUserID'
exec usp_UpdateSQLIdentity 'PRWebUserList', 'prwucl_WebUserListID'
exec usp_UpdateSQLIdentity 'PRWebUserListDetail', 'prwuld_WebUserListDetailID'
exec usp_UpdateSQLIdentity 'PRWebUserContact', 'prwuc_WebUserContactID'
exec usp_UpdateSQLIdentity 'PRWebServiceLicenseKey', 'prwslk_WebServiceLicenseID'
exec usp_UpdateSQLIdentity 'PRWebServiceLicenseKeyWM', 'prwslkwm_WebServiceLicenseWebMethodID'


/* 33 Insert Statements Created. */
Commit Transaction;
Select getdate() as "End Date/Time";
Set NoCount Off
