/***********************************************************************
 Copyright Blue Book Services, Inc. 2013-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRCompanySocialMediaEdit.aspx
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace PRCo.BBS.CRM
{
    public partial class PRCompanySocialMediaEdit : PageBase
    {
        protected string _sSID = string.Empty;
        protected int _iUserID;

        protected string _szReturnURL;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                hidUserID.Text = Request["user_userid"];
                hidSID.Text = Request["SID"];
                hidCompanyID.Text = Request["CompanyID"];
                PopulateSocialMedia(Convert.ToInt32(hidCompanyID.Text));
            }

            _iUserID = Int32.Parse(hidUserID.Text);
            _sSID = hidSID.Text;
            _szReturnURL = "PRCompanyContactInfoListing.asp?SID=" + _sSID + "&Key0=1&Key1=" + hidCompanyID.Text + "&T=Company&Capt=Contact+Info";
            ReturnURL.Value = _szReturnURL;

            imgbtnSave.ImageUrl = "/" + _szAppName + "/img/Buttons/save.gif";

            hlCancelImg.ImageUrl = "/" + _szAppName + "/img/Buttons/cancel.gif";
            hlCancelImg.NavigateUrl = _szReturnURL;
            hlCancel.NavigateUrl = _szReturnURL;
        }





        protected const string SQL_SOCIAL_MEDIA =
            "SELECT RTRIM(capt_Code) AS capt_Code, capt_US, prsm_SocialMediaID, prsm_SocialMediaTypeCode, prsm_URL " +
              "FROM custom_captions " +
                   "LEFT OUTER JOIN PRSocialMedia ON capt_code = prsm_SocialMediaTypeCode AND prsm_CompanyID=@CompanyID AND prsm_Disabled IS NULL " +
             "WHERE capt_Family = 'prsm_SocialMediaTypeCode' " +
            "ORDER BY Capt_Order ";

        protected const string SQL_SOCIAL_MEDIA_DOMAIN =
            "SELECT  RTRIM(capt_Code) AS capt_Code, capt_US FROM Custom_Captions WHERE capt_Family = 'prsm_SocialMediaDomain'";


        protected void PopulateSocialMedia(int companyID)
        {

            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdSocialMedia = new SqlCommand(SQL_SOCIAL_MEDIA, dbConn);
                cmdSocialMedia.Parameters.AddWithValue("CompanyID", companyID);

                using (SqlDataReader smReader = cmdSocialMedia.ExecuteReader(CommandBehavior.Default)) {
                    repSocialMedia.DataSource = smReader;
                    repSocialMedia.DataBind();
                }

                SqlCommand cmdSocialMediaDomain = new SqlCommand(SQL_SOCIAL_MEDIA_DOMAIN, dbConn);
                using (SqlDataReader smdReader = cmdSocialMediaDomain.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    repSocialMediaDomains.DataSource = smdReader;
                    repSocialMediaDomains.DataBind();
                }

            }
            catch (Exception e)
            {
                lblMsg.Text += e.Message;
            }
        }


       
        protected void btnSaveOnClick(object sender, EventArgs e)
        {
            int companyID = Convert.ToInt32(hidCompanyID.Text);

            SqlConnection dbConn = OpenDBConnection();
            SqlTransaction oTran = null;
            try
            {
                List<string> socialMediaCodes = new List<string>();

                SqlCommand cmdSocialMedia = new SqlCommand(SQL_SOCIAL_MEDIA, dbConn, oTran);
                cmdSocialMedia.Parameters.AddWithValue("CompanyID", companyID);

                using (SqlDataReader reader = cmdSocialMedia.ExecuteReader(CommandBehavior.Default))
                {
                    while (reader.Read())
                    {
                        socialMediaCodes.Add(reader.GetString(0));
                    }
                }

                oTran = dbConn.BeginTransaction();
                foreach (string customCaptionCode in socialMediaCodes)
                {

                    string id = Request["hdnSMID_" + customCaptionCode];
                    string url = Request["txtSMURL_" + customCaptionCode];

                    if (!string.IsNullOrEmpty(url))
                    {
                        if (string.IsNullOrEmpty(id))
                        {
                            InsertSocialMedia(companyID, customCaptionCode, url, oTran);
                        }
                        else
                        {
                            UpdateSocialMedia(Convert.ToInt32(id), url, oTran);
                        }
                    }
                    else
                    {
                        if (!string.IsNullOrEmpty(id))
                        {
                            DeleteSocialMedia(Convert.ToInt32(id), oTran);
                        }

                    }
                }
                oTran.Commit();

                //Response.Redirect(_szReturnURL);
                Page.ClientScript.RegisterStartupScript(this.GetType(), "redirect", "redirect();", true);
            }
            catch (Exception eX)
            {
                oTran.Rollback();
                lblMsg.Text = eX.Message;
            }
        }


        protected const string SQL_PRSOCIALMEDIA_INSERT = 
            @"INSERT INTO PRSocialMedia (prsm_CompanyID, prsm_SocialMediaTypeCode, prsm_URL, prsm_CreatedBy, prsm_CreatedDate, prsm_UpdatedBy, prsm_UpdatedDate, prsm_TimeStamp) 
                                 VALUES (@prsm_CompanyID, @prsm_SocialMediaTypeCode, @prsm_URL, @UserID, GETDATE(), @UserID, GETDATE(), GETDATE())";


        public void InsertSocialMedia(int companyID, string typeCode, string url, SqlTransaction oTran)
        {
            SqlCommand cmdSocialMedia = new SqlCommand(SQL_PRSOCIALMEDIA_INSERT, oTran.Connection, oTran);
            cmdSocialMedia.Parameters.AddWithValue("prsm_CompanyID", companyID);
            cmdSocialMedia.Parameters.AddWithValue("prsm_SocialMediaTypeCode", typeCode);
            cmdSocialMedia.Parameters.AddWithValue("prsm_URL", url);
            cmdSocialMedia.Parameters.AddWithValue("UserID", Convert.ToInt32(hidUserID.Text));

            cmdSocialMedia.ExecuteNonQuery();
        }

        protected const string SQL_PRSOCIALMEDIA_UPDATE =
            "UPDATE PRSocialMedia SET prsm_URL=@prsm_URL, prsm_UpdatedBy=@UserID, prsm_UpdatedDate=GETDATE(), prsm_TimeStamp=GETDATE() WHERE prsm_SocialMediaID=@prsm_SocialMediaID";
        public void UpdateSocialMedia(int recordID, string url, SqlTransaction oTran)
        {
            SqlCommand cmdSocialMedia = new SqlCommand(SQL_PRSOCIALMEDIA_UPDATE, oTran.Connection, oTran);
            cmdSocialMedia.Parameters.AddWithValue("prsm_URL", url);
            cmdSocialMedia.Parameters.AddWithValue("prsm_SocialMediaID", recordID);
            cmdSocialMedia.Parameters.AddWithValue("UserID", Convert.ToInt32(hidUserID.Text));

            cmdSocialMedia.ExecuteNonQuery();
        }

        protected const string SQL_PRSOCIALMEDIA_DELETE = "DELETE FROM PRSocialMedia WHERE prsm_SocialMediaID=@prsm_SocialMediaID";
        public void DeleteSocialMedia(int recordID, SqlTransaction oTran)
        {
            SqlCommand cmdSocialMedia = new SqlCommand(SQL_PRSOCIALMEDIA_DELETE, oTran.Connection, oTran);
            cmdSocialMedia.Parameters.AddWithValue("prsm_SocialMediaID", recordID);
            cmdSocialMedia.ExecuteNonQuery();
        }
    }
}