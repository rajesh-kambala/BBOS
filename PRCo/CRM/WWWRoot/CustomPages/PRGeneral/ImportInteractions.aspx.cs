/***********************************************************************
 Copyright Produce Reporter Company 2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ImportInteractions
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.IO;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRCo.BBS.CRM
{
    public partial class ImportInteractions : PageBase
    {
        protected string sSID = "";
        protected int _iUserID;

        protected int _iRecordCount;
        protected int _iCompanyID;

        protected SqlConnection _dbConn;
        protected string _szUploadedFile;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Server.ScriptTimeout = GetConfigValue("BBScoreImportScriptTimeout", 3600);

            lblError.Text = string.Empty;

            if (!IsPostBack)
            {
                hidUserID.Text = Request["user_userid"];
            }

            _iUserID = Int32.Parse(hidUserID.Text);

            this.lnkUpload.Text = "Import Interactions File";
            this.lnkUploadImage.ImageUrl = "/" + this._szAppName + "/img/Buttons/Attachment.gif";
            this.lnkUploadImage.AlternateText = "Upload";

            if (!IsPostBack)
            {
                sSID = Request.Params.Get("SID");
                hidSID.Text = this.sSID;
            }
            else
            {
                sSID = hidSID.Text;
                //ProcessForm();
            }
        }

        protected void ImportClick(object sender, EventArgs e)
        {
            ProcessForm();
        }


        protected void ProcessForm()
        {

            DateTime dtStart;
            DateTime dtEnd;

            // Check to see if a license file was uploaded
            if (fileUpload.PostedFile == null
                || fileUpload.PostedFile.FileName == null
                || fileUpload.PostedFile.FileName.Length == 0
                || fileUpload.PostedFile.ContentLength == 0)
            {

                lblError.Text = "No file found to process";
                return;
            }

            try
            {
                dtStart = DateTime.Now;
                ProcessFile();
                lblRecordCount.Text = _iRecordCount.ToString("###,###,##0") + " Interactions Imported";
                dtEnd = DateTime.Now;

                StringBuilder sbScreenMsg = new StringBuilder();
                sbScreenMsg.Append("<p>Start DateTime: " + dtStart.ToString());
                sbScreenMsg.Append("<br>" + _iRecordCount.ToString("###,###,##0") + " Interactions Imported");
                sbScreenMsg.Append("<br>End DateTime:   " + dtEnd.ToString());

                pnlImportStats.Visible = true;
                lblRecordCount.Text += sbScreenMsg.ToString();
            }
            catch (Exception e)
            {
                lblError.Text = "An unexpected error has occured.  " + e.Message;
                lblError.Text += "<p><pre>" + e.StackTrace + "</pre>";

                if (_iCompanyID > 0)
                    lblError.Text += "  Last CompanyID read: " + _iCompanyID.ToString();
            }
        }

        private const string SQL_INSERT_COMMUNICATION =
             @"INSERT INTO Communication (Comm_CommunicationId,comm_DateTime,comm_Action,comm_PRCategory,comm_Note,comm_Subject,comm_Status,comm_Priority, comm_CreatedBy,comm_CreatedDate,comm_UpdatedBy,comm_UpdatedDate,comm_TimeStamp)
              VALUES (@Comm_CommunicationId,@comm_DateTime,@comm_Action, @comm_PRCategory,@comm_Note,@comm_Subject,@comm_Status,@comm_Priority, @comm_CreatedBy,GETDATE(),@comm_CreatedBy,GETDATE(),GETDATE())";

        private const string SQL_INSERT_COMM_LINK =
             @"INSERT INTO Comm_Link (CmLi_CommLinkId, CmLi_Comm_UserId,CmLi_Comm_CommunicationId,CmLi_Comm_CompanyId, CmLi_CreatedBy,CmLi_CreatedDate,CmLi_UpdatedBy,CmLi_UpdatedDate,CmLi_TimeStamp)
              VALUES (@CmLi_CommLinkId, @UserID, @Comm_CommunicationId,@CompanyID, @CmLi_CreatedBy,GETDATE(),@CmLi_CreatedBy,GETDATE(),GETDATE())";

        protected void ProcessFile()
        {

            StreamReader srImportFile = null;
            _dbConn = OpenDBConnection("CRM InteractionsImport");

            _iRecordCount = 0;

            SqlTransaction dbTran = _dbConn.BeginTransaction();
            try
            {
                srImportFile = new StreamReader(fileUpload.PostedFile.InputStream);

                bool bFirstRecord = true;

                string szInputLine = null;
                while ((szInputLine = srImportFile.ReadLine()) != null)
                {
                    // Skip the header record
                    if (bFirstRecord)
                    {
                        bFirstRecord = false;
                        continue;
                    }

                    _iRecordCount++;

                    // Load our CSV values into member variables
                    string[] aszInputValues = ParseCSVValues(szInputLine);
                    _iCompanyID = Int32.Parse(aszInputValues[0]);
                    DateTime _date = DateTime.Parse(aszInputValues[1]);
                    string salesRep = aszInputValues[2];
                    string Note = aszInputValues[3];


                    SqlCommand cmdSalesPerson = new SqlCommand($"SELECT user_userid FROM users WHERE user_logon='{salesRep}'", _dbConn, dbTran);
                    int salesPersonID = Convert.ToInt32(cmdSalesPerson.ExecuteScalar());

                    int commID = GetNextRecordID(dbTran, "Communication");
                    SqlCommand cmdInsertComm = new SqlCommand(SQL_INSERT_COMMUNICATION, _dbConn, dbTran);
                    cmdInsertComm.Parameters.AddWithValue("@Comm_CommunicationId", commID);
                    cmdInsertComm.Parameters.AddWithValue("@comm_Action", "MT");
                    cmdInsertComm.Parameters.AddWithValue("@comm_PRCategory", "FS");
                    cmdInsertComm.Parameters.AddWithValue("@comm_Note", Note);
                    cmdInsertComm.Parameters.AddWithValue("@comm_Subject", "Field Rep Visit");
                    cmdInsertComm.Parameters.AddWithValue("@comm_Status", "Complete");
                    cmdInsertComm.Parameters.AddWithValue("@comm_Priority", "Normal");
                    cmdInsertComm.Parameters.AddWithValue("@comm_CreatedBy", salesPersonID);
                    cmdInsertComm.Parameters.AddWithValue("@comm_DateTime", _date);
                    cmdInsertComm.ExecuteNonQuery();

                    int commLinkID = GetNextRecordID(dbTran, "Comm_Link");
                    SqlCommand cmdInsertCommLinkl = new SqlCommand(SQL_INSERT_COMM_LINK, _dbConn, dbTran);
                    cmdInsertCommLinkl.Parameters.AddWithValue("@CmLi_CommLinkId", commLinkID);
                    cmdInsertCommLinkl.Parameters.AddWithValue("@UserID", salesPersonID);
                    cmdInsertCommLinkl.Parameters.AddWithValue("@Comm_CommunicationId", commID);
                    cmdInsertCommLinkl.Parameters.AddWithValue("@CompanyID", _iCompanyID);
                    cmdInsertCommLinkl.Parameters.AddWithValue("@cmli_CreatedBy", salesPersonID);
                    cmdInsertCommLinkl.ExecuteNonQuery();

                } // End While
                dbTran.Commit();
            }
            catch
            {
                if (dbTran != null)
                    dbTran.Rollback();

                throw;
            }
            finally
            {

                if (srImportFile != null)
                {
                    srImportFile.Close();
                    srImportFile.Dispose();
                }

                _dbConn.Close();
            }
        }
    }
}