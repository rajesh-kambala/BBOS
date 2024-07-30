/***********************************************************************
 Copyright Produce Reporter Company 2006-2016

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ReportUser.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace PRCo.BBS.BBSMonitor {

    /// <summary>
    /// Helper class to manage which Person/Company needs
    /// to get a report.
    /// 
    /// Not all attributes are used by all Reports/events.  This has turned
    /// into a catch all for detemining what entities need to be processed.
    /// Probably need to rename this at some point.
    /// </summary>
    public class ReportUser {
        public int PersonID;
        public int CompanyID;
        public int ChangeCount;
        public int MethodID;
        public int SerialNumber;
        public int TESFormID;
        public int TESID;
        public int UserID;
        public int FaxQueueID;
        public int CommunicationLogID;
        public int WebUserID;
        public int Level;

        public string Logon;
        public string PersonName;
        public string CompanyName;
        public string Destination;
        public string Method;
        public string Attachment;
        public string Who;
        public string Priority;
        public string RightFaxEmbeddedCodes;
        public string FaxUserID;
        public string FaxPassword;
        public string Email;
        public string SortType;
        public string IndustryType;
        public string LetterType;
        public string CommunicationLanguage;

        public bool Invalid = false;
        public bool IsLibraryDoc = false;

        public DateTime ScheduledDateTime;

        public string Culture;

        public ReportUser(){}

        public ReportUser(int iPersonID, int iCompanyID) {
            PersonID = iPersonID;
            CompanyID = iCompanyID;
        }

        public ReportUser(int iPersonID, int iCompanyID, int iChangeCount) {
            PersonID = iPersonID;
            CompanyID = iCompanyID;
            ChangeCount = iChangeCount;
        }

        public ReportUser(int iPersonID, int iCompanyID, string szCulture, int iChangeCount)
        {
            PersonID = iPersonID;
            CompanyID = iCompanyID;
            Culture = szCulture;
            ChangeCount = iChangeCount;
        }
    }
}


