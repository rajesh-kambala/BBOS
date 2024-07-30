/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Configuration.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public class Configuration
    {
        static public bool ThrowDevExceptions
        {
            get { return Utilities.GetBoolConfigValue("ThrowDevExceptions", false); }
        }

        static public string WebSiteHome
        {
            get { return Utilities.GetConfigValue("WebSiteHome", "/"); }
        }

        static public bool PasswordOverride
        {
            get { return Utilities.GetBoolConfigValue("PasswordOverride", false); }
        }

        static public string PasswordOverride_Password
        {
            get { return Utilities.GetConfigValue("PasswordOverride_Password"); }
        }

        static public string InvalidLogin
        {
            get { return Utilities.GetConfigValue("LoginInvalid", "Invalid Login"); }
        }

        static public string BBOSWebSiteHome
        {
            get { return Utilities.GetConfigValue("BBOSWebSiteHome", "https://apps.bluebookservices.com/BBOS"); }
        }

        static public int ItemsPerPage
        {
            get { return Utilities.GetIntConfigValue("ScrollItemsPerPage", 10); }
        }
    }
}