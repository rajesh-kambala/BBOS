/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2017

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: PersonDetailsUserEdit
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Collections;
using System.Web.UI;
using TSI.BusinessObjects;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Allows the user to edit the notes associated
    /// with a Person.
    /// </summary>
    public partial class PersonDetailsUserEdit : PersonDetailsBase
    {
        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Page.Header.Controls.Add(UIUtils.GetJavaScriptControl(UIUtils.JS_FORM_FUNCTIONS_FILE));
            btnSave.OnClientClick = "bDirty=false;";
            btnCancel.OnClientClick = "bDirty=false;DisableValidation();";

            SetPageTitle(Resources.Global.PersonDetails, Resources.Global.AdditionalInformation);
            if (!IsPostBack)
            {
                hidPersonID.Text = GetRequestParameter("PersonID");
                hidPrivateNoteID.Text = "0";
                PopulateForm();
            }
        }

        protected const string SQL_SELECT_NOTES =
             @"SELECT * 
                 FROM vPRWebUserNote 
                 WHERE ((prwun_HQID = {0}  AND prwun_IsPrivate IS NULL) OR (prwun_WebUserID={1} AND prwun_IsPrivate = 'Y')) 
                   AND prwun_AssociatedID={2} 
                   AND prwun_AssociatedType={3}";
        /// <summary>
        /// Populates the Notes section of the page
        /// </summary>
        protected void PopulateForm()
        {
            if (!IsPostBack)
            {
                lblPersonName.Text = GetPersonName();
            }

            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prwun_HQID", _oUser.prwu_HQID));
            oParameters.Add(new ObjectParameter("prwun_WebUserID", _oUser.prwu_WebUserID));
            oParameters.Add(new ObjectParameter("prwun_AssociatedID", hidPersonID.Text));
            oParameters.Add(new ObjectParameter("prwun_AssociatedType", "P"));

            string szSQL = GetObjectMgr().FormatSQL(SQL_SELECT_NOTES, oParameters);
            IDataReader oReader = GetDBAccess().ExecuteReader(szSQL, oParameters, CommandBehavior.CloseConnection, null);
            try
            {
                while (oReader.Read())
                {
                    if (GetDBAccess().GetString(oReader, "prwun_IsPrivate") == "Y")
                    {
                        txtPrivateNotes.Text = GetDBAccess().GetString(oReader, "prwun_Note");
                        hidPrivateNoteID.Text = GetDBAccess().GetInt32(oReader, "prwun_WebUserNoteID").ToString();
                    }
                }
            }
            finally
            {
                if (oReader != null)
                {
                    oReader.Close();
                }
            }
        }

        /// <summary>
        /// Saves the note and returns the user to the
        /// Person Details page.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>   
        protected void btnSaveOnClick(object sender, EventArgs e)
        {
            SaveNote(Convert.ToInt32(hidPersonID.Text), "P", Convert.ToInt32(hidPrivateNoteID.Text), txtPrivateNotes.Text, true);
            Response.Redirect(PageConstants.Format(PageConstants.PERSON_DETAILS, hidPersonID.Text));
        }

        /// <summary>
        /// Takes the user to the Person Details page
        /// without saving any changes.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnCancelOnClick(object sender, EventArgs e)
        {
            Response.Redirect(PageConstants.Format(PageConstants.PERSON_DETAILS, hidPersonID.Text));
        }
    }
}