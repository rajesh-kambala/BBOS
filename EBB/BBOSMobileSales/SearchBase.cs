/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2022-2022

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SearchBase.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRCo.BBOS.UI.Web
{
    public class SearchBase : PageBase
    {
        protected string _szRedirectURL;

        private const string SQL_GET_COUNTRIES =
            @"SELECT    prcn_CountryId, 
                        {0} AS prcn_Country, 
                        prcn_Region, 
                        capt_us as Region
                FROM PRCountry WITH (NOLOCK) 
                     INNER JOIN Custom_Captions ON prcn_Region = capt_Code AND capt_Family = 'prcn_Region'
               WHERE prcn_CountryID >=0 
            ORDER BY capt_order, prcn_Country";

        private const string SQL_GET_STATES =
            @"SELECT prst_StateId, 
                        {0} AS prst_State, 
                        prst_CountryId 
                FROM PRState WITH (NOLOCK)
            ORDER BY prst_CountryId, prst_State";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        /// <summary>
        /// Helper function to reset/clear the controls in the specified table.
        /// </summary>
        /// <param name="tblTable">Table containing controls to clear</param>
        protected void ClearTableValues(Table tblTable)
        {
            foreach (TableRow oRow in tblTable.Rows)
            {
                foreach (TableCell oCell in oRow.Cells)
                {
                    foreach (Control oControl in oCell.Controls)
                    {
                        if ((!string.IsNullOrEmpty(oControl.ID)) &&
                            (oControl.ID.Contains("CHK_")))
                        {
                            CheckBox oCheckbox = (CheckBox)oControl;
                            oCheckbox.Checked = false;
                        }
                        else
                        {
                            // If there is a child table, 
                            // loop through and clear those values
                            if ((!string.IsNullOrEmpty(oControl.ID)) &&
                                (oControl.ID.Contains("TBL_")))
                            {
                                ClearTableValues((Table)oControl);
                            }
                        }
                    }
                }
            }
        }


        /// <summary>
        /// Helper function to disable the controls in the specified table.
        /// </summary>
        /// <param name="tblTable">Table containing controls</param>
        protected void DisableTableControls(Table tblTable)
        {
            foreach (TableRow oRow in tblTable.Rows)
            {
                foreach (TableCell oCell in oRow.Cells)
                {
                    foreach (Control oControl in oCell.Controls)
                    {
                        if (oControl is Table)
                        {
                            DisableTableControls((Table)oControl);

                        }
                        else if (oControl.ID.Contains("CHK_"))
                        {
                            CheckBox oCheckbox = (CheckBox)oControl;
                            oCheckbox.Enabled = false;
                        }
                        else
                        {
                            if (oControl.ID.Contains("LT_") || oControl.ID.Contains("GT_"))
                            {
                                LinkButton oButton = (LinkButton)oControl;
                                oButton.Visible = false;
                            }
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Helper function to re-enable the controls in the specified table.
        /// </summary>
        /// <param name="tblTable">Table containing controls</param>
        protected void EnableTableControls(Table tblTable)
        {
            foreach (TableRow oRow in tblTable.Rows)
            {
                foreach (TableCell oCell in oRow.Cells)
                {
                    foreach (Control oControl in oCell.Controls)
                    {
                        if (oControl is Table)
                        {
                            EnableTableControls((Table)oControl);
                        }
                        else if (oControl.ID.Contains("CHK_"))
                        {
                            CheckBox oCheckbox = (CheckBox)oControl;
                            oCheckbox.Enabled = true;
                        }
                        else
                        {
                            if (oControl.ID.Contains("LT_") || oControl.ID.Contains("GT_"))
                            {
                                LinkButton oButton = (LinkButton)oControl;
                                oButton.Visible = true;
                            }
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Retrieves and stores the current country list from the database
        /// </summary>
        /// <returns>DataTable of current PRCountry values</returns>
        public DataTable GetCountryList()
        {
            string szCacheName = string.Format("dtCountries_{0}", PageControlBaseCommon.GetCulture(_oUser));
            if (GetCacheValue(szCacheName) == null)
            {
                // Retrieve Country List from Database
                string szSQL = string.Format(SQL_GET_COUNTRIES,
                    GetObjectMgr().GetLocalizedColName("prcn_Country"));

                DataSet dsCountryList;
                DataTable dtCountryList;

                dsCountryList = GetDBAccess().ExecuteSelect(szSQL);
                dtCountryList = dsCountryList.Tables[0];

                // Store in Session
                AddCacheValue(szCacheName, dtCountryList);
                return dtCountryList;
            }
            else
            {
                return (DataTable)GetCacheValue(szCacheName);
            }
        }

        /// <summary>
        /// Retrieves and stores the current state list from the database
        /// </summary>
        /// <returns>DataTable of current PRState values</returns>
        public DataTable GetStateList()
        {
            string szCacheName = string.Format("dtStateList_{0}", PageControlBaseCommon.GetCulture(_oUser));
            if (GetCacheValue(szCacheName) == null)
            {
                // Retrieve State List from Database
                string szSQL = string.Format(SQL_GET_STATES,
                    GetObjectMgr().GetLocalizedColName("prst_State"));

                DataSet dsStateList;
                DataTable dtStateList;

                dsStateList = GetDBAccess().ExecuteSelect(szSQL);
                dtStateList = dsStateList.Tables[0];

                // Store in session
                AddCacheValue(szCacheName, dtStateList);
                return dtStateList;
            }
            else
            {
                return (DataTable)GetCacheValue(szCacheName);
            }
        }
    }
}