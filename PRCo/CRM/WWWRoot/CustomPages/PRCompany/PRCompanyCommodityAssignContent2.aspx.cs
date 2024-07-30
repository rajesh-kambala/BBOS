/***********************************************************************
 Copyright Produce Reporter Company 2019-2020

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRCompanyCommodityAssignContent.aspx
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
    public partial class PRCompanyCommodityAssignContent2 : PageBase
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

        const string SQL_SELECT_COMPANY_COMMODITIES = "SELECT * FROM vListingPRCompanyCommodity WHERE prcca_CompanyId=@CompanyID ORDER BY ISNULL(prcca_Sequence, 99999)";

        protected void PopulateForm()
        {
            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdCommodities = new SqlCommand(SQL_SELECT_COMPANY_COMMODITIES, dbConn);
                cmdCommodities.Parameters.AddWithValue("CompanyID", hidCompanyID.Value);
               
                using (SqlDataReader oCommodityReader = cmdCommodities.ExecuteReader())
                {
                    StringBuilder sbCommodities = new StringBuilder();

                    while(oCommodityReader.Read())
                    {
                        int iCommodityID = 0;
                        int iAttributeID = 0;
                        int iGrowingMethodID = 0;
                        string szPublishedDisplay = "";
                        string szControlKey = "";
                        string szDescription = "";
                        string szPublish = "";
                        int iSequence = 0;

                        if (oCommodityReader["prcca_CommodityID"] != DBNull.Value)
                            iCommodityID = Convert.ToInt32(oCommodityReader["prcca_CommodityID"]);

                        if (oCommodityReader["prcca_AttributeID"] != DBNull.Value)
                            iAttributeID  = Convert.ToInt32(oCommodityReader["prcca_AttributeID"]);

                        if (oCommodityReader["prcca_GrowingMethodID"] != DBNull.Value)
                            iGrowingMethodID = Convert.ToInt32(oCommodityReader["prcca_GrowingMethodID"]);

                        if (oCommodityReader["prcca_PublishedDisplay"] != DBNull.Value)
                            szPublishedDisplay = Convert.ToString(oCommodityReader["prcca_PublishedDisplay"]);

                        szControlKey = string.Format("{0}|{1}|{2}", iCommodityID, iAttributeID, iGrowingMethodID);

                        if (oCommodityReader["prcx_Description"] != DBNull.Value)
                            szDescription = Convert.ToString(oCommodityReader["prcx_Description"]);

                        if (oCommodityReader["prcca_Publish"] != DBNull.Value)
                            szPublish = Convert.ToString(oCommodityReader["prcca_Publish"]);

                        if (oCommodityReader["prcca_Sequence"] != DBNull.Value)
                            iSequence = Convert.ToInt32(oCommodityReader["prcca_Sequence"]);

                        sbCommodities.Append(string.Format("commodities[commodities.length] = {{commodityid:{0}, attributeid:{1}, growingmethodid:{2}, abbreviation:'{3}', controlKey:'{4}', description: '{5}', publish: '{6}', sequence:{7} }};\n",
                            iCommodityID,
                            iAttributeID,
                            iGrowingMethodID,
                            szPublishedDisplay,
                            szControlKey,
                            szDescription,
                            szPublish,
                            iSequence));
                    }

                    sbCommodities.Append("refreshTable();\n");
                    sbCommodities.Append("buildCurrentListing();\n");

                    string myScript = "\n<script type=\"text/javascript\" language=\"Javascript\" id=\"CommodityScriptBlock\">\n";
                    myScript += sbCommodities.ToString();
                    myScript += "\n\n </script>";
                    Page.ClientScript.RegisterStartupScript(this.GetType(), "CommodityScript", myScript, false);
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

        private class CCARecord
        {
            public int iCompanyId;
            public int iCommodityId;
            public int iAttributeId;
            public int iGrowingMethodId;
            public int iSequence;
            public string szAbbreviation;
            public string szControlKey;
            public string szDescription;
            public string szPublish;

            public object AttributeId_DB
            { 
                get 
                {
                    if (iAttributeId == 0)
                        return DBNull.Value;
                    else
                        return iAttributeId; 
                } 
            }
            public object GrowingMethodId_DB
            {
                get
                {
                    if (iGrowingMethodId == 0)
                        return DBNull.Value;
                    else
                        return iGrowingMethodId;
                }
            }
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

            public object Publish_DB { 
                get
                {
                    if (string.IsNullOrEmpty(szPublish) || szPublish == "N")
                        return DBNull.Value;
                    else
                        return szPublish;
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
            dynamic obj = Newtonsoft.Json.JsonConvert.DeserializeObject(hidCommodities.Value);

            SqlConnection dbConn = OpenDBConnection();
            SqlTransaction dbTran = dbConn.BeginTransaction();

            DateTime dtUpdatedDate = DateTime.Now;

            try
            {
                for (int i = 0; i < obj.Count; i++)
                {
                    CCARecord oCCA = new CCARecord();
                    oCCA.iCompanyId = Convert.ToInt32(hidCompanyID.Value);
                    oCCA.iCommodityId = obj[i].commodityid;
                    oCCA.iAttributeId = obj[i].attributeid;
                    oCCA.iGrowingMethodId = obj[i].growingmethodid;
                    oCCA.szAbbreviation = obj[i].abbreviation;
                    oCCA.szControlKey = obj[i].controlKey;
                    oCCA.szDescription = obj[i].description;
                    oCCA.szPublish = obj[i].publish;
                    oCCA.iSequence = obj[i].sequence;

                    if (CCAExists(dbConn, dbTran, oCCA))
                    {
                        CCAUpdate(dbConn, dbTran, oCCA, dtUpdatedDate);
                    }
                    else
                    {
                        CCAInsert(dbConn, dbTran, oCCA, dtUpdatedDate);
                    }
                }

                // Remove extra items that were deleted by user
                // (i.e. not updated nor inserted above, based on consistent datetime value of changes)
                CCADeleteExtras(dbConn, dbTran, Convert.ToInt32(hidCompanyID.Value), dtUpdatedDate);

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


            RedirectToCompanyCommodityListing();
        }

        private void RedirectToCompanyCommodityListing()
        {
            if (Request.Url.Host.Contains("localhost"))
                Response.Redirect(Request.RawUrl);

            string szNewUrl = Request.RawUrl.Replace("PRCompanyCommodityAssignContent2.aspx", "PRCompanyCommodityListing.asp");

            szNewUrl = szNewUrl.Substring(0, szNewUrl.IndexOf("?"));
            szNewUrl += "?SID=" + hidSID.Value;
            szNewUrl += "&Key0=1&Key1=" + hidCompanyID.Value;
            szNewUrl += "&F=PRCompany%2FPRCompanyCommodityAssignContent.asp&J=PRCompany%2FPRCompanyCommodityListing.asp";

            //Call client method so we can break free of inner iframe during redirect
            Page.ClientScript.RegisterStartupScript(this.GetType(), "redirect", "redirect('" + szNewUrl + "');", true);
        }

        const string SQL_INSERT_COMPANYCOMMODITYATTRIBUTE = @"DECLARE @NextPRCCAId int
                EXEC usp_GetNextId 'PRCompanyCommodityAttribute', @NextPRCCAId output
                INSERT INTO PRCompanyCommodityAttribute
                (prcca_CompanyCommodityAttributeId,
                    prcca_CreatedBy, prcca_createdDate, prcca_UpdatedBy, prcca_UpdatedDate, prcca_TimeStamp,
                    prcca_CompanyId, prcca_CommodityId, prcca_GrowingMethodId, prcca_AttributeId,
                    prcca_Publish, prcca_PublishWithGM, prcca_PublishedDisplay, prcca_Sequence
                )
                VALUES(
                    @NextPRCCAId,
                    @UserId, @UpdatedDate, @UserId, @UpdatedDate, @UpdatedDate,
                    @CompanyID, @CommodityId, @GrowingingMethodID, @AttributeId,
                    @Publish, NULL, @Abbreviation, @Sequence
                )";

        private void CCAInsert(SqlConnection dbConn, SqlTransaction dbTran, CCARecord oCCA, DateTime dtUpdatedDate)
        {
            SqlCommand sqlCommand = dbConn.CreateCommand();
            sqlCommand.Transaction = dbTran;

            sqlCommand.CommandText = SQL_INSERT_COMPANYCOMMODITYATTRIBUTE;
            sqlCommand.Parameters.AddWithValue("UserId", hidUserID.Value);
            sqlCommand.Parameters.AddWithValue("CompanyID", oCCA.iCompanyId);
            sqlCommand.Parameters.AddWithValue("CommodityId", oCCA.iCommodityId);
            sqlCommand.Parameters.AddWithValue("AttributeId", oCCA.AttributeId_DB);
            sqlCommand.Parameters.AddWithValue("GrowingingMethodID", oCCA.GrowingMethodId_DB);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", dtUpdatedDate);
            sqlCommand.Parameters.AddWithValue("Sequence", oCCA.Sequence_DB);
            sqlCommand.Parameters.AddWithValue("Publish", oCCA.Publish_DB);
            sqlCommand.Parameters.AddWithValue("Abbreviation", oCCA.szAbbreviation);
            object iRows = sqlCommand.ExecuteNonQuery();
        }

        const string SQL_UPDATE_COMPANYCOMMODITYATTRIBUTE = @"UPDATE PRCompanyCommodityAttribute SET
                                        prcca_UpdatedDate=@UpdatedDate, prcca_Publish=@Publish, prcca_Sequence=@Sequence
                                        WHERE prcca_CompanyId=@CompanyID
                                        AND ISNULL(prcca_CommodityId,0)= @CommodityId
                                        AND ISNULL(prcca_AttributeId,0)= @AttributeId
                                        AND ISNULL(prcca_GrowingMethodId,0)= @GrowingingMethodID";
        private void CCAUpdate(SqlConnection dbConn, SqlTransaction dbTran, CCARecord oCCA, DateTime dtUpdatedDate)
        {
            SqlCommand sqlCommand = dbConn.CreateCommand();
            sqlCommand.Transaction = dbTran;

            sqlCommand.CommandText = SQL_UPDATE_COMPANYCOMMODITYATTRIBUTE;
            sqlCommand.Parameters.AddWithValue("CompanyID", oCCA.iCompanyId);
            sqlCommand.Parameters.AddWithValue("CommodityId", oCCA.iCommodityId);
            sqlCommand.Parameters.AddWithValue("AttributeId", oCCA.iAttributeId);
            sqlCommand.Parameters.AddWithValue("GrowingingMethodID", oCCA.iGrowingMethodId);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", dtUpdatedDate);
            sqlCommand.Parameters.AddWithValue("Sequence", oCCA.Sequence_DB);
            sqlCommand.Parameters.AddWithValue("Publish", oCCA.Publish_DB);
            object iRows = sqlCommand.ExecuteNonQuery();
        }

        const string SQL_DELETE_COMPANYCOMMODITYATTRIBUTE = @"DELETE FROM PRCompanyCommodityAttribute
                                                                WHERE prcca_CompanyId=@CompanyID
                                                                AND prcca_UpdatedDate != @UpdatedDate";

        private void CCADeleteExtras(SqlConnection dbConn, SqlTransaction dbTran, int iCompanyId, DateTime dtUpdatedDate)
        {
            SqlCommand sqlCommand = dbConn.CreateCommand();
            sqlCommand.Transaction = dbTran;
            sqlCommand.CommandText = SQL_DELETE_COMPANYCOMMODITYATTRIBUTE;
            sqlCommand.Parameters.AddWithValue("CompanyID", iCompanyId);
            sqlCommand.Parameters.AddWithValue("UpdatedDate", dtUpdatedDate);
            object iRows = sqlCommand.ExecuteNonQuery();
        }

        const string SQL_COMPANYCOMMODITYATTRIBUTE_EXISTS = @"SELECT 'x' FROM PRCompanyCommodityAttribute WITH(NOLOCK) WHERE prcca_CompanyId = @CompanyID
                                                                AND ISNULL(prcca_CommodityId,0)= @CommodityId
                                                                AND ISNULL(prcca_AttributeId,0)= @AttributeId
                                                                AND ISNULL(prcca_GrowingMethodId,0)= @GrowingingMethodID";

        private bool CCAExists(SqlConnection dbConn, SqlTransaction dbTran, CCARecord oCCA)
        {
            SqlCommand sqlCommand = dbConn.CreateCommand();
            sqlCommand.Transaction = dbTran;
            sqlCommand.CommandText = SQL_COMPANYCOMMODITYATTRIBUTE_EXISTS;
            sqlCommand.Parameters.AddWithValue("CompanyID", oCCA.iCompanyId);
            sqlCommand.Parameters.AddWithValue("CommodityId", oCCA.iCommodityId);
            sqlCommand.Parameters.AddWithValue("AttributeId", oCCA.iAttributeId);
            sqlCommand.Parameters.AddWithValue("GrowingingMethodID", oCCA.iGrowingMethodId);
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
            RedirectToCompanyCommodityListing();
        }

        [WebMethod]
        public static string[] GetCommodityCompletionList(string prefixText, int count, string contextKey)
        {
            SqlConnection dbConn = OpenDBConnectionStatic();

            string exclusionClause = string.Empty;

            if (!string.IsNullOrEmpty(contextKey))
            {
                string[] args = contextKey.Split('|');
                if ((args.Length >= 1) &&
                    (args[0] != "Y"))
                    exclusionClause += " AND prcm_AttributeID IS NULL";

                if ((args.Length >= 2) &&
                    (args[1] != "Y"))
                    exclusionClause += " AND prcm_GrowingMethodID IS NULL";
            }

            string SQL = $"SELECT TOP {count} prcm_CommodityID, prcm_Description, prcm_AttributeID, prcm_GrowingMethodID, prcm_Abbreviation FROM PRCommodity2 WHERE (prcm_DescriptionMatch LIKE '%' + dbo.GetLowerAlpha('{prefixText}') + '%' OR prcm_AliasMatch LIKE '%' + dbo.GetLowerAlpha('{prefixText}') + '%') {exclusionClause} ORDER BY prcm_Description";

            //SqlCommand cmdCommodities = new SqlCommand($"SELECT TOP {count} prcx_CommodityTranslationId, prcx_Abbreviation FROM PRCommodityTranslation WHERE prcx_Abbreviation LIKE '%{prefixText}%' ORDER BY prcx_Description", dbConn);
            SqlCommand cmdCommodities = new SqlCommand(SQL, dbConn);

            using (SqlDataReader oReader = cmdCommodities.ExecuteReader(CommandBehavior.CloseConnection))
            {
                List<String> lReturnList = new List<string>();
                while (oReader.Read())
                {
                    string key = oReader.GetInt32(0).ToString() + "|";
                    if (oReader[2] != DBNull.Value)
                        key += oReader.GetInt32(2).ToString();
                    else
                        key += "0";

                    key += "|";
                    if (oReader[3] != DBNull.Value)
                        key += oReader.GetInt32(3).ToString();
                    else
                        key += "0";

                    key += "|";
                    key += oReader.GetString(4);

                    lReturnList.Add(AjaxControlToolkit.AutoCompleteExtender.CreateAutoCompleteItem(oReader.GetString(1), key));
                }

                return lReturnList.ToArray();
            }
        }
    }
}
