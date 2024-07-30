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

 ClassName: PageControlBaseCommon.CS
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using PRCo.EBB.BusinessObjects;
using TSI.DataAccess;
using System.Data;
using System.Collections;
using System.Web;
using System.Threading;
using System.Web.UI.WebControls;
using System.Web.UI;
using TSI.Utils;
using System.Globalization;
using System.Text;
using System.Collections.Generic;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides the common functionality needed by the user controls
    /// </summary>
    public class PageControlBaseCommon
    {
        /// <summary>
        /// Prefix used to mark reference data in the cache
        /// </summary>
        public const string REF_DATA_PREFIX = "RefData";
        public const string REF_DATA_NAME = REF_DATA_PREFIX + "_{0}_{1}";

        public static string GetCurrentCulture(IPRWebUser oUser)
        {
            if (oUser != null)
            {
                return oUser.prwu_Culture;
            }

            return Thread.CurrentThread.CurrentCulture.Name.ToLower();
        }

        /// <summary>
        /// Helper method that sets the current thread's culture using
        /// the user object.
        /// </summary>
        /// <param name="oUser"></param>
        public static void SetCulture(IPRWebUser oUser)
        {
            if (oUser == null)
            {
                return;
            }

            Thread.CurrentThread.CurrentUICulture = new CultureInfo(oUser.prwu_Culture);
            Thread.CurrentThread.CurrentCulture = new CultureInfo(oUser.prwu_Culture);

            HttpContext.Current.Response.Cookies[GetCookieID()]["Culture"] = oUser.prwu_Culture;
            HttpContext.Current.Response.Cookies[GetCookieID()]["UICulture"] = oUser.prwu_UICulture;
            HttpContext.Current.Response.Cookies[GetCookieID()]["Email"] = oUser.Email;
            //Response.Cookies[COOKIE_ID]["UserID"] = oUser.UserID;
            HttpContext.Current.Response.Cookies[GetCookieID()].Expires = DateTime.Now.AddYears(1);
        }

        public static string GetCookieID()
        {
            return Utilities.GetConfigValue("CookieID", "PRCo.BBOS");
        }

        public static Control FindControlRecursive(Control control, string id)
        {
            if (control == null) return null;
            //try to find the control at the current level
            Control ctrl = control.FindControl(id);

            if ((ctrl != null) &&
                (ctrl.ID != id))
            {
                return null;
            }

            if (ctrl == null)
            {
                //search the children
                foreach (Control child in control.Controls)
                {
                    ctrl = FindControlRecursive(child, id);

                    if (ctrl != null) break;
                }
            }
            return ctrl;
        }

        const string DEFAULT_CULTURE = "en-us";

        public static string GetCulture(IPRWebUser oUser)
        {
            if (oUser == null)
                return DEFAULT_CULTURE;
            else
                return oUser.prwu_Culture;
        }
    }
}
