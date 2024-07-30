/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, LLC. 2024-2024

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
    public class BusinessValuationRequestListing : CRMBase
    {
        public override void BuildContents()
        {
            try
            {
                SetRequestName("BusinessValuationRequestListing");

                AddContent(HTML.Form());

                EntryGroup filterBox = new EntryGroup("PRBusinessValuationSearchBox");
                filterBox.AddAttribute("width", "100%");
                filterBox.Title = "Filter Business Valuations";
                filterBox.GetHtmlInEditMode();

                string szFilter = filterBox.GetSqlForSearch();
                if (!string.IsNullOrEmpty(szFilter))
                    szFilter += " AND ";
                szFilter += "prbv_Deleted IS NULL";

                //TravantLogMessage($"filterBox.GetSqlForSearch(): {szFilter}");

                List businessValuationGrid = new List("PRBusinessValuationGrid");
                businessValuationGrid.Title = "Business Valuation Requests";
                businessValuationGrid.Filter = szFilter;

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(filterBox);
                vpMainPanel.Add(businessValuationGrid);

                AddContent(vpMainPanel);
                AddContent(HTML.InputHidden("HiddenMode", string.Empty));
    
                string saveURL = "javascript:document.EntryForm.HiddenMode.value='2';";
                AddSubmitButton("Filter", "Search.gif", saveURL);

                string clearURL = "javascript:$('#prbv_statuscode').val('sagecrm_code_all'); $('#prbv_createddate_start').val(''); $('#prbv_createddate_end').val(''); Clearprbv_companyid(); Clearprbv_personid(); document.EntryForm.HiddenMode.value='2';";
                                                                                                 
                AddSubmitButton("Clear", "Search.gif", clearURL);

                AddContent("<script>document.getElementById('EWARE_TOP').style='display:none;';</script>");
            }
            catch (Exception eX)
            {
                TravantLogMessage(eX.Message);
                AddContent(HandleException(eX));
            }
        }
    }
}