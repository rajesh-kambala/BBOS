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
    public class BackgroundCheckListing: CompanyBase
    {
        public override void BuildContents()
        {
            try
            {
                SetRequestName("BackgroundCheckListing");

                AddContent(HTML.Form());
                GetTabs("Company", "Background Checks");

                var companyID = GetCompanyID();

                List backgroundCheckGrid = new List("PRBackgroundCheckGrid");
                backgroundCheckGrid.Title = "Background Checks";
                backgroundCheckGrid.Filter = $"prbc_SubjectCompanyID={companyID}";

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(backgroundCheckGrid);

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
