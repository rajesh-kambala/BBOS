/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2014-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CustomFieldCompanyBulkEdit.aspx
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Data;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    public partial class CustomFieldCompanyBulkEdit : PageBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
            SetPageTitle(Resources.Global.BulkCompanyUpdateCustomData);

            if (!IsPostBack)
            {
                PopulateForm();
            }
        }

        protected IBusinessObjectSet _customFields = null;
        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            _customFields = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetByHQ(_oUser.prwu_HQID);
            repCustomFields.DataSource = _customFields;
            repCustomFields.DataBind();

            // Populate selected company list
            PopulateCompanyList();
        }

        protected override string GetBeginColumnSeparator(int count, int columns)
        {
            string seperator = base.GetBeginColumnSeparator(count, columns);

            if (!string.IsNullOrEmpty(seperator))
            {
                //return seperator + "<tr><td class=\"colHeader\" style=\"width:50px;text-align:center;\">Select</td><td class=\"colHeader\" colspan=\"2\" style=\"text-align:center;\">Field</td></tr>";
                //return seperator + "<tr><td class='' style='width:50px;text-align:center;'>Select</td><td class='' colspan='2' style='text-align:center;'>Field</td></tr>";
                return seperator + "<tr></tr>"; //<td class='' style='width:50px;text-align:center;'>Select</td><td class='' colspan='2' style='text-align:center;'>Field</td></tr>";
            }
            return seperator;
        }

        protected void RepCustomFields_ItemCreated(Object Sender, RepeaterItemEventArgs e)
        {
            // Execute the following logic for Items and Alternating Items.
            if (e.Item.ItemType == ListItemType.Item ||
                e.Item.ItemType == ListItemType.AlternatingItem)
            {
                //Get the MyClass instance for this repeater item
                IPRWebUserCustomField customField = (IPRWebUserCustomField)e.Item.DataItem;
                PlaceHolder ph = (PlaceHolder)e.Item.FindControl("phCustomField");

                WebUserCustomField webUserCustomField = (WebUserCustomField)LoadControl("UserControls/WebUserCustomField.ascx");
                webUserCustomField.DisplayCustomField(customField, WebUserCustomField.Mode.BulkEdit);

                ph.Controls.Add(webUserCustomField);
            }
        }

        /// <summary>
        /// Populates the Company list grid view control on the form
        /// </summary>
        protected void PopulateCompanyList()
        {
            // Restrieve the selected companies to use to populate the selected companies 
            // data grid 
            string szSelectedCompanyIDs = GetRequestParameter("CompanyIDList", true, true);

            // Generate the sql required to retrieve the selected companies     
            object[] args = {_oUser.prwu_Culture,
                             _oUser.prwu_WebUserID,
                             _oUser.prwu_HQID,
                             szSelectedCompanyIDs,
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityNewThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             DateTime.Today.AddDays(0 - Configuration.ClaimActivityMeritoriousThresholdIndicatorDays).ToString("MM/dd/yyyy hh:mm:ss"),
                             GetObjectMgr().GetLocalSourceCondition(),
                             GetObjectMgr().GetIntlTradeAssociationCondition()};

            string szSQL = string.Format(SQL_GET_SELECTED_COMPANIES, args);

            szSQL += GetOrderByClause(gvSelectedCompanies);

            // Create empty grid view in case 0 results are found
            //((EmptyGridView)gvSelectedCompanies).EmptyTableRowText = GetNoResultsFoundMsg(Resources.Global.Companies);
            gvSelectedCompanies.ShowHeaderWhenEmpty = true;
            gvSelectedCompanies.EmptyDataText = GetNoResultsFoundMsg(Resources.Global.Companies);

            // Execute search and bind results to grid
            gvSelectedCompanies.DataSource = GetDBAccess().ExecuteReader(szSQL, CommandBehavior.CloseConnection);
            gvSelectedCompanies.DataBind();
            EnableBootstrapFormatting(gvSelectedCompanies);

            //OptimizeViewState(gvSelectedCompanies);

            // Display the number of matching records found
            lblRecordCount.Text = string.Format(Resources.Global.RecordSelectedMsg, gvSelectedCompanies.Rows.Count, Resources.Global.Companies);

            //// If no results are found, disable the buttons that require a company            
            if (gvSelectedCompanies.Rows.Count == 0)
            {
                btnSave.Enabled = false;
                btnCancel.Enabled = false;
            }
        }

        protected void btnSaveOnClick(object sender, EventArgs e)
        {
            string szSelectedCompanyIDs = GetRequestParameter("CompanyIDList", true);
            //string[] aszSelectedCompanyIDs = szSelectedCompanyIDs.Split(new char[] { ',' });

            IBusinessObjectSet customFields = new PRWebUserCustomFieldMgr(_oLogger, _oUser).GetByHQ(_oUser.prwu_HQID);

            string value = null;
            foreach (IPRWebUserCustomField customField in customFields)
            {
                if (Request.Form["CustomFieldDataCB_" + customField.prwucf_WebUserCustomFieldID.ToString()] == "on")
                {
                    if (customField.prwucf_FieldTypeCode == "DDL")
                    {
                        //int lookupID = 0;
                        string name = "CustomFieldDataDDL_" + customField.prwucf_WebUserCustomFieldID.ToString();
                        value = Request.Form[name];

                        //if (!string.IsNullOrEmpty(work))
                        //{
                        //    lookupID = Convert.ToInt32(work);
                        //}

                        //foreach (string comapnyID in aszSelectedCompanyIDs)
                        //{
                        //    customField.SetValue(Convert.ToInt32(comapnyID), lookupID);
                        //}
                    }
                    else
                    {
                        string name = "CustomFieldDataTxt_" + customField.prwucf_WebUserCustomFieldID.ToString();
                        value = Request.Form[name];

                        //foreach (string comapnyID in aszSelectedCompanyIDs)
                        //{
                        //    customField.SetValue(Convert.ToInt32(comapnyID), work);
                        //}
                    }

                    ArrayList oParameters = new ArrayList();
                    oParameters.Add(new ObjectParameter("CompanyID", _oUser.prwu_BBID));
                    oParameters.Add(new ObjectParameter("HQID", _oUser.prwu_HQID));
                    oParameters.Add(new ObjectParameter("UserID", _oUser.prwu_WebUserID));
                    oParameters.Add(new ObjectParameter("CustomFieldID", customField.prwucf_WebUserCustomFieldID));
                    oParameters.Add(new ObjectParameter("CompanyIDList", szSelectedCompanyIDs));
                    oParameters.Add(new ObjectParameter("Value", value));
                    GetDBAccess().ExecuteNonQuery("usp_SetCustomData", oParameters, null, CommandType.StoredProcedure);
                }
            }

            AddUserMessage("The custom data values have been set for the selected companies.", true);
            Response.Redirect(GetReturnURL(PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST));
        }

        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.COMPANY_SEARCH_RESULTS_EXECUTE_LAST));
        }

        protected void btnNewCustomDataOnClick(object sender, EventArgs e)
        {
            SetReturnURL(Request.RawUrl);
            Response.Redirect(string.Format(PageConstants.CUSTOM_FIELD_EDIT, -1));
        }

        /// <summary>
        /// Check users page level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.CustomFields).HasPrivilege;
        }

        /// <summary>        
        /// Check users control/data level authorization
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForData()
        {
            // The user must "own" the list in order to edit it.  This check will be done after the
            // user list data has been retrieved.            
            return true;
        }
    }
}