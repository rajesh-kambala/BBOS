<!-- #include file ="..\accpaccrm.js" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2021

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->

<%
    doPage();

function doPage()
{
    bDebug = false;

    var oppo_opportunityid = getIdValue("oppo_opportunityid");
    if (oppo_opportunityid == -1) {
        oppo_opportunityid = getIdValue("Key7");
    } else {
        var queryString =  "?" + new String(Request.QueryString);
        //queryString = changeKey(queryString, "Key0", "7");
        queryString = changeKey(queryString, "Key7", oppo_opportunityid);    
        queryString = removeKey(queryString, "oppo_opportunityid");
        
        if (queryString.indexOf("?") != 0) {
            queryString = "?" + queryString;
        }
        
        //Response.Write("<p>" + Request.ServerVariables("URL")+ queryString);
        Response.Redirect(Request.ServerVariables("URL")+ queryString);
        return;
    }


    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

    // TODO: Determine real security groups
    var sSecurityGroups = "1,2,3,4,5,6,7,8,9,10,11";

    var bNew = false;
    var recOpp = null;
    var oppoType = null;
    var oppoPPID = null;

    var sCurrentURL = eWare.URL("PROpportunity/PROpportunitySummary.asp") + "&Capt=Sales+Mgmt";

    if (oppo_opportunityid == -1) {
        bNew = true;
        oppoType = getIdValue("Type");
        recOpp = eWare.CreateRecord("Opportunity");

        // start this in edit mode
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
       
    } else {
        recOpp = eWare.FindRecord("Opportunity", "oppo_opportunityid=" + oppo_opportunityid);
        oppoType = recOpp.oppo_Type;
    } 

    oppoPPID = getIdValue("PPID");

    var blkSummary = null;
    switch(oppoType) {
         case "BP":
            blkSummary=eWare.GetBlock("PROpportunityBPAd");
            blkSummary.Title="Blueprints Ad Opportunity Summary";        
            blkSummary.GetEntry("oppo_PRTrigger").DefaultValue = "ISC";
            break;
         case "DA":
            blkSummary=eWare.GetBlock("PROpportunityDigitalAd");
            blkSummary.Title="Digital Ad Opportunity Summary";        
            blkSummary.GetEntry("oppo_PRTrigger").DefaultValue = "ISC";
            break;
         case "NEWM":
            blkSummary=eWare.GetBlock("PROpportunitySummary");
            blkSummary.Title="Opportunity Summary";
            blkSummary.GetEntry("oppo_PRTrigger").DefaultValue = "ISC";
            break;
         case "UPG":
            blkSummary=eWare.GetBlock("PROpportunitySummary");
            blkSummary.Title="Opportunity Summary";
            blkSummary.GetEntry("oppo_PRTrigger").DefaultValue = "CM";
     }

    blkSummary.GetEntry("oppo_Status").LookupFamily = "oppo_PRStatus";
    blkSummary.GetEntry("oppo_Status").OnChangeScript = "ToggleStatus();";
    blkSummary.GetEntry("oppo_Stage").LookupFamily = "oppo_PRStage";
    blkSummary.GetEntry("oppo_Stage").DefaultValue = "Opportunity";
    blkSummary.GetEntry("oppo_Type").ReadOnly = true;
    blkSummary.GetEntry("oppo_Opened").ReadOnly = true;
    blkSummary.GetEntry("oppo_Closed").ReadOnly = true;

    if (bNew) {
        // set the defaults for the screen (for edit) and the record (for saves)

        DEBUG("isEmpty(oppoPPID) = " + isEmpty(oppoPPID));
        DEBUG("oppoPPID = " + oppoPPID);
        if(!isEmpty(oppoPPID) && oppoPPID > 0) {
            blkSummary.GetEntry("oppo_assigneduserid").Hidden = true;
            blkSummary.GetEntry("oppo_PrimaryPersonId").Hidden = true;
            blkSummary.GetEntry("oppo_PRSecondaryPersonId").Hidden = true;
        }
        else
        {
            fld = blkSummary.GetEntry("oppo_assigneduserid");
            fld.defaultValue = user_userid;
        }   
        
        // These fields will be read-only; they do not need field defaults set
        // set the type to New Membership Opportunity
        recOpp.oppo_Type = oppoType;
        fld = blkSummary.GetEntry("oppo_Type").defaultValue = oppoType;

        recOpp.oppo_Status = "Open";
        recOpp.oppo_Opened = getDBDateTime();

        if (!isEmpty(comp_companyid) && oppoPPID > 0) 
        {
            if ((oppoType == "NEWM") ||
                (oppoType == "UPG")) {
                recOpp.oppo_PrimaryCompanyId = comp_companyid;
                oCompany1 = blkSummary.GetEntry("oppo_PrimaryCompanyId");
                oCompany1.DefaultValue = comp_companyid;
            }
        }
    }    

    if ((oppoType == "BP") || (oppoType == "DA")) {
        blkSummary.GetEntry("oppo_prlostreason").LookupFamily = "oppo_AdLostReason";
    } else {
        blkSummary.GetEntry("oppo_PRAdRun").Hidden = true;
        blkSummary.GetEntry("oppo_PRTargetStartYear").Hidden = true;
        blkSummary.GetEntry("oppo_PRTargetStartMonth").Hidden = true;
        blkSummary.GetEntry("oppo_PRAdRenewal").Hidden = true;
        blkSummary.GetEntry("oppo_SignedAuthReceivedDate").Hidden = true;    
    }

    if (oppoType == "NEWM") {

        blkSummary.GetEntry("oppo_PRType").LookupFamily = "oppo_PRType_Mem";
        blkSummary.GetEntry("oppo_Source").LookupFamily = "oppo_Source";
        blkSummary.GetEntry("oppo_PRPipeline").LookupFamily = "oppo_PRPipelineM";
        blkSummary.GetEntry("oppo_prlostreason").LookupFamily = "oppo_MembershipLostReason";
        blkSummary.GetEntry("oppo_PrimaryPersonId").Restrictor = "oppo_PrimaryCompanyId";
        blkSummary.GetEntry("oppo_PRSecondaryPersonId").Restrictor = "oppo_PrimaryCompanyId";
        blkSummary.GetEntry("oppo_Source").Required = true;
        blkSummary.GetEntry("oppo_PRPipeline").Required = true;
    } 

    if (oppoType == "UPG") {
        blkSummary.GetEntry("oppo_PRType").LookupFamily = "oppo_PRType_Upg";
        blkSummary.GetEntry("oppo_Source").Hidden = true;
        blkSummary.GetEntry("oppo_PRPipeline").LookupFamily = "oppo_PRPipelineU";
        blkSummary.GetEntry("oppo_prlostreason").LookupFamily = "oppo_UpgradeLostReason";
        blkSummary.GetEntry("oppo_PrimaryPersonId").Restrictor = "oppo_PrimaryCompanyId";
        blkSummary.GetEntry("oppo_PRSecondaryPersonId").Restrictor = "oppo_PrimaryCompanyId";    
        blkSummary.GetEntry("oppo_Source").Required = true;
        blkSummary.GetEntry("oppo_PRPipeline").Required = true;
    } 

    if (recOpp("oppo_PRWebUserID") > 0) {
        //blkSummary.GetEntry("oppo_PrimaryCompanyId").Hidden = true;
        blkSummary.GetEntry("oppo_PrimaryPersonId").Hidden = true;
        blkSummary.GetEntry("oppo_PRSecondaryPersonID").Hidden = true;
    }

    var blkContainer = eWare.GetBlock("Container");
    blkContainer.DisplayButton(Button_Default) = false;    
    
    // the listing can be from Company, User, or Team
    var sListingAction = eWare.Url("PROpportunity/PROpportunityListing.asp") + "&Capt=Sales+Mgmt";
    if ((recOpp.oppo_PRPipeline == "M:BBOS") &&
        (recOpp.oppo_PRWebUserID > 0)) {
        sListingAction = eWare.Url("PROpportunity/PROpportunityListingBBOSInquiry.asp") + "&Capt=Sales+Mgmt";

        if (getIdValue("Key4") != -1) {
            sListingAction = changeKey(sListingAction, "Key0", "4");
        }
    }

    var sSummaryAction = sCurrentURL;

    if (eWare.Mode == '99') {
        recOpp("oppo_status") = "Open";
        recOpp("oppo_prlostreason") = "";
        recOpp.SaveChanges();    
    
        Response.Redirect(changeKey(sSummaryAction, "em", View));
        return;
    }

    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkSummary);
    
    if (bNew )
    {
        blkSummary.ArgObj = recOpp;
    }

    if (eWare.Mode == Save)
    {
        blkContainer.Execute(recOpp); 

        
        sSQL = "SELECT ListingSpecalistID = dbo.ufn_GetPRCoSpecialistUserId(" + comp_companyid + ", 1)"
        recListingSpecalist = eWare.CreateQueryObj(sSQL);
        recListingSpecalist.SelectSQL();

        // perform the addition "defaulting" of values based upon what was entered.
        // have to save these dates manually because accpac will not save them because they were marked as readonly
        sDateValue = getFormValue("_HIDDENoppo_opened");
        if (sDateValue != null && sDateValue != "" && isValidDate(sDateValue))
        {
            dt = new Date(sDateValue);
            recOpp.oppo_Opened = getDBDateTime(dt);
        }    

        if(!isEmpty(oppoPPID) && oppoPPID > 0) {
            // Assign primary person id passed in
            recOpp.oppo_PrimaryPersonId = oppoPPID;
            //blkSummary.GetEntry("oppo_PrimaryPersonId").defaultValue = oppoPPID;

            if (!recListingSpecalist.eof) {
                recOpp.oppo_assigneduserid = recListingSpecalist("ListingSpecalistID");
            }
        }

        recOpp.SaveChanges();

        var recCommunication = null;

        if (bNew) {

            var subject = "Opportunity Note";
            var category = "SM";

            switch(oppoType) {
                case "BP":
                    subject = "Opportunity Note - Blueprints Advertising";
                    category = "FS";
                    break;
                case "DA":
                    subject = "Opportunity Note - Digital Advertising";
                    category = "FS";
                    break;
                case "NEWM":
                    subject = "Opportunity Note - Membership";
                    category = "SM";
                    break;
                case "UPG":
                    subject = "Opportunity Note - Upgrade";
                    category = "SM";
                    break;
            }

            recCommunication = eWare.CreateRecord("Communication");
            recCommunication.comm_DateTime = recOpp.oppo_Opened;
            recCommunication.comm_ToDateTime = recOpp.oppo_Opened;
            recCommunication.comm_Subject = subject;
            recCommunication.comm_Type = 'Task';
            recCommunication.comm_Action = 'Note';
            recCommunication.comm_Status = 'Pending';
            recCommunication.comm_Priority = 'Normal';
            recCommunication.comm_PRCategory = category;
       
        } else {

            recCommunication = eWare.FindRecord("Communication", "Comm_OpportunityId=" + oppo_opportunityid);
        }

        recCommunication.comm_Note = getIdValue("oppo_note");
        recCommunication.SaveChanges();

        if (bNew) {
            var recCommLink = eWare.CreateRecord("Comm_Link");
            recCommLink.cmli_Comm_CommunicationId = recCommunication("comm_CommunicationID");
            recCommLink.cmli_Comm_CompanyId = recOpp.oppo_PrimaryCompanyId;
            recCommLink.cmli_Comm_PersonId = recOpp.oppo_PrimaryPersonId;
            recCommLink.cmli_Comm_UserId = user_userid;

            // Assign to the sales rep
            if(!isEmpty(oppoPPID && oppoPPID > 0 && !recListingSpecalist.eof)) {
                recCommLink.cmli_Comm_UserId = recListingSpecalist("ListingSpecalistID");        
            }

            recCommLink.SaveChanges();
        }


        var redirectURL = changeKey(sCurrentURL, "Key7", recOpp("oppo_opportunityid"));
        redirectURL = changeKey(redirectURL, "Key1", recOpp("oppo_PrimaryCompanyId"));

        Response.Redirect(redirectURL);
        return;
    } 
    
    
    if (eWare.Mode == View) 
    {
        if (isUserInGroup(sSecurityGroups ))
        {
            blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

            sSummaryAction = changeKey(sSummaryAction, "Key7", recOpp("oppo_opportunityid"))
            blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
            
            if ((recOpp.oppo_PRPipeline == "M:BBOS") &&
                (recOpp.oppo_PRWebUserID > 0) &&  
                (recOpp.oppo_PrimaryCompanyId == 0)) 
            {
                blkContainer.AddButton(eWare.Button("New Company","NewCompany.gif", eWare.Url("PRCompany/PRCompanyNew.asp") + "&oppo_OpportunityID=" + recOpp("oppo_opportunityid")));
            }


            if (recOpp.oppo_Status == "Closed") {
                var sURL = changeKey(sSummaryAction, "em", "99");
                blkContainer.AddButton(eWare.Button("Reopen","new.gif","javascript:document.EntryForm.action='" + sURL + "';document.EntryForm.submit();"));
            }            
        }

        if (recOpp("oppo_PRWebUserID") > 0) {
            var blkWebUser = eWare.GetBlock("PRWebUserInfo");
            var recWebUser = eWare.FindRecord("vPRWebUser", "prwu_WebUserId=" + recOpp("oppo_PRWebUserID"));
            blkWebUser.ArgObj = recWebUser;
            blkWebUser.Title="Web User";
            blkContainer.AddBlock(blkWebUser);
        }

        if (bNew == true)
        {
            eWare.AddContent(blkContainer.Execute()); 
            Response.Write(eWare.GetPage("new"));
        } else {
            blkSummary.ArgObj = recOpp;
            eWare.AddContent(blkContainer.Execute()); 
            Response.Write(eWare.GetPage("Opportunity"));
        }
    } 
    else if (eWare.Mode == Edit)
    {
        Response.Write("<script type=\"text/javascript\" src=\"PROpportunitySummary.js\"></script>");
        
        if (bNew)
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        else
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));

        if (isUserInGroup(sSecurityGroups ))
            blkContainer.AddButton(eWare.Button("save", "save.gif", "javascript:save();"));

        if (bNew)
        {
            eWare.AddContent(blkContainer.Execute()); 
        } else {
            eWare.AddContent(blkContainer.Execute(recOpp)); 
        }
        
        Response.Write(eWare.GetPage("New"));
    }    

