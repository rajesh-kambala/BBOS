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
    public class BackgroundCheckRequestListing : CRMBase
    {
        public override void BuildContents()
        {
            try
            {
                SetRequestName("BackgroundCheckRequestListing");

                AddContent(HTML.Form());

                EntryGroup filterBox = new EntryGroup("PRBackgroundCheckRequestSearchBox");
                filterBox.AddAttribute("width", "100%");
                filterBox.Title = "Filter Background Checks";
                filterBox.GetHtmlInEditMode();

                string szFilter = filterBox.GetSqlForSearch();

                //TravantLogMessage($"filterBox.GetSqlForSearch(): {szFilter}");

                List backgroundCheckRequestGrid = new List("PRBackgroundCheckRequestGrid");
                backgroundCheckRequestGrid.Title = "Background Check Requests";
                backgroundCheckRequestGrid.Filter = szFilter;

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(filterBox);
                vpMainPanel.Add(backgroundCheckRequestGrid);

                AddContent(vpMainPanel);
                AddContent(HTML.InputHidden("HiddenMode", string.Empty));

                string saveURL = "javascript:document.EntryForm.HiddenMode.value='2';";
                AddSubmitButton("Filter", "Search.gif", saveURL);

                string clearURL = "javascript:$('#prbcr_statuscode').val('sagecrm_code_all'); $('#prbcr_requestdatetime_start').val(''); $('#prbcr_requestdatetime_end').val(''); document.EntryForm.HiddenMode.value='2';";
                AddSubmitButton("Clear", "Search.gif", clearURL);

                AddContent("<script>document.getElementById('EWARE_TOP').style='display:none;';</script>");

                string sentRequestID = Dispatch.EitherField("sr");
                if (!string.IsNullOrEmpty(sentRequestID))
                {
                    Record recBackgroundCheckRequest = FindRecord("PRBackgroundCheckRequest", "prbcr_BackgroundCheckRequestID = " + sentRequestID);

                    QuerySelect recPersonEmail = GetQuery();
                    recPersonEmail.SQLCommand = $"SELECT emai_EmailAddress FROM vPRPersonEmail WHERE ELink_RecordID={recBackgroundCheckRequest.GetFieldAsInt("prbcr_RequestingPersonD")} AND emai_CompanyID={recBackgroundCheckRequest.GetFieldAsInt("prbcr_RequestingCompanyID")}";
                    recPersonEmail.ExecuteReader();
                    string personEmail = recPersonEmail.FieldValue("emai_EmailAddress");

                    AddContent($"<script>alert('The background check business report has been sent to { personEmail}.');</script>");
                }


            }
            catch (Exception eX)
            {
                TravantLogMessage(eX.Message);
                AddContent(HandleException(eX));
            }
        }
    }
}
