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
    public class MyCRMInteraction : CRMBase
    {
        public override void BuildContents()
        {
            try
            {
                SetRequestName("MyCRMInteraction");
                //TravantLogMessage($"Begin BuildContents");

                AddContent(HTML.Form());
                AddContent("<script type=\"text/javascript\" src=\"/crm/CustomPages/PRCoGeneral.js\"></script>");
                AddContent("<Link rel=\"stylesheet\" href=\"/crm/prco.css\">");

                EntryGroup filterBox = new EntryGroup("PRCommunicationListFilter");
                filterBox.AddAttribute("width", "100%");
                filterBox.Title = "Filter My CRM Interactions";
                filterBox.GetEntry("cmli_comm_userid").DefaultValue = CurrentUser.UserId.ToString();
                filterBox.GetHtmlInEditMode();

                string szFilter = filterBox.GetSqlForSearch();
                szFilter = szFilter.Replace("LIKE N'", "LIKE N'%"); //wildcard search
                //TravantLogMessage($"filterBox.GetSqlForSearch(): {szFilter}");

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(filterBox);
                vpMainPanel.Add(BuildCompanyInteractionListingGrid(szFilter));
                AddContent(vpMainPanel.ToHtml());

                AddContent(HTML.InputHidden("HiddenMode", string.Empty));
                AddContent(HTML.InputHidden("HIDDENORDERBY", _sortBy));
                AddContent(HTML.InputHidden("HIDDENORDERBYDESC", _sortDesc));

                AddButtonContent(BuildDragAndDrop_PRInteraction());

                string saveURL = "javascript:document.EntryForm.HiddenMode.value='2';";
                AddSubmitButton("Filter", "Search.gif", saveURL);
                AddUrlButton("Clear", "Cancel.gif", UrlDotNet(ThisDotNetDll, "RunMyCRMInteractionListing") + "&Clear=Y");

                string szNewInteractionUrl = Url("PRGeneral/PRInteraction.asp") + $"&comm_communicationid=-1";
                szNewInteractionUrl = RemoveKey(szNewInteractionUrl, "Key6");
                AddUrlButton("New Interaction", "New.gif", szNewInteractionUrl);

                AddButtonContent("<script>hideMyCRM();</script>");
                //TravantLogMessage($"End BuildContents");
            }
            catch (Exception eX)
            {
                AddContent(HandleException(eX));
            }
        }

        private ContentBox BuildCompanyInteractionListingGrid(string szFilter)
        {
            string selectSQL = $"SELECT * FROM vListCommunication2 WHERE comm_status='Pending'";
            if (!string.IsNullOrEmpty(szFilter))
                selectSQL += " AND " + szFilter;
            return BuildInteractionListingGrid(selectSQL, CurrentUser.UserId.ToString(), true, "comm_datetime", false);
        }
    }
}