%>
        <script type="text/javascript">
            var isWebUserOppo = false;
            function initBBSI() {
<%
                if (eWare.Mode == Edit) {
                    Response.Write("initializeKeypressFunctions();\n");

                    Response.Write("ToggleStatus();\n");
                    Response.Write("RemoveDropdownItemByName('oppo_status', '--None--');\n");
                    Response.Write("RemoveDropdownItemByName('oppo_stage', '--None--');\n");
                    Response.Write("document.getElementById('oppo_forecast_CID').style.display = 'none';\n");


                    if (oppoType == "BP") {
                        Response.Write("toggleTrigger();\n");
                    }

                    if (recOpp("oppo_PRWebUserID") > 0) {
                        Response.Write("isWebUserOppo = true;\n");

                        if (recOpp.oppo_PrimaryCompanyId == 0) {
                            Response.Write("document.getElementById('oppo_primarycompanyid').value = '0';\n");
                        }
                    }
                }

                if (oppoType == "BP") {
                    Response.Write("InsertWhiteSpaceDivider('wsdiv01', '_Captoppo_pradsize');\n");
                    Response.Write("InsertWhiteSpaceDivider('wsdiv03', '_Captoppo_prtargetstartyear');\n");
                } else if (oppoType == "DA") {
                    Response.Write("InsertWhiteSpaceDivider('wsdiv01', '_Captoppo_prtargetstartyear');\n");
                    Response.Write("InsertWhiteSpaceDivider('wsdiv03', '_Captoppo_prdigitalplacement');\n");
                } else {
                    Response.Write("InsertWhiteSpaceDivider('wsdiv01', '_Captoppo_prpipeline');\n");
                    Response.Write("InsertWhiteSpaceDivider('wsdiv03', '_Captoppo_prreferredbycompanyid');\n");
                }
%>
                initializePage();
            }

            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }


            function InsertWhiteSpaceDivider(sDividerID, sInsertBefore)
            {
                var tblNonVisible = document.getElementById("tblNonVisible");
                if (tblNonVisible == null)
                {
                    divNonVisible = document.createElement("DIV");
                    divNonVisible.innerHTML = ("<table style=\"display:none;\" ID=\"tblNonVisible\">" +
                                "<tr ID=\"tr_" + sDividerID + "\">"+
                                "<td colspan=\"10\"><hr /></td></tr>" + 
                                "</table>");
                    document.body.appendChild(divNonVisible);
                }
                else
                {
                    newTR = document.createElement("TR");
                    newTR.id = "tr_" + sDividerID;
                    var newTD = document.createElement("TD");
                    newTD.colSpan = 10;
                    newTD.innerHTML = "<hr />";
                    newTR.insertBefore(newTD, null)
                    tblNonVisible.insertBefore(newTR, null);
                }
                InsertRow(sInsertBefore, "tr_"+sDividerID);

            }            
        </script>
<%
}

Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>