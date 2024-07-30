/***********************************************************************
 Copyright Blue Book Services, Inc. 2016

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of lue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRCompanySendRequests.aspx
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRCo.BBS.CRM
{
    public partial class PRCompanySendRequests : PageBase
    {
        protected string _sSID = string.Empty;
        protected int _iUserID;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                hidUserID.Text = Request["user_userid"];
                hidSID.Text = Request["SID"];
                hidCompanyID.Text = Request["comp_CompanyID"];
                if (string.IsNullOrEmpty(hidCompanyID.Text))
                {
                    hidCompanyID.Text = Request["Key1"];
                }
                PopulateForm();

                trContinue.Visible = false;
            }

            _iUserID = Int32.Parse(hidUserID.Text);
            _sSID = hidSID.Text;

            imgbtnSave.ImageUrl = "/" + _szAppName + "/img/Buttons/sendletter.gif";

            hlCancelImg.ImageUrl = "/" + _szAppName + "/img/Buttons/continue.gif";
            hlCancelImg.NavigateUrl = "PRCompanySummary.asp?SID=" + _sSID + "&Key0=1&Key1=" + hidCompanyID.Text;
            hlCancel.NavigateUrl = "PRCompanySummary.asp?SID=" + _sSID + "&Key0=1&Key1=" + hidCompanyID.Text;

            hlContinueImg.ImageUrl = "/" + _szAppName + "/img/Buttons/continue.gif";
            hlContinueImg.NavigateUrl = "PRCompanySummary.asp?SID=" + _sSID + "&Key0=1&Key1=" + hidCompanyID.Text;
            hlContinue.NavigateUrl = "PRCompanySummary.asp?SID=" + _sSID + "&Key0=1&Key1=" + hidCompanyID.Text;

        }

        private const string SQL_SELECT_COMPANY =
            @"SELECT comp_PRCommunicationLanguage, comp_PRIndustryType
                  FROM Company WITH (NOLOCK)
                 WHERE comp_CompanyID=@CompanyID";

        private const string SQL_SELECT_PERSONS =
            @"SELECT pers_PersonID,
                       Pers_FullName,
	                   peli_PRTitle,
	                   emai_EmailAddress
                  FROM vPRPersonnelListing
                 WHERE peli_CompanyID=@CompanyID
                   AND peli_PRStatus = '1'
                   AND emai_EmailAddress IS NOT NULL
              ORDER BY pers_FullName";

        protected void PopulateForm()
        {
            SqlConnection dbConn = OpenDBConnection("SendRequests");

            SqlCommand cmdCompanyInfo = new SqlCommand(SQL_SELECT_COMPANY, dbConn);
            cmdCompanyInfo.Parameters.AddWithValue("CompanyID", Convert.ToInt32(hidCompanyID.Text));

            using (SqlDataReader reader = cmdCompanyInfo.ExecuteReader())
            {
                if (reader.Read())
                {
                    hidIndustryType.Text = reader["comp_PRIndustryType"].ToString();
                    hidLanguage.Text = reader["comp_PRCommunicationLanguage"].ToString();
                    if (hidLanguage.Text == "S")
                    {
                        lblSpanish.Visible = true;
                    }
                }
            }


            try
            {
                SqlCommand cmdRequestCount = new SqlCommand(SQL_SELECT_PERSONS, dbConn);
                cmdRequestCount.Parameters.AddWithValue("CompanyID", Convert.ToInt32(hidCompanyID.Text));
                repPersons.DataSource = cmdRequestCount.ExecuteReader();
                repPersons.DataBind();
            }
            finally
            {
                dbConn.Close();
            }
        }

        protected void btnSaveOnClick(object sender, EventArgs e)
        {
            string tempReportsFolder = GetConfigValue("TempReports");
            string sqlReportsFolder = GetConfigValue("SQLReportPath");
            string templatesFolder = GetConfigValue("TemplatesPath");

            StringBuilder attachmentList = new StringBuilder();

            string personID = Request["rbPersonID"];
            string personEmail = Request["personEmail" + personID];

            SqlConnection dbConn = OpenDBConnection("SendRequests");
            try
            {
                SqlCommand cmdCreateEmail = new SqlCommand("usp_CreateEmail", dbConn);
                cmdCreateEmail.CommandType = CommandType.StoredProcedure;
                cmdCreateEmail.Parameters.AddWithValue("CreatorUserId", hidUserID.Text);
                cmdCreateEmail.Parameters.AddWithValue("RelatedCompanyId", hidCompanyID.Text);
                cmdCreateEmail.Parameters.AddWithValue("RelatedPersonId", personID);
                cmdCreateEmail.Parameters.AddWithValue("DoNotRecordCommunication", GetConfigValue("CompanySendRequestsDoNotRecordCommunication", "0"));
                cmdCreateEmail.Parameters.AddWithValue("Source", "Company Send Requests");
                cmdCreateEmail.Parameters.AddWithValue("Content_Format", "HTML");
                cmdCreateEmail.Parameters.AddWithValue("To", personEmail);
                cmdCreateEmail.Parameters.AddWithValue("Action", "EmailOut");
                cmdCreateEmail.Parameters.AddWithValue("PRCategory", "R");

                string subject = null;
                string emailBody = null;

                switch (hidLanguage.Text)
                {
                    case "E":
                        using (StreamReader srTemplate = new StreamReader(Path.Combine(templatesFolder, "NewListingRequest.html")))
                        {
                            emailBody = srTemplate.ReadToEnd();
                        }

                        subject = GetConfigValue("CompanySendRequestsEmailSubject", "More information needed to establish Blue Book Rating");
                        emailBody = GetFormattedEmail(dbConn,
                                                        null,
                                                        Convert.ToInt32(hidCompanyID.Text),
                                                        Convert.ToInt32(personID),
                                                        subject,
                                                        emailBody,
                                                        string.Empty);

                        if (hidIndustryType.Text == "T")
                        {
                            File.Copy(Path.Combine(templatesFolder, "Transportation Reference List.pdf"), Path.Combine(tempReportsFolder, "Transportation Reference List.pdf"), true);
                            attachmentList.Append(Path.Combine(sqlReportsFolder, "Transportation Reference List.pdf"));
                        }
                        else
                        {
                            File.Copy(Path.Combine(templatesFolder, "Produce Reference List.pdf"), Path.Combine(tempReportsFolder, "Produce Reference List.pdf"), true);
                            attachmentList.Append(Path.Combine(sqlReportsFolder, "Produce Reference List.pdf"));
                        }
                        break;

                    case "S":
                        using (StreamReader srTemplate = new StreamReader(Path.Combine(templatesFolder, "NewListingRequest - Spanish.html")))
                        {
                            emailBody = srTemplate.ReadToEnd();
                        }

                        subject = GetConfigValue("CompanySendRequestsEmailSubjectSpanish", "Más información necesaria para establecer la clasificación del libro azul/Blue Book");
                        emailBody = GetFormattedEmail(dbConn,
                                                        null,
                                                        Convert.ToInt32(hidCompanyID.Text),
                                                        Convert.ToInt32(personID),
                                                        subject,
                                                        emailBody,
                                                        string.Empty,
                                                        "es-mx");

                        if (hidIndustryType.Text == "T")
                        {
                            File.Copy(Path.Combine(templatesFolder, "Transportation Reference List - Spanish.pdf"), Path.Combine(tempReportsFolder, "Transportation Reference List - Spanish.pdf"), true);
                            attachmentList.Append(Path.Combine(sqlReportsFolder, "Transportation Reference List - Spanish.pdf"));
                        }
                        else
                        {
                            File.Copy(Path.Combine(templatesFolder, "Produce Reference List - Spanish.pdf"), Path.Combine(tempReportsFolder, "Produce Reference List - Spanish.pdf"), true);
                            attachmentList.Append(Path.Combine(sqlReportsFolder, "Produce Reference List - Spanish.pdf"));
                        }
                        break;
                }

                LogMessage(attachmentList.ToString());

                cmdCreateEmail.Parameters.AddWithValue("Subject", subject);
                cmdCreateEmail.Parameters.AddWithValue("AttachmentFileName", attachmentList.ToString());
                cmdCreateEmail.Parameters.AddWithValue("Content", emailBody);
                cmdCreateEmail.ExecuteNonQuery();

                trMsg.Visible = true;
                lblMsg.Text = "Successfully generated and sent the Financial Statement and Reference List request.";


                trContinue.Visible = true;
                trCancel.Visible = false;
                trSave.Visible = false;
            }
            catch (Exception eX)
            {
                trMsg.Visible = true;
                lblMsg.Text += eX.Message;
                lblMsg.Text += "<br/><pre>" + eX.StackTrace + "</pre>";
            }
            finally
            {
                CloseDBConnection(dbConn);
            }
        }

        private void LogMessage(string msg)
        {
            trMsg.Visible = true;
            lblMsg.Text += "<br/>" + msg;
        }
    }
}