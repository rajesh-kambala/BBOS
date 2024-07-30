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
    public class PersonInteraction : PersonBase
    {
        public override void BuildContents()
        {
            try
            {
                SetRequestName("PersonInteractionListing");
                //TravantLogMessage($"Begin BuildContents");

                var personID = GetPersonID();

                GetTabs("Person", "Interactions");
                AddContent(HTML.Form());
                AddContent("<script type=\"text/javascript\" src=\"/crm/CustomPages/PRCoGeneral.js\"></script>");
                AddContent("<Link rel=\"stylesheet\" href=\"/crm/prco.css\">");

                EntryGroup filterBox = new EntryGroup("PRCommunicationListFilter");
                filterBox.AddAttribute("width", "100%");
                filterBox.Title = "Filter Interactions";
                filterBox.GetHtmlInEditMode();

                string szFilter = filterBox.GetSqlForSearch();
                szFilter = szFilter.Replace("LIKE N'", "LIKE N'%"); //wildcard search
                TravantLogMessage($"filterBox.GetSqlForSearch(): {szFilter}");

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(filterBox);
                vpMainPanel.Add(BuildPersonInteractionListingGrid(szFilter));
                AddContent(vpMainPanel.ToHtml());

                AddContent(HTML.InputHidden("HiddenMode", string.Empty));
                AddContent(HTML.InputHidden("HIDDENORDERBY", _sortBy));
                AddContent(HTML.InputHidden("HIDDENORDERBYDESC", _sortDesc));

                AddButtonContent(BuildDragAndDrop_PRInteraction());

                string saveURL = "javascript:document.EntryForm.HiddenMode.value='2';";
                AddSubmitButton("Filter", "Search.gif", saveURL);

                string clearScript = "$('#comm_datetime_start').val(''); $('#comm_datetime_end').val(''); $('#cmli_comm_useridInput').val(''); $('#comm_subject').val(''); $('#cmli_comm_userid').val($('#cmli_comm_userid option:first').val()); $('#cmli_comm_userid option').filter(function() { return $(this).text() == '--All--'; }).prop('selected', true);";
                string clearURL = $"javascript:{clearScript}; document.EntryForm.HiddenMode.value='2';";
                AddSubmitButton("Clear", "Cancel.gif", clearURL);

                //AddUrlButton("Clear", "Cancel.gif", UrlDotNet(ThisDotNetDll, "RunPersonInteractionListing") + "&Clear=Y");

                //AddUrlButton("New Interaction", "New.gif", Url("361"));
                string szNewInteractionUrl = Url("PRGeneral/PRInteraction.asp") + $"&comm_communicationid=-1";
                szNewInteractionUrl = RemoveKey(szNewInteractionUrl, "Key6");
                AddUrlButton("New Interaction", "New.gif", szNewInteractionUrl);

                string reportURL = Metadata.GetTranslation("SSRS", "URL");
                reportURL += Metadata.GetTranslation("SSRS", "ArchiveInteractionSummary");
                reportURL += $"&PersonID={personID}&rc:Parameters=false";
                AddUrlButton("Archived Interactions Report", "New.gif", $"javascript:ViewReport('{reportURL}');");

                //TravantLogMessage($"End BuildContents");
                
                //Defect 6948 - always clear out filter criteria
                string crmReadyClear = $"crm.ready( function() {{{clearScript}}});";
                AddHeaderScript(crmReadyClear);
            }
            catch (Exception eX)
            {
                AddContent(HandleException(eX));
            }
        }

        private ContentBox BuildPersonInteractionListingGrid(string szFilter="")
        {
            var personID = GetPersonID();
            string selectSQL = $"SELECT * FROM vListCommunication2 WHERE pers_PersonID={personID}";
            if (!string.IsNullOrEmpty(szFilter))
                selectSQL += " AND " + szFilter;
            return BuildInteractionListingGrid(selectSQL);
        }
    }
}
