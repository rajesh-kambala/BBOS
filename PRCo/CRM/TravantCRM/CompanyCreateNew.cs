/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2020

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
using System.Configuration;
using System.Data.SqlClient;

namespace BBSI.CRM
{
    public class CompanyCreateNew: CompanyBase
    {

        public override void BuildContents()
        {
            try
            {
                SetRequestName("CompanyCreateNew");
                //TravantLogMessage($"Begin BuildContents");

                var companyID = GetCompanyID();

                GetTabs("Company", "Summary");
                AddContent(HTML.Form());
                AddContent("<script type='text/javascript' src='/crm/CustomPages/TravantCRMScripts/CompanyCreateNew.js'></script>");
                AddContent("<script type=\"text/javascript\" src=\"/crm/CustomPages/PRCoGeneral.js\"></script>");
                AddContent("<Link rel=\"stylesheet\" href=\"/crm/prco.css\">");
                AddContent("<div style='font-weight:700; margin-bottom:12px;'>Create New Company</div>");

                string hMode = Dispatch.EitherField("HiddenMode");

                if (hMode == "Save")
                {
                    string optRecordType = Dispatch.EitherField("optRecordType");
                    string sourceId = Dispatch.EitherField("sourceId");

                    int iResult;
                    if (optRecordType == "1")
                    {
                        //HQ Save
                        iResult = ReplicateCompany(companyID);
                    }
                    else
                    {
                        //Branch Save
                        int iSourceId = Convert.ToInt32(sourceId);

                        Record SourceCompany = FindRecord("Company", $"comp_CompanyId={iSourceId}");
                        if (SourceCompany.Eof())
                        {
                            AddContent($"<span style='color:red'>Invalid Source ID {iSourceId}</span><br><br>");
                            iResult = 0;
                        }
                        else
                        {
                            iResult = ReplicateCompany(companyID, iSourceId);
                        }
                    }

                    if (iResult > 0)
                    {
                        TravantLogMessage($"Created new record {iResult}");
                        string szUrl = Url("PRCompany/PRCompanySummary.asp");
                        szUrl = ChangeKey(szUrl, "Key1", iResult.ToString());

                        Dispatch.Redirect(szUrl); //Take user to new record
                    }
                    else
                    {
                        TravantLogMessage($"Failed to create new record.");
                    }
                }

                VerticalPanel vpMainPanel = new VerticalPanel();
                vpMainPanel.AddAttribute("width", "100%");
                vpMainPanel.Add(BuildContent());
                AddContent(vpMainPanel.ToHtml());

                AddContent(HTML.InputHidden("HiddenMode", string.Empty));
                AddContent(HTML.InputHidden("HIDDENORDERBY", _sortBy));
                AddContent(HTML.InputHidden("HIDDENORDERBYDESC", _sortDesc));

                //AddButtonContent(BuildDragAndDrop_PRInteraction());

                AddUrlButton("Save", "Save.gif", "javascript:save();");
                AddUrlButton("Cancel", "Cancel.gif", Url("PRCompany/PRCompanySummary.asp"));

                //TravantLogMessage($"End BuildContents");
            }
            catch (Exception eX)
            {
                AddContent(HandleException(eX));
            }
        }

        protected int ReplicateCompany(int companyID)
        {
            return ReplicateCompany(companyID, 0);
        }

