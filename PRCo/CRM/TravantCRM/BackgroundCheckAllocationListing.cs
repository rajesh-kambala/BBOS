/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, LLC. 2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, LLC is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, LLC.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using Sage.CRM.Blocks;
using Sage.CRM.Controls;
using Sage.CRM.Data;
using Sage.CRM.HTML;
using Sage.CRM.Utils;
using Sage.CRM.WebObject;
using Sage.CRM.UI;

namespace BBSI.CRM
{
    public class BackgroundCheckAllocationListing : CompanyBase
    {
        public override void BuildContents()
        {
            try
            {
                SetRequestName("BackgroundCheckAllocationListing");

                AddContent(HTML.Form());
                GetTabs("Company", "Service");

                var companyID = GetCompanyID();

                VerticalPanel vpSummary = new VerticalPanel();
                vpSummary.AddAttribute("width", "100%");

                QuerySelect recQuery = GetQuery();
                recQuery.SQLCommand = $"Select dbo.ufn_GetAllocatedBackgroundChecks({companyID}) as nUnits ";
                recQuery.ExecuteReader();

                int allocation = 0;
                if (!recQuery.Eof())
                    allocation = Convert.ToInt32(recQuery.FieldValue("nUnits"));


                recQuery = GetQuery();
                recQuery.SQLCommand = $"Select dbo.ufn_GetAvailableBackgroundChecks({companyID}) as nUnits ";
                recQuery.ExecuteReader();

                int remaining = 0;
                if (!recQuery.Eof())
                    remaining = Convert.ToInt32(recQuery.FieldValue("nUnits"));

                string contents = "<table border=\"0\"><tr>";
                contents += "<tr><td width=\"100%\"><span class=\"VIEWBOXCAPTION\">Total Allocated Background Checks:&nbsp;</span><br/><span class=\"VIEWBOX\">" + allocation + "</span></td></tr>";
                contents += "<tr><td width=\"100%\"><span class=\"VIEWBOXCAPTION\">Remaining Background Checks:&nbsp;</span><br/><span class=\"VIEWBOX\">" + remaining + "</span></td></tr>";
                contents += "</table>";

                ContentBox cbGrid = new ContentBox();
                cbGrid.Title = $"<strong>Available Background Checks</strong><br/>";
                cbGrid.Inner = new HTMLString(contents);

                vpSummary.Add(cbGrid);
                AddContent(vpSummary.ToHtml());


                List backgroundCheckGrid = new List("PRBackgroundCheckAllocationGrid");
                backgroundCheckGrid.Title = "Background Check Allocations";
                backgroundCheckGrid.Filter = $"prbca_CompanyID={companyID}";

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(backgroundCheckGrid);

               
                string continueURL = Url("PRCompany/PRCompanyService.asp") + $"&T=Company&Capt=Services";
                AddUrlButton("Continue", "Continue.gif", continueURL);

                AddContent(vpMainPanel);
                AddContent(HTML.InputHidden("HiddenMode", string.Empty));

            }
            catch (Exception eX)
            {
                TravantLogMessage(eX.Message);
                AddContent(HandleException(eX));
            }
        }
    }
}
