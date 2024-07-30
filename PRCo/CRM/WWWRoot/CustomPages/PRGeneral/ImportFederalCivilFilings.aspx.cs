/***********************************************************************
 Copyright Blue Book Services, Inc. 2013-2016

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: ImportFederalCivilFilings
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using LumenWorks.Framework.IO.Csv;

namespace PRCo.BBS.CRM.CustomPages.PRGeneral
{
    public partial class ImportFederalCivilFilings : PageBase
    {
        protected string sSID = "";
        protected int _iUserID;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Server.ScriptTimeout = GetConfigValue("BBScoreImportScriptTimeout", 3600);

            lblError.Text = string.Empty;
            lblTotalCount.Text = string.Empty;

            if (!IsPostBack)
            {
                hidUserID.Text = Request["user_userid"];
            }

            _iUserID = Int32.Parse(hidUserID.Text);

            // Upload link
            lnkUpload.NavigateUrl = "javascript:document.forms[0].submit();";
            this.lnkUpload.Text = "Import Court Cases File";
            this.lnkUploadImage.NavigateUrl = "javascript:document.forms[0].submit();";
            this.lnkUploadImage.ImageUrl = "/" + this._szAppName + "/img/Buttons/Attachment.gif";
            this.lnkUploadImage.Text = "Upload";

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

            // Check to see if a license file was uploaded
            if (!fileUpload.HasFile)
            {
                lblError.Text = "No file found to process";
                return;
            }

            try
            {
                ProcessFile(fileUpload.PostedFile);
                lblTotalCount.Text = "The file was successfully processed.<br/>";
                lblTotalCount.Text += " - " + _recordCount.ToString("###,###,##0") + " Records Processed.<br/>";
                lblTotalCount.Text += " - " + _caseCount.ToString("###,###,##0") + " Cases Processed.<br/>";
                lblTotalCount.Text += " - " + _insertedCount.ToString("###,###,##0") + " Cases Added.<br/>";
                lblTotalCount.Text += " - " + _updatedCount.ToString("###,###,##0") + " Cases Updated.<br/>";
                lblTotalCount.Text += " - " + _deletedCount.ToString("###,###,##0") + " Cases Removed.<br/>";
            }
            catch (Exception e)
            {
                lblError.Text = "An unexpected error has occured.  " + e.Message;
                lblError.Text += "<p><pre>" + e.StackTrace + "</pre>";

            }
        }

        protected const string SQL_INSERT_RECORD =
            @"INSERT INTO PRCourtCases (prcc_CompanyID, prcc_CaseNumber, prcc_CaseTitle, prcc_SuitType, prcc_FiledDate, prcc_ClosedDate, prcc_CourtCode, prcc_CaseOperatingStatus, prcc_ClaimAmt, prcc_Notes, prcc_CreatedBy, prcc_CreatedDate, prcc_UpdatedBy, prcc_UpdatedDate, prcc_TimeStamp)  
              VALUES (@CompanyID, @CaseNumber, @CaseTitle, @SuitType, @FiledDate, @ClosedDate, @CourtCode, @CaseOperatingStatus, @ClaimAmt, @Notes, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE())";

        protected const string SQL_UPDATE_RECORD =
            @"UPDATE PRCourtCases 
                 SET prcc_FiledDate =  @FiledDate,
                     prcc_ClosedDate = @ClosedDate,
                     prcc_CourtCode = @CourtCode,
                     prcc_SuitType = @SuitType,
                     prcc_CaseOperatingStatus = @CaseOperatingStatus,
                     prcc_ClaimAmt = @ClaimAmt,
                     prcc_Notes = @Notes,
                     prcc_UpdatedBy = @UserID,
                     prcc_UpdatedDate = GETDATE(), 
                     prcc_TimeStamp = GETDATE()
               WHERE prcc_CourtCaseID = @CaseID";

        protected const string SQL_DELETE_RECORD =
            "DELETE FROM PRCourtCases WHERE prcc_CourtCaseID = @CaseID";

        private int _caseCount = 0;
        private int _recordCount = 0;
        private int _updatedCount = 0;
        private int _insertedCount = 0;
        private int _deletedCount = 0;

        private SqlCommand cmdInsert = null;
        private SqlCommand cmdUpdate = null;
        private SqlCommand cmdDelete = null;
        protected int ProcessFile(HttpPostedFile oPostedFile)
        {

            SqlConnection dbConn = null;
            SqlTransaction dbTran = null;

            try
            {
                List<CivilCase> civilCases = LoadData(oPostedFile.InputStream);

                dbConn = OpenDBConnection();
                dbTran = dbConn.BeginTransaction();
                
                foreach(CivilCase civilCase in civilCases) {


                    lblTotalCount.Text += "<br/>BBID: " + civilCase.BBID.ToString();


                    if (CaseExists(civilCase, dbConn, dbTran))
                    {
                        if (civilCase.Publish)
                        {
                            if (cmdUpdate == null)
                            {
                                cmdUpdate = new SqlCommand(SQL_UPDATE_RECORD, dbConn, dbTran);
                            }

                            cmdUpdate.Parameters.Clear();
                            AddParameters(civilCase, cmdUpdate);
                            cmdUpdate.ExecuteNonQuery();
                            _updatedCount++;
                        }
                        else
                        {
                            if (cmdDelete == null)
                            {
                                cmdDelete = new SqlCommand(SQL_DELETE_RECORD, dbConn, dbTran);
                            }

                            cmdDelete.Parameters.Clear();
                            cmdDelete.Parameters.AddWithValue("@CaseID", civilCase.CaseID);
                            cmdDelete.ExecuteNonQuery();
                            _deletedCount++;
                        }
                    }
                    else
                    {
                        if (civilCase.Publish)
                        {
                            if (cmdInsert == null)
                            {
                                cmdInsert = new SqlCommand(SQL_INSERT_RECORD, dbConn, dbTran);
                            }

                            cmdInsert.Parameters.Clear();
                            AddParameters(civilCase, cmdInsert);
                            cmdInsert.ExecuteNonQuery();
                            _insertedCount++;
                        }
                    }


                } // End For


                if (GetConfigValue("ImportFederalCivilFilingsCommit", true))
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

        private List<CivilCase> LoadData(System.IO.Stream inputStream)
        {
            List<CivilCase> civilCases = new List<CivilCase>();

            using (CsvReader csv = new CsvReader(new StreamReader(inputStream), true))
            {
                csv.SupportsMultiline = true;

                int fieldCount = csv.FieldCount;

                while (csv.ReadNextRecord())
                {
                    _recordCount++;

                    if (string.IsNullOrEmpty(csv["BBID"]))
                    {
                        continue;
                    }

                    int companyID = 0;
                    if (!int.TryParse(csv["BBID"], out companyID))
                    {
                        continue;
                    }


                    _caseCount++;
                    CivilCase civilCase = new CivilCase();
                    civilCases.Add(civilCase);


                    civilCase.BBID = companyID;
                    civilCase.CaseTitle = csv["Case Title"];
                    civilCase.CourtCode = csv["Court"];
                    civilCase.CaseNumber = csv["Case#"];
                    civilCase.Notes = csv["Published Notes"];
                    civilCase.SuitType = csv["Suit Type"];

                    DateTime dtTmp = DateTime.MinValue;
                    if (!DateTime.TryParse(csv["File Date"], out dtTmp))
                    {
                        throw new ApplicationException("Record " + _recordCount.ToString("###,##0") + ", BBID " + csv["BBID"] + " - Invalid File Date found: " + csv["File Date"]);
                    }
                    civilCase.FiledDate = Convert.ToDateTime(csv["File Date"]);

                    civilCase.Publish = false;
                    if ((!string.IsNullOrEmpty(csv["Publish"])) &&
                        (csv["Publish"].ToUpper() == "Y")) {
                            civilCase.Publish = true;
                    }


                    if (string.IsNullOrEmpty(csv["Claim Amount"]))
                    {
                        civilCase.ClaimAmt = 0M;
                    } else { 
                        Decimal dTmp = 0M;
                        if (!Decimal.TryParse(stripCharacter(csv["Claim Amount"], "$"), out dTmp))
                        {
                            throw new ApplicationException("Record " + _recordCount.ToString("###,##0") + ", BBID " + csv["BBID"] + " - Invalid Claim Amount found: " + csv["Claim Amount"]);
                        }
                        civilCase.ClaimAmt = Convert.ToDecimal(stripCharacter(csv["Claim Amount"], "$"));
                    }

                    civilCase.CaseOperatingStatus = csv["Case &/or Operating  Status"];
                    if (!string.IsNullOrEmpty(csv["Closed Date"]))
                    {
                        dtTmp = DateTime.MinValue;
                        if (!DateTime.TryParse(csv["Closed Date"], out dtTmp))
                        {
                            throw new ApplicationException("Record " + _recordCount.ToString("###,##0") + ", BBID " + csv["BBID"] + " - Invalid Closed Date found: " + csv["Closed Date"]);
                        }


                        civilCase.ClosedDate = Convert.ToDateTime(csv["Closed Date"]);
                    }
                }
            }

            return civilCases;
        }


        protected const string SQL_CASE_EXISTS =
            @"SELECT prcc_CourtCaseID
                FROM PRCourtCases WITH (NOLOCK)
               WHERE prcc_CompanyID = @CompanyID
                 AND prcc_CaseNumber = @CaseNumber";
                 
        private SqlCommand cmdExists = null;
        private bool CaseExists(CivilCase civilCase, SqlConnection dbConn, SqlTransaction dbTran)
        {
            if (cmdExists == null)
            {
                cmdExists = new SqlCommand(SQL_CASE_EXISTS, dbConn, dbTran);
            }

            cmdExists.Parameters.Clear();
            cmdExists.Parameters.AddWithValue("@CompanyID", civilCase.BBID);
            cmdExists.Parameters.AddWithValue("@CaseNumber", civilCase.CaseNumber);

            object result = cmdExists.ExecuteScalar();
            if (result == null)
            {
                civilCase.IsNew = true;
                return false;
            }

            civilCase.CaseID = (int)result;
            return true;
        }

        private void AddParameters(CivilCase civilCase, SqlCommand sqlCommand)
        {

            if (civilCase.CaseID > 0) {
                sqlCommand.Parameters.AddWithValue("@CaseID", civilCase.CaseID);
            }

            sqlCommand.Parameters.AddWithValue("@CompanyID", civilCase.BBID);
            sqlCommand.Parameters.AddWithValue("@CaseNumber", civilCase.CaseNumber);
            sqlCommand.Parameters.AddWithValue("@CaseTitle", civilCase.CaseTitle);
            sqlCommand.Parameters.AddWithValue("@FiledDate", civilCase.FiledDate);

            if (civilCase.ClosedDate == DateTime.MinValue)
            {
                sqlCommand.Parameters.AddWithValue("@ClosedDate", DBNull.Value);
            }
            else
            {
                sqlCommand.Parameters.AddWithValue("@ClosedDate", civilCase.ClosedDate);
            }

            sqlCommand.Parameters.AddWithValue("@CourtCode", civilCase.CourtCode);
            sqlCommand.Parameters.AddWithValue("@CaseOperatingStatus", civilCase.CaseOperatingStatus);
            sqlCommand.Parameters.AddWithValue("@ClaimAmt", civilCase.ClaimAmt);

            if (string.IsNullOrEmpty(civilCase.SuitType))
            {
                sqlCommand.Parameters.AddWithValue("@SuitType", DBNull.Value);
            }
            else
            {
                sqlCommand.Parameters.AddWithValue("@SuitType", civilCase.SuitType);
            }

            if (string.IsNullOrEmpty(civilCase.Notes))
            {
                sqlCommand.Parameters.AddWithValue("@Notes", DBNull.Value);
            }
            else
            {
                sqlCommand.Parameters.AddWithValue("@Notes", civilCase.Notes);
            }

            sqlCommand.Parameters.AddWithValue("@UserID", _iUserID);
        }
    }

    public class CivilCase
    {
        public int CaseID { get; set; }
        public int BBID { get; set; }
        public string CaseTitle { get; set; }
        public string CourtCode { get; set; }
        public string CaseNumber { get; set; }
        public string SuitType { get; set; }
        public string Notes { get; set; }
        public DateTime FiledDate { get; set; }
        public Decimal ClaimAmt { get; set; }
        public string CaseOperatingStatus { get; set; }
        public DateTime ClosedDate { get; set; }
        public bool IsNew { get; set; }
        public bool Publish { get; set; }

    }
}