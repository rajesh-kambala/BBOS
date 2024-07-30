/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: RecentViews.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;
using TSI.BusinessObjects;
using TSI.DataAccess;
using TSI.Utils;
using PRCo.EBB.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Displays the last number of companies and persons viewed by the
    /// current user.
    /// </summary>
    public partial class RecentViews : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            string szTitle = Resources.Global.RecentViews;
            SetPageTitle(szTitle);
            ((BBOS)Master).HTMLTitle = GetApplicationNameAbbr() + " " + szTitle;

            if (!IsPostBack)
            {
                SetSortField(gvRecentCompanies, "ndx");
                SetSortField(gvRecentPersons, "ndx");
                PopulateForm();
            }

            EnableFormValidation();

            //Set User control properties
        }

        protected void PopulateForm()
        {
            PopulateRecentCompanies();

            if (_oUser.IsLimitado)
                pnlRecentPersons.Visible = false;
            else
                PopulateRecentPersons();
        }

        protected const string SQL_RECENT_COMPANIES =
            @"SELECT vPRBBOSCompanyList.*, 
                     dbo.ufn_HasNote({1}, {2}, comp_CompanyID, 'C') As HasNote, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, {5}) As IndustryType, 
                     dbo.ufn_GetCustomCaptionValue('comp_PRType_BBOS', comp_PRType, {5}) As CompanyType,
                     dbo.ufn_HasNewClaimActivity(comp_PRHQID, {3}) as HasNewClaimActivity, 
                     dbo.ufn_HasMeritoriousClaim(comp_PRHQID, {4}) as HasMeritoriousClaim,
                     dbo.ufn_HasCertification(comp_PRHQID) as HasCertification,
                     dbo.ufn_HasCertification_Organic(comp_PRHQID) as HasCertification_Organic,
                     dbo.ufn_HasCertification_FoodSafety(comp_PRHQID) as HasCertification_FoodSafety
                FROM dbo.ufn_GetRecentCompanies({1}, {0})  
                    INNER JOIN vPRBBOSCompanyList ON CompanyID = comp_CompanyID ";

        protected void PopulateRecentCompanies()
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("CompanyLimit", Utilities.GetIntConfigValue("RecentViewsTopNCompanies", 10)));
            oParameters.Add(new ObjectParameter("WebUserID", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("WebUserHQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("NewClaimThresholdDate", DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")));
            oParameters.Add(new ObjectParameter("MeritoriousClaimThesholdDate", DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss")));
            oParameters.Add(new ObjectParameter("Culture", _oUser.prwu_Culture));

            string szSQL = SQL_RECENT_COMPANIES;
            if (_oUser.IsLimitado)
                szSQL = szSQL.Replace("ufn_GetRecentCompanies", "ufn_GetRecentCompanies_Limitado");

            szSQL = GetObjectMgr().FormatSQL(szSQL, oParameters);

            szSQL += " WHERE " + GetObjectMgr().GetLocalSourceCondition();
            szSQL += " AND " + GetObjectMgr().GetIntlTradeAssociationCondition();
            szSQL += GetOrderByClause(gvRecentCompanies);

            //((EmptyGridView)gvRecentCompanies).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.RecentlyViewedCompanies);
            gvRecentCompanies.ShowHeaderWhenEmpty = true;
            gvRecentCompanies.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.RecentlyViewedCompanies);

            gvRecentCompanies.DataSource = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            gvRecentCompanies.DataBind();
            EnableBootstrapFormatting(gvRecentCompanies);

            fsRecentCompaniesLegend.Text = string.Format(Resources.Global.RevewViewsCompanyMsg, gvRecentCompanies.Rows.Count);
        }

        protected const string SQL_RECENT_PERSON = "SELECT pers_PersonID, RTRIM(pers_FirstName) As pers_FirstName, RTRIM(pers_LastName) as pers_LastName, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, NULL, pers_Suffix) as PersonName, dbo.ufn_HasNote({1}, {2}, pers_PersonID, 'P') As HasNote, ndx " +
                                                     "FROM dbo.ufn_GetRecentPersons({1}, {0}) " +
                                                          "INNER JOIN Person WITH (NOLOCK) ON PersonID = pers_personID ";
        protected void PopulateRecentPersons()
        {
            string szSQL = string.Format(SQL_RECENT_PERSON,
                                         Utilities.GetIntConfigValue("RecentViewsTopNPersons", 10),
                                         _oUser.prwu_WebUserID,
                                         _oUser.prwu_HQID);
            szSQL += GetOrderByClause(gvRecentPersons);

            //((EmptyGridView)gvRecentPersons).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.RecentlyViewedPersons);
            gvRecentPersons.ShowHeaderWhenEmpty = true;
            gvRecentPersons.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.RecentlyViewedPersons);

            gvRecentPersons.DataSource = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            gvRecentPersons.DataBind();
            EnableBootstrapFormatting(gvRecentPersons);

            fsRecentPersonsLegend.Text = string.Format(Resources.Global.RevewViewsPersonMsg, gvRecentPersons.Rows.Count);
        }

        //protected string GetPersonCompanies(int iPersonID)
        //{
        //    StringBuilder sbCell;
        //    IDBAccess oDataAccess;
        //    IDataReader oReader;
        //    GetPersonCompanies_Data(iPersonID, out sbCell, out oDataAccess, out oReader);
        //    try
        //    {
        //        while (oReader.Read())
        //        {
        //            object[] oArgs = {oDataAccess.GetInt32(oReader, "comp_CompanyID"),
        //                              GetCompanyDataForCell(oDataAccess.GetInt32(oReader, "comp_CompanyID"),
        //                                                    oDataAccess.GetString(oReader, "comp_PRBookTradestyle"),
        //                                                    oDataAccess.GetString(oReader, "comp_PRLegalName"),
        //                                                    UIUtils.GetBool(oDataAccess.GetString(oReader, "HasNote")),
        //                                                    oDataAccess.GetDateTime(oReader, "comp_PRLastPublishedCSDate"),
        //                                                    oDataAccess.GetString(oReader, "comp_PRListingStatus"),
        //                                                    GetObjectMgr().TranslateFromCRMBool(oReader["HasNewClaimActivity"]),
        //                                                    GetObjectMgr().TranslateFromCRMBool(oReader["HasMeritoriousClaim"])),
        //                               GetCompanyNameForCell(oDataAccess.GetInt32(oReader, "comp_CompanyID"),
        //                                                    oDataAccess.GetString(oReader, "comp_PRBookTradestyle"),
        //                                                    oDataAccess.GetString(oReader, "comp_PRLegalName")),
        //                              oDataAccess.GetString(oReader, "CityStateCountryShort")};

        //            sbCell.Append(string.Format(PERSON_COMPANIES_CELL, oArgs));
        //        }
        //    }
        //    finally
        //    {
        //        if (oReader != null)
        //        {
        //            oReader.Close();
        //        }
        //    }

        //    sbCell.Append("</table>");
        //    return sbCell.ToString();
        //}

        protected string GetPersonCompanies_BBNum(int iPersonID)
        {
            StringBuilder sbCell;
            IDBAccess oDataAccess;
            IDataReader oReader;
            GetPersonCompanies_Data(iPersonID, out sbCell, out oDataAccess, out oReader);
            try
            {
                while (oReader.Read())
                {
                    object[] oArgs = {oDataAccess.GetInt32(oReader, "comp_CompanyID")};

                    sbCell.Append(string.Format(BOOTSTRAP_ROW_TEMPLATE, "text-left", oArgs[0]));
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            sbCell.Append("</table>");
            return sbCell.ToString();
        }

        protected string GetPersonCompanies_Icons(int iPersonID)
        {
            StringBuilder sbCell;
            IDBAccess oDataAccess;
            IDataReader oReader;
            GetPersonCompanies_Data(iPersonID, out sbCell, out oDataAccess, out oReader);
            try
            {
                while (oReader.Read())
                {
                    object[] oArgs = {  GetCompanyDataForCell(oDataAccess.GetInt32(oReader, "comp_CompanyID"),
                                            oDataAccess.GetString(oReader, "comp_PRBookTradestyle"),
                                            oDataAccess.GetString(oReader, "comp_PRLegalName"),
                                            UIUtils.GetBool(oDataAccess.GetString(oReader, "HasNote")),
                                            oDataAccess.GetDateTime(oReader, "comp_PRLastPublishedCSDate"),
                                            oDataAccess.GetString(oReader, "comp_PRListingStatus"),
                                            true,
                                            GetObjectMgr().TranslateFromCRMBool(oReader["HasNewClaimActivity"]),
                                            GetObjectMgr().TranslateFromCRMBool(oReader["HasMeritoriousClaim"]),
                                            GetObjectMgr().TranslateFromCRMBool(oReader["HasCertification"]),
                                            GetObjectMgr().TranslateFromCRMBool(oReader["HasCertification_Organic"]),
                                            GetObjectMgr().TranslateFromCRMBool(oReader["HasCertification_FoodSafety"]),
                                            true,
                                            bIncludeCompanyNameLink:false) };

                    sbCell.Append(string.Format(BOOTSTRAP_ROW_TEMPLATE, "text-right", oArgs[0]));
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            sbCell.Append("</table>");
            return sbCell.ToString();
        }

        protected string GetPersonCompanies_CompanyName(int iPersonID)
        {
            StringBuilder sbCell;
            IDBAccess oDataAccess;
            IDataReader oReader;
            GetPersonCompanies_Data(iPersonID, out sbCell, out oDataAccess, out oReader);
            try
            {
                while (oReader.Read())
                {
                    object[] oArgs = {  GetCompanyNameForCell(oDataAccess.GetInt32(oReader, "comp_CompanyID"),
                                            oDataAccess.GetString(oReader, "comp_PRBookTradestyle"),
                                            oDataAccess.GetString(oReader, "comp_PRLegalName")) };

                    sbCell.Append(string.Format(BOOTSTRAP_ROW_TEMPLATE, "text-left", oArgs[0]));
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            sbCell.Append("</table>");
            return sbCell.ToString();
        }

        protected string GetPersonCompanies_Location(int iPersonID)
        {
            StringBuilder sbCell;
            IDBAccess oDataAccess;
            IDataReader oReader;
            GetPersonCompanies_Data(iPersonID, out sbCell, out oDataAccess, out oReader);
            try
            {
                while (oReader.Read())
                {
                    object[] oArgs = { oDataAccess.GetString(oReader, "CityStateCountryShort") };
                    sbCell.Append(string.Format(BOOTSTRAP_ROW_TEMPLATE, "text-left", oArgs[0]));
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            sbCell.Append("</table>");
            return sbCell.ToString();
        }

        private void GetPersonCompanies_Data(int iPersonID, out StringBuilder sbCell, out IDBAccess oDataAccess, out IDataReader oReader)
        {
            object[] args = {_oUser.prwu_WebUserID,
                                     _oUser.prwu_HQID,
                                     iPersonID,
                                     DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                                     DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                                     GetObjectMgr().GetLocalSourceCondition(),
                                     GetObjectMgr().GetIntlTradeAssociationCondition()};

            string szSQL = string.Format(SQL_GET_PERSON_COMPANIES, args);

            sbCell = new StringBuilder("<table style='border:0px;'>");
            oDataAccess = DBAccessFactory.getDBAccessProvider();
            oDataAccess.Logger = _oLogger;
            oReader = oDataAccess.ExecuteReader(szSQL, null, CommandBehavior.CloseConnection, null);
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            PopulateForm();
        }

        /// <summary>
        /// Adds the sort indicator to the appropriate column
        /// header.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            SetSortIndicator((GridView)sender, e);

            if (((GridView)sender).ID == "gvRecentCompanies")
                DisplayLocalSource(e);
        }

        /// <summary>
        /// Only members level 4 or greater can access
        /// this page.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForPage()
        {
            return _oUser.IsLimitado || _oUser.HasPrivilege(SecurityMgr.Privilege.RecentViewsPage).HasPrivilege;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

    }
}
