/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2009-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: Accelerator
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web.UI;

using PRCo.EBB.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Provides the IE Accelerator functionality to allow a user to 
    /// quickly search BBOS.
    /// </summary>
    public partial class Accelerator : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Page.Header.DataBind();

            string szAction = GetRequestParameter("Action", false);
            string szSelection = GetRequestParameter("Selection", false);
            if (szSelection != null)
            {
                szSelection = szSelection.Trim();
            }

            if (string.IsNullOrEmpty(szAction))
            {
                litMsg.Text = Resources.Global.Error_InvalidActionSpecified;
                return;
            }

            try
            {
                switch (szAction.ToLower())
                {
                    case "search":
                        Search(szSelection);
                        break;
                    case "preview":
                        Preview(szSelection);
                        break;
                    default:
                        litMsg.Text = Resources.Global.Error_InvalidActionSpecified;
                        break;
                }
            }
            catch (System.Threading.ThreadAbortException)
            {
                // Just eat this.  It is thrown due to the due response.redirect issued
                // is other methods.
            }
            catch (Exception eX)
            {
                litMsg.Text = string.Format(Resources.Global.UnexpectedErrorMsg, Utilities.GetConfigValue("EMailSupportAddress"));

                LogError(eX);

                if (Configuration.ThrowDevExceptions)
                {
                    throw;
                }
            }
        }

        /// <summary>
        /// Creates the Search Critiera object and redirects
        /// to the Company Search Results page.
        /// </summary>
        /// <param name="szSelection"></param>
        protected void Search(string szSelection)
        {
            if (_oUser == null)
            {
                string szReturnURL = Server.UrlEncode("Accelerator.aspx?Action=Search&Selection=" + Server.UrlEncode(szSelection));
                Response.Redirect(PageConstants.LOGIN + "?ReturnUrl=" + szReturnURL, false);
                return;
            }

            Session["oWebUserSearchCriteria"] = GetSearchCriteria(_oUser, szSelection);
            Response.Redirect(PageConstants.COMPANY_SEARCH_RESULTS_NEW, false);
        }

        protected const string SQL_PREVIEW = "SELECT * FROM vPRBBOSCompanyList WHERE comp_CompanyID IN ({0})";

        /// <summary>
        /// Builds the preview page by executing the company search.
        /// </summary>
        /// <param name="szSelection"></param>
        protected void Preview(string szSelection)
        {
            if (_oUser == null)
            {
                litMsg.Text = Resources.Global.MustBeLoggedInToUseAccelerator; //"You must be logged into the Blue Book Online Services to utilize this accelerator.<p align=center><a href=Login.aspx target=_blank>Log into the BBOS</a></p>";
                return;
            }

            if (string.IsNullOrEmpty(szSelection))
            {
                litMsg.Text = Resources.Global.UnableToGenerateBBOSPreview; // "Unable to generate BBOS preview.  Please select valid text on the web page.";
                return;
            }

            IPRWebUserSearchCriteria oWebUserSearchCriteria = GetSearchCriteria(_oUser, szSelection);

            ArrayList oParameters;
            string szSQL = string.Format(SQL_PREVIEW, oWebUserSearchCriteria.Criteria.GetSearchSQL(out oParameters));

            int iCount = 0;
            string szCompany = null;
            using (IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null))
            {
                while (oReader.Read())
                {
                    iCount++;

                    if (iCount == 1)
                    {
                        szCompany = Resources.Global.FoundBBNumber + " " + oReader.GetInt32(0).ToString() + " " + oReader.GetString(2) + " " + Resources.Global.located_at + " " + oReader.GetString(3) + ".";
                    }
                }
            }

            switch (iCount)
            {
                case 0:
                    litMsg.Text = Resources.Global.NoMatchingCompaniesFoundFor + " '" + szSelection + "'.";
                    break;
                case 1:
                    litMsg.Text = szCompany;
                    break;
                default:
                    litMsg.Text = Resources.Global.Found + " " + iCount.ToString("###,##0") + " " + Resources.Global.PossibleCompaniesFor + " '" + szSelection + "'.";
                    break;
            }
        }

        /// <summary>
        /// Helper method instantiates and initilizes the Search Critiera
        /// object for both the Search and Preview actions.
        /// </summary>
        /// <param name="oUser"></param>
        /// <param name="szSelection"></param>
        /// <returns></returns>
        protected IPRWebUserSearchCriteria GetSearchCriteria(IPRWebUser oUser, string szSelection)
        {
            IPRWebUserSearchCriteria oWebUserSearchCriteria = (IPRWebUserSearchCriteria)new PRWebUserSearchCriteriaMgr(_oLogger, oUser).CreateObject();
            oWebUserSearchCriteria.prsc_SearchType = PRWebUserSearchCriteria.SEARCH_TYPE_COMPANY;
            oWebUserSearchCriteria.WebUser = oUser;

            CompanySearchCriteria oCompanySearchCritiera = (CompanySearchCriteria)oWebUserSearchCriteria.Criteria;

            oCompanySearchCritiera.IsQuickSearch = true;
            oCompanySearchCritiera.ListingStatus = "L,H,LUV";
            oCompanySearchCritiera.PayReportCount = -1;

            oCompanySearchCritiera.CompanyName = szSelection;
            int iBBID = 0;
            if (Int32.TryParse(szSelection, out iBBID))
            {
                oCompanySearchCritiera.BBID = iBBID;
            }

            return oWebUserSearchCriteria;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        protected override bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool SessionTimeoutForPageEnabled()
        {
            return false;
        }
    }
}
