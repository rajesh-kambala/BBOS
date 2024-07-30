/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2023

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: SearchBase
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

using PRCo.EBB.BusinessObjects;


namespace PRCo.BBOS.UI.Web
{
    public class SearchBase : PageBase
    {
        protected int _iSearchID;
        protected bool _bIsDirty = false;
        public static char[] achDelimiter = new char[] { ',' };

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

        private const string SQL_GET_TERMINAL_MARKETS =
            @"SELECT prtm_TerminalMarketId, prtm_FullMarketName, prtm_City, prtm_State, prst_StateID, prtm_ListedMarketName 
                FROM PRTerminalMarket WITH (NOLOCK) 
                     LEFT OUTER JOIN PRState WITH (NOLOCK) ON prtm_State = prst_Abbreviation 
             ORDER BY prtm_State, prtm_City, prtm_ListedMarketName ";

        protected const string REF_DATA_INDUSTRY_TYPE = "BBOSSearchIndustryType";

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);
        }

        protected void ApplySecurity(List<Control> lControls, SecurityMgr.Privilege privilege, bool bForceAllowed = false, bool bBBOS9 = false)
        {
            SecurityMgr.SecurityResult result = null;
            if (bForceAllowed)
            {
                result = new SecurityMgr.SecurityResult();
                result.HasPrivilege = true;
                result.Enabled = true;
                result.Visible = true;
            }
            else
            {
                result = _oUser.HasPrivilege(privilege);
            }

            if (!result.HasPrivilege)
            {
                foreach (Control oControlRaw in lControls)
                {
                    if (oControlRaw is WebControl)
                    {
                        WebControl oControl = (WebControl)oControlRaw;
                        //oControl.Enabled
                        if (oControl is CheckBox ||
                            oControl is CheckBoxList ||
                            oControl is DropDownList ||
                            oControl is Label ||
                            oControl is LinkButton ||
                            oControl is RadioButtonList ||
                            oControl is TextBox || 
                            oControl is Panel)
                        {
                            oControl.Enabled = result.Enabled;
                            oControl.Visible = result.Visible;
                        }
                        else if (oControl is HyperLink)
                        {
                            oControl.Enabled = result.Enabled;
                            oControl.Visible = result.Visible;
                            if (bBBOS9)
                            {
                                if (!oControl.Enabled)
                                {
                                    ((HyperLink)oControl).NavigateUrl = "";
                                    ((HyperLink)oControl).CssClass += " disabled";
                                }
                            }
                        }
                        else if (oControl is Panel)
                        {
                            oControl.Visible = false;
                        }
                        else if (oControl is Table)
                        {
                            Table tblControl = (Table)oControl;
                            DisableTableControls(tblControl);
                        }
                    }
                    else if(oControlRaw is HtmlControl)
                    {
                        HtmlControl oControl = (HtmlControl)oControlRaw;

                        if (oControl is HtmlInputCheckBox ||
                            oControl is HtmlGenericControl)
                        {
                            oControl.Disabled = !result.Enabled;
                            oControl.Visible = result.Visible;

                            if(!result.Enabled)
                                oControl.Attributes.Add("disabled","");
                            if (!result.Visible)
                                oControl.Attributes.Add("class", "tw-hidden");
                        }
                    }
                }
            }
        }

        protected void ApplySecurity_Bootstrap(IEnumerable<WebControl> lControls, SecurityMgr.Privilege privilege)
        {
            SecurityMgr.SecurityResult result = _oUser.HasPrivilege(privilege);

            if (!result.HasPrivilege)
            {
                foreach (WebControl oControl in lControls)
                {
                    //oControl.Enabled
                    if (oControl is CheckBox ||
                        oControl is CheckBoxList ||
                        oControl is DropDownList ||
                        oControl is Label ||
                        oControl is LinkButton ||
                        oControl is RadioButtonList ||
                        oControl is TextBox)
                    {
                        oControl.Enabled = result.Enabled;
                        oControl.Visible = result.Visible;
                    }
                    else if (oControl is Panel)
                    {
                        oControl.Visible = false;
                    }
                    else if (oControl is Table)
                    {
                        Table tblControl = (Table)oControl;
                        DisableTableControls(tblControl);
                    }
                }
            }
        }

        /// <summary>
        /// Retrieves the current table value for the condition and return column specified
        /// </summary>
        /// <param name="dtValueList">DataTable of list values</param>
        /// <param name="szCodeCondition">Code condition to return</param>
        /// <param name="szReturnColumn">Column name to pull return value from</param>
        /// <returns></returns>
        public string GetValueFromList(DataTable dtValueList, string szCodeCondition, string szReturnColumn)
        {
            string szValue = "";

            DataRow[] adrValue = dtValueList.Select(szCodeCondition);
            foreach (DataRow drRow in adrValue)
            {
                szValue = drRow[szReturnColumn].ToString();
            }

            return szValue;
        }

        #region "TableValues"
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

        protected void ClearTableValues_AllCheckboxes(Control oParent)
        {
            foreach (CheckBox oCheckbox in oParent.FindDescendants<CheckBox>())
            {
                if ((oCheckbox.ID.Contains("CHK_")))
                    oCheckbox.Checked = false;
            }
        }
        #endregion

        #region "PlaceholderValues"
        /// <summary>
        /// Helper function to reset/clear the controls in the specified placeholder
        /// </summary>
        /// <param name="phControl">Control containing controls to clear</param>
        protected void ClearPlaceholderValues(PlaceHolder phControl)
        {
            foreach (Control oSpan in phControl.Controls)
            {
                foreach (Control oControl in oSpan.Controls)
                {
                    if ((!string.IsNullOrEmpty(oControl.ID)) &&
                        (oControl.ID.Contains("CHK_")))
                    {
                        CheckBox oCheckbox = (CheckBox)oControl;
                        oCheckbox.Checked = false;
                    }

                    //TODO: handle child tables if needed
                }
            }
        }
        #endregion

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

        public void BindCountryValues(ListControl oList,
                                      string filter)
        {
            BindCountryValues(oList, filter, "prcn_Country");
        }

        public void BindCountryValues(ListControl oList,
                                      string filter,
                                      string sort)
        {
            DataView dv = new DataView(GetCountryList());
            dv.RowFilter = filter;
            dv.Sort = sort;

            oList.DataSource = dv;
            oList.DataTextField = "prcn_Country";
            oList.DataValueField = "prcn_CountryID";
            oList.DataBind();
        }

        public string SetValue(string value, ListControl oList)
        {
            string work = GetSelectedValues(oList);

            if (!string.IsNullOrEmpty(work))
            {
                if (!string.IsNullOrEmpty(value))
                {
                    value += ",";
                }
                value += work;
            }

            return value;
        }
        public string addValue(string value, HtmlInputRadioButton oRadioButton)
        {
            if(oRadioButton.Checked)
            {
                if (!string.IsNullOrEmpty(value))
                {
                    if (value.Split(',').Contains(oRadioButton.Value))
                        return value;

                    value += ",";
                }
                value += oRadioButton.Value;
            }

            return value;
        }
        public string addValue(string value, string szID)
        {
            if (szID != "" && !string.IsNullOrEmpty(value))
            {
                value += ",";
            }
            value += szID;

            return value;
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

        /// <summary>
        /// Retrieves and stores the current terminal market list from the database
        /// </summary>
        /// <returns>DataTable of current PRTerminalMarket values</returns>
        public DataTable GetTerminalMarketList()
        {
            string szCacheName = "dtTerminalMarketList";
            if (GetCacheValue(szCacheName) == null)
            {
                // Retrieve Terminal Market List from Database
                string szSQL = SQL_GET_TERMINAL_MARKETS;

                DataSet dsTerminalMarketList;
                DataTable dtTerminalMarketList;

                dsTerminalMarketList = GetDBAccess().ExecuteSelect(szSQL);
                dtTerminalMarketList = dsTerminalMarketList.Tables[0];

                // Store in Session
                AddCacheValue(szCacheName, dtTerminalMarketList);
                return dtTerminalMarketList;
            }
            else
            {
                return (DataTable)GetCacheValue(szCacheName);
            }
        }

        /// <summary>
        /// Helper method to lookup the corresponding code value for data stored within
        /// the given datatable.
        /// </summary>
        /// <param name="aszCodeList">List of Codes</param>
        /// <param name="dtListData">DataTable for lookup</param>
        /// <param name="szCodeColumnName">Code Column Name</param>
        /// <param name="szMeaningColumnName">Value Column Name</param>
        /// <returns>String of translated values</returns>
        public string TranslateListValues(string[] aszCodeList, DataTable dtListData,
            string szCodeColumnName, string szMeaningColumnName)
        {
            string szValueList = "";

            foreach (string szCode in aszCodeList)
            {
                if (!String.IsNullOrEmpty(szCode))
                {
                    if (szValueList.Length > 0)
                        szValueList += ", ";
                    szValueList += GetValueFromList(dtListData, szCodeColumnName + " = " + szCode, szMeaningColumnName);
                }
            }

            return szValueList;
        }
    }
}