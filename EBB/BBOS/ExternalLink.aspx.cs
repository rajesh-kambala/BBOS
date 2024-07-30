/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2007-2021
​
 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.
​
 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.
​
 All Rights Reserved.
​
 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com
​
 ClassName: ExternalLink
 Description:	
​
 Notes:	
​
***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using TSI.BusinessObjects;

namespace PRCo.BBOS.UI.Web {

    /// <summary>
    /// This is a non-visual component that logs that the user clicked a link
    /// to an external web site.
    /// </summary>
    public partial class ExternalLink : PageBase {
    
        protected const string SQL_PREXTERNALLINKAUDITTRAIL_INSERT = "INSERT INTO PRExternalLinkAuditTrail(prelat_WebUserID, prelat_CompanyID, prelat_AssociatedID, prelat_AssociatedType, prelat_URL, prelat_TriggerPage, prelat_CreatedBy, prelat_CreatedDate, prelat_UpdatedBy, prelat_UpdatedDate, prelat_Timestamp) VALUES ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10})";
    
        override protected void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);

            string szURL = null;
            string szID = null;
            string szType = null;

            try
            {
                szURL = cleanInput(GetRequestParameter("BBOSURL").Trim());
                szID = cleanInput(GetRequestParameter("BBOSID"));
                szType = cleanInput(GetRequestParameter("BBOSType"));

                // This deals with the script kiddies.
                if (_oUser == null) {
                    if ((string.IsNullOrEmpty(szType)) ||
                        (szType.Length > 5))
                        return;

                    if (szID.Length != 6)
                        return;

                    if ((!string.IsNullOrEmpty(szURL)) &&
                        (!szURL.ToLower().StartsWith("http://")) &&
                        (!szURL.ToLower().StartsWith("https://")))
                        return;
                }
            }
            catch
            {
                // Spiders, bots, etc hit this page and as a result,
                // generate a lot of bogus exceptions.  If we don't have
                // our parameters, and we don't have a user, we will just
                // eat this exception and return nothing.  We are assuming
                // a bot has invoked this page.
                if (_oUser == null)
                {
                    return;
                }

                throw;
            }

            int associatedID = 0;
            if (!Int32.TryParse(szID, out associatedID))
            {
                // This deals with the script kiddies.
                if (_oUser == null)
                    return;

                throw new ApplicationException("Invalid associated ID specified.");
            }

            string szTriggerPage = GetRequestParameter("TriggerPage", false);
            if ((string.IsNullOrEmpty(szTriggerPage)) &&
                (Request.UrlReferrer != null)) {
                szTriggerPage = Request.UrlReferrer.LocalPath;
            }
            
            try {
                ArrayList oParameters = new ArrayList();
                if (_oUser == null) {
                    oParameters.Add(new ObjectParameter("prelat_WebUserID", null));
                    oParameters.Add(new ObjectParameter("prelat_CompanyID", null));
                } else {
                    oParameters.Add(new ObjectParameter("prelat_WebUserID", _oUser.prwu_WebUserID));
                    oParameters.Add(new ObjectParameter("prelat_CompanyID", _oUser.prwu_BBID));
                }
                oParameters.Add(new ObjectParameter("prelat_AssociatedID", associatedID));
                oParameters.Add(new ObjectParameter("prelat_AssociatedType", szType));
                oParameters.Add(new ObjectParameter("prelat_URL", szURL));
                oParameters.Add(new ObjectParameter("prelat_TriggerPage", szTriggerPage));
                GetObjectMgr().AddAuditTrailParametersForInsert(oParameters, "prelat");

                string szSQL = GetObjectMgr().FormatSQL(SQL_PREXTERNALLINKAUDITTRAIL_INSERT, oParameters);
                GetObjectMgr().ExecuteIdentityInsert("PRExternalLinkAuditTrail", szSQL, oParameters, null);

                if (szType == "PA") {
                    GetObjectMgr().UpdateArticleViewCount(Convert.ToInt32(szID));
                }

            } catch (Exception eX) {
                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Configuration.ThrowDevExceptions) {
                    throw;
                }
            }
            
            if(szURL.ToLower().StartsWith("mailto:"))
            {
                //Defect 6982 - allow mailto: links
            }
            else if ((!szURL.ToLower().StartsWith("http://")) &&
                (!szURL.ToLower().StartsWith("https://"))) {
                szURL = "http://" + szURL;
            }
            
            Response.Redirect(szURL);
        }

        protected string cleanInput(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return value;
            }

            string work = value;
            work = work.Replace("'A=0", string.Empty);

            if (work.StartsWith("92'"))
            {
                work = work.Substring(3, work.Length - 3);
            }

            return work;
        }

        protected override bool IsTermsExempt()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage() {
            return true;
        }

        protected override bool IsAuthorizedForData() {
            return true;
        }
    }
}