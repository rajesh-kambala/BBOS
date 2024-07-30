/***********************************************************************
 Copyright Blue Book Services, Inc. 2019

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ImportNewsletterMetrics
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.IO;
using System.Web;

using LumenWorks.Framework.IO.Csv;

namespace PRCo.BBS.CRM.CustomPages.PRGeneral
{
    public partial class ImportNewsletterMetrics : PageBase
    {
        protected string sSID = "";
        protected int _iUserID;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Server.ScriptTimeout = GetConfigValue("BBImportNewsletterMetricsScriptTimeout", 3600);

            lblError.Text = string.Empty;
            lblTotalCount.Text = string.Empty;

            if (!IsPostBack)
            {
                hidUserID.Text = Request["user_userid"];
            }

            _iUserID = int.Parse(hidUserID.Text);

            // Upload link
            this.lnkUpload.NavigateUrl = "javascript:document.forms[0].submit();";
            this.lnkUpload.Text = "Import Newsletter Metrics";

            if (!IsPostBack)
            {
                sSID = Request.Params.Get("SID");
                hidSID.Text = this.sSID;
            }
            else
            {
                sSID = hidSID.Text;
                ProcessForm();
            }
        }

        protected void ProcessForm()
        {
            lblTotalCount.Text = string.Empty;
            lblError.Text = string.Empty;

            string szError = "";

            // Check to see if a file was uploaded
            if (!fileUpload.HasFile)
                szError += "No file found to process<br/>";

            if (txtOrigEmailsSentCount.Text.Length == 0)
                szError += "# Emails Sent is a required field<br/>";

            if (txtSentDate.Text.Length == 0)
                szError += "Date Sent is a required field<br/>";

            if (szError != "")
            {
                lblError.Text = szError;
                return;
            }

            try
            {
                DateTime dtStart = DateTime.Now;
                ProcessFile(fileUpload.PostedFile);
                lblTotalCount.Text = "The file was successfully processed.<br/>";
                lblTotalCount.Text += " - " + _recordCount.ToString("###,###,##0") + " Records Processed.<br/>";
                lblTotalCount.Text += " - " + _insertedCount.ToString("###,###,##0") + " Records Added.<br/>";
                DateTime dtEnd = DateTime.Now;
                lblTotalCount.Text += string.Format("Finished at {0} - elapsed time {1} minutes<br/>", dtEnd.ToShortTimeString(), dtEnd.Subtract(dtStart).TotalMinutes.ToString("F"));
            }
            catch (Exception e)
            {
                lblError.Text = "An unexpected error has occured.  " + e.Message;
                lblError.Text += "<p><pre>" + e.StackTrace + "</pre>";
            }
        }

        protected const string SQL_INSERT_DETAIL =
            @"DECLARE @NewsletterMetricsDetailID int;
              EXEC usp_GetNextId 'PRNewsletterMetricsDetail', @NewsletterMetricsDetailID output;

              INSERT INTO PRNewsletterMetricsDetail 
              (
                    prnlmd_NewsletterMetricsHeaderID, 
                    prnlmd_NewsLetterMetricsDetailID, 
                    prnlmd_CreatedBy, 
                    prnlmd_CreatedDate, 
                    prnlmd_UpdatedBy, 
                    prnlmd_UpdatedDate, 
                    prnlmd_EmailAddress,
                    prnlmd_FirstName,
                    prnlmd_LastName,
                    prnlmd_BBID,
                    prnlmd_State,
                    prnlmd_Country,
                    prnlmd_CSGID,
                    prnlmd_CompanyName,
                    prnlmd_ListingLocation,
                    prnlmd_PrimaryService,
                    prnlmd_Lists,
                    prnlmd_TimeStamp,
                    prnlmd_BounceType,
                    prnlmd_Event,
                    prnlmd_IsMember,
                    prnlmd_BusinessType
                )
                VALUES
                (
                    @NewsletterMetricsHeaderID, 
                    @NewsletterMetricsDetailID, 
                    @UserID, 
                    GETDATE(), 
                    @UserID, 
                    GETDATE(), 
                    @EmailAddress,
                    @FirstName,
                    @LastName,
                    @BBID,
                    @State,
                    @Country,
                    @CSGID,
                    @CompanyName,
                    @ListingLocation,
                    @PrimaryService,
                    @Lists,
                    @TimeStamp,
                    @BounceType,
                    @Event,
                    NULL,
                    NULL
                );
            ";

        protected const string SQL_UPDATE_DETAIL_SUFFIX =
            @"UPDATE PRNewsletterMetricsDetail 
				SET prnlmd_IsMember = 
					CASE WHEN EXISTS(SELECT * FROM PRService WITH (NOLOCK) WHERE prse_CompanyID=prnlmd_BBID AND prse_Primary='Y') THEN 1 ELSE 0 END
				WHERE prnlmd_NewsletterMetricsHeaderID=@NewsletterMetricsHeaderID;

			UPDATE PRNewsletterMetricsDetail 
				SET prnlmd_BusinessType = 
					CASE WHEN EXISTS(SELECT * FROM PRCompanyClassification WITH (NOLOCK) INNER JOIN PRClassification WITH (NOLOCK) ON prc2_ClassificationId = prcl_ClassificationId AND prcl_Name='Retail' WHERE prc2_CompanyID = prnlmd_BBID)
					THEN
						'Retailer'
					ELSE
						CASE (SELECT comp_PRIndustryType FROM Company WITH (NOLOCK) WHERE comp_CompanyID = prnlmd_BBID)
							WHEN 'P' THEN 'Produce (not Retailer)'
							WHEN 'T' THEN 'Transportation'
							WHEN 'S' THEN 'Supply/Service'
							ELSE 'Unknown'
						END
					END
				WHERE prnlmd_NewsletterMetricsHeaderID=@NewsletterMetricsHeaderID;
            ";

        private int _recordCount = 0;
        private int _insertedCount = 0;

        private SqlCommand cmdInsert = null;
        protected int ProcessFile(HttpPostedFile oPostedFile)
        {
            SqlConnection dbConn = null;
            SqlTransaction dbTran = null;

            int lastBBIDProcessed = 0;
            int lastRowProcessed = 0;

            try
            {
                List<NewsletterMetric> newsletterMetrics = LoadData(oPostedFile.InputStream);

                dbConn = OpenDBConnection();
                dbTran = dbConn.BeginTransaction();

                int prnlmh_NewsletterMetricsHeaderID = HeaderExists(txtSentDate.Text, dbConn, dbTran);

                if (prnlmh_NewsletterMetricsHeaderID > 0)
                {
                    //Remove existing detail records, then re-import new file
                    DeleteDetails(prnlmh_NewsletterMetricsHeaderID, dbConn, dbTran);
                    UpdateHeader(prnlmh_NewsletterMetricsHeaderID, txtSentDate.Text, Convert.ToInt32(txtOrigEmailsSentCount.Text), dbConn, dbTran);
                }
                else
                {
                    //Create new header record
                    prnlmh_NewsletterMetricsHeaderID = InsertHeader(txtSentDate.Text, Convert.ToInt32(txtOrigEmailsSentCount.Text), dbConn, dbTran);
                }

                foreach (NewsletterMetric newsletterMetric in newsletterMetrics)
                {
                    lastBBIDProcessed = newsletterMetric.BBID;
                    lastRowProcessed++;

                    if (cmdInsert == null)
                    {
                        cmdInsert = new SqlCommand(SQL_INSERT_DETAIL, dbConn, dbTran);
                    }

                    cmdInsert.Parameters.Clear();
                    AddParameters(prnlmh_NewsletterMetricsHeaderID, newsletterMetric, cmdInsert);
                    cmdInsert.ExecuteNonQuery();
                    _insertedCount++;
                }

                SqlCommand cmdUpdate = new SqlCommand(SQL_UPDATE_DETAIL_SUFFIX, dbConn, dbTran);
                cmdUpdate.Parameters.AddWithValue("@NewsletterMetricsHeaderID", prnlmh_NewsletterMetricsHeaderID);
                cmdUpdate.ExecuteNonQuery();

                if (GetConfigValue("ImportNewsletterMetricsCommit", true)) 
                {
                    dbTran.Commit();
                }
                else
                {
                    dbTran.Rollback();
                }
                return 0;
                
            }
            catch
            {
                lblTotalCount.Text += "Last BBID Before Error: " + lastBBIDProcessed.ToString();
                lblTotalCount.Text += "<br/>Last Row Processed Before Error: " + lastRowProcessed.ToString();
                if (dbTran != null)
                {
                    dbTran.Rollback();
                }
                throw;
            }
            finally
            {
                if (dbConn != null)
                {
                    dbConn.Close();
                }
            }
        }

        private List<NewsletterMetric> LoadData(System.IO.Stream inputStream)
        {
            List<NewsletterMetric> newsletterMetrics = new List<NewsletterMetric>();

            using (CsvReader csv = new CsvReader(new StreamReader(inputStream), true))
            {
                csv.SupportsMultiline = true;

                int fieldCount = csv.FieldCount;

                while (csv.ReadNextRecord())
                {
                    _recordCount++;

                    NewsletterMetric newsletterMetric = new NewsletterMetric();
                    newsletterMetrics.Add(newsletterMetric);

                    newsletterMetric.EmailAddress = csv["Email Address"];
                    newsletterMetric.FirstName = csv["First Name"];
                    newsletterMetric.LastName = csv["Last Name"];

                    int _BBID = 0;
                    if (!int.TryParse(csv["BBID"], out _BBID))
                    {
                        newsletterMetric.BBID = 0;
                    }
                    else
                        newsletterMetric.BBID = _BBID;

                    newsletterMetric.State = csv["State"];
                    newsletterMetric.Country = csv["Country"];
                    newsletterMetric.CSGID = csv["CSG ID"];
                    newsletterMetric.CompanyName = csv["Company_Name"];
                    newsletterMetric.ListingLocation = csv["Listing_Location"];
                    newsletterMetric.PrimaryService = csv["Primary_Service"];
                    newsletterMetric.Lists = csv["Lists"];

                    DateTime dtTmp = DateTime.MinValue;
                    if (!DateTime.TryParse(csv["Timestamp"], out dtTmp))
                    {
                        throw new ApplicationException("Record " + _recordCount.ToString("###,##0") + ", BBID " + csv["BBID"] + " - Invalid Timestamp found: " + csv["Timestamp"]);
                    }
                    newsletterMetric.TimeStamp = Convert.ToDateTime(csv["Timestamp"]);

                    if(!ColumnExists(csv, "Bounce Type"))
                        newsletterMetric.BounceType = "";
                    else
                        newsletterMetric.BounceType = csv["Bounce Type"];

                    if (!ColumnExists(csv, "Event"))
                        newsletterMetric.Event = "";
                    else
                        newsletterMetric.Event = csv["Event"];
                }
            }

            return newsletterMetrics;
        }
        public bool ColumnExists(CsvReader reader, string columnName)
        {
            string[] fieldHeaders = reader.GetFieldHeaders();
            for (int i = 0; i < reader.FieldCount; i++)
            {
                if (fieldHeaders[i].Equals(columnName, StringComparison.InvariantCultureIgnoreCase))
                {
                    return true;
                }
            }

            return false;
        }

        protected const string SQL_HEADER_EXISTS =
            @"SELECT prnlmh_NewsletterMetricsHeaderID
              FROM PRNewsletterMetricsHeader WITH (NOLOCK)
              WHERE prnlmh_SentDate = @SentDate";
        protected const string SQL_HEADER_EXISTS_BYID =
            @"SELECT prnlmh_NewsletterMetricsHeaderID
              FROM PRNewsletterMetricsHeader WITH (NOLOCK)
              WHERE prnlmh_NewsletterMetricsHeaderID = @prnlmh_NewsletterMetricsHeaderID";

        /// <summary>
        /// Header Exists
        /// </summary>
        /// <param name="szSentDate"></param>
        /// <param name="dbConn"></param>
        /// <param name="dbTran"></param>
        /// <returns>0 if not found, prnlmh_NewsletterMetricsHeaderID if found </returns>
        private int HeaderExists(string szSentDate, SqlConnection dbConn, SqlTransaction dbTran)
        {
            SqlCommand cmdExists = new SqlCommand(SQL_HEADER_EXISTS, dbConn, dbTran);

            cmdExists.Parameters.Clear();
            cmdExists.Parameters.AddWithValue("@SentDate", szSentDate);

            object result = cmdExists.ExecuteScalar();
            if (result == null)
            {
                return 0;
            }

            return (int)result;
        }
        private int HeaderExists(int prnlmh_NewsletterMetricsHeaderID, SqlConnection dbConn, SqlTransaction dbTran)
        {
            SqlCommand  cmdExists = new SqlCommand(SQL_HEADER_EXISTS_BYID, dbConn, dbTran);

            cmdExists.Parameters.Clear();
            cmdExists.Parameters.AddWithValue("@prnlmh_NewsletterMetricsHeaderID", prnlmh_NewsletterMetricsHeaderID);

            object result = cmdExists.ExecuteScalar();
            if (result == null)
            {
                return 0;
            }

            return (int)result;
        }

        protected const string SQL_DELETE_HEADER =
            @"DELETE FROM PRNewsletterMetricsHeader
                WHERE prnlmh_NewsLetterMetricsHeaderID=@prnlmh_NewsletterMetricsHeaderID";

        private void DeleteHeader(int prnlmh_NewsletterMetricsHeaderID, SqlConnection dbConn, SqlTransaction dbTran)
        {
            if (HeaderExists(prnlmh_NewsletterMetricsHeaderID, dbConn, dbTran) == 0)
                return;

            SqlCommand cmdDeleteHeader = new SqlCommand(SQL_DELETE_HEADER, dbConn, dbTran);

            cmdDeleteHeader.Parameters.Clear();
            cmdDeleteHeader.Parameters.AddWithValue("@prnlmh_NewsletterMetricsHeaderID", prnlmh_NewsletterMetricsHeaderID);

            object result = cmdDeleteHeader.ExecuteScalar();
        }

        protected const string SQL_UPDATE_HEADER =
    @"UPDATE PRNewsletterMetricsHeader 
                SET 
                    prnlmh_SentDate=@prnlmh_SentDate,
                    prnlmh_EmailCount=@prnlmh_EmailCount
                WHERE prnlmh_NewsletterMetricsHeaderID=@prnlmh_NewsletterMetricsHeaderID";

        private void UpdateHeader(int prnlmh_NewsletterMetricsHeaderID, string szSentDate, int recordCount, SqlConnection dbConn, SqlTransaction dbTran)
        {
            SqlCommand cmdUpdateHeader = new SqlCommand(SQL_UPDATE_HEADER, dbConn, dbTran);

            cmdUpdateHeader.Parameters.Clear();
            cmdUpdateHeader.Parameters.AddWithValue("@prnlmh_NewsletterMetricsHeaderID", prnlmh_NewsletterMetricsHeaderID);
            cmdUpdateHeader.Parameters.AddWithValue("@prnlmh_SentDate", szSentDate);
            cmdUpdateHeader.Parameters.AddWithValue("@prnlmh_EmailCount", recordCount);

            object result = cmdUpdateHeader.ExecuteNonQuery();
        }

        protected const string SQL_INSERT_HEADER =
            @"DECLARE @prnlmh_NewsletterMetricsHeaderID int;
              EXEC usp_GetNextId 'PRNewsletterMetricsHeader', @prnlmh_NewsletterMetricsHeaderID output;
              INSERT INTO PRNewsletterMetricsHeader (prnlmh_NewsletterMetricsHeaderID, prnlmh_SentDate, prnlmh_EmailCount)
                VALUES (@prnlmh_NewsletterMetricsHeaderID, @SentDate, @RecordCount);
              SELECT @prnlmh_NewsletterMetricsHeaderID;
             ";



        private int InsertHeader(string szSentDate, int recordCount, SqlConnection dbConn, SqlTransaction dbTran)
        {
            SqlCommand cmdInsertHeader = new SqlCommand(SQL_INSERT_HEADER, dbConn, dbTran);

            cmdInsertHeader.Parameters.Clear();
            cmdInsertHeader.Parameters.AddWithValue("@SentDate", szSentDate);
            cmdInsertHeader.Parameters.AddWithValue("@RecordCount", recordCount);

            object result = cmdInsertHeader.ExecuteScalar();
            return (int)result;
        }

        protected const string SQL_DELETE_DETAILS =
            @"DELETE FROM PRNewsletterMetricsDetail
                WHERE prnlmd_NewsletterMetricsHeaderID=@prnlmd_NewsletterMetricsHeaderID";

        private void DeleteDetails(int prnlmd_NewsletterMetricsHeaderID, SqlConnection dbConn, SqlTransaction dbTran)
        {
            if (HeaderExists(prnlmd_NewsletterMetricsHeaderID, dbConn, dbTran) == 0)
                return;

            SqlCommand cmdDeleteHeader = new SqlCommand(SQL_DELETE_DETAILS, dbConn, dbTran);

            cmdDeleteHeader.Parameters.Clear();
            cmdDeleteHeader.Parameters.AddWithValue("@prnlmd_NewsletterMetricsHeaderID", prnlmd_NewsletterMetricsHeaderID);

            object result = cmdDeleteHeader.ExecuteScalar();
        }

        private void AddParameters(int NewsletterMetricsHeaderID, NewsletterMetric newsletterMetric, SqlCommand sqlCommand)
        {
            sqlCommand.Parameters.AddWithValue("@NewsletterMetricsHeaderID", NewsletterMetricsHeaderID);
            sqlCommand.Parameters.AddWithValue("@UserID", _iUserID);
            sqlCommand.Parameters.AddWithValue("@EmailAddress", newsletterMetric.EmailAddress);
            sqlCommand.Parameters.AddWithValue("@FirstName", newsletterMetric.FirstName);
            sqlCommand.Parameters.AddWithValue("@LastName", newsletterMetric.LastName);
            sqlCommand.Parameters.AddWithValue("@BBID", newsletterMetric.BBID);
            sqlCommand.Parameters.AddWithValue("@State", newsletterMetric.State);
            sqlCommand.Parameters.AddWithValue("@Country", newsletterMetric.Country);
            sqlCommand.Parameters.AddWithValue("@CSGID", newsletterMetric.CSGID);
            sqlCommand.Parameters.AddWithValue("@CompanyName", newsletterMetric.CompanyName);
            sqlCommand.Parameters.AddWithValue("@ListingLocation", newsletterMetric.ListingLocation);
            sqlCommand.Parameters.AddWithValue("@PrimaryService", newsletterMetric.PrimaryService);
            sqlCommand.Parameters.AddWithValue("@Lists", newsletterMetric.Lists);
            sqlCommand.Parameters.AddWithValue("@Timestamp", newsletterMetric.TimeStamp);
            sqlCommand.Parameters.AddWithValue("@BounceType", newsletterMetric.BounceType);
            sqlCommand.Parameters.AddWithValue("@Event", newsletterMetric.Event);
        }
    }

    public class NewsletterMetric
    {
        public string EmailAddress { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public int BBID { get; set; }
        public string State { get; set; }
        public string Country { get; set; }
        public string CSGID { get; set; }
        public string CompanyName { get; set; }
        public string ListingLocation { get; set; }
        public string PrimaryService { get; set; }
        public string Lists{ get; set; }
        public DateTime TimeStamp{ get; set; }
        public string BounceType { get; set; }
        public string Event{ get; set; }
    }

    public class NewsletterMetricHeader
    {
        public int NewsletterMetricsHeaderID { get; set; }
        public DateTime SentDate { get; set; }
        public int EmailCount { get; set; }
    }
}