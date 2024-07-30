/***********************************************************************
 Copyright Produce Reporter Company 2010-2013

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Company is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Company
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRCompanyAttentionLineEdit.aspx
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace PRCo.BBS.CRM
{
    /// <summary>
    /// This page allows the user to edit specific attention lines
    /// and possibly apply those changes to other attenion lines
    /// for the current company.
    /// </summary>
    public partial class PRCompanyAttentionLineEdit : PageBase
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
                hidAttenionLineID.Text = Request["prattn_AttentionLineID"];

                PopulateForm();
            }

            _iUserID = Int32.Parse(hidUserID.Text);
            _sSID = hidSID.Text;
            _szReturnURL = "PRCompanyAttentionLine.asp?SID=" + _sSID + "&Key0=1&Key1=" + hidCompanyID.Value;
            ReturnURL.Value = _szReturnURL;

            imgbtnSave.ImageUrl = "/" + _szAppName + "/img/Buttons/save.gif";

            hlCancelImg.ImageUrl = "/" + _szAppName + "/img/Buttons/cancel.gif";
            hlCancelImg.NavigateUrl = _szReturnURL;
            hlCancel.NavigateUrl = _szReturnURL;

            imgbtnDelete.ImageUrl = "/" + _szAppName + "/img/Buttons/Delete.gif";

            ccFax.ServicePath = "/" + _szAppName + "/CustomPages/AJAXHelper.asmx";
            ccEmail.ServicePath = "/" + _szAppName + "/CustomPages/AJAXHelper.asmx";
        }

        protected const string SQL_SELECT_ATTN =
                 @"SELECT prattn_CompanyID, 
                        dbo.ufn_GetCustomCaptionValue('prattn_ItemCode', prattn_ItemCode, 'en-us') As Item, 
                        prattn_IncludeWireTransferInstructions, 
                        prattn_Disabled, 
                        prattn_PersonID, 
                        prattn_CustomLine, 
                        prattn_AddressID, 
                        prattn_EmailID, 
                        prattn_PhoneID, 
                        prattn_ItemCode, 
                        prattn_UpdatedDate, 
                        ISNULL(user_logon, CAST(prattn_UpdatedBy AS varchar(10))) As UpdatedBy, 
                        comp_PRIndustryType, 
                        prattn_BBOSOnly 
                   FROM PRAttentionLine WITH (NOLOCK) 
                        INNER JOIN Company WITH (NOLOCK) ON comp_CompanyID = prattn_CompanyID 
                        LEFT OUTER JOIN Users WITH (NOLOCK) ON prattn_UpdatedBy = user_userid 
                  WHERE prattn_AttentionLineID = @AttentionLineID";

        protected const string SQL_SELECT_PERSONS =
               @"SELECT pers_PersonID, dbo.ufn_FormatPerson2(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix, 1) As FullName 
                   FROM Person WITH (NOLOCK) 
                        INNER JOIN Person_Link WITH (NOLOCK) ON pers_PersonID = peli_PersonID 
                  WHERE peli_CompanyID=@CompanyID 
                    AND peli_PRStatus IN (1,2) 
                     {0} 
                ORDER BY FullName";

        protected const string SQL_SELECT_ADDRESS =
           @"SELECT addr_AddressID, dbo.ufn_FormatAddress2(' ', addr_Address1,addr_Address2,addr_Address3,addr_Address4,addr_Address5,prci_City, ISNULL(prst_Abbreviation, prst_State), prcn_Country, addr_PostCode) As Address, adli_Type 
               FROM Address WITH (NOLOCK) 
                    INNER JOIN Address_Link WITH (NOLOCK) ON addr_AddressID = adli_AddressID 
                    INNER JOIN vPRLocation ON addr_PRCityID = prci_CityID 
             WHERE adli_CompanyID = @CompanyID";

        protected void PopulateForm()
        {
            int iCompanyID = 0;
            int iPersonID = 0;
            int iAddressID = 0;
            int iPhoneID = 0;
            int iEmailID = 0;
            string szItemCode = null;
            string szIndustryType = null;
            bool bBBOSOnly = false;

            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdAttnLine = new SqlCommand(SQL_SELECT_ATTN, dbConn);
                cmdAttnLine.Parameters.AddWithValue("AttentionLineID", Convert.ToInt32(hidAttenionLineID.Text));
               
                using (SqlDataReader oAttnLineReader = cmdAttnLine.ExecuteReader())
                {
                    oAttnLineReader.Read();
                    iCompanyID = GetInt(oAttnLineReader, 0);
                    lblItem.Text = GetString(oAttnLineReader, 1);
                    cbIncludeWTI.Checked = GetBool(oAttnLineReader, 2);
                    cbDisabled.Checked = GetBool(oAttnLineReader, 3);
                    iPersonID = GetInt(oAttnLineReader, 4);
                    txtCustomLine.Text = GetString(oAttnLineReader, 5);
                    iAddressID = GetInt(oAttnLineReader, 6);
                    iEmailID = GetInt(oAttnLineReader, 7);
                    iPhoneID = GetInt(oAttnLineReader, 8);
                    szItemCode = GetString(oAttnLineReader, 9);

                    lblUpdatedDate.Text = oAttnLineReader.GetDateTime(10).ToString("MM/dd/yyy hh:mm tt");
                    lblUpdatedBy.Text = GetString(oAttnLineReader, 11);

                    szIndustryType = GetString(oAttnLineReader, 12);

                    if (oAttnLineReader[13] != DBNull.Value) {
                        bBBOSOnly = true;
                    }
                }

                string szQualifierClause = string.Empty;
                if (szItemCode.StartsWith("TES"))
                {
                    szQualifierClause = " AND peli_PRSubmitTES = 'Y' ";
                }
                string szSQL = string.Format(SQL_SELECT_PERSONS, szQualifierClause);

                SqlCommand cmdPersons = new SqlCommand(szSQL, dbConn);
                cmdPersons.Parameters.AddWithValue("CompanyID", iCompanyID);
                using (SqlDataReader drPersons = cmdPersons.ExecuteReader())
                {
                    ddlPerson.DataTextField = "FullName";
                    ddlPerson.DataValueField = "pers_PersonID";
                    ddlPerson.DataSource = drPersons;
                    ddlPerson.DataBind();
                    ddlPerson.SelectedIndex = ddlPerson.Items.IndexOf(ddlPerson.Items.FindByValue(iPersonID.ToString()));
                }

                SqlCommand cmdAddress = new SqlCommand(SQL_SELECT_ADDRESS, dbConn);
                cmdAddress.Parameters.AddWithValue("CompanyID", iCompanyID);
                using (SqlDataReader drAddress = cmdAddress.ExecuteReader()) {
                    ddlAddress.DataTextField = "Address";
                    ddlAddress.DataValueField = "addr_AddressID";
                    ddlAddress.DataSource = drAddress;
                    ddlAddress.DataBind();
                    ddlAddress.SelectedIndex = ddlAddress.Items.IndexOf(ddlAddress.Items.FindByValue(iAddressID.ToString()));
                }

                if (szItemCode == "TES-V")
                {
                    lblPhone.Text = "Phone";
                    ccFax.Category = "Phone";
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

            ddlPerson.Items.Insert(0, new ListItem("-- None --", "0"));
            ddlAddress.Items.Insert(0, new ListItem("-- None --", "0"));

            ccFax.SelectedValue = iPhoneID.ToString();
            ccFax.ContextKey = iCompanyID.ToString();

            ccEmail.SelectedValue = iEmailID.ToString();
            ccEmail.ContextKey = iCompanyID.ToString();


            // We maintain several hidden values for the front-end
            // JavaScript to use to validate the changes
            hidCompanyID.Value = iCompanyID.ToString();

            if (iPersonID > 0)
            {
                hidAddressee.Value = "Person";
            }
            else
            {
                hidAddressee.Value = "Custom";
            }

            if (iAddressID > 0)
            {
                hidDelivery.Value = "Address";
            }
            if (iPhoneID > 0)
            {
                hidDelivery.Value = "Fax";
            }
            if (iEmailID > 0)
            {
                hidDelivery.Value = "Email";
            }
            if (bBBOSOnly)
            {
                hidDelivery.Value = "BBOS";
            }

            hidOldAddressee.Value = hidAddressee.Value;
            hidOldDelivery.Value = hidDelivery.Value;
            hidCustom.Value = txtCustomLine.Text;
            hidPersonID.Value = iPersonID.ToString();
            hidAddressID.Value = iAddressID.ToString();
            hidPhoneID.Value = iPhoneID.ToString();
            hidEmailID.Value = iEmailID.ToString();

            // Now determine which delivery options
            // are available based on the item code
            switch (szItemCode)
            {
                case "BILL":
                    hidBBOSEnabled.Value = "false";
                    cbIncludeWTI.Visible = true;
                    break;
                case "BOOK-APR":
                case "BOOK-OCT":
                case "BOOK-UNV":
                case "BOOK-F":
                case "BPRINT":
                case "KYCG":
                case "JEP-M":
                case "TES-M":
                case "BBSICC":
                    hidEmailEnabled.Value = "false";
                    hidFaxEnabled.Value = "false";
                    hidBBOSEnabled.Value = "false";
                    break;
                case "CSUPD":
                case "EXUPD":
                    hidAddressEnabled.Value = "false";
                    hidBBOSEnabled.Value = "false";
                    break;
                case "TES-V":
                    hidEmailEnabled.Value = "false";
                    hidAddressEnabled.Value = "false";
                    hidBBOSEnabled.Value = "false";
                    break;
                case "LRL":
                    hidBBOSEnabled.Value = "false";
                    hidFaxEnabled.Value = "false";
                    break;
                case "ARD":
                    hidBBOSEnabled.Value = "false";
                    hidFaxEnabled.Value = "false";
                    hidAddressEnabled.Value = "false";
                    break;

                case "JEP-E":
                    hidAddressEnabled.Value = "false";
                    hidBBOSEnabled.Value = "false";
                    break;

                case "TES-E":
                    hidAddressEnabled.Value = "false";

                    // Lumber only has Email delivery for electronic
                    // faxes.
                    if (szIndustryType == "L")
                    {
                        hidDelivery.Value = "Email";
                        hidFaxEnabled.Value = "false";
                    }

                    break;
            }

            if ((szItemCode == "BOOK-APR") ||
                (szItemCode == "BOOK-OCT") ||
                (szItemCode == "BOOK-UNV") ||
                (szItemCode == "BOOK-F") ||
                (szItemCode == "BPRINT") ||
                (szItemCode == "KYCG")) {

                tblDeleteButton.Visible = true;
            }
        }

        protected const string SQL_UPDATE_ATTNLINE =
            @"UPDATE PRAttentionLine 
               SET prattn_Disabled = @Disabled, 
                   prattn_PersonID = @PersonID, 
                   prattn_CustomLine = @CustomLine, 
                   prattn_AddressID = @AddressID, 
                   prattn_EmailID = @EmailID, 
                   prattn_PhoneID = @PhoneID, 
                   prattn_BBOSOnly = @BBOSOnly,
                   prattn_IncludeWireTransferInstructions = @IncludWTI,
                   prattn_UpdatedBy = @UserID, 
                   prattn_UpdatedDate = GETDATE(), 
                   prattn_TimeStamp = GETDATE() ";

        protected const string SQL_UDPATE_WHERE = "WHERE prattn_AttentionLineID = @AttentionLineID";
        
        protected const string SQL_UDPATE_WHERE2 = "WHERE prattn_CompanyID = @CompanyID ";

        /// <summary>
        /// We either save a specific attenion line or we update a set based on the
        /// company and old values.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSaveOnClick(object sender, EventArgs e)
        {

            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdAttnLine = new SqlCommand(SQL_UPDATE_ATTNLINE, dbConn);

                if (cbIncludeWTI.Checked)
                {
                    cmdAttnLine.Parameters.AddWithValue("IncludWTI", "Y");
                }
                else
                {
                    cmdAttnLine.Parameters.AddWithValue("IncludWTI", DBNull.Value);
                }

                if (cbDisabled.Checked)
                {
                    cmdAttnLine.Parameters.AddWithValue("Disabled", "Y");
                }
                else
                {
                    cmdAttnLine.Parameters.AddWithValue("Disabled", DBNull.Value);
                }

                if (hidAddressee.Value == "Person")
                {
                    cmdAttnLine.Parameters.AddWithValue("PersonID", Convert.ToInt32(ddlPerson.SelectedValue));
                    cmdAttnLine.Parameters.AddWithValue("CustomLine", DBNull.Value);
                }
                else
                {
                    cmdAttnLine.Parameters.AddWithValue("PersonID", DBNull.Value);
                    cmdAttnLine.Parameters.AddWithValue("CustomLine", txtCustomLine.Text);
                }

                switch (hidDelivery.Value)
                {
                    case "Address":
                        cmdAttnLine.Parameters.AddWithValue("AddressID", Convert.ToInt32(ddlAddress.SelectedValue));
                        cmdAttnLine.Parameters.AddWithValue("PhoneID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("EmailID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("BBOSOnly", DBNull.Value);
                        break;
                    case "Fax":
                        cmdAttnLine.Parameters.AddWithValue("AddressID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("PhoneID", Convert.ToInt32(ddlFax.SelectedValue));
                        cmdAttnLine.Parameters.AddWithValue("EmailID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("BBOSOnly", DBNull.Value);
                        break;
                    case "Email":
                        cmdAttnLine.Parameters.AddWithValue("AddressID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("PhoneID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("EmailID", Convert.ToInt32(ddlEmail.SelectedValue));
                        cmdAttnLine.Parameters.AddWithValue("BBOSOnly", DBNull.Value);
                        break;
                    case "BBOS":
                        cmdAttnLine.Parameters.AddWithValue("AddressID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("PhoneID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("EmailID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("BBOSOnly", "Y");
                        break;
                    default:
                        cmdAttnLine.Parameters.AddWithValue("AddressID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("PhoneID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("EmailID", DBNull.Value);
                        cmdAttnLine.Parameters.AddWithValue("BBOSOnly", DBNull.Value);
                        break;

                }
                cmdAttnLine.Parameters.AddWithValue("UserID", Convert.ToInt32(hidUserID.Text));
                
                // Determine if we're updating many lines
                // or just one.
                string szWhereClause = null;
                if (hidUpdateOthers.Value == "true") {

                    szWhereClause += SQL_UDPATE_WHERE2;
                    cmdAttnLine.Parameters.AddWithValue("CompanyID", Convert.ToInt32(hidCompanyID.Value));

                    // We need criteria for the old addressee
                    if (hidOldAddressee.Value == "Person")
                    {
                        szWhereClause += " AND prattn_PersonID = @OldPersonID ";
                        cmdAttnLine.Parameters.AddWithValue("OldPersonID", Convert.ToInt32(hidPersonID.Value));
                    }
                    else
                    {
                        if (string.IsNullOrEmpty(hidCustom.Value))
                        {
                            szWhereClause += " AND prattn_CustomLine IS NULL ";
                        }
                        else
                        {
                            szWhereClause += " AND prattn_CustomLine = @OldCustom ";
                            cmdAttnLine.Parameters.AddWithValue("OldCustom", hidCustom.Value);
                        }
                    }

                    // We need criteria for the old delivery 
                    switch (hidOldDelivery.Value)
                    {
                        case "Address":
                            szWhereClause += " AND prattn_AddressID = @OldAddressID ";
                            cmdAttnLine.Parameters.AddWithValue("OldAddressID", Convert.ToInt32(hidAddressID.Value));
                            break;
                        case "Fax":
                            szWhereClause += " AND prattn_PhoneID = @OldPhoneID ";
                            cmdAttnLine.Parameters.AddWithValue("OldPhoneID", Convert.ToInt32(hidPhoneID.Value));
                            break;
                        case "Email":
                            szWhereClause += " AND prattn_EmailID = @OldEmailID ";
                            cmdAttnLine.Parameters.AddWithValue("OldEmailID", Convert.ToInt32(hidEmailID.Value));
                            break;
                    }

                    // And of course we need to limit this also by the items
                    // available to the selected delivery method.
                    szWhereClause += " AND prattn_ItemCode IN ";
                    switch (hidDelivery.Value)
                    {
                        case "Address":
                            szWhereClause += "('BILL', 'BOOK-APR', 'BOOK-OCT', 'BOOK-UNV', 'BOOK-F', 'BPRINT', 'KYCG', 'JEP-M', 'LRL', 'TES-M', 'BBSICC')";
                            break;
                        case "Fax":
                            szWhereClause += "('BILL', 'CSUPD', 'EXUPD', 'TES-E', 'JEP-E')"; 
                            break;
                        case "Email":
                            szWhereClause += "('BILL', 'CSUPD', 'EXUPD', 'TES-E', 'JEP-E', 'LRL', 'ARD')"; 
                            break;
                    }

                } else {
                    szWhereClause = SQL_UDPATE_WHERE;
                    cmdAttnLine.Parameters.AddWithValue("AttentionLineID", Convert.ToInt32(hidAttenionLineID.Text));
                }
                
                cmdAttnLine.CommandText += szWhereClause;

                //lblMsg.Text += "hidDelivery.Value:" + hidDelivery.Value + "<br/>";
                //lblMsg.Text += "hidOldDelivery.Value:" + hidOldDelivery.Value + "<br/>";
                //lblMsg.Text += cmdAttnLine.CommandText + "<br/>";
                
                //lblMsg.Text += "CompanyID:" + hidCompanyID.Value + "<br/>";
                //lblMsg.Text += "OldEmailID:" + hidEmailID.Value + "<br/>";
                //lblMsg.Text += "OldPersonID:" + hidPersonID.Value + "<br/>"; 

                
                cmdAttnLine.ExecuteNonQuery();
                //Response.Redirect(_szReturnURL);
                Page.ClientScript.RegisterStartupScript(this.GetType(), "redirect", "redirect();", true);
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }
        }

        protected const string SQL_DELETE_ATTNLINE =
            "DELETE FROM PRAttentionLine WHERE prattn_AttentionLineID=@AttentionLineID";

        protected void btnDeleteOnClick(object sender, EventArgs e)
        {
            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdAttnLine = new SqlCommand(SQL_DELETE_ATTNLINE, dbConn);
                cmdAttnLine.Parameters.AddWithValue("AttentionLineID", Convert.ToInt32(hidAttenionLineID.Text));
                cmdAttnLine.ExecuteNonQuery();
                //Response.Redirect(_szReturnURL);
                Page.ClientScript.RegisterStartupScript(this.GetType(), "redirect", "redirect();", true);
            }
            catch (Exception eX)
            {
                lblMsg.Text += eX.Message;
            }
            finally
            {
                CloseDBConnection(dbConn);
            }
        }
    }
}
