/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2018

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: About
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Web.UI.WebControls;
using static PRCo.BBOS.UI.Web.PageControlBaseCommon;
using PRCo.EBB.BusinessObjects;

namespace PRCo.BBOS.UI.Web
{
    /// <summary>
    /// Code-behind for the About screen.  
    /// </summary>
    public partial class About : PageBase
    {
        protected Label lblCopyrightYear;
        //protected Table tblBrowserInfo;


        protected Label lblSTSessionID;
        protected Label lblSTStartDateTime;
        protected Label lblSTRequestList;


        protected Literal ltAppName;

        /// <summary>
        /// Initializes the various controls when the page is loaded.  Fires
        /// before any event handlers.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        override protected void Page_Load(object sender, System.EventArgs e)
        {
            base.Page_Load(sender, e);

            SetPageTitle(GetApplicationName() + " " + GetApplicationVersion());

            GetVersionInfo();
            DisplayBrowserInfo();
            DisplayUserInfo();
        }

        /// <summary>
        /// Displays the version information for the various components
        /// of the appliation.
        /// </summary>
        protected void GetVersionInfo()
        {
            litAppVersion.Text = GetApplicationNameAbbr() + " " + Resources.Global.Version;
            lblAppVersion.Text = GetAssemblyInfo(new PageConstants());
            lblFrameworkVersion.Text = GetAssemblyInfo(new PRWebUser());
            lblTSIVersion.Text = GetAssemblyInfo(new TSI.BusinessObjects.SortCriterion());
        }

        /// <summary>
        /// Returns the version information from the specified object's
        /// assembly.
        /// </summary>
        /// <param name="oObject"></param>
        /// <returns></returns>
        protected string GetAssemblyInfo(object oObject)
        {
            System.Reflection.AssemblyName oAssName = oObject.GetType().Assembly.GetName();
            return oAssName.Version.ToString();
        }

        /// <summary>
        /// Adds the two cells (row header, data) to the
        /// specified table.
        /// </summary>
        /// <param name="oCol1"></param>
        /// <param name="oCol2"></param>
        /// <param name="oTable"></param>
        protected void AddCellsToTable(TableCell oCol1,
                                        TableCell oCol2,
                                        Table oTable)
        {
            oCol1.CssClass = "rowHeader";
            oCol1.Width = new Unit(100, UnitType.Pixel);
            TableRow oRow = new TableRow();
            oRow.Cells.Add(oCol1);
            oRow.Cells.Add(oCol2);
            oTable.Rows.Add(oRow);
        }

        /// <summary>
        /// Display information on the current 
        /// user's browser.
        /// </summary>
        protected void DisplayBrowserInfo()
        {
            System.Web.HttpBrowserCapabilities browser = Request.Browser;

            lblUserAgent.Text = UIUtils.GetString(Request.UserAgent);
            lblBrowser.Text = UIUtils.GetString(browser.Browser);
            lblBrowserVersion.Text = UIUtils.GetString(browser.Version);
        }

        /// <summary>
        /// Display information on the current user.
        /// </summary>
        protected void DisplayUserInfo()
        {
            lblUIUserID.Text = _oUser.Email;
            lblCulture.Text = _oUser.prwu_Culture;
        }

        /// <summary>
        /// Determines who is authorized to
        /// view this page.
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return true;
        }

        protected override bool IsAuthorizedForData()
        {
            return true;
        }

        #region Web Form Designer generated code
        override protected void OnInit(EventArgs e)
        {
            //
            // CODEGEN: This call is required by the ASP.NET Web Form Designer.
            //
            InitializeComponent();
            base.OnInit(e);
        }

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
        }
        #endregion
    }
}
