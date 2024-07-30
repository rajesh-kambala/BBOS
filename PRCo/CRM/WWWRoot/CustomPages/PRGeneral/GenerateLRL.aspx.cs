/***********************************************************************
 Copyright Produce Reporter Company 2009-2014

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: GeneraetLRL.aspx
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI.WebControls;

using ICSharpCode.SharpZipLib.Zip;

namespace PRCo.BBS.CRM
{
    /// <summary>
    /// This is almost a direct port of old Paradox code to generate the Listing Report
    /// Letters.  The short-term goal was to implement in CRM with a longer term goal to revisit
    /// this functionality.  Since the code has a short lifespan, not much time was spent 
    /// optimizing/structuring it.
    /// </summary>
    public partial class GenerateLRL : PageBase
    {
        protected string sSID = string.Empty;
        protected int _iUserID;

        private bool _bIsTest = false;

        private const string STANDARD_INDENT = "     ";
        private const string BRANCH_INDENT = "     ";
        private const string NEWLINE = "\r\n";
        private const int PAGE_LENGTH = 58;

        private string _fileDate = DateTime.Now.ToString("MM/dd/yyyy");

        private string _LRLBaseCompanyDataFile, _LRLListingDataFile, _LRLPersonDataFile, _LRLControlFile;
        private string _LRLCompanyProductFile, _LRLProductMasterFile;

        private DateTime _dtNow;

        private int _MailingPieceCount = 0;
        private int _LocationCount = 0;
        private int _PeopleCount = 0;
        private int _CompanyProductCount = 0;
        private int _ProcutMasterCount = 0;

        override protected void Page_Load(object sender, EventArgs e)
        {
            Server.ScriptTimeout = 60 * 180;
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {

                DateTime dtToday = DateTime.Today;
                if (GetConfigValue("LRLToday", null) != null)
                {
                    dtToday = Convert.ToDateTime(GetConfigValue("LRLToday"));
                }

                // When first loading the screen, let's try to figure out
                // a default batch type and date.
                string szLetterType = null;

                DateTime dtDueDate = DateTime.MinValue;
                if (GetConfigValue("LRLDueDate", null) != null)
                {
                    dtDueDate = Convert.ToDateTime(GetConfigValue("LRLDueDate"));
                    szLetterType = GetConfigValue("LRLLetterType");
                }
                else
                {
                    // The summer book close is in August
                    if ((dtToday.Month >= 3) &&
                        (dtToday.Month < 9))
                    {
                        szLetterType = "Summer";
                        dtDueDate = new DateTime(dtToday.Year, 8, 1);

                    }
                    // The winter book close is in February
                    else
                    {
                        szLetterType = "Winter";

                        if (DateTime.Today.Month <= 2)
                        {
                            dtDueDate = new DateTime(dtToday.Year, 2, 1);
                        }
                        else
                        {
                            dtDueDate = new DateTime(dtToday.Year + 1, 2, 1);
                        }
                    }

                    // Find the first Monday of our month.
                    while (dtDueDate.DayOfWeek != DayOfWeek.Monday)
                    {
                        dtDueDate = dtDueDate.AddDays(1);
                    }
                }

                txtDeadlineDate.Text = dtDueDate.ToString("MM/dd/yyyy");
                litBatch.Text = szLetterType + " " + dtDueDate.ToString("yyyy");
                
                hidUserID.Text = Request["user_userid"];
                hidSID.Text = Request.Params.Get("SID");
                BindLookupValues();

                ddlLetterType.SelectedValue = szLetterType;

                PopulateForm();

                if (GetConfigValue("LRLConnectionListDate", null) != null)
                {
                    txtCLDate.Text = GetConfigValue("LRLConnectionListDate");
                }
            }

            _iUserID = Int32.Parse(hidUserID.Text);
            sSID = hidSID.Text;

            imgbtnGenerate.ImageUrl = "/" + _szAppName + "/img/Buttons/continue.gif";
            //hlViewVerbiageImg.ImageUrl = "/" + _szAppName + "/img/Buttons/continue.gif";
            //hlViewVerbiageImg.NavigateUrl = "PRLRLVerbiage.asp?SID=" + sSID;
            //hlViewVerbiage.NavigateUrl = "PRLRLVerbiage.asp?SID=" + sSID;

            hlViewBatchesImg.ImageUrl = "/" + _szAppName + "/img/Buttons/continue.gif";
            hlViewBatchesImg.NavigateUrl = "PRLRLBatchListing.asp?SID=" + sSID;
            hlViewBatches.NavigateUrl = "PRLRLBatchListing.asp?SID=" + sSID;

            btnGenerate.OnClientClick = "return GenerateLRL();";
        }

        /// <summary>
        /// Bind custom_captions to the various list controls
        /// </summary>
        private void BindLookupValues()
        {
            BindLookupValue(GetDBConnnection(), ddlLetterType, "LRLLetterType");
            BindLookupValue(GetDBConnnection(), cblIndustryType, "comp_PRIndustryType");

            
            BindCountry(cblCountry);
            cblCountry.SelectedValue = "1";

            BindState(null, null);
            BindCity(null, null);
        }

        private const string SQL_SELECT_COUNTRY = 
            "SELECT prcn_CountryID, prcn_Country FROM PRCountry WITH(NOLOCK) WHERE prcn_CountryID > 0  ORDER BY prcn_Country";
        private const string SQL_SELECT_STATE = 
            "SELECT prst_StateID, prst_State FROM PRState WITH(NOLOCK) WHERE prst_CountryID=@prst_CountryID AND prst_State IS NOT NULL ORDER BY prst_State";
        private const string SQL_SELECT_CITY = 
            "SELECT prci_CityID, prci_City FROM PRCity WITH(NOLOCK) WHERE prci_StateID=@prci_StateID ORDER BY prci_City";


        private void BindCountry(ListControl oControl)
        {
            SqlCommand cmdCustomCaption = new SqlCommand(SQL_SELECT_COUNTRY, GetDBConnnection());

            oControl.DataTextField = "prcn_Country";
            oControl.DataValueField = "prcn_CountryID";

            using (IDataReader drCustomCaption = cmdCustomCaption.ExecuteReader(CommandBehavior.Default))
            {
                oControl.DataSource = drCustomCaption;
                oControl.DataBind();
            }
        }

        protected void BindState(object sender, EventArgs e)
        {
            int iSelectedCount = 0;
            int iCountryID = 0;
            foreach (ListItem oItem in cblCountry.Items)
            {
                if (oItem.Selected)
                {
                    iSelectedCount++;
                    iCountryID = Convert.ToInt32(oItem.Value);
                }
            }

            if (iSelectedCount == 1)
            {
                pnlStateSelect.Visible = true;
                
                litState.Text = string.Empty;
                SqlCommand cmdCustomCaption = new SqlCommand(SQL_SELECT_STATE, GetDBConnnection());
                cmdCustomCaption.Parameters.AddWithValue("prst_CountryID", iCountryID);

                cblState.DataTextField = "prst_State";
                cblState.DataValueField = "prst_StateID";

                using (IDataReader drCustomCaption = cmdCustomCaption.ExecuteReader(CommandBehavior.Default))
                {
                    cblState.DataSource = drCustomCaption;
                    cblState.DataBind();
                }

                if (cblState.Items.Count == 0)
                {
                    litState.Text = "No States/Provinces Found.";
                    pnlStateSelect.Visible = false;
                }
            }
            else
            {
                cblState.Items.Clear();
                litState.Text = "Please select a single country.";
                pnlStateSelect.Visible = false;
            }

            BindCity(sender, e);
        }

        protected void BindCity(object sender, EventArgs e)
        {
            int iSelectedCount = 0;
            int iStateID = 0;
            foreach (ListItem oItem in cblState.Items)
            {
                if (oItem.Selected)
                {
                    iSelectedCount++;
                    iStateID = Convert.ToInt32(oItem.Value);
                }
            }

            if (iSelectedCount == 1)
            {
                pnlCitySelect.Visible = true;
                litCity.Text = string.Empty;
                SqlCommand cmdCustomCaption = new SqlCommand(SQL_SELECT_CITY, GetDBConnnection());
                cmdCustomCaption.Parameters.AddWithValue("prci_StateID", iStateID);

                cblCity.DataTextField = "prci_City";
                cblCity.DataValueField = "prci_CityID";

                using (IDataReader drCustomCaption = cmdCustomCaption.ExecuteReader(CommandBehavior.Default))
                {
                    cblCity.DataSource = drCustomCaption;
                    cblCity.DataBind();
                }

                if (cblCity.Items.Count == 0)
                {
                    litCity.Text = "No Cities Found.";
                    pnlCitySelect.Visible = false;
                }
            }
            else
            {
                cblCity.Items.Clear();
                litCity.Text = "Please select a single state/province.";
                pnlCitySelect.Visible = false;
            }
        }


        private const string SQL_SELECT_BATCH_INFO =
               @"SELECT MAX(prlrlb_BatchName) As prlrlb_BatchName, MAX(prlrlb_LetterType) As prlrrb_LetterType, SUM(prlrlb_Count) As TotalLetters, MIN(prlrlb_CreatedDate) As BatchStart, MAX(prlrlb_CreatedDate) As BatchEnd 
                   FROM PRLRLBatch WITH(NOLOCK) 
                  WHERE prlrlb_BatchName = @prlrlb_BatchName 
                    AND prlrlb_BatchType <> 'T'";

        private const string SQL_SELECT_COMPANIES_WO_LETTERS =
                @"SELECT COUNT(1) 
                    FROM Company WITH (NOLOCK) 
                         INNER JOIN PRAttentionLine WITH(NOLOCK) ON comp_CompanyID = prattn_CompanyID 
                   WHERE comp_PRType = 'H' 
                     AND comp_PRListingStatus IN ('L', 'H', 'LUV') 
                     AND prattn_ItemCode = 'LRL' ";

        private const string SQL_COMPANIES_WO_LETTERS_CLAUSE =
            " AND ISNULL(comp_PRLastLRLLetterDate, '2006-12-04') NOT BETWEEN '{0}' AND '{1}' "; 

        private const string SQL_COMPANIES_WO_LETTERS_CLAUSE2 =
            @"AND comp_CompanyID NOT IN ( 
                SELECT DISTINCT CmLi_Comm_CompanyId 
                  FROM Comm_Link WITH(NOLOCK) 
                       INNER JOIN Communication WITH(NOLOCK) ON cmli_Comm_CommunicationID = Comm_CommunicationID 
                 WHERE comm_PRCategory = 'L' 
                   AND comm_PRSubcategory = 'LRL' 
                   AND comm_Action IN ('LetterOut', 'EmailOut')
                   AND comm_Status = 'Complete' 
                   AND comm_CreatedDate BETWEEN '{0}' AND '{1}') ";

        DateTime _dtBatchStart = new DateTime();
        DateTime _dtBatchEnd = new DateTime();


        /// <summary>
        /// Populate the initial form.
        /// </summary>
        private void PopulateForm()
        {
            SqlCommand cmdBatchInfo = new SqlCommand(SQL_SELECT_BATCH_INFO, GetDBConnnection());
            cmdBatchInfo.Parameters.AddWithValue("prlrlb_BatchName", litBatch.Text);

            using (IDataReader drBatchInfo = cmdBatchInfo.ExecuteReader(CommandBehavior.Default))
            {
                while (drBatchInfo.Read())
                {
                    //litBatch.Text = _szBatchName;

                    if (drBatchInfo[1] != DBNull.Value)
                    {
                        litLetterCount.Text = drBatchInfo.GetInt32(2).ToString("###,##0");
                        _dtBatchStart = drBatchInfo.GetDateTime(3);
                        _dtBatchEnd = drBatchInfo.GetDateTime(4);
                    }
                    else
                    {

                        litLetterCount.Text = "0";

                        // Set our start/end so that all companies
                        // are returned.
                        _dtBatchStart = DateTime.Today;
                        _dtBatchEnd = DateTime.Today.AddDays(1);
                    }

                    hidBatchStart.Value = _dtBatchStart.ToString("MM-dd-yyyy hh:mm tt");
                    hidBatchEnd.Value = _dtBatchEnd.AddSeconds(1).ToString("MM-dd-yyyy hh:mm:ss tt");
                }
            }

            string szSQL = SQL_SELECT_COMPANIES_WO_LETTERS + string.Format(SQL_COMPANIES_WO_LETTERS_CLAUSE, hidBatchStart.Value, hidBatchEnd.Value);
            //lblMsg.Text = szSQL;

            SqlCommand cmdNoLeterCount = new SqlCommand(szSQL, GetDBConnnection());
            cmdNoLeterCount.CommandTimeout = 300;
            litCompaniesWOLetters.Text = ((Int32)cmdNoLeterCount.ExecuteScalar()).ToString("###,##0");
            litCompaniesWOLetters2.Text = litCompaniesWOLetters.Text;
            hidCompaniesWOLetters.Value = litCompaniesWOLetters.Text;

            CloseDBConnection(_dbConn);
            _dbConn = null; 
        }

        private const string SQL_INSERT_BATCH =
            "INSERT INTO PRLRLBatch (prlrlb_BatchName, prlrlb_BatchType, prlrlb_LetterType, prlrlb_Count, prlrlb_Criteria, prlrlb_CreatedBy, prlrlb_CreatedDate, prlrlb_UpdatedBy, prlrlb_UpdatedDate, prlrlb_Timestamp) " +
            "VALUES (@prlrlb_BatchName, @prlrlb_BatchType, @prlrlb_LetterType, @prlrlb_Count, @prlrlb_Criteria, @prlrlb_CreatedBy, @prlrlb_CreatedDate, @prlrlb_UpdatedBy, @prlrlb_UpdatedDate, @prlrlb_Timestamp)";

        private const string SQL_SELECT_COMPANIES =
              @"SELECT comp_CompanyID, comp_PRType, CASE WHEN prattn_EmailID IS NULL THEN 'M' ELSE 'E' END As DeliveryType, Addressee, DeliveryAddress, comp_Name,
                       [Order] = RANK() OVER (PARTITION BY comp_PRHQID ORDER BY comp_PRType Desc, comp_PRIndustryType asc, prcn_Country asc , prst_State asc, prci_City asc, comp_Name asc, comp_CompanyId asc) 
                  FROM Company WITH(NOLOCK) 
                       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID 
                       LEFT OUTER JOIN vPRCompanyAttentionLine ON comp_CompanyID = prattn_CompanyID AND prattn_ItemCode = 'LRL'
                 WHERE comp_PRType = 'H' 
                   {0} 
              ORDER BY comp_CompanyID, [Order]";




        /// <summary>
        /// Generate the Listing Report Letters based on the specfied criteria.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GenerateLRLs(object sender, EventArgs e)
        {
            _dtNow = DateTime.Now;
            _bIsTest = cbTestOnly.Checked;

            _LRLBaseCompanyDataFile = Path.Combine(GetConfigValue("GenerateLRLFolder"),
                                                   GetConfigValue("GenerateLRLCompanyFile", "Base_Company_Data.txt"));

            if (File.Exists(_LRLBaseCompanyDataFile))
                File.Delete(_LRLBaseCompanyDataFile);

            WriteBaseCompanyDataHeader();

            _LRLListingDataFile = Path.Combine(GetConfigValue("GenerateLRLFolder"),
                                       GetConfigValue("GenerateLRLListingFile", "LRL_Listing_Data.txt"));
            if (File.Exists(_LRLListingDataFile))
                File.Delete(_LRLListingDataFile);
            WriteListingDataFileHeader();


            _LRLPersonDataFile = string.Concat(GetConfigValue("GenerateLRLFolder"),
                                               GetConfigValue("GenerateLRLPersonFile", "LRL_Person_Data.txt"));
            if (File.Exists(_LRLPersonDataFile))
                File.Delete(_LRLPersonDataFile);
            WritePersonDataFileHeader();


            _LRLCompanyProductFile = string.Concat(GetConfigValue("GenerateLRLFolder"),
                                                   GetConfigValue("GenerateLRLCompanyProductFile", "LRL_Company_Product_Data.txt"));
            if (File.Exists(_LRLCompanyProductFile))
                File.Delete(_LRLCompanyProductFile);
            WriteCompanyProductDataFileHeader();


            _LRLProductMasterFile = string.Concat(GetConfigValue("GenerateLRLFolder"),
                                                  GetConfigValue("GenerateLRLProductMasterFile", "LRL_Product_Master_Data.txt"));
            if (File.Exists(_LRLProductMasterFile))
                File.Delete(_LRLProductMasterFile);
            WriteProductMasterDataFileHeader();


            _szLogFile = Path.Combine(GetConfigValue("GenerateLRLFolder"),
                                      string.Format(GetConfigValue("GenerateLRLLogFile", "GenerateLRLLogFile_{0}.txt"), DateTime.Now.ToString("yyyyMMdd_HHmm")));

            if (File.Exists(_szLogFile))
            {
                File.Delete(_szLogFile);
            }

            int iDebugLimit = GetConfigValue("GenerateLRLDebugCount", 999999);
            WriteToLog("Batch Start: " + DateTime.Now.ToString());

            List<Company> lCompanies = new List<Company>();
            int iProcessingCompanyID = 0;

            try 
            {

                int iDebugCount = 0;

                string szSQL = string.Format(SQL_SELECT_COMPANIES, BuildWhereClause());
                WriteToLog(szSQL);

                // Build a list of Company objects for further processing.
                SqlCommand sqlCompanies = new SqlCommand(szSQL, GetDBConnnection());
                sqlCompanies.CommandTimeout = 60 * 60;
                using (IDataReader drCompanies = sqlCompanies.ExecuteReader(CommandBehavior.Default))
                {
                    while (drCompanies.Read())
                    {
                        Company oCompany = new Company();
                        oCompany.CompanyID = drCompanies.GetInt32(0);
                        oCompany.Type = drCompanies.GetString(1);
                        oCompany.Order = drCompanies.GetInt64(6);

                        oCompany.DeliveryType = drCompanies.GetString(2);
                        if (oCompany.DeliveryType == "E") {
                            oCompany.Addressee = drCompanies.GetString(3);
                            oCompany.DeliveryAddress = drCompanies.GetString(4);
                        }

                        oCompany.Name = drCompanies.GetString(5);

                        lCompanies.Add(oCompany);

                        iDebugCount++;
                        if (iDebugCount >= iDebugLimit)
                        {
                            break;
                        }
                    }
                }


                bool bMailFilesCreated = false;
                int mailCount = 0;
                int emailCount = 0;

                // For each company, generate a letter and add it to
                // the output file.
                foreach (Company oCompany in lCompanies)
                {
                    iProcessingCompanyID = oCompany.CompanyID;
                    lblMsg.Text = "Processing " + oCompany.CompanyID.ToString();

                    if (oCompany.DeliveryType == "E")
                    {
                        EmailLRL(oCompany);
                        emailCount++;
                    }
                    else
                    {
                        bMailFilesCreated = true;
                        ProcessCompany(oCompany);
                        mailCount++;
                    }
                }
                ProcessProductMasterFile();



                SqlTransaction oTran = GetDBConnnection().BeginTransaction();
                try
                {

                    // If this isn't a test run, then create an interaction for this
                    // company that indicates a LRL was sent out.
                    if (!_bIsTest)
                    {
                        iDebugCount = 0;

                        WriteToLog("Start Creating Interactions: " + DateTime.Now.ToString());
                        SqlCommand cmdCreateTask = new SqlCommand("usp_CreateTask", GetDBConnnection(), oTran);
                        cmdCreateTask.CommandType = CommandType.StoredProcedure;

                        SqlCommand cmdUpdateCompany = new SqlCommand("UPDATE Company SET comp_PRLastLRLLetterDate=@Now, comp_UpdatedBy=@UserID, comp_UpdatedDate=@Now, comp_Timestamp=@Now WHERE comp_CompanyID = @CompanyID;",
                                                                     GetDBConnnection(),
                                                                     oTran);


                        int iAssignedToUserID = GetConfigValue("GenerateLRLTaskUserID", 45);
                        string szNotes = GetConfigValue("GenerateLRLTaskNotes", "Listing Report Letter Sent.");
                        foreach (Company oCompany in lCompanies)
                        {

                            cmdCreateTask.Parameters.Clear();
                            cmdCreateTask.Parameters.AddWithValue("AssignedToUserId", iAssignedToUserID);
                            cmdCreateTask.Parameters.AddWithValue("TaskNotes", szNotes);
                            cmdCreateTask.Parameters.AddWithValue("RelatedCompanyID", oCompany.CompanyID);
                            cmdCreateTask.Parameters.AddWithValue("StartDateTime", _dtNow);
                            cmdCreateTask.Parameters.AddWithValue("DueDateTime", _dtNow);

                            if (oCompany.DeliveryType == "E")
                            {
                                cmdCreateTask.Parameters.AddWithValue("Action", "EmailOut");
                            }
                            else
                            {
                                cmdCreateTask.Parameters.AddWithValue("Action", "LetterOut");
                            }


                            cmdCreateTask.Parameters.AddWithValue("Status", "Complete");
                            cmdCreateTask.Parameters.AddWithValue("PRCategory", "L");
                            cmdCreateTask.Parameters.AddWithValue("PRSubcategory", "LRL");
                            cmdCreateTask.ExecuteNonQuery();

                            cmdUpdateCompany.Parameters.Clear();
                            cmdUpdateCompany.Parameters.AddWithValue("Now", _dtNow);
                            cmdUpdateCompany.Parameters.AddWithValue("UserID", _iUserID);
                            cmdUpdateCompany.Parameters.AddWithValue("CompanyID", oCompany.CompanyID);
                            cmdUpdateCompany.ExecuteNonQuery();

                            iDebugCount++;
                            if (iDebugCount >= iDebugLimit)
                            {
                                break;
                            }
                        }
                        WriteToLog("Finished Creating Interactions: " + DateTime.Now.ToString());
                    }

                    // If this isn't a test run, create a batch record for this execution.
                    SqlCommand cmdInsertBatch = new SqlCommand(SQL_INSERT_BATCH, GetDBConnnection(), oTran);
                    cmdInsertBatch.Parameters.AddWithValue("prlrlb_BatchName", litBatch.Text);

                    if (_bIsTest)
                    {
                        cmdInsertBatch.Parameters.AddWithValue("prlrlb_BatchType", "T");
                    }
                    else
                    {
                        cmdInsertBatch.Parameters.AddWithValue("prlrlb_BatchType", "L");
                    }

                    cmdInsertBatch.Parameters.AddWithValue("prlrlb_LetterType", ddlLetterType.SelectedValue);
                    cmdInsertBatch.Parameters.AddWithValue("prlrlb_Count", lCompanies.Count);
                    cmdInsertBatch.Parameters.AddWithValue("prlrlb_Criteria", BuildEnglishCriteria());
                    cmdInsertBatch.Parameters.AddWithValue("prlrlb_CreatedBy", _iUserID);
                    cmdInsertBatch.Parameters.AddWithValue("prlrlb_CreatedDate", _dtNow);
                    cmdInsertBatch.Parameters.AddWithValue("prlrlb_UpdatedBy", _iUserID);
                    cmdInsertBatch.Parameters.AddWithValue("prlrlb_UpdatedDate", _dtNow);
                    cmdInsertBatch.Parameters.AddWithValue("prlrlb_Timestamp", _dtNow);

                    cmdInsertBatch.ExecuteNonQuery();

                    oTran.Commit();
                }
                catch (Exception exc)
                {
                    if (oTran != null)
                    {
                        oTran.Rollback();
                    }

                    WriteToLog(iProcessingCompanyID, "EXCEPTION: " + exc.Message);

                    throw;
                }

                StringBuilder sbMessage = new StringBuilder();
                sbMessage.Append("Processed " + lCompanies.Count.ToString("###,##0") + " Companies.<br/>");
                sbMessage.Append(" - Mail: " + mailCount.ToString("###,##0") + " Companies.<br/>");
                sbMessage.Append(" - Email: " + emailCount.ToString("###,##0") + " Companies.<br/>");

                if (mailCount > 0)
                {
                    sbMessage.Append("The output files can be found at " + GetConfigValue("GenerateLRLFolder") + ".<br/>");
                }
                else
                {
                    sbMessage.Append("No output files were created.<br/>");
                }


                WriteToLog("Processed " + lCompanies.Count.ToString("###,##0") + " Companies.");

                // Only package up the output mail house files
                // if we actually process companies for LRL mailings.
                if (bMailFilesCreated)
                {
                    GenerateControlCountFile();

                    if ((!_bIsTest) ||
                        (GetConfigValue("LRLSendEmailRegardlessofTest", "false").ToLower() == "true"))
                    {
                        string ftpFileName = CompressFiles(lCompanies);
                        UploadFile(GetConfigValue("LRLFTPServer", "ftp://ftp.bluebookservices.com"),
                                   GetConfigValue("LRLFTPUsername", "qa"),
                                   GetConfigValue("LRLFTPPassword", "qA$1901"),
                                   ftpFileName);

                        GenerateEmail(Path.GetFileName(ftpFileName));

                        CleanupFiles();
                    }
                }

                lblMsg.Text = sbMessage.ToString();
            } 
            catch (Exception ex) 
            {
                lblMsg.Text += "<br/>EXCEPTION: " + ex.Message;
                lblMsg.Text += "<br/><pre>" + ex.StackTrace + "</pre>";

                WriteToLog(iProcessingCompanyID, "EXCEPTION: " + ex.Message);

            } 
            finally 
            {
                CloseDBConnection(_dbConn);
                _dbConn = null;
                WriteToLog("Batch End: " + DateTime.Now.ToString());
            }

            PopulateForm();
        }


        private const string SQL_SELECT_BRANCHES =
               @"SELECT comp_CompanyID, comp_PRType
                   FROM Company WITH(NOLOCK) 
                        INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
                  WHERE comp_PRType = 'B' 
                    AND comp_PRListingStatus IN ('L', 'H', 'LUV') 
                    AND comp_PRHQID = @HQID 
               ORDER BY prcn_Country, prst_State, prci_City, comp_PRBookTradeStyle";

        private SqlCommand cmdBranches = null;
        /// <summary>
        /// Helper method that retrieves the branches for the specified
        /// company.
        /// </summary>
        /// <param name="oCompany"></param>
        /// <returns></returns>
        private List<Company> GetBranches(Company oCompany)
        {
            List<Company> lBranches = new List<Company>();

            if (cmdBranches == null)
            {
                cmdBranches = new SqlCommand(SQL_SELECT_BRANCHES, GetDBConnnection());
            }
            cmdBranches.Parameters.Clear();
            cmdBranches.Parameters.AddWithValue("HQID", oCompany.CompanyID);

            using (IDataReader drBranches = cmdBranches.ExecuteReader(CommandBehavior.Default))
            {
                while (drBranches.Read())
                {
                    Company oBranch = new Company();
                    oBranch.CompanyID = drBranches.GetInt32(0);
                    oBranch.Type = drBranches.GetString(1);
                    lBranches.Add(oBranch);
                }
            }

            return lBranches;
        }


        private void ProcessCompany(Company company)
        {
            ProcessBaseCompanyData(company);
            ProcessListingData(company);
            ProcessPersonsData(company);
            ProcessCompanyProduct(company);

            if (company.Type == "H")
            {
                _MailingPieceCount++; 

                List<Company> branches = GetBranches(company);
                int i = 1;

                foreach (Company branch in branches)
                {
                    i++;
                    branch.Order = i;
                    ProcessCompany(branch);
                }
            }
        }


        private void ProcessBaseCompanyData(Company company)
        {
            //Get base company data.
            string szSQL = string.Format("SELECT * FROM vLRLCompany WHERE BBID={0}", company.CompanyID);
            //WriteToLog(company.CompanyID, szSQL);

            SqlCommand sqlBaseData = new SqlCommand(szSQL, GetDBConnnection());
            sqlBaseData.CommandTimeout = 60 * 60;

            //Insert a line in the base company data file.
            using (IDataReader drBaseData = sqlBaseData.ExecuteReader(CommandBehavior.Default))
            {
                while (drBaseData.Read())
                {
                    if (!string.IsNullOrEmpty(GetStringValue(drBaseData, "PublishLogo")))
                    {
                        company.Logo = GetStringValue(drBaseData, "Logo");
                    }

                    StringBuilder text = new StringBuilder();

                    text.Append(GetIntValue(drBaseData, "BBID"));
                    text.Append("\t");
                    text.Append(GetIntValue(drBaseData, "HQID"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Company Name"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Type"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Listing City"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Listing State"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Listing Country"));
                    text.Append("\t");
                    text.Append(company.Order);
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Industry"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "CL Message"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Last CL Date"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Volume Message"));
                    text.Append("\t");

                    if (!string.IsNullOrEmpty(GetStringValue(drBaseData, "PublishLogo")))
                    {
                        text.Append(GetLogoPathForExport(GetStringValue(drBaseData, "Logo")));
                    }
                    text.Append("\t");
                    
                    
                    text.Append(GetStringValue(drBaseData, "Has DL"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Attention Line"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Address 1"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Address 2"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Address 3"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Address 4"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Mailing City"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Mailing State"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Mailing Country"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Mailing Zip"));
                    text.Append("\t");
                    text.Append(_fileDate);
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Member"));
                    text.Append("\t");
                    text.Append(GetStringValue(drBaseData, "Marketing Message"));
                    text.Append("\t");

                    string email = string.Empty;
                    string title = null;
                    string addressee = null;

                    //  1. If TES-M enabled and TES-E disabled, then: list TES-M attn line on LRL and leave Email field blank. 
                    // [Goal: have them add an email on LRL, which we would then add to TES-E and disable TES-M]
                    if ((drBaseData["TESM_Disabled"] == DBNull.Value) &&
                        (drBaseData["TESE_Disabled"] != DBNull.Value))
                    {
                        title = GetStringValue(drBaseData, "TESM_Title");
                        addressee = GetStringValue(drBaseData, "TESM_Addressee");
                    }

                    // 2. If TES-M disabled and TES-E enabled with email, then: list TES-E attn line on LRL and pull in email from 
                    // TES-E attn line. [Goal: Validate that TES-E attn line remains correct]
                    // 3. If TES-M disabled and TES-E enabled with Fax, then: list TES-E attn line on LRL and and leave Email field blank. 
                    // [Goal: have them add an email on LRL, which we would then update TES-E so TES is delivered by Email, not Fax]
                    if ((drBaseData["TESM_Disabled"] != DBNull.Value) &&
                        (drBaseData["TESE_Disabled"] == DBNull.Value))
                    {
                        email = GetStringValue(drBaseData, "TESE_Email");
                        title = GetStringValue(drBaseData, "TESE_Title");
                        addressee = GetStringValue(drBaseData, "TESE_Addressee");
                    }

                    // 4. If TES-M enabled and TES-E enabled, then: list TES-M attn line on LRL and leave Email field blank. 
                    //[Goal: have them add an email on LRL, which we would then add to TES-E and disable TES-M]
                    if ((drBaseData["TESM_Disabled"] == DBNull.Value) &&
                        (drBaseData["TESE_Disabled"] == DBNull.Value))
                    {
                        title = GetStringValue(drBaseData, "TESM_Title");
                        addressee = GetStringValue(drBaseData, "TESM_Addressee");
                    }

                    text.Append(email);
                    text.Append("\t");
                    text.Append(title);
                    text.Append("\t");
                    text.Append(addressee);

                    text.Append(GenerateLRL.NEWLINE);

                    WriteToFile(_LRLBaseCompanyDataFile, text.ToString());

                    _LocationCount++;
                }
            }
        }



        private const string SQL_SELECT_LISTING_DATA =
               @"SELECT comp_CompanyID as BBID, 
                        dbo.ufn_GetListingFromCompany2(comp_CompanyID, 4, 1, 1) as Listing 
                   FROM Company WITH (NOLOCK)
                  WHERE comp_CompanyID = {0} 
               ORDER BY comp_CompanyID";

        private void ProcessListingData(Company company)
        {
            //Get listing data.
            string szListingSQL = string.Format(SQL_SELECT_LISTING_DATA, company.CompanyID);

            SqlCommand sqlListingData = new SqlCommand(szListingSQL, GetDBConnnection());
            sqlListingData.CommandTimeout = 60 * 60;

            //Insert a line in the listing data file.
            using (IDataReader drListingData = sqlListingData.ExecuteReader(CommandBehavior.Default))
            {
                while (drListingData.Read())
                {
                    StringBuilder text = new StringBuilder();
                    text.Append(_fileDate);
                    text.Append("\t");
                    text.Append(GetIntValue(drListingData, "BBID"));
                    text.Append("\t");
                    text.Append(GetStringValue(drListingData, "Listing"));
                    text.Append(GenerateLRL.NEWLINE);
                    WriteToFile(_LRLListingDataFile, text.ToString());
                }
            }
        }
        private const string SQL_SELECT_PERSONS =
           @"SELECT [PersonID] = peli_PersonID, 
                   [BBID] = peli_CompanyID,  
                   [Formatted Name] = dbo.ufn_FormatPersonByID (peli_PersonID),  
                   [First Name] = rtrim(pers_FirstName),  
                   [Last Name] = rtrim(pers_LastName),  
                   [Title] = peli_PRTitle,  
                   [Start Date] = peli_PRStartDate,  
                   [E-Mail Address] = rtrim(emai_EmailAddress),  
                   [Pub in BBOS] = peli_PREBBPublish,  
                   peli_PRPctOwned,  
                   HasLicense,
                   [Order] = RANK() OVER (PARTITION BY peli_CompanyID ORDER BY capt_Order, pers_FullName asc)  
              FROM vPRPersonnelListing  
                   LEFT OUTER JOIN Custom_Captions on capt_Code = peli_PRTitleCode  
                                                AND capt_Family = 'pers_TitleCode' 
                                                AND capt_FamilyType = 'Choices'  
             WHERE peli_PRStatus in (1,2) 
               AND peli_CompanyID={0} 
          ORDER BY [Order]";

        private void ProcessPersonsData(Company company)
        {
            //Get person data.
            string szPersonSQL = string.Format(SQL_SELECT_PERSONS, company.CompanyID);

            SqlCommand sqlPersonData = new SqlCommand(szPersonSQL, GetDBConnnection());
            sqlPersonData.CommandTimeout = 60 * 60;

            //Insert a line in the persons data file.
            using (IDataReader drPersonData = sqlPersonData.ExecuteReader(CommandBehavior.Default))
            {
                while (drPersonData.Read())
                {
                    StringBuilder text = new StringBuilder();

                    text.Append(GetIntValue(drPersonData, "PersonID"));
                    text.Append("\t");
                    text.Append(GetIntValue(drPersonData, "BBID"));
                    text.Append("\t");
                    text.Append(GetStringValue(drPersonData, "Formatted Name"));
                    text.Append("\t");
                    text.Append(GetStringValue(drPersonData, "First Name"));
                    text.Append("\t");
                    text.Append(GetStringValue(drPersonData, "Last Name"));
                    text.Append("\t");
                    text.Append(GetStringValue(drPersonData, "Title"));
                    text.Append("\t");
                    text.Append(GetStringValue(drPersonData, "Start Date"));
                    text.Append("\t");
                    text.Append(GetStringValue(drPersonData, "E-Mail Address"));
                    text.Append("\t");
                    text.Append(GetStringValue(drPersonData, "Pub in BBOS"));
                    text.Append("\t");
                    text.Append(GetIntValue(drPersonData, "Order"));
                    text.Append("\t");
                    text.Append(_fileDate);
                    text.Append("\t");
                    text.Append(GetPercentValue(drPersonData, "peli_PRPctOwned"));

                    if (GetConfigValue("LRLExportHasLicenseEnabled", false))
                    {
                        text.Append("\t");
                        // We want to send a blank instead of "N"
                        if (GetStringValue(drPersonData, "HasLicense") == "Y")
                        {
                            text.Append("Y");
                        }
                    }

                    text.Append(GenerateLRL.NEWLINE);

                    WriteToFile(_LRLPersonDataFile, text.ToString());

                    _PeopleCount++;
                }
            }
        }


        private const string SQL_SELECT_COMPANY_PRODUCTS =
                   @"SELECT prcprpr_CompanyID [BBID], 
                            prcprpr_ProductProvidedID [ProductID]
                       FROM PRCompanyProductProvided WITH (NOLOCK)
                      WHERE prcprpr_CompanyID = {0}
                        AND prcprpr_ProductProvidedID > 0
                   ORDER BY prcprpr_CompanyID, prcprpr_ProductProvidedID";

        private void ProcessCompanyProduct(Company company)
        {
            string szCompanyProductSQL = string.Format(SQL_SELECT_COMPANY_PRODUCTS, company.CompanyID);

            SqlCommand sqlCompanyProduct = new SqlCommand(szCompanyProductSQL, GetDBConnnection());
            sqlCompanyProduct.CommandTimeout = 60 * 60;

            //Insert a line in the persons data file.
            using (IDataReader drCompanyProductData = sqlCompanyProduct.ExecuteReader(CommandBehavior.Default))
            {
                while (drCompanyProductData.Read())
                {
                    StringBuilder text = new StringBuilder();

                    text.Append(GetIntValue(drCompanyProductData, "BBID"));
                    text.Append("\t");
                    text.Append(GetIntValue(drCompanyProductData, "ProductID"));
                    text.Append(GenerateLRL.NEWLINE);

                    WriteToFile(_LRLCompanyProductFile, text.ToString());

                    _CompanyProductCount++;
                }
            }
        }




        private const string SQL_SELECT_PRODUCTS =
                   @"SELECT prprpr_ProductProvidedID [ProductID], 
                            prprpr_Name  [Product Name], 
	                        prprpr_DisplayOrder [Display Order]
                       FROM PRProductProvided WITH (NOLOCK)
                   ORDER BY prprpr_DisplayOrder";

        private void ProcessProductMasterFile()
        {
            SqlCommand sqlProduct = new SqlCommand(SQL_SELECT_PRODUCTS, GetDBConnnection());
            sqlProduct.CommandTimeout = 60 * 60;

            //Insert a line in the persons data file.
            using (IDataReader drProductData = sqlProduct.ExecuteReader(CommandBehavior.Default))
            {
                while (drProductData.Read())
                {
                    StringBuilder text = new StringBuilder();

                    text.Append(GetIntValue(drProductData, "ProductID"));
                    text.Append("\t");
                    text.Append(GetStringValue(drProductData, "Product Name"));
                    text.Append("\t");
                    text.Append(GetIntValue(drProductData, "Display Order"));
                    text.Append(GenerateLRL.NEWLINE);

                    WriteToFile(_LRLProductMasterFile, text.ToString());

                    _ProcutMasterCount++;
                }
            }
        }




        protected void WriteBaseCompanyDataHeader()
        {
            StringBuilder text = new StringBuilder();

            text.Append("BBID");
            text.Append("\t");
            text.Append("HQID");
            text.Append("\t");
            text.Append("Company Name");
            text.Append("\t");
            text.Append("Type");
            text.Append("\t");
            text.Append("Listing City");
            text.Append("\t");
            text.Append("Listing State");
            text.Append("\t");
            text.Append("Listing Country");
            text.Append("\t");
            text.Append("Order");
            text.Append("\t");
            text.Append("Industry");
            text.Append("\t");
            text.Append("CL Message");
            text.Append("\t");
            text.Append("Last CL Date");
            text.Append("\t");
            text.Append("Volume Message");
            text.Append("\t");
            text.Append("Logo");
            text.Append("\t");
            text.Append("Has DL");
            text.Append("\t");
            text.Append("Attention Line");
            text.Append("\t");
            text.Append("Address 1");
            text.Append("\t");
            text.Append("Address 2");
            text.Append("\t");
            text.Append("Address 3");
            text.Append("\t");
            text.Append("Address 4");
            text.Append("\t");
            text.Append("Mailing City");
            text.Append("\t");
            text.Append("Mailing State");
            text.Append("\t");
            text.Append("Mailing Country");
            text.Append("\t");
            text.Append("Mailing Zip");
            text.Append("\t");
            text.Append("File Date");
            text.Append("\t");
            text.Append("Member");
            text.Append("\t");
            text.Append("Marketing Message");
            text.Append("\t");
            text.Append("Email");
            text.Append("\t");
            text.Append("Title");
            text.Append("\t");
            text.Append("Attention");
            text.Append(GenerateLRL.NEWLINE);

            WriteToFile(_LRLBaseCompanyDataFile, text.ToString());
        }

        protected void WritePersonDataFileHeader()
        {
            StringBuilder text = new StringBuilder();

            text.Append("PersonID");
            text.Append("\t");
            text.Append("BBID");
            text.Append("\t");
            text.Append("Formatted Name");
            text.Append("\t");
            text.Append("First Name");
            text.Append("\t");
            text.Append("Last Name");
            text.Append("\t");
            text.Append("Title");
            text.Append("\t");
            text.Append("Start Date");
            text.Append("\t");
            text.Append("E-Mail Address");
            text.Append("\t");
            text.Append("Pub in BBOS");
            text.Append("\t");
            text.Append("Order");
            text.Append("\t");
            text.Append("File Date");
            text.Append("\t");
            text.Append("Ownership Percent");

            if (GetConfigValue("LRLExportHasLicenseEnabled", false))
            {
                text.Append("\t");
                text.Append("Has License");
            }

            text.Append(GenerateLRL.NEWLINE);

            WriteToFile(_LRLPersonDataFile, text.ToString());
        }

        protected void WriteCompanyProductDataFileHeader()
        {
            StringBuilder text = new StringBuilder();

            text.Append("BBID");
            text.Append("\t");
            text.Append("ProductID");
            text.Append(GenerateLRL.NEWLINE);

            WriteToFile(_LRLCompanyProductFile, text.ToString());
        }


        protected void WriteProductMasterDataFileHeader()
        {
            StringBuilder text = new StringBuilder();

            text.Append("ProductID");
            text.Append("\t");
            text.Append("Product Name");
            text.Append("\t");
            text.Append("Display Order");
            text.Append(GenerateLRL.NEWLINE);

            WriteToFile(_LRLProductMasterFile, text.ToString());
        }


        protected void WriteListingDataFileHeader()
        {
            StringBuilder text = new StringBuilder();

            text.Append("File Date");
            text.Append("\t");
            text.Append("BBID");
            text.Append("\t");
            text.Append("Listing");
            text.Append(GenerateLRL.NEWLINE);

            WriteToFile(_LRLListingDataFile, text.ToString());
        }

        protected string GetStringValue(IDataReader drReader, string szColName)
        {
            if (drReader[szColName] == DBNull.Value)
            {
                return String.Empty;
            }
            return Convert.ToString(drReader[szColName]).Trim();
        }

        protected int GetIntValue(IDataReader drReader, string szColName)
        {
            if (drReader[szColName] == DBNull.Value)
            {
                return 0;
            }
            return Convert.ToInt32(drReader[szColName]);
        }

        protected string GetPercentValue(IDataReader drReader, string szColName)
        {
            if (drReader[szColName] == DBNull.Value)
            {
                return String.Empty;
            }

            decimal value = Convert.ToDecimal(drReader[szColName]);
            if (value == 0)
            {
                return String.Empty;
            }

            return value.ToString("0.00") + "%";
        }

        /// <summary>
        /// Method builds the WHERE clause to select the companies to generate
        /// letters for.
        /// </summary>
        /// <returns></returns>
        protected string BuildWhereClause()
        {
            StringBuilder sbWhereClause = new StringBuilder();

            switch(Request["rbFilterType"]) {
                case "Criteria":
                    AddSubClause(sbWhereClause, cblListingStatus, "comp_PRListingStatus", true);
                    AddSubClause(sbWhereClause, cblIndustryType, "comp_PRIndustryType", true);

                    // We are going to look at City first, then State, then Country.  If we have
                    // cities selected, there is no need to look at states, etc.
                    if (!AddSubClause(sbWhereClause, cblCity, "prci_CityID", false))
                    {
                        if (!AddSubClause(sbWhereClause, cblState, "prst_StateID", false))
                        {
                            AddSubClause(sbWhereClause, cblCountry, "prcn_CountryID", false);
                        }
                    }

                    if (rblMembers.SelectedValue == "M")
                    {
                        sbWhereClause.Append(" AND dbo.ufn_GetPrimaryService(comp_CompanyID) IS NOT NULL ");
                    }
                    if (rblMembers.SelectedValue == "NM")
                    {
                        sbWhereClause.Append(" AND dbo.ufn_GetPrimaryService(comp_CompanyID) IS NULL ");
                    }

                    
                    if (rblRated.SelectedValue == "R")
                    {
                        sbWhereClause.Append(" AND prra_RatingID IS NOT NULL ");
                    }
                    if (rblRated.SelectedValue == "UR")
                    {   
                        sbWhereClause.Append(" AND prra_RatingID IS NULL ");
                    }

                    sbWhereClause.Append(string.Format(SQL_COMPANIES_WO_LETTERS_CLAUSE, hidBatchStart.Value, hidBatchEnd.Value));
                    
                    break;
                case "IDs":
                   AddSubClause(sbWhereClause, cblIndustryType, "comp_PRIndustryType", true);
                   sbWhereClause.Append(" AND comp_CompanyID IN (" + txtCompanyIDs.Text + ")");
                    break;
                case "DoubleCheck":
                    sbWhereClause.Append(string.Format(SQL_COMPANIES_WO_LETTERS_CLAUSE, hidBatchStart.Value, hidBatchEnd.Value));
                    break;
            }

            return sbWhereClause.ToString();
        }



        /// <summary>
        /// Helper method that adds an AND clause to the WHERE clause.
        /// </summary>
        /// <param name="sbWhereClause"></param>
        /// <param name="oListControl"></param>
        /// <param name="szColumnName"></param>
        /// <param name="bIsString"></param>
        /// <returns></returns>
        protected bool AddSubClause(StringBuilder sbWhereClause, ListControl oListControl, string szColumnName, bool bIsString)
        {
            StringBuilder sbSubClause = new StringBuilder();

            foreach (ListItem oItem in oListControl.Items)
            {
                if (oItem.Selected)
                {
                    if (sbSubClause.Length > 0)
                    {
                        sbSubClause.Append(",");
                    }

                    if (bIsString)
                    {
                        sbSubClause.Append("'" + oItem.Value + "'");
                    }
                    else
                    {
                        sbSubClause.Append(oItem.Value);
                    }
                }
            }

            if (sbSubClause.Length > 0)
            {
                sbWhereClause.Append("AND ");
                sbWhereClause.Append(szColumnName);
                sbWhereClause.Append(" IN (");
                sbWhereClause.Append(sbSubClause);
                sbWhereClause.Append(") ");
                return true;
            }

            return false;
        }

        /// <summary>
        /// Translates the criteria into English for easier viewing by the users
        /// when they are reviewing the job history.
        /// </summary>
        /// <returns></returns>
        protected string BuildEnglishCriteria()
        {
            StringBuilder sbWhereClause = new StringBuilder();

            switch(Request["rbFilterType"]) {
                case "Criteria":
                    AddEnglishCriteria(sbWhereClause, cblListingStatus, "Listing Status");
                    AddEnglishCriteria(sbWhereClause, cblIndustryType, "Industry Type");

                    AddEnglishCriteria(sbWhereClause, cblCountry, "Listing Country");
                    AddEnglishCriteria(sbWhereClause, cblState, "Listing State");
                    AddEnglishCriteria(sbWhereClause, cblCity, "Listing City");

                    if (rblMembers.SelectedValue == "M")
                    {
                        sbWhereClause.Append("  Member Only");
                    }
                    if (rblMembers.SelectedValue == "NM")
                    {
                        sbWhereClause.Append("  Non-Members Only");
                    }


                    if (rblRated.SelectedValue == "R")
                    {
                        sbWhereClause.Append("  Rated Companies Only");
                    }
                    if (rblRated.SelectedValue == "UR")
                    {
                        sbWhereClause.Append("  Unrated Companies Only");
                    }

                    break;
                case "IDs":
                    sbWhereClause.Append("Company IDs = " + txtCompanyIDs.Text + ".");
                    break;
                case "DoubleCheck":
                    sbWhereClause.Append("Double Check = " + litCompaniesWOLetters.Text + " Companies.");
                    break;
            }



            if (txtCLDate.Text != string.Empty)
            {
                sbWhereClause.Append("  Connection List Date = " + txtCLDate.Text + ".");
            }

            if (txtDeadlineDate.Text != string.Empty)
            {
                sbWhereClause.Append("  Deadline Date = " + txtDeadlineDate.Text + ".");
            }

            return sbWhereClause.ToString();
        }

        /// <summary>
        /// Helper method that translates a control's selected values into English. 
        /// </summary>
        /// <param name="sbWhereClause"></param>
        /// <param name="oListControl"></param>
        /// <param name="szCriteriaName"></param>
        protected void AddEnglishCriteria(StringBuilder sbWhereClause, ListControl oListControl, string szCriteriaName)
        {
            StringBuilder sbSubClause = new StringBuilder();

            foreach (ListItem oItem in oListControl.Items)
            {
                if (oItem.Selected)
                {
                    if (sbSubClause.Length > 0)
                    {
                        sbSubClause.Append(", ");
                    }

                    sbSubClause.Append(oItem.Text);
                }
            }
            
            if (sbSubClause.Length > 0)
            {
                if (sbWhereClause.Length > 0)
                {
                    sbWhereClause.Append("  ");
                }

                sbWhereClause.Append(szCriteriaName);
                sbWhereClause.Append("=");
                sbWhereClause.Append(sbSubClause);
                sbWhereClause.Append(".");
            }
        }

       
        private SqlConnection _dbConn = null;

        /// <summary>
        /// Returns an open DB Connection
        /// </summary>
        /// <returns></returns>
        private SqlConnection GetDBConnnection() {
            if (_dbConn == null)
            {
                _dbConn = OpenDBConnection("GenerateLRL");
            }

            return _dbConn;
        }

        private string _szLogFile = null;
        private void WriteToLog(string szText)
        {
            WriteToLog(0, szText);
        }
        private void WriteToLog(int iCompanyID, string szText) {
            if (_szLogFile == null) {
                _szLogFile = string.Concat(GetConfigValue("GenerateLRLFolder"), 
                                           GetConfigValue("GenerateLRLLogFile", "GenerateLRLLogFile.txt"));
            }

            if (iCompanyID > 0)
            {
                WriteToFile(_szLogFile, iCompanyID.ToString() + ": " + szText + Environment.NewLine);
            }
            else
            {
                WriteToFile(_szLogFile, szText + Environment.NewLine);
            }
        }

        /// <summary>
        /// Helper function that writes the specified text to the
        /// specified file
        /// </summary>
        /// <param name="szFileName"></param>
        /// <param name="szContent"></param>
        private void WriteToFile(string szFileName, string szContent) {
            File.AppendAllText(szFileName, szContent);
        }

        private void BackupFiles()
        {
            BackupFile(_LRLBaseCompanyDataFile);
            BackupFile(_LRLPersonDataFile);
            BackupFile(_LRLListingDataFile);
            BackupFile(_LRLCompanyProductFile);
            BackupFile(_LRLProductMasterFile);
            BackupFile(_szLogFile);
        }


        private void CleanupFiles()
        {
            File.Delete(_LRLBaseCompanyDataFile);
            File.Delete(_LRLPersonDataFile);
            File.Delete(_LRLListingDataFile);
            File.Delete(_LRLCompanyProductFile);
            File.Delete(_LRLProductMasterFile);
            File.Delete(_LRLControlFile);
        }

        private string _szTimestamp = null;
        private void BackupFile(string szFileName)
        {

            FileInfo oFileInfo = new FileInfo(szFileName);
            if ((oFileInfo.Exists) &&
                (oFileInfo.Length > 0))
            {
                GC.Collect();

                if (string.IsNullOrEmpty(_szTimestamp))
                {
                    _szTimestamp = DateTime.Now.ToString("yyyyMMdd_HHmm");
                }

                string szBackupName = Path.GetFileNameWithoutExtension(szFileName) + "_" + _szTimestamp + Path.GetExtension(szFileName);
                File.Copy(szFileName, GetConfigValue("GenerateLRLBackupFolder", @"C:\") + szBackupName);
            }
        }

        protected void OnLetterTypeChange(object sender, EventArgs e)
        {
            DateTime dtDueDate = Convert.ToDateTime(txtDeadlineDate.Text);
            litBatch.Text = ddlLetterType.SelectedValue + " " + dtDueDate.ToString("yyyy");
            PopulateForm();
        }

        protected void GenerateControlCountFile()
        {
            _LRLControlFile = Path.Combine(GetConfigValue("GenerateLRLFolder"),
                                           GetConfigValue("GenerateLRLControlFile", "Control.txt"));

            if (File.Exists(_LRLControlFile))
                File.Delete(_LRLControlFile);

            string text = GetFormattedControlTotals();
            WriteToFile(_LRLControlFile, text.ToString());
        }

        protected string GetFormattedControlTotals()
        {
            StringBuilder text = new StringBuilder();

            text.Append("Mailing Piece Count");
            text.Append("\t");
            text.Append("Location Count");
            text.Append("\t");
            text.Append("People Count");
            text.Append("\t");
            text.Append("Company Product Count");
            text.Append("\t");
            text.Append("Product Count");
            text.Append(Environment.NewLine);
            text.Append(_MailingPieceCount.ToString());
            text.Append("\t");
            text.Append(_LocationCount.ToString());
            text.Append("\t");
            text.Append(_PeopleCount.ToString());
            text.Append("\t");
            text.Append(_CompanyProductCount.ToString());
            text.Append("\t");
            text.Append(_ProcutMasterCount.ToString());

            return text.ToString();
        }


        protected string CompressFiles(List<Company> lCompanies)
        {
            string zipName = Path.Combine(GetConfigValue("GenerateLRLFolder"),
                                          GetConfigValue("GenerateLRLCompressFile", string.Format("BBSi LRL Data {0}.zip", DateTime.Now.ToString("yyyyMMdd_HHmm"))));

            using (ZipOutputStream zipOutputStream = new ZipOutputStream(File.Create(zipName)))
            {
                zipOutputStream.SetLevel(9); // 0-9, 9 being the highest compression
                zipOutputStream.Password = GetConfigValue("GenerateLRLZipPassword", "P@ssword1");

                addZipEntry(zipOutputStream, GetConfigValue("GenerateLRLFolder"), GetConfigValue("GenerateLRLCompanyFile", "Base_Company_Data.txt"));
                addZipEntry(zipOutputStream, GetConfigValue("GenerateLRLFolder"), GetConfigValue("GenerateLRLListingFile", "LRL_Listing_Data.txt"));
                addZipEntry(zipOutputStream, GetConfigValue("GenerateLRLFolder"), GetConfigValue("GenerateLRLPersonFile", "LRL_Person_Data.txt"));
                addZipEntry(zipOutputStream, GetConfigValue("GenerateLRLFolder"), GetConfigValue("GenerateLRLPersonFile", "LRL_Company_Product_Data.txt"));
                addZipEntry(zipOutputStream, GetConfigValue("GenerateLRLFolder"), GetConfigValue("GenerateLRLPersonFile", "LRL_Product_Master_Data.txt"));

                addZipEntry(zipOutputStream, GetConfigValue("GenerateLRLFolder"), GetConfigValue("GenerateLRLControlFile", "Control.txt"));

                string logoFolder = GetConfigValue("LogosFolder");
                foreach (Company company in lCompanies)
                {
                    if (!string.IsNullOrEmpty(company.Logo))
                    {
                        addZipEntry(zipOutputStream, logoFolder, company.Logo, GetLogoPathForExport(company.Logo));
                    }
                }

                zipOutputStream.Finish();
                zipOutputStream.IsStreamOwner = true;
                zipOutputStream.Close();
            }

            return zipName;
        }

        protected void GenerateEmail(string fileName)
        {
            string body = string.Format(GetConfigValue("GenerateLRLEmailBody",
                                                       "A new BBSi LRL file, {0}, has been uploaded to {1} and is available for processing."), 
                                        fileName, 
                                        GetConfigValue("LRLFTPServer", "ftp://ftp.bluebookprco.com"));

            SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", GetDBConnnection());
            cmdCreateEmail.CommandType = CommandType.StoredProcedure;
            cmdCreateEmail.Parameters.AddWithValue("To", GetConfigValue("GenerateLRLEmailAddress", "cwalls@travant.com"));
            cmdCreateEmail.Parameters.AddWithValue("Subject", GetConfigValue("GenerateLRLEmailSubject", "New BBSi LRL Files"));
            cmdCreateEmail.Parameters.AddWithValue("Content", body);
            cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
            cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");
            cmdCreateEmail.ExecuteNonQuery();

            if (!string.IsNullOrEmpty(GetConfigValue("GenerateLRLBBSiEmailAddress", string.Empty)))
            {
                body += Environment.NewLine + Environment.NewLine;
                body += GetFormattedControlTotals();

                cmdCreateEmail = new SqlCommand("usp_CreateEmail", GetDBConnnection());
                cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                cmdCreateEmail.Parameters.AddWithValue("To", GetConfigValue("GenerateLRLBBSiEmailAddress"));
                cmdCreateEmail.Parameters.AddWithValue("Subject", GetConfigValue("GenerateLRLEmailSubject", "New BBSi LRL Files"));
                cmdCreateEmail.Parameters.AddWithValue("Content", body);
                cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
                cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");
                cmdCreateEmail.ExecuteNonQuery();
            }
        }

        protected string GetLogoPathForExport(string logo)
        {
            if (!string.IsNullOrEmpty(logo))
            {
                return @"logos\" + logo.Substring(logo.IndexOf(@"\") + 1);
            }

            return logo;
        }

        ReportInterface oRI = null;
        string lrlEmailBody = null;
        protected void EmailLRL(Company company)
        {
            if (oRI == null)
            {
                oRI = new ReportInterface();
            }

            // Setup our supporting files, etc.
            if (lrlEmailBody == null)
            {
                string templatesFolder = GetConfigValue("TemplatesPath");
                using (StreamReader srTemplate = new StreamReader(Path.Combine(templatesFolder, "LRL Email.txt")))
                {
                    lrlEmailBody = srTemplate.ReadToEnd();
                }
            }



            byte[] abReport = oRI.GenerateListingReportLetter(company.CompanyID);

            string lrlFileName = string.Format(GetConfigValue("LRLEmailFileName", "BBSi Listing Report Letter {0}.pdf"), company.CompanyID);

            if (_bIsTest)
            {
                string fullName = Path.Combine(GetConfigValue("GenerateLRLFolder"), lrlFileName);
                WriteFileToDisk(fullName, abReport);

            }
            else
            {
                SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", GetDBConnnection());
                cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                cmdCreateEmail.Parameters.AddWithValue("CreatorUserId", hidUserID.Text);
                cmdCreateEmail.Parameters.AddWithValue("Subject", GetConfigValue("LSLEmailSubject", "Your Listing Report for " + company.Name));
                cmdCreateEmail.Parameters.AddWithValue("RelatedCompanyId", company.CompanyID);
                cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
                cmdCreateEmail.Parameters.AddWithValue("Source", "Generate LRL");
                cmdCreateEmail.Parameters.AddWithValue("To", company.DeliveryAddress);
                cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");
                cmdCreateEmail.Parameters.AddWithValue("Content_Format", "HTML");

                string emailBody = GetFormattedEmail(GetDBConnnection(),
                                              null,
                                              company.CompanyID,
                                              0,
                                              GetConfigValue("LSLEmailSubject", "Your Listing Report for " + company.Name),
                                              lrlEmailBody,
                                              company.Addressee);
                cmdCreateEmail.Parameters.AddWithValue("Content", emailBody);

                WriteFileToDisk(Path.Combine(GetConfigValue("TempReports"), lrlFileName), abReport);
                cmdCreateEmail.Parameters.AddWithValue("@AttachmentFileName", Path.Combine(GetConfigValue("SQLReportPath"), lrlFileName));
                cmdCreateEmail.ExecuteNonQuery();
            }

        }
    }

    public class Company
    {
        public int CompanyID;
        public string Type;
        public long Order;
        public string Logo;
        public string DeliveryType;
        public string Addressee;
        public string DeliveryAddress;
        public string Name;
    }
}
