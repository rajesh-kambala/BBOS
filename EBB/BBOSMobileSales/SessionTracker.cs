/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SessionTracker.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;

namespace PRCo.BBOS.UI.Web
{

    /// <summary>
    /// Helper class that tracks who is currently logged in.
    /// </summary>
    public class SessionTracker {

        private int userID;
        private string email;
        private string guid;
        private string sessionID;
        private string browserUserAgent;
        private string ipAddress;
        private DateTime lastRequest;
        private DateTime firstAccess;
        private DateTime expiration;
        private int pageCount;
        private int violationCount;

        public int UserID
        {
            get { return userID; }
            set { userID = value; }
        }
        public string Email
        {
            get { return email; }
            set { email = value; }
        }
        public string GUID
        {
            get { return guid; }
            set { guid = value; }
        }
        public string SessionID
        {
            get { return sessionID; }
            set { sessionID = value; }
        }

        public string BrowserUserAgent {
            get { return browserUserAgent; }
            set { browserUserAgent = value; }
        }

        public string IPAddress {
            get { return ipAddress; }
            set { ipAddress = value; }
        }

        public DateTime LastRequest
        {
            get { return lastRequest; }
            set { lastRequest = value; }
        }
        public DateTime FirstAccess
        {
            get { return firstAccess; }
            set { firstAccess = value; }
        }
        public DateTime Expiration
        {
            get { return expiration; }
            set { expiration = value; }
        }
        public int PageCount
        {
            get { return pageCount; }
            set { pageCount = value; }
        }

        public int ViolationCount {
            get { return violationCount; }
            set { violationCount = value; }
        }
    }
}