/***********************************************************************
 Copyright Produce Reporter Company 2006-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRTESFormBatchView
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections;
using System.IO;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;

using ICSharpCode.SharpZipLib.Zip;

namespace PRCo.BBS.CRM
{
    /// <summary>
    /// Provides the functionality to generate TES Form Batches and 
    /// to also generate the data file extracts
    /// </summary>
    public partial class PRTESFormBatchView : PageBase
    {
        protected const string SQL_BATCH_LIST = "SELECT TOP {0} prtfb_TESFormBatchID, prtfb_CreatedDate, prtfb_LastFileCreation, COUNT(1) AS FormCount FROM PRTESFormBatch WITH (NOLOCK) INNER JOIN PRTESForm WITH (NOLOCK) on prtfb_TESFormBatchID = prtf_TESFormBatchID GROUP BY prtfb_TESFormBatchID, prtfb_CreatedDate, prtfb_LastFileCreation ORDER BY prtfb_TESFormBatchID DESC;";
        protected const string SQL_CREATE_BATCH = "usp_GenerateTESFormBatch";
        protected const string SQL_SELECT_FORM_EXTRACT = "SELECT * FROM vPRTESFormExtract WHERE prtf_TESFormBatchID=@Parm01 AND prtf_FormType=@Parm02 ORDER BY Responderprcn_Country, Responderprst_Abbreviation, Responderprci_City, prtf_CompanyID, prtf_SerialNumber, prtesr_SubjectCompanyID";
        protected const string SQL_UPDATE_BATCH = "UPDATE PRTESFormBatch SET prtfb_LastFileCreation = GETDATE(), prtfb_UpdatedDate=GETDATE(), prtfb_TimeStamp=GETDATE() WHERE prtfb_TESFormBatchID=@Parm01;";
        protected const string SQL_UPDATE_FORM = "UPDATE PRTESForm SET prtf_SentMethod = @PARM02, prtf_SentDateTime = GETDATE(), prtf_UpdatedDate=GETDATE(), prtf_TimeStamp=GETDATE() WHERE prtf_TESFormBatchID=@Parm01;";
        protected const string SQL_SENT_METHOD = "SELECT RTRIM(capt_code) AS capt_code, capt_us FROM Custom_Captions WITH (NOLOCK) WHERE capt_family = 'prtf_SentMethod' ORDER BY capt_us";

        protected const string FORM_SINGLE_ENGLISH = "SE";
        protected const string FORM_SINGLE_SPANISH = "SS";
        protected const string FORM_SINGLE_INTERNATIONAL = "SI";

        protected const string FORM_MULTIPLE_ENGLISH = "ME";
        protected const string FORM_MULTIPLE_SPANISH = "MS";
        protected const string FORM_MULTIPLE_INTERNATIONAL = "MI";


        private string _responderDataFile, _subjectDataFile, _TESControlFile;
        private const string NEWLINE = "\r\n";

        protected const string SQL_SELECT_RESPONDER_DATA =
                                             "SELECT DISTINCT " +
                                                    "prtfb_TESFormBatchID " +
                                                    ",FormType " +
                                                    ",prtf_SerialNumber " +
                                                    ",ResponderBBID " +
                                                    ",Attention " +
                                                    ",ResponderName " +
                                                    ",[Addr1] " +
                                                    ",[Addr2] " +
                                                    ",[Addr3] " +
                                                    ",[Addr4] " +
                                                    ",[City] " +
                                                    ",[State] " +
                                                    ",[Country] " +
                                                    ",[Zip] " +
                                             "FROM vPRTESExtract " +
                                            "WHERE prtfb_TESFormBatchID = {0} " +
                                         "ORDER BY FormType, prtf_SerialNumber";
        
        protected const string SQL_SELECT_SUBJECT_DATA =
                                            "SELECT " +
                                                    "prtfb_TESFormBatchID, " +
                                                    "prtf_SerialNumber, " +
                                                    "SubjectBBID, " +
                                                    "SubjectCompanyName,  " +
                                                    "SubjectListingLocation  " +
                                             "FROM vPRTESExtract " +
                                            "WHERE prtfb_TESFormBatchID = {0} " +
                                         "ORDER BY FormType, prtf_SerialNumber";


        protected System.Web.UI.HtmlControls.HtmlGenericControl pnlBatchesFooter;

        override protected void Page_Load(object sender, EventArgs e)
        {
            Server.ScriptTimeout = GetConfigValue("TESDocumatchScriptTimeout", 3600);

            base.Page_Load(sender, e);
            lblMessage.Text = string.Empty;

            if (!IsPostBack)
            {
                hidSID.Text = Request.Params.Get("SID");
                PopulateForm();

                //  For some reason for LinkButtons, the __doPostBack() method is not found whe invoked from the
                //  href attribute, even though it is defined in the rendered HTML.  To get around this we are
                //  invoking the __doPostBack() from client-side JS functions.
                imgbtnGenerateBatch.ImageUrl = "/" + this._szAppName + "/img/Buttons/Continue.gif";
                btnGenerateBatch.OnClientClick = "return GenerateBatch();";

                imgbtnGenerateFiles.ImageUrl = "/" + this._szAppName + "/img/Buttons/Continue.gif";
                btnGenerateFiles.OnClientClick = "return GenerateFiles()";

                imgbtnNewGenerateFiles.ImageUrl = "/" + this._szAppName + "/img/Buttons/Continue.gif";
                btnNewGenerateFiles.OnClientClick = "return GenerateMailHouseFiles()";
                
            }
        }


        protected const string SQL_REQUEST_COUNT =
            "SELECT COUNT(1) As RequestCount " +
	          "FROM PRTESRequest WITH (NOLOCK)  " +
	         "WHERE prtesr_TESFormID IS NULL " +
               "AND prtesr_SentMethod = 'M';";

        /// <summary>
        /// Populates the form with the available list
        /// of batches.
        /// </summary>
        protected void PopulateForm()  {

            SqlConnection dbConn = OpenDBConnection();
            try {

                string szSQL = string.Format(SQL_BATCH_LIST, GetBatchListMax());

                using (SqlDataReader oReader = new SqlCommand(szSQL, dbConn).ExecuteReader(CommandBehavior.Default))
                {
                    repBatches.DataSource = oReader;
                    repBatches.DataBind();
                }

                pnlBatchesFooter.Visible = false;  
                if (repBatches.Items.Count == 0) {
                    pnlBatchesFooter.Visible = true;                     
                }

                SqlCommand cmdRequestCount = new SqlCommand(SQL_REQUEST_COUNT, dbConn);
                object oCount = cmdRequestCount.ExecuteScalar();
                hidTESRequestCount.Value = Convert.ToInt32(oCount).ToString("###,##0");


            } catch (Exception e) {
                lblMessage.Text = "An Unexpected Error Has Occurred: " + e.Message + "<p><pre>" + e.StackTrace + "<pre></p>";
            } finally {
                CloseDBConnection(dbConn);
            }
        }

        /// <summary>
        /// Event handler that generates TES Batch and TES Form records.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnGenerateBatchOnClick(Object sender, EventArgs e)
        {
            int iCount = 0;
            int iBatchID = 0;

            SqlConnection dbConn = OpenDBConnection();
            SqlCommand dbCmd = new SqlCommand(SQL_CREATE_BATCH, dbConn);
            dbCmd.Parameters.AddWithValue("@SentMethod", "M");
            dbCmd.Parameters.AddWithValue("@Source", "BBScore,NC,MI");
            dbCmd.CommandTimeout = GetConfigValue("TESDocumatchGenerateBatchSQLTimeout", 600);
            dbCmd.CommandType = CommandType.StoredProcedure;

            SqlDataReader oReader = dbCmd.ExecuteReader(CommandBehavior.CloseConnection);
            try {
                if (oReader.Read()) {
                    if (oReader[0] != DBNull.Value) {
                        iBatchID = oReader.GetInt32(0);
                        iCount = oReader.GetInt32(1);
                    }
                }
            } catch (Exception eX) {
                lblMessage.Text = "An Unexpected Error Has Occurred: " + eX.Message;
            } finally {
                oReader.Close();
            }


            if (iCount == 0) {
                lblMessage.Text = "No pending TES requests were found so a batch was not created.";
            } else {
                lblMessage.Text = string.Format("Batch {0} was created with {1} forms.", iBatchID, iCount);
                PopulateForm();
            }
        }


        /// <summary>
        /// Event handler that generates a creates new TES Batch records.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnGenerateFilesOnClick(Object sender, EventArgs e) {

            if (string.IsNullOrEmpty(Request.Params.Get("rbFormBatchID"))) {
                lblMessage.Text = "Please select a TES Form Batch.";
                return;
            }

            int iBatchID = Int32.Parse(Request.Params.Get("rbFormBatchID"));

            SqlConnection dbConn = OpenDBConnection();

            try {

                GenerateFormSingleFile(dbConn, iBatchID, FORM_SINGLE_ENGLISH);
                GenerateFormSingleFile(dbConn, iBatchID, FORM_SINGLE_SPANISH);
                GenerateFormSingleFile(dbConn, iBatchID, FORM_SINGLE_INTERNATIONAL);
                GenerateFormMultipleFile(dbConn, iBatchID, FORM_MULTIPLE_ENGLISH);
                GenerateFormMultipleFile(dbConn, iBatchID, FORM_MULTIPLE_SPANISH);
                GenerateFormMultipleFile(dbConn, iBatchID, FORM_MULTIPLE_INTERNATIONAL);

                // Update the batch so we know that the extracts were created.
                SqlCommand dbCmd = new SqlCommand(SQL_UPDATE_BATCH, dbConn);
                dbCmd.Parameters.Add(new SqlParameter("Parm01", iBatchID));
                dbCmd.ExecuteNonQuery();

                // Update the batch so we know that the extracts were created.
                dbCmd = new SqlCommand(SQL_UPDATE_FORM, dbConn);
                dbCmd.Parameters.Add(new SqlParameter("Parm01", iBatchID));
                dbCmd.Parameters.Add(new SqlParameter("Parm02", "M"));
                dbCmd.ExecuteNonQuery();

                lblMessage.Text = "Files created successfully for batch " + iBatchID.ToString() + " at " + GetConfigValue("TESDocumatchExtractFolder");
                PopulateForm();
            } catch (Exception eX) {
                lblMessage.Text = "An Unexpected Error Has Occurred: " + eX.Message;
            } finally {
                CloseDBConnection(dbConn);
            }
        }

        protected void btnNewGenerateFilesOnClick(Object sender, EventArgs e)
        {

            if (string.IsNullOrEmpty(Request.Params.Get("rbFormBatchID")))
            {
                lblMessage.Text = "Please select a TES Form Batch.";
                return;
            }

            int iBatchID = Int32.Parse(Request.Params.Get("rbFormBatchID"));
            string fileDate = DateTime.Now.ToString("yyyyMMdd");

            SqlConnection dbConn = OpenDBConnection();

            try
            {
                _responderDataFile = Path.Combine(GetConfigValue("TESDocumatchExtractFolder"),
                                       GetConfigValue("TESResponderDataFile", "TES_Responder_Data.txt"));

                if (File.Exists(_responderDataFile))
                    File.Delete(_responderDataFile);

                WriteResponderDataHeader();
                GenerateResponderData(dbConn, iBatchID, fileDate);

                _subjectDataFile = Path.Combine(GetConfigValue("TESDocumatchExtractFolder"),
                                         GetConfigValue("TESSubjectDataFile", "TES_Subject_Data.txt"));

                if (File.Exists(_subjectDataFile))
                    File.Delete(_subjectDataFile);

                WriteSubjectDataHeader();
                GenerateSubjectData(dbConn, iBatchID, fileDate);


                // Update the batch so we know that the extracts were created.
                SqlCommand dbCmd = new SqlCommand(SQL_UPDATE_BATCH, dbConn);
                dbCmd.Parameters.Add(new SqlParameter("Parm01", iBatchID));
                dbCmd.ExecuteNonQuery();

                // Update the batch so we know that the extracts were created.
                dbCmd = new SqlCommand(SQL_UPDATE_FORM, dbConn);
                dbCmd.Parameters.Add(new SqlParameter("Parm01", iBatchID));
                dbCmd.Parameters.Add(new SqlParameter("Parm02", "M"));
                dbCmd.ExecuteNonQuery();


                GenerateControlCountFile(dbConn, iBatchID);

                string ftpFileName = CompressFiles();
                //UploadFile(GetConfigValue("TESFTPServer", "ftp://ftp.bluebookprco.com"),
                //           GetConfigValue("TESFTPUsername", "qa"),
                //           GetConfigValue("TESFTPPassword", "qA$1901"),
                //           ftpFileName);

                UploadFileSFTP(GetConfigValue("TESFTPServer", "ftp://ftp.bluebookservices.com"),
                               22,
                               GetConfigValue("TESFTPUsername", "qa"),
                               GetConfigValue("TESFTPPassword", "qA$1901"),
                               ftpFileName,
                               Path.GetFileName(ftpFileName));

                GenerateEmail(Path.GetFileName(ftpFileName));

                lblMessage.Text = "Files created successfully for batch " + iBatchID.ToString() + " at " + GetConfigValue("TESDocumatchExtractFolder");
                PopulateForm();
            }
            catch (Exception eX)
            {
                lblMessage.Text = "An Unexpected Error Has Occurred: " + eX.Message + "<p><pre>" + eX.StackTrace + "</pre></p>";
            }
            finally
            {
                CloseDBConnection(dbConn);
            }
        }

        protected void GenerateResponderData(SqlConnection dbConn, int iBatchID, string fileDate)
        {

             //Get base company data.
            string szSQL = string.Format(SQL_SELECT_RESPONDER_DATA, iBatchID);

            SqlCommand cmdResponderData = new SqlCommand(szSQL, dbConn);
            cmdResponderData.CommandTimeout = 60 * 60;

            using (IDataReader drResponderData = cmdResponderData.ExecuteReader(CommandBehavior.Default))
            {
                while (drResponderData.Read())
                {
                    StringBuilder text = new StringBuilder();

                    text.Append(GetIntValue(drResponderData, "prtfb_TESFormBatchID"));
                    text.Append("\t");
                    text.Append(fileDate);
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "FormType"));
                    text.Append("\t");
                    text.Append(GetIntValue(drResponderData, "prtf_SerialNumber"));
                    text.Append("\t");
                    text.Append(GetIntValue(drResponderData, "ResponderBBID"));
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "Attention"));
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "ResponderName"));
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "Addr1"));
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "Addr2"));
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "Addr3"));
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "Addr4"));
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "City"));
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "State"));
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "Country"));
                    text.Append("\t");
                    text.Append(GetStringValue(drResponderData, "Zip"));
                    text.Append(PRTESFormBatchView.NEWLINE);

                    WriteToFile(_responderDataFile, text.ToString());
                }
            }
        }

        protected void GenerateSubjectData(SqlConnection dbConn, int iBatchID, string fileDate)
        {

            //Get base company data.
            string szSQL = string.Format(SQL_SELECT_SUBJECT_DATA, iBatchID);

            SqlCommand cmdSubjectData = new SqlCommand(szSQL, dbConn);
            cmdSubjectData.CommandTimeout = 60 * 60;

            using (IDataReader drSubjectData = cmdSubjectData.ExecuteReader(CommandBehavior.Default))
            {
                while (drSubjectData.Read())
                {
                    StringBuilder text = new StringBuilder();

                    text.Append(GetIntValue(drSubjectData, "prtfb_TESFormBatchID"));
                    text.Append("\t");
                    text.Append(fileDate);
                    text.Append("\t");
                    text.Append(GetIntValue(drSubjectData, "prtf_SerialNumber"));
                    text.Append("\t");
                    text.Append(GetIntValue(drSubjectData, "SubjectBBID"));
                    text.Append("\t");
                    text.Append(GetStringValue(drSubjectData, "SubjectCompanyName"));
                    text.Append("\t");
                    text.Append(GetStringValue(drSubjectData, "SubjectListingLocation"));
                    text.Append(PRTESFormBatchView.NEWLINE);

                    WriteToFile(_subjectDataFile, text.ToString());
                }
            }
        }

        /// <summary>
        /// Generates a file in the "Single" format for the specified form type
        /// data.
        /// </summary>
        /// <param name="dbConn"></param>
        /// <param name="iBatchID"></param>
        /// <param name="szFormType"></param>
        protected void GenerateFormSingleFile(SqlConnection dbConn, int iBatchID, string szFormType) {

            int iLineCount = 0;
            string szDate = DateTime.Now.ToString("yyyyMMdd");
            ArrayList alOuputString = new ArrayList();

            SqlDataReader oReader = GetDataReader(dbConn, iBatchID, szFormType);
            
            try {
                while (oReader.Read()) {
                    iLineCount = 0;

                    AddLineToOutput(alOuputString,
                                    GetString(oReader["prtf_SerialNumber"]).PadLeft(8, '0') + " " + oReader["prtesr_SubjectCompanyID"] + " " + oReader["prtf_CompanyID"] + " " + szDate,
                                    ref iLineCount);

                    AddRecipientInfo(alOuputString, oReader, ref iLineCount, 7);

                    AddLineToOutput(alOuputString, "BB #" + GetString(oReader["prtesr_SubjectCompanyID"]), ref iLineCount);
                    AddSubjectInfo(alOuputString, oReader, ref iLineCount, 4, true);

                    alOuputString.Add("\f");
                }
            } finally {
                oReader.Close();
            }

            CreateExtractFile(alOuputString, szFormType);
        }

        /// <summary>
        /// Generates a file in the "Multiple" format for the specified form type
        /// data.
        /// </summary>
        /// <param name="dbConn"></param>
        /// <param name="iBatchID"></param>
        /// <param name="szFormType"></param>
        protected void GenerateFormMultipleFile(SqlConnection dbConn, int iBatchID, string szFormType) {

            int iLineCount = 0;
            int iSaveSerialNumber = 0;
            ArrayList alOuputString = new ArrayList();
            
            SqlDataReader oReader = GetDataReader(dbConn, iBatchID, szFormType);

            try {
                while (oReader.Read()) {
                    iLineCount = 0;

                    // If we have a new serial number, write out the new recipient
                    // info
                    if (iSaveSerialNumber != Convert.ToInt32(oReader["prtf_SerialNumber"])) {

                        // We need the form feed only if this isn't our first 
                        // time here.
                        if (iSaveSerialNumber > 0) {
                            alOuputString.Add("\f");
                        }

                        iSaveSerialNumber = Convert.ToInt32(oReader["prtf_SerialNumber"]);
                        AddLineToOutput(alOuputString,
                                        GetString(oReader["prtf_SerialNumber"]).PadLeft(8, '0') + " " + oReader["prtf_CompanyID"],
                                        ref iLineCount);

                        AddRecipientInfo(alOuputString, oReader, ref iLineCount, 7);
                    }

                    AddLineToOutput(alOuputString, GetString(oReader["prtesr_SubjectCompanyID"]), ref iLineCount);
                    AddSubjectInfo(alOuputString, oReader, ref iLineCount, 4, true);
                }

                // Make sure we have our final form feed
                if (iSaveSerialNumber > 0) {
                    alOuputString.Add("\f");
                }

            } finally {
                oReader.Close();
            }

            CreateExtractFile(alOuputString, szFormType);
        }




        protected void WriteResponderDataHeader()
        {
            StringBuilder text = new StringBuilder();

            text.Append("BatchID");
            text.Append("\t");
            text.Append("Created Date");
            text.Append("\t");
            text.Append("Form Type");
            text.Append("\t");
            text.Append("Serial Number");
            text.Append("\t");
            text.Append("Responder BBID");
            text.Append("\t");
            text.Append("Attention");
            text.Append("\t");
            text.Append("Company Name");
            text.Append("\t");
            text.Append("Addr1");
            text.Append("\t");
            text.Append("Addr2");
            text.Append("\t");
            text.Append("Addr3");
            text.Append("\t");
            text.Append("Addr4");
            text.Append("\t");
            text.Append("City");
            text.Append("\t");
            text.Append("State");
            text.Append("\t");
            text.Append("Country");
            text.Append("\t");
            text.Append("Zip");
            text.Append(PRTESFormBatchView.NEWLINE);

            WriteToFile(_responderDataFile, text.ToString());
        }

        protected void WriteSubjectDataHeader()
        {
            StringBuilder text = new StringBuilder();

            text.Append("BatchID");
            text.Append("\t");
            text.Append("Created Date");
            text.Append("\t");
            text.Append("Serial Number");
            text.Append("\t");
            text.Append("Subject BBID");
            text.Append("\t");
            text.Append("Subject Company Name");
            text.Append("\t");
            text.Append("Listing Location");
            text.Append(PRTESFormBatchView.NEWLINE);

            WriteToFile(_subjectDataFile, text.ToString());
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

        /// <summary>
        /// Helper function that writes the specified text to the
        /// specified file
        /// </summary>
        /// <param name="szFileName"></param>
        /// <param name="szContent"></param>
        private void WriteToFile(string szFileName, string szContent)
        {
            File.AppendAllText(szFileName, szContent);
        }



        /// <summary>
        /// Writes the string list to the extract file based on the
        /// form type.
        /// </summary>
        /// <param name="alOuputString"></param>
        /// <param name="szFormType"></param>
        protected void CreateExtractFile(ArrayList alOuputString, string szFormType) {
            using (StreamWriter sw = new StreamWriter(GetFileName(szFormType))) {
                foreach (string szLine in alOuputString) {
                    sw.WriteLine(szLine);
                }
            } 
        }

        /// <summary>
        /// Returns an open DataReader executed for the specified batch 
        /// and form type.
        /// </summary>
        /// <param name="dbConn"></param>
        /// <param name="iBatchID"></param>
        /// <param name="szFormType"></param>
        /// <returns></returns>
        protected SqlDataReader GetDataReader(SqlConnection dbConn, int iBatchID, string szFormType) {
            SqlCommand dbCmd = new SqlCommand(SQL_SELECT_FORM_EXTRACT, dbConn);

            dbCmd.Parameters.Add(new SqlParameter("Parm01", iBatchID));
            dbCmd.Parameters.Add(new SqlParameter("Parm02", szFormType));

            return dbCmd.ExecuteReader(CommandBehavior.Default);
        }

        /// <summary>
        /// Adds the recipient information to the string list.  Ensures the correct number
        /// of lines are accounted for.
        /// </summary>
        /// <param name="alOuputString"></param>
        /// <param name="oReader"></param>
        /// <param name="iLineCount"></param>
        /// <param name="iNumberRequiredLines"></param>
        protected void AddRecipientInfo(ArrayList alOuputString, SqlDataReader oReader, ref int iLineCount, int iNumberRequiredLines) {

            ArrayList alszWorkArea = null;
            int iSectionLines = iLineCount + iNumberRequiredLines;

            string szAttentionLine = GetString(oReader["AttentionLine"]);

            if (!string.IsNullOrEmpty(szAttentionLine)) {
                alszWorkArea = LimitStringLength(szAttentionLine, GetConfigValue("TESDocumatchResponderAddressMaxLength", 44));
                foreach (string szLine in alszWorkArea) {
                    AddLineToOutput(alOuputString, szLine, ref iLineCount);
                }
            }

            alszWorkArea = LimitStringLength(((string)oReader["ResponderCorrTradeStyle"]).Trim(), GetConfigValue("TESDocumatchResponderAddressMaxLength", 44));
            foreach (string szLine in alszWorkArea) {
                AddLineToOutput(alOuputString, szLine, ref iLineCount);
            }

            AddLineToOutput(alOuputString, GetString(oReader["addr_Address1"]), ref iLineCount);
            AddLineToOutput(alOuputString, GetString(oReader["addr_Address2"]), ref iLineCount);
            AddLineToOutput(alOuputString, GetString(oReader["addr_Address3"]), ref iLineCount);
            AddLineToOutput(alOuputString, GetString(oReader["addr_Address4"]), ref iLineCount);
            AddLineToOutput(alOuputString, GetString(oReader["addr_Address5"]), ref iLineCount);


            alszWorkArea = LimitStringLength(GetString(oReader["Responderprci_City"]) + ", " + GetString(oReader["Responderprst_Abbreviation"]) + " " + GetString(oReader["addr_PostCode"]), GetConfigValue("TESDocumatchResponderAddressMaxLength", 44));
            foreach (string szLine in alszWorkArea) {
                AddLineToOutput(alOuputString, szLine, ref iLineCount);
            }

            // This is a mailing address so only include the country
            // if not the US.
            if (GetString(oReader["Responderprcn_Country"]) != "USA") {
                AddLineToOutput(alOuputString, GetString(oReader["Responderprcn_Country"]), ref iLineCount);
            }

            if (iLineCount < iSectionLines) {
                // Add blank lines so that we have 7 address lines
                for (int i = iLineCount; i < iSectionLines; i++) {
                    alOuputString.Add(string.Empty);
                }
            }

            // Truncate our address section 
            if (iLineCount > iSectionLines) {
                alOuputString.RemoveRange(iSectionLines - 1, (iLineCount - iSectionLines));
            }
        }


        /// <summary>
        /// Adds the subject information to the string list.  Ensures the correct number
        /// of lines are accounted for.
        /// </summary>
        /// <param name="alOuputString"></param>
        /// <param name="oReader"></param>
        /// <param name="iLineCount"></param>
        /// <param name="iNumberRequiredLines"></param>
        /// <param name="bIsSingle"></param>
        protected void AddSubjectInfo(ArrayList alOuputString, SqlDataReader oReader, ref int iLineCount, int iNumberRequiredLines, bool bIsSingle) {

            ArrayList alszWorkArea = null;
            int iSectionLines = iLineCount + iNumberRequiredLines;
            int iMaxLineLength = 0;
            if (bIsSingle) {
                iMaxLineLength = 34;
            } else {
                iMaxLineLength = 44;
            }

            if (bIsSingle) {
                string szSubject = GetString(oReader["SubjectBookTradeStyle"]);
                if (szSubject.Length > iMaxLineLength) {
                    szSubject = szSubject.Substring(0, iMaxLineLength); 
                }

                AddLineToOutput(alOuputString, szSubject, ref iLineCount);
            } else {
                alszWorkArea = LimitStringLength(((string)oReader["SubjectBookTradeStyle"]).Trim(), iMaxLineLength);
                foreach (string szLine in alszWorkArea) {
                    AddLineToOutput(alOuputString, szLine, ref iLineCount);
                }
            }


            string szLocation = GetString(oReader["Subjectprci_City"]) + ", " + GetString(oReader["Subjectprst_Abbreviation"]);

            // This is a mailing address so only include the country
            // if not the US.
            if ((GetString(oReader["Responderprcn_Country"]) != "USA") && (GetString(oReader["Responderprcn_Country"]) != "Canada")) {
                szLocation += " " + GetString(oReader["Subjectprcn_Country"]);
            }

            alszWorkArea = LimitStringLength(szLocation, iMaxLineLength);
            foreach (string szLine in alszWorkArea) {
                AddLineToOutput(alOuputString, szLine, ref iLineCount);
            }


            // Add blank lines so that we 
            for (int i = iLineCount; i < iSectionLines; i++) {
                alOuputString.Add(string.Empty);
            }
            // Truncate our address section 
            if (iLineCount > iSectionLines) {
                alOuputString.RemoveRange(iSectionLines - 1, (iLineCount - iSectionLines));
            }
        }

        /// <summary>
        /// Adds the line to the output is the line value is not null or empty.
        /// Increments the line count appropriately.
        /// </summary>
        /// <param name="alOuputString"></param>
        /// <param name="szLine"></param>
        /// <param name="iLineCount"></param>
        protected void AddLineToOutput(ArrayList alOuputString, string szLine, ref int iLineCount ) {
            if (!string.IsNullOrEmpty(szLine)) {
                alOuputString.Add(szLine.Trim().ToUpper());
                iLineCount++;
            }
        }

        /// <summary>
        /// Returns the full path and file name to write the data
        /// to based on the specified form type.
        /// </summary>
        /// <param name="szFormType"></param>
        /// <returns></returns>
        protected string GetFileName(string szFormType) {

            string szFileName = null;
            switch (szFormType) {
                case FORM_SINGLE_ENGLISH:
                    szFileName = GetConfigValue("TESDocumatchFormSingleEnglishName", @"TESSingleEnglish.txt");
                    break;
                case FORM_SINGLE_SPANISH:
                    szFileName = GetConfigValue("TESDocumatchFormSingleSpanishName", @"TESSingleSpanish.txt");
                    break;
                case FORM_SINGLE_INTERNATIONAL:
                    szFileName = GetConfigValue("TESDocumatchFormSingleInternationalName", @"TESSingleInternational.txt");
                    break;
                case FORM_MULTIPLE_ENGLISH:
                    szFileName = GetConfigValue("TESDocumatchFormMultipleEnglishName", @"TESMultipleEnglish.txt");
                    break;
                case FORM_MULTIPLE_SPANISH:
                    szFileName = GetConfigValue("TESDocumatchFormMultipleSpanishName", @"TESMultipleSpanish.txt");
                    break;
                case FORM_MULTIPLE_INTERNATIONAL:
                    szFileName = GetConfigValue("TESDocumatchFormMultipleInternationalName", @"TESMultipleInternational.txt");
                    break;
                default:
                    throw new ApplicationException("Invalid form type found: " + szFormType);
            }

            string szRootFolder = GetConfigValue("TESDocumatchExtractFolder");
            return string.Concat(szRootFolder, szFileName);
        }

        protected int GetBatchListMax() {
            return GetConfigValue("TESDocumatchBatchListMax", 25);
        }

        protected string GetDateTime(object dtDateTime) {
            if ((dtDateTime != null) &&
                (dtDateTime != DBNull.Value)) {
                return ((DateTime)dtDateTime).ToString("MM/dd/yyyy HH:mm tt");
            }
            return "&nbsp;";
        }




        protected string CompressFiles()
        {
            string zipName = Path.Combine(GetConfigValue("TESDocumatchExtractFolder"),
                                          GetConfigValue("TESCompressFile", string.Format("BBSi TES Data {0}.zip", DateTime.Now.ToString("yyyy-MM-dd hhmm"))));

            using (ZipOutputStream zipOutputStream = new ZipOutputStream(File.Create(zipName)))
            {
                zipOutputStream.SetLevel(9); // 0-9, 9 being the highest compression
                zipOutputStream.Password = GetConfigValue("TESZipPassword", "P@ssword1");

                addZipEntry(zipOutputStream, GetConfigValue("TESDocumatchExtractFolder"), GetConfigValue("TESResponderDataFile", "TES_Responder_Data.txt"));
                addZipEntry(zipOutputStream, GetConfigValue("TESDocumatchExtractFolder"), GetConfigValue("TESSubjectDataFile", "TES_Subject_Data.txt"));
                addZipEntry(zipOutputStream, GetConfigValue("TESDocumatchExtractFolder"), GetConfigValue("TESControlFile", "Control.txt"));

                zipOutputStream.Finish();
                zipOutputStream.IsStreamOwner = true;
                zipOutputStream.Close();
            }

            return zipName;
        }

        protected void GenerateEmail(string fileName)
        {
            string body = string.Format(GetConfigValue("GenerateTESEmailBody",
                                                       "A new BBSi TES file, {0}, has been uploaded to {1} and is available for processing."),
                                        fileName,
                                        GetConfigValue("LRLFTPServer", "ftp://ftp.bluebookprco.com"));

            SqlConnection sqlConn = OpenDBConnection();
            SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", sqlConn);
            cmdCreateEmail.CommandType = CommandType.StoredProcedure;
            cmdCreateEmail.Parameters.AddWithValue("To", GetConfigValue("GenerateTESEmailAddress", "cwalls@travant.com"));
            cmdCreateEmail.Parameters.AddWithValue("Subject", GetConfigValue("GenerateTESEmailSubject", "New BBSi TES Files"));
            cmdCreateEmail.Parameters.AddWithValue("Content", body);
            cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
            cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");

            cmdCreateEmail.ExecuteNonQuery();

            if (!string.IsNullOrEmpty(GetConfigValue("GenerateTESBBSiEmailAddress", string.Empty)))
            {
                body += Environment.NewLine + Environment.NewLine;

                cmdCreateEmail = new SqlCommand("usp_CreateEmail", sqlConn);
                cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                cmdCreateEmail.Parameters.AddWithValue("To", GetConfigValue("GenerateTESBBSiEmailAddress"));
                cmdCreateEmail.Parameters.AddWithValue("Subject", GetConfigValue("GenerateTESEmailSubject", "New BBSi TES Files"));
                cmdCreateEmail.Parameters.AddWithValue("Content", body);
                cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", 1);
                cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");

                cmdCreateEmail.ExecuteNonQuery();
            }

            CloseDBConnection(sqlConn);
        }

        protected const string SQL_CONTROL_TOTALS_1 =
            "SELECT COUNT(distinct prtf_SerialNumber) as TotalFormCount, COUNT(distinct ResponderBBID) As MailingCount, COUNT(1) as SubjectCount " +
              "FROM vPRTESExtract " +
            "WHERE prtfb_TESFormBatchID = {0}";

        protected const string SQL_CONTROL_TOTALS_2 =
            "SELECT FormType, count(distinct prtf_SerialNumber) As FormCount " +
              "FROM vPRTESExtract " +
             "WHERE prtfb_TESFormBatchID = {0} " +
            "GROUP BY FormType";

        protected const string SQL_CONTROL_TOTALS_3 =
            "SELECT FormPageCount, " +
	               "COUNT(ResponderBBID) As MailingCount " +
              "FROM (SELECT ResponderBBID, COUNT(distinct prtf_SerialNumber) As FormPageCount " +
                      "FROM vPRTESExtract " +
                     "WHERE prtfb_TESFormBatchID = {0} " +
                  "GROUP BY ResponderBBID)TableA " +
            "GROUP BY FormPageCount " +
            "ORDER BY FormPageCount";

        protected void GenerateControlCountFile(SqlConnection sqlConn, int iBatchID)
        {

            _TESControlFile = Path.Combine(GetConfigValue("TESDocumatchExtractFolder"),
                                           GetConfigValue("TESControlFile", "Control.txt"));

            if (File.Exists(_TESControlFile))
                File.Delete(_TESControlFile);


            StringBuilder sbControlFile = new StringBuilder();

            SqlCommand cmdControlTotals1 = new SqlCommand(string.Format(SQL_CONTROL_TOTALS_1, iBatchID), sqlConn);
            using (IDataReader reader = cmdControlTotals1.ExecuteReader())
            {
                reader.Read();

                sbControlFile.Append("Form Count\t");
                sbControlFile.Append(GetInt(reader, 0));
                sbControlFile.Append(Environment.NewLine);
                sbControlFile.Append("Subject Count\t");
                sbControlFile.Append(GetInt(reader, 2));
                sbControlFile.Append(Environment.NewLine);
                sbControlFile.Append("Mailing Pieces Count\t");
                sbControlFile.Append(GetInt(reader, 1));
                sbControlFile.Append(Environment.NewLine);
            }

            sbControlFile.Append(Environment.NewLine);

            SqlCommand cmdControlTotals2 = new SqlCommand(string.Format(SQL_CONTROL_TOTALS_2, iBatchID), sqlConn);
            using (IDataReader reader = cmdControlTotals2.ExecuteReader())
            {
                sbControlFile.Append("Forms Count by Form Type");
                sbControlFile.Append(Environment.NewLine);

                sbControlFile.Append("Form Type\tFormCount");
                sbControlFile.Append(Environment.NewLine);

                while (reader.Read())
                {
                    sbControlFile.Append(GetString(reader, 0));
                    sbControlFile.Append("\t");
                    sbControlFile.Append(GetInt(reader, 1));
                    sbControlFile.Append(Environment.NewLine);
                }
            }

            sbControlFile.Append(Environment.NewLine);

            SqlCommand cmdControlTotals3 = new SqlCommand(string.Format(SQL_CONTROL_TOTALS_3, iBatchID), sqlConn);
            using (IDataReader reader = cmdControlTotals3.ExecuteReader())
            {
                sbControlFile.Append("Form Count by Number of Pages");
                sbControlFile.Append(Environment.NewLine);

                sbControlFile.Append("Form Page Count\tForm Count");
                sbControlFile.Append(Environment.NewLine);
                
                while (reader.Read())
                {
                    sbControlFile.Append(GetInt(reader, 0));
                    sbControlFile.Append("\t");
                    sbControlFile.Append(GetInt(reader, 1));
                    sbControlFile.Append(Environment.NewLine);
                }
            }

            WriteToFile(_TESControlFile, sbControlFile.ToString());
        }
    }
}
