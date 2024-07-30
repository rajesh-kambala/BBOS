/***********************************************************************
 Copyright Produce Reporter Company 2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRCompanyClassificationAssignContent2.aspx
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.Services;
using System.Data;
using System.Text;

namespace PRCo.BBS.CRM
{
    /// <summary>
    /// This page allows the user to edit specific attention lines
    /// and possibly apply those changes to other attenion lines
    /// for the current company.
    /// </summary>
    public partial class PRCompanyClassificationAssignContent2 : PageBase
    {
        protected string _sSID = string.Empty;
        protected string _szReturnURL;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                string[] arrSID = Request["SID"].Split(',');
                if (arrSID.Length > 0)
                    hidSID.Value = arrSID[0];
                else
                    hidSID.Value = "";

                //Both required
                hidCompanyID.Value = Request["CompanyID"];
                hidUserID.Value = Request["UID"];

                if (string.IsNullOrEmpty(hidCompanyID.Value) || string.IsNullOrEmpty(hidUserID.Value))
                {
                    throw new Exception("Missing required params CompanyID and UID.");
                }

                PopulateForm();
            }
        }

        const string SQL_SELECT_COMPANY_CLASSIFICATIONS = "SELECT vPRCompanyClassification.*, (PRClassification.prcl_Name+' (' + PRClassification.prcl_Abbreviation+')') AS prcl_Name FROM vPRCompanyClassification INNER JOIN PRClassification ON PRClassification.prcl_Abbreviation = vPRCompanyClassification.prcl_Abbreviation WHERE prc2_CompanyId=@CompanyID ORDER BY ISNULL(prc2_Sequence, 0)";

        protected void PopulateForm()
        {
            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdClassifications = new SqlCommand(SQL_SELECT_COMPANY_CLASSIFICATIONS, dbConn);
                cmdClassifications.Parameters.AddWithValue("CompanyID", hidCompanyID.Value);

                using (SqlDataReader oClassificationReader = cmdClassifications.ExecuteReader())
                {
                    StringBuilder sbClassifications = new StringBuilder();

                    while (oClassificationReader.Read())
                    {
                        int iClassificationID = 0;
                        string szName = "";
                        string szControlKey = "";
                        int iSequence = 0;

                        if (oClassificationReader["prc2_ClassificationID"] != DBNull.Value)
                            iClassificationID = Convert.ToInt32(oClassificationReader["prc2_ClassificationID"]);

                        if (oClassificationReader["prcl_Name"] != DBNull.Value)
                            szName = Convert.ToString(oClassificationReader["prcl_Name"]);

                        szControlKey = string.Format("{0}", iClassificationID);

                        if (oClassificationReader["prc2_Sequence"] != DBNull.Value)
                            iSequence = Convert.ToInt32(oClassificationReader["prc2_Sequence"]);

                        sbClassifications.Append(string.Format("classifications[classifications.length] = {{classificationid:{0}, name:'{1}', controlKey:'{2}', sequence:{3} }};\n",
                            iClassificationID,
                            szName,
                            szControlKey,
                            iSequence));
                    }

                    sbClassifications.Append("refreshTable();\n");
                    //sbClassifications.Append("buildCurrentListing();\n");

                    string myScript = "\n<script type=\"text/javascript\" language=\"Javascript\" id=\"ClassificationScriptBlock\">\n";
                    myScript += sbClassifications.ToString();
                    myScript += "\n\n </script>";
                    Page.ClientScript.RegisterStartupScript(this.GetType(), "ClassificationScript", myScript, false);
                }
            }
            catch (Exception e)
            {
                lblMsg.Text += e.Message;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }
        }

        private class CCRecord
        {
            public int iCompanyId;
            public int iClassificationId;
            public int iSequence;
            public string szName;
            public string szControlKey;

            public int Sequence_DB
            {
                get
                {
                    if (iSequence == 0)
                        return 99999;
                    else
                        return iSequence;
                }
            }
        }

        /// <summary>
        /// Save button
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSaveOnClick(object sender, EventArgs e)
        {
            dynamic obj = Newtonsoft.Json.JsonConvert.DeserializeObject(hidClassifications.Value);

            SqlConnection dbConn = OpenDBConnection();
            SqlTransaction dbTran = dbConn.BeginTransaction();

            DateTime dtUpdatedDate = DateTime.Now;

            try
            {
                for (int i = 0; i < obj.Count; i++)
                {
                    CCRecord oCC = new CCRecord();
                    oCC.iCompanyId = Convert.ToInt32(hidCompanyID.Value);
                    oCC.iClassificationId = obj[i].classificationid;
                    oCC.szName = obj[i].name;
                    oCC.szControlKey = obj[i].controlKey;
                    oCC.iSequence = obj[i].sequence;

                    if (CCExists(dbConn, dbTran, oCC))
                    {
                        CCUpdate(dbConn, dbTran, oCC, dtUpdatedDate);
                    }
                    else
                    {
                        CCInsert(dbConn, dbTran, oCC, dtUpdatedDate);
                    }
                }

                // Remove extra items that were deleted by user
                // (i.e. not updated nor inserted above, based on consistent datetime value of changes)
                CCDeleteExtras(dbConn, dbTran, Convert.ToInt32(hidCompanyID.Value), dtUpdatedDate);

                dbTran.Commit();
            }
            catch
            {
                dbTran.Rollback();
                throw;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }


            RedirectToCompanyClassificationListing();
        }

        private void RedirectToCompanyClassificationListing()
        {
            if (Request.Url.Host.Contains("localhost"))
                Response.Redirect(Request.RawUrl);

            string szNewUrl = Request.RawUrl.Replace("PRCompanyClassificationAssignContent2.aspx", "PRCompanyClassificationListing.asp");

            szNewUrl = szNewUrl.Substring(0, szNewUrl.IndexOf("?"));
            szNewUrl += "?SID=" + hidSID.Value;
            szNewUrl += "&Key0=1&Key1=" + hidCompanyID.Value;
            szNewUrl += "&F=PRCompany%2FPRCompanyClassificationAssignContent.asp&J=PRCompany%2FPRCompanyClassificationListing.asp";

            //Call client method so we can break free of inner iframe during redirect
            Page.ClientScript.RegisterStartupScript(this.GetType(), "redirect", "redirect('" + szNewUrl + "');", true);
        }

        const string SQL_INSERT_COMPANYCLASSIFICATION = @"DECLARE @NextPRCCId int
                EXEC usp_GetNextId 'PRCompanyClassification', @NextPRCCId output
                INSERT INTO PRCompanyClassification
                (prc2_CompanyClassificationId,
                    prc2_CreatedBy, prc2_createdDate, prc2_UpdatedBy, prc2_UpdatedDate, prc2_TimeStamp,
                    prc2_CompanyId, prc2_ClassificationId,
                    prc2_Sequence
                )
                VALUES(
                    @NextPRCCId,
                    @UserId, @UpdatedDate, @UserId, @UpdatedDate, @UpdatedDate,
                    @CompanyID, @ClassificationId, 
                    @Sequence
                )";

        private void CCInsert(SqlConnection dbConn, SqlTransaction dbTran, CCRecord oCC, DateTime dtUpdatedDate)
        {
            SqlCommand sqlCommand = dbConn.CreateCommand();
            sqlCommand.Transaction = dbTran;

            sqlCommand.CommandText = SQL_INSERT_COMPANYCLASSIFICATION;
            sqlCommand.Parameters.AddWithValue("UserId", hidUserID.Value);
            sqlCommand.Parameters.AddWithValue("CompanyID", oCC.iCompanyId);
            sqlCommand.Parameters.AddWithValue("ClassificationId", oCC.iClassificationId);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", dtUpdatedDate);
            sqlCommand.Parameters.AddWithValue("Sequence", oCC.Sequence_DB);
            object iRows = sqlCommand.ExecuteNonQuery();
        }

        const string SQL_UPDATE_COMPANYCLASSIFICATION = @"UPDATE PRCompanyClassification SET
                                        prc2_UpdatedDate=@UpdatedDate, prc2_Sequence=@Sequence
                                        WHERE prc2_CompanyId=@CompanyID
                                        AND ISNULL(prc2_ClassificationId,0)= @ClassificationId";

        private void CCUpdate(SqlConnection dbConn, SqlTransaction dbTran, CCRecord oCC, DateTime dtUpdatedDate)
        {
            SqlCommand sqlCommand = dbConn.CreateCommand();
            sqlCommand.Transaction = dbTran;

            sqlCommand.CommandText = SQL_UPDATE_COMPANYCLASSIFICATION;
            sqlCommand.Parameters.AddWithValue("CompanyID", oCC.iCompanyId);
            sqlCommand.Parameters.AddWithValue("ClassificationId", oCC.iClassificationId);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", dtUpdatedDate);
            sqlCommand.Parameters.AddWithValue("Sequence", oCC.Sequence_DB);
            object iRows = sqlCommand.ExecuteNonQuery();
        }

        const string SQL_DELETE_COMPANYCLASSIFICATION = @"DELETE FROM PRCompanyClassification
                                                                WHERE prc2_CompanyId=@CompanyID
                                                                AND prc2_UpdatedDate != @UpdatedDate";

        private void CCDeleteExtras(SqlConnection dbConn, SqlTransaction dbTran, int iCompanyId, DateTime dtUpdatedDate)
        {
            SqlCommand sqlCommand = dbConn.CreateCommand();
            sqlCommand.Transaction = dbTran;
            sqlCommand.CommandText = SQL_DELETE_COMPANYCLASSIFICATION;
            sqlCommand.Parameters.AddWithValue("CompanyID", iCompanyId);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", dtUpdatedDate);
            object iRows = sqlCommand.ExecuteNonQuery();
        }

        const string SQL_COMPANYCLASSIFICATION_EXISTS = @"SELECT 'x' FROM PRCompanyClassification WITH(NOLOCK) WHERE prc2_CompanyId = @CompanyID
                                                                AND ISNULL(prc2_ClassificationId,0)= @ClassificationId";

        private bool CCExists(SqlConnection dbConn, SqlTransaction dbTran, CCRecord oCC)
        {
            SqlCommand sqlCommand = dbConn.CreateCommand();
            sqlCommand.Transaction = dbTran;
            sqlCommand.CommandText = SQL_COMPANYCLASSIFICATION_EXISTS;
            sqlCommand.Parameters.AddWithValue("CompanyID", oCC.iCompanyId);
            sqlCommand.Parameters.AddWithValue("ClassificationId", oCC.iClassificationId);
            object oValue = sqlCommand.ExecuteScalar();

            if (oValue == null)
            {
                return false;
            }

            return true;
        }

        /// <summary>
        /// Cancel button
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            RedirectToCompanyClassificationListing();
        }
    }
}
