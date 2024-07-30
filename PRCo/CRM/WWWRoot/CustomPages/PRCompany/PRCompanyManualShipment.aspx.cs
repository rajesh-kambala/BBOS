/***********************************************************************
 Copyright Blue Book Services, Inc. 2012-2015

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of PBlue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PRCompanyManualShipment.aspx
 Description:	

 Notes:

***********************************************************************
***********************************************************************/
using System;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRCo.BBS.CRM
{
    public partial class PRCompanyManualShipment : PageBase
    {
        protected string _sSID = string.Empty;
        protected int _iUserID;

        protected string _szReturnURL;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                hidUserID.Value = Request["user_userid"];
                hidSID.Value = Request["SID"];
                hidCompanyID.Value = Request["key1"];

                PopulateForm();
            }

            _iUserID = Int32.Parse(hidUserID.Value);
            _sSID = hidSID.Value;
            _szReturnURL = "PRCompanyAttentionLine.asp?SID=" + _sSID + "&Key0=1&Key1=" + hidCompanyID.Value + "&T=Company&Capt=Contact+Info";

            imgbtnSave.ImageUrl = "/" + _szAppName + "/img/Buttons/save.gif";

            hlContinueImg.ImageUrl = "/" + _szAppName + "/img/Buttons/continue.gif";
            hlContinueImg.NavigateUrl = _szReturnURL;
            hlContinue.NavigateUrl = _szReturnURL;

        }


        protected const string SQL_SELECT_ITEMS =
            @"SELECT capt_code, capt_us 
               FROM Custom_Captions WITH (NOLOCK) 
              WHERE capt_family = 'prshplgd_ItemCode'
            ORDER BY capt_Order";


        protected const string SQL_SELECT_ATTENTION_LINES =
            @"SELECT prattn_AttentionLineID, '<b>' +  CAST(capt_us as VARCHAR(50)) + '</b>:<br/>' + 
                     ISNULL(prattn_CustomLine, dbo.ufn_FormatPerson(pers_FirstName, pers_LastName, pers_MiddleName, null, pers_Suffix)) + '<br/>' +  
                     dbo.ufn_FormatAddress2('<br/>',
							              addr_Address1,
							              addr_Address2,
							              addr_Address3,
							              addr_Address4,
							              addr_Address5,
							              prci_City,
							              ISNULL(prst_Abbreviation, prst_State),
							              prcn_Country,
							              Addr_PostCode) As Delivery
                FROM PRAttentionLine WITH (NOLOCK) 
                     INNER JOIN Custom_Captions WITH (NOLOCK) on prattn_ItemCode = capt_code and capt_family = 'prattn_ItemCode' 
                     LEFT OUTER JOIN Person WITH (NOLOCK) ON prattn_PersonID = pers_PersonID 
                     LEFT OUTER JOIN Address_Link WITH (NOLOCK) ON prattn_CompanyID = adli_CompanyID AND prattn_AddressID = adli_AddressID 
                     LEFT OUTER JOIN Address WITH (NOLOCK) on prattn_AddressID = addr_AddressID 
                     LEFT OUTER JOIN vPRLocation ON addr_PRCityID = prci_CityID 
               WHERE prattn_ItemCode IN ('BOOK-OCT', 'BOOK-APR', 'BOOK-UNV', 'BOOK-F', 'BPRINT', 'KYCG')
                 AND prattn_CompanyID = @CompanyID
            ORDER BY capt_order";

        protected const string SQL_SELECT_ADDRESS =
            @"SELECT addr_AddressID, 
                     '<b>' +  adli_TypeDisplay + '</b>:<br/>' + 
                     dbo.ufn_FormatAddress2('<br/>',
							  addr_Address1,
							  addr_Address2,
							  addr_Address3,
							  addr_Address4,
							  addr_Address5,
							  prci_City,
							  ISNULL(prst_Abbreviation, prst_State),
							  prcn_Country,
							  Addr_PostCode) As Delivery
               FROM vPRAddress
               WHERE adli_CompanyId=@CompanyID";

        protected const string SQL_COMPANY_SUSPENDED =
            @"SELECT prci2_Suspended
                FROM PRCompanyIndicators WITH (NOLOCK)
               WHERE prci2_CompanyID = @CompanyID";

        protected void PopulateForm()
        {
            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdItems = new SqlCommand(SQL_SELECT_ITEMS, dbConn);
                SqlDataReader readerItems = cmdItems.ExecuteReader();
                cblItems.DataSource = readerItems;
                cblItems.DataTextField = "capt_us";
                cblItems.DataValueField = "capt_code";
                cblItems.DataBind();
                readerItems.Close();

                SqlCommand cmdAttentionLines = new SqlCommand(SQL_SELECT_ATTENTION_LINES, dbConn);
                cmdAttentionLines.Parameters.AddWithValue("CompanyID", hidCompanyID.Value);
                SqlDataReader readerAttentionLine = cmdAttentionLines.ExecuteReader();
                rbAttentionLine.DataSource = readerAttentionLine;
                rbAttentionLine.DataTextField = "Delivery";
                rbAttentionLine.DataValueField = "prattn_AttentionLineID";
                rbAttentionLine.DataBind();
                readerAttentionLine.Close();

                SqlCommand cmdAddresses = new SqlCommand(SQL_SELECT_ADDRESS, dbConn);
                cmdAddresses.Parameters.AddWithValue("CompanyID", hidCompanyID.Value);
                SqlDataReader readerAddresses = cmdAddresses.ExecuteReader();
                rbAddresses.DataSource = readerAddresses;
                rbAddresses.DataTextField = "Delivery";
                rbAddresses.DataValueField = "addr_AddressID";
                rbAddresses.DataBind();
                readerAddresses.Close();


                SqlCommand cmdSuspended = new SqlCommand(SQL_COMPANY_SUSPENDED, dbConn);
                cmdSuspended.Parameters.AddWithValue("CompanyID", hidCompanyID.Value);
                object result = cmdSuspended.ExecuteScalar();
                if ((result != null) &&
                    (result != DBNull.Value))
                {
                    btnSave.Enabled = false;
                    imgbtnSave.Enabled = false;
                }                
            }
            catch (Exception e)
            {
                lblMsg.Text += e.Message;
                lblMsg.Text += "<p>" + e.StackTrace + "</p>";
            }
            finally
            {
                CloseDBConnection(dbConn);
            }            

        }

        protected const string SQL_INSERT_SHIPMENT_LOG =
            @"INSERT INTO PRShipmentLog (prshplg_AttentionLineID, prshplg_CompanyID, prshplg_PersonID, prshplg_Addressee, prshplg_AddressID, prshplg_DeliveryAddress, prshplg_MailRoomComments, prshplg_Type, prshplg_CreatedBy, prshplg_CreatedDate, prshplg_UpdatedBy, prshplg_UpdatedDate, prshplg_Timestamp)
               SELECT prattn_AttentionLineID, prattn_CompanyID, prattn_PersonID, Addressee, prattn_AddressID, DeliveryAddress, @Comments, @Type, @User, GETDATE(), @User, GETDATE(), GETDATE()
                 FROM vPRCompanyAttentionLine
                WHERE prattn_AttentionLineID = @AttentionLineID;
              SELECT SCOPE_IDENTITY();";

        protected const string SQL_INSERT_SHIPMENT_LOG2 =
            @"INSERT INTO PRShipmentLog (prshplg_CompanyID, prshplg_Addressee, prshplg_AddressID, prshplg_DeliveryAddress, prshplg_MailRoomComments, prshplg_Type, prshplg_CreatedBy, prshplg_CreatedDate, prshplg_UpdatedBy, prshplg_UpdatedDate, prshplg_Timestamp)
               SELECT @CompanyID, @Addressee, @AddressID, dbo.ufn_FormatAddress2(' ', addr_Address1,addr_Address2,addr_Address3,addr_Address4,addr_Address5,prci_City,ISNULL(prst_Abbreviation, prst_State), prcn_Country, addr_PostCode), @Comments, @Type, @User, GETDATE(), @User, GETDATE(), GETDATE()
                 FROM Address WITH (NOLOCK) 
                      INNER JOIN vPRLocation ON addr_PRCityID = prci_CityID
               WHERE addr_AddressID = @AddressID 
              SELECT SCOPE_IDENTITY();";

        protected const string SQL_INSERT_SHIPMENT_LOG_DETAIL =
            @"INSERT INTO PRShipmentLogDetail (prshplgd_ShipmentLogID, prshplgd_ItemCode, prshplgd_CreatedBy, prshplgd_CreatedDate, prshplgd_UpdatedBy, prshplgd_UpdatedDate, prshplgd_Timestamp)
                VALUES (@ShipmentLogID, @ItemCode, @User, GETDATE(), @User, GETDATE(), GETDATE())";

        protected void btnSaveOnClick(object sender, EventArgs e)
        {

            SqlConnection dbConn = OpenDBConnection();
            try
            {
                SqlCommand cmdShipmentLog = null;
                if (!string.IsNullOrEmpty(rbAttentionLine.SelectedValue))
                {
                    cmdShipmentLog = new SqlCommand(SQL_INSERT_SHIPMENT_LOG, dbConn);
                    cmdShipmentLog.Parameters.AddWithValue("AttentionLineID", rbAttentionLine.SelectedValue);
                }
                else
                {
                    cmdShipmentLog = new SqlCommand(SQL_INSERT_SHIPMENT_LOG2, dbConn);
                    cmdShipmentLog.Parameters.AddWithValue("CompanyID", hidCompanyID.Value);
                    cmdShipmentLog.Parameters.AddWithValue("Addressee", txtAddressee.Text);
                    cmdShipmentLog.Parameters.AddWithValue("AddressID", rbAddresses.SelectedValue);
                }   

                cmdShipmentLog.Parameters.AddWithValue("Comments", txtComments.Text);
                cmdShipmentLog.Parameters.AddWithValue("Type", "Manual");
                cmdShipmentLog.Parameters.AddWithValue("User", hidUserID.Value);
                int shipmentLogID = Convert.ToInt32(cmdShipmentLog.ExecuteScalar());


                foreach (ListItem item in cblItems.Items)
                {
                    if (item.Selected)
                    {
                        SqlCommand cmdShipmentLogDetail = new SqlCommand(SQL_INSERT_SHIPMENT_LOG_DETAIL, dbConn);
                        cmdShipmentLogDetail.Parameters.AddWithValue("ShipmentLogID", shipmentLogID);
                        cmdShipmentLogDetail.Parameters.AddWithValue("ItemCode", item.Value);
                        cmdShipmentLogDetail.Parameters.AddWithValue("User", hidUserID.Value);
                        cmdShipmentLogDetail.ExecuteNonQuery();
                    }
                }


                //DisplayUserMessage("The shipment has been successfully created and placed in the queue.");
                //Response.Redirect("PRCompanyAttentionLine.asp?Key0=1&Key1=" + hidCompanyID.Value + "&SID=" + hidSID.Value);
                Page.ClientScript.RegisterStartupScript(this.GetType(), "success", "success();", true);

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