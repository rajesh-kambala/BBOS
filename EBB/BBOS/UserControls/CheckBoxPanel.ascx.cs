/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CheckBoxPanel
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace PRCo.BBOS.UI.Web.UserControls
{
    /// <summary>
    /// User control that displays a collapsible panel of checkboxes (initially used on CompanySearchService.aspx)
    /// </summary>
    public partial class CheckBoxPanel : UserControlBase
    {
        protected string _szPanelID;
        protected CheckBoxGroup _oCBG;
        public event EventHandler CheckBoxChanged;

        override protected void Page_Load(object sender, EventArgs e)
        {
        }

        public string PanelID
        {
            get { return _szPanelID; }
            set { _szPanelID = value; }
        }

        protected const string PREFIX_CLASS = "CLASS";

        public CheckBoxGroup CBG
        {
            get { return _oCBG; }
            set {
                _oCBG = value;

                cbID.ID = "CHK_" + PREFIX_CLASS + CBG.root.id;
                cbID.Attributes.Add("Value", CBG.root.id);
                cbID.CheckedChanged += new EventHandler(oCheckbox_CheckChanged);
                cbID.AutoPostBack = true;
                cbID.Text = CBG.root.name + GetCompanyCount(CBG.root.count, false);
                cbID.Attributes.Add("onclick", string.Format("toggleTable('{2}{0}', '{2}{1}');", cbID.ClientID, phID.ClientID, "contentMain_"));
                cbID.Attributes.Add("value", CBG.root.id);

                HtmlGenericControl divRow = new HtmlGenericControl("div");
                divRow.Attributes.Add("class", "row");
                phID.Controls.Add(divRow);

                foreach (CheckBoxItem oCBI in CBG.lstItems)
                {
                    HtmlGenericControl divCol = new HtmlGenericControl("div");
                    divCol.Attributes.Add("class", "col-lg-4 col-md-6 col-sm-12 col-xs-12 mar_top_5 nowrapdiv_wraplabel");
                    divRow.Controls.Add(divCol);

                    //Append checkbox
                    CheckBox oCheckbox = new CheckBox();
                    oCheckbox.ID = "CHK_" + PREFIX_CLASS + oCBI.id;

                    oCheckbox.CssClass = "smallcheck nomargin nowrapdiv_wraplabel";

                    oCheckbox.Attributes.Add("Value", oCBI.id);
                    oCheckbox.CheckedChanged += new EventHandler(oCheckbox_CheckChanged);
                    oCheckbox.AutoPostBack = true;
                    oCheckbox.Text = oCBI.name + GetCompanyCount(oCBI.count, false);
                    oCheckbox.InputAttributes["ParentID"] = CBG.root.checkboxId;
                    //oCheckbox.Font.Size = FontUnit.Smaller;

                    divCol.Controls.Add(oCheckbox);
                }
            }
        }

        protected void oCheckbox_CheckChanged(object sender, EventArgs e)
        {
            //Consumer of this control must subscribe to the CheckBoxChanged event that will bubble-up to it
            CheckBoxChanged?.Invoke(this, new EventArgs());
        }

        public string GetToggleOnClick()
        {
            string szOnClick = string.Format("Toggle_Hid('{0}', document.getElementById('<%=hid{0}.ClientID%>'));", PanelID);
            return szOnClick;
        }
    }
}