        protected int ReplicateCompany(int companyID, int sourceId)
        {
            int retVal = 0;

            var user_userid = GetContextInfo("User", "User_UserId");

            const string SQL_REPLICATE_BRANCH = @"EXEC dbo.usp_ReplicateCompany {0}, {1}";
            const string SQL_REPLICATE_HQ = @"EXEC dbo.usp_ReplicateCompany {0}";

            int iCompanyId_Old = 0;
            string szComp_Name_Old = "";
            var recCompanyOld = FindRecord("Company", "comp_CompanyID=" + companyID);
            if (!recCompanyOld.Eof())
            {
                iCompanyId_Old = recCompanyOld.GetFieldAsInt("comp_CompanyId");
                szComp_Name_Old = recCompanyOld.GetFieldAsString("comp_Name");
            }
            else
            {
                AddContent($"Invalid source BBID #{iCompanyId_Old}<br>");
                TravantLogMessage($"Invalid source BBID #{iCompanyId_Old}");
            }

            QuerySelect recReplicateCompany = new QuerySelect();
            if (sourceId == 0)
            {
                recReplicateCompany.SQLCommand = $"{string.Format(SQL_REPLICATE_HQ, companyID)}";
            }
            else
            {
                recReplicateCompany.SQLCommand = $"{string.Format(SQL_REPLICATE_BRANCH, companyID, sourceId)}";
            }

            TravantLogMessage($"recReplicationCompany.SQLCommand = {recReplicateCompany.SQLCommand}");
            recReplicateCompany.ExecuteReader();

            string szFind = "comp_Name='" + szComp_Name_Old.Replace("'", "''") + "' AND comp_CreatedDate > DATEADD(second, -10, GETDATE())"; //10 seconds back
            TravantLogMessage($"szFind = {szFind}");

            var recCompanyNew = FindRecord("Company", szFind);
            if (!recCompanyNew.Eof())
            {
                retVal = recCompanyNew.GetFieldAsInt("comp_companyid");
                TravantLogMessage($"Replicated to new BBID {retVal}");

                //Automatically open a new transaction on the new company
                QuerySelect recOpenTransaction = new QuerySelect();
                recOpenTransaction.SQLCommand = $"EXEC usp_CreateTransaction @UserId={user_userid}, @prtx_CompanyId={retVal}, @prtx_Explanation='Transaction created by Company Replication from BBID {companyID}'";
                recOpenTransaction.ExecuteReader();
            }
            else
            {
                retVal = 0;
            }

            TravantLogMessage($"retVal={retVal}");
            return retVal;
        }

        private ContentBox BuildContent()
        {
            ContentBox cbContent = new ContentBox();
            
            var sChoices = @"
                            <table class='CONTENT'>
                                <tr class='CONTENT'>
                                    <td width='1px' class='TABLEBORDERLEFT'>
                                    <td height='100%' width='100%' class='VIEWBOXCAPTION'>
                                        Would you like to create an HQ record or a Branch record?
                                    </td>
                                </tr>

                                <tr class='CONTENT'>
                                    <td width='1px' class='TABLEBORDERLEFT'>
                                    <td height='100%' width='100%' class='VIEWBOXCAPTION'>
                                        <INPUT type=radio name='optRecordType' onclick='onOptRecordTypeClick()' value='1' ><span valign=top class=viewboxcaption>HQ Record</span></INPUT>
                                        <INPUT type=radio name='optRecordType' onclick='onOptRecordTypeClick()' value='2' ><span valign=top class=viewboxcaption>Branch Record</span></INPUT>
                                    </td>
                                </tr>

                                <tr class='CONTENT'><td width='1px' class='TABLEBORDERLEFT'><td height='100%' width='100%' class='VIEWBOXCAPTION'>&nbsp;</td></tr>
                                <tr class='CONTENT trSource' style='display: none;'>
                                    <td width='1px' class='TABLEBORDERLEFT'>
                                    <td height='100%' width='100%' class='VIEWBOXCAPTION'>
                                        Source ID <input type='text' id='sourceId' name='sourceId'  />
                                     </td>
                                </tr>

                                <tr class='CONTENT'><td width='1px' class='TABLEBORDERLEFT'><td height='100%' width='100%' class='VIEWBOXCAPTION'>&nbsp;</td></tr>

                            </table>";

            // Needed to prevent <enter> from submitting the form.
            sChoices += "<div style=display:none;><input type=text id=dummy /></div>";

            var companyID = GetCompanyID();
            sChoices += $"<input type='hidden' id='hidCompanyId' value='{companyID}'>";
            cbContent.Inner = new HTMLString(sChoices);

            return cbContent;
        }
    }
}
