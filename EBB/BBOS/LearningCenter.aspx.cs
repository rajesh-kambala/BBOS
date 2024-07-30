/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: LearningCenter.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.IO;
using System.Net;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using PRCo.EBB.BusinessObjects;
using TSI.Arch;
using TSI.BusinessObjects;
using TSI.Utils;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// This call provides links to the various "Publication" pages and also 
    /// allows the user to search across publication types.
    /// <remarks>
    /// There are three (3) different implemenations of keyword searching in this module
    /// (four if you count "none").  Refer to the specific methods contained in this file
    /// for specific on each implemenation.
    /// <list type="bullet">
    /// <item>MSIndexingService</item>
    /// <item>GoogleDesktop</item>
    /// <item>SQLServerSearch</item>
    /// <item>None</item>
    /// </list>
    /// </remarks>
    /// </summary>
    public partial class LearningCenter : PublishingBase
    {
        protected const string INDENT = "&nbsp;&nbsp;&nbsp;&nbsp;";

        protected bool _bClearCriteria;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(Resources.Global.LearningCenter);
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_TOGGLE_FUNCTIONS_FILE));
            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS2_FILE));
            //Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_VALIDATION_FILE));
            EnableFormValidation();

            Advertisement.Logger = _oLogger;
            Advertisement.WebUser = _oUser;
            Advertisement.LoadAds();

            ucPublicationArticles.Logger = _oLogger;
            ucPublicationArticles.WebUser = _oUser;

            if (!IsPostBack)
            {
                txtDateFrom.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());
                txtDateTo.Attributes.Add("placeholder", GetCultureInfo_ShortDatePattern().ToUpper());

                BindLookupValues();
                PopulateForm();
                lblRecordCount.Visible = false;

                if (!string.IsNullOrEmpty(GetRequestParameter("ExecuteLastSearch", false)))
                {
                    Search();
                }
            }

            this.Form.DefaultButton = btnSearch.UniqueID; //Enter key invoked search button
        }

        /// <summary>
        /// Bind reference data to our search controls.
        /// </summary>
        protected void BindLookupValues()
        {
            //BindLookupValues(cbPublications, GetReferenceData("BBOSLCSearchPublicationCode"));
        }

        protected const string SQL_SEARCH =
            @"SELECT    prpbar_PublicationArticleID, 
                        prpbar_PublicationCode, 
                        prpbar_PublicationEditionID, 
                        prpbar_Name, 
                        prpbar_Abstract, 
                        prpbar_PublishDate, 
                        prpbar_FileName, 
                        prpbar_NoChargeExpiration, 
                        prpbar_ProductID, 
                        dbo.ufn_GetCustomCaptionValue('prpbar_PublicationCode', prpbar_PublicationCode, '{3}') As Publication, 
                        dbo.ufn_GetProductPrice(prpbar_ProductID, {4}) AS pric_price, 
                        Size, 
                        prpbar_MediaTypeCode, 
                        NULL Category
                FROM PRPublicationArticle WITH (NOLOCK) 
                     INNER JOIN Custom_Captions ON prpbar_PublicationCode = capt_code AND capt_Family = 'BBOSLCSearchPublicationCode'
                     INNER JOIN (SELECT SUBSTRING(Directory, {0}+1, LEN(Directory)-{0}) + '\' + filename As filename, Size FROM OpenQuery({1}, 'SELECT filename, Directory, Size FROM SCOPE() {2}')) As FileIndex ON filename = prpbar_FileName ";

        protected const string SQL_SEARCH2 =
                @"SELECT 
                    prpbar_PublicationArticleID, 
                    prpbar_PublicationCode, 
                    prpbar_PublicationEditionID, 
                    prpbar_Name, 
                    prpbar_Abstract, 
                    prpbar_PublishDate, 
                    prpbar_FileName, 
                    prpbar_NoChargeExpiration, 
                    prpbar_ProductID, 
                    dbo.ufn_GetCustomCaptionValue('prpbar_PublicationCode', prpbar_PublicationCode, '{0}') As Publication, 
                    dbo.ufn_GetProductPrice(prpbar_ProductID, {1}) AS pric_price, prpbar_MediaTypeCode, 
                    NULL AS Category
                FROM PRPublicationArticle WITH (NOLOCK) 
                    INNER JOIN Custom_Captions ON prpbar_PublicationCode = capt_code AND capt_Family = 'BBOSLCSearchPublicationCode' ";

        protected const string SQL_SEARCH2_WORDPRESS =
                @"SELECT wp.ID AS prpbar_PublicationArticleID,
			        'WPBA' AS prpbar_PublicationCode,
				    NULL AS prpbar_PublicationEditionID, 
				    wp.post_title AS prpbar_Name, 
				    CASE 
                        WHEN post_content LIKE '<p>%' THEN 
                            SUBSTRING(post_content, 0, CHARINDEX('</p>', post_content)+4)
				        ELSE 
					        SUBSTRING(post_content, 0, PATINDEX('%' + CHAR(13) + CHAR(10) + '%', post_content))
				    END AS prpbar_Abstract,
				    wp.post_date AS prpbar_PublishDate, 
				    guid AS prpbar_FileName, 
				    NULL AS prpbar_NoChargeExpiration, 
				    NULL AS prpbar_ProductID, 
				    wpd.BlueprintEdition AS Publication, 
    				NULL AS pric_price, 
				    NULL AS prpbar_MediaTypeCode,
                    Category
                  FROM {1} wp WITH (NOLOCK)
		            INNER JOIN {2} meta ON post_id = wp.ID
			        CROSS APPLY CRM.dbo.ufn_GetWordPressPostDetails4(wp.ID,'{0}') wpd";

        protected const string SQL_FILE_WHERE = @"WHERE FREETEXT(Contents, ''{0}'')";

        /// <summary>
        /// Executes the file search by querying both the database
        /// and the Index Services Catalog.
        /// </summary>
        protected void Search()
        {
            ArrayList oParameters = new ArrayList();
            StringBuilder sbSQL = new StringBuilder();
            StringBuilder sbSQLWordPress = new StringBuilder();

            string szWhereClause = " WHERE prpbar_PublicationCode NOT IN ('BP', 'BPS') AND (prpbar_PublishDate <= GETDATE() OR prpbar_PublishDate IS NULL) ";

            if (_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                szWhereClause += " AND prpbar_IndustryTypeCode LIKE '%,L,%' ";
            else
                szWhereClause += " AND prpbar_IndustryTypeCode NOT LIKE '%,L,%' ";


            string szWhereClauseWordPress = @" WHERE wp.post_status IN ('publish')
		                                            AND meta_key = 'blueprintEdition'";

            // We have issues with linking the MS Indexing Service Catalog to SQL Server when the
            // files being indexed are on a remote server.  To get around this for now, we have two
            // ways to search files.
            if (Utilities.GetBoolConfigValue("LearningCenterLinkedToSQLServer", false))
            {
                string szFileSearch = string.Empty;
                string szFileRoot = Utilities.GetConfigValue("LearningCenterIndexPath");

                if (!string.IsNullOrEmpty(txtKeyWords.Text.Trim()))
                {
                    szFileSearch = string.Format(SQL_FILE_WHERE, txtKeyWords.Text.Trim());
                }

                object[] oArgs = {szFileRoot.Length,
                                  Utilities.GetConfigValue("LearningCenterIndexCatalog", "BBOSLearningCenter"),
                                  szFileSearch,
                                  _oUser.prwu_Culture,
                                  PRICING_LIST_ONLINE};
                sbSQL.Append(string.Format(SQL_SEARCH, oArgs));

            }
            else
            {
                object[] oArgs = {_oUser.prwu_Culture,
                                  PRICING_LIST_ONLINE};
                sbSQL.Append(string.Format(SQL_SEARCH2, oArgs));

                if(_oUser.prwu_IndustryType == "L")
                    sbSQLWordPress.Append(string.Format(SQL_SEARCH2_WORDPRESS, _oUser.prwu_IndustryType, Configuration.WordPressLumber_posts, Configuration.WordPressLumber_postmeta));
                else
                    sbSQLWordPress.Append(string.Format(SQL_SEARCH2_WORDPRESS, _oUser.prwu_IndustryType, Configuration.WordPressProduce_posts, Configuration.WordPressProduce_postmeta));


                if (!string.IsNullOrEmpty(txtKeyWords.Text.Trim()))
                {
                    string szFileList = GetFileList(txtKeyWords.Text.Trim());

                    // If we have keywords, and no files are found, we
                    // need to make sure no results are returned.  We still need to
                    // execute the query because the GridView is bound to it.
                    if (string.IsNullOrEmpty(szFileList))
                        szWhereClause += "AND 1=0 ";
                    else
                        szWhereClause += "AND prpbar_FileName IN (" + szFileList + ") ";

                    szWhereClauseWordPress += string.Format(" AND (FREETEXT(wp.post_content, '{0}') OR FREETEXT(wp.post_title, '{0}'))", txtKeyWords.Text.Trim());
                }
            }

            if (!string.IsNullOrEmpty(txtDateFrom.Text))
            {
                szWhereClause += "AND prpbar_PublishDate >= @FromDate ";
                oParameters.Add(new ObjectParameter("FromDate", UIUtils.GetDateTime(txtDateFrom.Text, GetCultureInfo(_oUser))));
                szWhereClauseWordPress += " AND wp.post_date >= @FromDate ";
            }

            if (!string.IsNullOrEmpty(txtDateTo.Text))
            {
                szWhereClause += "AND prpbar_PublishDate <= @ToDate ";
                oParameters.Add(new ObjectParameter("ToDate", UIUtils.GetDateTime(txtDateTo.Text, GetCultureInfo(_oUser)).AddDays(1)));
                szWhereClauseWordPress += " AND wp.post_date <= @ToDate ";
            }

            sbSQL.Append(szWhereClause);
            sbSQLWordPress.Append(szWhereClauseWordPress);

            if (_oUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                sbSQL.Append(" UNION ");
                sbSQL.Append(sbSQLWordPress.ToString());
            }

            string szUnionSorted = string.Format("SELECT * FROM ({0}) t ORDER BY (CASE WHEN prpbar_PublishDate IS NULL THEN 1 ELSE 0 END) DESC, prpbar_PublishDate DESC",
                                    sbSQL.ToString());

            DisplayDebuggingData(szUnionSorted, oParameters); 

            DataSet dsArticles = GetDBAccess().ExecuteSelect(szUnionSorted, oParameters);  
            ucPublicationArticles.dsArticles = dsArticles;
            rowArticles.Visible = true;

            // Display the number of matching records found
            lblRecordCount.Visible = true;
            lblRecordCount.Text = string.Format(Resources.Global.RecordCountFoundMsg, dsArticles.Tables[0].Rows.Count, Resources.Global.Articles);

            // Store the criteria data in the session
            // for later searches in this session.
            Session["txtKeyWords"] = txtKeyWords.Text.Trim();
            Session["txtDateTo"] = txtDateTo.Text;
            Session["txtDateFrom"] = txtDateFrom.Text;

            try
            {
                IDbTransaction oTran = GetObjectMgr().BeginTransaction();
                GetObjectMgr().InsertSearchAuditTrail("LC", "LC", txtKeyWords.Text.Trim(), dsArticles.Tables[0].Rows.Count, oTran);
                GetObjectMgr().Commit();
            }
            catch (Exception eX)
            {
                GetObjectMgr().Rollback();

                // There's nothing the end user can do about this so
                // just log it and keep moving.
                LogError(eX);

                if (Utilities.GetBoolConfigValue("ThrowDevExceptions", false))
                {
                    throw;
                }
            }
        }

        protected void btnSearchOnClick(object sender, EventArgs e)
        {
            // Make sure we don't use anything from a previous 
            // search
            Session["txtKeyWords"] = null;
            Session["txtDateTo"] = null;
            Session["txtDateFrom"] = null;

            Search();
        }

        /// <summary>
        /// Populates the critiera form with data from the session.
        /// </summary>
        protected void PopulateForm()
        {
            if (Utilities.GetConfigValue("FileIndexingEngine", string.Empty) == "None")
            {
                pnlKeyWords.Visible = false;
            }

            //Defect 4467 don't remember search criteria
            txtKeyWords.Text = string.Empty; // (string)Session["txtKeyWords"];
            txtDateTo.Text = string.Empty; // (string)Session["txtDateTo"];
            txtDateFrom.Text = string.Empty; // (string)Session["txtDateFrom"];
        }

        /// <summary>
        /// Clears the search criteria including any data stored in
        /// the session.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnClearOnClick(object sender, EventArgs e)
        {
            Session["txtKeyWords"] = null;
            Session["txtDateTo"] = null;
            Session["txtDateFrom"] = null;

            _bClearCriteria = true;
            lblRecordCount.Visible = false;

            lblRecordCount.Text = string.Empty;
            rowArticles.Visible = false;
            //gvSearchResults2.Visible = false;

            PopulateForm();
        }

        /// <summary>
        /// Helper method that returns the nonbreaking white space
        /// for the appropriate level of indentation.
        /// </summary>
        /// <param name="iLevel"></param>
        /// <returns></returns>
        protected string GetIndent(int iLevel)
        {
            string szIndent = string.Empty;
            for (int i = 0; i < iLevel - 1; i++)
            {
                szIndent += INDENT;
            }
            return szIndent;
        }

        /// <summary>
        /// Helper method that helps with bi-directional sorting
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GridView_Sorting(Object sender, GridViewSortEventArgs e)
        {
            SetSortingAttributes((GridView)sender, e);
            Search();
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
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="szSQL"></param>
        /// <param name="oParameters"></param>
        protected void DisplayDebuggingData(string szSQL, IList oParameters)
        {
            if (!Utilities.GetBoolConfigValue("DisplayLearningCenterSearchDebugging", false))
            {
                return;
            }

            tblDebug.Visible = true;

            lblSQL.Text = szSQL;

            // Spin through our SQL parms adding 
            // them to our format array 
            StringBuilder szParameters = new StringBuilder();
            foreach (ObjectParameter oParameter in oParameters)
            {
                string szName = oParameter.Name.ToString();
                string szValue = oParameter.Value.ToString();

                szParameters.Append(szName);
                szParameters.Append("=");
                szParameters.Append(szValue);
                szParameters.Append("<br>");
            }

            lblParameters.Text = szParameters.ToString();
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        /// <summary>
        /// This method queries the MS Indexing Service and returns a delimited
        /// list of file names for use in an IN clause.
        /// </summary>
        /// <param name="szKeywords"></param>
        /// <returns></returns>
        protected string GetFileList(string szKeywords)
        {
            if (string.IsNullOrEmpty(szKeywords))
            {
                return string.Empty;
            }

            string szFileSearchType = Utilities.GetConfigValue("FileIndexingEngine", "None");
            switch (szFileSearchType)
            {
                case "MSIndexingService":
                    return MSIndexerSearch(szKeywords);
                case "GoogleDesktop":
                    return GoogleDesktopSearch(szKeywords);
                case "SQLServerSearch":
                    return SQLServerSearch(szKeywords);
                case "None":
                    return string.Empty;
                default:
                    throw new ApplicationUnexpectedException("Invalid FileIndexingEngine config value specified: " + szFileSearchType);
            }
        }

        protected const string MS_INDEXING_SERVICE_CONNECTION = "Provider=MSIDXS; Data Source=\"{0}\"";
        protected const string MS_INDEXING_SERVICE_QUERY = "SELECT filename, Directory, Size FROM SCOPE() WHERE FREETEXT(Contents, '{0}')";

        /// <summary>
        /// Uses the MS Indexing Service to search the contents of
        /// the files.
        /// <remarks>
        /// Requires an MS Indexing Service catalog to be created on 
        /// the LearningCenter box.  Then we linked the newly created catalog
        /// to SQL Server.  Finally, we need to install the free PDF IFilter
        /// add-on for MS Indexing Service in order for the indexer to properly
        /// handle PDF files.
        /// <list type="Number">
        /// <listheader>Install Adobe PDF IFilter for MS Indexing Service</listheader>
        /// <item>Obtain the Adobe component from VSS or http://www.adobe.com/support/downloads/detail.jsp?ftpID=2611 </item>
        /// <item>Simply run the installer and following the instructions.</item>
        /// </list>
        /// <list type="number">
        /// <listheader>Configure MS Indexing Service</listheader>
        /// <item>Create a new directory to hold the custom IS catalog.</item>
        /// <item>Right-click on "My Computer" and select "Manage".</item>
        /// <item>Expandes "Services and Applications"</item>
        /// <item>Right-click on "Indexing Service" and select "New", then "Catalog"</item>
        /// <item>Give the catalog a name (i.e. BBOSLearningCenter) and point it to the directory created in the first step.</item>
        /// <item>Click OK</item>
        /// <item>Right click on the "Directories" under the newly created catalog and select "New", then "Directory".</item>
        /// <item>Select the "Learning Center" directory.  Click OK.</item>
        /// <item>Restart the Indexing Service.</item>
        /// </list>
        /// </remarks>
        /// </summary>
        /// <param name="szKeywords"></param>
        /// <returns></returns>
        protected string MSIndexerSearch(string szKeywords)
        {
            StringBuilder sbFileList = new StringBuilder();

            string szConnectionString = string.Format(MS_INDEXING_SERVICE_CONNECTION, Utilities.GetConfigValue("LearningCenterIndexCatalog", "BBOSLearningCenter"));
            string szQuery = string.Format(MS_INDEXING_SERVICE_QUERY, szKeywords);

            System.Data.OleDb.OleDbConnection oISConn = new System.Data.OleDb.OleDbConnection(szConnectionString);
            System.Data.OleDb.OleDbCommand oISCommand = oISConn.CreateCommand();
            oISCommand.CommandText = szQuery;
            System.Data.OleDb.OleDbDataReader oReader = null;

            string szFileRoot = Utilities.GetConfigValue("LearningCenterIndexPath");

            try
            {
                oISConn.Open();
                oReader = oISCommand.ExecuteReader(CommandBehavior.CloseConnection);

                while (oReader.Read())
                {
                    string szFullPath = oReader.GetString(1) + @"\" + oReader.GetString(0);
                    string szRelativePath = szFullPath.Substring(szFileRoot.Length);

                    if (sbFileList.Length > 0)
                    {
                        sbFileList.Append(",");
                    }
                    sbFileList.Append(GetDBAccess().PrepareValueForSQL(szRelativePath));
                }

                return sbFileList.ToString();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        private const string GOOGLE_SEARCH_STRING = "{0}{1}&has={1}+&format=xml&adv=1&type=cat_files&in={2}&under=on&num=9999999";

        /// <summary>
        /// Uses the Google Desktop Search engine.  Instead of using the API
        /// (time contraints during development), we are instead using the web 
        /// interface.  Each machine will have it's own key which needs to be 
        /// ascertained.
        /// <remarks>
        /// This functionality requires that GoogleDesktop is installed and some user is 
        /// actively logged in.  The GDS Listener is only active for logged in users (any user
        /// will do in our case).  There is a hidden api key that contains the default URL to
        /// use.  The URL is specific to the machine as each machine has a unique Token.  Also,
        /// be sure to configure GDS to only index files and then exclude all directories other
        /// than the learning center.
        /// </remarks>
        /// </summary>
        /// <param name="szKeywords"></param>
        /// <returns></returns>
        protected string GoogleDesktopSearch(string szKeywords)
        {
            StringBuilder sbFileList = new StringBuilder();
            string szFileRoot = Utilities.GetConfigValue("LearningCenterIndexPath");

            WebClient wcGDS = new WebClient();

            string szQuery = string.Format(GOOGLE_SEARCH_STRING,
                                           GetGoogleSearchURL(),
                                           szKeywords.Replace(' ', '+'),
                                           szFileRoot);

            LogMessage(szQuery);

            string xmlResults = null;
            using (Stream stream = wcGDS.OpenRead(szQuery))
            {
                StreamReader reader = new StreamReader(stream);
                xmlResults = reader.ReadToEnd();
            }

            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.LoadXml(xmlResults);

            XmlNodeList xmlURLNodes = xmlDocument.SelectNodes("/results/result/url");
            foreach (XmlNode xmlURLNode in xmlURLNodes)
            {
                if (sbFileList.Length > 0)
                {
                    sbFileList.Append(",");
                }

                string szRelativePath = xmlURLNode.InnerText.Substring(szFileRoot.Length);
                sbFileList.Append(GetDBAccess().PrepareValueForSQL(szRelativePath));
            }

            return sbFileList.ToString();
        }

        private const string GOOGLE_REG_KEY = "Software\\Google\\Google Desktop\\API";
        private const string GOOGLE_REG_VALUE = "search_url";
        /// <summary>
        /// We need to use the search query hidden in the registry because it
        /// contains a key that allows us to invoke it.
        /// </summary>
        /// <returns></returns>
        protected string GetGoogleSearchURL()
        {
            return Utilities.GetConfigValue("GoogleDesktopSearchURL");

            // We had all kinds of trouble getting the default ASP.NET user to be able to access
            // the hidden registry key.  So we just moved it to the config file.
            //using (RegistryKey regGoogleKey = Registry.CurrentUser.OpenSubKey(GOOGLE_REG_KEY)) {
            //    return Convert.ToString(regGoogleKey.GetValue(GOOGLE_REG_VALUE));
            //}
        }

        protected const string SQL_KEYWORD_SEARCH =
                @"SELECT prpbar_FileName 
                  FROM PRPublicationArticle WITH (NOLOCK)
                 WHERE 
                    prpbar_PublicationCode NOT IN ('BP', 'BPS','KYC')
                    AND (FREETEXT (prpbar_Name, '{0}') 
                    OR FREETEXT (prpbar_Abstract, '{0}') 
                    OR FREETEXT (prpbar_FileName, '{0}') 
                    OR FREETEXT (prpbar_Body, '{0}')) 
                AND prpbar_FileName IS NOT NULL;";

        /// <summary>
        /// Uses the SQL Server full-text searching features.  A full-text
        /// index must exist on the PRPublicationArticle table for the colums
        /// referenced above.
        /// <remarks>
        /// This search routine makes use of the full-text capabilities of SQL Server.
        /// The index and catalog are created by default in the indexes.sql file.
        /// </remarks>
        /// </summary>
        /// <param name="szKeywords"></param>
        /// <returns></returns>
        protected string SQLServerSearch(string szKeywords)
        {
            StringBuilder sbFileList = new StringBuilder();
            string szSQL = string.Format(SQL_KEYWORD_SEARCH, szKeywords.Replace("'", "''"));

            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            try
            {
                while (oReader.Read())
                {
                    if (sbFileList.Length > 0)
                    {
                        sbFileList.Append(",");
                    }

                    sbFileList.Append(GetDBAccess().PrepareValueForSQL(oReader.GetString(0)));
                }

                return sbFileList.ToString();
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }
    }
}
