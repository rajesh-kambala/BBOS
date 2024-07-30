/*
 * Copyright (c) 2002-2008 Travant Solutions, Inc.
 * Created by Travant Excel SQL Export MACROs
 * SQL Inserts created from BBOS Demo Data.xls
 * on 4/14/2008 1:26:38 PM
 *
 */

Set NoCount On
Select getdate() as "Start Date/Time";
Begin Transaction;

/*  Begin PRWebUserList Inserts */
SET IDENTITY_INSERT PRWebUserList ON;
Select 'Begin PRWebUserList Inserts';
Insert Into PRWebUserList
(prwucl_WebUserListID,prwucl_WebUserID,prwucl_CompanyID,prwucl_HQID,prwucl_TypeCode,prwucl_Name,prwucl_Description,prwucl_IsPrivate,prwucl_CreatedBy,prwucl_CreatedDate,prwucl_UpdatedBy,prwucl_UpdatedDate,prwucl_TimeStamp)
Values (1,-100,-100,-100,'CU','Prospect List','All potential sales pros in my territory','Y',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserList
(prwucl_WebUserListID,prwucl_WebUserID,prwucl_CompanyID,prwucl_HQID,prwucl_TypeCode,prwucl_Name,prwucl_Description,prwucl_IsPrivate,prwucl_CreatedBy,prwucl_CreatedDate,prwucl_UpdatedBy,prwucl_UpdatedDate,prwucl_TimeStamp)
Values (2,-100,-100,-100,'CU','Credit Watch List','Watch carefully for changes in Blue Book Ratings','Y',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserList
(prwucl_WebUserListID,prwucl_WebUserID,prwucl_CompanyID,prwucl_HQID,prwucl_TypeCode,prwucl_Name,prwucl_Description,prwucl_IsPrivate,prwucl_CreatedBy,prwucl_CreatedDate,prwucl_UpdatedBy,prwucl_UpdatedDate,prwucl_TimeStamp)
Values (3,-100,-100,-100,'CU','Excellent Truck Companies','All the truck companies that have a XXXX Blue Book Rating','Y',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserList
(prwucl_WebUserListID,prwucl_WebUserID,prwucl_CompanyID,prwucl_HQID,prwucl_TypeCode,prwucl_Name,prwucl_Description,prwucl_IsPrivate,prwucl_CreatedBy,prwucl_CreatedDate,prwucl_UpdatedBy,prwucl_UpdatedDate,prwucl_TimeStamp)
Values (4,-100,-100,-100,'CU','Holiday Card List','Those companies I wish to be sure I send a Holiday Card to at year''s-end','Y',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserList
(prwucl_WebUserListID,prwucl_WebUserID,prwucl_CompanyID,prwucl_HQID,prwucl_TypeCode,prwucl_Name,prwucl_Description,prwucl_IsPrivate,prwucl_CreatedBy,prwucl_CreatedDate,prwucl_UpdatedBy,prwucl_UpdatedDate,prwucl_TimeStamp)
Values (5,-100,-100,-100,'CU','Key Accounts','High Profile customers in my territory','Y',-100,GETDATE(),-100,GETDATE(),GETDATE());

SET IDENTITY_INSERT PRWebUserList OFF;
/*  5 PRWebUserList Insert Statements Created */


/*  Begin PRWebUserListDetail Inserts */
SET IDENTITY_INSERT PRWebUserListDetail ON;
Select 'Begin PRWebUserListDetail Inserts';
Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (1,1,104524,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (2,1,109064,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (3,1,100737,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (4,1,114322,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (5,1,107952,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (6,1,107378,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (7,1,104786,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (8,1,101402,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (9,2,162959,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (10,2,103079,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (11,2,160703,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (12,2,166036,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (13,2,135035,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (14,2,189065,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (15,2,125788,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (16,2,114030,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (17,2,172111,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (18,2,117360,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (19,2,147046,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (20,2,105581,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (21,2,159466,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (22,2,154311,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (23,2,169147,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (24,3,108542,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (25,3,107644,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (26,3,130329,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (27,3,110604,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (28,3,111164,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (29,3,120063,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (30,3,131971,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (31,3,108800,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (32,3,122308,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (33,3,109841,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (34,3,118270,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (35,3,142227,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (36,3,123496,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (37,3,107071,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (38,3,158349,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (39,3,107155,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (40,3,134663,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (41,3,152079,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (42,3,108797,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (43,3,109637,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (44,3,110791,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (45,3,130135,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (46,3,110009,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (47,3,119548,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (48,3,125423,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (49,3,110236,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (50,3,124476,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (51,3,120857,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (52,3,109311,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (53,3,153853,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (54,3,139486,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (55,4,105716,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (56,4,110341,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (57,4,100586,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (58,4,112573,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (59,4,114843,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (60,4,110588,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (61,4,139047,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (62,4,112956,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (63,4,108224,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (64,4,102201,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (65,4,130750,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (66,4,113515,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (67,4,100579,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (68,4,110909,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (69,4,114027,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (70,4,104892,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (71,4,111865,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (72,4,113695,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (73,4,100548,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (74,4,104388,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (75,4,147784,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (76,4,111358,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (77,4,111541,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (78,4,102316,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (79,4,107465,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (80,4,108542,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (81,4,118270,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (82,4,123496,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (83,4,108797,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (84,4,125423,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (85,4,109931,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (86,4,111245,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (87,4,107317,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (88,4,123544,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (89,4,130938,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (90,4,131270,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (91,4,109849,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (92,4,134451,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (93,4,118561,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (94,4,107749,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (95,4,109186,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (96,4,120857,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (97,4,153853,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (98,4,110050,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (99,4,155258,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (100,4,203922,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (101,4,150285,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (102,4,154805,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (103,4,109309,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (104,4,148410,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (105,4,170104,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (106,4,160353,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (107,4,153787,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (108,4,168239,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (109,4,163314,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (110,4,205465,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (111,4,164505,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (112,5,188911,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (113,5,112751,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (114,5,161577,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (115,5,161705,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (116,5,106379,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (117,5,104524,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (118,5,101974,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (119,5,111344,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (120,5,185980,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (121,5,117213,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (122,5,100793,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (123,5,101386,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (124,5,106413,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (125,5,102316,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (126,5,111146,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (127,5,101878,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (128,5,164669,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (129,5,197959,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (130,5,103569,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (131,5,157008,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (132,5,154231,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (133,5,163382,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (134,5,132628,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (135,5,170241,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (136,5,100998,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (137,5,137118,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (138,5,128790,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (139,5,114792,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (140,5,148820,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (141,5,159477,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (142,5,102567,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (143,5,105086,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (144,5,148884,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (145,5,154589,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (146,5,111802,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

Insert Into PRWebUserListDetail
(prwuld_WebUserListDetailID,prwuld_WebUserListID,prwuld_AssociatedID,prwuld_AssociatedType,prwuld_CreatedBy,prwuld_CreatedDate,prwuld_UpdatedBy,prwuld_UpdatedDate,prwuld_TimeStamp)
Values (147,5,113248,'C',-100,GETDATE(),-100,GETDATE(),GETDATE());

SET IDENTITY_INSERT PRWebUserListDetail OFF;
/*  147 PRWebUserListDetail Insert Statements Created */


/*  Begin PRWebUserContact Inserts */
SET IDENTITY_INSERT PRWebUserContact ON;
Select 'Begin PRWebUserContact Inserts';
Insert Into PRWebUserContact
(prwuc_WebUserContactID,prwuc_WebUserID,prwuc_CompanyID,prwuc_HQID,prwuc_AssociatedCompanyID,prwuc_FirstName,prwuc_LastName,prwuc_Title,prwuc_MiddleName,prwuc_Suffix,prwuc_Email,prwuc_PhoneAreaCode,prwuc_PhoneNumber,prwuc_FaxAreaCode,prwuc_FaxNumber,prwuc_CellAreaCode,prwuc_CellNumber,prwuc_ResidenceAreaCode,prwuc_ResidenceNumber,prwuc_IsPrivate,prwuc_CreatedBy,prwuc_CreatedDate,prwuc_UpdatedBy,prwuc_UpdatedDate,prwuc_TimeStamp)
Values (1,-100,-100,-100,111609,'Chris','Smith','General Manager','Harold',NULL,'csmith@4star.com',941,'747-9512',941,'747-9877',941,'747-1111',941,'747-3333','Y',-100,GetDate(),-100,GetDate(),GetDate());

Insert Into PRWebUserContact
(prwuc_WebUserContactID,prwuc_WebUserID,prwuc_CompanyID,prwuc_HQID,prwuc_AssociatedCompanyID,prwuc_FirstName,prwuc_LastName,prwuc_Title,prwuc_MiddleName,prwuc_Suffix,prwuc_Email,prwuc_PhoneAreaCode,prwuc_PhoneNumber,prwuc_FaxAreaCode,prwuc_FaxNumber,prwuc_CellAreaCode,prwuc_CellNumber,prwuc_ResidenceAreaCode,prwuc_ResidenceNumber,prwuc_IsPrivate,prwuc_CreatedBy,prwuc_CreatedDate,prwuc_UpdatedBy,prwuc_UpdatedDate,prwuc_TimeStamp)
Values (2,-100,-100,-100,100826,'Susan','Summers','Vice President',NULL,NULL,'susans@unitedsalad.com',503,'288-9512',503,'288-9877',503,'288-1111',503,'288-3333','Y',-100,GetDate(),-100,GetDate(),GetDate());

Insert Into PRWebUserContact
(prwuc_WebUserContactID,prwuc_WebUserID,prwuc_CompanyID,prwuc_HQID,prwuc_AssociatedCompanyID,prwuc_FirstName,prwuc_LastName,prwuc_Title,prwuc_MiddleName,prwuc_Suffix,prwuc_Email,prwuc_PhoneAreaCode,prwuc_PhoneNumber,prwuc_FaxAreaCode,prwuc_FaxNumber,prwuc_CellAreaCode,prwuc_CellNumber,prwuc_ResidenceAreaCode,prwuc_ResidenceNumber,prwuc_IsPrivate,prwuc_CreatedBy,prwuc_CreatedDate,prwuc_UpdatedBy,prwuc_UpdatedDate,prwuc_TimeStamp)
Values (3,-100,-100,-100,121002,'John','Walters','Sales',NULL,NULL,'jwalters@faziomarketing.com',559,'486-9512',559,'486-9877',559,'486-1111',559,'486-3333','Y',-100,GetDate(),-100,GetDate(),GetDate());

Insert Into PRWebUserContact
(prwuc_WebUserContactID,prwuc_WebUserID,prwuc_CompanyID,prwuc_HQID,prwuc_AssociatedCompanyID,prwuc_FirstName,prwuc_LastName,prwuc_Title,prwuc_MiddleName,prwuc_Suffix,prwuc_Email,prwuc_PhoneAreaCode,prwuc_PhoneNumber,prwuc_FaxAreaCode,prwuc_FaxNumber,prwuc_CellAreaCode,prwuc_CellNumber,prwuc_ResidenceAreaCode,prwuc_ResidenceNumber,prwuc_IsPrivate,prwuc_CreatedBy,prwuc_CreatedDate,prwuc_UpdatedBy,prwuc_UpdatedDate,prwuc_TimeStamp)
Values (4,-100,-100,-100,121002,'Sally','Jones','Sales',NULL,NULL,'sjones@faziomarketing.com',559,'486-9513',559,'486-9878',559,'486-1112',559,'486-3334','Y',-100,GetDate(),-100,GetDate(),GetDate());

SET IDENTITY_INSERT PRWebUserContact OFF;
/*  4 PRWebUserContact Insert Statements Created */


/*  Begin PRWebUserNote Inserts */
SET IDENTITY_INSERT PRWebUserNote ON;
Select 'Begin PRWebUserNote Inserts';
Insert Into PRWebUserNote
(prwun_WebUserNoteID,prwun_WebUserID,prwun_CompanyID,prwun_HQID,prwun_AssociatedID,prwun_AssociatedType,prwun_Note,prwun_IsPrivate,prwun_CreatedBy,prwun_CreatedDate,prwun_UpdatedBy,prwun_UpdatedDate,prwun_TimeStamp)
Values (1,-100,-100,-100,119928,'C','Contact:  Joe Douglas
Phone 210 226-6446
E-Mail:  jcollier@aatrans.com
===========================
Contact  summary

10/10/06 Discussed the possibility of utilizing this company in 2007 for the hauling of our Potatoes throughout the Midwest, with their Gen. Mgr. and Pres., Joe Douglas.  He is to provide us with some information about their company via FAX by Friday 10/11/06. He also advised to look at their Web Site for further information.

10/11/06  Heard from Allred produce that this is an excellent transportation company, when we were speaking on the phone.  I will call them to get more information.  Their BB rating is excellent also.  We need a new transportation company since XYZ Truck Brokers went out of business.
','Y',-100,GETDATE(),100001,GETDATE(),GETDATE());

Insert Into PRWebUserNote
(prwun_WebUserNoteID,prwun_WebUserID,prwun_CompanyID,prwun_HQID,prwun_AssociatedID,prwun_AssociatedType,prwun_Note,prwun_IsPrivate,prwun_CreatedBy,prwun_CreatedDate,prwun_UpdatedBy,prwun_UpdatedDate,prwun_TimeStamp)
Values (2,-100,-100,-100,1,'PC','Spoke with Chris on 5/1/08 about purchasing a load of green beans.','Y',-100,GETDATE(),100001,GETDATE(),GETDATE());

Insert Into PRWebUserNote
(prwun_WebUserNoteID,prwun_WebUserID,prwun_CompanyID,prwun_HQID,prwun_AssociatedID,prwun_AssociatedType,prwun_Note,prwun_IsPrivate,prwun_CreatedBy,prwun_CreatedDate,prwun_UpdatedBy,prwun_UpdatedDate,prwun_TimeStamp)
Values (3,-100,-100,-100,3,'PC','New Sales guy here as of 5/1/08.','Y',-100,GETDATE(),100001,GETDATE(),GETDATE());

Insert Into PRWebUserNote
(prwun_WebUserNoteID,prwun_WebUserID,prwun_CompanyID,prwun_HQID,prwun_AssociatedID,prwun_AssociatedType,prwun_Note,prwun_IsPrivate,prwun_CreatedBy,prwun_CreatedDate,prwun_UpdatedBy,prwun_UpdatedDate,prwun_TimeStamp)
Values (4,-100,-100,-100,4,'PC','New salesperson here as of 5/1/08.','Y',-100,GETDATE(),100001,GETDATE(),GETDATE());

Insert Into PRWebUserNote
(prwun_WebUserNoteID,prwun_WebUserID,prwun_CompanyID,prwun_HQID,prwun_AssociatedID,prwun_AssociatedType,prwun_Note,prwun_IsPrivate,prwun_CreatedBy,prwun_CreatedDate,prwun_UpdatedBy,prwun_UpdatedDate,prwun_TimeStamp)
Values (5,-100,-100,-100,25034,'P','2/22/04 -- We are to meet with Leo at the United Convention in Phoenix.

1/15/04 -- Left voice mail message for Leo to return my call.

12/23/03 -- Called and left a message for Leo, who was in a meeting. Leo promptly called back and said that he was considering our proposal and asked that I call him back in the next 10-14 days.
','Y',-100,GETDATE(),100001,GETDATE(),GETDATE());

Insert Into PRWebUserNote
(prwun_WebUserNoteID,prwun_WebUserID,prwun_CompanyID,prwun_HQID,prwun_AssociatedID,prwun_AssociatedType,prwun_Note,prwun_IsPrivate,prwun_CreatedBy,prwun_CreatedDate,prwun_UpdatedBy,prwun_UpdatedDate,prwun_TimeStamp)
Values (6,-100,-100,-100,111609,'C','Company Contact:
  Scott Shackelford
  Business Phone: 941-555-1212
  Home Phone:  954-555-1313
  E-mail: scott@aol.com
  Assistant:  Joanne
===================================

PHONE FOLLOW UP DOCUMENTATION:

04/01/08 - have not heard from Scott via phone, but met with him at a local convention.  He suggested some revisions to the proposal which I am working on.

1/15/08 -- Left voice mail message for Scott to return my call.  

12/23/07 -- Called and left a message for Scott, who was in a meeting. Scott promptly called back and said that he was considering our proposal and asked that I call him back in the next 10-14 days.

UPDATE: Joanne called me back to indicate the FAX was received and would be given to Scott this afternoon. 

11/15/07 -- Talked to Joanne, who said she did not get the FAX we sent yesterday.

LETTER/PROPOSAL DOCUMENTATION:
c:\proposals\agrointl.doc

11/16/07 -- Resent Letter by FAX','Y',-100,GETDATE(),100001,GETDATE(),GETDATE());

Insert Into PRWebUserNote
(prwun_WebUserNoteID,prwun_WebUserID,prwun_CompanyID,prwun_HQID,prwun_AssociatedID,prwun_AssociatedType,prwun_Note,prwun_IsPrivate,prwun_CreatedBy,prwun_CreatedDate,prwun_UpdatedBy,prwun_UpdatedDate,prwun_TimeStamp)
Values (7,-100,-100,-100,111358,'C','Date        Product      Quantity        Price         Contact Person
--------------------------------------------------------------------------------
6/12/06   Carrots      8 Pallets        $12/box      Tim McCorkle
7/23/06   Carrots      15 Pallets      $12/box      Tony Pazzi


Misc. Notes:
--------------------------
9/11/07  We have not sold to this company in quite some time.  This Key Customer appears to be slipping.  I will need to re-establish contact here with Tony Pazzi in the next 2 weeks.  Report anything unusual here with the President.

10/5/07  I tried calling Tony Pazzi today but he was out of the office.  He had already left for the PMA convention in PA.  He is not expected to return until 10/15/07 late in the day.  I will attempt to reach him on 10/18/07.','Y',-100,GETDATE(),100001,GETDATE(),GETDATE());

Insert Into PRWebUserNote
(prwun_WebUserNoteID,prwun_WebUserID,prwun_CompanyID,prwun_HQID,prwun_AssociatedID,prwun_AssociatedType,prwun_Note,prwun_IsPrivate,prwun_CreatedBy,prwun_CreatedDate,prwun_UpdatedBy,prwun_UpdatedDate,prwun_TimeStamp)
Values (8,-100,-100,-100,104263,'C','Background:
================================
We have been selling this account since 2002.  After initially selling exclusively Apricots, we have expanded our sales activity to include 4 main categories, with Peaches now our highest volume commodity.  The firm consistently pays us within two weeks. Although their Pay Rating reflects variable pay, we have had good experiences with their pay practices to date - we will continually need to monitor this account.','Y',-100,GETDATE(),100001,GETDATE(),GETDATE());

Insert Into PRWebUserNote
(prwun_WebUserNoteID,prwun_WebUserID,prwun_CompanyID,prwun_HQID,prwun_AssociatedID,prwun_AssociatedType,prwun_Note,prwun_IsPrivate,prwun_CreatedBy,prwun_CreatedDate,prwun_UpdatedBy,prwun_UpdatedDate,prwun_TimeStamp)
Values (9,-100,-100,-100,149203,'C','10/10/06 Discussed the possiblility of utilizing this company in 2007 for the hauling of our Potatoes throughout the midwest, with their Gen. Mgr. and Pres., Joe Smith.  He is to provide us with some information about their company via FAX by Friday 10/11/06. He also advised us to look at their Web Site for further information.','Y',-100,GETDATE(),100001,GETDATE(),GETDATE());

SET IDENTITY_INSERT PRWebUserNote OFF;
/*  9 PRWebUserNote Insert Statements Created */


/*  Begin PRWebUserSearchCriteria Inserts */
SET IDENTITY_INSERT PRWebUserSearchCriteria ON;
Select 'Begin PRWebUserSearchCriteria Inserts';
Insert Into PRWebUserSearchCriteria
(prsc_SearchCriteriaID,prsc_WebUserID,prsc_CompanyID,prsc_HQID,prsc_Name,prsc_LastExecutionDateTime,prsc_LastExecutionResultCount,prsc_ExecutionCount,prsc_SearchType,prsc_SelectedIDs,prsc_IsPrivate,prsc_IsLastUnsavedSearch,prsc_CreatedBy,prsc_CreatedDate,prsc_UpdatedBy,prsc_UpdatedDate,prsc_TimeStamp,prsc_Criteria)
Values (1,-100,-100,-100,'All Strawberry Shippers in CA with XXX or XXXX',NULL,0,0,'Company',NULL,'Y',NULL,-100,GETDATE(),-100,GETDATE(),GETDATE(),'<?xml version="1.0" encoding="utf-16"?>  <CompanySearchCriteria xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">    <BBID>0</BBID>    <SearchWizardID>0</SearchWizardID>    <CompanyName />    <SortAsc>false</SortAsc>    <CompanyType />    <ListingStatus>L,H</ListingStatus>    <PhoneAreaCode />    <PhoneNumber />    <FaxAreaCode />    <FaxNumber />    <Email />    <IndustryType>P</IndustryType>    <ListingCountryIDs />    <ListingStateIDs>5</ListingStateIDs>    <ListingCity />    <ListingPostalCode />    <TerminalMarketIDs />    <RadiusType>Listing Postal Code</RadiusType>    <ClassificationIDs>390</ClassificationIDs>    <ClassificationSearchType>Any</ClassificationSearchType>    <CommodityIDs>84</CommodityIDs>    <NumberOfRetailStores />    <NumberOfRestaurantStores />    <CommoditySearchType>Any</CommoditySearchType>    <MemberYearSearchType>=</MemberYearSearchType>    <BBScoreSearchType>=</BBScoreSearchType>    <RatingCreditWorthIDs />    <RatingIntegrityIDs>6,5</RatingIntegrityIDs>    <RatingPayIDs />    <HasNotes>false</HasNotes>    <FaxNotNull>false</FaxNotNull>    <EmailNotNull>false</EmailNotNull>    <NewListingOnly>false</NewListingOnly>    <IsQuickSearch>false</IsQuickSearch>    <CustomIdentifierNotNull>false</CustomIdentifierNotNull>    <NewListingDaysOld>1</NewListingDaysOld>    <Radius>-1</Radius>    <CommodityGMAttributeID>0</CommodityGMAttributeID>    <CommodityAttributeID>0</CommodityAttributeID>    <MemberYear>0</MemberYear>    <BBScore>0</BBScore>  </CompanySearchCriteria>');

Insert Into PRWebUserSearchCriteria
(prsc_SearchCriteriaID,prsc_WebUserID,prsc_CompanyID,prsc_HQID,prsc_Name,prsc_LastExecutionDateTime,prsc_LastExecutionResultCount,prsc_ExecutionCount,prsc_SearchType,prsc_SelectedIDs,prsc_IsPrivate,prsc_IsLastUnsavedSearch,prsc_CreatedBy,prsc_CreatedDate,prsc_UpdatedBy,prsc_UpdatedDate,prsc_TimeStamp,prsc_Criteria)
Values (2,-100,-100,-100,'All Retail and Wholesale Grocers',NULL,0,0,'Company',NULL,'Y',NULL,-100,GETDATE(),-100,GETDATE(),GETDATE(),'<?xml version="1.0" encoding="utf-16"?>  <CompanySearchCriteria xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">    <BBID>0</BBID>    <SearchWizardID>0</SearchWizardID>    <CompanyName />    <SortAsc>false</SortAsc>    <CompanyType />    <ListingStatus>L,H</ListingStatus>    <PhoneAreaCode />    <PhoneNumber />    <FaxAreaCode />    <FaxNumber />    <Email />    <IndustryType>P</IndustryType>    <ClassificationIDs>330,340</ClassificationIDs>    <ClassificationSearchType>Any</ClassificationSearchType>    <NumberOfRetailStores />    <NumberOfRestaurantStores />    <HasNotes>false</HasNotes>    <FaxNotNull>false</FaxNotNull>    <EmailNotNull>false</EmailNotNull>    <NewListingOnly>false</NewListingOnly>    <IsQuickSearch>false</IsQuickSearch>    <CustomIdentifierNotNull>false</CustomIdentifierNotNull>    <NewListingDaysOld>1</NewListingDaysOld>    <Radius>-1</Radius>    <CommodityGMAttributeID>0</CommodityGMAttributeID>    <CommodityAttributeID>0</CommodityAttributeID>    <MemberYear>0</MemberYear>    <BBScore>0</BBScore>  </CompanySearchCriteria>');

Insert Into PRWebUserSearchCriteria
(prsc_SearchCriteriaID,prsc_WebUserID,prsc_CompanyID,prsc_HQID,prsc_Name,prsc_LastExecutionDateTime,prsc_LastExecutionResultCount,prsc_ExecutionCount,prsc_SearchType,prsc_SelectedIDs,prsc_IsPrivate,prsc_IsLastUnsavedSearch,prsc_CreatedBy,prsc_CreatedDate,prsc_UpdatedBy,prsc_UpdatedDate,prsc_TimeStamp,prsc_Criteria)
Values (3,-100,-100,-100,'All Produce Co''s within 25 mi radius of 85255',NULL,0,0,'Company',NULL,'Y',NULL,-100,GETDATE(),-100,GETDATE(),GETDATE(),'<?xml version="1.0" encoding="utf-16"?>  <CompanySearchCriteria xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">    <BBID>0</BBID>    <SearchWizardID>0</SearchWizardID>    <CompanyName />    <SortAsc>false</SortAsc>    <CompanyType />    <ListingStatus>L,H</ListingStatus>    <PhoneAreaCode />    <PhoneNumber />    <FaxAreaCode />    <FaxNumber />    <Email />    <IndustryType>P</IndustryType>    <ListingCountryIDs />    <ListingStateIDs />    <ListingCity />    <ListingPostalCode>85255</ListingPostalCode>    <TerminalMarketIDs />    <RadiusType>Listing Postal Code</RadiusType>    <HasNotes>false</HasNotes>    <FaxNotNull>false</FaxNotNull>    <EmailNotNull>false</EmailNotNull>    <NewListingOnly>false</NewListingOnly>    <IsQuickSearch>false</IsQuickSearch>    <CustomIdentifierNotNull>false</CustomIdentifierNotNull>    <NewListingDaysOld>1</NewListingDaysOld>    <Radius>25</Radius>    <CommodityGMAttributeID>0</CommodityGMAttributeID>    <CommodityAttributeID>0</CommodityAttributeID>    <MemberYear>0</MemberYear>    <BBScore>0</BBScore>  </CompanySearchCriteria>');

Insert Into PRWebUserSearchCriteria
(prsc_SearchCriteriaID,prsc_WebUserID,prsc_CompanyID,prsc_HQID,prsc_Name,prsc_LastExecutionDateTime,prsc_LastExecutionResultCount,prsc_ExecutionCount,prsc_SearchType,prsc_SelectedIDs,prsc_IsPrivate,prsc_IsLastUnsavedSearch,prsc_CreatedBy,prsc_CreatedDate,prsc_UpdatedBy,prsc_UpdatedDate,prsc_TimeStamp,prsc_Criteria)
Values (4,-100,-100,-100,'All Produce Co''s with BB Score 950 or higher',NULL,0,0,'Company',NULL,'Y',NULL,-100,GETDATE(),-100,GETDATE(),GETDATE(),'<?xml version="1.0" encoding="utf-16"?>  <CompanySearchCriteria xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">    <BBID>0</BBID>    <SearchWizardID>0</SearchWizardID>    <CompanyName />    <SortAsc>false</SortAsc>    <CompanyType />    <ListingStatus>L,H</ListingStatus>    <PhoneAreaCode />    <PhoneNumber />    <FaxAreaCode />    <FaxNumber />    <Email />    <IndustryType>P</IndustryType>    <MemberYearSearchType>=</MemberYearSearchType>    <BBScoreSearchType>&gt;</BBScoreSearchType>    <RatingCreditWorthIDs />    <RatingIntegrityIDs />    <RatingPayIDs />    <HasNotes>false</HasNotes>    <FaxNotNull>false</FaxNotNull>    <EmailNotNull>false</EmailNotNull>    <NewListingOnly>false</NewListingOnly>    <IsQuickSearch>false</IsQuickSearch>    <CustomIdentifierNotNull>false</CustomIdentifierNotNull>    <NewListingDaysOld>1</NewListingDaysOld>    <Radius>-1</Radius>    <CommodityGMAttributeID>0</CommodityGMAttributeID>    <CommodityAttributeID>0</CommodityAttributeID>    <MemberYear>0</MemberYear>    <BBScore>950</BBScore>  </CompanySearchCriteria>');

SET IDENTITY_INSERT PRWebUserSearchCriteria OFF;
/*  4 PRWebUserSearchCriteria Insert Statements Created */






/* 169 Insert Statements Created. */
Commit Transaction;
Select getdate() as "End Date/Time";
Set NoCount Off
