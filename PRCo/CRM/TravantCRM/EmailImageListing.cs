/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2020-2022

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, Inc.  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.Text;
using Sage.CRM.Blocks;
using Sage.CRM.Controls;
using Sage.CRM.Data;
using Sage.CRM.HTML;
using Sage.CRM.Utils;
using Sage.CRM.WebObject;
using Sage.CRM.UI;

namespace BBSI.CRM
{
    public class EmailImageListing : CRMBase
    {
        public override void BuildContents()
        {
            try
            {
                SetRequestName("EmailImageListing");

                AddContent(HTML.Form());

                EntryGroup filterBox = new EntryGroup("PREmailImagesListFilter");
                filterBox.AddAttribute("width", "100%");
                filterBox.Title = "Filter Email Images";
                filterBox.GetHtmlInEditMode();

                string szFilter = filterBox.GetSqlForSearch();
                if (!string.IsNullOrEmpty(szFilter))
                    szFilter += " AND ";
                szFilter += "prei_Deleted IS NULL";

                TravantLogMessage($"filterBox.GetSqlForSearch(): {szFilter}");

                List emailImageGrid = new List("EmailImageGrid");
                emailImageGrid.Title = "Email Images";
                emailImageGrid.Filter = szFilter;

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(filterBox);
                vpMainPanel.Add(emailImageGrid);

                AddContent(vpMainPanel);
                AddContent(HTML.InputHidden("HiddenMode", string.Empty));

                string saveURL = "javascript:document.EntryForm.HiddenMode.value='2';";
                AddSubmitButton("Filter", "Search.gif", saveURL);

                string clearURL = "javascript:$('#prei_emailtypecode').val('sagecrm_code_all'); $('#prei_startdate_start').val(''); $('#prei_startdate_end').val(''); document.EntryForm.HiddenMode.value='2';";
                AddSubmitButton("Clear", "Search.gif", clearURL);

                AddUrlButton("New Email Image", "New.gif", UrlDotNet(ThisDotNetDll, "RunEmailImage") + "&prei_EmailImageID=0");
            }
            catch (Exception eX)
            {
                TravantLogMessage(eX.Message);
                AddContent(HandleException(eX));
            }
        }
    }
}
