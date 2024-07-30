/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: UserProfile
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Handles the  registration of new users and editing of 
    /// existing users.
    /// 
    /// TODO: Ensure this handles the Membership parameter
    /// correctly.  Assume it is in the session for now.
    /// </summary>
    public partial class UserProfile : EMCWizardBase
    {
        protected string _szAUSReceiveMethod;
        protected string _szAUSReceiveMethod_Email;

        protected string _szAUSChangePreference;
        protected string _szAUSFax;
        protected string _szPRAlertEmail;

        protected IPRWebUser _oRegisteredUser;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            if (!IsPostBack)
            {
                lblIsMembership.Text = (string)Session["IsMembership"];

                if (GetRequestParameter("PurchaseMembership", false) != null)
                {
                    Session["PurchaseMembership"] = GetRequestParameter("PurchaseMembership");
                }
            }

            // Make sure we get the GetObjectByKey using the parameter as a string
            // to ensure the correct overloaded method gets called.
            _oRegisteredUser = (IPRWebUser)new PRWebUserMgr(_oLogger, _oUser).GetObjectByKey(_oUser.prwu_WebUserID.ToString());
            btnRegister.Text = Resources.Global.btnSave;

            SetPageTitle(Resources.Global.MyUserProfile, _oRegisteredUser.Name);

            // Add company submenu to this page
            SetSubmenu("btnUserProfile", blnDisableValidation: true);

            litWelcomeMsg.Text = Resources.Global.WelcomeMsg2;

            lblUserInfo.Text = Resources.Global.LogInSettings; //"Log In Settings";
            btnEditSocialMedia.Visible = true;

            if (Session["IsBBIDLogin"] != null)
            {
                AddUserMessage("This is the only time you will be allowed to login by specifying your BB #.  Please confirm your email address is correct and use it to log in in the future.");
            }

            //AddDoubleClickPreventionJS(btnRegister);
            EnableFormValidation();
            btnCancel.OnClientClick = "DisableValidation();";

            if (!IsPostBack)
            {
                LoadLookupValues();
                PopulateForm();
            }
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// their default values.
        /// </summary>  
        protected void LoadLookupValues()
        {
            BindLookupValues(ddlTimeZone, GetReferenceData("prwu_Timezone"), _oRegisteredUser.prwu_Timezone, true);

            BindLookupValues(ddlLanguage, GetReferenceData("prwu_Culture"), _oRegisteredUser.prwu_Culture);
            BindLookupValues(ddlCompanyUpdateMessageType, GetReferenceData("prwu_CompanyUpdateMessageType"), _oRegisteredUser.prwu_CompanyUpdateMessageType);

            GetAUSSettings();

            // AUS Receive Method defaults
            if (string.IsNullOrEmpty(_szAUSReceiveMethod))
            {
                _szAUSReceiveMethod = "2";  // Email - End of Day
            }
            if (string.IsNullOrEmpty(_szAUSChangePreference))
            {
                _szAUSChangePreference = "2"; // All Changes
            }

            List<ICustom_Caption> lLookupValues = new List<ICustom_Caption>();

            string szMeaning = null;
            if (string.IsNullOrEmpty(_szAUSFax))
            {
                //szMeaning = Resources.Global.AUSNoFaxNumberMsg;
                szMeaning = Resources.Global.NoFaxNumberFound;
                NoFax.Text = Resources.Global.NoFaxNumberFoundText; 
            }
            else
            {
                szMeaning = string.Format(Resources.Global.AUSReceiveFax, _szAUSFax);
            }

            //Defect 4282
            if(string.IsNullOrEmpty(_szPRAlertEmail))
            {
                _szPRAlertEmail = _oRegisteredUser.Email;
            }

            if (_szPRAlertEmail == _oRegisteredUser.Email)
                rbDeliveryMethodEmail.SelectedValue = "1";
            else
            {
                rbDeliveryMethodEmail.SelectedValue = "2";
                hidPeli_PRAlertEmail.Value = _szPRAlertEmail;
            }
            hidRegisteredUserEmail.Value = _oRegisteredUser.Email;

            ICustom_Caption oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = "1";
            oCustom_Caption.Meaning = szMeaning;
            lLookupValues.Add(oCustom_Caption);

            oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = "4";
            oCustom_Caption.Meaning = Resources.Global.AUSRecieveEmailImmediately; //was with _oRegisteredUser.Email
            lLookupValues.Add(oCustom_Caption);

            oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = "2";
            oCustom_Caption.Meaning = Resources.Global.AUSRecieveEmail; //was with _oRegisteredUser.Email
            lLookupValues.Add(oCustom_Caption);

            oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = "3";
            oCustom_Caption.Meaning = Resources.Global.AUSRecieveWeb;
            lLookupValues.Add(oCustom_Caption);

            BindLookupValues(rbDeliveryMethod, lLookupValues, _szAUSReceiveMethod);

            if (string.IsNullOrEmpty(_szAUSFax))
            {
                foreach (ListItem oListItem in rbDeliveryMethod.Items)
                {
                    if (oListItem.Value == "1")
                    {
                        oListItem.Enabled = false;
                    }
                }
            }

            // Delivery Method Email defaults
            if (string.IsNullOrEmpty(_szAUSReceiveMethod_Email))
            {
                _szAUSReceiveMethod_Email = "1";  // Send to PRWebUser.Email
            }

            List<ICustom_Caption> lLookupValues_Email = new List<ICustom_Caption>();
            oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = "1";
            oCustom_Caption.Meaning = string.Format(Resources.Global.SendToEmail, _oRegisteredUser.Email);
            lLookupValues_Email.Add(oCustom_Caption);

            oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = "2";
            oCustom_Caption.Meaning = string.Format(Resources.Global.SendToEmailOther, _oRegisteredUser.Email) + "&nbsp;<input type='text' class='form-control' id='peli_PRAlertEmail' tsiDisplayName='Delivery Method Send To Email' tsiEmail='true' tsiRequired='true' disabled />";
            lLookupValues_Email.Add(oCustom_Caption);

            BindLookupValues(rbDeliveryMethodEmail, lLookupValues_Email, _szAUSReceiveMethod_Email);

            //Other defaults
            BindLookupValues(ddlLocalSourceSearch, GetReferenceData("BBOSSearchLocalSoruce"), _oRegisteredUser.prwu_LocalSourceSearch);
            BindWidgets();
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            // Set User Information
            lblEmail.Text = _oRegisteredUser.Email;

            GetPersonLinkSettings();

            fsCompanySearchSettings.Visible = true;

            fsCompanyUpdateDaysOld.Visible = _oUser.HasPrivilege(SecurityMgr.Privilege.CompanyUpdatesSearchPage).HasPrivilege;
            txtCompanyUpdateDaysOld.Text = Convert.ToString(_oRegisteredUser.prwu_CompanyUpdateDaysOld);

            fsEmailSettings.Visible = true;
            cbEmailPurchases.Checked = _oRegisteredUser.prwu_EmailPurchases;
            cbCompressEmailedPurchases.Checked = _oRegisteredUser.prwu_CompressEmailedPurchases;
            cbCompanyLinksInNewTab.Checked = _oRegisteredUser.prwu_CompanyLinksNewTab;
            cbHideBRPurchConfMsg.Checked = _oRegisteredUser.HideBRPurchaseConfirmationMsg;

            fsAlertsSettings.Visible = true;
            if (_szAUSChangePreference == "1")
            {
                cbAUSKeyOnly.Checked = true;
            }

            if (_oRegisteredUser.prwu_PersonLinkID == 0)
            {
                fsAlertsSettings.Visible = false;
                pnlLumberSettings.Visible = false;
            }

            if (_oRegisteredUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                pnlLumberSettings.Visible = true;
                fsCSSettings.Visible = false;
                trARReports.Visible = false;
            }
            else
            {
                PopulateCSSettings();
            }

            lblEmail.Visible = true;

            if (_oRegisteredUser.prwu_BBID == 0)
            {
                btnEditSocialMedia.Enabled = false;
            }

            if (_oRegisteredUser.HasLocalSourceDataAccess())
            {
                trLocalSource.Visible = true;
            }

            if(_oRegisteredUser.IsLimitado)
            {
                //Hide all panels except the Login Settings panel and AUS Settings
                fsCompanySearchSettings.Visible = false;
                fsCSSettings.Visible = false;
                fsEmailSettings.Visible = false;
                fsWidgets.Visible = false;
            }
        }

        protected const string SQL_AUS_SETTINGS_SELECT =
            @"SELECT peli_PRAUSReceiveMethod, peli_PRAUSChangePreference, dbo.ufn_FormatPhone(fax.phon_CountryCode, fax.phon_AreaCode, fax.phon_Number, fax.phon_PRExtension) As Fax,
                PeLi_PRAlertEmail
               FROM Person_Link WITH (NOLOCK) 
                    LEFT OUTER JOIN vPRPersonPhone fax WITH (NOLOCK) ON peli_PersonID = fax.PLink_RecordID AND fax.phon_PRIsFax = 'Y' AND fax.phon_PRPreferredInternal = 'Y' 
              WHERE peli_PersonLinkID={0}";

        /// <summary>
        /// Retrieves the current user's AUS settings
        /// </summary>
        protected void GetAUSSettings()
        {
            if (_oRegisteredUser.prwu_PersonLinkID == 0)
            {
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("peli_PersonLinkID", _oRegisteredUser.prwu_PersonLinkID));

            string szSQL = GetObjectMgr().FormatSQL(SQL_AUS_SETTINGS_SELECT, oParameters);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                if (oReader.Read())
                {
                    _szAUSReceiveMethod = GetDBAccess().GetString(oReader, 0);
                    _szAUSChangePreference = GetDBAccess().GetString(oReader, 1);
                    _szAUSFax = GetDBAccess().GetString(oReader, 2);
                    _szPRAlertEmail = GetDBAccess().GetString(oReader, 3);
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }

            if (_oRegisteredUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
            {
                ltWhatIsKeyChanges.Text = Resources.Global.KeyChangeDefinitionL;
            }
            else
            {
                ltWhatIsKeyChanges.Text = Resources.Global.KeyChangeDefinition;
            }
        }

        /// <summary>
        /// Saves the user's Alerts (AUS) settings
        /// </summary>
        /// <param name="oTran"></param>
        protected void SaveAlertsSettings(IDbTransaction oTran)
        {
            if (_oRegisteredUser.prwu_PersonLinkID == 0)
            {
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PersonID", _oRegisteredUser.peli_PersonID));
            oParameters.Add(new ObjectParameter("CompanyID", _oRegisteredUser.prwu_BBID));
            oParameters.Add(new ObjectParameter("peli_PersonID", _oRegisteredUser.prwu_PersonLinkID));
            oParameters.Add(new ObjectParameter("ReceiveMethod", rbDeliveryMethod.SelectedValue));

            if (cbAUSKeyOnly.Checked)
            {
                oParameters.Add(new ObjectParameter("ChangePreference", "1"));
            }
            else
            {
                oParameters.Add(new ObjectParameter("ChangePreference", "2"));
            }
            oParameters.Add(new ObjectParameter("CRMUserID", _oRegisteredUser.prwu_WebUserID));

            GetDBAccess().ExecuteNonQuery("usp_AUSSettingsUpdate", oParameters, oTran, CommandType.StoredProcedure);
        }

        protected const string SQL_CS_SETTINGS_SELECT =
            @"SELECT peli_PRCSReceiveMethod, peli_PRCSSortOption, dbo.ufn_FormatPhone(fax.phon_CountryCode, fax.phon_AreaCode, fax.phon_Number, fax.phon_PRExtension) As Fax 
               FROM Person_Link WITH (NOLOCK) 
                    LEFT OUTER JOIN vPRPersonPhone fax WITH (NOLOCK) ON peli_PersonID = fax.PLink_RecordID AND fax.phon_PRIsFax = 'Y' AND fax.phon_PRPreferredInternal = 'Y' 
              WHERE peli_PersonLinkID={0}";

        protected const string SQL_HAS_EXPRESS_UPDATE =
            @"SELECT 'X' FROM PRService WHERE prse_ServiceCode = 'EXUPD' AND prse_HQID={0}";

        /// <summary>
        /// Retrieves the current user's AUS settings
        /// </summary>
        protected void PopulateCSSettings()
        {
            if (_oRegisteredUser.prwu_PersonLinkID == 0)
            {
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("peli_PersonLinkID", _oRegisteredUser.prwu_PersonLinkID));

            string csReceiveMethod = null;
            string csSortOption = null;
            string csFax = null;

            using (IDataReader oReader = GetDBAccess().ExecuteReader(GetObjectMgr().FormatSQL(SQL_CS_SETTINGS_SELECT, oParameters), oParameters, CommandBehavior.CloseConnection, null))
            {
                if (oReader.Read())
                {
                    csReceiveMethod = GetDBAccess().GetString(oReader, 0);
                    csSortOption = GetDBAccess().GetString(oReader, 1);
                    csFax = GetDBAccess().GetString(oReader, 2);
                }
            }

            string csProductName = "Credit Sheet Update Report";
            oParameters.Clear();
            oParameters.Add(new ObjectParameter("prse_HQID", _oRegisteredUser.prwu_HQID));
            object result = GetDBAccess().ExecuteScalar(GetObjectMgr().FormatSQL(SQL_HAS_EXPRESS_UPDATE, oParameters), oParameters);
            if ((result != DBNull.Value) &&
                (result != null))
            {
                csProductName = "Express Update Report";
            }

            // Set Defaults.
            if (string.IsNullOrEmpty(csReceiveMethod))
            {
                csReceiveMethod = "2";  // Email
            }
            if (string.IsNullOrEmpty(csSortOption))
            {
                csSortOption = "I"; // Industry
            }

            List<ICustom_Caption> lLookupValues = new List<ICustom_Caption>();

            string szMeaning = null;
            if (string.IsNullOrEmpty(csFax))
            {
                //szMeaning = Resources.Global.AUSNoFaxNumberMsg;
                szMeaning = "No fax number found.";
                CSNoFax.Text = "Contact Blue Book Customer Service at 630 668-3500 to receive the " + csProductName + " via fax.<br/>";
            }
            else
            {
                szMeaning = string.Format(Resources.Global.AUSReceiveFax, csFax);
            }

            ICustom_Caption oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = "1";
            oCustom_Caption.Meaning = szMeaning;
            lLookupValues.Add(oCustom_Caption);

            oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = "2";
            oCustom_Caption.Meaning = string.Format(Resources.Global.AUSRecieveEmail2, _oRegisteredUser.Email);
            lLookupValues.Add(oCustom_Caption);

            oCustom_Caption = new Custom_Caption();
            oCustom_Caption.Code = "3";
            oCustom_Caption.Meaning = Resources.Global.AUSRecieveWeb;
            lLookupValues.Add(oCustom_Caption);

            BindLookupValues(rbCSDeliveryMethod, lLookupValues, csReceiveMethod);

            if (string.IsNullOrEmpty(csFax))
            {
                foreach (ListItem oListItem in rbDeliveryMethod.Items)
                {
                    if (oListItem.Value == "1")
                    {
                        oListItem.Enabled = false;
                    }
                }
            }

            BindLookupValues(ddlCSSortOption, GetReferenceData("peli_PRCSSortOption"), csSortOption);

            receiveCSProductName.Text = csProductName;
            headCSProductName.Text = csProductName;
        }

        private const string SQL_UPDATE_CS_SETTINGS =
            @"UPDATE Person_Link SET peli_PRCSReceiveMethod=@ReceiveMethod, peli_PRCSSortOption=@SortOption WHERE peli_PersonLinkID=@PersonLinkID";

        /// <summary>
        /// Saves the user's AUS settings
        /// </summary>
        /// <param name="oTran"></param>
        protected void SaveCSettings(IDbTransaction oTran)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("ReceiveMethod", rbCSDeliveryMethod.SelectedValue));
            oParameters.Add(new ObjectParameter("SortOption", ddlCSSortOption.SelectedValue));
            oParameters.Add(new ObjectParameter("PersonLinkID", _oRegisteredUser.prwu_PersonLinkID));

            GetObjectMgr().GetDBAccessFullRights().ExecuteNonQuery(SQL_UPDATE_CS_SETTINGS, oParameters, oTran);
        }

        #region "Widgets"
        private void BindWidgets()
        {
            //Add all widgets to available list
            if(_oUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                BindLookupValues(lstAvailableWidgets, GetReferenceData("PRWebUserWidgetL"));
            else
                BindLookupValues(lstAvailableWidgets, GetReferenceData("PRWebUserWidget"));

            //Get all widgets configured for current user
            PRWebUserWidgetMgr oMgr = new PRWebUserWidgetMgr(_oLogger, _oRegisteredUser);
            IBusinessObjectSet osWebUserWidgets = oMgr.GetObjects(string.Format("{0}={1} ORDER BY prwuw_Sequence", PRWebUserWidgetMgr.COL_PRWUW_WEB_USER_ID, _oRegisteredUser.prwu_WebUserID));

            //Move selected widgets to Selected list
            foreach (PRWebUserWidget owidget in osWebUserWidgets)
            {
                ListItem li = lstAvailableWidgets.Items.FindByValue(owidget.prwuw_WidgetCode);
                if (li != null)
                    MoveWidgetRight(li);
            }

            RefreshWidgetSelections();
        }
        private const string SQL_INSERT_WIDGET =
            @"INSERT INTO PRWebUserWidget (prwuw_WebUserID, prwuw_WidgetCode, prwuw_Sequence) VALUES (@prwuw_WebUserID, @prwuw_WidgetCode, @prwuw_Sequence)";
        private const string SQL_DELETE_WIDGETS =
            @"DELETE FROM PRWebUserWidget WHERE prwuw_WebUserID = @prwuw_WebUserID";

        /// <summary>
        /// Saves the user's Widget settings
        /// </summary>
        /// <param name="oTran"></param>
        protected void SaveWidgetSettings(IDbTransaction oTran)
        {
            //Delete all widget records for current user
            ArrayList oDeleteParameters = new ArrayList();
            oDeleteParameters.Add(new ObjectParameter("prwuw_WebUserID", _oRegisteredUser.prwu_WebUserID));
            GetObjectMgr().GetDBAccessFullRights().ExecuteNonQuery(SQL_DELETE_WIDGETS, oDeleteParameters, oTran);

            //Insert selected widgets for current user
            int iSequence = 1;
            foreach (ListItem li in lstSelectedWidgets.Items)
            {
                ArrayList oInsertParameters = new ArrayList();
                oInsertParameters.Add(new ObjectParameter("prwuw_WebUserID", _oRegisteredUser.prwu_WebUserID));
                oInsertParameters.Add(new ObjectParameter("prwuw_WidgetCode", li.Value));
                oInsertParameters.Add(new ObjectParameter("prwuw_Sequence", iSequence++));

                GetObjectMgr().GetDBAccessFullRights().ExecuteNonQuery(SQL_INSERT_WIDGET, oInsertParameters, oTran);
            }
        }

        protected void btnLeft_Click(object sender, EventArgs e)
        {
            if (lstSelectedWidgets.SelectedIndex != -1)
            {
                //Move right
                int i = 0;
                while (i < lstSelectedWidgets.Items.Count)
                {
                    if (lstSelectedWidgets.Items[i].Selected == true)
                    {
                        lstAvailableWidgets.Items.Add(lstSelectedWidgets.Items[i]);
                        lstSelectedWidgets.Items.Remove(lstSelectedWidgets.Items[i]);
                    }
                    else
                        i++;
                }

                RefreshWidgetSelections();
            }
        }

        protected void btnRight_Click(object sender, EventArgs e)
        {
            if (lstAvailableWidgets.SelectedIndex != -1)
            {
                //Move right
                int i = 0;
                while (i < lstAvailableWidgets.Items.Count)
                {
                    if (lstAvailableWidgets.Items[i].Selected == true)
                    {
                        lstSelectedWidgets.Items.Add(lstAvailableWidgets.Items[i]);
                        lstAvailableWidgets.Items.Remove(lstAvailableWidgets.Items[i]);
                    }
                    else
                        i++;
                }

                RefreshWidgetSelections();
            }
        }

        protected void btnUp_Click(object sender, EventArgs e)
        {
            MoveWidgetItem(lstSelectedWidgets, -1);
        }

        protected void btnDown_Click(object sender, EventArgs e)
        {
            MoveWidgetItem(lstSelectedWidgets, 1);
        }

        private void MoveWidgetRight(ListItem li)
        {
            lstSelectedWidgets.Items.Add(li);
            lstAvailableWidgets.Items.Remove(li);
        }

        private void MoveWidgetLeft(ListItem li)
        {
            lstAvailableWidgets.Items.Add(li);
            lstSelectedWidgets.Items.Remove(li);
        }

        public void MoveWidgetItem(ListBox oListBox, int direction)
        {
            // Checking selected item
            if (oListBox.SelectedItem == null || oListBox.SelectedIndex < 0)
                return; // No selected item - nothing to do

            // Calculate new index using move direction
            int newIndex = oListBox.SelectedIndex + direction;

            // Checking bounds of the range
            if (newIndex < 0 || newIndex >= oListBox.Items.Count)
                return; // Index out of range - nothing to do

            ListItem selected = oListBox.SelectedItem;

            // Removing removable element
            oListBox.Items.Remove(selected);
            // Insert it in new position
            oListBox.Items.Insert(newIndex, selected);
            // Restore selection
            oListBox.SelectedIndex = newIndex;
        }

        private void RefreshWidgetSelections()
        {
            lstAvailableWidgets.ClearSelection();
            lstSelectedWidgets.ClearSelection();

            if (lstAvailableWidgets.Items.Count > 0)
                btnRight.Enabled = true;
            else
                btnRight.Enabled = false;

            if (lstSelectedWidgets.Items.Count > 0)
                btnLeft.Enabled = true;
            else
                btnLeft.Enabled = false;
        }
        #endregion

        /// <summary>
        /// Saves the user's Lumber settings
        /// </summary>
        /// <param name="oTran"></param>
        protected void SaveLumberSettings(IDbTransaction oTran)
        {
            if (_oRegisteredUser.prwu_PersonLinkID == 0)
            {
                return;
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("PersonLinkID", _oRegisteredUser.prwu_PersonLinkID));
            oParameters.Add(new ObjectParameter("WillSubmitARAging", _oObjectMgr.GetPIKSCoreBool(cbWillSubmitARData.Checked)));
            oParameters.Add(new ObjectParameter("ReceivesCreditSheetReport", _oObjectMgr.GetPIKSCoreBool(cbReceiveCreditSheetReport.Checked)));
            oParameters.Add(new ObjectParameter("CRMUserID", _oRegisteredUser.prwu_WebUserID));

            GetDBAccess().ExecuteNonQuery("usp_SaveLumberSettings", oParameters, oTran, CommandType.StoredProcedure);
        }

        private const string SQL_PERSONLINK_SELECT =
            @"SELECT peli_PRReceivesTrainingEmail, peli_PRReceivesPromoEmail, peli_PRWillSubmitARAging, peli_PRReceivesCreditSheetReport, peli_PRReceiveBRSurvey
                FROM Person_Link WITH (NOLOCK)
               WHERE peli_PersonLinkID = @PersonLinkID;";
        protected void GetPersonLinkSettings()
        {
            if (_oRegisteredUser.prwu_PersonLinkID == 0)
            {
                return;
            }

            List<ObjectParameter> parameters = new List<ObjectParameter>();
            parameters.Add(new ObjectParameter("PersonLinkID", _oRegisteredUser.prwu_PersonLinkID));
            IDataReader personLinkReader = GetDBAccess().ExecuteReader(SQL_PERSONLINK_SELECT, parameters, CommandBehavior.CloseConnection, null);
            try
            {
                if (personLinkReader.Read())
                {
                    // Only expecting one of these
                    cbReceivesTrainingEmail.Checked = GetObjectMgr().TranslateFromCRMBool(personLinkReader[0]);
                    cbReceivesPromoEmail.Checked = GetObjectMgr().TranslateFromCRMBool(personLinkReader[1]);
                    cbWillSubmitARData.Checked = GetObjectMgr().TranslateFromCRMBool(personLinkReader[2]);
                    cbReceiveCreditSheetReport.Checked = GetObjectMgr().TranslateFromCRMBool(personLinkReader[3]);
                    cbReceiveBRSurvey.Checked = GetObjectMgr().TranslateFromCRMBool(personLinkReader[4]);
                }
            }
            finally
            {
                if (personLinkReader != null)
                {
                    personLinkReader.Close();
                }
            }
        }

        protected void SaveEmailSettings(IDbTransaction oTran)
        {
            if (_oRegisteredUser.prwu_PersonLinkID == 0)
            {
                return;
            }

            List<ObjectParameter> parameters = new List<ObjectParameter>();
            parameters.Add(new ObjectParameter("PersonLinkID", _oRegisteredUser.prwu_PersonLinkID));
            parameters.Add(new ObjectParameter("ReceivesTrainingEmail", cbReceivesTrainingEmail.Checked));
            parameters.Add(new ObjectParameter("ReceivesPromoEmail", cbReceivesPromoEmail.Checked));
            parameters.Add(new ObjectParameter("ReceivesBRSurveyEMail", cbReceiveBRSurvey.Checked));
            parameters.Add(new ObjectParameter("CRMUserID", _oRegisteredUser.prwu_WebUserID));

            string szAlertEmail = null;

            //Store default or custom email in peli_PRAlertEmail
            if (rbDeliveryMethod.SelectedValue == "2" || rbDeliveryMethod.SelectedValue == "4")
            {
                switch (rbDeliveryMethodEmail.SelectedValue)
                {
                    case "2":
                        szAlertEmail = hidPeli_PRAlertEmail.Value;
                        break;
                    default:
                        szAlertEmail = _oRegisteredUser.Email;
                        break;
                }
            }

            parameters.Add(new ObjectParameter("PRAlertEmail", szAlertEmail));

            GetDBAccess().ExecuteNonQuery("usp_EmailCampaignOptInSettingsUpdate", parameters, oTran, CommandType.StoredProcedure);
        }

        /// <summary>
        /// Populates the user object from the form controls.
        /// </summary>
        /// <returns></returns>
        protected bool PopulateObject()
        {
            if (!_oRegisteredUser.IsInDB)
            {
                // The password fields are required for new users
                if (txtPassword.Text != txtConfirmPassword.Text)
                {
                    AddUserMessage(Resources.Global.PasswordsDoNotMatchMsg);
                    return false;
                }

                _oRegisteredUser.Password = txtPassword.Text;
            }
            else
            {
                // The password fields are not required for existing users so
                // only process them if either are specified.
                if ((!string.IsNullOrEmpty(txtPassword.Text)) ||
                    (!string.IsNullOrEmpty(txtConfirmPassword.Text)))
                {
                    if (txtPassword.Text != txtConfirmPassword.Text)
                    {
                        AddUserMessage(Resources.Global.PasswordsDoNotMatchMsg);
                        return false;
                    }

                    _oRegisteredUser.Password = txtPassword.Text;
                }

                if (Session["IsBBIDLogin"] != null)
                {
                    _oRegisteredUser.prwu_BBIDLoginCount++;
                }
            }

            _oRegisteredUser.prwu_Culture = ddlLanguage.SelectedValue;
            _oRegisteredUser.prwu_UICulture = ddlLanguage.SelectedValue;
            _oRegisteredUser.prwu_Timezone = ddlTimeZone.SelectedValue;

            if(_oRegisteredUser.IsLimitado)
            {
                _oRegisteredUser.Save();
                return true;
            }

            _oRegisteredUser.prwu_CompanyUpdateMessageType = ddlCompanyUpdateMessageType.SelectedValue;
            _oRegisteredUser.prwu_ARReportsThrehold = ddlARReports.SelectedValue;

            if (_oRegisteredUser.HasLocalSourceDataAccess())
            {
                _oRegisteredUser.prwu_LocalSourceSearch = ddlLocalSourceSearch.SelectedValue;
            }

            // Added a little paranoia check here in case the user has managed to slip a non-number here. Just null out the field.
            // Why wouldn't we instead throw an error instead of siliently modifying user input?  CHW
            _oRegisteredUser.prwu_CompanyUpdateDaysOld = Regex.IsMatch(txtCompanyUpdateDaysOld.Text, "^[0-9]+$") ? (int?)int.Parse(txtCompanyUpdateDaysOld.Text) : null;

            _oRegisteredUser.prwu_EmailPurchases = cbEmailPurchases.Checked;
            _oRegisteredUser.prwu_CompressEmailedPurchases = cbCompressEmailedPurchases.Checked;
            _oRegisteredUser.prwu_CompanyLinksNewTab = cbCompanyLinksInNewTab.Checked;
            _oRegisteredUser.HideBRPurchaseConfirmationMsg = cbHideBRPurchConfMsg.Checked;

            IDbTransaction oTran = GetObjectMgr().BeginTransaction();
            try
            {
                SaveEmailSettings(oTran);

                if (_oRegisteredUser.prwu_IndustryType == GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    SaveLumberSettings(oTran);
                }
                SaveAlertsSettings(oTran);

                SaveWidgetSettings(oTran);

                _oRegisteredUser.Save(oTran);
                GetObjectMgr().Commit();

                if (_oRegisteredUser.prwu_IndustryType != GeneralDataMgr.INDUSTRY_TYPE_LUMBER)
                {
                    SaveCSettings(null);
                }

                // If the user is editing themselves, refresh our application
                // user.
                if (_oRegisteredUser.prwu_WebUserID == _oUser.prwu_WebUserID)
                {
                    _oUser = (IPRWebUser)new PRWebUserMgr(_oLogger, _oUser).GetByEmail(_oUser.Email);
                    Session["oUser"] = _oUser;
                }
            }
            catch
            {
                GetObjectMgr().Rollback();
                throw;
            }
            return true;
        }

        /// <summary>
        /// Saves the user and redirects to the appropriate page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnRegisterOnClick(object sender, EventArgs e)
        {
            bool bIsNewUser = !_oRegisteredUser.IsInDB;

            if (PopulateObject())
            {
                if (Session["IsBBIDLogin"] != null)
                {
                    Session["IsBBIDLogin"] = null;
                }

                // Let's refresh our user.
                IPRWebUser oUser = new PRWebUserMgr(_oLogger, _oRegisteredUser).GetByEmail(_oRegisteredUser.Email);
                Session["oUser"] = oUser;
                SetCulture(_oRegisteredUser);
                Response.Redirect(GetReturnURL(PageConstants.BBOS_HOME));
            }
        }

        /// <summary>
        /// Returns the user to the specified ReturnURL
        /// parameter.  If not specified, then the user is returned
        /// to the company search results executing the last search.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            Response.Redirect(GetReturnURL(PageConstants.BBOS_HOME));
        }

        /// <summary>
        /// All users can view this page.
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return true;
        }

        /// <summary>
        /// All users can view this data.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        public override bool EnableJSClientIDTranslation()
        {
            return true;
        }

        protected override bool IsTermsExempt()
        {
            if (Session["IsBBIDLogin"] != null)
            {
                return true;
            }

            if (_oUser.IsLimitado)
                return true;

            return false;
        }

        override protected bool SessionTimeoutForPageEnabled()
        {
            if (Session["IsBBIDLogin"] != null)
            {
                return true;
            }

            return false;
        }

        /// <summary>
        /// Helper method to return a handle to the Company Details Header used on the page to display 
        /// the company BB #, name, and location
        /// </summary>
        /// <returns></returns>
        protected override EMCW_CompanyHeader GetEditCompanyWizardHeader()
        {
            return (EMCW_CompanyHeader)ucCompanyDetailsHeader;
        }
    }
}
